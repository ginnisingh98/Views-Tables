--------------------------------------------------------
--  DDL for Package IGF_AP_LI_PROF_IMP_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_LI_PROF_IMP_PROC" AUTHID CURRENT_USER AS
/* $Header: IGFAP35S.pls 115.1 2003/06/12 16:39:20 rasahoo noship $ */
          PROCEDURE main ( errbuf         IN OUT  NOCOPY VARCHAR2,
                           retcode        IN OUT  NOCOPY NUMBER,
                           p_award_year   IN VARCHAR2,
                           p_batch_id     IN NUMBER,
                           p_del_int      IN VARCHAR2,
                           p_css_import   IN VARCHAR2 DEFAULT NULL);


          TYPE message_rec IS RECORD
                  (field_name    VARCHAR2(30),
                   msg_text      VARCHAR2(2000));
          TYPE lookup_meaning_tab IS TABLE OF message_rec
                              INDEX BY BINARY_INTEGER;
          lookup_meaning_table lookup_meaning_tab;

          TYPE igf_ap_lkup_hash_table IS TABLE OF NUMBER
                              INDEX BY BINARY_INTEGER;
          lookup_hash_table   igf_ap_lkup_hash_table;


          TYPE igf_ap_message_table IS TABLE OF message_rec
                              INDEX BY BINARY_INTEGER;
          PROCEDURE  css_import( errbuf         IN OUT  NOCOPY VARCHAR2,
                                 retcode        IN OUT  NOCOPY NUMBER,
                                 p_award_year   IN VARCHAR2);


 END igf_ap_li_prof_imp_proc;

 

/
