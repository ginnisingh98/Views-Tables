--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_SYS_DT_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_SYS_DT_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCA16S.pls 120.1 2005/08/11 05:39:06 appldev noship $ */
/*****************************************************
||  Created By :  Navin Sidana
||  Created On :  11/4/2004
||  Purpose : Package for validating System date types
||  for each module.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| nsidana          10/13/2004       Created
*****************************************************/
  FUNCTION chk_one_per_cal(p_dt_alias IN VARCHAR2,p_cal_type IN VARCHAR2,p_seq_num IN NUMBER) RETURN VARCHAR2;

  PROCEDURE execute_validation_proc(proc_name IN VARCHAR2,p_sys_date IN VARCHAR2,p_dt_alias IN VARCHAR2,p_cal_type IN VARCHAR2,p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_ad_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_en_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_rec_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_fi_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_ps_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_sws_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_rct_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_fa_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_ucas_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);
  PROCEDURE val_hesa_sda(p_sys_date_type IN VARCHAR2,p_dt_alias IN VARCHAR2, p_cal_type IN VARCHAR2, p_seq_num IN NUMBER,p_err_msg_list OUT NOCOPY VARCHAR2);

END igs_ca_val_sys_dt_type_pkg;

 

/
