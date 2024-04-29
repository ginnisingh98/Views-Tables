--------------------------------------------------------
--  DDL for Package Body OKE_DTS_WSH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DTS_WSH_PKG" AS
/* $Header: OKEPWSHB.pls 120.2.12010000.2 2008/08/08 06:12:59 aveeraba ship $ */

--
--  Name          : Bill_To_Location
--  Pre-reqs      : None
--  Function      : This function returns bill_to_location_id if it is defined
--                  as party roles in the contract structure, return -9999 if
--   		    no such role defined in the contract
--
--
--  Parameters    :
--  IN            : P_Deliverable_ID            NUMBER
--
--  OUT           : None
--
--  Returns       : NUMBER
--


  FUNCTION Bill_To_Location ( P_Deliverable_ID NUMBER ) RETURN NUMBER IS

    CURSOR Line_C IS
    SELECT L.ID, DECODE(L.CLE_ID, NULL, 'T', 'S'), L.DNZ_CHR_ID
    FROM okc_k_lines_b L, oke_k_deliverables_b D
    WHERE L.ID = D.K_Line_ID
    AND D.Deliverable_ID = P_Deliverable_ID;

    CURSOR C1 ( P_ID NUMBER, p_header_id number ) IS
    SELECT C.Location_ID
    FROM okc_k_party_roles_b R, oke_cust_site_uses_v C
    WHERE R.dnz_chr_id = P_header_ID
    AND   R.Cle_ID = P_ID
    AND   R.JTOT_Object1_Code = 'OKE_BILLTO'
    AND   R.Object1_ID1 = C.ID1;

    CURSOR C2 ( P_ID NUMBER ) IS
    SELECT Cle_ID_Ascendant, Level_Sequence
    FROM okc_ancestrys
    WHERE Cle_ID = P_ID
    ORDER BY Level_Sequence desc;

    CURSOR C3 ( P_ID NUMBER ) IS
    SELECT C.Location_ID
    FROM okc_k_party_roles_b R, oke_cust_site_uses_v C
    WHERE R.dnz_Chr_ID = P_ID
    AND   R.Chr_ID = P_ID
    AND   R.JTOT_Object1_Code = 'OKE_BILLTO'
    AND   R.Object1_ID1 = C.ID1;


    L_ID NUMBER;
    L_Line_ID NUMBER;
    L_Header_ID NUMBER;
    L_Level VARCHAR2(1);
    L_Counter NUMBER := 0;

  BEGIN

    IF P_Deliverable_ID > 0 THEN

      OPEN Line_C;
      FETCH Line_C INTO L_Line_ID, L_Level, L_Header_ID;
      CLOSE Line_C;

      -- Check immediate level of roles defined

      FOR C1_Rec IN C1 ( L_Line_ID,l_header_id ) LOOP

 	L_ID := C1_Rec.Location_Id;
        L_Counter := L_Counter + 1;

      END LOOP;


      IF L_Counter = 1 THEN

        RETURN L_ID;

      ELSIF L_Counter > 1 THEN

	RETURN -9999;

      ELSE

        -- Check line position within the contract hierarchy

        IF L_Level = 'T' THEN

	  FOR C3_Rec IN C3 ( L_Header_ID ) LOOP

	    L_ID := C3_Rec.Location_Id;
    	    L_Counter := L_Counter + 1;

	  END LOOP;

          IF L_Counter = 1 THEN

            RETURN L_ID;

          ELSE

	    RETURN -9999;

	  END IF;

	ELSIF L_Level = 'S' THEN

	  FOR C2_Rec IN C2 ( L_Line_ID ) LOOP

            FOR C1_Rec IN C1 ( C2_Rec.Cle_ID_Ascendant,l_header_id ) LOOP

	      L_ID := C1_Rec.Location_Id;
	      L_Counter := L_Counter + 1;

	    END LOOP;

	    EXIT WHEN L_COUNTER = 1;

	  END LOOP;

	  IF L_COUNTER = 1 THEN

	    RETURN L_ID;

	  ELSIF L_Counter > 1 THEN

	    RETURN -9999;

	  ELSE

 	    FOR C3_Rec IN C3 ( L_Header_ID ) LOOP

	      L_ID := C3_Rec.Location_Id;
    	      L_Counter := L_Counter + 1;

	    END LOOP;

            IF L_Counter = 1 THEN

              RETURN L_ID;

            ELSE

	      RETURN -9999;

	    END IF;

	  END IF;

	END IF;

      END IF;

    END IF;

--bug 7277190
return -9999;
--bug 7277190

  EXCEPTION
    WHEN OTHERS THEN

      RETURN -9999;

  END Bill_To_Location;



END;


/
