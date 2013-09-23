function toX3D(builder, name){

  var geometry = builder.geom
  var vertices = geometry.vertices;
  var faces    = geometry.faces;
  var uvs = builder.uvs;

  result = []
  result.push("<?xml version='1.0' encoding='UTF-8'?>");
  result.push("<!DOCTYPE X3D PUBLIC \"ISO//Web3D//DTD X3D 3.1//EN\" \"http://www.web3d.org/specifications/x3d-3.1.dtd\">");
  result.push("<X3D profile=\"Immersive\" version=\"3.1\" xsd:noNamespaceSchemaLocation=\"http://www.web3d.org/specifications/x3d-3.1.xsd\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema-instance\">");
  result.push("\
    <head>\n\
      <meta content='"+name+".x3d' name='title'/>\n\
      <meta content='X3D export from terrafab.bengler.no' name='description'/>\n\
      <meta content='"+(new Date()).toString()+"' name='created'/>\n\
      <meta content='Bengler TerraFab' name='creator'/>\n\
      <meta content='http://terrafab.bengler.no' name='reference'/>\n\
      <meta content='Bengler TerraFab, http://terrafab.bengler.no' name='generator'/>\n\
    </head>\n");
  result.push("<Scene>");
  result.push("<Shape>");
  result.push("<Appearance>");
  result.push("<ImageTexture url='texture.png'/>");
  result.push("</Appearance>");
  // Add indicies for triangles
  indicies = [];
  for(var i = 0; i<faces.length; i++){
    indicies.push([faces[i].a, faces[i].b, faces[i].c].join(' '));
  }
  result.push("<IndexedTriangleSet solid='false' index='"+indicies.join(' ')+"'>");
  // Add vertices
  points = [];
  for(var i = 0; i<vertices.length; i++){
    points.push(""+vertices[i].x/1000+" "+(-vertices[i].z/1000)+" "+vertices[i].y/1000);
  }
  result.push("<Coordinate point='"+points.join(', ')+"'/>");
  // Add UV-map
  uvmap = [];
  for(var i= 0; i < uvs.length; i++) {
    uvmap.push(""+uvs[i].x+" "+uvs[i].y);
  }
  result.push("<TextureCoordinate point='"+uvmap.join(' ')+"'/>")
  result.push("</IndexedTriangleSet>");
  result.push("</Shape>");
  result.push("</Scene>");
  result.push("</X3D>");
  return result.join("\n");
}


module.exports = toX3D;