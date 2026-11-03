extends Control

const PASTEL_BASE := preload("res://assets/pastel/pastel_base.png")
const FRANGO := preload("res://assets/pastel/frango_cremoso.png")
const CARNE := preload("res://assets/pastel/carne_queijo.png")
const PALMITO := preload("res://assets/pastel/palmito.png")
const REWARD := preload("res://assets/pastel/mordida_pastel.png")

const INK := Color("#2c211b")
const MUTED := Color("#7e6b5c")
const CREAM := Color("#fff8ed")
const PAPER := Color("#f4e6d0")
const YELLOW := Color("#f3b51b")
const TOMATO := Color("#d94835")
const GREEN := Color("#4f7b5c")
const BROWN := Color("#8f5d35")
const WOOD := Color("#c9915a")

const ITEMS := [
	{"id":"massa", "name":"Pastel tradicional", "category":"Massa", "price":4.50, "emoji":"P", "description":"Crocante e dourado"},
	{"id":"carne", "name":"Carne com queijo", "category":"Recheios", "price":8.90, "emoji":"C", "description":"Moída temperada + muçarela", "texture":CARNE},
	{"id":"frango", "name":"Frango cremoso", "category":"Recheios", "price":8.50, "emoji":"F", "description":"Frango desfiado + cremoso", "texture":FRANGO},
	{"id":"palmito", "name":"Palmito da casa", "category":"Recheios", "price":8.20, "emoji":"P", "description":"Palmito, milho e ervilha", "texture":PALMITO},
	{"id":"pimenta", "name":"Pimenta da casa", "category":"Molhos", "price":1.50, "emoji":"!", "description":"Ardência na medida"},
	{"id":"vinagrete", "name":"Vinagrete fresco", "category":"Molhos", "price":1.50, "emoji":"V", "description":"Tomate, cebola e cheiro-verde"},
	{"id":"verde", "name":"Molho verde", "category":"Molhos", "price":1.90, "emoji":"M", "description":"Cremoso e herbal"},
	{"id":"queijo", "name":"Queijo extra", "category":"Extras", "price":2.80, "emoji":"Q", "description":"Mais queijo derretido"},
	{"id":"azeitona", "name":"Azeitona", "category":"Extras", "price":1.20, "emoji":"A", "description":"Toque salgado"},
	{"id":"milho", "name":"Milho crocante", "category":"Extras", "price":1.20, "emoji":"M", "description":"Docinho e colorido"}
]
const CATEGORIES := ["Massa", "Recheios", "Molhos", "Extras"]

var _category := "Recheios"
var _selected: Array[String] = ["massa"]
var _title_screen: Control
var _category_buttons: Dictionary = {}
var _content: VBoxContainer
var _ingredient_grid: GridContainer
var _board: PanelContainer
var _base_image: TextureRect
var _filling_image: TextureRect
var _board_chips: HFlowContainer
var _summary_list: VBoxContainer
var _subtotal_label: Label
var _status_label: Label
var _finish_button: Button
var _overlay: ColorRect
var _result_card: PanelContainer
var _result_score: Label
var _result_copy: Label
var _hero_tag: Label
var _category_title: Label
var _category_hint: Label
var _toast: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_title_screen = self
	_build_interface()
	_refresh_category()
	_refresh_board()
	_refresh_summary()

func _process(_delta: float) -> void:
	if _toast != null and _toast.modulate.a > 0.0:
		_toast.modulate.a = maxf(0.0, _toast.modulate.a - _delta * 0.45)

