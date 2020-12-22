str = '''
Synonyms for pep: Verve, Vim, Elan, Panache
Carbonated beverages: Moxie, Fresca, Jolt, Surge
Types of knife: Pen, Jack, Pocket, Butterfly
NFL teams (singular): Dolphin, Bill, Saint, Brown

Autonomous regions: Catalonia, Gran Chaco, Crimea, Nevis
Types of wine: Shiraz, Grenache, Pinotage, Albariño
MLB general managers: Ng, Hoyer, Rizzo, Preller
Senators: Young, Grassley, Murkowski, Peters

Fermented foods: Kvass, Gundruk, Poi, Miso
Constructed languages: Quenya, Klingon, Sindarin, Interlingua
Precede -ase to name enzymes: Kin, Amyl, Lip, Phosphoryl
Make phrases with red: Eye, Herring, Admiral, Tape

Types of taxes: Zakat, Gabelle, Tithe, Scutage
Synonyms for remove or cut out: Extirpate, Excise, Resect, Ablate
Sleeping pills: Intermezzo, Silenor, Lunesta, Halcion
Messaging platforms: Discord, Line, Messenger, Slack

Bear: Teddy, Mama, Care, Hug
“New”: Mexico, Moon, Deal, Haven
English royal houses: York, Stuart, Godwin, Tudor
Black: Currant, Berry, Sheep, Beard

Synonyms: Peak, Zenith, Apex, Apogee
Supermarkets: Acme, Vons, Tops, Hy-Vee
Parts of armor: Rondel, Greave, Bassinet, Cuisse
Types of marks: Hall, Bench, Birth, Trade

Harry Potter characters: Fletcher, Peeves, Bones, Thomas
Synonyms for steal: Filch, Lift, Rob, Swipe
Make another word with s in front: Park, Cream, Election, Peculate
Types of knots: Slip, Hitch, Trinity, Overhand

Contains “ana”: Anaphase, Moana, Manager, Vanadium
Disney movies: Robin Hood, Hercules, Brave, Coco
Constellations: Lyra, Pisces, Pegasus, Aquila
Water___: Mark, Line, Fall, Proof

Things that are acidic: Lemon, Coffee, Soda, Battery
British spelling differs: Color, Analyze, Estrogen, License
SI units: Candela, Second, Pascal, Tesla
Car companies: Baolong, Venturi, Smart, Isuzu
'''

import json
import re

all_groups = []
for group in str.split('\n\n'):
    contents = []
    for line in list(filter(None, group.split('\n'))):
        halves = line.split(':')
        first = halves[0]
        second = halves[1]
        words = [word.strip() for word in second.split(',')]
        contents.append((first, words))
    all_groups.append(contents)
# print(all_groups)

## Single to double quotes: copy output of previous stage
print(re.sub('\'', '\"', 
# put output from previous stage below between ''' and '''
'''
[[('Synonyms for pep', ['Verve', 'Vim', 'Elan', 'Panache']), ('Carbonated beverages', ['Moxie', 'Fresca', 'Jolt', 'Surge']), ('Types of knife', ['Pen', 'Jack', 'Pocket', 'Butterfly']), ('NFL teams (singular)', ['Dolphin', 'Bill', 'Saint', 'Brown'])], [('Autonomous regions', ['Catalonia', 'Gran Chaco', 'Crimea', 'Nevis']), ('Types of wine', ['Shiraz', 'Grenache', 'Pinotage', 'Albariño']), ('MLB general managers', ['Ng', 'Hoyer', 'Rizzo', 'Preller']), ('Senators', ['Young', 'Grassley', 'Murkowski', 'Peters'])], [('Fermented foods', ['Kvass', 'Gundruk', 'Poi', 'Miso']), ('Constructed languages', ['Quenya', 'Klingon', 'Sindarin', 'Interlingua']), ('Precede -ase to name enzymes', ['Kin', 'Amyl', 'Lip', 'Phosphoryl']), ('Make phrases with red', ['Eye', 'Herring', 'Admiral', 'Tape'])], [('Types of taxes', ['Zakat', 'Gabelle', 'Tithe', 'Scutage']), ('Synonyms for remove or cut out', ['Extirpate', 'Excise', 'Resect', 'Ablate']), ('Sleeping pills', ['Intermezzo', 'Silenor', 'Lunesta', 'Halcion']), ('Messaging platforms', ['Discord', 'Line', 'Messenger', 'Slack'])], [('Bear', ['Teddy', 'Mama', 'Care', 'Hug']), ('“New”', ['Mexico', 'Moon', 'Deal', 'Haven']), ('English royal houses', ['York', 'Stuart', 'Godwin', 'Tudor']), ('Black', ['Currant', 'Berry', 'Sheep', 'Beard'])], [('Synonyms', ['Peak', 'Zenith', 'Apex', 'Apogee']), ('Supermarkets', ['Acme', 'Vons', 'Tops', 'Hy-Vee']), ('Parts of armor', ['Rondel', 'Greave', 'Bassinet', 'Cuisse']), ('Types of marks', ['Hall', 'Bench', 'Birth', 'Trade'])], [('Harry Potter characters', ['Fletcher', 'Peeves', 'Bones', 'Thomas']), ('Synonyms for steal', ['Filch', 'Lift', 'Rob', 'Swipe']), ('Make another word with s in front', ['Park', 'Cream', 'Election', 'Peculate']), ('Types of knots', ['Slip', 'Hitch', 'Trinity', 'Overhand'])], [('Contains “ana”', ['Anaphase', 'Moana', 'Manager', 'Vanadium']), ('Disney movies', ['Robin Hood', 'Hercules', 'Brave', 'Coco']), ('Constellations', ['Lyra', 'Pisces', 'Pegasus', 'Aquila']), ('Water___', ['Mark', 'Line', 'Fall', 'Proof'])], [('Things that are acidic', ['Lemon', 'Coffee', 'Soda', 'Battery']), ('British spelling differs', ['Color', 'Analyze', 'Estrogen', 'License']), ('SI units', ['Candela', 'Second', 'Pascal', 'Tesla']), ('Car companies', ['Baolong', 'Venturi', 'Smart', 'Isuzu'])]]
'''))
