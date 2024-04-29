--------------------------------------------------------
--  DDL for Package Body ENG_VAL_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VAL_TO_ID" AS
/* $Header: ENGSVIDB.pls 120.8.12010000.4 2011/11/28 09:15:47 rambkond ship $ */
--  Global constant holding the package name

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'ENG_Val_To_Id';
g_Token_Tbl             Error_Handler.Token_Tbl_Type;

--  Prototypes for val_to_id functions.

--  START GEN val_to_id

--  Key Flex

FUNCTION Key_Flex
(   p_key_flex_code                 IN  VARCHAR2
,   p_structure_number              IN  NUMBER
,   p_appl_short_name               IN  VARCHAR2
,   p_segment_array                 IN  FND_FLEX_EXT.SegmentArray
)
RETURN NUMBER
IS
l_id                          NUMBER;
l_segment_array               FND_FLEX_EXT.SegmentArray;
BEGIN

    l_segment_array := p_segment_array;

    --  Convert any missing values to NULL

    FOR I IN 1..l_segment_array.COUNT LOOP

        IF l_segment_array(I) = FND_API.G_MISS_CHAR THEN
            l_segment_array(I) := NULL;
        END IF;

    END LOOP;

    --  Call Flex conversion routine

    IF NOT FND_FLEX_EXT.get_combination_id
    (   application_short_name        => p_appl_short_name
    ,   key_flex_code                 => p_key_flex_code
    ,   structure_number              => p_structure_number
    ,   validation_date               => NULL
    ,   n_segments                    => l_segment_array.COUNT
    ,   segments                      => l_segment_array
    ,   combination_id                => l_id
    )
    THEN

        --  Error getting combination id.
        --  Function has already pushed a message on the stack. Add to
        --  the API message list.

        FND_MSG_PUB.Add;
        l_id := FND_API.G_MISS_NUM;

    END IF;

    RETURN l_id;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Key_Flex'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Key_Flex;

--  Generator will append new prototypes before end generate comment.


--  Approval_List
/*****************************************************************************
* Function      : Approval_List
* Returns       : NULL if the function is unsuccessful else the Id of the
*                 approval list name
* Purpose       : Convert the Approval_List_name to its ID.
*****************************************************************************/

