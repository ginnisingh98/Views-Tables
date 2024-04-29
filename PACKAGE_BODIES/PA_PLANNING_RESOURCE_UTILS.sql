--------------------------------------------------------
--  DDL for Package Body PA_PLANNING_RESOURCE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLANNING_RESOURCE_UTILS" AS
/* $Header: PARPRLUB.pls 120.12.12010000.5 2009/07/07 11:05:40 bifernan ship $ */

g_job_group_id NUMBER;
/********************************************************
 * Check whether any planning resources or class defaults for the spread
 * curve exist.
 *******************************************************/
FUNCTION chk_spread_curve_in_use(p_spread_curve_id IN NUMBER) return BOOLEAN
IS

CURSOR chk_if_exists IS
select 'Y'
from dual
where ((exists (select 'Y'
               from   pa_resource_list_members
               where  spread_curve_id = p_spread_curve_id))
OR     (exists (select 'Y'
               from   pa_plan_res_defaults
               where  spread_curve_id = p_spread_curve_id)));

l_exists VARCHAR2(1) := 'N';
l_return BOOLEAN := FALSE;
BEGIN
open chk_if_exists;
fetch chk_if_exists into l_exists;
IF chk_if_exists%FOUND THEN
   l_return := TRUE;
ELSE
   l_return := FALSE;
END IF;

close chk_if_exists;
RETURN l_return;

END chk_spread_curve_in_use;

/********************************************************
 * Check whether any planning resources with NLR exist
 * ******************************************************/
FUNCTION chk_nlr_resource_exists(p_non_labor_resource IN Varchar2) return
BOOLEAN
IS
CURSOR chk_nlr_resource IS
select 'Y'
from   pa_resource_list_members
where  non_labor_resource = p_non_labor_resource
and    migration_code = 'N';

l_exists VARCHAR2(1) := 'N';
l_return BOOLEAN := FALSE;
BEGIN
open chk_nlr_resource;
fetch chk_nlr_resource into l_exists;
IF chk_nlr_resource%FOUND THEN
   l_return := TRUE;
ELSE
   l_return := FALSE;
END IF;

close chk_nlr_resource;
RETURN l_return;

END chk_nlr_resource_exists;


/*******************************************************************
 * Function    : Get_res_member_code
 * Description : The purpose of this function is to return the resource
 *               code for a given resource list member id.
 *               Takes in parameter - p_resource_list_member_id
 *               Returns - l_resource_code
 *******************************************************************/
FUNCTION Get_res_member_code(p_resource_list_member_id IN NUMBER)
return VARCHAR2
IS
-- Decl of local variables
l_res_type_code  VARCHAR2(30):= NULL;
l_resource_code  VARCHAR2(30):= NULL;
BEGIN
/* The purpose of this function is to return the resource code for a
 * given planning resource.*/
	IF p_resource_list_member_id IS NOT NULL THEN
           BEGIN
           SELECT typ.res_type_code
             INTO l_res_type_code
             FROM pa_res_types_b typ,
                  pa_resource_list_members rlm,
                  pa_res_formats_b fmt
            WHERE rlm.resource_list_member_id = p_resource_list_member_id
              AND rlm.res_format_id = fmt.res_format_id
              AND fmt.res_type_enabled_flag = 'Y'
              AND fmt.res_type_id = typ.res_type_id;
           EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	         l_res_type_code := NULL;
                 RETURN NULL;
           END;

           IF l_res_type_code IS NOT NULL THEN
	      Select DECODE(incurred_by_res_flag, 'Y','',
	           DECODE(l_res_type_code,
	           'NAMED_PERSON',to_char(person_id),
                   'PERSON_TYPE', person_type_code,
                   'JOB', to_char(job_id),
                   'BOM_LABOR', to_char(bom_resource_id),
                   'RESOURCE_CLASS',resource_class_code,
                   'NON_LABOR_RESOURCE',non_labor_resource,
                   'BOM_EQUIPMENT',to_char(bom_resource_id),
                   'INVENTORY_ITEM',to_char(inventory_item_id),
                   'ITEM_CATEGORY',to_char(item_category_id)))
               INTO l_resource_code
               FROM pa_resource_list_members
               WHERE resource_list_member_id = p_resource_list_member_id;

               Return l_resource_code;
           ELSE
              Return Null;
           END IF;
        ELSE
              Return Null;
        END IF;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
	Return l_resource_code;
 WHEN OTHERS THEN
	Return Null;
END Get_res_member_code;
/*************************************/
/*****************************************************************
 * Function    : Get_member_Fin_Cat_Code
 * Description : The purpose of this function is to return the Financial
 *               category code for a given planning resource.
 *               Takes in Parameter - p_resource_member_id
 *               Returns - l_fin_category_code
 *******************************************************************/
FUNCTION Get_member_Fin_Cat_Code(p_resource_list_member_id IN NUMBER) return
VARCHAR2
IS
l_fin_category_code  pa_resource_list_members.FC_RES_TYPE_CODE%TYPE := NULL;
BEGIN
	IF p_resource_list_member_id IS NOT NULL THEN
		SELECT DECODE(fc_res_type_code,
		'EXPENDITURE_TYPE',expenditure_type,
		'EXPENDITURE_CATEGORY',expenditure_category,
		'EVENT_TYPE',event_type,
		'REVENUE_CATEGORY',revenue_category)
		INTO l_fin_category_code
		FROM  pa_resource_list_members
		WHERE RESOURCE_LIST_MEMBER_ID = p_resource_list_member_id;

		Return l_fin_category_code;
	ELSE
                Return Null;
        END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
	Return l_fin_category_code;
   WHEN OTHERS THEN
	Return Null;
END Get_member_Fin_Cat_Code;
/***********************************/
/***********************************************************************
 * Function    : Get_member_incur_by_res_code
 * Description : The purpose of this function is to return the incurred by
 *               resource code for a given resource_list member.
 *               Takes in parameter - p_resource_list_member_id
 *               Returns - l_incur_by_res_code
 ***********************************************************************/
FUNCTION Get_member_Incur_by_Res_Code(p_resource_list_member_id IN NUMBER)
  return VARCHAR2
IS
--Decl of Local Var
l_incur_by_res_code VARCHAR2(30) := NULL;
BEGIN
  IF p_resource_list_member_id IS NOT NULL THEN
		SELECT DECODE(incurred_by_res_flag,'N','',
		nvl(to_char(person_id),nvl(to_char(job_id),
                nvl(person_type_code,
                    nvl(to_char(incur_by_role_id),
                    nvl(incur_by_res_class_code, 'ERROR'))))))
		INTO l_incur_by_res_code
		FROM pa_resource_list_members
		WHERE resource_list_member_id = p_resource_list_member_id;

                Return l_incur_by_res_code;
   ELSE
               Return NULL;
   END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
	Return l_incur_by_res_code;
WHEN OTHERS THEN
	Return null;
END Get_member_Incur_By_Res_Code;
/****************************************************************/
/**************************************************************
 * FUNCTION : Get_res_type_code
 *************************************************************/
 FUNCTION Get_res_type_code(p_res_format_id IN NUMBER)
 RETURN VARCHAR2
 IS
 l_res_type_code  pa_res_types_b.RES_TYPE_CODE%TYPE := null;
 BEGIN
    IF p_res_format_id IS NOT NULL THEN
      SELECT b.res_type_code
      INTO l_res_type_code
      FROM pa_res_formats_b a, pa_res_types_b b
      WHERE a.RES_TYPE_ID = b.RES_TYPE_ID
      AND a.RES_TYPE_ENABLED_FLAG = 'Y'
      AND a.res_format_id = p_res_format_id;
      Return l_res_type_code;
  ELSE
      Return Null;
  END IF;
 EXCEPTION
 WHEN OTHERS THEN
     Return Null;
 END Get_res_type_code;

/*******************************************************************
 * Function    : Get_Resource_Code
 * Description : The purpose of this function is to return the resource
 *               code for a given resource assignment.
 *               Takes in parameter - p_resource_assignment_id
 *               Returns - l_resource_code
 *******************************************************************/
FUNCTION Get_resource_Code(p_resource_assignment_id IN NUMBER) return VARCHAR2
IS
-- Decl of local variables
l_resource_code  pa_resource_assignments.res_type_code%TYPE := NULL;
BEGIN
/* The purpose of this function is to return the resource code for a given resource assignment.*/
	IF p_resource_assignment_id IS NOT NULL THEN
	      Select DECODE(incurred_by_res_flag, 'Y','',
	           DECODE(res_type_code,
	           'NAMED_PERSON',to_char(person_id),
                   'PERSON_TYPE', person_type_code,
                   'JOB', to_char(job_id),
                   'BOM_LABOR', to_char(bom_resource_id),
                   'RESOURCE_CLASS',resource_class_code,
                   'NON_LABOR_RESOURCE',non_labor_resource,
                   'BOM_EQUIPMENT',to_char(bom_resource_id),
                   'INVENTORY_ITEM',to_char(inventory_item_id),
                   'ITEM_CATEGORY',to_char(item_category_id)))
               INTO l_resource_code
               FROM pa_resource_assignments
               WHERE resource_assignment_id = p_resource_assignment_id;

               Return l_resource_code;
        ELSE
              Return Null;
END IF;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
	Return l_resource_code;
 WHEN OTHERS THEN
	Return Null;
END Get_resource_Code;
/*********************************************************************/

/***********************************************************************
 * Function    : Get_Incur_By_Res_Code
 * Description : The purpose of this function is to return the incurred by
 *               resource code for a given resource assignment.
 *               Takes in parameter - p_resource_assignment_id
 *               Returns - l_incur_by_res_code
 ***********************************************************************/

FUNCTION Get_Incur_by_Res_Code(p_resource_assignment_id IN NUMBER)
  return VARCHAR2
IS
--Decl of Local Var
l_incur_by_res_code VARCHAR2(30) := NULL;
BEGIN
  IF p_resource_assignment_id IS NOT NULL THEN
		SELECT DECODE(incurred_by_res_flag,'N','',
		nvl(to_char(person_id),nvl(to_char(job_id), nvl(person_type_code,
                    nvl(to_char(incur_by_role_id),
                    nvl(incur_by_res_class_code, NULL))))))
		INTO l_incur_by_res_code
		FROM pa_resource_assignments
		WHERE resource_assignment_id = p_resource_assignment_id;

                Return l_incur_by_res_code;
   ELSE
               Return NULL;
   END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
	Return l_incur_by_res_code;
WHEN OTHERS THEN
	Return null;
END Get_Incur_By_Res_Code;
/****************************************************************/

/*****************************************************************
 * Function    : Get_Fin_Category_Code
 * Description : The purpose of this function is to return the Financial
 *               category code for a given resource assignment.
 *               Takes in Parameter - p_resource_assignment_id
 *               Returns - l_fin_category_code
 *******************************************************************/
FUNCTION Get_Fin_Category_Code(p_resource_assignment_id IN NUMBER) return
VARCHAR2
IS
l_fin_category_code  pa_resource_assignments.FC_RES_TYPE_CODE%TYPE := NULL;
BEGIN
	IF p_resource_assignment_id IS NOT NULL THEN
		SELECT DECODE(fc_res_type_code,
		'EXPENDITURE_TYPE',expenditure_type,
		'EXPENDITURE_CATEGORY',expenditure_category,
		'EVENT_TYPE',event_type,
		'REVENUE_CATEGORY',revenue_category_code)
		INTO l_fin_category_code
		FROM  pa_resource_assignments
		WHERE resource_assignment_id = p_resource_assignment_id;

		Return l_fin_category_code;
	ELSE
                Return Null;
        END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
	Return l_fin_category_code;
   WHEN OTHERS THEN
	Return Null;
END Get_Fin_Category_Code;
/**********************************************************************/

/****************************************************************************
 * Procedure   : Validate_Organization
 * Description : This procedure validates the organization for a
 *               planning. It first validates the name and id,  of
 *               the organization and then checks if the organization
 *               is an expenditure organization or a project owning
 *               organization.
 *               The organization on a planning resource can
 *               be an expenditure organization since the resource
 *               could be a person.
 *               The organization on the planning resource can be a project
 *               owning organization since the resource could an expense which
 *               is incurred by the project organization.
 *               Hence, we are checking for both.
 * Called By   :
 * Calls Prog  : PA_HR_ORG_UTILS.Check_OrgName_Or_Id
*****************************************************************************/
PROCEDURE Validate_Organization
            (p_organization_name	IN 	VARCHAR2,
             p_organization_id		IN	NUMBER,
             x_organization_id		OUT NOCOPY	NUMBER,
             x_return_status		OUT NOCOPY	VARCHAR2,
             x_error_msg_code   	OUT NOCOPY	VARCHAR2)
IS
--Declaration of Local variables
--  l_return_status            VARCHAR2(1);
  l_organization_id                   NUMBER := null;
-- l_error_msg_data           fnd_new_messages.message_name%TYPE;
BEGIN
        x_return_status  := FND_API.G_RET_STS_SUCCESS;
        x_error_msg_code := Null;
-- validate the organization and assign the id to the global record.
/*****************************************************************
 * We are going to make use of an existing procedure
 * PA_HR_ORG_UTILS.Check_OrgName_Or_Id, which will take in the
 * Organization ID and organization name and will check for null
 * for either of the fields and will accordingly derive the Organization_id.
 ********************************************************************/
  IF (p_organization_id IS NOT NULL) OR
     ( p_organization_name IS NOT NULL)
  THEN
        PA_HR_ORG_UTILS.Check_OrgName_Or_Id(
                    p_organization_id,
                    p_organization_name,
                    PA_STARTUP.G_Check_ID_Flag,
                    l_organization_id,
                    x_return_status,
                    x_error_msg_code);

/*******************************************************************
 * If the call to the procedure Check_OrgName_Or_Id, returns an error then
 * call the package PA_UTILS and pass the error message.
 ********************************************************************/
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF x_error_msg_code = 'PA_INVALID_ORG' THEN
     	      PA_UTILS.Add_Message('PA', 'PA_INVALID_ORG_PLAN_RES', 'PLAN_RES',
                                   Pa_Planning_Resource_Pvt.g_token);
              Return;
           ELSIF x_error_msg_code = 'PA_ORG_NOT_UNIQUE' THEN
              PA_UTILS.Add_Message('PA', 'PA_ORG_NOT_UNIQUE_PLAN_RES',
                                   'PLAN_RES',Pa_Planning_Resource_Pvt.g_token);
              Return;
           ELSE
              Return;
           END IF;
        END IF;
/*******************************************************************
 * If the call to the procedure Check_OrgName_Or_Id, completes successfully,
 * then we need validate that the organization is a valid expenditure and
 * project organization in the system.
 ***********************************************************************/
               BEGIN
	       	    SELECT distinct  ORGANIZATION_ID
                    INTO x_organization_id
                    FROM pa_all_organizations
                    WHERE INACTIVE_DATE IS NULL
                    AND PA_ORG_USE_TYPE in ('EXPENDITURES', 'PROJECTS')
                    AND   ORGANIZATION_ID = l_organization_id;
              EXCEPTION
              WHEN OTHERS THEN
                    x_organization_id := NULL;
                    x_return_status:= FND_API.G_RET_STS_ERROR;
                    x_error_msg_code:= 'PA_ORG_INVALID_PROJ_EXP';
                    /*  We will be adding a new message which reads
                     Organization is an Invalid Expenditure or Project
                     Organization.*/
                    PA_UTILS.Add_Message('PA', x_error_msg_code, 'PLAN_RES',
                                         Pa_Planning_Resource_Pvt.g_token);
                    Return;
              END;

  END IF;

END VALIDATE_ORGANIZATION;
/*******************************************************************/

/************************************************************************
 *   Procedure        : Check_SupplierName_Or_Id
 *   Description      : This Subprog validates the supplier name
 *                      and ID combination
 *********************************************************************/

PROCEDURE Check_SupplierName_Or_Id
            ( p_supplier_id            IN      NUMBER
             ,p_supplier_name          IN      VARCHAR2
             ,p_check_id_flag          IN      VARCHAR2
             ,x_supplier_id            OUT NOCOPY     NUMBER
             ,x_return_status          OUT NOCOPY     VARCHAR2
             ,x_error_msg_code         OUT NOCOPY     VARCHAR2 ) IS

      l_current_id         NUMBER := NULL;
      l_num_ids            NUMBER := 0;
      l_id_found_flag      VARCHAR(1) := 'N';

       CURSOR c_ids IS
       SELECT vendor_id
       FROM po_vendors
       WHERE vendor_name  = p_supplier_name;
BEGIN
IF (p_supplier_id IS NOT NULL)
THEN
  IF (p_check_id_flag = 'Y') THEN
     BEGIN
       	SELECT vendor_id
	INTO x_supplier_id
	FROM PO_Vendors
	WHERE vendor_id = p_supplier_id;
     EXCEPTION
     WHEN OTHERS THEN
         x_supplier_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
	--Need to get a proper message
         x_error_msg_code:= 'PA_INVALID_SUPPLIER';
        RETURN;
      END;
  ELSIF (p_check_id_flag='N') THEN
            x_supplier_id := p_supplier_id;
  ELSIF (p_check_id_flag = 'A') THEN
/******************************************************************
 * The Check_id_flag of 'A' indicates that this validation is coming from Java
 * front end, and hence the Id and Name Combination needs to be
 * validated in the database.
 * *****************************************************************/
       IF (p_supplier_name IS NULL) THEN
             -- Return a null ID since the name is null.
       	     x_supplier_id := NULL;
       ELSE
            OPEN c_ids;
              LOOP
                FETCH c_ids INTO l_current_id;
                EXIT WHEN c_ids%NOTFOUND;
                IF (l_current_id = p_supplier_id) THEN
                      l_id_found_flag := 'Y';
                      x_supplier_id := p_supplier_id;
                 END IF;
               END LOOP;
	       l_num_ids := c_ids%ROWCOUNT;
            CLOSE c_ids;

             IF (l_num_ids = 0) THEN
                 -- No IDs for name
                 RAISE NO_DATA_FOUND;
             ELSIF (l_num_ids = 1) THEN
                 -- Since there is only one ID for the name use it.
                 x_supplier_id := l_current_id;
             ELSIF (l_num_ids > 1) THEN
                 --More than one ID for the name
                   RAISE TOO_MANY_ROWS;
              END IF;
       END IF;
  ELSE
	x_supplier_id := NULL;
  END IF;
ELSE
        IF (p_supplier_name IS NOT NULL) THEN
  	  BEGIN
            SELECT vendor_id
            INTO x_supplier_id
            FROM po_vendors
            WHERE vendor_name  = p_supplier_name;
          EXCEPTION
          WHEN OTHERS THEN
              x_supplier_id := NULL;
              x_return_status:= FND_API.G_RET_STS_ERROR;
       	      --Need to get a proper message
              x_error_msg_code:= 'PA_INVALID_SUPPLIER_NAME';
             Return;
	  END;
        ELSE
          x_supplier_id := NULL;
        END IF;
END IF;
       x_return_status:= FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OTHERS THEN
         x_supplier_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
          --Need to get a proper message
         x_error_msg_code:= 'PA_INVALID_SUPPLIER';
         RETURN;
END Check_SupplierName_Or_Id;
/******************************************************************
 * Procedure   : Validate Supplier
 * Description : The Purpose of this procedure is to Validate if the
 *               Supplier is valid in the system or not. Validation done
 *               as follows:-
 *               1. If the Resource_class_code passed as IN parameter = 'PEOPLE'
 *               Then we call sub-Function Is_Contingent_Worker which checks if
 *               the person is a contingent worker. if not then an error message
 *               is displayed.
 *               2. Next the Supplier ID/Name validity check needs to be done
 *               Hence the main prog calls subprog Check_SupplierName_Or_Id
 *               to do the check.
 **********************************************************************/
PROCEDURE Validate_Supplier(
         p_resource_class_code  	IN	  VARCHAR2,
         p_person_id	        	IN        NUMBER,
         p_supplier_id		        IN	  NUMBER    DEFAULT NULL,
         p_supplier_name		IN	  VARCHAR2  DEFAULT NULL,
         x_supplier_id		        OUT NOCOPY	  NUMBER,
         x_return_status		OUT NOCOPY	  VARCHAR2,
         x_error_msg_code	        OUT NOCOPY	  VARCHAR2)

IS
      l_return_status      VARCHAR2(1);
      l_error_msg_code     fnd_new_messages.message_name%TYPE;
      l_supplier_id        PO_VENDORS.vendor_id%TYPE := NULL;
      l_err_status         VARCHAR2(30) := 'N';
/************************************************************************
 * Sub-function    : Is_Contingent_Worker
 * Description     : This Subprog checks if the resource is a contingent
 *                 worker or not, If it is a contingent worker Then
 *                 then it returns 'Y' Else returns 'N'.  To Check
 *                 for Contingent worker we are directly looking it up
 *                 from the per_people_x view as it filters those where
 *                 sysdate between effective start and end date.
 *                 Also checks to see if the current_npw_flag = 'Y'
 ************************************************************************/
Function Is_Contingent_Worker(p_person_id  IN VARCHAR2) Return VARCHAR2
IS
   l_cwk_flag     VARCHAR2(30) := null;
BEGIN
	SELECT 'Y'
        INTO l_cwk_flag
        --FROM per_people_x
        FROM per_all_people_f
	WHERE person_id = p_person_id
        AND current_npw_flag = 'Y'
        AND trunc(sysdate) between trunc(effective_start_date) AND
        trunc(effective_end_date);

	Return l_cwk_flag;
EXCEPTION
WHEN OTHERS THEN
	-- This status will indicate not a contingent worker.
	Return 'N';
END Is_Contingent_Worker;
/*******************/

/************************************
 *         Main Body                *
 ************************************/

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_resource_class_code = 'PEOPLE'  and p_person_id IS NOT NULL THEN
    /* If the p_resource_class_code is 'People' then we need to check if
         * the resource is a contingent
         * worker. This is done by call to the subprog Check_contingent which
         * will return the status. */
	 IF Is_Contingent_Worker(p_person_id) = 'N' THEN
		x_supplier_id := NULL;
                l_err_status := 'Y';
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_msg_code:= 'PA_IS_NOT_CONTINGENT';
                PA_UTILS.Add_Message('PA', x_error_msg_code, 'PLAN_RES',
                                     Pa_Planning_Resource_Pvt.g_token);
               Return;
	 END IF;
    END IF;

IF p_resource_class_code <> 'PEOPLE' OR
                          l_err_status = 'N'
THEN
      IF (p_supplier_id IS NOT NULL) OR
         (p_supplier_name IS NOT NULL)
      THEN
-- dbms_output.put_line('- IN Validate Supp ');
      /* We call the Procedure Check_SupplierName_Or_Id to validate the
      * Supplier ID and Name combination. */
            Check_SupplierName_Or_Id(
            p_supplier_id,
            p_supplier_name,
            PA_STARTUP.G_Check_ID_Flag,
            l_supplier_id,
            l_return_status,
            l_error_msg_code);

-- dbms_output.put_line('- After Check_SupplierName_Or_Id p_supplier_name IS : '|| p_supplier_name);
-- dbms_output.put_line('- After Check_SupplierName_Or_Id p_supplier_id IS : '|| p_supplier_id);
-- dbms_output.put_line('- After Check_SupplierName_Or_Id l_supplier_id IS : '|| l_supplier_id);
-- dbms_output.put_line('- After Check_SupplierName_Or_Id l_return_status IS : '|| l_return_status);
            x_supplier_id    := l_supplier_id;
            x_return_status  := l_return_status;
            x_error_msg_code := l_error_msg_code;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               PA_UTILS.Add_Message('PA', l_error_msg_code, 'PLAN_RES',
                                     Pa_Planning_Resource_Pvt.g_token);
               Return;
            END IF;
        ELSE
            x_supplier_id := NULL;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_msg_code:= 'PA_PLN_RL_NO_SUPPLIER';
            PA_UTILS.Add_Message('PA', x_error_msg_code, 'PLAN_RES',
                                 Pa_Planning_Resource_Pvt.g_token);
            Return;
        END IF;
 END IF;
END Validate_Supplier;
/************************************************************************/

/*******************************
 *  Procedure : Check_PersonName_or_ID
 * Description  : Used to validate the Person ID
 *                Name combination.
 ************************************/
PROCEDURE  Check_PersonName_or_ID(
               p_person_id      IN   VARCHAR2,
               p_person_name    IN   VARCHAR2,
               p_check_id_flag  IN   VARCHAR2,
               x_person_id      OUT NOCOPY  NUMBER,
               x_return_status  OUT NOCOPY  VARCHAR2,
               x_error_msg_code OUT NOCOPY  VARCHAR2)
IS
 l_current_id     NUMBER   := NULL;
 l_person_id      NUMBER;
 l_num_ids        NUMBER   := 0;

/****************************************************
 * Bug  - 3523947
 * Desc - Modified the cursor c_ids. Removed the check
 *        where sysdate between eff start and end date.
 *        And selecting from per_people_x to keep it
 *        consistent with the other selects.
 ***************************************************/
 Cursor c_ids IS
    SELECT person_id
    --FROM per_all_people_f
    FROM per_people_x
    WHERE full_name = p_person_name;
    --AND trunc(sysdate) between trunc(effective_start_date) AND
    --trunc(effective_end_date);
BEGIN
  x_return_status:= FND_API.G_RET_STS_SUCCESS;
IF (p_person_id IS NOT NULL)
THEN
    IF (p_check_id_flag = 'Y') THEN
	BEGIN
       	    SELECT person_id
	    INTO l_person_id
	    FROM per_people_x
	    WHERE person_id = p_person_id;
            x_person_id := l_person_id;
	EXCEPTION
	WHEN OTHERS THEN
            x_person_id := NULL;
            x_return_status:= FND_API.G_RET_STS_ERROR;
      	   --Need to get a proper message
            x_error_msg_code:= 'PA_INVALID_PERSON_ID';
            Return;
         END;
      ELSIF (p_check_id_flag='N') THEN
            l_person_id := p_person_id;
            x_person_id := l_person_id;
      ELSIF (p_check_id_flag = 'A') THEN
 /******************************************************
 * The Check_id_flag of 'A' indicates that this validation is
 * coming from Java front end, and hence the id and Name combination
 * needs to be validated in the database.
 * ****************************************************/
          IF (p_person_name IS NULL) THEN
               -- Return a null ID since the name is
               x_person_id := NULL;
               l_person_id := NULL;
           ELSE
                OPEN c_ids;
                  LOOP
                    FETCH c_ids INTO l_current_id;
                    EXIT WHEN c_ids%NOTFOUND;
                      IF (l_current_id = p_person_id) THEN
                               l_person_id := p_person_id;
                               x_person_id := l_person_id;
                       END IF;
                   END LOOP;
                   l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                      -- Since there is only one ID for the name use it.
                      l_person_id := l_current_id;
                      x_person_id := l_person_id;
                 ELSIF (l_num_ids > 1) THEN
                      --More than one ID for the Name
                      RAISE TOO_MANY_ROWS;
                  END IF;
            END IF;
    ELSE
	l_person_id := NULL;
        x_person_id := l_person_id;
    END IF;
ELSE
     IF (p_person_name IS NOT NULL) THEN
       	 BEGIN
             SELECT person_id
             INTO l_person_id
             FROM per_people_x
             WHERE full_name = p_person_name;
             x_person_id := l_person_id;
          EXCEPTION
          WHEN OTHERS THEN
              x_person_id := NULL;
              x_return_status:= FND_API.G_RET_STS_ERROR;
 	           --Need to get a proper message
              x_error_msg_code:= 'PA_INVALID_PERSON_NAME';
              Return;
	    END;
      ELSE
          l_person_id := NULL;
          x_person_id := l_person_id;
      END IF;
END IF;
/***************************************************
 * This Select has been moved from the Main Body to this
 * Procedure. As any other Prog's calling the Check_
 * PersonName_or_id check would need this cond to be present.
 * *****************************************************/
/******************************************************
 * Bug - 3523947
 * Desc - Modified the below select. We no longer need the
 *        check where sysdate between effective start and
 *        end date.
 *****************************************************/
     BEGIN
         SELECT person_id
         INTO x_person_id
         FROM per_all_people_f per
         WHERE
         --sysdate BETWEEN effective_start_date AND effective_end_date
         (current_employee_flag = 'Y' or CURRENT_NPW_FLAG = 'Y')
         AND   ((PA_CROSS_BUSINESS_GRP.IsCrossBGProfile = 'Y') OR
               ((PA_CROSS_BUSINESS_GRP.IsCrossBGProfile = 'N') AND
                 fnd_profile.value('PER_BUSINESS_GROUP_ID') =
                 BUSINESS_GROUP_ID))
         AND person_id = l_person_id
         and rownum = 1;
     EXCEPTION
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          --Need to get message for this.
          x_error_msg_code:= 'PA_INVALID_PERSON_ID';
          PA_UTILS.Add_Message('PA', x_error_msg_code, 'PLAN_RES',
                               Pa_Planning_Resource_Pvt.g_token);
          Return;
     END;

        x_return_status:= FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN
         x_person_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
          --Need to get a proper message
         x_error_msg_code:= 'PA_INVALID_PERSON_ID';
         Return;
END Check_PersonName_Or_Id;
/***************************/

/*******************************
 *  * Procedure : Check_JobName_or_ID
 *  * Description  : Used to validate the Job ID
 *  *                Name combination. -- NOT USED ANYMORE
 *  *******************************************/
PROCEDURE  Check_JobName_or_ID(
               p_job_id  IN   VARCHAR2,
               p_job_name  IN   VARCHAR2,
               p_check_id_flag  IN   VARCHAR2,
               x_job_id      OUT NOCOPY  NUMBER,
               x_return_status  OUT NOCOPY  VARCHAR2,
               x_error_msg_code OUT NOCOPY  VARCHAR2)
IS
BEGIN
NULL;
END Check_JobName_or_ID;

/*******************************
 * Procedure : Check_JG_JobName_or_ID
 * Description  : Used to validate the Job ID
 *                Name combination in the context of Job Group.
 *******************************************/
PROCEDURE  Check_JG_JobName_or_ID(
               p_job_id         IN   NUMBER,
               p_job_name       IN   VARCHAR2,
	       p_job_group_id   IN   NUMBER,
               p_check_id_flag  IN   VARCHAR2,
               x_job_id         OUT NOCOPY  NUMBER,
               x_return_status  OUT NOCOPY  VARCHAR2,
               x_error_msg_code OUT NOCOPY  VARCHAR2)
IS
 l_current_id     NUMBER   := NULL;
 l_num_ids        NUMBER   := 0;

    Cursor c_ids IS
    SELECT job_id
    FROM per_jobs
    WHERE name = p_job_name
    AND job_group_id = p_job_group_id;
BEGIN
    x_return_status:= FND_API.G_RET_STS_SUCCESS;
--4461039 : Added check for p_job_group_id
IF p_job_group_id IS NULL THEN
	x_job_id := NULL;
        x_return_status:= FND_API.G_RET_STS_ERROR;
        x_error_msg_code:= 'PA_PL_RES_INVALID_JOB_GROUP';
        Return;
END IF;

IF (p_job_id IS NOT NULL)
THEN
    -- Added for bug 4025261 - need to ensure the given job_id is
    -- in the job group even if check_id_flag is N.
    IF (p_check_id_flag = 'Y' OR p_check_id_flag='N') THEN
	BEGIN
       	    SELECT job_id
	    INTO x_job_id
       	    FROM per_jobs
	    WHERE job_id = p_job_id
            AND job_group_id = p_job_group_id;
	EXCEPTION
	WHEN OTHERS THEN
             x_job_id := NULL;
             x_return_status:= FND_API.G_RET_STS_ERROR;
          	--Need to get a proper message
             x_error_msg_code:= 'PA_INVALID_JOB_ID';
              Return;
         END;
      -- ELSIF (p_check_id_flag='N') THEN
            -- x_job_id := p_job_id;
      ELSIF (p_check_id_flag = 'A') THEN
      /******************************************************
      * The Check_id_flag of 'A' indicates that this validation is
      * coming from Java front end,
      * and hence the Id and Name combination needs to be validated
      * in the database.
      *******************************************************/
          IF (p_job_name IS NULL) THEN
              -- Return a null ID since the name is
              x_job_id := NULL;
          ELSE
            OPEN c_ids;
               LOOP
                  FETCH c_ids INTO l_current_id;
                  EXIT WHEN c_ids%NOTFOUND;
                    IF (l_current_id = p_job_id) THEN
                         x_job_id := p_job_id;
                     END IF;
                END LOOP;
                l_num_ids := c_ids%ROWCOUNT;
            CLOSE c_ids;

            IF (l_num_ids = 0) THEN
                -- No IDs for name
                RAISE NO_DATA_FOUND;
            ELSIF (l_num_ids = 1) THEN
                   -- Since there is only one ID for the name use it.
                   x_job_id := l_current_id;
            ELSIF (l_num_ids > 1) THEN
                   --More than one ID for the Name
                    RAISE TOO_MANY_ROWS;
            END IF;
                              END IF;
          ELSE
		x_job_id := NULL;
	  END IF;
   ELSE
       IF (p_job_name IS NOT NULL) THEN
       	  BEGIN
             SELECT job_id
             INTO x_job_id
             FROM per_jobs
             WHERE name  = p_job_name
             AND job_group_id = p_job_group_id;
          EXCEPTION
          WHEN OTHERS THEN
                x_job_id := NULL;
                x_return_status:= FND_API.G_RET_STS_ERROR;
 	             --Need to get a proper message
                x_error_msg_code:= 'PA_INVALID_JOB_NAME';
                Return;
	    END;
        ELSE
             x_job_id := NULL;
        END IF;
