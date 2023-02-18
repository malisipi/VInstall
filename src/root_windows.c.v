module vinstall

fn C.MessageBoxW(int, &u16, &u16, int) int
fn C.ShellExecute(int, &u16, &u16, &u16, &u16, int)
