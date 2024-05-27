import { convert } from "pinyin-pro";
import { readFileSync, writeFileSync } from "fs";

const data = readFileSync("pinyin-data/pinyin.txt", "utf-8").trim().split("\n");
const dict: [string, string][] = [];

for (const line of data) {
  if (line.startsWith("#")) continue;
  const [code, pinyins] = line.split("#")[0]!.split(":");
  const pinyin_list = pinyins.trim().split(",");
  const char = String.fromCodePoint(parseInt(code.trim().slice(2), 16));
  for (const pinyin of pinyin_list) {
    const normalized = convert(pinyin, { format: "symbolToNum" });
    dict.push([char, normalized]);
  }
}

const header = readFileSync("snow/unihan.dict.yaml", "utf-8");
const content =
  header + dict.map(([char, pinyin]) => `${char}\t${pinyin}`).join("\n") + "\n";
writeFileSync("snow_pinyin.unihan.dict.yaml", content);
