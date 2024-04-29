--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_007" AUTHID CURRENT_USER AS
/* $Header: IGSFI62S.pls 120.0 2005/06/01 16:18:44 appldev noship $ */

FUNCTION get_sob_id RETURN NUMBER;
PRAGMA restrict_references(get_sob_id,wnds,wnps);

FUNCTION get_coa_id RETURN NUMBER;
PRAGMA restrict_references(get_coa_id,wnds,wnps);

FUNCTION get_gl_shortname RETURN VARCHAR2;
PRAGMA restrict_references(get_sob_id,wnds);

FUNCTION get_segval_desc(p_value_set_id NUMBER,p_value VARCHAR2) RETURN VARCHAR2;
PRAGMA restrict_references(get_segval_desc,wnds);

PROCEDURE get_appl_acc(p_cr_activity_id   IN  igs_fi_cr_activities.credit_activity_id%TYPE,
                       p_invoice_lines_id IN  igs_fi_invln_int.invoice_lines_id%TYPE,
                       p_dr_gl_ccid       OUT NOCOPY igs_fi_cr_activities.dr_gl_ccid%TYPE,
                       p_cr_gl_ccid       OUT NOCOPY igs_fi_cr_activities.cr_gl_ccid%TYPE,
                       p_dr_account_cd    OUT NOCOPY igs_fi_cr_activities.dr_account_cd%TYPE,
                       p_cr_account_cd    OUT NOCOPY igs_fi_cr_activities.cr_account_cd%TYPE,
                       p_status           OUT NOCOPY BOOLEAN);

FUNCTION get_sum_appl_amnt(p_application_id  igs_fi_applications.application_id%TYPE) RETURN NUMBER;
PRAGMA restrict_references(get_sum_appl_amnt,wnds,wnps);

PROCEDURE create_application (p_application_id    IN OUT NOCOPY igs_fi_applications.application_id%TYPE,
                              p_credit_id         IN     igs_fi_applications.credit_id%TYPE,
                              p_invoice_id        IN     igs_fi_applications.invoice_id%TYPE,
                              p_amount_apply      IN     igs_fi_applications.amount_applied%TYPE,
                              p_appl_type         IN     igs_fi_applications.application_type%TYPE,
                              p_appl_hierarchy_id IN     igs_fi_applications.appl_hierarchy_Id%TYPE,
                              p_validation        IN     VARCHAR2 DEFAULT 'Y',
                              p_dr_gl_ccid        OUT NOCOPY    igs_fi_cr_activities.dr_gl_ccid%TYPE,
                              p_cr_gl_ccid        OUT NOCOPY    igs_fi_cr_activities.cr_gl_ccid%TYPE,
                              p_dr_account_cd     OUT NOCOPY    igs_fi_cr_activities.dr_account_cd%TYPE,
                              p_cr_account_cd     OUT NOCOPY    igs_fi_cr_activities.cr_account_cd%TYPE,
                              p_unapp_amount      OUT NOCOPY    igs_fi_credits_all.unapplied_amount%TYPE,
                              p_inv_amt_due       OUT NOCOPY    igs_fi_inv_int_all.invoice_amount_due%TYPE,
                              p_err_msg           OUT NOCOPY    fnd_new_messages.message_name%TYPE,
                              p_status            OUT NOCOPY    BOOLEAN,
			      p_d_gl_date         IN     DATE
			      );


FUNCTION validate_person(p_person_id igs_pe_person.person_id%TYPE) RETURN VARCHAR2;
PRAGMA restrict_references(validate_person,wnds,wnps);

FUNCTION get_ccid_concat(p_ccid   IN  NUMBER) RETURN VARCHAR2;
PRAGMA restrict_references(get_ccid_concat,wnds,wnps);

FUNCTION get_person_id_type RETURN VARCHAR2;
PRAGMA restrict_references(get_person_id_type,wnds,wnps);

PROCEDURE finp_get_conv_prc_run_ind(p_n_conv_process_run_ind  OUT NOCOPY  igs_fi_control.conv_process_run_ind%TYPE,
                                    p_v_message_name          OUT NOCOPY  fnd_new_messages.message_name%TYPE);

PROCEDURE finp_get_balance_rule (p_v_balance_type          IN  igs_fi_balance_rules.balance_name%TYPE,
                                 p_v_action                IN  VARCHAR2,
				 p_n_balance_rule_id       OUT NOCOPY igs_fi_balance_rules.balance_rule_id%TYPE,
				 p_d_last_conversion_date  OUT NOCOPY igs_fi_balance_rules.last_conversion_date%TYPE,
				 p_n_version_number        OUT NOCOPY igs_fi_balance_rules.version_number%TYPE );

END igs_fi_gen_007;

 

/
