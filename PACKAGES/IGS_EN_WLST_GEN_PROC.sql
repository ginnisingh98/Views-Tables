--------------------------------------------------------
--  DDL for Package IGS_EN_WLST_GEN_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_WLST_GEN_PROC" AUTHID CURRENT_USER AS
/* $Header: IGSEN76S.pls 115.10 2003/12/11 11:09:46 rnirwani ship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 18-JUL-2001
  --
  --Purpose: Package  specification contains definition of procedures
  --         getPersonDetail and getUooDetail
  --         and procedure to raise event for sending mail to student
  --         and administrator
  --         and function to get message text
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ptandon     26-Aug-2003     Modified the procedure Enrp_Resequence_Wlst and
  --                            added three more procedures Enrp_Wlst_Assign_Pos,
  --                            Enrp_Wlst_Dt_Reseq and Enrp_Wlst_Pri_Pref_Calc as
  --                            part of Waitlist Enhancements Build (Bug# 3052426)
  -- rnirwani   01-Dec-2003     Bug# 2829263. Term records build
  --                            Parameters to procedure wf_inform_stud have been modified.
  -------------------------------------------------------------------

  -- Record type for PL/SQL table
  TYPE t_modified_pos_rec IS RECORD
  (
       current_position            NUMBER,
       previous_position           NUMBER
  );

  TYPE t_modified_pos_tab IS TABLE OF t_modified_pos_rec INDEX BY BINARY_INTEGER;

  FUNCTION  getmessagetext (p_message_name     IN   VARCHAR2
                            )RETURN VARCHAR2;

  PROCEDURE  getpersondetail ( p_person_id      IN   igs_pe_person.person_id%TYPE        ,
                               p_person_number  OUT NOCOPY  igs_pe_person.person_number%TYPE    ,
                               p_full_name      OUT NOCOPY  igs_pe_person.full_name%TYPE        ,
                               p_email_addr     OUT NOCOPY  igs_pe_person.email_addr%TYPE       ,
                               p_message        OUT NOCOPY  VARCHAR2
                             ) ;

  PROCEDURE  getuoodetail ( p_uoo_id           IN     igs_ps_unit_ofr_opt.uoo_id%TYPE      ,
                            p_unit_cd          OUT NOCOPY    igs_ps_unit_ver.unit_cd%TYPE         ,
                            p_unit_title       OUT NOCOPY    igs_ps_unit_ver.title%TYPE           ,
                            p_cal_type         OUT NOCOPY    igs_ps_unit_ofr_opt.cal_type%TYPE    ,
                            p_alternate_code   OUT NOCOPY    igs_ca_inst.alternate_code%TYPE      ,
                            p_location_desc    OUT NOCOPY    igs_ad_location.description%TYPE     ,
                            p_unit_class       OUT NOCOPY    igs_ps_unit_ofr_opt.unit_class%TYPE  ,
                            p_message          OUT NOCOPY    VARCHAR2
                          )  ;

  PROCEDURE   wf_inform_stud    (  p_person_id                IN igs_en_stdnt_ps_att.person_id%TYPE     ,
                                   p_program_cd               IN igs_en_stdnt_ps_att.course_cd%TYPE,
                                   P_version_number           IN igs_en_stdnt_ps_att.version_number%TYPE,
                                   P_program_attempt_status   IN igs_en_stdnt_ps_att.course_attempt_status%TYPE,
                                   p_org_id                   IN NUMBER,
                                   p_old_key_program          IN igs_en_stdnt_ps_att.course_cd%TYPE DEFAULT NULL,
                                   p_old_prim_program         IN igs_en_stdnt_ps_att.course_cd%TYPE DEFAULT NULL,
                                   p_load_cal_type            IN igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                                   p_load_ci_seq_num          IN igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                                );

  PROCEDURE  wf_send_mail_stud  (  p_person_id    IN    igs_pe_person.person_id%TYPE     ,
                                   p_uoo_id       IN    igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                                   p_org_id       IN    NUMBER
                                );

  PROCEDURE  wf_send_mail_adm   (  p_person_id_list    IN    VARCHAR2                         ,
                                   p_uoo_id            IN    igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                                   p_org_id            IN    NUMBER
                                );

  FUNCTION Enrp_Resequence_Wlst ( p_uoo_id              IN   igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                                  p_modified_pos_tab    IN   t_modified_pos_tab
                                 ) RETURN BOOLEAN;

  PROCEDURE check_stud_count (  itemtype    IN  VARCHAR2,
                                itemkey     IN  VARCHAR2,
                                        actid       IN  NUMBER,
                                            funcmode    IN  VARCHAR2,
                                            resultout   OUT NOCOPY VARCHAR2
                             );

  PROCEDURE check_manual_ind (  itemtype    IN  VARCHAR2,
                                itemkey     IN  VARCHAR2,
                                    actid       IN  NUMBER,
                                            funcmode    IN  VARCHAR2,
                                            resultout   OUT NOCOPY VARCHAR2
                             );

  -- Procedure to re-sequence the students after calculating the priority/preference for the student in context.
  PROCEDURE enrp_wlst_assign_pos (  p_person_id         IN  NUMBER ,
                                    p_program_cd        IN  VARCHAR2 ,
                                    p_uoo_id            IN  NUMBER
                                 );

  -- Procedure to re-sequence the remaining students after placing the student in context at appropriate position.
  PROCEDURE enrp_wlst_dt_reseq   (  p_person_id         IN  NUMBER ,
                                    p_program_cd        IN  VARCHAR2 ,
                                    p_uoo_id            IN  NUMBER ,
                                    p_cur_position      IN  NUMBER
                                 );

  -- Procedure to calculate priority/preference weightages.
  PROCEDURE enrp_wlst_pri_pref_calc  (  p_person_id             IN  NUMBER ,
                                        p_program_cd            IN  VARCHAR2 ,
                                        p_uoo_id                IN  NUMBER ,
                                        p_priority_weight       OUT NOCOPY NUMBER ,
                                        p_preference_weight     OUT NOCOPY NUMBER
                                     );

  PROCEDURE inform_stud_not (  itemtype    IN  VARCHAR2,
                               itemkey     IN  VARCHAR2,
                               actid       IN  NUMBER,
                               funcmode    IN  VARCHAR2,
                               resultout   OUT NOCOPY VARCHAR2
                             );

END igs_en_wlst_gen_proc ;

 

/
