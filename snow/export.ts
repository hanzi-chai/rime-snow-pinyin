import { readFileSync, writeFileSync } from "fs";

const primitive = readFileSync("code.txt", "utf8")
  .split("\n")
  .map((x) => x.split("\t"))
  .filter((x) => x[3]);

primitive.sort((a, b) => {
  const [ashort, aidx] = [a[3], a[4]];
  const [bshort, bidx] = [b[3], b[4]];
  if (ashort === bshort) {
    return parseInt(aidx) - parseInt(bidx);
  }
  return ashort.localeCompare(bshort);
});

let final = primitive.map((x) => {
  const [name, _, __, short] = x;
  let actual = short;
  if (/^[bpmfdtnlgkhjqxzcsrywv]{1,3}$/.test(short)) {
    actual += "_";
  }
  return [actual, name];
});

final = [[";", "的"], ["/", "了"], ...final];

writeFileSync("dazhu.txt", final.map((x) => x.join("\t")).join("\n"));
