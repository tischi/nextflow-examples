#!/usr/bin/env nextflow

# fake, not functional, created with the help of chatGPT 4
  
nextflow.enable.dsl=2

// Define parameters
params.input_folder = './images'

// Input channel with image tuples
input_images = Channel
    .fromPath("${params.input_folder}/*.png")
    .map { file -> tuple(file.baseName, file) }

workflow {

    // Run CellposeSegmentation on input images
    segmented = CellposeSegmentation(input_images)
    
    // Combine original images with their corresponding segmented images
    measurements_input = input_images.join(segmented)
    
    // Run FijiMeasurements on combined tuples
    FijiMeasurements(measurements_input)
}
  

// Cellpose process for image segmentation
process CellposeSegmentation {

    input:
    tuple val(datasetID), path(image)
    
    output:
    tuple val(datasetID), path("${datasetID}_seg.tif")
    
    script:
    """
    cellpose --input ${image} --pretrained_model cyto --save_tif
    """
}

// Fiji process for extracting intensity and morphometry measurements
process FijiMeasurements {

    input:
    tuple val(datasetID), path(original_image), path(segmented_image)

    output:
    path("${datasetID}_measurements.csv") 

    script:
    """
    fiji --headless --console -macro fiji_script.groovy "${original_image},${segmented_image},${datasetID}_measurements.csv"
    """
}


