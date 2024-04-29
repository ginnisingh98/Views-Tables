--------------------------------------------------------
--  DDL for Package IGF_AP_LI_BASE_REC_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_LI_BASE_REC_IMPORT" AUTHID CURRENT_USER AS
/* $Header: IGFAP43S.pls 120.0 2005/06/01 15:05:44 appldev noship $ */
PROCEDURE main ( errbuf         OUT NOCOPY VARCHAR2,
                                retcode         OUT NOCOPY NUMBER,
                                p_award_year    IN         VARCHAR2,
                                p_batch_id      IN         NUMBER,
                                p_del_ind       IN         VARCHAR2
                               );

 PROCEDURE print_log_process(
                              p_alternate_code     IN VARCHAR2,
                              p_batch_id           IN  NUMBER,
                              p_del_ind            IN VARCHAR2,
                              p_awd_yr_status      IN VARCHAR2
                             ) ;
   PROCEDURE add_log_table_process(
                                  p_person_number     IN VARCHAR2,
                                  p_error             IN VARCHAR2,
                                  p_message_str       IN VARCHAR2
                                 );

END igf_ap_li_base_rec_import;

 

/
