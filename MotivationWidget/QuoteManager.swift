import Foundation
import SwiftUI

struct Quote: Identifiable {
    let id: Int
    let text: String
    let author: String
}

struct QuoteManager {

    static let quotes: [Quote] = [
        Quote(id:  0, text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        Quote(id:  1, text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
        Quote(id:  2, text: "Life is what happens when you're busy making other plans.", author: "John Lennon"),
        Quote(id:  3, text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
        Quote(id:  4, text: "Spread love everywhere you go. Let no one ever come to you without leaving happier.", author: "Mother Teresa"),
        Quote(id:  5, text: "When you reach the end of your rope, tie a knot in it and hang on.", author: "Franklin D. Roosevelt"),
        Quote(id:  6, text: "Always remember that you are absolutely unique. Just like everyone else.", author: "Margaret Mead"),
        Quote(id:  7, text: "Don't judge each day by the harvest you reap but by the seeds that you plant.", author: "Robert Louis Stevenson"),
        Quote(id:  8, text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
        Quote(id:  9, text: "An unexamined life is not worth living.", author: "Socrates"),
        Quote(id: 10, text: "In the middle of every difficulty lies opportunity.", author: "Albert Einstein"),
        Quote(id: 11, text: "You must be the change you wish to see in the world.", author: "Mahatma Gandhi"),
        Quote(id: 12, text: "Darkness cannot drive out darkness; only light can do that.", author: "Martin Luther King Jr."),
        Quote(id: 13, text: "Do one thing every day that scares you.", author: "Eleanor Roosevelt"),
        Quote(id: 14, text: "Well behaved women seldom make history.", author: "Laurel Thatcher Ulrich"),
        Quote(id: 15, text: "Life shrinks or expands in proportion to one's courage.", author: "Anaïs Nin"),
        Quote(id: 16, text: "You gain strength, courage and confidence by every experience in which you really stop to look fear in the face.", author: "Eleanor Roosevelt"),
        Quote(id: 17, text: "Nothing is impossible. The word itself says 'I'm possible!'", author: "Audrey Hepburn"),
        Quote(id: 18, text: "The question isn't who's going to let me; it's who is going to stop me.", author: "Ayn Rand"),
        Quote(id: 19, text: "Be yourself; everyone else is already taken.", author: "Oscar Wilde"),
        Quote(id: 20, text: "Two roads diverged in a wood, and I took the one less traveled by.", author: "Robert Frost"),
        Quote(id: 21, text: "I am not a product of my circumstances. I am a product of my decisions.", author: "Stephen Covey"),
        Quote(id: 22, text: "The most common way people give up their power is by thinking they don't have any.", author: "Alice Walker"),
        Quote(id: 23, text: "It always seems impossible until it's done.", author: "Nelson Mandela"),
        Quote(id: 24, text: "Do not go where the path may lead; go instead where there is no path and leave a trail.", author: "Ralph Waldo Emerson"),
        Quote(id: 25, text: "You will face many defeats in life, but never let yourself be defeated.", author: "Maya Angelou"),
        Quote(id: 26, text: "The greatest glory in living lies not in never falling, but in rising every time we fall.", author: "Nelson Mandela"),
        Quote(id: 27, text: "In the end, it's not the years in your life that count. It's the life in your years.", author: "Abraham Lincoln"),
        Quote(id: 28, text: "Never let the fear of striking out keep you from playing the game.", author: "Babe Ruth"),
        Quote(id: 29, text: "Life is either a daring adventure or nothing at all.", author: "Helen Keller"),
        Quote(id: 30, text: "Many of life's failures are people who did not realize how close they were to success when they gave up.", author: "Thomas Edison"),
        Quote(id: 31, text: "You have brains in your head. You have feet in your shoes. You can steer yourself any direction you choose.", author: "Dr. Seuss"),
        Quote(id: 32, text: "If life were predictable it would cease to be life and be without flavor.", author: "Eleanor Roosevelt"),
        Quote(id: 33, text: "If you look at what you have in life, you'll always have more.", author: "Oprah Winfrey"),
        Quote(id: 34, text: "If you want to live a happy life, tie it to a goal, not to people or things.", author: "Albert Einstein"),
        Quote(id: 35, text: "Money and success don't change people; they merely amplify what is already there.", author: "Will Smith"),
        Quote(id: 36, text: "Your time is limited, so don't waste it living someone else's life.", author: "Steve Jobs"),
        Quote(id: 37, text: "Not how long, but how well you have lived is the main thing.", author: "Seneca"),
        Quote(id: 38, text: "Live in the sunshine, swim the sea, drink the wild air.", author: "Ralph Waldo Emerson"),
        Quote(id: 39, text: "Go confidently in the direction of your dreams! Live the life you've imagined.", author: "Henry David Thoreau"),
        Quote(id: 40, text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle"),
        Quote(id: 41, text: "Whoever is happy will make others happy too.", author: "Anne Frank"),
        Quote(id: 42, text: "Do not let making a living prevent you from making a life.", author: "John Wooden"),
        Quote(id: 43, text: "A pessimist sees the difficulty in every opportunity; an optimist sees the opportunity in every difficulty.", author: "Winston Churchill"),
        Quote(id: 44, text: "Success usually comes to those who are too busy to be looking for it.", author: "Henry David Thoreau"),
        Quote(id: 45, text: "Opportunities don't happen. You create them.", author: "Chris Grosser"),
        Quote(id: 46, text: "Try not to become a man of success. Rather become a man of value.", author: "Albert Einstein"),
        Quote(id: 47, text: "It is not the strongest of the species that survive, nor the most intelligent, but the one most responsive to change.", author: "Charles Darwin"),
        Quote(id: 48, text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
        Quote(id: 49, text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
    ]

    static func quoteForDate(_ date: Date = Date()) -> Quote {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % quotes.count
        return quotes[index]
    }

    // Shared gradient palette — used by both the main app and home screen widgets
    static let gradientPalettes: [[Color]] = [
        [Color(red: 0.20, green: 0.20, blue: 0.60), Color(red: 0.55, green: 0.20, blue: 0.70)],
        [Color(red: 0.10, green: 0.50, blue: 0.60), Color(red: 0.10, green: 0.30, blue: 0.80)],
        [Color(red: 0.70, green: 0.20, blue: 0.30), Color(red: 0.90, green: 0.50, blue: 0.10)],
        [Color(red: 0.10, green: 0.55, blue: 0.35), Color(red: 0.10, green: 0.30, blue: 0.55)],
        [Color(red: 0.45, green: 0.10, blue: 0.65), Color(red: 0.20, green: 0.10, blue: 0.45)],
    ]

    static func gradientColors(for index: Int) -> [Color] {
        gradientPalettes[index % gradientPalettes.count]
    }
}
