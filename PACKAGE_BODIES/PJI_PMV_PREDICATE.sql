--------------------------------------------------------
--  DDL for Package Body PJI_PMV_PREDICATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_PREDICATE" AS
/* $Header: PJIRX05B.pls 120.4 2005/11/17 16:19:48 appldev noship $ */

FUNCTION Show_Class_Code(p_Class_Code IN VARCHAR2
						, p_Class_Category IN VARCHAR2
						, p_Org_ID IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
l_Return_Value		NUMBER;
l_Security_Profile_ID	NUMBER;
l_Not_Secured_Flag	VARCHAR2(30);
BEGIN
	IF NOT (UPPER(p_Class_Category) = 'ALL' OR p_Class_Category IS NULL) THEN
		BEGIN
			IF p_Class_Category = '$PROJECT_TYPE$ALL' AND (UPPER(p_Org_ID) <> 'ALL' AND p_Org_ID IS NOT NULL) THEN
				SELECT 1
				INTO l_Return_Value
				FROM pji_class_codes pjicc
				, pa_project_types_all papta
				WHERE
				pjicc.class_id = p_Class_Code
				AND pjicc.record_type = 'T'
				AND papta.project_type= pjicc.class_code
				AND papta.org_id = p_Org_ID;
			ELSIF SUBSTR(p_Class_Category, 1, 14) = '$PROJECT_TYPE$' AND (UPPER(p_Org_ID) <> 'ALL' AND p_Org_ID IS NOT NULL) THEN
				SELECT 1
				INTO l_Return_Value
				FROM pji_class_codes pjicc
				, pa_project_types_all papta
				WHERE
				pjicc.class_id = p_Class_Code
				AND pjicc.class_category = p_Class_Category
				AND pjicc.record_type = 'T'
				AND papta.project_type_class_code= SUBSTR(p_Class_Category,15)
				AND papta.project_type= pjicc.class_code
				AND papta.org_id = p_Org_ID;
			ELSIF p_Class_Category = '$PROJECT_TYPE$ALL' THEN
				BEGIN
					l_Security_Profile_ID:=fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL');
					SELECT view_all_organizations_flag
					INTO l_Not_Secured_Flag
					FROM per_security_profiles prof
					WHERE security_profile_id = l_Security_Profile_ID;
				END;

				IF l_Not_Secured_Flag = 'Y' THEN
					SELECT 1
					INTO l_Return_Value
					FROM pji_class_codes pjicc
					, pa_project_types_all papta
					, pa_implementations_all paimp
					WHERE
					pjicc.class_id = p_Class_Code
					AND pjicc.record_type = 'T'
					AND papta.project_type= pjicc.class_code
					AND paimp.org_id = papta.org_id;
				ELSE
					SELECT 1
					INTO l_Return_Value
					FROM pji_class_codes pjicc
					, pa_project_types_all papta
					, per_organization_list sec
					, pa_implementations_all paimp
					WHERE
					pjicc.class_id = p_Class_Code
					AND pjicc.record_type = 'T'
					AND papta.project_type= pjicc.class_code
					AND papta.org_id = sec.organization_id
					AND paimp.org_id = sec.organization_id
					AND sec.security_profile_id = l_Security_Profile_ID;
				END IF;
			ELSE
				SELECT 1
				INTO l_Return_Value
				FROM pji_class_codes
				WHERE
				class_id = p_Class_Code
				AND class_category = p_Class_Category;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	END IF;
	RETURN l_Return_Value;
END;

FUNCTION Show_Currency_Type(p_Currency_Code IN VARCHAR2
						, p_Org_ID IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
l_Return_Value	NUMBER;
BEGIN
	IF p_Currency_Code = 'FII_GLOBAL1' THEN
		RETURN 1;
	ELSIF p_Currency_Code = 'FII_GLOBAL2' THEN
		RETURN 2;
	ELSIF p_Currency_Code = 'FII_GLOBAL1' THEN
		RETURN NULL;
	ELSE
		IF NOT (UPPER(p_Org_ID) = 'ALL' OR p_Org_ID IS NULL) THEN
		BEGIN
			SELECT 1
			INTO l_Return_Value
			FROM
			pa_implementations_all paimp
			, gl_sets_of_books     glsob
			WHERE
			paimp.set_of_books_id = glsob.set_of_books_id
			and paimp.org_id = p_Org_ID
			and glsob.currency_code = p_Currency_Code;

			RETURN l_Return_Value;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN NULL;
			WHEN OTHERS THEN
				RETURN NULL;
		END;
		ELSE
			RETURN NULL;
		END IF;
	END IF;
END Show_Currency_Type;

FUNCTION Show_Project(p_Project_ID IN NUMBER
                        , p_Organization_ID IN VARCHAR2
                        , p_Org_ID IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
l_Return_Value	NUMBER;
BEGIN
	IF p_Organization_ID IS NOT NULL THEN
        IF NOT (UPPER(p_Org_ID) = 'ALL' OR p_Org_ID IS NULL) THEN
            SELECT 1
            INTO l_Return_Value
            FROM pa_projects_all prj
			, pji_org_denorm pjd
            WHERE
            1=1
            AND project_id = p_Project_ID
            AND prj.carrying_out_organization_id = pjd.sub_organization_id
			AND pjd.organization_id = p_Organization_ID
            AND prj.org_id = p_Org_ID;
		ELSE
            SELECT 1
            INTO l_Return_Value
            FROM pa_projects_all prj
			, pji_org_denorm pjd
            WHERE
            1=1
            AND project_id = p_Project_ID
            AND prj.carrying_out_organization_id = pjd.sub_organization_id
			AND pjd.organization_id = p_Organization_ID;
		END IF;
		RETURN l_Return_Value;
	ELSE
		RETURN NULL;
	END IF;
END;


FUNCTION Show_Project_Type    (p_Project_ID         IN NUMBER
                             , p_Organization_ID    IN VARCHAR2
                             , p_Project_Type       IN VARCHAR2
                             , p_Org_ID             IN VARCHAR2 DEFAULT NULL)

RETURN NUMBER
IS
l_Return_Value	NUMBER;
BEGIN

	IF p_Organization_ID IS NOT NULL THEN
        IF NOT (UPPER(p_Org_ID) = 'ALL' OR p_Org_ID IS NULL) THEN

        SELECT 1 into l_Return_Value
             FROM
                  pa_projects_all prj
      			, pji_org_denorm pjd
				, (SELECT project_id
			 	FROM pji_project_classes
			 	WHERE class_category = '$PROJECT_TYPE$'||p_Project_Type) PJC
            WHERE
            1=1
            and prj.project_id = pjc.project_id
            and prj.carrying_out_organization_id = pjd.sub_organization_id
            and prj.project_id = p_Project_ID
            and pjd.organization_id = p_Organization_ID
            and prj.org_id = p_Org_ID;

         ELSE

           SELECT 1 into l_Return_Value
            FROM
                 pa_projects_all prj
     			,pji_org_denorm pjd
				, (SELECT project_id
			 	FROM pji_project_classes
			 	WHERE class_category = '$PROJECT_TYPE$'||p_Project_type) PJC
            WHERE
            1=1
            and prj.project_id = pjc.project_id
            and prj.carrying_out_organization_id = pjd.sub_organization_id
            and prj.project_id = p_Project_ID
            and pjd.organization_id = p_Organization_ID;
           END IF;
		RETURN l_Return_Value;
	ELSE
		RETURN NULL;
	END IF;
END;


FUNCTION Show_Operating_Unit(p_Org_ID IN VARCHAR2)
RETURN NUMBER
IS
l_Return_Value		NUMBER;
l_Security_Profile_ID	NUMBER;
l_Not_Secured_Flag	VARCHAR2(30);
BEGIN
	l_Security_Profile_ID:=fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL');

	IF l_Security_Profile_ID IS NOT NULL THEN
		BEGIN
			SELECT view_all_organizations_flag
			INTO l_Not_Secured_Flag
			FROM per_security_profiles prof
			WHERE security_profile_id = l_Security_Profile_ID;
			IF l_Not_Secured_Flag = 'Y' THEN
				SELECT 1
				INTO l_Return_Value
				FROM pa_implementations_all imp
				WHERE org_id = p_Org_ID;
			ELSE
				SELECT 1
				INTO l_Return_Value
				FROM
				pa_implementations_all imp
				, per_organization_list list
				WHERE
				list.security_profile_id = l_Security_Profile_ID
				AND list.organization_id = p_Org_ID
				AND imp.org_id = list.organization_id;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			NULL;
		END;
	END IF;
	RETURN l_Return_Value;
END;

END PJI_PMV_PREDICATE;

/
