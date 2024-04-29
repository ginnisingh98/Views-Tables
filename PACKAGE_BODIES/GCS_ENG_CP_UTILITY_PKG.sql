--------------------------------------------------------
--  DDL for Package Body GCS_ENG_CP_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_ENG_CP_UTILITY_PKG" as
/* $Header: gcs_cpeng_utb.pls 120.5 2006/11/07 23:32:43 sangarg noship $ */

   g_api	VARCHAR2(80)	:=	'gcs.plsql.CP_ENG_CP_UTILITY_PKG';

   PROCEDURE generate_xml_and_ntfs(
				x_errbuf			OUT NOCOPY VARCHAR2,
				x_retcode			OUT NOCOPY VARCHAR2,
				p_execution_type	IN VARCHAR2,
				p_run_name			IN VARCHAR2,
				p_cons_entity_id	IN NUMBER,
				p_category_code		IN VARCHAR2,
				p_child_entity_id	IN NUMBER,
				p_run_detail_id		IN NUMBER,
				p_entry_id			IN NUMBER,
				p_load_id			IN NUMBER)
   IS

     l_ret_status_code BOOLEAN;
     l_request_id	   NUMBER(15);

     --Bugfix 5288100: Do not launch the xml generator if Aggregation is NOT_APPLICABLE
     l_request_error_code  VARCHAR2(400);

   BEGIN

     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_XML_AND_NTFS.begin', '<<Enter>>');
     END IF;

     fnd_file.put_line(fnd_file.log, '<<Parameter Listings>>');
     fnd_file.put_line(fnd_file.log, 'Execution Type	:	' || p_execution_type);
     fnd_file.put_line(fnd_file.log, 'Run Name			:	' || p_run_name);
     fnd_file.put_line(fnd_file.log, 'Consolidation Entity	:	' || p_cons_entity_id);
     fnd_file.put_line(fnd_file.log, 'Category Code		:	' || p_category_code);
     fnd_file.put_line(fnd_file.log, 'Child Entity 		:	' || p_child_entity_id);
     fnd_file.put_line(fnd_file.log, 'Run Detail 		:	' || p_run_detail_id);
     fnd_file.put_line(fnd_file.log, 'Entry Identifier	:	' || p_entry_id);
     fnd_file.put_line(fnd_file.log, 'Load Identifier	:	' || p_load_id);
     fnd_file.put_line(fnd_file.log, '<<End of Parameter Listing>>');

     IF (p_execution_type 	=	'CONS_PROCESS') THEN
       fnd_file.put_line(fnd_file.log, '<<Obsoleted XML Generation Message>>');
       --Bugfix 4874306: Eliminate calls to XML Generation in order to leverage data templates
       --gcs_xml_gen_pkg.submit_entry_xml_gen(
       --				  	x_errbuf		=>	x_errbuf,
       --				  	x_retcode		=>	x_retcode,
       --				  	p_run_name		=>	p_run_name,
       --				  	p_cons_entity_id	=>	p_cons_entity_id,
       --				  	p_category_code		=>	p_category_code,
       --				  	p_child_entity_id	=>	p_child_entity_id,
       --				  	p_run_detail_id		=>	p_run_detail_id);
     ELSIF (p_execution_type 	=	'IMPACT_ENGINE') THEN
       fnd_file.put_line(fnd_file.log, '<<Setting Impact Analysis Messages>>');
       IF (p_load_id <> 0) THEN
       --In this case the control is coming from Data Submission,
       --we need to send the notification without attachment. Making call to the notification workflow
       gcs_wf_ntf_pkg.raise_impact_notification(
					p_run_name		=>	p_run_name,
					p_cons_entity_id	=>	p_cons_entity_id,
					p_entry_id		=>	NVL(p_entry_id,0),
					p_load_id		=>	NVL(p_load_id,0));
       ELSE
       --Start of Bugfix 5524909
       --In this case the control comes from Manual Adj.
       --So we need to send notification with attachment. Making a call to GCS_PDF_GEN concurrent program
       --to generate PDF and sent the notification there after
       l_request_id :=     fnd_request.submit_request(
                                       application     => 'GCS',
                                       program         => 'FCH_PDF_GEN',
                                       sub_request     => FALSE,
                                       argument1       => p_entry_id,
                                       argument2       => p_run_name,
                                       argument3       => p_cons_entity_id );
        fnd_file.put_line(fnd_file.log, 'Submitted PDF Generation Request: '|| l_request_id);
       END IF;
       --End of Bugfix 5524909
       fnd_file.put_line(fnd_file.log, '<<End of Impact Analysis Messages>>');
     ELSIF (p_execution_type	=	'NTF_ONLY' AND p_category_code 	=	'AGGREGATION') THEN
       fnd_file.put_line(fnd_file.log, '<<Sending Notification>>');
       gcs_wf_ntf_pkg.raise_status_notification(
					p_cons_detail_id	=>	p_run_detail_id);
       fnd_file.put_line(fnd_file.log, '<<Ending Notification>>');
       fnd_file.put_line(fnd_file.log, '<<Generating Consolidation Trial Balance XML>>');

       --Bugfix 5288100: If request error code is NOT_APPLICABLE then do not launched XML Writer Program
       SELECT request_error_code
       INTO   l_request_error_code
       FROM   gcs_cons_eng_run_dtls
       WHERE  run_detail_id  =  p_run_detail_id;

       IF (l_request_error_code <> 'NOT_APPLICABLE') THEN
         l_request_id :=     fnd_request.submit_request(
                                        application     => 'GCS',
                                        program         => 'FCH_XML_WRITER',
                                        sub_request     => FALSE,
                                        argument1       => 'CONSOLIDATION',
                                        argument2       => p_run_name,
                                        argument3       => p_cons_entity_id,
                                        argument4       => NULL );
         commit;
       END IF;
       fnd_file.put_line(fnd_file.log, 'Submitted XML Generation Request: '||l_request_id);
       fnd_file.put_line(fnd_file.log, '<<Ending Generation of Consolidation Trial Balance XML>>');
     ELSIF (p_execution_type  =		'NTF_ONLY') THEN
       fnd_file.put_line(fnd_file.log, '<<Sending Notification>>');
       gcs_wf_ntf_pkg.raise_status_notification(
                                        p_cons_detail_id        =>      p_run_detail_id);
       fnd_file.put_line(fnd_file.log, '<<Ending Notification>>');
     END IF;


     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.GENERATE_XML_AND_NTFS.end', '<<Exit>>');
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
       fnd_file.put_line(fnd_file.log, 'Fatal Error Occurred : ' || SQLERRM);
       l_ret_status_code         :=      fnd_concurrent.set_completion_status(
                                                status  =>      'ERROR',
                                                message =>      NULL);
   END generate_xml_and_ntfs;

   PROCEDURE submit_xml_ntf_program(
				    p_execution_type	  IN VARCHAR2,
				    p_run_name			  IN VARCHAR2,
		                    p_cons_entity_id      IN NUMBER,
                		    p_category_code       IN VARCHAR2,
		                    p_child_entity_id     IN NUMBER DEFAULT NULL,
                		    p_run_detail_id       IN NUMBER DEFAULT NULL,
				    p_entry_id			  IN NUMBER	DEFAULT NULL,
				    p_load_id			  IN NUMBER	DEFAULT NULL)
   IS

     l_request_id NUMBER(15);

   BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_XML_NTF_PROGRAM.begin', '<<Enter>>');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Execution Type	:	' || p_execution_type);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Run Name             :       ' || p_run_name);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Consoliation Entity  :       ' || p_cons_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Category             :       ' || p_category_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Child Entity         :       ' || p_child_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Run Detail ID        :       ' || p_run_detail_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Entry ID		:	' || p_entry_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || '.SUBMIT_XML_NTF_PROGRAM', 'Load ID		:	' || p_load_id);
    END IF;

    l_request_id :=     fnd_request.submit_request(
                                        application     => 'GCS',
                                        program         => 'FCH_XML_NTF_UTILITY',
                                        sub_request     => FALSE,
                                        argument1       => p_execution_type,
                                        argument2       => p_run_name,
                                        argument3       => p_cons_entity_id,
                                        argument4       => p_category_code,
                                        argument5       => p_child_entity_id,
					argument6		=> p_run_detail_id,
					argument7		=> p_entry_id,
					argument8		=> p_load_id);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL         <=      FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || '.SUBMIT_XML_NTF_PROGRAM.end', '<<Exit>>');
    END IF;
  END submit_xml_ntf_program;

END GCS_ENG_CP_UTILITY_PKG;

/
