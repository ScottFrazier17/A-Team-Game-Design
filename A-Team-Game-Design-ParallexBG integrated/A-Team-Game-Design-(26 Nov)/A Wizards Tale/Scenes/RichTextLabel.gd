extends RichTextLabel


func applyTexteffects(text):
    var formatted_text = text
    formatted_text = formatted_text.replace("^b", "<b>").replace("^/b", "</b>")
    formatted_text = formatted_text.replace("^i", "<i>").replace("^/i", "</i>")
    formatted_text = formatted_text.replace("^u", "<u>").replace("^/u", "</u>")
    return formatted_text
    
func displayFormattedtext(formatted_text):
    bbcode_text = formatted_text
# Called when the node enters the scene tree for the first time.
func _ready():
    var file = File.new()
    var error = file.open("res://Text Files/credits.txt", File.READ)
    if error == OK:
        var text = file.get_as_text()
        file.close()
        
        var formatted_text = applyTexteffects(text)
        displayFormattedtext(formatted_text)
    else:
        print("Error opening the file")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