FUNCTION Approval_List
( p_approval_list IN  VARCHAR2
, x_err_text      OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
BEGIN

    SELECT  approval_list_id
    INTO    l_id
    FROM    eng_ecn_approval_lists
    WHERE   approval_list_name = p_approval_list;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
            x_err_text := G_PKG_NAME || ' : (Approval List Value-id conversion) '
                        || substrb(SQLERRM,1,200);
            RETURN  FND_API.G_MISS_NUM;

END Approval_List;





--  Approval_List
/*****************************************************************************
* Function      : Lifecycle_Id
* Returns       : NULL if the function is unsuccessful else the Id of the
*                 lifecycle name
* Purpose       : Convert the Lifecycle name to its ID.
*****************************************************************************/

FUNCTION Lifecycle_id
( p_lifecycle_name IN  VARCHAR2
, p_inventory_item_id           IN NUMBER
, p_org_id                      IN NUMBER
, x_err_text      OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
l_sql_stmt                      VARCHAR2(2000);
l_item_lifecycle_id             NUMBER;

BEGIN
        --
        -- Bug 3311072: Made changes to fetch lifecycle
        -- Added By LKASTURI
        l_sql_stmt := 'SELECT OLC.LIFECYCLE_ID                  '
                || 'FROM EGO_OBJ_TYPE_LIFECYCLES OLC,           '
                || 'FND_OBJECTS O                               '
                || 'WHERE O.OBJ_NAME =  :1                      '
                || 'AND   OLC.OBJECT_ID = O.OBJECT_ID           '
                || 'AND OLC.OBJECT_CLASSIFICATION_CODE in       '
                || '(SELECT TO_CHAR(IC.ITEM_CATALOG_GROUP_ID)   '
                || ' FROM MTL_ITEM_CATALOG_GROUPS_B IC          '
                || ' CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id   '
                || ' START WITH item_catalog_group_id =         '
                || ' (SELECT item_catalog_group_id              '
                || '  FROM mtl_system_items                     '
                || '  WHERE inventory_item_id = :2              '
                || '  AND organization_id = :3                  '
                || ' )) ';

        EXECUTE IMMEDIATE l_sql_stmt INTO l_item_lifecycle_id USING 'EGO_ITEM', p_inventory_item_id, p_org_id;

        l_sql_stmt := ' SELECT LP.PROJ_ELEMENT_ID       '
        || 'from   pa_ego_phases_v LP   '
        || 'where name = :1                             '
        || 'and parent_structure_id = :2                '
        || 'and object_type = :3                        ';

        EXECUTE IMMEDIATE l_sql_stmt
        INTO l_id
        USING p_lifecycle_name, l_item_lifecycle_id, 'PA_TASKS';

        -- End Changes

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
            x_err_text := G_PKG_NAME || ' : (Lifecycle  Value-id conversion) '
                        || substrb(SQLERRM,1,200);
            RETURN  FND_API.G_MISS_NUM;

END Lifecycle_Id;


--Bug 2848506 added the below function to get object name
--when the user does'nt supply it via OBJECT_DISPLAY_NAME column in ENG_CHANGE_LINES_INTERFACE




FUNCTION Get_Object_name
(
  p_object_id IN NUMBER
  )
  RETURN VARCHAR2
  IS
  l_obj_name VARCHAR2(240);
  BEGIN

      SELECT display_name
      into  l_obj_name
      from fnd_objects_vl
      where object_id = p_object_id;

      RETURN l_obj_name;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
        RETURN NULL;

END Get_Object_name;

PROCEDURE Preprocess_Key
( p_object_name           IN VARCHAR2
, p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
, x_pk1_name              IN OUT NOCOPY VARCHAR2
, x_pk2_name              IN OUT NOCOPY VARCHAR2
, x_pk3_name              IN OUT NOCOPY VARCHAR2
, x_pk4_name              IN OUT NOCOPY VARCHAR2
, x_pk5_name              IN OUT NOCOPY VARCHAR2
)
IS
   l_err_text   VARCHAR2(2000);
   l_org_id     NUMBER;
  BEGIN
   x_pk1_name := NULL;
   x_pk2_name := NULL;
   x_pk3_name := NULL;
   x_pk4_name := NULL;
   x_pk5_name := NULL;

   IF p_object_name = 'EGO_ITEM' THEN
      x_pk1_name := p_change_line_rec.pk1_name;
      x_pk3_name := to_char(Organization(p_change_line_rec.pk3_name, l_err_text));
   ELSIF p_object_name = 'EGO_ITEM_REVISION' THEN
      x_pk1_name := p_change_line_rec.pk1_name;
      x_pk2_name := p_change_line_rec.pk2_name;
      l_org_id := Organization(p_change_line_rec.pk4_name, l_err_text);
      x_pk4_name := to_char(l_org_id);
      x_pk3_name := Revised_Item(p_revised_item_num => p_change_line_rec.pk3_name
                                ,p_organization_id => l_org_id
                                ,x_err_text => l_err_text);
   ELSE
      x_pk1_name := p_change_line_rec.pk1_name;
      x_pk2_name := p_change_line_rec.pk2_name;
      x_pk3_name := p_change_line_rec.pk3_name;
      x_pk4_name := p_change_line_rec.pk4_name;
      x_pk5_name := p_change_line_rec.pk5_name;
   END IF;
END Preprocess_Key;


PROCEDURE Object_Name
( p_display_name         IN VARCHAR2
, x_object_name          IN OUT NOCOPY VARCHAR2
, x_query_object_name    IN OUT NOCOPY VARCHAR2
, x_query_column1_name   IN OUT NOCOPY VARCHAR2
, x_query_column2_name   IN OUT NOCOPY VARCHAR2
, x_query_column3_name   IN OUT NOCOPY VARCHAR2
, x_query_column4_name   IN OUT NOCOPY VARCHAR2
, x_query_column5_name   IN OUT NOCOPY VARCHAR2
, x_query_column1_type   IN OUT NOCOPY VARCHAR2
, x_query_column2_type   IN OUT NOCOPY VARCHAR2
, x_query_column3_type   IN OUT NOCOPY VARCHAR2
, x_query_column4_type   IN OUT NOCOPY VARCHAR2
, x_query_column5_type   IN OUT NOCOPY VARCHAR2
, x_fk1_column_name      IN OUT NOCOPY VARCHAR2
, x_fk2_column_name      IN OUT NOCOPY VARCHAR2
, x_fk3_column_name      IN OUT NOCOPY VARCHAR2
, x_fk4_column_name      IN OUT NOCOPY VARCHAR2
, x_fk5_column_name      IN OUT NOCOPY VARCHAR2
, x_object_id            IN OUT NOCOPY NUMBER  --Bug 2848506 Required for adding Items for HeaderCO's
)
IS
BEGIN


   -- assuming obj.query_object_name is the name of a view that has column names
   -- which match the column names in the table vl.object_name
   SELECT vl.obj_name, obj.query_object_name, obj.query_column1_name,
     obj.query_column2_name, obj.query_column3_name, obj.query_column4_name,
     obj.query_column5_name, obj.query_column1_type, obj.query_column2_type,
     obj.query_column3_type, obj.query_column4_type, obj.query_column5_type,
     vl.pk1_column_name, vl.pk2_column_name, vl.pk3_column_name,
     vl.pk4_column_name, vl.pk5_column_name ,vl.object_id
   INTO x_object_name, x_query_object_name, x_query_column1_name,
     x_query_column2_name, x_query_column3_name, x_query_column4_name,
     x_query_column5_name, x_query_column1_type, x_query_column2_type,
     x_query_column3_type, x_query_column4_type, x_query_column5_type,
     x_fk1_column_name, x_fk2_column_name, x_fk3_column_name, x_fk4_column_name,
     x_fk5_column_name,x_object_id
   FROM fnd_objects_vl vl, eng_change_objects obj
      WHERE vl.display_name = p_display_name AND obj.object_id = vl.object_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_object_name := NULL;
END Object_Name;


FUNCTION Get_Type_From_Header
( p_change_notice    IN  VARCHAR2
, p_org_id           IN NUMBER
)
RETURN NUMBER
IS
   l_id                          NUMBER;
BEGIN

    SELECT  change_order_type_id
    INTO    l_id
    FROM    eng_engineering_changes
    WHERE   change_notice = p_change_notice
      AND organization_id = p_org_id;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
            RETURN  FND_API.G_MISS_NUM;

END Get_Type_From_Header;



/*****************************************************************************
* Function      : Get_Change_Id
* Returns       : NULL if the function is unsuccessful, else the Id of the
*                 change, given change notice and org id
* Purpose       : Convert the change notice and org id into a change id
*****************************************************************************/

FUNCTION Get_Change_Id
( p_change_notice           IN  VARCHAR2
, p_org_id                  IN NUMBER
, x_change_mgmt_type_code   OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
   l_id                          NUMBER;
BEGIN

    SELECT  change_id, change_mgmt_type_code
    INTO    l_id, x_change_mgmt_type_code
    FROM    eng_engineering_changes
    WHERE   change_notice = p_change_notice
      AND organization_id = p_org_id;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
            RETURN  FND_API.G_MISS_NUM;

END Get_Change_Id;


--  Project
/*****************************************************************************
* Function      : Project
* Returns       : NULL if the function is unsuccessful, else the Id of the
*                 project name
* Purpose       : Convert the Project_Number to its ID.
*****************************************************************************/

FUNCTION Project
( p_project_name IN  VARCHAR2
, x_err_text      OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
BEGIN

/*
 Changed the Table name from mtl_projects_v to PA_PROJECTS_ALL
 to avoid the Non-Mergeable view Performance issues
*/
    SELECT  project_id
    INTO    l_id
    FROM    pa_projects_all
    WHERE   name = p_project_name;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
            x_err_text := G_PKG_NAME || ' : (Project Value-id conversion)'
                        || substrb(SQLERRM,1,200);
            RETURN  FND_API.G_MISS_NUM;

END Project;

-- Task
/*****************************************************************************
* Function      : Task
* Returns       : NULL if the function is unsuccessful, else the Id of the
*                 task name
* Purpose       : Convert the Task_Number to its ID.
*****************************************************************************/

FUNCTION Task
( p_task_number   IN  VARCHAR2
, p_project_Id    IN  NUMBER
, x_err_text      OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
BEGIN

    SELECT  task_id
    INTO    l_id
    FROM    pa_tasks
    WHERE   task_number = p_task_number
    AND     project_id = p_project_id;

    RETURN l_id;


EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
            x_err_text := G_PKG_NAME || ' : (Task Value-id conversion)'
                        || substrb(SQLERRM,1,200);
            RETURN  FND_API.G_MISS_NUM;

END Task;


--  Requestor
/*****************************************************************************
* Function      : Requestor
* Returns       : NULL if the function is unsuccessful else the Id of the
*                 approval list name
* Purpose       : Convert the Requestor to its ID.
*****************************************************************************/

FUNCTION Requestor
( p_requestor     IN   VARCHAR2
, p_organization_id IN NUMBER
, x_err_text      OUT NOCOPY VARCHAR2
)

RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

    l_id := Eng_Change_Common_Util.Get_User_Party_Id
            ( p_user_name => p_requestor
            , x_err_text => x_err_text);

    RETURN l_id;

END Requestor;

--* Function added for Bug 4402842
--* Employee
/*****************************************************************************
* Function      : Employee
* Returns       : NULL if the function is unsuccessful else the Id of the
*                 Employee
* Purpose       : Convert the Employee Number to its Party Id
*****************************************************************************/
FUNCTION Employee (
    p_employee_number     IN  VARCHAR2
  , x_err_text            OUT NOCOPY VARCHAR2
)
RETURN NUMBER IS

  l_party_id                NUMBER;

  CURSOR c_employee IS
  SELECT hz.party_id
  FROM PER_PEOPLE_F P, HZ_PARTIES HZ , PER_ASSIGNMENTS_X A, PER_PERSON_TYPES T
  WHERE A.PERSON_ID = P.PERSON_ID
  AND HZ.PARTY_ID = P.PARTY_ID
  AND HZ.PARTY_TYPE = 'PERSON'
  AND A.PRIMARY_FLAG = 'Y'
  AND A.ASSIGNMENT_TYPE = 'E'
  AND P.PERSON_TYPE_ID = T.PERSON_TYPE_ID
  AND P.BUSINESS_GROUP_ID = T.BUSINESS_GROUP_ID
  AND TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE
  AND TRUNC(SYSDATE) BETWEEN A.EFFECTIVE_START_DATE AND A.EFFECTIVE_END_DATE
  AND T.system_person_TYPE = 'EMP'
  AND P.EMPLOYEE_NUMBER = p_employee_number;

BEGIN
    OPEN c_employee;
    FETCH c_employee INTO l_party_id;
    CLOSE c_employee;

    return l_party_id;
EXCEPTION
WHEN OTHERS THEN
    IF (c_employee%ISOPEN)
    THEN
        CLOSE c_employee;
    END IF;
    x_err_text := G_PKG_NAME || ' : (employee Value-id conversion)' || substrb(SQLERRM,1,200);
    RETURN  FND_API.G_MISS_NUM;
END Employee;
--* End of Bug 4402842

--  Assignee
/*****************************************************************************
* Function      : Assignee
* Returns       : NULL if the function is unsuccessful else the Id of the
*                 Assignee name (Person or Group)
* Purpose       : Convert the Assignee to its party id for Eng Change
*****************************************************************************/
FUNCTION Assignee
( p_assignee              IN   VARCHAR2  -- party name
--, p_assignee_company_name IN   VARCHAR2
--, p_organization_id       IN   NUMBER
, x_err_text              OUT NOCOPY  VARCHAR2
)

RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
BEGIN

    l_id := Eng_Change_Common_Util.Get_User_Party_Id
            ( p_user_name => p_assignee
            , x_err_text => x_err_text);

    IF l_id IS NULL THEN                -- take this as a group name

        SELECT party_id INTO l_id
        FROM hz_parties
        WHERE party_name = p_assignee AND party_type = 'GROUP';
    END IF;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := NULL;
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Assignee Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        RETURN  FND_API.G_MISS_NUM;

END Assignee ;

/*
FUNCTION Status_Type(p_status_name  IN VARCHAR2)
RETURN NUMBER
IS
  l_result NUMBER;
BEGIN
  SELECT status_code into l_result from eng_change_statuses_vl
  where status_name = p_status_name;

  return l_result;
EXCEPTION
  WHEN OTHERS THEN
    return NULL;
END Status_Type;*/

/* 11.5 .10  we need both status_code and status_type */
PROCEDURE Status_Type(
 p_status_name  IN VARCHAR2
,x_status_code  OUT NOCOPY NUMBER
,x_status_type  OUT  NOCOPY NUMBER
,x_return_status    OUT NOCOPY  VARCHAR2
,p_change_order_type_id IN NUMBER
,p_plm_or_erp           IN VARCHAR2
)
IS
  l_st_code NUMBER;
  l_st_type NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if p_plm_or_erp ='PLM' then
    SELECT status_code ,status_type into l_st_code,l_st_type
    from  eng_change_statuses_vl
    where status_name = p_status_name
    and ((status_code in (select status_code from  eng_lifecycle_statuses
                        where entity_name='ENG_CHANGE_TYPE'
                                and entity_id1 = p_change_order_type_id)
         AND status_type <> 0)
      OR status_type =0);
  else
    SELECT status_code ,status_code into l_st_code,l_st_type
    /* Changed the above line from SELECT status_code ,status_type into l_st_code,l_st_type for Bug 8823124*/
    from  eng_change_statuses_vl
    where status_name = p_status_name;
--    and status_code =status_type;//commented for bug 3332992
  end if;

x_status_code := l_st_code;
x_status_type := l_st_type;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
        x_return_status := NULL;

    WHEN OTHERS THEN
       x_return_status := FND_API.G_MISS_NUM;

END Status_Type;



FUNCTION Approval_Status_Type(p_approval_status_name  IN VARCHAR2)
RETURN NUMBER
IS
  l_result NUMBER;
BEGIN
  SELECT to_number(lookup_code) into l_result from mfg_lookups
  where lookup_type = 'ENG_ECN_APPROVAL_STATUS'
    and meaning = p_approval_status_name;

  return l_result;
EXCEPTION
  WHEN OTHERS THEN
    return NULL;
END Approval_Status_Type;


FUNCTION Line_Status(p_status_name   IN VARCHAR2)
RETURN VARCHAR2
IS
  l_result VARCHAR2(30);
BEGIN
/* Status will not be saved in FND table anymore but in eng_change_statuses_vl
   SELECT lookup_code INTO l_result
  FROM fnd_lookup_values
  where lookup_type = 'ENG_CHANGE_LINE_STATUSES'
    AND meaning = p_status_name AND language = userenv('LANG'); */
--      Bug  2908248

SELECT status_code into l_result from eng_change_statuses_vl
  where status_name = p_status_name;

  return l_result;
EXCEPTION
  WHEN OTHERS THEN
    return NULL;
END Line_Status;


--  Change_Management_Type
/*****************************************************************
* FUNCTION      : Change_Management_Type
* Returns       : Change_Mgmt_Type_Code
* Purpose       : Will verify that the change management type that
*                 the user has specified exists for the language.
******************************************************************/
FUNCTION Change_Management_Type
(  p_change_management_type    IN  VARCHAR2
,  x_err_text                  OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS
    l_result        VARCHAR2(30);

BEGIN


    SELECT  change_mgmt_type_code
    INTO    l_result
    FROM   eng_change_order_types_VL  --11.5.10 changes
    WHERE  trim(type_name) = trim(p_change_management_type)
           and  type_classification='CATEGORY' and NVL(DISABLE_DATE,SYSDATE+1) > SYSDATE
           and START_DATE <=SYSDATE;

    return l_result;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := NULL;
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Change_Management_Type Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        RETURN  FND_API.G_MISS_CHAR ;

END Change_Management_Type;


--  Source_Type
/*****************************************************************
* FUNCTION      : Source_Type
* Returns       : Source_Type_Code
* Purpose       : Will verify that the source type that
*                 the user has specified exists for the language.
******************************************************************/
FUNCTION Source_Type
(  p_source_type               IN  VARCHAR2
,  x_err_text                  OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS
    l_result        VARCHAR2(30);

BEGIN

    SELECT lookup_code
    INTO l_result
    FROM fnd_lookup_values_vl
    WHERE lookup_type = 'ENG_CHANGE_SOURCE_TYPES'
    AND upper(trim(meaning)) = upper(trim(p_source_type));

    return l_result;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := NULL;
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Source_Type Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        RETURN  FND_API.G_MISS_CHAR ;

END Source_Type;


--  Source_Name
/*****************************************************************
* FUNCTION      : Source_Name
* Returns       : Source_Id
* Purpose       : Will verify that the source type that
*                 the user has specified exists for the language.
******************************************************************/
FUNCTION Source_Name
(  p_source_name               IN  VARCHAR2
,  p_source_type_code          IN  VARCHAR2
,  x_err_text                  OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
    l_result        NUMBER ;

BEGIN

    SELECT person_id
    INTO l_result
    FROM ego_people_v
    WHERE person_type = p_source_type_code
    AND Upper(person_name) = Upper(p_source_name);

    return l_result;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := NULL;
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Source_Name Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        RETURN  FND_API.G_MISS_CHAR ;

END Source_Name ;


-- Start bug 4967902
FUNCTION Hierarchy
(  p_organization_hierarchy      IN  VARCHAR2
,  x_err_text                    OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
    l_id        NUMBER ;

BEGIN

    Select organization_structure_id
    into l_id
    from per_organization_structures
    where name = p_organization_hierarchy;

    return l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := NULL;
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Organization_Hierarchy Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        RETURN  FND_API.G_MISS_CHAR ;

END Hierarchy ;
-- End bug 4967902

-- Item_Revision
/*****************************************************************
* FUNCTION      : Item_Revision
* Returns       : Item_Revision_Id in Future
* Purpose       : Will verify that the Item Revision that
*                 the user has specified exists.
******************************************************************/
FUNCTION Item_Revision
(  p_item_id             IN  NUMBER
 , p_organization_id     IN  NUMBER
 , p_item_revision       IN  VARCHAR2
,  x_err_text            OUT NOCOPY VARCHAR2
)
RETURN  NUMBER
IS
    l_result        NUMBER;

BEGIN

    SELECT  -100
    INTO    l_result
    FROM   MTL_ITEM_REVISIONS
    WHERE  inventory_item_id  = p_item_id
    AND    organization_id    = p_organization_id
    AND    revision           = p_item_revision  ;

    return l_result;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := NULL;
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Item Revision Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        RETURN  FND_API.G_MISS_CHAR ;

END Item_Revision ;


--  Change_Order_Type
/**************************************************************************
* Procedure     : Change_Order_Type
* Returns       : NUMBER, DISABLE DATE
* Purpose       : Will convert the change_order_type to change_order_type_id
*                 and will return the id and disable date. If it fails then
                  will return NULL.
*                 For an unexpected error it will return a missing value.
***************************************************************************/
PROCEDURE Change_Order_Type
( p_change_order_type IN  VARCHAR2
, p_change_mgmt_type  IN  VARCHAR2
, x_err_text          OUT NOCOPY VARCHAR2
, x_change_order_id   OUT NOCOPY NUMBER
, x_disable_date      OUT NOCOPY DATE
, x_object_id         OUT NOCOPY NUMBER
)
IS
BEGIN



    SELECT  change_order_type_id, disable_date, object_id
    INTO    x_change_order_id, x_disable_date, x_object_id
    FROM    eng_change_order_types_vl
    WHERE   type_name = p_change_order_type
      AND   change_mgmt_type_code = p_change_mgmt_type
      AND   type_classification='HEADER';

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_change_order_id := NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Change Order Type Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        x_change_order_id := FND_API.G_MISS_NUM;

END Change_Order_Type;

--  Change_Order_Line_Type
/**************************************************************************
* Procedure     : Change_Order_Line_Type
* Returns       : NUMBER, DISABLE DATE
* Purpose       : Procedure added on 25-Feb-2004 to enable line types import.
*                 Bug No: 3463472
*                 Issue: DEF-1694
*                 Will convert the change_order_type to change_order_type_id
*                 and will return the id and disable date. If it fails then
                  will return NULL. This works only for Line Types
*                 For an unexpected error it will return a missing value.
***************************************************************************/
PROCEDURE Change_Order_Line_Type
( p_change_order_type IN  VARCHAR2
, p_change_mgmt_type  IN  VARCHAR2
, x_err_text          OUT NOCOPY VARCHAR2
, x_change_order_id   OUT NOCOPY NUMBER
, x_disable_date      OUT NOCOPY DATE
, x_object_id         OUT NOCOPY NUMBER
)
IS
BEGIN

    SELECT  change_order_type_id, disable_date, object_id
    INTO    x_change_order_id, x_disable_date, x_object_id
    FROM    eng_change_order_types_vl
    WHERE   type_name = p_change_order_type
      AND   change_mgmt_type_code = p_change_mgmt_type
      AND   type_classification='LINE';

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_change_order_id := NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Change Order Type Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        x_change_order_id := FND_API.G_MISS_NUM;

END Change_Order_Line_Type;


--  Change_Mgmt_Type
/**************************************************************************
* Procedure     : Change_Mgmt_Type
* Returns       : Change mgmt type code
* Purpose       : Will convert the change mgmt type name to the
*                 corresponding code. If it fails then will return NULL.
***************************************************************************/
PROCEDURE Change_Mgmt_Type
(
  p_change_mgmt_type_name  IN  VARCHAR2
, x_change_mgmt_type_code  OUT NOCOPY VARCHAR2
, x_err_text OUT NOCOPY VARCHAR2
)
IS
BEGIN

    SELECT  change_mgmt_type_code
    INTO    x_change_mgmt_type_code
    FROM    eng_change_order_types_vl
    WHERE   type_name = p_change_mgmt_type_name
            and type_classification='CATEGORY'
            and NVL(DISABLE_DATE,SYSDATE+1) > SYSDATE
            and START_DATE <=SYSDATE;  --11.5.10

EXCEPTION

    WHEN OTHERS THEN
        x_change_mgmt_type_code := NULL;
        x_err_text := G_PKG_NAME || ' : (Change Mgmt Type Value-id conversion) '
                        || substrb(SQLERRM,1,200);

END Change_Mgmt_Type;


-- From Work Order and To Work Order
/*****************************************************************************
* Added by MK for ECO New Effectivities on 08/24/2000
* Function      : Work_Order
* Returns       : NULL if the function is unsuccessful else the Id of the
*                 work order number
* Purpose       : Convert the Requestor to its ID.
*****************************************************************************/

FUNCTION Work_Order
( p_work_order          IN  VARCHAR2
, p_organization_id     IN  NUMBER
, x_err_text            OUT NOCOPY VARCHAR2
)

RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
BEGIN

    SELECT  wip_entity_id
    INTO    l_id
    FROM    WIP_ENTITIES
    WHERE   organization_id = p_organization_id
    AND     wip_entity_name = p_work_order ;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_err_text := NULL;
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Work Order Value-id conversion) '
                        || substrb(SQLERRM,1,200);
END Work_Order ;

-- Change Order VID conversion procedure
-- changed the signature to get status id :enhancement:5414834
PROCEDURE Change_Order_VID
( p_ECO_rec                IN Eng_Eco_Pub.ECO_Rec_Type
, p_old_eco_unexp_rec      IN Eng_Eco_Pub.ECO_Unexposed_Rec_Type
, P_eco_unexp_rec          IN OUT NOCOPY Eng_Eco_Pub.ECO_Unexposed_Rec_Type
, x_Mesg_Token_Tbl         OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status          OUT NOCOPY VARCHAR2
)
IS
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_change_order_type_id  NUMBER;
l_change_mgmt_type_code VARCHAR2(30);
l_disable_date          DATE;
l_object_id             NUMBER;
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_err_text              VARCHAR2(2000);

l_change_type_code      VARCHAR2(80);
l_change_mgmt_type_name VARCHAR2(45);
l_change_notice         VARCHAR2(10);
l_transaction_type      VARCHAR2(10);
l_old_change_type_id    NUMBER;
l_old_change_mgmt_type  VARCHAR2(30);


l_status_type           NUMBER;
l_status_code           NUMBER;

BEGIN
        l_change_type_code       := p_ECO_rec.change_type_code;
        l_change_mgmt_type_name  := p_ECO_rec.change_management_type;
        l_change_notice          := p_ECO_rec.ECO_Name;
        l_transaction_type       := p_ECO_rec.transaction_type;
        l_old_change_type_id     := p_old_eco_unexp_rec.change_order_type_id;
        l_old_change_mgmt_type   := p_old_eco_unexp_rec.change_mgmt_type_code;

        l_token_tbl(1).token_name := 'ECO_NAME';
        l_token_tbl(1).token_value := l_change_notice;

        IF l_change_mgmt_type_name IS NULL OR
           l_change_mgmt_type_name = FND_API.G_MISS_CHAR
        THEN
          l_change_mgmt_type_code := 'CHANGE_ORDER';
        ELSE
          Change_Mgmt_Type
          (
            p_change_mgmt_type_name => l_change_mgmt_type_name
          , x_change_mgmt_type_code => l_change_mgmt_type_code
          , x_err_text => l_err_text
          );
        END IF;

          IF l_change_mgmt_type_code IS NULL
          THEN
            l_token_tbl(2).token_name := 'CHANGE_MGMT_TYPE_NAME';
            l_token_tbl(2).token_value := l_change_mgmt_type_name;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              Error_Handler.Add_Error_Token
              (
                p_Message_Name  => 'ENG_CHANGE_MGMT_TYPE_INVALID'
              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , p_Token_Tbl      => l_Token_Tbl
              );
            END IF;

            x_Return_Status := FND_API.G_RET_STS_ERROR;
            x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
            return; --added for bug 10234492
        END IF;


        -- Convert change_order_type_code to change_order_type_id

        IF l_change_type_code IS NOT NULL AND
           l_change_type_code <> FND_API.G_MISS_CHAR AND
           l_change_mgmt_type_code IS NOT NULL
        THEN
                Change_Order_Type
                        ( p_change_order_type => l_change_type_code
                        , p_change_mgmt_type => l_change_mgmt_type_code
                        , x_err_text => l_err_text
                        , x_change_order_id => l_change_order_type_id
                        , x_disable_date => l_disable_date
                        , x_object_id => l_object_id
                        );

                IF l_change_order_type_id IS NULL
                THEN
                        l_token_tbl(2).token_name := 'CHANGE_TYPE_CODE';
                        l_token_tbl(2).token_value := l_change_type_code;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                ( p_Message_Name  => 'ENG_CHANGE_TYPE_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl      => l_Token_Tbl
                                );
                        END IF;

                        x_Return_Status := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                ELSIF l_change_order_type_id = FND_API.G_MISS_NUM
                THEN
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                ELSE
                        p_eco_unexp_rec.change_order_type_id := l_change_order_type_id;
                        p_eco_unexp_rec.change_mgmt_type_code := l_change_mgmt_type_code;
                        x_Return_Status := FND_API.G_RET_STS_SUCCESS;
                END IF;
        ELSE
                IF l_transaction_type = Bom_GLOBALS.G_OPR_CREATE
                THEN
                   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        Error_Handler.Add_Error_Token
                        ( p_Message_Name  => 'ENG_CHANGE_TYPE_MISSING'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                        );
                   END IF;
                   x_Return_Status := FND_API.G_RET_STS_ERROR;
                   x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                   p_eco_unexp_rec.change_order_type_id := NULL;
                ELSE
                   p_eco_unexp_rec.change_order_type_id := l_old_change_type_id;
                   p_eco_unexp_rec.change_mgmt_type_code := l_old_change_mgmt_type;
                END IF;
        END IF;

        -- Change order type must not be disabled

        IF l_disable_date < SYSDATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'CHANGE_TYPE_CODE';
                        l_token_tbl(2).token_value := l_change_type_code;
                        Error_Handler.Add_Error_Token
                        ( p_Message_Name  => 'ENG_CHANGE_TYPE_DISABLED'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                        );
                END IF;
                x_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                p_eco_unexp_rec.change_order_type_id := l_change_order_type_id;
        END IF;
      --folowing has been added for bug 10234492
       if x_Return_Status = FND_API.G_RET_STS_ERROR then
          return;
         end if;


        IF p_ECO_rec.Status_Name IS NOT NULL AND
           p_ECO_rec.Status_Name <> FND_API.G_MISS_CHAR
        THEN
              Status_Type(p_status_name => p_ECO_rec.Status_Name
                           ,x_status_code => l_status_code
                           ,x_status_type => l_status_type
                           , x_return_status => x_return_status
                           ,p_change_order_type_id =>p_ECO_Unexp_Rec.change_order_type_id
                           ,p_plm_or_erp        => p_ECO_rec.plm_or_erp_change);
                IF l_status_type IS NULL or l_status_code IS NULL
                THEN
                        l_token_tbl(1).token_name := 'STATUS_TYPE';
                        l_token_tbl(1).token_value := p_ECO_rec.Status_Name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'ENG_STATUS_TYPE_INVALID'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , p_token_tbl          => l_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_token_tbl.DELETE;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                ELSE
                        p_ECO_Unexp_Rec.Status_Type := l_status_type ;
                        p_ECO_Unexp_Rec.Status_Code := l_status_code ;
                END IF;

        ELSE
            p_ECO_Unexp_Rec.Status_Type := NULL;
        END IF;

END Change_Order_VID;

/***************************************************************************
* Function      : Responsible_Org
* Returns       : NUMBER
* Purpose       : Will convert the value of responsible_org to organization_id
*                 using the table HR_ALL_ORGANIZATION_UNITS.
*                 If the conversion fails then the function will return a NULL
*                 otherwise will return the org_id. For an unexpected error
*                 function will return a missing value.
****************************************************************************/
FUNCTION Responsible_Org
( p_responsible_org IN  VARCHAR2
, p_current_org     IN  NUMBER
, x_err_text        OUT NOCOPY VARCHAR2
)
RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
BEGIN
    -- Bug 4947857
    -- The following query has been fixed to fetch valid departments immaterial of the business group in context.
    -- The view hr_organization_units in iteself is restricted based on the profile HR: Cross Business group
    -- Value and per_business_group_id in context if the prior value is N.
    -- Also , it is being assumed here that the user will login to Oracle Appliction for doing an import from
    -- 11.5.10 onwards because Change Import concurrent pogram is used. Otherwise the query should return all
    -- departments
    SELECT  hou.organization_id
    INTO    l_id
    FROM    hr_organization_units hou
    --      , org_organization_definitions org_def
    WHERE   hou.name = p_responsible_org
    --AND     org_def.business_group_id = hou.business_group_id
    --AND     org_def.organization_id = p_current_org  ;
    AND exists (SELECT null FROM hr_organization_information hoi
                      WHERE hoi.organization_id = hou.organization_id
                        AND hoi.org_information_context = 'CLASS'
                        AND hoi.org_information1 = 'BOM_ECOD'
                        AND hoi.org_information2 = 'Y');

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
        x_err_text := G_PKG_NAME || ' : (Responsible Org Value-id conversion) '
                        || substrb(SQLERRM,1,200);
        RETURN FND_API.G_MISS_NUM;

END Responsible_Org;

/***************************************************************************
* Function      : Organization
* Returns       : NUMBER
* Purpose       : Will convert the value of organization_code to organization_id
*                 using MTL_PARAMETERS.
*                 If the conversion fails then the function will return a NULL
*                 otherwise will return the org_id. For an unexpected error
*                 function will return a missing value.
****************************************************************************/
FUNCTION Organization(p_organization IN VARCHAR2,
                        x_err_text OUT NOCOPY VARCHAR2 )

RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
l_err_text                    VARCHAR2(2000);
BEGIN

    SELECT  organization_id
    INTO    l_id
    FROM    mtl_parameters
    WHERE   organization_code = p_organization;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN NULL;

    WHEN OTHERS THEN
        RETURN FND_API.G_MISS_NUM;

END Organization;

/****************************************************************************
* Function      : Revised_Item
* Parameters IN : Revised Item Name
*                 Organization ID
* Parameters OUT: Error_Text
* Returns       : Revised Item Id
* Purpose       : This function will get the ID for the revised item and
*                 return the ID. If the revised item is invalid then the
*                 ID will returned as NULL.
****************************************************************************/
FUNCTION Revised_Item(  p_revised_item_num IN VARCHAR2,
                        p_organization_id IN NUMBER,
                        x_err_text OUT NOCOPY VARCHAR2 )
RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
l_err_text                    VARCHAR2(2000);
BEGIN

/*    ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id => p_organization_id,
                flex_code => 'MSTK',
                flex_name => p_revised_item_num,
                flex_id => l_id,
                set_id => -1,
                err_text => x_err_text);

    IF (ret_code <> 0) THEN
        RETURN NULL;
    ELSE
        RETURN l_id;
    END IF;
*/
    select inventory_item_id into l_id
    from mtl_system_items_kfv
    where concatenated_segments = p_revised_item_num
    and organization_id = p_organization_id;

    return l_id;

EXCEPTION
   when others then
     return null;

END Revised_Item;


FUNCTION Revised_Item_Code(  p_revised_item_num IN NUMBER,
                        p_organization_id IN NUMBER,
                        p_revison_code  IN   VARCHAR2 )
RETURN  number
IS
l_id                          NUMBER;
ret_code                      NUMBER;
BEGIN
    select revision_id into l_id
    from mtl_item_revisions
    where inventory_item_id = p_revised_item_num
    and organization_id = p_organization_id
    and revision =   p_revison_code    ;

    return l_id;

EXCEPTION
   when others then
     return null;

END Revised_Item_Code;

--  Use_Up_Item

FUNCTION Use_Up_Item(   p_use_up_item_num IN VARCHAR2,
                        p_organization_id IN NUMBER,
                        x_err_text OUT NOCOPY VARCHAR2 )
RETURN NUMBER
IS
l_id                          NUMBER;
ret_code                      NUMBER;
l_err_text                    VARCHAR2(2000);
BEGIN

    /*ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id => p_organization_id,
                flex_code => 'MSTK',
                flex_name => p_use_up_item_num,
                flex_id => l_id,
                set_id => -1,
                err_text => x_err_text);

    IF (ret_code <> 0) THEN
        RETURN NULL;
    END IF;*/
    select inventory_item_id into l_id
    from mtl_system_items_kfv
    where concatenated_segments = p_use_up_item_num
    and organization_id = p_organization_id;

    RETURN l_id;
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;
END Use_Up_Item;

-- Assembly item id

FUNCTION ASSEMBLY_ITEM( p_organization_id   IN NUMBER,
                        p_assembly_item_num IN VARCHAR2,
                        x_err_text OUT NOCOPY VARCHAR2)
return NUMBER
IS
l_id                            NUMBER;
ret_code                      NUMBER;
BEGIN

    /*ret_code := INVPUOPI.mtl_pr_parse_flex_name(
               org_id => p_organization_id,
               flex_code => 'MSTK',
               flex_name => p_assembly_item_num,
               flex_id => l_id,
               set_id => -1,
               err_text => x_err_text);

        IF (ret_code <> 0) THEN
                NULL;
        END IF;*/
    select inventory_item_id into l_id
    from mtl_system_items_kfv
    where concatenated_segments = p_assembly_item_num
    and organization_id = p_organization_id;

    RETURN l_id;
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;
END;


--  Bill_Sequence

FUNCTION Bill_Sequence( p_assembly_item_id IN NUMBER,
                       p_alternate_bom_designator IN VARCHAR2,
                       p_organization_id  IN NUMBER,
                       x_err_text         OUT NOCOPY VARCHAR2
                        )
RETURN NUMBER
IS
l_id                          NUMBER;
l_err_text                    VARCHAR2(2000);
BEGIN

        SELECT bill_sequence_id
          INTO l_id
          FROM bom_bill_of_materials
         WHERE assembly_item_id = p_assembly_item_id
           AND NVL(alternate_bom_designator, 'NONE') =
               NVL(p_alternate_bom_designator, 'NONE')
           AND organization_id = p_organization_id;

        RETURN l_id;

        EXCEPTION
                WHEN OTHERS THEN
                        RETURN NULL;


END Bill_Sequence;


FUNCTION BillandAssembly( p_revised_item_seq_id         IN      NUMBER,
                          x_bill_sequence_id            OUT NOCOPY     NUMBER,
                          x_assembly_item_id            OUT NOCOPY     NUMBER,
                          x_err_text                    OUT NOCOPY     VARCHAR2)
RETURN NUMBER IS
l_dummy VARCHAR2(80);
CURSOR c_BillExists IS
        SELECT 'Valid' b_valid
          FROM eng_revised_items
         WHERE revised_item_sequence_id = p_revised_item_seq_id
           AND bill_sequence_id IS NOT NULL;
BEGIN
-- Derive Bill_Sequence_id and assembly_item_id from Revised_item_sequence_id
--Do this only if the Bill of that item exists.

/********************** Temporarily commented ****************

        FOR BillExists IN c_BillExists LOOP
        BEGIN
                SELECT bill_sequence_id,
                       revised_item_id
                  INTO x_bill_sequence_id,
                       x_assembly_item_id
                  FROM eng_revised_items
                 WHERE revised_item_sequence_id = p_revised_item_seq_id;
****************************************/

                RETURN 1;   --indicating success of the conversion


END BillandAssembly;

/*************************************************************************
* Function      : BillAndRevItemSeq
* Parameters IN : Revised Item Unique Key information
* Parameters OUT: Bill Sequence ID
* Returns       : Revised Item Sequence
* Purpose       : Will use the revised item information to find the bill
*                 sequence and the revised item sequence.
FUNCTION  BillAndRevItemSeq(  p_revised_item_id         IN  NUMBER
                            , p_item_revision           IN  VARCHAR2
                            , p_effective_date          IN  DATE
                            , p_change_notice           IN  VARCHAR2
                            , p_organization_id         IN  NUMBER
                            , p_from_end_item_number    IN  NUMBER := NULL
                            , x_Bill_Sequence_Id        OUT NOCOPY NUMBER
                            )
RETURN NUMBER
IS
        l_Bill_Seq      NUMBER;
        l_Rev_Item_Seq  NUMBER;
BEGIN
        SELECT bill_sequence_id, revised_item_Sequence_id
          INTO l_Bill_Seq, l_Rev_Item_Seq
          FROM eng_revised_items
         WHERE revised_item_id           = p_revised_item_id
           AND NVL(new_item_revision,'NULL')= NVL(p_item_revision,'NULL')
           AND TRUNC(scheduled_date)     = trunc(p_effective_date)
           AND NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR)
                        = NVL(p_from_end_item_number, FND_API.G_MISS_CHAR)
           AND change_notice             = p_change_notice
           AND organization_id           = p_organization_id;

         x_Bill_Sequence_Id := l_Bill_Seq;
         RETURN l_Rev_Item_Seq;

        EXCEPTION
                WHEN OTHERS THEN
                        x_Bill_Sequence_Id := NULL;
                        RETURN NULL;
END BillAndRevItemSeq;
**************************************************************************/


FUNCTION AsmblyFromRevItem(p_revised_item_seq_id   IN   NUMBER,
                           x_err_text             OUT NOCOPY   VARCHAR2
                           )
RETURN NUMBER
IS
l_assembly_item_id      NUMBER;
BEGIN
        /*********************************************************
        SELECT revised_item_id
          INTO l_assembly_item_id
          FROM eng_revised_items
         WHERE revised_item_sequence_id = p_revised_item_seq_id;

        RETURN l_assembly_item_id;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;
        **********************************************************/
        NULL;
END;

FUNCTION Revised_Item_Sequence(  p_revised_item_id      IN   NUMBER
                               , p_change_notice        IN   VARCHAR2
                               , p_organization_id      IN   NUMBER
                               , p_new_item_revision    IN   VARCHAR2
                               )
RETURN NUMBER
IS
l_id                          NUMBER;
BEGIN

        SELECT revised_item_sequence_id
          INTO l_id
          FROM Eng_revised_items
         WHERE revised_item_id   = p_revised_item_id
           AND change_notice     = p_change_notice
           AND organization_id   = p_organization_id
           AND NVL(new_item_revision, 'NONE') =
               NVL(p_new_item_revision, 'NONE');

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        RETURN NULL;

    WHEN OTHERS THEN
        RETURN FND_API.G_MISS_NUM;

END Revised_Item_Sequence;


-- Eco Revision
FUNCTION Revision ( p_rev       IN VARCHAR2
                  , p_organization_id IN NUMBER
                  , p_change_notice IN VARCHAR2
                  , x_err_text OUT NOCOPY VARCHAR2
                  ) RETURN NUMBER
IS
l_revision_id  NUMBER;
BEGIN
        SELECT revision_id
          INTO l_revision_id
          FROM eng_change_order_revisions
         WHERE change_notice = p_change_notice
           AND organization_id = p_organization_id
           AND revision = p_rev;

        RETURN l_revision_id;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;
                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;

END Revision;

/*  11.5.10 Function to return parent_revised_item_sequence_id ,
    given revised_item_id ,schedule_date and alternate_bom_designator
*/

FUNCTION ParentRevSeqId
                  ( parent_item_name       IN VARCHAR2
                  , p_organization_id IN NUMBER
                  , p_alternate_bom_code IN VARCHAR2
                  ,p_schedule_date    DATE
                  ,p_change_id       NUMBER
                  ) RETURN NUMBER
IS
cursor parent (rev_item_id eng_revised_items.revised_item_id%TYPE
                    ) is
         select revised_item_sequence_id
         from   eng_revised_items
         where  REVISED_ITEM_ID = rev_item_id and
                organization_id  = p_organization_id and
                nvl(alternate_bom_designator,'NULL') = nvl(p_alternate_bom_code,'NULL')and
                SCHEDULED_DATE = p_schedule_date and
                change_id=        p_change_id           ;



l_id                          NUMBER;
l_revised_item_seq_id         NUMBER;
ret_code                      NUMBER;
l_err_text                    VARCHAR2(2000);
begin

        l_id := Use_Up_Item(  p_use_up_item_num =>
                                        parent_item_name
                            , p_organization_id =>
                                        p_organization_id
                            , x_err_text        => l_Err_Text);

        open parent(l_id);
        fetch parent into l_revised_item_seq_id;
        close parent;

return l_revised_item_seq_id;

EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        RETURN NULL;
                WHEN OTHERS THEN
                        RETURN FND_API.G_MISS_NUM;


END ParentRevSeqId;

--11.5.10

-- 11.5.10E
/**************************************************************************
* Function      : From_Revision_Id
* Returns       : NUMBER
* Purpose       : This function takes the from revision and returns the
*                 revision Id for the revised Item. If the
*                 revision is passed as null, then the revision Id of the
*                 current revision is returned.
***************************************************************************/

FUNCTION From_Revision_Id( p_assembly_item_id IN VARCHAR2,
                           p_organization_id IN NUMBER,
                           p_revision IN VARCHAR2,
                           p_revision_date IN DATE,
                           x_err_text OUT NOCOPY VARCHAR2 )
RETURN NUMBER
IS
l_revision_id      NUMBER;
l_revision         VARCHAR2(3);
l_cur_rev_ef_date  DATE;

CURSOR FROM_REVISION_ID_CURRENT IS
       SELECT REVISION_ID, REVISION, EFFECTIVITY_DATE
       FROM   MTL_ITEM_REVISIONS
       WHERE  INVENTORY_ITEM_ID = p_assembly_item_id
       AND    ORGANIZATION_ID = p_organization_id
       AND    EFFECTIVITY_DATE <= p_revision_date
       AND    IMPLEMENTATION_DATE IS NOT NULL
       ORDER BY EFFECTIVITY_DATE DESC, REVISION DESC;

CURSOR FROM_REVISION_ID_FUTURE(p_date IN DATE) IS
       SELECT REVISION_ID
       FROM   MTL_ITEM_REVISIONS
       WHERE  INVENTORY_ITEM_ID = p_assembly_item_id
       AND    ORGANIZATION_ID = p_organization_id
       AND    REVISION = p_revision
       AND    EFFECTIVITY_DATE > p_date;
BEGIN
  OPEN FROM_REVISION_ID_CURRENT;
  FETCH FROM_REVISION_ID_CURRENT INTO l_revision_id, l_revision, l_cur_rev_ef_date;
  CLOSE FROM_REVISION_ID_CURRENT;

  IF (l_revision = p_revision)
  THEN
    RETURN l_revision_id;
  ELSE
    l_revision_id := NULL;

    OPEN FROM_REVISION_ID_FUTURE(l_cur_rev_ef_date);
    FETCH FROM_REVISION_ID_FUTURE INTO l_revision_id;
    CLOSE FROM_REVISION_ID_FUTURE;
    RETURN l_revision_id;
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF FROM_REVISION_ID_CURRENT%ISOPEN
      THEN
        CLOSE FROM_REVISION_ID_CURRENT;
      END IF;
      IF FROM_REVISION_ID_FUTURE%ISOPEN
      THEN
        CLOSE FROM_REVISION_ID_FUTURE;
      END IF;

      RETURN NULL;

    WHEN OTHERS THEN
      IF FROM_REVISION_ID_CURRENT%ISOPEN
      THEN
        CLOSE FROM_REVISION_ID_CURRENT;
      END IF;
      IF FROM_REVISION_ID_FUTURE%ISOPEN
      THEN
        CLOSE FROM_REVISION_ID_FUTURE;
      END IF;

      RETURN FND_API.G_MISS_NUM;

END From_Revision_Id;


/**************************************************************************
* Function      : New_Revision_Reason_Code
* Returns       : VARCHAR2
* Purpose       : This function takes the reason and returns the reason
*                 code for the reason given.
***************************************************************************/

FUNCTION New_Revision_Reason_Code( p_reason IN VARCHAR2,
                           x_err_text OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2
IS
l_reason_code      VARCHAR2(30) := NULL;

BEGIN
  SELECT LOOKUP_CODE
  INTO l_reason_code
  FROM FND_LOOKUPS
  WHERE LOOKUP_TYPE = 'EGO_ITEM_REVISION_REASON'
  AND ENABLED_FLAG = 'Y'
  AND MEANING = p_reason;

  RETURN l_reason_code;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;
END New_Revision_Reason_Code;


/**************************************************************************
* Function      : Get_Structure_Type_Id
* Returns       : NUMBER
* Purpose       : This function takes the structure name and returns the
*                 structure id.
***************************************************************************/

FUNCTION Get_Structure_Type_Id( p_structure_type_name IN VARCHAR2,
                                x_err_text OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2
IS
l_structure_type_id      VARCHAR2(30) := NULL;

BEGIN
  SELECT structure_type_id
  INTO l_structure_type_id
  FROM bom_structure_types_vl
  WHERE structure_type_name = p_structure_type_name;

  RETURN l_structure_type_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;
END Get_Structure_Type_Id;


/****************************************************************************
* Procedure     : Revised_Item_VID
* Parameters IN : Revised Item Unexposed column Record
*                 Revised Item exposed column record
* Parameters OUT: Revised item Unexposed column record after conversion
*                 Return Status
*                 Mesg_Token_Tbl
* Purpose       : This procedure will drive the Value-To_Id conversion for the
*                 revised item entity.
****************************************************************************/
PROCEDURE Revised_Item_VID
(  x_Return_Status       OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_rev_item_unexp_Rec  IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_rev_item_unexp_Rec  IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , p_revised_item_Rec    IN  Eng_Eco_Pub.Revised_Item_Rec_Type
)
IS
l_return_value  NUMBER;
l_Return_Status VARCHAR2(1);
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_Rev_Item_Unexp_Rec    Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type;
l_Err_Text              VARCHAR2(2000);
l_bill_seq_id           NUMBER;
l_eco_type              VARCHAR2(3);
l_from_revision         VARCHAR2(3) := NULL;
l_from_revision_id      NUMBER;
l_structure_type_id     NUMBER;

BEGIN
        l_Return_Status := FND_API.G_RET_STS_SUCCESS;
        l_Rev_item_Unexp_Rec := p_Rev_item_Unexp_Rec;

        IF p_revised_item_rec.use_up_item_name IS NOT NULL AND
           p_revised_item_rec.use_up_item_name <> FND_API.G_MISS_CHAR
        THEN
                l_rev_item_unexp_rec.use_up_item_id :=
                Use_Up_Item(  p_use_up_item_num =>
                                        p_revised_item_rec.use_up_item_name
                            , p_organization_id =>
                                        p_rev_item_unexp_Rec.organization_id
                            , x_err_text        => l_Err_Text);

                IF l_rev_item_unexp_rec.use_up_item_id IS NULL
                THEN
                        l_return_status := FND_API.G_RET_STS_ERROR;

                                l_token_tbl(1).token_name := 'USE_UP_ITEM_NAME';
                                l_token_tbl(1).token_value :=
                                        p_revised_item_rec.use_up_item_name;
                                l_token_tbl(2).token_name := 'ORGANIZATION_CODE';
                                l_token_tbl(2).token_value :=
                                        p_revised_item_rec.organization_code;

                                Error_Handler.Add_Error_Token
                                ( p_Message_Name   =>'ENG_USE_UP_ITEM_ID_VID_INVALID'
                                , p_Message_Text   => NULL
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl => l_Token_Tbl);
                END IF;
        END IF;

        --
        -- If the user has give requestor name then convert requestor name
        -- to requestor ID.
        --

        IF p_revised_item_rec.requestor IS NOT NULL AND
           p_revised_item_rec.requestor <> FND_API.G_MISS_CHAR
        THEN
                 l_rev_item_unexp_rec.requestor_id :=
                 Requestor
                 (  p_requestor         => p_revised_item_rec.requestor
                  , p_organization_id   => p_rev_item_unexp_rec.organization_id
                  , x_err_text          => l_err_text
                  );

                 IF l_err_text IS NOT NULL
                 THEN
                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => NULL
                         , p_Message_Text   => l_err_text
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         );
                         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 ELSIF l_rev_item_unexp_rec.requestor_id IS NULL
                 THEN
                        l_token_tbl(1).token_name := 'REQUESTOR';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.requestor;
                        l_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                        l_token_tbl(2).token_value :=
                                        p_revised_item_rec.organization_code;

                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => 'ENG_RIT_REQUESTOR_INVALID'
                         , p_Message_Text   => NULL
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_token_tbl      => l_token_tbl
                         );
                         l_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
        END IF;


        /*******************************************************
        -- Followings are for ECO Routing and New Effectivities
        -- Added by MK on 08/24/2000
        ********************************************************/
        --
        -- If the user has give from_work_order or to_work_order,
        -- then convert to wip_entity_id
        --
        IF p_revised_item_rec.from_work_order IS NOT NULL AND
           p_revised_item_rec.from_work_order <> FND_API.G_MISS_CHAR
        THEN
                 l_rev_item_unexp_rec.from_wip_entity_id :=
                 Work_Order
                 (  p_work_order        => p_revised_item_rec.from_work_order
                  , p_organization_id   => p_rev_item_unexp_rec.organization_id
                  , x_err_text          => l_err_text
                  );

                 IF l_err_text IS NOT NULL
                 THEN
                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => NULL
                         , p_Message_Text   => l_err_text
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         );
                         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 ELSIF l_rev_item_unexp_rec.from_wip_entity_id IS NULL
                 THEN
                        l_token_tbl(1).token_name := 'FROM_WORK_ORDER';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.from_work_order ;
                        l_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                        l_token_tbl(2).token_value :=
                                        p_revised_item_rec.revised_item_name ;

                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => 'ENG_RIT_FROM_WO_INVALID'
                         , p_Message_Text   => NULL
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_token_tbl      => l_token_tbl
                         );
                         l_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
        END IF ;

        IF p_revised_item_rec.to_work_order IS NOT NULL AND
           p_revised_item_rec.to_work_order <> FND_API.G_MISS_CHAR
        THEN
                 l_rev_item_unexp_rec.to_wip_entity_id :=
                 Work_Order
                 (  p_work_order        => p_revised_item_rec.to_work_order
                  , p_organization_id   => p_rev_item_unexp_rec.organization_id
                  , x_err_text          => l_err_text
                  );

                 IF l_err_text IS NOT NULL
                 THEN
                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => NULL
                         , p_Message_Text   => l_err_text
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         );
                         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 ELSIF l_rev_item_unexp_rec.from_wip_entity_id IS NULL
                 THEN
                        l_token_tbl(1).token_name := 'TO_WORK_ORDER';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.to_work_order ;
                        l_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                        l_token_tbl(2).token_value :=
                                        p_revised_item_rec.revised_item_name ;

                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => 'ENG_RIT_TO_WO_INVALID'
                         , p_Message_Text   => NULL
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_token_tbl      => l_token_tbl
                         );
                         l_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
        END IF ;

        --
        -- If the user has give Copmletion_Location_Name,
        -- then convert to completion_location_id
        --
        IF p_revised_item_rec.completion_location_name IS NOT NULL AND
           p_revised_item_rec.completion_location_name <> FND_API.G_MISS_CHAR
        THEN
                l_rev_item_unexp_rec.completion_locator_id :=
                BOM_RTG_Val_To_Id.Completion_locator_id
                (  p_completion_location_name   => p_revised_item_rec.completion_location_name
                 , p_organization_id            => p_rev_item_unexp_rec.organization_id
                 , x_err_text                   => l_err_text
                 );
                IF l_err_text IS NOT NULL
                THEN
                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => NULL
                         , p_Message_Text   => l_err_text
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         );
                         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                ELSIF  l_rev_item_unexp_rec.completion_locator_id IS NULL
                THEN
                        l_token_tbl(1).token_name := 'COMPLETION_LOCATION_NAME';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.completion_location_name ;
                        l_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                        l_token_tbl(2).token_value :=
                                        p_revised_item_rec.revised_item_name ;

                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => 'ENG_RIT_LOCATION_NAME_INVALID'
                         , p_Message_Text   => NULL
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_token_tbl      => l_token_tbl
                         );
                         l_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
        END IF;
        -- Added by MK 08/24/2000

        -- Added by MK on 02/15/2001
        IF ( l_rev_item_unexp_rec.bill_sequence_id IS NULL OR
             l_rev_item_unexp_rec.bill_sequence_id = FND_API.G_MISS_NUM ) AND
           (( p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
             p_revised_item_rec.alternate_bom_code IS NOT NULL ) OR
         /* Added for Bug 2992001  */
            (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE))
        THEN

            l_rev_item_unexp_rec.bill_sequence_id :=
                    BOM_Val_To_Id.Bill_Sequence_Id
                    ( p_assembly_item_id => l_rev_item_unexp_rec.revised_item_id
                    , p_organization_id  => l_rev_item_unexp_rec.organization_id
                    , p_alternate_bom_code =>
                                            p_revised_item_rec.alternate_bom_code
                    , x_err_text         => l_err_text
                    );

IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Getting Bill Seq Id . . . : ' ||
                             to_char(l_rev_item_unexp_rec.bill_sequence_id));
END IF;

        END IF;

        IF ( l_rev_item_unexp_rec.routing_sequence_id IS NULL OR
             l_rev_item_unexp_rec.routing_sequence_id = FND_API.G_MISS_NUM )  AND
           ( p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
             p_revised_item_rec.alternate_bom_code IS NOT NULL )

        THEN

            l_rev_item_unexp_rec.routing_sequence_id :=
                    BOM_RTG_Val_To_Id.Routing_Sequence_id
                    (  p_assembly_item_id  =>  l_rev_item_unexp_rec.revised_item_id
                     , p_organization_id   =>  l_rev_item_unexp_rec.organization_id
                     , p_alternate_routing_designator =>
                                               p_revised_item_rec.alternate_bom_code
                     , x_err_text          => l_err_text
                     );


IF Bom_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Getting Routing Seq Id . . . : ' ||
                             to_char(l_rev_item_unexp_rec.routing_sequence_id));
