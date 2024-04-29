--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_015
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_015" AUTHID CURRENT_USER AS
/* $Header: IGSAD93S.pls 115.5 2003/12/09 14:04:09 pbondugu ship $ */
  PROCEDURE sel_ad_src_cat_imp (p_source_type_id IN NUMBER,
                             p_batch_id IN NUMBER,
                             p_enable_log IN VARCHAR2,
                             p_legacy_ind IN VARCHAR2);

  PROCEDURE prc_ad_category (p_source_type_id IN NUMBER,
                             p_batch_id IN NUMBER,
                             p_interface_run_id  IN NUMBER,
                             p_enable_log IN VARCHAR2,
                             p_legacy_ind IN VARCHAR2);

  PROCEDURE store_ad_stats (p_source_type_id IN NUMBER,
                            p_batch_id IN NUMBER,
                            p_interface_run_id  IN NUMBER);

  PROCEDURE del_cmpld_ad_records (p_source_type_id IN NUMBER,
                                  p_batch_id IN NUMBER,
                                  p_interface_run_id  IN NUMBER);
END igs_ad_imp_015;

 

/
