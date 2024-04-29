--------------------------------------------------------
--  DDL for Package IGS_SS_EN_WRAPPERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SS_EN_WRAPPERS" AUTHID CURRENT_USER AS
/* $Header: IGSSS09S.pls 120.12 2006/08/24 07:34:34 bdeviset noship $ */

PROCEDURE validate_prog_pro(
p_person_id             igs_en_su_attempt.person_id%TYPE,
p_cal_type              igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number    igs_ca_inst.sequence_number%TYPE,
p_uoo_id                igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_course_cd             igs_en_su_attempt.course_cd%TYPE,
p_enr_method_type       igs_en_su_attempt.enr_method_type%TYPE,
p_message_name          OUT NOCOPY VARCHAR2,
p_deny_warn             OUT NOCOPY VARCHAR2,
p_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE enrp_ss_val_person_step(
p_person_id                     IN      NUMBER,
p_person_type                   IN      VARCHAR2,
p_load_cal_type                 IN      VARCHAR2,
p_load_ci_sequence_number       IN      NUMBER,
p_program_cd                    IN      VARCHAR2,
p_program_version               IN      NUMBER,
p_message_name                  OUT NOCOPY      VARCHAR2,
p_deny_warn                     OUT NOCOPY      VARCHAR2,
p_step_eval_result              OUT NOCOPY      VARCHAR2,
p_calling_obj                                   IN VARCHAR2,
p_create_warning                                IN VARCHAR2,
p_ss_session_id                 IN      NUMBER);

PROCEDURE validate_unit_steps(
p_person_id          IN  igs_en_su_attempt.person_id%TYPE,
p_cal_type           IN  igs_ca_inst.cal_type%TYPE,
p_ci_sequence_number IN  igs_ca_inst.sequence_number%TYPE,
p_uoo_id             IN  igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_course_cd          IN  igs_en_su_attempt.course_cd%TYPE,
p_return_status      OUT NOCOPY VARCHAR2,
p_message_name       OUT NOCOPY VARCHAR2,
p_deny_warn          OUT NOCOPY VARCHAR2);

PROCEDURE get_person_type_by_rank(
p_person_id             IN  NUMBER,
p_person_type           OUT NOCOPY VARCHAR2);

PROCEDURE call_fee_ass (
p_person_id             IN NUMBER,
p_cal_type              IN VARCHAR2,
p_sequence_number       IN NUMBER,
p_course_cd             IN VARCHAR2,
p_unit_cd               IN VARCHAR2,
p_uoo_id                IN igs_en_su_attempt.uoo_id%TYPE);


PROCEDURE enroll_cart_unit(
p_person_id             IN NUMBER,
p_uoo_id                IN NUMBER,
p_unit_cd               IN VARCHAR2,
p_version_number        IN NUMBER,
p_course_cd             IN VARCHAR2,
p_unit_attempt_status   IN VARCHAR2,
p_enrolled_dt           IN DATE DEFAULT SYSDATE);

PROCEDURE Validate_enroll_validate (
p_person_id                 IN igs_en_su_attempt.person_id%TYPE,
p_load_cal_type             IN igs_ca_inst.cal_type%TYPE,
p_load_ci_sequence_number   IN igs_ca_inst.sequence_number%TYPE,
p_uoo_ids                   IN VARCHAR2,
p_program_cd                IN igs_en_su_attempt.course_cd%TYPE,
p_message_name              OUT NOCOPY VARCHAR2,
p_deny_warn                 OUT NOCOPY VARCHAR2,
p_return_status             OUT NOCOPY VARCHAR2,
p_enr_method                IN  igs_en_cat_prc_dtl.enr_method_type%TYPE DEFAULT NULL,
p_enrolled_dt               IN  DATE DEFAULT SYSDATE);

PROCEDURE get_cart_details(
p_person_id             IN NUMBER,
p_program_cd            IN VARCHAR2,
p_load_cal_type         IN VARCHAR2,
p_load_ci_seq_num       IN NUMBER,
p_total_units_cart      OUT NOCOPY NUMBER,
p_total_cp_cart         OUT NOCOPY NUMBER);

PROCEDURE insert_into_enr_worksheet(
p_person_number         IN VARCHAR2,
p_course_cd             IN VARCHAR2,
p_uoo_id                IN NUMBER,
p_waitlist_ind          IN VARCHAR2,
p_session_id            IN NUMBER,
p_return_status         OUT NOCOPY VARCHAR2,
p_message               OUT NOCOPY VARCHAR2,
p_cal_type              IN VARCHAR2 DEFAULT NULL,
p_ci_sequence_number    IN NUMBER DEFAULT NULL,
p_audit_requested       IN VARCHAR2 DEFAULT 'N',
p_enr_method            IN igs_en_cat_prc_dtl.enr_method_type%TYPE DEFAULT NULL,
p_override_cp           IN NUMBER DEFAULT NULL,   --rvivekan ,added as a part of Bulk unit upload 3-Aug-2003
p_subtitle              IN VARCHAR2 DEFAULT NULL, --rvivekan ,added as a part of Bulk unit upload 3-Aug-2003
p_gradsch_cd            IN VARCHAR2 DEFAULT NULL, --rvivekan ,added as a part of Bulk unit upload 3-Aug-2003
p_gs_version_num        IN NUMBER DEFAULT NULL,  --rvivekan ,added as a part of Bulk unit upload 3-Aug-2003
p_core_indicator_code   IN VARCHAR2 DEFAULT NULL,
p_calling_obj                   IN VARCHAR2); --ptandon, added as part of Prevent Dropping Core Units build 1-Oct-2003

PROCEDURE  drop_selected_units (
p_uoo_ids               IN VARCHAR2,
p_person_id             IN NUMBER,
p_person_type           IN VARCHAR2,
p_load_cal_type         IN VARCHAR2,
p_load_sequence_number  IN NUMBER,
p_program_cd            IN VARCHAR2,
p_program_version       IN NUMBER DEFAULT NULL,
P_DCNT_REASON_CD        IN VARCHAR2 DEFAULT NULL,
p_admin_unit_status     IN VARCHAR2 DEFAULT NULL,
p_effective_date        IN DATE DEFAULT SYSDATE,
p_failed_uoo_ids        OUT NOCOPY VARCHAR2,
p_failed_unit_cds       OUT NOCOPY VARCHAR2,
p_return_status         OUT NOCOPY VARCHAR2,
p_message               OUT NOCOPY VARCHAR2,
p_ovrrd_min_cp_chk      IN VARCHAR2 DEFAULT 'N', --msrinivi , added new param 22-feb-2002
p_ovrrd_crq_chk         IN VARCHAR2 DEFAULT 'N', --msrinivi , added new param 2-may-2002
p_ovrrd_prq_chk         IN VARCHAR2 DEFAULT 'N' ,--msrinivi , added new param 2-may-2002
p_ovrrd_att_typ_chk     IN VARCHAR2 DEFAULT 'N') ;

-- Added the following two parameters p_reason, p_source_of_drop
-- as part of Drop/ Transfer Workflow Notification DLD. Bug# 2599925.

PROCEDURE drop_all_workflow (
p_uoo_ids               IN VARCHAR2,
p_person_id             IN NUMBER,
p_load_cal_type         IN VARCHAR2,
p_load_sequence_number  IN NUMBER,
p_program_cd            IN VARCHAR2,
p_return_status         OUT NOCOPY VARCHAR2,
p_drop_date             IN DATE DEFAULT NULL,
p_old_cp                IN NUMBER DEFAULT NULL,
p_new_cp                IN NUMBER DEFAULT NULL);

PROCEDURE transfer_workflow (
p_source_uoo_ids        IN VARCHAR2,
p_dest_uoo_ids          IN VARCHAR2,
p_person_id             IN NUMBER,
p_load_cal_type         IN VARCHAR2,
p_load_sequence_number  IN NUMBER,
p_program_cd            IN VARCHAR2,
p_unit_attempt_status   IN VARCHAR2,
p_reason                IN VARCHAR2,
p_return_status         OUT NOCOPY VARCHAR2,
p_message               OUT NOCOPY VARCHAR2);

/*
    Procedure to check whether Grading Schema exists in the Unit Section Level /
    Unit level. Added as part of Drop / Transfer Workflow Notification DLD.
    pradhakr; 03-Oct-2002; Bug# 2599925.
*/

FUNCTION enr_val_grad_usec(
p_uoo_ids               IN VARCHAR2,
p_grading_schema_code   IN VARCHAR2,
p_gs_version_number     IN NUMBER
) RETURN BOOLEAN;

PROCEDURE validate_upd_cp(
x_person_id             IN NUMBER,
x_person_type           IN VARCHAR2,
x_load_cal_type         IN VARCHAR2,
x_load_sequence_number  IN NUMBER,
x_uoo_id                IN NUMBER,
x_program_cd            IN VARCHAR2,
x_program_version       IN NUMBER,
X_OVERRIDE_ENROLLED_CP  IN NUMBER,
x_message               OUT NOCOPY VARCHAR2,
x_return_status         OUT NOCOPY VARCHAR2) ;

PROCEDURE blk_drop_units(
  p_uoo_id               IN NUMBER,
  p_person_id            IN NUMBER,
  p_person_type          IN VARCHAR2,
  p_load_cal_type        IN VARCHAR2,
  p_load_sequence_number IN NUMBER,
  p_acad_cal_type        IN VARCHAR2,
  p_acad_sequence_number IN NUMBER,
  p_program_cd           IN VARCHAR2,
  p_program_version      IN NUMBER,
  p_dcnt_reason_cd       IN VARCHAR2,
  p_admin_unit_status    IN VARCHAR2,
  p_effective_date       IN DATE DEFAULT SYSDATE,
  p_enrolment_cat        IN VARCHAR2,
  p_comm_type            IN VARCHAR2,
  p_enr_meth_type        IN VARCHAR2,
  p_total_credit_points  IN NUMBER,
  p_force_att_type       IN VARCHAR2,
  p_val_ovrrd_chk        IN VARCHAR2,
  p_ovrrd_drop           IN VARCHAR2,
  p_return_status        OUT NOCOPY BOOLEAN,
  p_message              OUT NOCOPY VARCHAR2,
  p_sub_unit             IN VARCHAR2 DEFAULT NULL);

--
-- Added as Part of EN213 Build
-- This Procedure is to switch the core unit sections selected.
--
PROCEDURE enrp_switch_core_section(
  p_person_id             IN NUMBER,
  p_program_cd            IN VARCHAR2,
  p_source_uoo_id         IN NUMBER,
  p_dest_uoo_id           IN NUMBER,
  p_session_id            IN NUMBER,
  p_cal_type              IN VARCHAR2,
  p_ci_sequence_number    IN NUMBER,
  p_audit_requested       IN VARCHAR2,
  p_core_indicator_code   IN VARCHAR2,
  p_waitlist_ind          IN VARCHAR2,
  p_return_status         OUT NOCOPY VARCHAR2,
  p_message_name          OUT NOCOPY VARCHAR2);

PROCEDURE drop_notif_variable(
  p_reason                IN VARCHAR2,
  p_source_of_drop        IN VARCHAR2);

PROCEDURE ENRP_CHK_DEL_SUB_UNITS(
p_person_id IN NUMBER,
p_course_cd IN VARCHAR2,
p_load_cal_type IN VARCHAR2,
p_load_ci_seq_num IN NUMBER,
p_selected_uoo_ids IN VARCHAR2,
p_ret_all_uoo_ids OUT NOCOPY VARCHAR2,
p_ret_sub_uoo_ids OUT NOCOPY VARCHAR2,
p_ret_nonsub_uoo_ids OUT NOCOPY VARCHAR2,
p_delete_flag IN VARCHAR2 DEFAULT 'N'
);

FUNCTION get_unit_int_status(
             x_person_id IN NUMBER,
             x_person_type IN VARCHAR2,
             x_load_cal_type IN VARCHAR2,
             x_load_sequence_number IN NUMBER,
             x_program_cd IN VARCHAR2,
             x_message OUT NOCOPY VARCHAR2,
             x_return_status OUT NOCOPY VARCHAR2
           )
RETURN VARCHAR2;

--procedure to update the terms SPA planning sheet status.
PROCEDURE update_spa_plan_sts( p_n_person_id IN NUMBER,
                               p_c_program_cd IN VARCHAR2,
                               p_c_cal_type IN VARCHAR2,
                               p_n_seq_num IN NUMBER,
                               p_c_plan_sts    IN VARCHAR2);

PROCEDURE update_grading_schema(
             p_person_id IN NUMBER,
             p_uoo_id IN NUMBER,
             p_course_cd IN VARCHAR2,
             p_grading_schema IN VARCHAR2,
             p_gs_version IN NUMBER,
             p_message OUT NOCOPY VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2
             );

PROCEDURE update_credit_points(
             p_person_id IN NUMBER,
             p_person_type IN VARCHAR2,
             p_load_cal_type IN VARCHAR2,
             p_load_sequence_number IN NUMBER,
             p_uoo_id IN NUMBER,
             p_course_cd IN VARCHAR2,
             p_course_version IN NUMBER,
             p_override_enrolled_cp IN NUMBER,
             p_message OUT NOCOPY VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2
             );

PROCEDURE update_audit(
             p_person_id IN NUMBER,
             p_load_cal_type IN VARCHAR2,
             p_load_sequence_number IN NUMBER,
             p_uoo_id IN NUMBER,
             p_course_cd IN VARCHAR2,
             p_no_assessment_ind IN VARCHAR2,
             p_override_cp IN NUMBER,
             p_message OUT NOCOPY VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2
             );

PROCEDURE remove_permission_unit(
             p_request_id IN NUMBER,
             p_load_cal IN VARCHAR2,
             p_load_seq_num IN NUMBER,
             p_course_cd IN VARCHAR2
             );


PROCEDURE update_core_indicator(
             p_person_id IN NUMBER,
             p_uoo_id IN NUMBER,
             p_program_cd IN VARCHAR2,
             p_core_indicator IN VARCHAR2,
             p_message OUT NOCOPY VARCHAR2);

PROCEDURE check_en_security( p_person_id  IN NUMBER,
                             p_course_cd  IN VARCHAR2,
                             p_uoo_id     IN NUMBER,
                             p_table      IN VARCHAR2,
                             p_mode       IN VARCHAR2,
                             p_select_allowed  OUT NOCOPY VARCHAR2,
                             p_update_allowed  OUT NOCOPY VARCHAR2,
                             p_message         OUT NOCOPY VARCHAR2);

PROCEDURE update_audit_flag(p_person_id IN NUMBER,
                            p_course_cd  IN VARCHAR2,
                            p_uoo_id    IN NUMBER,
                            p_upd_audit_flag IN VARCHAR2);

FUNCTION check_perm_exists(p_person_id IN NUMBER,
                           p_uoo_id    IN NUMBER,
                           p_request_type IN VARCHAR2) return varchar2;
FUNCTION check_sua_exists(p_person_id IN NUMBER,
                           p_uoo_id    IN NUMBER,
                           p_course_cd IN VARCHAR2) return varchar2;

PROCEDURE chk_cart_units(p_person_id IN NUMBER,
                         p_course_cd  IN VARCHAR2,
                         p_load_cal_type  IN VARCHAR2,
                         p_load_sequence_number IN NUMBER,
                         p_cart_exists OUT NOCOPY VARCHAR2
                         );

END igs_ss_en_wrappers;

 

/
