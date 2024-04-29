--------------------------------------------------------
--  DDL for Package IGS_AS_NOTIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_NOTIFY_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSAS40S.pls 120.0 2005/07/05 12:49:07 appldev noship $ */

/*
  ||  Created By : nmankodi
  ||  Created On : 01-FEB-2002
  ||  Purpose : To Generate Notifications for Attendance and Grading.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

PROCEDURE  gen_as_notifications (
     errbuf                     OUT NOCOPY	  VARCHAR2,  -- Standard Error Buffer Variable
     retcode                    OUT NOCOPY	  NUMBER,    -- Standard Concurrent Return code
     p_load_calendar       IN     VARCHAR2,      -- Load Calendar ( Concatenated value of Calandar Type and Sequence Number )
     p_attend_advance_offset    IN    NUMBER,    -- No. of Days offset for Attendance Submission advanced notification.
     p_attend_start_offset      IN    NUMBER,    -- No. of Days offset for Attendance Submission is available notification.
     p_attend_end_offset        IN    NUMBER,    -- No. of Days offset for Attendance Submission is ending soon notification.
     p_midterm_advance_offset   IN    NUMBER,    -- No. of Days offset for Mid Term Grading submission advanced notification.
     p_midterm_start_offset     IN    NUMBER,    -- No. of Days offset for Mid Term Grading submission is available notification.
     p_midterm_end_offset       IN    NUMBER,    -- No. of Days offset for Mid Term Grading submission is ending soon notification.
     p_earlyfinal_advance_offset IN    NUMBER,   -- No. of Days offset for Early-Final Grading Submission advanced notification.
     p_earlyfinal_start_offset  IN    NUMBER,    -- No. of Days offset for Early-Final Grading Submission is available notification.
     p_earlyfinal_end_offset    IN    NUMBER,    -- No. of Days offset for Early-Final Grading Submission is ending soon notification.
     p_final_advance_offset     IN    NUMBER,    -- No. of Days offset for Final Grading Submission advanced notification.
     p_final_start_offset       IN    NUMBER,    -- No. of Days offset for Final Grading Submission is available notification.
     p_final_end_offset         IN    NUMBER     -- No. of Days offset for Final Grading Submission is ending soon notification.
                                                 -- Offsets can be Positive,Zero or NULL.
                                                 -- NULL means that the notification will not be generated.
                                                 -- Zero means Notification will be generated if the Alias Date is todate.
                                                 -- Positive Offset means before the Alias Date.
);
PROCEDURE raise_sua_ref_cd_be( P_AUTH_PERSON_ID IN NUMBER,
                               P_PERSON_ID IN NUMBER,
                			          P_SUAR_ID  IN NUMBER,
                		           P_ACTION         IN VARCHAR2 );

END igs_as_notify_pkg;

 

/
