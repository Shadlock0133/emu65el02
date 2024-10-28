use std::{collections::BTreeMap, env, fs};

fn main() {
    let file = fs::read_to_string(env::args_os().nth(1).unwrap()).unwrap();
    let map: BTreeMap<u16, &str> = file
        .lines()
        .map(|x| {
            let (name, v) = x.split_once("  =$").unwrap();
            let addr = u16::from_str_radix(
                v.split_once(";").map(|x| x.0).unwrap_or(v),
                16,
            )
            .unwrap();
            (addr, name)
        })
        .collect();
    for (name, addr) in map {
        println!("{addr}  =${name:04x}");
    }
}
