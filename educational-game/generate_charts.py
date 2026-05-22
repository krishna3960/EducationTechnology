import matplotlib.pyplot as plt
import numpy as np

# ---------------------------------------------------------
# 1. Users Donut Chart
# ---------------------------------------------------------
labels = ['< Monthly', 'Monthly\n(Non-Daily)', 'Daily']
sizes = [50, 35, 15]  # percentages
colors = ['#00FFFF', '#0099FF', '#0033FF'] # Cyan, Light Blue, Deep Blue

fig, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(aspect="equal"))
fig.patch.set_alpha(0.0) # Transparent background
ax.set_facecolor((0,0,0,0))

wedges, texts, autotexts = ax.pie(
    sizes, 
    colors=colors,
    startangle=90, 
    autopct='%1.0f%%', 
    pctdistance=0.85,
    textprops=dict(color="w", weight="bold", fontsize=14),
    wedgeprops=dict(width=0.3, edgecolor='none')
)

# Add ChatGPT text in the center
center_text = "ChatGPT:\n800M\nWeekly"
ax.text(0, 0, center_text, ha='center', va='center', fontsize=16, color='white', weight='bold')

plt.title("Yearly Users (2 Billion Total)", color='white', fontsize=18, weight='bold', pad=20)
plt.legend(wedges, labels, loc="center left", bbox_to_anchor=(1, 0.5), frameon=False, labelcolor='white', fontsize=14)

plt.tight_layout()
plt.savefig('Assets/users_donut_chart.png', dpi=300, transparent=True)
plt.close()

# ---------------------------------------------------------
# 2. Hardware Resource Intensity Bar Chart
# ---------------------------------------------------------
labels = ['Silicon', 'Copper', 'Rare Earths', 'Water', 'Energy']
traditional = [100, 100, 100, 100, 100]
ai_chips = [180, 220, 350, 450, 380]
multipliers = ['1.8x', '2.2x', '3.5x', '4.5x', '3.8x']

x = np.arange(len(labels))
width = 0.35

fig, ax = plt.subplots(figsize=(8, 6))
fig.patch.set_alpha(0.0)
ax.set_facecolor((0,0,0,0))

# Colors fitting the new UI (Pale purple for traditional, bright yellow for AI)
color_trad = '#A094C6' 
color_ai = '#EED28A'

rects1 = ax.bar(x - width/2, traditional, width, label='Traditional Chips', color=color_trad)
rects2 = ax.bar(x + width/2, ai_chips, width, label='AI-Optimized Chips', color=color_ai)

# Add text labels on top of AI bars
for i, rect in enumerate(rects2):
    height = rect.get_height()
    ax.annotate(multipliers[i],
                xy=(rect.get_x() + rect.get_width() / 2, height),
                xytext=(0, 5),  # 5 points vertical offset
                textcoords="offset points",
                ha='center', va='bottom', color='white', weight='bold', fontsize=12)

# Styling
ax.set_ylabel('Resource Intensity (Index)', color='white', weight='bold', fontsize=12)
ax.set_xticks(x)
ax.set_xticklabels(labels, color='white', fontsize=12)
ax.tick_params(axis='y', colors='white')
ax.spines['bottom'].set_color('white')
ax.spines['left'].set_color('white')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# Grid
ax.yaxis.grid(True, linestyle='--', alpha=0.2, color='white')

# Legend
legend = ax.legend(frameon=False, labelcolor='white', fontsize=12, loc='upper left')

plt.tight_layout()
plt.savefig('Assets/hardware_bar_chart.png', dpi=300, transparent=True)
plt.close()

print("Charts generated successfully in Assets/ folder!")
