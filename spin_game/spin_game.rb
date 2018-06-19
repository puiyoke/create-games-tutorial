require "gosu"

class SpinGame < Gosu::Window
    def initialize width=480, height=480, fullscreen=false
        super
        self.caption = "Spin-Game"

        @ball = Gosu::Image.new("football.png")
        @arrow = Gosu::Image.new("arrow.png")
        @win_image = Gosu::Image.new("winner.png")
        @lose_image = Gosu::Image.new("loser.png")

        @ball_angle = 0.0
        @gameover = false
        @won = false
    end

    def update
        close if Gosu::button_down?(Gosu::KbEscape)
        return if @gameover

        if Gosu::button_down?(Gosu::KbSpace)
            @gameover = true
            @lose = did_we_lose?
            return
        end

        @ball_angle += 10.0
        @ball_angle %= 360
    end

    private
    def did_we_lose?
        return @ball_angle > 290 || @ball_angle < 210
    end

    def draw
        @arrow.draw(320, 200, 1)
        @ball.draw_rot(240, 240, 0, @ball_angle)

        if @gameover
            image = @lose ? @lose_image : @win_image
            image.draw(0, 120, 2)
        end
    end
end

SpinGame.new.show