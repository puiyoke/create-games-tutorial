require "gosu"

class HelloWorldGame < Gosu::Window
    
    def initialize width=800, height=600, fullscreen=false
        super
        self.caption = "Hello World!"
        @song = Gosu::Song.new "song.wav"
        @song.play
        @sound = Gosu::Sample.new "sound.wav"
        @image = Gosu::Image.from_text("Hello World!", 100, default_font_name = {})       
    end

    def button_down id
        close if id == Gosu::KbEscape
        @sound.play if id == Gosu::KbX
    end

    def update
        #+ Math.tan(Time.now.to_f)*200
        @x = self.width/2 - @image.width/2 + Math.sin(Time.now.to_f)*150
        @y = self.height/2 - @image.height/2 + Math.cos(Time.now.to_f)*200
    end

    def draw
        @image.draw @x,
                    @y,
                    0
    end
end

HelloWorldGame.new.show