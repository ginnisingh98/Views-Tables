--------------------------------------------------------
--  DDL for Package Body PA_RBS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_UTILS" AS
/* $Header: PARRBSUB.pls 120.9 2006/03/13 04:41:06 avaithia noship $ */

/********************************************************
 * Function : get_max_rbs_frozen_version
 * Description : Get the latest frozen version of an RBS.
 *******************************************************/
FUNCTION get_max_rbs_frozen_version(p_rbs_header_id IN NUMBER) return NUMBER
IS

l_version_id NUMBER := NULL;
BEGIN
   IF p_rbs_header_id IS NOT NULL THEN
      BEGIN
      select rbs_version_id
      into   l_version_id
      from   pa_rbs_versions_b ver1
      where  ver1.rbs_header_id = p_rbs_header_id
        and  ver1.current_reporting_flag = 'Y';
-- sysdate join?
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_version_id := NULL;
         WHEN OTHERS THEN
            l_version_id := NULL;
      END;
   END IF;

   RETURN l_version_id;

END get_max_rbs_frozen_version;

/*****************************************************
 * Function : Get_element_Name
 * Description : This Function is used to return the
 *               Element_Name for a given
 *               resource_source_id and resource_type_code
 *               passed in.
 * **************************************************/
Function Get_element_Name
   (p_resource_source_id IN Number,
    p_resource_type_code   IN Varchar2)
RETURN Varchar2
IS
 l_element_name Varchar2(240);
 l_return_status Varchar2(30);
 l_msg_data Varchar2(30);
 l_revenue_category_code Varchar2(30);
BEGIN
    /****************************************************************
    * If the p_resource_source_id or the p_resource_type_code
    * passed in is Null then we cannot derive the element_name
    * so just pass back null and return.
    * ****************************************************************/
    IF p_resource_source_id IS NULL OR p_resource_type_code IS NULL THEN
        l_element_name := NULL;
        Return l_element_name;
    END IF;

    IF p_resource_type_code = 'VERSION' THEN
         BEGIN
            SELECT name
            INTO   l_element_name
            FROM   Pa_rbs_versions_tl
            WHERE  rbs_version_id = p_resource_source_id
            AND    language = userenv('LANG');
         EXCEPTION
         WHEN OTHERS THEN
              l_element_name := Null;
         END;
    END IF;
    --If the p_resource_type_code = NAMED_PERSON
    --Then call to Get_Resource_Name to get the
    --element_name
    IF p_resource_type_code = 'NAMED_PERSON' THEN
        Pa_Planning_resource_utils.Get_Resource_Name
          ( P_Res_Type_Code            => 'NAMED_PERSON',
            P_Person_Id                => p_resource_source_id,
            P_Bom_Resource_Id          => null,
            P_Job_Id                   => null,
            P_Person_Type_Code         => null,
            P_Non_Labor_Resource       => null,
            P_Inventory_Item_Id        => null,
            P_Item_Category_Id         => null,
            P_Resource_Class_Id        => null,
            P_Proc_Func_Flag           => null,
            P_Res_Assignment_Id        => null,
            X_Resource_Displayed       => l_element_name,
            X_Return_Status            => l_return_status,
            X_Msg_Data                 => l_msg_data );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_element_name := NULL;
           END IF;
    END IF;

    --If the p_resource_type_code = JOB
    --Then call to Get_Resource_Name to get the
    --element_name
    IF p_resource_type_code = 'JOB' THEN
        Pa_Planning_resource_utils.Get_Resource_Name
          ( P_Res_Type_Code            => 'JOB',
            P_Person_Id                => null,
            P_Bom_Resource_Id          => null,
            P_Job_Id                   => p_resource_source_id,
            P_Person_Type_Code         => null,
            P_Non_Labor_Resource       => null,
            P_Inventory_Item_Id        => null,
            P_Item_Category_Id         => null,
            P_Resource_Class_Id        => null,
            P_Proc_Func_Flag           => null,
            P_Res_Assignment_Id        => null,
            X_Resource_Displayed       => l_element_name,
            X_Return_Status            => l_return_status,
            X_Msg_Data                 => l_msg_data );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_element_name := NULL;
           END IF;
    END IF;

    --If the p_resource_type_code = PERSON_TYPE
    --Then use the below select to get the
    --element_name
    IF p_resource_type_code = 'PERSON_TYPE' THEN
          BEGIN
             SELECT lk.meaning
             INTO  l_element_name
             from hr_lookups lk, per_person_types per
             where lk.lookup_type = 'PERSON_TYPE'
             and per.system_person_type in ('EMP', 'CWK')
             and per.system_person_type = lk.lookup_code
             and per.business_group_id = 0
             and per.person_type_id = p_resource_source_id;
         EXCEPTION WHEN OTHERS THEN
                l_element_name := NULL;
	END;
    END IF;

    --If the p_resource_type_code = BOM_LABOR
    --Then call to Get_Resource_Name to get the
    --element_name
    IF p_resource_type_code = 'BOM_LABOR' THEN
        Pa_Planning_resource_utils.Get_Resource_Name
          ( P_Res_Type_Code            => 'BOM_LABOR',
            P_Person_Id                => null,
            P_Bom_Resource_Id          => p_resource_source_id,
            P_Job_Id                   => null,
            P_Person_Type_Code         => null,
            P_Non_Labor_Resource       => null,
            P_Inventory_Item_Id        => null,
            P_Item_Category_Id         => null,
            P_Resource_Class_Id        => null,
            P_Proc_Func_Flag           => null,
            P_Res_Assignment_Id        => null,
            X_Resource_Displayed       => l_element_name,
            X_Return_Status            => l_return_status,
            X_Msg_Data                 => l_msg_data );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_element_name := NULL;
           END IF;
    END IF;

    --If the p_resource_type_code = BOM_EQUIPMENT
    --Then call to Get_Resource_Name to get the
    --element_name
    IF p_resource_type_code = 'BOM_EQUIPMENT' THEN
        Pa_Planning_resource_utils.Get_Resource_Name
          ( P_Res_Type_Code            => 'BOM_EQUIPMENT',
            P_Person_Id                => null,
            P_Bom_Resource_Id          => p_resource_source_id,
            P_Job_Id                   => null,
            P_Person_Type_Code         => null,
            P_Non_Labor_Resource       => null,
            P_Inventory_Item_Id        => null,
            P_Item_Category_Id         => null,
            P_Resource_Class_Id        => null,
            P_Proc_Func_Flag           => null,
            P_Res_Assignment_Id        => null,
            X_Resource_Displayed       => l_element_name,
            X_Return_Status            => l_return_status,
            X_Msg_Data                 => l_msg_data );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_element_name := NULL;
           END IF;
    END IF;

    --If the p_resource_type_code = ITEM_CATEGORY
    --Then call to Get_Resource_Name to get the
    --element_name
    IF p_resource_type_code = 'ITEM_CATEGORY' THEN
        Pa_Planning_resource_utils.Get_Resource_Name
          ( P_Res_Type_Code            => 'ITEM_CATEGORY',
            P_Person_Id                => null,
            P_Bom_Resource_Id          => null,
            P_Job_Id                   => null,
            P_Person_Type_Code         => null,
            P_Non_Labor_Resource       => null,
            P_Inventory_Item_Id        => null,
            P_Item_Category_Id         => p_resource_source_id,
            P_Resource_Class_Id        => null,
            P_Proc_Func_Flag           => null,
            P_Res_Assignment_Id        => null,
            X_Resource_Displayed       => l_element_name,
            X_Return_Status            => l_return_status,
            X_Msg_Data                 => l_msg_data );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_element_name := NULL;
           END IF;
    END IF;

    --If the p_resource_type_code = INVENTORY_ITEM
    --Then call to Get_Resource_Name to get the
    --element_name
    IF p_resource_type_code = 'INVENTORY_ITEM' THEN
        Pa_Planning_resource_utils.Get_Resource_Name
          ( P_Res_Type_Code            => 'INVENTORY_ITEM',
            P_Person_Id                => null,
            P_Bom_Resource_Id          => null,
            P_Job_Id                   => null,
            P_Person_Type_Code         => null,
            P_Non_Labor_Resource       => null,
            P_Inventory_Item_Id        => p_resource_source_id,
            P_Item_Category_Id         => null,
            P_Resource_Class_Id        => null,
            P_Proc_Func_Flag           => null,
            P_Res_Assignment_Id        => null,
            X_Resource_Displayed       => l_element_name,
            X_Return_Status            => l_return_status,
            X_Msg_Data                 => l_msg_data );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_element_name := NULL;
           END IF;
    END IF;

    --If the p_resource_type_code = NON_LABOR_RESOURCE
    --Then call to Get_Resource_Name to get the
    --element_name
    IF p_resource_type_code = 'NON_LABOR_RESOURCE' THEN
        BEGIN
           SELECT non_labor_resource
           INTO l_element_name
           FROM pa_non_labor_resources
           WHERE NON_LABOR_RESOURCE_ID = p_resource_source_id;
        EXCEPTION
        WHEN OTHERS THEN
           l_element_name := NULL;
        END;
    END IF;

    --If the p_resource_type_code = RESOURCE_CLASS
    --Then call to Get_Resource_Name to get the
    --element_name
    IF p_resource_type_code = 'RESOURCE_CLASS' THEN
        Pa_Planning_resource_utils.Get_Resource_Name
          ( P_Res_Type_Code            => 'RESOURCE_CLASS',
            P_Person_Id                => null,
            P_Bom_Resource_Id          => null,
            P_Job_Id                   => null,
            P_Person_Type_Code         => null,
            P_Non_Labor_Resource       => null,
            P_Inventory_Item_Id        => null,
            P_Item_Category_Id         => null,
            P_Resource_Class_Id        => p_resource_source_id,
            P_Proc_Func_Flag           => null,
            P_Res_Assignment_Id        => null,
            X_Resource_Displayed       => l_element_name,
            X_Return_Status            => l_return_status,
            X_Msg_Data                 => l_msg_data );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_element_name := NULL;
           END IF;
    END IF;

    IF p_resource_type_code = 'REVENUE_CATEGORY' THEN
      /***********************************************
      * Get the revenue Category Code from pa_rbs_element_map
      * table, based on the ID passed.
      ************************************************/
       BEGIN
           SELECT RESOURCE_NAME
           INTO l_revenue_category_code
           FROM Pa_rbs_element_map
           --WHERE RESOURCE_NAME = 'REVENUE_CATEGORY' -- NEED TO REVISIT
           WHERE resource_type_id =
                     (SELECT res_type_id
                      FROM pa_res_types_b
                      WHERE res_type_code =  'REVENUE_CATEGORY')
           AND   RESOURCE_ID = p_resource_source_id;
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;

      /***********************************************
      * Get the Meaning from Pa_Lookups
      * table, for the lookup_type = 'REVENUE CATEGORY'
      * and lookup code = the l_revenue_category_code.
      ************************************************/
       BEGIN
          SELECT lk.Meaning
          INTO l_element_name
          FROM PA_LOOKUPS lk
          WHERE lk.Lookup_Type = 'REVENUE CATEGORY'
          and lk.lookup_code = l_revenue_category_code;
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;

    END IF;

    --If the p_resource_type_code = EVENT_TYPE
    --Then use the below select to get the
    --element_name
   IF p_resource_type_code = 'EVENT_TYPE' THEN
       BEGIN
           SELECT Event_Type
           INTO l_element_name
           FROM pa_event_types
           WHERE event_type_id = p_resource_source_id;
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;
   END IF;

    --If the p_resource_type_code = EXPENDITURE_TYPE
    --Then use the below select to get the
    --element_name
   IF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
       BEGIN
           SELECT expenditure_type
           INTO l_element_name
           FROM pa_expenditure_types
           WHERE expenditure_type_id = p_resource_source_id;
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;
   END IF;

    --If the p_resource_type_code = EXPENDITURE_CATEGORY
    --Then use the below select to get the
    --element_name
   IF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
       BEGIN
           SELECT expenditure_category
           INTO l_element_name
           FROM pa_expenditure_categories
           WHERE expenditure_category_id = p_resource_source_id;
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;
   END IF;

    --If the p_resource_type_code = ORGANIZATION
    --Then call to Ret_Organization_Name to get the
    --element_name
   IF p_resource_type_code = 'ORGANIZATION' THEN
       BEGIN
           l_element_name := Pa_Planning_Resource_Utils.Ret_Organization_Name
                             (P_Organization_Id => p_resource_source_id);
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;
   END IF;

    --If the p_resource_type_code = ROLE
    --Then call to Ret_Role_Name to get the
    --element_name
   IF p_resource_type_code = 'ROLE' THEN
       BEGIN
           l_element_name := Pa_Planning_Resource_Utils.Ret_Role_Name
                             (P_Role_Id => p_resource_source_id);
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;
   END IF;

    --If the p_resource_type_code = SUPPLIER
    --Then use the below select to get the
    --element_name
   IF p_resource_type_code = 'SUPPLIER' THEN
       BEGIN
          SELECT Vendor_Name
          INTO l_element_name
          FROM po_vendors
          WHERE vendor_id = p_resource_source_id;
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;
   END IF;

    --If the p_resource_type_code IN (NAMED_ROLE,USER_DEFINED)
    --Then use the below select to get the
    --element_name
   IF p_resource_type_code IN ('NAMED_ROLE','USER_DEFINED') THEN
       BEGIN
           SELECT resource_name
           INTO l_element_name
           FROM pa_rbs_element_map
           --WHERE RESOURCE_NAME = p_resource_type_code -- NEED TO REVISIT
           WHERE resource_type_id =
                     (SELECT res_type_id
                      FROM pa_res_types_b
                      WHERE res_type_code =  'REVENUE_CATEGORY')
           AND   RESOURCE_ID  = p_resource_source_id;
       EXCEPTION
       WHEN OTHERS THEN
           l_element_name := Null;
       END;
   END IF;

    Return l_element_name;