END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;

EXCEPTION
       WHEN OTHERS THEN
           x_job_id := NULL;
           x_return_status:= FND_API.G_RET_STS_ERROR;
           --Need to get a proper message
           x_error_msg_code:= 'PA_INVALID_JOB';
           Return;
END Check_JG_JobName_Or_Id;
/**********************************/
/********************************************
 * Procedure : Check_BOM_EqLabor_or_ID
 * Description : This Procedure can be called
 *            when the res_type_code is 'BOM_LABOR'
 *            or 'BOM_EQUIPMENT'(determined by the p_res_type_code)
 *            It validates the p_bom_eqlabor_id and p_bom_eqlabor_name
 *            and returns the x_bom_resource_id.
*******************************************/
PROCEDURE Check_BOM_EqLabor_or_ID
              ( p_bom_eqlabor_id         IN       NUMBER
              , p_bom_eqlabor_name       IN       VARCHAR2
	      , p_res_type_code	         IN       VARCHAR2
              , p_check_id_flag          IN       VARCHAR2
              , x_bom_resource_id        OUT NOCOPY      NUMBER
              , x_return_status          OUT NOCOPY      VARCHAR2
              , x_error_msg_code     OUT NOCOPY      VARCHAR2 )
 IS
   l_current_id                  NUMBER := NULL;
   l_num_ids                     NUMBER := 0;
   l_id_found_flag               VARCHAR(1) := 'N';
   l_return_status 	         VARCHAR2(1);
   l_error_msg_data              fnd_new_messages.message_name%TYPE;

CURSOR c_ids IS
SELECT b.resource_id
FROM bom_resources b
WHERE b.resource_type = p_res_type_code
and NVL(b.disable_date,SYSDATE) >= SYSDATE
and b.expenditure_type is NOT NULL
and b.resource_code = p_bom_eqlabor_name;

BEGIN
  x_return_status:= FND_API.G_RET_STS_SUCCESS;


 IF(p_bom_eqlabor_id IS NOT NULL)
  THEN

	IF (p_check_id_flag = 'Y') THEN

	     BEGIN
	     	SELECT b.resource_id
		INTO x_bom_resource_id
                FROM bom_resources b
                WHERE b.resource_type = p_res_type_code
                AND nvl(b.disable_date,SYSDATE) >= SYSDATE
                AND b.expenditure_type IS NOT NULL
                AND b.resource_id = p_bom_eqlabor_id;

	     EXCEPTION
	     WHEN OTHERS THEN

                 x_bom_resource_id := NULL;
                 x_return_status:= FND_API.G_RET_STS_ERROR;
	         --Need to get a proper message
                 x_error_msg_code:= 'PA_INVALID_BOM_ID';
                -- RAISE; --commented for bug 3947006
		Return ;
              END;
  ELSIF (p_check_id_flag='N') THEN

            x_bom_resource_id := p_bom_eqlabor_id;
  ELSIF (p_check_id_flag = 'A') THEN

/*********************************************************
 * The Check_id_flag of 'A' indicates that this validation is
 * coming from Java front end and hence the ID and name combination
 * needs to be validated in the database.
 * *************************************************/

      IF (p_bom_eqlabor_name IS NULL) THEN
           -- Return a null ID since the name is null.
          x_bom_resource_id := NULL;
      ELSE
           OPEN c_ids;
             LOOP
                FETCH c_ids INTO l_current_id;
                EXIT WHEN c_ids%NOTFOUND;
                IF (l_current_id = p_bom_eqlabor_id) THEN
                       l_id_found_flag := 'Y';
                       x_bom_resource_id := p_bom_eqlabor_id;
                 END IF;
               END LOOP;
	              l_num_ids := c_ids%ROWCOUNT;
           CLOSE c_ids;

           IF (l_num_ids = 0) THEN
                -- No IDs for name
                RAISE NO_DATA_FOUND;
           ELSIF (l_num_ids = 1) THEN
                 -- Since there is only one ID for the name use it.
                 x_bom_resource_id := l_current_id;
           ELSIF (l_num_ids > 1) THEN
                 --More than one ID for Name
                 RAISE TOO_MANY_ROWS;
            END IF;
      END IF;
    ELSE
 	  x_bom_resource_id := NULL;
    END IF;
ELSE

    IF (p_bom_eqlabor_name  IS NOT NULL) THEN

  	BEGIN
	   SELECT b.resource_id
           INTO x_bom_resource_id
           FROM bom_resources b
           WHERE b.resource_type = p_res_type_code --2
           AND NVL(b.disable_date,SYSDATE) >= SYSDATE
           AND b.expenditure_type IS NOT NULL
           AND b.resource_code = p_bom_eqlabor_name;
         EXCEPTION
         WHEN OTHERS THEN
              x_bom_resource_id := NULL;
              x_return_status:= FND_API.G_RET_STS_ERROR;
 	      --Need to get a proper message
              x_error_msg_code:= 'PA_INVALID_BOM_NAME';
              --RAISE; --commented for bug 3817916
              Return;--Added for bug 3817916
	END;
     ELSE
          x_bom_resource_id := NULL;
     END IF;
END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
EXCEPTION
       WHEN OTHERS THEN
         x_bom_resource_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
          --Need to get a proper message
         x_error_msg_code:= 'PA_INVALID_BOM_ID';
                       RAISE;
END Check_BOM_EqLabor_or_ID;
/*******************************/
/********************************************
 * Procedure   : Check_ItemCat_or_ID
 * Description : This Procedure can be called
 *            when the res_type_code is 'ITEM_CATEGORY'
 *            It validates the p_item_cat_id and p_item_cat_name
 *            and returns the x_item_category_id.
*******************************************/
PROCEDURE Check_ItemCat_or_ID
          ( p_item_cat_id               IN        NUMBER
           ,p_item_cat_name             IN        VARCHAR2
           , P_item_category_set_id 	IN        NUMBER
           , p_check_id_flag            IN        VARCHAR2
           , x_item_category_id         OUT NOCOPY       NUMBER
           , x_return_status            OUT NOCOPY       VARCHAR2
           , x_error_msg_code       OUT NOCOPY       VARCHAR2 )
 IS
   l_current_id              NUMBER := NULL;
   l_num_ids                 NUMBER := 0;
   l_id_found_flag           VARCHAR(1) := 'N';
   l_return_status 	     VARCHAR2(1);
   l_error_msg_data          fnd_new_messages.message_name%TYPE;

CURSOR c_ids IS
SELECT c.category_id
FROM mtl_categories_b c, mtl_category_set_valid_cats I
WHERE i.category_set_id = p_item_category_set_id
AND i.category_id = c.category_id
AND nvl(c.disable_date,sysdate) >= sysdate
AND fnd_Flex_ext.GET_SEGS('INV', 'MCAT', c.structure_id, c.category_id) =
    p_item_cat_name;
--AND c.description = p_item_cat_name;

BEGIN
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
IF (p_item_cat_id IS NOT NULL)
THEN
   IF (p_check_id_flag = 'Y') THEN
	BEGIN
            SELECT c.category_id
            INTO x_item_category_id
            FROM mtl_categories_b c, mtl_category_set_valid_cats I
            WHERE i.category_set_id = p_item_category_set_id
            AND i.category_id = c.category_id
            AND NVL(c.disable_date,sysdate) >= sysdate
            AND c.category_id = p_item_cat_id;

	EXCEPTION
	WHEN OTHERS THEN
              x_item_category_id := NULL;
              x_return_status:= FND_API.G_RET_STS_ERROR;
      	      --Need to get a proper message
              x_error_msg_code:= 'PA_INVALID_ITEM_CAT_ID';
              RAISE;
        END;
   ELSIF (p_check_id_flag='N') THEN
       x_item_category_id := p_item_cat_id;
   ELSIF (p_check_id_flag = 'A') THEN
    /***********************************************************
    *   The Check_id_flag of 'A' indicates that this validation is
    *   coming from Java front end,
    *   and hence the Id and Name combination needs to be validated
    *   in the database.
   *********************************************************/
        IF (p_item_cat_name IS NULL) THEN
             -- Return a null ID since the name is null.
     	     x_item_category_id := NULL;
        ELSE
             OPEN c_ids;
               LOOP
                 FETCH c_ids INTO l_current_id;
                 EXIT WHEN c_ids%NOTFOUND;
                 IF (l_current_id = p_item_cat_id) THEN
                      l_id_found_flag := 'Y';
                      x_item_category_id := p_item_cat_id;
                  END IF;
               END LOOP;
               l_num_ids := c_ids%ROWCOUNT;
             CLOSE c_ids;
             IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
             ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_item_category_id := l_current_id;
             ELSIF (l_num_ids > 1) THEN
                  --More than one ID for the Name
                  RAISE TOO_MANY_ROWS;
             END IF;
        END IF;
  ELSE
      x_item_category_id := NULL;
  END IF;
ELSE
    IF (p_item_cat_name  IS NOT NULL) THEN
    	BEGIN
       	   SELECT c.category_id
            INTO x_item_category_id
            FROM mtl_categories_b c, mtl_category_set_valid_cats I
            WHERE i.category_set_id = p_item_category_set_id
            AND i.category_id = c.category_id
            AND nvl(c.disable_date,sysdate) >= sysdate
            AND fnd_Flex_ext.GET_SEGS('INV', 'MCAT', c.structure_id, c.category_id) = p_item_cat_name;
            -- AND c.description = p_item_cat_name;
      EXCEPTION
      WHEN OTHERS THEN
              x_item_category_id := NULL;
              x_return_status:= FND_API.G_RET_STS_ERROR;
      	      --Need to get a proper message
              x_error_msg_code:= 'PA_INVALID_ITEM_CAT_NAME';
              Return;
   	  END;
    ELSE
          x_item_category_id := NULL;
     END IF;
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_item_category_id := NULL;
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --Need to get a proper message
    x_error_msg_code:= 'PA_INVALID_ITEM_CAT_ID';
    Return;
END Check_ItemCat_or_ID;
/********************************/
/********************************************
 * Procedure   : Check_InventoryItem_or_ID
 * Description : This Procedure can be called
 *            when the res_type_code is 'INVENTORY_ITEM'
 *            It validates the p_item_id and p_item_name
 *            and returns the x_item_id.
*******************************************/
PROCEDURE Check_InventoryItem_or_ID
          (  p_item_id                 IN        NUMBER
           , p_item_name               IN        VARCHAR2
           , P_item_master_id 	       IN        NUMBER
           , p_check_id_flag           IN        VARCHAR2
           , x_item_id                 OUT NOCOPY       NUMBER
           , x_return_status           OUT NOCOPY       VARCHAR2
           , x_error_msg_code          OUT NOCOPY       VARCHAR2 )
 IS
   l_current_id              NUMBER := NULL;
   l_num_ids                 NUMBER := 0;
   l_id_found_flag           VARCHAR(1) := 'N';
   l_return_status 	     VARCHAR2(1);
   l_error_msg_data          fnd_new_messages.message_name%TYPE;

/********************************************
 * Bug - 3566965
 * Desc - Modified the cursor to select based on
 *        the segment1 field instead of the
 *        description field. Also we dont need a join
 *        with the MTL_SYSTEM_ITEMS_tl table.
 *******************************************/
CURSOR c_ids IS
  SELECT b.INVENTORY_ITEM_ID
  FROM MTL_SYSTEM_ITEMS_b b
  WHERE b.organization_id = p_item_master_id
  AND b.ENABLED_FLAG = 'Y'
  --AND b.INVENTORY_ITEM_ID = t.INVENTORY_ITEM_ID
  --AND b.organization_id = t.organization_id
  --AND t.language = userenv('LANG')
  AND b.segment1 = p_item_name;

BEGIN
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
IF (p_item_id IS NOT NULL)
THEN
   IF (p_check_id_flag = 'Y') THEN
	BEGIN
           /********************************************
            * Bug - 3566965
            * Desc - Modified the below select. We dont need
            *        a join to the mtl_system_items_tl
            *        table.
            *******************************************/
            SELECT b.INVENTORY_ITEM_ID
            INTO x_item_id
            FROM MTL_SYSTEM_ITEMS_b b
            WHERE b.organization_id = p_item_master_id
            AND b.ENABLED_FLAG = 'Y'
            --AND b.INVENTORY_ITEM_ID = t.INVENTORY_ITEM_ID
            --AND b.organization_id = t.organization_id
            --AND t.language = userenv('LANG')
            AND b.inventory_item_id = p_item_id;
	EXCEPTION
	WHEN OTHERS THEN
              x_item_id := NULL;
              x_return_status:= FND_API.G_RET_STS_ERROR;
      	      --Need to get a proper message
              x_error_msg_code:= 'PA_INVALID_INV_ID';
              RAISE;
        END;
   ELSIF (p_check_id_flag='N') THEN
       x_item_id := p_item_id;
   ELSIF (p_check_id_flag = 'A') THEN
    /***********************************************************
    *   The Check_id_flag of 'A' indicates that this validation is
    *   coming from Java front end,
    *   and hence the Id and Name combination needs to be validated
    *   in the database.
   *********************************************************/
        IF (p_item_name IS NULL) THEN
             -- Return a null ID since the name is null.
     	     x_item_id := NULL;
        ELSE
             OPEN c_ids;
               LOOP
                 FETCH c_ids INTO l_current_id;
                 EXIT WHEN c_ids%NOTFOUND;
                 IF (l_current_id = p_item_id) THEN
                      l_id_found_flag := 'Y';
                      x_item_id := p_item_id;
                  END IF;
               END LOOP;
               l_num_ids := c_ids%ROWCOUNT;
             CLOSE c_ids;
             IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
             ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_item_id := l_current_id;
             ELSIF (l_num_ids > 1) THEN
                  --More than one ID for the Name
                  RAISE TOO_MANY_ROWS;
             END IF;
        END IF;
  ELSE
      x_item_id := NULL;
  END IF;
ELSE
    IF (p_item_name  IS NOT NULL) THEN
    	BEGIN
        /********************************************
         * Bug - 3566965
         * Desc - Modified the below select to be based on
         *        the segment1 field instead of the
         *        description field. Also we dont need a join
         *        with the MTL_SYSTEM_ITEMS_tl table.
         *******************************************/
            SELECT b.INVENTORY_ITEM_ID
            INTO x_item_id
            FROM MTL_SYSTEM_ITEMS_b b
            WHERE b.organization_id = p_item_master_id
            AND b.ENABLED_FLAG = 'Y'
            --AND b.INVENTORY_ITEM_ID = t.INVENTORY_ITEM_ID
            --AND b.organization_id = t.organization_id
            --AND t.language = userenv('LANG')
            AND b.segment1 = p_item_name;
      EXCEPTION
      WHEN OTHERS THEN
              x_item_id := NULL;
              x_return_status:= FND_API.G_RET_STS_ERROR;
      	      --Need to get a proper message
              x_error_msg_code:= 'PA_INVALID_INV_NAME';
              Return;
   	  END;
    ELSE
          x_item_id := NULL;
     END IF;
END IF;
EXCEPTION
WHEN OTHERS THEN
    x_item_id := NULL;
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --Need to get a proper message
    x_error_msg_code:= 'PA_INVALID_INV_ID';
    Return;
END Check_InventoryItem_or_Id;
/******************************************************************
* Procedure : Validate_Resource
 * Description :The purpose of this procedure is to validate the resource
 *              per resource class.
 *              The IN Parameters to the procedure are:
 *              p_resource_code,p_resource_name,p_resource_class_code,
 *              p_res_type_code.
 *              The OUT Parameters are :
 *              x_person_id,x_bom_resource_id,x_job_id,x_person_type_code,
 *              x_non_labor_resource,x_inventory_item_id,x_item_category_id,
 *              x_resource_class_code,x_resource_class_flag,x_return_status,
 *              x_error_message_code.
 **********************************************************************/

PROCEDURE Validate_Resource(
        p_resource_code		    IN	VARCHAR2	DEFAULT NULL,
        p_resource_name		    IN	VARCHAR2	DEFAULT NULL,
        p_resource_class_code	 IN	VARCHAR2,
        p_res_type_code		    IN	VARCHAR2	DEFAULT NULL,
        x_person_id		       OUT NOCOPY	NUMBER,
        x_bom_resource_id	    OUT NOCOPY	NUMBER,
        x_job_id		          OUT NOCOPY	NUMBER,
        x_person_type_code	    OUT NOCOPY	VARCHAR2,
        x_non_labor_resource	 OUT NOCOPY	VARCHAR2,
        x_inventory_item_id	 OUT NOCOPY	NUMBER,
        x_item_category_id	    OUT NOCOPY	NUMBER,
        x_resource_class_code	 OUT NOCOPY	VARCHAR2,
        x_resource_class_flag	 OUT NOCOPY	VARCHAR2,
        x_return_status		    OUT NOCOPY	VARCHAR2,
        x_error_msg_code	    OUT NOCOPY	VARCHAR2)

IS
--Declaration of Local Variabled
l_job_id         NUMBER;
l_person_id      NUMBER;
l_bom_resource_id NUMBER;
l_return_status  VARCHAR2(30);
l_error_msg_code VARCHAR2(30);
l_item_category_set_id NUMBER;
l_item_master_id  NUMBER;
l_item_category_id NUMBER;
l_inventory_item_id NUMBER;
/*********************************************
 * Subfunction : Check_Res_Null
 * Description : The Purpose of this function is to verify
 *               For Null condition in the fields
 *               p_resource_code,p_resource_name,
 *               p_resource_class_code and p_res_type_code
 *               If the condition fails 'Y' is returned
 *               else the value remains as 'N'.
 *************************************************/
FUNCTION Check_Res_Null(
        p_resource_code         IN      VARCHAR2        DEFAULT NULL,
        p_resource_name         IN      VARCHAR2        DEFAULT NULL,
        p_resource_class_code   IN      VARCHAR2,
        p_res_type_code         IN      VARCHAR2        DEFAULT NULL)
RETURN VARCHAR2
IS
       l_check_null_flag     VARCHAR2(30) := 'N';
BEGIN
       IF p_res_type_code IS  NULL THEN
		l_check_null_flag := 'Y';
	END IF;
	IF p_resource_class_code IS NULL THEN
		l_check_null_flag := 'Y';
	END IF;
	IF (p_resource_code IS NULL AND p_resource_name IS NULL)
	THEN
		l_check_null_flag := 'Y';
	END IF;
	Return l_Check_Null_Flag;
END Check_Res_Null;
/************************************/

/*********************************************
 * Subfunction : Match_classcode_Type
 * Description : The Purpose of this function is to verify
 *               that the p_res_type_code is a valid resource type
 *               in the given p_resource_class_code.
 *               It will return 'N' if it is not valid
 *               and 'Y' otherwise.
*******************************************************/
Function Match_classcode_Type(
                           p_resource_class_code IN VARCHAR2,
                           p_res_type_code       IN VARCHAR2)
RETURN VARCHAR2
IS
   l_check_match_flag    VARCHAR2(30) := 'Y';
BEGIN
/*********************************************************
 * Outer IF to validate that the resource_class_code passed
 * is a valid resource_class_code. If not it would go to
 * the Else.
 * ********************************************************/
IF p_resource_class_code IN ('PEOPLE','EQUIPMENT','MATERIAL_ITEMS',
                            'FINANCIAL_ELEMENTS')
THEN
   IF p_resource_class_code = 'PEOPLE'
   THEN
   /********************************************************
    * IF p_resource_class_code = 'PEOPLE'
    * then the res_type_code should be one of
    * 'NAMED_PERSON','BOM_LABOR','NAMED_ROLE',
    * 'JOB','PERSON_TYPE','RESOURCE_CLASS'
    ************************************************************/
       IF p_res_type_code IN ('NAMED_PERSON','BOM_LABOR','NAMED_ROLE',
                         'JOB','PERSON_TYPE','RESOURCE_CLASS')
       THEN
           l_check_match_flag := 'Y';
       ELSE
           l_check_match_flag := 'N';
       END IF;

   ELSIF p_resource_class_code = 'EQUIPMENT'
   THEN
   /********************************************************
    * IF p_resource_class_code = 'EQUIPMENT'
    * then the res_type_code should be one of
    * 'NON_LABOR_RESOURCE','BOM_EQUIPMENT',
    * 'RESOURCE_CLASS'
    ************************************************************/
        IF p_res_type_code IN ('NON_LABOR_RESOURCE','BOM_EQUIPMENT',
                        'RESOURCE_CLASS')
        THEN
             l_check_match_flag := 'Y';
        ELSE
             l_check_match_flag := 'N';
        END IF;

   ELSIF p_resource_class_code = 'MATERIAL_ITEMS'
   THEN
   /********************************************************
    * IF p_resource_class_code = 'MATERIAL_ITEMS'
    * then the res_type_code should be one of
    * 'INVENTORY_ITEM',
    * 'ITEM_CATEGORY','RESOURCE_CLASS'
    ************************************************************/
        IF p_res_type_code IN ('INVENTORY_ITEM',
                             'ITEM_CATEGORY','RESOURCE_CLASS')
        THEN
             l_check_match_flag := 'Y';
        ELSE
             l_check_match_flag := 'N';
        END IF;

    ELSIF p_resource_class_code = 'FINANCIAL_ELEMENTS' THEN
        IF p_res_type_code IN ('RESOURCE_CLASS')
        THEN
             l_check_match_flag := 'Y';
        ELSE
             l_check_match_flag := 'N';
        END IF;

    END IF;
ELSE
/*******************************************
 * If the resource_class_code is not Valid.
 * *****************************************/
       l_check_match_flag := 'N';
END IF;
  Return l_Check_Match_Flag;
END Match_classcode_Type;
/*************************/

/*************************
 *    Main Body          *
 ************************/
BEGIN
-- hr_utility.trace('Start Validate_Resource');
       x_return_status:= FND_API.G_RET_STS_SUCCESS;
              x_resource_class_flag := 'N';
/* Call to the Function check_null_flag to check for the null conditions*/

 IF Check_Res_Null(p_resource_code,p_resource_name,
                  p_resource_class_code,p_res_type_code) = 'Y'
 THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Return;
 ELSE

   IF Match_classcode_Type(p_resource_class_code,p_res_type_code) = 'N'
   THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       --Need to get message for this.
       x_error_msg_code:= 'PA_RESOURCE_NO_MATCH';
       PA_UTILS.Add_Message('PA', x_error_msg_code, 'PLAN_RES',
                            Pa_Planning_Resource_Pvt.g_token);
   ELSE

       IF p_res_type_code = 'RESOURCE_CLASS' THEN
          IF p_resource_code = p_resource_class_code THEN
              x_resource_class_code := p_resource_class_code;
              x_resource_class_flag := 'Y';
          ELSE
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              Return;
           END IF;
       ELSIF p_res_type_code = 'PERSON_TYPE' THEN
           BEGIN
               SELECT lookup_code
               INTO x_person_type_code
               FROM pa_lookups
               WHERE lookup_type = 'PA_PERSON_TYPE'
               AND lookup_code = p_resource_code;
           EXCEPTION
           WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              --Need to get message for this.
              x_error_msg_code:= 'PA_PERSON_TYPE_CODE_INVALID';
              PA_UTILS.Add_Message('PA', x_error_msg_code, 'PLAN_RES',
                                   Pa_Planning_Resource_Pvt.g_token);
           END;
       ELSIF p_res_type_code = 'NON_LABOR_RESOURCE' THEN
           BEGIN
               SELECT non_labor_resource
               INTO x_non_labor_resource
               FROM pa_non_labor_resources
               WHERE non_labor_resource = p_resource_name;
           EXCEPTION
           WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              --Need to get message for this.
              x_error_msg_code:= 'PA_NON_LABOR_CODE_INVALID';
              PA_UTILS.Add_Message('PA', x_error_msg_code, 'PLAN_RES',
                                   Pa_Planning_Resource_Pvt.g_token);
           END;
       ELSIF p_res_type_code = 'NAMED_PERSON' THEN

                pa_planning_resource_utils.Check_PersonName_or_ID(
                p_person_id     => p_resource_code,
                p_person_name     => p_resource_name,
                p_check_id_flag     => PA_STARTUP.G_Check_ID_Flag,
                x_person_id         => l_person_id,
                x_return_status     => l_return_status,
                x_error_msg_code    => l_error_msg_code);

              x_person_id        := l_person_id;
              x_return_status    := l_return_status;
              x_error_msg_code   := l_error_msg_code;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 PA_UTILS.Add_Message('PA', l_error_msg_code, 'PLAN_RES',
                                      Pa_Planning_Resource_Pvt.g_token);
                 Return;
             END IF;
  /***************************************
 * Rest of code goes here all the ELSIF
 * ***************************************/
       ELSIF p_res_type_code = 'JOB' THEN

-- hr_utility.trace('p_res_type_code IS : ' || p_res_type_code);
-- hr_utility.trace('Before Check_JG_JobName_or_ID');
-- hr_utility.trace('p_resource_code IS : ' || p_resource_code);
-- hr_utility.trace('p_resource_name IS : ' || p_resource_name);
-- hr_utility.trace('g_job_group_id IS : ' || g_job_group_id);
-- hr_utility.trace('PA_STARTUP.G_Check_ID_Flag IS : ' || PA_STARTUP.G_Check_ID_Flag);
             Check_JG_JobName_or_ID(
                P_job_id          => p_resource_code,
                p_job_name        => p_resource_name,
                p_job_group_id    => g_job_group_id,
                p_check_id_flag   => PA_STARTUP.G_Check_ID_Flag,
                x_job_id          => l_job_id,
                x_return_status   => l_return_status,
                x_error_msg_code  => l_error_msg_code);

                x_job_id          :=  l_job_id;
                x_return_status   :=  l_return_status;
                x_error_msg_code  :=  l_error_msg_code;

-- hr_utility.trace('after Check_JG_JobName_or_ID');
-- hr_utility.trace('x_return_status IS : ' || x_return_status);
-- hr_utility.trace('x_error_msg_code IS : ' || x_error_msg_code);
-- hr_utility.trace('x_job_id IS : ' || x_job_id);
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 PA_UTILS.Add_Message('PA', l_error_msg_code, 'PLAN_RES',
                                      Pa_Planning_Resource_Pvt.g_token);
                 Return;
             END IF;
       ELSIF p_res_type_code = 'BOM_LABOR' THEN

           pa_planning_resource_utils.Check_BOM_EqLabor_or_ID(
           p_bom_eqlabor_id       => p_resource_code,
           p_bom_eqlabor_name     => p_resource_name,
           p_res_type_code        => 2,
           p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag,
           x_bom_resource_id      => l_bom_resource_id,
           x_return_status        => l_return_status,
           x_error_msg_code       => l_error_msg_code);


          x_bom_resource_id := l_bom_resource_id;
          x_return_status   := l_return_status;
          x_error_msg_code  := l_error_msg_code;
		--Added for bug 3947006
	  IF x_return_status = Fnd_Api.G_Ret_Sts_Error THEN

              Return;
           END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.Add_Message('PA', l_error_msg_code, 'PLAN_RES',
                                   Pa_Planning_Resource_Pvt.g_token);
              Return;
           END IF;
       ELSIF p_res_type_code = 'BOM_EQUIPMENT' THEN

           pa_planning_resource_utils.Check_BOM_EqLabor_or_ID(
           p_bom_eqlabor_id       => p_resource_code,
           p_bom_eqlabor_name     => p_resource_name,
           p_res_type_code        => 1,
           p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag,
           x_bom_resource_id      => l_bom_resource_id,
           x_return_status        => l_return_status,
           x_error_msg_code       => l_error_msg_code);

           x_bom_resource_id := l_bom_resource_id;
           x_return_status   := l_return_status;
           x_error_msg_code  := l_error_msg_code;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              PA_UTILS.Add_Message('PA', l_error_msg_code, 'PLAN_RES',
                                   Pa_Planning_Resource_Pvt.g_token);
              Return;
           END IF;

ELSIF p_res_type_code = 'ITEM_CATEGORY' THEN

   BEGIN
	SELECT def.item_category_set_id
	INTO l_item_category_set_id
        FROM pa_plan_res_defaults def
           -- , pa_resource_classes_b cl
        WHERE def.resource_class_id = 3
        AND def.object_type ='CLASS';
        --AND cl.resource_class_id = def.resource_class_id
        --AND cl.resource_class_id = 3;
       --AND cl.resource_class_code = 'MATERIAL_ITEMS';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       x_item_category_id := NULL;
       x_return_status:= FND_API.G_RET_STS_ERROR;
       --Need to get a proper message
       x_error_msg_code:= 'PA_NO_ITEM_CATEGORY_SET';
       Return;
   WHEN OTHERS THEN
       x_item_category_id := NULL;
       x_return_status:= FND_API.G_RET_STS_ERROR;
       --Need to get a proper message
       x_error_msg_code:= 'PA_NO_ITEM_CATEGORY_SET';
       Return;
   END;

     Pa_planning_resource_utils.Check_ItemCat_or_ID(
	  P_item_cat_id          =>  p_resource_code,
          P_item_cat_name   	 =>  p_resource_name,
     	  P_item_category_set_id =>  l_item_category_set_id,
          P_check_id_flag        =>  PA_STARTUP.G_Check_ID_Flag,
          X_item_category_id     =>  l_item_category_id,
          X_return_status        =>  l_return_status,
          X_error_msg_code       =>  l_error_msg_code);

          x_item_category_id := l_item_category_id;
          x_return_status    := l_return_status;
          x_error_msg_code   := l_error_msg_code;
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           PA_UTILS.Add_Message('PA', l_error_msg_code, 'PLAN_RES',
                                Pa_Planning_Resource_Pvt.g_token);
     END IF;
ELSIF p_res_type_code = 'INVENTORY_ITEM' THEN
   BEGIN
	SELECT def.item_master_id
	INTO l_item_master_id
        FROM pa_plan_res_defaults def
           -- , pa_resource_classes_b cl
        WHERE def.resource_class_id = 3
        AND def.object_type ='CLASS';
        --AND cl.resource_class_id = def.resource_class_id
        --AND cl.resource_class_id = 3;
        --AND cl.resource_class_code = 'MATERIAL_ITEMS';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
       x_inventory_item_id := NULL;
       x_return_status:= FND_API.G_RET_STS_ERROR;
       --Need to get a proper message
       x_error_msg_code:= 'PA_NO_MAT_ITEM_ID';
       Return;
   WHEN OTHERS THEN
       x_inventory_item_id := NULL;
       x_return_status:= FND_API.G_RET_STS_ERROR;
       --Need to get a proper message
       x_error_msg_code:= 'PA_NO_MAT_ITEM_ID';
       Return;
   END;
     Pa_planning_resource_utils.Check_InventoryItem_or_ID(
	  P_item_id               =>  p_resource_code,
          P_item_name   	  =>  p_resource_name,
     	  P_item_master_id        =>  l_item_master_id,
          P_check_id_flag         =>  PA_STARTUP.G_Check_ID_Flag,
          X_item_id               =>  l_inventory_item_id,
          X_return_status         =>  l_return_status,
          X_error_msg_code        =>  l_error_msg_code);

          X_inventory_item_id   := l_inventory_item_id;
          x_return_status       := l_return_status;
          x_error_msg_code      := l_error_msg_code;
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           PA_UTILS.Add_Message('PA', l_error_msg_code, 'PLAN_RES',
                                Pa_Planning_Resource_Pvt.g_token);
           Return;
     END IF;
/******ELSIF*******/
   END IF;
/*************/
  END IF;
END IF;

END Validate_Resource;
/***************************************************/

/*******************************************************
 * Procedure : Default_Expenditure_Type
 * 1. If Expenditure Type is available on the planning resource,
 *    leave as is.
 * 2. If Exp Type is null:
 *      i. Derive from BOM Resources, if the planning resource has one.
 *      ii. Derive from Non-Labor Resource, if the planning resource has one.
 *      iii. Derive from item if planning resource has one.
 *  We could pass back null for the Expenditure type for the planning resource,
 *  if none of the above yields a value.
 * *******************************************************/
 /**********************************************************
 * Bug - 3615477
 * Desc - In this proc we are going to be updating the value of
 *        res_temp.expenditure_type and the final update is not
 *        required while updating the expenditure_type value.
 *        Also in the where clause we are checking for
 *        res_temp.expenditure_type IS NULL
 **********************************************************/
