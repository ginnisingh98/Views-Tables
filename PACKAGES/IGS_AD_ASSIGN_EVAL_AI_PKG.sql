--------------------------------------------------------
--  DDL for Package IGS_AD_ASSIGN_EVAL_AI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_ASSIGN_EVAL_AI_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADB4S.pls 115.10 2003/06/06 22:27:42 tmajumde noship $ */

PROCEDURE Assign_Eval_To_Appl_Inst(
	 Errbuf                   OUT NOCOPY VARCHAR2,
         Retcode                  OUT NOCOPY NUMBER,
         p_review_profile_id      IN  NUMBER DEFAULT NULL,
         p_review_group_code      IN  NUMBER DEFAULT NULL,
         p_unassigned_appl        IN  VARCHAR2 DEFAULT NULL,
         p_org_id IN NUMBER
);

PROCEDURE Assign_Eval_To_Ai(
	 Errbuf                   OUT NOCOPY VARCHAR2,
         Retcode                  OUT NOCOPY NUMBER,
         p_appl_rev_profile_id    IN  NUMBER,
         p_appl_revprof_revgr_id  IN  NUMBER,
         p_person_id              IN  NUMBER,
         p_admission_appl_number  IN  NUMBER,
         p_nominated_course_cd    IN  VARCHAR2,
         p_sequence_number        IN  NUMBER );

PROCEDURE  Wf_Inform_Evaluator_Appl
                       (  p_evaluator_id        IN   NUMBER,
                          p_evaluator_name      IN   VARCHAR2,
                          p_evaluator_full_name IN   VARCHAR2
                        );

FUNCTION rule_function  (p_subscription in RAW,
                         p_event        in out NOCOPY WF_EVENT_T) return varchar2;


FUNCTION Calc_Ratstat(
        p_person_id IN igs_ad_ps_appl_inst_all.person_id%TYPE,
        p_admission_appl_number IN igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
        p_nominated_course_cd IN igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
        p_sequence_number IN igs_ad_ps_appl_inst_all.sequence_number%TYPE,
        p_faculty_id IN igs_ad_appl_eval.evaluator_id%TYPE,
        p_roletype IN VARCHAR2 DEFAULT NULL,
        p_eval_type IN VARCHAR2,
        p_eval_seq_number IN NUMBER)
	RETURN VARCHAR2;

-- this procedure will set the package variable g_dns_ind according to the value of the checkbox do not send notification in ratings forms(IGSAD090)
-- rghosh (bug # 2871426 - Evaluator entry and assignment
PROCEDURE set_dns_ind (x_do_not_send_notif  IN VARCHAR2);

--this function will return the value of the next sequence number that has to be assigned to new evaluator who is added manually
-- rghosh (bug#2871426 - Evaluator entry and assignment)
FUNCTION set_eval_sequence (p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                                                            p_admission_appl_number  igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
                                                            p_nominated_course_cd   igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
                                                            p_sequence_number   igs_ad_ps_appl_inst_all.sequence_number%TYPE,
							    p_evaluator_id igs_ad_appl_eval.evaluator_id%TYPE,
							    p_rating_type_id igs_ad_appl_eval.rating_type_id%TYPE,
							    p_rating_scale_id igs_ad_appl_eval.rating_scale_id%TYPE )
							    RETURN NUMBER;

END igs_ad_assign_eval_ai_pkg ;

 

/
