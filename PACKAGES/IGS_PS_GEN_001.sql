--------------------------------------------------------
--  DDL for Package IGS_PS_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GEN_001" AUTHID CURRENT_USER AS
  /* $Header: IGSPS01S.pls 120.1 2005/10/04 00:43:14 appldev ship $ */

/*
Who       When          What
sarakshi  24-Apr-2003   Enh#2858431,added procedure change_unit_section_status
jdeekoll    06-May-03       Added 4 procedure as part of HR Integration(# 2833853)

*/

  PROCEDURE crsp_ins_crs_ver (
  p_old_course_cd IN VARCHAR2 ,
  p_old_version_number IN NUMBER ,
  p_new_course_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  ;

  PROCEDURE crsp_ins_unit_section(
  p_old_uoo_id IN NUMBER,
  p_new_uoo_id IN NUMBER,
  p_message_name OUT NOCOPY VARCHAR2,
  p_log_creation_date DATE DEFAULT NULL);

  PROCEDURE change_unit_section_status(
  p_c_old_cal_status      IN VARCHAR2,
  p_c_new_cal_status      IN VARCHAR2,
  p_c_cal_type            IN VARCHAR2,
  p_n_ci_sequence_number  IN NUMBER,
  p_b_ret_status          OUT NOCOPY BOOLEAN,
  p_c_message_name        OUT NOCOPY VARCHAR2) ;

  FUNCTION fac_exceed_exp_wl(
                             p_c_cal_type IN VARCHAR2,
                             p_n_cal_seq_num IN NUMBER,
                             p_n_person_id IN NUMBER,
                             p_n_curr_wl IN NUMBER,
                             p_n_tot_fac_wl OUT NOCOPY NUMBER,
                             p_n_exp_wl OUT NOCOPY NUMBER) RETURN BOOLEAN;

  FUNCTION teach_fac_wl(
                         p_c_cal_type IN VARCHAR2,
                         p_n_cal_seq_num IN NUMBER,
                         p_n_person_id IN NUMBER,
                         p_n_curr_wl IN NUMBER,
                         p_n_tot_fac_wl OUT NOCOPY NUMBER,
                         p_n_exp_wl OUT NOCOPY NUMBER) RETURN BOOLEAN;

END IGS_PS_GEN_001;

 

/