END Get_element_Name;
/********************************************************
 * Procedure : Insert_elements
 * Description : This Procedure is used to insert into
 *               the pa_rbs_element_names_b table
 *               it does a direct
 *               Insert from the pa_rbs_elem_in_temp
 *               table based on the resource_type_id
 *               passed.
 * *****************************************************/
  PROCEDURE Insert_elements(p_resource_type_id    IN  NUMBER,
                            x_return_status      OUT NOCOPY Varchar2)
 IS
     --l_element_name_id Number;
  BEGIN
     -- IF p_call_flag = 'B' THEN
         INSERT INTO Pa_rbs_element_names_b
               (RBS_ELEMENT_NAME_ID,
                RESOURCE_SOURCE_ID,
                RESOURCE_TYPE_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN)
         SELECT
               PA_RBS_ELEMENT_NAMES_S.NEXTVAL,
               a.resource_source_id,
               a.resource_type_id,
               sysdate,
               FND_GLOBAL.USER_ID,
                sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
        FROM pa_rbs_elem_in_temp a
        WHERE a.resource_type_id = p_resource_type_id
        AND NOT EXISTS (select 'Y'
                        FROM Pa_rbs_element_names_b b
                        where b.RESOURCE_TYPE_ID = a.resource_type_id
                        and   b.RESOURCE_SOURCE_ID = a.resource_source_id);
        -- AND (a.resource_source_id,a.resource_type_id)
        -- NOT IN (SELECT RESOURCE_SOURCE_ID, RESOURCE_TYPE_ID
        --         FROM Pa_rbs_element_names_b
        --         where RESOURCE_TYPE_ID = p_resource_type_id);
  EXCEPTION
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
  END Insert_elements;

/******************************************************
 * Procedure : Insert_non_tl_names
 * Description : This API is used to insert into the
 *               pa_rbs_element_names_tl table.
 *               For those res_type_codes for which there
 *               is no Multi lang support.
 *               We are going to insert the value based
 *               on the values inserted into the
 *               pa_rbs_element_names_b table.
 * **************************************************/
PROCEDURE Insert_non_tl_names
           (p_resource_type_id   IN Number,
            p_resource_type_code IN Varchar2,
            x_return_status      OUT NOCOPY Varchar2)
IS
  l_count Number;
  l_temp_count Number;
BEGIN
   IF p_resource_type_code = 'VERSION' THEN--VERSION
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.name,
               c.language,
               c.source_lang,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Pa_rbs_versions_tl c
            WHERE a.resource_source_id = b.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            AND   c.rbs_version_id   = a.resource_source_id
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = c.language);
   END IF;--VERSION

   IF p_resource_type_code = 'RULE' THEN--RULE
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.meaning,
               c.language,
               c.source_lang,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                fnd_lookup_values c
            WHERE a.resource_source_id = b.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            AND   c.lookup_type   = 'RBS_RULE_RESOURCE'
            AND   c.lookup_code   = 'USER_DEFINED_RESOURCE'
            AND   c.view_application_id = 275
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = c.language);
   END IF;--RULE

   --MLS Changes.
   IF p_resource_type_code = 'NAMED_PERSON' THEN--NAMED_PERSON
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.full_name,
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                per_all_people_f c,
                fnd_languages l
            WHERE a.resource_source_id = b.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            AND   c.person_Id   = a.resource_source_id
            and   sysdate between c.effective_start_date
                              and c.effective_end_date
            and   l.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--NAMED_PERSON

   --MLS Changes.
   IF p_resource_type_code = 'JOB' THEN--JOB
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.name,
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Per_Jobs c,
                Fnd_Languages L
            WHERE a.resource_source_id = b.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            AND   c.Job_Id   = a.resource_source_id
            and   l.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--JOB

   IF p_resource_type_code = 'PERSON_TYPE' THEN --PERSON_TYPE
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               lk.meaning,
               lk.language,
               lk.source_lang,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                fnd_lookup_values lk,
		/* Changes for Bug 3780201 start*/
		pa_rbs_element_map c
            WHERE a.resource_source_id = b.resource_source_id
             and a.resource_type_id   = p_resource_type_id
             and b.resource_type_id   = p_resource_type_id
             and lk.lookup_type = 'PA_PERSON_TYPE'
	     and c.resource_id = a.resource_source_id
	     and c.resource_type_id = p_resource_type_id
	     and lk.lookup_code = c.resource_name
             and NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = lk.language);
   END IF;--PERSON_TYPE

   --MLS Changes.
   IF p_resource_type_code IN ('BOM_LABOR','BOM_EQUIPMENT') THEN
       --BOM_LABOR,BOM_EQUIPMENT
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               --For bug 3602566.
               --c.description,
               c.resource_code, --End of bug 3602566.
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Bom_Resources c,
                Fnd_Languages L
            WHERE a.resource_source_id = b.resource_source_id
            and c.resource_id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and   L.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--BOM_LABOR,BOM_EQUIPMENT

   --MLS Changes.
   IF p_resource_type_code = 'NON_LABOR_RESOURCE' THEN
       --NON_LABOR_RESOURCE
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.non_labor_resource,
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                pa_non_labor_resources c,
                Fnd_Languages L
            WHERE a.resource_source_id = b.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and   c.non_labor_resource_id = a.resource_source_id
            and   L.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--NON_LABOR_RESOURCE

   IF p_resource_type_code = 'RESOURCE_CLASS' THEN
       --RESOURCE_CLASS
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.name,
               c.language,
               c.source_lang, --USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Pa_Resource_Classes_tl c
            WHERE a.resource_source_id = b.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and   c.resource_class_id = a.resource_source_id
            and NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = c.language);
   END IF;--RESOURCE_CLASS

   --MLS Changes.
   IF p_resource_type_code IN ('NAMED_ROLE','USER_DEFINED')
   THEN
       --NAMED_ROLE, USER_DEFINED
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.resource_name,
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Pa_rbs_element_map c,
                Fnd_Languages L
            WHERE a.resource_source_id = b.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and c.resource_id = a.resource_source_id
            and c.resource_type_id = p_resource_type_id
            and   L.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--NAMED_ROLE, USER_DEFINED

   IF p_resource_type_code IN ('REVENUE_CATEGORY')
   THEN
       --REVENUE_CATEGORY
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               lk.meaning, --c.resource_name,
               lk.language,
               lk.source_lang,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Pa_rbs_element_map c,
                fnd_lookup_values lk
            WHERE a.resource_source_id = b.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and c.resource_id = a.resource_source_id
            and c.resource_type_id = p_resource_type_id
            and lk.lookup_type = 'REVENUE CATEGORY'
            and lk.lookup_code = c.resource_name
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = lk.language);
   END IF;--REVENUE_CATEGORY

   --MLS Changes.
   IF p_resource_type_code = 'EVENT_TYPE' THEN
       --EVENT_TYPE
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.event_type,
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                pa_event_types c,
                Fnd_Languages L
            WHERE a.resource_source_id = b.resource_source_id
            and c.event_type_id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and L.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--EVENT_TYPE

   --MLS Changes.
   IF p_resource_type_code = 'EXPENDITURE_TYPE' THEN
       --EXPENDITURE_TYPE
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.expenditure_type,
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                pa_expenditure_types c,
                Fnd_Languages L
            WHERE a.resource_source_id = b.resource_source_id
            and c.expenditure_type_id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and L.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--EXPENDITURE_TYPE

   --MLS Changes.
   IF p_resource_type_code = 'EXPENDITURE_CATEGORY' THEN
       --EXPENDITURE_CATEGORY
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.expenditure_category,
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                pa_expenditure_categories c,
                Fnd_Languages L
            WHERE a.resource_source_id = b.resource_source_id
            and c.expenditure_category_id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and L.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--EXPENDITURE_CATEGORY

   --MLS Changes.
   IF p_resource_type_code = 'SUPPLIER' THEN
       --SUPPLIER
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.vendor_name,
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                po_vendors c,
                Fnd_Languages L
            WHERE a.resource_source_id = b.resource_source_id
            and c.vendor_id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and L.Installed_Flag in ('I', 'B')
            AND NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);
   END IF;--SUPPLIER

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
END Insert_non_tl_names;

/******************************************************
 * Procedure : Insert_tl_names
 * Description : This API is used to insert into the
 *               pa_rbs_element_names_tl table.
 *               For those res_type_codes for which there
 *               are corr TL tables
 *               We are going to insert the value based
 *               on the values inserted into the
 *               pa_rbs_element_names_b table.
 *               and do a join with the corr TL
 *               tables for the res_type_codes.
 * **************************************************/
PROCEDURE Insert_tl_names
           (p_resource_type_id   IN Number,
            p_resource_type_code IN Varchar2,
            x_return_status      OUT NOCOPY Varchar2)
IS
BEGIN

   IF p_resource_type_code = 'ORGANIZATION' THEN
       --ORGANIZATION
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.name,
               c.language,
               c.source_lang,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                hr_all_organization_units_tl c
            WHERE a.resource_source_id = b.resource_source_id
            and c.organization_id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            AND NOT EXISTS (select 'Y'
                            from  pa_rbs_element_names_tl tl
                            where tl.rbs_element_name_id = a.rbs_element_name_id
                            and   tl.language       = c.language);
     END IF;--ORGANIZATION

    IF p_resource_type_code = 'ROLE' THEN
       --ROLE
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               c.meaning,
               c.language,
               c.source_lang,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Pa_Project_Role_Types_tl c
            WHERE a.resource_source_id = b.resource_source_id
            and   c.project_role_id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            AND NOT EXISTS (select 'Y'
                            from  pa_rbs_element_names_tl tl
                            where tl.rbs_element_name_id = a.rbs_element_name_id
                            and   tl.language            = c.language);
     END IF;--ROLE

    IF p_resource_type_code = 'ITEM_CATEGORY' THEN
       --ITEM_CATEGORY
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               fnd_Flex_ext.GET_SEGS('INV', 'MCAT',
                                     c.structure_id, c.category_id),
               l.language_code,
               USERENV('LANG'),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Fnd_Languages L,
                Mtl_Categories_v c
            WHERE a.resource_source_id = b.resource_source_id
            and   c.category_id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            and   L.Installed_Flag in ('I', 'B')
            AND   NOT EXISTS (select 'Y'
                        FROM pa_rbs_element_names_tl tl
                        where tl.rbs_element_name_id = a.rbs_element_name_id
                        and   tl.language = l.language_code);

     END IF;--ITEM_CATEGORY

     IF p_resource_type_code = 'INVENTORY_ITEM' THEN
       --INVENTORY_ITEM
       INSERT INTO Pa_rbs_element_names_tl
             (RBS_ELEMENT_NAME_ID,
              RESOURCE_NAME,
              Language,
              Source_Lang,
              Last_Update_Date,
              Last_Updated_By,
              Creation_Date,
              Created_by,
              Last_Update_Login)
          SELECT
               a.rbs_element_name_id,
               --For bug 3602566.
               --c.description,
               d.segment1,
               c.language,
               c.source_lang,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.LOGIN_ID
            FROM
                pa_rbs_element_names_b a,
                pa_rbs_elem_in_temp b,
                Mtl_System_Items_tl c,
                Mtl_System_Items_b d --For bug 3602566
            WHERE a.resource_source_id = b.resource_source_id
            and c.Inventory_Item_Id = a.resource_source_id
            AND   a.resource_type_id   = p_resource_type_id
            AND   b.resource_type_id   = p_resource_type_id
            AND   c.inventory_item_id  = d.inventory_item_id  --For bug 3602566
            AND   c.organization_id    = d.organization_id  --For bug 3602566
            AND   c.organization_id =
                    (select item_master_id
                     from pa_resource_classes_b cls,
                          pa_plan_res_defaults def
                     where def.resource_class_id = cls.resource_class_id                             and cls.resource_class_code = 'MATERIAL_ITEMS'
                     and def.object_type = 'CLASS')
            AND NOT EXISTS (select 'Y'
                            from  pa_rbs_element_names_tl tl
                            where tl.rbs_element_name_id = a.rbs_element_name_id
                            and   tl.language            = c.language);
     END IF;--INVENTORY_ITEM

END Insert_tl_names;