END IF;

        END IF;
---11.5.10
    IF (p_revised_item_rec.parent_revised_item_name is not null) then

        l_rev_item_unexp_rec.parent_revised_item_seq_id:=
                 ParentRevSeqId
                  ( parent_item_name     =>   p_revised_item_rec.parent_revised_item_name
                  , p_organization_id    =>   l_rev_item_unexp_rec.organization_id
                  , p_alternate_bom_code =>   p_revised_item_rec.parent_alternate_name
                  , p_schedule_date      =>   p_revised_item_rec.start_effective_date
                  , p_change_id          =>   l_rev_item_unexp_rec.change_id);
    end if;



IF (p_revised_item_rec.from_end_item_name is not null) then

  l_rev_item_unexp_rec.from_end_item_id :=
              Revised_Item
            (  p_revised_item_num =>p_revised_item_rec.from_end_item_name,
               p_organization_id =>l_rev_item_unexp_rec.organization_id,
                        x_err_text =>l_err_text );

IF (p_revised_item_rec.from_end_item_revision is not null) then

   select  revision_id into l_rev_item_unexp_rec.from_end_item_revision_id
      from mtl_item_revisions
   where  inventory_item_id =l_rev_item_unexp_rec.from_end_item_id
   and    organization_id =l_rev_item_unexp_rec.organization_id;

   select bill_sequence_id into l_bill_seq_id from bom_bill_of_materials
   where
   ASSEMBLY_ITEM_ID       = l_rev_item_unexp_rec.from_end_item_id
   and ORGANIZATION_ID                = l_rev_item_unexp_rec.organization_id
   and ALTERNATE_BOM_DESIGNATOR       = p_revised_item_rec.from_end_item_alternate;

