extends Node2D

@onready var field = $TileMap
@onready var OneBall = preload("res://one_ball.tscn")

var balls_width = 3
var balls_height = 3
@onready var offset = Vector2(field.tile_set.tile_size * 2)

const PATTERNS = {
	"start": [[0,0,"RED"],[0,2,"RED"],[1,2,"BLUE"]]
}

const IDS = {
	"RED": {"color": Color.RED},
	"BLUE": {"color": Color.CYAN},
	"GRAY": {"color": Color.GRAY},
}


var field_arr = [
	[null, null, null],
	[null, null, null],
	[null, null, null],
]

func _ready():
	fill_starting_field_arr("start")
	fill_starting_field()

func set_coord(node, node_pos_in_tile):
	node.position = field.map_to_local(node_pos_in_tile) + offset

func fill_starting_field_arr(pattern_key):
	var arr_width = []
	var arr_height = []
	for i in balls_width:
		arr_width.append(null)
	for i in balls_height:
		arr_height.append(arr_width.duplicate())
	field_arr = arr_height.duplicate()
	
	for i in PATTERNS[pattern_key]:
		field_arr[i[0]][i[1]] = i[2]
	

func fill_starting_field():
	for i in field_arr.size():
		for j in field_arr[i].size():
			if field_arr[i][j] == null:
				add_one_ball("GRAY",i,j)
			else:
				add_one_ball(field_arr[i][j],i,j)
#			print(field_arr[i][j],[i,j])

func add_one_ball(id,x,y):
	var one_ball = OneBall.instantiate()
	set_coord(one_ball,Vector2i(x,y))
	one_ball.get_node("ColorRect").color = IDS[id]["color"]
	field.add_child(one_ball)
	one_ball.connect("ball_pressed", Callable(self,"move_ball"))

func move_ball(ball):
	var ball_coord = get_ball_coord(ball)
	var neibh = cut_offield_cells(field.get_surrounding_cells(ball_coord))
	
	for i in neibh:
		field_arr[i.x][i.y] = generate_new_ball_id(field_arr[i.x][i.y],get_ball_id(ball_coord.x,ball_coord.y))
	field_arr[ball_coord.x][ball_coord.y] = "GRAY"
	update_field()
	
func cut_offield_cells(cells_array):
	var cutted_array = []
	for i in cells_array:
		if clamp(i.x, 0 , balls_width - 1 ) == i.x and clamp(i.y, 0 , balls_height - 1) == i.y:
			cutted_array.append(i)
	return cutted_array

func get_ball_id(x,y):
	return field_arr[x][y]

func update_field():
	for i in field.get_children():
		var ball_coord =  get_ball_coord(i)
		#меняем отображение шара соотв. id в массиве
		var ball_id = field_arr[ball_coord.x][ball_coord.y]
		if ball_id == null:
			pass
		else:
			i.get_node("ColorRect").color = IDS[ball_id]["color"]

func get_ball_coord(ball):
	return field.local_to_map(ball.position - offset)
	
func generate_new_ball_id(ball_id,addind_ball_id):
	if ball_id == addind_ball_id:
		return "BLUE"
	else:
		return "RED"
