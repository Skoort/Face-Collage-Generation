
pathToAverage = 'Data/average.obj';
pathToTemplate = 'Data/template.obj';
pathToRegions = "Data/template_color.ply";
pathToFaces = 'Data/Faces';

addpath(genpath('C:/Users/HP/Documents/GitHub/meshmonk'));

%
averageFace = LoadFace(pathToAverage);
%
template = LoadFace(pathToTemplate);
[numRegions, regionByIndex, indicesByRegion, colorPerRegion] = LoadRegions(pathToRegions);
%
[numFaces, faces] = LoadFaces(pathToFaces);
%%numFaces = 10;

numMergedFaces = 6;
[chosenFaces, chosenFacesByRegion] = ChooseRandomFaces(numFaces, numRegions, numMergedFaces);

shouldFilterRegions = true;
if shouldFilterRegions
    [numRegions, regionByIndex, indicesByRegion, chosenFacesByRegion] = FilterRegions(regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion);
end

splicedFace = SpliceFacesTogether(template, faces, numRegions, indicesByRegion, numMergedFaces, chosenFaces, chosenFacesByRegion);
%SpliceFacesTogetherCloud(pathToRegions, numRegions, indicesByRegion, numMergedFaces, chosenFacesByRegion);


v1 = DrawFace(splicedFace, "Spliced face", false);



mergeOptions = ["MERGE_SIMPLE", "MERGE_SMOOTH_DIST", "MERGE_3"];
selectedMergeOption = 3;
shouldAverageWeights = true;

if selectedMergeOption == 1
    maxDistanceToSmooth = 2;
    collageFace = MergeSimple(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
elseif selectedMergeOption == 2
    maxDistanceToSmooth = 0.25;
    collageFace = MergeSimplePercent(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
    %collageFace = ColorMerge(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
elseif selectedMergeOption == 3
    % NOTE: Not using distance here.
    collageFace = MergeSmooth(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights);  % <- Done
    %collageFace = ColorMerge(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, 4);  % <- Done
elseif selectedMergeOption == 4
    maxDistanceToSmooth = 1;
    collageFace = MergeSmoothPercent(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
    %collageFace = ColorMerge(faces, splicedFace, numRegions, regionByIndex, indicesByRegion, chosenFaces, chosenFacesByRegion, shouldAverageWeights, maxDistanceToSmooth);  % <- Done
elseif selectedMergeOption == 5
    collageFace = Merge3(splicedFace, shouldAverageWeights);  % <- To implement.
else
    warning("Incorrect merge option selected!");
end


v3 = DrawFace(collageFace, "Merge before fit");

% NOTE: This is to make the colors in correct place. Remove this.
v3.SceneLightVisible = true;
v3.SceneLightLinked = true;
v3.CameraTarget = [0, 0, 0];
v3.CameraUpVector = [0, 1, 0];
v3.SceneLightPosition = [0, 0, 180];
v3.CameraPosition = [0, 0, 180];
writePath = 'Examples/Region coloring';
saveas(v3.Figure, [writePath, '\regionsSimplePercent0_1.png']);

numFits = 1;
for i=1:numFits
    collageFace = MeshFit2(collageFace);  % <- Done
end


v4 = DrawFace(collageFace, "Merge after fit");

face = clone(collageFace);
face.VertexRGB = zeros(size(face.Vertices));
for i = 1:size(face.Vertices, 1)
    face.VertexRGB(i, :) = [1, 1, 1] * i / size(face.Vertices, 1);
end
face.ColorMode = 'texture';

verts = readmatrix("Data/template_middle_verts.txt");

face.VertexRGB(verts, :) = repmat([1, 0, 0], length(verts), 1);

i = 4000;

face.VertexRGB(i, :) = [0, 1, 0];
face.VertexRGB(face.nVertices - (i - 1), :) = [0, 0, 1];

vT = DrawFace(face, "Do colors match?");


symmetryFactor = 1;
collageFace2 = IntroduceSymmetry(collageFace, symmetryFactor);


v5 = DrawFace(collageFace2, "After introducing symmetry.");
%}


shouldAverageFaceAfterSymmetry = false;
if shouldAverageFaceAfterSymmetry
	smoothSymmetryFace = AverageFace(collageFace2);

	v6 = DrawFace(smoothSymmetryFace, "Symmetry face after average", false);
else
    smoothSymmetryFace = collageFace2;
end


shouldFitMeshAgainAfterSymmetry = false;
if shouldFitMeshAgainAfterSymmetry
	smoothSymmetryFace2 = MeshFit2(smoothSymmetryFace);  % <- Done

	v7 = DrawFace(smoothSymmetryFace2, "Symmetry face after average and refitting.", false);
else
	smoothSymmetryFace2 = smoothSymmetryFace;
end


interpAmount = 0.8;

interpolatedFace = InterpFace(splicedFace, smoothSymmetryFace2, interpAmount);  % <- Done


v8 = DrawFace(interpolatedFace, "Interpolated face", false);


factorOfAverage = 0.3;
finalFace = interpolatedFace;
numBins = 11;
upperAngleLimit = 90;
HistogramStuff(averageFace, factorOfAverage, faces, chosenFaces, finalFace, numBins, upperAngleLimit, indicesByRegion);