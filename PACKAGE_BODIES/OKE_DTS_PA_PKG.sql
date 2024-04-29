--------------------------------------------------------
--  DDL for Package Body OKE_DTS_PA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DTS_PA_PKG" AS
/* $Header: OKEPDPAB.pls 115.3 2002/05/30 15:44:23 pkm ship      $ */

--
--  Name          : Event_Type_Exist
--  Pre-reqs      : None
--  Function      : This function returns boolean value for billing event
--                  types exist in OKE billing records
--
--
--  Parameters    :
--  IN            : P_Event_Type            VARCHAR2
--
--  OUT           : None
--
--  Returns       : BOOLEAN
--


  FUNCTION Event_Type_Exist ( P_Event_Type VARCHAR2 ) RETURN BOOLEAN IS

    CURSOR Event_C IS
    SELECT 'X'
    FROM oke_k_billing_events
    WHERE Bill_Event_Type = P_Event_Type;

    L_Value VARCHAR2(1);

  BEGIN

    IF P_Event_Type IS NOT NULL THEN

      OPEN Event_C;
      FETCH Event_C INTO L_Value;
      CLOSE Event_C;

      IF L_Value = 'X' THEN

        RETURN ( TRUE );

      ELSE

        RETURN ( FALSE );

      END IF;

    ELSE

      RETURN ( TRUE );

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE Event_C;
      RETURN ( TRUE );

  END Event_Type_Exist;


--
--  Name          : Project_Exist
--  Pre-reqs      : None
--  Function      : This function returns boolean value for project
--                  exist in OKE records
--
--
--  Parameters    :
--  IN            : P_Project_ID            NUMBER
--
--  OUT           : None
--
--  Returns       : BOOLEAN
--

  FUNCTION Project_Exist ( P_Project_ID NUMBER ) RETURN BOOLEAN IS

    CURSOR C1 IS
    SELECT 'X'
    FROM oke_k_deliverables_b
    WHERE Project_ID = P_Project_ID;

    CURSOR C2 IS
    SELECT 'X'
    FROM oke_k_lines
    WHERE Project_ID = P_Project_ID;

    CURSOR C3 IS
    SELECT 'X'
    FROM oke_k_headers
    WHERE Project_ID = P_Project_ID;

    CURSOR C4 IS
    SELECT 'X'
    FROM oke_k_fund_allocations
    WHERE Project_ID = P_Project_ID;

    L_Value VARCHAR2(1);

  BEGIN

    -- Check all OKE tables which contain project_id reference

    OPEN C1;
    FETCH C1 INTO L_Value;
    CLOSE C1;

    IF L_Value = 'X' THEN

      RETURN TRUE;

    ELSE

      OPEN C2;
      FETCH C2 INTO L_Value;
      CLOSE C2;

      IF L_Value = 'X' THEN

        RETURN TRUE;

      ELSE

        OPEN C3;
        FETCH C3 INTO L_Value;
        CLOSE C3;

        IF L_Value = 'X' THEN

          RETURN TRUE;

        ELSE

          OPEN C4;
	  FETCH C4 INTO L_Value;
          CLOSE C4;

          IF L_Value = 'X' THEN

            RETURN TRUE;

          ELSE

	    RETURN FALSE;

	  END IF;

        END IF;

      END IF;

    END IF;

  EXCEPTION

    WHEN OTHERS THEN

      RETURN FALSE;

  END Project_Exist;

END;


/
