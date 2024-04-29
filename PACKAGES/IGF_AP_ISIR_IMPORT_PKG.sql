--------------------------------------------------------
--  DDL for Package IGF_AP_ISIR_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ISIR_IMPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP01S.pls 120.0 2005/06/01 13:51:34 appldev noship $ */


PROCEDURE main_import_process (
                errbuf             OUT NOCOPY VARCHAR2,
                retcode            OUT NOCOPY NUMBER,
                p_org_id           IN         NUMBER,
                p_award_year       IN         VARCHAR2,
                p_force_add        IN         VARCHAR2,
                p_create_inquiry   IN         VARCHAR2,
                p_adm_source_type  IN         VARCHAR2,
                p_match_code       IN         VARCHAR2,
                p_rec_type         IN         VARCHAR2,
                p_rec_status       IN         VARCHAR2,
                p_message_class    IN         VARCHAR2,
                p_school_type      IN         VARCHAR2,
                p_school_code      IN         VARCHAR2,
                p_del_int          IN         VARCHAR2,
                p_spawn_process    IN         VARCHAR2,
                p_upd_ant_val      IN         VARCHAR2  DEFAULT 'Y'
		);

 PROCEDURE validate_corrections (p_base_id  igf_ap_fa_base_rec_all.base_id%TYPE,
                                 p_isir_id  igf_ap_isir_matched.isir_id%TYPE);


 PROCEDURE update_matched_isir (p_isir_id igf_ap_isir_matched_all.isir_id%TYPE,
                                p_system_record_type igf_ap_isir_matched_all.system_record_type%TYPE,
                                p_payment_isir igf_ap_isir_matched_all.payment_isir%TYPE,
                                p_active_isir igf_ap_isir_matched_all.active_isir%TYPE DEFAULT NULL);

 PROCEDURE update_fabase (p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_isir_corr_status igf_ap_fa_base_rec_all.isir_corr_status%TYPE,
                          p_isir_corr_status_date igf_ap_fa_base_rec_all.isir_corr_status_date%TYPE);

 PROCEDURE update_isir_corr (p_isirc_id igf_ap_isir_corr_all.isirc_id%TYPE,
             					  p_correction_status igf_ap_isir_corr_all.correction_status%TYPE  DEFAULT NULL );

 PROCEDURE prepare_message;

 PROCEDURE create_message(document_id IN VARCHAR2,display_type IN VARCHAR2,document IN OUT NOCOPY VARCHAR2,
                          document_type IN OUT NOCOPY VARCHAR2);

 PROCEDURE outside_corrections(itemtype IN VARCHAR2,itemkey IN VARCHAR2,actid IN NUMBER,funcmode IN VARCHAR2,resultout OUT NOCOPY VARCHAR2);

 PROCEDURE send_message;


END IGF_AP_ISIR_IMPORT_PKG;

 

/