/*********************************************************
 * Procedure : Populate_RBS_Element_Name
 * Description : This API does the following:-
 *               - It can be called in 2 ways
 *               1. passing 1 resource_source_id and resource_type_id
 *               2. Populating the pa_rbs_elem_in_temp with a bunch
 *               of resource_source_id and resource_type_id and
 *               call this api.
 *               -> In the first case we will take in a
 *               resource_source_id and resource_type_id
 *               and derive the element_name associated.
 *               And then insert into the pa_rbs_element_names_b
 *               and pa_rbs_element_names_tl tables.
 *               Pass back the element_name_id.
 *               -> In the 2nd case
 *               Reads the records from the temp table.
 *               For each of them derives the element_name
 *               Inserts into the pa_rbs_element_names_b
 *               table.
 *               Inserts into the pa_rbs_element_names_tl
 *               table.
 *               Delete the recs in the temp table.
 ********************************************************/
PROCEDURE Populate_RBS_Element_Name
           (p_resource_source_id  IN Number Default Null,
           p_resource_type_id    IN Number Default Null,
           x_rbs_element_name_id OUT NOCOPY Number,
           x_return_status       OUT NOCOPY Varchar2)
IS
  /*********************************************
  * This cursor is used to get the res_type_id
  * and the corr res_type_codes for it from the
  * temp table. so that we can insert into the
  * table for each res_type_code.
  ********************************************/
  Cursor c_get_res_types
  IS
  SELECT distinct a.resource_type_id,
         decode(a.resource_type_id,-1,'VERSION',-2,'RULE',b.res_type_code)
  FROM pa_rbs_elem_in_temp a,pa_res_types_b b
  WHERE a.resource_type_id = b.res_type_id(+)
  ORDER by resource_type_id;

 --Declaration of the local variables
  l_return_status       Varchar2(30);
  l_element_name        Varchar2(30);
  l_call_flag           Varchar2(1);
  l_resource_source_id  Varchar2(30);
  l_resource_type_id    Number;
  l_res_type_code       Varchar2(30);
  l_res_type            Varchar2(30);
  l_count               Number;
  l_chk_flag            Varchar2(1) := 'Y';

  l_existing_count  Number;
  l_element_name_id Number;
  l_temp_count      Number;
  l_last_analyzed   all_tables.last_analyzed%TYPE;
  l_pa_schema       VARCHAR2(30);
BEGIN
    --Initialize the x_return_status.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --For bug 4026456, 4887312

    /*
    FND_STATS.SET_TABLE_STATS('PA',
                          'PA_RBS_ELEM_IN_TEMP',
                          100,
                          10,
                          100);
    */
     --End of bug 4026456, 4887312

    -- Proper Fix for 4887312 *** RAMURTHY  03/01/06 02:33 pm ***
    -- It solves the issue above wrt commit by the FND_STATS.SET_TABLE_STATS call

    PA_TASK_ASSIGNMENT_UTILS.set_table_stats('PA','PA_RBS_ELEM_IN_TEMP',100,10,100);

    -- End fix 4887312
   /*******************************************************
   * Test to determine how this API is being called.
   * If a value is passed for the p_resource_source_id
   * and p_resource_type_id then set the call_flag = 'A'
   * else set the call_flag = 'B'.
   * In the case of Call_flag = 'A' the user needs to pass in
   * 1 value for p_resource_source_id and p_resource_type_id
   * and then call this API.
   * In the case of call_flag = 'B' the user should not pass in
   * these values and just populate the temp table.
   *******************************************************/
   IF p_resource_source_id IS NOT NULL and p_resource_type_id IS NOT NULL THEN
      l_call_flag := 'A';
   ELSE
      l_call_flag := 'B';
   END IF;
   /*******************/
   IF l_call_flag = 'A' THEN
      IF p_resource_source_id = -1 THEN
            l_resource_type_id := -2;
      ELSE
            l_resource_type_id := p_resource_type_id;
      END IF;
     /*******************************************
     * Insert into the pa_rbs_elem_in_temp table
     * explicitely.
     **********************************************/
     BEGIN
        Insert into pa_rbs_elem_in_temp
              (resource_source_id,
               resource_type_id)
        Values
              (p_resource_source_id,
               l_resource_type_id);
     EXCEPTION
     WHEN OTHERS THEN
       x_rbs_element_name_id := Null;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RETURN;
     END;
  END IF;
     /*************************************************
      * Added an extra check to check for duplicate rows
      * in the pa_rbs_elem_in_temp temporary table
      * and delete it, before proceeding.
      * Because if duplicate values are passed for
      * combination of resource_source_id and
      * resource_type_id, then we cannot anyway
      * insert multiple rows into the 2 main tables.
      **************************************************/
     BEGIN
        DELETE FROM pa_rbs_elem_in_temp a WHERE ROWID > (
         SELECT min(rowid) FROM pa_rbs_elem_in_temp b
         WHERE a.resource_source_id = b.resource_source_id
         AND   a.resource_type_id   = b.resource_type_id);

        /* Also check to see that rows don't already exist
         * in element names for these resources - therefore,
         * delete rows from the temp table which already
         * have rows in pa_rbs_element_names_b */

         DELETE FROM pa_rbs_elem_in_temp a
         WHERE EXISTS (SELECT 'Y'
                         FROM pa_rbs_element_names_b b
                        WHERE a.resource_source_id = b.resource_source_id
                          AND a.resource_type_id   = b.resource_type_id);
     END;

    select count(*) into l_temp_count from pa_rbs_elem_in_temp;
    IF l_temp_count = 0  AND l_call_flag = 'A' THEN
       SELECT rbs_element_name_id
         INTO x_rbs_element_name_id
         FROM pa_rbs_element_names_b
        WHERE resource_source_id = p_resource_source_id
          AND resource_type_id = l_resource_type_id
          AND rownum = 1;

       RETURN;
    END IF;
    /*****************************
    * Open the c_get_res_types cursor
    * which would get the res_type_id's
    * and corr res_type_code.
    *******************************/
    OPEN c_get_res_types;
    LOOP
      FETCH c_get_res_types INTO l_res_type,l_res_type_code;
      EXIT WHEN c_get_res_types%NOTFOUND;
          /*******************************************
          * Set a Savepoint so that in case something fails
          * we can roll back the insert into any prev tables.
          **************************************************/
           Savepoint insert_for_call_flag_AB;
          /***********************************************
          * Insert into the Pa_rbs_element_names_b
          * for the res_type passed. it will just do an
          * Insert as Select from the pa_rbs_elem_in_temp
          * table for the corr res_type.
          *****************************************************/
          Insert_elements
             (p_resource_type_id     => l_res_type,
              x_return_status        => l_return_status);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               Rollback to Savepoint insert_for_call_flag_AB;
               x_rbs_element_name_id := NULL;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
           END IF;--Return Status

          IF l_res_type_code NOT IN
         ('ORGANIZATION','ITEM_CATEGORY','INVENTORY_ITEM','ROLE')
          THEN
               Insert_non_tl_names
               (p_resource_type_id   => l_res_type,
                p_resource_type_code => l_res_type_code,
                x_return_status      => l_return_status);
               /**************************************************
               * Rollback changes and pass UNEXP error
               * and rbs_element_name_id  as NULL and return.
               *************************************************/
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   Rollback to Savepoint insert_for_call_flag_AB;
                   x_rbs_element_name_id := NULL;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   RETURN;
               END IF;--Return Status
         END IF;--Res_type_code

         IF l_res_type_code IN
         ('ORGANIZATION','ITEM_CATEGORY','INVENTORY_ITEM','ROLE')
          THEN
               Insert_tl_names
               (p_resource_type_id   => l_res_type,
                p_resource_type_code => l_res_type_code,
                x_return_status      => l_return_status);
               /**************************************************
               * Rollback changes and pass UNEXP error
               * and rbs_element_name_id  as NULL and return.
               *************************************************/
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   Rollback to Savepoint insert_for_call_flag_AB;
                   x_rbs_element_name_id := NULL;
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   RETURN;
               END IF;--Return Status
         END IF;--Res_type_code

     END LOOP;
  CLOSE c_get_res_types;

DELETE FROM pa_rbs_elem_in_temp;


IF l_call_flag = 'A' THEN
    BEGIN
       SELECT rbs_element_name_id
       INTO x_rbs_element_name_id
       FROM pa_rbs_element_names_b
       WHERE resource_source_id = p_resource_source_id
       AND   resource_type_id   = l_resource_type_id;
    EXCEPTION
    WHEN OTHERS THEN
          x_rbs_element_name_id := NULL;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
    END;
END IF;

END Populate_RBS_Element_Name;

 /* ----------------------------------------------------------------
    Wrapper API for handling RBS version changes. This API is called
    by the RBS summarization program. This API includes calls to all
    API's that handle RBS version changes in other PA modules. This
	API is called in the beginning of PJI concurrent program that
	handles RBS version changes
    ----------------------------------------------------------------*/
