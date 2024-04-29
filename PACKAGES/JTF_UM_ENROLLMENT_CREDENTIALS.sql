--------------------------------------------------------
--  DDL for Package JTF_UM_ENROLLMENT_CREDENTIALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_ENROLLMENT_CREDENTIALS" AUTHID CURRENT_USER as
/* $Header: JTFUMECS.pls 120.2 2005/10/29 03:45:34 snellepa ship $ */

PROCEDURE ASSIGN_ENROLLMENT_CREDENTIALS
          (
	   X_USER_NAME VARCHAR2,
	   X_USER_ID   NUMBER,
	   X_SUBSCRIPTION_ID NUMBER
	   );

PROCEDURE ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_ID NUMBER,
	   X_APPLICATION_ID    NUMBER
	  );

PROCEDURE ASSIGN_RESPONSIBILITY
          (
	   X_USER_ID            NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2,
	   X_APPLICATION_ID     NUMBER
	  );

PROCEDURE REVOKE_RESPONSIBILITY
          (
	   X_USER_ID            NUMBER,
	   X_RESPONSIBILITY_KEY VARCHAR2,
	   X_APPLICATION_ID     NUMBER
	  );

PROCEDURE REVOKE_RESPONSIBILITY
          (
	   X_USER_ID           NUMBER,
	   X_RESPONSIBILITY_ID NUMBER,
	   X_APPLICATION_ID    NUMBER
	  );

PROCEDURE REJECT_ENROLL_DEL_PEND_USER (P_USERNAME in  VARCHAR2);

  --
  -- Procedure
  --    assign_user_enrollment
  --
  -- Description
  --    This API calls other api's that will perform:
  --      createUserEnrollment;
  --      if (isApprovalRequired)
  --        assignEnrollCredentials;
  --      else
  --        launchWFProcess;
  --
  -- IN
  --    p_user_id         -- userid
  --    p_username        -- username
  --    p_usertype_id     -- usertype id
  --    p_enrollment_id -- enrollment id
  --    p_delegate_flag   -- delegate flag (T/F)
  --    p_approval_id     -- enrollment's approval id,
  --                         if p_approval_id is null approval is not required.
  --                         if p_approval_id is not null, approval is required.
  --
  -- OUT
  --    x_enrollment_reg_id -- enrollment reg id
  procedure assign_user_enrollment (p_user_id           in  number,
                                    p_username          in  varchar2,
                                    p_usertype_id       in  number,
                                    p_enrollment_id     in  number,
                                    p_delegate_flag     in  varchar2,
                                    p_approval_id       in  number,
                                    x_enrollment_reg_id out NOCOPY number);

END JTF_UM_ENROLLMENT_CREDENTIALS;


 

/
