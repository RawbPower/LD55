extends Label

var win_lines = ["Wow! You have\n summoned great\n courage... Get it?", "Counting!", "You can't spell\n summon without sum!", "You'll advance to\n summoning circles\n in no time!", "You're a\n mathemagicain!", "Numbers are the\n real magic!", "You summoned all\n your strength!", "You are sum\n sort of genius!", "Inspirational!", "A+++", "That's more\n impressive than\n any spell!", "Numbers!", "My favourite\n student!"]

func set_random_win_line():
	$TextureRect.visible = true
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$TextureRect/TextureRect/Label.text = win_lines[rng.randi_range(0, win_lines.size()-1)]
