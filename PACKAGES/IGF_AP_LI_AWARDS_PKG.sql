--------------------------------------------------------
--  DDL for Package IGF_AP_LI_AWARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_LI_AWARDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP37S.pls 115.1 2003/06/09 16:04:30 bkkumar noship $ */
PROCEDURE main_import_process ( errbuf          OUT NOCOPY VARCHAR2,
                                retcode         OUT NOCOPY NUMBER,
                                p_award_year    IN         VARCHAR2,
                                p_batch_id      IN         NUMBER,
                                p_del_ind       IN         VARCHAR2 );

PROCEDURE print_log_process  ( p_person_number IN  VARCHAR2,
                               p_error         IN  VARCHAR2 );

END igf_ap_li_awards_pkg;

 

/
