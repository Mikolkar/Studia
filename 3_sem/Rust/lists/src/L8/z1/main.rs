fn interpreter(code: &str, iterations: usize, width: usize, height: usize) -> String {
    
    fn grid_to_string(grid: &Vec<Vec<u8>>) -> String {
    let rows_as_strings: Vec<String> = grid.iter()
        .map(|row| {
            let row_as_string: String = row.iter()
                .map(|&cell| if cell == 0 { '0' } else { '1' })
                .collect();
            row_as_string
        })
        .collect();
    let grid_as_string = rows_as_strings.join("\r\n");
    grid_as_string
}
    
    let mut grid = vec![vec![0; width]; height];
    let mut x = 0;
    let mut y = 0;
    let mut iter_count = 0;
    let code_chars: Vec<char> = code.chars().collect();
    let mut i = 0;
    let mut stack = Vec::new();

    while i < code_chars.len() && iter_count < iterations {
        match code_chars[i] {
            'n' => { y = if y == 0 { height - 1 } else { y - 1 }; iter_count += 1; },
            'e' => { x = (x + 1) % width; iter_count += 1; },
            's' => { y = (y + 1) % height; iter_count += 1; },
            'w' => { x = if x == 0 { width - 1 } else { x - 1 }; iter_count += 1; },
            '*' => { grid[y][x] ^= 1; iter_count += 1; },
            '[' => {
                if grid[y][x] == 0 {
                    let mut bracket_count = 1;
                    while bracket_count != 0 {
                        i += 1;
                        if code_chars[i] == '[' { bracket_count += 1; }
                        if code_chars[i] == ']' { bracket_count -= 1; }
                    }
                } else {
                    stack.push(i);
                }
                iter_count += 1;
            },
            ']' => {
                if grid[y][x] != 0 {
                    i = *stack.last().unwrap();
                } else {
                    stack.pop();
                }
                iter_count += 1;
            },
            _ => {}
        }
        i += 1;
    }

    let result = grid_to_string(&grid);
    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn simple_cases() {
        assert_eq!(display_actual(&interpreter("*e*e*e*es*es*ws*ws*w*w*w*n*n*n*ssss*s*s*s*", 0, 6, 9)), display_expected("000000\r\n000000\r\n000000\r\n000000\r\n000000\r\n000000\r\n000000\r\n000000\r\n000000"), "Your interpreter should initialize all cells in the datagrid to 0");
    }

    #[test]
    fn simple_case_1() {
        assert_eq!(display_actual(&interpreter("*e*e*e*es*es*ws*ws*w*w*w*n*n*n*ssss*s*s*s*", 7, 6, 9)), display_expected("111100\r\n000000\r\n000000\r\n000000\r\n000000\r\n000000\r\n000000\r\n000000\r\n000000"), "Your interpreter should adhere to the number of iterations specified");
    }

    #[test]
    fn simple_case_2() {
        assert_eq!(display_actual(&interpreter("*e*e*e*es*es*ws*ws*w*w*w*n*n*n*ssss*s*s*s*", 19, 6, 9)), display_expected("111100\r\n000010\r\n000001\r\n000010\r\n000100\r\n000000\r\n000000\r\n000000\r\n000000"), "Your interpreter should traverse the 2D datagrid correctly");
    }

    #[test]
    fn simple_case_3() {
        assert_eq!(display_actual(&interpreter("*e*e*e*es*es*ws*ws*w*w*w*n*n*n*ssss*s*s*s*", 42, 6, 9)), display_expected("111100\r\n100010\r\n100001\r\n100010\r\n111100\r\n100000\r\n100000\r\n100000\r\n100000"), "Your interpreter should traverse the 2D datagrid correctly for all of the \"n\", \"e\", \"s\" and \"w\" commands");
    }

    #[test]
    fn simple_case_4() {
        assert_eq!(display_actual(&interpreter("*e*e*e*es*es*ws*ws*w*w*w*n*n*n*ssss*s*s*s*", 100, 6, 9)), display_expected("111100\r\n100010\r\n100001\r\n100010\r\n111100\r\n100000\r\n100000\r\n100000\r\n100000"), "Your interpreter should terminate normally and return a representation of the final state of the 2D datagrid when all commands have been considered from left to right even if the number of iterations specified have not been fully performed");
    }

    /// Prints representation of datagrid - 0's are black and 1's are white.
    /// Note: it only works properly if your interpreter returns a representation
    /// of the datagrid in the correct format.
    fn pretty_print(datagrid: &str) -> &str {
        let rows = datagrid.split("\r\n");
        let mut output = String::new();
        output += "<pre>";
        for row in rows {
            for cell in row.chars() {
                output += "<span style=\"color:"; 
                output += if cell == '0' { "black" } else { "white" };
                output += ";background-color:"; 
                output += if cell == '0' { "black" } else { "white" };
                output += "\">xx</span>";
            }
            output += "<br />";
        }
        output += "</pre>";
        println!("{}", output);
        datagrid
    }

    /// Displays the grid the interpreter returns
    fn display_actual(actual: &str) -> &str {
        println!("You returned:");
        pretty_print(actual)
    }

    /// Displays the expected final state of datagrid
    fn display_expected(expected: &str) -> &str {
        println!("Expected final state of data grid:");
        pretty_print(expected)
    }   
}