--------------------------------------------------------
--  DDL for Package IGS_UC_REF_DATA_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_REF_DATA_INSERT" AUTHID CURRENT_USER AS
/* $Header: IGSUC61S.pls 115.5 2003/07/10 07:48:21 rgangara noship $  */

  PROCEDURE setup_common_data;

  PROCEDURE proc_cvrefdis_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvreferror_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefethnic_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefexam_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvreffee_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefoeq_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefoffersubj_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefrescat_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefstatus_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefucasgroup_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefestgroup_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefschooltype_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefawardbody_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefapr_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefkeyword_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefpocc_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvrefofferabbrev_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_uvofferabbrev_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvRefsubj_view (
     p_v_report                 IN    VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE update_ucas_sync (
     p_v_report                   IN      VARCHAR2
    );
  PROCEDURE proc_cvRefTariff_view (
     p_v_report                IN      VARCHAR2
    ,p_n_rec_cnt_for_commit    IN      NUMBER
    );
  PROCEDURE proc_cvJointAdmissions_view (
     p_v_report                IN      VARCHAR2
    ,p_n_rec_cnt_for_commit    IN      NUMBER
    );
  PROCEDURE proc_cvRefSocioEconomic_view (
     p_v_report                 IN   VARCHAR2
    ,p_n_rec_cnt_for_commit     IN   NUMBER
    );
  PROCEDURE proc_cvRefSocialClass_view (
     p_v_report                 IN   VARCHAR2
    ,p_n_rec_cnt_for_commit     IN   NUMBER
    );
  PROCEDURE proc_cvRefPre2000POCC_view (
     p_v_report                IN      VARCHAR2
    ,p_n_rec_cnt_for_commit    IN      NUMBER
    );

END IGS_UC_REF_DATA_INSERT;

 

/