func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = Color("#261913")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var top_texture := ColorRect.new()
	top_texture.color = Color("#3b2418")
	top_texture.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_texture.size.y = 96.0
	top_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_texture)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	root.add_theme_constant_override("margin_left", 32)
	root.add_theme_constant_override("margin_right", 32)
	root.add_theme_constant_override("margin_top", 22)
	root.add_theme_constant_override("margin_bottom", 22)
	add_child(root)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 62.0
	header.add_theme_constant_override("separation", 18)
	root.add_child(header)
	var brand := VBoxContainer.new()
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.add_theme_constant_override("separation", 0)
	header.add_child(brand)
	var kicker := _label("PASTELARIA ARTESANAL • MONTE DO SEU JEITO", 11, YELLOW)
	brand.add_child(kicker)
	var title := _label("Pastelaria do Bairro", 30, CREAM)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.25))
	title.add_theme_constant_override("shadow_offset_y", 2)
	brand.add_child(title)
	var header_note := _label("ingredientes honestos, crocância garantida", 12, Color("#d6bda3"))
	brand.add_child(header_note)
	var order_chip := PanelContainer.new()
	order_chip.add_theme_stylebox_override("panel", _panel_style(Color("#52311f"), Color("#805337"), 14, 1))
	order_chip.custom_minimum_size = Vector2(176, 48)
	header.add_child(order_chip)
	var order_text := _label("PEDIDO #042\nmontagem livre", 11, CREAM)
	order_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	order_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	order_chip.add_child(order_text)

	var divider := ColorRect.new()
	divider.color = Color("#a66d3f")
	divider.custom_minimum_size.y = 1.0
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(divider)
	root.add_child(_spacer(18))

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	root.add_child(body)

	var side := _panel(Color("#fff8ed"), Color("#d7b993"), 18)
	side.custom_minimum_size.x = 188.0
	body.add_child(side)
	var side_box := VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 10)
	side.add_child(side_box)
	var side_head := _label("MONTAGEM", 11, TOMATO)
	side_box.add_child(side_head)
	var side_copy := _label("Escolha uma categoria\ne monte seu pastel.", 14, INK)
	side_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_box.add_child(side_copy)
	side_box.add_child(_spacer(8))
	for category in CATEGORIES:
		var button := Button.new()
		button.text = category
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.y = 42.0
		button.add_theme_font_size_override("font_size", 15)
		button.pressed.connect(_select_category.bind(category))
		_category_buttons[category] = button
		side_box.add_child(button)
	side_box.add_spacer(false)
	var tip := _label("Dica do bairro\nMisture cremoso + crocante para ganhar mais pontos.", 11, MUTED)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_box.add_child(tip)

	var middle := VBoxContainer.new()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_theme_constant_override("separation", 12)
	body.add_child(middle)
	var middle_top := HBoxContainer.new()
	middle.add_child(middle_top)
	var middle_title := VBoxContainer.new()
	middle_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle_top.add_child(middle_title)
	_category_title = _label("Escolha o recheio", 23, CREAM)
	middle_title.add_child(_category_title)
	_category_hint = _label("Clique em um cartão para colocar no pedido", 12, Color("#d6bda3"))
	middle_title.add_child(_category_hint)
	_hero_tag = _label("feito na hora", 11, YELLOW)
	_hero_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	middle_top.add_child(_hero_tag)

	_board = _panel(Color("#d59a5e"), Color("#f1c58d"), 22)
	_board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board.custom_minimum_size.y = 300.0
	middle.add_child(_board)
	var board_root := Control.new()
	board_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board.add_child(board_root)
	var paper := ColorRect.new()
	paper.color = Color("#e9c083")
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	paper.position += Vector2(12, 12)
	paper.size -= Vector2(24, 24)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_root.add_child(paper)
	var board_caption := _label("SEU PASTEL", 10, Color("#8c5832"))
	board_caption.position = Vector2(22, 18)
	board_root.add_child(board_caption)
	_base_image = TextureRect.new()
	_base_image.texture = PASTEL_BASE
	_base_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_base_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_base_image.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_base_image.position = Vector2(-180, -102)
	_base_image.size = Vector2(360, 220)
	_base_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_root.add_child(_base_image)
	_filling_image = TextureRect.new()
	_filling_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_filling_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_filling_image.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_filling_image.position = Vector2(-135, -78)
	_filling_image.size = Vector2(270, 165)
	_filling_image.modulate = Color(1, 1, 1, 0.92)
	_filling_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_root.add_child(_filling_image)
	_board_chips = HFlowContainer.new()
	_board_chips.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_board_chips.position = Vector2(24, -42)
	_board_chips.size.y = 30
	_board_chips.add_theme_constant_override("separation", 7)
	board_root.add_child(_board_chips)
	var board_hint := _label("Clique nos cartões ao lado para adicionar • clique no item abaixo para remover", 11, Color("#8c5832"))
	board_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	board_hint.position = Vector2(24, -21)
	board_root.add_child(board_hint)

	var choose_panel := _panel(Color("#3b2418"), Color("#805337"), 14)
	choose_panel.custom_minimum_size.y = 180.0
	middle.add_child(choose_panel)
	var choose_box := VBoxContainer.new()
	choose_box.add_theme_constant_override("separation", 8)
	choose_panel.add_child(choose_box)
	_content = choose_box
	_ingredient_grid = GridContainer.new()
	_ingredient_grid.columns = 3
	_ingredient_grid.add_theme_constant_override("h_separation", 9)
	_ingredient_grid.add_theme_constant_override("v_separation", 9)
	choose_box.add_child(_ingredient_grid)

	var summary := _panel(Color("#fff8ed"), Color("#d7b993"), 18)
	summary.custom_minimum_size.x = 246.0
	body.add_child(summary)
	var summary_box := VBoxContainer.new()
	summary_box.add_theme_constant_override("separation", 10)
	summary.add_child(summary_box)
	var receipt_head := HBoxContainer.new()
	summary_box.add_child(receipt_head)
	var receipt_title := _label("SEU PEDIDO", 11, TOMATO)
	receipt_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	receipt_head.add_child(receipt_title)
	var live := _label("● AO VIVO", 10, GREEN)
	receipt_head.add_child(live)
	var receipt_sub := _label("Pastel feito na hora", 20, INK)
	summary_box.add_child(receipt_sub)
	var line := ColorRect.new()
	line.color = Color("#dec6a8")
	line.custom_minimum_size.y = 1
	summary_box.add_child(line)
	_summary_list = VBoxContainer.new()
	_summary_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_box.add_child(_summary_list)
	var total_line := HBoxContainer.new()
	summary_box.add_child(total_line)
	var total_text := _label("TOTAL ESTIMADO", 11, MUTED)
	total_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	total_line.add_child(total_text)
	_subtotal_label = _label("R$ 0,00", 24, INK)
	total_line.add_child(_subtotal_label)
	_finish_button = Button.new()
	_finish_button.text = "FINALIZAR PEDIDO  →"
	_finish_button.custom_minimum_size.y = 54
	_finish_button.add_theme_font_size_override("font_size", 14)
	_finish_button.pressed.connect(_finish_order)
	summary_box.add_child(_finish_button)
	var summary_note := _label("Você pode trocar qualquer item antes de finalizar.", 10, MUTED)
	summary_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_box.add_child(summary_note)

	var footer := HBoxContainer.new()
	footer.custom_minimum_size.y = 30.0
	root.add_child(footer)
	_status_label = _label("Monte do seu jeito e descubra sua combinação perfeita.", 12, Color("#d6bda3"))
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(_status_label)
	var footer_right := _label("offline • sem cadastro • só diversão", 10, Color("#98765c"))
	footer.add_child(footer_right)

	_toast = _label("", 14, CREAM)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_toast.position = Vector2(-190, 86)
	_toast.size = Vector2(380, 38)
	_toast.modulate.a = 0.0
	add_child(_toast)

	_overlay = ColorRect.new()
	_overlay.color = Color(0.08, 0.04, 0.02, 0.75)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	_overlay.z_index = 20
	add_child(_overlay)
	_build_result_card()
	_apply_button_theme()
	resized.connect(_on_resized)

