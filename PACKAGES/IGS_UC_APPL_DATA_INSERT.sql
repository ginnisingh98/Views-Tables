--------------------------------------------------------
--  DDL for Package IGS_UC_APPL_DATA_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APPL_DATA_INSERT" AUTHID CURRENT_USER AS
/* $Header: IGSUC64S.pls 115.4 2003/07/10 07:18:28 rgangara noship $  */

  PROCEDURE populate_interface_tables (
     p_n_appno                    IN     NUMBER
   );

  PROCEDURE proc_ivstark_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstara_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstarc_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstarg_view (
     p_v_report               IN   VARCHAR2
    ,p_n_rec_cnt_for_commit   IN   NUMBER
    );

  PROCEDURE proc_ivstart_view (
     p_v_report               IN   VARCHAR2
    ,p_n_rec_cnt_for_commit   IN   NUMBER
    );

  PROCEDURE proc_ivstarn_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivqualification_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstatement_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivoffer_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstarx_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstarh_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstarpqr_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstarz1_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstarz2_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_ivstarw_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE launch_adm_imp;

END igs_uc_appl_data_insert;

 

/
