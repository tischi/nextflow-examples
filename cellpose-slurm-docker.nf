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
    
    // Resource specifications with retry logic
    memory { 16.GB * task.attempt }
    time { 30.minutes * task.attempt }
    errorStrategy { (task.exitStatus in 137..140 || task.exitStatus == 143) ? 'retry' : 'terminate' }
    maxRetries 3

    // Container
    container 'docker.io/cellpose/cellpose:latest'
}
