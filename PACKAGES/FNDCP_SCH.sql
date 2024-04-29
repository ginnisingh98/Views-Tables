--------------------------------------------------------
--  DDL for Package FNDCP_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FNDCP_SCH" AUTHID CURRENT_USER as
/* $Header: AFCPSCHS.pls 115.2 99/07/16 23:15:23 porting ship $ */

-- Procedure
--   COMMIT_CHANGES
--
-- Purpose
--   Commits changes and sets 'dirty' flag for scheduler engine.
--
PROCEDURE COMMIT_CHANGES;

--
-- Procedure
--   SET_SESSION_MODE
--
-- Purpose
--   Sets the package mode for the current session.
--
-- Arguments:
--   session_mode - 'seed_data' if new data is for Datamerge.
--                  'customer_data' is the default.
--
PROCEDURE set_session_mode(session_mode IN VARCHAR2);


-- Function
--   MESSAGE
--
-- Purpose
--   Return an error message.  Messages are set when
--   validation (program) errors occur.
--
FUNCTION message RETURN VARCHAR2;

--
-- Procedure
--   Class
--
-- Purpose
--   Register a Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name	     - Class Name
--
--   User_Class_Name - User Class Name
--
--   Description     - Description
--
PROCEDURE	Class(	Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			User_Class_Name IN Varchar2,
			Description	IN Varchar2 DEFAULT NULL,
			Lang_CODE       IN Varchar2);

--
-- Function
--   Class_Exists
--
-- Purpose
--   Determine Existence of Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name	     - Class Name
--
FUNCTION Class_Exists (	Application 	IN Varchar2,
			Class_Name      IN Varchar2
			) Return Boolean;

--
-- Function
--   Class_Enable
--
-- Purpose
--   Set enabled flag for Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name	     - Class Name
--
PROCEDURE Class_Enable(	Application 	IN Varchar2,
			Class_Name      IN Varchar2
			);

--
-- Function
--   Class_Disable
--
-- Purpose
--   Reset enabled flag for Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name	     - Class Name
--
PROCEDURE Class_Disable(Application 	IN Varchar2,
			Class_Name      IN Varchar2
			);

--
-- Function
--   Set_Class_Resub
--
-- Purpose
--   Reset enabled flag for Concurrent Release Class.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Class_Name	     - Class Name
--
--   Resub_Interval  - How long of a delay for resubmission
--
--   Resub_Int_Unit_Code - Units for Resub_Interval
--			(MINUTES, HOURS, DAYS, MONTHS)
--
--   Resub_Int_Type_Code - Offset from start or end of request?
--			(START, END)
--
PROCEDURE Set_Class_Resub(Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			Resub_Interval  IN Number,
			Resub_Int_Unit_Code IN Varchar,
			Resub_Int_Type_Code IN Varchar
			);

-- Procedure
--   Class_Member
--
-- Purpose
--   Add Disjunction to a Concurrent Release Class.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Disjunction_Application - Application Short Name
--
--   Disjunction_Name      - Disjunction Name
--
PROCEDURE Class_Member(	Class_Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			Disjunction_Application IN Varchar2,
			Disjunction_Name IN Varchar2
			);

-- Procedure
--   Class_DisMember
--
-- Purpose
--   Remove Disjunction from a Concurrent Release Class.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Disjunction_Application - Application Short Name
--
--   Disjunction_Name      - Disjunction Name
--
PROCEDURE Class_DisMember(Class_Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			Disjunction_Application IN Varchar2,
			Disjunction_Name IN Varchar2
			);

-- Function
--   Class_Member_Exists
--
-- Purpose
--   Check Membership in a Concurrent Release Class.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Disjunction_Application - Application Short Name
--
--   Disjunction_Name      - Disjunction Name
--
Function Class_Member_Exists(Class_Application 	IN Varchar2,
			Class_Name      IN Varchar2,
			Disjunction_Application IN Varchar2,
			Disjunction_Name IN Varchar2
			)return Boolean;


-- Procedure
--   Disjunction
--
-- Purpose
--   Register a Concurrent Release Disjunction.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Disj_Name       - Disjunction Name
--
--   User_Disj_Name  - User Disjunction Name
--
--   Description     - Description
--
PROCEDURE       Disjunction(  	Application     IN Varchar2,
                        	Disj_Name      	IN Varchar2,
                        	User_Disj_Name	IN Varchar2,
                        	Description     IN Varchar2 DEFAULT NULL,
                        	Lang_CODE       IN Varchar2);
-- Function
--   Disjunction_Exists
--
-- Purpose
--   Determin Existence of a Concurrent Release Disjunction.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Disj_Name       - Disjunction Name
--
FUNCTION Disjunction_Exists(  	Application     IN Varchar2,
                        	Disj_Name      	IN Varchar2
                        ) Return Boolean;

-- Procedure
--   Disj_Member_S
--
-- Purpose
--   Add State to a Concurrent Release Disjunction.
--
-- Arguments:
--   Disj Application - Application Short Name
--
--   Disj_Name      - Disj Name
--
--   State_Application - Application Short Name
--
--   State_Name      - State Name
--
--   State_Value      - Value Name
--
--   Negation Flag    - 'Y' or 'N'
--
PROCEDURE Disj_Member_S(Disj_Application 	IN Varchar2,
			Disj_Name      IN Varchar2,
			State_Application IN Varchar2,
			State_Name IN Varchar2,
			State_Value IN Varchar2,
			Negation_Flag IN Varchar2 DEFAULT 'N'
			);

