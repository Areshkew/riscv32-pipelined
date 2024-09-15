import argparse
import subprocess
import sys

def execute_commands(commands_with_args, specific_commands=None):
    for tag, command in commands_with_args.items():
        if specific_commands and tag not in specific_commands:
            continue
        try:
            if "&" in command:
                command.remove("&")
                print(f"Executing in background: {' '.join(command)}")
                subprocess.Popen(command)
            else:
                print(f"Executing: {' '.join(command)}")
                completed_process = subprocess.run(command, check=True, text=True, capture_output=True)
                print("Output:", completed_process.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error in executing {' '.join(command)}", file=sys.stderr)
            print("Error Details:", e.stderr, file=sys.stderr)
        except Exception as e:
            print(f"Unexpected error occurred while executing {' '.join(command)}: {e}", file=sys.stderr)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="RiscV multigen tool")
    parser.add_argument('-asm', action='store_true', help='Execute assembly to binaries compiler')
    parser.add_argument('-all', action='store_true', help='Execute all commands')
    
    args = parser.parse_args()
    
    commands_with_args = {
        'compiler': ['py', 'Compiler.py'],
        'iverilog': ['iverilog', '-o', 'pipeline_CPU.vvp', 'pipeline_CPU_tb.v'],
        'vvp': ['vvp', 'pipeline_CPU.vvp'],
        'gtkwave': ['gtkwave', 'pipeline_CPU_tb.vcd']
    }
    
    if args.asm:
        execute_commands(commands_with_args, specific_commands=['compiler'])
    elif args.all:
        execute_commands(commands_with_args)
    else:
        print("No arguments provided, doing nothing.\nUse -h, --help.")
