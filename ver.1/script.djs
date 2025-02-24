// Основные константы
const WORD_LENGTH = 5;

const MAX_ATTEMPTS = 6;
const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

// Список слов для игры
const WORDS = [
    'APPLE', 'BRAIN', 'CHAIR', 'DANCE', 'EAGLE',
    'FLAME', 'GHOST', 'HONEY', 'IGLOO', 'JELLY',
    'KOALA', 'LEMON', 'MONEY', 'NURSE', 'OCEAN',
    'PIANO', 'QUEEN', 'RIVER', 'SNAKE', 'TIGER',
    'UMBRA', 'VIOLA', 'WHALE', 'XENON', 'YACHT',
    'ZEBRA'
];

// Глобальные переменные
let secretWord;
let currentAttempt = 0;
let boardState = Array(MAX_ATTEMPTS).fill('');
let messageTimeout;

// Инициализация игры
function initGame() {
    // Выбор случайного слова
    secretWord = WORDS[Math.floor(Math.random() * WORDS.length)];
    
    // Инициализация игрового поля
    const board = document.querySelector('.board');
    board.innerHTML = '';
    
    for (let i = 0; i < MAX_ATTEMPTS; i++) {
        const row = document.createElement('div');
        row.className = 'row';
        
        for (let j = 0; j < WORD_LENGTH; j++) {
            const tile = document.createElement('div');
            tile.className = 'tile';
            row.appendChild(tile);
        }
        
        board.appendChild(row);
    }

    // Инициализация клавиатуры
    initKeyboard();

    // Обработка физической клавиатуры
    document.addEventListener('keydown', handlePhysicalKeyPress);
}

// Инициализация клавиатуры
function initKeyboard() {
    const keyboard = document.querySelector('.keyboard');
    keyboard.innerHTML = '';

    const rows = [
        'QWERTYUIOP',
        'ASDFGHJKL', 
        'ZXCVBNM'
    ];

    rows.forEach(rowLetters => {
        const row = document.createElement('div');
        row.className = 'keyboard-row';

        rowLetters.split('').forEach(letter => {
            const key = document.createElement('button');
            key.className = 'key';
            key.textContent = letter;
            key.addEventListener('click', () => handleKeyPress(letter));
            row.appendChild(key);
        });

        keyboard.appendChild(row);
    });

    // Добавляем кнопки ENTER и BACKSPACE
    const controlRow = document.createElement('div');
    controlRow.className = 'keyboard-row';
    
    const enterKey = document.createElement('button');
    enterKey.className = 'key enter-key';
    enterKey.textContent = 'ENTER';
    enterKey.addEventListener('click', () => handleKeyPress('ENTER'));
    
    const backspaceKey = document.createElement('button');
    backspaceKey.className = 'key backspace-key';
    backspaceKey.textContent = '⌫';
    backspaceKey.addEventListener('click', () => handleKeyPress('BACKSPACE'));
    
    controlRow.appendChild(enterKey);
    controlRow.appendChild(backspaceKey);
    keyboard.appendChild(controlRow);
}

// Обработка нажатия клавиши
function handleKeyPress(letter) {
    if (letter === 'ENTER') {
        submitGuess();
    } else if (letter === 'BACKSPACE') {
        deleteLetter();
    } else {
        addLetter(letter);
    }
}

// Обработка физической клавиатуры
function handlePhysicalKeyPress(event) {
    const key = event.key.toUpperCase();
    
    if (key === 'ENTER') {
        handleKeyPress('ENTER');
    } else if (key === 'BACKSPACE') {
        handleKeyPress('BACKSPACE');
    } else if (ALPHABET.includes(key)) {
        handleKeyPress(key);
    }
}

// Добавление буквы
function addLetter(letter) {
    if (boardState[currentAttempt].length < WORD_LENGTH) {
        const currentWord = boardState[currentAttempt];
        boardState[currentAttempt] = currentWord + letter;
        updateBoard();
    }
}

// Удаление буквы
function deleteLetter() {
    if (boardState[currentAttempt].length > 0) {
        boardState[currentAttempt] = boardState[currentAttempt].slice(0, -1);
        updateBoard();
    }
}

// Отправка слова
function submitGuess() {
    const guess = boardState[currentAttempt];
    if (guess.length === WORD_LENGTH) {
        if (!WORDS.includes(guess)) {
            showMessage('Такого слова нет', 3000);
            return;
        }
        checkWord();
        currentAttempt++;
    }
}

// Обновление игрового поля
function updateBoard() {
    const row = document.querySelectorAll('.row')[currentAttempt];
    const tiles = row.querySelectorAll('.tile');
    
    tiles.forEach((tile, index) => {
        tile.textContent = boardState[currentAttempt][index] || '';
    });
}

// Проверка слова
function checkWord() {
    const guess = boardState[currentAttempt];
    const row = document.querySelectorAll('.row')[currentAttempt];
    const tiles = row.querySelectorAll('.tile');

    const secretLetters = secretWord.split('');
    const guessLetters = guess.split('');

    // Сначала проверяем точные совпадения
    guessLetters.forEach((letter, index) => {
        if (letter === secretLetters[index]) {
            tiles[index].classList.add('correct');
            secretLetters[index] = null; // Помечаем букву как использованную
        }
    });

    // Затем проверяем частичные совпадения
    guessLetters.forEach((letter, index) => {
        if (!tiles[index].classList.contains('correct')) {
            if (secretLetters.includes(letter)) {
                tiles[index].classList.add('present');
                secretLetters[secretLetters.indexOf(letter)] = null;
            } else {
                tiles[index].classList.add('absent');
            }
        }
    });

    // Обновляем клавиатуру
    updateKeyboard(guess);

    // Проверяем победу или поражение
    if (guess === secretWord) {
        showMessage('Поздравляем! Вы угадали слово!');
        endGame();
    } else if (currentAttempt === MAX_ATTEMPTS - 1) {
        showMessage('Проигрыш', 3000);
        setTimeout(() => {
            showMessage(`Игра окончена. Загаданное слово: ${secretWord}`);
        }, 3000);
        endGame();

    }
}

// Обновление клавиатуры
function updateKeyboard(guess) {
    const keys = document.querySelectorAll('.key');
    const guessLetters = guess.split('');

    keys.forEach(key => {
        const letter = key.textContent;
        if (guessLetters.includes(letter)) {
            if (secretWord.includes(letter)) {
                if (secretWord.indexOf(letter) === guess.indexOf(letter)) {
                    key.classList.add('correct');
                } else {
                    key.classList.add('present');
                }
            } else {
                key.classList.add('absent');
            }
        }
    });
}

// Показ сообщений
function showMessage(message, duration = 0) {
    const messageElement = document.querySelector('.message');
    messageElement.textContent = message;
    messageElement.style.display = 'block';
    messageElement.classList.toggle('lose', message === 'Проигрыш');


    if (duration > 0) {
        clearTimeout(messageTimeout);
        messageTimeout = setTimeout(() => {
            messageElement.style.display = 'none';
        }, duration);
    }
}

// Завершение игры
function endGame() {
    document.removeEventListener('keydown', handlePhysicalKeyPress);
}

// Основная функция запуска игры
function startGame() {
    initGame();
}

// Запуск игры при загрузке страницы
window.onload = startGame;
