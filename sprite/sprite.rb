require "gosu"

class Sprite
    def initialize window
        @window = window
        @width = @height = 160
        # @image = Gosu::Image.new "hero.png"
        @idle = Gosu::Image.load_tiles(@window, "sprite_sheet_idle.png", @width, @height, true)
        @move = Gosu::Image.load_tiles(@window, "sprite_sheet_move.png", @width, @height, true)
        #center image
        # @x = @window.width/2 - @image.width/2
        # @y = @window.height/2 - @image.height/2
        @x = @window.width/2 - @width/2
        @y = @window.height/2 - @height/2
        @direction = :left
        #frame from sprite_sheet
        @frame = 0
        @moving = false
    end

    def update
        @frame += 1
        @moving = false
        if @window.button_down? Gosu::KbLeft
            @direction = :left
            @x += -5 
            @moving = true
        end
        if @window.button_down? Gosu::KbRight
            @direction = :right
            @x += 5
            @moving = true
        end
    end

    def draw
        #getting range from the sprite_sheet, pull out image from sprite_sheet to print
        f = @frame % @idle.size
        image = @moving ? @move[f] : @idle[f]
        if @direction == :right
            # @image.draw @x, @y, 1
            image.draw @x, @y, 1
        else
            # @image.draw @x + @image.width, @y, 1, -1
            image.draw @x + @width, @y, 1, -1, 1
        end
    end
end

class SpriteGame < Gosu::Window
    def initialize width=800, height=600, fullscreen=false
        super
        self.caption = "Sprite Demonstration"
        @sprite = Sprite.new self
    end

    def button_down id
        close if id == Gosu::KbEscape
    end

    def update
        @sprite.update
    end

    def draw
        @sprite.draw
    end
end

SpriteGame.new.show