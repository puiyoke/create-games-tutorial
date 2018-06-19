require "gosu"

class Enemy
    attr_accessor :image, :x, :y, :direction, :alive
    SPEED = 7
    def initialize(window, images, x, y, direction)
      @window = window
      @images = images
      @x = x
      @y = y
      @direction = direction
      @alive = true
    end
  
    def update
      return unless @alive
      image = current_image
      if(@direction == :left)
        @x -= 5
      else
        @x += 5
      end
  
      if @x + image.width < 0
        @direction = :right
      elsif @x > @window.width
        @direction = :left
      end
    end
  
    def draw
      if @alive
        image = current_image
      else
        image = @images.last
      end
      image.draw(@direction == :left ? @x : @x + image.width + 20, @y, 1, @direction == :left ? 1 : -1)
    end
  
    def body
      image = current_image
      {:x => @x + 50,
       :y => @y + 20,
       :width => image.width - 80,
       :height => image.height - 50}
    end
  
    def current_image
      @images[(Gosu::milliseconds / 100 % 4)]
    end


end

class GameBasic < Gosu::Window
    def initialize height=800, width=600, fullscreen=false
        super
        self.caption = "Game Basics"
        @background = Gosu::Image.new("background.png")
        @hero_position = [30, 410]
        @enemy_position = [500, 390]
        @hero_direction = :right
        # hero_spritesheet.png[stand still, walk1, walk2, walk3, jump up, fall down]
        @hero = Gosu::Image::load_tiles("hero_spritesheet.png", 160, 132)
        @current_hero_image = @hero.first
        # @enemy = Gosu::Image.new("enemy_idle.png")
        @enemy_images = Gosu::Image::load_tiles("enemy_spritesheet.png", 142, 160)
        @enemies = [Enemy.new(self, @enemy_images, 500, 390, :left)]
        @score = 0
        @font = Gosu::Font.new(64, :name => "Pixeled.ttf") 
    end

    def update
        close if Gosu::button_down?(Gosu::KbEscape)

        if Gosu::button_down?(Gosu::KbRight)
            move(:right)
        elsif
            Gosu::button_down?(Gosu::KbLeft)
            move(:left)
        else
            @walking = false
        end

        jump if Gosu::button_down?(Gosu::KbUp)
        handle_jump if @jumping

        @enemies.each{|enemy| enemy.update}

        if @hurt_until
            @current_hero_image = @hero[6]
            @hurt_until = nil if Gosu::milliseconds > @hurt_until
        elsif @jumping
            @current_hero_image = @vertical_velocity > 0 ?
                                  @hero[4] : @hero[5]
        elsif @walking
            # Gosu::milliseconds returns the number of millis since the game started.  We want to see
            # a new animation frame about every 100 milliseconds or so, and we have three animation frames
            step = (Gosu::milliseconds / 100 % 3) + 1
            @current_hero_image  = @hero[step]
        else
            @current_hero_image = @hero.first
        end
        handle_collisions
    end

    def draw
        @background.draw(0, 0, 0)
        @enemies.each{|enemy| enemy.draw}
        if @hero_direction == :right
            @current_hero_image.draw(@hero_position[0], @hero_position[1], 1)
        else
            #@current_hero_image.width + 20 is to prevent collision rectangle from shifting when hero changes direction
            @current_hero_image.draw(@hero_position[0] + @current_hero_image.width + 20, @hero_position[1], 1, -1)
        end
        # @enemy.draw(@enemy_position[0], @enemy_position[1], 1)
        draw_collision_bodies
        @font.draw("Score: #{@score}", 5, 0, 10)
    end

    private

    def spawn_enemies
        random = [-110, 850]
        @enemies.push(Enemy.new(self, @enemy_images, random[rand(2)], 390, :left))
    end

    def move(way)
        return if @hurt_until
        speed = 5
        @walking = true
        if way == :right
            @hero_position[0] += speed
            @hero_direction = :right
        elsif way == :left
            @hero_position[0] -= speed
            @hero_direction = :left
        end
    end

    def jump
        return if @jumping || @hurt_until
        @jumping = true
        @vertical_velocity = 60
    end

    def handle_jump
        gravity = 1.3
        ground_level = 410
        @hero_position = [@hero_position[0],
                          @hero_position[1] - @vertical_velocity]
        if @vertical_velocity.round == 0  # top of the jump
            @vertical_velocity = -1
        elsif @vertical_velocity < 0 #falling
            @vertical_velocity = @vertical_velocity * gravity
        else #going up
            @vertical_velocity = @vertical_velocity / gravity
        end

        if @hero_position[1] >= ground_level
            @hero_position[1] = ground_level
            @jumping = false
        end
    end

    def handle_collisions
        # did the enemy and player collide?
        @player_rectangle =  {:x => @hero_position[0] + 50,
                            :y => @hero_position[1] + 10,
                            :width => @current_hero_image.width - 80,
                            :height => @current_hero_image.height - 30}
        # @enemy_rectangle = {:x => @enemy_position[0] + 50,
        #                     :y => @enemy_position[1] + 20,
        #                     :width => @enemy.width - 80,
        #                     :height => @enemy.height - 50}
        @enemies.each do |enemy|
            return if @hurt_until
            next unless enemy.alive
            collision = check_for_collisions(@player_rectangle, enemy.body)
            if collision == :left
                @hero_position[0] += 30
                @hurt_until = Gosu::milliseconds + 200
            elsif collision == :right
                @hero_position[0] -= 30
                @hurt_until = Gosu::milliseconds + 200
            elsif collision == :bottom
                @jumping = true
                @vertical_velocity = 10
                enemy.alive = false
                @score += 1
                spawn_enemies
            end
        end
    end
    
    def draw_collision_bodies
        draw_bounding_body(@player_rectangle)
        @enemies.each do |enemy|
            draw_bounding_body(enemy.body)
        end
    end
    
    #to run draw_bounding_body type "ruby -d game_basic.rb" in terminal
    def draw_bounding_body(rect, z = 10, color = Gosu::Color::GREEN)
        return unless $DEBUG
        Gosu::draw_line(rect[:x], rect[:y], color, rect[:x], rect[:y] + rect[:height], color, z)
        Gosu::draw_line(rect[:x], rect[:y] + rect[:height], color, rect[:x] + rect[:width], rect[:y] + rect[:height], color, z)
        Gosu::draw_line(rect[:x] + rect[:width], rect[:y] + rect[:height], color, rect[:x] + rect[:width], rect[:y], color, z)
        Gosu::draw_line(rect[:x] + rect[:width], rect[:y], color, rect[:x], rect[:y], color, z)
    end
    
    def check_for_collisions(rect1, rect2)
        # returns :top, :bottom, :left :right for the most intersected part, relative to
        # rect1 (so you can tell if you're jumping on a bad guy or running into him)
        # nil if no collisions
        intersection = rec_intersection([[rect1[:x], rect1[:y]],
                                         [rect1[:x] + rect1[:width], rect1[:y] + rect1[:height]]],
                                        [[rect2[:x], rect2[:y]],
                                         [rect2[:x] + rect2[:width], rect2[:y] + rect2[:height]]])
        if intersection
          top_left, bottom_right = intersection
          # if wider than tall, which works since our enemies are tallish
          if (bottom_right[0] - top_left[0]) > (bottom_right[1] - top_left[1])
            # top or bottom?
            if rect1[:y] == top_left[1]
              :top
            else
              :bottom
            end
          else
            # left or right?
            if rect1[:x] == top_left[0]
              :left
            else
              :right
            end
          end
        else
          nil
        end
    end
    
    def rec_intersection(rect1, rect2)
        # http://stackoverflow.com/questions/19442068/how-does-this-code-find-the-rectangle-intersection
        x_min = [rect1[0][0], rect2[0][0]].max
        x_max = [rect1[1][0], rect2[1][0]].min
        y_min = [rect1[0][1], rect2[0][1]].max
        y_max = [rect1[1][1], rect2[1][1]].min
        return nil if ((x_max < x_min) || (y_max < y_min))
        return [[x_min, y_min], [x_max, y_max]]
    end
end


GameBasic.new.show