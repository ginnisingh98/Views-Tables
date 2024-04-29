--------------------------------------------------------
--  DDL for Package IGF_AP_BATCH_VER_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_BATCH_VER_PRC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP08S.pls 115.16 2003/12/10 08:52:50 bkkumar ship $ */

PROCEDURE main (    errbuf            OUT NOCOPY VARCHAR2,
                    retcode           OUT NOCOPY NUMBER,
                    p_award_year      IN  VARCHAR2,
                    p_org_id          IN  NUMBER);


PROCEDURE update_process_status ( p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                                  p_fed_verif_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE );


FUNCTION get_gr_ver_code ( pv_fed_verif_status  igf_lookups_view.lookup_code%TYPE,
                           p_cal_type           igf_ap_batch_aw_map_all.ci_cal_type%TYPE,
                           p_sequence_number    igf_ap_batch_aw_map_all.ci_sequence_number%TYPE) RETURN VARCHAR2;


PROCEDURE update_fed_verif_status  ( p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                                     p_fed_verif_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE );

lp_isir_rec igf_ap_isir_matched%rowtype;

END igf_ap_batch_ver_prc_pkg;

 

/
