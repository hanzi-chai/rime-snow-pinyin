import { readFileSync, writeFileSync } from "fs";

const base = readFileSync("snow_pinyin.base.dict.yaml", "utf-8");
const frequency = readFileSync("../libchai/assets/frequency.txt", "utf-8");

const freqMap: Map<string, number> = new Map();

for (const line of frequency.split("\n")) {
  const [word, freq] = line.split("\t");
  freqMap.set(word, parseInt(freq, 10));
}

const dictionary: [string, string][] = [];

for (const line of base.split("\n")) {
  if (line.startsWith("#")) continue;
  if (!line.includes('\t')) continue;

  const [word, pinyin] = line.split("\t");
  dictionary.push([word, pinyin]);
}

dictionary.sort((a, b) => {
  const freqA = freqMap.get(a[0]) ?? 0;
  const freqB = freqMap.get(b[0]) ?? 0;
  return freqB - freqA;
});

writeFileSync("dictionary.txt", dictionary.map(([word, pinyin]) => `${word}\t${pinyin}`).join("\n") + "\n", "utf-8");