PROCEDURE Default_Expenditure_Type
IS
BEGIN

    /*************************************************
    * Update to use when the expenditure_type is null
    * and bom_resource_id is not null. We use the below
    * Update to set the value for expenditure_type
    * ************************************************/
    --Bug 3615477
    --Also updating the value of fc_res_type_code.
    --Bug 3628429
    --Join to the pa_expenditure_types table.
    -- Fixed bug 3962699 - Removed the setting of fc_res_type_code from
    -- all the below selects.  No need to set fc res type code - only
    -- need to set Exp Type.
     UPDATE pa_res_members_temp res_temp
     SET  res_temp.expenditure_type =
                            (SELECT exp.expenditure_type
                             FROM bom_resources bom, pa_expenditure_types exp
                             WHERE bom.resource_id = res_temp.bom_resource_id
                             AND   exp.expenditure_type = bom.expenditure_type
                             AND   exp.UNIT_OF_MEASURE = 'HOURS'
                             AND ROWNUM = 1)
     WHERE res_temp.expenditure_type IS NULL
     AND res_temp.bom_resource_id IS NOT NULL;

    /*************************************************
    * Update to use when the expenditure_type is null
    * and non_labor_resource is not null. We use the below
    * Update to set the value for expenditure_type
    *************************************************/
    --Bug 3615477
    --Also updating the value of fc_res_type_code.
     UPDATE pa_res_members_temp res_temp
     SET  res_temp.expenditure_type =
                           (SELECT n.expenditure_type
                              FROM pa_non_labor_resources n
                             WHERE n.non_labor_resource =
                                           res_temp.non_labor_resource
                             AND ROWNUM = 1)
     WHERE res_temp.expenditure_type IS NULL
     AND res_temp.non_labor_resource IS NOT NULL;

     -- Get the item's exp type if it exists

    --Bug 3615477
    --Also updating the value of fc_res_type_code.
     UPDATE pa_res_members_temp res_temp
     SET  res_temp.expenditure_type =
             PJM_COMMITMENT_UTILS.MTL_EXPENDITURE_TYPE(
                   res_temp.organization_id, res_temp.inventory_item_id)
     WHERE res_temp.organization_id IS NOT NULL
     AND res_temp.inventory_item_id IS NOT NULL
     AND res_temp.expenditure_type IS NULL;

EXCEPTION
WHEN OTHERS THEN
     RAISE;
END Default_Expenditure_Type;
/******************************************/
/*******************************************************
 * Procedure : Default_Rate_Expenditure_Type
 *      i. Derive from BOM Resources, if the planning resource has one.
 *      ii. Derive from Non-Labor Resource, if the planning resource has one.
 *      iii. Derive from item if planning resource has one.
 *      iv. Derive from class
 *  We could pass back null for the Rate Expenditure type for the planning
 *  resource, if none of the above yields a value.
 * *******************************************************/
 /**********************************************************
 * Bug - 3615477
 * Desc - In this proc we are going to be updating the value of
 *        res_temp.rate_expenditure_type and the final update is
 *        required while updating the rate_expenditure_type value.
 *        Also in the where condition we are checking for
 *        res_temp.rate_expenditure_type IS NULL
 **********************************************************/
PROCEDURE Default_Rate_Expenditure_Type
IS
BEGIN
    /*************************************************
    * Update to use when the rate_expenditure_type is null
    * and bom_resource_id is not null. We use the below
    * Update to set the value for rate_expenditure_type
    * ************************************************/
    --Bug 3628429
    --Join to the pa_expenditure_types table.
     UPDATE pa_res_members_temp res_temp
     SET  res_temp.rate_expenditure_type =
                            (SELECT exp.expenditure_type
                             FROM bom_resources bom,pa_expenditure_types exp
                             WHERE bom.resource_id = res_temp.bom_resource_id
                             AND   exp.expenditure_type = bom.expenditure_type
                             AND   exp.UNIT_OF_MEASURE = 'HOURS'
                             AND ROWNUM = 1)
     WHERE res_temp.rate_expenditure_type IS NULL
     AND res_temp.bom_resource_id IS NOT NULL;
    /*************************************************
    * Update to use when the rate_expenditure_type is null
    * and non_labor_resource is not null. We use the below
    * Update to set the value for rate_expenditure_type
    *************************************************/
     UPDATE pa_res_members_temp res_temp
     SET  res_temp.rate_expenditure_type =
                           (SELECT n.expenditure_type
                           FROM pa_non_labor_resources n
                            WHERE  n.non_labor_resource =
                                           res_temp.non_labor_resource
                             AND ROWNUM = 1)
     WHERE res_temp.rate_expenditure_type IS NULL
     AND res_temp.non_labor_resource IS NOT NULL;

     -- Get the item's exp type if it exists

     UPDATE pa_res_members_temp res_temp
     SET  res_temp.rate_expenditure_type =
             PJM_COMMITMENT_UTILS.MTL_EXPENDITURE_TYPE(
                   res_temp.organization_id, res_temp.inventory_item_id)
     WHERE res_temp.organization_id IS NOT NULL
     AND res_temp.inventory_item_id IS NOT NULL
     AND res_temp.rate_expenditure_type IS NULL;

    /**************************************************
    * Final Update which will default the value of
    * rate_expenditure_type based on the resource class id
    * **************************************************/
     UPDATE pa_res_members_temp res_temp
     SET  res_temp.rate_expenditure_type =
                             (SELECT expenditure_type
                                FROM pa_plan_res_defaults
                               WHERE resource_class_id =
                                     res_temp.resource_class_id
                             AND ROWNUM = 1
                             AND object_type = 'CLASS')
     WHERE (res_temp.rate_expenditure_type IS NULL OR
           (res_temp.rate_expenditure_type = 'NO Val'))
     AND res_temp.resource_class_id IS NOT NULL;
EXCEPTION
WHEN OTHERS THEN
     RAISE;
END Default_Rate_Expenditure_Type;
/******************************************/

/*********************************************************
* Procedure : Default_OU
* Description : To derive the default Org ID
* First it will try to derive it from hr_organization_information
* based on the organization_id.
* If the Org_id is still null then we will get it based on the p_project_id
* passed from pa_projects_all table.
* ******************************************************/
PROCEDURE default_ou(p_project_id IN PA_PROJECTS_ALL.PROJECT_ID%TYPE)
IS
l_proj_ou NUMBER;
BEGIN
       UPDATE pa_res_members_temp res_temp
       SET org_id = (SELECT to_number(org_information1)
              FROM   hr_organization_information
              WHERE  org_information_context = 'Exp Organization Defaults'
              AND    organization_id         = res_temp.organization_id
              AND    rownum                  = 1)
       WHERE res_temp.organization_id IS NOT NULL
       AND res_temp.org_id IS NULL;

       BEGIN
       SELECT org_id
       INTO l_proj_ou
       FROM pa_projects_all
       WHERE project_id = p_project_id
       AND rownum     = 1;

       EXCEPTION WHEN NO_DATA_FOUND THEN
           l_proj_ou := NULL;
       END;

       UPDATE pa_res_members_temp res_temp
       SET org_id = l_proj_ou
       WHERE res_temp.org_id IS NULL;

EXCEPTION
WHEN OTHERS THEN
     RAISE;
END default_ou;
/************************************************/

/*********************************************************
* Procedure : Default_UOM
* Description : To derive the Unit of Measure based on the
* resource_class_code. Update the UOM in the table with the appr
* value.
* ******************************************************/
PROCEDURE Default_UOM
IS
BEGIN
       /*********************************************************
       * If the resource_class code in the table is 'PEOPLE' or EQUIPMENT
       * Then by default the Unit of measure should only be 'HOURS'
       *************************************************************/
        UPDATE pa_res_members_temp res_temp
        SET unit_of_measure = 'HOURS'
        WHERE res_temp.resource_class_code IN ('PEOPLE', 'EQUIPMENT')
        AND res_temp.unit_of_measure IS NULL;

       /***********************************************************
       * If the resource class code is 'MATERIAL_ITEMS' and the
       * Inventory_item_id is not null then we need to derive the
       * Unit of measure from MTL_SYSTEM_ITEMS_b based on the inventory_item
       * And Organization id that matches the master_item_id in
       * pa_plan_res_defaults. If the planning resource has an organization,
       * use that; if not, use item master.
       ***************************************************************/
        UPDATE pa_res_members_temp res_temp
        SET unit_of_measure = (SELECT primary_uom_code
                               FROM   mtl_system_items_b items
                               WHERE  items.inventory_item_id =
                                      res_temp.inventory_item_id
                               AND    items.organization_id =
                                      res_temp.organization_id
                               AND    ROWNUM = 1)
        WHERE res_temp.resource_class_code = 'MATERIAL_ITEMS'
        AND res_temp.unit_of_measure IS NULL
        AND res_temp.organization_id IS NOT NULL
        AND res_temp.inventory_item_id IS NOT NULL;

        UPDATE pa_res_members_temp res_temp
        SET unit_of_measure = (SELECT primary_uom_code
                               FROM mtl_system_items_b items
                               WHERE items.inventory_item_id =
                                      res_temp.inventory_item_id
                         AND items.organization_id =
 					(SELECT def.item_master_id
                                           FROM pa_resource_classes_b cls,
						pa_plan_res_defaults def
                         WHERE cls.resource_class_code = 'MATERIAL_ITEMS'
 			   AND cls.resource_class_id = def.resource_class_id
                           AND def.object_type = 'CLASS')
                                AND ROWNUM     = 1)
        WHERE res_temp.resource_class_code = 'MATERIAL_ITEMS'
        AND res_temp.unit_of_measure IS NULL
        AND res_temp.inventory_item_id IS NOT NULL;

      /************************************************************
      * If the class is Financial Elements , or it is Material
      * Items but there is no item in the planning resource,
      * and there is an expenditure type, then take the UOM of
      * the expenditure type.
      ***************************************************************/
         UPDATE pa_res_members_temp res_temp
         SET res_temp.unit_of_measure = (SELECT unit_of_measure
                         FROM pa_expenditure_types et
                         WHERE et.expenditure_type = res_temp.expenditure_type
                           AND ROWNUM = 1)
         WHERE res_temp.resource_class_code IN
               ('MATERIAL_ITEMS', 'FINANCIAL_ELEMENTS')
         AND res_temp.inventory_item_id IS NULL
         AND res_temp.unit_of_measure IS NULL
         AND res_temp.expenditure_type IS NOT NULL;

        /******************************************************
        * If the Unit of measure column is still null, then
        * Default it to 'DOLLARS'
        *********************************************************/
         UPDATE pa_res_members_temp res_temp
         SET res_temp.unit_of_measure = 'DOLLARS'
         WHERE res_temp.unit_of_measure IS NULL;

EXCEPTION
WHEN OTHERS THEN
 RAISE;
END Default_UOM;

/*********************************************************
* Procedure Default_Supplier
* If Supplier is not null, pass it back.
* 1. Code to get from per_cont_workers_current_x if
* incurred_by_res_flag is 'N' - AI: need to revisit if we need to do it
* for incurred by resources also
* ******************************************************/
PROCEDURE Default_Supplier
IS
BEGIN
     UPDATE pa_res_members_temp res_temp
     SET  res_temp.vendor_id =
                             (SELECT asgn.vendor_id
                                FROM per_all_assignments_f asgn
                               WHERE asgn.person_id = res_temp.person_id
                                 AND asgn.primary_flag = 'Y'
                                 AND asgn.assignment_type = 'C'
                                 AND trunc(sysdate) BETWEEN
                                     asgn.effective_start_date AND
                                     asgn.effective_end_date
                                 AND ROWNUM = 1)
     WHERE res_temp.vendor_id IS NULL
     -- Fix for bug 3940856 - get supplier for all cwk
     -- AND res_temp.incurred_by_res_flag = 'N'
     AND res_temp.person_id IS NOT NULL;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END Default_Supplier;

/*********************************************************
* Procedure Default_Currency_Code
* ******************************************************/
PROCEDURE Default_Currency_Code
IS

BEGIN
      UPDATE pa_res_members_temp res_temp
      SET rate_func_curr_code = (
                  SELECT FC.Currency_Code
                  FROM FND_CURRENCIES FC,
                       GL_SETS_OF_BOOKS GB,
                       PA_IMPLEMENTATIONS_all IMP
                   -- Bug 4656920 - removed nvl on imp.org_id for R12 MOAC
                   WHERE imp.org_id = nvl(res_temp.org_id, -99)
                   AND IMP.Set_Of_Books_ID = GB.Set_Of_Books_ID
                   AND FC.Currency_Code =
                       DECODE(IMP.Set_Of_Books_ID, NULL,NULL,GB.CURRENCY_CODE));

      UPDATE pa_res_members_temp res_temp
      SET rate_func_curr_code = unit_of_measure
      WHERE inventory_item_id IS NOT NULL
      AND rate_based_flag = 'N';

      -- Added for bug  3841920 - The UOM for all non-rate based
      -- transactions should be 'Currency'
      UPDATE pa_res_members_temp res_temp
      SET unit_of_measure = 'DOLLARS'
      WHERE inventory_item_id IS NOT NULL
      AND rate_based_flag = 'N';

EXCEPTION
WHEN OTHERS THEN
   RAISE;
END Default_Currency_Code;
/**************************************************/
/*********************************************************
 * Procedure  : default_job
 * If job is not null, then leave as is
 * i. Default from person's HR Job if planning resource has a person
 *    and the person is not the incurred by resource.
 * If we cannot default job, we will pass back null.
 * ******************************************************/
 PROCEDURE default_job
 IS
 BEGIN
     UPDATE pa_res_members_temp res_temp
     SET job_id = (SELECT job_id
                 FROM per_all_assignments_f assn
                 WHERE assn.person_id = res_temp.person_id
                 AND   SYSDATE BETWEEN assn.effective_start_date
                                   AND  assn.effective_end_date
                 AND assn.assignment_type in ('C','E')
                 AND assn.primary_flag = 'Y'
                 AND ROWNUM = 1)
     WHERE res_temp.job_id IS NULL
     AND res_temp.person_id IS NOT NULL;

     UPDATE pa_res_members_temp res_temp
     SET job_id = (SELECT default_job_id
                     FROM pa_project_role_types_vl role
                    WHERE role.project_role_id = res_temp.project_role_id
                      AND ROWNUM = 1)
     WHERE res_temp.job_id IS NULL
     AND res_temp.project_role_id IS NOT NULL;

 EXCEPTION
 WHEN OTHERS THEN
     RAISE;
 END default_job;

/**************************************************/
/*********************************************************
 * Procedure  : default_person_type
 * If person_type is not null, then leave as is
 * i. Get from person's HR person record if planning resource has a person
 *    and the person is not the incurred by resource.
 *    Now, doing it for incurred by resource also, if inc by is a person
 * If we cannot default person_type, we will pass back null.
 *  ******************************************************/
 PROCEDURE default_person_type
 IS
 BEGIN
-- Issue with future dated or terminated employees/contingent workers?

     UPDATE pa_res_members_temp res_temp
     SET person_type_code = (SELECT
                           decode(peo.current_employee_flag, 'Y', 'EMP', 'CWK')
                 FROM per_all_people_f peo
                 WHERE peo.person_id = res_temp.person_id
                 AND   SYSDATE BETWEEN peo.effective_start_date
                                   AND peo.effective_end_date
                 AND ROWNUM = 1)
     WHERE res_temp.person_type_code IS NULL
     -- AND res_temp.incurred_by_res_flag = 'N' -- Bug 3827566
     AND res_temp.person_id IS NOT NULL;
 EXCEPTION
 WHEN OTHERS THEN
     RAISE;
 END default_person_type;

/*******************************************************/

/*********************************************************
* Procedure Default_Organization
* If Organization is not null, then leave as is
* i. Default from person's HR organization if planning resource has a person
*    and the person is not the incurred by resource.
* ii. Default from bom resource, id planning resource has one.
* iii. Default from item, if planning resource has one
* If we cannot default organization, we will pass back null.
* ******************************************************/
PROCEDURE Default_Organization (p_project_id IN PA_PROJECTS_ALL.PROJECT_ID%TYPE)
IS

l_organization_id NUMBER := NULL;
  BEGIN

     /***************************************************
     * All of the below updates will only fire for
     * organization_id being null in the temp table.
     * If it is not null....then dont do anything.
     * ****************************************************/

     /**************************************************
     * This Update will fire when the incurred_by_res_flag is Yes or No
     * and person_id IS NOT NULL.
     * We are updating the value for organization_id = derived value
     * based on person's HR org.
     * ***************************************************/
     UPDATE pa_res_members_temp res_temp
     SET organization_id = (SELECT a.organization_id
                 FROM per_assignments_x a,
                      pa_all_organizations org
                 WHERE a.person_id = res_temp.person_id
                 AND a.organization_id = org.organization_id
                 AND org.inactive_date is null
                 AND org.pa_org_use_type = 'EXPENDITURES'
                 AND a.assignment_type in ('C','E')
                 AND a.primary_flag = 'Y'
                 AND ROWNUM = 1)
     WHERE res_temp.person_id IS NOT NULL
     AND res_temp.organization_id IS NULL;

     /**************************************************
     * This Update will fire when the incurred_by_res_flag = 'N'
     * and bom_resource_id IS NOT NULL and organization_id IS NULL.
     * We are deriving the value for organization_id
     * ***************************************************/
     UPDATE pa_res_members_temp res_temp
     SET organization_id = (SELECT b.organization_id
                 FROM bom_resources b
                 WHERE b.resource_id = res_temp.bom_resource_id
                 AND ROWNUM = 1)
     WHERE res_temp.incurred_by_res_flag = 'N'
     AND res_temp.bom_resource_id IS NOT NULL
     AND res_temp.organization_id IS NULL;

     /**************************************************
     * This Update will fire when the incurred_by_res_flag = 'N'
     * and inventory_item_id IS NOT NULL and organization_id IS NULL.
     * We are deriving the value for organization_id
     * ***************************************************/
     UPDATE pa_res_members_temp res_temp
     SET organization_id = (SELECT i.organization_id
                 FROM mtl_system_items_b i
                 WHERE i.inventory_item_id = res_temp.inventory_item_id
                   AND i.organization_id =
                                        (SELECT def.item_master_id
                                           FROM pa_resource_classes_b cls,
                                                pa_plan_res_defaults def
                         WHERE cls.resource_class_code = 'MATERIAL_ITEMS'
                           AND cls.resource_class_id = def.resource_class_id
                           AND def.object_type = 'CLASS')
                 AND ROWNUM = 1)
     WHERE res_temp.incurred_by_res_flag = 'N'
     AND res_temp.inventory_item_id IS NOT NULL
     AND res_temp.organization_id IS NULL;

     /**************************************************
     * This Update will fire for all resources if the organization_id is null
     * We are deriving the value for organization_id from the project
     * ***************************************************/

     BEGIN
     SELECT proj.carrying_out_organization_id
       INTO l_organization_id
       FROM pa_projects_all proj,
            pa_all_organizations org
      WHERE proj.project_id = p_project_id
        AND proj.carrying_out_organization_id = org.organization_id
        AND org.inactive_date is null
        AND org.pa_org_use_type = 'EXPENDITURES'
        AND ROWNUM = 1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_organization_id := NULL;
       WHEN OTHERS THEN
          l_organization_id := NULL;
     END;

     IF l_organization_id IS NOT NULL THEN
        UPDATE pa_res_members_temp res_temp
        SET organization_id = l_organization_id
        WHERE res_temp.organization_id IS NULL;
     END IF;


EXCEPTION
     WHEN OTHERS THEN
          RAISE;

END Default_Organization;
/*************************************/

/***********************************************************
 * Function  : Default_Rate_Based
 * Description : Function takes in resource_class_code,
 *               inventory_item_id, expenditure_type,
 *               and returns rate_based_flag.
 ***********************************************************/
PROCEDURE default_rate_based
IS
BEGIN
      /****************************************
       * First Update all the rows no 'N' as by
       * default it should be N  and not null.
       ******************************************/
      UPDATE pa_res_members_temp res_temp
      SET rate_based_flag = 'N';

     /********************************************
     * Update it to 'Y' for resource_class_code
     * in 'PEOPLE' or 'EQUIPMENT'
     ***********************************************/
       UPDATE pa_res_members_temp res_temp
       SET rate_based_flag = 'Y'
       WHERE res_temp.resource_class_code in ('PEOPLE','EQUIPMENT');

       UPDATE pa_res_members_temp res_temp
       SET rate_based_flag = 'Y'
       WHERE res_temp.resource_class_code
                    = 'MATERIAL_ITEMS'
       AND res_temp.inventory_item_id IS NOT NULL
       AND NOT EXISTS (select 'Y'
                         from mtl_system_items_b item,
                              mtl_units_of_measure meas
                        where item.inventory_item_id =
                              res_temp.inventory_item_id
                          and item.primary_uom_code = meas.uom_code
                          and meas.uom_class = 'Currency');

 /**********************************************************
 * If the x_rate_exp_type is not null but exp_type is null
 * then use x_rate_exp_type to derive rate_based_flag.
 * Modified the existing update statement to include the foll:
 * - 'MATERIAL_ITEMS' in res_class_code.
 * - Added an nvl condition to derive based on the
 * rate expenditure type if the expenditure type is null
 * - added an extra condition to check that either one of
 * expenditure type or rate expenditure type should not be null.
 * ********************************************************/
       UPDATE pa_res_members_temp res_temp
       SET rate_based_flag =
                    (SELECT c.cost_rate_flag
                     FROM pa_expenditure_types c
                     WHERE c.expenditure_type = res_temp.expenditure_type)
                     -- nvl(res_temp.expenditure_type,  Bug 3586021
                             -- res_temp.rate_expenditure_type))
       WHERE res_temp.resource_class_code
                    in ('MATERIAL_ITEMS',  'FINANCIAL_ELEMENTS')
       --Added the below cond so that it does not override prev upd.
       AND res_temp.inventory_item_id IS NULL
       AND res_temp.expenditure_type IS NOT NULL;
       -- AND (res_temp.expenditure_type IS NOT NULL OR
              -- res_temp.rate_expenditure_type is not null); -- Bug 3586021
EXCEPTION
WHEN OTHERS THEN
      RAISE;
END Default_rate_based;
/*******************************************************/

/*************************************************************
 * Procedure  : get_resource_defaults
 * ***********************************************************/
/************************************************************
 * Bug - 3473324
 * Added parameter x_incur_by_res_type, to get the res_type_code
 * for incur by resource.
 **********************************************************/
PROCEDURE get_resource_defaults (
P_resource_list_members		IN 	        SYSTEM.PA_NUM_TBL_TYPE,
P_project_id			IN 	        PA_PROJECTS_ALL.PROJECT_ID%TYPE,
X_resource_class_flag		OUT NOCOPY	SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
X_resource_class_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_resource_class_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_res_type_code			OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_incur_by_res_type		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_person_id			OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_job_id			OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_person_type_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_named_role			OUT NOCOPY	SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
X_bom_resource_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_non_labor_resource		OUT NOCOPY	SYSTEM.PA_VARCHAR2_20_TBL_TYPE,
X_inventory_item_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_item_category_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_project_role_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_organization_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_fc_res_type_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_expenditure_type		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_expenditure_category		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_event_type			OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_revenue_category_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_supplier_id			OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_spread_curve_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_etc_method_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_mfc_cost_type_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_incurred_by_res_flag		OUT NOCOPY	SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
X_incur_by_res_class_code	OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_incur_by_role_id		OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_unit_of_measure		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_org_id			OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_rate_based_flag		OUT NOCOPY	SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
X_rate_expenditure_type		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
X_rate_func_curr_code		OUT NOCOPY	SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
-- X_rate_incurred_by_org_id	OUT NOCOPY	SYSTEM.PA_NUM_TBL_TYPE,
X_msg_data			OUT NOCOPY	VARCHAR2,
X_msg_count			OUT NOCOPY	NUMBER,
X_return_status			OUT NOCOPY	VARCHAR2)
IS
--Declaration of Tables used for Bulk Fetch
	l_resource_list_member_id 	SYSTEM.PA_NUM_TBL_TYPE;
	l_resource_class_flag		SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
	l_resource_class_code		SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_resource_class_id		SYSTEM.PA_NUM_TBL_TYPE;
	l_person_id			SYSTEM.PA_NUM_TBL_TYPE;
	l_job_id			SYSTEM.PA_NUM_TBL_TYPE;
        l_person_type_code		SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_named_role			SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_bom_resource_id		SYSTEM.PA_NUM_TBL_TYPE;
	l_non_labor_resource		SYSTEM.PA_VARCHAR2_20_TBL_TYPE;
	l_inventory_item_id		SYSTEM.PA_NUM_TBL_TYPE;
	l_item_category_id		SYSTEM.PA_NUM_TBL_TYPE;
	l_project_role_id		SYSTEM.PA_NUM_TBL_TYPE;
	l_organization_id		SYSTEM.PA_NUM_TBL_TYPE;
	l_fc_res_type_code		SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_expenditure_type		SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_expenditure_category		SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_event_type			SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_revenue_category_code		SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_supplier_id			SYSTEM.PA_NUM_TBL_TYPE;
	l_spread_curve_id		SYSTEM.PA_NUM_TBL_TYPE;
	l_etc_method_code		SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_mfc_cost_type_id		SYSTEM.PA_NUM_TBL_TYPE;
	l_incurred_by_res_flag		SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
	l_incur_by_res_class_code	SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
	l_incur_by_role_id		SYSTEM.PA_NUM_TBL_TYPE;
        l_rate_expenditure_type         SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
        l_rate_incurred_by_org_id       SYSTEM.PA_NUM_TBL_TYPE;
        l_rate_based_flag               SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
        l_exception                     EXCEPTION;
        l_last_analyzed                 all_tables.last_analyzed%TYPE;
        l_pa_schema                     VARCHAR2(30);
/*********************************************
 * * Main Block
 * ***********************************************/
BEGIN
      --Initialize the x_return_status
      X_Return_Status      := Fnd_Api.G_Ret_Sts_Success;

      --For bug 4039707, 4887312

-- Commenting out for TEMP fix to bug 4887312 - proper fix will be done soon.
/*
         FND_STATS.SET_TABLE_STATS('PA',
                           'PA_RES_MEMBERS_TEMP',
                           100,
                           10,
                           100);

         FND_STATS.SET_TABLE_STATS('PA',
                           'PA_RES_MEMBER_ID_TEMP',
                           100,
                           10,
                           100);
*/
      --End of bug 4039707, 4887312

    -- Proper Fix for 4887312 *** RAMURTHY  03/01/06 02:33 pm ***
    -- It solves the issue above wrt commit by the FND_STATS.SET_TABLE_STATS call

    PA_TASK_ASSIGNMENT_UTILS.set_table_stats('PA','PA_RES_MEMBERS_TEMP',100,10,100);
    PA_TASK_ASSIGNMENT_UTILS.set_table_stats('PA','PA_RES_MEMBER_ID_TEMP',100,10,100);

    -- End Bug fix 4887312

    /***********************************************
    * Deleting from the temp tables in the beginning as well
    * to be on the safe side.
    ***********************************************/
    DELETE FROM pa_res_members_temp;

    DELETE FROM pa_res_member_id_temp;
  /************************************************************
   * Created a script to create 2 tables in the DB
   * 1. pa_res_member_id_temp which would only hold the
   *    resource_list_member_id
   * 2. pa_res_members_temp which would hold the
   *    resource_list_member_id and all the other attributes
   *    which need to be defaulted
  *************************************************************/

  /***************************************************************
   * First insert into the pa_res_member_id_temp table just the
   * resource_list_member_id which have been passed as IN param's
   **************************************************************/
  FOR i in p_resource_list_members.first..p_resource_list_members.last
    LOOP
     INSERT INTO pa_res_member_id_temp
             (resource_list_member_id,
              order_id)
     VALUES(p_resource_list_members(i),
            i);
    END LOOP;

/********************************************************
 * Bug         : 3473425
 * Description : When Duplicate resource list member ID's
 *               were passed as IN parameters into the PL/SQL
 *               table, this proc was failing. To rectify that
 *               we have now induded a column order_id in the
 *               pa_res_members_temp table. And in the below insert
 *               we are populating value into it, same as the order
 *               id in pa_res_members_id_temp.
 *********************************************************/
    INSERT INTO pa_res_members_temp
             (resource_list_member_id,
              order_id,
              resource_class_flag		,
              resource_class_code		,
              resource_class_id			,
              --Added column newly
              res_type_code                     ,
              person_id			        ,
              job_id				,
              person_type_code		        ,
              named_role			,
              bom_resource_id			,
              non_labor_resource		,
              inventory_item_id		        ,
              item_category_id			,
              project_role_id			,
              organization_id			,
              fc_res_type_code			,
              expenditure_type			,
              expenditure_category		,
              Event_type			,
              revenue_category		        ,
              vendor_id			        ,
              spread_curve_id			,
              etc_method_code			,
              mfc_cost_type_id			,
              incurred_by_res_flag		,
              incur_by_res_class_code		,
              incur_by_role_id			,
              unit_of_measure			,
              org_id				,
              rate_based_flag			,
              rate_expenditure_type		,
              rate_func_curr_code		,
              rate_incurred_by_org_id	)
  SELECT  /*+ ORDERED */
              a.resource_list_member_id           ,
              b.order_id,
              a.resource_class_flag               ,
              a.resource_class_code               ,
              a.resource_class_id                 ,
              typ.res_type_code                   ,
              a.person_id                         ,
              a.job_id                            ,
              a.person_type_code                  ,
              a.team_role                         ,
              a.bom_resource_id                   ,
              a.non_labor_resource                ,
              a.inventory_item_id                 ,
              a.item_category_id                  ,
	      a.project_role_id			  ,
              a.organization_id			  ,
              a.fc_res_type_code		  ,
              a.expenditure_type		  ,
              a.expenditure_category		  ,
              a.Event_type			  ,
              a.revenue_category		  ,
              a.vendor_id			  ,
              a.spread_curve_id			  ,
              a.etc_method_code			  ,
              a.mfc_cost_type_id		  ,
              a.incurred_by_res_flag		  ,
              a.incur_by_res_class_code		  ,
              a.incur_by_role_id                  ,
              NULL                                ,
              NULL                                ,
              NULL                                ,
              NULL                                ,
              NULL                                ,
              NULL
             FROM pa_res_member_id_temp b,
                  pa_resource_list_members a,
		  pa_res_formats_b fmt,
	          pa_res_types_b typ
             WHERE a.resource_list_member_id = b.resource_list_member_id
               AND a.res_format_id = fmt.res_format_id
               AND fmt.res_type_id = typ.res_type_id(+);

      /************************************************************
      * Bug 3466920
      * Bug Fix - Earlier we were not updating the res_type_code
      * for an incurred by resource. Hence it was always getting passed
      * as Null. We have however fixed the issue with the below Update.
      * This Update will fire when if the res_type_code is still null
      * and the incurred_by_res_flag='Y'
      ****************************************************************/
      UPDATE pa_res_members_temp res_temp
      SET res_type_code = DECODE(res_temp.person_id, NULL,
                     DECODE(res_temp.job_id, NULL,
                      DECODE(res_temp.person_type_code, NULL,
                       DECODE(res_temp.incur_by_role_id, NULL,
                        DECODE(res_temp.incur_by_res_class_code, NULL,
                         NULL, 'RESOURCE_CLASS'),
                        'ROLE'),
                       'PERSON_TYPE'),
                      'JOB'),
                     'NAMED_PERSON')
      WHERE incurred_by_res_flag = 'Y'
      AND res_type_code IS NULL;

  /******************************************************************
   * Call the Procedure Default_job which will Update the Job ID
   * in the temp table pa_res_members_temp with the correct
   * value.
   * *****************************************************************/
   pa_planning_resource_utils.default_job;

  /******************************************************************
   * Call the Procedure default_person_type which will Update the
   * person_type_code in the temp table pa_res_members_temp with the correct
   * value.
   * *****************************************************************/
   pa_planning_resource_utils.default_person_type;

   /******************************************************************
   * Call the Procedure Default_Organization  which will
   * Update the organization_id and rate_incurred_by_org_id
   * in the temp table pa_res_members_temp with the correct
   * values.
   * *****************************************************************/
   pa_planning_resource_utils.default_organization(
           p_project_id => p_project_id);

  /******************************************************************
   * Call the Procedure Default_Expenditure_Type  which will
   * Update the expenditure_type
   * in the temp table pa_res_members_temp with the correct
   * values.
   * *****************************************************************/
   pa_planning_resource_utils.default_expenditure_type;

  /******************************************************************
   * Call the Procedure Default_Rate_Expenditure_Type  which will
   * Update the rate_expenditure_type
   * in the temp table pa_res_members_temp with the correct
   * values.
   * *****************************************************************/
   pa_planning_resource_utils.default_rate_expenditure_type;

   /******************************************************************
   * Call the Procedure Default_Supplier  which will
   * Update the vendor_id
   * in the temp table pa_res_members_temp with the correct
   * values.
   * *****************************************************************/
   pa_planning_resource_utils.default_supplier;

   /******************************************************************
   * Call the Procedure Default_rate_based  which will
   * Update the Rate_based_flag
   * in the temp table pa_res_members_temp with the correct
   * values.
   * *****************************************************************/
   pa_planning_resource_utils.default_rate_based;

  /******************************************************************
   * Call the Procedure Default_OU which will
   * Update the OU
   * in the temp table pa_res_members_temp with the correct
   * values.
   *****************************************************************/
   pa_planning_resource_utils.default_ou(p_project_id);

   /******************************************************************
   * Call the Procedure Default_UOM  which will
   * Update the Unit_of_measure
   * in the temp table pa_res_members_temp with the correct
   * values.
   *****************************************************************/
   pa_planning_resource_utils.default_uom;

   /******************************************************************
   * Call the Procedure Default_Currency_Code  which will
   * Update the Rate_Func_Curr_Code
   * in the temp table pa_res_members_temp with the correct
   * values.
   *****************************************************************/
    pa_planning_resource_utils.default_currency_code;

   /*****************************************************************
    * Fetch the values that are currently there in the pa_res_members_temp
    * table into the out var's.  Select it from the Temp table
    * pa_res_members_temp and Bulk collect it into the OUT var's.
    *********************************************************************/
    /**********************************************************
     * Added an extra order ID join between the pa_res_members_temp
     * and pa_res_member_id_temp table to keep in sync.
     * Bug - 3473425
     **********************************************************/
     /*********************************************************
     * Bug - 3473324
     * Desc - If the incurred_by res_flag was 'N' or Null then we would
     *        populate the res_type_code into the x_res_type_code parameter.
     *        If the incur_by_res_flag was 'Y' then we would populate the
     *        res_type_code into the x_incur_by_res_type parameter.
     ********************************************************/
     SELECT
        a.RESOURCE_CLASS_FLAG,
        a.RESOURCE_CLASS_CODE,
        a.RESOURCE_CLASS_ID,
        decode(a.incurred_by_res_flag,'Y',Null,a.RES_TYPE_CODE),
        decode(a.incurred_by_res_flag,'Y',a.RES_TYPE_CODE,Null),
        a.PERSON_ID,
        a.JOB_ID,
        a.PERSON_TYPE_CODE,
        a.NAMED_ROLE ,
        a.BOM_RESOURCE_ID,
        a.NON_LABOR_RESOURCE,
        a.INVENTORY_ITEM_ID,
        a.ITEM_CATEGORY_ID,
        a.PROJECT_ROLE_ID,
        a.ORGANIZATION_ID,
        a.FC_RES_TYPE_CODE,
        a.EXPENDITURE_TYPE,
        a.EXPENDITURE_CATEGORY,
        a.EVENT_TYPE,
        a.REVENUE_CATEGORY,
        a.VENDOR_ID,
        a.SPREAD_CURVE_ID,
        a.ETC_METHOD_CODE,
        a.MFC_COST_TYPE_ID,
        a.INCURRED_BY_RES_FLAG,
        a.INCUR_BY_RES_CLASS_CODE,
        a.INCUR_BY_ROLE_ID,
        a.UNIT_OF_MEASURE,
        a.ORG_ID,
        a.RATE_BASED_FLAG,
        a.RATE_EXPENDITURE_TYPE,
        a.RATE_FUNC_CURR_CODE
        --a.RATE_INCURRED_BY_ORG_ID
     BULK COLLECT INTO
        x_resource_class_flag           ,
        x_resource_class_code           ,
        x_resource_class_id             ,
        x_res_type_code                 ,
        x_incur_by_res_type             ,
        x_person_id                     ,
        x_job_id                        ,
        x_person_type_code              ,
        x_named_role                    ,
        x_bom_resource_id               ,
        x_non_labor_resource            ,
        x_inventory_item_id             ,
        x_item_category_id              ,
        x_project_role_id               ,
        x_organization_id               ,
        x_fc_res_type_code              ,
        x_expenditure_type              ,
        x_expenditure_category          ,
        x_event_type                    ,
        x_revenue_category_code         ,
        x_supplier_id                   ,
        x_spread_curve_id               ,
        x_etc_method_code               ,
        x_mfc_cost_type_id              ,
        x_incurred_by_res_flag          ,
        x_incur_by_res_class_code       ,
        x_incur_by_role_id              ,
        x_unit_of_measure               ,
        x_org_id                        ,
        x_rate_based_flag               ,
        x_rate_expenditure_type         ,
        x_rate_func_curr_code
        -- x_rate_incurred_by_org_id
   FROM pa_res_members_temp a,
        pa_res_member_id_temp b
   WHERE a.resource_list_member_id = b.resource_list_member_id
   AND   a.order_id  = b.order_id
   ORDER BY b.order_id;

   IF x_resource_class_id.COUNT <> p_resource_list_members.COUNT then
       X_Return_Status   := Fnd_Api.G_RET_STS_UNEXP_ERROR;
       RAISE l_exception;
    END IF;

   DELETE FROM pa_res_members_temp;

   DELETE FROM pa_res_member_id_temp;

