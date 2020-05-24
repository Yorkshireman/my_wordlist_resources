require 'securerandom'

Wordlist.destroy_all
Word.destroy_all
WordlistEntry.destroy_all

# rubocop:disable Layout/LineLength
def generate_random_sentence
  words = %w[vulputate mi sit amet mauris commodo quis imperdiet massa tincidunt nunc pulvinar sapien et ligula ullamcorper malesuada proin libero nunc consequat interdum varius sit amet]
  random_length = rand(5..20)
  shuffled_array = words.shuffle
  shuffled_array[0, random_length].join(' ')
end

uuids = %w[74083e1f-9c8c-4f4b-9333-9d46d30d17bf 9578f0c6-3231-4d66-91ad-b4946d323f86 869d329b-7c2c-4a64-afc3-437906d20699 6ccf4990-16c2-44f6-87ab-6bc0fde07873 174ae069-046c-4c95-a617-70e27d89a717 18066cc9-8fc3-42d5-b5b6-bfd620133841 e43d66ab-a35e-4056-9890-d2d303e1014f b0ecfc49-f5bf-45ea-b8d3-c0f2cb2c1a3b d7e68bb2-90c5-4888-95e7-931c799d926c 93035f10-dc3c-4303-9e23-dcfe35c273ad 67907c74-5649-4018-ac31-35a831b2bc95 188b12cb-1196-4170-8414-cfdebce23a86 28d99f4c-59de-476b-b1d2-8400189e49cc 3e2578a8-5e6b-43d9-babd-f2c2e67788f8 5837d7df-b40d-4233-97cc-e611cea033bc 5a1eac7f-4105-412c-983e-03e95f9756a1 07f05d42-46f4-42a1-a5e0-8cc97e338139 c8252b22-f30c-430c-bdfa-46f385c97517 0988e5c8-fcb9-49c7-a565-f865d1e01151 c6817cf1-cecb-4bcd-be36-41efbd61f902]

# create Wordlists
uuids.each { |uuid| Wordlist.create(user_id: uuid) }

words = %w[laugh capable annoying fragile talented rot cord frightened ignore shave jewel misty print sneeze box fry hollow whip drink pleasant determine scent land naughty pull prescribe motionless endanger progress charming drop trousers wrench scald cord rebuild experience gratis responsible rob suffer lethal let renounce lacking cannon hard spring functional rich territory hook connection keen gaudy wool ski kitten determine relation coach oafish quizzical knock hulking bow swim thoughtless tell convey health burn furtive lumpy early knot yummy sever advise xenophobic invincible regular stream education frog purpose stretch abject present roll snail bird show impart contrast split unique invite handsomely leap forlese zinc exclaim taste attractive team silent lift sister pretend hurt ritzy push sever abrasive blood turn tie cub]
# rubocop:enable Layout/LineLength(RuboCop)

# create Words
words.each { |word| Word.create(name: word) }

Wordlist.all.each do |wordlist|
  # create WordlistEntries
  words = Word.all.sample(20)
  words.each do |word|
    WordlistEntry.create(word_id: word.id, wordlist_id: wordlist.id, description: generate_random_sentence)
  end
end
