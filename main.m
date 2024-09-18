close all; clear; clc;

% Path to the folder containing images
pathToFolder = 'M:\US_Volume_estimation\pork\';
type = 'pork';
id = 3;

%% Tracked Linear Probe - MHA file
% Load the MHA volume
mhaVolumeName = fullfile(pathToFolder, 'track', 'reconstruction', strcat(type, '_', num2str(id), '.mha'));
mhaInfo = mha_read_header(mhaVolumeName);
mhaVolume = mha_read_volume(mhaInfo);
sliceIndexMha = round(size(mhaVolume, 3) / 2);
figure; imshow3D(mhaVolume);

% Load the expert contour
expertLabelName = fullfile(pathToFolder, 'track', 'label', strcat(type, '_', num2str(id), '_label.mha'));
expertInfo = mha_read_header(expertLabelName);
expertLabelMha = mha_read_volume(expertInfo);
figure; imshow(labeloverlay(mhaVolume(:, :, sliceIndexMha), expertLabelMha(:, :, sliceIndexMha), ...
    'Colormap', 'autumn', 'Transparency', 0.5));

% Estimate the volume of the lesion using data from the tracked linear probe
% Estimate the volume by counting the number of voxels belonging to the mask
pixelDimensions = mhaInfo.PixelDimensions;
voxelVolume = pixelDimensions(1) * pixelDimensions(2) * pixelDimensions(3); 
lesionVolumeMha = voxelVolume * sum(expertLabelMha(:));
disp(['Estimated lesion volume using tracked linear probe: ', num2str(lesionVolumeMha)]);

%% Convex Probe - DICOM file
dicomVolumeName = fullfile(pathToFolder, 'convex', 'original', strcat(type, '_', num2str(id)));
dicomVolume = dicomread(dicomVolumeName);
dicomInfo = dicominfo(dicomVolumeName);
dicomVolume = squeeze(dicomVolume);
sliceIndexDicom = round(size(dicomVolume, 3) / 2);
figure; imshow3D(dicomVolume);

% Load the expert contour
expertLabelName = fullfile(pathToFolder, 'convex', 'label', strcat(type, '_', num2str(id), '_label.mha'));
expertInfo = mha_read_header(expertLabelName);
expertLabelDicom = mha_read_volume(expertInfo);
expertLabelDicom = permute(expertLabelDicom, [2, 1, 3]);
figure; imshow(labeloverlay(dicomVolume(:, :, sliceIndexDicom), expertLabelDicom(:, :, sliceIndexDicom), ...
    'Colormap', 'autumn', 'Transparency', 0.5));

% Estimate the volume of the lesion using data from the convex probe
voxelDimensionsDicom = strsplit(dicomInfo.Private_200d_3303, '\');
voxelVolumeDicom = str2double(voxelDimensionsDicom{1}) * ...
    str2double(voxelDimensionsDicom{2}) * ...
    str2double(voxelDimensionsDicom{3}); 

lesionVolumeDicom = voxelVolumeDicom * sum(expertLabelDicom(:));
disp(['Estimated lesion volume using convex probe: ', num2str(lesionVolumeDicom)]);
