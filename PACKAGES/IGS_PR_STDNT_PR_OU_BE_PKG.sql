--------------------------------------------------------
--  DDL for Package IGS_PR_STDNT_PR_OU_BE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_STDNT_PR_OU_BE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPR35S.pls 115.0 2002/10/04 14:31:06 ddey noship $ */

  /*************************************************************
  Created By :Deepankar Dey
  Date Created on : 21-Sept-2002
  Purpose :  After successful Insertion / Updation record , Business Event needs to be raised to send
             notification to student.The Business Event Package needs to be created, to raise Business
	     Event from different points.
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  PROCEDURE approve_otcm(
                         p_person_id                  IN NUMBER,
                         p_course_cd                  IN VARCHAR2,
                         p_sequence_number            IN NUMBER,
                         p_decision_status            IN VARCHAR2,
                         p_decision_dt                IN VARCHAR2,
                         p_progression_outcome_type   IN VARCHAR2,
                         p_description                IN VARCHAR2,
                         p_appeal_expiry_dt           IN VARCHAR2,
                         p_show_cause_expiry_dt       IN VARCHAR2
			 );




  PROCEDURE apply_positive_otcm(
			 p_person_id                 IN NUMBER,
			 p_course_cd		     IN VARCHAR2,
			 p_sequence_number	     IN NUMBER,
			 p_decision_status	     IN VARCHAR2,
			 p_decision_dt		     IN VARCHAR2,
			 p_progression_outcome_type  IN VARCHAR2,
			 p_description               IN VARCHAR2,
			 p_applied_dt		     IN VARCHAR2
			);



  PROCEDURE apply_otcm(
			 p_person_id                 IN NUMBER,
			 p_course_cd		     IN VARCHAR2,
			 p_sequence_number	     IN NUMBER,
			 p_decision_status	     IN VARCHAR2,
			 p_decision_dt		     IN VARCHAR2,
			 p_progression_outcome_type  IN VARCHAR2,
			 p_appeal_expiry_dt	     IN VARCHAR2,
			 p_show_cause_expiry_dt	     IN VARCHAR2,
			 p_applied_dt		     IN VARCHAR2,
			 p_description               IN VARCHAR2
			);



  PROCEDURE show_cause_uph_dsm(
			p_person_id                    IN NUMBER,
			p_course_cd		       IN VARCHAR2,
			p_sequence_number	       IN NUMBER,
			p_decision_status	       IN VARCHAR2,
			p_decision_dt		       IN VARCHAR2,
			p_progression_outcome_type     IN VARCHAR2,
			p_description		       IN VARCHAR2,
			p_applied_dt		       IN VARCHAR2,
			p_show_cause_dt		       IN VARCHAR2,
			p_show_cause_outcome_dt        IN VARCHAR2,
			p_show_cause_outcome_type      IN VARCHAR2
                          );



   PROCEDURE appeal_uph_dsm(
			p_person_id                    IN NUMBER,
			p_course_cd                    IN VARCHAR2,
			p_sequence_number              IN NUMBER,
			p_decision_status              IN VARCHAR2,
			p_decision_dt                  IN VARCHAR2,
			p_progression_outcome_type     IN VARCHAR2,
			p_description                  IN VARCHAR2,
			p_applied_dt                   IN VARCHAR2,
			p_appeal_dt                    IN VARCHAR2,
			p_appeal_outcome_dt            IN VARCHAR2,
			p_appeal_outcome_type          IN VARCHAR2
                          );



   PROCEDURE remove_waive_cancel_otcm(
                         p_person_id                  IN NUMBER,
                         p_course_cd		      IN VARCHAR2,
                         p_sequence_number	      IN NUMBER,
                         p_decision_status	      IN VARCHAR2,
                         p_decision_dt		      IN VARCHAR2,
                         p_progression_outcome_type   IN VARCHAR2,
                         p_applied_dt                 IN VARCHAR2 ,
			 p_description                IN VARCHAR2
                          );


END igs_pr_stdnt_pr_ou_be_pkg;

 

/
