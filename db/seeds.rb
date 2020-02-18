Wordlist.destroy_all

require 'securerandom'

def generate_random_sentence
  words = ['vulputate', 'mi', 'sit', 'amet', 'mauris', 'commodo', 'quis', 'imperdiet', 'massa', 'tincidunt', 'nunc', 'pulvinar', 'sapien', 'et', 'ligula', 'ullamcorper', 'malesuada', 'proin', 'libero', 'nunc', 'consequat', 'interdum', 'varius', 'sit', 'amet']
  random_length = rand(5..20)
  shuffled_array = words.shuffle
  shuffled_array[0, random_length].join(' ')
end

uuids = ['1c6b5a3b-290c-46c8-8afe-1f7714eb322d', 'a368aedc-8ab4-4d3d-a251-9be58c72754d', '91e86206-81ac-45a7-924d-886d4f0f4d53', '6108cd63-65a9-418e-b308-646d37318bd7', 'ca702f40-4406-4d47-954d-69bf091d2457', '198ff935-1b1d-471b-809f-91cd066be552', '2fd9e429-45b0-445e-9211-328d3fd96631', '1ebef7c8-1ccf-464c-801a-a9d96ca3be73', 'e37f5da6-23e7-499e-af56-7c4e55f20b42', 'a725f929-070f-4022-a19d-b369652ac6d0', 'cbe1b489-f162-4bb4-8ee0-7fb0287e4ebc', '558be55b-8200-4457-a25d-3113370dc42a', '2acc19ce-038e-43f8-8146-333daa4e24bc', '56aaad42-118e-4d82-aa76-2b8bf5ce4a6a', '2cd13ffd-30bb-47d1-ac1b-51a7057142b4', '8410373b-3491-4846-9bc4-f49284c3c4bb', '6efafcbc-4609-48fa-82b4-b8a3e357fd5c', 'be00a69f-3ec8-4d6b-9ef5-bb6e33f04068', 'a03fe91f-17d9-41e7-aeaf-89826602b1b4', '43fee27d-f478-44ec-afd8-33aca61efce1']

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
