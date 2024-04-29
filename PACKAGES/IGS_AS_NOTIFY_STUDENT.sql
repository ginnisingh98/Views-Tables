--------------------------------------------------------
--  DDL for Package IGS_AS_NOTIFY_STUDENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_NOTIFY_STUDENT" AUTHID CURRENT_USER AS
/* $Header: IGSAS50S.pls 115.4 2003/12/04 06:03:02 ddey noship $ */

  /*************************************************************
  Created By :Deepankar Dey
  Date Created on : 21-Sept-2002
  Purpose : This package will be called from the function node of IGSAS006.
             The purpose of the function is to select the person_id and their user name and
	     add it to the ad hoc role and set it as an item attribute of the workflow.
	     This procedure also sets the item attributes by extracting them from the event parameters.
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  PROCEDURE wf_notify_student(
                             p_busEvent IN VARCHAR2,
                             p_name IN VARCHAR2,
                             p_users IN VARCHAR2,
                             p_subject IN VARCHAR2,
                             p_message IN VARCHAR2 );

  PROCEDURE wf_set_role (itemtype    IN  VARCHAR2  ,
			 itemkey     IN  VARCHAR2  ,
			 actid	     IN  NUMBER    ,
                         funcmode    IN  VARCHAR2  ,
			 resultout   OUT NOCOPY VARCHAR2  ) ;
  /*************************************************************
  Created By :Sameer
  Date Created on : 1-Nov-2002
  Purpose : This procedure will be called to launch workflow IGSAS006.
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  PROCEDURE wf_launch_as007 (
      p_user IN VARCHAR2,
      p_stud_id IN NUMBER,
      p_stud_number IN VARCHAR2,
      p_stud_name IN VARCHAR2,
      p_order_number IN NUMBER,
      p_item_number IN NUMBER);

  /*************************************************************
  Created By :Deepankar
  Date Created on : 9-Nov-2003
  Purpose : This procedure will be called to launch workflow IGSAS006.
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  PROCEDURE raise_rel_subdate_event (
	p_unit_cd           IN VARCHAR2,
	p_term              IN VARCHAR2,
	p_location          IN VARCHAR2,
	p_title             IN VARCHAR2,
	p_teaching_cal      IN VARCHAR2,
	p_sec_number        IN VARCHAR2,
	p_instructor        IN NUMBER,
	p_ass_id            IN NUMBER,
	p_ass_type          IN VARCHAR2,
	p_reference         IN VARCHAR2 ,
	p_grading_period    IN VARCHAR2,
	p_rel_sub_dt        IN VARCHAR2 ,
	p_event             IN VARCHAR2
	);


 PROCEDURE set_adhoc_role (itemtype    IN  VARCHAR2  ,
			 itemkey     IN  VARCHAR2  ,
			 actid	     IN  NUMBER    ,
                         funcmode    IN  VARCHAR2  ,
			 resultout   OUT NOCOPY VARCHAR2  ) ;

END igs_as_notify_student;

 

/
