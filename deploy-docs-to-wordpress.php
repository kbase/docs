<?php
/*
 deploy-docs-to-wordpress.php

Copies doc files to the uploads directory of the related wordpress installation.

Depends on a specific directory layout

 docroot
   external-content
     docs
   wordpress
     uploads
       kb-include
         docs


Simply copies them to the right directory, for now. No validation other than existence
Of the source file.

This ensures that we don't just have the entire docs repo reachable by the web server.

Docs are pulled into the site in two ways:

1. The document templates look for specific content fields to contain the name of a file
to include, and just include it. The container directory of the file is hardcoded into the
template, so that content managers can't get to arbitrary file locations.

2. Some documents have inline content like images. In the last iteration of the site these
were hard-coded into the docuents as C5 file references. This is not good because it creates
a dependency between the document and C5. We are returning the references to plain image
references. (Haven't worked that out yet -- probably need to rewrite the image urls.)

*/

$source = realpath(".");
$target = realpath("../../wordpress/wp-content/uploads/kb-include/docs");

$files = [
  'genome_annotation/RELEASE_NOTES.txt',
  'command_line_prod/Genome_Annotation_CommandLineHelp.txt', 
  'genome_annotation/API/genome_annotation.html',
  'genome_annotation/API/genome_annotation_nav.html',
  'genome_annotation/tutorials/outdated_tutorials/annotating_a_genome.html',
  
  'assembly/RELEASE_NOTES.txt',
  'command_line_prod/Assembly_Service_CommandLineHelp.txt',
  'assembly/tutorials/client_walkthrough.html',
  'assembly/tutorials/quast.png',
  
  'auth/RELEASE_NOTES-auth.txt',
  'auth/RELEASE_NOTES-auth_service.txt',
  'command_line_prod/Authorization_Service_CommandLineHelp.txt',
  'auth/PerlClientTutorial.html',
  
  'kb_seed/RELEASE_NOTES.txt',
  'kb_seed/API/cdmi-scripts-body.html',
  'kb_seed/API/cdmi-er-scripts-body.html',
  'kb_seed/API/cdmi_api.html',
  'kb_seed/API/cdmi_api_nav.html',
  'kb_seed/tutorials/basic_exercises.html',
  'kb_seed/tutorials/command_line_pipes.html',
  'kb_seed/tutorials/The_Corresponds_and_Close_Genomes_Commands.html',
  
  'cmonkey/RELEASE_NOTES.txt',
  'cmonkey/API/cmonkey.html',
  'cmonkey/API/cmonkey_nav.html',
  
  'communities_api/RELEASE_NOTES.txt',
  'command_line_prod/Communities_API_Service_CommandLineHelp.txt',
  'communities/API/communities_api.html',
  'communities/API/communities_api_nav.html',
  
  'cbd/RELEASE_NOTES.txt',
  'command_line_prod/CBD_Service_CommandLineHelp.txt',
  'cbd/API/CompressionBasedDistance.html',
  'cbd/API/CompressionBasedDistance_nav.html',
  
  'expression/RELEASE_NOTES.txt',
  'command_line_prod/Expression_Service_CommandLineHelp.txt',
  'expression/API/ExpressionServices.html',
  'expression/API/ExpressionServices_nav.html',
  
  'KBaseFBAModeling/build/kbase_us/RELEASE_NOTES.txt',
  'command_line_prod/FBA_Model_Service_CommandLineHelp.txt',
  'KBaseFBAModeling/build/kbase_us/API/KBaseFBAModeling.html',
  'KBaseFBAModeling/build/kbase_us/API/KBaseFBAModeling_nav.html',
  'KBaseFBAModeling/tutorials/FBABuildGenomeModel.html',  
  'KBaseFBAModeling/tutorials/img',
  
  'functional_ortholog_predictor/build/kbase_us/RELEASE_NOTES.txt',
  'functional_ortholog_predictor/build/kbase_us/API/FunctionalOrthologPredictor.html',
  'functional_ortholog_predictor/build/kbase_us/API/FunctionalOrthologPredictor_nav.html',
  
  'command_line_prod/Genotype_Phenotype_Service.txt',
  'genotype_phenotype/build/kbase_us/API/GenotypePhenotypeAPI.html',
  'genotype_phenotype/build/kbase_us/API/GenotypePhenotypeAPI_nav.html',
  'genotype_phenotype/genotype-to-phenotype-tutorial.html',
  
  'id_map/RELEASE_NOTES.txt',
  'id_map/API/IdMap.html',
  'id_map/API/IdMap_nav.html',
  
  'idserver/build/kbase_us/RELEASE_NOTES.txt',
  'command_line_prod/ID_Service_CommandLineHelp.txt',
  'idserver/build/kbase_us/API/IDServerService.html',
  'idserver/build/kbase_us/API/IDServerService_nav.html',

  'inferelator/RELEASE_NOTES.txt',
  'inferelator/API/inferelator.html',
  'inferelator/API/inferelator_nav.html',
  
  'interlog_projection/release-notes',
  'interlog_projection/API/interlog_projection.html',
  'interlog_projection/API/interlog_projection_nav.html',
  
  # Just tutorials
  'microbial/microbial-analysis.html',
  'microbial/images/microbialtutorial_workflow.png',
  'microbial/images/microbialtutorial_login.png',
  'microbial/images/microbialtutorial_browser.png',
  'microbial/images/microbialtutorial_filebrowser.jpg',
  'microbial/images/microbialtutorial_deleteicon.jpg',
  'microbial/images/microbialtutorial_dnloadicon.jpg',
  'microbial/images/microbialtutorial_editicon.jpg',
  'microbial/images/microbialtutorial_addfileicon.jpg',
  'microbial/images/microbialtutorial_createicon.png',
  'microbial/images/microbialtutorial_creatediricon.jpg',
  'microbial/images/microbialtutorial_uploadicon.jpg',
  'microbial/images/microbialtutorial_fbaobject.png',
  'microbial/images/microbialtutorial_fbaviewer.png',
    
  'm5nr/RELEASE_NOTES.txt',
  'command_line_prod/M5NR_Service_CommandLineHelp.txt',
  'm5nr/API/M5NR.html',
  'm5nr/API/M5NR_nav.html',
  
  'meme/RELEASE_NOTES.txt',
  'meme/API/meme.html',
  'meme/API/meme_nav.html',
  
  'matR/RELEASE_NOTES.txt',
  'communities/matR/matR-tutorial.html',
  
  'command_line_prod/Networks_Service_CommandLineHelp.txt',
  'networks/release-notes.txt',
  'networks/API/KBaseNetworksService.html',
  'networks/API/KBaseNetworksService_nav.html',
  
  'command_line_prod/Ontology_Service_CommandLineHelp.txt',
  'ontology_service/build/kbase_us/RELEASE-NOTES.txt',
  'ontology_service/build/kbase_us/API/OntologyService.html',
  'ontology_service/build/kbase_us/API/OntologyService_nav.html',
  'ontology_service/tutorials/ontology_tutorial.html',
  
  'command_line_prod/Phispy_Service_CommandLineHelp.txt',
  'phispy/build/kbase_us/RELEASE_NOTES.txt',
  'phispy/build/kbase_us/API/Phispy.html',
  'phispy/build/kbase_us/API/Phispy_nav.html',
  'phispy/tutorials/phispy.html',
  
  'trees/build/kbase_us/RELEASE_NOTES.txt',
  'trees/user_manuals/scripts/trees_overview.html',
  'trees/build/kbase_us/API/KBaseTrees.html',
  
  'plant_expression_service/build/kbase_us/RELEASE-NOTES.txt',
  'plant_expression_service/tutorials/plant_expression_service_tutorial.html',
  'plant_expression_service/build/kbase_us/API/PlantExpressionService.html',
  'plant_expression_service/build/kbase_us/API/PlantExpressionService_nav.html',
  
  'command_line_prod/Probabilistic_Annotation_Service_CommandLineHelp.txt',
  'probabilistic_annotation/RELEASE_NOTES.txt',
  'probabilistic_annotation/API/probabilistic_annotation.html',
  'probabilistic_annotation/API/probabilistic_annotation_nav.html',
  
  'protein_info_service/build/kbase_us/RELEASE-NOTES.txt',
  'protein_info_service/build/kbase_us/API/ProteinInfoService.html',
  
  'sim_service/build/kbase_us/RELEASE_NOTES.txt',
  'sim_service/build/kbase_us/API/SimService.html',
  'sim_service/build/kbase_us/API/SimService_nav.html',
  
  'jnomics/RELEASE',
  'jnomics/variation/tutorials/IdentifyVariants.html',
  'command_line_prod/Genotyping_Variation_Service_CommandLineHelp.txt',
  
  'command_line_prod/Workspace_Service_CommandLineHelp.txt',
  'workspace_deluxe/build/kbase_us/RELEASE_NOTES.txt',
  'workspace_deluxe/build/kbase_us/API/WorkspaceDeluxe.html',
  'workspace_deluxe/build/kbase_us/API/WorkspaceDeluxe_nav.html',
  
    # more tutorials. 
  'plant_expression_service/tutorials/plant_expression_service_tutorial.html',
  'ontology_service/tutorials/ontology_tutorial.html',
  'trees/tutorials/script_basics/tree-community-tutorial.html',
  'communities/matR/tutorial/KBase-matR-tutorial.html',
  'KBaseFBAModeling/tutorials/FBABuildGenomeModel.html',
  'jnomics/variation/tutorials/IdentifyVariants.html', 
  'phispy/tutorials/phispy.html'
  
  
];

