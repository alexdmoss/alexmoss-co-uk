document.addEventListener('DOMContentLoaded', () => {
    const display = document.getElementById('movie-display');
    const pickBtn = document.getElementById('pick-btn');
    let movies = [];

    // Fetch movies on load
    fetch('movies.txt')
        .then(response => response.text())
        .then(text => {
            // Split by newline and filter out empty lines
            movies = text.split('\n').map(line => line.trim()).filter(line => line.length > 0);
            console.log(`Loaded ${movies.length} movies.`);
        })
        .catch(err => {
            console.error('Error loading movies:', err);
            display.innerHTML = '<p class="error">Failed to load movie list.</p>';
        });

    pickBtn.addEventListener('click', () => {
        if (movies.length === 0) {
            return;
        }

        // Disable button during animation
        pickBtn.disabled = true;

        // Add a little spin animation effect
        pickBtn.style.transform = 'scale(0.95)';
        setTimeout(() => pickBtn.style.transform = '', 100);

        // Pick random movie
        const randomIndex = Math.floor(Math.random() * movies.length);
        const selectedMovie = movies[randomIndex];

        // Display movie immediately
        display.innerHTML = ''; // Clear current

        const titleElement = document.createElement('h2');
        titleElement.className = 'movie-title';
        titleElement.textContent = selectedMovie;
        display.appendChild(titleElement);

        // Trigger confetti
        if (window.confetti) {
            confetti({
                particleCount: 150,
                spread: 70,
                origin: { y: 0.6 },
                colors: ['#D42426', '#165B33', '#F8B229', '#ffffff']
            });
        }

        // Re-enable button
        pickBtn.disabled = false;
    });
});

// Add pulse animation style dynamically
const styleSheet = document.createElement("style");
styleSheet.innerText = `
@keyframes pulse {
    0% { opacity: 0.5; transform: scale(0.98); }
    50% { opacity: 1; transform: scale(1.02); }
    100% { opacity: 0.5; transform: scale(0.98); }
}`;
document.head.appendChild(styleSheet);
