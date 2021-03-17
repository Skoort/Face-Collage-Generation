pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = 'Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));


face1 = LoadFace('Data/Faces/face1.obj');
face2 = LoadFace('Data/Faces/face5.obj');

destColor = [0, 1, 1];%[173, 216, 230] / 255;
%face1.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, face1.nVertices, 1);
for i=1:face1.nVertices
    t = i / face1.nVertices;
    face1.VertexRGB(i, :) = [1, 1, 1] * (1 - t) + destColor * t;
end
face1.VertexRGB(3400, :) = [255, 0, 0] / 255;
face1.ColorMode = 'texture';

%face2.VertexRGB = repmat([0xff, 0xdb, 0xac] / 255, face2.nVertices, 1);
for i=1:face2.nVertices
    t = i / face2.nVertices;
    face2.VertexRGB(i, :) = [1, 1, 1] * (1 - t) + destColor * t;
end
face2.VertexRGB(3400, :) = [255, 0, 0] / 255;
face2.ColorMode = 'texture';


v1 = DrawFace(face1, "Obraz 1", false);
v1.SceneLightVisible = true;
v1.SceneLightLinked = true;
v1.CameraTarget = [0, 0, 0];
v1.CameraUpVector = [0, 1, 0];
v1.SceneLightPosition = [0, 0, 180];
v1.CameraPosition = [0, 0, 180];
saveas(v1.Figure, 'TwoPointsFace1.png');

v2 = DrawFace(face2, "Obraz 2", false);
v2.SceneLightVisible = true;
v2.SceneLightLinked = true;
v2.CameraTarget = [0, 0, 0];
v2.CameraUpVector = [0, 1, 0];
v2.SceneLightPosition = [0, 0, 180];
v2.CameraPosition = [0, 0, 180];
saveas(v2.Figure, 'TwoPointsFace2.png');