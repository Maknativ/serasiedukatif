import re

with open('index.html', 'r', encoding='utf-8', errors='ignore') as f:
    html = f.read()

html = re.sub(r'<button class="nav-btn active" onclick="showSection\(''beranda'', this\)">.*?</button>', '<button class="nav-btn active" onclick="showSection(''beranda'', this)">🏠 Beranda</button>', html)
html = re.sub(r'<button class="nav-btn" onclick="showSection\(''menu-a'', this\)">.*?</button>', '<button class="nav-btn" onclick="showSection(''menu-a'', this)">🗺️ Lorong Waktu</button>', html)
html = re.sub(r'<button class="nav-btn" onclick="showSection\(''menu-b'', this\)">.*?</button>', '<button class="nav-btn" onclick="showSection(''menu-b'', this)">🍽️ Jelajah Rasa</button>', html)
html = re.sub(r'<button class="nav-btn" onclick="showSection\(''menu-c'', this\)">.*?</button>', '<button class="nav-btn" onclick="showSection(''menu-c'', this)">🎨 Pojok Aksi</button>', html)

html = re.sub(r'<h2>Selamat Datang di SERASI!.*?</h2>', '<h2>Selamat Datang di SERASI! 🎉</h2>', html)
html = re.sub(r'<h3>.*?Lorong Waktu</h3>', '<h3>🗺️ Lorong Waktu</h3>', html)
html = re.sub(r'<h3>.*?Jelajah Rasa</h3>', '<h3>🍽️ Jelajah Rasa</h3>', html)
html = re.sub(r'<h3>.*?Pojok Aksi</h3>', '<h3>🎨 Pojok Aksi</h3>', html)
html = re.sub(r'<h2>.*?Lorong Waktu Legenda Sragen</h2>', '<h2>🗺️ Lorong Waktu Legenda Sragen</h2>', html)
html = re.sub(r'<h2>.*?Jelajah Rasa Bumi Sukowati</h2>', '<h2>🍽️ Jelajah Rasa Bumi Sukowati</h2>', html)
html = re.sub(r'<button class="action-btn">Lihat Sajian.*?</button>', '<button class="action-btn">Lihat Sajian 🔊</button>', html)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)
