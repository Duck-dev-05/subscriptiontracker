import os
import glob

def refactor_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace .fill(AppTheme.surface) with .fill(.ultraThinMaterial).environment(\.colorScheme, .dark)
    new_content = content.replace('.fill(AppTheme.surface)', '.fill(.ultraThinMaterial)\n                                .environment(\\.colorScheme, .dark)')
    
    # Replace .background(AppTheme.surface) with .background(.ultraThinMaterial).environment(\.colorScheme, .dark)
    new_content = new_content.replace('.background(AppTheme.surface)', '.background(.ultraThinMaterial)\n                                .environment(\\.colorScheme, .dark)')
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for filepath in glob.glob('d:/Code/subscriptiontracker/Views/**/*.swift', recursive=True):
    refactor_file(filepath)