EXCEPTION
 WHEN l_exception THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Return;
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Return;
END Get_Resource_defaults;


/*********************************************************
 * Eugene's code
 ********************************************************/

/*********************************************************
 *Type (Procedure or Procedure): Function
 *Package Object Name          : Ret_Resource_Name
 *Purpose:                       Return the resource name from a given
 *			         resource type code and id.
 * Public or Private API?       Public
 * *******************************************************/
  Function Ret_Resource_Name (P_Res_Type_Code      IN Varchar2,
			       P_Person_Id          IN Number,
			       P_Bom_Resource_Id    IN Number,
    			       P_Job_Id             IN Number,
			       P_Person_Type_Code   IN Varchar2,
			       P_Non_Labor_Resource IN Varchar2,
			       P_Inventory_Item_Id  IN Number,
			       P_Resource_Class_Id  IN Number,
			       P_Item_Category_Id   IN Number,
                               p_res_assignment_id  IN NUMBER default null ) Return Varchar2

  Is

	l_Return_Status Varchar2(1)    := Null;
	l_Msg_Data	Varchar2(30)   := Null;
	l_Resource_Name Varchar2(1000) := Null;

  Begin

	pa_planning_resource_utils.Get_Resource_Name (
                           P_Res_Type_Code      => P_Res_Type_Code,
			   P_Person_Id          => P_Person_Id,
			   P_Bom_Resource_Id    => P_Bom_Resource_Id,
    			   P_Job_Id             => P_Job_Id,
			   P_Person_Type_Code   => P_Person_Type_Code,
			   P_Non_Labor_Resource => P_Non_Labor_Resource,
			   P_Inventory_Item_Id  => P_Inventory_Item_id,
			   P_Item_Category_Id   => P_Item_Category_Id,
			   P_Resource_Class_Id	=> P_Resource_Class_Id,
			   P_Proc_Func_Flag     => 'F',
                           p_res_assignment_id  => p_res_assignment_id,
			   X_Resource_Displayed => l_Resource_Name,
		 	   X_Return_Status      => l_Return_Status,
			   X_Msg_Data           => l_Msg_Data );

	Return l_Resource_Name;

  Exception
	When Others Then
		Raise;

  End Ret_Resource_Name;
/*****************************************/

/***************************************************************
 * Type (Procedure or Procedure): Procedure
 * Package Object Name:           Get_Resource_Name
 **************************************************************/
  Procedure Get_Resource_Name ( P_Res_Type_Code            IN Varchar2,
			        P_Person_Id                IN Number,
			        P_Bom_Resource_Id          IN Number,
    			        P_Job_Id                   IN Number,
			        P_Person_Type_Code         IN Varchar2,
			        P_Non_Labor_Resource       IN Varchar2,
			        P_Inventory_Item_Id        IN Number,
			        P_Item_Category_Id         IN Number,
				P_Resource_Class_Id	   IN Number,
				P_Proc_Func_Flag           IN Varchar2,
                                P_Res_Assignment_Id        IN NUMBER,
				X_Resource_Displayed       OUT NOCOPY Varchar2,
		 		X_Return_Status            OUT NOCOPY Varchar2,
				X_Msg_Data    	           OUT NOCOPY Varchar2 )

  Is

	l_Res_Type_Displayed          Varchar2(1000) := Null;

	--BAD_PER_IN_RES_LIST_MEM       Exception;
	--NULL_PER_IN_RES_LIST_MEM      Exception;
	--BAD_JOB_IN_RES_LIST_MEM       Exception;
	--NULL_JOB_IN_RES_LIST_MEM      Exception;
	--BAD_PER_TYPE_IN_LIST_MEM      Exception;
	--NULL_PER_TYPE_IN_LIST_MEM     Exception;
	BAD_BOM_LABOR_RES_IN_LST_MEM  Exception;
	NULL_BOM_LABOR_RES_IN_LST_MEM Exception;
	BAD_BOM_EQUIP_RES_IN_LST_MEM  Exception;
	NULL_BOM_EQUIP_RES_IN_LST_MEM Exception;
	BAD_ITEM_CAT_IN_LST_MEM       Exception;
	NULL_ITEM_CAT_IN_LST_MEM      Exception;
	BAD_INVEN_ITEM_IN_LST_MEM     Exception;
	NULL_INVEN_ITEM_IN_LST_MEM    Exception;
	--NULL_NLR_IN_LIST_MEM	      Exception;
	--BAD_RESCLASS_IN_LIST_MEM      Exception;
	--NULL_RESCLASS_IN_LIST_MEM     Exception;
        UNEXPEC_ERROR                 Exception;
       /*************************************************
        * Bug         - 3485392
        * Description - Using the Known_as field from the
        *               Per_people_x table to derive the
        *               resource_name. If the known_as field is
        *               Null then select the full_name.
        *************************************************/
	Cursor c_People (P_Person_Id IN Number) is
	Select
		--nvl(known_as,Full_Name)
                --Bug 3485392
		Full_Name
	From
		Per_People_X
	Where
		Person_Id = P_Person_Id
	And     ( (Pa_Cross_Business_Grp.IsCrossBGProfile = 'N' AND
		   Fnd_Profile.Value('PER_BUSINESS_GROUP_ID') = Business_Group_Id)
		  OR Pa_Cross_Business_Grp.IsCrossBGProfile = 'Y');

	Cursor c_Job (P_Job_Id In Number) Is
	Select
		Name
	From
		Per_Jobs
	Where
		Job_Id = P_Job_Id
	And     ( (Pa_Cross_Business_Grp.IsCrossBGProfile = 'N' AND
		   Fnd_Profile.Value('PER_BUSINESS_GROUP_ID') = Per_Jobs.Business_Group_Id )
		  OR Pa_Cross_Business_Grp.IsCrossBGProfile = 'Y');

	Cursor c_PersonType (P_Person_Type IN Varchar2) Is
	Select
		Meaning
	From
		pa_lookups
	Where
		Lookup_Type = 'PA_PERSON_TYPE'
	And	Lookup_Code = P_Person_Type;

       /*************************************************
        * Bug - 3461494
        * Description - Using the Resource code field from the
        *               Bom_Resources table to derive the
        *               resource_name instead of using the
        *               description.
        *************************************************/
	Cursor c_BOM (P_BOM_Res_Id IN Number) Is
	Select
		Resource_code
	From
		Bom_Resources
	Where
		Resource_Id = P_BOM_Res_Id;

	Cursor c_Item_Cat ( P_Item_Cat_Id IN Number ) Is
	Select fnd_Flex_ext.GET_SEGS('INV', 'MCAT', c.structure_id, c.category_id)
	From   mtl_categories_v c
	Where  c.Category_Id = P_Item_Cat_Id;

        /**********************************************************
        * Bug - 3566965
        * Desc - Instead of the description we are now selecting the
        *        segment1 field from Mtl_System_Items_b table as the
        *        resource name.
        **********************************************************/
	Cursor c_Inven_Item (P_Inven_Item_Id IN Number ) Is
	Select
		segment1
	From
		Mtl_System_Items_b
	Where
		--Language = USERENV('LANG')
	Inventory_Item_Id = P_Inven_Item_Id
        and 	organization_id =
				(select
					item_master_id
                                 from
					pa_resource_classes_b cls,
                               		pa_plan_res_defaults def
                                 where
					def.resource_class_id = cls.resource_class_id
                                 and 	cls.resource_class_code = 'MATERIAL_ITEMS'
                                 and 	def.object_type = 'CLASS');

	Cursor c_ResClass (P_Res_Class_Id IN Number) Is
	Select
		Name
	From
		Pa_Resource_Classes_Vl
	Where
		Resource_Class_Id = P_Res_Class_Id;

	Cursor c_PrjRoles (P_Prj_Role_Id IN Number) Is
	Select
		Meaning
	From
		Pa_Project_Role_Types_vl
	Where
		Project_Role_Id = P_Prj_Role_Id;

       Cursor c_Res_Attributes Is
       Select
                a.Res_Type_Code Res_Type_Code,
                a.Person_Id Person_Id,
                a.Job_Id Job_Id,
                a.Bom_Resource_Id Bom_Resource_Id,
                a.Inventory_Item_Id Inventory_Item_Id,
                a.Item_Category_Id Item_Category_Id,
                a.Person_Type_Code Person_Type_Code,
                a.Non_Labor_Resource Non_Labor_Resource,
                a.incurred_by_res_flag incurred_by_res_flag,
                c.Resource_Class_Id
       From
		Pa_Resource_Assignments a
	       ,Pa_Resource_Classes_b c
       Where
		c.Resource_Class_Code = a.Resource_Class_Code
       And      a.Resource_Assignment_Id = P_Res_Assignment_Id;


       l_Res_Attributes 	c_Res_Attributes%RowType;
       l_Person_Id 		Number;
       l_Job_Id 		Number;
       l_Inventory_Item_Id 	Number;
       l_Item_Category_Id 	Number;
       l_Non_Labor_Resource 	Varchar2(20);
       l_Bom_Resource_Id 	Number;
       l_Resource_Class_Id 	Number;
       l_Person_Type_Code 	Varchar2(30);
       l_Res_Type_Code 		Varchar2(30);

Begin

	If P_Res_Assignment_Id Is Not Null Then

      		Open c_Res_Attributes;
      		Fetch c_Res_Attributes Into l_Res_Attributes;
      		Close c_Res_Attributes;

           IF l_Res_Attributes.incurred_by_res_flag <> 'Y' THEN
      		l_Person_Id          := l_Res_Attributes.Person_Id;
      		l_Job_Id             := l_Res_Attributes.Job_Id;
      		l_Inventory_Item_Id  := l_Res_Attributes.Inventory_Item_Id;
     		l_Item_Category_Id   := l_Res_Attributes.Item_Category_Id;
      		l_Bom_Resource_Id    := l_Res_Attributes.Bom_Resource_Id;
      		l_Resource_Class_Id  := l_Res_Attributes.Resource_Class_Id;
      		l_Non_Labor_Resource := l_Res_Attributes.Non_Labor_Resource;
      		l_Person_Type_Code   := l_Res_Attributes.Person_Type_Code;
      		l_Res_Type_Code      := l_Res_Attributes.Res_Type_Code;
           ELSE
                X_Resource_Displayed := NULL;
                RETURN; -- added to not do anything for incurred by resources
           END IF;

	Else

      		l_Person_Id          := P_Person_Id;
      		l_Job_Id             := P_Job_Id;
      		l_Inventory_Item_Id  := P_Inventory_Item_Id;
      		l_Item_Category_Id   := P_Item_Category_Id;
      		l_Bom_Resource_Id    := P_Bom_Resource_Id;
      		l_Resource_Class_Id  := P_Resource_Class_Id;
      		l_Non_Labor_Resource := P_Non_Labor_Resource;
      		l_Person_Type_Code   := P_Person_Type_Code;
      		l_Res_Type_Code      := P_Res_Type_Code;

	End If;

	If l_Res_Type_Code = 'NAMED_PERSON' Then

		If l_Person_Id is Not Null Then

			Open c_People(P_Person_Id => l_Person_Id);
			Fetch c_People Into l_Res_Type_Displayed;
			If c_People%NotFound Then
				Close c_People;
				--Raise BAD_PER_IN_RES_LIST_MEM;
				Raise UNEXPEC_ERROR;
			End If;
			Close c_People;

		Else

			--Raise NULL_PER_IN_RES_LIST_MEM;
			Raise UNEXPEC_ERROR;

		End If;

	ElsIf l_Res_Type_Code = 'JOB' Then

		If l_Job_Id is Not Null Then

			Open c_Job(P_Job_Id => l_Job_Id);
			Fetch c_Job Into l_Res_Type_Displayed;
			If c_Job%NOTFOUND Then
				Close c_job;
				--Raise BAD_JOB_IN_RES_LIST_MEM;
				Raise UNEXPEC_ERROR;
			End If;
			Close c_Job;

		Else

			--Raise NULL_JOB_IN_RES_LIST_MEM;
			Raise UNEXPEC_ERROR;

		End If;

	ElsIf l_Res_Type_Code = 'PERSON_TYPE' Then

		If l_Person_Type_Code is Not Null Then

			-- CWK, EMP
			-- Get meaning from fnd_common_lookups
			Open c_PersonType(P_Person_Type => l_Person_Type_Code);
			Fetch c_PersonType Into l_Res_Type_Displayed;
			If c_PersonType%NOTFOUND Then
				Close c_PersonType;
				--Raise BAD_PER_TYPE_IN_LIST_MEM;
				Raise UNEXPEC_ERROR;
			End If;
			Close c_PersonType;

		Else

			--Raise NULL_PER_TYPE_IN_LIST_MEM;
			Raise UNEXPEC_ERROR;

		End If;

	ElsIf l_Res_Type_Code = 'BOM_LABOR' Then

		If l_Bom_Resource_Id is Not Null Then

			Open c_BOM(P_BOM_Res_Id => l_Bom_Resource_Id);
			Fetch c_BOM into l_Res_Type_Displayed;

			If c_BOM%NotFound Then

				Close c_BOM;
				Raise BAD_BOM_LABOR_RES_IN_LST_MEM;

			End If;

			Close c_BOM;

		Else

			Raise NULL_BOM_LABOR_RES_IN_LST_MEM;

		End If;


	ElsIf l_Res_Type_Code = 'BOM_EQUIPMENT' Then

		If l_Bom_Resource_Id is Not Null Then

			Open c_BOM(P_BOM_Res_Id => l_Bom_Resource_Id);
			Fetch c_BOM into l_Res_Type_Displayed;

			If c_BOM%NotFound Then

				Close c_BOM;
				Raise BAD_BOM_EQUIP_RES_IN_LST_MEM;

			End If;

			Close c_BOM;

		Else

			Raise NULL_BOM_EQUIP_RES_IN_LST_MEM;

		End If;

	ElsIf l_Res_Type_Code = 'ITEM_CATEGORY' Then

		If l_Item_Category_Id is Not Null Then

			Open c_Item_Cat(P_Item_Cat_Id => l_Item_Category_Id);
			Fetch c_Item_Cat into l_Res_Type_Displayed;

			If c_Item_Cat%NotFound Then

				Close c_Item_Cat;
				Raise BAD_ITEM_CAT_IN_LST_MEM;

			End If;

			Close c_Item_Cat;

		Else

			Raise NULL_ITEM_CAT_IN_LST_MEM;

		End If;

	ElsIf l_Res_Type_Code = 'INVENTORY_ITEM' Then

		If l_Inventory_Item_Id is Not Null Then

			Open c_Inven_Item(P_Inven_Item_Id => l_Inventory_Item_Id);
			Fetch c_Inven_Item into l_Res_Type_Displayed;

			If c_Inven_Item%NotFound Then

				Close c_Inven_Item;
				Raise BAD_INVEN_ITEM_IN_LST_MEM;

			End If;

			Close c_Inven_Item;

		Else

			Raise NULL_INVEN_ITEM_IN_LST_MEM;

		End If;

	ElsIf l_Res_Type_Code = 'NON_LABOR_RESOURCE' Then

		If l_Non_Labor_Resource is Not Null Then

			l_Res_Type_Displayed := l_Non_Labor_Resource;

		Else

			--Raise NULL_NLR_IN_LIST_MEM;
			Raise UNEXPEC_ERROR;

		End If;

	ElsIf l_Res_Type_Code = 'RESOURCE_CLASS' Then

		If l_Resource_Class_Id is Not Null Then

			-- get name from pa_resource_classes_vl
			Open c_ResClass(P_Res_Class_Id => l_Resource_Class_Id);
			Fetch c_ResClass into l_Res_Type_Displayed;
			If c_ResClass%NOTFOUND Then

				Close c_ResClass;
				--Raise BAD_RESCLASS_IN_LIST_MEM;
				Raise UNEXPEC_ERROR;

			End If;
			Close c_ResClass;

		Else

			--Raise NULL_RESCLASS_IN_LIST_MEM;
			Raise UNEXPEC_ERROR;

		End If;

	End If;

	X_Return_Status           := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Data                := Null;
	X_Resource_Displayed	  := l_Res_Type_Displayed;

  Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_msg_data := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Get_Resource_Name');

              Return;
     /*	When NULL_PER_IN_RES_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_PER_IN_RES_LIST_MEM';
			Pa_Utils.Add_Message
               			(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_NULL_PER_IN_RES_LIST_MEM');
		Else

			X_Resource_Displayed := Null;

		End If;*/
	/*When BAD_PER_IN_RES_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_BAD_PER_IN_RES_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
        	        	 P_Msg_Name        => 'PA_BAD_PER_IN_RES_LIST_MEM');
		Else

			X_Resource_Displayed := Null;

		End If;*/

	/*When NULL_JOB_IN_RES_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_JOB_IN_RES_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_NULL_JOB_IN_RES_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;*/
	/*When BAD_JOB_IN_RES_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_BAD_JOB_IN_RES_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_BAD_JOB_IN_RES_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;*/
	/*When NULL_PER_TYPE_IN_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_PER_TYPE_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_PER_TYPE_IN_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;*/
	/*When BAD_PER_TYPE_IN_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_BAD_PER_TYPE_IN_LIST_MEM';
			Pa_Utils.Add_Message
	        		(P_App_Short_Name  => 'PA',
        	        	 P_Msg_Name        => 'PA_BAD_PER_TYPE_IN_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;*/
	When BAD_BOM_LABOR_RES_IN_LST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_BAD_BOM_LABOR_RES_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_BAD_BOM_LABOR_RES_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;
	When NULL_BOM_LABOR_RES_IN_LST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_BOM_LABOR_RES_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_BOM_LABOR_RES_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;
	When BAD_BOM_EQUIP_RES_IN_LST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_BAD_BOMEQUIP_RES_IN_LST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_BAD_BOMEQUIP_RES_IN_LST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;
	When NULL_BOM_EQUIP_RES_IN_LST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_BOM_EQUIP_RES_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_BOM_EQUIP_RES_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;
	When BAD_ITEM_CAT_IN_LST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_BAD_ITEM_CAT_IN_LST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_BAD_ITEM_CAT_IN_LST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;
	When NULL_ITEM_CAT_IN_LST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_ITEM_CAT_IN_LST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_ITEM_CAT_IN_LST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;
	When BAD_INVEN_ITEM_IN_LST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_BAD_INVEN_ITEM_IN_LST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_BAD_INVEN_ITEM_IN_LST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;
	When NULL_INVEN_ITEM_IN_LST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_INVEN_ITEM_IN_LST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_INVEN_ITEM_IN_LST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;
	/*When NULL_NLR_IN_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_NLR_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_NLR_IN_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;*/
	/*When NULL_RESCLASS_IN_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_NULL_RESCLASS_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_RESCLASS_IN_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;*/
	/*When BAD_RESCLASS_IN_LIST_MEM Then
		If P_Proc_Func_Flag = 'P' Then
			X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data		:= 'PA_BAD_RESCLASS_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_BAD_RESCLASS_IN_LIST_MEM');
		Else
			X_Resource_Displayed := Null;
		End If;*/
	When Others Then
		Raise;

  End Get_Resource_Name;
/**************************************************/
 /***********************************************************
 *Type (Procedure or Procedure): Function
 *Package Object Name:           Ret_Fin_Category_Name
 *Purpose:                       Return the resource name from a given
 *    				  resource type code.
 *Public or Private API?
 **************************************************************/
  Function Ret_Fin_Category_Name ( P_FC_Res_Type_Code      IN Varchar2,
			           P_Expenditure_Type      IN Varchar2,
			           P_Expenditure_Category  IN Varchar2,
			           P_Event_Type            IN Varchar2,
			           P_Revenue_Category_Code IN Varchar2,
                                   p_res_assignment_id  IN NUMBER default null) Return Varchar2
  Is

	l_Return_Status     Varchar2(1)    := Null;
	l_Msg_Data	    Varchar2(30)   := Null;
	l_Fin_Cat_Displayed Varchar2(80)   := Null;

  Begin

	Pa_Planning_Resource_Utils.Get_Fin_Category_Name (
                P_FC_Res_Type_Code      => P_FC_Res_Type_Code,
	        P_Expenditure_Type      => P_Expenditure_Type,
	        P_Expenditure_Category  => P_Expenditure_Category,
                P_Event_Type            => P_Event_Type,
	        P_Revenue_Category_Code => P_Revenue_Category_Code,
	        P_Proc_Func_Flag        => 'F',
                p_res_assignment_id     => p_res_assignment_id,
	        X_Fin_Cat_Displayed     => l_Fin_Cat_Displayed,
 	        X_Return_Status         => l_Return_Status,
	        X_Msg_Data              => l_Msg_Data );

	Return l_Fin_Cat_Displayed;

  Exception
	When Others Then
		Raise;

  End Ret_Fin_Category_Name;


/**************************************************************
 * Procedure : Get_Fin_Category_Name
 * ***********************************************************/

Procedure Get_Fin_Category_Name ( P_FC_Res_Type_Code        IN Varchar2,
			            P_Expenditure_Type      IN Varchar2,
			            P_Expenditure_Category  IN Varchar2,
			            P_Event_Type            IN Varchar2,
			            P_Revenue_Category_Code IN Varchar2,
			            P_Proc_Func_Flag        IN Varchar2,
                                    P_Res_Assignment_Id     IN NUMBER default null,
                                    X_Fin_Cat_Displayed    OUT NOCOPY Varchar2,
		 	            X_Return_Status        OUT NOCOPY Varchar2,
			            X_Msg_Data    	   OUT NOCOPY Varchar2 )

  Is

	l_Fin_Cat_Displayed          Varchar2(80)   := Null;

	--NULL_EXP_TYPE_IN_LIST_MEM    Exception;
	--NULL_EXP_CAT_IN_LIST_MEM     Exception;
	--NULL_EVENT_TYPE_IN_LIST_MEM  Exception;
	--NULL_REV_CAT_IN_LIST_MEM     Exception;
	--NULL_FC_RES_TYPE_IN_LIST_MEM Exception;
	INV_FC_RES_TYPE_IN_LIST_MEM  Exception;
	UNEXPEC_ERROR                Exception;

	Cursor c_Res_Attributes
        Is
        Select
		Fc_Res_Type_Code,
		Expenditure_Type,
		Expenditure_Category,
       		Event_Type,
		Revenue_Category_Code
       	From
		Pa_Resource_Assignments
       	Where
		Resource_Assignment_Id = P_Res_Assignment_Id;

       l_Res_Attributes c_Res_Attributes%RowType;
       l_Fc_Res_Type_Code      Varchar2(30);
       l_Expenditure_Type      Varchar2(30);
       l_Expenditure_Category  Varchar2(30);
       l_Event_Type            Varchar2(30);
       l_Revenue_Category_Code Varchar2(30);

  Begin

	If P_Res_Assignment_Id Is Not Null Then

      		Open c_Res_Attributes;
      		Fetch c_Res_Attributes Into l_Res_Attributes;
      		Close c_Res_Attributes;

      		l_Fc_Res_Type_Code      := l_Res_Attributes.Fc_Res_Type_Code;
      		l_Expenditure_Type      := l_Res_Attributes.Expenditure_Type;
      		l_Expenditure_Category  := l_Res_Attributes.Expenditure_Category;
      		l_Event_Type            := l_Res_Attributes.Event_Type;
      		l_Revenue_Category_Code := l_Res_Attributes.Revenue_Category_Code;

	Else

      		l_Fc_Res_Type_Code      := P_Fc_Res_Type_Code;
     		l_Expenditure_Type      := P_Expenditure_Type;
      		l_Expenditure_Category  := P_Expenditure_Category;
      		l_Event_Type            := P_Event_Type;
      		l_Revenue_Category_Code := P_Revenue_Category_Code;

	End If;

	If l_FC_Res_Type_Code is Not Null Then

		If l_FC_Res_Type_Code = 'EXPENDITURE_TYPE' Then

			If l_Expenditure_Type is Not Null Then

				l_Fin_Cat_Displayed := l_Expenditure_Type;

			Else

				--Raise NULL_EXP_TYPE_IN_LIST_MEM;
				Raise UNEXPEC_ERROR;

			End If;

		ElsIf l_FC_Res_Type_Code = 'EXPENDITURE_CATEGORY' Then

			If l_Expenditure_Category is Not Null Then

				l_Fin_Cat_Displayed := l_Expenditure_Category;

			Else

				--Raise NULL_EXP_CAT_IN_LIST_MEM;
				Raise UNEXPEC_ERROR;

			End If;

		ElsIf l_FC_Res_Type_Code = 'EVENT_TYPE' Then

			If l_Event_Type is Not Null Then

				l_Fin_Cat_Displayed := l_Event_Type;

			Else

				--Raise NULL_EVENT_TYPE_IN_LIST_MEM;
				Raise UNEXPEC_ERROR;

			End If;

		ElsIf l_FC_Res_Type_Code = 'REVENUE_CATEGORY' Then

			If l_Revenue_Category_Code is Not Null Then

                              BEGIN

                                 SELECT lk.Meaning
                                 INTO l_Fin_Cat_Displayed
                                 FROM PA_LOOKUPS lk
                                 WHERE lk.Lookup_Type = 'REVENUE CATEGORY'
                                 and lk.lookup_code = l_revenue_category_code;

                              EXCEPTION
                                 WHEN OTHERS THEN
                                    l_Fin_Cat_Displayed := NULL;
                                    --Raise NULL_REV_CAT_IN_LIST_MEM;
                                    Raise UNEXPEC_ERROR;

                              END;

			Else

				--Raise NULL_REV_CAT_IN_LIST_MEM;
				Raise UNEXPEC_ERROR;

			End If;

		Else

			Raise INV_FC_RES_TYPE_IN_LIST_MEM;

		End If;

	Else

		--Raise NULL_FC_RES_TYPE_IN_LIST_MEM;
		-- Raise UNEXPEC_ERROR;
                -- Return null if resource/assignment does not have fin cat
                l_Fin_Cat_Displayed := NULL;

	End If; -- P_FC_Res_Type_Code is not null

	X_Return_Status     := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Data          := Null;
	X_Fin_Cat_Displayed := l_Fin_Cat_Displayed;

  Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_msg_data := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Get_Fin_Category_Name');
              Return;
	/*When NULL_FC_RES_TYPE_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_NULL_FC_RESTYPE_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_FC_RESTYPE_IN_LIST_MEM');
		Else

			X_Fin_Cat_Displayed := Null;

		End If;*/

	/*When NULL_EXP_TYPE_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_NULL_EXP_TYPE_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_EXP_TYPE_IN_LIST_MEM');

		Else

			X_Fin_Cat_Displayed := Null;

		End If;*/

	/*When NULL_EXP_CAT_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_NULL_EXP_CAT_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_EXP_CAT_IN_LIST_MEM');

		Else

			X_Fin_Cat_Displayed := Null;

		End If;*/

	/*When NULL_EVENT_TYPE_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_NULL_EVENT_TYPE_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_EVENT_TYPE_IN_LIST_MEM');

		Else

			X_Fin_Cat_Displayed := Null;

		End If;*/

	/*When NULL_REV_CAT_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_NULL_REV_CAT_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_NULL_REV_CAT_IN_LIST_MEM');

		Else

			X_Fin_Cat_Displayed := Null;

		End If;*/

	When INV_FC_RES_TYPE_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_INV_FC_RESTYPE_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_INV_FC_RESTYPE_IN_LIST_MEM');

		Else

			X_Fin_Cat_Displayed := Null;

		End If;

	When Others Then
		Raise;

  End Get_Fin_Category_Name;

/**************************************************/

/********************************************************
 * Function : Ret_Organization_Name
 * ********************************************************/
Function Ret_Organization_Name ( P_Organization_Id IN Number ) Return Varchar2

  Is

	l_Return_Status     Varchar2(1)   := Null;
	l_Msg_Data	    Varchar2(30)  := Null;
	l_Organization_Name Varchar2(240) := Null;

  Begin

	pa_planning_resource_utils.Get_Organization_Name (
                                P_Organization_Id => P_Organization_Id,
				P_Proc_Func_Flag  => 'F',
				X_Org_Displayed   => l_Organization_Name,
		 		X_Return_Status   => l_Return_Status,
				X_Msg_Data        => l_Msg_Data );

	Return l_Organization_Name;

  Exception
	When Others Then
		Raise;

  End Ret_Organization_Name;
/*************************************/
/********************************************************
 * Procedure : Get_Organization_name
 * *****************************************************/
 Procedure Get_Organization_Name ( P_Organization_Id IN Number,
				    P_Proc_Func_Flag  IN Varchar2,
				    X_Org_Displayed  OUT NOCOPY Varchar2,
		 		    X_Return_Status  OUT NOCOPY Varchar2,
				    X_Msg_Data       OUT NOCOPY Varchar2 )

  Is

	l_Org_Displayed        Varchar2(240)  := Null;

	--BAD_ORG_ID_IN_LIST_MEM  Exception;
	--NULL_ORG_ID_IN_LIST_MEM Exception;
	UNEXPEC_ERROR           Exception;

  Begin

	If P_Organization_Id is Not Null Then

		-- Get organization name from hr_all_organization_units_tl
		Begin

			l_Org_Displayed := Pa_Expenditures_Utils.GetOrgTlName(P_Organization_Id);

		Exception
			When Others Then
				--Raise BAD_ORG_ID_IN_LIST_MEM;
				Raise UNEXPEC_ERROR;
		End;

	Else

		--Raise NULL_ORG_ID_IN_LIST_MEM;
		-- Raise UNEXPEC_ERROR;
                l_Org_Displayed := NULL;

	End If;

	X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Data      := Null;
	X_Org_Displayed := l_Org_Displayed;

  Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_msg_data := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Get_Organization_Name');
              Return;
	/*When NULL_ORG_ID_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_NULL_ORG_ID_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_NULL_ORG_ID_IN_LIST_MEM');

		Else

			X_Org_Displayed := Null;

		End If;*/

	/*When BAD_ORG_ID_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_BAD_ORG_ID_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_BAD_ORG_ID_IN_LIST_MEM');

		Else

			X_Org_Displayed := Null;

		End If;*/

	When Others Then
		Raise;

  End Get_Organization_Name;
