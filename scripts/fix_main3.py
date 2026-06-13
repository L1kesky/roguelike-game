with open(r'C:\Users\haoji\Documents\Codex\2026-06-06\d-school\warm_snow_roguelike\scripts\Main.gd', 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')

# Remove the corrupted sparkle insertion at lines 1390-1394 area
# Remove the garbage [H] line that got inserted at wrong position
new_lines = []
skip_sparkle_count = 0
for i, line in enumerate(lines):
    # Skip the wrongly-placed sparkle lines (they're before the return in win screen)
    if i >= 1310 and i <= 1314 and 'sx :=' in line:
        continue
    
    # Remove the garbage [H] line that leaked into the wrong place
    if '键位帮助' in line and i > 1360 and i < 1400:
        continue
    
    new_lines.append(line)

content = '\n'.join(new_lines)

# Now the original draw_map title section at around line 1310 should be back to just:
# # draw_string 被注释
# return

# Find the right draw_string comment in the not-game_started section (around line 1308-1310)
# It should be preceded by dr.draw_rect(Rect2(w/2-100, h/2+60...
for i in range(len(new_lines)):
    if 'draw_string' in new_lines[i] and '标题' in new_lines[i]:
        # Remove the sparkle lines that were wrongly inserted here too
        # Just keep this line and the return
        pass

# Actually, let me just look at the correct section and add sparkles properly
# The title screen draw is between "if not game_started:" and "return"
# Find the "文字由 TitleUI Label 展示" comment or "draw_string被注释" 
for i in range(len(new_lines)):
    if '文字由 TitleUI' in new_lines[i] or 'draw_string' in new_lines[i] and '??' in new_lines[i]:
        # This is the right comment in the title screen draw section
        # Check if the next lines already have sparkle code
        if i+1 < len(new_lines) and 'for i in range' in new_lines[i+1]:
            # Already has sparkles (from previous correct insertion) - good
            print(f"Sparkles already present at line {i+1}")
            break
        else:
            # Need to add sparkles
            indent = '\t\t'
            sparkle_lines = [
                '# 背景金色火星',
                'for i in range(12):',
                '\tvar sx := (i * 67 + int(ft * 8) % 31) % int(w)',
                '\tvar sy := (i * 43 + int(ft * 6) % 37) % int(h)',
                '\tdr.draw_circle(Vector2(sx, sy), 1 + (i % 2), Color(0.92, 0.72, 0.28, 0.04 + i * 0.015))',
            ]
            for j, sl in enumerate(sparkle_lines):
                new_lines.insert(i + 1 + j, indent + sl)
            print(f"Added sparkles at line {i+1}")
            break
    elif i < len(new_lines) - 1 and 'draw_rect.*200.*30' in str(new_lines[i]) and 'draw_rect' in str(new_lines[i+1]):
        # Check if we're in the title screen section (before "return")
        for j in range(i, min(i+5, len(new_lines))):
            if 'return' in new_lines[j] and j < len(new_lines) - 1:
                next_line = new_lines[j+1].strip()
                if next_line.startswith('if map_data.is_empty'):
                    # This IS the title screen return - right before this return!
                    indent = '\t\t'
                    sparkle_lines = [
                        '# 背景金色火星',
                        'for i in range(12):',
                        '\tvar sx := (i * 67 + int(ft * 8) % 31) % int(w)',
                        '\tvar sy := (i * 43 + int(ft * 6) % 37) % int(h)',
                        '\tdr.draw_circle(Vector2(sx, sy), 1 + (i % 2), Color(0.92, 0.72, 0.28, 0.04 + i * 0.015))',
                    ]
                    for k, sl in enumerate(sparkle_lines):
                        new_lines.insert(j + k, indent + sl)
                    print(f"Added sparkles at line {j} (before return)")
                    break
        break

content = '\n'.join(new_lines)

with open(r'C:\Users\haoji\Documents\Codex\2026-06-06\d-school\warm_snow_roguelike\scripts\Main.gd', 'w', encoding='utf-8') as f:
    f.write(content)

print(f'Done. Total lines: {len(new_lines)}')