-- Procedure
--   Disj_Member_P
--
-- Purpose
--   Add Period to a Concurrent Release Disjunction.
--
-- Arguments:
--   Disj Application - Application Short Name
--
--   Disj_Name      - Disj Name
--
--   Period_Application - Application Short Name
--
--   Period_Name      - Period Name
--
--   Negation Flag    - 'Y' or 'N'
--
PROCEDURE Disj_Member_P(Disj_Application 	IN Varchar2,
			Disj_Name      IN Varchar2,
			Period_Application IN Varchar2,
			Period_Name IN Varchar2,
			Negation_Flag IN Varchar2 DEFAULT 'N'
			);

-- Procedure
--   Disj_DisMember
--
-- Purpose
--   Remove State or Period from a Concurrent Release Disjunction.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Member_Application - Application Short Name
--
--   Member_Name      - Member Name
--
--   Member_Type      - 'S' or 'P'
--
PROCEDURE Disj_DisMember(Disj_Application 	IN Varchar2,
			Disj_Name      IN Varchar2,
			Member_Application IN Varchar2,
			Member_Name IN Varchar2,
			Member_Type IN Varchar2
			);

-- Function
--   Disj_Member_Exists
--
-- Purpose
--   Check Membership in a Concurrent Release Disjunction.
--
-- Arguments:
--   Class Application - Application Short Name
--
--   Class_Name      - Class Name
--
--   Member_Application - Application Short Name
--
--   Member_Name      - Member Name
--
--   Member_Type      - 'S' or 'P'
--
FUNCTION Disj_Member_Exists(Disj_Application       IN Varchar2,
                        Disj_Name      IN Varchar2,
                        Member_Application IN Varchar2,
                        Member_Name IN Varchar2,
                        Member_Type IN Varchar2
			)return Boolean;


-- Function
--   Period_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release Period.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Period_Name     - Period Name
--
FUNCTION Period_Exists     (    Application     IN Varchar2,
                                Period_Name     IN Varchar2
                        ) return Boolean;

-- Procedure
--   Period
--
-- Purpose
--   Register a Concurrent Release Period.
--
-- Arguments:
--   Application     - Application Short Name
--
--   Period_Name     - Period Name
--
--   User_Period_Name - User Period Name
--
--   Description     - Description
--
--   Period_Type     - Day, Month, Year, or Reverse Month
--
--   Period_Length   - Length of period in terms of Period_Type
--
--   Period_Start    - Start point of a period
--
--   Period_Stop     - Stop point of a period

PROCEDURE       Period	   (    Application     IN Varchar2,
                                Period_Name     IN Varchar2,
                                User_Period_Name IN Varchar2,
                                Description     IN Varchar2,
				Period_Type	IN Varchar2,
				Period_Length   IN Number,
				Period_Start    IN Date,
				Period_Stop     IN Date,
				Lang_CODE       IN Varchar2
                        );

-- Procedure
--   State_Value_Set
--
-- Purpose
--   Register a Concurrent Release State Value Set
--
-- Arguments:
--   Set_Name        - SetName
--
--   User_Set_Name   - User Set Name
--
--   Description     - Description
--
PROCEDURE       State_Value_Set(Set_Name        IN Varchar2,
                                User_Set_Name   IN Varchar2,
                                Description     IN Varchar2 DEFAULT NULL,
				Lang_CODE       IN Varchar2
                        );

-- Procedure
--   State_Value
--
-- Purpose
--   Register a Concurrent Release State Value
--
-- Arguments:
--   Value_Name      - Value Name
--
--   Value_Set_Name  - Set Name
--
PROCEDURE       State_Value(	Value_Name     IN Varchar2,
				Value_Set_Name IN Varchar2,
                                DESCRIPTION IN VARCHAR2 DEFAULT NULL,
				Lang_CODE       IN Varchar2
                        );

-- Function
--   State_Value_Set_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release State Value Set
--
-- Arguments:
--   Set_Name        - SetName
--
FUNCTION State_Value_Set_Exists(Set_Name        IN Varchar2
                        	) return Boolean;

-- Function
--   State_Value_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release State Value
--
-- Arguments:
--   Value_Name      - Value Name
--
--   Value_Set_Name  - Set Name
--
FUNCTION State_Value_Exists(	Value_Name     IN Varchar2,
				Value_Set_Name IN Varchar2
                        ) return Boolean;

-- Procedure
--   State
--
-- Purpose
--   Register a Concurrent Release State
--
-- Arguments:
--   Application     - Application Short Name
--
--   State_Name      - Period Name
--
--   User_State_Name - User Period Name
--
--   Description     - Description
--
--   Value_Name      - Value Name of initial value
--
--   Value_Set_Name  - Set Name used by this state
--
PROCEDURE       State(   	Application     IN Varchar2,
                                State_Name      IN Varchar2,
                                User_State_Name IN Varchar2,
                                Description     IN Varchar2 DEFAULT NULL,
				Value_Set_Name  IN Varchar2,
				Value_Name      IN Varchar2,
				Lang_CODE       IN Varchar2
                        );

-- Function
--   State_Exists
--
-- Purpose
--   Determine Existence of a Concurrent Release State
--
-- Arguments:
--   Application     - Application Short Name
--
--   State_Name      - Period Name
--
FUNCTION State_Exists(   	Application     IN Varchar2,
                                State_Name      IN Varchar2
                        ) return Boolean;



end FNDCP_SCH;

 

/