/***************************************/

/******************************************************************
 * Function : Ret_Supplier_Name
 * ****************************************************************/

  Function Ret_Supplier_Name ( P_Supplier_Id IN Number ) Return Varchar2

  Is

	l_Return_Status Varchar2(1)   := Null;
	l_Msg_Data	Varchar2(30)  := Null;
	l_Supplier_Name Varchar2(240) := Null;

  Begin

	Pa_Planning_Resource_Utils.Get_Supplier_Name(
        	P_Supplier_Id        => P_Supplier_Id,
		P_Proc_Func_Flag     => 'F',
		X_Supplier_Displayed => l_Supplier_Name,
		X_Return_Status      => l_Return_Status,
		X_Msg_Data           => l_Msg_Data );


	Return l_Supplier_Name;

  Exception
	When Others Then
		Raise;

  End Ret_Supplier_Name;
/*********************************/

/***************************************************
 * Procedure : Get_Supplier_Name
 * *************************************************/
   Procedure Get_Supplier_Name ( P_Supplier_Id         IN Number,
				P_Proc_Func_Flag      IN Varchar2,
				X_Supplier_Displayed OUT NOCOPY Varchar2,
		 		X_Return_Status      OUT NOCOPY Varchar2,
				X_Msg_Data    	      OUT NOCOPY Varchar2 )

  Is

	l_Supplier_Displayed  Varchar2(240)  := Null;

	--BAD_VEND_IN_LIST_MEM  Exception;
	--NULL_VEND_IN_LIST_MEM Exception;
	UNEXPEC_ERROR         Exception;

	Cursor c_Supplier (P_Vendor_Id IN Number) Is
	Select
		Vendor_Name
	From
		Po_Vendors
	Where
		Vendor_id = P_Vendor_Id;

  Begin

	If P_Supplier_Id is Not Null Then

		Open c_Supplier(P_Vendor_Id => P_Supplier_Id);
		Fetch c_Supplier Into l_Supplier_Displayed;
		If c_Supplier%NOTFOUND Then

			Close c_Supplier;
			--Raise BAD_VEND_IN_LIST_MEM;
			Raise UNEXPEC_ERROR;

		End If;
		Close c_Supplier;

	Else

		--Raise NULL_VEND_IN_LIST_MEM;
		--Raise UNEXPEC_ERROR;
                l_Supplier_Displayed := NULL;

	End If;

	X_Return_Status      := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Data           := Null;
	X_Supplier_Displayed := l_Supplier_Displayed;

  Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_msg_data := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Get_Supplier_Name');
              Return;
	/*When NULL_VEND_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_NULL_VEND_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_NULL_VEND_IN_LIST_MEM');

		Else

			X_Supplier_Displayed := Null;

		End If;*/

	/*When BAD_VEND_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_BAD_VEND_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_BAD_VEND_IN_LIST_MEM');

		Else

			X_Supplier_Displayed := Null;

		End If;*/

	When Others Then
		Raise;

  End Get_Supplier_Name;
/******************************************/

/***********************************************************
 * Function  : Ret_Role_Name
 * *********************************************************/
  Function Ret_Role_Name ( P_Role_Id IN Number ) Return Varchar2

  Is

	l_Return_Status Varchar2(1)  := Null;
	l_Msg_Data	Varchar2(30) := Null;
	l_Role_Name     Varchar2(80) := Null;

  Begin

	Pa_Planning_Resource_Utils.Get_Role_Name(
                        P_Role_Id        => P_Role_Id,
			P_Proc_Func_Flag => 'F',
			X_Role_Displayed => l_Role_Name,
		 	X_Return_Status  => l_Return_Status,
			X_Msg_Data       => l_Msg_Data );


	Return l_Role_Name;

  Exception
	When Others Then
		Raise;

  End Ret_Role_Name;
/******************************************/

/******************************************************
 * Procedure : Get_Role_Name
 * ****************************************************/
  Procedure Get_Role_Name ( P_Role_Id         IN Number,
			    P_Proc_Func_Flag  IN Varchar2,
			    X_Role_Displayed OUT NOCOPY Varchar2,
		 	    X_Return_Status  OUT NOCOPY Varchar2,
			    X_Msg_Data       OUT NOCOPY Varchar2 )
  Is

	l_Role_Displayed      Varchar2(80);

	--BAD_ROLE_IN_LIST_MEM  Exception;
	--NULL_ROLE_IN_LIST_MEM Exception;
	UNEXPEC_ERROR         Exception;

	Cursor c_PrjRoles (P_Prj_Role_Id IN Number) Is
	Select
		Meaning
	From
		Pa_Project_Role_Types_vl
	Where
		Project_Role_Id = P_Prj_Role_Id;

  Begin

	If P_Role_Id is Not Null Then

		-- Get role from pa_project_role_types_vl
		Open c_PrjRoles(P_Prj_Role_Id => P_Role_Id);
		Fetch c_PrjRoles Into l_Role_Displayed;

		If c_PrjRoles%NOTFOUND Then

			Close c_PrjRoles;
			--Raise BAD_ROLE_IN_LIST_MEM;
			Raise UNEXPEC_ERROR;

		End If;

		Close c_PrjRoles;

	Else

		--Raise NULL_ROLE_IN_LIST_MEM;
		--Raise UNEXPEC_ERROR;
                l_Role_Displayed := NULL;

	End If;

	X_Return_Status  := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Data       := Null;
	X_Role_Displayed := l_Role_Displayed;

  Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_msg_data := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Get_Role_Name');
              Return;
	/*When NULL_ROLE_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_NULL_ROLE_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_NULL_ROLE_IN_LIST_MEM');

		Else

			X_Role_Displayed := Null;

		End If;*/

	/*When BAD_ROLE_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_BAD_ROLE_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_BAD_ROLE_IN_LIST_MEM');

		Else

			X_Role_Displayed := Null;

		End If;*/

	When Others Then
		Raise;

  End Get_Role_Name;
/***********************************************/

/**********************************************************
 * Function : Ret_Incur_By_Res_Name
 * *********************************************************/
Function Ret_Incur_By_Res_Name ( P_Person_Id 	           IN Number,
			           P_Job_Id    	           IN Number,
			           P_Incur_By_Role_Id      IN Number,
			           P_Person_Type_Code      IN Varchar2,
			           P_Inc_By_Res_Class_Code IN Varchar2,
                                   P_Res_Assignment_Id     IN NUMBER default null) Return varchar2
  Is

	l_Return_Status Varchar2(1)    := Null;
	l_Msg_Data	Varchar2(30)   := Null;
	l_Inc_By_Name   Varchar2(1000) := Null;

  Begin

	Pa_Planning_Resource_Utils.Get_Incur_By_Res_Name(
        	P_Person_Id 	        => P_Person_Id,
		P_Job_Id   	        => P_Job_Id,
		P_Incur_By_Role_Id      => P_Incur_By_Role_Id,
		P_Person_Type_Code      => P_Person_Type_Code,
		P_Inc_By_Res_Class_Code => P_Inc_By_Res_Class_Code,
		P_Proc_Func_Flag        => 'F',
        	P_Res_Assignment_Id     => P_Res_Assignment_Id,
        	X_Inc_By_Displayed      => l_Inc_By_Name,
		X_Return_Status         => l_Return_Status,
		X_Msg_Data    	        => l_Msg_Data );

	Return l_Inc_By_Name;

  Exception
	When Others Then
		Raise;

  End Ret_Incur_By_Res_Name;
/******************************************/

/****************************************************************
 * Procedure : Get_Incur_By_Res_Name
 * **************************************************************/
  Procedure Get_Incur_By_Res_Name ( P_Person_Id 	     IN Number,
			            P_Job_Id   	             IN Number,
			            P_Incur_By_Role_Id       IN Number,
			            P_Person_Type_Code       IN Varchar2,
			            P_Inc_By_Res_Class_Code  IN Varchar2,
			            P_Proc_Func_Flag         IN Varchar2,
                                    P_Res_Assignment_Id      IN NUMBER default null,
			            X_Inc_By_Displayed      OUT NOCOPY Varchar2,
		 	            X_Return_Status         OUT NOCOPY Varchar2,
			            X_Msg_Data    	    OUT NOCOPY Varchar2)

  Is

	l_Inc_By_Displayed	       Varchar2(1000);

	--BAD_PER_IN_RES_LIST_MEM        Exception;
	--BAD_JOB_IN_RES_LIST_MEM        Exception;
	--BAD_INCUR_ROLE_IN_LIST_MEM     Exception;
	--BAD_PER_TYPE_IN_LIST_MEM       Exception;
	--BAD_INCUR_RESCLASS_IN_LIST_MEM Exception;
	--INV_INCUR_BY_IN_LIST_MEM       Exception;
	UNEXPEC_ERROR                  Exception;

	Cursor c_People (P_Person_Id IN Number) is
	Select
		Full_Name
	From
		Per_People_X
	Where
		Person_Id = P_Person_Id
	And     ( (Pa_Cross_Business_Grp.IsCrossBGProfile = 'N' AND
		   Fnd_Profile.Value('PER_BUSINESS_GROUP_ID') = Business_Group_Id)
		  OR Pa_Cross_Business_Grp.IsCrossBGProfile = 'Y');

	Cursor c_Job (P_Job_Id In Number) Is
	Select
		Name
	From
		Per_Jobs
	Where
		Job_Id = P_Job_Id
	And     ( (Pa_Cross_Business_Grp.IsCrossBGProfile = 'N' AND
		   Fnd_Profile.Value('PER_BUSINESS_GROUP_ID') = Business_Group_Id )
		  OR Pa_Cross_Business_Grp.IsCrossBGProfile = 'Y');

	Cursor c_PersonType (P_Person_Type IN Varchar2) Is
	Select
		Meaning
	From
		hr_lookups
	Where
		Lookup_Type = 'PERSON_TYPE'
	And	Lookup_Code = P_Person_Type;

	Cursor c_ResClass2 (P_Resource_Class_Code IN Varchar2) Is
	Select
		Name
	From
		Pa_Resource_Classes_Vl
	Where
		Resource_Class_Code = P_Resource_Class_Code;

	Cursor c_PrjRoles (P_Prj_Role_Id IN Number) Is
	Select
		Meaning
	From
		Pa_Project_Role_Types_vl
	Where
		Project_Role_Id = P_Prj_Role_Id;

       Cursor c_Res_Attributes
       Is
       Select
		Person_Id,
		Job_Id,
              	Incur_By_Role_Id,
		Person_Type_Code,
              	Incur_By_Res_Class_Code
       From
		Pa_Resource_Assignments
       Where
		Resource_Assignment_Id = P_Res_Assignment_Id;

      	l_Res_Attributes  c_Res_Attributes%RowType;

       Cursor Get_Inc_By_Flag Is
       Select
		Incurred_By_Res_Flag
       From
		Pa_Resource_Assignments
       Where
		Resource_Assignment_Id = P_Res_Assignment_Id;

       l_Person_Id 		Number;
       l_Job_Id 		Number;
       l_Incur_By_Role_Id 	Number;
       l_Person_Type_Code 	Varchar2(30);
       l_Inc_By_Res_Class_Code  Varchar2(30);
       l_Inc_By_Flag 		Varchar2(1) := 'N';

  Begin

	If P_Res_Assignment_Id Is Not Null Then

     		Open Get_inc_By_Flag;
     		Fetch Get_Inc_By_Flag Into l_Inc_By_Flag;
     		Close Get_Inc_By_Flag;

	End If;

	If l_Inc_By_Flag = 'Y' Then

      		Open c_Res_Attributes;
      		Fetch c_Res_Attributes Into l_Res_Attributes;
      		Close c_Res_Attributes;

      		l_person_id             := l_res_attributes.person_id;
      		l_job_id                := l_res_attributes.job_id;
      		l_incur_by_role_id      := l_res_attributes.incur_by_role_id;
      		l_person_type_code      := l_res_attributes.person_type_code;
      		l_inc_by_res_class_code := l_res_attributes.incur_by_res_class_code;

	Else

      		l_person_id := p_person_id;
      		l_job_id := p_job_id;
      		l_incur_by_role_id      := p_incur_by_role_id;
      		l_person_type_code      := p_person_type_code;
      		l_inc_by_res_class_code := p_inc_by_res_class_code;

	End If;

	-- Check in this order:
	-- Named Person, job, role, person type, Financial Elements Resource class
	If l_Person_Id is Not Null Then

		Open c_People(P_Person_Id => l_Person_Id);
		Fetch c_People Into l_Inc_By_Displayed;
		If c_People%NotFound Then
			Close c_People;
			--Raise BAD_PER_IN_RES_LIST_MEM;
			Raise UNEXPEC_ERROR;
		End If;
		Close c_People;

	ElsIf l_Job_Id is Not Null Then

		Open c_Job(P_Job_Id => l_Job_Id);
		Fetch c_Job Into l_Inc_By_Displayed;
		If c_Job%NOTFOUND Then
			Close c_job;
			--Raise BAD_JOB_IN_RES_LIST_MEM;
			Raise UNEXPEC_ERROR;
		End If;
		Close c_Job;

	ElsIf l_Incur_By_Role_Id is Not Null Then

		Open c_PrjRoles(P_Prj_Role_Id => l_Incur_By_Role_Id);
		Fetch c_PrjRoles Into l_Inc_By_Displayed;
		If c_PrjRoles%NOTFOUND Then
			Close c_PrjRoles;
			--Raise BAD_INCUR_ROLE_IN_LIST_MEM;
			Raise UNEXPEC_ERROR;
		End If;
		Close c_PrjRoles;

	ElsIf l_Person_Type_Code is Not Null Then

		-- CWK, EMP
		-- Get meaning from fnd_common_lookups
		Open c_PersonType(P_Person_Type => l_Person_Type_Code);
		Fetch c_PersonType Into l_Inc_By_Displayed;
		If c_PersonType%NOTFOUND Then
			Close c_PersonType;
			--Raise BAD_PER_TYPE_IN_LIST_MEM;
			Raise UNEXPEC_ERROR;
		End If;
		Close c_PersonType;

	ElsIf l_Inc_By_Res_Class_Code is Not Null Then

		Open c_ResClass2(P_Resource_Class_Code => l_Inc_By_Res_Class_Code);
		Fetch c_ResClass2 into l_Inc_By_Displayed;
		If c_ResClass2%NOTFOUND Then

			Close c_ResClass2;
			--Raise BAD_INCUR_RESCLASS_IN_LIST_MEM;
			Raise UNEXPEC_ERROR;

		End If;
		Close c_ResClass2;

	Else

		--Raise INV_INCUR_BY_IN_LIST_MEM;
		--Raise UNEXPEC_ERROR;
                -- Return Null if resource or assignment is not
	        -- an incurred by resource.
                l_Inc_By_Displayed := NULL;

	End If;

	X_Inc_By_Displayed := l_Inc_By_Displayed;
	X_Msg_Data         := Null;
	X_Return_Status    := Fnd_Api.G_Ret_Sts_Success;

  Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_msg_data := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Get_Incur_By_Res_Name');
              Return;
	/*When BAD_PER_IN_RES_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_BAD_PER_IN_RES_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
        	        	 P_Msg_Name        => 'PA_BAD_PER_IN_RES_LIST_MEM');

		Else

			X_Inc_By_Displayed := Null;

		End If;*/

	/*When BAD_JOB_IN_RES_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status	:= Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_BAD_JOB_IN_RES_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_BAD_JOB_IN_RES_LIST_MEM');

		Else

			X_Inc_By_Displayed := Null;

		End If;*/

	/*When BAD_INCUR_ROLE_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_BAD_INCUR_ROLE_IN_LIST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_BAD_INCUR_ROLE_IN_LIST_MEM');

		Else

			X_Inc_By_Displayed := Null;

		End If;*/

	/*When BAD_PER_TYPE_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_BAD_PER_TYPE_IN_LIST_MEM';
			Pa_Utils.Add_Message
	        		(P_App_Short_Name  => 'PA',
        	        	 P_Msg_Name        => 'PA_BAD_PER_TYPE_IN_LIST_MEM');

		Else

			X_Inc_By_Displayed := Null;

		End If;*/

	/*When BAD_INCUR_RESCLASS_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_BAD_INC_RESCLASS_IN_LST_MEM';
			Pa_Utils.Add_Message
        	       		(P_App_Short_Name  => 'PA',
                		 P_Msg_Name        => 'PA_BAD_INC_RESCLASS_IN_LST_MEM');

		Else

			X_Inc_By_Displayed := Null;

		End If;*/

	/*When INV_INCUR_BY_IN_LIST_MEM Then

		If P_Proc_Func_Flag = 'P' Then

			X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
			X_Msg_Data	:= 'PA_INV_INCUR_BY_IN_LIST_MEM';
			Pa_Utils.Add_Message
	               		(P_App_Short_Name  => 'PA',
	                	 P_Msg_Name        => 'PA_INV_INCUR_BY_IN_LIST_MEM');

		Else

			X_Inc_By_Displayed := Null;

		End If;*/

	When Others Then
		Raise;

  End Get_Incur_By_Res_Name;
/**************************************************/

/********************************************************
 * Procedure  : Get_Plan_Res_Combination.
 *****************************************************/

Procedure Get_Plan_Res_Combination(
		P_Resource_List_Member_Id IN  Number,
		X_Resource_Alias	 OUT NOCOPY Varchar2,
 		X_Plan_Res_Combination   OUT NOCOPY Varchar2,
		X_Return_Status          OUT NOCOPY Varchar2,
		X_Msg_Count              OUT NOCOPY Number,
		X_Msg_Data               OUT NOCOPY Varchar2)

 Is

	l_Res_Type_displayed     Varchar2(1000) := Null;
	l_FC_Displayed           Varchar2(80)   := Null;
	l_Orgn_Displayed         Varchar2(240)  := Null;
	l_Supplier_Displayed     Varchar2(240)  := Null;
	l_Role_Displayed         Varchar2(80)   := Null;
	l_Res_Incur_By_displayed Varchar2(1000) := Null;
	l_Res_Incur_By_alias     Varchar2(1000) := Null;

	Cursor c_Enabled_Flags (P_Res_Format_Id IN Number) is
	Select
		f.Res_Type_Enabled_Flag,
		f.Orgn_Enabled_Flag,
		f.Fin_Cat_Enabled_Flag,
		f.Incurred_By_Enabled_Flag,
		f.Supplier_Enabled_Flag,
		f.Role_Enabled_Flag,
		f.Resource_Class_Flag,
		f.Res_Type_Id,
		f.Resource_Type_Disp_Chars,
		f.Orgn_Disp_Chars,
		f.Fin_Cat_Disp_Chars,
		f.Incurred_By_Disp_Chars,
		f.Supplier_Disp_Chars,
		f.Role_Disp_Chars,
		t.Res_Type_Code
	From
		Pa_Res_Formats_B f,
		Pa_Res_Types_B t
	Where
		f.Res_Type_Id = t.Res_Type_Id(+)
	And	f.Res_Format_Id = P_Res_Format_Id;

	Cursor c_Res_List (P_Res_List_Member_Id IN Number) is
	Select
		Res_Format_Id,
		Person_Id,
		Job_Id,
		Organization_Id,
		Vendor_Id,
		Expenditure_Type,
		Event_Type,
		Non_Labor_Resource,
		Expenditure_Category,
		Revenue_Category,
		Non_Labor_Resource_Org_Id,
		Project_Role_Id,
		Resource_Format_Id,
		Resource_Class_Id,
		Mfc_Cost_Type_Id,
		Resource_Class_Flag,
		Fc_Res_Type_Code,
		Bom_Resource_Id,
		Inventory_Item_Id,
		Item_Category_Id,
		Person_Type_Code,
		team_role ,
		Incurred_By_Res_Flag,
		Incur_By_Res_Class_Code,
		Incur_By_Role_Id
	From
		Pa_Resource_List_Members
	Where
		Resource_List_Member_Id = P_Res_List_Member_Id;

	Res_List_Member_Rec c_Res_List%RowType;
	Res_Format_Rec c_Enabled_Flags%RowType;

	-- User Exception Definitions
	INVALID_RES_LIST_MEM_ID Exception;
	NULL_MEM_LIST_RES_FORMAT Exception;
	INVALID_MEM_LIST_RES_FORMAT Exception;
	--BAD_RES_TYPE_CODE Exception;
	FAIL_GET_NAME Exception;

 Begin

	-- We always display the combination in the following order
	--	Resource
	--	Financial Category
	--	Organization
	--	Supplier
	-- 	Role
	--	Incurred By

	-- Initialize values
	X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Count     	:= 0;
	X_Msg_Data		:= Null;
        /***************************************************
        * Bug - 3591595
        * Desc - If the P_Resource_List_Member_Id is passed in as Null
        *        then set the x_resource_alias and X_Plan_Res_Combination
        *        as Null and Return.
        ******************************************************/
        IF P_Resource_List_Member_Id IS NULL THEN
		X_Resource_Alias	 := Null;
 		X_Plan_Res_Combination   := Null;
	        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
                Return;
        END IF;

	Open c_Res_List(P_Res_List_Member_Id => P_Resource_List_Member_Id);
	Fetch c_Res_List into Res_List_Member_Rec;
	If c_Res_List%NotFound Then
		Close c_Res_List;
		Raise INVALID_RES_LIST_MEM_ID;
	End If;
	Close c_Res_List;

	If Res_List_Member_Rec.Res_Format_Id is Not Null Then

		Open c_Enabled_Flags(P_Res_Format_Id => Res_List_Member_Rec.Res_Format_Id);
		Fetch c_Enabled_Flags into Res_Format_Rec;
		If c_Enabled_Flags%NotFound Then
			Close c_Enabled_Flags;
			Raise INVALID_MEM_LIST_RES_FORMAT;
		End If;
		Close c_Enabled_Flags;

	Else

		Raise NULL_MEM_LIST_RES_FORMAT;

	End If;


	-- An Assumption is that there will never be more that 3 segments to the format
	-- So therefore will not count the number of segments with enabled_flag = 'Y'

	-- Check res_type_enabled_flag = 'Y'
	If Res_Format_Rec.Res_Type_Enabled_Flag = 'Y' Then

		Pa_Planning_Resource_Utils.Get_Resource_Name (
			P_Res_Type_Code      => Res_Format_Rec.Res_Type_Code,
			P_Person_Id          => Res_List_Member_Rec.Person_Id,
			P_Bom_Resource_Id    => Res_List_Member_Rec.BOM_Resource_Id,
    			P_Job_Id             => Res_List_Member_Rec.Job_Id,
			P_Person_Type_Code   => Res_List_Member_Rec.Person_Type_Code,
			P_Non_Labor_Resource => Res_List_Member_Rec.Non_Labor_Resource,
			P_Inventory_Item_Id  => Res_List_Member_Rec.Inventory_Item_Id,
			P_Item_Category_Id   => Res_List_Member_Rec.Item_Category_Id,
			P_Resource_Class_Id  => Res_List_Member_Rec.Resource_Class_Id,
			P_Proc_Func_Flag     => 'P',
			X_Resource_Displayed => l_Res_Type_Displayed,
		 	X_Return_Status      => X_Return_Status,
			X_Msg_Data    	     => X_Msg_Data);

		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_GET_NAME;

		End If;

		If l_Res_Type_Displayed is Not Null Then

			X_Plan_Res_Combination := l_Res_Type_Displayed;
                        --Bug 3485392
                        IF Res_Format_Rec.Res_Type_Code = 'NAMED_PERSON' THEN
                             BEGIN
                                 --Select nvl(known_as,Full_Name)
                                 --Bug 8296696
                                 Select decode(known_as,null,full_name,known_as||' ('||last_name||')')
                                 INTO l_Res_Type_Displayed
                                 From Per_People_X
                                 Where Person_Id = Res_List_Member_Rec.Person_Id;
                             END;
                        END IF;
			X_Resource_Alias       := substr(l_Res_Type_Displayed,1,Res_Format_Rec.Resource_Type_Disp_Chars);

		--Else

			--Raise BAD_RES_TYPE_CODE;

		End If;

	End If;

	-- Check fin_cat_enabled_flag = 'Y'
	If Res_Format_Rec.Fin_Cat_Enabled_Flag = 'Y' Then

		Pa_Planning_Resource_Utils.Get_Fin_Category_Name (
			P_FC_Res_Type_Code      => Res_List_Member_Rec.Fc_Res_Type_Code,
			P_Expenditure_Type      => Res_List_Member_Rec.Expenditure_Type,
			P_Expenditure_Category  => Res_List_Member_Rec.Expenditure_Category,
			P_Event_Type            => Res_List_Member_Rec.Event_Type,
			P_Revenue_Category_Code => Res_List_Member_Rec.Revenue_Category,
			P_Proc_Func_Flag        => 'P',
                        P_Res_Assignment_Id     => NULL,
			X_Fin_Cat_Displayed     => l_FC_Displayed,
		 	X_Return_Status         => X_Return_Status,
			X_Msg_Data	        => X_Msg_Data);

		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_GET_NAME;

		End If;

		If X_Plan_Res_Combination is Not Null Then

			X_Plan_Res_Combination := X_Plan_Res_Combination || ' - ' || l_FC_Displayed;
			X_Resource_Alias := substr(X_Resource_Alias || ' - ' ||
					  substr(l_FC_Displayed,1,Res_Format_Rec.Fin_Cat_Disp_Chars), 1, 80);

		Else

			X_Plan_Res_Combination := l_FC_Displayed;
			X_Resource_Alias       := substr(l_FC_Displayed,1,Res_Format_Rec.Fin_Cat_Disp_Chars);

		End If;

	End If;

	-- Check orgn_enabled_flag = 'Y'
	If Res_Format_Rec.Orgn_Enabled_Flag = 'Y' Then

		Pa_Planning_Resource_Utils.Get_Organization_Name (
			P_Organization_Id => Res_List_Member_Rec.Organization_Id,
			P_Proc_Func_Flag  => 'P',
			X_Org_Displayed   => l_Orgn_Displayed,
		 	X_Return_Status   => X_Return_Status,
			X_Msg_Data	  => X_Msg_Data);

		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_GET_NAME;

		End If;

		If X_Plan_Res_Combination is Not Null Then

			X_Plan_Res_Combination := X_Plan_Res_Combination || ' - ' || l_Orgn_Displayed;
			X_Resource_Alias := substr(X_Resource_Alias || ' - ' ||
				  substr(l_Orgn_Displayed,1,Res_Format_Rec.Orgn_Disp_Chars), 1, 80);

		Else

			X_Plan_Res_Combination := l_Orgn_Displayed;
			X_Resource_Alias       := substr(l_Orgn_Displayed,1,Res_Format_Rec.Orgn_Disp_Chars);

		End If;

	End If;

	-- Check supplier_enabled_flag = 'Y'
	If Res_Format_Rec.Supplier_Enabled_Flag = 'Y' Then

		Pa_Planning_Resource_Utils.Get_Supplier_Name (
			P_Supplier_Id        => Res_List_Member_Rec.Vendor_Id,
			P_Proc_Func_Flag     => 'P',
			X_Supplier_Displayed => l_Supplier_Displayed,
		 	X_Return_Status      => X_Return_Status,
			X_Msg_Data	     => X_Msg_Data);

		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_GET_NAME;

		End If;

		If X_Plan_Res_Combination is Not Null Then

			X_Plan_Res_Combination := X_Plan_Res_Combination || ' - ' || l_Supplier_Displayed;
			X_Resource_Alias := substr(X_Resource_Alias || ' - ' ||
				  substr(l_Supplier_Displayed,1,Res_Format_Rec.Supplier_Disp_Chars), 1, 80);

		Else

			X_Plan_Res_Combination := l_Supplier_Displayed;
			X_Resource_Alias       := substr(l_Supplier_Displayed,1,Res_Format_Rec.Supplier_Disp_Chars);

		End If;

	End If;

	-- Check role_enabled_flag = 'Y'
	If Res_Format_Rec.Role_Enabled_Flag = 'Y' Then
                -- Team Role Changes
		/*Pa_Planning_Resource_Utils.Get_Role_Name (
			P_Role_Id        => Res_List_Member_Rec.Project_Role_Id,
			P_Proc_Func_Flag => 'P',
			X_Role_Displayed => l_Role_Displayed,
		 	X_Return_Status  => X_Return_Status,
			X_Msg_Data	 => X_Msg_Data);


		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_GET_NAME;

		End If;*/
                -- Team Role Changes
                l_Role_Displayed := Res_List_Member_Rec.Team_Role;

		If X_Plan_Res_Combination is Not Null Then

			X_Plan_Res_Combination := X_Plan_Res_Combination || ' - ' || l_Role_Displayed;
			X_Resource_Alias := substr(X_Resource_Alias || ' - ' ||
				 substr(l_Role_Displayed,1,Res_Format_Rec.Role_Disp_Chars), 1, 80);

		Else

			X_Plan_Res_Combination := l_Role_Displayed;
			X_Resource_Alias       := substr(l_Role_Displayed,1,Res_Format_Rec.Role_Disp_Chars);

		End If;

	End If;

	-- Check incurred_by_enabled_flag = 'Y'
	If Res_Format_Rec.Incurred_By_Enabled_Flag = 'Y' and
	   Res_List_Member_Rec.Incurred_By_Res_Flag = 'Y' Then

		Pa_Planning_Resource_Utils.Get_Incur_By_Res_Name (
			P_Person_Id 	        => Res_List_Member_Rec.Person_Id,
			P_Job_Id   	        => Res_List_Member_Rec.Job_Id,
			P_Incur_By_Role_Id      => Res_List_Member_Rec.Incur_By_Role_Id,
			P_Person_Type_Code      => Res_List_Member_Rec.Person_Type_Code,
			P_Inc_By_Res_Class_Code => Res_List_Member_Rec.Incur_By_Res_Class_Code,
			P_Proc_Func_Flag        => 'P',
                        P_Res_Assignment_Id     => null,
			X_Inc_By_Displayed      => l_Res_Incur_By_displayed,
		 	X_Return_Status         => X_Return_Status,
			X_Msg_Data	        => X_Msg_Data);

		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_GET_NAME;

		End If;

                If l_Res_Incur_By_displayed is Not Null Then

                   l_Res_Incur_By_alias := l_Res_Incur_By_displayed;
                   --Bug 3940932
                   IF Res_List_Member_Rec.Person_Id IS NOT NULL THEN
                      BEGIN
                         SELECT nvl(known_as,Full_Name)
                         INTO l_Res_Incur_By_alias
                         FROM Per_People_X
                         WHERE Person_Id = Res_List_Member_Rec.Person_Id;
                         END;
                   END IF;
                End If;

		If X_Plan_Res_Combination is Not Null Then

		   X_Plan_Res_Combination := X_Plan_Res_Combination || ' - ' ||
                                             l_Res_Incur_By_displayed;
	 	   X_Resource_Alias := substr(X_Resource_Alias || ' - ' ||
			  substr(l_Res_Incur_By_alias,1,Res_Format_Rec.Incurred_By_Disp_Chars), 1, 80);

		Else
		   X_Plan_Res_Combination := l_Res_Incur_By_displayed;
		   X_Resource_Alias       := substr(l_Res_Incur_By_alias,1,Res_Format_Rec.Incurred_By_Disp_Chars);

		End If;

	End If; -- Check incurred_by_enabled_flag = 'Y'

 Exception
	When INVALID_RES_LIST_MEM_ID Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_INVALID_RES_LIST_MEM_ID';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_INVALID_RES_LIST_MEM_ID');
	When NULL_MEM_LIST_RES_FORMAT Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_NULL_MEM_LIST_RES_FRM';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_NULL_MEM_LIST_RES_FRM');
	When INVALID_MEM_LIST_RES_FORMAT Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_INVALID_MEM_LIST_RES_FRM';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_INVALID_MEM_LIST_RES_FRM');
	/*When BAD_RES_TYPE_CODE Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_BAD_RES_TYPE_CODE';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_BAD_RES_TYPE_CODE');*/
	When FAIL_GET_NAME Then
		X_Msg_Count     	:= 1;
		-- Assumes that the called procedure populates the
		-- out parameters with the rest of the needed values
		-- and executes pa_utils.add_message()
	When Others Then
		Raise;

 End Get_Plan_Res_Combination;
/****************************************************/


/******Eugene*******************************************/
Function Get_Plan_Res_Combination( P_Resource_List_Member_Id IN Number) Return Varchar2
IS

	l_Plan_Res_Combination	Varchar2(2000);
	l_Return_Status 	Varchar2(1);
	l_Res_List_Member_Alias Varchar2(2000);
	l_Error_Msg_Data 	Varchar2(30);
	l_Error_Count 		Number;

BEGIN

	Pa_Planning_Resource_Utils.Get_Plan_Res_Combination(
                P_Resource_List_Member_Id  => P_Resource_List_Member_Id,
                X_Resource_Alias           => l_Res_List_Member_Alias,
                X_Plan_Res_Combination     => l_Plan_Res_Combination,
                X_Return_Status            => l_Return_Status,
                X_Msg_Count                => l_Error_Count,
                X_Msg_Data                 => l_Error_Msg_Data);

	If l_Return_Status <> Fnd_Api.G_Ret_Sts_Success Then

		-- Since this function calls the procedure get_plan_res_combination
		-- then the message is populated already using pa_utils.add_message()
		-- so just return 'ERROR'
		-- The message stack is already populated.
   		Return 'ERROR';

	Else

   		Return l_Plan_Res_Combination;

	End If;


