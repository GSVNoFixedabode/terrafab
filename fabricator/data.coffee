config = require("../config/app");
helpers = require("../routes/helpers")
exec = require('child_process').exec;

class TerrainData
  constructor: (nwNorthing, nwEasting, seNorthing, seEasting, @xsamples, @ysamples) ->
    @box = [nwNorthing, nwEasting, seNorthing, seEasting]
  width: ->
    Math.abs(@box[0]-@box[2])
  height: ->
    Math.abs(@box[1]-@box[3])
  load: (onload) ->
    console.log "Executing: #{@gdalCommand()}"
    exec @gdalCommand(), (err, stdout, stderr) =>
      if err?
        console.error err
        console.error "Loading dummy data"
        @data = fs.readFileSync(__dirname+"/../dummy/dtm.bin")
        onload()
      else
        @data = fs.readFileSync(@fileName())
        onload()
  fileName: ->
    config.files.tmpPath +
      "/"+helpers.fileHash(
          "dtm_"+@box.join("_")+[@xsamples,@ysamples].join('_'), 'bin')
  gdalCommand: ->
    dtm_file = config.lib.dtmFile;
    out_type = "UInt16"
    out_scale = "0 2469 0 32767"
    out_format = "ENVI"
    out_options = null
    return "bash -c '" +
      "gdal_translate -q" +
        " -scale " + out_scale +
        " -ot " + out_type +
        " -of " + out_format +
        " -outsize " + @xsamples + " " + @ysamples +
        " -projwin " + @box.join(', ') +
        " " + dtm_file + " " + @fileName() + "'"
  isLoaded: ->
    true
  getSample: (x, y) ->
    offset = (x+y*@xsamples)*2
    return @data[offset]|@data[offset+1]<<8

module.exports = TerrainData