/* not supported for 11.5.10
   select STRUCTURE_REVISION_ID  into l_rev_item_unexp_rec.from_end_item_struct_rev_id
   from  should be using minor revision table
   where BILL_SEQUENCE_ID =l_bill_seq_id
   and REVISION       =p_revised_item_rec.from_end_item_revision
   and  OBJECT_REVISION_ID = l_rev_item_unexp_rec.from_end_item_revision_id;
*/

end if;

end if;
--11.5.10

        -- 11.5.10E
        -- Querying to find if the change is ERP or PLM change
        -- 'From Revision' changes are valid only for PLM changes
        l_eco_type := Eng_Globals.Get_PLM_Or_ERP_Change
                          (p_revised_item_rec.eco_name,
                           l_rev_item_unexp_rec.organization_id
                           );

        IF (l_eco_type IS NULL)
        THEN
          l_eco_type := 'PLM';
        END IF;

        IF (l_eco_type = 'PLM')
        THEN
          -- Changes to enable 'From Revision' for revised items.
          -- The from revision id is set from the revision label
          IF ( (p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
                p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE) AND
                p_revised_item_rec.from_item_revision IS NOT NULL)
          THEN
            l_rev_item_unexp_rec.from_item_revision_id := From_Revision_Id
                    (  p_assembly_item_id  => l_rev_item_unexp_rec.revised_item_id
                     , p_organization_id   => l_rev_item_unexp_rec.organization_id
                     , p_revision          => p_revised_item_rec.from_item_revision
                     , p_revision_date     => SYSDATE
                     , x_err_text          => l_err_text
                     );
            IF Bom_Globals.Get_Debug = 'Y'
            THEN
              Error_Handler.Write_Debug('Getting From Revision Id . . . : ' ||
                             to_char(l_rev_item_unexp_rec.from_item_revision_id));
            END IF;

            IF ( l_rev_item_unexp_rec.from_item_revision_id IS NULL OR
                 l_rev_item_unexp_rec.from_item_revision_id = FND_API.G_MISS_NUM)
            THEN
              l_token_tbl(1).token_name  := 'FROM_REVISION';
              l_token_tbl(1).token_value := l_rev_item_unexp_rec.from_item_revision_id ;
              l_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
              l_token_tbl(2).token_value := p_revised_item_rec.revised_item_name ;

              Error_Handler.Add_Error_Token
              ( p_Message_Name   => 'ENG_INVALID_FROM_REVISION'
              , p_Message_Text   => NULL
              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , p_token_tbl      => l_token_tbl
              );
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;

          -- The new revision reason, if provided is converted to the corresponding
          -- code.
          IF((p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_CREATE OR
              p_revised_item_rec.transaction_type = ENG_GLOBALS.G_OPR_UPDATE) AND
              p_revised_item_rec.New_Revised_Item_Revision IS NOT NULL AND
              p_revised_item_rec.new_revision_reason IS NOT NULL)
          THEN
            l_rev_item_unexp_rec.new_revision_reason_code :=
                    New_Revision_Reason_Code
                    (  p_reason    => p_revised_item_rec.new_revision_reason
                     , x_err_text  => l_err_text
                     );

            IF ( l_rev_item_unexp_rec.new_revision_reason_code IS NULL OR
                 l_rev_item_unexp_rec.new_revision_reason_code = FND_API.G_MISS_CHAR)
            THEN
              l_token_tbl(1).token_name  := 'NEW_REVISION_REASON';
              l_token_tbl(1).token_value := p_revised_item_rec.new_revision_reason ;
              l_token_tbl(2).token_name  := 'REVISED_ITEM_NAME';
              l_token_tbl(2).token_value := p_revised_item_rec.revised_item_name ;

              Error_Handler.Add_Error_Token
              ( p_Message_Name   => 'ENG_INVALID_REVISION_REASON'
              , p_Message_Text   => NULL
              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , p_token_tbl      => l_token_tbl
              );
              l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF Bom_Globals.Get_Debug = 'Y'
            THEN
              Error_Handler.Write_Debug('Getting New Revision reason Code . . . : ' ||
                               l_rev_item_unexp_rec.new_revision_reason_code); -- bug 4309885: removed to_char(varchar) as it is not supported in 8i
            END IF;
          END IF;
        END IF;  -- End of (l_eco_type = 'PLM')

        --
        -- Convert structure type name to structure type id
        -- if it is given
        --
        IF p_revised_item_rec.structure_type_name IS NOT NULL AND
           p_revised_item_rec.structure_type_name <> FND_API.G_MISS_CHAR
        THEN
                l_rev_item_unexp_rec.structure_type_id :=
                Get_Structure_Type_Id
                (  p_structure_type_name   => p_revised_item_rec.structure_type_name
                 , x_err_text              => l_err_text
                 );
                IF l_err_text IS NOT NULL
                THEN
                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => NULL
                         , p_Message_Text   => l_err_text
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         );
                         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                ELSIF  l_rev_item_unexp_rec.structure_type_id IS NULL
                THEN
                        l_token_tbl(1).token_name := 'STRUCTURE_TYPE_NAME';
                        l_token_tbl(1).token_value :=
                                        p_revised_item_rec.structure_type_name ;
                        l_token_tbl(2).token_name := 'REVISED_ITEM_NAME';
                        l_token_tbl(2).token_value :=
                                        p_revised_item_rec.revised_item_name ;

                         Error_Handler.Add_Error_Token
                         ( p_Message_Name   => 'ENG_STRUC_TYPE_NAME_INVALID'
                         , p_Message_Text   => NULL
                         , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                         , p_token_tbl      => l_token_tbl
                         );
                         l_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
        END IF;

        x_return_status := l_return_status;
        x_rev_item_unexp_rec := l_rev_item_unexp_rec;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

END Revised_Item_VID;


PROCEDURE ECO_Header_VID
(   x_Return_Status              OUT NOCOPY    VARCHAR2
 ,  x_Mesg_Token_Tbl             OUT NOCOPY    Error_Handler.Mesg_Token_Tbl_Type
 ,  p_ECO_Rec                    IN     Eng_Eco_Pub.ECO_Rec_Type
 ,  p_ECO_Unexp_Rec              IN     Eng_Eco_Pub.Eco_Unexposed_Rec_Type
 ,  x_ECO_Unexp_Rec              IN OUT NOCOPY    Eng_Eco_Pub.Eco_Unexposed_Rec_Type
)
IS
l_err_text              VARCHAR2(2000) := NULL;
l_return_value          NUMBER;
l_Return_Status         VARCHAR2(1);
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_ECO_Unexp_Rec         Eng_Eco_Pub.Eco_Unexposed_Rec_Type;


