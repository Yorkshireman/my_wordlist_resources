Wordlist.destroy_all

require 'securerandom'

def generate_random_sentence
  words = ['vulputate', 'mi', 'sit', 'amet', 'mauris', 'commodo', 'quis', 'imperdiet', 'massa', 'tincidunt', 'nunc', 'pulvinar', 'sapien', 'et', 'ligula', 'ullamcorper', 'malesuada', 'proin', 'libero', 'nunc', 'consequat', 'interdum', 'varius', 'sit', 'amet']
  random_length = rand(5..20)
  shuffled_array = words.shuffle
  shuffled_array[0, random_length].join(' ')
end

uuids = []
20.times do
  uuids << SecureRandom.uuid
end

# create Wordlists
uuids.each { |uuid| Wordlist.create(user_id: uuid) }

words = ['laugh', 'capable', 'annoying', 'fragile', 'talented', 'rot', 'cord', 'frightened', 'ignore', 'shave', 'jewel', 'misty', 'print', 'sneeze', 'box', 'fry', 'hollow', 'whip', 'drink', 'pleasant', 'determine', 'scent', 'land', 'naughty', 'pull', 'prescribe', 'motionless', 'endanger', 'progress', 'charming', 'drop', 'trousers', 'wrench', 'scald', 'cord', 'rebuild', 'experience', 'gratis', 'responsible', 'rob', 'suffer', 'lethal', 'let', 'renounce', 'lacking', 'cannon', 'hard', 'spring', 'functional', 'rich', 'territory', 'hook', 'connection', 'keen', 'gaudy', 'wool', 'ski', 'kitten', 'determine', 'relation', 'coach', 'oafish', 'quizzical', 'knock', 'hulking', 'bow', 'swim', 'thoughtless', 'tell', 'convey', 'health', 'burn', 'furtive', 'lumpy', 'early', 'knot', 'yummy', 'sever', 'advise', 'xenophobic', 'invincible', 'regular', 'stream', 'education', 'frog', 'purpose', 'stretch', 'abject', 'present', 'roll', 'snail', 'bird', 'show', 'impart', 'contrast', 'split', 'unique', 'invite', 'handsomely', 'leap', 'forlese', 'zinc', 'exclaim', 'taste', 'attractive', 'team', 'silent', 'lift', 'sister', 'pretend', 'hurt', 'ritzy', 'push', 'sever', 'abrasive', 'blood', 'turn', 'tie', 'cub']
# create Words
words.each { |word| Word.create(name: word) }

Wordlist.all.each do |wordlist|
  # create WordlistEntries
  words = Word.all.sample(20)
  words.each do |word|
    description = generate_random_sentence()
    WordlistEntry.create(word_id: word.id, wordlist_id: wordlist.id, description: description)
  end
end