PROCEDURE PROCESS_RBS_CHANGES (
  p_rbs_header_id      IN NUMBER,
  p_new_rbs_version_id IN NUMBER,
  p_old_rbs_version_id IN NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  l_worker_id NUMBER;

BEGIN

  --Initialize return status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Call to RBS handler API
  PA_RBS_VERSIONS_PVT.SET_REPORTING_FLAG (
    p_rbs_version_id => p_new_rbs_version_id,
    x_return_status  => x_return_status );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    pa_debug.log_message ('Error in API PA_RBS_VERSIONS_PVT.SET_REPORTING_FLAG' || SQLERRM);
    --RETURN;
  END IF;

  --Call to Allocations handler API
  PA_ALLOC_UTILS.ASSOCIATE_RBS_TO_ALLOC_RULE(
    p_rbs_header_id  => p_rbs_header_id,
    p_rbs_version_id => p_new_rbs_version_id,
    x_return_status  => x_return_status,
    x_error_code     => x_msg_data );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    pa_debug.log_message ('Error in API PA_ALLOC_UTILS.ASSOCIATE_RBS_TO_ALLOC_RULE' || SQLERRM);
    --RETURN;
  END IF;

  --Call to Budgeting and Forecasting handler API

  PA_RLMI_RBS_MAP_PUB.PUSH_RBS_VERSION (
    p_old_rbs_version_id => p_old_rbs_version_id,
    p_new_rbs_version_id => p_new_rbs_version_id,
    x_return_status      => x_return_status,
    x_msg_count          => x_msg_count,
    x_msg_data           => x_msg_data );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    pa_debug.log_message ('Error in API PA_RLMI_RBS_MAP_PUB.PUSH_RBS_VERSION' || SQLERRM);
    --RETURN;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data      := SQLERRM;
END;


--      History:
--
--      07-APR-2004     sushma                created
/*==============================================================================
This api is used to Refresh Resource names
=============================================================================*/

-- Procedure            : Refresh_Resource_Names
-- Type                 : Public Procedure
-- Purpose              : This API will be used to refresh Resource names associated with RBS.
--                      : This API will be called from :
--                      : 1.Concurrent program: Refresh RBS Element Names

-- Note                 : This API will refresh Resource names(associated with all RBS) for each resource type present
--                        in pa_rbs_element_names_b table by
--                        making join with respective tables.

-- Assumptions          :

-- Parameters           : None
--

PROCEDURE Refresh_Resource_Names(errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY VARCHAR2)
IS

        --This cursor selects all the resource types from pa_res_types_b table
        CURSOR Res_Types_c IS
        SELECT Res_type_id
        FROM pa_res_types_b;

        l_res_type_id   NUMBER;
	PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

	--Initialize variables
    	retcode := 0;
    	errbuf := NULL;

	PA_DEBUG.SET_PROCESS(x_process    => 'PLSQL',
                             x_debug_mode => PG_DEBUG);

    	PA_DEBUG.WRITE_FILE('LOG', TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': PA_DEBUG_MODE: '||PG_DEBUG);

	--Print report heading
    	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,TO_CHAR(sysdate,'DD-MON-YYYY')||
                                '                                   '||
                                'PARRCSUB - Refresh RBS Element Names');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));


    	IF PG_DEBUG = 'Y' THEN
       		PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||
                 'deleting all rows from Tl table');
    	END IF;


        --Delete all rows from pa_rbs_element_names_tl table

        DELETE FROM pa_rbs_element_names_tl;


	--Refreshing Rule based Rbs
        IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||
                  'Refreshing Rule Based Rbs');
        END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
			to remove the GSCC Warning File.Sql.33 */
	INSERT INTO pa_rbs_element_names_tl(
		RBS_ELEMENT_NAME_ID,
		RESOURCE_NAME,
		LANGUAGE,
		SOURCE_LANG,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN
		)
                (
                SELECT
                        a.rbs_element_name_id,
                        lk.meaning,
                        lk.language,
                        lk.source_lang,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        fnd_global.login_id
                 FROM   --pa_lookups lk,
                        fnd_lookup_values lk,
                        pa_rbs_element_names_b a
                 WHERE
		 	a.resource_type_id = -2
                 and    a.resource_source_id = -1
		 AND	lk.lookup_code = 'USER_DEFINED_RESOURCE'
		 AND	lk.lookup_type = 'RBS_RULE_RESOURCE');

	--Refreshing the Version names
	IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||
                 'Refreshing Version Names ');
        END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
	INSERT INTO pa_rbs_element_names_tl(
                RBS_ELEMENT_NAME_ID,
                RESOURCE_NAME,
                LANGUAGE,
                SOURCE_LANG,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN
                )
                (
                SELECT
                        b.rbs_element_name_id,
                        vertl.name,
                        vertl.language,
                        vertl.source_lang,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        fnd_global.login_id
                 FROM   pa_rbs_versions_tl vertl,
                        pa_rbs_element_names_b b
                 WHERE	b.resource_type_id = -1
		 AND    b.resource_source_id = vertl.rbs_version_id);


        OPEN Res_Types_c;

        --Loop through all resource types reproducing all resources
        --associated with all RBS
	--into pa_rbs_element_names_tl table.

        LOOP
                FETCH Res_Types_c INTO l_res_type_id;

		EXIT WHEN Res_Types_c%NOTFOUND;

                --FOR res_type_id=1 Res_type_code=BOM_LABOR
                IF l_res_type_id=1 THEN
                --dbms_output.put_line('For Res_Type_Id=1 BOM_LABOR');
		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                          ': '||'Refreshing BOM_LABOR ');
                END IF;
        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        --MLS Changes
                        INSERT INTO pa_rbs_element_names_tl(
                			RBS_ELEMENT_NAME_ID,
			                RESOURCE_NAME,
       			                LANGUAGE,
                			SOURCE_LANG,
                			LAST_UPDATE_DATE,
                			LAST_UPDATED_BY,
                			CREATION_DATE,
                			CREATED_BY,
                			LAST_UPDATE_LOGIN
                			)
					(
                                SELECT
                                        a.rbs_element_name_id,
                                        b.resource_code,
                                        --b.description,--For bug 3602566
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                 FROM   bom_resources b,
	                                pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE   a.resource_type_id = 1
                                AND     b.resource_id = a.resource_source_id
                                AND     l.Installed_Flag in ('I', 'B'));
                END IF;


                IF l_res_type_id=2 THEN

		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                          ': '||'Refreshing BOM_EQUIPMENT ');
                END IF;
        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        --MLS Changes
                        INSERT INTO pa_rbs_element_names_tl(
                                        RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
					(
                                SELECT
                                        a.rbs_element_name_id,
                                        b.resource_code,
                                        --b.description,--For bug 3602566
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    bom_resources b,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE   a.resource_type_id = 2
                                AND     b.resource_id = a.resource_source_id
                                and     L.Installed_Flag in ('I', 'B'));
                END IF;


                --FOR res_type_id=3 Res_type_code=NAMED_PERSON
                IF l_res_type_id=3 THEN
                 --dbms_output.put_line('For Res_Type_Id=3 NAMED_PERSON');
		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing NAMED_PERSON ');
                END IF;
        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        --MLS Changes
                         INSERT INTO pa_rbs_element_names_tl(
                                        RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                 SELECT
                                        b.rbs_element_name_id,
                                        per.full_name,
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    per_all_people_f per,
                                        pa_rbs_element_names_b b,
                                        Fnd_Languages L
                                WHERE TRUNC(sysdate) BETWEEN
                                      effective_start_date AND
                                      NVL(effective_end_date,TRUNC(sysdate))
                                 AND   b.resource_type_id=3
                                 AND   per.person_id=b.resource_source_id
                                 and   L.Installed_Flag in ('I', 'B'));
                END IF;


                 --FOR res_type_id=4  Res_type_code=EVENT_TYPE
                IF l_res_type_id=4 THEN
                 --dbms_output.put_line('For Res_Type_Id=4 EVENT_TYPE');
		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing EVENT_TYPE ');
                END IF;
        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        --MLS Changes
                        INSERT INTO pa_rbs_element_names_tl(
                                        RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        E.EVENT_TYPE,
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    PA_EVENT_TYPES E,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE   a.resource_type_id=4
                                AND     E.event_type_id=a.resource_source_id
                                AND     L.Installed_Flag in ('I', 'B'));
                END IF;

                --FOR res_type_id=5  Res_type_code=EXPENDITURE_CATEGORY

                IF l_res_type_id=5 THEN
                --dbms_output.put_line('For Res_Type_Id=5 EXPENDITURE_CATEGORY');

		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing EXPENDITURE_CATEGORY ');
                END IF;
        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        --MLS Changes
                        INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        ec.EXPENDITURE_CATEGORY,
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    pa_expenditure_categories ec,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE   a.resource_type_id = 5
                                AND     ec.EXPENDITURE_CATEGORY_ID =
                                        a.resource_source_id
                                AND     L.Installed_Flag in ('I', 'B'));
                END IF;

                --FOR res_type_id=6  Res_type_code=EXPENDITURE_TYPE
                IF l_res_type_id=6 THEN
                --dbms_output.put_line('For Res_Type_Id=6 EXPENDITURE_TYPE');
		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Refreshing EXPENDITURE_TYPE ');
                END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        --MLS Changes
                        INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        ec.expenditure_type,
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    pa_expenditure_types ec,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE   a.resource_type_id = 6
                                AND     ec.EXPENDITURE_TYPE_ID =
                                        a.resource_source_id
                                AND     L.Installed_Flag in ('I', 'B'));
                END IF;

                --FOR res_type_id=7  Res_type_code=ITEM_CATEGORY
                IF l_res_type_id=7 THEN
                 --dbms_output.put_line('For Res_Type_Id=7 =ITEM_CATEGORY');
		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing ITEM_CATEGORY ');
                END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        fnd_Flex_ext.GET_SEGS('INV', 'MCAT',
                                                 c.structure_id, c.category_id),
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    mtl_categories_v c,
                                        Fnd_Languages L,
                                        pa_rbs_element_names_b a
                                WHERE   a.resource_source_id=c.CATEGORY_ID
                                AND     a.resource_type_id=7
                                AND     L.Installed_Flag in ('I', 'B'));
                END IF;

                --FOR res_type_id=8  Res_type_code=INVENTORY_ITEM
                IF l_res_type_id=8 THEN
		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing INVENTORY_ITEM ');
                END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                         INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                 SELECT
                                        a.rbs_element_name_id,
                                        b.segment1, --For bug 3602566
                                        t.language,
                                        t.source_lang,
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    MTL_SYSTEM_ITEMS_tl t,
                                        MTL_SYSTEM_ITEMS_b b,
                                        pa_plan_res_defaults p,
                                        pa_rbs_element_names_b a
                                WHERE   b.inventory_item_id=t.inventory_item_id
                                AND     b.organization_id=t.organization_id
                                AND     t.organization_id = p.item_master_id
                                AND     p.resource_class_id = 3
                                AND     a.resource_type_id=8
                                AND     a.resource_source_id=t.inventory_item_id);
                END IF;

                --FOR res_type_id=9  Res_type_code=JOB
                IF l_res_type_id=9 THEN
		IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing JOB ');
                END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        --MLS Changes
                        INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        job.name,
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    per_jobs job,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE   a.resource_type_id=9
                                AND 	a.resource_source_id=job.job_id
                                AND     L.Installed_Flag in ('I', 'B'));

                END IF;

                 --FOR res_type_id=10  Res_type_code=ORGANIZATION
                IF l_res_type_id=10 THEN
        		IF PG_DEBUG = 'Y' THEN
                                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,
                                'HH:MI:SS')|| ': '||'Refreshing ORGANIZATION ');
                         END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                         INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                 SELECT
                                        distinct a.rbs_element_name_id,
                                        tl.name,
                                        tl.language,
                                        tl.source_lang,
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    hr_all_organization_units_tl tl,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE  tl.organization_id = a.resource_source_id
                                AND    a.resource_type_id = 10);
                END IF;

                --FOR res_type_id=11  Res_type_code=PERSON_TYPE
                IF l_res_type_id=11 THEN
		   IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing PERSON_TYPE ');
                   END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                      INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                               SELECT  a.rbs_element_name_id,
                                       lk.meaning,
                                       lk.language,
                                       lk.source_lang,
                                       sysdate,
                                       fnd_global.user_id,
                                       sysdate,
                                       fnd_global.user_id,
                                       fnd_global.login_id
				FROM   pa_rbs_element_map map,-- For bug 3799582
                                       fnd_lookup_values lk,
                                       pa_rbs_element_names_b a
				WHERE  map.resource_type_id = a.resource_type_id
				AND    a.resource_source_id=map.resource_id
				AND    a.resource_type_id=11
                                AND    lk.lookup_type = 'PA_PERSON_TYPE'
                                AND    lk.lookup_code = map.resource_name);

                END IF;

                --FOR res_type_id=12  Res_type_code=NON_LABOR_RESOURCE
                IF l_res_type_id=12 THEN
			IF PG_DEBUG = 'Y' THEN
                           PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,
                           'HH:MI:SS')||': '||'Refreshing NON_LABOR_RESOURCE ');
                	END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        --MLS Changes
                        INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        r.NON_LABOR_RESOURCE,
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    pa_non_labor_resources r,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE  a.resource_source_id =
                                       r.non_labor_resource_id
                                AND    a.resource_type_id = 12
                                AND    L.Installed_Flag in ('I', 'B'));
                END IF;

                --FOR res_type_id=13  Res_type_code=RESOURCE_CLASS
                IF l_res_type_id=13 THEN
        	    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing RESOURCE_CLASS');
                    END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                       INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                               SELECT
                                        a.rbs_element_name_id,
                                        tl.name,
                                        tl.language,
                                        tl.source_lang,
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    pa_resource_classes_tl tl,
                                        pa_rbs_element_names_b a
                                WHERE  a.resource_source_id=tl.resource_class_id
                                AND a.resource_type_id=13);
                END IF;

                --FOR res_type_id=14  Res_type_code=REVENUE_CATEGORY
                IF l_res_type_id=14 THEN
		    IF PG_DEBUG = 'Y' THEN
                       PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                       ': '||'Refreshing REVENUE_CATEGORY');
                    END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                        INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        lk.meaning,
                                        lk.language,
                                        lk.source_lang,
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    fnd_lookup_values lk,
                                        pa_rbs_element_names_b a,
					pa_rbs_element_map map
				WHERE   a.resource_source_id=map.resource_id
				AND	map.resource_name=lk.lookup_code
				AND	lk.Lookup_Type = 'REVENUE CATEGORY'
				AND	a.resource_type_id=14);
                END IF;

                --FOR res_type_id=15  Res_type_code=ROLE
                IF l_res_type_id=15 THEN
	             IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing ROLE');
                     END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                       INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        tl.meaning,
                                        tl.language,
                                        tl.source_lang,
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM   pa_project_role_types_tl tl,
                                       pa_rbs_element_names_b a
                                WHERE  a.resource_type_id = 15
                                AND  a.resource_source_id = tl.project_role_id);
                END IF;

                --FOR res_type_id=16  Res_type_code=SUPPLIER
                IF l_res_type_id=16 THEN
		    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing SUPPLIER');
                    END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                       --MLS Changes
                       INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        v.vendor_name,
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    po_vendors v,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE   a.resource_type_id = 16
                                AND     a.resource_source_id = v.vendor_id
                                AND     L.Installed_Flag in ('I', 'B'));
                END IF;


                --FOR res_type_id=18  Res_type_code=USER DEFINED
                IF l_res_type_id=18 THEN
                    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||
                        ': '||'Refreshing USER DEFINED');
                    END IF;

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
                       --MLS
                       INSERT INTO pa_rbs_element_names_tl(
                                       RBS_ELEMENT_NAME_ID,
                                        RESOURCE_NAME,
                                        LANGUAGE,
                                        SOURCE_LANG,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_LOGIN
                                        )
                                        (
                                SELECT
                                        a.rbs_element_name_id,
                                        map.resource_name,
                                        l.language_code,
                                        USERENV('LANG'),
                                        sysdate,
                                        fnd_global.user_id,
                                        sysdate,
                                        fnd_global.user_id,
                                        fnd_global.login_id
                                FROM    pa_rbs_element_map map,
                                        pa_rbs_element_names_b a,
                                        Fnd_Languages L
                                WHERE   a.resource_type_id = 18
                                AND     a.resource_source_id = map.resource_id
                                AND     L.Installed_Flag in ('I', 'B'));
                END IF;


        END LOOP;

        CLOSE Res_Types_c;

        --dbms_output.put_line('Leaving Refresh_Resource_Names procedure');

	IF PG_DEBUG = 'Y' THEN
        	PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||'Leaving Refresh_Resource_Names procedure');
    	END IF;
    	Commit;

    	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Refresh_Resource_Names completed successfully.');
    	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));

EXCEPTION

	WHEN OTHERS THEN
        	Rollback;
        	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Unexpected error: '||SQLCODE||' '||SQLERRM);
        	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));

        	FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error: '||SQLCODE||' '||SQLERRM);
        	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));

        	retcode := SQLCODE;
        	errbuf := SQLERRM;
        	RAISE;

END Refresh_Resource_Names;

