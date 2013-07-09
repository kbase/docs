#!/usr/bin/python

from BeautifulSoup import BeautifulSoup
import requests
import sys
import urllib2
from HTMLParser import HTMLParser


DOCS_ROOT = 'http://www.kbase.us/services/docs/'

DEPLOY_DICT = [
               {'name': 'CDM API',
                'service': 'cdmi_api', 
                'target_dir':'kb_seed',
                'html_name': 'application_api'},

               {'name': 'CDM Entity-Relationship API',
                'service': 'cdmi_api',
                'target_dir':'kb_seed',
                'html_name': 'er_api',
                'html_target': 'cdmi_entity_api'},

               {'name': 'ID Server API',
                'service': 'idserver', 
                'target_dir':'idserver',
                'html_name': 'idserver_client_api',
                'html_target':'idserver_api'},

                {'name': 'Workspace Service',
                'service': 'workspaceService', 
                'target_dir':'workspace_service'},

                #{'name': 'Assembly Service',
                #'service': 'assembly', 
                #'target_dir':'assembly',
                #'html_name': ''},

               {'name': 'Plant Expression Service',
                'service': 'PlantExpressionService', 
                'target_dir':'plant_expression_service',
                'html_name': 'PlantExpressionService'},

               {'name': 'Tree Service',
                'service': 'trees',
                'target_dir':'trees', 
                'html_name': 'Tree',
                'html_target':'tree'},   

                #{'name': 'Similarity Service',
                #'service': 'sim_service', 
                #'target_dir':'sim_service',
                #'html_name': 'sim_service'},

               {'name': 'Communties API',
                'service': 'communities_api', 
                'target_dir':'communities',
                'html_name': 'CommunitiesAPI'},

               {'name': 'QC Service', 
                'service': 'communities_qc', 
                'target_dir':'communities_qc',
                'html_name': 'communitiesQC'},

                #{'name': 'Authorization Client',
                #'service': 'authorization_server', 
                #'target_dir':'auth', 
                #'html_name': 'AuthUser',
                #'html_target':},

               {'name': 'Genome Annotation Service',
                'service': 'genome_annotation', 
                'target_dir':'genome_annotation',
                'html_name': 'genomeanno_impl'},

               {'name': 'Translation Service', 
                'service': 'translation', 
                'target_dir':'translation',
                'html_name': 'MOTranslationService',
                'html_target':'MOTranslationService'},

               {'name': 'Networks Service', 
                'service': 'KBaseNetworksService', 
                'target_dir':'networks',
                'html_name': 'KBaseNetworksService'},

               {'name': 'Ontology Service',
                'service': 'ontology_service',
                'html_name': 'OntologyService',
                'target_dir':'ontology_service',
                'html_target': 'OntologyService' },

               {'name': 'Protein Info Service',
                'service': 'protein_info_service', 
                'target_dir':'protein_info_service', 
                'html_name': 'ProteinInfoService'},

               {'name': 'Experiment Service',
                'service': 'experiment', 
                'target_dir':'experiment', 
                'html_name': 'experiment'},

                #{'name': 'FBA Modeling Service',
                #'service': 'fbaModelServices', 
                #'target_dir':'KBaseFBAModeling', 
                #'html_name': 'fbaModelServices'},

               {'name': 'Genotype Phenotype Service',
                'service': 'Genotype_PhenotypeAPI', 
                'target_dir':'genotype_phenotype', 
                'html_name': 'Genotype_PhenotypeAPI'},                             

               {'name': 'PROM Service',
                'service': 'prom_service', 
                'target_dir':'prom_service', 
                'html_name': 'PROM'},

               {'name': 'Phispy Service',
                'service': 'Phispy', 
                'target_dir':'phispy', 
                'html_name': 'Phispy'},

               {'name': 'Regulation Service',
                'service': 'Regulation', 
                'target_dir':'regulation', 
                'html_name': 'Regulation'},

               {'name': 'Fizzy Feature Selection Service',
                'service': 'feature_selection', 
                'target_dir':'feature_selection',
                'html_name': 'Fizzy'},
               ]




def pull_api_doc(service, target, name, html_name=None, html_target=None):
    if html_name:
        url = DOCS_ROOT+service+'/'+html_name+'.html'
    else:
        url = DOCS_ROOT+service+'/'+service+'.html'

    print "\nPulling API Doc file:", service, ' [', url, ']'    
    try:
        r = urllib2.urlopen(url)
    except (404):
        return

    doc_text = r.read()

    content = BeautifulSoup(doc_text)
    #content.find(id='NAME').replace_with(name)
    try:
        nav = content.find('ul', id="index").extract()
    except:
        nav = None

    target_dir = target+'/'+'API/'

    if html_target:
        content_target = target_dir+html_target+'.html'        
    else:
        content_target = target_dir+service+'.html'

    f = open(content_target, 'w')
    f.write(str(content.prettify()))
    print 'Wrote content to:', content_target    

    if nav:
        if html_target:
            nav_target = target_dir+html_target+'_nav.html'        
        else:
            nav_target = target_dir+service+'_nav.html'

        f = open(nav_target, 'w')
        f.write(str(nav.prettify()))
        print 'Wrote nav to:', nav_target
        print



def pull_api_docs():
    for obj in DEPLOY_DICT:
        service = obj['service']
        target = obj['target_dir']
        name = obj['name']

        try:
            html_name = obj['html_name']
        except:
            html_name = None

        try:
            html_target = obj['html_target']
        except:
            html_target = None

        if html_name and html_target:
            pull_api_doc(service, target, name, html_name, html_target)
        elif html_name:
            pull_api_doc(service, target, name, html_name)            
        else:
            pull_api_doc(service, target, name)


def pull_readmes():
    pass



if __name__ == "__main__":
    pull_api_docs();