func _build_result_card() -> void:
	_result_card = _panel(Color("#fff8ed"), Color("#f3b51b"), 22)
	_result_card.custom_minimum_size = Vector2(500, 420)
	_result_card.set_anchors_preset(Control.PRESET_CENTER)
	_result_card.position = Vector2(-250, -210)
	_result_card.z_index = 21
	_result_card.visible = false
	add_child(_result_card)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	_result_card.add_child(box)
	var image := TextureRect.new()
	image.texture = REWARD
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(300, 160)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(image)
	var over := _label("PEDIDO APROVADO", 11, TOMATO)
	over.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(over)
	var headline := _label("Esse pastel ficou brabo!", 28, INK)
	headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(headline)
	_result_score = _label("100 PONTOS", 34, TOMATO)
	_result_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_result_score)
	_result_copy = _label("", 13, MUTED)
	_result_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_result_copy)
	var again := Button.new()
	again.text = "MONTAR OUTRO PASTEL"
	again.custom_minimum_size.y = 48
	again.pressed.connect(_reset_order)
	box.add_child(again)

func _refresh_category() -> void:
	if _ingredient_grid == null:
		return
	for child in _ingredient_grid.get_children():
		child.queue_free()
	_category_title.text = "Escolha " + ("a massa" if _category == "Massa" else "o " + _category.to_lower())
	_category_hint.text = "Clique em um cartão para adicionar ao pedido"
	for category in CATEGORIES:
		var button: Button = _category_buttons.get(category)
		if button:
			button.add_theme_stylebox_override("normal", _panel_style(PAPER if _category == category else Color("#efe0ca"), YELLOW if _category == category else Color("#e3c9a6"), 10, 1))
			button.add_theme_color_override("font_color", INK)
	for item in ITEMS:
		if item["category"] != _category:
			continue
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 108)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", _panel_style(Color("#fff8ed"), Color("#d7b993"), 12, 1))
		var content := VBoxContainer.new()
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		content.add_theme_constant_override("separation", 2)
		card.add_child(content)
		var button := Button.new()
		button.flat = true
		button.text = str(item["emoji"])
		button.custom_minimum_size.y = 42
		button.add_theme_font_size_override("font_size", 28)
		button.pressed.connect(_add_item.bind(str(item["id"])))
		content.add_child(button)
		var name := _label(str(item["name"]), 12, INK)
		name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(name)
		var detail := _label("R$ %.2f" % float(item["price"]), 10, TOMATO)
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(detail)
		_ingredient_grid.add_child(card)
	if _category == "Massa":
		_category_hint.text = "A massa tradicional já está no pedido"

