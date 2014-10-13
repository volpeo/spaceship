game = new Phaser.Game(1000, 600, Phaser.CANVAS, 'game')

mainState = {
  preload: () -> 
    this.stage.backgroundColor = '#000000';
    this.stage.smoothed=false
    PIXI.scaleModes.DEFAULT = PIXI.scaleModes.NEAREST
    this.load.image('background', 'images/background.jpg');
    this.load.image('circle', 'images/circle.png');
    this.load.image('point', 'images/waypoint.png');
    this.load.atlasJSONHash('player', 'images/spaceship.png', 'images/spaceship.json');
  

  create: () -> 
    this.physics.startSystem(Phaser.Physics.ARCADE)
    this.add.tileSprite(0, 0, 1000, 600, 'background')

    # player
    this.player = this.add.sprite(300, 300, 'player')
    this.physics.enable(this.player, Phaser.Physics.ARCADE)
    this.player.animations.add('burst', [1, 2, 3], 6, true, true)
    this.player.animations.add('stop', [0], 0)
    this.player.anchor.setTo(0.5, 0.5)
    this.player.body.maxVelocity.setTo(400, 400)
    this.player.body.collideWorldBounds = true
    this.currentSpeed = 0

    # waypoint / moving
    this.waypoint = []
    this.waypointMode = false
    this.nextPos = {x: 0, y: 0, sprite: null}
    this.moving = false

    # keys
    shift = this.input.keyboard.addKey(Phaser.Keyboard.SHIFT)
    shift.onDown.add(() ->
      this.waypointMode = true
    , this)
    shift.onUp.add(() ->
      this.waypointMode = false
    , this)

    this.input.onDown.add(() ->
      point = this.add.sprite(this.input.x, this.input.y, 'circle')
      point.anchor.setTo(0.5, 0.5)
      this.add.tween(point).to({alpha: 0}, 200).start()
      this.add.tween(point.scale).to({x: 2, y: 2}, 200).start()

      if this.waypointMode
        point = this.add.sprite(this.input.x, this.input.y, 'point')
        point.anchor.setTo(0.5, 0.5)
        this.waypoint.push({ x: this.input.x, y: this.input.y, sprite: point})
        if this.waypoint.length == 1
          this.gotoPosition(this.waypoint[0].x, this.waypoint[0].y)  
      else
        for point in this.waypoint
          point.sprite.kill()
        this.gotoPosition(this.input.x, this.input.y)
        this.waypoint = []
    , this);



  update: () -> 
    if this.player.body.velocity.isZero()
      this.moving = false
    else
      this.moving = true

    if this.waypoint.length > 0 and not this.moving
      this.gotoPosition(this.waypoint[0].x, this.waypoint[0].y)
    
    if Phaser.Rectangle.contains(this.player.body, this.nextPos.x, this.nextPos.y)
      this.player.body.velocity.set(0, 0)
      if this.waypoint.length > 0 and Phaser.Rectangle.contains(this.player.body, this.waypoint[0].x, this.waypoint[0].y)
        this.waypoint[0].sprite.kill()
        this.waypoint.shift()
      else
        this.moving = false

    if this.moving
      this.player.animations.play('burst', true)
    else
      this.player.animations.play('stop')

  gotoPosition: (x, y) ->
    this.nextPos = {x: x, y: y}
    rotation = this.physics.arcade.moveToXY(this.player, x, y, 100) + Phaser.Math.degToRad(90)
    angle = Phaser.Math.radToDeg(rotation)
    # console.log angle
    # if angle > 180
    #   rotation -= Phaser.Math.degToRad(360)
    # else if angle < -180
    #   rotation += Phaser.Math.degToRad(360)
    # console.log Phaser.Math.radToDeg(rotation)
    # console.log "--------------"

    this.add.tween(this.player).to({rotation: rotation}, 200, Phaser.Easing.Linear.None, false).start()
      
}


game.state.add('main', mainState)
game.state.start('main')