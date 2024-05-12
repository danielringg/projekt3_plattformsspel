require 'ruby2d'

set width: 800
set height: 480

#mycket av koden är tagen från den här videon som jag såg när jag först började projektet: https://www.youtube.com/watch?v=pyixn98XB90&ab_channel=CodewithMario
walk_speed = 10
jump_speed = 10

background = Image.new( #https://opengameart.org/content/background-6
    'img/background.png',
)

#skapar scoreboarden uppe i vänstra hörnet
score = 0
text = Text.new(score, x: 10, y: 10, size: 20, color: 'white')

#skapar tileset med 32x32 tiles som jag kan använda för att skapa banan
tileset = Ruby2D::Tileset.new(
    'img/tileset.png',
    tile_width: 32,
    tile_height: 32,
    scale: 1,
)

#2d-array där jag kan lägga in tiles på koordinater
tiles1 = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"o",0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"pl","pm","pr",0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,"f",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,"pl","pm","pm","pm","pr",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
[0,0,0,"f",0,0,0,0,0,"pl","pm","pr",0,0,"pl","pr",0,0,0,0,0,0,0,0,0],
[0,"pl","pm","pm","pr",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],]

#tiles
tileset.define_tile(
    'platform_left',
    4,
    5,
)
tileset.define_tile(
    'platform_middle',
    5,
    5,
)
tileset.define_tile(
    'platform_right',
    6,
    5,
)
tileset.define_tile(
    'platform_right',
    6,
    5,
)
tileset.define_tile(
    'flower',
    7,
    0,
)
tileset.define_tile(
    'orb',
    3,
    0,
)

#funktion som ritar upp banan, konverterar positioner i arrayen till koordinater i spelfönstret
def draw_level(tiles, tileset)
    tiles.each_with_index do |row, i|
        row.each_with_index do |tile, j|
            if tile == "pl"
                tileset.set_tile('platform_left', [{ x: j * 32, y: i * 32 }])
            elsif tile == "pm"
                tileset.set_tile('platform_middle', [{ x: j * 32, y: i * 32 }])
            elsif tile == "pr"
                tileset.set_tile('platform_right', [{ x: j * 32, y: i * 32 }])
            elsif tile == "f"
                tileset.set_tile('flower', [{ x: j * 32, y: i * 32 }])
            elsif tile == "o"
                tileset.set_tile('orb', [{ x: j * 32, y: i * 32 }])
            end
        end
    end
end
draw_level(tiles1, tileset)

#skapar karaktären
hero = Sprite.new(
    'img/character1.png', #https://opengameart.org/content/a-platformer-in-the-forest
    width: 64,
    height: 64,
    clip_width: 32,
    x: 100,
    y: 320,
    animations:{
    walk: 1..4,
    jump: 5..7,
    hit: 9..10,
    climb: 19..22
  }
)

#flytta på karaktären med piltangenterna, innehåller if-satser som känner av om det finns plattformar under eller bredvid sig
on :key_held do |event|
    case event.key
    when 'left'
        if tiles1[hero.y / 32][(hero.x / 32)-1] == 0
            hero.play animation: :walk, loop: true, flip: :horizontal
        if hero.x > 0
            hero.x -= walk_speed
        else
            if background.x < 0
                background.x += walk_speed
            end
        end
        end
    when 'right'
        if tiles1[hero.y / 32][(hero.x / 32)+1] == 0
            hero.play animation: :walk, loop: true
            if hero.x < (800 - hero.width)
                hero.x += walk_speed
            else
                if (background.x - 800) > -background.width
                    background.x -= walk_speed
                end
            end
        end
    when 'up'
        hero.play animation: :jump, loop: true
        
        jump_start_pos = hero.y
        jump_duration = 0.5
        jump_height = 100
        
        jump_start_time = Time.now
        jump_end_time = jump_start_time + jump_duration
        
        update do
            current_time = Time.now
            elapsed_time = current_time - jump_start_time
            
            if elapsed_time < jump_duration
                progress = elapsed_time / jump_duration
                hero.y = jump_start_pos - (Math.sin(progress * Math::PI) * jump_height).round
            elsif hero.y < 410
                if tiles1[(hero.y / 32)+2][hero.x / 32] == 0
                    hero.y += 4
                end
            end
        end
    end

    #om man står på en orb ska sitt score gå upp, fick inte riktigt det här att fungera dock
    if tiles1[hero.y / 32][hero.x / 32] == "o"
        score += 1
        text.text = score
    end
    
end

#stannar animationerna när man står stilla
on :key_up do
    hero.stop
end

show