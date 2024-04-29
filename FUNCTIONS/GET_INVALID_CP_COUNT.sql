--------------------------------------------------------
--  DDL for Function GET_INVALID_CP_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."GET_INVALID_CP_COUNT" 
				   ( P_PHONE_NUMBER_S1 	IN VARCHAR2
				   , P_REASON_CODE_S1	IN VARCHAR2
				   , P_PHONE_NUMBER_S2 	IN VARCHAR2
				   , P_REASON_CODE_S2	IN VARCHAR2
				   , P_PHONE_NUMBER_S3 	IN VARCHAR2
				   , P_REASON_CODE_S3	IN VARCHAR2
				   , P_PHONE_NUMBER_S4 	IN VARCHAR2
				   , P_REASON_CODE_S4	IN VARCHAR2
				   , P_PHONE_NUMBER_S5 	IN VARCHAR2
				   , P_REASON_CODE_S5	IN VARCHAR2
				   , P_PHONE_NUMBER_S6 	IN VARCHAR2
				   , P_REASON_CODE_S6	IN VARCHAR2
				   )
				RETURN NUMBER
				IS
				   l_num_invalid_cps NUMBER(5);
				BEGIN

				   	l_num_invalid_cps := 0;

					IF  (P_PHONE_NUMBER_S1 IS NOT NULL AND P_REASON_CODE_S1 IS NULL) THEN
						l_num_invalid_cps := l_num_invalid_cps + 1;
					END IF;

					IF  (P_PHONE_NUMBER_S2 IS NOT NULL AND P_REASON_CODE_S2 IS NULL) THEN
						l_num_invalid_cps := l_num_invalid_cps + 1;
					END IF;

					IF  (P_PHONE_NUMBER_S3 IS NOT NULL AND P_REASON_CODE_S3 IS NULL) THEN
						l_num_invalid_cps := l_num_invalid_cps + 1;
					END IF;

					IF  (P_PHONE_NUMBER_S4 IS NOT NULL AND P_REASON_CODE_S4 IS NULL) THEN
						l_num_invalid_cps := l_num_invalid_cps + 1;
					END IF;

					IF  (P_PHONE_NUMBER_S5 IS NOT NULL AND P_REASON_CODE_S5 IS NULL) THEN
						l_num_invalid_cps := l_num_invalid_cps + 1;
					END IF;

					IF  (P_PHONE_NUMBER_S6 IS NOT NULL AND P_REASON_CODE_S6 IS NULL) THEN
						l_num_invalid_cps := l_num_invalid_cps + 1;
					END IF;

				RETURN l_num_invalid_cps;

				END Get_Invalid_CP_Count;
 

/
