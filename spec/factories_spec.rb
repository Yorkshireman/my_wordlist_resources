require 'rails_helper'

RSpec.describe '#wordlist_with_wordlist_entries_with_categories' do
  it 'creates 1 Wordlist' do
    expect { wordlist_with_wordlist_entries_with_categories }.to change { Wordlist.count }.by 1
  end

  it 'creates 2 WordlistEntries' do
    expect { wordlist_with_wordlist_entries_with_categories }.to change { WordlistEntry.count }.by 2
  end

  it 'WordlistEntries are unique' do
    expect(WordlistEntry.count).to eq 0
    wordlist_with_wordlist_entries_with_categories
    expect(WordlistEntry.all[0].id == WordlistEntry.all[1].id).to be false
  end

  it 'creates 6 categories' do
    expect { wordlist_with_wordlist_entries_with_categories }.to change { Category.count }.by 6
  end

  it 'created Wordlist has the two created WordlistEntries' do
    expect(WordlistEntry.count).to eq 0
    wl = wordlist_with_wordlist_entries_with_categories
    expect(wl.wordlist_entries).to eq([WordlistEntry.all[0], WordlistEntry.all[1]])
  end

  it 'the WordlistEntries have 3 Categories each' do
    wl = wordlist_with_wordlist_entries_with_categories
    expect(wl.wordlist_entries.first.categories.count).to eq 3
    expect(wl.wordlist_entries.second.categories.count).to eq 3
  end
end

RSpec.describe '#wordlist_with_wordlist_entries_no_categories' do
  it 'creates 1 Wordlist' do
    expect { wordlist_with_wordlist_entries_no_categories }.to change { Wordlist.count }.by 1
  end

  it 'creates 2 WordlistEntries' do
    expect { wordlist_with_wordlist_entries_no_categories }.to change { WordlistEntry.count }.by 2
  end

  it 'WordlistEntries are unique' do
    expect(WordlistEntry.count).to eq 0
    wordlist_with_wordlist_entries_no_categories
    expect(WordlistEntry.all[0].id == WordlistEntry.all[1].id).to be false
  end

  it 'created Wordlist has the two created WordlistEntries' do
    expect(WordlistEntry.count).to eq 0
    wl = wordlist_with_wordlist_entries_no_categories
    expect(wl.wordlist_entries).to eq([WordlistEntry.all[0], WordlistEntry.all[1]])
  end
end