l_change_mgmt_type_code VARCHAR2(30) ;
l_source_type_code      VARCHAR2(30) ;
l_status_type           NUMBER;
l_approval_status_type  NUMBER;
l_status_code           NUMBER;
l_plm_or_erp_change     eng_engineering_changes.plm_or_erp_change%type;
BEGIN
        l_Return_Status := FND_API.G_RET_STS_SUCCESS;
        l_ECO_Unexp_Rec := p_ECO_Unexp_Rec;

        l_token_tbl(1).token_name := 'ECO_Name';
        l_token_tbl(1).token_value := p_ECO_rec.ECO_name;

        -- Initializing Plm or Erp Change
        IF p_eco_rec.transaction_type = 'CREATE'
        THEN
            l_plm_or_erp_change := p_eco_rec.plm_or_erp_change;
        ELSE
            l_plm_or_erp_change := Eng_Globals.Get_PLM_Or_ERP_Change(
                                      p_ECO_Rec.eco_name
                                    , p_ECO_Unexp_Rec.organization_id);
        END IF;

        --
        -- Convert Approval_List_Name to Approval_List_Id
        --

        IF p_ECO_rec.approval_list_name IS NOT NULL AND
           p_ECO_rec.approval_list_name <> FND_API.G_MISS_CHAR
        THEN
                l_Return_Value :=
                        Approval_List( p_approval_list => p_ECO_rec.approval_list_name
                                     , x_err_text => l_err_text
                                     );

                IF l_Return_Value IS NULL
                THEN
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value := p_ECO_rec.ECO_name;
                        l_token_tbl(1).token_name := 'APPROVAL_LIST_NAME';
                        l_token_tbl(1).token_value := p_ECO_rec.Approval_List_Name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_APPROVAL_LIST_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.approval_list_id := l_Return_Value;
                END IF;
        ELSE
                l_ECO_Unexp_Rec.approval_list_id := NULL;
        END IF;
        --
        -- Convert ECO_Department to Responsible_Org_Id
        --

        IF p_ECO_rec.ECO_Department_Name IS NOT NULL AND
           p_ECO_rec.ECO_Department_name <> FND_API.G_MISS_CHAR
        THEN
                l_Return_Value :=
                        Responsible_Org
                                ( p_responsible_org => p_ECO_rec.ECO_Department_name
                                , p_current_org     => l_ECO_Unexp_Rec.organization_id
                                , x_err_text => l_err_text
                                );

                IF l_Return_Value IS NULL
                THEN
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value := p_ECO_rec.ECO_name;
                        l_token_tbl(1).token_name := 'ECO_DEPARTMENT';
                        l_token_tbl(1).token_value := p_ECO_rec.ECO_Department_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_RESP_ORG_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.responsible_org_id := l_Return_Value;
                END IF;
        ELSE
                l_ECO_Unexp_Rec.responsible_org_id := NULL;
        END IF;

        --  Added for Bug 4402842
        IF p_ECO_rec.employee_number IS NOT NULL AND
           p_ECO_rec.employee_number <> FND_API.G_MISS_CHAR AND
           l_plm_or_erp_change <> 'PLM'
        THEN
            l_Return_Value :=
                    Employee( p_employee_number => p_ECO_rec.employee_number
                            , x_err_text        => l_err_text);
            IF l_Return_Value IS NULL
            THEN
                l_token_tbl(2).token_name := 'ECO_NAME';
                l_token_tbl(2).token_value := p_ECO_rec.ECO_name;
                l_token_tbl(1).token_name := 'EMPLOYEE_NUMBER';
                l_token_tbl(1).token_value := p_ECO_rec.employee_number;

                Error_Handler.Add_Error_Token(
                    p_Message_Name       => 'ENG_EMP_NUMBER_INVALID'
                  , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                  , p_Token_Tbl          => l_Token_Tbl );
                l_Return_Status := FND_API.G_RET_STS_ERROR;

            ELSIF l_Return_Value = FND_API.G_MISS_NUM
            THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                    Error_Handler.Add_Error_Token(
                        p_Message_Text => l_err_text
                      , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl );
                END IF;

                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                RETURN;
            ELSE
                l_ECO_Unexp_Rec.Requestor_id := l_Return_Value;
            END IF;
            --* End of Bug 4402842

        --
        -- Convert Requestor to Requestor_Id
        --
        ELSIF p_ECO_rec.Requestor IS NOT NULL AND
           p_ECO_rec.Requestor <> FND_API.G_MISS_CHAR
        THEN
                l_Return_Value :=
                        Requestor
                                ( p_Requestor => p_ECO_rec.Requestor
                                , p_organization_id => p_ECO_Unexp_rec.organization_id
                                , x_err_text => l_err_text
                                );

                IF l_Return_Value IS NULL
                THEN
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value := p_ECO_rec.ECO_name;
                        l_token_tbl(1).token_name := 'REQUESTOR';
                        l_token_tbl(1).token_value := p_ECO_rec.Requestor;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_REQUESTOR_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.Requestor_id := l_Return_Value;
                END IF;
        ELSE
            l_ECO_Unexp_Rec.Requestor_Id := NULL;
        END IF;

        IF p_ECO_rec.Project_Name IS NOT NULL AND
           p_ECO_rec.Project_Name <> FND_API.G_MISS_CHAR
        THEN
                l_Return_Value :=
                                Project
                                ( p_project_name => p_ECO_rec.project_name
                                , x_err_text => l_err_text
                                );

                IF l_Return_Value IS NULL
                THEN
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value := p_ECO_rec.ECO_name;
                        l_token_tbl(1).token_name := 'PROJECT_NUMBER';
                        l_token_tbl(1).token_value := p_ECO_rec.project_name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_PROJECT_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.project_id := l_Return_Value;
                END IF;
        ELSE
                l_ECO_Unexp_Rec.project_id := NULL;
        END IF;

        IF p_ECO_rec.Task_Number IS NOT NULL AND
           p_ECO_rec.Task_Number <> FND_API.G_MISS_CHAR
        THEN
                l_Return_Value :=
                                Task
                                ( p_task_number => p_ECO_rec.task_number
                                , p_project_id  => l_ECO_Unexp_Rec.project_id
                                , x_err_text    => l_err_text
                                );

                IF l_Return_Value IS NULL
                THEN
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value := p_ECO_rec.ECO_name;
                        l_token_tbl(1).token_name := 'TASK_NUMBER';
                        l_token_tbl(1).token_value := p_ECO_rec.task_number;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_TASK_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.task_id := l_Return_Value;
                END IF;
        ELSE
                l_ECO_Unexp_Rec.task_id := NULL;
        END IF;

        --
        -- Assignee
        -- Convert Assignee to Assignee_Id (Party Id of Group or Person)
        --
        IF p_ECO_rec.Assignee IS NOT NULL AND
           p_ECO_rec.Assignee <> FND_API.G_MISS_CHAR
        THEN
                        l_Return_Value :=
                        Assignee
                                ( p_assignee => p_ECO_rec.Assignee
                                --, p_assignee_company_name => p_ECO_Unexp_rec.Assignee_Company_Name
                                --, p_organization_id => p_ECO_Unexp_rec.organization_id
                                , x_err_text => l_err_text
                                );
                IF l_Return_Value IS NULL
                THEN
                        -- Bug No :3463516
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value := p_ECO_rec.ECO_name;
                        l_token_tbl(1).token_name := 'ASSIGNEE';
                        l_token_tbl(1).token_value := p_ECO_rec.Assignee ;
                        --l_token_tbl(3).token_name := 'COMPANY_NAME';
                        --l_token_tbl(3).token_value := p_ECO_rec.Assignee_Company_Name ;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ASSIGNEE_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );

                        l_token_tbl.DELETE;
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.Assignee_id := l_Return_Value;
                END IF;

        --
        -- User should be able to null out assignee
        -- ELSE
        --   l_ECO_Unexp_Rec.Assignee_id := NULL;

        END IF;


        --
        -- Change_Management_Type
        -- Get the Change Management Type code for the corresponding
        -- change management type
        --
        IF p_ECO_rec.Change_Management_Type IS NOT NULL AND
           p_ECO_rec.Change_Management_Type <> FND_API.G_MISS_CHAR
        THEN

                l_change_mgmt_type_code :=
                Change_Management_Type(  p_change_management_type => p_ECO_rec.Change_Management_Type
                                       , x_err_text               => l_err_text
                                                   );
                IF   l_change_mgmt_type_code IS NULL
                THEN
                        l_token_tbl(1).token_name := 'CHANGE_MANAGEMENT_TYPE';
                        l_token_tbl(1).token_value := p_ECO_rec.Change_Management_Type;

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'ENG_CHG_MGMT_TYPE_INVALID'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , p_token_tbl          => g_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_token_tbl.DELETE;

                        l_return_status := FND_API.G_RET_STS_ERROR;

                ELSIF  l_change_mgmt_type_code = FND_API.G_MISS_CHAR
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.Change_Mgmt_Type_Code := l_Change_Mgmt_Type_Code ;
                END IF;

        ELSE
            l_ECO_Unexp_Rec.Change_Mgmt_Type_Code := NULL;
        END IF;


        IF p_ECO_rec.Status_Name IS NOT NULL AND
           p_ECO_rec.Status_Name <> FND_API.G_MISS_CHAR
        THEN



--                l_status_type :=
                Status_Type(p_status_name => p_ECO_rec.Status_Name
                           ,x_status_code => l_status_code
                           ,x_status_type => l_status_type
                           , x_return_status =>l_return_status
                           ,p_change_order_type_id =>l_ECO_Unexp_Rec.change_order_type_id
                           ,p_plm_or_erp        => p_ECO_rec.plm_or_erp_change  );
                IF l_status_type IS NULL or l_status_code IS NULL
                THEN
                        l_token_tbl(1).token_name := 'STATUS_TYPE';
                        l_token_tbl(1).token_value := p_ECO_rec.Status_Name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'ENG_STATUS_TYPE_INVALID'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , p_token_tbl          => g_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_token_tbl.DELETE;
                        l_return_status := FND_API.G_RET_STS_ERROR;
                ELSE
                        l_ECO_Unexp_Rec.Status_Type := l_status_type ;
                        l_ECO_Unexp_Rec.Status_Code := l_status_code ;
                END IF;

        ELSE
            l_ECO_Unexp_Rec.Status_Type := NULL;
        END IF;


        IF p_ECO_rec.Approval_Status_Name IS NOT NULL AND
           p_ECO_rec.Approval_Status_Name <> FND_API.G_MISS_CHAR
        THEN

                l_approval_status_type :=
                Approval_Status_Type(p_approval_status_name => p_ECO_rec.Approval_Status_Name);

                IF l_approval_status_type IS NULL
                THEN
                        l_token_tbl(1).token_name := 'APPROVAL_STATUS_TYPE';
                        l_token_tbl(1).token_value := p_ECO_rec.Approval_Status_Name;

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'ENG_APPR_STATUS_TYPE_INVALID'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , p_token_tbl          => g_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_token_tbl.DELETE;
                        l_return_status := FND_API.G_RET_STS_ERROR;

                ELSE
                        l_ECO_Unexp_Rec.Approval_Status_Type := l_approval_status_type ;
                END IF;

        ELSE
            l_ECO_Unexp_Rec.Approval_Status_Type := NULL;
        END IF;

        --
        -- Source_Type
        -- Get the Source Type code for the corresponding
        -- source type
        --
        IF p_ECO_rec.Source_Type IS NOT NULL AND
           p_ECO_rec.Source_Type <> FND_API.G_MISS_CHAR
        THEN

                l_source_type_code :=
                Source_Type(  p_source_type  => p_ECO_rec.Source_Type
                            , x_err_text     => l_err_text
                                                   );
                IF   l_source_type_code IS NULL
                THEN
                        l_token_tbl(1).token_name := 'SOURCE_TYPE';
                        l_token_tbl(1).token_value := p_ECO_rec.Source_Type ;

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'ENG_CHG_SRC_TYPE_INVALID'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , p_token_tbl          => g_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_token_tbl.DELETE;

                        l_return_status := FND_API.G_RET_STS_ERROR;

                ELSIF  l_source_type_code = FND_API.G_MISS_CHAR
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.Source_Type_Code := l_source_type_code ;
                END IF;

        ELSE
            l_ECO_Unexp_Rec.Source_Type_Code := NULL;
        END IF;


        --
        -- Source_Name
        -- Get the Source Id for the corresponding
        -- source name and source type code
        IF l_ECO_Unexp_Rec.Source_Type_Code IS NOT NULL AND
           l_ECO_Unexp_Rec.Source_Type_Code <> FND_API.G_MISS_CHAR AND
           p_ECO_rec.Source_Name IS NOT NULL AND
           p_ECO_rec.Source_Name <> FND_API.G_MISS_CHAR
        THEN

                l_Return_Value :=
                Source_Name(  p_source_name      => p_ECO_rec.Source_Name
                            , p_source_type_code => l_ECO_Unexp_Rec.Source_Type_Code
                            , x_err_text         => l_err_text
                           );

                IF   l_Return_Value IS NULL
                THEN
                        l_token_tbl(1).token_name := 'SOURCE_TYPE';
                        l_token_tbl(1).token_value := p_ECO_rec.Source_Type ;
                        l_token_tbl(2).token_name := 'SOURCE_NAME';
                        l_token_tbl(2).token_value := p_ECO_rec.Source_Name ;

                        Error_Handler.Add_Error_Token
                        (  p_message_name       => 'ENG_CHG_SRC_NAME_INVALID'
                         , p_mesg_token_tbl     => l_mesg_token_tbl
                         , p_token_tbl          => g_token_tbl
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );

                        l_token_tbl.DELETE;

                        l_return_status := FND_API.G_RET_STS_ERROR;

                ELSIF  l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.Source_Id := l_Return_Value ;
                END IF;

        ELSE
            l_ECO_Unexp_Rec.Source_Id := NULL;
        END IF;

        -- Start Bug 4967902
        IF p_ECO_rec.Organization_Hierarchy IS NOT NULL AND
           p_ECO_rec.Organization_Hierarchy <> FND_API.G_MISS_CHAR
        THEN
                l_Return_Value :=
                                Hierarchy
                                ( p_organization_hierarchy => p_ECO_rec.Organization_Hierarchy
                                , x_err_text               => l_err_text
                                );
                IF l_Return_Value IS NULL
                THEN
                        l_token_tbl(2).token_name := 'ECO_NAME';
                        l_token_tbl(2).token_value := p_ECO_rec.ECO_name;
                        l_token_tbl(1).token_name := 'ORGANIZATION_HIERARCHY';
                        l_token_tbl(1).token_value := p_ECO_rec.Organization_Hierarchy;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_HIERARCHY_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_ECO_Unexp_Rec := l_ECO_Unexp_Rec;
                        RETURN;

                ELSE
                        l_ECO_Unexp_Rec.hierarchy_id := l_Return_Value;
                END IF;
        ELSE
                l_ECO_Unexp_Rec.hierarchy_id := NULL;
        END IF;
      -- End bug 4967902

        x_return_status  := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_ECO_Unexp_Rec  := l_ECO_Unexp_Rec;

END ECO_Header_VID;

/*****************************************************************************
* Procedure     : ECO_Header_UUI_To_UI
* Parameters IN : ECO Header exposed columns record
*                 ECO Header unexposed columns record
* Parameters OUT: ECO Header unexposed columns record after the conversion
*                 Mesg_Token_Tbl
*                 Return_Status
* Purpose       : This procedure will perform value to id conversion for all
*                 the eco header columns that form the unique key for this
*                 entity.
******************************************************************************/
PROCEDURE ECO_Header_UUI_To_UI
(  p_eco_rec            IN  Eng_Eco_Pub.Eco_Rec_Type
 , p_eco_unexp_rec      IN  Eng_Eco_Pub.Eco_Unexposed_Rec_Type
 , x_eco_unexp_rec      IN OUT NOCOPY Eng_Eco_Pub.Eco_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
)
IS

l_dummy                 VARCHAR2(30); -- Bug 3591992

BEGIN
        x_eco_unexp_rec := p_eco_unexp_rec;

        --
        -- Get the change_id
        -- Added for Bug 3591992
        x_eco_unexp_rec.change_id := Get_Change_Id(p_ECO_rec.eco_name, p_eco_unexp_rec.organization_id, l_dummy);

END ECO_Header_UUI_To_UI;

/*****************************************************************************
* Procedure     : ECO_Revision_UUI_To_UI
* Parameters IN : ECO Revision exposed columns record
*                 ECO Revision unexposed columns record
* Parameters OUT: ECO revision unexposed columns record after the conversion
*                 Mesg_Token_Tbl
*                 Return_Status
* Purpose       : This procedure will perform value to id conversion for all
*                 the ECO revision columns that form the unique key for this
*                 entity.
******************************************************************************/
PROCEDURE ECO_Revision_UUI_To_UI
(  p_eco_revision_rec   IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
 , p_eco_rev_unexp_rec  IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , x_eco_rev_unexp_rec  IN OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
)
IS
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_dummy                 VARCHAR2(30);

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_eco_rev_unexp_rec := p_eco_rev_unexp_rec;

        IF p_eco_revision_rec.revision IS NULL OR
           p_eco_revision_rec.revision = FND_API.G_MISS_CHAR
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REVISION_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );

                x_return_status  := FND_API.G_RET_STS_ERROR;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END IF;

        x_eco_rev_unexp_rec.change_id := Get_Change_Id(p_eco_revision_rec.eco_name, p_eco_rev_unexp_rec.organization_id, l_dummy);

END ECO_Revision_UUI_To_UI;

/*****************************************************************************
* Procedure     : Revised_Item_UUI_To_UI
* Parameters IN : Revised Item exposed columns record
*                 Revised Item unexposed columns record
* Parameters OUT: Revised Item unexposed columns record after the conversion
*                 Mesg_Token_Tbl
*                 Return_Status
* Purpose       : This procedure will perform value to id conversion for all
*                 the revised item columns that form the unique key for this
*                 entity.
******************************************************************************/
PROCEDURE Revised_Item_UUI_To_UI
(  p_revised_item_rec   IN  Eng_Eco_Pub.Revised_Item_Rec_Type
 , p_rev_item_unexp_rec IN  Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_rev_item_unexp_rec IN OUT NOCOPY Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
)
IS
        l_err_text      VARCHAR2(2000);
        l_rev_item_unexp_rec    Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status         VARCHAR2(1);
        l_dummy                 VARCHAR2(30);
BEGIN

        l_rev_item_unexp_rec := p_rev_item_unexp_rec;
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        g_Token_Tbl(1).Token_Value := p_revised_item_rec.revised_item_name;

        /***********************************************************
        --
        -- Verify that the unique key columns are not null or missing
        --
        ************************************************************/
        IF p_revised_item_rec.revised_item_name IS NULL OR
           p_revised_item_rec.revised_item_name = FND_API.G_MISS_CHAR
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RITEM_NAME_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF p_revised_item_rec.start_effective_date IS NULL OR
           p_revised_item_rec.start_Effective_date = FND_API.G_MISS_DATE
        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_RITEM_DATE_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        --
        -- If Key columns are NULL then return
        --
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                x_Return_Status := l_Return_Status;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                RETURN;
        END IF;

        --
        -- User Unique Key for Revised Item is:
        -- ECO Name, Revised Item ID, Start_Effective Date, Item_Revision, Org
        -- Org Code -> ID conversion will happen before this step
        -- Therefore converting revised item name to ID
        --

        l_rev_item_unexp_rec.revised_item_id :=
        Revised_Item(  p_revised_item_num       =>
                                p_revised_item_rec.revised_item_name
                     ,  p_organization_id       =>
                                l_rev_item_unexp_rec.organization_id
                     ,  x_err_text              => l_err_text
                     );

        IF l_rev_item_unexp_rec.revised_item_id IS NULL
        THEN
                g_token_tbl(2).token_name  := 'ORGANIZATION_CODE';
                g_token_tbl(2).token_value :=
                                        p_revised_item_rec.organization_code;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REVISED_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_rev_item_unexp_rec.change_id :=
              Get_Change_Id(p_revised_item_rec.eco_name,
                      l_rev_item_unexp_rec.organization_id,
                      l_dummy);
        IF l_rev_item_unexp_rec.change_id IS NULL
        THEN
                g_token_tbl(2).token_name  := 'CHANGE_NOTICE';
                g_token_tbl(2).token_value :=
                                        p_revised_item_rec.eco_name;
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_REVISED_ITEM_INVALID'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_rev_item_unexp_rec := l_rev_item_unexp_rec;
        x_Return_Status := l_Return_Status;

END Revised_Item_UUI_To_UI;


