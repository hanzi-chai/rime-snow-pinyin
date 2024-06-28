import { convert } from "pinyin-pro";
import { readFileSync, writeFileSync } from "fs";

const tygfPinyin = readFileSync("snow/tygf.txt", "utf-8").trim().split("\n");
const extendedPinyin = readFileSync("pinyin-data/pinyin.txt", "utf-8")
  .trim()
  .split("\n");
const extended: [string, string, number][] = [];

const numbers = [
  "ling2",
  "yi1",
  "er4",
  "san1",
  "si4",
  "wu3",
  "liu4",
  "qi1",
  "ba1",
  "jiu3",
  "shi2",
];

const specialFix = {
  m̄: "m1",
  hm: "hm5",
  ê̄: "ê1",
  ế: "ê2",
  ê̌: "ê3",
  ề: "ê4",
};

for (const line of extendedPinyin) {
  if (line.startsWith("#")) continue;
  const [code_str, pinyins] = line.split("#")[0]!.split(":");
  const code = parseInt(code_str.trim().slice(2), 16);
  const pinyin_list = pinyins.trim().split(",");
  const char = String.fromCodePoint(code);
  const weight = 0x4e00 <= code && code <= 0x9fff ? 1 : 0;
  for (const pinyin of pinyin_list) {
    if (pinyin in specialFix) {
      extended.push([char, specialFix[pinyin], weight]);
      continue;
    }
    const normalized = convert(pinyin, { format: "symbolToNum" })
      .replace("ü", "v")
      .replace("0", "5");
    extended.push([char, normalized, weight]);
  }
}

const knownPinyin = new Map<string, string[]>();
let extraCount = 0;

const content = readFileSync("snow/dict.yaml", "utf-8").split("\n");
content.push("# 字母");
content.push(
  "# 用 ~ 和 ~~ 作为特殊音节的标记，具体如何输入可以由方案自行决定，不影响简拼"
);
for (const letter of "abcdefghijklmnopqrstuvwxyz") {
  content.push(`${letter}\t~${letter}`);
}
content.push("");
for (const letter of "abcdefghijklmnopqrstuvwxyz") {
  content.push(`${letter.toUpperCase()}\t~~${letter}`);
}
content.push("");
content.push("# 数字");
for (const [index, number] of numbers.entries()) {
  content.push(`${index}\t${number}`);
}
content.push("");
content.push("#《通用规范汉字字典》");
for (const line of tygfPinyin) {
  let [char, pinyin, frequency] = line.split("\t");
  if (parseInt(frequency) < 2) {
    frequency = "2";
  }
  content.push(`${char}\t${pinyin}\t${frequency}`);
  knownPinyin.set(char, (knownPinyin.get(char) || []).concat(pinyin));
}
content.push("");
content.push("# 大字集");
extended.forEach(([char, normalized, weight]) => {
  if (knownPinyin.has(char)) {
    if (knownPinyin.get(char)!.includes(normalized)) {
      return;
    }
    extraCount++;
    console.log(`Extra: ${char} ${normalized}`);
  }
  content.push(`${char}\t${normalized}\t${weight}`);
});
writeFileSync("snow_pinyin.dict.yaml", content.join("\n"));

console.log(`Extra: ${extraCount}`);