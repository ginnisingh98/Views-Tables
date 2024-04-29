--------------------------------------------------------
--  DDL for Package IGF_AP_LG_TD_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_LG_TD_IMP" AUTHID CURRENT_USER AS
/* $Header: IGFAP39S.pls 115.2 2003/06/16 07:24:45 nsidana noship $ */

PROCEDURE main( errbuf    OUT NOCOPY VARCHAR2,
                retcode         OUT NOCOPY NUMBER,
                p_award_year    IN         VARCHAR2,
                p_batch_id      IN         NUMBER,
                p_del_ind       IN         VARCHAR2
         );
PROCEDURE print_log_process(
                              p_alternate_code     IN VARCHAR2,
                              p_batch_id           IN  NUMBER,
                              p_del_ind            IN VARCHAR2
                             ) ;
PROCEDURE update_fabase_process(
                                p_person_number IN VARCHAR2
                               );
PROCEDURE update_fabase_rec(
                             p_fa_process_status     IN VARCHAR2
                           );
PROCEDURE add_log_table(
                        p_person_number     IN VARCHAR2,
                        p_error             IN VARCHAR2,
                        p_message_str       IN VARCHAR2
                       );


END igf_ap_lg_td_imp;

 

/