/*****************************************************************
* Function      : Component_Sequence
* Parameters IN : Revised Component unique index information
* Parameters OUT: Error Text
* Returns       : Component_Sequence_Id
* Purpose       : Function will query the component sequence id using
*                 alternate unique key information. If unsuccessfull
*                 function will return a NULL.
********************************************************************/
FUNCTION Component_Sequence(p_component_item_id IN NUMBER,
                            p_operation_sequence_num IN VARCHAR2,
                            p_effectivity_date       IN DATE,
                            p_bill_sequence_id       IN NUMBER,
                            x_err_text OUT NOCOPY VARCHAR2 )
RETURN NUMBER
IS
                l_id                          NUMBER;
                ret_code                      NUMBER;
                l_err_text                    VARCHAR2(2000);
BEGIN

                select component_sequence_id
                into   l_id
                from   bom_inventory_components
                where  bill_sequence_id = p_bill_sequence_id
                and    component_item_id = p_component_item_id
                and    operation_seq_num = p_operation_sequence_num
                and    effectivity_date = p_effectivity_date;

                RETURN l_id;

EXCEPTION

                WHEN OTHERS THEN
                        RETURN NULL;

END Component_Sequence;


/*************************************************************
* Function      : BillAndRevItemSeq
* Parameters IN : Revised Item Unique Key information
* Parameters OUT: Bill Sequence ID
* Returns       : Revised Item Sequence
* Purpose       : Will use the revised item information to find the bill
*                 sequence and the revised item sequence.
* History       : Added p_new_routing_revsion and
*                 p_from_end_item_number in argument
*
* Moved from BOM_Val_To_Id BOMSVIDB.pls to resolve Eco dependency
* by MK on 12/03/00
******************************************************************/
FUNCTION  BillAndRevItemSeq(  p_revised_item_id         IN  NUMBER
                            , p_alternate_bom_code      IN  VARCHAR2 := NULL       --- Bug 2429272  Change 1
                            , p_item_revision           IN  VARCHAR2
                            , p_effective_date          IN  DATE
                            , p_change_notice           IN  VARCHAR2
                            , p_organization_id         IN  NUMBER
                            , p_new_routing_revision    IN  VARCHAR2 := NULL
                            , p_from_end_item_number    IN  VARCHAR2 := NULL
                            , x_Bill_Sequence_Id        OUT NOCOPY NUMBER
                            , x_lot_number              OUT NOCOPY VARCHAR2
                            , x_from_wip_entity_id      OUT NOCOPY NUMBER
                            , x_to_wip_entity_id        OUT NOCOPY NUMBER
                            , x_from_cum_qty            OUT NOCOPY NUMBER
                            , x_eco_for_production      OUT NOCOPY NUMBER
                            , x_cfm_routing_flag        OUT NOCOPY NUMBER
                            )
RETURN NUMBER
IS
                l_Bill_Seq      NUMBER;
                l_Rev_Item_Seq  NUMBER;
                l_Bill_Seq1     NUMBER := NULL;                               -- Bug 2429272  Change2 Begin

         cursor c1 (rev_item_id eng_revised_items.revised_item_id%TYPE,
                    org_id eng_revised_items.organization_id%TYPE,
                    alt_bom_code bom_bill_of_materials.alternate_bom_designator%TYPE) is
         select bill_sequence_id
         from   bom_bill_of_materials
         where  assembly_item_id = rev_item_id and
                organization_id  = org_id and
                nvl(effectivity_control, 1) <> 4 AND -- Bug 4210718
                nvl(alternate_bom_designator,'NULL') = nvl(alt_bom_code,'NULL');
                                                                              -- Bug 2429272 Change2 End
/* Bug 2429272
User is trying to create a eco (through ECOBO or MCO) for the both
primary bill and alternate bill.  But the calling procedure/function
is calling this procedure only with revised_item_id , organization_id
and change_notice but not using the parameter alternate_bom_designator.
But there are two records(primary and alt with same revised_item_id,
organization and change_notice) exists for this eco in eng_revised_items
. So, querying eng_revised_items only with revised_item_id, org_id and
change_notice will retrieve  two records which is causing the error
*/

BEGIN
                                                                              -- Bug 2429272 Change3 Begin
                open c1(p_revised_item_id, p_organization_id,p_alternate_bom_code);
                fetch c1 into l_bill_seq1;
                if (c1%NOTFOUND) then
                   l_bill_seq1 := NULL;
                end if;

           if (l_bill_seq1 is not null) then
                SELECT bill_sequence_id
                     , revised_item_Sequence_id
                     , lot_number
                     , from_wip_entity_id
                     , to_wip_entity_id
                     , from_cum_qty
                     , NVL(eco_for_production,2)
                     , NVL(cfm_routing_flag,2)
                INTO   l_Bill_Seq
                     , l_Rev_Item_Seq
                     , x_lot_number
                     , x_from_wip_entity_id
                     , x_to_wip_entity_id
                     , x_from_cum_qty
                     , x_eco_for_production
                     , x_cfm_routing_flag
                FROM eng_revised_items
                WHERE NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                          =  NVL(p_from_end_item_number,FND_API.G_MISS_CHAR)
                  AND NVL(new_routing_revision,FND_API.G_MISS_CHAR)
                                          =  NVL(p_new_routing_revision,FND_API.G_MISS_CHAR)
                  AND NVL(new_item_revision, FND_API.G_MISS_CHAR)
                                          =  NVL(p_item_revision ,  FND_API.G_MISS_CHAR)
                  AND scheduled_date      = p_effective_date  --bug 5096309 removed trunc
                  AND change_notice              = p_change_notice
                  AND organization_id            = p_organization_id
                  AND revised_item_id            = p_revised_item_id
                  and bill_sequence_id           = l_bill_seq1;
             else                                                    -- Bug 2429272 Change3 End
                SELECT bill_sequence_id
                     , revised_item_Sequence_id
                     , lot_number
                     , from_wip_entity_id
                     , to_wip_entity_id
                     , from_cum_qty
                     , NVL(eco_for_production,2)
                     , NVL(cfm_routing_flag,2)
                INTO   l_Bill_Seq
                     , l_Rev_Item_Seq
                     , x_lot_number
                     , x_from_wip_entity_id
                     , x_to_wip_entity_id
                     , x_from_cum_qty
                     , x_eco_for_production
                     , x_cfm_routing_flag
                FROM eng_revised_items
                WHERE NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                          =  NVL(p_from_end_item_number,FND_API.G_MISS_CHAR)
                  AND NVL(new_routing_revision,FND_API.G_MISS_CHAR)
                                          =  NVL(p_new_routing_revision,FND_API.G_MISS_CHAR)
                  AND NVL(new_item_revision, FND_API.G_MISS_CHAR)
                                          =  NVL(p_item_revision ,  FND_API.G_MISS_CHAR)
                  AND scheduled_date      = p_effective_date   --bug 5096309 removed trunc
                  AND change_notice              = p_change_notice
                  AND organization_id            = p_organization_id
                  AND revised_item_id            = p_revised_item_id  ;
             end if;                                                -- Bug 2429272


                x_Bill_Sequence_Id := l_Bill_Seq;
                RETURN l_Rev_Item_Seq;

EXCEPTION
    WHEN OTHERS THEN
        x_Bill_Sequence_Id := NULL;
        RETURN NULL;
END BillAndRevItemSeq;




/*************************************************************
* Function      : RtgAndRevItemSeq
* Parameters IN : Revised Item Unique Key information
* Parameters OUT: Routing Sequence ID
* Returns       : Revised Item Sequence
* Purpose       : Will use the revised item information to find the bill
*                 sequence and the revised item sequence.
* History       : Added p_new_routing_revsion and
*                 p_from_end_item_number in argument by MK
*                 on 11/02/00
* Moved from BOM_RTG_Val_To_Id BOMRVIDB.pls to resolve Eco dependency
* by MK on 12/03/00
**************************************************************/
FUNCTION  RtgAndRevItemSeq(  p_revised_item_id         IN  NUMBER
                           , p_item_revision           IN  VARCHAR2
                           , p_effective_date          IN  DATE
                           , p_change_notice           IN  VARCHAR2
                           , p_organization_id         IN  NUMBER
                           , p_new_routing_revision    IN  VARCHAR2
                           , p_from_end_item_number    IN  VARCHAR2 := NULL
                           , p_alternate_routing_code  IN VARCHAR2 := NULL    -- Added for bug 13329115
                           , x_routing_sequence_id     OUT NOCOPY NUMBER
                           , x_lot_number              OUT NOCOPY VARCHAR2
                           , x_from_wip_entity_id      OUT NOCOPY NUMBER
                           , x_to_wip_entity_id        OUT NOCOPY NUMBER
                           , x_from_cum_qty            OUT NOCOPY NUMBER
                           , x_eco_for_production      OUT NOCOPY NUMBER
                           , x_cfm_routing_flag        OUT NOCOPY NUMBER
                           )
RETURN NUMBER
IS
                l_Rev_Item_Seq  NUMBER;



BEGIN
                SELECT routing_sequence_id
                     , revised_item_Sequence_id
                     , lot_number
                     , from_wip_entity_id
                     , to_wip_entity_id
                     , from_cum_qty
                     , NVL(eco_for_production,2)
                     , NVL(cfm_routing_flag,2)
                INTO   x_routing_sequence_id
                     , l_Rev_Item_Seq
                     , x_lot_number
                     , x_from_wip_entity_id
                     , x_to_wip_entity_id
                     , x_from_cum_qty
                     , x_eco_for_production
                     , x_cfm_routing_flag
                FROM eng_revised_items
                WHERE NVL(from_end_item_unit_number, FND_API.G_MISS_CHAR )
                                  = NVL(p_from_end_item_number, FND_API.G_MISS_CHAR)
                  AND NVL(new_routing_revision, FND_API.G_MISS_CHAR) =
                             NVL(p_new_routing_revision, FND_API.G_MISS_CHAR)
                  AND NVL(new_item_revision,FND_API.G_MISS_CHAR)=
                             NVL(p_item_revision,FND_API.G_MISS_CHAR)
                  AND TRUNC(scheduled_date)      = TRUNC(p_effective_date)
                  AND change_notice              = p_change_notice
                  AND organization_id            = p_organization_id
                  AND revised_item_id            = p_revised_item_id
                  AND NVL(alternate_bom_designator, FND_API.G_MISS_CHAR) =
                             NVL(p_alternate_routing_code, FND_API.G_MISS_CHAR);    -- Added for bug 13329115

                RETURN l_Rev_Item_Seq;

EXCEPTION
    WHEN OTHERS THEN
        x_routing_sequence_id := NULL;
        RETURN NULL;
END RtgAndRevItemSeq;



/*****************************************************************************
* Procedure     : BillAndRevitem_UUI_To_UI
* Parameters IN : Revised Item Unique Key information
* Parameters OUT: Revised Item Seq Id and Bill Sequence ID
*                 Mesg_Token_Tbl
*                 Return_Status
* Purpose       : Will use the revised item information to find the bill
*                 sequence and the revised item sequence.
*
* Added by MK on 12/03/00
******************************************************************************/
PROCEDURE BillAndRevitem_UUI_To_UI
(  p_revised_item_name           IN  VARCHAR2
 , p_alternate_bom_code          IN  varchar2 := NULL  -- Bug 2429272
 , p_revised_item_id             IN  NUMBER
 , p_item_revision               IN  VARCHAR2
 , p_effective_date              IN  DATE
 , p_change_notice               IN  VARCHAR2
 , p_organization_id             IN  NUMBER
 , p_new_routing_revision        IN  VARCHAR2 := NULL
 , p_from_end_item_number        IN  VARCHAR2 := NULL
 , p_entity_processed            IN  VARCHAR2 := 'RC'
 , p_component_item_name         IN  VARCHAR2 := NULL
 , p_component_item_id           IN  NUMBER   := NULL
 , p_operation_sequence_number   IN  NUMBER   := NULL
 , p_rfd_sbc_name                IN  VARCHAR2 := NULL
 , p_transaction_type            IN  VARCHAR2 := NULL
 , x_revised_item_sequence_id    OUT NOCOPY NUMBER
 , x_bill_sequence_id            OUT NOCOPY NUMBER
 , x_component_sequence_id       OUT NOCOPY NUMBER
 , x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_other_message               OUT NOCOPY VARCHAR2
 , x_other_token_tbl             OUT NOCOPY Error_Handler.Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
)
IS
        l_lot_number            VARCHAR2(30) ;
        l_from_wip_entity_id    NUMBER ;
        l_to_wip_entity_id      NUMBER ;
        l_from_cum_qty          NUMBER ;
        l_eco_for_production    NUMBER ;
        l_cfm_routing_flag      NUMBER ;

        l_err_text              VARCHAR2(2000);
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status         VARCHAR2(1);
BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;


    x_revised_item_sequence_id :=
    BillAndRevItemSeq(  p_revised_item_id   => p_revised_item_id
                      , p_alternate_bom_code   => p_alternate_bom_code    -- Bug 2429272
                      , p_item_revision     => p_item_revision
                      , p_effective_date    => p_effective_date
                      , p_change_notice     => p_change_notice
                      , p_organization_id   => p_organization_id
                      , p_new_routing_revision => p_new_routing_revision
                      , p_from_end_item_number => p_from_end_item_number
                      , x_Bill_Sequence_Id     => x_Bill_Sequence_Id
                      , x_lot_number           => l_lot_number
                      , x_from_wip_entity_id   => l_from_wip_entity_id
                      , x_to_wip_entity_id     => l_to_wip_entity_id
                      , x_from_cum_qty         => l_from_cum_qty
                      , x_eco_for_production   => l_eco_for_production
                      , x_cfm_routing_flag     => l_cfm_routing_flag
                      );


    IF  x_revised_item_sequence_id IS NULL AND p_entity_processed = 'RC'
    THEN
        g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
        g_Token_Tbl(1).Token_Value := p_component_item_name ;
        g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
        g_Token_Tbl(2).Token_Value := p_revised_item_name;
        g_token_tbl(3).token_name  := 'ECO_NAME';
        g_token_tbl(3).token_value := p_change_notice ;

        Error_Handler.Add_Error_Token
        ( p_Message_Name       => 'BOM_REV_SEQUENCE_NOT_FOUND'
        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        , p_Token_Tbl          => g_Token_Tbl
        );

        l_Return_Status := FND_API.G_RET_STS_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_Return_Status := l_Return_Status;
        x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
        x_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
        x_other_token_tbl(1).token_value :=  p_component_item_name ;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('And this call returned with ' || l_Return_Status); END IF ;

        RETURN;

     ELSIF p_transaction_type IN
           ( BOM_Globals.G_OPR_UPDATE, BOM_globals.G_OPR_DELETE,
             BOM_Globals.G_OPR_CANCEL
            ) AND
           x_bill_sequence_id IS NULL AND p_entity_processed = 'RC'
     THEN
         l_return_status := FND_API.G_RET_STS_ERROR;

         g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
         g_Token_Tbl(1).Token_Value :=  p_revised_item_name;

         Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_BILL_SEQUENCE_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
         x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
         x_Return_Status := l_Return_Status;
         x_other_message := 'BOM_CMP_UUI_SEV_ERROR';
         x_other_token_tbl(1).token_name := 'REVISED_COMPONENT_NAME';
         x_other_token_tbl(1).token_value := p_component_item_name ;

         RETURN;


    ELSIF x_revised_item_sequence_id IS NULL AND p_entity_processed = 'SBC'
    THEN
        g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        g_Token_Tbl(1).Token_Value := p_revised_item_name ;
        g_Token_Tbl(2).Token_Name  := 'SUBSTITUTE_ITEM_NAME';
        g_Token_Tbl(2).Token_Value := p_rfd_sbc_name ;
        g_token_tbl(3).token_name  := 'ECO_NAME';
        g_token_tbl(3).token_value := p_change_notice ;

        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'BOM_SBC_REV_SEQ_NOT_FOUND'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
        );

        l_Return_Status := FND_API.G_RET_STS_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        --
        -- Set the other message and its tokens
        --
        x_other_message := 'BOM_SBC_UUI_SEV_ERROR';
        x_other_token_tbl(1).token_name  := 'SUBSTITUTE_ITEM_NAME';
        x_other_token_tbl(1).token_value := p_rfd_sbc_name ;

        x_Return_Status := l_Return_Status;
        RETURN;

    ELSIF x_revised_item_sequence_id IS NULL AND p_entity_processed = 'RFD'
    THEN

        g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        g_Token_Tbl(1).Token_Value := p_revised_item_name ;
        g_Token_Tbl(2).Token_Name  := 'REFERENCE_DESIGNATOR_NAME';
        g_Token_Tbl(2).Token_Value := p_rfd_sbc_name ;
        g_Token_Tbl(3).Token_Name  := 'ECO_NAME';
        g_Token_Tbl(3).Token_Value := p_change_notice ;

        Error_Handler.Add_Error_Token
        (  p_Message_Name       => 'BOM_RFD_REV_SEQ_NOT_FOUND'
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , p_Token_Tbl          => g_Token_Tbl
        );

        l_Return_Status := FND_API.G_RET_STS_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        --
        -- Set the other message
        --
        x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
        x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
        x_other_token_tbl(1).token_value := p_rfd_sbc_name ;

        x_Return_Status := l_Return_Status;
        RETURN;

    ELSIF x_bill_sequence_id IS NULL and p_entity_processed = 'RFD'
    THEN
        g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
        g_Token_Tbl(1).Token_Value := p_revised_item_name ;
        g_Token_Tbl(2).Token_Name  := 'REFERENCE_DESIGNATOR_NAME';
        g_Token_Tbl(2).Token_Value := p_rfd_sbc_name ;

        Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RFD_BILL_SEQ_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
        l_Return_Status := FND_API.G_RET_STS_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        --
        -- Set the other message
        --
        x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
        x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
        x_other_token_tbl(1).token_value := p_rfd_sbc_name ;

        x_Return_Status := l_Return_Status;
        RETURN;

    END IF;


    IF p_entity_processed IN ( 'SBC' ,  'RFD' )
    THEN
        x_component_sequence_id :=
        Component_Sequence
                          (  p_component_item_id        =>  p_component_item_id
                           , p_operation_sequence_num   =>  p_operation_sequence_number
                           , p_effectivity_date         =>  p_effective_date
                           , p_bill_sequence_id         =>  x_bill_sequence_id
                           , x_err_text                 =>  l_Err_Text
                           );