func _add_item(id: String) -> void:
	var item := _item_by_id(id)
	if item.is_empty():
		return
	if id == "massa":
		_selected = ["massa"] + _selected.filter(func(value: String) -> bool: return value != "massa")
	elif str(item["category"]) == "Molhos":
		_selected = _selected.filter(func(value: String) -> bool: return str(_item_by_id(value).get("category", "")) != "Molhos")
		_selected.append(id)
	elif not _selected.has(id):
		if _selected.size() >= 5:
			_show_toast("Seu pastel já está bem recheado!")
			return
		_selected.append(id)
	_show_toast(str(item["name"]) + " adicionado")
	_refresh_board()
	_refresh_summary()

func _remove_item(id: String) -> void:
	if id == "massa":
		return
	_selected.erase(id)
	_refresh_board()
	_refresh_summary()
	_show_toast("Item removido")

func _refresh_board() -> void:
	if _board_chips == null:
		return
	for child in _board_chips.get_children():
		child.queue_free()
	_filling_image.texture = null
	for id in _selected:
		var item := _item_by_id(id)
		if item.has("texture"):
			_filling_image.texture = item["texture"]
			_filling_image.modulate = Color(1, 1, 1, 0.9)
		var chip := Button.new()
		chip.text = "  " + str(item["emoji"]) + " " + str(item["name"]) + "  ×"
		chip.custom_minimum_size.y = 28
		chip.add_theme_font_size_override("font_size", 10)
		chip.pressed.connect(_remove_item.bind(id))
		chip.add_theme_stylebox_override("normal", _panel_style(Color("#fff8ed"), Color("#c78950"), 10, 1))
		chip.add_theme_stylebox_override("hover", _panel_style(Color("#ffe7c2"), TOMATO, 10, 1))
		chip.add_theme_color_override("font_color", INK)
		_board_chips.add_child(chip)
	_board.modulate = Color(1.02, 1.0, 0.96)
	var tween := create_tween()
	tween.tween_property(_board, "modulate", Color.WHITE, 0.22)

