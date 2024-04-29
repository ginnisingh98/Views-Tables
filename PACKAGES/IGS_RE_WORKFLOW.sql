--------------------------------------------------------
--  DDL for Package IGS_RE_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_WORKFLOW" AUTHID CURRENT_USER AS
/* $Header: IGSRE21S.pls 115.1 2003/09/22 05:15:54 ddey noship $ */

 /******************************************************************
  Created By         :Deepankar Dey
  Date Created By    :18-Jul-2001
  Purpose            :This package implements procedure concerned to workflow
  remarks            :
  Change History
  Who      When        What
  DDEY 8-Sep-2003 The changes are done as per the
                  Enrollments Notifications TD Bug # 3052429
 ******************************************************************/

   PROCEDURE  retopic_event (
				p_personid	IN NUMBER ,
				p_programcd	IN VARCHAR2 ,
				p_restopic	IN VARCHAR2
                            );


   PROCEDURE  rethesis_event (
				p_personid	IN NUMBER ,
				p_ca_seq_num	IN NUMBER ,
				p_thesistopic	IN VARCHAR2 ,
				p_thesistitle	IN VARCHAR2 ,
				p_approved	IN VARCHAR2 ,
				p_deleted	IN VARCHAR2
                                   );

   PROCEDURE supervision_event (
				p_personid	IN NUMBER  ,
				p_ca_seq_num	IN NUMBER ,
				p_supervisorid	IN NUMBER ,
				p_startdt	IN DATE ,
				p_enddt	        IN DATE ,
				p_spr_percent	IN NUMBER ,
				p_spr_type	IN VARCHAR2,
				p_fund_percent	IN NUMBER ,
				p_org_unit_cd	IN VARCHAR2 ,
				p_rep_person_id	IN VARCHAR2 ,
				p_rep_seq_num	IN NUMBER
                                );
   PROCEDURE overduesub_event (
				p_personid	IN NUMBER   ,
				p_programcd	IN VARCHAR2,
				p_thesistitle	IN VARCHAR2,
				p_maxsubdt	IN DATE,
				p_suprvsr	IN VARCHAR2
     );



 PROCEDURE retopic_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );

 PROCEDURE thesis_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );

 PROCEDURE supervision_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );

 PROCEDURE overduesub_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );


  -- The changes are done as per the Enrollments Notifications TD Bug # 3052429

  PROCEDURE milestone_event(
			   p_personid     IN   NUMBER  	,
			   p_ca_seq_num	  IN   NUMBER   ,
			   p_milestn_typ  IN   VARCHAR2 ,
			   p_milestn_stat IN   VARCHAR2 ,
			   p_due_dt	  IN   DATE     ,
			   p_dt_reached	  IN   DATE     ,
			   p_deleted	  IN   VARCHAR2
                           );


  PROCEDURE thesis_exam_event(
			  p_personid	        IN NUMBER ,
			  p_ca_sequence_number  IN NUMBER ,
			  p_the_sequence_number	IN NUMBER ,
			  p_creation_dt	        IN DATE ,
			  p_submission_dt	IN DATE ,
			  p_thesis_exam_type	IN VARCHAR2
                             );

  PROCEDURE thesis_result_event(
			  p_personid	        IN  NUMBER ,
			  p_ca_sequence_number  IN 	NUMBER,
			  p_the_sequence_number IN	NUMBER ,
			  p_creation_dt	        IN DATE ,
			  p_submission_dt	IN DATE ,
			  p_thesis_exam_type	IN VARCHAR2 ,
			  p_thesis_result_cd	IN VARCHAR2 );

  PROCEDURE confirm_reg_event (
                          p_personid	     IN NUMBER  ,
                          p_programcd	     IN VARCHAR2,
                          p_spa_start_dt     IN DATE ,
			  p_prog_attempt_stat IN VARCHAR2
                             );

  PROCEDURE milstn_notify_prcs (
                               errbuf     OUT NOCOPY VARCHAR2 ,
                               retcode    OUT NOCOPY NUMBER ) ;
  PROCEDURE create_adhoc_role (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 );
 PROCEDURE confirm_reg_not(
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2
                    );

 PROCEDURE milstn_notify_not(
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2
                    );


END igs_re_workflow;

 

/
