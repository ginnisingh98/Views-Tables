--------------------------------------------------------
--  DDL for Package IGS_UC_TRAN_PROCESSOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_TRAN_PROCESSOR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSUC23S.pls 120.3 2006/08/21 03:51:54 jbaber ship $ */

PROCEDURE trans_build (
                        P_Tran_type      IN  igs_uc_transactions.transaction_type%TYPE,
                        P_App_no         IN  igs_uc_transactions.app_no%TYPE,
                        P_Choice_no      IN  igs_uc_transactions.choice_no%TYPE,
                        P_Decision       IN  igs_uc_transactions.decision%TYPE,
                        P_Course         IN  igs_uc_transactions.program_code%TYPE,
                        P_Campus         IN  igs_uc_transactions.campus%TYPE,
                        P_Entry_month    IN  igs_uc_transactions.entry_month%TYPE,
                        P_Entry_year     IN  igs_uc_transactions.entry_year%TYPE,
                        P_Entry_point    IN  igs_uc_transactions.entry_point%TYPE,
                        P_SOC            IN  igs_uc_transactions.SOC%TYPE,
                        P_Free_Format    IN  igs_uc_transactions.comments_in_offer%TYPE,
                        P_Hold           IN  igs_uc_transactions.hold_flag%TYPE,
                        P_return1        OUT NOCOPY igs_uc_transactions.return1%TYPE,
                        P_return2        OUT NOCOPY igs_uc_transactions.return2%TYPE,
                        P_Inst_reference IN  igs_uc_transactions.inst_reference%TYPE ,
                        P_cond_cat       IN  igs_uc_transactions.test_cond_cat%TYPE DEFAULT NULL,
                        P_cond_name      IN  igs_uc_transactions.test_cond_name%TYPE DEFAULT NULL,
                        P_auto_generated IN  igs_uc_transactions.auto_generated_flag%TYPE DEFAULT NULL,
			p_system_code    IN  igs_uc_transactions.system_code%TYPE DEFAULT NULL,
			p_ucas_cycle     IN  igs_uc_transactions.ucas_cycle%TYPE DEFAULT NULL,
                        p_modular        IN  igs_uc_transactions.modular%TYPE DEFAULT NULL,
                        p_part_time      IN  igs_uc_transactions.part_time%TYPE DEFAULT NULL,
                        p_uc_tran_id     OUT NOCOPY igs_uc_transactions.uc_tran_id%TYPE,
                        p_validate_error_cd OUT NOCOPY igs_lookup_values.lookup_code%TYPE,
                        p_mode           IN  VARCHAR2 DEFAULT 'R');

PROCEDURE transaction_population(p_condition_category1 IN  igs_uc_transactions.test_cond_cat%TYPE,
                                 p_condition_name1     IN  igs_uc_transactions.test_cond_name%TYPE,
                                 p_soc1                OUT NOCOPY  igs_uc_transactions.SOC%TYPE,
                                 p_comments_in_offer   OUT NOCOPY igs_uc_offer_conds.marvin_code%TYPE );

PROCEDURE transaction_validation(p_transaction_type  IN igs_uc_transactions.transaction_type%TYPE,
                                 p_decision          IN igs_uc_transactions.decision%TYPE,
                                 p_comments_in_offer IN igs_uc_transactions.comments_in_offer%TYPE,
                                 p_error_code OUT NOCOPY igs_lookup_values.lookup_code%TYPE);

PROCEDURE trans_write( p_system_code IN  igs_uc_ucas_control.system_code%TYPE,
                       errbuf        OUT NOCOPY VARCHAR2,
                       retcode       OUT NOCOPY NUMBER );

-- rghosh  bug# 2860860 (UCAS Conditional Offer build)
-- added the function get_adm_offer_resp_stat
-- this function will return the user defined offer response status mapped with
-- which the Admission Application instance has to be updated with, after validating
-- the Old and New Outcome statuses and Offer Response Status against UCAS setup.

FUNCTION get_adm_offer_resp_stat  (
       p_alt_appl_id IN igs_ad_appl_all.alt_appl_id%TYPE,
       p_choice_number IN  igs_ad_appl_all.choice_number%TYPE,
       p_old_outcome_status IN igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE,
       p_new_outcome_status IN igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE,
       p_old_adm_offer_resp_status IN igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE,
       p_message_name OUT NOCOPY VARCHAR2
       )  RETURN VARCHAR2 ;

END igs_uc_tran_processor_pkg;

 

/
