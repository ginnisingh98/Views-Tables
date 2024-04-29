--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_PTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_PTE" as
 -- $Header: PAXPTEEB.pls 120.1 2005/08/11 10:44:20 eyefimov noship $

 -- Added a parameter to Check_Time_Exp_Proj_User to handle admin entry
 -- in Web Expenses

  PROCEDURE Check_Time_Exp_Proj_User( X_person_id   IN NUMBER DEFAULT NULL,
                                      X_fnd_user_id IN NUMBER DEFAULT NULL,
                                      X_approved    IN OUT NOCOPY VARCHAR2,
        	                          X_msg_text    OUT NOCOPY VARCHAR2 )

  IS

     l_user_id NUMBER;

  BEGIN

-- If user has passed fnd_user_id then use that id else get
-- user_id from fnd_global

   l_user_id := nvl(x_fnd_user_id, fnd_global.user_id) ;

-- If the Profile is not set, we use NVL to set X_approved to 'N'

-- Commenting the call to Value_specific API. Instead using standard
-- FND_PROFILE.Value API

  X_approved := NVL(FND_PROFILE.VALUE_SPECIFIC
                              (NAME              => 'PA_TIME_EXP_PROJ_USER',
                               USER_ID           => l_user_id,
                               RESPONSIBILITY_ID => null,
                               APPLICATION_ID    => null ),'N');



-- X_approved := NVL(FND_PROFILE.VALUE
--                            (NAME  => 'PA_TIME_EXP_PROJ_USER'),'N');
--
-- This Procedure can be customized to provide any additional validation that
-- might be required for a user .
-- The default for this procedure will not make any changes over what is set
-- in the profile option

  END  Check_Time_Exp_Proj_User;

  PROCEDURE Get_Exp_AutoApproval (X_source          IN VARCHAR2,
                                  X_exp_class_code  IN VARCHAR2 DEFAULT NULL,
                                  X_txn_id          IN NUMBER DEFAULT NULL,
				                  X_exp_ending_date IN DATE DEFAULT NULL,
                                  X_person_id       IN NUMBER DEFAULT NULL,
                                  P_Timecard_Table  IN Pa_Otc_Api.Timecard_Table DEFAULT PAGTCX.dummy,
                                  P_Module          IN VARCHAR2 DEFAULT NULL,
                                  X_approved        IN OUT NOCOPY VARCHAR2)
  IS

	REQUIRED_FIELDS_NULL exception;

  BEGIN

--      X_source must be passed. If X_source is null then we raise an exception.

	IF (X_source IS NULL) THEN
		RAISE REQUIRED_FIELDS_NULL;
	END IF;
	IF (X_source = 'PA' and X_exp_class_code IS NULL) THEN
		RAISE REQUIRED_FIELDS_NULL;
	END IF;

--      X_exp_class_code must be passed if X_source is 'PA'.

	IF (X_source = 'AP') OR (X_source = 'SELF_SERVICE') THEN

		X_approved := FND_PROFILE.VALUE_SPECIFIC
                              (NAME              => 'PA_PTE_AUTOAPPROVE_ER',
                               USER_ID           => null,
                               RESPONSIBILITY_ID => null,
                               APPLICATION_ID    => 275 );

        --  This procedure can be customized to provide any needed additional
        --  validations that might be required.  The default for this procedure
	--  will not make any changes from what is set in the profile option.

        ELSE
		IF (X_exp_class_code = 'OE') THEN
			X_approved := FND_PROFILE.VALUE_SPECIFIC
                              (NAME              => 'PA_PTE_AUTOAPPROVE_ER',
                               USER_ID           => null,
                               RESPONSIBILITY_ID => null,
                               APPLICATION_ID    => 275 );

		ELSE
 --
 --     Modified to pass responsibility and user_id for this procedure
 --     User can setup the autoapproval on responsibility level
 --     Shree 09/17/99
 --
			X_approved := FND_PROFILE.VALUE_SPECIFIC
                              (NAME              => 'PA_PTE_AUTOAPPROVE_TS',
                               USER_ID           => FND_GLOBAL.USER_ID,
                               RESPONSIBILITY_ID => FND_GLOBAL.RESP_ID,
                               APPLICATION_ID    => FND_GLOBAL.RESP_APPL_ID);

		END IF;
	END IF;

--      If X_approved is null(happens if the profile is not set), then
--      X_approved is set to 'N'

	IF (X_approved IS NULL) THEN
		X_approved := 'N';
	END IF;

  EXCEPTION
	WHEN REQUIRED_FIELDS_NULL THEN
		X_approved := 'REQUIRED_FIELDS_NULL';
	WHEN OTHERS THEN
		RAISE;

  END Get_Exp_AutoApproval;

end PA_CLIENT_EXTN_PTE ;

/
