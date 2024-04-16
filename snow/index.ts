import { pinyin, addDict } from 'pinyin-pro';
import { readFileSync, writeFileSync } from 'fs';
import CompleteDict from '@pinyin-pro/data/complete.json';

addDict(CompleteDict);

const dictDir = '../ice/cn_dicts/';

const base = readFileSync(dictDir + 'base.dict.yaml', 'utf-8');
const diff: string[][] = [];

for (const line of base.split('\n')) {
  if (line.startsWith('#')) continue;
  if (!line.includes('\t')) continue;
  const [word, simp_pinyin, _] = line.split('\t');
  try {
    const ref_pinyin = pinyin(word, { toneType: 'none', v: true });
    if (simp_pinyin !== ref_pinyin) {
      diff.push([word, simp_pinyin, ref_pinyin]);
    }
  } catch (e) {
    console.error(line);
  }
}

// write diff to file

writeFileSync('diff.txt', diff.map(([word, simp_pinyin, ref_pinyin]) => `${word}\t${simp_pinyin}\t${ref_pinyin}`).join('\n') + '\n', 'utf-8');
