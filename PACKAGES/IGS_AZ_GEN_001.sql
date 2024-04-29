--------------------------------------------------------
--  DDL for Package IGS_AZ_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AZ_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSAZ01S.pls 120.1 2005/11/18 01:44:57 appldev ship $ */

/*********************************************************************************************************
 Created By         : Girish Jha
 Date Created By    : 14 May 2003
 Purpose            : This package is the generaic package for advising functionality. This contains the routines
                      for Maintaining the advising group, apply advising holds on the students of the group and
                      sending the notifications to students and advisors.
                      This is modular approach to make the routines which can be called from 1. Concurrent program
                      2. Self service pages 3. Any pl/sql block separately.

 remarks            : None
 Change History

Who             When           What
-----------------------------------------------------------
Girish Jha      12-May-2003    New Package created.
***************************************************************************************************************/

   PROCEDURE MAINTAIN_GROUPS
     ( errbuf OUT NOCOPY VARCHAR2,
       retcode OUT NOCOPY VARCHAR2,
       p_group_name  IN VARCHAR2 DEFAULT NULL,
       p_APPLY_HOLD IN  VARCHAR2 DEFAULT 'N',
       p_NOTIFY IN VARCHAR2 DEFAULT 'Y');


  PROCEDURE APPLY_HOLD
     ( errbuf OUT NOCOPY VARCHAR2,
       retcode OUT NOCOPY VARCHAR2,
       p_group_name  IN VARCHAR2 DEFAULT NULL,
       p_NOTIFY IN VARCHAR2 DEFAULT 'Y'
     );


 PROCEDURE SEND_NOTIFICATION
     ( errbuf OUT NOCOPY VARCHAR2,
       retcode OUT NOCOPY VARCHAR2,
       p_group_name  IN VARCHAR2 DEFAULT NULL
     );

 PROCEDURE ASSIGN_STUDENTS_TO_ADVISORS (
  p_group_name                        IN VARCHAR2,
  p_n_processed   OUT NOCOPY  NUMBER,
 p_start_date  IN DATE DEFAULT NULL -- This is accepted because, the call from ss page requires the start date to be null so that it can be displayed for suggested match acceptance.
);

 /******************************************************************
   Created By         : Girish Jha
   Date Created By    : 17-May-2003
   Purpose            : This procedure will be used for raising business event.  This
procedure is made very generic.
			This will acceept business event name and five pair of name value
pair of w/f parameters.
			The name of the parameters must be registered with the w/f.
   Change History
   Who      When        What
  ******************************************************************/
PROCEDURE notify_person(
                             p_busEvent IN  VARCHAR2,
                             p_param_name1 IN  VARCHAR2  DEFAULT NULL,
                             p_param_value1 IN  VARCHAR2 DEFAULT NULL,
                             p_param_name2 IN  VARCHAR2  DEFAULT NULL,
                             p_param_value2 IN  VARCHAR2 DEFAULT NULL,
                             p_param_name3 IN  VARCHAR2  DEFAULT NULL,
                             p_param_value3 IN  VARCHAR2 DEFAULT NULL,
                             p_param_name4 IN  VARCHAR2  DEFAULT NULL,
                             p_param_value4 IN  VARCHAR2 DEFAULT NULL,
                             p_param_name5 IN  VARCHAR2  DEFAULT NULL,
                             p_param_value5 IN  VARCHAR2 DEFAULT NULL
);




PROCEDURE end_date_advisor(p_group_name VARCHAR2,
			   p_advisor_person_id NUMBER,
			   p_end_date  DATE DEFAULT SYSDATE,
                           p_calling_mod VARCHAR2 DEFAULT 'C',
                           p_enforce VARCHAR2 DEFAULT NULL
			   );


PROCEDURE end_date_student(p_group_name VARCHAR2,
			   p_student_person_id  NUMBER,
			   p_end_date  DATE DEFAULT SYSDATE,
                           p_calling_mod VARCHAR2 DEFAULT 'C' ,
                           p_enforce VARCHAR2 DEFAULT NULL);

PROCEDURE end_std_advsng_hold(P_GROUP_NAME VARCHAR2, P_PERSON_ID NUMBER, p_hld_end_dt DATE DEFAULT SYSDATE);

  procedure deactivate_Group
  (p_group_name Varchar2,
  x_return_status  OUT NOCOPY varchar2,
  x_msg_count OUT NOCOPY  number,
  x_msg_data  OUT NOCOPY varchar2
  );
  procedure reactivate_Group
  (p_group_name Varchar2,
  x_return_status  OUT NOCOPY varchar2,
  x_msg_count OUT NOCOPY  number,
  x_msg_data  OUT NOCOPY varchar2
  );

PROCEDURE submit_maintain_group_job
(
  p_group_name      IN IGS_AZ_GROUPS.group_name%TYPE,
  p_return_status   OUT NOCOPY VARCHAR2,
  p_message_data    OUT NOCOPY VARCHAR2,
  p_message_count   OUT NOCOPY NUMBER,
  p_request_id        OUT NOCOPY NUMBER
);

 /******************************************************************
   Created By         : anilk
   Date Created By    : 10-Jun-2003
   Purpose            : This procedure is called from workflow IGSAZ001
   Change History
   Who      When        What
  ******************************************************************/
  PROCEDURE wf_set_role (itemtype    IN  VARCHAR2  ,
			 itemkey     IN  VARCHAR2  ,
			 actid	     IN  NUMBER    ,
                         funcmode    IN  VARCHAR2  ,
			 resultout   OUT NOCOPY VARCHAR2  ) ;


END IGS_AZ_GEN_001;

 

/
