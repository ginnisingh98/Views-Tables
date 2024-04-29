--------------------------------------------------------
--  DDL for Package IGS_UC_COMM_DATA_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_COMM_DATA_INSERT" AUTHID CURRENT_USER AS
/* $Header: IGSUC63S.pls 115.5 2003/07/10 07:49:32 rgangara noship $  */

  PROCEDURE proc_cvinstitution_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cveblsubject_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvschool_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvschoolcontact_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_cvcourse_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_uvcourse_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_uvcoursevacancies_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_uvcoursevacoptions_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

  PROCEDURE proc_uvcoursekeyword_view (
     p_v_report                   IN      VARCHAR2
    ,p_n_rec_cnt_for_commit	  IN	  NUMBER
    );

END IGS_UC_COMM_DATA_INSERT;

 

/
