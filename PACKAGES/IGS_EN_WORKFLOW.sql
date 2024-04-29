--------------------------------------------------------
--  DDL for Package IGS_EN_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_WORKFLOW" AUTHID CURRENT_USER AS
/* $Header: IGSEN85S.pls 120.2 2006/04/13 01:53:54 smaddali ship $ */

 /******************************************************************
  Created By         :Sanjeeb Rakshit
  Date Created By    :18-Jul-2001
  Purpose            :This package implements procedure concerned to workflow
  remarks            :
  Change History
  Who      When        What
  vchappid 26-Jul-01  Two new procedures have been included
  knaraset 18-Nov-2003 Added procedure student_placement_event, for placement build
  bdeviset 20-Mar-2006 Added procedure raise_spi_rcond_event for bug# 5083465
 ******************************************************************/


 PROCEDURE  sua_status_change_mail( p_unit_status IN VARCHAR2,
                                    p_person_id   IN NUMBER,
                                    p_uoo_id      IN NUMBER
                                  );

 PROCEDURE inform_stdnt_instruct_action( p_student_id       IN NUMBER,
                                         p_instructor_id    IN NUMBER,
                                         p_uoo_id           IN NUMBER,
                                         p_approval_status  IN VARCHAR2,
                                         p_date_submission  IN DATE,
					 p_request_type     IN VARCHAR2
                                       );

  PROCEDURE inform_instruct_stdnt_petition( p_student_id       IN NUMBER,
                                            p_instructor_id    IN NUMBER,
                                            p_uoo_id           IN NUMBER,
                                            p_date_submission  IN DATE,
					    p_transaction_type IN VARCHAR2,
					    p_request_type     IN VARCHAR2
                                          );
  PROCEDURE  intermission_event(p_personid	IN  NUMBER  ,
				p_program_cd	IN  VARCHAR2,
				p_intmtype	IN  VARCHAR2,
				p_startdt	IN  DATE,
				p_enddt	        IN  DATE ,
				p_inst_name	IN  VARCHAR2,
				p_max_cp	IN  NUMBER,
				p_max_term	IN  NUMBER,
				p_anti_cp	IN  NUMBER,
				p_approver	IN  NUMBER
                                  );

  PROCEDURE  progdiscont_event (
  			        p_personid	IN NUMBER   ,
				p_programcd	IN VARCHAR2,
				p_discontindt	IN DATE ,
				p_discontincd	IN VARCHAR2
                                   );

  PROCEDURE progtrans_event (
				p_personid	IN NUMBER ,
				p_destprogcd	IN VARCHAR2,
				p_progstartdt	IN DATE ,
				p_location	IN VARCHAR2,
				p_atten_type	IN VARCHAR2,
				p_atten_mode	IN VARCHAR2,
				p_prog_status	IN VARCHAR2,
				p_trsnfrdt	IN DATE,
				p_sourceprogcd	IN VARCHAR2
                             );

 PROCEDURE progofropt_event (
				p_personid	    IN   NUMBER   ,
				p_programcd	    IN   VARCHAR2 ,
				p_locationcd	    IN   VARCHAR2 ,
				p_prev_location_cd  IN   VARCHAR2 ,
				p_attndmode	    IN   VARCHAR2 ,
				p_prev_attndmode    IN   VARCHAR2 ,
				p_attndtype	    IN   VARCHAR2 ,
				p_prev_attndtype    IN   VARCHAR2

                            );

 PROCEDURE enr_notification (  ERRBUF           OUT NOCOPY VARCHAR2 ,
                               RETCODE          OUT NOCOPY NUMBER ,
                               p_acad_cal_type	IN VARCHAR2 ,
                               p_sub_offset_day	IN NUMBER
                            );


 PROCEDURE intermission_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );


 PROCEDURE progtrans_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );

 PROCEDURE progofropt_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );


 PROCEDURE progdiscont_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );

PROCEDURE student_placement_event(p_person_id	IN  NUMBER  ,
				p_program_cd	IN  VARCHAR2,
				p_unit_cd	IN  VARCHAR2,
				p_unit_class IN VARCHAR2,
                p_location_cd IN VARCHAR2,
                p_uoo_id IN NUMBER);

procedure raise_withdraw_perm_evt (p_n_uoo_id IN NUMBER,
                                   p_c_load_cal IN VARCHAR2,
                                   p_n_load_seq_num IN NUMBER,
                                   p_n_person_id IN NUMBER,
                                   p_c_course_cd IN VARCHAR2,
                                   p_c_approval_type IN VARCHAR2);


PROCEDURE raise_spi_rcond_event ( p_person_id             IN NUMBER,
                                  p_program_cd            IN VARCHAR2,
                                  p_intm_type             IN VARCHAR2,
                                  p_changed_rconds        IN VARCHAR2,
                                  p_changed_rconds_desc   IN VARCHAR2);

END igs_en_workflow;

 

/
