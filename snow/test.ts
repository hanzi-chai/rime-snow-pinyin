import { pinyin, addDict } from 'pinyin-pro';
import CompleteDict from '@pinyin-pro/data/complete.json';
addDict(CompleteDict);
pinyin('连杆式', { toneType: 'none' });