IF Bom_Globals.get_debug = 'Y' then Error_Handler.write_debug
('Component sequence ' ||  x_component_sequence_id  ) ;
END IF;

        IF x_component_sequence_id IS NULL
        AND  p_entity_processed = 'SBC'
        THEN
                g_Token_Tbl(1).Token_Name  := 'REVISED_COMPONENT_NAME';
                g_Token_Tbl(1).Token_Value := p_component_item_name ;
                g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(2).Token_Value := p_revised_item_name ;
                g_Token_Tbl(3).Token_Name  := 'SUBSTITUTE_ITEM_NAME';
                g_Token_Tbl(3).Token_Value := p_rfd_sbc_name ;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_SBC_COMP_SEQ_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                --
                -- Set the other message and its tokens
                --
                x_other_message := 'BOM_SBC_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'SUBSTITUTE_ITEM_NAME';
                x_other_token_tbl(1).token_value := p_rfd_sbc_name ;

                l_Return_Status := FND_API.G_RET_STS_ERROR;
                g_Token_Tbl.Delete;

        ELSIF x_component_sequence_id IS NULL
        AND   p_entity_processed = 'RFD'
        THEN
                g_Token_Tbl(1).Token_Name  := 'REVISED_ITEM_NAME';
                g_Token_Tbl(1).Token_Value := p_revised_item_name ;
                g_Token_Tbl(2).Token_Name  := 'REFERENCE_DESIGNATOR_NAME';
                g_Token_Tbl(2).Token_Value := p_rfd_sbc_name ;
                g_Token_Tbl(3).Token_Name  := 'REVISED_COMPONENT_NAME';
                g_Token_Tbl(3).Token_Value :=  p_component_item_name ;

                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'BOM_RFD_COMP_SEQ_NOT_FOUND'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , p_Token_Tbl          => g_Token_Tbl
                 );
                --
                -- Set the other message
                --
                x_other_message := 'BOM_RFD_UUI_SEV_ERROR';
                x_other_token_tbl(1).token_name := 'REFERENCE_DESIGNATOR_NAME';
                x_other_token_tbl(1).token_value := p_rfd_sbc_name ;

                l_Return_Status := FND_API.G_RET_STS_ERROR;
                g_Token_Tbl.Delete;
        END IF;

    END IF ;

    -- Set Revised Item Attributes to Global System Information.
    Bom_Globals.Set_Lot_Number(l_lot_number) ;
    Bom_Globals.Set_From_Wip_Entity_Id(l_from_wip_entity_id) ;
    Bom_Globals.Set_To_Wip_Entity_Id(l_to_wip_entity_id) ;
    Bom_Globals.Set_From_Cum_Qty(l_from_cum_qty) ;
    Bom_Globals.Set_Eco_For_Production(l_eco_for_production) ;

    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    x_Return_Status := l_Return_Status;


END BillAndRevitem_UUI_To_UI ;



/*****************************************************************************
* Procedure     : RtgAndRevitem_UUI_UI
* Parameters IN : Revised Item Unique Key information
* Parameters OUT: Revised Item Seq Id and Routing Sequence ID
*                 Mesg_Token_Tbl
*                 Return_Status
* Purpose       : Will use the revised item information to find the bill
*                 sequence and the revised item sequence.
*
* Added by MK on 12/03/00
******************************************************************************/
PROCEDURE RtgAndRevitem_UUI_To_UI
(  p_revised_item_name           IN  VARCHAR2
 , p_revised_item_id             IN  NUMBER
 , p_item_revision               IN  VARCHAR2
 , p_effective_date              IN  DATE
 , p_change_notice               IN  VARCHAR2
 , p_organization_id             IN  NUMBER
 , p_new_routing_revision        IN  VARCHAR2 := NULL
 , p_from_end_item_number        IN  VARCHAR2 := NULL
 , p_entity_processed            IN  VARCHAR2 := 'ROP'
 , p_operation_sequence_number   IN  NUMBER   := NULL
 , p_operation_type              IN  NUMBER   := NULL
 , p_resource_sequence_number    IN  NUMBER   := NULL
 , p_sub_resource_code           IN  VARCHAR2 := NULL
 , p_schedule_sequence_number    IN  NUMBER   := NULL
 , p_transaction_type            IN  VARCHAR2 := NULL
 , p_alternate_routing_code      IN  VARCHAR2 := NULL    -- Added for bug 13329115
 , x_revised_item_sequence_id    OUT NOCOPY NUMBER
 , x_routing_sequence_id         OUT NOCOPY NUMBER
 , x_operation_sequence_id       OUT NOCOPY NUMBER
 , x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_other_message               OUT NOCOPY VARCHAR2
 , x_other_token_tbl             OUT NOCOPY Error_Handler.Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
)
IS
        l_lot_number            VARCHAR2(30) ;
        l_from_wip_entity_id    NUMBER ;
        l_to_wip_entity_id      NUMBER ;
        l_from_cum_qty          NUMBER ;
        l_eco_for_production    NUMBER ;
        l_cfm_routing_flag      NUMBER ;
        l_err_text              VARCHAR2(2000);
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status         VARCHAR2(1);
BEGIN

        l_return_status := FND_API.G_RET_STS_SUCCESS;

        x_revised_item_sequence_id :=
                    RtgAndRevItemSeq
                    (  p_revised_item_id   => p_revised_item_id
                     , p_item_revision     => p_item_revision
                     , p_effective_date    => p_effective_date
                     , p_change_notice     => p_change_notice
                     , p_organization_id   => p_organization_id
                     , p_new_routing_revision  => p_new_routing_revision
                     , p_from_end_item_number  => p_from_end_item_number
                     , p_alternate_routing_code  => p_alternate_routing_code    -- Added for bug 13329115
                     , x_routing_sequence_id  => x_routing_sequence_id
                     , x_lot_number           => l_lot_number
                     , x_from_wip_entity_id   => l_from_wip_entity_id
                     , x_to_wip_entity_id     => l_to_wip_entity_id
                     , x_from_cum_qty         => l_from_cum_qty
                     , x_eco_for_production   => l_eco_for_production
                     , x_cfm_routing_flag     => l_cfm_routing_flag
                    );

         IF x_revised_item_sequence_id IS NULL AND p_entity_processed = 'ROP'
         THEN
             g_Token_Tbl(1).Token_Name  := 'OP_SEQ_NUMBER';
             g_Token_Tbl(1).Token_Value := p_operation_sequence_number;
             g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
             g_Token_Tbl(2).Token_Value := p_revised_item_name;
             g_token_tbl(3).token_name  := 'ECO_NAME';
             g_token_tbl(3).token_value := p_change_notice ;

             Error_Handler.Add_Error_Token
             (  p_Message_Name       => 'BOM_OP_RIT_SEQUENCE_NOT_FOUND'
              , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , p_Token_Tbl          => g_Token_Tbl
             );

             l_Return_Status    := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl   := l_Mesg_Token_Tbl;
             x_Return_Status    := l_Return_Status;


             RETURN;

         ELSIF x_revised_item_sequence_id IS NULL AND p_entity_processed = 'RES'
         THEN

             g_Token_Tbl(1).Token_Name  := 'RES_SEQ_NUMBER';
             g_Token_Tbl(1).Token_Value := p_resource_sequence_number;
             g_Token_Tbl(2).Token_Name  := 'REVISED_ITEM_NAME';
             g_Token_Tbl(2).Token_Value := p_revised_item_name;
             g_token_tbl(3).token_name  := 'ECO_NAME';
             g_token_tbl(3).token_value := p_change_notice ;

             Error_Handler.Add_Error_Token
             (  p_Message_Name       => 'BOM_RES_RIT_SEQUENCE_NOT_FOUND'
              , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , p_Token_Tbl          => g_Token_Tbl
             );

             l_Return_Status  := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
             x_Return_Status  := l_Return_Status;

             RETURN;

         ELSIF x_revised_item_sequence_id IS NULL AND p_entity_processed = 'SR'
         THEN
             g_Token_Tbl(1).token_name  := 'SUB_RESOURCE_CODE';
             g_Token_Tbl(1).token_value := p_sub_resource_code ;
             g_Token_Tbl(2).token_name  := 'SCHEDULE_SEQ_NUMBER';
             g_Token_Tbl(2).token_value := p_schedule_sequence_number ;
             g_Token_Tbl(3).Token_Name  := 'REVISED_ITEM_NAME';
             g_Token_Tbl(3).Token_Value := p_revised_item_name;
             g_token_tbl(4).token_name  := 'ECO_NAME';
             g_token_tbl(4).token_value := p_change_notice ;

             Error_Handler.Add_Error_Token
             (  p_Message_Name       => 'BOM_SUB_RES_RIT_SEQ_NOT_FOUND'
              , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , p_Token_Tbl          => g_Token_Tbl
             );

             l_Return_Status  := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
             x_Return_Status  := l_Return_Status;

             RETURN;

         END IF;

         IF p_entity_processed IN ( 'RES' ,  'SR' )
         THEN

               x_operation_sequence_id :=
                    BOM_RTG_Val_To_Id.Operation_Sequence_id
                           (  p_routing_sequence_id         => x_routing_sequence_id
                            , p_operation_type              => p_operation_type
                            , p_operation_seq_num           => p_operation_sequence_number
                            , p_effectivity_date            => p_effective_date
                            , x_err_text                    => l_err_text
                           );

                IF x_operation_sequence_id  IS NULL AND p_entity_processed = 'RES'
                THEN
                        g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value := p_operation_sequence_number ;
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_RES_OP_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF x_operation_sequence_id  IS NULL AND p_entity_processed = 'SOR'
                THEN
                        g_token_tbl(1).token_name  := 'OP_SEQ_NUMBER';
                        g_token_tbl(1).token_value := p_operation_sequence_number ;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'BOM_SUB_RES_OP_NOT_FOUND'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => g_Token_Tbl
                        );
                       l_Return_Status := FND_API.G_RET_STS_ERROR;
                       RETURN;

                ELSIF l_err_text IS NOT NULL AND
                  (x_operation_sequence_id  IS NULL OR
                   x_operation_sequence_id = FND_API.G_MISS_NUM
                   )
                THEN
                        -- This is an unexpected error.
                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => NULL
                         , p_Message_Text       => l_err_text || ' in ' ||
                                                   G_PKG_NAME
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;
          END IF ;

          -- Set Revised Item Attributes to Global System Information.
          Bom_Rtg_Globals.Set_Lot_Number(l_lot_number) ;
          Bom_Rtg_Globals.Set_From_Wip_Entity_Id(l_from_wip_entity_id) ;
          Bom_Rtg_Globals.Set_To_Wip_Entity_Id(l_to_wip_entity_id) ;
          Bom_Rtg_Globals.Set_From_Cum_Qty(l_from_cum_qty) ;
          Bom_Rtg_Globals.Set_Eco_For_Production(l_eco_for_production) ;
          Bom_Rtg_Globals.Set_Routing_Sequence_Id(x_routing_sequence_id) ;


          x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
          x_Return_Status := l_Return_Status;

END RtgAndRevitem_UUI_To_UI ;

PROCEDURE Change_Line_UUI_To_UI
(  p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_change_line_unexp_rec IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status         OUT NOCOPY VARCHAR2
)
IS

        l_err_text              VARCHAR2(2000);
        l_change_line_unexp_rec Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type ;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status         VARCHAR2(1);
BEGIN

        l_change_line_unexp_rec := p_change_line_unexp_rec;
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        g_Token_Tbl(1).Token_Name  := 'LINE_NAME';
        g_Token_Tbl(1).Token_Value := p_change_line_rec.name;

        /***********************************************************
        --
        -- Verify that the unique key columns are not null or missing
        --
        ************************************************************/
        IF (p_change_line_rec.name IS NULL OR
           p_change_line_rec.name = FND_API.G_MISS_CHAR)

        THEN
                Error_Handler.Add_Error_Token
                (  p_Message_Name       => 'ENG_CL_NAME_KEYCOL_NULL'
                 , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                 );
                 l_Return_Status := FND_API.G_RET_STS_ERROR;
        END IF;

        --
        -- If Key columns are NULL then return
        --
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                x_Return_Status := l_Return_Status;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                RETURN;
        END IF;

        --
        -- User Unique Key for Change Line is:
        -- ECO Name, Line Name, Org
        -- Org Code -> ID conversion will happen before this step
        -- No need to convert to Line Name to Id in this step
        --
        g_Token_Tbl.Delete ;

        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_change_line_unexp_rec := l_change_line_unexp_rec;
        x_Return_Status := l_Return_Status;


END Change_Line_UUI_To_UI ;


PROCEDURE Change_Line_VID
(  p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_change_line_unexp_rec IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status         OUT NOCOPY VARCHAR2
)
IS

l_err_text                      VARCHAR2(2000) := NULL;
l_Return_Status                 VARCHAR2(1);
l_Mesg_Token_Tbl                Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl                     Error_Handler.Token_Tbl_Type;
l_change_mgmt_type_code         VARCHAR2(30);
l_hdr_change_mgmt_type_code     VARCHAR2(30);
l_change_line_unexp_rec         Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type ;
l_dynamic_sql                   VARCHAR2(4000);
l_dynamic_cursor                INTEGER;
l_dummy                         INTEGER;

l_query_object_name             VARCHAR2(30);
l_query_column1_name            VARCHAR2(30);
l_query_column2_name            VARCHAR2(30);
l_query_column3_name            VARCHAR2(30);
l_query_column4_name            VARCHAR2(30);
l_query_column5_name            VARCHAR2(30);
l_query_column1_type            VARCHAR2(8);
l_query_column2_type            VARCHAR2(8);
l_query_column3_type            VARCHAR2(8);
l_query_column4_type            VARCHAR2(8);
l_query_column5_type            VARCHAR2(8);
l_fk1_column_name               VARCHAR2(30);
l_fk2_column_name               VARCHAR2(30);
l_fk3_column_name               VARCHAR2(30);
l_fk4_column_name               VARCHAR2(30);
l_fk5_column_name               VARCHAR2(30);
l_pk1_name                      VARCHAR2(240);
l_pk2_name                      VARCHAR2(240);
l_pk3_name                      VARCHAR2(240);
l_pk4_name                      VARCHAR2(240);
l_pk5_name                      VARCHAR2(240);
l_where_clause_empty            BOOLEAN;

l_change_type_id                NUMBER ;
l_disable_date                  DATE ;
l_item_id                       NUMBER ;
l_item_revision_id              NUMBER ;
l_return_value                  NUMBER;
 --Bug 2848506
l_display_name                  VARCHAR2(240);
l_error_text                    VARCHAR2(240);
l_org_id                        NUMBER;
l_rev_id                        NUMBER;
l_inv_item_id                   NUMBER;



