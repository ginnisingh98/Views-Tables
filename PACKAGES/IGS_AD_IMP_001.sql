--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_001" AUTHID CURRENT_USER AS
/* $Header: IGSAD79S.pls 115.25 2003/12/09 14:26:17 pbondugu ship $ */
  /*************************************************************
   Created By :
   Date Created By :
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
   ssaleem          13-OCT-2003     Bug : 3130316
                                    Included a new variable g_enable_log
                                    for Import Process Enhancements
   asbala          4-NOV-2003       Bug 3130316 (added the parameter P_ENABLE_LOG)
   pkpatel         6-NOV-2003       Added procedures print_stats and logerrormessage
   ***************************************************************/
  --- SWS Import Process Enhancements
  g_interface_run_id  IGS_AD_INTERFACE_CTL.interface_run_id%TYPE;
  g_enable_log          VARCHAR2(1) := 'N';

  PROCEDURE logerrormessage(p_record IN VARCHAR2,
                          p_error IN VARCHAR2,
                          p_entity_name IN VARCHAR2 DEFAULT NULL,
                          p_match_ind IN VARCHAR2 DEFAULT NULL);

  PROCEDURE print_stats(p_interface_run_id IN igs_ad_interface_all.interface_run_id%TYPE);

  PROCEDURE set_message(p_name IN VARCHAR2,
                        p_token_name IN VARCHAR2 DEFAULT NULL,
                        p_token_value IN VARCHAR2 DEFAULT NULL);

  PROCEDURE logHeader(p_proc_name VARCHAR2);

  PROCEDURE logDetail(p_debug_msg VARCHAR2);

  PROCEDURE update_parent_record_status (p_source_type_id IN NUMBER,
                                         p_batch_id IN NUMBER,
                                         p_interface_run_id  IN NUMBER);

  TYPE g_category_entity_type_record IS RECORD (
       category_name fnd_lookup_values.lookup_code%TYPE,
       entity_name   user_tables.table_name%TYPE);

  TYPE g_category_entity_type_table IS TABLE OF g_category_entity_type_record INDEX BY BINARY_INTEGER;

  PROCEDURE store_stats (p_source_type_id IN NUMBER,
                         p_batch_id IN NUMBER,
                         p_interface_run_id  IN NUMBER,
                         p_category_entity_table IN g_category_entity_type_table);

  FUNCTION import_legacy_data (
        p_batch_id         NUMBER,
        p_source_type_id   NUMBER,
        p_interface_run_id NUMBER) RETURN BOOLEAN;

  PROCEDURE imp_adm_data(
         ERRBUF OUT NOCOPY VARCHAR2,
         RETCODE OUT NOCOPY NUMBER ,
         P_BATCH_ID  IN NUMBER,
    	 P_SOURCE_TYPE_ID IN NUMBER,
         P_MATCH_SET_ID  IN NUMBER,
         P_LEGACY_IND        IN VARCHAR2 DEFAULT 'N',
    	 P_ENABLE_LOG IN VARCHAR2 DEFAULT 'Y',
         P_ACAD_CAL_TYPE  IN VARCHAR2 DEFAULT NULL,
         P_ACAD_SEQUENCE_NUMBER  IN NUMBER DEFAULT NULL,
         P_ADM_CAL_TYPE  IN VARCHAR2 DEFAULT NULL,
         P_ADM_SEQUENCE_NUMBER  IN NUMBER DEFAULT NULL,
         P_ADMISSION_CAT  IN VARCHAR2 DEFAULT NULL,
         P_S_ADMISSION_PROCESS_TYPE  IN VARCHAR2 DEFAULT NULL,
         P_INTERFACE_RUN_ID  IN NUMBER DEFAULT NULL,
         P_ORG_ID	     IN NUMBER DEFAULT NULL
         );

  FUNCTION find_source_cat_rule(p_source_type_id in number,
                                p_category in varchar2)
  RETURN VARCHAR2 ;

END igs_ad_imp_001;

 

/
