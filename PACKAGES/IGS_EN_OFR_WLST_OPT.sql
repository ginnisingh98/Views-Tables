--------------------------------------------------------
--  DDL for Package IGS_EN_OFR_WLST_OPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_OFR_WLST_OPT" AUTHID CURRENT_USER AS
/* $Header: IGSEN75S.pls 120.1 2005/07/12 02:25:10 appldev ship $ */


  FUNCTION  ofr_enrollment_or_waitlist (  p_uoo_id                IN   igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                          p_session_id            IN   igs_en_su_attempt.session_id%TYPE,
                                          p_waitlist_ind          IN   VARCHAR2,
                                          p_person_number         IN   igs_pe_person.person_number%TYPE,
                                          p_course_cd             IN   igs_en_su_attempt.course_cd%TYPE,
                                          p_enr_method_type       IN   igs_en_su_attempt.enr_method_type%TYPE,
                                          p_deny_or_warn          OUT NOCOPY  VARCHAR2,
                                          p_message               OUT NOCOPY  VARCHAR2,
                                          p_cal_type              IN   igs_ca_inst.cal_type%TYPE,
                                          p_ci_sequence_number    IN   igs_ca_inst.sequence_number%TYPE,
                                          p_audit_requested       IN   VARCHAR2 DEFAULT 'N',
                                          p_override_cp		IN NUMBER DEFAULT NULL,   --rvivekan ,added as a part of Bulk unit upload 3-Aug-2003
                                          p_subtitle		IN VARCHAR2 DEFAULT NULL, --rvivekan ,added as a part of Bulk unit upload 3-Aug-2003
                                          p_gradsch_cd		IN VARCHAR2 DEFAULT NULL, --rvivekan ,added as a part of Bulk unit upload 3-Aug-2003
                                          p_gs_version_num	IN NUMBER DEFAULT NULL, --rvivekan ,added as a part of Bulk unit upload 3-Aug-2003
																					p_core_indicator_code IN VARCHAR2,
																					p_calling_obj	IN VARCHAR2
						                            ) RETURN BOOLEAN ;


END igs_en_ofr_wlst_opt ;

 

/
