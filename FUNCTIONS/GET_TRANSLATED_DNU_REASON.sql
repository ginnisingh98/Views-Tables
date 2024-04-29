--------------------------------------------------------
--  DDL for Function GET_TRANSLATED_DNU_REASON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."GET_TRANSLATED_DNU_REASON" (P_DNU_REASON_CODE IN VARCHAR2)
				RETURN VARCHAR2
				IS
					l_dnu_reason VARCHAR2(500);
				BEGIN

				SELECT DESCRIPTION
				INTO l_dnu_reason
				FROM  FND_LOOKUPS
				WHERE LOOKUP_TYPE 	= 'IEC_DNU_REASON'
		  		AND  LOOKUP_CODE	= P_DNU_REASON_CODE;

				RETURN l_dnu_reason;

				END Get_Translated_DNU_Reason;
 

/