BEGIN
        l_Return_Status := FND_API.G_RET_STS_SUCCESS;
        x_Return_Status := FND_API.G_RET_STS_SUCCESS;
        l_display_name  :=p_change_line_rec.object_display_name;
        l_change_line_unexp_rec := p_change_line_unexp_rec ;
        l_token_tbl(1).token_name := 'LINE_NAME';
        l_token_tbl(1).token_value := p_change_line_rec.name;

        l_change_line_unexp_rec.organization_id := Organization(p_change_line_rec.organization_code, l_err_text);

        l_change_line_unexp_rec.change_id :=
              Get_Change_Id(p_change_notice => p_change_line_rec.eco_name,
                            p_org_id => l_change_line_unexp_rec.organization_id,
                            x_change_mgmt_type_code => l_hdr_change_mgmt_type_code
                           );

        IF p_change_line_rec.change_management_type IS NOT NULL AND
          p_change_line_rec.change_management_type <> FND_API.G_MISS_CHAR
        THEN
          Change_Mgmt_Type
          (
            p_change_mgmt_type_name => p_change_line_rec.change_management_type
          , x_change_mgmt_type_code => l_change_mgmt_type_code
          , x_err_text => l_err_text
          );

          IF l_change_mgmt_type_code IS NULL
                OR l_change_mgmt_type_code <> l_hdr_change_mgmt_type_code
          THEN
            l_token_tbl(2).token_name := 'CHANGE_MGMT_TYPE_NAME';
            l_token_tbl(2).token_value := p_change_line_rec.change_management_type;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              Error_Handler.Add_Error_Token
              (
                p_Message_Name  => 'ENG_CHANGE_MGMT_TYPE_INVALID'
              , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
              , p_Token_Tbl      => l_Token_Tbl
              );
            END IF;

            x_Return_Status := FND_API.G_RET_STS_ERROR;
            x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
          END IF;

          --Bug No: 3463472
          --Issue: DEF-1694
          --Desctiption: Removed the _LINE coming after the change code.
          --l_change_mgmt_type_code := l_change_mgmt_type_code || '_LINE';
        END IF;


        -- Convert change_type_code to change_type_id
        IF p_change_line_rec.change_type_code IS NOT NULL AND
           p_change_line_rec.change_type_code <> FND_API.G_MISS_CHAR
        THEN
                --Bug No: 3463472
                --Issue: DEF-1694
                --Calling procedure Change_Order_Line_Type
                --Change_Order_Type
                Change_Order_Line_Type
                        ( p_change_order_type => p_change_line_rec.change_type_code
                        , p_change_mgmt_type  => l_change_mgmt_type_code
                        , x_err_text          => l_err_text
                        , x_change_order_id   => l_change_type_id
                        , x_disable_date      => l_disable_date
                        , x_object_id         => l_change_line_unexp_rec.object_id
                        );

                IF l_change_type_id IS NULL
                THEN
                        l_token_tbl(2).token_name := 'CHANGE_TYPE_CODE';
                        l_token_tbl(2).token_value := p_change_line_rec.change_type_code;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                ( p_Message_Name  => 'ENG_CL_CHANGE_TYPE_INVALID'
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_Token_Tbl      => l_Token_Tbl
                                );
                        END IF;

                        l_Return_Status := FND_API.G_RET_STS_ERROR;
                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

                ELSIF l_change_type_id = FND_API.G_MISS_NUM
                THEN
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                ( p_Message_Text => l_err_text
                                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                ELSE
                        l_change_line_unexp_rec.change_type_id := l_change_type_id;
                END IF;

        END IF;

        -- Change order type must not be disabled

        IF   l_change_line_unexp_rec.change_type_id IS NOT NULL
        AND  l_disable_date < SYSDATE
        THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                        l_token_tbl(2).token_name := 'CHANGE_TYPE_CODE';
                        l_token_tbl(2).token_value := p_change_line_rec.change_type_code ;

                        Error_Handler.Add_Error_Token
                        ( p_Message_Name  => 'ENG_CL_CHANGE_TYPE_DISABLED'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , p_Token_Tbl      => l_Token_Tbl
                        );
                END IF;
                l_Return_Status := FND_API.G_RET_STS_ERROR;
                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        END IF;
/* Not required any more as subjects have moved to eng_change_subjects
        IF p_change_line_rec.sequence_number = -1
        THEN
           l_change_line_unexp_rec.change_type_id :=
                 Get_Type_From_Header(p_change_notice => p_change_line_rec.eco_name,
                                      p_org_id => l_change_line_unexp_rec.organization_id
                                     );
--Bug 2848506

        END IF;
         if  l_display_name is null then
            l_display_name:=Get_object_name(l_change_line_unexp_rec.object_id);
         end if;


--   IF (p_change_line_rec.change_type_code IS NOT NULL)
--    THEN
      IF (l_display_name =
             bom_globals.retrieve_message ('ENG', 'ENG_SUBJECT_ITEM_REVISION')
         )
      THEN
         --For Item Revision PK1_NAME,PK3_NAME,PK4_NAME Columns are mandatory
         IF (    p_change_line_rec.pk1_name IS NOT NULL
             AND p_change_line_rec.pk3_name IS NOT NULL
             AND p_change_line_rec.pk4_name IS NOT NULL
            )
         THEN
            l_org_id := ORGANIZATION (p_change_line_rec.pk4_name, l_err_text);

            IF (l_org_id IS NOT NULL AND l_org_id <> fnd_api.g_miss_num)
            THEN
               l_inv_item_id := revised_item (
                                   p_change_line_rec.pk3_name,
                                   l_org_id,
                                   l_err_text
                                );

               IF (    l_inv_item_id IS NOT NULL
                   AND l_inv_item_id <> fnd_api.g_miss_num
                  )
               THEN
                  l_rev_id := revised_item_code (
                                 l_inv_item_id,
                                 l_org_id,
                                 p_change_line_rec.pk1_name
                              );

                  IF (l_rev_id IS NOT NULL AND l_rev_id <> fnd_api.g_miss_num)
                  THEN
                     l_return_status := 'S'; --fnd_api.g_ret_sts_error;
                  ELSE
                     l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
                     l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
                     error_handler.add_error_token (
                        p_message_name=> 'ENG_PK1_NAME_INVALID',
                        p_mesg_token_tbl=> l_mesg_token_tbl,
                        x_mesg_token_tbl=> l_mesg_token_tbl,
                        p_token_tbl=> l_token_tbl
                     );
                     l_return_status := fnd_api.g_ret_sts_error;
                  END IF; --end of l_rev_id IS NOT NULL
               ELSE
                  l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
                  l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
                  error_handler.add_error_token (
                     p_message_name=> 'ENG_PK3_NAME_INVALID',
                     p_mesg_token_tbl=> l_mesg_token_tbl,
                     x_mesg_token_tbl=> l_mesg_token_tbl,
                     p_token_tbl=> l_token_tbl
                  );
                  l_return_status := fnd_api.g_ret_sts_error;
               END IF; -- l_inv_item_id IS NOT NULL
            ELSE
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
               error_handler.add_error_token (
                  p_message_name=> 'ENG_PK4_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := fnd_api.g_ret_sts_error;
            END IF; --l_org_id IS NOT NULL
         ELSE
            IF (   p_change_line_rec.pk1_name IS NULL
                OR p_change_line_rec.pk1_name = fnd_api.g_miss_char
               )
            THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
               error_handler.add_error_token (
                  p_message_name=> 'ENG_PK1_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := fnd_api.g_ret_sts_error;
            END IF;

            IF (   p_change_line_rec.pk3_name IS NULL
                OR p_change_line_rec.pk3_name = fnd_api.g_miss_char
               )
            THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
               error_handler.add_error_token (
                  p_message_name=> 'ENG_PK3_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := fnd_api.g_ret_sts_error;
            END IF;

            IF (   p_change_line_rec.pk4_name IS NULL
                OR p_change_line_rec.pk4_name = fnd_api.g_miss_char
               )
            THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
               error_handler.add_error_token (
                  p_message_name=> 'ENG_PK4_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF; --p_change_line_rec.Pk1_Name
      ELSIF (l_display_name =
                       bom_globals.retrieve_message ('ENG', 'ENG_SUBJECT_ITEM')
            )
      THEN
         --For Item  PK1_NAME,PK3_NAME Columns are mandatory
         IF (    p_change_line_rec.pk1_name IS NOT NULL
             AND p_change_line_rec.pk3_name IS NOT NULL
            )
         THEN
            l_org_id := ORGANIZATION (p_change_line_rec.pk3_name, l_err_text);

            IF (l_org_id IS NOT NULL AND l_org_id <> fnd_api.g_miss_num)
            THEN
               l_rev_id := revised_item (
                              p_change_line_rec.pk1_name,
                              l_org_id,
                              l_err_text
                           );

               IF (l_rev_id IS NOT NULL AND l_rev_id <> fnd_api.g_miss_num)
               THEN
                  l_return_status := 'S';
               ELSE
                  l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
                  l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
                  error_handler.add_error_token (
                     p_message_name=> 'ENG_PK1_NAME_INVALID',
                     p_mesg_token_tbl=> l_mesg_token_tbl,
                     x_mesg_token_tbl=> l_mesg_token_tbl,
                     p_token_tbl=> l_token_tbl
                  );
                  l_return_status := fnd_api.g_ret_sts_error;
               END IF; --l_rev_id IS NOT NULL
            ELSE
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
               error_handler.add_error_token (
                  p_message_name=> 'ENG_PK3_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := fnd_api.g_ret_sts_error;
            END IF; --l_org_id IS NOT NULL
         ELSE
            IF (   p_change_line_rec.pk1_name IS NULL
                OR p_change_line_rec.pk1_name = fnd_api.g_miss_char
               )
            THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
               error_handler.add_error_token (
                  p_message_name=> 'ENG_PK1_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := fnd_api.g_ret_sts_error;
            END IF;

            IF (   p_change_line_rec.pk3_name IS NULL
                OR p_change_line_rec.pk3_name = fnd_api.g_miss_char
               )
            THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value :=
                                           p_change_line_rec.change_type_code;
               error_handler.add_error_token (
                  p_message_name=> 'ENG_PK3_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := fnd_api.g_ret_sts_error;
            END IF;
         END IF; --p_change_line_rec.Pk1_Name
      END IF; --End Of If of check for l_display_name
--     END IF; --End of IF (p_change_line_rec.change_type_code is not null )


     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_change_line_unexp_rec := l_change_line_unexp_rec;
        x_Return_Status := l_Return_Status;
        RETURN;
      END IF;

--End Of Bug 2848506
*/

        IF p_change_line_rec.status_name IS NOT NULL AND
           p_change_line_rec.status_name <> FND_API.G_MISS_CHAR
        THEN
           l_change_line_unexp_rec.status_code := Line_Status(p_change_line_rec.status_name);
        END IF;


        IF p_change_line_rec.Assignee_Name IS NOT NULL AND
           p_change_line_rec.Assignee_Name <> FND_API.G_MISS_CHAR
        THEN
                l_Return_Value :=
                        Assignee
                                ( p_assignee => p_change_line_rec.Assignee_Name
                                , x_err_text => l_err_text
                                );


                IF l_Return_Value IS NULL
                THEN
                        l_token_tbl(2).token_name := 'ASSIGNEE';
                        l_token_tbl(2).token_value := p_change_line_rec.Assignee_Name;

                        Error_Handler.Add_Error_Token
                        (  p_Message_Name       => 'ENG_ASSIGNEE_INVALID'
                         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                         , p_Token_Tbl          => l_Token_Tbl
                         );

                        l_token_tbl.DELETE;
                        l_Return_Status := FND_API.G_RET_STS_ERROR;

                ELSIF l_Return_Value = FND_API.G_MISS_NUM
                THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                Error_Handler.Add_Error_Token
                                        ( p_Message_Text => l_err_text
                                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                        );
                        END IF;

                        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
                        x_Change_Line_Unexp_Rec := l_Change_Line_Unexp_Rec;
                        RETURN;

                ELSE
                        l_change_line_unexp_rec.Assignee_id := l_Return_Value;
                END IF;

        --
        -- User should be able to null out assignee
        -- ELSE
        --   l_ECO_Unexp_Rec.Assignee_id := NULL;



        END IF;
/* not required for 11.5.10
        -- Subject Validation
        Object_Name(p_display_name => l_display_name     --p_change_line_rec.object_display_name --Bug 2848506
                   ,x_object_name => l_change_line_unexp_rec.object_name
                   ,x_query_object_name => l_query_object_name
                   ,x_query_column1_name => l_query_column1_name
                   ,x_query_column2_name => l_query_column2_name
                   ,x_query_column3_name => l_query_column3_name
                   ,x_query_column4_name => l_query_column4_name
                   ,x_query_column5_name => l_query_column5_name
                   ,x_query_column1_type => l_query_column1_type
                   ,x_query_column2_type => l_query_column2_type
                   ,x_query_column3_type => l_query_column3_type
                   ,x_query_column4_type => l_query_column4_type
                   ,x_query_column5_type => l_query_column5_type
                   ,x_fk1_column_name => l_fk1_column_name
                   ,x_fk2_column_name => l_fk2_column_name
                   ,x_fk3_column_name => l_fk3_column_name
                   ,x_fk4_column_name => l_fk4_column_name
                   ,x_fk5_column_name => l_fk5_column_name
                   ,x_object_id       => l_change_line_unexp_rec.object_id  --Bug 2848506
                   );


       IF l_change_line_unexp_rec.object_name IS NOT NULL
          and
          --Bug 2848506 ,for 'None' line types no validations is required
          l_change_line_unexp_rec.object_name <> 'ENG_CHANGE_MISC'

        THEN
           -- prepare dynamic sql to validate subject instance
           Preprocess_Key(p_object_name => l_change_line_unexp_rec.object_name
                         ,p_change_line_rec => p_change_line_rec
                         ,x_pk1_name => l_pk1_name
                         ,x_pk2_name => l_pk2_name
                         ,x_pk3_name => l_pk3_name
                         ,x_pk4_name => l_pk4_name
                         ,x_pk5_name => l_pk5_name
                         );


           l_dynamic_sql := 'SELECT ';
           l_dynamic_sql := l_dynamic_sql || l_fk1_column_name;
           IF l_fk2_column_name IS NOT NULL THEN
              l_dynamic_sql := l_dynamic_sql || ', ' || l_fk2_column_name;
           END IF;
           IF l_fk3_column_name IS NOT NULL THEN
              l_dynamic_sql := l_dynamic_sql || ', ' || l_fk3_column_name;
           END IF;
           IF l_fk4_column_name IS NOT NULL THEN
              l_dynamic_sql := l_dynamic_sql || ', ' || l_fk4_column_name;
           END IF;
           IF l_fk5_column_name IS NOT NULL THEN
              l_dynamic_sql := l_dynamic_sql || ', ' || l_fk5_column_name;
           END IF;
           l_dynamic_sql := l_dynamic_sql || ' FROM ' || l_query_object_name;
           l_dynamic_sql := l_dynamic_sql || ' WHERE ';
           l_where_clause_empty := TRUE;

           IF l_pk1_name IS NOT NULL THEN
              l_where_clause_empty := FALSE;
              l_dynamic_sql := l_dynamic_sql || l_query_column1_name || ' = :pk1';
           END IF;
          IF l_pk2_name IS NOT NULL THEN
              IF NOT l_where_clause_empty THEN
                 l_dynamic_sql := l_dynamic_sql || ' AND ';
              END IF;
              l_where_clause_empty := FALSE;
              l_dynamic_sql := l_dynamic_sql || l_query_column2_name || ' = :pk2';
           END IF;
           IF l_pk3_name IS NOT NULL THEN
              IF NOT l_where_clause_empty THEN
                 l_dynamic_sql := l_dynamic_sql || ' AND ';
              END IF;
              l_where_clause_empty := FALSE;
              l_dynamic_sql := l_dynamic_sql || l_query_column3_name || ' = :pk3';
           END IF;
           IF l_pk4_name IS NOT NULL THEN
              IF NOT l_where_clause_empty THEN
                 l_dynamic_sql := l_dynamic_sql || ' AND ';
              END IF;
              l_where_clause_empty := FALSE;
              l_dynamic_sql := l_dynamic_sql || l_query_column4_name || ' = :pk4';
           END IF;
           IF l_pk5_name IS NOT NULL THEN
              IF NOT l_where_clause_empty THEN
                 l_dynamic_sql := l_dynamic_sql || ' AND ';
              END IF;
              l_where_clause_empty := FALSE;
              l_dynamic_sql := l_dynamic_sql || l_query_column5_name || ' = :pk5';
           END IF;

           l_dynamic_cursor := dbms_sql.open_cursor;
           dbms_sql.parse(l_dynamic_cursor, l_dynamic_sql, dbms_sql.native);
           IF l_pk1_name IS NOT NULL THEN
              dbms_sql.bind_variable(l_dynamic_cursor, ':pk1', l_pk1_name);
           END IF;
           IF l_pk2_name IS NOT NULL THEN
              dbms_sql.bind_variable(l_dynamic_cursor, ':pk2', l_pk2_name);
           END IF;
           IF l_pk3_name IS NOT NULL THEN
              dbms_sql.bind_variable(l_dynamic_cursor, ':pk3', l_pk3_name);
           END IF;
           IF l_pk4_name IS NOT NULL THEN
              dbms_sql.bind_variable(l_dynamic_cursor, ':pk4', l_pk4_name);
           END IF;
           IF l_pk5_name IS NOT NULL THEN
              dbms_sql.bind_variable(l_dynamic_cursor, ':pk5', l_pk5_name);
           END IF;

           IF l_fk1_column_name IS NOT NULL THEN
              dbms_sql.define_column(l_dynamic_cursor, 1, l_change_line_unexp_rec.pk1_value, 100);
           END IF;
           IF l_fk2_column_name IS NOT NULL THEN
              dbms_sql.define_column(l_dynamic_cursor, 2, l_change_line_unexp_rec.pk2_value, 100);
           END IF;
           IF l_fk3_column_name IS NOT NULL THEN
              dbms_sql.define_column(l_dynamic_cursor, 3, l_change_line_unexp_rec.pk3_value, 100);
           END IF;
           IF l_fk4_column_name IS NOT NULL THEN
              dbms_sql.define_column(l_dynamic_cursor, 4, l_change_line_unexp_rec.pk4_value, 100);
           END IF;
           IF l_fk5_column_name IS NOT NULL THEN
              dbms_sql.define_column(l_dynamic_cursor, 5, l_change_line_unexp_rec.pk5_value, 100);
           END IF;

           l_dummy := dbms_sql.execute(l_dynamic_cursor);

           IF dbms_sql.fetch_rows(l_dynamic_cursor) > 0 THEN
              IF l_fk1_column_name IS NOT NULL THEN
                 dbms_sql.column_value(l_dynamic_cursor, 1, l_change_line_unexp_rec.pk1_value);
              END IF;
              IF l_fk2_column_name IS NOT NULL THEN
                 dbms_sql.column_value(l_dynamic_cursor, 2, l_change_line_unexp_rec.pk2_value);
              END IF;
              IF l_fk3_column_name IS NOT NULL THEN
                 dbms_sql.column_value(l_dynamic_cursor, 3, l_change_line_unexp_rec.pk3_value);
              END IF;
              IF l_fk4_column_name IS NOT NULL THEN
                 dbms_sql.column_value(l_dynamic_cursor, 4, l_change_line_unexp_rec.pk4_value);
              END IF;
              IF l_fk5_column_name IS NOT NULL THEN
                 dbms_sql.column_value(l_dynamic_cursor, 5, l_change_line_unexp_rec.pk5_value);
              END IF;
           END IF;

           dbms_sql.close_cursor(l_dynamic_cursor);


          IF l_change_line_unexp_rec.pk1_value IS NULL THEN
             l_token_tbl(2).token_name := 'PK_VALUES';
             l_token_tbl(2).token_value := p_change_line_rec.pk1_name ;

             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                Error_Handler.Add_Error_Token
                ( p_Message_Name  => 'ENG_PK_VALUES_INVALID'
                , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                , p_Token_Tbl      => l_Token_Tbl
                );
             END IF;

             x_Return_Status := FND_API.G_RET_STS_ERROR;
             x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

             l_token_tbl.DELETE ;
             l_token_tbl(1).token_name := 'LINE_NAME';
             l_token_tbl(1).token_value := p_change_line_rec.name;
          END IF;
        END IF;
*/
        IF  l_return_status <> FND_API.G_RET_STS_SUCCESS
            AND x_return_status <> FND_API.G_RET_STS_UNEXP_ERROR
        THEN
            x_Return_Status := l_return_status ;
        END IF;

        x_change_line_unexp_rec := l_change_line_unexp_rec ;
END Change_Line_VID ;


END ENG_Val_To_Id;

/