/*****************************************************
 * Function    : Get_Concatenated_Name
 * Description : This Function is used to return the
 *               Concatenated Name given a rbs_element_id.
 ****************************************************/
Function Get_Concatenated_name
   (p_rbs_element_id IN Number)
RETURN Varchar2
IS
   /******************************************************
   * The Below cursor selects the resource_names for
   * the rbs_element_id passed in, using a connect by clause.
   * It starts with the deepest node first, and then traverses up.
   *********************************************************/
   Cursor c_element_name
   IS
   SELECT tl.resource_name
   FROM pa_rbs_elements ele, pa_rbs_element_names_vl tl
   WHERE ele.RBS_ELEMENT_NAME_ID = tl.RBS_ELEMENT_NAME_ID
   CONNECT BY PRIOR ele.parent_element_id = ele.rbs_element_id
   START WITH ele.rbs_element_id = p_rbs_element_id
   ORDER BY rbs_level DESC;

   l_element_name Varchar2(240);
   l_concat_name  Varchar2(10000);
   l_count        Number;
BEGIN
   /************************************************
   * If the p_rbs_element_id is not passed in or null
   * passed in just return Null.
   ***************************************************/
   IF p_rbs_element_id IS NULL THEN
       Return Null;
   END IF;
   OPEN c_element_name;
   LOOP
       FETCH c_element_name INTO l_element_name;
       EXIT WHEN c_element_name%NOTFOUND;
       l_count := c_element_name%ROWCOUNT;
       /*********************************************
       * If Count is 1 just assing the l_element_name to the
       * l_concat_name.
       ***************************************************/
       IF l_count = 1 THEN
            l_concat_name := l_element_name;
       ELSE
       /*********************************************
       * If Count > 1 just assing the l_element_name to the
       * l_concat_name.
       ***************************************************/
            l_concat_name := l_concat_name ||'.'||l_element_name;
       END IF;
    END LOOP;
   CLOSE c_element_name;
   --Pass back the Concatenated Name.
    Return l_concat_name;
EXCEPTION
WHEN OTHERS THEN
   --If any exception encountered pass back Null.
   Return Null;
END Get_Concatenated_name;

/* ----------------------------------------------------------------
 * API for upgrading a resource list to an RBS. This API is called
 * by the resource list upgrade concurrent program.
 * ----------------------------------------------------------------*/
