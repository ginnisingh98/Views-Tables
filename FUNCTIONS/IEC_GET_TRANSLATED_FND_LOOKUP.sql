--------------------------------------------------------
--  DDL for Function IEC_GET_TRANSLATED_FND_LOOKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."IEC_GET_TRANSLATED_FND_LOOKUP" 
				   ( P_LOOKUP_CODE IN VARCHAR2
				   , P_LOOKUP_TYPE IN VARCHAR2
				   , P_LANGUAGE IN VARCHAR2
				   )
				RETURN VARCHAR2
				IS
					l_translated_string VARCHAR2(500);
				BEGIN

				SELECT MEANING
				INTO l_translated_string
				FROM  FND_LOOKUP_VALUES
				WHERE LOOKUP_CODE	= P_LOOKUP_CODE
		  		AND  LOOKUP_TYPE 	= P_LOOKUP_TYPE
		  		AND  LANGUAGE		= P_LANGUAGE
				AND  ROWNUM 		= 1;

				RETURN l_translated_string;

				END iec_get_translated_fnd_lookup;
 

/