function copyFile($source, $dest, $file) {
  echo "Copying $file...";
  $dir = dirname($file);
  if ($dir !== '') {
    # ensure the target dir exits.
    $destDir = $dest . '/' . $dir;
  }
  if (!file_exists($destDir)) {
    if (!mkdir($destDir, 0770, true)) {
      echo "Warning: cannot create directory $destDir, skipping file $file \n";
      return;
    }
  }
  copy($source . '/' . $file, $dest . '/' . $file);
  echo "done.\n";
}

# use this for directories we know we need entirely; e.g. images for tutorials.
function getDirContents($root, $dir) {
  #echo 'Getting dir contents ... ' . $dir . "\n";
  #return [];
  $dh = opendir($root . '/' . $dir);
  $files = [];
  while ( ($fname = readdir($dh)) !== false) {
    switch (filetype($root . '/' . $dir . '/' . $fname)) {
      case 'file': 
      # echo 'found file ' . $fname . "\n";
      array_push($files, $dir . '/' . $fname); break;
      case 'dir': 
      # $files = array_merge($files, getDirContents($dir . '/' . $fname));
    }
  }
  return $files;
}

  
  
foreach ($files as $file) {
  $sourcePath = $source . '/' . $file;
  $destPath = $target . '/' . $file;
  
  # make sure the source exists.
  if (!file_exists($sourcePath)) {
    echo 'File ' . $sourcePath . ' not found -- skipping' . "\n";
    continue;
  }
  
  switch (filetype($sourcePath)) {
    case 'file': copyFile($source, $target, $file); break;
    case 'dir': 
      # NB the sourceFile will have the parent directory(s) prefixed.
      foreach (getDirContents($source, $file) as $sourceFile) {
        copyFile($source, $target, $sourceFile);
      }; break;
  }
  
}
