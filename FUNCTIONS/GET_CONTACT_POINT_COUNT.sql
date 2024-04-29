--------------------------------------------------------
--  DDL for Function GET_CONTACT_POINT_COUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."GET_CONTACT_POINT_COUNT" 
				   ( P_PHONE_NUMBER_S1 IN VARCHAR2
				   , P_PHONE_NUMBER_S2 IN VARCHAR2
				   , P_PHONE_NUMBER_S3 IN VARCHAR2
				   , P_PHONE_NUMBER_S4 IN VARCHAR2
				   , P_PHONE_NUMBER_S5 IN VARCHAR2
				   , P_PHONE_NUMBER_S6 IN VARCHAR2
				   )
				RETURN NUMBER
				IS
				   l_num_contact_points NUMBER(5);
				BEGIN

				   	l_num_contact_points := 0;

					IF P_PHONE_NUMBER_S1 IS NOT NULL THEN
						l_num_contact_points := l_num_contact_points + 1;
					END IF;

					IF P_PHONE_NUMBER_S2 IS NOT NULL THEN
						l_num_contact_points := l_num_contact_points + 1;
					END IF;

					IF P_PHONE_NUMBER_S3 IS NOT NULL THEN
						l_num_contact_points := l_num_contact_points + 1;
					END IF;

					IF P_PHONE_NUMBER_S4 IS NOT NULL THEN
						l_num_contact_points := l_num_contact_points + 1;
					END IF;

					IF P_PHONE_NUMBER_S5 IS NOT NULL THEN
						l_num_contact_points := l_num_contact_points + 1;
					END IF;

					IF P_PHONE_NUMBER_S6 IS NOT NULL THEN
						l_num_contact_points := l_num_contact_points + 1;
					END IF;

				RETURN l_num_contact_points;

				END Get_Contact_Point_Count;
 

/
