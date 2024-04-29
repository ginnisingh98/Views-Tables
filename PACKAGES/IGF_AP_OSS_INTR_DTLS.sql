--------------------------------------------------------
--  DDL for Package IGF_AP_OSS_INTR_DTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_OSS_INTR_DTLS" AUTHID CURRENT_USER AS
/* $Header: IGFAP20S.pls 115.12 2003/09/04 05:52:12 rasahoo ship $ */

-- rasahoo     01-Sep-2003  modified data types , replaced igf_ap_fa_base_h_all
--                          as part of  FA-114(Obsoletion of FA base record History)
-- npalanis    23-OCT-2002  Bug : 2608360
--                          residency_status_id references are changed to  residency_status_cd
--                          IGS_AD_ATHLETICS_V references changed to igs_pe_athletic_prg_v
--
--
-- this is the declaration of ref cursor which will be returned from the
-- get_details procedure
-- this ref cursor 'oss_dtl_rec' contains oss data from
--
-- 1.  IGS_AD_APPL
-- 2.  IGS_AD_APPL_STAT
-- 3.  IGS_PE_TYP_INSTANCES_V
-- 4.  IGS_AP_PRCS_CAT
-- 5.  IGS_AD_PS_APPL_INST
-- 6.  IGS_AD_OU_STAT
-- 7.  IGS_AD_OFR_RESP_STAT
-- 8.  IGS_AD_ATHLETICS_V
-- 9.  IGS_AD_FEE_STAT
-- 10. IGS_PS_VER
-- 11. IGS_EN_STDNT_PS_ATT
-- 12. IGS_CA_INST / IGS_CA_TYPE
--

-- Note : give all the cols %TYPE or DataType --