END Get_Plan_Res_Combination;
/**************************************/

/*************************************************/
 Procedure Validate_Fin_Category(
		P_FC_Res_Type_Code	IN  Varchar2,
		P_Resource_Class_Code	IN  Varchar2,
		P_Fin_Category_Name	IN  Varchar2,
		P_migration_code   	IN  Varchar2,
		X_Expenditure_Type	OUT NOCOPY Varchar2,
		x_Expenditure_Category 	OUT NOCOPY Varchar2,
		X_Event_Type		OUT NOCOPY Varchar2,
		X_Revenue_Category	OUT NOCOPY Varchar2,
		X_Return_Status		OUT NOCOPY Varchar2,
		X_Error_Message_Code	OUT NOCOPY Varchar2)

 Is

	Cursor c_Event_Type ( P_Fin_Cat_Name IN Varchar2 ) Is
	Select
		'Y'
  	From
		Pa_Event_Types
 	Where
		Event_Type = P_Fin_Cat_Name
	And	Event_Type_Classification IN ('AUTOMATIC','MANUAL','WRITE OFF','WRITE ON')
 	And 	Decode(Pa_Get_Resource.Include_Inactive_Resources,
				'Y',Start_Date_Active,
				Trunc(SysDate)) Between Start_Date_Active
					           And Nvl(End_Date_Active,Trunc(SysDate));

	Cursor c_Exp_Type ( P_Fin_Cat_Name IN Varchar2) Is
	Select
		'Y'
  	From
		Pa_Expenditure_Types
 	Where
		lower(Expenditure_Type) = lower(P_Fin_Cat_Name)
 	And 	Decode(Pa_Get_Resource.Include_Inactive_Resources,
				'Y',Start_Date_Active,
				Trunc(SysDate)) Between Start_Date_Active
					           And Nvl(End_Date_Active,Trunc(SysDate));

	Cursor c_Exp_Cat ( P_Fin_Cat_Name IN Varchar2) Is
	Select
		'Y'
  	From
		Pa_Expenditure_Categories
 	Where
		lower(Expenditure_Category) = lower(P_Fin_Cat_Name)
 	And 	Decode(Pa_Get_Resource.Include_Inactive_Resources,
				'Y',Start_Date_Active,
				Trunc(SysDate)) Between Start_Date_Active
					           And Nvl(End_Date_Active,Trunc(SysDate));


	Cursor c_Rev_Cat_Code ( P_Fin_Cat_Code IN Varchar2) Is
	Select
		Meaning
  	From
		Pa_Lookups
 	Where
		Lookup_Code = P_Fin_Cat_Code
	And	Lookup_Type = 'REVENUE CATEGORY';

        Cursor c_Rev_Cat_Meaning ( P_Fin_Cat_Meaning IN Varchar2) Is
        Select
                lookup_code
        From
                Pa_Lookups
        Where
                Meaning = P_Fin_Cat_Meaning
        And     Lookup_Type = 'REVENUE CATEGORY';

	Cursor c_UOM ( P_Fin_Cat_Name IN Varchar2 ) Is
	Select
		'Y'
	From
		Pa_Expenditure_Types
	Where
		Unit_Of_Measure = 'HOURS'
	And 	Expenditure_Type = P_Fin_Cat_Name;

	MAN_PARAMS_NULL            Exception;
	BAD_FIN_CAT_FOR_EVENT_TYPE Exception;
	BAD_FIN_CAT_FOR_EXP_TYPE   Exception;
	BAD_FIN_CAT_FOR_EXP_CAT    Exception;
	BAD_FIN_CAT_FOR_REV_CAT    Exception;
	INVALID_VAL_FC_RES_TYPE    Exception;
	BAD_FIN_CAT_UOM            Exception;
	UNEXPEC_ERROR              Exception;
	INVALID_FIN_CAT_CODE       Exception;
	l_Dummy	Varchar2(1) := Null;
	l_rev_meaning	Varchar2(80) := Null;
	l_rev_code	Varchar2(30) := Null;

 Begin

	-- Initialize values
	X_Return_Status      := Fnd_Api.G_Ret_Sts_Success;
	X_Error_Message_Code := Null;

	If P_FC_Res_Type_Code is Null or
	   P_Fin_Category_Name is Null or
	   P_Resource_Class_Code is Null Then

		Raise MAN_PARAMS_NULL;
		--Raise UNEXPEC_ERROR;

	End If;

	If P_FC_Res_Type_Code = 'EVENT_TYPE' Then

		Open c_Event_Type(P_Fin_Cat_Name => P_Fin_Category_Name);
		Fetch c_Event_Type Into l_Dummy;
		If c_Event_Type%NotFound Then

			Close c_Event_Type;
			Raise BAD_FIN_CAT_FOR_EVENT_TYPE;
			--Raise UNEXPEC_ERROR;

		End If;
		X_Event_Type := P_Fin_Category_Name;
		Close c_Event_Type;

	ElsIf P_FC_Res_Type_Code = 'EXPENDITURE_TYPE' Then

		Open c_Exp_Type(P_Fin_Cat_Name => P_Fin_Category_Name);
		Fetch c_Exp_Type Into l_Dummy;
		If c_Exp_Type%NotFound Then

			Close c_Exp_Type;
			Raise BAD_FIN_CAT_FOR_EXP_TYPE;
			--Raise UNEXPEC_ERROR;

		End If;
		X_Expenditure_Type := P_Fin_Category_Name;
		Close c_Exp_Type;

	ElsIf P_FC_Res_Type_Code = 'EXPENDITURE_CATEGORY' Then

		Open c_Exp_Cat(P_Fin_Cat_Name => P_Fin_Category_Name);
		Fetch c_Exp_Cat Into l_Dummy;
		If c_Exp_Cat%NotFound Then


			Close c_Exp_Cat;
			Raise BAD_FIN_CAT_FOR_EXP_CAT;
			--Raise UNEXPEC_ERROR;

		End If;
		X_Expenditure_Category := P_Fin_Category_Name;
		Close c_Exp_Cat;

	ElsIf P_FC_Res_Type_Code = 'REVENUE_CATEGORY' Then

		-- First check to see if the P_Fin_Category_Name is the
		-- Rev Cat Code
		Open c_Rev_Cat_Code(P_Fin_Cat_Code => P_Fin_Category_Name);
		Fetch c_Rev_Cat_Code Into l_rev_meaning;
		If c_Rev_Cat_Code%NotFound Then
		   -- Check to see if it is the Meaning

                   Open c_Rev_Cat_Meaning(P_Fin_Cat_Meaning => P_Fin_Category_Name);
                   Fetch c_Rev_Cat_Meaning Into l_rev_code;
                   If c_Rev_Cat_Meaning%NotFound Then
                      Close c_Rev_Cat_Meaning;
                      Raise BAD_FIN_CAT_FOR_REV_CAT;
                      --Raise UNEXPEC_ERROR;
                   Else
                      X_Revenue_Category := l_rev_code;
                      Close c_Rev_Cat_Meaning;
                   End If;
                Else
		   X_Revenue_Category := P_Fin_Category_Name;
                End If;
		Close c_Rev_Cat_Code;
	Else
	  RAISE INVALID_FIN_CAT_CODE;

	End If;

	If P_Resource_Class_Code in ('PEOPLE','EQUIPMENT') And
	   P_FC_Res_Type_Code = 'EXPENDITURE_TYPE' And
           P_migration_code = 'N' Then

		Open c_UOM(P_Fin_Cat_Name => P_Fin_Category_Name);
		Fetch c_UOM Into l_Dummy;
		If c_UOM%NotFound Then

			Close c_UOM;
			Raise BAD_FIN_CAT_UOM;

		End If;
		Close c_UOM;

	End If;

 Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_error_message_code := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Validate_Fin_Category');
	When INVALID_FIN_CAT_CODE Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VFC_INVALID_FIN_CAT_CODE';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_VFC_INVALID_FIN_CAT_CODE',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When MAN_PARAMS_NULL Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VFC_MAN_PARAMS_NULL';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_VFC_MAN_PARAMS_NULL',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When BAD_FIN_CAT_FOR_EVENT_TYPE Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VFC_BAD_FINCAT_FOR_EVT_TYPE';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
              	         P_Msg_Name        => 'PA_VFC_BAD_FINCAT_FOR_EVT_TYPE',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When BAD_FIN_CAT_FOR_EXP_TYPE Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VFC_BAD_FIN_CAT_FOR_EXP_TYP';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
              	         P_Msg_Name        => 'PA_VFC_BAD_FIN_CAT_FOR_EXP_TYP',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When BAD_FIN_CAT_FOR_EXP_CAT Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VFC_BAD_FIN_CAT_FOR_EXP_CAT';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
              	         P_Msg_Name        => 'PA_VFC_BAD_FIN_CAT_FOR_EXP_CAT',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When BAD_FIN_CAT_FOR_REV_CAT Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VFC_BAD_FIN_CAT_FOR_REV_CAT';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
              	         P_Msg_Name        => 'PA_VFC_BAD_FIN_CAT_FOR_REV_CAT',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When BAD_FIN_CAT_UOM Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VFC_BAD_FIN_CAT_UOM';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_VFC_BAD_FIN_CAT_UOM',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When Others Then
		Raise;

 End Validate_Fin_Category;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API name                      : Get_Resource_Cost_Rate
-- Type                          : Procedure
-- Pre-reqs                      : None
-- Function                      : To get the Resource Rate and  Currency attributes.
-- Prameters
-- P_eligible_rlm_id_tbl      IN    SYSTEM.PA_NUM_TBL_TYPE  REQUIRED  --Resource List Member Id
-- P_project_id               IN    NUMBER  REQUIRED
--  History
--  05-MAR-04   Vgade                    -Created
--
/*----------------------------------------------------------------------------*/
Procedure Get_Resource_Cost_Rate(
   P_eligible_rlm_id_tbl      IN  SYSTEM.PA_NUM_TBL_TYPE
  ,P_project_id               IN  pa_projects_all.project_id%type
  ,p_structure_type           IN VARCHAR2
  ,p_fin_plan_type_id         IN NUMBER  DEFAULT NULL
  ,P_resource_curr_code_tbl   OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE
  ,P_resource_raw_rate_tbl    OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  ,P_resource_burden_rate_tbl OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
   ) AS
--Start of variables used for debugging
   l_msg_count                      NUMBER :=0;
   l_data                           VARCHAR2(2000);
   l_msg_data                       VARCHAR2(2000);
   l_error_msg_code                 VARCHAR2(30);
   l_msg_index_out                  NUMBER;
   l_return_status                  VARCHAR2(2000);
   l_debug_mode                     VARCHAR2(30);
  --End of variables used for debugging

   l_task_id                         pa_tasks.task_id%TYPE;
   l_top_task_id                     pa_tasks.task_id%TYPE;
  l_bill_job_group_id                pa_projects_all.bill_job_group_id%TYPE;
  l_project_type                     pa_projects_all.project_type%TYPE;
  l_expenditure_type                 pa_resource_assignments.expenditure_type%TYPE;
  l_org_id                           pa_projects_all.org_id%TYPE;
  l_expenditure_OU                   pa_projects_all.org_id%TYPE;
  l_txn_currency_code_override       pa_fp_res_assignments_tmp.txn_currency_code_override%TYPE;
  l_cost_rate_multiplier             CONSTANT pa_labor_cost_multipliers.multiplier%TYPE := 1;
--  l_burden_override_multiplier       pa_fp_res_assignments_tmp.b_multiplier_override%TYPE;
  l_burden_override_multiplier       Number;
  l_cost_override_rate               pa_fp_res_assignments_tmp.rw_cost_rate_override%TYPE;
  l_raw_cost                         pa_fp_res_assignments_tmp.txn_raw_cost%TYPE;
  l_raw_cost_rate                    pa_fp_res_assignments_tmp.raw_cost_rate%TYPE;
  l_burden_cost                      pa_fp_res_assignments_tmp.txn_burdened_cost%TYPE;
  l_mfc_cost_type_id                 pa_resource_assignments.mfc_cost_type_id%TYPE;
  l_mfc_cost_source                  CONSTANT NUMBER := 2;

 --Out variables
  l_txn_raw_cost                     number;
  l_txn_cost_rate                    number;
  l_txn_burden_cost                  number;
  l_txn_burden_cost_rate             number;
  l_burden_multiplier                number;
  l_cost_ind_compiled_set_id         number;
  l_raw_cost_rejection_code          varchar2(1000);
  l_burden_cost_rejection_code       varchar2(1000);
  -- Changes for PFC
  l_func_currency_code               varchar2(15);
  l_dummy_rate_date                  Date;
  l_dummy_rate_type                  Varchar2(100);
  l_dummy_exch_rate                  Number;
  l_dummy_cost                       Number;
  l_final_txn_rate_date              Date;
  l_final_txn_rate_type              Varchar2(100);
  l_final_txn_exch_rate              Number;
  l_final_txn_burden_cost            Number;
  l_status                           Varchar2(100);
  l_stage                            Number;

  l_wp_versioning                    Varchar2(1);
  l_wp_vers_id                       Number;
  l_budget_version_id                Number;

l_resource_list_member_Id_tab SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_resource_assignment_id_tab SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_expenditure_ou_tbl         SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

l_burden_multiplier_tab      SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.PA_NUM_TBL_TYPE();
l_ind_compiled_set_id_tab    SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.PA_NUM_TBL_TYPE();
l_bill_rate_tab              SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.PA_NUM_TBL_TYPE();
l_markup_percent_tab         SYSTEM.PA_NUM_TBL_TYPE :=SYSTEM.PA_NUM_TBL_TYPE();
l_txn_currency_code_tab  SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_rev_txn_curr_code_tab  SYSTEM.PA_VARCHAR2_15_TBL_TYPE := SYSTEM.PA_VARCHAR2_15_TBL_TYPE();
l_cost_rejection_code_tab SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_burden_rejection_code_tab  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_revenue_rejection_code_tab SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

-- Bug 7457385
CURSOR cur_proj_is_template(c_project_id NUMBER)
IS
SELECT 'Y'
FROM pa_projects_all
WHERE project_id = c_project_id
AND template_flag = 'Y';

l_template_flag VARCHAR2(1);

Begin
IF p_structure_type = 'WORKPLAN' THEN

   -- Bug 7457385
   OPEN cur_proj_is_template(p_project_id);
   FETCH cur_proj_is_template into l_template_flag;
   IF cur_proj_is_template%NOTFOUND THEN
     l_template_flag := 'N';
   END IF;
   CLOSE cur_proj_is_template;

   -- Bug 7457385 - In case of templates, you have a working workplan version
   -- with status code as structure_working and current_working_flag as Y
   IF l_template_flag = 'Y' THEN
     l_wp_vers_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(
                                      p_project_id => p_project_id);
   ELSE
     l_wp_versioning := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                      p_project_id => p_project_id);
     IF l_wp_versioning = 'Y' THEN
        l_wp_vers_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(
                                      p_project_id => p_project_id);
        IF l_wp_vers_id IS NULL THEN
           l_wp_vers_id := PA_PROJECT_STRUCTURE_UTILS.get_latest_wp_version(
                                      p_project_id => p_project_id);
        END IF;
     ELSE
        l_wp_vers_id := PA_PROJECT_STRUCTURE_UTILS.get_latest_wp_version(
                                      p_project_id => p_project_id);
     END IF;
   END IF;

   IF l_wp_vers_id IS NOT NULL THEN
      SELECT budget_version_id
      INTO   l_budget_version_id
      FROM   pa_budget_versions
      WHERE  project_structure_version_id = l_wp_vers_id
      AND    wp_version_flag = 'Y';
   END IF;

ELSE
   -- Bug 4779037 - added in Financial plan case.
   SELECT MAX(bv.budget_version_id)
   INTO   l_budget_version_id
   FROM   pa_budget_versions bv
   WHERE  bv.fin_plan_type_id = p_fin_plan_type_id
   AND    bv.project_id = p_project_id
   AND    NVL(wp_version_flag,'N') = 'N'
   AND    NVL(bv.budget_status_code,'W') IN ('W','S');
END IF;

        PA_FIN_PLAN_UTILS2.Get_Resource_Rates
        ( p_calling_module              => 'MSP'
        ,p_source_context               => 'RLMI'
        ,p_project_id                   => p_project_id
        ,p_budget_version_id            => l_budget_version_id
        ,p_resource_list_member_Id_tab  => p_eligible_rlm_id_tbl
        ,x_cost_txn_curr_code_tab       => P_resource_curr_code_tbl
        ,x_raw_cost_rate_tab            => P_resource_raw_rate_tbl
        ,x_burden_cost_rate_tab         => P_resource_burden_rate_tbl
        ,x_expenditure_ou_tab           => l_expenditure_ou_tbl
        ,x_resource_assignment_id_tab   => l_resource_assignment_id_tab
        ,x_resource_list_member_Id_tab  => l_resource_list_member_Id_tab
        ,x_burden_multiplier_tab        => l_burden_multiplier_tab
        ,x_ind_compiled_set_id_tab      => l_ind_compiled_set_id_tab
        ,x_bill_rate_tab                => l_bill_rate_tab
        ,x_markup_percent_tab           => l_markup_percent_tab
        ,x_txn_currency_code_tab        => l_txn_currency_code_tab
        ,x_rev_txn_curr_code_tab        => l_rev_txn_curr_code_tab
        ,x_cost_rejection_code_tab      => l_cost_rejection_code_tab
        ,x_burden_rejection_code_tab    => l_burden_rejection_code_tab
        ,x_revenue_rejection_code_tab   => l_revenue_rejection_code_tab
        ,x_return_status                => l_return_status
        ,x_msg_data                     => l_msg_data
        ,x_msg_count                    => l_msg_count
        );

        -- If the currency code of the transaction is not the same as
        -- the project functional currency code, then convert it to the PFC.
        l_func_currency_code := PA_CURRENCY.get_currency_code;
        FOR i IN p_eligible_rlm_id_tbl.FIRST .. p_eligible_rlm_id_tbl.LAST LOOP

          IF P_resource_curr_code_tbl(i) <> l_func_currency_code  THEN

              pa_multi_currency_txn.get_currency_amounts (
                p_project_id                  => p_project_id
               ,p_exp_org_id                  => l_expenditure_ou_tbl(i)
               ,p_calling_module              => 'WORKPLAN'
               ,p_task_id                     => null
               ,p_ei_date                     => SYSDATE
               ,p_denom_raw_cost              => 1
               ,p_denom_curr_code             => P_resource_curr_code_tbl(i)
               ,p_acct_curr_code              => l_func_currency_code
               ,p_accounted_flag              => 'N'
               ,p_acct_rate_date              => l_dummy_rate_date -- NA
               ,p_acct_rate_type              => l_dummy_rate_type -- NA
               ,p_acct_exch_rate              => l_dummy_exch_rate -- NA
               ,p_acct_raw_cost               => l_dummy_cost -- NA
               ,p_project_curr_code           => l_func_currency_code
               ,p_project_rate_type           => l_dummy_rate_type -- NA
               ,p_project_rate_date           => l_dummy_rate_date -- NA
               ,p_project_exch_rate           => l_dummy_exch_rate -- NA
               ,p_project_raw_cost            => l_dummy_cost -- NA
               ,p_projfunc_curr_code          => l_func_currency_code
               ,p_projfunc_cost_rate_type     => l_final_txn_rate_type
               ,p_projfunc_cost_rate_date     => l_final_txn_rate_date
               ,p_projfunc_cost_exch_rate     => l_final_txn_exch_rate
               ,p_projfunc_raw_cost           => l_final_txn_burden_cost
               ,p_system_linkage              => 'NER'
               ,p_status                      => l_status
               ,p_stage                       => l_stage);

           P_resource_raw_rate_tbl(i) := nvl(l_final_txn_exch_rate,0) * NVL(P_resource_raw_rate_tbl(i),0);
           P_resource_burden_rate_tbl(i) := nvl(l_final_txn_exch_rate,0) * NVL(P_resource_burden_rate_tbl(i),0);
           P_resource_curr_code_tbl(i) :=  l_func_currency_code;
        END IF;
  END LOOP;

Exception
  When Others  Then
   null;
 -- END IF;   ------------------------------------------------------------}
end Get_Resource_Cost_Rate;
/*********************Eugene*******************/

 Procedure Validate_Incur_by_Resource(
		P_Resource_Class_Code	  IN  Varchar2,
		P_Res_Type_Code		  IN  Varchar2	Default Null,
		P_Incur_By_Res_Code	  IN  varchar2	Default Null,
		X_Person_Id		  OUT NOCOPY Number,
		X_Incur_By_Role_Id	  OUT NOCOPY Number,
		X_Job_Id		  OUT NOCOPY Number,
		X_Person_Type_Code	  OUT NOCOPY varchar2,
		X_Incur_By_Res_Class_Code OUT NOCOPY varchar2,
		X_Return_Status		  OUT NOCOPY Varchar2,
		X_Error_Message_Code	  OUT NOCOPY Varchar2)

 Is

	MAN_PARAMS_NULL     Exception;
	INVAL_RES_CLSS_CODE Exception;
	INVAL_RES_TYPE_CODE Exception;
	UNEXPEC_ERROR       Exception;

 Begin

	-- Initialize values
	X_Return_Status      := Fnd_Api.G_Ret_Sts_Success;
	X_Error_Message_Code := Null;

	If P_Incur_By_Res_Code is Null Or
	   P_Res_Type_Code is NUll Then

		Raise MAN_PARAMS_NULL;
		--Raise UNEXPEC_ERROR;

	End If;

	If P_Resource_Class_Code <> 'FINANCIAL_ELEMENTS' Then

		Raise INVAL_RES_CLSS_CODE;

	End If;

	If P_Res_Type_Code = 'NAMED_PERSON' Then

		X_Person_Id := P_Incur_By_Res_Code;

	ElsIf P_Res_Type_Code = 'JOB' Then

		X_Job_Id := P_Incur_By_Res_Code;

	ElsIf P_Res_Type_Code = 'PERSON_TYPE' Then

		X_Person_Type_Code := P_Incur_By_Res_Code;

	ElsIf P_Res_Type_Code = 'RESOURCE_CLASS' Then

		X_Incur_By_Res_Class_Code := P_Incur_By_Res_Code;

	ElsIf P_Res_Type_Code = 'ROLE' Then

		X_Incur_By_Role_Id := P_Incur_By_Res_Code;

	Else

		Raise INVAL_RES_TYPE_CODE;

	End If;

 Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_error_message_code := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Validate_Incur_by_Resource');

	When MAN_PARAMS_NULL Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VIR_MAN_PARAMS_NULL';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_VIR_MAN_PARAMS_NULL',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When INVAL_RES_CLSS_CODE Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VIR_INVAL_RES_CLSS_CODE';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_VIR_INVAL_RES_CLSS_CODE',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When INVAL_RES_TYPE_CODE Then
		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Error_Message_Code	:= 'PA_VIR_INVAL_RES_TYPE_CODE';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_VIR_INVAL_RES_TYPE_CODE',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When Others Then
		Raise;

 End Validate_Incur_by_Resource;
/***********Eugene**************/

Procedure Validate_Planning_Resource(
		P_Task_Name		  IN  VARCHAR2 	Default Null,
		P_Task_Number		  IN  Varchar2 	Default Null,
		P_Planning_Resource_Alias IN  Varchar2 	Default Null,
		P_Resource_List_Member_Id IN  Number 	Default Null,
                P_resource_list_id        IN  Number    Default Null,
		P_Res_Format_Id		  IN  Number 	Default Null,
		P_Resource_Class_Code	  IN  Varchar2,
		P_Res_Type_Code		  IN  Varchar2 	Default Null,
		P_Resource_Code		  IN  Varchar2 	Default Null,
		P_Resource_Name		  IN  Varchar2 	Default Null,
		P_Project_Role_Id	  IN  Number 	Default Null,
		P_Project_Role_Name	  IN  Varchar2 	Default Null,
		P_Team_Role	          IN  Varchar2 	Default Null,
		P_Organization_Id	  IN  Number 	Default Null,
		P_Organization_Name	  IN  Varchar2 	Default Null,
		P_FC_Res_Type_Code	  IN  Varchar2 	Default Null,
		P_Fin_Category_Name	  IN  Varchar2 	Default Null,
		P_Supplier_Id		  IN  Number 	Default Null,
		P_Supplier_Name		  IN  Varchar2 	Default Null,
		P_Incur_By_Resource_Code  IN  varchar2 	Default Null,
		P_Incur_By_Resource_Type  IN  Varchar2 	Default Null,
		X_Resource_List_Member_Id OUT NOCOPY Number,
		X_Person_Id		  OUT NOCOPY Number,
		X_Bom_Resource_Id	  OUT NOCOPY Number,
		X_Job_Id		  OUT NOCOPY Number,
		X_Person_Type_Code	  OUT NOCOPY varchar2,
		X_Non_Labor_Resource	  OUT NOCOPY varchar2,
		X_Inventory_Item_Id	  OUT NOCOPY Number,
		X_Item_Category_Id	  OUT NOCOPY Number,
		X_Project_Role_Id	  OUT NOCOPY Number,
		X_Team_Role	          OUT NOCOPY Varchar2,
		X_Organization_Id	  OUT NOCOPY Number,
		X_Expenditure_Type	  OUT NOCOPY Varchar2,
		X_Expenditure_Category	  OUT NOCOPY Varchar2,
		X_Event_Type		  OUT NOCOPY Varchar2,
		X_Revenue_Category_Code	  OUT NOCOPY Varchar2,
		X_Supplier_Id		  OUT NOCOPY Number,
		X_Resource_Class_Id	  OUT NOCOPY Number,
		X_resource_class_flag	  OUT NOCOPY varchar2,
		X_Incur_By_Role_Id	  OUT NOCOPY Number,
		X_Incur_By_Res_Class_Code OUT NOCOPY varchar2,
		X_Incur_By_Res_Flag	  OUT NOCOPY varchar2,
		X_Return_Status		  OUT NOCOPY Varchar2,
		X_Msg_Data		  OUT NOCOPY Varchar2,
		X_Msg_Count		  OUT NOCOPY Number)


 Is

	Cursor c_Res_List_Mem (P_Plan_Res_List_Mem_Id In Number Default Null)
Is
	Select
		Resource_List_Member_Id,
		Res_Format_Id
	From
		Pa_Resource_List_Members
	Where   (P_Plan_Res_List_Mem_Id is Not Null and
		 Resource_List_Member_Id = P_Plan_Res_List_Mem_Id)  ;

        Cursor c_get_migration_code (P_Res_List_Mem_Id In Number) Is
        Select migration_code
        From   Pa_Resource_List_Members
        Where  Resource_List_Member_Id = P_Res_List_Mem_Id;

	Cursor c_Get_Fmt_Details (P_Res_Format_Id IN Number ) is
	Select
		Res_Type_Id,
		Res_Type_Enabled_Flag,
		Orgn_Enabled_Flag,
		Fin_Cat_Enabled_Flag,
		Incurred_By_Enabled_Flag,
		Supplier_Enabled_Flag,
		Role_Enabled_flag,
		Resource_Class_Flag
	From
		Pa_Res_Formats_B
	Where
		Res_Format_Id = P_Res_Format_Id;

        CURSOR get_job_group_id(p_res_list_id in NUMBER) is
        select job_group_id
        from pa_resource_lists_all_bg
        where resource_list_id = p_res_list_id;

        CURSOR chk_job_in_job_group(p_job_group_id IN NUMBER,
                                    p_Job_ID in NUMBER) IS
        select 'Y'
        from per_jobs
        where job_group_id = p_job_group_id
        and  Job_ID = p_Job_ID;

        CURSOR get_res_list_id(p_res_member_id in NUMBER) is
        select resource_list_id
        from pa_resource_list_members
        where resource_list_member_id = p_res_member_id;

	l_Resource_List_Member_Id 	Number := Null;
	l_Res_Format_Id           	Number := Null;
	l_Person_Id			Number := Null;
	l_Incur_By_Role_Id		Number := Null;
	l_Job_Id			Number := Null;
	l_Person_Type_Code		varchar2(30) := Null;
	l_Incur_By_Res_Class_Code	varchar2(30) := Null;
	-- l_dummy_Res_Class_Flag	 	Varchar2(30) := Null;
	l_dummy_Res_Class_Code		Varchar2(30) := Null;
        l_bom_combo_exists              Varchar2(1) := 'N';
	l_jg_valid            		Varchar2(1) := 'Y';
	l_job_group_id                  Number := Null;
	l_resource_list_id              Number := Null;
        l_team_role                     Varchar2(80);
	l_migration_code         	Varchar2(1) := 'N';
	--PARAMS_ALL_NULL          	Exception;
	--BAD_PLAN_RES_LIST_ALIAS  	Exception;
	--BAD_PLAN_RES_LIST_MEM_ID  	Exception;
	--PLN_RL_FORMAT_BAD_FMT_ID	Exception;
	INVALID_BOM_COMBO		Exception;
	BAD_FC_PARAM_COMBO		Exception;
	BAD_INCUR_PARAM_COMBO		Exception;
	MISSING_RES_TYPE_VALUES		Exception;
	MISSING_ORG_VALUES		Exception;
	MISSING_FC_VALUES		Exception;
	MISSING_INCUR_BY_VALUES		Exception;
	MISSING_SUPPLIER_VALUES		Exception;
	MISSING_ROLE_VALUES		Exception;
	MISSING_TEAM_ROLE		Exception;
	FAIL_VALIDATION			Exception;
	-- JOB_GROUP_ERROR			Exception;
	UNEXPEC_ERROR			Exception;

	l_List_Mem_Rec 			c_Res_List_Mem%RowType;
	l_fmt_details  			c_Get_Fmt_Details%RowType;

	Function AddTaskAlias(P_Error_Code  IN Varchar2,
			      P_Task_Number IN Varchar2,
			      P_Task_Name   IN Varchar2,
			      P_Alias       IN Varchar2) Return Varchar2

	Is

		l_Return_Value Varchar2(2000) := Null;

	Begin

		If P_Task_Number is not null and P_Task_Name is Not Null and P_Alias is Not Null Then

			l_Return_Value := P_Error_Code || P_Task_Number || P_Task_Name || P_Alias;

		ElsIf P_Task_Number is not null and P_Task_Name is Not Null Then

			l_Return_Value := P_Error_Code || P_Task_Number || P_Task_Name;

		Else

			l_Return_Value := P_Error_Code;

		End If;

		Return l_Return_Value;

	End AddTaskAlias;

 Begin

	-- Initialize Values
	X_Return_Status           := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Count               := 0;
	X_Msg_Data                := Null;

        X_Incur_By_Res_Flag  := 'N'; -- set it to Yes when checking if
                                     -- incurred by resource exists.

/* bug 3436074
	If P_Resource_List_Member_Id is Null and
	   P_Planning_Resource_Alias is Null and
	   P_Res_Format_Id is Null Then
*/

	If P_Resource_List_Member_Id is Null and
           P_Res_Format_Id is Null Then

		--Raise PARAMS_ALL_NULL;
		Raise UNEXPEC_ERROR;

	End If;

        -- Added to ensure UOM validation for migrated resources
        -- is not done because of a corner case where it is possible
        -- (in the old model) to have an expenditure type of UOM <> Hours
        -- but track as labor as 'Y', which will be upgraded to PEOPLE
        -- resource class.
        l_migration_code := 'N';

	If P_Resource_List_Member_Id is not Null Then

		X_Resource_List_Member_Id := P_Resource_List_Member_Id;
                OPEN c_get_migration_code(P_Res_List_Mem_Id =>
                                                P_Resource_List_Member_Id);
                FETCH c_get_migration_code INTO l_migration_code;
                CLOSE c_get_migration_code;

/* bug 3436074 with the change update top this code is not needed.
	Else

		If P_Planning_Resource_Alias is Not Null Then

			Open c_Res_List_Mem (P_Plan_Res_Alias => P_Planning_Resource_Alias);
			Fetch c_Res_List_Mem Into l_List_Mem_Rec;
			If c_Res_List_Mem%NotFound Then

				Close c_Res_List_Mem;
				Raise BAD_PLAN_RES_LIST_ALIAS;

			End If;
			Close c_Res_List_Mem;

			X_Resource_List_Member_Id := l_List_Mem_Rec.Resource_List_Member_Id;

		End If;
*/

	End If;

	If P_Res_Format_Id Is Null Then

		If x_Resource_List_Member_Id is Not Null Then

			Open c_Res_List_Mem (P_Plan_Res_List_Mem_Id => x_Resource_List_Member_Id);
			Fetch c_Res_List_Mem Into l_List_Mem_Rec;
			If c_Res_List_Mem%NotFound Then

				Close c_Res_List_Mem;
				--Raise BAD_PLAN_RES_LIST_MEM_ID;
				Raise UNEXPEC_ERROR;

			End If;
			Close c_Res_List_Mem;

		End If;

		l_Res_Format_Id := l_List_Mem_Rec.Res_Format_Id;

	Else

		l_Res_Format_Id := P_Res_Format_Id;

	End If;

	Open c_Get_Fmt_Details (P_Res_Format_Id => l_Res_Format_Id);
	Fetch c_Get_Fmt_Details Into l_fmt_details;
	If c_Get_Fmt_Details%NotFound Then

		Close c_Get_Fmt_Details;
		--Raise PLN_RL_FORMAT_BAD_FMT_ID;
		Raise UNEXPEC_ERROR;

	End If;
        Close c_Get_Fmt_Details; --Fix for bug#6504988

	If ( ( P_FC_Res_Type_Code is Null and P_Fin_Category_Name is Null ) or
	     ( P_FC_Res_Type_Code is Not Null and P_Fin_Category_Name is Not Null ) ) Then


		Null;

	Else
		Raise BAD_FC_PARAM_COMBO;

	End If;

	If ( ( P_Incur_By_Resource_Code is Null and P_Incur_By_Resource_Type is Null ) Or
	     ( P_Incur_By_Resource_Code is Not Null and P_Incur_By_Resource_Type is Not Null ) ) Then

		Null;

	Else
		Raise BAD_INCUR_PARAM_COMBO;

	End If;

        -- Set up resource class flag
        x_resource_class_flag := l_fmt_details.resource_class_flag;

	If l_fmt_details.Res_Type_Enabled_Flag = 'Y' and
           P_Resource_Code is Null and
	   P_Resource_Name is Null Then
		Raise MISSING_RES_TYPE_VALUES;

	ElsIf P_Resource_Code is Not Null or
	      P_Resource_Name is Not Null Then

