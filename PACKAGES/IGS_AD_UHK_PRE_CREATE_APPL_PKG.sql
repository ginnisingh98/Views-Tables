--------------------------------------------------------
--  DDL for Package IGS_AD_UHK_PRE_CREATE_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_UHK_PRE_CREATE_APPL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADD3S.pls 120.2 2006/05/25 05:53:26 arvsrini noship $ */

  --
  --  User Hook - which can be customisable by the customer.
  --

  PROCEDURE derive_app_type (
    p_person_id in number,
    p_login_resp in varchar2,
    p_acad_cal_type in varchar2,
    p_acad_cal_seq_number in number,
    p_adm_cal_type in varchar2,
    p_adm_ci_sequence_number in number,
    p_application_type in out nocopy varchar2,
    p_location_code in out nocopy varchar2,
    p_program_type in out nocopy varchar2,
    p_sch_apl_to_id in out nocopy number,
    p_attendance_type in out nocopy varchar2,
    p_attendance_mode in out nocopy varchar2,
    p_oo_attribute_1 in out nocopy varchar2,
    p_oo_attribute_2 in out nocopy varchar2,
    p_oo_attribute_3 in out nocopy varchar2,
    p_oo_attribute_4 in out nocopy varchar2,
    p_oo_attribute_5 in out nocopy varchar2,
    p_oo_attribute_6 in out nocopy varchar2,
    p_oo_attribute_7 in out nocopy varchar2,
    p_oo_attribute_8 in out nocopy varchar2,
    p_oo_attribute_9 in out nocopy varchar2,
    p_oo_attribute_10 in out nocopy varchar2,
    p_citizenship_residency_ind in out nocopy varchar2,
    p_cit_res_attribute_1 in out nocopy varchar2,
    p_cit_res_attribute_2 in out nocopy varchar2,
    p_cit_res_attribute_3 in out nocopy varchar2,
    p_cit_res_attribute_4 in out nocopy varchar2,
    p_cit_res_attribute_5 in out nocopy varchar2,
    p_cit_res_attribute_6 in out nocopy varchar2,
    p_cit_res_attribute_7 in out nocopy varchar2,
    p_cit_res_attribute_8 in out nocopy varchar2,
    p_cit_res_attribute_9 in out nocopy varchar2,
    p_cit_res_attribute_10 in out nocopy varchar2,
    p_state_of_res_type_code in out nocopy varchar2,
    p_dom_attribute_1 in out nocopy varchar2,
    p_dom_attribute_2 in out nocopy varchar2,
    p_dom_attribute_3 in out nocopy varchar2,
    p_dom_attribute_4 in out nocopy varchar2,
    p_dom_attribute_5 in out nocopy varchar2,
    p_dom_attribute_6 in out nocopy varchar2,
    p_dom_attribute_7 in out nocopy varchar2,
    p_dom_attribute_8 in out nocopy varchar2,
    p_dom_attribute_9 in out nocopy varchar2,
    p_dom_attribute_10 in out nocopy varchar2,
    p_gen_attribute_1 in out nocopy varchar2,
    p_gen_attribute_2 in out nocopy varchar2,
    p_gen_attribute_3 in out nocopy varchar2,
    p_gen_attribute_4 in out nocopy varchar2,
    p_gen_attribute_5 in out nocopy varchar2,
    p_gen_attribute_6 in out nocopy varchar2,
    p_gen_attribute_7 in out nocopy varchar2,
    p_gen_attribute_8 in out nocopy varchar2,
    p_gen_attribute_9 in out nocopy varchar2,
    p_gen_attribute_10 in out nocopy varchar2,
    p_gen_attribute_11 in out nocopy varchar2,
    p_gen_attribute_12 in out nocopy varchar2,
    p_gen_attribute_13 in out nocopy varchar2,
    p_gen_attribute_14 in out nocopy varchar2,
    p_gen_attribute_15 in out nocopy varchar2,
    p_gen_attribute_16 in out nocopy varchar2,
    p_gen_attribute_17 in out nocopy varchar2,
    p_gen_attribute_18 in out nocopy varchar2,
    p_gen_attribute_19 in out nocopy varchar2,
    p_gen_attribute_20 in out nocopy varchar2,
    p_entry_status in out nocopy varchar2,
    p_entry_level in out nocopy varchar2,
    p_spcl_gr1 in out nocopy varchar2,
    p_spcl_gr2 in out nocopy varchar2,
    p_apply_for_finaid in out nocopy varchar2,
    p_finaid_apply_date in out nocopy date,
    p_appl_date in out nocopy date,
    p_attribute_category in out nocopy varchar2,
    p_attribute1 in out nocopy varchar2,
    p_attribute2 in out nocopy varchar2,
    p_attribute3 in out nocopy varchar2,
    p_attribute4 in out nocopy varchar2,
    p_attribute5 in out nocopy varchar2,
    p_attribute6 in out nocopy varchar2,
    p_attribute7 in out nocopy varchar2,
    p_attribute8 in out nocopy varchar2,
    p_attribute9 in out nocopy varchar2,
    p_attribute10 in out nocopy varchar2,
    p_attribute11 in out nocopy varchar2,
    p_attribute12 in out nocopy varchar2,
    p_attribute13 in out nocopy varchar2,
    p_attribute14 in out nocopy varchar2,
    p_attribute15 in out nocopy varchar2,
    p_attribute16 in out nocopy varchar2,
    p_attribute17 in out nocopy varchar2,
    p_attribute18 in out nocopy varchar2,
    p_attribute19 in out nocopy varchar2,
    p_attribute20 in out nocopy varchar2,
    p_attribute21 in out nocopy varchar2,
    p_attribute22 in out nocopy varchar2,
    p_attribute23 in out nocopy varchar2,
    p_attribute24 in out nocopy varchar2,
    p_attribute25 in out nocopy varchar2,
    p_attribute26 in out nocopy varchar2,
    p_attribute27 in out nocopy varchar2,
    p_attribute28 in out nocopy varchar2,
    p_attribute29 in out nocopy varchar2,
    p_attribute30 in out nocopy varchar2,
    p_attribute31 in out nocopy varchar2,
    p_attribute32 in out nocopy varchar2,
    p_attribute33 in out nocopy varchar2,
    p_attribute34 in out nocopy varchar2,
    p_attribute35 in out nocopy varchar2,
    p_attribute36 in out nocopy varchar2,
    p_attribute37 in out nocopy varchar2,
    p_attribute38 in out nocopy varchar2,
    p_attribute39 in out nocopy varchar2,
    p_attribute40 in out nocopy varchar2
    );

  PROCEDURE derive_app_fee (
    p_person_id in number,
    p_login_resp in varchar2,
    p_acad_cal_type in varchar2,
    p_acad_cal_seq_number in number,
    p_adm_cal_type in varchar2,
    p_adm_ci_sequence_number in number,
    p_application_type in out nocopy varchar2,
    p_application_fee_amount in out nocopy number,
    p_location_code in out nocopy varchar2,
    p_program_type in out nocopy varchar2,
    p_sch_apl_to_id in out nocopy number,
    p_attendance_type in out nocopy varchar2,
    p_attendance_mode in out nocopy varchar2,
    p_oo_attribute_1 in out nocopy varchar2,
    p_oo_attribute_2 in out nocopy varchar2,
    p_oo_attribute_3 in out nocopy varchar2,
    p_oo_attribute_4 in out nocopy varchar2,
    p_oo_attribute_5 in out nocopy varchar2,
    p_oo_attribute_6 in out nocopy varchar2,
    p_oo_attribute_7 in out nocopy varchar2,
    p_oo_attribute_8 in out nocopy varchar2,
    p_oo_attribute_9 in out nocopy varchar2,
    p_oo_attribute_10 in out nocopy varchar2,
    p_citizenship_residency_ind in out nocopy varchar2,
    p_cit_res_attribute_1 in out nocopy varchar2,
    p_cit_res_attribute_2 in out nocopy varchar2,
    p_cit_res_attribute_3 in out nocopy varchar2,
    p_cit_res_attribute_4 in out nocopy varchar2,
    p_cit_res_attribute_5 in out nocopy varchar2,
    p_cit_res_attribute_6 in out nocopy varchar2,
    p_cit_res_attribute_7 in out nocopy varchar2,
    p_cit_res_attribute_8 in out nocopy varchar2,
    p_cit_res_attribute_9 in out nocopy varchar2,
    p_cit_res_attribute_10 in out nocopy varchar2,
    p_state_of_res_type_code in out nocopy varchar2,
    p_dom_attribute_1 in out nocopy varchar2,
    p_dom_attribute_2 in out nocopy varchar2,
    p_dom_attribute_3 in out nocopy varchar2,
    p_dom_attribute_4 in out nocopy varchar2,
    p_dom_attribute_5 in out nocopy varchar2,
    p_dom_attribute_6 in out nocopy varchar2,
    p_dom_attribute_7 in out nocopy varchar2,
    p_dom_attribute_8 in out nocopy varchar2,
    p_dom_attribute_9 in out nocopy varchar2,
    p_dom_attribute_10 in out nocopy varchar2,
    p_gen_attribute_1 in out nocopy varchar2,
    p_gen_attribute_2 in out nocopy varchar2,
    p_gen_attribute_3 in out nocopy varchar2,
    p_gen_attribute_4 in out nocopy varchar2,
    p_gen_attribute_5 in out nocopy varchar2,
    p_gen_attribute_6 in out nocopy varchar2,
    p_gen_attribute_7 in out nocopy varchar2,
    p_gen_attribute_8 in out nocopy varchar2,
    p_gen_attribute_9 in out nocopy varchar2,
    p_gen_attribute_10 in out nocopy varchar2,
    p_gen_attribute_11 in out nocopy varchar2,
    p_gen_attribute_12 in out nocopy varchar2,
    p_gen_attribute_13 in out nocopy varchar2,
    p_gen_attribute_14 in out nocopy varchar2,
    p_gen_attribute_15 in out nocopy varchar2,
    p_gen_attribute_16 in out nocopy varchar2,
    p_gen_attribute_17 in out nocopy varchar2,
    p_gen_attribute_18 in out nocopy varchar2,
    p_gen_attribute_19 in out nocopy varchar2,
    p_gen_attribute_20 in out nocopy varchar2,
    p_entry_status in out nocopy varchar2,
    p_entry_level in out nocopy varchar2,
    p_spcl_gr1 in out nocopy varchar2,
    p_spcl_gr2 in out nocopy varchar2,
    p_apply_for_finaid in out nocopy varchar2,
    p_finaid_apply_date in out nocopy date,
    p_appl_date in out nocopy date,
    p_attribute_category in out nocopy varchar2,
    p_attribute1 in out nocopy varchar2,
    p_attribute2 in out nocopy varchar2,
    p_attribute3 in out nocopy varchar2,
    p_attribute4 in out nocopy varchar2,
    p_attribute5 in out nocopy varchar2,
    p_attribute6 in out nocopy varchar2,
    p_attribute7 in out nocopy varchar2,
    p_attribute8 in out nocopy varchar2,
    p_attribute9 in out nocopy varchar2,
    p_attribute10 in out nocopy varchar2,
    p_attribute11 in out nocopy varchar2,
    p_attribute12 in out nocopy varchar2,
    p_attribute13 in out nocopy varchar2,
    p_attribute14 in out nocopy varchar2,
    p_attribute15 in out nocopy varchar2,
    p_attribute16 in out nocopy varchar2,
    p_attribute17 in out nocopy varchar2,
    p_attribute18 in out nocopy varchar2,
    p_attribute19 in out nocopy varchar2,
    p_attribute20 in out nocopy varchar2,
    p_attribute21 in out nocopy varchar2,
    p_attribute22 in out nocopy varchar2,
    p_attribute23 in out nocopy varchar2,
    p_attribute24 in out nocopy varchar2,
    p_attribute25 in out nocopy varchar2,
    p_attribute26 in out nocopy varchar2,
    p_attribute27 in out nocopy varchar2,
    p_attribute28 in out nocopy varchar2,
    p_attribute29 in out nocopy varchar2,
    p_attribute30 in out nocopy varchar2,
    p_attribute31 in out nocopy varchar2,
    p_attribute32 in out nocopy varchar2,
    p_attribute33 in out nocopy varchar2,
    p_attribute34 in out nocopy varchar2,
    p_attribute35 in out nocopy varchar2,
    p_attribute36 in out nocopy varchar2,
    p_attribute37 in out nocopy varchar2,
    p_attribute38 in out nocopy varchar2,
    p_attribute39 in out nocopy varchar2,
    p_attribute40 in out nocopy varchar2
    );

  PROCEDURE pre_submit_application (
      p_person_id       in   number,
      p_ss_adm_appl_id  in   number,
      p_return_status   in out nocopy   varchar2,
      p_msg_data        out   nocopy varchar2
   );

END igs_ad_uhk_pre_create_appl_pkg;

 

/