TYPE oss_dtl_rec IS  RECORD (
adm_appl_status                   igs_ad_appl_all.adm_appl_status%TYPE,
s_adm_appl_status                 igs_ad_appl_stat.s_adm_appl_status%TYPE,
appl_dt                           igs_ad_appl_all.appl_dt%TYPE,
class_standing                    igs_pr_css_class_std_v.class_standing%TYPE,
-- NULL till DLD Build for DLD Class Standing i1a
cur_enrol_credit_points           NUMBER(15,2),
admission_cat                     igs_ad_appl_all.admission_cat%TYPE,
s_admission_process_type          igs_ad_prcs_cat_all.s_admission_process_type%TYPE,
prog_attempt                      VARCHAR2(100),
-- igs_ad_ps_appl_inst.course_cd ||<space>||igs_ad_ps_appl_inst.crv_version_number%TYPE,
prog_att_course_cd                igs_ad_ps_appl_inst_all.course_cd%TYPE,
prog_att_ver_num                  igs_ad_ps_appl_inst_all.crv_version_number%TYPE,
prog_att_attend_mode              igs_ad_ps_appl_inst_all.attendance_mode%TYPE,
prog_att_attend_type              igs_ad_ps_appl_inst_all.attendance_type%TYPE,
adm_outcome_status                igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE,
s_adm_outcome_status              igs_ad_ou_stat.s_adm_outcome_status%TYPE,
decision_date                     igs_ad_ps_appl_inst_all.decision_date%TYPE,
adm_offer_resp_status             igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE,
s_adm_offer_resp_status           igs_ad_ofr_resp_stat.s_adm_offer_resp_status%TYPE,
actual_response_date              igs_ad_ps_appl_inst_all.actual_response_dt%TYPE,
adm_fee_status                    igs_ad_appl_all.adm_fee_status%TYPE,
s_adm_fee_status                  igs_ad_fee_stat.s_adm_fee_status%TYPE,
sp_program_1                      igs_ad_appl. spcl_grp_1%TYPE,
--  sp_program_1 will be NULL till Admission DLD Build
sp_program_2                      igs_ad_appl. spcl_grp_2%TYPE,
-- sp_program_2 will be NULL till Admission DLD Build
entry_level                       igs_ad_ps_appl_inst. entry_level%TYPE,
-- entry_level will be NULL till Admission DLD Build
anticip_compl_date                DATE,
academic_index                    igs_ad_ps_appl_inst_all.academic_index%TYPE,
adm_org_unit_cd                   igs_ps_ver_all.responsible_org_unit_cd%TYPE,
final_unit_set                    VARCHAR2(100),
-- igs_ad_ps_appl_inst.unit_set_cd||<space>||igs_ad_ps_appl_inst.us_version_number%TYPE,
final_unit_set_course_cd          igs_ad_ps_appl_inst_all.unit_set_cd%TYPE,
final_unit_set_ver_num            igs_ad_ps_appl_inst_all.us_version_number%TYPE,
prog_att_start_dt                 igs_en_stdnt_ps_att_all.commencement_dt%TYPE,
transfered                        VARCHAR2(30),
-- transfered will be NULL as No Mapping exists for this
multiple_ad_appl                  VARCHAR2(10),
atb                               VARCHAR2(30),
enrolled_term                     igs_ca_inst_all.alternate_code%TYPE,
enrl_load_cal_type                igs_ca_inst_all.cal_type%TYPE,
enrl_load_seq_num                 igs_ca_inst_all. sequence_number%TYPE,
sap_evaluation_date               DATE,          -- NULL
sap_selected_flag                 VARCHAR2(30),  -- NULL
multiple_prog_d                   VARCHAR2(10),
enrl_primary_program              VARCHAR2(100),
--igs_en_stdnt_ps_att.course_cd||<space>||igs_en_stdnt_ps_att.version_number%TYPE,
enrl_primary_prog_course_cd       igs_en_stdnt_ps_att_all.course_cd%TYPE,
enrl_primary_prog_ver_num         igs_en_stdnt_ps_att_all.version_number%TYPE,
enrl_program_type                 igs_ps_ver_all.course_type%TYPE,
enrl_unit_set                     VARCHAR2(10),                                         -- NULL Not Mapped
enrl_uset_course_cd               igs_as_su_setatmpt.course_cd%TYPE,        -- NULL Not Mapped
enrl_uset_ver_num                 igs_as_su_setatmpt.us_version_number%TYPE,          -- NULL Not Mapped
enrl_course_attempt_status        igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
derived_attend_type               igs_en_stdnt_ps_att_all.derived_att_type%TYPE,
current_gpa                       NUMBER,                -- NULL Not Mapped
cumulative_gpa                    NUMBER,             -- NULL Not Mapped
acheived_cr_pts                   NUMBER,            -- NULL Not Mapped
pred_class_standing               VARCHAR2(60),        -- NULL ; till DLD Class Standing i1a build
enrl_org_unit_cd                  igs_ps_ver_all.responsible_org_unit_cd%TYPE,
enrl_attend_mode                  igs_en_stdnt_ps_att_all.attendance_mode%TYPE,
enrl_location_cd                  igs_en_stdnt_ps_att_all.location_cd%TYPE,
enrl_total_cp                     NUMBER(15,2),
enrl_cuml_cp                      NUMBER(15,2),
enrl_cuml_trans_cp                NUMBER(15,2),
admission_appl_number             igs_ad_appl_all. admission_appl_number%TYPE
);

--
-- end of declaration for oss_dtl_rec Record
--

TYPE oss_dtl_cur  IS REF CURSOR RETURN oss_dtl_rec;    -- ref cursor of the record type 'oss_dtl_rec'

--
-- this procedure which will be called from other packages / plds
-- the parameters passed to this procedure are
-- person_id             IN
-- awd_cal_type          IN
-- awd_seq_num           IN
-- ref cursor variable   OUT NOCOPY
-- all the packages and pls which will be calling this package procedure
-- must decalre a record type variable as defined above.
--

--Added the last six parameters as per the FACCR004 in Disbursement Build Jul 2002

PROCEDURE  get_details (p_person_id      IN     igs_ad_appl_all.person_id%TYPE,
                        p_awd_cal_type   IN     igs_ca_inst_all.cal_type%TYPE,
                        p_awd_seq_num    IN     igs_ca_inst_all.sequence_number%TYPE,
                        lv_oss_dtl_rec   IN OUT NOCOPY oss_dtl_cur
                         ) ;

END igf_ap_oss_intr_dtls;

 

/