-- hr_utility.trace('P_Resource_Code IS : ' || P_Resource_Code);
-- hr_utility.trace('P_Resource_Name IS : ' || P_Resource_Name);
        	-- Populate g_job_group_id: if the resource is a job then
        	-- need to validate against job group ID.
        	-- Get job group ID from resource list of member
       		-- if not passed in.
		l_resource_list_id := p_resource_list_id;

		If p_resource_list_member_id is not null Then

               		open get_res_list_id(p_resource_list_member_id);
                        fetch get_res_list_id into l_resource_list_id;
                        close get_res_list_id;

		End If;

		If l_resource_list_id IS NOT NULL THEN

               		open get_job_group_id(l_resource_list_id);
                        fetch get_job_group_id into g_job_group_id;
                        close get_job_group_id;

		End If;

-- hr_utility.trace('g_job_group_id IS : ' || g_job_group_id);
-- hr_utility.trace('Before Pa_Planning_Resource_Utils.Validate_Resource');
		Pa_Planning_Resource_Utils.Validate_Resource(
			P_resource_Code		=> P_Resource_Code,
			P_Resource_Name		=> P_Resource_Name,
			P_Resource_Class_Code	=> P_Resource_Class_Code,
			P_Res_Type_Code		=> P_Res_Type_Code,
			X_Person_Id		=> X_Person_Id,
			X_Bom_Resource_Id	=> X_Bom_Resource_Id,
			X_Job_Id		=> X_Job_Id,
			X_Person_Type_Code	=> X_Person_Type_Code,
			X_Non_Labor_Resource	=> X_Non_Labor_Resource,
			X_Inventory_Item_Id	=> X_Inventory_Item_Id,
			X_Item_Category_Id	=> X_Item_Category_Id,
			X_Resource_Class_Code	=> l_Dummy_Res_Class_Code,
			X_Resource_Class_Flag	=> X_resource_class_flag,
			X_Return_Status		=> X_Return_Status,
			X_Error_Msg_Code	=> X_Msg_Data);

-- hr_utility.trace('After Pa_Planning_Resource_Utils.Validate_Resource');
-- hr_utility.trace('X_Return_Status IS : ' || X_Return_Status);
-- hr_utility.trace('X_Msg_Data IS : ' || X_Msg_Data);
		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_VALIDATION;

		End If;

	End If;

	If l_fmt_details.Orgn_Enabled_Flag = 'Y' and
	   P_Organization_Id is Null and
	   P_Organization_Name is Null Then

		Raise MISSING_ORG_VALUES;

	ElsIf P_Organization_Id is Not Null or
	      P_Organization_Name is Not Null Then
		Pa_Planning_Resource_Utils.Validate_Organization(
			P_Organization_Name => P_Organization_Name,
			P_Organization_Id   => P_Organization_Id,
			X_Organization_Id   => X_Organization_Id,
			X_Return_Status     => X_Return_Status,
			X_Error_Msg_Code    => X_Msg_Data);

		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then
			Raise FAIL_VALIDATION;

		End If;

	End If;

	If l_fmt_details.Fin_Cat_Enabled_Flag = 'Y' and
	   P_FC_Res_Type_Code is Null and
	   P_Fin_Category_Name is Null Then

		Raise MISSING_FC_VALUES;

	ElsIf P_FC_Res_Type_Code is Not Null or
	      P_Fin_Category_Name is Not Null Then

		Pa_Planning_Resource_Utils.Validate_Fin_Category(
			P_FC_Res_Type_Code	=> P_FC_Res_Type_Code,
			P_Resource_Class_Code	=> P_Resource_Class_Code,
			P_Fin_Category_Name	=> P_Fin_Category_Name,
                        P_migration_code        => l_migration_code,
			X_Expenditure_Type	=> X_Expenditure_Type,
			X_Expenditure_Category 	=> X_Expenditure_Category,
			X_Event_Type		=> X_Event_Type,
			X_Revenue_Category	=> X_Revenue_Category_Code,
			X_Return_Status		=> X_Return_Status,
			X_Error_Message_Code	=> X_Msg_Data);

		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_VALIDATION;

		End If;

	End If;

	If l_fmt_details.Incurred_By_Enabled_Flag = 'Y' and
	   P_Incur_By_Resource_Code is Null and
	   P_Incur_By_Resource_Type is Null Then

			Raise MISSING_INCUR_BY_VALUES;

	ElsIf P_Incur_By_Resource_Code is Not Null or
	      P_Incur_By_Resource_Type is Not Null Then

		If P_Resource_Class_Code = 'FINANCIAL_ELEMENTS' Then

			Pa_Planning_Resource_Utils.Validate_Incur_by_Resource(
				P_Resource_Class_Code	  => P_Resource_Class_Code,
				P_Res_Type_Code		  => P_Incur_By_Resource_Type,
				P_Incur_By_Res_Code	  => P_Incur_By_Resource_Code,
				X_Person_Id		  => l_Person_Id,
				X_Incur_By_Role_Id	  => l_Incur_By_Role_Id,
				X_Job_Id		  => l_Job_Id,
				X_Person_Type_Code	  => l_Person_Type_Code,
				X_Incur_By_Res_Class_Code => l_Incur_By_Res_Class_Code,
				X_Return_Status		  => X_Return_Status,
				X_Error_Message_Code	  => X_Msg_Data);

			If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

				Raise FAIL_VALIDATION;

			End If;

			X_Incur_By_Res_Flag := 'Y';

			If P_Incur_By_Resource_Type = 'NAMED_PERSON' Then

				X_Person_Id := l_Person_Id;

			ElsIf P_Incur_By_Resource_Type = 'ROLE' Then

				X_Incur_By_Role_Id := l_Incur_By_Role_Id;

			ElsIf P_Incur_By_Resource_Type = 'JOB' Then

				X_Job_Id := l_Job_Id;

			ElsIf P_Incur_By_Resource_Type = 'PERSON_TYPE' Then

				X_Person_Type_Code := l_Person_Type_Code;

			ElsIf P_Incur_By_Resource_Type = 'RESOURCE_CLASS' Then

				X_Incur_By_Res_Class_Code := l_Incur_By_Res_Class_Code;

			End If;

		End If; -- P_Resource_Class_Code = 'FINANCIAL_ELEMENTS'

	End If;

	If l_fmt_details.Supplier_Enabled_Flag = 'Y' and
	   P_Supplier_Id is Null and
	   P_Supplier_Name is Null Then

		Raise MISSING_SUPPLIER_VALUES;

	ElsIf P_Supplier_Id is Not Null or
 	      P_Supplier_Name is Not Null Then

		Pa_Planning_Resource_Utils.Validate_Supplier(
			P_Resource_Class_Code 	=> P_Resource_Class_Code,
			P_Person_Id	 	=> x_person_id,
			P_Supplier_Id	 	=> P_Supplier_Id,
			P_Supplier_Name	 	=> P_Supplier_Name,
			X_Supplier_Id	 	=> X_Supplier_Id,
			X_Return_Status	 	=> X_Return_Status,
			X_Error_Msg_Code 	=> X_Msg_Data);

-- dbms_output.put_line('- After Validate_Supplier X_Supplier_Id IS : '|| X_Supplier_Id);
 -- dbms_output.put_line('- After Validate_Supplier X_Return_Status IS : '|| X_Return_Status);
		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_VALIDATION;

		End If;

	End If;
        -- Team Role changes
        /******************************************************
         * Checking for combination of p_project_role_id and p_team_role
         * If p_project_role_id is null then p_team_role must be null.
         * If p_project_role_id is not null, then p_team_role must be
         * not null.
         *******************************************************/
         /*******************************************************
          * Bug - 3601619
          * Desc - If the p_team_role paramter is null, and the
          * p_Project_Role_Name is not Null or the p_project_role_id
          * is not Null, then we will default the p_team_role to be
          * the same as the P_Project_Role_Name.
          ************************************************************/
          IF p_team_role IS NULL THEN
              IF l_fmt_details.Role_Enabled_flag = 'Y' THEN
                 IF P_Project_Role_Name IS NOT NULL THEN
                    l_team_role := P_Project_Role_Name;
                 ELSE
                    IF p_project_role_id IS NOT NULL THEN
                       l_team_role := Pa_Planning_Resource_Utils.Ret_Role_Name
                                      (P_Role_Id => p_project_role_id );
                    END IF;
                 END IF;
              ELSE
                 l_team_role := NULL;
              END IF;
          ELSE
             -- Cannot have a team role without a role, regardless of
	     -- whether role/team role is part of format.
             -- Check for Role existence.
             IF P_Project_Role_Name IS NULL and p_project_role_id IS NULL AND
                P_Task_Name IS NULL and P_Task_Number IS NULL THEN
                -- Added task name and number check because from TA flow,
                -- it is acceptable in some cases to have a team role
                -- without a role.
                RAISE MISSING_TEAM_ROLE;
             ELSE
                l_team_role := p_team_role;
             END IF;
          END IF;
        --3601619
        --p_team_role changed to l_team_role.

	If l_fmt_details.Role_Enabled_flag = 'Y' THEN
           IF (p_project_role_id IS NULL AND P_Project_Role_Name is Null and
               l_team_role IS NOT NULL) OR
            ((p_project_role_id IS NOT NULL OR P_Project_Role_Name is not null)
                and l_team_role IS NULL)
           THEN
                RAISE MISSING_TEAM_ROLE;
           END IF;
        END IF;

	If l_fmt_details.Role_Enabled_flag = 'Y' and
	   P_Project_Role_Id Is Null and
	   P_Project_Role_Name is Null Then

		Raise MISSING_ROLE_VALUES;

	ElsIf P_Project_Role_Id Is Not Null or
	      P_Project_Role_Name is Not Null Then

		Pa_Role_Utils.Check_Role_Name_Or_Id(
			P_Role_Id		=> P_Project_Role_Id,
			P_Role_Name		=> P_Project_Role_Name,
                        p_check_id_flag         => PA_STARTUP.G_Check_ID_Flag,
			X_Role_Id		=> X_Project_Role_Id,
			X_Return_Status		=> X_Return_Status,
			X_Error_Message_Code	=> X_Msg_Data);

		If X_Return_Status = Fnd_Api.G_Ret_Sts_Error Then

			Raise FAIL_VALIDATION;

		End If;

	End If;
        -- Assign out parameter x_team_role in all cases.
        -- Team Role changes
        --3601619
        x_team_role := l_team_role;

        -- Bug 4202047 - if BOM resource - Org format is used, check
        -- that the combination exists in BOM table - cannot override Org.
        IF X_Bom_Resource_Id IS NOT NULL AND
           X_Organization_Id IS NOT NULL THEN

           -- Validate the combination
           BEGIN
           SELECT 'Y'
             INTO l_bom_combo_exists
             FROM bom_resources b
            WHERE b.resource_id = X_Bom_Resource_Id
              AND b.organization_id = X_Organization_Id
              AND ROWNUM = 1;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 RAISE INVALID_BOM_COMBO;
           END;

        END IF;

 Exception
        When UNEXPEC_ERROR THEN
              X_Return_Status         := Fnd_Api.G_Ret_Sts_UnExp_Error;
              --x_msg_count := x_msg_count + 1;
              x_msg_data := Null;
              Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'PA_PLANNING_RESOURCE_UTILS',
                        P_Procedure_Name   => 'Validate_Planning_Resource');

	/*When PARAMS_ALL_NULL Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_PARAMS_NULL',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_PARAMS_NULL');*/

	/*When BAD_PLAN_RES_LIST_ALIAS Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_BAD_ALIAS',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_BAD_ALIAS');*/

	/*When BAD_PLAN_RES_LIST_MEM_ID Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_BAD_RL_MEM_ID',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_BAD_RL_MEM_ID');*/

	/*When PLN_RL_FORMAT_BAD_FMT_ID Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_FORMAT_BAD_FMT_ID',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_FORMAT_BAD_FMT_ID');*/

/*
        When JOB_GROUP_ERROR Then -- Error Message needs to be defined
                X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
                X_Msg_Count     := 1;
                X_Msg_Data      := AddTaskAlias(
                                        P_Error_Code  => 'PA_JOB_NOT_IN_JOB_GROUP',
                                        P_Task_Number => P_Task_Number,
                                        P_Task_Name   => P_Task_Name,
                                        P_Alias       => P_Planning_Resource_Alias);
                Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_JOB_NOT_IN_JOB_GROUP',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
*/

	When BAD_FC_PARAM_COMBO Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_USE_FC_LOV',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_USE_FC_LOV',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);

	When BAD_INCUR_PARAM_COMBO Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_USE_INCUR_RES_LOV',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_USE_INCUR_RES_LOV',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);

	When MISSING_RES_TYPE_VALUES Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_NO_RES_TYPE',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_NO_RES_TYPE',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);

	When MISSING_ORG_VALUES Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_NO_ORG',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_NO_ORG',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);

	When MISSING_FC_VALUES Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_NO_FC',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_NO_FC',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);

	When MISSING_INCUR_BY_VALUES Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_NO_INCUR_BY',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_NO_INCUR_BY',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);

	When MISSING_SUPPLIER_VALUES Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_NO_SUPPLIER',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_NO_SUPPLIER',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);

	When MISSING_ROLE_VALUES Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_NO_ROLE',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_NO_ROLE',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);

	When MISSING_TEAM_ROLE Then
		X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     := 1;
		X_Msg_Data      := AddTaskAlias(
					P_Error_Code  => 'PA_PLN_RL_TEAM_ROLE',
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		Pa_Utils.Add_Message
			(P_App_Short_Name  => 'PA',
			 P_Msg_Name        => 'PA_PLN_RL_TEAM_ROLE',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When INVALID_BOM_COMBO Then
                X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
                X_Msg_Count     := 1;
                X_Msg_Data      := AddTaskAlias(
                                    P_Error_Code  => 'PA_PLN_RL_INV_BOM_ORG',
                                    P_Task_Number => P_Task_Number,
                                    P_Task_Name   => P_Task_Name,
                                    P_Alias       => P_Planning_Resource_Alias);
                Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_PLN_RL_INV_BOM_ORG',
                         p_token1          => 'PLAN_RES',
                         p_value1          => Pa_Planning_Resource_Pvt.g_token);
	When FAIL_VALIDATION Then
		-- return status is already set by the called procedure already
		X_Msg_Count := 1;
		X_Msg_Data  := AddTaskAlias(
					P_Error_Code  => X_Msg_Data,
			      		P_Task_Number => P_Task_Number,
			      		P_Task_Name   => P_Task_Name,
					P_Alias       => P_Planning_Resource_Alias);
		-- Assuming that all the called procedure already do add_message().

	When Others Then
		Raise;

 End Validate_Planning_Resource;
/***************Eugene***************/

/**********End of Get_Plan_Res_Combination Procedure ********/

/*******************************************************
 * End Eugene's code
 * ***************************************************/

/*********************************************************
 * Procedure : Derive_Resource_List_Member
 * Description : This Procedure is used to derive a
 *               resource list member, given a project ID
 *               resource_format Id and a few attributes.
 *               (1) It first Checks if the Mandatory values
 *                   are passed.
 *               (2) It then calls the API PA_TASK_ASSIGNMENT_UTILS
 *               Get_WP_Resource_List_Id --> which will return the
 *               resource list ID.
 *               (3) Then Based on the values passed Constructs a
 *               Dynamic SQL and retrieves the values from
 *               pa_resource_list_members table.
 *               (4) If no rows are returned then does step 5,6
 *               (5) Checks if the resource list is project specific
 *               If it is then creates a new resource_list_member
 *               Call to pa_planning_resource_pvt.create_planning_resource
 *               And passes back the newly
 *               created resource_list_member_id
 *               (6) If it is a Centrally controlled resource list
 *               Then it calls Vijays API which will return the best
 *               Matching resource list member.
 *               (6a) Insert into Pa_res_list_map_tmp1 and then call
 *               Api pa_resource_mapping.map_resource_list.
 *               which will put the correct resource_list_member_id
 *               in pa_res_list_map_tmp4.
 **************************************************************/
Function Derive_Resource_List_Member
    (p_project_id                IN     NUMBER,
     p_res_format_id             IN     NUMBER,
     p_person_id                 IN     NUMBER     DEFAULT NULL,
     p_job_id                    IN     NUMBER     DEFAULT NULL,
     p_organization_id           IN     NUMBER     DEFAULT NULL,
     p_expenditure_type          IN     Varchar2   DEFAULT NULL,
     p_expenditure_category      IN     Varchar2   DEFAULT NULL,
     p_project_role_id           IN     Number     DEFAULT NULL,
     p_person_type_code          IN     Varchar2   DEFAULT NULL,
     p_named_role                IN     Varchar2   DEFAULT NULL)
   RETURN NUMBER
 IS

CURSOR get_fmt_details (p_res_format_id NUMBER) IS
SELECT f.Res_Type_Enabled_Flag,
       f.Orgn_Enabled_Flag,
       f.Fin_Cat_Enabled_Flag,
       f.Role_Enabled_Flag,
       f.incurred_by_enabled_flag,
       f.supplier_enabled_flag,
       f.Res_Type_Id,
       t.Res_Type_Code
FROM   Pa_Res_Formats_B f,
       Pa_Res_Types_B t
WHERE  f.Res_Type_Id = t.Res_Type_Id(+)
AND    f.Res_Format_Id = p_res_format_id;

   l_resource_list_id        NUMBER;
   l_res_list_member_id      VARCHAR2(30);
   l_resource_list_member_id NUMBER;
   l_cursor                  INTEGER;
   l_rows                    INTEGER;
   l_stmt                    VARCHAR2(2000);
   l_exists                  VARCHAR2(1) := 'Y';
   l_central_control         VARCHAR2(1);
   l_valid                   VARCHAR2(1);
   l_valid_job               VARCHAR2(1);
   l_return_status           VARCHAR2(30);
   l_msg_count               NUMBER;
   l_error_msg_data          VARCHAR2(200);
   l_record_version_number   NUMBER;
   l_resource_class_id       NUMBER;

   l_fmt_details             get_fmt_details%RowType;
   l_person_id               NUMBER := NULL;
   l_job_id                  NUMBER := NULL;
   l_job_group_id            NUMBER := NULL;
   l_organization_id         NUMBER := NULL;
   l_project_role_id         NUMBER := NULL;
   l_person_type_code        VARCHAR2(30) := NULL;
   l_named_role              VARCHAR2(80) := NULL;
   l_fin_category_name       VARCHAR2(200) := NULL;
   l_fc_res_type_code        VARCHAR2(30) := NULL;

  BEGIN
      /***************************************************
      * The Project_ID and res_format_id are mandatory.
      * In case they are not passed. Raise an unexpected
      * error and return.
      ****************************************************/
      IF p_project_id IS NULL OR p_res_format_id IS NULL THEN
           l_resource_list_member_id := NULL;
           Return l_resource_list_member_id;
      END IF;
      /*************************************************
      * Call to Sheenie's API which will take in the
      * project_id and return back the resource_list_id.
      * It would get the resource_list_ID associated to the
      * project and for which Workplan is enabled.
      ****************************************************/
      l_resource_list_id :=
      Pa_Task_Assignment_Utils.Get_WP_Resource_List_Id(p_project_id);

      IF l_resource_list_id IS NULL THEN
           l_resource_list_member_id := NULL;
           Return l_resource_list_member_id;
      END IF;

     /****************************************************
      * Once we have got the Resource_List_ID
      * We need to establish if it is Project specific or
      * Centrally Controlled resource_list.
      *******************************************************/
      BEGIN
         SELECT control_flag
         INTO l_central_control
         FROM pa_resource_lists_all_bg
         WHERE resource_list_id = l_resource_list_id;
      EXCEPTION
      WHEN OTHERS THEN
           l_resource_list_member_id := NULL;
           Return l_resource_list_member_id;
      END;
    /********************************
    *    Open Cursor
    ********************************/
     l_cursor  := dbms_sql.open_cursor;
    /**************************************************************
    * Constructing the Select Statement based on the values passed
    * as parameters to this procedure.
    ***********************************************************/
  l_stmt := 'SELECT resource_list_member_id '||
            ' FROM pa_resource_list_members ' ||
            ' WHERE resource_list_id = :resource_list_id' ||
            ' AND enabled_flag = ''Y'' ' ||
            ' AND res_format_id = :res_format_id';

   -- Get the required segments of the format and append clauses
   -- based on that.  Fixes bug 3728941.
   Open get_fmt_details(p_res_format_id => p_res_format_id);
   Fetch get_fmt_details into l_fmt_details;
   Close get_fmt_details;

   /*****************************************
    * If person_ID value is passed then append
    * it to the Where clause.
    *******************************************/
    IF -- p_person_id IS NOT NULL AND
       l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
       l_fmt_details.Res_Type_Code = 'NAMED_PERSON'
    THEN
       l_person_id := p_person_id;
       l_stmt := l_stmt || ' AND person_id = :person_id';
    END IF;

   /*****************************************
    * If organization_id value is passed then append
    * it to the Where clause.
    *******************************************/
    IF --p_organization_id IS NOT NULL AND
       l_fmt_details.Orgn_Enabled_Flag = 'Y'
    THEN
       l_organization_id := p_organization_id;
       l_stmt := l_stmt || ' AND organization_id = :organization_id';
    END IF;

   /*****************************************
    * If job_id value is passed then append
    * it to the Where clause.
    *******************************************/
    IF -- p_job_id IS NOT NULL AND
       l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
       l_fmt_details.Res_Type_Code = 'JOB'
    THEN
       l_job_id := p_job_id;
       l_stmt := l_stmt || ' AND job_id = :job_id';
    END IF;

   /*****************************************
    * If expenditure_type value is passed then append
    * it to the Where clause.
    *******************************************/
    IF p_expenditure_type IS NOT NULL AND
       l_fmt_details.Fin_Cat_Enabled_Flag = 'Y'
    THEN
       l_fin_category_name := p_expenditure_type;
       l_fc_res_type_code  := 'EXPENDITURE_TYPE';
       l_stmt := l_stmt || ' AND expenditure_type = :expenditure_type AND fc_res_type_code = ''EXPENDITURE_TYPE''';
    END IF;

   /*****************************************
    * If expenditure_category value is passed then append
    * it to the Where clause.
    *******************************************/
    IF p_expenditure_category IS NOT NULL AND p_expenditure_type IS NULL AND
       l_fmt_details.Fin_Cat_Enabled_Flag = 'Y'
    THEN
       l_fin_category_name := p_expenditure_category;
       l_fc_res_type_code  := 'EXPENDITURE_CATEGORY';
       l_stmt := l_stmt || ' AND expenditure_category = :expenditure_category AND fc_res_type_code = ''EXPENDITURE_CATEGORY''';
    END IF;

    IF p_expenditure_category IS NULL AND p_expenditure_type IS NULL AND
       l_fmt_details.Fin_Cat_Enabled_Flag = 'Y'
    THEN
       l_fin_category_name := NULL;
       l_fc_res_type_code  := NULL;
       l_stmt := l_stmt || ' AND expenditure_category = :expenditure_category AND fc_res_type_code = ''EXPENDITURE_CATEGORY''';

    END IF;
   /*****************************************
    * If project_role_id value is passed then append
    * it to the Where clause.
    *******************************************/
   /*****************************************
    * If named_role value is passed then append
    * it to the Where clause.
    *******************************************/
    --IF p_named_role IS NOT NULL THEN
       --l_stmt := l_stmt || ' AND team_role = :named_role';
    --END IF;
    IF p_project_role_id IS NOT NULL AND p_named_role IS NOT NULL AND
       l_fmt_details.Role_Enabled_Flag = 'Y'
    THEN
       l_project_role_id := p_project_role_id;
       l_named_role := p_named_role;
       l_stmt := l_stmt || ' AND project_role_id = :project_role_id AND team_role = :named_role';
    END IF;

   /*****************************************
    * If person_type_code value is passed then append
    * it to the Where clause.
    *******************************************/
    IF -- p_person_type_code IS NOT NULL AND
       l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
       l_fmt_details.Res_Type_Code = 'PERSON_TYPE'
    THEN
       l_person_type_code := p_person_type_code;
       l_stmt := l_stmt || ' AND person_type_code = :person_type_code';
    END IF;


   /********************************************
    * If the List is Centrally Controlled
    * Then need to pass the object_type = 'RESOURCE_LIST'
    * and object_id = resource_list_id.
    * IF the List is not centrally controlled the
    * we need to pass the object_type = 'PROJECT'
    * and object_id = p_project_id.
    ********************************************/
    IF l_central_control = 'Y' THEN
        l_stmt := l_stmt || ' AND object_type = :object_type1';
        l_stmt := l_stmt || ' AND object_id = :resource_list_id';
    ELSE
        l_stmt := l_stmt || ' AND object_type = :object_type2';
        l_stmt := l_stmt || ' AND object_id = :project_id';
    END IF;

    --l_stmt := l_stmt || ';';

-- dbms_output.put_line('l_stmt is :' || substr(l_stmt, 1, 240));
-- dbms_output.put_line('l_stmt is :' || substr(l_stmt, 240, 500));
-- dbms_output.put_line('p_res_format_id is :' || p_res_format_id);
-- dbms_output.put_line('l_resource_list_id is :' || l_resource_list_id);
-- dbms_output.put_line('p_project_role_id is :' || p_project_role_id);
-- dbms_output.put_line('p_named_role is :' || p_named_role);
-- dbms_output.put_line('p_project_id is :' || p_project_id);
    /*************************************
     *    Parse the Select Stmt
     ************************************/
    dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);

    /************************************
    * Bind the Variables
    ********************************/
    /******************************************
     * Bug - 3583651
     * Desc - Added code to Binnd the variables
     *        resource_list_id, res_format_id
     *********************************************/
     --Binding the resource_list_id column
        dbms_sql.bind_variable(l_cursor,'resource_list_id', l_resource_list_id);
     --Binding the res_format_id column
        dbms_sql.bind_variable(l_cursor,'res_format_id', p_res_format_id);

     --Binding the person_id column when p_person_id is not null
    IF -- p_person_id IS NOT NULL AND
       l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
       l_fmt_details.Res_Type_Code = 'NAMED_PERSON'
    THEN
        dbms_sql.bind_variable(l_cursor,'person_id', p_person_id);
    END IF;
     --Binding the job_id column when p_job_id is not null
    IF -- p_job_id IS NOT NULL AND
       l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
       l_fmt_details.Res_Type_Code = 'JOB'
    THEN
-- dbms_output.put_line('p_job_id is :' || p_job_id);
        dbms_sql.bind_variable(l_cursor,'job_id', p_job_id);
    END IF;
     --Binding the organization_id column when p_organization_id is not null
    IF -- p_organization_id IS NOT NULL AND
       l_fmt_details.Orgn_Enabled_Flag = 'Y'
    THEN
-- dbms_output.put_line('p_organization_id is :' || p_organization_id);
       dbms_sql.bind_variable(l_cursor,'organization_id', p_organization_id);
    END IF;
     --Binding the expenditure_type column when p_expenditure_type is not null
    IF p_expenditure_type IS NOT NULL AND
       l_fmt_details.Fin_Cat_Enabled_Flag = 'Y'
    THEN
       dbms_sql.bind_variable(l_cursor,'expenditure_type', p_expenditure_type);
    END IF;
     --Binding the expenditure_category column when
     --p_expenditure_category is not null
    IF p_expenditure_category IS NOT NULL AND p_expenditure_type IS NULL AND
       l_fmt_details.Fin_Cat_Enabled_Flag = 'Y'
    THEN
       dbms_sql.bind_variable(l_cursor,'expenditure_category',p_expenditure_category);
    END IF;

    IF p_expenditure_category IS NULL AND p_expenditure_type IS NULL AND
       l_fmt_details.Fin_Cat_Enabled_Flag = 'Y'
    THEN
       dbms_sql.bind_variable(l_cursor,'expenditure_category',l_fin_category_name);
    END IF;
     --Binding the project_role_id column when p_project_role_id is not null
     --Binding the named_role column when p_named_role is not null
    IF p_project_role_id IS NOT NULL AND p_named_role IS NOT NULL AND
       l_fmt_details.Role_Enabled_Flag = 'Y'
    THEN
       dbms_sql.bind_variable(l_cursor,'project_role_id', p_project_role_id);
       dbms_sql.bind_variable(l_cursor,'named_role', p_named_role);
    END IF;
    --Binding the person_type_code column when p_person_type_code is not null
    IF -- p_person_type_code IS NOT NULL AND
       l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
       l_fmt_details.Res_Type_Code = 'PERSON_TYPE'
    THEN
       dbms_sql.bind_variable(l_cursor,'person_type_code', p_person_type_code);
    END IF;
    --Binding the object_type1 column when l_central_control equals Y
    IF l_central_control = 'Y' THEN
       dbms_sql.bind_variable(l_cursor,'object_type1', 'RESOURCE_LIST');
    END IF;
    --Binding the object_type2 and project_id
    -- column when l_central_control does not equal Y
    IF l_central_control <> 'Y' THEN
       dbms_sql.bind_variable(l_cursor,'object_type2', 'PROJECT');
       dbms_sql.bind_variable(l_cursor,'project_id', p_project_id);
    END IF;

    --Define Output Variables
    --dbms_sql.define_column(l_cursor,1,l_resource_list_member_id,30);
    dbms_sql.define_column(l_cursor,1,l_resource_list_member_id);

    l_rows := dbms_sql.execute(l_cursor);

    /****************************
     * Loop Through the Records
     ****************************/
       /********************************************
       * If No Values are Found we are setting the l_exists
       * flag to be N. If the Value is N we need to do some
       * logic based on the centrally controlled flag.
       **********************************************/
        IF dbms_sql.fetch_rows(l_cursor) = 0 THEN
            l_exists := 'N';
        ELSE
            l_exists := 'Y';
        END IF;
    /**********************************************************
    * If the select returns some Value then assign it to the
    * l_resource_list_member_id.
    * ********************************************************/
    IF l_exists = 'Y' THEN
-- dbms_output.put_line('l_exists is Y');
         dbms_sql.column_value(l_cursor,1,l_resource_list_member_id);
         dbms_sql.close_cursor(l_cursor);
-- dbms_output.put_line('l_resource_list_member_id is :' || l_resource_list_member_id);
         --Return the l_resource_list_member_id
         --To the calling API
         RETURN l_resource_list_member_id;
   END IF;

   /***********************************************************
    * If for the resource_list_ID passed we were not able
    * to derive the appropriate member based on the param
    * passed then we have 2 options
    * depending on the centrally_controlled flag
    * on the resource_list.
    *************************************************************/

   /***********************************************************
   * If the Centrally Controlled flag = 'Y' Then we have to do the
   * following.
   * *********************************************************/
   IF l_exists = 'N' and l_central_control = 'Y' THEN
       --Delete the temp table.
       DELETE FROM pa_res_list_map_tmp1;
       DELETE FROM pa_res_list_map_tmp4;
       /***************************************************
       * Populate the temp table with the parameters passed in.
       * Then we need to call the mapping API, which
       * would read the values from the below table and will get
       * the best matching resource_list_member_id.
       * *****************************************************/
-- dbms_output.put_line('l_fc_res_type_code IS : ' || l_fc_res_type_code);
-- dbms_output.put_line('p_person_id IS : ' || p_person_id);
-- dbms_output.put_line('p_job_id IS : ' || p_job_id);
-- dbms_output.put_line('p_organization_id IS : ' || p_organization_id);
-- dbms_output.put_line('p_expenditure_type IS : ' || p_expenditure_type);
-- dbms_output.put_line('p_expenditure_category IS : ' || p_expenditure_category);
-- dbms_output.put_line('p_project_role_id IS : ' || p_project_role_id);
-- dbms_output.put_line('p_person_type_code IS : ' || p_person_type_code);

       -- populate fc_res_type_code for mapping.
       IF p_expenditure_type IS NOT NULL THEN
          l_fc_res_type_code := 'EXPENDITURE_TYPE';
       ELSIF p_expenditure_category IS NOT NULL THEN
          l_fc_res_type_code := 'EXPENDITURE_CATEGORY';
       END IF;