PROCEDURE UPGRADE_LIST_TO_RBS (
  p_resource_list_id   IN NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

  -- l_return_status   varchar2(1);
  l_start_date      date;
  l_end_date        date;

  CURSOR get_list_info (p_resource_list_id NUMBER) IS
  SELECT resource_list_id,
         start_date_active,
         end_date_active,
         business_group_id,
         job_group_id,
         nvl(uncategorized_flag, 'N') uncategorized_flag,
         decode(group_resource_type_id,103, 'ORGANIZATION',
          decode(group_resource_type_id, 108, 'EXPENDITURE_CATEGORY',
           decode(group_resource_type_id, 109, 'REVENUE_CATEGORY',
         'NONE'))) group_res_type
    FROM pa_resource_lists_all_bg
   WHERE resource_list_id = p_resource_list_id;
     -- AND nvl(uncategorized_flag, 'N') <> 'Y';

  CURSOR get_lists_names (p_resource_list_id NUMBER) IS
  SELECT name,
         description,
         language,
         source_lang
    FROM pa_resource_lists_tl
   WHERE resource_list_id = p_resource_list_id;

  CURSOR get_parents (p_resource_list_id NUMBER) IS
  SELECT resource_list_member_id,
         organization_id,
         expenditure_category,
         revenue_category
    FROM pa_resource_list_members
   WHERE resource_list_id = p_resource_list_id
     AND migration_code = 'M'
     AND resource_type_id not in (110, 107)
     AND parent_member_id is null;

  CURSOR get_non_parents (p_resource_list_id NUMBER) IS
  SELECT child.resource_list_member_id,
         child.parent_member_id,
         child.resource_type_id,
         child.organization_id,
         child.person_id,
         child.job_id,
         child.vendor_id,
         child.project_role_id,
         child.event_type,
         child.expenditure_type,
         child.expenditure_category,
         child.revenue_category
    FROM pa_resource_list_members child
   WHERE child.resource_list_id = p_resource_list_id
     AND ((child.parent_member_id IS NOT NULL AND
          EXISTS (SELECT 'Y' FROM pa_resource_lists_all_bg
                  WHERE resource_list_id = p_resource_list_id
                  AND group_resource_type_id in (108, 109, 103)))
         OR (child.parent_member_id IS NULL AND
          EXISTS (SELECT 'Y' FROM pa_resource_lists_all_bg
                  WHERE resource_list_id = p_resource_list_id
                  AND group_resource_type_id not in (108, 109, 103))))
     AND migration_code = 'M'
     AND resource_type_id not in (110, 107)
     ORDER BY child.parent_member_id; -- Added for bug 3745326 so that outline numbers for child elements can be properly derived.

  CURSOR get_res_type_id(p_resource_type_id NUMBER) IS
  SELECT res_type_id, res_type_code
    FROM pa_res_types_b
   WHERE res_type_code = decode(p_resource_type_id, 101, 'NAMED_PERSON',
                          decode(p_resource_type_id, 102, 'JOB',
                           decode(p_resource_type_id, 103, 'ORGANIZATION',
                            decode(p_resource_type_id, 104, 'SUPPLIER',
                             decode(p_resource_type_id, 111, 'ROLE',
                             decode(p_resource_type_id, 105, 'EXPENDITURE_TYPE',
                             decode(p_resource_type_id, 106, 'EVENT_TYPE',
                         decode(p_resource_type_id, 108, 'EXPENDITURE_CATEGORY',
                          decode(p_resource_type_id, 109, 'REVENUE_CATEGORY',
                         NULL)))))))));

  CURSOR get_rev_cat(p_resource_list_id NUMBER) IS
  SELECT rlm.revenue_category,
         typ.res_type_id     -- resource_type_id
    FROM pa_resource_list_members rlm,
         (select res_type_id from pa_res_types_b
           where res_type_code = 'REVENUE_CATEGORY') typ
   WHERE rlm.resource_list_id = p_resource_list_id
     AND rlm.resource_type_id = 109;

CURSOR get_projects(p_resource_list_id NUMBER) IS
SELECT asg.project_id
  FROM pa_resource_list_assignments asg,
       pa_resource_list_uses pru
 WHERE asg.resource_list_id = p_resource_list_id
   AND asg.resource_list_assignment_id = pru.resource_list_assignment_id
   AND pru.use_code = 'ACTUALS_ACCUM';

        l_res_type_id         NUMBER;
        l_project_id          NUMBER;
        l_list                get_list_info%ROWTYPE;
        l_revenue_category_id NUMBER;
        l_expenditure_type_id NUMBER;
        l_event_type_id       NUMBER;
        l_expenditure_category_id NUMBER;
        l_rbs_header_id      NUMBER;
        l_rbs_version_id     NUMBER;
        l_rbs_element_id     NUMBER;
        l_resource_source_id NUMBER;
        l_resource_id        NUMBER;
        l_element_name_id    NUMBER;
        l_parent_element_id  NUMBER;
        l_old_parent_member_id  NUMBER;
        l_rbs_identifier_id  NUMBER;
        l_rbs_level          NUMBER;
        l_top_node_id        NUMBER;
        --l_status             VARCHAR2(30);
        l_new_element_name_id  NUMBER;
        l_Rbs_Version_From_Id     NUMBER;
        l_rbs_dummy_id       NUMBER;
        l_name_count         NUMBER;
        l_res_type_code      VARCHAR2(30);

        l_num                    Number;
        l_count                  Number;
        l_done                   Varchar2(1);
        l_rbs_header_name        VARCHAR2(240);

        -- l_return_status      VARCHAR2(30);
        -- l_msg_count          NUMBER;
        -- l_msg_code           VARCHAR2(2000);
        l_outline_number     VARCHAR2(240) := '0';
        l_parent_outline_number VARCHAR2(240) := '0';
        l_child_outline_number VARCHAR2(240) := '1';
        l_last_analyzed         all_tables.last_analyzed%TYPE;
        l_pa_schema             VARCHAR2(30);
BEGIN

--dbms_output.put_line('START UPGRADE');
-- Upgrade Resource List

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data := NULL;
  x_msg_count := 0;

  --For bug 4045542, 4887312
  /*
       FND_STATS.SET_TABLE_STATS('PA',
                       'PA_RBS_ELEMENTS_TEMP',
                        100,
                        10,
                        100);
  */
    --End of bug 4045542, 4887312
    -- Proper Fix for 4887312 *** RAMURTHY  03/01/06 02:33 pm ***
    -- It solves the issue above wrt commit by the FND_STATS.SET_TABLE_STATS call

    PA_TASK_ASSIGNMENT_UTILS.set_table_stats('PA','PA_RBS_ELEMENTS_TEMP',100,10,100);

    -- End fix 4887312


OPEN get_list_info(p_resource_list_id);
FETCH get_list_info into l_list;
IF get_list_info%NOTFOUND THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   CLOSE get_list_info;
   RETURN;
END IF;
CLOSE get_list_info;

--dbms_output.put_line('l_list.uncategorized_flag IS : ' || l_list.uncategorized_flag);
IF l_list.uncategorized_flag = 'Y' THEN
   -- This is the none list - don't need to do anything.
   RETURN;
END IF;

        --dbms_output.put_line('Upgrading list : ' || l_list.resource_list_id);
          -- set a savepoint for the list so that the entire list
          -- can be rolled back if it errors.
          savepoint l_resource_list_savepoint;

          SELECT PA_RBS_HEADERS_S.nextval
            INTO l_rbs_header_id from dual;

          INSERT INTO PA_RBS_HEADERS_B
          (RBS_HEADER_ID,
           EFFECTIVE_FROM_DATE,
           EFFECTIVE_TO_DATE,
           BUSINESS_GROUP_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           RECORD_VERSION_NUMBER,
           USE_FOR_ALLOC_FLAG)
          VALUES
          (l_rbs_header_id,
           l_list.start_date_active,
           l_list.end_date_active,
           l_list.business_group_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           1,
           'Y');

          --dbms_output.put_line('Created RBS Header : ' || l_rbs_header_id);

           -- Insert into the RBS Headers TL table from pa_resource_lists_tl.
           FOR l_names in get_lists_names(l_list.resource_list_id) LOOP -- RBS H TL Loop

              --dbms_output.put_line('Creating RBS Header Names TL');
              --dbms_output.put_line('RBS Header Name is: ' || l_names.name);

              -- Check name uniqueness - bug 3725985
              Select Count(*)
              Into l_Count
              From Pa_Rbs_Headers_tl
              Where Name = l_names.name
              And language = userenv('LANG');

              IF l_Count <> 0 THEN
                 l_num := 1;
                 l_done := 'N';
                 LOOP
                   EXIT when l_done = 'Y';
                   l_rbs_header_name := substr(l_names.name, 1, 235) || l_num;
                   Select Count(*)
                   Into l_Count
                   From Pa_Rbs_Headers_tl
                   Where Name = l_rbs_header_name
                   And language = userenv('LANG');

                   IF l_Count = 0 THEN
                      l_done := 'Y';
                   END IF;
                   l_num := l_num + 1;
                 END LOOP;
              ELSE
                 l_rbs_header_name := l_names.name;
              END IF;

              INSERT INTO PA_RBS_HEADERS_TL(
                RBS_HEADER_ID,
                NAME,
                DESCRIPTION,
                LANGUAGE,
		SOURCE_LANG,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN)
              VALUES(
                l_rbs_header_id,
                l_rbs_header_name,
                l_names.description,
                l_names.language,
                l_names.source_lang,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id);
           END LOOP;  -- End RBS H TL names Loop
           -- Done with RBS Headers
           --dbms_output.put_line('Done RBS Header');

           -- Insert into RBS Versions - frozen and working
           --dbms_output.put_line('Creating RBS Versions');
           -- FOR i in 1 .. 2 LOOP -- RBS Versions Loop (Frozen and Working)
           -- Create Frozen version, then copy to working

              l_outline_number := '0';

              SELECT PA_RBS_VERSIONS_S.nextval
                INTO l_rbs_version_id from dual;
              l_Rbs_Version_From_Id := l_rbs_version_id;

              INSERT INTO PA_RBS_VERSIONS_B (
                RBS_VERSION_ID,
                VERSION_NUMBER,
                RBS_HEADER_ID,
                VERSION_START_DATE,
                VERSION_END_DATE,
                JOB_GROUP_ID,
                RULE_BASED_FLAG,
                VALIDATED_FLAG,
                STATUS_CODE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                RECORD_VERSION_NUMBER,
                current_reporting_flag )
             VALUES (
                l_rbs_version_id,
                1,
                l_rbs_header_id,
                l_list.start_date_active,
                NULL,
                l_list.job_group_id,
                'N',
                'Y',
                'FROZEN',
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                1,
                'Y');

           --dbms_output.put_line('Created RBS Version : ' || l_rbs_version_id);

             FOR l_names in get_lists_names(l_list.resource_list_id) LOOP -- RBS V TL Loop
              --dbms_output.put_line('Creating RBS Version Names TL');
              --dbms_output.put_line('RBS Version Name is: ' || l_names.name);
                INSERT INTO PA_RBS_VERSIONS_TL(
                  RBS_VERSION_ID,
                  NAME,
                  DESCRIPTION,
                  LANGUAGE,
                  SOURCE_LANG,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN)
                VALUES(
                  l_rbs_version_id,
                  l_rbs_header_name,
                  l_names.description,
                  l_names.language,
                  l_names.source_lang,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  fnd_global.login_id);
             END LOOP;  -- End RBS V TL names Loop Version

             -- Stamp frozen version ID on pa_resource_lists_all_bg

             -- IF l_status = 'FROZEN' THEN
                UPDATE pa_resource_lists_all_bg
                   SET migrated_rbs_version_id = l_rbs_version_id
                 WHERE resource_list_id = l_list.resource_list_id;
             -- END IF;

             -- Create Elements for the Version top nodes
             -- First populate element names for the top node.

             INSERT INTO PA_RBS_ELEM_IN_TEMP
                (resource_source_id, resource_type_id)
             VALUES (l_rbs_version_id, -1);

             -- Upgrade all the resource list members for this list -
             -- For each version
             -- First, Populate rbs element names for all elements.
             -- populate temp table and call API.

             --dbms_output.put_line('Populate RBS Element Names');
             INSERT INTO PA_RBS_ELEM_IN_TEMP
                (resource_source_id,
                 resource_type_id)
             SELECT decode(typ.res_type_code, 'ORGANIZATION', rlm.organization_id,
                    decode(typ.res_type_code, 'NAMED_PERSON', rlm.person_id,
                    decode(typ.res_type_code, 'JOB', rlm.job_id,
                    decode(typ.res_type_code, 'SUPPLIER', rlm.vendor_id,
                        decode(typ.res_type_code, 'ROLE', rlm.project_role_id,
                          NULL))))), -- resource_source_id,
                    typ.res_type_id     -- resource_type_id
              FROM pa_resource_list_members rlm,
                   (select res_type_id, res_type_code from pa_res_types_b) typ
             WHERE rlm.resource_list_id = l_list.resource_list_id
               AND ((rlm.resource_type_id = 103
                     AND typ.res_type_code = 'ORGANIZATION') OR -- Org
                    (rlm.resource_type_id = 101
                     AND typ.res_type_code = 'NAMED_PERSON') OR -- Emp
                    (rlm.resource_type_id = 102
                     AND typ.res_type_code = 'JOB') OR -- Job
                    (rlm.resource_type_id = 104
                     AND typ.res_type_code = 'SUPPLIER') OR -- Vendor
                    (rlm.resource_type_id = 111
                     AND typ.res_type_code = 'ROLE') -- Role
                   );

             /*INSERT INTO PA_RBS_ELEM_IN_TEMP
               (resource_source_id,
                resource_type_id)
             SELECT source.resource_source_id,
                    typ.res_type_id     -- resource_type_id
               FROM pa_resource_list_members rlm,
                    (select res_type_id, res_type_code from pa_res_types_b) typ,
                    ((select expenditure_type_id resource_source_id,
                            expenditure_type    resource_name, 1 type_number
                       from pa_expenditure_types)
                     UNION
                    (select expenditure_category_id resource_source_id,
                            expenditure_category    resource_name, 2 type_number
                       from pa_expenditure_categories)
                     UNION
                    (select event_type_id resource_source_id,
                            event_type    resource_name, 3 type_number
                       from pa_event_types)) source
              WHERE rlm.resource_list_id = l_list.resource_list_id
                AND ((rlm.resource_type_id = 105
                      AND typ.res_type_code = 'EXPENDITURE_TYPE'
                      AND source.resource_name = rlm.expenditure_type
                      AND source.type_number = 1) OR--ExpType
                     (rlm.resource_type_id = 106
                      AND typ.res_type_code = 'EVENT_TYPE'
                      AND source.resource_name = rlm.event_type
                      AND source.type_number = 3) OR -- Event Type
                     (rlm.resource_type_id = 108
                      AND typ.res_type_code = 'EXPENDITURE_CATEGORY'
                      AND source.resource_name = rlm.expenditure_category
                      AND source.type_number = 2) --ECat
                  );*/
                -- rewrite the above sql for perf bug 4887375
             INSERT INTO PA_RBS_ELEM_IN_TEMP
               (resource_source_id,
                resource_type_id)
             SELECT resource_source_id,
                    res_type_id     -- resource_type_id
             FROM
             (
                 (SELECT source.resource_source_id,
                    typ.res_type_id     -- resource_type_id
                  FROM
                    pa_resource_list_members rlm,
                    (select res_type_id, res_type_code from pa_res_types_b) typ,
                    ((select expenditure_category_id resource_source_id,
                            expenditure_category    resource_name, 2 type_number
                       from pa_expenditure_categories)
                     UNION
                     (select event_type_id resource_source_id,
                            event_type    resource_name, 3 type_number
                       from pa_event_types)) source
                  WHERE rlm.resource_list_id = l_list.resource_list_id
                      AND ((rlm.resource_type_id = 106
                      AND typ.res_type_code = 'EVENT_TYPE'
                      AND source.resource_name = rlm.event_type
                      AND source.type_number = 3) OR -- Event Type
                      (rlm.resource_type_id = 108
                      AND typ.res_type_code = 'EXPENDITURE_CATEGORY'
                      AND source.resource_name = rlm.expenditure_category
                      AND source.type_number = 2) --ECat
                      )
                  )
           UNION ALL
              (SELECT source.resource_source_id,
                            typ.res_type_id     -- resource_type_id
               FROM
                    pa_resource_list_members rlm,
                    (select res_type_id, res_type_code from pa_res_types_b) typ,
                    (select expenditure_type_id resource_source_id,
                            expenditure_type    resource_name, 1 type_number
                       from pa_expenditure_types) source
               WHERE rlm.resource_list_id = l_list.resource_list_id
                      AND (rlm.resource_type_id = 105
                      AND typ.res_type_code = 'EXPENDITURE_TYPE'
                      AND source.resource_name = rlm.expenditure_type
                      AND source.type_number = 1)--ExpType
               )
           );


                -- Generate number Key for Rev Cat and populate map table
                -- before calling populate element name.
                FOR l_rev_cat in get_rev_cat(l_list.resource_list_id) LOOP
                   pa_rbs_mapping.create_res_type_numeric_id (
                      p_resource_name      => l_rev_cat.revenue_category,
                      p_resource_type_id   => l_rev_cat.res_type_id,
                      x_resource_id        => l_resource_id,
                      x_return_status      => x_return_status,
                      --x_msg_count          => l_msg_count,
                      x_msg_data           => x_msg_data);


                INSERT INTO PA_RBS_ELEM_IN_TEMP
                       (resource_source_id,
                        resource_type_id)
                VALUES (l_resource_id,
                        l_rev_cat.res_type_id);

                END LOOP;

              --dbms_output.put_line('Call Populate_RBS_Element_Name');

-- select count(*) into l_name_count from pa_rbs_element_names_b;
--dbms_output.put_line('l_name_count before Populate_RBS_Element_Name is ' || l_name_count);

              PA_RBS_UTILS.Populate_RBS_Element_Name(
                             p_resource_source_id  => NULL,
                             p_resource_type_id    => NULL,
                             x_rbs_element_name_id => l_rbs_dummy_id,
                             x_return_status       => x_return_status);
-- select count(*) into l_name_count from pa_rbs_element_names_b;
--dbms_output.put_line('l_name_count after Populate_RBS_Element_Name is ' || l_name_count);
--dbms_output.put_line('error after Populate_RBS_Element_Name is ' || sqlerrm);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 --dbms_output.put_line('Populate_RBS_Element_Name Error');
                  rollback to l_resource_list_savepoint;
              ELSE
                 --dbms_output.put_line('Populate_RBS_Element_Name Success');
                 -- Continue by creating RBS elements.
                 -- First create top node for the version:
                 SELECT PA_RBS_ELEMENTS_S.nextval
                   INTO l_top_node_id from dual;

                 SELECT PA_RBS_ELEMENT_IDENTIFIER_S.nextval
                   INTO l_rbs_identifier_id from dual;


                 SELECT rbs_element_name_id INTO l_element_name_id
                   FROM pa_rbs_element_names_b
                  WHERE resource_source_id = l_rbs_version_id
                    AND resource_type_id = -1;

                 INSERT INTO PA_RBS_ELEMENTS (
                    RBS_Element_Id,
                    Rbs_Element_Name_Id,
                    RBS_Version_Id,
                    Outline_Number,
                    Order_Number,
                    Resource_Type_Id,
                    Resource_Source_Id,
                    Rule_Flag,
                    Parent_Element_Id,
                    Rbs_Level,
                    Element_Identifier,
                    User_Created_Flag,
                    Last_Update_Date,
                    Last_Updated_By,
                    Creation_Date,
                    Created_By,
                    Last_Update_Login,
                    Record_Version_Number )
                 VALUES (
                    l_top_node_id,
                    l_element_name_id,
                    l_rbs_version_id,
                    0,
                    0, -- P_Order_Number,
                    -1,
                    l_rbs_version_id,
                    'N',
                    NULL,
                    1,
                    l_rbs_identifier_id,
                    'N',
                    sysdate,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    1);

                 -- First create the parent elements if the list
                 -- is grouped.
                 IF l_list.group_res_type in ('ORGANIZATION',
                                              'EXPENDITURE_CATEGORY',
                                              'REVENUE_CATEGORY') THEN
                    FOR l_parents in get_parents(l_list.resource_list_id) LOOP
                       --dbms_output.put_line('Creating Parents');
                       --dbms_output.put_line('Parent ID is : ' || l_parents.resource_list_member_id);

                    l_expenditure_category_id := NULL;
                    l_revenue_category_id := NULL;

                       l_outline_number := to_char(to_number(l_outline_number)
                                           + 1);

                       SELECT PA_RBS_ELEMENTS_S.nextval
                         INTO l_rbs_element_id from dual;

                       SELECT PA_RBS_ELEMENT_IDENTIFIER_S.nextval
                         INTO l_rbs_identifier_id from dual;

                       --dbms_output.put_line('Getting Parent Exp Rev');
                       --dbms_output.put_line('group_res_type is ' || l_list.group_res_type);

                       IF l_list.group_res_type = 'EXPENDITURE_CATEGORY' THEN
                          SELECT expenditure_category_id
                            INTO l_expenditure_category_id
                            FROM pa_expenditure_categories
                           WHERE expenditure_category =
                                 l_parents.expenditure_category;
                       ELSIF l_list.group_res_type = 'REVENUE_CATEGORY' THEN
                          BEGIN
                          SELECT resource_id
                            INTO l_revenue_category_id
                            FROM pa_rbs_element_map
                           WHERE resource_name = l_parents.revenue_category
                             AND resource_type_id = (select res_type_id
                                                       from pa_res_types_b
                                     where res_type_code = 'REVENUE_CATEGORY');
                           EXCEPTION WHEN NO_DATA_FOUND THEN
                                l_revenue_category_id := -999;
                           END;
                       END IF;

                       SELECT res_type_id INTO l_res_type_id
                         FROM pa_res_types_b
                        WHERE res_type_code = l_list.group_res_type;

                     --dbms_output.put_line('l_parents.organization_id is: ' || l_parents.organization_id);
                       SELECT decode(l_list.group_res_type,
                                  'ORGANIZATION', l_parents.organization_id,
                            decode(l_list.group_res_type,'EXPENDITURE_CATEGORY',
                                  l_expenditure_category_id,
                              decode(l_list.group_res_type, 'REVENUE_CATEGORY',
                                  l_revenue_category_id, NULL)))
                         INTO l_resource_source_id
                         FROM dual;

                       --dbms_output.put_line('l_resource_source_id is: ' || l_resource_source_id);

                       BEGIN
                       SELECT rbs_element_name_id
                         INTO l_element_name_id
                         FROM pa_rbs_element_names_b
                        WHERE resource_source_id = l_resource_source_id
                          AND resource_type_id = l_res_type_id;
                       EXCEPTION WHEN NO_DATA_FOUND THEN
                              l_element_name_id := -888;
                       END;

                       --dbms_output.put_line('l_element_name_id is: ' || l_element_name_id);

                       INSERT INTO PA_RBS_ELEMENTS (
                           RBS_Element_Id,
                           Rbs_Element_Name_Id,
                           RBS_Version_Id,
                           Outline_Number,
                           Order_Number,
                           Resource_Type_Id,
                           Resource_Source_Id,
                           Organization_Id,
                           Expenditure_Category_Id,
                           Revenue_Category_Id,
                           Rule_Flag,
                           Parent_Element_Id,
                           Rbs_Level,
                           Element_Identifier,
                           User_Created_Flag,
                           Last_Update_Date,
                           Last_Updated_By,
                           Creation_Date,
                           Created_By,
                           Last_Update_Login,
                           Record_Version_Number )
                   Values (
                           l_rbs_element_id,
                           l_element_name_id,
                           l_rbs_version_id,
                           l_Outline_Number,
                           null, -- P_Order_Number,
                           l_res_type_id,
                           l_resource_source_id,
                           l_parents.organization_id,
                           l_expenditure_category_id,
                           l_revenue_category_id,
                           'N',
                           l_top_node_id,
                           2,
                           l_rbs_identifier_id,
                           'N',
                           sysdate,
                           fnd_global.user_id,
                           sysdate,
                           fnd_global.user_id,
                           fnd_global.login_id,
                           1);
                       -- Stamp rbs element ID on pa_resource_list_members for
                       -- parent

                       -- IF l_status = 'FROZEN' THEN
                          UPDATE pa_resource_list_members
                             SET migrated_rbs_element_id = l_rbs_element_id
                           WHERE resource_list_member_id =
                                 l_parents.resource_list_member_id;
                       -- END IF;

                    END LOOP; -- Parents Loop
                 END IF; -- Grouped List IF

                 -- Now create the rest of the elements
                 l_old_parent_member_id := -1;
                 l_outline_number := 0;
                 FOR l_members in get_non_parents(l_list.resource_list_id) LOOP
                     IF l_old_parent_member_id <> l_members.parent_member_id
                     THEN
                        l_child_outline_number := 1;
                        l_old_parent_member_id := l_members.parent_member_id;
                     END IF;
                    --dbms_output.put_line('Creating Non Parents');
                    --dbms_output.put_line('Member ID is : ' || l_members.resource_list_member_id);
                    --dbms_output.put_line('Parent Member ID is : ' || l_members.parent_member_id);

                    l_expenditure_category_id := NULL;
                    l_revenue_category_id := NULL;
                    l_event_type_id := NULL;
                    l_expenditure_type_id := NULL;

                    SELECT PA_RBS_ELEMENTS_S.nextval
                      INTO l_rbs_element_id from dual;

                    SELECT PA_RBS_ELEMENT_IDENTIFIER_S.nextval
                      INTO l_rbs_identifier_id from dual;

                    OPEN get_res_type_id(l_members.resource_type_id);
                    FETCH get_res_type_id into l_res_type_id, l_res_type_code;
                    CLOSE get_res_type_id;

                    --dbms_output.put_line('l_res_type_code is : ' || l_res_type_code);

                    IF l_members.parent_member_id IS NOT NULL THEN
                       -- BEGIN
                       SELECT migrated_rbs_element_id
                         INTO l_parent_element_id
                         FROM pa_resource_list_members
                        WHERE resource_list_member_id =
                              l_members.parent_member_id;
                       -- EXCEPTION WHEN NO_DATA_FOUND THEN
                          -- rollback to l_resource_list_savepoint;
                       -- END;
                    --dbms_output.put_line('l_parent_element_id is : ' || l_parent_element_id);
                       SELECT (rbs_level + 1), expenditure_category_id,
                              revenue_category_id
                         INTO l_rbs_level, l_expenditure_category_id,
                              l_revenue_category_id
                         FROM pa_rbs_elements
                        WHERE rbs_element_id = l_parent_element_id;
                    ELSE
                       l_parent_element_id := l_top_node_id;
                       l_rbs_level := 2;
                    END IF;


                    IF l_parent_element_id IS NOT NULL THEN
                       SELECT outline_number INTO l_parent_outline_number
                         FROM pa_rbs_elements
                        WHERE rbs_element_id = l_parent_element_id;
                    --dbms_output.put_line('l_parent_outline_number is : ' || l_parent_outline_number);
                    END IF;

                    --IF l_res_type_code = 'EXPENDITURE_CATEGORY' THEN
                    IF l_members.expenditure_category IS NOT NULL THEN
                       BEGIN
                       SELECT expenditure_category_id
                         INTO l_expenditure_category_id
                         FROM pa_expenditure_categories
                        WHERE expenditure_category =
                                 l_members.expenditure_category;
                       EXCEPTION WHEN NO_DATA_FOUND THEN
                          l_expenditure_category_id := -777;
                       END;
                    END IF;

                    --ELSIF l_res_type_code = 'REVENUE_CATEGORY' THEN
                    IF l_members.revenue_category IS NOT NULL THEN
                       BEGIN
                       SELECT resource_id
                         INTO l_revenue_category_id
                         FROM pa_rbs_element_map
                        WHERE resource_name = l_members.revenue_category
                          AND resource_type_id = (select res_type_id
                                                    from pa_res_types_b
                                     where res_type_code = 'REVENUE_CATEGORY');
                       EXCEPTION WHEN NO_DATA_FOUND THEN
                          l_revenue_category_id := -888;
                       END;
                    END IF;

                    --ELSIF l_res_type_code = 'EXPENDITURE_TYPE' THEN
                    IF l_members.expenditure_type IS NOT NULL THEN
                       SELECT expenditure_type_id
                         INTO l_expenditure_type_id
                         FROM pa_expenditure_types
                        WHERE expenditure_type = l_members.expenditure_type;
                    END IF;

                    --ELSIF l_res_type_code = 'EVENT_TYPE' THEN
                    IF l_members.event_type IS NOT NULL THEN
                       SELECT event_type_id
                         INTO l_event_type_id
                         FROM pa_event_types
                        WHERE event_type = l_members.event_type;
                    END IF;

                     SELECT decode(l_res_type_code,
                                   'ORGANIZATION', l_members.organization_id,
                            decode(l_res_type_code,'EXPENDITURE_CATEGORY',
                                   l_expenditure_category_id,
                            decode(l_res_type_code, 'REVENUE_CATEGORY',
                                   l_revenue_category_id,
                            decode(l_res_type_code,'EXPENDITURE_TYPE',
                                   l_expenditure_type_id,
                            decode(l_res_type_code,'EVENT_TYPE',l_event_type_id,
                            decode(l_res_type_code,'JOB', l_members.job_id,
                            decode(l_res_type_code,'NAMED_PERSON',
                                   l_members.person_id,
                            decode(l_res_type_code,'ROLE',
                                   l_members.project_role_id,
                            decode(l_res_type_code,'SUPPLIER',
                                   l_members.vendor_id, NULL)))))))))
                       INTO l_resource_source_id
                       FROM dual;

                       BEGIN
                       SELECT rbs_element_name_id INTO l_element_name_id
                         FROM pa_rbs_element_names_b
                        WHERE resource_source_id = l_resource_source_id
                          AND resource_type_id = l_res_type_id;
                       EXCEPTION WHEN NO_DATA_FOUND THEN
                              l_element_name_id := -888;
                       END;

                       IF (l_parent_element_id IS NULL) OR
                          (l_parent_element_id = l_top_node_id) THEN
                          l_outline_number := to_char(to_number(
                                                      l_outline_number) + 1);
                       ELSE
                          l_outline_number := l_parent_outline_number || '.' ||
                                              l_child_outline_number;
                          l_child_outline_number := l_child_outline_number + 1;
                       END IF;

                       INSERT INTO PA_RBS_ELEMENTS (
                           RBS_Element_Id,
                           Rbs_Element_Name_Id,
                           RBS_Version_Id,
                           Outline_Number,
                           Order_Number,
                           Resource_Type_Id,
                           Resource_Source_Id,
                           Organization_Id,
                           person_id,
                           job_id,
                           role_id,
                           supplier_id,
                           Expenditure_Category_Id,
                           Revenue_Category_Id,
                           Expenditure_type_id,
                           event_type_id,
                           Rule_Flag,
                           Parent_Element_Id,
                           Rbs_Level,
                           Element_Identifier,
                           User_Created_Flag,
                           Last_Update_Date,
                           Last_Updated_By,
                           Creation_Date,
                           Created_By,
                           Last_Update_Login,
                           Record_Version_Number)
                   Values (
                           l_rbs_element_id,
                           l_element_name_id,
                           l_rbs_version_id,
                           l_Outline_Number,
                           null, -- P_Order_Number,
                           l_res_type_id,
                           l_resource_source_id,
                           l_members.organization_id,
                           l_members.person_id,
                           l_members.job_id,
                           l_members.project_role_id,
                           l_members.vendor_id,
                           l_expenditure_category_id,
                           l_revenue_category_id,
                           l_expenditure_type_id,
                           l_event_type_id,
                           'N',
                           l_parent_element_id,
                           l_rbs_level,
                           l_rbs_identifier_id,
                           'N',
                           sysdate,
                           fnd_global.user_id,
                           sysdate,
                           fnd_global.user_id,
                           fnd_global.login_id,
                           1);

                       -- Stamp rbs element ID on pa_resource_list_members for
                       -- parent

                       -- IF l_status = 'FROZEN' THEN
                          UPDATE pa_resource_list_members
                             SET migrated_rbs_element_id = l_rbs_element_id
                           WHERE resource_list_member_id =
                                 l_members.resource_list_member_id;
                       -- END IF;

                 END LOOP; -- Non parents loop.
              END IF; -- No errors If

           -- END LOOP;  -- Versions loop (frozen and working)

           -- Create frozen version elements again but with user_created_flag
	   -- as 'Y'
	   delete from Pa_Rbs_Elements_Temp;
           Insert Into Pa_Rbs_Elements_Temp(
                   New_Element_Id,
                   Old_Element_Id,
                   Old_Parent_Element_Id,
                   New_Parent_Element_Id )
           (Select
                   Pa_Rbs_Elements_S.NextVal,
                   Rbs_Element_Id,
                   Parent_Element_Id,
                   Null
            From
                   Pa_Rbs_Elements
            Where
                   Rbs_Version_Id = l_rbs_version_id
            and    user_created_flag = 'N' );

           Update Pa_Rbs_Elements_Temp Tmp1
           Set New_Parent_Element_Id =
                (Select
                        New_Element_Id
                 From
                        Pa_Rbs_Elements_Temp Tmp2
                 Where
                        Tmp1.Old_Parent_Element_Id = Tmp2.Old_Element_Id);

           --dbms_output.put_line('Updated into Temp');

        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
           Insert Into Pa_Rbs_Elements
                (
                RBS_ELEMENT_ID,
                RBS_ELEMENT_NAME_ID,
                RBS_VERSION_ID,
                OUTLINE_NUMBER,
                ORDER_NUMBER,
                RESOURCE_TYPE_ID,
                RESOURCE_SOURCE_ID,
                PERSON_ID,
                JOB_ID,
                ORGANIZATION_ID,
                EXPENDITURE_TYPE_ID,
                EVENT_TYPE_ID,
                EXPENDITURE_CATEGORY_ID,
                REVENUE_CATEGORY_ID,
                inventory_item_id,
                item_category_id,
                bom_labor_id,
                bom_equipment_id,
                non_labor_resource_id,
                role_id,
                person_type_id,
                resource_class_id,
                supplier_id,
                rule_flag,
                PARENT_ELEMENT_ID,
                rbs_level,
                element_identifier,
                user_defined_custom1_id,
                user_defined_custom2_id,
                user_defined_custom3_id,
                user_defined_custom4_id,
                user_defined_custom5_id,
                USER_CREATED_FLAG,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                RECORD_VERSION_NUMBER)
           Select
                Tmp.New_Element_Id,
                Rbs_Elements.Rbs_Element_Name_Id,
                l_rbs_version_id,
                Rbs_Elements.Outline_Number,
                Rbs_Elements.Order_Number,
                Rbs_Elements.Resource_Type_Id,
                Rbs_Elements.Resource_Source_Id,
                Rbs_Elements.Person_Id,
                Rbs_Elements.Job_Id,
                Rbs_Elements.Organization_Id,
                Rbs_Elements.Expenditure_Type_Id,
                Rbs_Elements.Event_Type_Id,
                Rbs_Elements.Expenditure_Category_Id,
                Rbs_Elements.Revenue_Category_Id,
                Rbs_Elements.Inventory_Item_Id,
                Rbs_Elements.Item_Category_Id,
                Rbs_Elements.Bom_Labor_Id,
                Rbs_Elements.Bom_Equipment_Id,
                Rbs_Elements.Non_Labor_Resource_Id,
                Rbs_Elements.Role_Id,
                Rbs_Elements.Person_Type_Id,
                Rbs_Elements.Resource_Class_Id,
                Rbs_Elements.Supplier_Id,
                Rbs_Elements.Rule_Flag,
                Tmp.New_Parent_Element_Id,
                Rbs_Elements.Rbs_Level,
                Rbs_Elements.Element_Identifier,
                Rbs_Elements.User_Defined_Custom1_Id,
                Rbs_Elements.User_Defined_Custom2_Id,
                Rbs_Elements.User_Defined_Custom3_Id,
                Rbs_Elements.User_Defined_Custom4_Id,
                Rbs_Elements.User_Defined_Custom5_Id,
                'Y',
                Pa_Rbs_Versions_Pvt.G_Last_Update_Date,
                Pa_Rbs_Versions_Pvt.G_Last_Updated_By,
                Pa_Rbs_Versions_Pvt.G_Creation_Date,
                Pa_Rbs_Versions_Pvt.G_Created_By,
                Pa_Rbs_Versions_Pvt.G_Last_Update_Login,
                1
        From
                Pa_Rbs_Elements Rbs_Elements,
                Pa_Rbs_Elements_Temp Tmp
        Where
                Tmp.Old_Element_Id = Rbs_Elements.Rbs_Element_Id;

           -- Call API to populate mapping rules and mapping denorm tables.
           -- Only need to do it for the Frozen version.

              -- Create mapping rules
              PA_RBS_MAPPING.create_mapping_rules(
                 p_rbs_version_id   => l_rbs_version_id,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 --dbms_output.put_line('create_mapping_rules ERROR');
                 rollback to l_resource_list_savepoint;
              END IF;

              -- Populate denorm table used for reporting
              PJI_PJP_SUM_DENORM.populate_rbs_denorm_upgrade(
                 p_rbs_version_id   => l_rbs_version_id,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 --dbms_output.put_line('POPULATE_RBS_DENORM_UPGRADE ERROR');
                 rollback to l_resource_list_savepoint;
              END IF;

           -- Bug 3950096 - create association for reporting if resource list
	   -- was used for reporting.
           -- Bug 4303512 - added outer join to make sure only one
           -- RBS association is marked as primary.
           INSERT INTO pa_rbs_prj_assignments (
              RBS_PRJ_ASSIGNMENT_ID           ,
              PROJECT_ID                      ,
              RBS_VERSION_ID                  ,
              RBS_HEADER_ID                   ,
              REPORTING_USAGE_FLAG            ,
              WP_USAGE_FLAG                   ,
              FP_USAGE_FLAG                   ,
              PROG_REP_USAGE_FLAG             ,
              PRIMARY_REPORTING_RBS_FLAG      ,
              ASSIGNMENT_STATUS               ,
              LAST_UPDATE_DATE                ,
              LAST_UPDATED_BY                 ,
              CREATION_DATE                   ,
              CREATED_BY                      ,
              LAST_UPDATE_LOGIN               ,
              RECORD_VERSION_NUMBER           )
           (SELECT  pa_rbs_prj_assignments_s.nextval,
                    asg.project_id,
                    l_rbs_version_id,
                    l_rbs_header_id,
                    'Y',
                    'N',
                    'N',
                    'N',
                    decode(rpa.primary_reporting_rbs_flag, 'Y', 'N', pru.default_flag),
                    'ACTIVE',
                    sysdate,
                    fnd_global.user_id,
                    sysdate,
                    fnd_global.user_id,
                    fnd_global.login_id,
                    1
             FROM   pa_resource_list_assignments asg,
                    pa_resource_list_uses pru,
                    pa_rbs_prj_assignments rpa
             WHERE  asg.resource_list_id = l_list.resource_list_id
             AND    asg.resource_list_assignment_id =
                          pru.resource_list_assignment_id
             AND    pru.use_code = 'ACTUALS_ACCUM'
             AND    asg.project_id = rpa.project_id(+)
             AND    rpa.primary_reporting_rbs_flag(+) = 'Y'
           );

           -- Call PJI API to log an event. Bug 4249632.
           OPEN get_projects(l_list.resource_list_id);
           LOOP
              FETCH get_projects INTO l_project_id;
              EXIT WHEN get_projects%NOTFOUND;

              PJI_FM_XBS_ACCUM_MAINT.RBS_PUSH
                  (P_NEW_RBS_VERSION_ID => l_rbs_version_id,
                   P_PROJECT_ID         => l_project_id,
                   X_RETURN_STATUS      => x_return_status,
                   X_MSG_CODE           => x_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 --dbms_output.put_line('Even Log ERROR');
                 rollback to l_resource_list_savepoint;
              END IF;

           END LOOP;
           CLOSE get_projects;

           -- Create Working Version and elements.
              l_outline_number := '0';

              SELECT PA_RBS_VERSIONS_S.nextval
                INTO l_rbs_version_id from dual;

              INSERT INTO PA_RBS_VERSIONS_B (
                RBS_VERSION_ID,
                VERSION_NUMBER,
                RBS_HEADER_ID,
                VERSION_START_DATE,
                VERSION_END_DATE,
                JOB_GROUP_ID,
                RULE_BASED_FLAG,
                VALIDATED_FLAG,
                STATUS_CODE,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                RECORD_VERSION_NUMBER,
                current_reporting_flag )
             VALUES (
                l_rbs_version_id,
                2,
                l_rbs_header_id,
                NULL,
                NULL,
                l_list.job_group_id,
                'N',
                'Y',
                'WORKING',
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                fnd_global.login_id,
                1,
                'N');

           --dbms_output.put_line('Created RBS Version : ' || l_rbs_version_id);

             FOR l_names in get_lists_names(l_list.resource_list_id) LOOP -- RBS V TL Loop
              --dbms_output.put_line('Creating RBS Version Names TL');
              --dbms_output.put_line('RBS Version Name is: ' || l_names.name);
                INSERT INTO PA_RBS_VERSIONS_TL(
                  RBS_VERSION_ID,
                  NAME,
                  DESCRIPTION,
                  LANGUAGE,
                  SOURCE_LANG,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN)
                VALUES(
                  l_rbs_version_id,
                  l_rbs_header_name,
                  l_names.description,
                  l_names.language,
                  l_names.source_lang,
                  sysdate,
                  fnd_global.user_id,
                  sysdate,
                  fnd_global.user_id,
                  fnd_global.login_id);
             END LOOP;  -- End RBS V TL names Loop Version

           --dbms_output.put_line('Created RBS Working : ' || l_rbs_version_id);

        delete from Pa_Rbs_Elements_Temp;
        Insert Into Pa_Rbs_Elements_Temp(
                New_Element_Id,
                Old_Element_Id,
                Old_Parent_Element_Id,
                New_Parent_Element_Id )
        (Select
                Pa_Rbs_Elements_S.NextVal,
                Rbs_Element_Id,
                Parent_Element_Id,
                Null
         From
                Pa_Rbs_Elements
         Where
                Rbs_Version_Id = l_Rbs_Version_From_Id
         and    user_created_flag = 'Y' );

           --dbms_output.put_line('Inserted into Temp');
        Update Pa_Rbs_Elements_Temp Tmp1
        Set New_Parent_Element_Id =
                (Select
                        New_Element_Id
                 From
                        Pa_Rbs_Elements_Temp Tmp2
                 Where
                        Tmp1.Old_Parent_Element_Id = Tmp2.Old_Element_Id);

           --dbms_output.put_line('Updated into Temp');
        /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                        to remove the GSCC Warning File.Sql.33 */
        Insert Into Pa_Rbs_Elements
                (
                RBS_ELEMENT_ID,
                RBS_ELEMENT_NAME_ID,
                RBS_VERSION_ID,
                OUTLINE_NUMBER,
                ORDER_NUMBER,
                RESOURCE_TYPE_ID,
                RESOURCE_SOURCE_ID,
                PERSON_ID,
                JOB_ID,
                ORGANIZATION_ID,
                EXPENDITURE_TYPE_ID,
                EVENT_TYPE_ID,
                EXPENDITURE_CATEGORY_ID,
                REVENUE_CATEGORY_ID,
                inventory_item_id,
                item_category_id,
                bom_labor_id,
                bom_equipment_id,
                non_labor_resource_id,
                role_id,
                person_type_id,
                resource_class_id,
                supplier_id,
                rule_flag,
                PARENT_ELEMENT_ID,
                rbs_level,
                element_identifier,
                user_defined_custom1_id,
                user_defined_custom2_id,
                user_defined_custom3_id,
                user_defined_custom4_id,
                user_defined_custom5_id,
                USER_CREATED_FLAG,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                RECORD_VERSION_NUMBER)
        Select
                Tmp.New_Element_Id,
                Rbs_Elements.Rbs_Element_Name_Id,
                l_rbs_version_id,
                Rbs_Elements.Outline_Number,
                Rbs_Elements.Order_Number,
                Rbs_Elements.Resource_Type_Id,
                Rbs_Elements.Resource_Source_Id,
                Rbs_Elements.Person_Id,
                Rbs_Elements.Job_Id,
                Rbs_Elements.Organization_Id,
                Rbs_Elements.Expenditure_Type_Id,
                Rbs_Elements.Event_Type_Id,
                Rbs_Elements.Expenditure_Category_Id,
                Rbs_Elements.Revenue_Category_Id,
                Rbs_Elements.Inventory_Item_Id,
                Rbs_Elements.Item_Category_Id,
                Rbs_Elements.Bom_Labor_Id,
                Rbs_Elements.Bom_Equipment_Id,
                Rbs_Elements.Non_Labor_Resource_Id,
                Rbs_Elements.Role_Id,
                Rbs_Elements.Person_Type_Id,
                Rbs_Elements.Resource_Class_Id,
                Rbs_Elements.Supplier_Id,
                Rbs_Elements.Rule_Flag,
                Tmp.New_Parent_Element_Id,
                Rbs_Elements.Rbs_Level,
                Rbs_Elements.Element_Identifier,
                Rbs_Elements.User_Defined_Custom1_Id,
                Rbs_Elements.User_Defined_Custom2_Id,
                Rbs_Elements.User_Defined_Custom3_Id,
                Rbs_Elements.User_Defined_Custom4_Id,
                Rbs_Elements.User_Defined_Custom5_Id,
                Rbs_Elements.User_Created_Flag,
                Pa_Rbs_Versions_Pvt.G_Last_Update_Date,
                Pa_Rbs_Versions_Pvt.G_Last_Updated_By,
                Pa_Rbs_Versions_Pvt.G_Creation_Date,
                Pa_Rbs_Versions_Pvt.G_Created_By,
                Pa_Rbs_Versions_Pvt.G_Last_Update_Login,
                1
        From
                Pa_Rbs_Elements Rbs_Elements,
                Pa_Rbs_Elements_Temp Tmp
        Where
                Tmp.Old_Element_Id = Rbs_Elements.Rbs_Element_Id;

           --dbms_output.put_line('Craeted Elemenst ');
        Pa_Rbs_Utils.Populate_RBS_Element_Name (
               P_Resource_Source_Id  => l_rbs_version_id,
               P_Resource_Type_Id    => -1,
               X_Rbs_Element_Name_Id => l_new_element_name_id,
               X_Return_Status       => x_return_status);

        If x_return_status = Fnd_Api.G_Ret_Sts_Success Then

               Update Pa_Rbs_Elements
               Set Rbs_Element_Name_Id = l_New_Element_Name_Id,
                   Resource_Source_Id  = l_rbs_version_id
               Where Rbs_Version_Id = l_rbs_version_id
               And Resource_Type_Id = -1
               And Rbs_Level = 1;

        Else
           rollback to l_resource_list_savepoint;
        END IF;


EXCEPTION
  WHEN OTHERS THEN
--dbms_output.put_line('IN WHEN OTHERS ERROR');
--dbms_output.put_line('SQLERRM IS : ' || sqlerrm);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --rollback;

END UPGRADE_LIST_TO_RBS;

/*******************************************************************
 * Procedure : Delete_proj_specific_RBS
 * Desc      : This API is used to delete the project specific RBS
 *             assignment  once the project is deleted.
 *********************************************************************/
 PROCEDURE Delete_Proj_Specific_RBS(
   p_project_id         IN         NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER)
 IS
 BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count     := 0;
     DELETE FROM pa_rbs_prj_assignments
     WHERE project_id = p_project_id;
 EXCEPTION
 WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg( p_pkg_name =>
             'Pa_RBS_Utils.Delete_Proj_Specific_RBS'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
             x_msg_count := x_msg_count+1;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 END Delete_Proj_Specific_RBS;

procedure ADD_LANGUAGE
is
begin
  delete from pa_rbs_element_names_tl T
  where not exists
    (select NULL
    from pa_rbs_element_names_b B
    where B.RBS_ELEMENT_NAME_ID = T.RBS_ELEMENT_NAME_ID
    );

  update pa_rbs_element_names_tl T set (
      RESOURCE_NAME
    ) = (select
      B.RESOURCE_NAME
    from pa_rbs_element_names_tl b
    where B.RBS_ELEMENT_NAME_ID = T.RBS_ELEMENT_NAME_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RBS_ELEMENT_NAME_ID,
      T.LANGUAGE
  ) in (select
     SUBT.RBS_ELEMENT_NAME_ID,
      SUBT.LANGUAGE
    from pa_rbs_element_names_tl SUBB, pa_rbs_element_names_tl SUBT
    where SUBB.RBS_ELEMENT_NAME_ID = SUBT.RBS_ELEMENT_NAME_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RESOURCE_NAME <> SUBT.RESOURCE_NAME
  ));

  insert into pa_rbs_element_names_tl (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    RBS_ELEMENT_NAME_ID,
    RESOURCE_NAME,
    LANGUAGE,
    SOURCE_LANG
 ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.RBS_ELEMENT_NAME_ID,
    B.RESOURCE_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from pa_rbs_element_names_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from pa_rbs_element_names_tl T
    where T.RBS_ELEMENT_NAME_ID = B.RBS_ELEMENT_NAME_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END PA_RBS_UTILS;

/
