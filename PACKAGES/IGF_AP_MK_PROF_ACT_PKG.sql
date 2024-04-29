--------------------------------------------------------
--  DDL for Package IGF_AP_MK_PROF_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_MK_PROF_ACT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP42S.pls 115.1 2003/06/16 08:13:01 bkkumar noship $ */

PROCEDURE lg_make_active_profile ( errbuf    OUT NOCOPY VARCHAR2,
                                retcode         OUT NOCOPY NUMBER,
                                p_award_year    IN         VARCHAR2,
                                p_batch_id      IN         NUMBER,
                                p_del_ind       IN         VARCHAR2 );




FUNCTION check_dup_person(p_person_number  IN VARCHAR2)
RETURN BOOLEAN;

PROCEDURE add_log_table_process(
                                p_person_number     IN VARCHAR2,
                                p_error             IN VARCHAR2,
                                p_message_str       IN VARCHAR2
                               );
 PROCEDURE print_log_process(
                              p_alternate_code     IN VARCHAR2,
                              p_batch_id           IN  NUMBER,
                              p_del_ind            IN VARCHAR2
                             );

END igf_ap_mk_prof_act_pkg;

 

/