--dbms_output.put_line('l_fc_res_type_code IS : ' || l_fc_res_type_code);

       INSERT INTO pa_res_list_map_tmp1
              (person_id,
               job_id,
               organization_id,
               expenditure_type,
               expenditure_category,
               fc_res_type_code,
               project_role_id,
               resource_class_id,
               resource_class_code,
               res_format_id,
               person_type_code,
               named_role)
       VALUES
              (p_person_id,
               p_job_id,
               p_organization_id,
               p_expenditure_type,
               p_expenditure_category,
               l_fc_res_type_code,
               p_project_role_id,
               1,
               'PEOPLE',
               p_res_format_id,
               p_person_type_code,
               p_named_role);
       /**********************************************
       * Call to the API passing the resource_list_ID
       * This API would read the values from the temp
       * table pa_res_list_map_tmp1 and will take in
       * the resource_list_id and get the best matching
       * resource_list_member_id and insert it into the
       * table pa_res_list_map_tmp4.
       **************************************************/
-- dbms_output.put_line('Pa_Resource_Mapping.map_resource_list');
-- dbms_output.put_line('l_resource_list_id IS : ' || l_resource_list_id);
-- dbms_output.put_line('p_project_id IS : ' || p_project_id);
       Pa_Resource_Mapping.map_resource_list
          (p_resource_list_id => l_resource_list_id,
           p_project_id       => p_project_id,
           x_return_status    => l_return_status,
           x_msg_count        => l_msg_count,
           x_msg_data         => l_error_msg_data);

         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
              l_resource_list_member_id := NULL;
              RETURN l_resource_list_member_id;
         END IF;

        /***********************************************
        * Get the resource_list_member_id value from
        * the pa_res_list_map_tmp4 table.
        ************************************************/
         BEGIN
            SELECT RESOURCE_LIST_MEMBER_ID
            INTO l_res_list_member_id
            FROM pa_res_list_map_tmp4
            WHERE rownum = 1;
-- dbms_output.put_line('MAPPING l_res_list_member_id IS : ' || l_res_list_member_id);
         EXCEPTION
         WHEN OTHERS THEN
              l_resource_list_member_id := NULL;
              RETURN l_resource_list_member_id;
         END;
         /*******************************************
         * If the resource_list_member_id returned equals
         * 'PEOPLE' then we dont need to return it.
         * so just return Null. Else return the appr
         * value.
         *********************************************/
         IF l_res_list_member_id = 'PEOPLE' THEN
             l_resource_list_member_id := NULL;
         ELSE
             l_resource_list_member_id := l_res_list_member_id;
         END IF;

         RETURN to_number(l_resource_list_member_id);

   END IF;
   /*************************************************
    * If the Resource_list is not Centrally Controlled
    * then do the following
    **********************************************/
   IF l_exists = 'N' and l_central_control = 'N' THEN
--dbms_output.put_line(' START *** ');
      /*************************************************
       * Call to Pa_Planning_Resource_Pvt.Create_Planning_Resource
       * which would create the planning resource member
       * for the project_id,res_format_id and resource_list_id passed
       * using the information passed.
       *****************************************************/
       BEGIN
          SELECT resource_class_id
          INTO   l_resource_class_id
          FROM pa_res_formats_b
          WHERE res_format_id = p_res_format_id;
       EXCEPTION
       WHEN OTHERS THEN
         l_resource_list_member_id := NULL;
       END;

       /* Validate first to ensure that all the required segments
        * exist before calling Create_Planning_Resource because if the
        * resource cannot be created just return null without any error.
        * Create_Planning_Resource puts any error it gets on the stack, which
        * then gets displayed to the user.  We want to prevent that.
        * This is for bug fix 3818238 */

       l_valid := 'Y';
       IF (l_valid = 'Y' AND
           l_fmt_details.Supplier_Enabled_Flag = 'Y') THEN
           l_valid := 'N';
       END IF;

       IF (l_valid = 'Y' AND
           l_fmt_details.Incurred_By_Enabled_Flag = 'Y') THEN
           l_valid := 'N';
       END IF;

       IF (l_valid = 'Y' AND
           l_fmt_details.Fin_Cat_Enabled_Flag = 'Y') THEN
           IF (l_fin_category_name IS NOT NULL AND
               l_fc_res_type_code IS NOT NULL) THEN
               l_valid := 'Y';
           ELSE
               l_valid := 'N';
           END IF;
       END IF;

       IF (l_valid = 'Y' AND
           l_fmt_details.Role_Enabled_Flag = 'Y') THEN
           IF (l_project_role_id IS NOT NULL AND
               l_named_role IS NOT NULL) THEN
               l_valid := 'Y';
           ELSE
               l_valid := 'N';
           END IF;
       END IF;

       IF (l_valid = 'Y' AND
           l_fmt_details.Orgn_Enabled_Flag = 'Y') THEN
           IF (l_organization_id IS NOT NULL) THEN
               l_valid := 'Y';
           ELSE
               l_valid := 'N';
           END IF;
       END IF;

       IF (l_valid = 'Y' AND
           l_fmt_details.Res_Type_Enabled_Flag = 'Y') THEN
           IF ((l_fmt_details.Res_Type_Code = 'NAMED_PERSON' AND
                l_person_id IS NOT NULL) OR
               (l_fmt_details.Res_Type_Code = 'PERSON_TYPE' AND
                l_person_type_code IS NOT NULL) OR
               (l_fmt_details.Res_Type_Code = 'JOB' AND l_job_id IS NOT NULL))
           THEN
               l_valid := 'Y';
           ELSE
               l_valid := 'N';
           END IF;
       END IF;

       IF (l_valid = 'Y' AND l_fmt_details.Res_Type_Code = 'JOB') THEN
          -- Check that list has job group and that job is in job group
          -- Added for bug 4025261
          BEGIN
          SELECT job_group_id
            INTO l_job_group_id
            FROM pa_resource_lists_all_bg
           WHERE resource_list_id = l_resource_list_id;

       	  SELECT 'Y'
	    INTO l_valid_job
       	    FROM per_jobs
	   WHERE job_id = l_job_id
             AND job_group_id = l_job_group_id;

          EXCEPTION WHEN NO_DATA_FOUND THEN
             l_valid := 'N';
          END;

       END IF;

-- dbms_output.put_line('l_valid IS ' || l_valid);
       IF l_valid = 'Y' THEN
-- hr_utility.trace_on(null, 'RMJOB');
-- hr_utility.trace('************* START **************');
-- hr_utility.trace('Call Pa_Planning_Resource_Pvt.Create_Planning_Resource');
--dbms_output.put_line('Pa_Planning_Resource_Pvt.Create_Planning_Resource');
          Pa_Planning_Resource_Pvt.Create_Planning_Resource
             (p_resource_list_id        => l_resource_list_id,
              p_res_format_id           => p_res_format_id,
              p_resource_class_id       => l_resource_class_id,
              p_project_id              => p_project_id,
              p_person_id               => l_person_id,
              p_job_id                  => l_job_id,
              p_organization_id         => l_organization_id,
              p_project_role_id         => l_project_role_id,
              p_person_type_code        => l_person_type_code,
              p_team_role               => l_named_role,
              p_fin_category_name       => l_fin_category_name,
              p_fc_res_type_code        => l_fc_res_type_code,
              x_resource_list_member_id => l_resource_list_member_id,
              x_record_version_number   => l_record_version_number,
              x_return_status           => l_return_status,
              x_msg_count               => l_msg_count,
              x_error_msg_data          => l_error_msg_data);

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
               l_resource_list_member_id := NULL;
            END IF;
        ELSE
           l_resource_list_member_id := NULL;
        END IF;
        --Return the newly created resource_list_member_id.
        RETURN l_resource_list_member_id;
   END IF;

  END Derive_Resource_List_Member;
/***************************************/
/*********************************************************
 * Procedure : Get_Res_Format_For_Team_Role
 * Description : This API is used to return back the correct
 *               resource format ID  to be used for Assignments
 *               and Requirements.
 *               The calling API would pass a resource_list_id
 *               This API would then get all the formats
 *               associated with the resource_list passed
 *               from the pa_plan_rl_formats table which do not
 *               have res_type_code
 *               of Named_person,Bom_Labor,Resource_Class(for Req)
 *               of Bom_Labor,Resource_Class(for asgmt)
 *               - It then gets the format which has the highest
 *               precedence from the list of format ID's.
 *
 * As per bug 6014706 res_type_code can be of type Resource_Class
 ***************************************************************/
Procedure Get_Res_Format_For_Team_Role
    (p_resource_list_id           IN           NUMBER,
     x_asgmt_res_format_id        OUT  NOCOPY  NUMBER,
     x_req_res_format_id          OUT  NOCOPY  NUMBER,
     x_return_status              OUT  NOCOPY  Varchar2)

IS
   /****************************************
   * Cursor c_get_asgmt_res_formats to get the
   * res_formats for assignments.
   *****************************************/
   Cursor c_get_asgmt_res_formats
   IS
    select a.res_format_id
    from pa_res_formats_b a,pa_res_types_b b, pa_plan_rl_formats c
    where a.resource_class_id = 1
    and a.res_type_id = b.res_type_id (+)
    and c.res_format_id = a.res_format_id
    and c.resource_list_id = p_resource_list_id
    and nvl(b.res_type_code, 'DUMMY') <> 'BOM_LABOR';
    /*For bug 6014706 : Removed  RESOURCE_CLASS
    NOT IN ('BOM_LABOR','RESOURCE_CLASS');*/

   /****************************************
   * Cursor c_get_asgmt_res_formats to get the
   * res_formats for requirement.
   *****************************************/
   Cursor c_get_req_res_formats
   IS
    select a.res_format_id
    from pa_res_formats_b a,pa_res_types_b b, pa_plan_rl_formats c
    where a.resource_class_id = 1
    and a.res_type_id = b.res_type_id (+)
    and c.res_format_id = a.res_format_id
    and c.resource_list_id = p_resource_list_id
    and nvl(b.res_type_code, 'DUMMY') NOT IN
        ('NAMED_PERSON','BOM_LABOR','PERSON_TYPE');
     -- Added person_type for Bug 4350963
/*For bug 6014706 : Removed  RESOURCE_CLASS
('NAMED_PERSON','BOM_LABOR','RESOURCE_CLASS', 'PERSON_TYPE');
*/
  l_return_status  Varchar2(30);
  l_msg_code Varchar2(30);
  l_res_format_id  Number;
  l_precedence     Number := 0;
  l_precedence_temp Number := 0;
  l_final_asgmt_format_id Number;
  l_final_req_format_id Number;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  --Using these Dummy Values for precedence
  --for now. Later when Vijay passes the API remove this.
   /************************************************
   * For Assignments do the following
   * ***********************************************/
  IF pa_task_assignment_utils.is_uncategorized_res_list(p_resource_list_id => p_resource_list_id) = 'Y'
  THEN --Added IF-ELSE for bug 5962655
    x_asgmt_res_format_id := Null;
    x_req_res_format_id   := Null;
 ELSE
    OPEN  c_get_asgmt_res_formats;
    l_precedence := 0;
    l_precedence_temp := 1000;
    LOOP
        FETCH c_get_asgmt_res_formats INTO l_res_format_id;
        IF c_get_asgmt_res_formats%ROWCOUNT = 0 THEN
            x_asgmt_res_format_id := Null;
        END IF;
       EXIT WHEN c_get_asgmt_res_formats%NOTFOUND;
         BEGIN
              pa_resource_mapping.get_format_precedence (
                p_resource_class_id   => 1,
                p_res_format_id       => l_res_format_id ,
                x_format_precedence   => l_precedence,
                x_return_status       => l_return_status,
                x_msg_code            => l_msg_code );

                IF l_precedence IS NULL THEN
                     l_final_asgmt_format_id := Null;
                END IF;
         EXCEPTION
         WHEN OTHERS THEN
                x_asgmt_res_format_id := Null;
         END;

        -- The lower the precedence the more granular the format, so
        -- the format with the lowest precedence is best.

        IF l_precedence_temp >= l_precedence THEN
              l_precedence_temp := l_precedence;
              l_final_asgmt_format_id := l_res_format_id;
        END IF;

  END LOOP;
  CLOSE c_get_asgmt_res_formats;


   /************************************************
   * For Requirements do the following
   * ***********************************************/
    OPEN  c_get_req_res_formats;
    l_precedence := 0;
    l_precedence_temp := 1000;
    LOOP
        FETCH c_get_req_res_formats INTO l_res_format_id;
        IF c_get_req_res_formats%ROWCOUNT = 0 THEN
            x_req_res_format_id := Null;
        END IF;
       EXIT WHEN c_get_req_res_formats%NOTFOUND;
       BEGIN
              pa_resource_mapping.get_format_precedence (
                p_resource_class_id   => 1,
                p_res_format_id       => l_res_format_id ,
                x_format_precedence   => l_precedence,
                x_return_status       => l_return_status,
                x_msg_code            => l_msg_code );
                IF l_precedence IS NULL THEN
                     l_final_req_format_id := Null;
                END IF;
         EXCEPTION
         WHEN OTHERS THEN
                x_req_res_format_id := Null;
         END;

        -- The lower the precedence the more granular the format, so
        -- the format with the lowest precedence is best.

        IF l_precedence_temp >= l_precedence THEN
              l_precedence_temp := l_precedence;
              l_final_req_format_id := l_res_format_id;
        END IF;

    END LOOP;
    CLOSE c_get_req_res_formats;

  /***************************************************
   * Return back the final Assignment and Requirement
   * format ID's
   **************************************************/
   x_asgmt_res_format_id := l_final_asgmt_format_id;
   x_req_res_format_id   := l_final_req_format_id;

 END IF; --Added for bug 6014706
END Get_Res_Format_For_Team_Role;

/* ----------------------------------------------------------------
 * API for populating a resource list into the new TL tables. This API
 * is called by the resource list upgrade concurrent program.
 * ----------------------------------------------------------------*/
PROCEDURE Populate_list_into_tl(
  p_resource_list_id   IN NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY VARCHAR2,
  x_msg_data           OUT NOCOPY VARCHAR2 ) IS

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data  := NULL;

Insert into pa_resource_lists_tl (
         LAST_UPDATE_LOGIN,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         RESOURCE_LIST_ID,
         NAME,
         DESCRIPTION,
         LANGUAGE,
         SOURCE_LANG
       ) select
         fnd_global.login_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         lst.resource_list_id,
         lst.name,
         lst.description,
         l.language_code,
         userenv('LANG')
       from pa_resource_lists_all_bg lst,
            fnd_languages l
       where l.Installed_Flag in ('I', 'B')
         and lst.resource_list_id = p_resource_list_id
         and not exists (select 'Y'
                           from pa_resource_lists_tl T
                          where t.resource_list_id = lst.resource_list_id);
EXCEPTION
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count := 1;
     x_msg_data  := SQLERRM;
     RETURN;
END;

/*******************************************************************
 * Procedure : Delete_proj_specific_resource
 * Desc      : This API is used to delete the project specific resources
 *             once the project is deleted.
 *******************************************************************/
 PROCEDURE Delete_Proj_Specific_Resource(
   p_project_id         IN         NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER)
 IS
 l_res_list_id pa_resource_lists_all_bg.resource_list_id%TYPE;

     --For bug 4039707
     CURSOR get_resource_lists IS
     SELECT resource_list_id FROM pa_resource_lists_all_bg
     WHERE migration_code is not null;

 BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count     := 0;

     OPEN get_Resource_lists;

     LOOP
        FETCH get_resource_lists INTO l_res_list_id;
        EXIT WHEN get_resource_lists%NOTFOUND;

        DELETE FROM pa_resource_list_members
        WHERE resource_list_id = l_res_list_id
        AND object_type = 'PROJECT'
        AND  object_id  = p_project_id;
     END LOOP;

     CLOSE get_resource_lists;

 EXCEPTION
 WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name =>
             'Pa_Planning_Resource_Utils.Delete_proj_specific_resource'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
             x_msg_count := x_msg_count+1;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 END Delete_Proj_Specific_Resource;

FUNCTION Get_class_member_id(p_project_id          IN  NUMBER,
                             p_resource_list_id    IN  NUMBER,
                             p_resource_class_code IN  VARCHAR2) return NUMBER
IS

l_resource_list_member_id NUMBER;
l_central_control         VARCHAR2(1);

BEGIN
SELECT nvl(control_flag, 'N')
INTO   l_central_control
FROM   pa_resource_lists_all_bg
WHERE  resource_list_id = p_resource_list_id;

IF l_central_control = 'Y' THEN
   SELECT resource_list_member_id
   INTO   l_resource_list_member_id
   FROM   pa_resource_list_members
   WHERE  resource_list_id = p_resource_list_id
   AND    resource_class_flag = 'Y'
   AND    resource_class_code = p_resource_class_code;
ELSE
   SELECT resource_list_member_id
   INTO   l_resource_list_member_id
   FROM   pa_resource_list_members
   WHERE  resource_list_id = p_resource_list_id
   AND    resource_class_flag = 'Y'
   AND    resource_class_code = p_resource_class_code
   AND    object_type = 'PROJECT'
   AND    object_id = p_project_id;
END IF;

RETURN l_resource_list_member_id;

EXCEPTION WHEN OTHERS THEN
   l_resource_list_member_id := NULL;
   RETURN l_resource_list_member_id;

END Get_class_member_id;

/*****************************************************************
 *  Function : get_rate_based_flag
 *  Given a resource list member, this function returns a flag
 *  to indicate whether the list member is rate based or not.
 *  ************************************************************/
FUNCTION Get_rate_based_flag(p_resource_list_member_id IN NUMBER)
return VARCHAR2 IS

CURSOR get_res_details(p_resource_list_member_id IN NUMBER) IS
SELECT resource_class_code, inventory_item_id, expenditure_type
FROM   pa_resource_list_members
WHERE  resource_list_member_id = p_resource_list_member_id;

l_rate_based_flag VARCHAR2(1) := 'N';
l_res_details     get_res_details%ROWTYPE;

BEGIN
OPEN get_res_details(p_resource_list_member_id => p_resource_list_member_id);
FETCH get_res_details into l_res_details;
IF get_res_details%NOTFOUND THEN
   l_rate_based_flag := NULL;
   RETURN l_rate_based_flag;
END IF;
CLOSE get_res_details;

IF l_res_details.resource_class_code in ('PEOPLE','EQUIPMENT') THEN
   l_rate_based_flag := 'Y';
ELSIF (l_res_details.resource_class_code = 'MATERIAL_ITEMS') AND
      (l_res_details.inventory_item_id IS NOT NULL) THEN

       SELECT 'Y'
       INTO   l_rate_based_flag
       FROM   dual
       WHERE NOT EXISTS (select 'Y'
                         from mtl_system_items_b item,
                              mtl_units_of_measure meas
                        where item.inventory_item_id =
                              l_res_details.inventory_item_id
                          and item.primary_uom_code = meas.uom_code
                          and meas.uom_class = 'Currency');

ELSIF (l_res_details.resource_class_code in ('MATERIAL_ITEMS',
                                             'FINANCIAL_ELEMENTS')) AND
      (l_res_details.expenditure_type IS NOT NULL) AND
      (l_res_details.inventory_item_id IS NULL) THEN

      SELECT c.cost_rate_flag
      INTO   l_rate_based_flag
      FROM   pa_expenditure_types c
      WHERE  c.expenditure_type = l_res_details.expenditure_type;
END IF;

RETURN l_rate_based_flag;

END Get_rate_based_flag;


/*****************************************************************
 * Function : check_enable_allowed
 * Given a disabled resource list member, this function checks to see if
 * enabling it is allowed - meaning that it won't result in a duplicate
 * resource list member.  Hence it checks to see if there are any enabled
 * list members with the same format and attributes.  Returns Y if the
 * given list member is unique; and N if not.
 * This function called from both the planning resource lists page
 * and the resource list form when a list member is enabled.  It is only
 * called for migrated resources to deal with the specific problem of
 * migrating list members which have financial category for both
 * parent and child, and the child cannot be guaranteed to be unique,
 * so it is migrated but disabled.  Look at bugs 3682103 and 3710822 for
 * more detail and background.
 * ************************************************************/
FUNCTION check_enable_allowed(p_resource_list_member_id    IN NUMBER)
                              RETURN VARCHAR2
IS
l_res_format_id        NUMBER;
l_res_list_id          NUMBER;
l_allowed              VARCHAR2(1) := 'Y';
l_enabled_flag         VARCHAR2(1) := 'Y';
l_expenditure_type     VARCHAR2(100);
l_revenue_category     VARCHAR2(100);
l_expenditure_category VARCHAR2(100);
l_event_type           VARCHAR2(100);
l_object_type          VARCHAR2(100);
l_object_id            NUMBER;

BEGIN
SELECT res_format_id, resource_list_id, expenditure_type,
       expenditure_category, revenue_category, event_type, object_type,
       object_id, enabled_flag
INTO   l_res_format_id, l_res_list_id, l_expenditure_type,
       l_expenditure_category, l_revenue_category, l_event_type, l_object_type,
       l_object_id, l_enabled_flag
FROM   pa_resource_list_members
WHERE  resource_list_member_id = p_resource_list_member_id;

l_allowed := 'Y';
IF l_res_format_id in (29, 73) AND (l_enabled_flag = 'N') THEN

   BEGIN
   SELECT 'N'
   INTO   l_allowed
   FROM   pa_resource_list_members
   WHERE  resource_list_id = l_res_list_id
   AND    res_format_id = l_res_format_id
   AND    enabled_flag = 'Y'
   AND    resource_list_member_id <> p_resource_list_member_id
   AND    object_type = l_object_type
   AND    object_id = l_object_id
   AND    nvl(expenditure_type, 'DUMMY') = nvl(l_expenditure_type, 'DUMMY')
   AND    nvl(expenditure_category, 'DUMMY') =
                                           nvl(l_expenditure_category,'DUMMY')
   AND    nvl(revenue_category, 'DUMMY') = nvl(l_revenue_category, 'DUMMY')
   AND    nvl(event_type, 'DUMMY') = nvl(l_event_type, 'DUMMY');

   EXCEPTION WHEN NO_DATA_FOUND THEN
      l_allowed := 'Y';
   END;

END IF;

RETURN l_allowed;

EXCEPTION WHEN OTHERS THEN
   l_allowed := 'N';
   RETURN l_allowed;

END check_enable_allowed;

/*****************************************************************
 * Procedure : check_list_member_on_list
 * Given a resource list member and a resource list, this procedure checks
 * to see if the list member is on the list (looking at the project specific
 * case as well) and returns an error message if it isn't.
 * If p_chk_enabled is passed in as 'Y', an additional check is done
 * to see whether the list member is enabled or not.
 * Added parameters p_alias and x_resource_list_member_id to do
 * name to ID conversion on alias and derive a list member ID.
 * ************************************************************/
PROCEDURE check_list_member_on_list(
  p_resource_list_id          IN NUMBER,
  p_resource_list_member_id   IN NUMBER,
  p_project_id                IN NUMBER,
  p_chk_enabled               IN VARCHAR2 DEFAULT 'N',
  p_alias                     IN VARCHAR2 DEFAULT NULL,
  x_resource_list_member_id   OUT NOCOPY NUMBER,
  x_valid_member_flag         OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY VARCHAR2,
  x_msg_data                  OUT NOCOPY VARCHAR2) IS


l_central_control   VARCHAR2(1)  := 'Y';
l_object_type       VARCHAR2(30) := NULL;
l_object_id         NUMBER;

BEGIN

x_valid_member_flag := NULL;
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_data      := NULL;
x_msg_count     := 0;

SELECT control_flag
INTO   l_central_control
FROM   pa_resource_lists_all_bg
WHERE  resource_list_id = p_resource_list_id;

IF l_central_control = 'N' THEN
   l_object_type := 'PROJECT';
   l_object_id   := p_project_id;
ELSE
   l_object_type := 'RESOURCE_LIST';
   l_object_id   := p_resource_list_id;
END IF;

BEGIN
IF p_alias IS NOT NULL and p_resource_list_member_id IS NULL THEN
   SELECT resource_list_member_id
   INTO   x_resource_list_member_id
   FROM   pa_resource_list_members
   WHERE  alias = p_alias
   AND    resource_list_id = p_resource_list_id
   AND    object_type = l_object_type
   AND    object_id = l_object_id;

ELSIF p_resource_list_member_id IS NOT NULL THEN
   x_resource_list_member_id := p_resource_list_member_id;

ELSIF p_alias IS NULL and p_resource_list_member_id IS NULL THEN
   x_valid_member_flag := 'N';
   x_resource_list_member_id := NULL;
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_data      := 'PA_MEMBER_NOT_ON_LIST';
   x_msg_count     := 1;
   --Modified below for Bug fix 7291217
   Pa_Utils.Add_Message(P_App_Short_Name  => 'PA'
                        ,P_Msg_Name => 'PA_MEMBER_NOT_ON_LIST'
 	                ,P_TOKEN1 => 'RESOURCE_LIST_MEMBER'
 	                ,P_VALUE1 => p_alias
 	                ,P_TOKEN2 => 'RESOURCE_LIST'
 	                ,P_VALUE2 => PA_TASK_UTILS.GET_RESOURCE_LIST_NAME(p_resource_list_id));
   RETURN;
END IF;

SELECT 'Y'
INTO   x_valid_member_flag
FROM   pa_resource_list_members
WHERE  resource_list_member_id = x_resource_list_member_id
AND    resource_list_id = p_resource_list_id
AND    object_type = l_object_type
AND    object_id = l_object_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
   x_valid_member_flag := 'N';
   x_resource_list_member_id := NULL;
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_msg_data      := 'PA_MEMBER_NOT_ON_LIST';
   x_msg_count     := 1;
   --Modified below for Bug fix 7291217
   Pa_Utils.Add_Message(P_App_Short_Name  => 'PA'
                          ,P_Msg_Name => 'PA_MEMBER_NOT_ON_LIST'
 	                  ,P_TOKEN1 => 'RESOURCE_LIST_MEMBER'
 	                  ,P_VALUE1 => p_alias
 	                  ,P_TOKEN2 => 'RESOURCE_LIST'
 	                  ,P_VALUE2 => PA_TASK_UTILS.GET_RESOURCE_LIST_NAME(p_resource_list_id));
   RETURN;
END;

IF p_chk_enabled = 'Y' THEN
   BEGIN
   SELECT 'Y'
   INTO   x_valid_member_flag
   FROM   pa_resource_list_members
   WHERE  resource_list_member_id = x_resource_list_member_id
   AND    enabled_flag = 'Y';

   EXCEPTION WHEN NO_DATA_FOUND THEN
      x_valid_member_flag := 'N';
      x_resource_list_member_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data      := 'PA_MEMBER_NOT_ENABLED';
      x_msg_count     := 1;
      Pa_Utils.Add_Message(P_App_Short_Name  => 'PA',
                           P_Msg_Name        => 'PA_MEMBER_NOT_ENABLED');
      RETURN;
   END;
END IF;

END check_list_member_on_list;

/********************************************************************
 * Procedure  : default_other_elements
 * This procedure derives other segments for a planning resource, based
 * on the resource format, if it is possible to derive anything.  For
 * example, if the format provided is Named Person - Organization, and
 * the person ID or name is specified, the person's HR Organization is derived
 * and passed back as X_organization_id and X_organization_name.  Please
 * see the functional design for all the values that can be derived.
 * Currently, the only formats that can allow derivation are:
 * BOM Equipment - Organization - 48
 * BOM Labor - Organization - 10
 * Named Person - Financial Category - Organization (get Org) - 3
 * Named Person - Organization - 5
 * Projects Non-Labor Resource - Financial Category - Organization (get Fin Cat) - 43
 * *****************************************************************/
PROCEDURE default_other_elements (
P_res_format_id          IN             NUMBER,
P_person_id              IN             NUMBER    DEFAULT NULL,
P_person_name            IN             VARCHAR2  DEFAULT NULL,
p_bom_resource_id        IN             NUMBER    DEFAULT NULL,
p_bom_resource_name      IN             VARCHAR2  DEFAULT NULL,
p_non_labor_resource     IN             VARCHAR2  DEFAULT NULL,
X_organization_id        OUT NOCOPY     NUMBER,
x_organization_name      OUT NOCOPY     VARCHAR2,
X_expenditure_type       OUT NOCOPY     VARCHAR2,
X_msg_data               OUT NOCOPY     VARCHAR2,
X_msg_count              OUT NOCOPY     NUMBER,
X_return_status          OUT NOCOPY     VARCHAR2) IS

CURSOR get_fmt_details (p_res_format_id IN NUMBER) IS
SELECT f.Res_Type_Enabled_Flag,
       f.Orgn_Enabled_Flag,
       f.Fin_Cat_Enabled_Flag,
       f.Role_Enabled_Flag,
       f.Res_Type_Id,
       t.Res_Type_Code
FROM   Pa_Res_Formats_B f,
       Pa_Res_Types_B t
WHERE  f.Res_Type_Id = t.Res_Type_Id(+)
AND    f.Res_Format_Id = p_res_format_id;

l_fmt_details             get_fmt_details%RowType;
l_person_id               NUMBER;
l_bom_resource_id         NUMBER;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;
x_msg_data      := NULL;
x_msg_count     := 0;
X_organization_id := NULL;
X_organization_name := NULL;
X_expenditure_type := NULL;

Open get_fmt_details(p_res_format_id => p_res_format_id);
Fetch get_fmt_details into l_fmt_details;
Close get_fmt_details;

IF l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
   (l_fmt_details.Res_Type_Code = 'NAMED_PERSON' AND
   (P_person_id is not NULL OR P_person_name is NOT NULL)) THEN
   IF l_fmt_details.Orgn_Enabled_Flag = 'Y' THEN
      -- Do name to ID conversion on person
      pa_planning_resource_utils.Check_PersonName_or_ID(
                p_person_id      => P_person_id,
                p_person_name    => P_person_name,
                p_check_id_flag  => PA_STARTUP.G_Check_ID_Flag,
                x_person_id      => l_person_id,
                x_return_status  => x_return_status,
                x_error_msg_code => X_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 PA_UTILS.Add_Message ('PA', X_msg_data, 'PLAN_RES',
                                       Pa_Planning_Resource_Pvt.g_token);
                 Return;
             END IF;

      -- Get the person's HR Org and pass back
      BEGIN
      SELECT a.organization_id, orgvl.name
        INTO X_organization_id, X_organization_name
        FROM per_assignments_x a,
             pa_all_organizations org,
             hr_all_organization_units_vl orgvl
       WHERE a.person_id = l_person_id
         AND a.organization_id = orgvl.organization_id
         AND a.organization_id = org.organization_id
         AND org.inactive_date is null
         AND org.pa_org_use_type = 'EXPENDITURES'
         AND a.assignment_type in ('C','E')
         AND a.primary_flag = 'Y'
         AND ROWNUM = 1;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         X_organization_id := NULL;
         X_organization_name := NULL;
      END;

   END IF;
ELSIF l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
      (l_fmt_details.Res_Type_Code in ('BOM_LABOR', 'BOM_EQUIPMENT') AND
      (p_bom_resource_id is not NULL OR p_bom_resource_name is NOT NULL)) THEN

      -- Do name to ID conversion on bom resource
      IF l_fmt_details.Res_Type_Code = 'BOM_LABOR' THEN
         pa_planning_resource_utils.Check_BOM_EqLabor_or_ID(
           p_bom_eqlabor_id       => p_bom_resource_id,
           p_bom_eqlabor_name     => p_bom_resource_name,
           p_res_type_code        => 2,
           p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag,
           x_bom_resource_id      => l_bom_resource_id,
           x_return_status        => x_return_status,
           x_error_msg_code       => X_msg_data);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            PA_UTILS.Add_Message ('PA', X_msg_data, 'PLAN_RES',
                                  Pa_Planning_Resource_Pvt.g_token);
            Return;
         END IF;
      ELSIF l_fmt_details.Res_Type_Code = 'BOM_EQUIPMENT' THEN
         pa_planning_resource_utils.Check_BOM_EqLabor_or_ID(
           p_bom_eqlabor_id       => p_bom_resource_id,
           p_bom_eqlabor_name     => p_bom_resource_name,
           p_res_type_code        => 1,
           p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag,
           x_bom_resource_id      => l_bom_resource_id,
           x_return_status        => x_return_status,
           x_error_msg_code       => X_msg_data);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            PA_UTILS.Add_Message ('PA', X_msg_data, 'PLAN_RES',
                                  Pa_Planning_Resource_Pvt.g_token);
            Return;
         END IF;
      END IF;

      IF (l_fmt_details.Orgn_Enabled_Flag = 'Y' AND
          l_bom_resource_id IS NOT NULL) THEN
      -- Get the Org
         SELECT b.organization_id, orgvl.name
           INTO X_organization_id, X_organization_name
           FROM bom_resources b,
                hr_all_organization_units_vl orgvl
          WHERE b.resource_id = l_bom_resource_id
            AND b.organization_id = orgvl.organization_id
            AND ROWNUM = 1;

      END IF;

ELSIF l_fmt_details.Res_Type_Enabled_Flag = 'Y' AND
      (l_fmt_details.Res_Type_Code = 'NON_LABOR_RESOURCE' AND
       p_non_labor_resource is not NULL) THEN

      IF l_fmt_details.Fin_Cat_Enabled_Flag = 'Y' THEN
         -- Get the Fin Cat
         SELECT n.expenditure_type
           INTO x_expenditure_type
           FROM pa_non_labor_resources n
          WHERE n.non_labor_resource = p_non_labor_resource
            AND ROWNUM = 1;

      END IF;
END IF;

END default_other_elements;

END PA_PLANNING_RESOURCE_UTILS;
/******************************************************************/

/
