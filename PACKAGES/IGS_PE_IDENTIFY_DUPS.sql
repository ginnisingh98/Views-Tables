--------------------------------------------------------
--  DDL for Package IGS_PE_IDENTIFY_DUPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_IDENTIFY_DUPS" AUTHID CURRENT_USER AS
/* $Header: IGSPE03S.pls 120.0 2005/06/01 18:01:08 appldev noship $ */


 -- Main procedure called from the Identify Duplicates process.
  PROCEDURE find_dup_main(
    ERRBUF OUT NOCOPY VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER,
    x_report_requested IN VARCHAR2);
 -- procedure called from the find_dup_main procedure.
  PROCEDURE find_duplicates (
    x_errbuf IN OUT NOCOPY VARCHAR2,
    x_retcode IN OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER);
 -- Procedure to find the duplicate records using the person related info only.
  PROCEDURE find_duplicates_p(
    x_errbuf IN OUT NOCOPY VARCHAR2,
    x_retcode IN OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER,
    x_batch_id IN NUMBER);
 -- Procedure to find the duplicate records using the person and person id type related info only.
  PROCEDURE find_duplicates_pp(
    x_errbuf IN OUT NOCOPY VARCHAR2,
    x_retcode IN OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER,
    x_batch_id IN NUMBER,
    x_person_id_type IN VARCHAR2);
 -- Procedure to find the duplicate records using the person and address related info only.
  PROCEDURE find_duplicates_pa(
    x_errbuf IN OUT NOCOPY VARCHAR2,
    x_retcode IN OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER,
    x_batch_id IN NUMBER,
    x_addr_type IN VARCHAR2);
 -- Procedure to find the duplicate records using the person, address and person id type related info.
  PROCEDURE find_duplicates_ppa(
    x_errbuf IN OUT NOCOPY VARCHAR2,
    x_retcode IN OUT NOCOPY VARCHAR2,
    x_match_set_id IN NUMBER,
    x_batch_id IN NUMBER,
    x_addr_type IN VARCHAR2,
    x_person_id_type IN VARCHAR2);
 -- Procedure to form the select clause which returns the person duplicate records in the system.
  PROCEDURE form_dup_whereclause(
    x_errbuf IN OUT NOCOPY VARCHAR2 ,
    x_retcode IN OUT NOCOPY VARCHAR2 ,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_match_category IN VARCHAR2 DEFAULT NULL,
    x_view_name IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_surname IN VARCHAR2 DEFAULT NULL,
    x_given_names IN VARCHAR2 DEFAULT NULL,
    x_api_person_id IN VARCHAR2 DEFAULT NULL,
    x_pref_alternate_id IN VARCHAR2 DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    x_birth_dt IN DATE DEFAULT NULL,
    x_sex IN VARCHAR2 DEFAULT NULL,
    x_ethnic_origin IN VARCHAR2 DEFAULT NULL,
    x_addr_type IN VARCHAR2 DEFAULT NULL,
    x_addr_line_1 IN VARCHAR2 DEFAULT NULL,
    x_addr_line_2 IN VARCHAR2 DEFAULT NULL,
    x_addr_line_3 IN VARCHAR2 DEFAULT NULL,
    x_addr_line_4 IN VARCHAR2 DEFAULT NULL,
    x_city IN VARCHAR2 DEFAULT NULL,
    x_state IN VARCHAR2 DEFAULT NULL,
    x_province IN VARCHAR2 DEFAULT NULL,
    x_county IN VARCHAR2 DEFAULT NULL,
    x_country IN VARCHAR2 DEFAULT NULL,
    x_postcode IN VARCHAR2 DEFAULT NULL,
    x_select_clause IN OUT NOCOPY VARCHAR2
    );
  -- Procedure to find duplicate match for Related Person during import
   TYPE r_record_dup_rel IS RECORD(
             INTERFACE_ID              igs_ad_interface.interface_id%TYPE,
             INTERFACE_RELATIONS_ID    igs_ad_relations_int.interface_relations_id%TYPE,
             SURNAME                   igs_ad_relations_int.surname%TYPE,
             FIRST_NAME                igs_Ad_relations_int.given_names%TYPE,
             GENDER                    igs_ad_relations_int.sex%TYPE,
             BIRTH_DATE                igs_ad_relations_int.birth_dt%TYPE,
             BATCH_ID                  igs_ad_interface.batch_id%TYPE,
             MATCH_SET_ID              igs_pe_match_sets.match_set_id%TYPE);

        r_record_dup_rel_rec   r_record_dup_rel;

  TYPE r_matchset_partial IS RECORD(
      data_element igs_pe_mtch_set_data_all.data_element%TYPE,
      drop_if_null igs_pe_mtch_set_data_all.drop_if_null%TYPE);

  TYPE t_matchset IS TABLE OF r_matchset_partial INDEX BY BINARY_INTEGER;

  -- global variables added as part of Bug 3130316, Duplicate Person Matching Performance Improvements
  g_partial_if_null igs_pe_match_sets.partial_if_null%TYPE;
  g_exclude_inactive_ind igs_pe_match_sets.exclude_inactive_ind%TYPE;
  g_match_set_id igs_pe_match_sets.match_set_id%TYPE;
  g_source_type_id NUMBER;                                                       -- nsidana Bug 3633341
  g_addr_type_din igs_pe_mtch_set_data_all.drop_if_null%TYPE;
  g_person_id_type_din igs_pe_mtch_set_data_all.drop_if_null%TYPE;
  g_matchset_exact t_matchset;
  g_matchset_partial t_matchset;

  PROCEDURE Find_dup_rel_per(
   P_REL_DUP_REC  IN r_record_dup_rel,
   P_MATCH_FOUND OUT NOCOPY VARCHAR2
   );

   -- global variable added as part of Bug 3146324, Match Criteria Sets Enhancements
   g_primary_addr_flag VARCHAR2(1);

END Igs_Pe_Identify_Dups;

 

/
