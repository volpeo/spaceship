game = new Phaser.Game(800, 600, Phaser.AUTO, 'game')

mainState = {
  preload: () -> 
    game.stage.backgroundColor = '#000000';
    game.load.image('background', '/images/background.jpg');
    game.load.atlasJSONHash('player', 'images/spaceship.png', 'images/spaceship.json');
  

  create: () -> 
    game.physics.startSystem(Phaser.Physics.ARCADE)
    game.add.tileSprite(0, 0, 1000, 600, 'background')

    # player
    this.player = this.game.add.sprite(300, 300, 'player')
    game.physics.enable(this.player, Phaser.Physics.ARCADE)
    this.player.animations.add('burst', [1, 2, 3], 6, true, true)
    this.player.animations.add('stop', [0], 0)
    this.player.anchor.setTo(0.5, 0.5)
    this.player.body.maxVelocity.setTo(400, 400)
    this.player.body.collideWorldBounds = true
    this.currentSpeed = 0

    # waypoint / moving
    this.waypoints = []
    this.waypointMode = false
    this.nextPos = {x: 0, y: 0}
    this.moving = false

    # keys
    shift = game.input.keyboard.addKey(Phaser.Keyboard.SHIFT)
    shift.onDown.add(() ->
      this.waypointMode = true
    , this)
    shift.onUp.add(() ->
      this.waypointMode = false
    , this)

  update: () -> 

    if game.input.mousePointer.isDown
      this.moving = true
      if this.waypointMode
        this.waypoints.push({ x: game.input.x, y: game.input.y})
      else
        this.gotoPosition(game.input.x, game.input.y)
        this.waypoints = []

    if this.waypoints.length > 0
      this.gotoPosition(this.waypoints[0].x, this.waypoints[0].y)
    
    if (Phaser.Rectangle.contains(this.player.body, this.nextPos.x, this.nextPos.y))
      this.player.body.velocity.setTo(0, 0)
      if this.waypoints.length > 0
        this.waypoints.shift()
      else
        this.moving = false

    if this.moving
      this.player.animations.play('burst', true)
    else
      this.player.animations.play('stop')

  gotoPosition: (x, y) ->
    this.nextPos = {x: x, y: y}
    this.player.rotation = game.physics.arcade.moveToXY(this.player, x, y, 100) + Phaser.Math.degToRad(90)
      
}

game.state.add('main', mainState)
game.state.start('main')