func _refresh_summary() -> void:
	if _summary_list == null:
		return
	for child in _summary_list.get_children():
		child.queue_free()
	var total := 0.0
	for id in _selected:
		var item := _item_by_id(id)
		if item.is_empty():
			continue
		total += float(item["price"])
		var line := HBoxContainer.new()
		var name := _label(str(item["name"]), 12, INK)
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(name)
		line.add_child(_label("R$ %.2f" % float(item["price"]), 12, MUTED))
		_summary_list.add_child(line)
	_subtotal_label.text = "R$ %.2f" % total
	_finish_button.disabled = _selected.size() < 2
	_status_label.text = "%d item(ns) na montagem • %s" % [_selected.size(), "quase pronto" if _selected.size() >= 3 else "adicione um recheio"]

func _finish_order() -> void:
	if _selected.size() < 2:
		_show_toast("Escolha pelo menos um recheio")
		return
	var fillings := 0
	var sauces := 0
	var extras := 0
	for id in _selected:
		var category := str(_item_by_id(id).get("category", ""))
		if category == "Recheios": fillings += 1
		elif category == "Molhos": sauces += 1
		elif category == "Extras": extras += 1
	var score := 55 + fillings * 16 + sauces * 8 + extras * 5
	if fillings > 0 and sauces > 0: score += 8
	if extras > 0: score += 4
	_result_score.text = "%d PONTOS" % score
	_result_copy.text = "%d recheio(s), %d molho e %d extra(s).\nSua combinação tem equilíbrio e personalidade." % [fillings, sauces, extras]
	_overlay.visible = true
	_result_card.visible = true
	_result_card.modulate.a = 0.0
	_result_card.scale = Vector2(0.94, 0.94)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_result_card, "modulate:a", 1.0, 0.22)
	tween.tween_property(_result_card, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _reset_order() -> void:
	_selected = ["massa"]
	_overlay.visible = false
	_result_card.visible = false
	_category = "Recheios"
	_refresh_category()
	_refresh_board()
	_refresh_summary()
	_show_toast("Bancada limpa. Bora montar!")

func _select_category(category: String) -> void:
	_category = category
	_refresh_category()

func _item_by_id(id: String) -> Dictionary:
	for item in ITEMS:
		if str(item["id"]) == id:
			return item
	return {}

func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.4)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.55)

func _on_resized() -> void:
	if _result_card == null:
		return
	_result_card.position = Vector2(size.x * 0.5 - _result_card.size.x * 0.5, size.y * 0.5 - _result_card.size.y * 0.5)

func _apply_button_theme() -> void:
	_finish_button.add_theme_stylebox_override("normal", _panel_style(TOMATO, Color("#ff8066"), 12, 1))
	_finish_button.add_theme_stylebox_override("hover", _panel_style(Color("#ed654d"), Color("#ffad86"), 12, 1))
	_finish_button.add_theme_stylebox_override("disabled", _panel_style(Color("#c7b8a7"), Color("#c7b8a7"), 12, 1))
	_finish_button.add_theme_color_override("font_color", CREAM)
	_finish_button.add_theme_color_override("font_hover_color", CREAM)

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _panel(background: Color, border: Color, radius: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(background, border, radius, 1))
	return panel

func _panel_style(background: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0.08, 0.04, 0.02, 0.20)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 3)
	return style

func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	return spacer
