-- make game camera move based off current target player's note
-- this is example of scripting!1!!
function onOpponentNoteHit(note, isSustain)
    if not isSustain and not PlayScene.song.notes[PlayScene.instance.curSection].mustHitSection then
        moveCamByNote(note.noteData)
    end
end

function onGoodNoteHit(note, isSustain)
    if not isSustain and PlayScene.song.notes[PlayScene.instance.curSection].mustHitSection then
        moveCamByNote(note.noteData)
    end
end

function moveCamByNote(id)
    local exCampos = Vector2(0, 0)

    if id == 0 then
        exCampos = Vector2(-10, 0)
    elseif id == 1 then
        exCampos = Vector2(0, 10)
    elseif id == 2 then
        exCampos = Vector2(0, -10)
    else
        exCampos = Vector2(10, 0)
    end

    PlayScene.instance:moveCameraExtend(exCampos)
end