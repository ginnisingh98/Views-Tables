--------------------------------------------------------
--  DDL for Package Body EGO_ODI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ODI_PUB" as
/* $Header: EGOODIXB.pls 120.1.12010000.54 2009/11/30 12:52:39 nendrapu noship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : EGOODIXB.pls                                               |
| DESCRIPTION  : This file is a packaged procedure for the PLM exploders.   |
|                                                                           |
|                                                                           |
+==========================================================================*/



function Validate_Item(p_session_id    IN  NUMBER,
                        p_odi_session_id IN NUMBER,
                        p_index in number,
                        p_inv_id in VARCHAR2,
                        p_org_id in NUMBER,
                        p_segment1 in varchar2 DEFAULT NULL,
                        p_segment2 in varchar2 DEFAULT NULL,
                        p_segment3 in varchar2 DEFAULT NULL,
                        p_segment4 in varchar2 DEFAULT NULL,
                        p_segment5 in varchar2 DEFAULT NULL,
                        p_segment6 in varchar2 DEFAULT NULL,
                        p_segment7 in varchar2 DEFAULT NULL,
                        p_segment8 in varchar2 DEFAULT NULL,
                        p_segment9 in varchar2 DEFAULT NULL,
                        p_segment10 in varchar2 DEFAULT NULL,
                        p_segment11 in varchar2 DEFAULT NULL,
                        p_segment12 in varchar2 DEFAULT NULL,
                        p_segment13 in varchar2 DEFAULT NULL,
                        p_segment14 in varchar2 DEFAULT NULL,
                        p_segment15 in varchar2 DEFAULT NULL,
                        p_segment16 in varchar2 DEFAULT NULL,
                        p_segment17 in varchar2 DEFAULT NULL,
                        p_segment18 in varchar2 DEFAULT NULL,
                        p_segment19 in varchar2 DEFAULT NULL,
                        p_segment20 in varchar2 DEFAULT NULL,
                        x_inv_item_id OUT NOCOPY number
                        )  RETURN BOOLEAN
is

l_inv_item_id NUMBER;
l_segment1 VARCHAR2(40);
l_segment2 VARCHAR2(40);
l_segment3 VARCHAR2(40);
l_segment4 VARCHAR2(40);
l_segment5 VARCHAR2(40);
l_segment6 VARCHAR2(40);
l_segment7 VARCHAR2(40);
l_segment8 VARCHAR2(40);
l_segment9 VARCHAR2(40);
l_segment10 VARCHAR2(40);
l_segment11 VARCHAR2(40);
l_segment12 VARCHAR2(40);
l_segment13 VARCHAR2(40);
l_segment14 VARCHAR2(40);
l_segment15 VARCHAR2(40);
l_segment16 VARCHAR2(40);
l_segment17 VARCHAR2(40);
l_segment18 VARCHAR2(40);
l_segment19 VARCHAR2(40);
l_segment20 VARCHAR2(40);

BEGIN

 IF p_org_id IS NULL THEN
     RETURN FALSE;
 END IF;

 IF p_inv_id IS NULL and p_segment1 IS NULL THEN
    RETURN FALSE;
 END IF;

  IF p_inv_id ='?' and p_segment1 ='?' THEN
    RETURN FALSE;
 END IF;

 IF p_inv_id = '?' THEN
    l_inv_item_id := NULL;
 ELSE
    l_inv_item_id := p_inv_id;
  END IF;


l_segment1 := p_segment1;
l_segment2 := p_segment2;
l_segment3 := p_segment3;
l_segment4 := p_segment4;
l_segment5 := p_segment5;
l_segment6 := p_segment6;
l_segment7 := p_segment7;
l_segment8 := p_segment8;
l_segment9 := p_segment9;
l_segment10 := p_segment10;
l_segment11 := p_segment11;
l_segment12 := p_segment12;
l_segment13 := p_segment13;
l_segment14 := p_segment14;
l_segment15 := p_segment15;
l_segment16 := p_segment16;
l_segment17 := p_segment17;
l_segment18 := p_segment18;
l_segment19 := p_segment19;
l_segment20 := p_segment20;

IF l_segment1 = '?' THEN l_segment1 := NULL; END IF;
IF l_segment2 = '?' THEN l_segment2 := NULL; END IF;
IF l_segment3 = '?' THEN l_segment3 := NULL; END IF;
IF l_segment4 = '?' THEN l_segment4 := NULL; END IF;
IF l_segment5 = '?' THEN l_segment5 := NULL; END IF;
IF l_segment6 = '?' THEN l_segment6 := NULL; END IF;
IF l_segment7 = '?' THEN l_segment7 := NULL; END IF;
IF l_segment8 = '?' THEN l_segment8 := NULL; END IF;
IF l_segment9 = '?' THEN l_segment9 := NULL; END IF;
IF l_segment10 = '?' THEN l_segment10 := NULL; END IF;
IF l_segment11 = '?' THEN l_segment11 := NULL; END IF;
IF l_segment12 = '?' THEN l_segment12 := NULL; END IF;
IF l_segment13 = '?' THEN l_segment13 := NULL; END IF;
IF l_segment14 = '?' THEN l_segment14 := NULL; END IF;
IF l_segment15 = '?' THEN l_segment15 := NULL; END IF;
IF l_segment16 = '?' THEN l_segment16 := NULL; END IF;
IF l_segment17 = '?' THEN l_segment17 := NULL; END IF;
IF l_segment18 = '?' THEN l_segment18 := NULL; END IF;
IF l_segment19 = '?' THEN l_segment19 := NULL; END IF;
IF l_segment20 = '?' THEN l_segment20 := NULL; END IF;

  --dbms_output.put_line( ' Inside  Validate_Item ');
  IF (l_inv_item_id IS NOT NULL)  THEN

   select inventory_item_id
   INTO  x_inv_item_id
   from mtl_system_items_kfv
   WHERE organization_id = p_org_id
   AND  inventory_item_id = to_number(l_inv_item_id);

   EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'InventoryItemId',
                             p_param_value => l_inv_item_id );

  ELSE

    --dbms_output.put_line('for segments ');
    select inventory_item_id
    INTO  x_inv_item_id
    from mtl_system_items_kfv
    WHERE organization_id = p_org_id
    AND  Nvl(segment1, 0) = Nvl(l_segment1, 0)
    AND  Nvl(segment2, 0) = Nvl(l_segment2, 0)
    AND  Nvl(segment3, 0) = Nvl(l_segment3, 0)
    AND  Nvl(segment4, 0) = Nvl(l_segment4, 0)
    AND  Nvl(segment5, 0) = Nvl(l_segment5, 0)
    AND  Nvl(segment6, 0) = Nvl(l_segment6, 0)
    AND  Nvl(segment7, 0) = Nvl(l_segment7, 0)
    AND  Nvl(segment8, 0) = Nvl(l_segment8, 0)
    AND  Nvl(segment9, 0) = Nvl(l_segment9, 0)
    AND  Nvl(segment10, 0) = Nvl(l_segment10, 0)
    AND  Nvl(segment11, 0) = Nvl(l_segment11, 0)
    AND  Nvl(segment12, 0) = Nvl(l_segment12, 0)
    AND  Nvl(segment13, 0) = Nvl(l_segment13, 0)
    AND  Nvl(segment14, 0) = Nvl(l_segment14, 0)
    AND  Nvl(segment15, 0) = Nvl(l_segment15, 0)
    AND  Nvl(segment16, 0) = Nvl(l_segment16, 0)
    AND  Nvl(segment17, 0) = Nvl(l_segment17, 0)
    AND  Nvl(segment18, 0) = Nvl(l_segment18, 0)
    AND  Nvl(segment19, 0) = Nvl(l_segment19, 0)
    AND  Nvl(segment20, 0) = Nvl(l_segment20, 0);

    EGO_ITEM_WS_PVT.POPULATE_SEGMENTS(p_session_id ,
                    p_odi_session_id ,
                    p_segment1 ,
                    p_segment2 ,
                    p_segment3 ,
                    p_segment4 ,
                    p_segment5 ,
                    p_segment6 ,
                    p_segment7 ,
                    p_segment8 ,
                    p_segment9 ,
                    p_segment10 ,
                    p_segment11 ,
                    p_segment12 ,
                    p_segment13 ,
                    p_segment14 ,
                    p_segment15 ,
                    p_segment16 ,
                    p_segment17 ,
                    p_segment18 ,
                    p_segment19 ,
                    p_segment20 ,
                    p_index );

  END IF;

  RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN
  --dbms_output.put_line(' Error : Invalid Item ');
  --raise_application_error(-20101, 'Invalid Organization Id or Organization Name');

   IF (l_inv_item_id IS NOT NULL)  THEN

     EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_ITEM_ID',
                      p_err_message => 'Invalid Inventory Item Id');

  ELSE

     EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_ITEM_NAME',
                      p_err_message => 'Invalid Inventory Item Name');
  END IF;

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  RETURN FALSE;

END Validate_Item;



function Validate_Organization(p_session_id    IN  NUMBER,
                               p_odi_session_id IN NUMBER,
                               p_index in number,
                               p_org_id in VARCHAR2 DEFAULT NULL,
                               p_org_code IN VARCHAR2 DEFAULT NULL,
                               x_organization_id OUT NOCOPY number
                               )  RETURN BOOLEAN
is

l_org_id NUMBER;

BEGIN
  --dbms_output.put_line('Inside Validate_organization');

  IF p_org_id IS NULL and p_org_code IS NULL THEN
    RETURN FALSE;
  END IF;

  IF p_org_id = '?' and p_org_code = '?' THEN
    RETURN FALSE;
  END IF;

  IF p_org_id = '?' THEN
    l_org_id := NULL;
  ELSE
    l_org_id := to_number(p_org_id);
  END IF;

  IF (l_org_id IS NOT NULL)  THEN

    --dbms_output.put_line(' with org id :'||p_org_id );
    select organization_id
    INTO x_organization_id
    from mtl_parameters
    WHERE organization_id = to_number(l_org_id);

    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'OrganizationId',
                             p_param_value => l_org_id);

  ELSE

    --dbms_output.put_line(' with org code p_org_code: '|| p_org_code);
    select organization_id
    INTO x_organization_id
    from mtl_parameters
    WHERE organization_code = p_org_code;

    EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'OrganizationCode',
                             p_param_value => p_org_code );


  END IF;

  RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN
  --dbms_output.put_line(' Error : Invalid Organization Details ');
  --raise_application_error(-20101, 'Invalid Organization Id');
 IF (l_org_id IS NOT NULL)  THEN

    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_ORG_ID',
                      p_err_message => 'Invalid Organization Id');
  ELSE

    EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                      p_odi_session_id => p_odi_session_id,
                      p_input_id  => p_index,
                      p_err_code => 'EGO_INVALID_ORG_CODE',
                      p_err_message => 'Invalid Organization Code');

  END IF;

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  RETURN FALSE;

END Validate_Organization;


/*
Validates the provided attribute group id or name and returns TRUE if they are
valid. If the id is provided, the name is derived and returned in x_ag_name.
To validate the attribute group name, the attribute p_ag_id must be null.
*/
function Validate_Attribute_Group(p_session_id NUMBER,
                                  p_odi_session_id IN NUMBER,
                                  p_ag_id in VARCHAR2,
                                  p_ag_name IN VARCHAR2,
                                  x_ag_name OUT NOCOPY VARCHAR2
                                  )  RETURN BOOLEAN
is

l_index NUMBER;
l_ag_id VARCHAR2(150);
l_ag_name VARCHAR2(150);

BEGIN

  l_ag_id := p_ag_id;
  l_ag_name := p_ag_name;

  IF p_ag_id = '?'  THEN
      l_ag_id := NULL;
  END IF;

  IF p_ag_name = '?' THEN
     l_ag_name := NULL;
  END IF;

  IF l_ag_id IS NULL AND l_ag_name IS NULL THEN
      RETURN FALSE;
  END IF;

  --dbms_output.put_line('Inside Validate_organization');
  IF (l_ag_id IS NOT NULL)  THEN

    --dbms_output.put_line(' with ag id :'||p_ag_id );
    SELECT ATTR_GROUP_NAME
    into x_ag_name
    FROM ego_attr_groups_v
    WHERE ATTR_GROUP_ID = to_number(l_ag_id);

  ELSE

    --dbms_output.put_line(' with org code p_org_code: '|| p_org_code);
    SELECT ATTR_GROUP_NAME
    INTO x_ag_name
    FROM ego_attr_groups_v
    WHERE ATTR_GROUP_NAME = l_ag_name;

  END IF;

  RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN

  --dbms_output.put_line(' Error : Invalid Organization Details ');

   SELECT Nvl(Max(INPUT_ID),0) + 1 into l_index
   FROM EGO_PUB_WS_INPUT_IDENTIFIERS
   WHERE session_id =  p_session_id;

 IF (l_ag_id IS NOT NULL)  THEN

   EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => l_index,
                             p_param_name  => 'AttributeGroupId',
                             p_param_value => l_ag_id
                             );

   EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => l_index,
                          p_err_code => 'EGO_INVALID_AG_ID',
                          p_err_message => 'Invalid Attribute Group Id');

 ELSE

   EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => l_index,
                             p_param_name  => 'AttributeGroupName',
                             p_param_value => l_ag_name
                             );

   EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => l_index,
                          p_err_code => 'EGO_INVALID_AG_NAME',
                          p_err_message => 'Invalid Attribute Group Name');

 END IF;

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'Handling exception at Config_UDA: ' );
       */
  RETURN FALSE;

END Validate_Attribute_Group;


--validates if the provided structure name exists
--for primary structures, the name passes should be 'Primary'. After
--execution, the name 'Primary' will be converted to NULL so the bom
--explosion code can correctly retrieve the primary BOM
function Validate_Structure_Name(p_session_id    IN  NUMBER,
                                 p_odi_session_id IN NUMBER,
                                 p_str_name IN OUT NOCOPY VARCHAR2,
                                 p_org_id IN NUMBER) RETURN BOOLEAN
is

l_tmp_str_name VARCHAR2(100);
l_error_str_name VARCHAR2(100);
p_index NUMBER;

BEGIN

 /*INSERT INTO emt_temp (Session_id, message)
                 values (4293, 'new inside l_str_name:' || p_str_name);
          */

  l_tmp_str_name := p_str_name;
  l_error_str_name := p_str_name;

  IF  l_tmp_str_name IS NULL THEN
      RETURN FALSE;
  END IF;

  IF upper(l_tmp_str_name) = 'PRIMARY'  OR l_tmp_str_name = '?' THEN
      p_str_name := NULL;
      l_tmp_str_name := p_str_name;
      RETURN TRUE;
  END IF;


  select  ALTERNATE_DESIGNATOR_CODE
  into p_str_name
  from  bom_alternate_designators
  WHERE organization_id = p_org_id
  AND  ALTERNATE_DESIGNATOR_CODE = l_tmp_str_name;

  RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN

  --dbms_output.put_line(' Error : Invalid Revision Details ');

  SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
  WHERE session_id =  p_session_id;

  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_index,
                             p_param_name  => 'StructureName',
                             p_param_value => l_error_str_name
                             );

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => p_index,
                          p_err_code => 'EGO_INVALID_STRUCTURE',
                          p_err_message => 'Invalid Structure Name and Org Combination');

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  RETURN FALSE;

END Validate_Structure_Name;


--validates if the provided structure name exists for a given item.
function Validate_Item_Structure_Name(p_session_id IN  NUMBER,
                                      p_odi_session_id IN NUMBER,
                                      p_str_name IN VARCHAR2,
                                      p_item_id IN NUMBER,
                                      p_org_id IN NUMBER,
                                      p_input_index IN NUMBER) RETURN BOOLEAN
is

l_tmp_str_name VARCHAR2(100);
l_error_str_name VARCHAR2(100);
--p_index NUMBER;

BEGIN

 /*INSERT INTO emt_temp (Session_id, message)
                 values (4293, 'new inside l_str_name:' || p_str_name);
          */

  l_tmp_str_name := p_str_name;
  l_error_str_name := p_str_name;

  IF  l_tmp_str_name IS NULL THEN
      RETURN FALSE;
  END IF;

  IF upper(l_tmp_str_name) = 'PRIMARY'  OR l_tmp_str_name = '?' THEN
      l_tmp_str_name := NULL;
  END IF;

  IF l_tmp_str_name IS NOT NULL THEN

    select alternate_bom_designator
    into l_tmp_str_name
    from bom_structures_b
    where assembly_item_id  = p_item_id
    and organization_id = p_org_id
    and alternate_bom_designator = l_tmp_str_name;

  ELSE

    select alternate_bom_designator
    into l_tmp_str_name
    from bom_structures_b
    where assembly_item_id  = p_item_id
    and organization_id = p_org_id
    and alternate_bom_designator IS NULL;

  END IF;

  RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN

  --dbms_output.put_line(' Error : Invalid Revision Details ');

  /*SELECT Nvl(Max(INPUT_ID),0) + 1 into p_index
  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
  WHERE session_id =  p_session_id;*/

  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => p_input_index,
                             p_param_name  => 'StructureName',
                             p_param_value => l_error_str_name
                             );

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => p_input_index,
                          p_err_code => 'EGO_INVALID_STRUCTURE',
                          p_err_message => 'Invalid Structure Name for a given Item');

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  RETURN FALSE;

END Validate_Item_Structure_Name;



--validates if the provided security group name exists
function Validate_Security_Group(p_session_id    IN  NUMBER,
                                 p_odi_session_id IN NUMBER,
                                 p_sec_grp_name IN VARCHAR2,
                                 x_sec_grp_id OUT NOCOPY NUMBER) RETURN BOOLEAN
is

l_index NUMBER;

BEGIN

  IF p_sec_grp_name IS NULL OR p_sec_grp_name = '?' THEN
      x_sec_grp_id := NULL;
      RETURN FALSE;
  END IF;

  --retrieving security group id from security group name
  select security_group_id
  into x_sec_grp_id
  from FND_SECURITY_GROUPS
  where security_group_key = p_sec_grp_name;

RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN
  --dbms_output.put_line(' Error : Invalid Revision Details ');

 SELECT Nvl(Max(INPUT_ID),0) + 1 into l_index
  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
  WHERE session_id =  p_session_id;

  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => l_index,
                             p_param_name  => 'SecurityGroup',
                             p_param_value => p_sec_grp_name
                             );

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => l_index,
                          p_err_code => 'EGO_INVALID_SECURITY_GROUP',
                          p_err_message => 'Invalid Security Group');

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  RETURN FALSE;

END Validate_Security_Group;


--validates if the provided responsibility application name exists
function Validate_Resp_Appl_Name(p_session_id    IN  NUMBER,
                                 p_odi_session_id IN NUMBER,
                                 p_resp_appl_name IN VARCHAR2,
                                 x_resp_appl_id OUT NOCOPY NUMBER) RETURN BOOLEAN
is

l_index NUMBER;

BEGIN

  IF p_resp_appl_name IS NULL OR p_resp_appl_name = '?' THEN
      x_resp_appl_id := NULL;
      RETURN FALSE;
  END IF;

  --retrieving application id from application name
  select application_id
  into x_resp_appl_id
  from FND_APPLICATION
  where application_short_name = p_resp_appl_name;

RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN
  --dbms_output.put_line(' Error : Invalid Revision Details ');

  SELECT Nvl(Max(INPUT_ID),0) + 1 into l_index
  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
  WHERE session_id =  p_session_id;

  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => l_index,
                             p_param_name  => 'ResponsibilityApplicationName',
                             p_param_value => p_resp_appl_name
                             );

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => l_index,
                          p_err_code => 'EGO_INVALID_RESP_APPL_NAME',
                          p_err_message => 'Invalid Responsibility Application Name');

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  RETURN FALSE;

END Validate_Resp_Appl_Name;


--validates if the provided responsibility name exists
function Validate_Resp_Name(p_session_id    IN  NUMBER,
                            p_odi_session_id IN NUMBER,
                            p_resp_name IN VARCHAR2,
                            x_resp_id OUT NOCOPY NUMBER) RETURN BOOLEAN
is

l_index NUMBER;

BEGIN

  IF p_resp_name IS NULL OR p_resp_name = '?' THEN
      x_resp_id := NULL;
      RETURN FALSE;
  END IF;

  --retrieving responsibility id from responsibility name
  Select responsibility_id
  into x_resp_id
  from FND_RESPONSIBILITY
  where responsibility_key = p_resp_name;

RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN
  --dbms_output.put_line(' Error : Invalid Revision Details ');

  SELECT Nvl(Max(INPUT_ID),0) + 1 into l_index
  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
  WHERE session_id =  p_session_id;

  EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => l_index,
                             p_param_name  => 'ResponsibilityName',
                             p_param_value => p_resp_name
                             );

  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => l_index,
                          p_err_code => 'EGO_INVALID_RESP_NAME',
                          p_err_message => 'Invalid Responsibility Name');

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  RETURN FALSE;

END Validate_Resp_Name;


function Validate_Language_Info(p_session_id    IN  NUMBER,
                                p_odi_session_id IN NUMBER,
                                p_language_code IN OUT NOCOPY VARCHAR2,
                                p_language_name VARCHAR2 DEFAULT NULL) RETURN BOOLEAN
is

l_temp VARCHAR(100);
l_index NUMBER;

BEGIN

  --dbms_output.put_line('Inside Validate_Language_Info');
  IF p_language_code IS NULL AND p_language_name IS NULL THEN
    RETURN FALSE;
  END IF;

  IF p_language_code ='?' AND p_language_name ='?' THEN
    RETURN FALSE;
  END IF;


  l_temp := p_language_code;

  IF l_temp = '?' THEN
     l_temp:= NULL;
  END IF;

  IF l_temp IS NOT NULL THEN
      select language_code
      into p_language_code
      from fnd_languages where language_code = l_temp;
  ELSE
      select language_code
      into p_language_code
      from fnd_languages where nls_language = upper(p_language_name);
  END IF;

  RETURN TRUE;

EXCEPTION
WHEN No_Data_Found THEN
  --dbms_output.put_line(' Error : Invalid Language Code ');

  SELECT Nvl(Max(INPUT_ID),0) + 1 into l_index
  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
  WHERE session_id =  p_session_id;


  IF l_temp IS NOT NULL THEN

      EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => l_index,
                             p_param_name  => 'LanguageCode',
                             p_param_value => l_temp
                             );

      EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => l_index,
                          p_err_code => 'EGO_INVALID_LANGUAGE_CODE',
                          p_err_message => 'Invalid Language Code');

  ELSE

      EGO_ODI_PUB.Populate_Input_Identifier(p_session_id => p_session_id,
                             p_odi_session_id => p_odi_session_id,
                             p_input_id  => l_index,
                             p_param_name  => 'LanguageName',
                             p_param_value => p_language_name
                             );

      EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_input_id  => l_index,
                          p_err_code => 'EGO_INVALID_LANGUAGE_NAME',
                          p_err_message => 'Invalid Language Name');


  END IF;

  RETURN FALSE;
  -- error OUT NOCOPY
WHEN OTHERS THEN
  --dbms_output.put_line(' Error : '|| SQLERRM);
  RETURN FALSE;

END Validate_Language_Info;


--Inserts the list of parameters contained in raw XML pointed by XPATH
--expression into table EGO_PUB_WS_CONFIG
PROCEDURE Insert_ODI_Parameter_List(p_session_id IN NUMBER,
                                    p_xml_node_xpath VARCHAR2,
                                    p_parameter_name VARCHAR2,
                                    p_web_service_name VARCHAR2 DEFAULT NULL)
                                   IS

 l_node_name VARCHAR2(100);
 l_pos NUMBER;

 --
 -- Query to retrieve the list of values for a given xml node of type list
 --
 --Cursor to recover list of node values
  CURSOR c_xml_node_value_list(p_session_id NUMBER,
                               xml_node_path VARCHAR2,
                               xml_node_name VARCHAR2)
                               IS
         select extractValue(val, xml_node_name) value
         from
             (select value(tags) val
              from EGO_PUB_WS_PARAMS i,
              table(XMLSequence(
              extract(i.xmlcontent, xml_node_path))) tags
              where session_id = p_session_id);


BEGIN

    l_pos := instr(p_xml_node_xpath, '/', -1);
    --Dbms_Output.put_line('p_search_str: ' || p_search_str);
    --Dbms_Output.put_line('xml_node_name pos: ' || l_pos);
    l_node_name :=  substr(p_xml_node_xpath, l_pos+1, length(p_xml_node_xpath) - l_pos);
    --Dbms_Output.put_line('xml_node_name: ' || l_node_name);

    --looping throgh all values and insert them in table
    FOR r in c_xml_node_value_list(p_session_id,
                                   p_xml_node_xpath,
                                   l_node_name) LOOP

        INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_session_id,
                               p_parameter_name,
                               2,
                               r.value,
                               sysdate,
                               0,
                               p_web_service_name);

    END LOOP;


END Insert_ODI_Parameter_List;



--Function that returns the specified ODI input parameter from table
--EGO_PUB_WS_PARAMS using the session_id.
--INPUT:
--p_session_id: unique identifier of input XML stored in table EGO_PUB_WS_PARAMS
--p_search_str: x_path expression pointing to parameter to be recovered
--              (e.g. '/structureQueryParameters/PublishEntities/StructureRevision')
--OUTPUT:
--parameter value in VARCHAR or NULL if parameter specified does not exist
FUNCTION Get_ODI_Input_Parameter(p_session_id IN NUMBER, p_search_str IN VARCHAR2) RETURN VARCHAR2 IS

x_value VARCHAR2(100);

BEGIN



select extractValue(xmlcontent, p_search_str)
into x_value
from EGO_PUB_WS_PARAMS
where session_id = p_session_id;

--check for parameter value not available condition generated by
--some web services when parameter value is not specified.
IF x_value = '?' THEN
   x_value := NULL;
END IF;

RETURN x_value;

END Get_ODI_Input_Parameter;



--Function that returns the specified ODI input parameters from table
--EGO_PUB_WS_PARAMS using the session_id as a comma separated list.
--INPUT:
--p_session_id: unique identifier of input XML stored in table EGO_PUB_WS_PARAMS
--p_search_str: x_path expression pointing to parameter to be recovered. The parameter
--              to be recovered (xml node) must be of type list
--              (e.g. '/structureQueryParameters/ListOfLanguageInformation/LanguageCode')
/*
FUNCTION Get_ODI_Input_Parameter_list(p_session_id IN NUMBER, p_search_str IN VARCHAR2)
RETURN VARCHAR2 IS

 x_value VARCHAR2(4000);
 l_node_name VARCHAR2(100);
 l_pos NUMBER;

 --
 -- Query to retrieve the list of values for a given xml node of type list
 --
 --Cursor to recover list of node values
  CURSOR c_xml_node_value_list(p_session_id NUMBER,
                               xml_node_path VARCHAR2,
                               xml_node_name VARCHAR2)
                               IS
         select extractValue(val, xml_node_name) value
         from
             (select value(tags) val
              from EGO_PUB_WS_PARAMS i,
              table(XMLSequence(
              extract(i.xmlcontent, xml_node_path))) tags
              where session_id = p_session_id);

BEGIN

    --x_value := '';

    l_pos := instr(p_search_str, '/', -1);
    --Dbms_Output.put_line('p_search_str: ' || p_search_str);
    --Dbms_Output.put_line('xml_node_name pos: ' || l_pos);
    l_node_name :=  substr(p_search_str, l_pos+1, length(p_search_str) - l_pos);
    --Dbms_Output.put_line('xml_node_name: ' || l_node_name);

    --looping throgh all values to create comma separated list
    FOR r in c_xml_node_value_list(p_session_id,
                                   p_search_str,
                                   l_node_name) LOOP

        IF x_value IS NULL THEN
         x_value := r.value;
        ELSE
          x_value := x_value || ',' || r.value;
        END IF;

    END LOOP;

    RETURN x_value;

END Get_ODI_Input_Parameter_list;
*/



--initializes the FND security context depending on the invokation mode.
--Depending on the invokation mode (e.g. BATCH, LIST, and HMDM), the
--credentials for initializing the security must be found in different places.
PROCEDURE Init_Security_Structure(p_session_id IN NUMBER,
                                  p_odi_session_id IN NUMBER)
IS

l_mode VARCHAR2(100);
l_application_id NUMBER;
l_responsibility_id NUMBER;
l_user_id NUMBER;
l_security_group_id NUMBER;
l_batch_id NUMBER;
l_user_name VARCHAR2(100);
l_responsibility_name VARCHAR2(100);
l_responsibility_appl_name VARCHAR2(100);
l_security_group_name VARCHAR2(100);
l_is_valid BOOLEAN;


BEGIN

 --retrieving invokation mode
 select char_value
 into l_mode
 from EGO_PUB_WS_CONFIG
 where parameter_name = 'MODE'
 and web_service_name = 'GET_ITEM_STRUCTURE'
 and session_id  = p_session_id;



     --if mode is batch, get security related information from publication
     --framework using batch_id. The FND_SECURITY is enabled using the
     --login credentials of the person who created the batch
     --IF l_mode = 'BATCH' THEN

        /*--retrieving batchId from input XML
        select to_number(extractValue(xmlcontent, '/structureQueryParameters/BatchStructureQueryParameters/BatchId'))
        into l_batch_id
        from EGO_PUB_WS_PARAMS
        where session_id = p_session_id;

        --retrieving user_id and responsibility
        select created_by, responsibility_id
        into l_user_id,l_responsibility_id
        from EGO_PUB_BAT_HDR_B
        where batch_id = l_batch_id;

        --retrieving responsibility_id
        Select application_id
        into l_application_id
        from FND_RESPONSIBILITY
        where responsibility_id = l_responsibility_id;
        */


     --END IF;

     --If mode is LIST or BATCH, we initialize the FND security using the
     --credentials provided by the party calling the web service.
     --IF l_mode = 'LIST' OR  l_mode = 'HMDM' THEN

        --raise_application_error(-20000, 'security information unavailable for LIST mode');

          --reading fnd user name
         select char_value
         into l_user_name
         from EGO_PUB_WS_CONFIG
         where session_id = p_session_id
         and web_service_name = 'GET_ITEM_STRUCTURE'
         and parameter_name = 'FND_USER_NAME';

         --retrieving user id from user name
         select user_id
         into l_user_id
         from fnd_user
         where user_name = l_user_name;

         --reading responsibility name
         select char_value
         into l_responsibility_name
         from EGO_PUB_WS_CONFIG
         where session_id = p_session_id
         and web_service_name = 'GET_ITEM_STRUCTURE'
         and parameter_name = 'RESPONSIBILITY_NAME';

         --validating responsibility name
         l_is_valid := Validate_Resp_Name(p_session_id => p_session_id,
                                          p_odi_session_id => p_odi_session_id,
                                          p_resp_name => l_responsibility_name,
                                          x_resp_id => l_responsibility_id);
         --IF l_is_valid = FALSE THEN
            --TODO: Handle properly
          --  raise_application_error(-20000, 'Invalid Responsibility Name');
         --END IF;

         --reading responsibility application name
         select char_value
         into l_responsibility_appl_name
         from EGO_PUB_WS_CONFIG
         where session_id = p_session_id
         and web_service_name = 'GET_ITEM_STRUCTURE'
         and parameter_name = 'RESPONSIBILITY_APPL_NAME';

         --validating responsibility application name
         l_is_valid := Validate_Resp_Appl_Name(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_resp_appl_name => l_responsibility_appl_name,
                                                x_resp_appl_id => l_application_id);
         --IF l_is_valid = FALSE THEN
            --TODO: Handle properly
         --   raise_application_error(-20000, 'Invalid Responsibility Application Name');
         --END IF;

         --reading security group name
         select char_value
         into l_security_group_name
         from EGO_PUB_WS_CONFIG
         where session_id = p_session_id
         and web_service_name = 'GET_ITEM_STRUCTURE'
         and parameter_name = 'SECURITY_GROUP_NAME';

         --validating security group
         l_is_valid := Validate_Security_Group(p_session_id => p_session_id,
                                               p_odi_session_id => p_odi_session_id,
                                               p_sec_grp_name => l_security_group_name,
                                               x_sec_grp_id => l_security_group_id);
         --IF l_is_valid = FALSE THEN
            --TODO: Raise error if provided security group is not valid
            --NULL;
            --raise_application_error(-20000, 'security information unavailable for LIST mode');
         --END IF;



     -- END IF;

    --remove, debugging purposes only
    /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'FND_SEC Userid: ' || l_user_id);
    --remove, debugging purposes only
    INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'FND_SEC respid: ' || l_responsibility_id);
    --remove, debugging purposes only
    INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'FND_SEC appid: ' || l_application_id);
    */


   --Initializing security context
   FND_GLOBAL.APPS_INITIALIZE(
      USER_ID=>l_user_id,
      RESP_ID=>l_responsibility_id,
      RESP_APPL_ID=>l_application_id
   );

   --FND_GLOBAL.Apps_Initialize(user_id => 1006535, resp_id => 24089, resp_appl_id => 431);
   --Dbms_Output.put_line('FND_GLOBAL.User_Id: ' || FND_GLOBAL.User_Id);
   --Dbms_Output.put_line('FND_GLOBAL.Login_Id: ' || FND_GLOBAL.Login_Id);

END Init_Security_Structure;


--Checks the specified security priviledge on items stored in table BOM_ODI_WS_ENTITIES.
--If an item (row) is found not to have the privilege, the PUBLISH_FLAG columns is set to 'N'
--so the end-item data is not published by ODI interfaces.
PROCEDURE check_end_item_security(p_session_id IN  NUMBER,
                                  p_odi_session_id IN NUMBER,
                                  p_priv_check IN  VARCHAR2,
                                  p_for_exploded_items IN VARCHAR2,
                                  x_return_status OUT NOCOPY  VARCHAR2
                                 )
  IS

  l_sec_predicate VARCHAR2(32767);
  l_dynamic_update_sql VARCHAR2(32767);
  l_dynamic_sql VARCHAR2(32767);
  l_item_id NUMBER;
  l_org_id NUMBER;
  l_rev_id NUMBER;

  l_mode VARCHAR2(10);
  l_batch_id NUMBER;
  l_batch_ent_obj_id NUMBER;
  l_user_name VARCHAR2(100);
  l_structure_name  VARCHAR2(100);
  p_index number;
  l_seq_number NUMBER;


  TYPE DYNAMIC_CUR IS REF CURSOR;
  v_dynamic_cursor         DYNAMIC_CUR;

BEGIN

  dbms_output.put_line(' Starting of check_security ');

    --delete, for debugging only
    /*INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' Starting of Check_security ');*/


   --obtaining security predicate based on FND_SECURITY initialization
   dbms_output.put_line(' calling EGO_DATA_SECURITY.get_security_predicat ');
   EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => p_priv_check
       ,p_object_name      => 'EGO_ITEM'
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(FND_GLOBAL.PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'i.ITEM_ID'
       ,p_pk2_alias        => 'i.ITEM_ORG_ID'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );

       dbms_output.put_line( ' Before If T, F : x_return_status - '|| x_return_status);

       --remove
       /*INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' x_return_status: ' || x_return_status);
       INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' l_sec_predicate: ' || l_sec_predicate);

        */

    IF x_return_status IN ('T','F')  THEN

      IF l_sec_predicate IS NOT NULL THEN

        BEGIN

          --selecting all end-items that do not have the publish privilege from table
          --BOM_ODI_WS_ENTITIES
          l_dynamic_sql := ' select ITEM_ID, ITEM_ORG_ID, ITEM_REV, SEQUENCE_NUMBER ' ||
                         ' from BOM_ODI_WS_ENTITIES i ' ||
                         ' where i.session_id = :1 ' ||
                         ' AND NOT ' || l_sec_predicate;

       --remove
       /*INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' l_dynamic_sql: ' || l_dynamic_sql);
*/
          --Looping throught all items with no publish privilege to generate the error
          --messages
          OPEN v_dynamic_cursor FOR l_dynamic_sql
          USING  p_session_id;
          LOOP

            FETCH  v_dynamic_cursor INTO l_item_id , l_org_id, l_rev_id, l_seq_number;
            EXIT WHEN v_dynamic_cursor%NOTFOUND;

              dbms_output.put_line(' In the loop Insering ... ');
              dbms_output.put_line(' No Publiush priv for l_item_id :' || l_item_id);

             --remove
             /*INSERT INTO emt_temp (Session_id, message)
             values (p_session_id, ' No publish privilege for item: ' || l_item_id);*/


              EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                              p_odi_session_id => p_odi_session_id,
                              p_input_id  => l_seq_number,
                              p_err_code => 'EGO_NO_PUBLISH_PRIV',
                              p_err_message => 'User does not have the publish privilege for item');

          END LOOP;

            CLOSE v_dynamic_cursor;
            x_return_status := 'S';
            --dbms_output.put_line(' Doing Commit ');
            --COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('When others of check security Error :'|| SQLERRM);
          ROLLBACK;
          x_return_status := 'E';
          RAISE;

          IF (v_dynamic_cursor%ISOPEN) THEN
            CLOSE v_dynamic_cursor;
          END IF;
        END; -- end of BEGIN


        --Now that the error messages have been generated,
        --set the flag PUBLISH_FLAG to 'N' in table table BOM_ODI_WS_ENTITIES
        --for end-items with no publish privilege to prevent their publication.
        /*l_dynamic_update_sql := ' delete from BOM_ODI_WS_ENTITIES i ' ||
                                ' where i.session_id = :1 ' ||
                                ' AND NOT ' || l_sec_predicate;*/

        l_dynamic_update_sql := ' update BOM_ODI_WS_ENTITIES i ' ||
                                ' set PUBLISH_FLAG = ''N'' ' ||
                                ' where i.session_id = :1 ' ||
                                ' AND nvl(i.PUBLISH_FLAG, ''Y'') = ''Y'' ' ||
                                ' AND NOT ' || l_sec_predicate;


        dbms_output.put_line(' Executing the l_dynamic_update_sql');
        EXECUTE IMMEDIATE l_dynamic_update_sql
        USING IN p_session_id;

      ELSE
         x_return_status := 'S';
      END IF;  -- end of l_sec_predicate IS NOT NULL

    END IF;

  END check_end_item_security;


/*
PROCEDURE generate_component_error(p_session_id IN  NUMBER)
  IS
  BEGIN

       --selecting end-item for a given component based on group_id
            --
            -- For exploded items give error message wrt to its structure.
            -- So, the following query retreives the end-items for the component
            FOR i IN (SELECT item_id, item_org_id, item_rev FROM BOM_ODI_WS_ENTITIES
                        where group_id = l_group_id and session_id = p_session_id)

                       --(SELECT pk1_value, pk2_value, pk3_value FROM EGO_ODI_WS_ENTITIES ent1
                       -- WHERE session_id = p_session_id and
                       -- SEQUENCE_NUMBER IN (
                       --               SELECT PK4_VALUE
                       --               FROM EGO_ODI_WS_ENTITIES  ent2
                       --               WHERE PK1_VALUE = l_item_id
                       --               AND PK2_VALUE = l_org_id
                       --               AND ent1.session_id = ent2.session_id
                       --           ))
              LOOP

                dbms_output.put_line('User did not have the privilege '||p_priv_check ||', on the the item '|| l_item_id);

                dbms_output.put_line('User did not have the privilege '||p_priv_check ||', for few components of the item '||i.item_id);

                --retrieving invokation mode
                select char_value
                into l_mode
                from EGO_PUB_WS_CONFIG
                where parameter_name = 'MODE'
                and session_id  = p_session_id;

                IF (l_mode = 'BATCH') THEN

                 --retrieving batchId from input XML
                  select to_number(extractValue(xmlcontent, '/structureQueryParameters/BatchStructureQueryParameters/BatchId'))
                  into l_batch_id
                  from EGO_PUB_WS_PARAMS
                  where session_id = p_session_id;

                  --retrieving batch_id
                  --select Numeric_Value
                  --into l_batch_id
                  --from EGO_PUB_WS_CONFIG
                  --where parameter_name = 'BATCH_ID'
                  --and session_id  = p_session_id;

                  --selecting entity_object_id with respect to
                  --publication framework tables to report the error
                  SELECT BATCH_ENTITY_OBJECT_ID
                  INTO l_batch_ent_obj_id
                  FROM Ego_Pub_Bat_Ent_Objs_v
                  WHERE batch_id = l_batch_id
                  AND PK1_VALUE = i.item_id
                  AND PK2_VALUE = i.item_org_id
                  AND PK3_VALUE = i.item_rev;

                  SELECT party_name INTO l_user_name
                  FROM EGO_USER_V WHERE USER_ID = FND_GLOBAL.USER_ID;

                  SELECT CHAR_VALUE INTO l_structure_name FROM EGO_PUB_BAT_PARAMS_B
                  WHERE type_id=l_batch_id AND Upper(parameter_name) ='STRUCTURE_NAME';

                  UPDATE EGO_PUB_BAT_STATUS_B
                  SET STATUS_CODE = 'F' , MESSAGE = 'User ' || l_user_name ||' does not have the publilsh privilege on few components of the structure ' ||
                  l_structure_name || ' for this Item.'
                  WHERE batch_id = l_batch_id AND BATCH_ENTITY_OBJECT_ID = l_batch_ent_obj_id;

                ELSE

                  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                  p_odi_session_id => p_odi_session_id,
                                  p_input_id  => l_seq_number,
                                  p_err_code => 'EGO_NO_PUBLISH_PRIV',
                                  p_err_message => 'User does not have the publilsh privilege on few components of the structure for the item');

                END IF;

            END LOOP;

  END generate_component_error;
*/

--OLD PROCEDURE ANALYZING COMPONENTS IN BATCH MODE
--Checks the specified security priviledge on all components stored in table BOM_EXPLOSIONS_ALL
--pointed by session_id in table BOM_ODI_WS_REVISIONS after all bom explosions have been executed
--for all end-items with valid publish privilege in table BOM_ODI_WS_ENTITIES.
--If an item (row) is found not to have the privilege, it is deleted from the table.
/*PROCEDURE check_component_security(p_session_id IN  NUMBER,
                                  p_odi_session_id IN NUMBER,
                                  p_priv_check IN  VARCHAR2,
                                  --p_group_id IN NUMBER,
                                  x_return_status OUT NOCOPY  VARCHAR2
                                 )
  IS

  l_sec_predicate VARCHAR2(32767);
  l_dynamic_update_sql VARCHAR2(32767);
  l_dynamic_sql VARCHAR2(32767);
  l_item_id NUMBER;
  l_org_id NUMBER;
  l_rowid ROWID;

  l_mode VARCHAR2(10);
  l_batch_id NUMBER;
  l_batch_ent_obj_id NUMBER;
  l_user_name VARCHAR2(100);
  l_structure_name  VARCHAR2(100);
  p_index number;
  l_seq_number NUMBER;
  l_group_id NUMBER;

  TYPE DYNAMIC_CUR IS REF CURSOR;
  v_dynamic_cursor         DYNAMIC_CUR;

BEGIN

  dbms_output.put_line(' Starting of check_component_security ');

    --delete, for debugging only
    INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' Starting of Check_security ');


   --obtaining security predicate based on FND_SECURITY initialization
   dbms_output.put_line(' calling EGO_DATA_SECURITY.get_security_predicat ');
   EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => p_priv_check
       ,p_object_name      => 'EGO_ITEM'
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(FND_GLOBAL.PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'e.COMPONENT_ITEM_ID'
       ,p_pk2_alias        => 'e.ORGANIZATION_ID'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );

       dbms_output.put_line( ' Before If T, F : x_return_status - '|| x_return_status);

       --remove
       INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' x_return_status: ' || x_return_status);
       INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' l_sec_predicate: ' || l_sec_predicate);



    IF x_return_status IN ('T','F')  THEN

      IF l_sec_predicate IS NOT NULL THEN

        BEGIN

          --selecting all components that do not have the publish privilege from table
          --BOM_EXPLOSIONS_ALL and joining with table BOM_ODI_WS_REVISIONS to update PUBLISH_FLAG
          l_dynamic_sql := ' select i.row_id, e.COMPONENT_ITEM_ID, e.ORGANIZATION_ID, i.sequence_number, e.group_id ' ||
                         ' from bom_explosions_all e, bom_odi_ws_revisions i ' ||
                         ' where i.session_id = :1 ' ||
                         'and e.rowid = i.row_id' ||
                         ' AND NOT ' || l_sec_predicate;

              --for debugging purposes only
              INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' Inside check_component_privilege: ');
              INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' l_dynamic_sql: ' || l_dynamic_sql);



          --Looping throught all components with no publish privilege to generate the error
          --messages
          OPEN v_dynamic_cursor FOR l_dynamic_sql
          USING  p_session_id;
          LOOP

            FETCH  v_dynamic_cursor INTO l_rowid, l_item_id , l_org_id, l_seq_number, l_group_id;
            EXIT WHEN v_dynamic_cursor%NOTFOUND;

            dbms_output.put_line(' In the loop Insering ... ');

              --for debugging purposes only
              INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' Looping to generate error info: ');
              INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' l_rowid: ' || l_rowid);
              INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' l_item_id: ' || l_item_id);
              INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' l_org_id: ' || l_org_id);

            --TODO: Replace this code with a proper error generation mechanim
            --for components
            IF TRUE THEN

                  EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                  p_odi_session_id => p_odi_session_id,
                                  p_input_id  => l_seq_number,
                                  p_err_code => 'EGO_NO_PUBLISH_PRIV',
                                  p_err_message => 'User does not have the publilsh privilege on few components of the structure for the item');

            ELSE
                  NULL;
                  --generate_component_error(p_session_id IN  NUMBER)
            END IF;
            --TODO: end


            --Now that the error messages have been generated,
            --set the flag PUBLISH_FLAG to 'N' in table table bom_odi_ws_revisions
            --for ecomponents with no publish privilege to prevent their publication.
            l_dynamic_update_sql := ' update BOM_ODI_WS_REVISIONS s ' ||
                                ' set PUBLISH_FLAG = ''N'' ' ||
                                ' where s.session_id = :1 ' ||
                                ' AND nvl(s.PUBLISH_FLAG, ''Y'') = ''Y'' ' ||
                                ' AND s.row_id =:2';

             INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' l_dynamic_update_sql:  ' || l_dynamic_update_sql);

            dbms_output.put_line(' Executing the l_dynamic_update_sql');
            EXECUTE IMMEDIATE l_dynamic_update_sql
            USING IN p_session_id, l_rowid;

          END LOOP;

            CLOSE v_dynamic_cursor;
            x_return_status := 'S';
            --dbms_output.put_line(' Doing Commit ');
            --COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('When others of check security Error :'|| SQLERRM);
          --ROLLBACK;
          x_return_status := 'E';
          RAISE;

          IF (v_dynamic_cursor%ISOPEN) THEN
            CLOSE v_dynamic_cursor;
          END IF;
        END; -- end of BEGIN

      ELSE
         x_return_status := 'S';
      END IF;  -- end of l_sec_predicate IS NOT NULL

    END IF;

  END check_component_security;*/


--Checks the specified security priviledge on all components stored in table BOM_EXPLOSIONS_ALL
--pointed by session_id in table BOM_ODI_WS_REVISIONS after all bom explosions have been executed
--for all end-items with valid publish privilege in table BOM_ODI_WS_ENTITIES.
--If an item (row) is found not to have the privilege, it is deleted from the table.
PROCEDURE check_component_security(p_session_id IN  NUMBER,
                                  p_odi_session_id IN NUMBER,
                                  p_priv_check IN  VARCHAR2,
                                  p_group_id IN NUMBER,
                                  p_input_identifier IN NUMBER,
                                  p_inv_item_id IN NUMBER,
                                  p_org_id IN NUMBER,
                                  p_rev_id IN NUMBER,
                                  x_return_status OUT NOCOPY  VARCHAR2
                                 )
  IS

  l_sec_predicate VARCHAR2(32767);
  l_dynamic_sql VARCHAR2(32767);
  l_dynamic_update_sql VARCHAR2(32767);

  l_mode VARCHAR2(10);
  l_batch_id NUMBER;
  l_batch_ent_obj_id NUMBER;
  l_user_name VARCHAR2(100);
  l_structure_name  VARCHAR2(100);
  p_index number;
  l_group_id NUMBER;
  l_count NUMBER;


BEGIN

  dbms_output.put_line(' Starting of check_component_security ');

    --delete, for debugging only
    /*INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' Starting of Check_Component_security ');
    */
   --obtaining security predicate based on FND_SECURITY initialization
   dbms_output.put_line(' calling EGO_DATA_SECURITY.get_security_predicate ');
   EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => p_priv_check
       ,p_object_name      => 'EGO_ITEM'
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(FND_GLOBAL.PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'e.COMPONENT_ITEM_ID'
       ,p_pk2_alias        => 'e.ORGANIZATION_ID'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );

       dbms_output.put_line( ' Before If T, F : x_return_status - '|| x_return_status);

       --remove
       /*INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' x_return_status: ' || x_return_status);
       INSERT INTO emt_temp (Session_id, message)
            values (p_session_id, ' l_sec_predicate: ' || l_sec_predicate);
         */


    IF x_return_status IN ('T','F')  THEN

      IF l_sec_predicate IS NOT NULL THEN

        BEGIN

          --selecting all components that do not have the publish privilege from table
          --BOM_EXPLOSIONS_ALL
          /*l_dynamic_sql := ' select e.COMPONENT_ITEM_ID, e.ORGANIZATION_ID, e.group_id ' ||
                         ' from bom_explosions_all e ' ||
                         ' where e.group_id = :1 ' ||
                         ' AND NOT ' || l_sec_predicate;*/

          l_dynamic_sql := ' select count(*) ' ||
                         ' from bom_explosions_all e ' ||
                         ' where e.group_id = :1 ' ||
                         ' AND NOT ' || l_sec_predicate;


            dbms_output.put_line(' Executing the l_dynamic_sql');
            EXECUTE IMMEDIATE l_dynamic_sql
            INTO l_count
            USING IN p_group_id;

          --if the count is different from zero, it means at least one component does not have
          --the publish privilege.
          IF l_count > 0 THEN

                DBMS_OUTPUT.PUT_LINE('At least one component has no publish privilege: ');

                /*INSERT INTO emt_temp (Session_id, message)
                values (p_session_id, 'components without publish privilege: ' || l_count);
                */
                 EGO_ODI_PUB.Log_Error(p_session_id => p_session_id,
                                  p_odi_session_id => p_odi_session_id,
                                  p_input_id  => p_input_identifier,
                                  p_err_code => 'EGO_NO_PUBLISH_PRIV',
                                  p_err_message => 'User does not have the publilsh privilege on few components of the structure for the item');

                 --UPDATE END-ITEM WITH PUBLISH_FLAG = 'N' TO PREVENT ITS PUBLICATION
                 l_dynamic_update_sql := ' update BOM_ODI_WS_ENTITIES i ' ||
                                ' set PUBLISH_FLAG = ''N'' ' ||
                                ' where i.session_id = :1 ' ||
                                ' and i.odi_session_id = :2 ' ||
                                ' and i.item_id = :3 ' ||
                                ' and i.item_org_id = :4 ' ||
                                ' and i.item_rev = :5 ' ||
                                ' AND nvl(i.PUBLISH_FLAG, ''Y'') = ''Y'' ';

                dbms_output.put_line(' Executing the l_dynamic_update_sql');
                EXECUTE IMMEDIATE l_dynamic_update_sql
                USING IN p_session_id, p_odi_session_id, p_inv_item_id, p_org_id, p_rev_id;


          END IF;

          --for debugging purposes only
          /*INSERT INTO emt_temp (Session_id, message)
          values (p_session_id, ' Inside check_component_privilege: ');
          INSERT INTO emt_temp (Session_id, message)
          values (p_session_id, ' l_dynamic_sql: ' || l_dynamic_sql);
            */
           x_return_status := 'S';
           --dbms_output.put_line(' Doing Commit ');
           --COMMIT;

        EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('When others of check security Error :'|| SQLERRM);
          x_return_status := 'E';
          RAISE;

        END; -- end of BEGIN

      ELSE
         x_return_status := 'S';
      END IF;  -- end of l_sec_predicate IS NOT NULL

    END IF;

  END check_component_security;


--returns the mode in which the getItemStructure web service is being
--invoked. The function returns a string describing the invokation
--mode as follows:
--
--       'HMDM'  - The web service is being invoked by H-MDM compatible code
--       'BATCH' - The web service is being invoked by PIM for TELCO publication
--                 code triggered by publication framework GUI
--       'LIST'  - The web service is being invoked by PIM for TELCO publication
--                 code and the parameters are passed as list of items
--       'NONE'  - If none of the above modes were found in the payload
FUNCTION Invocation_Mode_Structure(p_session_id IN NUMBER) RETURN VARCHAR2 IS

x_mode VARCHAR2(10) := 'NONE';
l_tmp_val VARCHAR2(100);
l_exists NUMBER;
l_exists1 NUMBER;

BEGIN

  --FIRST CHECK FOR SUBROUTINE MODE
  select count(*)
  into l_exists
  from EGO_PUB_WS_CONFIG
  where session_id = p_session_id
  and web_service_name = 'GET_ITEM_STRUCTURE'
  and parameter_name = 'MODE'
  and char_value = 'SUBROUTINE';

  IF l_exists=1 THEN
      RETURN 'SUBROUTINE';
  END IF;


  --START BATCH MODE CHECK
  --if batch_id is populated, we are in 'BATCH' mode
  select existsNode(xmlcontent, '/structureQueryParameters/BatchStructureQueryParameters/BatchId')
  into l_exists
  from EGO_PUB_WS_PARAMS
  where session_id = p_session_id;

  IF l_exists=1 THEN

      select extractValue(xmlcontent, '/structureQueryParameters/BatchStructureQueryParameters/BatchId')
      into l_tmp_val
      from EGO_PUB_WS_PARAMS
      where session_id = p_session_id;

      IF l_tmp_val <> '?' THEN
          RETURN 'BATCH';
      END IF;

  END IF;


  --START HMDM MODE CHECK
  --if organization Id or organization name were populated, we are in 'HMDM' mode
  select existsNode(xmlcontent, '/structureQueryParameters/OrganizationId')
  into l_exists
  from EGO_PUB_WS_PARAMS
  where session_id = p_session_id;

  select existsNode(xmlcontent, '/structureQueryParameters/OrganizationCode')
  into l_exists1
  from EGO_PUB_WS_PARAMS
  where session_id = p_session_id;


  IF l_exists=1 OR l_exists1=1 THEN

          select extractValue(xmlcontent, '/structureQueryParameters/OrganizationId')
          into l_tmp_val
          from EGO_PUB_WS_PARAMS
          where session_id = p_session_id;

          IF l_tmp_val <> '?' THEN
              RETURN 'HMDM';
          END IF;

          select extractValue(xmlcontent, '/structureQueryParameters/OrganizationCode')
          into l_tmp_val
          from EGO_PUB_WS_PARAMS
          where session_id = p_session_id;

          IF l_tmp_val <> '?' THEN
              RETURN 'HMDM';
          END IF;

  END IF;


  --START LIST MODE CHECK
  --if node ListOfItemStructureQueryParams occurs more than once,
  --we are in 'LIST' MODE
  select count(*)
  into l_exists
  from EGO_PUB_WS_PARAMS
  where session_id = p_session_id
  and existsNode(xmlcontent, '/structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/OrganizationId')=1;

  select count(*)
  into l_exists1
  from EGO_PUB_WS_PARAMS
  where session_id = p_session_id
  and existsNode(xmlcontent, '/structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/OrganizationCode')=1;


  --TODO: Change this to a check using the same XPATH expression as statement above
  --if there is one occurrence, check structurename node for meaningful value
  IF l_exists>=1 OR l_exists1>=1 THEN

      /*select extractValue(xmlcontent, '/structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/OrganizationId')
      into l_tmp_val
      from EGO_PUB_WS_PARAMS
      where session_id = p_session_id;

      IF l_tmp_val <> '?' THEN
          RETURN 'LIST';

      END IF;*/
      RETURN 'LIST';

  END IF;

  --If mode could not be determined, error out
  --IF x_mode = 'NONE' THEN
  raise_application_error(-20000, 'Invokation mode (e.g. BATCH, LIST or HMDM) could not be determined ');
  --END IF;

  RETURN x_mode;

END Invocation_Mode_Structure;



--Inserts language options in EGO_PUB_WS_CONFIG table
PROCEDURE Config_Languages(p_session_id        IN  NUMBER,
                           p_odi_session_id    IN  NUMBER,
                           p_lang_search_str   IN  VARCHAR2,
                           p_web_service_name VARCHAR2 DEFAULT NULL)
IS

l_lang_code_tab            dbms_sql.varchar2_table;
l_lang_name_tab            dbms_sql.varchar2_table;

l_langcode_xpath           VARCHAR2(200):=p_lang_search_str||'/LanguageCode';
l_langname_xpath           VARCHAR2(200):=p_lang_search_str||'/LanguageName';
l_codes_provided           VARCHAR(3):='Y';
l_count                    NUMBER;
l_is_valid                 BOOLEAN;
l_valid_count              NUMBER := 0;
l_temp_code                VARCHAR(200);
l_temp_name                VARCHAR(200);

BEGIN

      --extracting language Codes
      SELECT   extractValue(lang_code, '/LanguageCode')
        BULK COLLECT INTO  l_lang_code_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, l_langcode_xpath) )) langcode
              WHERE session_id=p_session_id
              );

      --extracting language names
      SELECT   extractValue(lang_code, '/LanguageName')
        BULK COLLECT INTO  l_lang_name_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, l_langname_xpath) )) langcode
              WHERE session_id=p_session_id
              );


      l_count :=  l_lang_code_tab.Count;
      IF l_count < l_lang_name_tab.Count THEN
         l_count := l_lang_name_tab.Count;
      END IF;

      --check if all language codes provided are different from null
      IF l_count > 0 THEN

          FOR i IN 1..l_count
          LOOP

              IF l_lang_code_tab.Count >= i THEN
                  l_temp_code := l_lang_code_tab(i);
              ELSE
                  l_temp_code := NULL;
              END IF;
              IF l_lang_name_tab.Count >= i THEN
                  l_temp_name := l_lang_name_tab(i);
              ELSE
                  l_temp_name := NULL;
              END IF;

              /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' l_temp_code: ' || l_temp_code);
              INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' l_lang_name_tab(i): ' || l_lang_name_tab(i));
              INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, ' l_temp_name: ' || l_temp_name);
              */

              --validating language code or language name
              l_is_valid := Validate_Language_Info(p_session_id => p_session_id,
                                                   p_odi_session_id => p_odi_session_id,
                                                   p_language_code => l_temp_code,
                                                   p_language_name => l_temp_name);

              IF l_is_valid = TRUE THEN
                  l_valid_count := l_valid_count + 1;
                  l_lang_code_tab(i) := l_temp_code;
              ELSE
                  l_lang_code_tab(i) := NULL;
                  --TODO: Generate warning message for non-valid language code/name
                  --in l_temp_code or l_temp_name
              END IF;

          END LOOP;

          --if no valid language codes or names were found, assume none were passed
          IF l_valid_count = 0 THEN
                l_codes_provided := 'N';
          END IF;

      ELSE

          l_codes_provided := 'N';

      END IF;

      --Insert record into config table for parameter language
      --IF l_lang_code_tab.Count> 0 THEN
      IF l_codes_provided = 'Y' THEN

          FOR i IN 1..l_count
          LOOP

            IF l_lang_code_tab(i) IS NOT NULL THEN
                INSERT INTO EGO_PUB_WS_CONFIG ( session_id,
                                                odi_session_id,
                                                Parameter_Name,
                                                Data_Type,
                                                Date_Value,
                                                Char_value,
                                                Numeric_Value,
                                                creation_date,
                                                created_by,
                                                web_service_name)
                                        VALUES (p_session_id,
                                                p_odi_session_id,
                                                'LANGUAGE_CODE',
                                                2,
                                                NULL,
                                                l_lang_code_tab(i),
                                                NULL,
                                                SYSDATE,
                                                G_CURRENT_USER_ID,
                                                p_web_service_name);
            END IF;
          END LOOP;

      ELSE

          FOR i IN (SELECT language_code FROM FND_LANGUAGES WHERE INSTALLED_FLAG IN ('I','B') ) LOOP
            INSERT INTO EGO_PUB_WS_CONFIG ( session_id,
                                            odi_session_id,
                                            Parameter_Name,
                                            Data_Type,
                                            Date_Value,
                                            Char_value,
                                            Numeric_Value,
                                            creation_date,
                                            created_by,
                                            web_service_name)
                                     VALUES (p_session_id,
                                             p_odi_session_id,
                                             'LANGUAGE_CODE',
                                             2,
                                             NULL,
                                             i.language_code,
                                             NULL,
                                             SYSDATE,
                                             G_CURRENT_USER_ID,
                                             p_web_service_name);
          END LOOP;

      END IF;


END Config_Languages;


--Inserts language options in EGO_PUB_WS_CONFIG table
PROCEDURE Config_UDAs(p_session_id        IN  NUMBER,
                      p_odi_session_id    IN  NUMBER,
                      p_parameter_name    IN VARCHAR2,
                      p_uda_search_str    IN  VARCHAR2,
                      p_ag_id_node_tag    IN VARCHAR2,
                      p_ag_name_node_tag  IN VARCHAR2,
                      p_web_service_name VARCHAR2 DEFAULT NULL)
IS

x_ag_name VARCHAR2(100);
l_valid_ag BOOLEAN;

l_uda_attr_id_tab    dbms_sql.varchar2_table;
l_uda_attr_name_tab  dbms_sql.varchar2_table;
l_uda_id_xpath       VARCHAR2(1000):=p_uda_search_str || '/' || p_ag_id_node_tag;
l_uda_name_xpath     VARCHAR2(1000):=p_uda_search_str || '/' || p_ag_name_node_tag;


BEGIN


    --Dbms_Output.put_line('Processing UDA Configurations');
    --remove, debugging purposes only
    /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'Entering Config_UDAs ' || p_parameter_name);
       */

    --reading list of attribute group ids
    SELECT   extractValue(uda_ag, p_ag_id_node_tag)
      BULK COLLECT INTO l_uda_attr_id_tab
      FROM  (SELECT  Value(udaag) uda_ag
              FROM EGO_PUB_WS_PARAMS i,
              TABLE(XMLSequence(
                extract(i.xmlcontent, l_uda_id_xpath) )) udaag
              WHERE session_id=p_session_id
            );

    --reading list of attribute group names
    SELECT   extractValue(uda_ag, p_ag_name_node_tag)
      BULK COLLECT INTO l_uda_attr_name_tab
      FROM  (SELECT  Value(udaag) uda_ag
              FROM EGO_PUB_WS_PARAMS i,
              TABLE(XMLSequence(
                extract(i.xmlcontent, l_uda_name_xpath) )) udaag
              WHERE session_id=p_session_id
            );

    --Dbms_Output.put_line('Before If of UDA Configurations :'||l_uda_attr_id_tab.Count );
    --Dbms_Output.put_line('Before If of UDA Configurations :'||l_uda_attr_name_tab.Count );

    --If attribute ids where provided, generate names
    --and generate the names
    IF l_uda_attr_id_tab.Count > 0 THEN



      --for all attribute Ids read
      FOR i IN 1..l_uda_attr_id_tab.Count
      LOOP

      /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'Inside attr_id loop l_uda_attr_id_tab(i) : '  || l_uda_attr_id_tab(i));
      */



       --TODO: Validate attribute ID and obtain name
       l_valid_ag := Validate_Attribute_Group(p_session_id,
                                              p_odi_session_id,
                                              l_uda_attr_id_tab(i),
                                              NULL,
                                              x_ag_name);

       --debugging statement remove
       /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'x_ag_name: ' || x_ag_name);

       IF l_valid_ag = TRUE THEN
       INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'validation TRUE');

       ELSE
       INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'validation FALSE');

       END IF;*/


       IF l_valid_ag = TRUE THEN

            --Dbms_Output.put_line('Inserting');
            --insert attribute name in configuration table
            INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                              odi_session_id,
                                              Parameter_Name,
                                              Data_Type,
                                              Date_Value,
                                              Char_value,
                                              Numeric_Value,
                                              creation_date,
                                              created_by,
                                              web_service_name)
                                      VALUES (p_session_id,
                                              p_odi_session_id,
                                              p_parameter_name,
                                              2,
                                              NULL,
                                              x_ag_name,
                                              NULL,SYSDATE,
                                              G_CURRENT_USER_ID,
                                              p_web_service_name);
       ELSE
           --TODO: Generate warning here
           --raise_application_error(-20101, 'Warning: Invalid Attribute Group');
           NULL;
       END IF;

      END LOOP;

    END IF;


    --If attribute names were provided and no IDs
    --validate names and insert into configuration table
    IF l_uda_attr_name_tab.Count > 0 THEN

      --Dbms_Output.put_line('In the loop ');

      --for all attribute names read
      FOR i IN 1..l_uda_attr_name_tab.Count
      LOOP

          --TODO: Validate attribute name
          l_valid_ag := Validate_Attribute_Group(p_session_id,
                                                 p_odi_session_id,
                                                 NULL,
                                                 l_uda_attr_name_tab(i),
                                                 x_ag_name);

       /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'Inside attr_name loop l_uda_attr_name_tab(i) : '  || l_uda_attr_name_tab(i));
       */

       --delete debugging
       /*IF l_valid_ag = TRUE THEN
       INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'validation TRUE');

       ELSE
       INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'validation FALSE');

       END IF;*/

          IF l_valid_ag = TRUE THEN

            --Dbms_Output.put_line('Inserting');
            --insert attribute name in configuration table
            INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                              odi_session_id,
                                              Parameter_Name,
                                              Data_Type,
                                              Date_Value,
                                              Char_value,
                                              Numeric_Value,
                                              creation_date,
                                              created_by,
                                              web_service_name)
                                      VALUES (p_session_id,
                                              p_odi_session_id,
                                              p_parameter_name,
                                              2,
                                              NULL,
                                              l_uda_attr_name_tab(i),
                                              NULL,SYSDATE,
                                              G_CURRENT_USER_ID,
                                              p_web_service_name);
          ELSE
              --TODO: Generate warning here
              NULL;
          END IF;

      END LOOP;

    END IF;


EXCEPTION
      WHEN OTHERS THEN
      NULL;
      /* INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'Handling exception at Config_UDA: ' || SQLERRM);

      */
       --TODO: Handle errors here
       --Dbms_Output.put_line('Create_Config_Param Exception:- '||SQLERRM||' Code :- '||SQLCODE);

END Config_UDAs;




--creates all configurability parameters and stores them in table
--EGO_PUB_WS_CONFIG
PROCEDURE Create_Params_Structure(p_session_id IN NUMBER,
                                  p_odi_session_id IN NUMBER)
IS

l_mode VARCHAR2(10) :='BATCH';
l_exists NUMBER;
l_fnd_user_name VARCHAR2(100);
l_responsibility_name VARCHAR2(100);
l_responsibility_appl_name VARCHAR2(100);
l_security_group_name VARCHAR2(100);
l_retpayload      VARCHAR2(10)  :='Y';
l_batch_id NUMBER;
l_user_id NUMBER;
l_responsibility_id NUMBER;
l_application_id NUMBER;

l_config_option VARCHAR2(100);
l_xml_node_xpath VARCHAR2(1000);
l_parameter_name VARCHAR2(100);

--array to store XML path expressions to retrieve single-value params
TYPE xpath_expr_array_type IS VARRAY(15) OF VARCHAR2(1000);
l_xpath_expr_array xpath_expr_array_type;

--array to store single_value parameter names
TYPE parameter_name_array_type IS VARRAY(15) OF VARCHAR2(1000);
l_parameter_name_array parameter_name_array_type;


BEGIN

  --determine invokation mode for getItemStructure web service
  --and insert in parametes table
  l_mode := Invocation_Mode_Structure(p_session_id);

  --if mode is SUBROUTINE, all parameters in table EGO_PUB_WS_CONFIG
  --have already been created by invoking ODI Scenario, so quit
  --procedure
  IF l_mode = 'SUBROUTINE' THEN
     RETURN;
  END IF;

  --debugging statement remove
  /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'invokation mode:' || l_mode);
   */

  --inserting invokation mode as config parameter
  INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'MODE',
                               2,
                               l_mode,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');


/*TODO: See if this is required for chunking to work
  IF (l_retpayload='Y')
  THEN
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
      VALUES (p_session_id,p_session_id,'return_payload',2,NULL,'TRUE',NULL,SYSDATE,G_CURRENT_USER_ID);
  ELSE
      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
      VALUES (p_session_id,p_session_id,'return_payload',2,NULL,'FALSE',NULL,SYSDATE,G_CURRENT_USER_ID);
  END IF;
    --End Chunking
*/



  --
  --STEP ONE: RETRIEVE ALL SINGLE-VALUE CONFIGURATION PARAMETERS
  --          AND STORE THEM IN TABLE EGO_PUB_WS_CONFIG
  --

  --initialize arrays of parameter names
  l_parameter_name_array := parameter_name_array_type('PUBLISH_REVISIONS',
                                                          'PUBLISH_STRUCT_AGS',
                                                          'PUBLISH_COMPONENTS',
                                                          'PUBLISH_COMP_REF',
                                                          'PUBLISH_COMP_SUBS',
                                                          'PUBLISH_COMP_AGS',
                                                          'LEVELS_TO_EXPLODE',
                                                          'EXPLODE_OPTION',
                                                          'EXPLODE_STD_BOM',
                                                          'RETURN_PAYLOAD',
                                                          'PUBLISH_COMP_OVR_AGS',
                                                          'PUBLISH_COMP_EXCLUSIONS',
                                                          'PUBLISH_VS_EXCLUSIONS'
                                                          );

  CASE

     WHEN l_mode = 'BATCH' THEN

      l_xpath_expr_array := xpath_expr_array_type('/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/StructureRevision',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/StructureHeaderAttributeGroups',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/StructureComponents',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/PublishStructureComponents/StructureReferenceDesignators',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/PublishStructureComponents/StructureSubstituteComponents',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/PublishStructureComponents/ComponentAttributeGroups',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/BomExploderParameters/LevelsToExplode',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/BomExploderParameters/ExplodeOption',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/BomExploderParameters/ExplodeStandard',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/ReturnPayload',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/PublishStructureComponents/ComponentUDAOverrides',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/PublishStructureComponents/ComponentExclusions',
                                                  '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/PublishStructureComponents/ValueSetExclusions'

                                                  );


     WHEN l_mode = 'HMDM' THEN

      l_xpath_expr_array := xpath_expr_array_type('/structureQueryParameters/PublishEntities/StructureRevision',
                                                  '/structureQueryParameters/PublishEntities/StructureHeaderAttributeGroups',
                                                  '/structureQueryParameters/PublishEntities/StructureComponents',
                                                  '/structureQueryParameters/PublishEntities/PublishStructureComponents/StructureReferenceDesignators',
                                                  '/structureQueryParameters/PublishEntities/PublishStructureComponents/StructureSubstituteComponents',
                                                  '/structureQueryParameters/PublishEntities/PublishStructureComponents/ComponentAttributeGroups',
                                                  '/structureQueryParameters/BomExploderParameters/LevelsToExplode',
                                                  '/structureQueryParameters/BomExploderParameters/ExplodeOption',
                                                  '/structureQueryParameters/BomExploderParameters/ExplodeStandard',
                                                  '/structureQueryParameters/PublishEntities/ReturnPayload',
                                                  '/structureQueryParameters/PublishEntities/PublishStructureComponents/ComponentUDAOverrides',
                                                  '/structureQueryParameters/PublishEntities/PublishStructureComponents/ComponentExclusions',
                                                  '/structureQueryParameters/PublishEntities/PublishStructureComponents/ValueSetExclusions'
                                                  );


      WHEN l_mode = 'LIST' THEN

      l_xpath_expr_array := xpath_expr_array_type('/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/StructureRevision',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/StructureHeaderAttributeGroups',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/StructureComponents',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/PublishStructureComponents/StructureReferenceDesignators',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/PublishStructureComponents/StructureSubstituteComponents',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/PublishStructureComponents/ComponentAttributeGroups',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/BomExploderParameters/LevelsToExplode',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/BomExploderParameters/ExplodeOption',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/BomExploderParameters/ExplodeStandard',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/ReturnPayload',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/PublishStructureComponents/ComponentUDAOverrides',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/PublishStructureComponents/ComponentExclusions',
                                                  '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/PublishStructureComponents/ValueSetExclusions'

                                                 );

      --if no mode has been identified, error out
      ELSE
        raise_application_error(-20101, 'Invokation mode (e.g. BATCH, LIST, or HMDM) could not be determined');


  END CASE;


  --retrieve all single-value parameters of interest from XML
  --and store them in table EGO_PUB_WS_CONFIG
  FOR position IN 1..l_parameter_name_array.COUNT
  LOOP

      l_config_option := upper(EGO_ODI_PUB.Get_ODI_Input_Parameter(p_session_id, l_xpath_expr_array(position)));

      --if parameter is not provided, assume a default value of 'Y' (Yes)
      IF l_config_option IS NULL OR l_config_option = '?' THEN

           CASE
               WHEN l_parameter_name_array(position) = 'LEVELS_TO_EXPLODE' THEN
                    --Temporary workaround for bug 8768551. This line must
                    --be changed to  l_config_option := '60' once bug is fixed
                    l_config_option := '60';
               WHEN l_parameter_name_array(position) = 'EXPLODE_OPTION' THEN
                    l_config_option := '2';
               WHEN l_parameter_name_array(position) = 'EXPLODE_STD_BOM' THEN
                    l_config_option := 'N';
               ELSE
                    l_config_option := 'Y';
           END CASE;


      END IF;

      IF l_config_option IS NOT NULL AND l_config_option <> '?' THEN

              INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               l_parameter_name_array(position),
                               2,
                               l_config_option,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

      END IF;

  END LOOP;



 --RETRIEVING FND_USER_NAME, RESPONSIBILITY_NAME, RESPONSIBILITY_APPL_NAME, and
 --SECURITY_GROUP_NAME depending on input mode

 --if mode is LIST or H-MDM, get authentication information from
 --user calling the web service. This info is stored in table
 --EGO_PUB_WS_PARAMS and can be recovered with the session_id
 IF l_mode <> 'BATCH' THEN

    --retrieving and storing FND_USER_NAME
    select fnd_user_name
    into l_fnd_user_name
    from EGO_PUB_WS_PARAMS
    where session_id = p_session_id;

    INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'FND_USER_NAME',
                               2,
                               l_fnd_user_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

    --retrieving and storing RESPONSIBILITY_NAME
    select responsibility_name
    into l_responsibility_name
    from EGO_PUB_WS_PARAMS
    where session_id = p_session_id;

    INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'RESPONSIBILITY_NAME',
                               2,
                               l_responsibility_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');


    --retrieving and storing RESPONSIBILITY_APPL_NAME
    select responsibility_appl_name
    into l_responsibility_appl_name
    from EGO_PUB_WS_PARAMS
    where session_id = p_session_id;

    INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'RESPONSIBILITY_APPL_NAME',
                               2,
                               l_responsibility_appl_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');


    --retrieving and storing SECURITY_GROUP_NAME
    select security_group_name
    into l_security_group_name
    from EGO_PUB_WS_PARAMS
    where session_id = p_session_id;

    INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'SECURITY_GROUP_NAME',
                               2,
                               l_security_group_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

  --IF MODE IS BATCH, retrieve authentication data from Publication Framework tables
  --This means the authentication information used corresponds to user who created the
  --publication batch throught the publication UI.
  ELSE


        --retrieving batchId from input XML
        select to_number(extractValue(xmlcontent, '/structureQueryParameters/BatchStructureQueryParameters/BatchId'))
        into l_batch_id
        from EGO_PUB_WS_PARAMS
        where session_id = p_session_id;

        --retrieving user_id and responsibility
        select created_by, responsibility_id
        into l_user_id, l_responsibility_id
        from EGO_PUB_BAT_HDR_B
        where batch_id = l_batch_id;

       --retrieving user name
        select USER_NAME
        into l_fnd_user_name
        from fnd_user
        where user_id = l_user_id;

        --inserting user name
        INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'FND_USER_NAME',
                               2,
                               l_fnd_user_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

        --retrieving responsibility name
        select responsibility_key
        into l_responsibility_name
        from FND_RESPONSIBILITY
        where responsibility_id = l_responsibility_id;

        --inserting responsibility name
        INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'RESPONSIBILITY_NAME',
                               2,
                               l_responsibility_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

        --retrieving application_id
        Select application_id
        into l_application_id
        from FND_RESPONSIBILITY
        where responsibility_id = l_responsibility_id;

        --retrieving responsibility_appl_name
        select APPLICATION_SHORT_NAME
        into l_responsibility_appl_name
        from FND_APPLICATION
        where application_id = l_application_id;

        --inserting responsibility_appl_name
        INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'RESPONSIBILITY_APPL_NAME',
                               2,
                               l_responsibility_appl_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

         --inserting security_group_name as NULL
         l_security_group_name := NULL;
         INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               p_odi_session_id,
                               'SECURITY_GROUP_NAME',
                               2,
                               l_security_group_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');
 END IF;



  --In batch mode, parameter LEVELS_TO_EXPLODE provided un publication UI
  --overrides parameter passed during invokation of web service
  --thus, the parameter is updated with the value from publication fwk tables
  IF l_mode = 'BATCH' THEN

     --retrieving batch_id
     select to_number(extractValue(xmlcontent, '/structureQueryParameters/BatchStructureQueryParameters/BatchId'))
     into l_batch_id
     from EGO_PUB_WS_PARAMS
     where session_id = p_session_id;

     --retrieving levels_to_explode
     select to_char(numeric_value)
     into l_config_option
     from Ego_Pub_Bat_Params_B
     where type_id = l_batch_id
           and parameter_name = 'LEVELS_TO_EXPLODE';

     --updating value of config parameter
     UPDATE EGO_PUB_WS_CONFIG
     SET Char_value = l_config_option
     where Parameter_Name = 'LEVELS_TO_EXPLODE'
           and web_service_name = 'GET_ITEM_STRUCTURE'
           and session_id = p_session_id
           and odi_session_id = p_odi_session_id;

      --retrieving EXPLODE_STD_BOM
     select char_value
     into l_config_option
     from Ego_Pub_Bat_Params_B
     where type_id = l_batch_id
           and parameter_name = 'EXPLODE_STD_BOM';

     --updating value of config parameter
     UPDATE EGO_PUB_WS_CONFIG
     SET Char_value = l_config_option
     where Parameter_Name = 'EXPLODE_STD_BOM'
           and web_service_name = 'GET_ITEM_STRUCTURE'
           and session_id = p_session_id
           and odi_session_id = p_odi_session_id;

     --forcing explosion type to be CURRENT (2)
     l_config_option := '2';
     UPDATE EGO_PUB_WS_CONFIG
     SET Char_value = l_config_option
     where Parameter_Name = 'EXPLODE_OPTION'
           and web_service_name = 'GET_ITEM_STRUCTURE'
           and session_id = p_session_id
           and odi_session_id = p_odi_session_id;

  END IF;

  --
  --STEP TWO: RETRIEVE ALL MULTI-VALUE CONFIGURATION PARAMETERS
  --          AND STORE THEM IN TABLE EGO_PUB_WS_CONFIG
  --


  --RETRIEVING LIST OF LANGUAGES
  l_parameter_name := 'LANGUAGE_CODE';

  CASE
      WHEN l_mode = 'BATCH' THEN
        l_xml_node_xpath := '/structureQueryParameters/BatchStructureQueryParameters/Configurability/ListOfLanguageInformation';
      WHEN l_mode = 'HMDM' THEN
        l_xml_node_xpath := '/structureQueryParameters/ListOfLanguageInformation';
      WHEN l_mode = 'LIST' THEN
        l_xml_node_xpath := '/structureQueryParameters/ParametersForListOfItems/Configurability/ListOfLanguageInformation';
  END CASE;

   --Inserts language options in Config table
   Config_Languages(p_session_id,
                    p_odi_session_id,
                    l_xml_node_xpath,
                    'GET_ITEM_STRUCTURE');


  --RETRIEVING LIST OF STRUCTURE HEADER ATTRIBUTE GROUPS TO PUBLISH
  CASE
      WHEN l_mode = 'BATCH' THEN
        --l_xml_node_xpath := '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/ListOfPublishStructureHeaderAttributeGroups/PublishStructureHeaderAttributeGroup';
        l_xml_node_xpath := '//PublishStructureHeaderAttributeGroup';
      WHEN l_mode = 'HMDM' THEN
        --l_xml_node_xpath := '/structureQueryParameters/PublishEntities/ListOfPublishStructureHeaderAttributeGroups/PublishStructureHeaderAttributeGroup';
        l_xml_node_xpath := '//PublishStructureHeaderAttributeGroup';
      WHEN l_mode = 'LIST' THEN
        --l_xml_node_xpath := '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/ListOfPublishStructureHeaderAttributeGroups/PublishStructureHeaderAttributeGroup';
        l_xml_node_xpath := '//PublishStructureHeaderAttributeGroup';
  END CASE;


   --Insert configurability options for Structure Header Attribute Groups
   Config_UDAs(p_session_id,
               p_odi_session_id,
               'HEADER_AG_NAME',
               l_xml_node_xpath,
               'AttributegroupId',
               'AttributeGroupName',
               'GET_ITEM_STRUCTURE');


  --RETRIEVING LIST OF COMPONENT ATTRIBUTE GROUPS TO PUBLISH
  CASE
      WHEN l_mode = 'BATCH' THEN
        --l_xml_node_xpath := '/structureQueryParameters/BatchStructureQueryParameters/Configurability/PublishEntities/PublishStructureComponents/ListOfPublishComponentAttributeGroups/PublishComponentAttributeGroup';
        l_xml_node_xpath := '//PublishComponentAttributeGroup';
      WHEN l_mode = 'HMDM' THEN
        --l_xml_node_xpath := '/structureQueryParameters/PublishEntities/PublishStructureComponents/ListOfPublishComponentAttributeGroups/PublishComponentAttributeGroup';
        l_xml_node_xpath := '//PublishComponentAttributeGroup';
      WHEN l_mode = 'LIST' THEN
        --l_xml_node_xpath := '/structureQueryParameters/ParametersForListOfItems/Configurability/PublishEntities/PublishStructureComponents/ListOfPublishComponentAttributeGroups/PublishComponentAttributeGroup';
        l_xml_node_xpath := '//PublishComponentAttributeGroup';
  END CASE;


   --Insert configurability options for Structure Header Attribute Groups
   Config_UDAs(p_session_id,
               p_odi_session_id,
               'COMP_AG_NAME',
               l_xml_node_xpath,
               'AttributegroupId',
               'AttributeGroupName',
               'GET_ITEM_STRUCTURE');


END Create_Params_Structure;




--procedure that populates ODI input table BOM_ODI_WS_ENTITIES for
--getItemStructure web service depending on the web service invocation mode
--('BATCH','HMDM','LIST'). The input data is obtained from the following
--sources depending on the invocation mode:
--MODE='BATCH': input data obtained from Publication Framework tables
--MODE='HMDM' : input data is obtained from XML sent by invoking client in request
--MODE='LIST' : input data is obtained from XML sent by invoking client in request
PROCEDURE Create_Entities_Structure(p_session_id IN NUMBER,
                                    p_odi_session_id IN NUMBER)
IS

l_mode VARCHAR(100);
l_structure_name VARCHAR2(150);
l_explosion_date DATE;
l_batch_id NUMBER;
l_item_id NUMBER;
l_org_id NUMBER;
l_rev_id NUMBER;
x_item_id NUMBER;
x_org_id NUMBER;
l_comma_separated_str VARCHAR2(2000);
l_temp_varchar VARCHAR2(150);
l_temp2_varchar VARCHAR2(150);
l_temp3_varchar VARCHAR2(150);
l_segment1 VARCHAR2(40);
l_segment2 VARCHAR2(40);
l_segment3 VARCHAR2(40);
l_segment4 VARCHAR2(40);
l_segment5 VARCHAR2(40);
l_segment6 VARCHAR2(40);
l_segment7 VARCHAR2(40);
l_segment8 VARCHAR2(40);
l_segment9 VARCHAR2(40);
l_segment10 VARCHAR2(40);
l_segment11 VARCHAR2(40);
l_segment12 VARCHAR2(40);
l_segment13 VARCHAR2(40);
l_segment14 VARCHAR2(40);
l_segment15 VARCHAR2(40);
l_segment16 VARCHAR2(40);
l_segment17 VARCHAR2(40);
l_segment18 VARCHAR2(40);
l_segment19 VARCHAR2(40);
l_segment20 VARCHAR2(40);
l_validate_structure BOOLEAN := TRUE; --tells if structure name has to be validated
l_validate_org_id BOOLEAN := TRUE; --tells if organization name has to be validated
l_is_item_id_valid BOOLEAN := TRUE; --tells if organization name has to be validated
l_is_valid BOOLEAN := TRUE;

--tables for LIST mode
l_item_id_tab  dbms_sql.varchar2_table;
l_org_id_tab  dbms_sql.varchar2_table;
l_rev_id_tab  dbms_sql.varchar2_table;
l_root_node_id_tab  dbms_sql.varchar2_table;
l_item_segment1_tab  dbms_sql.varchar2_table;
l_item_segment2_tab  dbms_sql.varchar2_table;
l_item_segment3_tab  dbms_sql.varchar2_table;
l_item_segment4_tab  dbms_sql.varchar2_table;
l_item_segment5_tab  dbms_sql.varchar2_table;
l_item_segment6_tab  dbms_sql.varchar2_table;
l_item_segment7_tab  dbms_sql.varchar2_table;
l_item_segment8_tab  dbms_sql.varchar2_table;
l_item_segment9_tab  dbms_sql.varchar2_table;
l_item_segment10_tab  dbms_sql.varchar2_table;
l_item_segment11_tab  dbms_sql.varchar2_table;
l_item_segment12_tab  dbms_sql.varchar2_table;
l_item_segment13_tab  dbms_sql.varchar2_table;
l_item_segment14_tab  dbms_sql.varchar2_table;
l_item_segment15_tab  dbms_sql.varchar2_table;
l_item_segment16_tab  dbms_sql.varchar2_table;
l_item_segment17_tab  dbms_sql.varchar2_table;
l_item_segment18_tab  dbms_sql.varchar2_table;
l_item_segment19_tab  dbms_sql.varchar2_table;
l_item_segment20_tab  dbms_sql.varchar2_table;
l_org_name_tab  dbms_sql.varchar2_table;
l_rev_name_tab  dbms_sql.varchar2_table;
l_structure_name_tab  dbms_sql.varchar2_table;
l_explosion_date_tab  dbms_sql.varchar2_table;
l_count NUMBER;
l_item_index NUMBER;

--variables to read comma separated string
--l_list1   VARCHAR2(50) := 'A,B,C,D,E,F,G,H,I,J';
l_tablen  BINARY_INTEGER;
l_tab     DBMS_UTILITY.uncl_array;

--Cursor to retrieve list of end-items from Publication Framework
CURSOR c_fwk_end_items(p_batch_id NUMBER) IS
SELECT pk1_value,
       pk2_value,
       pk3_value
FROM EGO_PUB_BAT_ENT_OBJS_V
WHERE batch_id = p_batch_id AND user_entered = 'Y';

--Cursor to retrieve list of end-items for SUBROUTINE mode
CURSOR c_subroutine_end_items(p_session_id NUMBER) IS
SELECT CHAR_VALUE
from EGO_PUB_WS_CONFIG
where session_id = p_session_id
and web_service_name = 'GET_ITEM_STRUCTURE'
and parameter_name = 'ITEM_INFORMATION';


BEGIN

  --identify getItemStructure web service invocation mode
 select char_value
 into l_mode
 from EGO_PUB_WS_CONFIG
 where session_id = p_session_id
 and web_service_name = 'GET_ITEM_STRUCTURE'
 and parameter_name = 'MODE';

  --populate odi input table depending on mode from different data sources
  CASE

     --if mode is SUBROUTINE, get item information from EGO_PUB_WS_CONFIG table
     WHEN l_mode = 'SUBROUTINE' THEN

        /*extract list of inventory item ids */
        SELECT to_number(char_value)
        BULK COLLECT INTO  l_item_id_tab
        from EGO_PUB_WS_CONFIG
        where session_id = p_session_id
        and web_service_name = 'GET_ITEM_STRUCTURE'
        and parameter_name like 'INVENTORY_ITEM_ID_%'
        order by parameter_name;

        /*extract list of organization ids */
        SELECT to_number(char_value)
        BULK COLLECT INTO  l_org_id_tab
        from EGO_PUB_WS_CONFIG
        where session_id = p_session_id
        and web_service_name = 'GET_ITEM_STRUCTURE'
        and parameter_name like 'ORGANIZATION_ID_%'
        order by parameter_name;

        /*extract list of revision ids */
        SELECT to_number(char_value)
        BULK COLLECT INTO  l_rev_id_tab
        from EGO_PUB_WS_CONFIG
        where session_id = p_session_id
        and web_service_name = 'GET_ITEM_STRUCTURE'
        and parameter_name like 'REVISION_ID_%'
        order by parameter_name;

        /*extract list of structure names */
        SELECT char_value
        BULK COLLECT INTO  l_structure_name_tab
        from EGO_PUB_WS_CONFIG
        where session_id = p_session_id
        and web_service_name = 'GET_ITEM_STRUCTURE'
        and parameter_name like 'STRUCTURE_NAME_%'
        order by parameter_name;

        /*extract list of root node ids */
        SELECT to_number(char_value)
        BULK COLLECT INTO  l_root_node_id_tab
        from EGO_PUB_WS_CONFIG
        where session_id = p_session_id
        and web_service_name = 'GET_ITEM_STRUCTURE'
        and parameter_name like 'ROOT_NODE_ID_%'
        order by parameter_name;



        --setting explosion date to the current date
        l_explosion_date := sysdate;


        --computing number of items in list from organization id
        l_count := l_org_id_tab.Count;


        --inserting from XML into data into ODI structure input table
        FOR i IN 1..l_count LOOP

            --START VALIDATIONS-----------------------

            --validate organization id and/or name
            l_temp_varchar := l_org_id_tab(i);
            l_temp2_varchar := NULL;
            l_is_valid := Validate_Organization(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_index => i,
                                                p_org_id => l_temp_varchar,
                                                p_org_code => l_temp2_varchar,
                                                x_organization_id => l_org_id);
            --IF l_is_valid = FALSE THEN
                --TODO: Generate warning only and skip loop
            --    raise_application_error(-20104, 'Invalid Organization Id or Organization Name');
            --END IF;


            --validate item id
            l_temp_varchar := l_item_id_tab(i);
            l_is_valid := Validate_Item(p_session_id => p_session_id,
                                        p_odi_session_id => p_odi_session_id,
                                        p_index => i,
                                        p_inv_id => l_temp_varchar,
                                        p_org_id => l_org_id,
                                        x_inv_item_id => l_item_id);
            --IF l_is_valid = FALSE THEN
                --TODO: Generate warning only and skip loop
                --raise_application_error(-20104, 'Invalid Item Id or Name ' || l_segment1);
            --END IF;


            --validating revision information
            l_rev_id := to_number(l_rev_id_tab(i));
            l_temp2_varchar := NULL;
            l_is_valid := EGO_ITEM_WS_PVT.validate_revision_details(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_index => i,
                                              p_inv_id => l_item_id,
                                              p_org_id => l_org_id,
                                              p_rev_id => l_rev_id,
                                              p_revision => l_temp2_varchar,
                                              p_rev_date => l_explosion_date,
                                              p_revision_id => l_rev_id, --out var
                                              p_revision_date => l_explosion_date --out var
                                              );
            --IF l_is_valid = FALSE THEN
                --TODO: Generate warning only
            --    raise_application_error(-20104, 'Invalid Revision ID or Revision Label');
            --END IF;

            --validating structure name
            l_structure_name := l_structure_name_tab(i);
            l_is_valid := Validate_Structure_Name(p_session_id => p_session_id,
                                                  p_odi_session_id => p_odi_session_id,
                                                  p_str_name => l_structure_name,
                                                  p_org_id => l_org_id);


            --Validate if structure name provided for the batch exists for the current end-item
            l_is_valid := Validate_Item_Structure_Name(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_str_name => l_structure_name,
                                              p_item_id => l_item_id,
                                              p_org_id => l_org_id,
                                              p_input_index => i);

            --IF l_is_valid = FALSE THEN
                --TODO: Generate warning only and skip loop
            --    raise_application_error(-20104, 'Invalid Structure Name');
            --END IF;

            --END VALIDATIONS-----------------------


            INSERT
            INTO BOM_ODI_WS_ENTITIES(
              session_id,
              odi_session_id,
              ITEM_ID,
              ITEM_ORG_ID,
              ITEM_REV,
              structure_name,
              EXPLOSION_DATE,
              PUBLISH_FLAG,
              SEQUENCE_NUMBER,
              CREATION_DATE,
              CREATED_BY,
              ROOT_NODE_ID)
            VALUES(
               p_session_id,
               p_odi_session_id,
               l_item_id,
               l_org_id,
               l_rev_id,
               l_structure_name,
               l_explosion_date,
               'Y',
               i,
               sysdate,
               0,
               l_root_node_id_tab(i));

        END LOOP;


     --if mode is batch, get information from publication framework using batch_id
     WHEN l_mode = 'BATCH' THEN

        --retrieving batchId from input XML
        select to_number(extractValue(xmlcontent, '/structureQueryParameters/BatchStructureQueryParameters/BatchId'))
        into l_batch_id
        from EGO_PUB_WS_PARAMS
        where session_id = p_session_id;

        --retrieving structure name from publication framework params table
        select char_value
        into l_structure_name
        from EGO_PUB_PARAMETERS_V
        where type_id = l_batch_id and parameter_name = 'STRUCTURE_NAME';


        --retrieving explosion date from publication framework params table
        select date_value
        into l_explosion_date
        from EGO_PUB_PARAMETERS_V
        where type_id = l_batch_id and parameter_name = 'EXPLOSION_DATE';


        --retrieving all end-items batch from publication framework entity tables
        --and inserting data into ODI structure input table
        l_item_index :=0;
        FOR r in c_fwk_end_items(l_batch_id) LOOP

            l_item_index := l_item_index + 1;

            --retrieving item_id, org_id, and rev_id from publication
            --framework tables
            l_item_id := r.pk1_value;
            l_org_id := r.pk2_value;
            l_rev_id := r.pk3_value;

            --Validate organization id only once since it is the same for all
            --items in batch. If not valid, error out
            IF l_validate_org_id = TRUE THEN

                l_is_valid := Validate_Organization(p_session_id => p_session_id,
                                                    p_odi_session_id => p_odi_session_id,
                                                    p_index => l_item_index,
                                                    p_org_id => l_org_id,
                                                    x_organization_id => l_org_id);
                --IF l_is_valid = FALSE THEN
                --    raise_application_error(-20104, 'Invalid Organization Id');
                --END IF;
                l_validate_org_id :=FALSE;
            END IF;

            --Validate if structure name exists in the system for the given organization.
            --This validation must only happen once since it is the same for all
            --items in batch.
            IF l_validate_structure = TRUE THEN

                /*INSERT INTO emt_temp (Session_id, message)
                values (p_session_id, 'new in l_str_name:' || l_structure_name);*/


                l_is_valid := Validate_Structure_Name(p_session_id => p_session_id,
                                                      p_odi_session_id => p_odi_session_id,
                                                      p_str_name => l_structure_name,
                                                      p_org_id => l_org_id);


                /*INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'new out l_str_name:' || l_structure_name);
                */

                --NULL;
               /*
                IF l_is_valid = FALSE THEN
                    IF l_structure_name IS NULL THEN
                        --TODO: exit the loop without publishing any structure and
                        --generate warning instead of error
                        raise_application_error(-20104, 'Structure Name NOT provided');
                    ELSE
                        raise_application_error(-20104, 'Invalid Structure Name');
                    END IF;

                END IF;
                */
                l_validate_structure :=FALSE;
            END IF;


           --validate item id for current end-item.
            l_is_valid := Validate_Item(p_session_id => p_session_id,
                                        p_odi_session_id => p_odi_session_id,
                                        p_index => l_item_index,
                                        p_inv_id => l_item_id,
                                        p_org_id => l_org_id,
                                        x_inv_item_id => l_item_id);
            --IF l_is_valid = FALSE THEN
            --    NULL;
                --TODO: Generate warning here and skip this item
                --raise_application_error(-20104, 'Invalid Item Id');
            --END IF;

            --Validate if structure name provided for the batch exists for the current end-item
            l_is_valid := Validate_Item_Structure_Name(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_str_name => l_structure_name,
                                              p_item_id => l_item_id,
                                              p_org_id => l_org_id,
                                              p_input_index => l_item_index);


            l_is_valid := EGO_ITEM_WS_PVT.validate_revision_details(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_index => l_item_index,
                                              p_inv_id => l_item_id,
                                              p_org_id => l_org_id,
                                              p_rev_id => l_rev_id,
                                              p_revision => null,
                                              p_rev_date => l_explosion_date,
                                              p_revision_id => l_rev_id, --out var
                                              p_revision_date => l_explosion_date --out var
                                              );
            --IF l_is_valid = FALSE THEN
            --    raise_application_error(-20104, 'Invalid Revision ID or Revision Label');
            --END IF;

           --if item is valid, insert to input table, otherwise generate warning
           IF l_is_item_id_valid = TRUE THEN

                INSERT
                INTO BOM_ODI_WS_ENTITIES(
                  session_id,
                  odi_session_id,
                  ITEM_ID,
                  ITEM_ORG_ID,
                  ITEM_REV,
                  structure_name,
                  EXPLOSION_DATE,
                  PUBLISH_FLAG,
                  SEQUENCE_NUMBER,
                  CREATION_DATE,
                  CREATED_BY,
                  ROOT_NODE_ID)
                VALUES(
                  p_session_id,
                  p_odi_session_id,
                  l_item_id,
                  l_org_id,
                  l_rev_id,
                  l_structure_name,
                  l_explosion_date,
                  'Y',
                  l_item_index,
                  sysdate,
                  0,
                  -1);

            --ELSE
                --TODO: Generate warning here
                --raise_application_error(-20101, ' Warning: Invalid Item Id');
            END IF;


        END LOOP;


     WHEN l_mode = 'HMDM' THEN


            --retrieving organization_id from input XML
            l_temp_varchar := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/OrganizationId');
            l_temp2_varchar := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/OrganizationCode');
            --validate organization id or name
            l_is_valid := Validate_Organization(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_index => 1,
                                                p_org_id => l_temp_varchar,
                                                p_org_code => l_temp2_varchar,
                                                x_organization_id => l_org_id);
            --IF l_is_valid = FALSE THEN
            --    raise_application_error(-20104, 'Invalid Organization Id or Name');
            --END IF;


            --retrieving inventory_item_id from input XML
            l_temp_varchar := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemId');
            l_segment1 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment1');
            l_segment2 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment2');
            l_segment3 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment3');
            l_segment4 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment4');
            l_segment5 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment5');
            l_segment6 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment6');
            l_segment7 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment7');
            l_segment8 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment8');
            l_segment9 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment9');
            l_segment10 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment10');
            l_segment11 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment11');
            l_segment12 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment12');
            l_segment13 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment13');
            l_segment14 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment14');
            l_segment15 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment15');
            l_segment16 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment16');
            l_segment17 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment17');
            l_segment18 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment18');
            l_segment19 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment19');
            l_segment20 := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/InventoryItemName/Segment20');
            --validate item id or name
            l_is_valid := Validate_Item(p_session_id => p_session_id,
                                        p_odi_session_id => p_odi_session_id,
                                        p_index => 1,
                                        p_inv_id => l_temp_varchar,
                                        p_org_id => l_org_id,
                                        p_segment1 => l_segment1,
                                        p_segment2 => l_segment2,
                                        p_segment3 => l_segment3,
                                        p_segment4 => l_segment4,
                                        p_segment5 => l_segment5,
                                        p_segment6 => l_segment6,
                                        p_segment7 => l_segment7,
                                        p_segment8 => l_segment8,
                                        p_segment9 => l_segment9,
                                        p_segment10 => l_segment10,
                                        p_segment11 => l_segment11,
                                        p_segment12 => l_segment12,
                                        p_segment13 => l_segment13,
                                        p_segment14 => l_segment14,
                                        p_segment15 => l_segment15,
                                        p_segment16 => l_segment16,
                                        p_segment17 => l_segment17,
                                        p_segment18 => l_segment18,
                                        p_segment19 => l_segment19,
                                        p_segment20 => l_segment20,
                                        x_inv_item_id => l_item_id);
            --IF l_is_valid = FALSE THEN
            --    raise_application_error(-20104, 'Invalid Item Id or Name');
            --END IF;

            --retrieving revision_id, revision, and explosion date from input XML
            l_rev_id := to_number(Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/RevisionId'));
            l_temp2_varchar := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/Revision');
            --NOTE: Errors might arise from the conversion between varchar2 and date if the user provided date
            --format and the db format do not match. Watch out for this condition.
            l_explosion_date := to_date(Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/RevisionDate'));
            --validating revision information
            /*l_is_valid := Validate_Revision_Info(p_rev_id => l_temp_varchar,
                                                 p_revision => l_temp2_varchar,
                                                 p_inv_id => l_item_id,
                                                 p_org_id => l_org_id,
                                                 x_revision_id => l_rev_id);
              */
            l_is_valid := EGO_ITEM_WS_PVT.validate_revision_details(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_index => 1,
                                              p_inv_id => l_item_id,
                                              p_org_id => l_org_id,
                                              p_rev_id => l_rev_id,
                                              p_revision => l_temp2_varchar,
                                              p_rev_date => l_explosion_date,
                                              p_revision_id => l_rev_id, --out var
                                              p_revision_date => l_explosion_date --out var
                                              );


            --IF l_is_valid = FALSE THEN
            --    raise_application_error(-20104, 'Invalid Revision ID or Revision Label');
            --END IF;


            --retrieving structure_name from input XML
            l_structure_name := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/StructureName');
            l_is_valid := Validate_Structure_Name(p_session_id => p_session_id,
                                                  p_odi_session_id => p_odi_session_id,
                                                  p_str_name => l_structure_name,
                                                  p_org_id => l_org_id);

            --IF l_is_valid = FALSE THEN
            --    raise_application_error(-20104, 'Invalid Structure Name');
            --END IF;

            --Validate if structure name provided for the batch exists for the current end-item
            l_is_valid := Validate_Item_Structure_Name(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_str_name => l_structure_name,
                                              p_item_id => l_item_id,
                                              p_org_id => l_org_id,
                                              p_input_index => 1);

            --retrieving explosion_date/revision_date from input XML
            /*l_temp_varchar := Get_ODI_Input_Parameter(p_session_id, '/structureQueryParameters/RevisionDate');
            --validating revision date is valid date
            l_is_valid := Validate_revision_date(l_temp_varchar,
                                 l_item_id ,
                                 l_org_id,
                                 l_explosion_date);
            IF l_is_valid = FALSE THEN
                raise_application_error(-20104, 'Invalid Revision Date');
            END IF;*/

            INSERT
            INTO BOM_ODI_WS_ENTITIES(
              session_id,
              odi_session_id,
              ITEM_ID,
              ITEM_ORG_ID,
              ITEM_REV,
              structure_name,
              EXPLOSION_DATE,
              PUBLISH_FLAG,
              SEQUENCE_NUMBER,
              CREATION_DATE,
              CREATED_BY,
              ROOT_NODE_ID)
            VALUES(
               p_session_id,
               p_odi_session_id,
               l_item_id,
               l_org_id,
               l_rev_id,
               l_structure_name,
               l_explosion_date,
               'Y',
               1,
               sysdate,
               0,
               -1);


     WHEN l_mode = 'LIST' THEN


        /*extract list of inventory item ids */
        SELECT   extractValue(lang_code, '/InventoryItemId')
        BULK COLLECT INTO  l_item_id_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemId') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment1 */
        SELECT   extractValue(lang_code, '/Segment1')
        BULK COLLECT INTO  l_item_segment1_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment1') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment2 */
        SELECT   extractValue(lang_code, '/Segment2')
        BULK COLLECT INTO  l_item_segment2_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment2') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment3 */
        SELECT   extractValue(lang_code, '/Segment3')
        BULK COLLECT INTO  l_item_segment3_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment3') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment4 */
        SELECT   extractValue(lang_code, '/Segment4')
        BULK COLLECT INTO  l_item_segment4_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment4') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment5 */
        SELECT   extractValue(lang_code, '/Segment5')
        BULK COLLECT INTO  l_item_segment5_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment5') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment6 */
        SELECT   extractValue(lang_code, '/Segment6')
        BULK COLLECT INTO  l_item_segment6_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment6') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment7 */
        SELECT   extractValue(lang_code, '/Segment7')
        BULK COLLECT INTO  l_item_segment7_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment7') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment8 */
        SELECT   extractValue(lang_code, '/Segment8')
        BULK COLLECT INTO  l_item_segment8_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment8') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment9 */
        SELECT   extractValue(lang_code, '/Segment9')
        BULK COLLECT INTO  l_item_segment9_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment9') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment10 */
        SELECT   extractValue(lang_code, '/Segment10')
        BULK COLLECT INTO  l_item_segment10_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment10') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment11 */
        SELECT   extractValue(lang_code, '/Segment11')
        BULK COLLECT INTO  l_item_segment11_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment11') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment12 */
        SELECT   extractValue(lang_code, '/Segment12')
        BULK COLLECT INTO  l_item_segment12_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment12') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment13 */
        SELECT   extractValue(lang_code, '/Segment13')
        BULK COLLECT INTO  l_item_segment13_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment13') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment14 */
        SELECT   extractValue(lang_code, '/Segment14')
        BULK COLLECT INTO  l_item_segment14_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment14') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment15 */
        SELECT   extractValue(lang_code, '/Segment15')
        BULK COLLECT INTO  l_item_segment15_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment15') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment16 */
        SELECT   extractValue(lang_code, '/Segment16')
        BULK COLLECT INTO  l_item_segment16_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment16') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment17 */
        SELECT   extractValue(lang_code, '/Segment17')
        BULK COLLECT INTO  l_item_segment17_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment17') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment18 */
        SELECT   extractValue(lang_code, '/Segment18')
        BULK COLLECT INTO  l_item_segment18_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment18') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment19 */
        SELECT   extractValue(lang_code, '/Segment19')
        BULK COLLECT INTO  l_item_segment19_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment19') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of inventory item segment20 */
        SELECT   extractValue(lang_code, '/Segment20')
        BULK COLLECT INTO  l_item_segment20_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/InventoryItemName/Segment20') )) langcode
              WHERE session_id=p_session_id
              );


        /*extract list of organization ids */
        SELECT   extractValue(lang_code, '/OrganizationId')
        BULK COLLECT INTO  l_org_id_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/OrganizationId') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of organization codes */
        SELECT   extractValue(lang_code, '/OrganizationCode')
        BULK COLLECT INTO  l_org_name_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/OrganizationCode') )) langcode
              WHERE session_id=p_session_id
              );


        /*extract list of revision ids */
        SELECT   extractValue(lang_code, '/RevisionId')
        BULK COLLECT INTO  l_rev_id_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/RevisionId') )) langcode
              WHERE session_id=p_session_id
              );

        /*extract list of revision codes */
        SELECT   extractValue(lang_code, '/Revision')
        BULK COLLECT INTO  l_rev_name_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/Revision') )) langcode
              WHERE session_id=p_session_id
              );


        /*extract list of revision dates or explosion dates */
        --IMPORTANT NOTE:  explosion_date might casue issues during the conversion
        --between varchar2 and date type as the format for the date stored in database might be
        --different from the format provided by the user. perhaps specify format in to_char()?
        SELECT   extractValue(lang_code, '/RevisionDate')
        BULK COLLECT INTO  l_explosion_date_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/RevisionDate') )) langcode
              WHERE session_id=p_session_id
              );


        /*extract list of structure names */
        SELECT   extractValue(lang_code, '/StructureName')
        BULK COLLECT INTO  l_structure_name_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, 'structureQueryParameters/ParametersForListOfItems/ListOfItemStructureQueryParams/StructureName') )) langcode
              WHERE session_id=p_session_id
              );


        --computing number of items in list from organization id or name since
        --one of them must be populated
        l_count := l_org_id_tab.Count;
        IF l_org_name_tab.Count > l_count THEN
            l_count := l_org_name_tab.Count;
        END IF;

        --inserting from XML into data into ODI structure input table
        FOR i IN 1..l_count LOOP

            --START VALIDATIONS-----------------------

            --validate organization id and/or name
            IF l_org_id_tab.Count >= i THEN
               l_temp_varchar := l_org_id_tab(i);
            ELSE
               l_temp_varchar := NULL;
            END IF;
            IF l_org_name_tab.Count >= i THEN
               l_temp2_varchar := l_org_name_tab(i);
            ELSE
               l_temp2_varchar := NULL;
            END IF;
            l_is_valid := Validate_Organization(p_session_id => p_session_id,
                                                p_odi_session_id => p_odi_session_id,
                                                p_index => i,
                                                p_org_id => l_temp_varchar,
                                                p_org_code => l_temp2_varchar,
                                                x_organization_id => l_org_id);
            --IF l_is_valid = FALSE THEN
                --TODO: Generate warning only and skip loop
            --    raise_application_error(-20104, 'Invalid Organization Id or Organization Name');
            --END IF;


            --validate item id and/or name
            IF l_item_id_tab.Count >= i THEN
               l_temp_varchar := l_item_id_tab(i);
            ELSE
               l_temp_varchar := NULL;
            END IF;
            IF l_item_segment1_tab.Count >= i THEN
               l_segment1 := l_item_segment1_tab(i);
            ELSE
               l_segment1 := NULL;
            END IF;
            IF l_item_segment2_tab.Count >= i THEN
               l_segment2 := l_item_segment2_tab(i);
            ELSE
               l_segment2 := NULL;
            END IF;
            IF l_item_segment3_tab.Count >= i THEN
               l_segment3 := l_item_segment3_tab(i);
            ELSE
               l_segment3 := NULL;
            END IF;
            IF l_item_segment4_tab.Count >= i THEN
               l_segment4 := l_item_segment4_tab(i);
            ELSE
               l_segment4 := NULL;
            END IF;
            IF l_item_segment5_tab.Count >= i THEN
               l_segment5 := l_item_segment5_tab(i);
            ELSE
               l_segment5 := NULL;
            END IF;
            IF l_item_segment6_tab.Count >= i THEN
               l_segment6 := l_item_segment6_tab(i);
            ELSE
               l_segment6 := NULL;
            END IF;
            IF l_item_segment7_tab.Count >= i THEN
               l_segment7 := l_item_segment7_tab(i);
            ELSE
               l_segment7 := NULL;
            END IF;
            IF l_item_segment8_tab.Count >= i THEN
               l_segment8 := l_item_segment8_tab(i);
            ELSE
               l_segment8 := NULL;
            END IF;
            IF l_item_segment9_tab.Count >= i THEN
               l_segment9 := l_item_segment9_tab(i);
            ELSE
               l_segment9 := NULL;
            END IF;
            IF l_item_segment10_tab.Count >= i THEN
               l_segment10 := l_item_segment10_tab(i);
            ELSE
               l_segment10 := NULL;
            END IF;
            IF l_item_segment11_tab.Count >= i THEN
               l_segment11 := l_item_segment11_tab(i);
            ELSE
               l_segment11 := NULL;
            END IF;
            IF l_item_segment12_tab.Count >= i THEN
               l_segment12 := l_item_segment12_tab(i);
            ELSE
               l_segment12 := NULL;
            END IF;
            IF l_item_segment13_tab.Count >= i THEN
               l_segment13 := l_item_segment13_tab(i);
            ELSE
               l_segment13 := NULL;
            END IF;
            IF l_item_segment14_tab.Count >= i THEN
               l_segment14 := l_item_segment14_tab(i);
            ELSE
               l_segment14 := NULL;
            END IF;
            IF l_item_segment15_tab.Count >= i THEN
               l_segment15 := l_item_segment15_tab(i);
            ELSE
               l_segment15 := NULL;
            END IF;
            IF l_item_segment16_tab.Count >= i THEN
               l_segment16 := l_item_segment16_tab(i);
            ELSE
               l_segment16 := NULL;
            END IF;
            IF l_item_segment17_tab.Count >= i THEN
               l_segment17 := l_item_segment17_tab(i);
            ELSE
               l_segment17 := NULL;
            END IF;
            IF l_item_segment18_tab.Count >= i THEN
               l_segment18 := l_item_segment18_tab(i);
            ELSE
               l_segment18 := NULL;
            END IF;
            IF l_item_segment19_tab.Count >= i THEN
               l_segment19 := l_item_segment19_tab(i);
            ELSE
               l_segment19 := NULL;
            END IF;
            IF l_item_segment20_tab.Count >= i THEN
               l_segment20 := l_item_segment20_tab(i);
            ELSE
               l_segment20 := NULL;
            END IF;

            l_is_valid := Validate_Item(p_session_id => p_session_id,
                                        p_odi_session_id => p_odi_session_id,
                                        p_index => i,
                                        p_inv_id => l_temp_varchar,
                                        p_org_id => l_org_id,
                                        p_segment1 => l_segment1,
                                        p_segment2 => l_segment2,
                                        p_segment3 => l_segment3,
                                        p_segment4 => l_segment4,
                                        p_segment5 => l_segment5,
                                        p_segment6 => l_segment6,
                                        p_segment7 => l_segment7,
                                        p_segment8 => l_segment8,
                                        p_segment9 => l_segment9,
                                        p_segment10 => l_segment10,
                                        p_segment11 => l_segment11,
                                        p_segment12 => l_segment12,
                                        p_segment13 => l_segment13,
                                        p_segment14 => l_segment14,
                                        p_segment15 => l_segment15,
                                        p_segment16 => l_segment16,
                                        p_segment17 => l_segment17,
                                        p_segment18 => l_segment18,
                                        p_segment19 => l_segment19,
                                        p_segment20 => l_segment20,
                                        x_inv_item_id => l_item_id);
            --IF l_is_valid = FALSE THEN
                --TODO: Generate warning only and skip loop
                --raise_application_error(-20104, 'Invalid Item Id or Name ' || l_segment1);
            --END IF;

            --validating revision information
            IF l_rev_id_tab.Count >= i THEN
               l_rev_id := to_number(l_rev_id_tab(i));
            ELSE
               l_rev_id := NULL;
            END IF;
            IF l_rev_name_tab.Count >= i THEN
               l_temp2_varchar := l_rev_name_tab(i);
            ELSE
               l_temp2_varchar := NULL;
            END IF;
            IF l_explosion_date_tab.Count >= i THEN
               --NOTE: watch for conversion between varchar2 and date.
               --there might be differences bewteen DB format and user provided
               --format
               l_explosion_date := to_date(l_explosion_date_tab(i));
            ELSE
               l_explosion_date := NULL;
            END IF;

            /*l_is_valid := Validate_Revision_Info(p_rev_id => l_temp_varchar,
                                                 p_revision => l_temp2_varchar,
                                                 p_inv_id => l_item_id,
                                                 p_org_id => l_org_id,
                                                 x_revision_id => l_rev_id);

            */
            l_is_valid := EGO_ITEM_WS_PVT.validate_revision_details(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_index => i,
                                              p_inv_id => l_item_id,
                                              p_org_id => l_org_id,
                                              p_rev_id => l_rev_id,
                                              p_revision => l_temp2_varchar,
                                              p_rev_date => l_explosion_date,
                                              p_revision_id => l_rev_id, --out var
                                              p_revision_date => l_explosion_date --out var
                                              );

            --IF l_is_valid = FALSE THEN
                --TODO: Generate warning only
            --    raise_application_error(-20104, 'Invalid Revision ID or Revision Label');
            --END IF;


            --validating structure name
            l_structure_name := l_structure_name_tab(i);
            l_is_valid := Validate_Structure_Name(p_session_id => p_session_id,
                                                  p_odi_session_id => p_odi_session_id,
                                                  p_str_name => l_structure_name,
                                                  p_org_id => l_org_id);


            --Validate if structure name provided for the batch exists for the current end-item
            l_is_valid := Validate_Item_Structure_Name(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_str_name => l_structure_name,
                                              p_item_id => l_item_id,
                                              p_org_id => l_org_id,
                                              p_input_index => i);

            --IF l_is_valid = FALSE THEN
                --TODO: Generate warning only and skip loop
            --    raise_application_error(-20104, 'Invalid Structure Name');
            --END IF;

            --validating revision date is valid date
            /*l_is_valid := Validate_revision_date( l_explosion_date_tab(i),
                                                   l_item_id,
                                                  l_org_id,
                                                  l_explosion_date);
            IF l_is_valid = FALSE THEN
                --TODO: Generate warning only and skip loop
                raise_application_error(-20104, 'Invalid Revision Date');
            END IF;*/

            --END VALIDATIONS-----------------------


            INSERT
            INTO BOM_ODI_WS_ENTITIES(
              session_id,
              odi_session_id,
              ITEM_ID,
              ITEM_ORG_ID,
              ITEM_REV,
              structure_name,
              EXPLOSION_DATE,
              PUBLISH_FLAG,
              SEQUENCE_NUMBER,
              CREATION_DATE,
              CREATED_BY,
              ROOT_NODE_ID)
            VALUES(
               p_session_id,
               p_odi_session_id,
               l_item_id,
               l_org_id,
               l_rev_id,
               l_structure_name,
               l_explosion_date,
               'Y',
               i,
               sysdate,
               0,
               -1);

        END LOOP;

  END CASE;

 END Create_Entities_Structure;



--Given a component code in the form of a string contained the concatenated
--inventory_item_id values, this procedure converts the inventory_item_ids
--into inventory_item_names and formats the output in the following manner:
--<ComponentCode>
--      <ItemReference>
--          <Name>A</Name>
--          <Sequence>1</Sequence>
--      </ItemReference>
--          <ItemReference>
--          <Name>B</Name>
--          <Sequence>2</Sequence>
--      </ItemReference>
--</ComponentCode>
FUNCTION Decode_Component_Code(component_code IN VARCHAR2) RETURN CLOB
IS

--str VARCHAR2(1000); commented for bug fix 8858296
str CLOB; --added for bug fix 8858296
item_name VARCHAR2(4000);
l_bom_item_type NUMBER;
l_icc_name VARCHAR2(4000);
item_id VARCHAR2(100);
item_count  NUMBER;
--start_index NUMBER;
end_index NUMBER;
l_component_code VARCHAR2(4000);

BEGIN
    item_count := length(component_code)/20;
    --str := 'Count3: ' || item_count || ' ';
    str := to_clob('<ComponentPath>'); --added to_clob for bug fix 8858296
    l_component_code := component_code;

    for i in 1..item_count
    loop
         --retrieving inventory_item_id from component_code string
         item_id := ltrim(substr(l_component_code,0,20),'0I');
         l_component_code := substr(l_component_code,21);

         --converting inventory_item_id to inventory_item_name and related info
         select msi.concatenated_segments,
         msi.bom_item_type,
         icc.concatenated_segments
         into item_name, l_bom_item_type, l_icc_name
         from MTL_SYSTEM_ITEMS_kfv msi,
         MTL_ITEM_CATALOG_GROUPS_kfv icc
         where
         inventory_item_id = item_id
         and msi.item_catalog_group_id =icc.item_catalog_group_id(+);

         --formatting as XML
         --added to_clob for bug fix 8858296
         str := str || to_clob('<ItemReference><Name>' || item_name || '</Name><Sequence>' || i || '</Sequence>'  || '<BomItemType>' ||  l_bom_item_type || '</BomItemType><CatalogCategoryName>' || l_icc_name || '</CatalogCategoryName></ItemReference>');

    end loop;

    str := str || to_clob('</ComponentPath>');

RETURN str;
END;


/*
If the user provides only the Revision and does NOT provide Explosion Date then, system would
calculate the explosion date based on the selected Item Revision. The explosion date would be
End Effective Date (for Past Revision), Sys Date (for Current Revision) and Start Effective Date
(for Future Revision). If the user provies both Revision and Explosion Date then, system would
check if the selected Item Revision is effective on the given Explosion Date. If it is not
effective on the given explosion date, system would select the Item Revision effective on the
given explosion date. In other words, Explosion Date would take precedence over Item Revision.
Also, as discussed please ensure that the Item Web Service will honour the Fixed Revision
Floating Revision functionality for the components.
*/
/*FUNCTION Compute_Revision_Date(p_rev_date IN DATE,
                               p_revision_id NUMBER,
                               p_revision_label VARCHAR2,
                               p_inventory_item_id IN NUMBER,
                               p_organization_id IN NUMBER)
                               RETURN DATE
IS

l_revision_id NUMBER;
l_revision_label VARCHAR2(100);
l_rev_date DATE;
l_effective_date DATE;
l_rev_end_date DATE;


--cursor to retrieve revision label
CURSOR c_get_revision_label(p_inv_item_id NUMBER,
                            p_org_id NUMBER,
                            p_rev_id NUMBER) IS
select revision_id,
       revision,
       inventory_item_id,
       organization_id,
       effectivity_date,
       (select nvl( min(b.effectivity_date)-(1/86400),to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss')) end_date from mtl_item_revisions_b b
        where b.inventory_item_id = a.inventory_item_id and
              b.organization_id = a.organization_id and
              b.effectivity_date > a.effectivity_date) end_date,
       implementation_date
from mtl_item_revisions_b a
where a.organization_id = p_org_id
      and inventory_item_id = p_inventory_item_id
      and revision_id = p_rev_id;


--cursor to retrieve revision identifier
CURSOR c_get_revision_id(p_inv_item_id NUMBER,
                            p_org_id NUMBER,
                            p_rev_label VARCHAR) IS
select revision_id,
       revision,
       inventory_item_id,
       organization_id,
       effectivity_date,
       (select nvl( min(b.effectivity_date)-(1/86400),to_date('9999/12/31 00:00:00','yyyy/mm/dd hh24:mi:ss')) end_date from mtl_item_revisions_b b
        where b.inventory_item_id = a.inventory_item_id and
              b.organization_id = a.organization_id and
              b.effectivity_date > a.effectivity_date) end_date,
       implementation_date
from mtl_item_revisions_b a
where a.organization_id = p_org_id
      and inventory_item_id = p_inventory_item_id
      and revision = p_rev_label;

BEGIN

       l_rev_date := p_rev_date;
       l_revision_id := p_revision_id;
       l_revision_label := p_revision_label;


       --if user provided either revision id or code/label
       IF l_revision_id IS NOT NULL OR l_revision_label IS NOT NULL THEN

          --first, derive both, revision id and revision label/code
          --from available parameter
          IF l_revision_id IS NOT NULL THEN

              FOR r in c_get_revision_label(p_inventory_item_id,
                                            p_organization_id,
                                            l_revision_id) LOOP
                 l_revision_label := r.revision;
                 l_effective_date  := r.effectivity_date;
                 l_rev_end_date := r.end_date;
              END LOOP;

          ELSE
              FOR r in c_get_revision_id(p_inventory_item_id,
                                         p_organization_id,
                                         l_revision_label) LOOP
                 l_revision_id := r.revision_id;
                 l_effective_date  := r.effectivity_date;
                 l_rev_end_date := r.end_date;
              END LOOP;
          END IF;

          --debugging statement remove
          --INSERT INTO emt_temp (Session_id, message)
          --       values (-1, 'l_revision_label:' || l_revision_label);
          --INSERT INTO emt_temp (Session_id, message)
          --       values (-1, 'l_revision_id:' || l_revision_id);
          --INSERT INTO emt_temp (Session_id, message)
          --       values (-1, 'l_effective_date:' || l_effective_date);
          --INSERT INTO emt_temp (Session_id, message)
          --       values (-1, 'l_rev_end_date:' || l_rev_end_date);
          --

          --once we have both, revision ID and revision label
          IF l_revision_id IS NOT NULL and l_revision_label IS NOT NULL THEN

                --if revision date was not provided, assume effectivity
                --date as explosion date
                IF l_rev_date IS NULL THEN
                   l_rev_date := l_effective_date;
                ELSE
                    --if revision date was provided, validate
                    IF l_rev_date > l_effective_date THEN

                        IF l_rev_date < l_rev_end_date THEN
                            --rev date is ok, use only revision date
                            --and not revision id
                            l_revision_id := NULL;
                        ELSE
                            --revision date is greater than end date,
                            --force it to be effectivity date
                            l_rev_date := l_effective_date;
                        END IF;

                    ELSE
                       --if revision date is before the effectivity date
                       --force it to be equal to effectivity date
                       l_rev_date := l_effective_date;
                    END IF;



                END IF;

          ELSE

              --if either revision id or revision code/label are null,
              --then error out
              IF l_revision_id IS NOT NULL THEN
                  raise_application_error(-20104, 'Invalid Revision Id');
              ELSE
                  raise_application_error(-20100, 'Invalid Revision Code/Label');
              END IF;

          END IF;


       --if user did not provide revision id or code/label
       --ELSE for IF p_revision_id IS NOT NULL OR p_rev_label IS NOT NULL THEN
       ELSE

          --if user provided explosion_date, validate it
          IF l_rev_date IS NOT NULL THEN


              --revision date has already been validated, maybe next
              --validation is not required?
              NULL;
              --validate revision_date
              --Validate_revision_date(p_rev_date => to_char(l_rev_date),
              --                       p_inventory_item_id => p_inventory_item_id,
              --                       p_organization_id => p_organization_id,
              --                       x_rev_date => l_rev_date);

          --if user did not provide explosion_date, revision id or revision code,
          --assume explosion date is today's date
          ELSE
              l_rev_date := sysdate;

          END IF;

       END IF;


        if ((revisionId != null) || (revision != null)) {
            RevisionVVOImpl revVO = getRevisionVVO();
            //Date[] rev_date = null;
            whereClause =
                    "(organization_id = :1) and (inventory_item_id = :2)";

            if (revisionId != null) {
                whereClause = whereClause + " and revision_id = :3 ";
                //" (organization_id = :1) and (inventory_item_id = :2) and (revision_id = :3)";
                revVO.setWhereClause(whereClause.toString());
                revVO.setWhereClauseParam(0, organizationId);
                revVO.setWhereClauseParam(1, inventoryItemId);
                revVO.setWhereClauseParam(2, revisionId);
            } else {
                if (revision != null) {
                    whereClause = whereClause + " and revision = :3 ";
                    revVO.setWhereClause(whereClause.toString());
                    revVO.setWhereClauseParam(0, organizationId);
                    revVO.setWhereClauseParam(1, inventoryItemId);
                    revVO.setWhereClauseParam(2, revision);
                }
            }
            revVO.executeQuery();
            RevisionVVORowImpl revVORow = (RevisionVVORowImpl)revVO.first();
            if (revVORow != null) {
                if (revisionId == null)
                    revisionId = revVORow.getRevisionId();

                if (revision == null)
                    revision = revVORow.getRevision();

                Date effectiveDate = revVORow.getEffectivityDate();
                Date revisionEndDate = revVORow.getEndDate();

                if (revisionDate == null) {
                    revisionDate = effectiveDate;
                }
                else {
                    if ((revisionDate.compareTo(effectiveDate) == 1)) {
                        if (revisionDate.compareTo(revisionEndDate) != -1) {
                            revisionDate = effectiveDate;
                        } else {
                            revisionId = null;
                        }
                    } else {
                        revisionDate = effectiveDate;
                    }
                }

            } else {
                if (revisionId != null) {
                    throw new OAException("EGO", "EGO_ITEM_SVC_INCORRECT_REV_ID");
                } else {
                    throw new OAException("EGO", "EGO_ITEM_SVC_INCORRECT_REV");
                }
            }

        }

        //End of if(revisionId != null || revisionLabel != null)
        else {
            if (revisionDate != null) {
                //Perform validations on revision date and throw error if not valid.
                 validateRevisionDate(organizationId, inventoryItemId, revisionDate);
            } else {
                revisionDate = txn.getCurrentUserDate();
            }
        }

        if (txn.isLoggingEnabled(OAFwkConstants.STATEMENT)) {
            txn.writeDiagnostics(this, "Validated revision",
                                 OAFwkConstants.STATEMENT);
            txn.writeDiagnostics(this, "revisionId " + revisionId,
                                 OAFwkConstants.STATEMENT);
            txn.writeDiagnostics(this, "revision " + revisionId,
                                 OAFwkConstants.STATEMENT);
            txn.writeDiagnostics(this, "revisionDate " + revisionId,
                                 OAFwkConstants.STATEMENT);

        }



        RETURN l_rev_date;

END Compute_Revision_Date;*/


/*
PROCEDURE Check_Publish_Privilege(p_session_id IN NUMBER)
IS

  l_sec_predicate VARCHAR2(32767);
  l_dynamic_update_sql VARCHAR2(32767);
  l_dynamic_sql VARCHAR2(32767);
  l_item_id NUMBER;
  l_org_id NUMBER;
  l_rev_id NUMBER;
  p_priv_check VARCHAR2(100);
  x_return_status VARCHAR2(100);

BEGIN

   --debugging statement remove
   --  INSERT INTO emt_temp (Session_id, message)
   --              values (p_session_id, 'Entering Check_Publish_Privilege ');


   p_priv_check := 'EGO_PUBLISH_ITEM';

   --dbms_output.put_line(' calling EGO_DATA_SECURITY.get_security_predicat ');
   EGO_DATA_SECURITY.get_security_predicate
       (p_api_version      => 1.0
       ,p_function         => p_priv_check -- 'EGO_VIEW_ITEM'
       ,p_object_name      => 'EGO_ITEM'
       ,p_user_name        => 'HZ_PARTY:'||TO_CHAR(FND_GLOBAL.PARTY_ID) --FND_GLOBAL.PARTY_ID  --'HZ_PARTY:'||TO_CHAR(G_PARTY_ID)
       ,p_statement_type   => 'EXISTS'
       ,p_pk1_alias        => 'i.pk1_value'
       ,p_pk2_alias        => 'i.pk2_value'
       ,p_pk3_alias        => NULL
       ,p_pk4_alias        => NULL
       ,p_pk5_alias        => NULL
       ,x_predicate        => l_sec_predicate
       ,x_return_status    => x_return_status );


 --INSERT INTO emt_temp (Session_id, message)
 --                values (p_session_id, 'x_return_status: ' || x_return_status);

 --INSERT INTO emt_temp (Session_id, message)
 --                values (p_session_id, 'p_user_name: ' || 'HZ_PARTY:'||TO_CHAR(FND_GLOBAL.PARTY_ID));

  --debugging statement remove
  --   INSERT INTO emt_temp (Session_id, message)
  --               values (p_session_id, 'l_sec_predicate: ' || l_sec_predicate);


  IF x_return_status IN ('T','F')  THEN

      IF l_sec_predicate IS NOT NULL THEN

      l_dynamic_sql := ' select pk1_value, pk2_value, pk3_value ' ||
                         ' from EGO_ODI_WS_ENTITIES i ' ||
                         ' where i.session_id = :1 ' ||
                         ' AND nvl(i.REF1_VALUE, ''Y'') = ''Y'' ' ||
                         ' AND NOT ' || l_sec_predicate;

      --debugging statement remove
    -- INSERT INTO emt_temp (Session_id, message)
    --             values (p_session_id, 'sql: ' || l_dynamic_sql);

      END IF;

   END IF;


END Check_Publish_Privilege;
*/


/*This procedure is in charge of exploding the second level of an ICC structure.
  In concrete, this procedure performe the following actions:
  1. Finds all the first level components of the ICC-Structure that have been
     previously retrieved by the EGO_GETICCSTRUCTURE ODI Package
  2. loops through the first level components and identifies which ones
     are of type OPTION_CLASS
  3. ODI_SESSION_ID un table EGO_PUB_WS_CONFIG (that contains parameters to
     execute ODI scenario as subroutine) is set to -1 to avoid conflicts
     with ODI main scenario invoking  ODI scenario as subroutine while
     reading input parameters.
*/
PROCEDURE Explode_ICC_Structure(p_session_id IN NUMBER,
                                p_odi_session_id IN NUMBER)
IS

l_mode VARCHAR(100);
l_application_id NUMBER;
l_responsibility_id NUMBER;
l_user_id NUMBER;
l_batch_id NUMBER;
l_batch_size NUMBER :=0;

--for security
l_fnd_user_name VARCHAR2(100);
l_responsibility_name VARCHAR2(100);
l_responsibility_appl_name VARCHAR2(100);
l_security_group_name VARCHAR2(100);

l_session_id NUMBER := p_session_id;
l_inventory_item_id NUMBER;
l_organization_id NUMBER;
l_revision_id NUMBER;
l_structure_name VARCHAR2(100) := 'Flow';

--component revisions information
l_comp_rev VARCHAR2(100);
l_comp_rev_id NUMBER;
l_comp_rev_label VARCHAR2(100);
l_comp_parent_rev VARCHAR2(100);
l_comp_rev_high_date DATE;

--x_rev_date DATE;
--x_rev_id NUMBER;
l_valid BOOLEAN;


--bom explosion configurability
l_levels_to_explode NUMBER;
l_explode_option NUMBER;
l_explode_standard VARCHAR2(10);
l_ordered_by NUMBER :=1;

x_err_msg  VARCHAR2(1000);
x_error_code NUMBER;
x_group_id NUMBER :=654;
x_return_status VARCHAR2(1);

--l_item_information VARCHAR2(1000);

--array to store single_value parameter names
TYPE parameter_name_array_type IS VARRAY(15) OF VARCHAR2(1000);
l_parameter_name_array parameter_name_array_type;

--array to store single_value parameter names
TYPE parameter_value_array_type IS VARRAY(15) OF VARCHAR2(1000);
l_parameter_value_array parameter_value_array_type;


--cursor to retrieve the all 1st level components generated by executing
--the EGO_GETICCSTRUCTURE ODI Package
cursor c_first_level_components(p_session_id NUMBER, p_odi_session_id NUMBER) is
select parent_sequence_id,
       pk1_value,
       ref1_value, /*BOM_ITEM_TYPE*/
       ref2_value, /*INVENTORY_ITEM_ID*/
       ref3_value, /*ORGANIZATION_ID*/
       ref4_value, /*REVISION_ID*/
       ref5_value, /*STRUCTURE_TYPE*/
       ref6_value  /*STRUCTURE_NAME*/
from EGO_PUB_WS_FLAT_RECS
where session_id = p_session_id
      and odi_session_id = p_odi_session_id
      and entity_type = 'ICCSH_COMP';


BEGIN


     --looping through all the components found for the end-item during the
     --bom explosion procedure to record their current revision and revision_id
     for comp_rec in c_first_level_components(p_session_id, p_odi_session_id)
     loop

         --If Component is of type OPTION_CLASS (BOM_ITEM_TYPE=2), then
         -- execute getItemStructure web service for current item
         IF comp_rec.ref1_value = '2' THEN

                 l_batch_size := l_batch_size + 1;

                 --Generating concatenated string containing information for which the structure will be published
                 --FORMAT: INVENTORY_ITEM_ID, ORGANIZATION_ID, REVISION_ID, STRUCTURE_TYPE, STRUCTURE_NAME
                 --l_item_information := comp_rec.ref2_value || ',' || comp_rec.ref3_value || ',' || comp_rec.ref4_value || ',' || comp_rec.ref5_value || ',' || comp_rec.ref6_value;

                 --INSERT NEW PARAMETER INVENTORY_ITEM_ID IN EGO_PUB_WS_CONFIG
                 INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               'INVENTORY_ITEM_ID_' || l_batch_size,
                               2,
                               comp_rec.ref2_value,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

                 --INSERT NEW PARAMETER ORGANIZATION_ID IN EGO_PUB_WS_CONFIG
                 INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               'ORGANIZATION_ID_' || l_batch_size,
                               2,
                               comp_rec.ref3_value,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

                 --INSERT NEW PARAMETER REVISION_ID IN EGO_PUB_WS_CONFIG
                 INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               'REVISION_ID_' || l_batch_size,
                               2,
                               comp_rec.ref4_value,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

                 --INSERT NEW PARAMETER STRUCTURE_NAME IN EGO_PUB_WS_CONFIG
                 INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               'STRUCTURE_NAME_' || l_batch_size,
                               2,
                               comp_rec.ref6_value,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');


                 --INSERT NEW PARAMETER ROOT_NODE_ID IN EGO_PUB_WS_CONFIG
                 INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                        VALUES (p_session_id,
                                -1,
                               'ROOT_NODE_ID_' || l_batch_size,
                               2,
                               comp_rec.parent_sequence_id,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

         END IF;


     end loop; --end for all 1st level components


     --If we need to explode the bom at least for one of the first level components
     --then generate parameters to execute EGO_GETITEMSTRUCTURE web service as a
     --subroutine (this only happens if at least one first level component is of type
     --OPTION_CLASS)
     IF l_batch_size > 0 THEN


               --Create parameter names
               l_parameter_name_array := parameter_name_array_type('MODE',
                                                          'PUBLISH_REVISIONS',
                                                          'PUBLISH_STRUCT_AGS',
                                                          'PUBLISH_COMPONENTS',
                                                          'PUBLISH_COMP_REF',
                                                          'PUBLISH_COMP_SUBS',
                                                          'PUBLISH_COMP_AGS',
                                                          'LEVELS_TO_EXPLODE',
                                                          'EXPLODE_OPTION',
                                                          'EXPLODE_STD_BOM',
                                                          'RETURN_PAYLOAD',
                                                          'PUBLISH_COMP_OVR_AGS',
                                                          'PUBLISH_COMP_EXCLUSIONS',
                                                          'PUBLISH_VS_EXCLUSIONS'
                                                          );

               --Create parameter values
               l_parameter_value_array := parameter_value_array_type('SUBROUTINE', --MODE
                                                          'Y',                   --PUBLISH_REVISIONS
                                                          'N',                   --PUBLISH_STRUCT_AGS
                                                          'Y',                   --PUBLISH_COMPONENTS
                                                          'N',                   --PUBLISH_COMP_REF
                                                          'N',                   --PUBLISH_COMP_SUBS
                                                          'Y',                   --PUBLISH_COMP_AGS
                                                          '1',                   --LEVELS_TO_EXPLODE
                                                          '2',                   --EXPLODE_OPTION
                                                          'Y',                   --EXPLODE_STD_BOM
                                                          'Y',                   --RETURN_PAYLOAD
                                                          'N',                   --PUBLISH_COMP_OVR_AGS
                                                          'N',                   --PUBLISH_COMP_EXCLUSIONS
                                                          'N'                    --PUBLISH_VS_EXCLUSIONS
                                                          );



               FOR position IN 1..l_parameter_name_array.COUNT
                  LOOP

                       --INSERTING PARAMETER NAME AND VALUE IN EGO_PUB_WS_CONFIG
                       INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               l_parameter_name_array(position),
                               2,
                               l_parameter_value_array(position),
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

               END LOOP;

               --retrieving and storing FND_USER_NAME
               select fnd_user_name
               into l_fnd_user_name
               from EGO_PUB_WS_PARAMS
               where session_id = p_session_id;

               INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               'FND_USER_NAME',
                               2,
                               l_fnd_user_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

               --retrieving and storing RESPONSIBILITY_NAME
               select responsibility_name
               into l_responsibility_name
               from EGO_PUB_WS_PARAMS
               where session_id = p_session_id;

               INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               'RESPONSIBILITY_NAME',
                               2,
                               l_responsibility_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');


               --retrieving and storing RESPONSIBILITY_APPL_NAME
               select responsibility_appl_name
               into l_responsibility_appl_name
               from EGO_PUB_WS_PARAMS
               where session_id = p_session_id;

               INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               'RESPONSIBILITY_APPL_NAME',
                               2,
                               l_responsibility_appl_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');


               --retrieving and storing SECURITY_GROUP_NAME
               select security_group_name
               into l_security_group_name
               from EGO_PUB_WS_PARAMS
               where session_id = p_session_id;

               INSERT INTO EGO_PUB_WS_CONFIG (session_id,
                                odi_session_id,
                                Parameter_Name,
                                Data_Type,
                                Char_value,
                                creation_date,
                                created_by,
                                web_service_name)
                       VALUES (p_session_id,
                               -1,
                               'SECURITY_GROUP_NAME',
                               2,
                               l_security_group_name,
                               sysdate,
                               0,
                               'GET_ITEM_STRUCTURE');

          /*Other parameters: Insert based in the values for ICC web service
          LANGUAGE_CODE
          LANGUAGE_CODE
          HEADER_AG_NAME
           (pass value of corresponding ICC node here)
          */

          --Inserts language options in Config table
          Config_Languages(p_session_id,
                    -1,
                    '',
                    'GET_ITEM_STRUCTURE');


     END IF; --IF l_batch_size > 0 THEN


END Explode_ICC_Structure;




PROCEDURE Explode_BOM_Structure(p_session_id IN NUMBER,
                                p_odi_session_id IN NUMBER)
IS

l_mode VARCHAR(100);
l_application_id NUMBER;
l_responsibility_id NUMBER;
l_user_id NUMBER;
l_batch_id NUMBER;

l_session_id NUMBER := p_session_id;
l_inventory_item_id NUMBER;
l_organization_id NUMBER;
l_revision_id NUMBER;
l_structure_name VARCHAR2(100) := 'Flow';

--component revisions information
l_comp_rev VARCHAR2(100);
l_comp_rev_id NUMBER;
l_comp_rev_label VARCHAR2(100);
l_comp_parent_rev VARCHAR2(100);
l_comp_rev_high_date DATE;

--x_rev_date DATE;
--x_rev_id NUMBER;
l_valid BOOLEAN;


--bom explosion configurability
l_levels_to_explode NUMBER;
l_explode_option NUMBER;
l_explode_standard VARCHAR2(10);
l_ordered_by NUMBER :=1;

x_err_msg  VARCHAR2(1000);
x_error_code NUMBER;
x_group_id NUMBER :=654;
x_return_status VARCHAR2(1);

CURSOR c_odi_end_items(p_session_id NUMBER, p_odi_session_id NUMBER) IS
SELECT session_id,
       odi_session_id,
       ITEM_ID,
       ITEM_ORG_ID,
       ITEM_REV,
       ITEM_REV_CODE,
       structure_name,
       explosion_date,
       sequence_number
FROM BOM_ODI_WS_ENTITIES
WHERE session_id = p_session_id
      and odi_session_id = p_odi_session_id
      and PUBLISH_FLAG = 'Y';

--cursor to retrieve the components generated during the bom explosion for
--a given end-item
cursor c_components(p_group_id NUMBER) is
select rowid row_id,
       component_sequence_id,
       comp_fixed_revision_id,
       parent_comp_seq_id
from bom_explosions_all be
where group_id = p_group_id;


BEGIN

  --Initialize FND security
  Init_Security_Structure(p_session_id, p_odi_session_id);

  --Check on the publish privilege for the end-items.
  --If end-item has no publish privilege, then remove end-item
  --from BOM_ODI_WS_ENTITIES table.
  check_end_item_security(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_priv_check => 'EGO_PUBLISH_ITEM',
                          p_for_exploded_items => 'Y',
                          x_return_status => x_return_status
                         );


  --READ CONFIGURABILITY OPTIONS FOR BOM EXPLOSION
  --reading levels to explode
  select to_number(char_value)
  into l_levels_to_explode
  from EGO_PUB_WS_CONFIG
  where session_id = p_session_id
     and web_service_name = 'GET_ITEM_STRUCTURE'
     and parameter_name = 'LEVELS_TO_EXPLODE';

  --Temporary workaround for bug 8768551. The following
  --if statement must be deleted once bug is fixed
  --IF  l_levels_to_explode = 60 THEN
  --    l_levels_to_explode := '61';
  --END IF;

  --reading explode_option
  select to_number(char_value)
  into l_explode_option
  from EGO_PUB_WS_CONFIG
  where session_id = p_session_id
     and web_service_name = 'GET_ITEM_STRUCTURE'
     and parameter_name = 'EXPLODE_OPTION';

  --reading EXPLODE_STD_BOM
  select char_value
  into l_explode_standard
  from EGO_PUB_WS_CONFIG
  where session_id = p_session_id
     and web_service_name = 'GET_ITEM_STRUCTURE'
     and parameter_name = 'EXPLODE_STD_BOM';


  --EXPLODE BOM FOR ALL END ITEMS WITH PUBLISH PRIVILEGE
  --looping through all user selected end-items in the batch
  FOR r in c_odi_end_items(p_session_id, p_odi_session_id) LOOP

    --computing explosion_date or revision_date
    /*l_valid := EGO_ITEM_WS_PVT.validate_revision_details(p_session_id => p_session_id,
                                              p_odi_session_id => p_odi_session_id,
                                              p_inv_id => r.ITEM_ID,
                                              p_org_id => r.ITEM_ORG_ID,
                                              p_rev_id => r.ITEM_REV,
                                              p_revision => r.ITEM_REV_CODE,
                                              p_rev_date => r.explosion_date,
                                              p_index => 1,
                                              p_revision_id => x_rev_id,
                                              p_revision_date => x_rev_date);

*/

     --debugging statement remove
     /*INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'Inside bom explosion code');
     INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'provided revision code' || r.ITEM_REV_CODE);
     INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'provided revision id:' || r.ITEM_REV);
     INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'provided revision date:' || r.explosion_date);
     INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'computed revision date:' || x_rev_date);
     INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'computed  revision_id :' || x_rev_id);
      --delete, for debugging only
     INSERT INTO emt_temp (Session_id, message)
          values (p_session_id, ' l_levels_to_explode:  ' || l_levels_to_explode);
     INSERT INTO emt_temp (Session_id, message)
          values (p_session_id, ' l_explode_option: ' || l_explode_option);
     INSERT INTO emt_temp (Session_id, message)
          values (p_session_id, ' l_explode_standard: ' || l_explode_standard);
     */

     --inserted
     --explosion_api originally utilized in H-MDM
     /*Bom_exploder_pub.Exploder_Userexit(Org_Id => r.ITEM_ORG_ID,
                                        rev_date =>  x_rev_date,
                                        order_by => l_ordered_by,
                                        Levels_To_Explode => l_levels_to_explode,
                                        alt_desg => r.structure_name,
                                        Error_Code => x_error_code,
                                        Err_Msg => x_err_msg,
                                        explode_option => l_explode_option,
                                        --std_bom_explode_flag => l_explode_standard,
                                        Grp_Id => x_group_id,
                                        pk_value1 => r.ITEM_ID,
                                        pk_value2 => r.ITEM_ORG_ID,
                                        end_item_revision_id => x_rev_id,
                                        p_autonomous_transaction => 1,
                                        end_item_id  => r.ITEM_ID,
                                        bom_or_eng => 1
                                        );
      */

     --New explosion API suggested by Bushan and Naveen for Item Service
     Bom_exploder_pub.Exploder_Userexit(Org_Id => r.ITEM_ORG_ID,
                                        rev_date =>  r.explosion_date,
                                        order_by => l_ordered_by,
                                        Levels_To_Explode => l_levels_to_explode,
                                        impl_flag  => 1, /* 1 - Imp Only, 2 - imp and unimpl */
                                        alt_desg => r.structure_name,
                                        Error_Code => x_error_code,
                                        Err_Msg => x_err_msg,
                                        explode_option => l_explode_option,
                                        std_bom_explode_flag => l_explode_standard,
                                        Grp_Id => x_group_id,
                                        pk_value1 => r.ITEM_ID,
                                        pk_value2 => r.ITEM_ORG_ID,
                                        --p_autonomous_transaction => 1,
                                        --end_item_id  => r.ITEM_ID,
                                        bom_or_eng => 2,  /* 1- BOM , 2 - ENG */
                                        material_ctrl       =>     1
                                        );


     IF x_error_code IS NOT NULL THEN
         --dbms_output.put_line('Error code is : '|| x_error_code);
         --dbms_output.put_line('Error mesg is : '|| x_err_msg);
         --dbms_output.put_line('Error mesg is : '|| SQLERRM);
         --delete, debugging only
         /*INSERT INTO emt_temp (Session_id, message)
         values (p_session_id, 'Error code is : ' || x_error_code);
         INSERT INTO emt_temp (Session_id, message)
         values (p_session_id, 'Error mesg is : ' || x_err_msg);
         */
         NULL;
     END IF;

     UPDATE BOM_ODI_WS_ENTITIES
     SET  group_id = x_group_id,
          EXPLOSION_DATE = bom_exploder_pub.get_explosion_date,
          EXPLOSION_OPTION = bom_exploder_pub.get_explode_option,
          ITEM_REV_CODE = bom_exploder_pub.get_expl_end_item_rev_code,
          ITEM_UNIT_NUMBER = bom_exploder_pub.get_expl_unit_number
     WHERE session_id = r.session_id
           AND odi_session_id = r.odi_session_id
           AND ITEM_ID =  r.ITEM_ID
           AND ITEM_ORG_ID = r.ITEM_ORG_ID
           AND ITEM_REV = r.ITEM_REV;


     --looping through all the components found for the end-item during the
     --bom explosion procedure to record their current revision and revision_id
     for comp_rec in c_components(x_group_id)
     loop

                 --delete, debugging only
                 /*INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'comp_rec.component_sequence_id: ' || comp_rec.component_sequence_id);
                 INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'bom_exploder_pub.get_explosion_date: ' || bom_exploder_pub.get_explosion_date);
                 INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'bom_exploder_pub.get_expl_end_item_rev_code: ' || bom_exploder_pub.get_expl_end_item_rev_code);
                  INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'comp_rec.comp_fixed_revision_id: ' || comp_rec.comp_fixed_revision_id);
                  INSERT INTO emt_temp (Session_id, message)
                 values (p_session_id, 'comp_rec.parent_comp_seq_id: ' || comp_rec.parent_comp_seq_id);
                 */

         IF comp_rec.component_sequence_id IS NOT NULL THEN
             l_comp_rev := bom_exploder_pub.get_component_revision(comp_rec.component_sequence_id);
             l_comp_rev_id := bom_exploder_pub.get_component_revision_id(comp_rec.component_sequence_id);
             l_comp_rev_label := bom_exploder_pub.get_component_revision_label(comp_rec.component_sequence_id);
         ELSE
             l_comp_rev := NULL;
             l_comp_rev_id :=NULL;
             l_comp_rev_label :=NULL;
         END IF;

         IF comp_rec.comp_fixed_revision_id IS NOT NULL THEN
             l_comp_rev_high_date := bom_exploder_pub.get_revision_highdate(comp_rec.comp_fixed_revision_id);
         ELSE
             l_comp_rev_high_date :=NULL;
         END IF;

         IF comp_rec.parent_comp_seq_id IS NOT NULL THEN
             l_comp_parent_rev := bom_exploder_pub.get_component_revision(comp_rec.parent_comp_seq_id);
         ELSE
             l_comp_parent_rev :=NULL;
         END IF;

            INSERT
            INTO bom_odi_ws_revisions(
              session_id,
              --group_id,
              --component_sequence_id,
              row_id,
              revision,
              revision_id,
              revision_label,
              revision_high_date,
              parent_revision,
              PUBLISH_FLAG,
              CREATION_DATE,
              CREATED_BY)
            VALUES(
               l_session_id,
               --x_group_id,
               --comp_rec.component_sequence_id,
               comp_rec.row_id,
               l_comp_rev,
               l_comp_rev_id,
               l_comp_rev_label,
               l_comp_rev_high_date,
               l_comp_parent_rev,
               'Y',
               sysdate,
               0);

     end loop; --end for all components

     --Check on the publish privilege for all components of the
     --just exploded end-item. If any component has no publish
     --privilege, then set PUBLISH_FLAG = N for end-item
     --to prevent its publication.
     check_component_security(p_session_id => p_session_id,
                          p_odi_session_id => p_odi_session_id,
                          p_priv_check => 'EGO_PUBLISH_ITEM',
                          p_group_id => x_group_id,
                          p_input_identifier => r.sequence_number,
                          p_inv_item_id => r.ITEM_ID,
                          p_org_id => r.ITEM_ORG_ID,
                          p_rev_id => r.ITEM_REV,
                          x_return_status => x_return_status);

   END LOOP; --end for all items with publish privilege


END Explode_BOM_Structure;



PROCEDURE Preprocess_Input_Structure(p_session_id IN NUMBER,
                                     p_odi_session_id IN NUMBER)
IS
BEGIN

   --debugging statement remove
  /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'Entering: Create_Params_Structure');
  */

   --Create Input parameters for ODI
   Create_Params_Structure(p_session_id, p_odi_session_id);

  --debugging statement remove
  /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'Entering: Create_Entities_Structure' );
  */

   --Create ODI Input table containing entities to process
   Create_Entities_Structure(p_session_id, p_odi_session_id);

  --debugging statement remove
  /*INSERT INTO emt_temp (Session_id, message)
              values (p_session_id, 'Entering: Explode_BOM_Structure ' );
  */

   --Explode BOM for all end-items selected
   Explode_BOM_Structure(p_session_id, p_odi_session_id);

END Preprocess_Input_Structure;




--This function reads the ODI output XML from table EGO_PUB_WS_OUTPUT using
--the provided session_id and transforms it using the XSL information stored
--in table EGO_ODI_WS_XSL and pointed by the web service name specified.
--The function returns the transformed XML into a clob variable.
FUNCTION Transform_XML(p_xml_input IN CLOB,
                       p_web_service_name IN VARCHAR2)
                       RETURN XmlType
                       IS

 indoc       VARCHAR2(2000);
 xsldoc      VARCHAR2(2000);
 myParser    dbms_xmlparser.Parser;
 indomdoc    dbms_xmldom.domdocument;
 xsltdomdoc  dbms_xmldom.domdocument;
 xsl         dbms_xslprocessor.stylesheet;
 outdomdocf  dbms_xmldom.domdocumentfragment;
 outnode     dbms_xmldom.domnode;
 proc        dbms_xslprocessor.processor;
 buf         varchar2(2000);
 xmlclob     clob;
 xslclob     clob;
 outclob    clob;

BEGIN

  xmlclob := p_xml_input;

  --selecting XLS transformation data from
  --table EGO_ODI_WS_XSL for specified web service
  select x.xslcontent.getclobval()
  into xslclob
  from EGO_ODI_WS_XSL x
  where web_service_name = p_web_service_name;

   myParser := dbms_xmlparser.newParser;
   dbms_xmlparser.parseclob(myParser, xmlclob);
   indomdoc := dbms_xmlparser.getDocument(myParser);
   dbms_xmlparser.parseclob(myParser, xslclob);
   xsltdomdoc := dbms_xmlparser.getDocument(myParser);
   xsl := dbms_xslprocessor.newstylesheet(xsltdomdoc, '');
   proc := dbms_xslprocessor.newProcessor;

   --apply stylesheet to DOM document
   outdomdocf := dbms_xslprocessor.processxsl(proc, xsl, indomdoc);
   outnode    := dbms_xmldom.makenode(outdomdocf);

   DBMS_LOB.CreateTemporary(outCLOB, TRUE);
   dbms_xmldom.writetoclob(outnode,outclob);

   RETURN XmlType(outclob);

END Transform_XML;





--Generates an XML payload containg the results of executing a given web service
--from the data stored by the service scenario execution in table EGO_PUB_WS_FLAT_RECS.
--The resulting XML payload is stored in column XMLCONTENT
--of table EGO_PUB_WS_OUTPUT
PROCEDURE Generate_XML(p_session_id       IN NUMBER,
                       p_odi_session_id   IN NUMBER,
                       p_web_service_name IN VARCHAR2,
                       p_xml_root_element IN VARCHAR2,
                       p_transform_xml IN BOOLEAN DEFAULT TRUE)
IS

    l_session_id            NUMBER        := p_session_id;
    l_odi_session_id        NUMBER        := p_odi_session_id;
    l_web_service_name      VARCHAR2(100) := p_web_service_name;
    l_entity_type           VARCHAR2(100) := NULL;
    l_xml                   CLOB;

    l_output_xml            XmlType;
    l_cr                    VARCHAR2(10)  := fnd_global.local_chr(10);
    l_qm                    VARCHAR2(1)   := '?';  -- Question mark in a string may be interpreted by ODI

    l_level_stack           dbms_sql.number_table;
    l_tags_stack            dbms_sql.varchar2_table;
    l_previous_level        NUMBER        := -1;
    l_previous_entity_type  VARCHAR2(100);
    l_return_payload        VARCHAR2(10)  :='TRUE';
    l_sequence              NUMBER        :=1;

    l_no_of_entities        NUMBER        :=0;   --No of entities for a session in case of chunk
    l_actual_node           VARCHAR2(100) :=NULL;
    l_end_xml               VARCHAR2(100) :=NULL;

    l_chunk_detail          CLOB; --Chunking
    l_err_xml               CLOB; --Error Handling

    l_entity_type_tag       EGO_PUB_WS_FLAT_RECS.ENTITY_TYPE%TYPE;  -- Perf Bug : 9129863

    -- Tree query to traverse the flatten xml structurally.
    --Cursor to recover top parents
    CURSOR c_ws_data(cp_session_id NUMBER)
    IS
    SELECT SEQUENCE_ID ,
           PARENT_SEQUENCE_ID,
           LEVEL LEVEL_NUMBER,
           ENTITY_TYPE,
           Value
    FROM EGO_PUB_WS_FLAT_RECS
    WHERE session_id = cp_session_id
    START WITH session_id = cp_session_id AND Nvl(PARENT_SEQUENCE_ID,-1)=-1
    CONNECT BY PRIOR SEQUENCE_ID = PARENT_SEQUENCE_ID AND session_id = cp_session_id;



    --Chunking Start--
    /*Cursor to get configurable parameter 'return_payload' value*/
    CURSOR Cur_config_param(cp_session_id NUMBER,
                            cp_odi_session_id NUMBER)
    IS
    SELECT Upper(Nvl(CHAR_VALUE,'TRUE')) param_value
    FROM ego_pub_ws_config
    WHERE session_id = cp_session_id
     AND odi_session_id = cp_odi_session_id
     AND upper(parameter_name) = 'RETURN_PAYLOAD';


    /*Cursor to get top level entity value and sequence*/
    CURSOR c_ws_top_entity(cp_session_id NUMBER)
    IS
    SELECT SEQUENCE_ID ,
           PARENT_SEQUENCE_ID,
           ENTITY_TYPE,
           Value
    FROM EGO_PUB_WS_FLAT_RECS
    WHERE session_id = cp_session_id
      AND Nvl(PARENT_SEQUENCE_ID,-1)=-1 ;


    --Cursor to recover data based on top level entity for chunking
    CURSOR c_ws_data_chunk(cp_session_id NUMBER,
                           cp_sequence_id NUMBER )
    IS
    SELECT SEQUENCE_ID ,
           PARENT_SEQUENCE_ID,
           LEVEL LEVEL_NUMBER,
           ENTITY_TYPE,
           Value
    FROM EGO_PUB_WS_FLAT_RECS
    WHERE session_id = cp_session_id
    START WITH session_id = cp_session_id AND Nvl(PARENT_SEQUENCE_ID,-1)=-1 AND SEQUENCE_ID=cp_sequence_id
    CONNECT BY PRIOR SEQUENCE_ID = PARENT_SEQUENCE_ID AND session_id = cp_session_id;

    --START WITH session_id = cp_session_id AND Nvl(PARENT_SEQUENCE_ID,-1)=-1
    --CONNECT BY PRIOR SEQUENCE_ID = PARENT_SEQUENCE_ID AND session_id = cp_session_id;

    --Chunking End--



    --Start error handling
    CURSOR c_err_detail(cp_session_id     NUMBER,
                         cp_odi_session_id NUMBER)
    IS
    SELECT session_id,input_id, err_code,err_message
    FROM EGO_PUB_WS_ERRORS
    WHERE session_id=cp_session_id
      AND odi_session_id= cp_odi_session_id;


    CURSOR c_err_identifier(cp_session_id     NUMBER,
                            cp_odi_session_id NUMBER,
                            cp_input_id       NUMBER)
    IS
    SELECT session_id, param_name,param_value
    FROM EGO_PUB_WS_INPUT_IDENTIFIERS
    WHERE session_id=cp_session_id
      AND odi_session_id= cp_odi_session_id
      AND input_id=cp_input_id;

    --End error handling

BEGIN

     --Chunking Start--
     /*Get value for configureable parameter 'return_payload'*/
     FOR i IN Cur_config_param(l_session_id,l_odi_session_id)
     LOOP

        l_return_payload:=i.param_value;
     END LOOP; --END LOOP FOR i IN Cur_config_param(l_session_id,l_odi_session_id)


     IF(l_web_service_name=G_VS_WEBSERVICE)
     THEN
       l_entity_type     :='ValueSets';
     END IF;

     IF(l_web_service_name=G_ICC_WEBSERVICE)
     THEN
       l_entity_type   :='ItemCatalogCategory';
     END IF;

     IF(l_web_service_name='GET_ITEM_DETAILS') THEN
       l_entity_type   :='ITEM';
     END IF;

     IF(l_web_service_name='GET_ITEM_STRUCTURE') THEN
       l_entity_type   :='ITEM_STRUCTURE';
     END IF;




     --Error Handling
     l_err_xml := l_err_xml || '<Status>' || l_cr;    --YJ

     FOR i IN c_err_detail(l_session_id,l_odi_session_id)
     LOOP
       l_err_xml := l_err_xml || '<Error>' || l_cr;
       l_err_xml := l_err_xml || '<Code>' || i.err_code||'</Code>'||l_cr;
       l_err_xml := l_err_xml || '<Message>' || i.err_message||'</Message>'||l_cr;
       l_err_xml := l_err_xml || '<InputIdentifier>'||l_cr;
       --Create identifier tag if parameter entries exist
       FOR j IN c_err_identifier(l_session_id,l_odi_session_id,i.input_id)
       LOOP
         l_err_xml := l_err_xml || '<Parameter>'||l_cr;
         l_err_xml := l_err_xml || '<Name>'||j.param_name||'</Name>'||l_cr;
         l_err_xml := l_err_xml || '<Value>'||j.param_value||'</Value>'||l_cr;
         l_err_xml := l_err_xml || '</Parameter>'||l_cr;
       END LOOP; --End FOR j IN c_err_identifier

       l_err_xml := l_err_xml || '</InputIdentifier>'|| l_cr;
       l_err_xml := l_err_xml || '</Error>' || l_cr;
     END LOOP; --End  FOR i IN c_err_detail(l_session_id,l_odi_session_id)

     l_err_xml := l_err_xml || '</Status>' || l_cr;
     --Error Handling







     IF  ( l_return_payload ='TRUE' OR l_return_payload ='Y') THEN
     --Case to return complete payload
     -- Value will be subset of ('Y','N') for Item and ItemStructure and
     -- will be subset of ('TRUE','FALSE') for ICC and ValueSet.
     --YJ

        l_xml := '<' || l_qm || 'xml version="1.0" encoding="UTF-8"' || l_qm || '>' || l_cr;
        l_xml := l_xml || '<'||p_xml_root_element||'>' || l_cr;

        FOR r in c_ws_data(l_session_id) LOOP
              IF r.level_number = l_previous_level THEN
                  IF r.entity_type = l_previous_entity_type THEN
                  --Dbms_Output.put_line(' r.entity_type  = '||r.entity_type );
                      -- End the previous tag only.

                      -- Perf Bug : 9129863 - Start
                      l_entity_type_tag :=  '</' || r.entity_type || '>' || l_cr;
                      dbms_lob.append(l_xml,l_entity_type_tag);
                      -- l_xml := l_xml || '</' || r.entity_type || '>' || l_cr;
                      -- Perf Bug : 9129863 - End

                  ELSE
                      -- End the previous tag, end the current tag and pop.
                      WHILE (l_level_stack(l_level_stack.COUNT) >= r.level_number AND l_level_stack.COUNT > 0)
                      LOOP
                          -- Perf Bug : 9129863 - Start
                          l_entity_type_tag := '</' || l_tags_stack(l_tags_stack.COUNT) || '>' || l_cr;
                          dbms_lob.append(l_xml,l_entity_type_tag);
                          -- l_xml := l_xml || '</' || l_tags_stack(l_tags_stack.COUNT) || '>' || l_cr;
                          -- Perf Bug : 9129863 - End

                          l_level_stack.DELETE(l_level_stack.COUNT);
                          l_tags_stack.DELETE(l_tags_stack.COUNT);
                          EXIT WHEN l_level_stack.COUNT=0;
                      END LOOP;

                      l_level_stack(l_level_stack.COUNT + 1) := r.level_number;
                      l_tags_stack(l_tags_stack.COUNT + 1) := r.entity_type;
                  END IF; --End IF r.entity_type = l_previous_entity_type THEN

              END IF;--End IF r.level_number = l_previous_level THEN

              IF r.level_number > l_previous_level THEN
                  -- Push the level name into the stack.
                  l_level_stack(l_level_stack.COUNT + 1) := r.level_number;
                  l_tags_stack(l_tags_stack.COUNT + 1) := r.entity_type;
              END IF;--End IF r.level_number > l_previous_level THEN


              IF r.level_number  < l_previous_level THEN
                  -- End the previous tag, end the current tag and pop.
                  IF l_level_stack.COUNT > 0 THEN

                      WHILE (l_level_stack(l_level_stack.COUNT) >= r.level_number AND l_level_stack.COUNT > 0)
                      LOOP
                          -- Perf Bug : 9129863 - Start
                          l_entity_type_tag :=  '</' || l_tags_stack(l_tags_stack.COUNT) || '>' || l_cr;
                          dbms_lob.append(l_xml,l_entity_type_tag);
                          -- l_xml := l_xml || '</' || l_tags_stack(l_tags_stack.COUNT) || '>' || l_cr;
                          -- Perf Bug : 9129863 - End

                          l_level_stack.DELETE(l_level_stack.COUNT);
                          l_tags_stack.DELETE(l_tags_stack.COUNT);
                          EXIT WHEN l_level_stack.COUNT=0;
                      END LOOP;
                      l_level_stack(l_level_stack.COUNT + 1) := r.level_number;
                      l_tags_stack(l_tags_stack.COUNT + 1) := r.entity_type;

                  END IF;

              END IF;--END IF r.level_number  < l_previous_level THEN

            -- Perf Bug : 9129863 - Start
            l_entity_type_tag := '<' || r.entity_type || '>' ;
            dbms_lob.append(l_xml,l_entity_type_tag);
            dbms_lob.append(l_xml,r.value);
            dbms_lob.writeappend(l_xml,Length(l_cr), l_cr);
            -- l_xml := l_xml || '<' || r.entity_type || '>' || r.value ||  l_cr;
            -- Perf Bug : 9129863 - End

            l_previous_level := r.level_number;
            l_previous_entity_type := r.entity_type;

        END LOOP; --END LOOP FOR r in c_ws_data(l_session_id) LOOP

        -- Pop and end tag all levels in stack.
        FOR i IN REVERSE 1..l_level_stack.COUNT LOOP
            -- Perf Bug : 9129863 - Start
            l_entity_type_tag := '</' || l_tags_stack(i) || '>' || l_cr;
            dbms_lob.append(l_xml,l_entity_type_tag);
            -- l_xml := l_xml || '</' || l_tags_stack(i) || '>' || l_cr;
            -- Perf Bug : 9129863 - End
        END LOOP;--END FOR i IN REVERSE 1..l_level_stack.COUNT LOOP
        --YJ REMOVE

        -- Perf Bug : 9129863 - Start
        dbms_lob.append(l_xml,l_err_xml);
        -- l_xml := l_xml || l_err_xml;

        l_entity_type_tag := '</'||p_xml_root_element||'>' || l_cr;
        dbms_lob.append(l_xml,l_entity_type_tag);
        --l_xml := l_xml || '</'||p_xml_root_element||'>' || l_cr;
        -- Perf Bug : 9129863 - End

        --If XML transformation option is on, transform the xml
        IF p_transform_xml = TRUE
        THEN
            l_output_xml := Transform_XML(l_xml, p_web_service_name);
        ELSE
            l_output_xml := XmlType(l_xml);
        END IF;

        -- Write final XML payload to output table in XML TYPE column
        -- with sequence id as zero
        -- This payload will be accessed using serviceutil.java with sequence_id
        -- as zero for return_payload as TRUE
        INSERT INTO ego_pub_ws_output (session_id,
                                       odi_session_id,
                                       web_service_name,
                                       sequence_id,
                                       xmlcontent,
                                       xml_odi,
                                       creation_date,
                                       created_by)

                              VALUES (l_session_id,
                                      p_odi_session_id,
                                      p_web_service_name,
                                      0,
                                      l_output_xml,
                                      XmlType(l_xml),
                                      sysdate,
                                      0);

     --End YJ
     ELSE --Case to return payload in chunk

        IF(l_web_service_name=G_VS_WEBSERVICE)
        THEN
          l_actual_node     :='ns1:ListOfValueSets';
          l_chunk_detail :='<ns1:ListOfValueSets xmlns:ns1="http://xmlns.oracle.com/apps/ego/extfwk/service/out"><AdditionalInfo><SessionId>'||l_session_id||'</SessionId>';
        END IF;

        IF(l_web_service_name=G_ICC_WEBSERVICE)
        THEN
          l_actual_node   :='ns1:ListOfICCs';
          l_chunk_detail :='<ns1:ListOfICCs xmlns:ns1="http://xmlns.oracle.com/apps/ego/itemcatalog/service/out"><AdditionalInfo><SessionId>'||l_session_id||'</SessionId>';--<EntityCount>
        END IF;

        IF(l_web_service_name='GET_ITEM_DETAILS') THEN
          l_actual_node   :='ns1:listOfItems';
          l_chunk_detail :='<ns1:listOfItems xmlns:ns1="http://xmlns.oracle.com/apps/ego/extfwk/service/out"><AdditionalInfo><SessionId>'||l_session_id||'</SessionId>';
        END IF;

        IF(l_web_service_name='GET_ITEM_STRUCTURE') THEN
          l_actual_node   :='ns0:listOfStructureHeaders';
          l_chunk_detail :='<ns0:listOfStructureHeaders xmlns:ns0="http://xmlns.oracle.com/apps/bom/structure/service"><AdditionalInfo><SessionId>'||l_session_id||'</SessionId>';
        END IF;

        l_end_xml  :='</AdditionalInfo>';



        FOR j IN c_ws_top_entity(l_session_id)
        LOOP
            l_xml := '<' || l_qm || 'xml version="1.0" encoding="UTF-8"' || l_qm || '>' || l_cr;
            l_xml := l_xml || '<'||p_xml_root_element||'>' || l_cr;

            /*Loop through to get data in chunk for top level entity*/
            FOR r in c_ws_data_chunk(l_session_id,j.sequence_id)
            LOOP
                  IF r.level_number = l_previous_level THEN
                      IF r.entity_type = l_previous_entity_type THEN
                          -- End the previous tag only.
                          -- Perf Bug : 9129863 - Start
                          l_entity_type_tag := '</' || r.entity_type || '>' || l_cr;
                          dbms_lob.append(l_xml,l_entity_type_tag);
                          -- l_xml := l_xml || '</' || r.entity_type || '>' || l_cr;
                          -- Perf Bug : 9129863 - End
                      ELSE
                          -- End the previous tag, end the current tag and pop.
                          WHILE (l_level_stack(l_level_stack.COUNT) >= r.level_number AND l_level_stack.COUNT > 0)
                          LOOP
                              -- Perf Bug : 9129863 - Start
                              l_entity_type_tag := '</' || l_tags_stack(l_tags_stack.COUNT) || '>' || l_cr;
                              dbms_lob.append(l_xml,l_entity_type_tag);
                              -- l_xml := l_xml || '</' || l_tags_stack(l_tags_stack.COUNT) || '>' || l_cr;
                              -- Perf Bug : 9129863 - End

                              l_level_stack.DELETE(l_level_stack.COUNT);
                              l_tags_stack.DELETE(l_tags_stack.COUNT);
                              EXIT WHEN l_level_stack.COUNT=0;
                          END LOOP;
                          l_level_stack(l_level_stack.COUNT + 1) := r.level_number;
                          l_tags_stack(l_tags_stack.COUNT + 1) := r.entity_type;
                      END IF;--END IF r.entity_type = l_previous_entity_type THEN

                  END IF;--END IF r.level_number = l_previous_level THEN


                  IF r.level_number > l_previous_level THEN
                      -- Push the level name into the stack.
                      l_level_stack(l_level_stack.COUNT + 1) := r.level_number;
                      l_tags_stack(l_tags_stack.COUNT + 1) := r.entity_type;
                  END IF;--END IF r.level_number > l_previous_level THEN


                  IF r.level_number  < l_previous_level THEN
                      -- End the previous tag, end the current tag and pop.

                      IF l_level_stack.COUNT > 0 THEN

                          WHILE (l_level_stack(l_level_stack.COUNT) >= r.level_number AND l_level_stack.COUNT > 0)
                          LOOP
                              -- End the previous tag only.
                              -- Perf Bug : 9129863 - Start
                              l_entity_type_tag := '</' || l_tags_stack(l_tags_stack.COUNT) || '>' || l_cr;
                              dbms_lob.append(l_xml,l_entity_type_tag);
                              -- l_xml := l_xml || '</' || l_tags_stack(l_tags_stack.COUNT) || '>' || l_cr;
                              -- Perf Bug : 9129863 - End

                              l_level_stack.DELETE(l_level_stack.COUNT);
                              l_tags_stack.DELETE(l_tags_stack.COUNT);
                              EXIT WHEN l_level_stack.COUNT=0;
                          END LOOP;
                          l_level_stack(l_level_stack.COUNT + 1) := r.level_number;
                          l_tags_stack(l_tags_stack.COUNT + 1) := r.entity_type;
                      END IF;
                  END IF;--END IF r.level_number  < l_previous_level THEN


                -- Perf Bug : 9129863 - Start
                l_entity_type_tag := '<' || r.entity_type || '>' ;
                dbms_lob.append(l_xml,l_entity_type_tag);
                dbms_lob.append(l_xml,r.value);
                dbms_lob.writeappend(l_xml,Length(l_cr), l_cr);
                -- l_xml := l_xml || '<' || r.entity_type || '>' || r.value ||  l_cr;
                -- Perf Bug : 9129863 - End

                l_previous_level := r.level_number;
                l_previous_entity_type := r.entity_type;

            END LOOP;--END FOR r in c_ws_data_chunk(l_session_id,j.sequence_id)
            --End of loop for procedding data at each top level entity

            -- Pop and end tag all levels in stack.
            FOR i IN REVERSE 1..l_level_stack.COUNT LOOP
                -- Perf Bug : 9129863 - Start
                l_entity_type_tag := '</' || l_tags_stack(i) || '>' || l_cr;
                dbms_lob.append(l_xml,l_entity_type_tag);
                -- l_xml := l_xml || '</' || l_tags_stack(i) || '>' || l_cr;
                -- Perf Bug : 9129863 - End

            END LOOP;
            -- Perf Bug : 9129863 - Start
            l_entity_type_tag := '</'||p_xml_root_element||'>' || l_cr;
            dbms_lob.append(l_xml,l_entity_type_tag);
            -- l_xml := l_xml || '</'||p_xml_root_element||'>' || l_cr;
            -- Perf Bug : 9129863 - End


            --If XML transformation option is on, transform the xml
            IF p_transform_xml = TRUE
            THEN
                l_output_xml := Transform_XML(l_xml, p_web_service_name);
            ELSE
                l_output_xml := XmlType(l_xml);
            END IF;


            -- Write XML payload to output table for each top level entity with
            -- sequence_id.
            INSERT INTO EGO_PUB_WS_OUTPUT(session_id,
                                          odi_session_id,
                                          web_service_name,
                                          sequence_id,
                                          xmlcontent,
                                          xml_odi,
                                          creation_date,
                                          created_by)
                        VALUES (l_session_id,
                                p_odi_session_id,
                                p_web_service_name,
                                l_sequence,
                                l_output_xml,
                                XmlType(l_xml),
                                sysdate,
                                0);

            --Re-Initialize all variable
            l_xml:=NULL;
            l_previous_level          := -1;
            l_previous_entity_type    :=NULL ;
            l_sequence                :=l_sequence+1;
            l_no_of_entities          :=l_no_of_entities+1;      --Counting number of top level entities

            IF l_level_stack.COUNT > 0 THEN
              WHILE ( l_level_stack.COUNT > 0)
              LOOP
                l_level_stack.DELETE(l_level_stack.COUNT);
                l_tags_stack.DELETE(l_tags_stack.COUNT);
                EXIT WHEN l_level_stack.COUNT=0;
              END LOOP;
            END IF;



        END LOOP; -- End FOR j IN c_ws_top_entity(l_session_id)
        --End of loop for  processing all top level entity.

        l_chunk_detail:=l_chunk_detail||'<EntityCount>'||l_no_of_entities||'</EntityCount>'||l_end_xml;
        l_chunk_detail := l_chunk_detail || l_err_xml||'</'||l_actual_node||'>';
        -- Insert final data in to output table with sequence_id as zero, This
        -- will contain session_id and entity_count, End user will use this data
        -- to get detail about no of entity for a session, It will use this detail
        -- to get data from database view provided to them
        INSERT INTO EGO_PUB_WS_OUTPUT (session_id,
                                       odi_session_id,
                                       web_service_name,
                                       sequence_id,
                                       xmlcontent,
                                       xml_odi,
                                       creation_date,
                                       created_by)
                              VALUES (l_session_id,
                                      l_odi_session_id,
                                      l_web_service_name,
                                      0,
                                      xmltype(l_chunk_detail),
                                      XmlType(l_chunk_detail),
                                      sysdate,
                                      0);

     END IF;--End IF  l_return_payload='TRUE'
     --Chunking End--




    --Insert XML as string for debugging
    --INSERT INTO EGO_PUB_WS_OUTPUT (session_id,
    --                                 odi_session_id,
    --                                 web_service_name,
    --                                 XMLCLOB,
    --                                 creation_date,
    --                                 created_by))
    --            VALUES (l_session_id,
    --                      p_odi_session_id,
    --                      p_web_service_name,
    --                      l_xml,
    --                      sysdate,
    --                      0);


END Generate_XML;




/* Procedure to get invocation Mode and setting batch_id based on invocation mode
   If mode is 'BATCH' then it will give some Batch Id, If mode is 'LIST' then
   Batch Id will be -1*/
PROCEDURE Invocation_Mode ( p_session_id    IN           NUMBER,
                            p_search_str    IN           VARCHAR2,
                            x_mode          OUT NOCOPY   VARCHAR2,
                            x_batch_id      OUT NOCOPY   NUMBER  )
IS

    --Local Variable
    l_mode         VARCHAR2(10) :='BATCH';
    l_batch_id     NUMBER:=-1;
    l_exists       NUMBER;

BEGIN
      --if BatchId node exist and It has some value then we are in 'BATCH' mode
      SELECT existsNode(xmlcontent, p_search_str)
      INTO l_exists
      FROM EGO_PUB_WS_PARAMS
      WHERE session_id = p_session_id;


      IF l_exists=1 THEN
          /*If node exist for 'BatchId' then extractValue for BatchId'*/
          SELECT Nvl(extractValue(xmlcontent,p_search_str),-1)
          INTO l_batch_id
          FROM EGO_PUB_WS_PARAMS
          WHERE session_id = p_session_id;

          IF l_batch_id >-1 THEN
              x_mode:= 'BATCH';
          ELSE
              x_mode:= 'LIST';
          END IF;
          x_batch_id:= l_batch_id;
      ELSE
          x_mode:= 'LIST';
          x_batch_id:= l_batch_id;
      END IF;

/*EXCEPTION
      WHEN OTHERS THEN
           NULL;*/

END Invocation_Mode;





/* Procedure to insert record for configurable parameter*/
PROCEDURE Create_Config_Param ( p_session_id        IN  NUMBER,
                                p_odi_session_id    IN  NUMBER,
                                p_webservice_name   IN  VARCHAR2,
                                p_lang_search_str   IN  VARCHAR2,
                                p_parent_hier       IN  VARCHAR2,
                                p_child_hier        IN  VARCHAR2)
IS

      l_lang_code_tab       dbms_sql.varchar2_table;
      l_UserDefAttrGrps     VARCHAR2(10);
      l_iccvers_config      VARCHAR2(10);
      l_transattrs_config   VARCHAR2(10);
      l_structure_config    VARCHAR2(10);
      l_langcode_xpath      VARCHAR2(100):=p_lang_search_str||'/ListOfLanguages/Language/LanguageCode';
      l_langname_xpath      VARCHAR2(100):=p_lang_search_str||'/ListOfLanguages/Language/LanguageName';
      l_retpay_xpath        VARCHAR2(100):=p_lang_search_str||'/ReturnPayload';
      l_retpayload          VARCHAR2(10)  :='TRUE';

BEGIN
      /*extract configurable parameter for language */
      SELECT   extractValue(lang_code, '/LanguageCode')
        BULK COLLECT INTO  l_lang_code_tab
        FROM  (SELECT  Value(langcode) lang_code
               FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                    extract(i.xmlcontent, l_langcode_xpath) )) langcode
              WHERE session_id=p_session_id
              );

      --Insert record into config table for parameter language
      IF l_lang_code_tab.Count> 0 THEN

          FOR i IN 1..l_lang_code_tab.Count
          LOOP
            INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by, web_service_name)
            VALUES (p_session_id,p_odi_session_id,'LANGUAGE_CODE',2,NULL,l_lang_code_tab(i),NULL,SYSDATE,G_CURRENT_USER_ID, p_webservice_name);
          END LOOP;
      ELSE
          FOR i IN (SELECT language_code FROM FND_LANGUAGES WHERE INSTALLED_FLAG IN ('I','B') ) LOOP
            INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by, web_service_name)
            VALUES (p_session_id,p_odi_session_id,'LANGUAGE_CODE',2,NULL,i.language_code,NULL,SYSDATE,G_CURRENT_USER_ID, p_webservice_name);
          END LOOP;
      END IF;


      --extract configurable parameter 'ReturnPayload'
      BEGIN
        SELECT   Upper(Nvl(extractValue(ret_pay, '/ReturnPayload'),'TRUE'))
        INTO  l_retpayload
        FROM  (SELECT  Value(retpay) ret_pay
              FROM EGO_PUB_WS_PARAMS i,
              TABLE(XMLSequence(
                    extract(i.xmlcontent, l_retpay_xpath) )) retpay
              WHERE session_id=p_session_id
              );

      EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
              l_retpayload:='TRUE';
      END;


      INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
      VALUES (p_session_id,p_odi_session_id,'return_payload',2,NULL,Upper(l_retpayload),NULL,SYSDATE,G_CURRENT_USER_ID);



      /*If WebService is ICC then create config param for ICC*/
      IF (p_webservice_name = G_ICC_WEBSERVICE ) THEN

                /*extract configurable parameter Attr Group and insert record into config table */
                SELECT   Nvl(extractValue(uda_ag, '/UserDefAttrGrps'),'TRUE')
                    INTO  l_UserDefAttrGrps
                    FROM  (SELECT  Value(udaag) uda_ag
                            FROM EGO_PUB_WS_PARAMS i,
                            TABLE(XMLSequence(
                              extract(i.xmlcontent, '/ICCQueryParam/ICCPubEntityObject/UserDefAttrGrps') )) udaag
                            WHERE session_id=p_session_id
                          );


                INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                      VALUES (p_session_id,p_odi_session_id,'PublishUDA',2,NULL,Upper(l_UserDefAttrGrps),NULL,SYSDATE,G_CURRENT_USER_ID);




                /*extract configurable parameter ICCVersions and insert record into config table */
                SELECT   Nvl(extractValue(uda_ag, '/ICCVersions'),'TRUE')
                    INTO  l_iccvers_config
                    FROM  (SELECT  Value(udaag) uda_ag
                            FROM EGO_PUB_WS_PARAMS i,
                            TABLE(XMLSequence(
                              extract(i.xmlcontent, '/ICCQueryParam/ICCPubEntityObject/ICCVersions') )) udaag
                            WHERE session_id=p_session_id
                          );


                INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                      VALUES (p_session_id,p_odi_session_id,'PublishICCVersions',2,NULL,Upper(l_iccvers_config),NULL,SYSDATE,G_CURRENT_USER_ID);



                /*extract configurable parameter TransAttrs and insert record into config table */
                SELECT   Nvl(extractValue(uda_ag, '/TransAttrs'),'TRUE')
                    INTO  l_transattrs_config
                    FROM  (SELECT  Value(udaag) uda_ag
                            FROM EGO_PUB_WS_PARAMS i,
                            TABLE(XMLSequence(
                              extract(i.xmlcontent, '/ICCQueryParam/ICCPubEntityObject/TransAttrs') )) udaag
                            WHERE session_id=p_session_id
                          );


                INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                      VALUES (p_session_id,p_odi_session_id,'PublishTransAttrs',2,NULL,Upper(l_transattrs_config),NULL,SYSDATE,G_CURRENT_USER_ID);


                /*extract configurable parameter ICCStructure  and insert record into config table */
                SELECT   Nvl(extractValue(uda_ag, '/ICCStructure'),'TRUE')
                    INTO  l_structure_config
                    FROM  (SELECT  Value(udaag) uda_ag
                            FROM EGO_PUB_WS_PARAMS i,
                            TABLE(XMLSequence(
                              extract(i.xmlcontent, '/ICCQueryParam/ICCPubEntityObject/ICCStructure') )) udaag
                            WHERE session_id=p_session_id
                          );


                INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                      VALUES (p_session_id,p_odi_session_id,'PublishICCStructure',2,NULL,Upper(l_structure_config),NULL,SYSDATE,G_CURRENT_USER_ID);





                /*Insert record into config table for parameter parent and child hierarchy*/
                INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                      VALUES (p_session_id,p_odi_session_id,'PublishParentICCs',2,NULL,Upper(p_parent_hier),NULL,SYSDATE,G_CURRENT_USER_ID);


                INSERT INTO EGO_PUB_WS_CONFIG ( session_id,odi_session_id,Parameter_Name,Data_Type,Date_Value,Char_value,Numeric_Value,creation_date,created_by)
                      VALUES (p_session_id,p_odi_session_id,'PublishChildICCs',2,NULL,Upper(p_child_hier),NULL,SYSDATE,G_CURRENT_USER_ID);


      END IF;

/*EXCEPTION
      WHEN OTHERS THEN
        NULL;*/
END Create_Config_Param;

/* Procedure to finding out List of ICC's and their version and to publish hierarchy of ICC to temporary table*/
PROCEDURE Preprocess_Input_ICC   (  p_session_id      IN NUMBER,
                                    p_odi_session_id  IN NUMBER )

IS

          l_icc_id_tab           dbms_sql.VARCHAR2_table;  --Netsed table of varchar2 to store ICC_Id's
          l_icc_ver_tab         dbms_sql.NUMBER_table;  --Netsed table of varchar2 to store ICC Version
          l_count                 NUMBER;

         --Bug 8767131
          l_dup_icc_id_tab     dbms_sql.Number_Table;   --Netsed table of varchar2 to store ICC_Id's
          l_dup_icc_ver_tab   dbms_sql.Number_Table; --Netsed table of varchar2 to store ICC Version
          l_unique_icc_count  NUMBER:=1;
          l_is_duplicate          BOOLEAN       :=FALSE;
          l_ref1_value            VARCHAR2(200):=NULL;
          --Bug 8767131


           /* Cursor to find out all child ICC's and their effective version as on
           1. End date of passed in version of passed in ICC Id for publishing ICC's effective in past.
           2. Start date of passed in version of passed in ICC Id for publishing ICC's effective in future..
           3. current date for publishing ICC's effective in present.*/

           CURSOR cur_icc_ver(cp_icc_id IN NUMBER, cp_icc_ver IN NUMBER,cp_publish_parent IN VARCHAR2, cp_publish_child IN VARCHAR2)
           IS
           SELECT cp_icc_id ITEM_CATALOG_GROUP_ID,cp_icc_ver VERSION_SEQ_ID,1 lev FROM dual
           UNION
           SELECT ITEM_CATALOG_GROUP_ID,VERSION_SEQ_ID,lev FROM
                    ( SELECT iccb.ITEM_CATALOG_GROUP_ID,VERSION_SEQ_ID ,lev
                      FROM EGO_MTL_CATALOG_GRP_VERS_B iccb,
                        ( SELECT ITEM_CATALOG_GROUP_ID,LEVEL lev
                          FROM MTL_ITEM_CATALOG_GROUPS_B
                          START WITH ITEM_CATALOG_GROUP_ID =cp_icc_id
                          CONNECT BY PRIOR ITEM_CATALOG_GROUP_ID=PARENT_CATALOG_GROUP_ID
                        ) hier
                      WHERE iccb.item_catalog_group_id=hier.item_catalog_group_id
                    )
                    WHERE
                    (
                     cp_publish_child ='TRUE'
                          AND
                          (
                              LEV           > 1
                              AND (item_catalog_group_id, VERSION_SEQ_ID)
                              IN
                              ( SELECT item_catalog_group_id,VERSION_SEQ_ID
                                  FROM    EGO_MTL_CATALOG_GRP_VERS_B
                                  WHERE (item_catalog_group_id,start_active_date )
                                        IN
                                        (  SELECT  item_catalog_group_id, MAX(start_active_date) start_active_date
                                          FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                          WHERE version_seq_id     > 0
                                          AND start_active_date <= (
                                                                        SELECT  nvl(end_active_date,SYSDATE)
                                                                        FROM    EGO_MTL_CATALOG_GRP_VERS_B
                                                                        WHERE   ITEM_CATALOG_GROUP_ID =cp_icc_id
                                                                        AND VERSION_SEQ_ID        =cp_icc_ver

                                                                    )
                                          GROUP BY item_catalog_group_id
                                          HAVING MAX(start_active_date)<=(
                                                                              SELECT  nvl(end_active_date,SYSDATE)
                                                                              FROM    EGO_MTL_CATALOG_GRP_VERS_B
                                                                              WHERE   ITEM_CATALOG_GROUP_ID =cp_icc_id
                                                                              AND VERSION_SEQ_ID        = cp_icc_ver

                                                                          )

                                        )
                              )
                          )
                    )
           UNION
           SELECT ITEM_CATALOG_GROUP_ID,VERSION_SEQ_ID,lev FROM
            ( SELECT iccb.ITEM_CATALOG_GROUP_ID,VERSION_SEQ_ID ,lev
              FROM EGO_MTL_CATALOG_GRP_VERS_B iccb,
                ( SELECT ITEM_CATALOG_GROUP_ID,LEVEL lev
                  FROM MTL_ITEM_CATALOG_GROUPS_B
                  START WITH ITEM_CATALOG_GROUP_ID =cp_icc_id
                  CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID=ITEM_CATALOG_GROUP_ID
                ) hier
              WHERE iccb.item_catalog_group_id=hier.item_catalog_group_id

            )
            WHERE
            (
             cp_publish_parent ='TRUE'
                  AND
                  (
                      LEV           > 1
                      AND (item_catalog_group_id, VERSION_SEQ_ID)
                      IN
                      ( SELECT item_catalog_group_id,VERSION_SEQ_ID
                          FROM    EGO_MTL_CATALOG_GRP_VERS_B
                          WHERE (item_catalog_group_id,start_active_date )
                                IN
                                ( SELECT  item_catalog_group_id, MAX(start_active_date) start_active_date
                                  FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                  WHERE  creation_date     <= ( SELECT  CREATION_DATE
                                                                FROM    EGO_MTL_CATALOG_GRP_VERS_B
                                                                WHERE   ITEM_CATALOG_GROUP_ID = cp_icc_id
                                                                AND VERSION_SEQ_ID        = cp_icc_ver
                                                              )
                                  AND version_seq_id     > 0
                                  AND start_active_date <= (
                                                                SELECT  CREATION_DATE
                                                                FROM    EGO_MTL_CATALOG_GRP_VERS_B
                                                                WHERE   ITEM_CATALOG_GROUP_ID =cp_icc_id
                                                                AND VERSION_SEQ_ID        = cp_icc_ver

                                                           )
                                  GROUP BY item_catalog_group_id
                                  HAVING   MAX(start_active_date)<=(
                                                                      SELECT  CREATION_DATE
                                                                      FROM    EGO_MTL_CATALOG_GRP_VERS_B
                                                                      WHERE   ITEM_CATALOG_GROUP_ID =cp_icc_id
                                                                      AND VERSION_SEQ_ID        = cp_icc_ver

                                                                    )
                                )
                      )
                  )
            );





          l_parent_hier         VARCHAR2(10);
          l_child_hier          VARCHAR2(10);
          batch_entity_rec      EGO_PUB_FWK_PK.TBL_OF_BAT_ENT_OBJ_TYPE;
          x_return_status       VARCHAR2(1);
          x_msg_count           NUMBER;
          x_msg_data            VARCHAR2(500);
          l_batch_id            NUMBER;
          l_mode                VARCHAR2(30);
          l_icc_parent_pub_tab  dbms_sql.VARCHAR2_table;
          l_icc_child_pub_tab   dbms_sql.VARCHAR2_table;
          l_batch_search_str    VARCHAR2(100):='/ICCQueryParam/BatchId';
          l_search_str          VARCHAR2(100):='/ICCQueryParam/ICCPubEntityObject';
          l_access_priv         BOOLEAN       :=TRUE;
          --l_valid_bat_entity    BOOLEAN       :=TRUE;
          l_valid_entity        BOOLEAN       :=TRUE;
          l_batch_entity_count  NUMBER        :=0;
BEGIN
     -- Check access priviledge for Setup Workbench for a user
    l_access_priv:= Check_Access_Priv(p_session_id,p_odi_session_id,G_ICC_WEBSERVICE);
    -- If user has access then continue else log information in information table
    -- and exit procedure
    IF(l_access_priv) THEN

        /* Call API to find out invocation mode and batch_id, Batch_Id will be -1 if mode is LIST*/
        Invocation_Mode( p_session_id,l_batch_search_str,l_mode,l_batch_id);

        --If mode is batch then batch_id will have value greater than -1
        IF l_batch_id >-1 THEN
            --Validate batch
            /*l_valid_bat_entity  := validate_entity(p_session_id,p_odi_session_id,l_batch_id,
                                              G_ICC_WEBSERVICE,NULL,NULL,NULL,NULL,NULL);*/


            SELECT pk1_value , nvl(pk2_value,-1)
            BULK COLLECT INTO  l_dup_icc_id_tab, l_dup_icc_ver_tab
            FROM Ego_Pub_Bat_Ent_Objs_v   --Find out if any other PK's
            WHERE batch_id = l_batch_id  AND user_entered = 'Y';


            /* FIND OUT PARENT AND CHILD ICC's also need to publish
            It will return TRUE if need to publish else FALSE */
            SELECT Upper(CHAR_VALUE) INTO l_parent_hier FROM EGO_PUB_BAT_PARAMS_b  WHERE type_id=l_batch_id AND Upper(parameter_name) ='PUBLISHPARENT';
            SELECT Upper(CHAR_VALUE) INTO l_child_hier FROM EGO_PUB_BAT_PARAMS_b  WHERE type_id=l_batch_id AND  Upper(parameter_name) ='PUBLISHCHILD';

        ELSE

            /*Extract value into array if ICCId node exist in Input table*/
            SELECT  extractValue(ICC_Id, '/ICCId')
            BULK COLLECT INTO  l_dup_icc_id_tab
            FROM (SELECT  Value(iccid) ICC_Id
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                        extract(i.xmlcontent, '/ICCQueryParam/ICCIdentifiersList/ICCIdentifier/ICCId') )) iccid
                    WHERE  session_id=p_session_id
                  );


            /*Extract value into array if VersionSequence node exist in Input table*/
            SELECT   Nvl(extractValue(ICC_Ver, '/VersionSequence'),-1)
            BULK COLLECT INTO  l_dup_icc_ver_tab
            FROM  (SELECT  Value(iccver) ICC_Ver
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                        extract(i.xmlcontent, '/ICCQueryParam/ICCIdentifiersList/ICCIdentifier/VersionSequence') )) iccver
                    WHERE  session_id=p_session_id
                  );

            /* Find out if parent ICC's need to publish for a ICC*/
            SELECT  upper(Nvl(extractValue(ICC_Id, '/ParentICCs'),'FALSE'))
            INTO  l_parent_hier
            FROM (SELECT  Value(iccid) ICC_Id
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                        extract(i.xmlcontent, '/ICCQueryParam/ICCPubEntityObject/ParentICCs') )) iccid
                    WHERE session_id=p_session_id
                  );

            /* Find out if child ICC's need to publish for a ICC*/
            SELECT  upper(Nvl(extractValue(ICC_Id, '/ChildICCs'),'FALSE'))
            INTO  l_child_hier
            FROM (SELECT  Value(iccid) ICC_Id
                    FROM EGO_PUB_WS_PARAMS i,
                    TABLE(XMLSequence(
                        extract(i.xmlcontent, '/ICCQueryParam/ICCPubEntityObject/ChildICCs') )) iccid
                    WHERE session_id=p_session_id
                  );


        END IF; --IF l_batch_id >-1 THEN


        /*Populating config parameter*/
        Create_Config_Param(p_session_id,p_odi_session_id,G_ICC_WEBSERVICE,l_search_str,l_parent_hier,l_child_hier);

        IF (l_batch_id >-1) THEN
          --IF (l_valid_bat_entity) THEN
               --Bug 8767131
              /*Execute cursor to publish data into temporary table */
              FOR i IN 1..l_dup_icc_id_tab.Count
              LOOP

                /*If ICC version is not passed then find out current effective version for passed in ICC
                and store in version array table*/
                IF  l_dup_icc_ver_tab(i)=-1 THEN
                  BEGIN
                    SELECT version_seq_id INTO l_dup_icc_ver_tab(i)
                    FROM
                    ( SELECT item_catalog_group_id,version_seq_id,MAX(start_active_date) start_active_date
                      FROM EGO_MTL_CATALOG_GRP_VERS_B
                      WHERE NVL(end_active_date, sysdate) >=  SYSDATE
                      AND start_active_date <= SYSDATE
                      AND   ITEM_CATALOG_GROUP_ID  =  l_dup_icc_id_tab(i)
                      AND version_seq_id > 0
                      GROUP BY item_catalog_group_id,version_seq_id
                      HAVING   MAX(start_active_date)<=SYSDATE
                    );
                  EXCEPTION
                      WHEN No_Data_Found THEN
                        l_dup_icc_ver_tab(i):=NULL;
                  END;
                END IF;

                l_icc_parent_pub_tab(i):= l_parent_hier;
                l_icc_child_pub_tab(i):=  l_child_hier;

                /*Once get ICC id and corresponding version_id get child ICC's for Each ICC*/

                /* Executing cursor to get associated child and their version for passed in icc_id and icc_version*/
                FOR j IN cur_icc_ver(l_dup_icc_id_tab(i),l_dup_icc_ver_tab(i),l_icc_parent_pub_tab(i),l_icc_child_pub_tab(i))
                LOOP

                  FOR k IN 1..l_icc_id_tab.Count
                  LOOP
                      IF(j.item_catalog_group_id =  l_icc_id_tab(k) )
                      THEN
                        IF(j.version_seq_id=l_icc_ver_tab(k)  OR
                              ( j.version_seq_id IS NULL AND l_icc_ver_tab(k) IS NULL ))
                        THEN
                           l_is_duplicate:=TRUE;
                        ELSE
                           l_ref1_value:='DUP';
                        END IF;

                      END IF; -- End IF(j.item_catalog_group_id =  l_icc_id_tab(k) )
                  END LOOP;  --END FOR k IN 1..l_icc_id_tab.Count

                  IF(NOT l_is_duplicate) THEN
                      l_icc_id_tab(l_unique_icc_count):=  j.item_catalog_group_id;
                      l_icc_ver_tab(l_unique_icc_count):=  j.version_seq_id;
                      l_unique_icc_count:=l_unique_icc_count+1;


                    INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value,pk4_value,pk5_value,ref1_value)
                    VALUES (p_session_id,p_odi_session_id,'ItemCatalogCategory',j.item_catalog_group_id,j.version_seq_id,NULL,NULL,NULL,l_ref1_value);


                    IF( j.item_catalog_group_id <>  l_dup_icc_id_tab(i)) THEN   --Bug Fix 8708269.Dont insert record for main Entity again
                                    --Bug 8757388
                                    l_batch_entity_count  :=l_batch_entity_count+1;
                                    batch_entity_rec(l_batch_entity_count).batch_id:=l_batch_id;
                                    batch_entity_rec(l_batch_entity_count).pk1_value:=j.item_catalog_group_id;
                                    batch_entity_rec(l_batch_entity_count).pk2_value:=j.version_seq_id;
                                    batch_entity_rec(l_batch_entity_count).pk3_value:=NULL ;
                                    batch_entity_rec(l_batch_entity_count).pk4_value:=NULL ;
                                    batch_entity_rec(l_batch_entity_count).pk5_value:=NULL ;
                                    batch_entity_rec(l_batch_entity_count).user_entered:= 'N';
                                    --END Bug 8757388

                    END IF; --END IF( j.item_catalog_group_id <>  l_icc_id_tab(i)) THEN

                  END IF;   -- END IF(NOT l_is_duplicate) THEN

                  l_is_duplicate:=FALSE;
                  l_ref1_value:=NULL;

                END LOOP; /*End FOR j IN cur_icc_ver(l_icc_id_tab(i),l_icc_ver_tab(i)) */

              END LOOP;/*FOR i IN 1..l_icc_id_tab.Count*/
              /* Calling Add_Derived_Entitites API once per batch to have status update.*/
              --Bug 8757388
              EGO_PUB_FWK_PK.add_derived_entities(batch_entity_rec,x_return_status,x_msg_count,x_msg_data);

          --END IF;--END IF (l_valid_bat_entity) THEN

        ELSE --Case of list of entities

          /*Execute cursor to publish data into temporary table */
          FOR i IN 1..l_dup_icc_id_tab.Count
          LOOP

            /*If ICC version is not passed then find out current effective version for passed in ICC
            and store in version array table*/
            IF  l_dup_icc_ver_tab(i)=-1 THEN
              BEGIN
                SELECT version_seq_id INTO l_dup_icc_ver_tab(i)
                FROM
                ( SELECT item_catalog_group_id,version_seq_id,MAX(start_active_date) start_active_date
                  FROM EGO_MTL_CATALOG_GRP_VERS_B
                  WHERE NVL(end_active_date, sysdate) >=  SYSDATE
                  AND start_active_date <= SYSDATE
                  AND   ITEM_CATALOG_GROUP_ID  =  l_dup_icc_id_tab(i)
                  AND version_seq_id > 0
                  GROUP BY item_catalog_group_id,version_seq_id
                  HAVING   MAX(start_active_date)<=SYSDATE
                );
              EXCEPTION
                  WHEN No_Data_Found THEN
                    l_dup_icc_ver_tab(i):=NULL;
              END;
            END IF;

            l_icc_parent_pub_tab(i):= l_parent_hier;
            l_icc_child_pub_tab(i):=  l_child_hier;

            l_valid_entity:= validate_entity(p_session_id,p_odi_session_id,NULL,
                                            G_ICC_WEBSERVICE,l_dup_icc_id_tab(i),l_dup_icc_ver_tab(i),
                                              NULL,NULL,NULL);

            IF(l_valid_entity)
            THEN
                /*Once get ICC id and corresponding version_id get child ICC's for Each ICC*/
                /* Executing cursor to get associated child and their version for passed in icc_id and icc_version*/
                FOR j IN cur_icc_ver(l_dup_icc_id_tab(i),l_dup_icc_ver_tab(i),l_icc_parent_pub_tab(i),l_icc_child_pub_tab(i))
                LOOP
                    FOR k IN 1..l_icc_id_tab.Count
                    LOOP
                        IF(j.item_catalog_group_id =  l_icc_id_tab(k) )
                        THEN
                          IF(j.version_seq_id=l_icc_ver_tab(k) OR
                                  ( j.version_seq_id IS NULL AND l_icc_ver_tab(k) IS NULL ))
                          THEN
                                l_is_duplicate:=TRUE;
                          ELSE
                                l_ref1_value:='DUP';
                          END IF;
                        END IF; --End IF(j.item_catalog_group_id =  l_icc_id_tab(k) )

                    END LOOP;  --END FOR k IN 1..l_icc_id_tab.Count

                    IF(NOT l_is_duplicate) THEN
                        l_icc_id_tab(l_unique_icc_count):=  j.item_catalog_group_id;
                        l_icc_ver_tab(l_unique_icc_count):=  j.version_seq_id;
                        l_unique_icc_count:=l_unique_icc_count+1;

                        INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value,pk4_value,pk5_value,ref1_value)
                        VALUES (p_session_id,p_odi_session_id,'ItemCatalogCategory',j.item_catalog_group_id,j.version_seq_id,NULL,NULL,NULL,l_ref1_value);

                    END IF;   -- END IF(NOT l_is_duplicate) THEN

                    l_is_duplicate:=FALSE;
                    l_ref1_value:=NULL;


                END LOOP; /*End FOR j IN cur_icc_ver(l_dup_icc_id_tab(i),l_dup_icc_ver_tab(i)) */
            END IF; --END IF(l_valid_entity)

          END LOOP;/*FOR i IN 1..l_icc_id_tab.Count*/

        END IF;--END IF (l_batch_id >-1) THEN
    --END Bug 8767131
    END IF;  -- END IF(l_access_priv) THEN
    COMMIT;
    /*EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;*/
END Preprocess_Input_ICC;


/* Procedure to finding out List of ICC's and their version and to publish hierarchy of ICC to temporary table*/
PROCEDURE Preprocess_Input_valueSet   (  p_session_id      IN NUMBER,
                                         p_odi_session_id  IN NUMBER )

IS

          l_vs_id_tab           dbms_sql.Number_Table;  --Netsed table of varchar2 to store ICC_Id's
          l_vs_ver_tab          dbms_sql.Number_Table;  --Netsed table of varchar2 to store ICC Version
          l_count               NUMBER;

         --Bug 8767131
          l_dup_vs_id_tab       dbms_sql.Number_Table;  --Netsed table of varchar2 to store ICC_Id's
          l_dup_vs_ver_tab      dbms_sql.Number_Table;  --Netsed table of varchar2 to store ICC Version
          l_unique_val_count    NUMBER:=1;
          l_is_duplicate        BOOLEAN       :=FALSE;
          l_ref1_value          VARCHAR2(200):=NULL;
          --Bug 8767131

          l_parent_hier         VARCHAR2(10);
          l_child_hier          VARCHAR2(10);
          batch_entity_rec      EGO_PUB_FWK_PK.TBL_OF_BAT_ENT_OBJ_TYPE;
          x_return_status       VARCHAR2(1);
          x_msg_count           NUMBER;
          x_msg_data            VARCHAR2(500);
          l_batch_id            NUMBER;
          l_mode                VARCHAR2(30);
          l_icc_parent_pub_tab  dbms_sql.VARCHAR2_table;
          l_icc_child_pub_tab   dbms_sql.VARCHAR2_table;
          l_batch_search_str    VARCHAR2(100):='/ValuesetQueryParam/BatchId';
          l_search_str          VARCHAR2(100):='/ValuesetQueryParam';
          l_access_priv         BOOLEAN       :=TRUE;
--          l_valid_bat_entity    BOOLEAN       :=TRUE;
          l_valid_entity        BOOLEAN       :=TRUE;

          l_batch_entity_count  NUMBER        :=0;
          /*Cursor to get child value set*/
          CURSOR Cur_vs_list(cp_value_set_id NUMBER , cp_version_seq_id NUMBER )
          IS
          SELECT value_set_id, version_seq_id
          FROM
            (
              ( SELECT value_set_id,NULL AS version_seq_id
                FROM ego_value_sets_v
                WHERE cp_version_seq_id IS NULL
                  START WITH  value_set_id = cp_value_set_id
                  CONNECT BY PRIOR  value_set_id = parent_value_set_id
              )
              UNION ALL
              /*( SELECT flex_value_set_id value_set_id ,version_seq_id
                FROM  EGO_FLEX_VALUESET_VERSION_B
                WHERE flex_value_set_id=  cp_value_set_id
                  AND cp_version_seq_id IS NOT NULL
                  AND NVL(end_active_date, sysdate) >=  SYSDATE
               AND start_active_date <= SYSDATE
                  AND version_seq_id>0
              ) */
              (SELECT cp_value_set_id AS value_set_id, cp_version_seq_id AS version_seq_id
               FROM dual
               WHERE cp_version_seq_id IS NOT NULL
              )
            );


BEGIN
    -- Check access priviledge for Setup Workbench for a user
    l_access_priv:= Check_Access_Priv(p_session_id,p_odi_session_id,G_VS_WEBSERVICE);
    -- If user has access then continue else log information in information table
    -- and exit procedure
    IF(l_access_priv) THEN

          /* Call API to find out invocation mode and batch_id, Batch_Id will be -1 if mode is LIST*/
          Invocation_Mode( p_session_id,l_batch_search_str,l_mode,l_batch_id);

          --Bug 8767131
          --If mode is batch then batch_id will have value greater than -1
          IF l_batch_id >-1 THEN
              /*l_valid_bat_entity:= validate_entity(p_session_id,p_odi_session_id,l_batch_id,
                                                   G_VS_WEBSERVICE,NULL,NULL,NULL,NULL,NULL);*/

              SELECT pk1_value , Nvl(pk2_value,-1)   --Bug 8722729
              BULK COLLECT INTO  l_dup_vs_id_tab, l_dup_vs_ver_tab
              FROM Ego_Pub_Bat_Ent_Objs_v   --Find out if any other PK's
              WHERE batch_id = l_batch_id  AND user_entered = 'Y';


          ELSE

              /*Extract value into array if ICCId node exist in Input table*/
              SELECT  extractValue(ValueSet_Id, '/ValueSetId')
              BULK COLLECT INTO  l_dup_vs_id_tab
              FROM (SELECT  Value(VSId) ValueSet_Id
                      FROM EGO_PUB_WS_PARAMS i,
                      TABLE(XMLSequence(
                         extract(i.xmlcontent, '/ValuesetQueryParam/ValuesetIdentifiersList/ValuesetIdentifier/ValueSetId') )) VSId
                      WHERE  session_id=p_session_id
                    );


              /*Extract value into array if VersionSequence node exist in Input table*/
              SELECT   Nvl(extractValue(ValueSet_Ver, '/VersionSeqId'),-1)
              BULK COLLECT INTO  l_dup_vs_ver_tab
              FROM  (SELECT  Value(VSVer) ValueSet_Ver
                      FROM EGO_PUB_WS_PARAMS i,
                      TABLE(XMLSequence(
                         extract(i.xmlcontent, '/ValuesetQueryParam/ValuesetIdentifiersList/ValuesetIdentifier/VersionSeqId') )) VSVer
                      WHERE  session_id=p_session_id
                    );
          END IF; --IF l_batch_id >-1 THEN

          /*Populating config parameter*/
          --Create_Config_Param_ValueSet(p_session_id,p_odi_session_id);
          Create_Config_Param(p_session_id,p_odi_session_id,G_VS_WEBSERVICE,l_search_str,NULL,NULL);

          IF (l_batch_id >-1 )
          THEN
            /*Execute cursor to publish data into temporary table */
            FOR i IN 1..l_dup_vs_id_tab.Count
            LOOP
             --Bug 8722729
             /*If VS version is not passed then find out current effective version for passed in VS
             and store in version array table*/
             IF  l_dup_vs_ver_tab(i)=-1 THEN
                BEGIN
              SELECT version_seq_id INTO l_dup_vs_ver_tab(i)
              FROM EGO_FLEX_VALUESET_VERSION_B
              WHERE NVL(end_active_date, sysdate) >=  SYSDATE
               AND start_active_date <= SYSDATE
               AND  FLEX_VALUE_SET_ID  = l_dup_vs_id_tab(i)
               AND version_seq_id > 0;
             EXCEPTION
              WHEN No_Data_Found THEN
                  l_dup_vs_ver_tab(i):=NULL;
                END;
             END IF; --END IF  l_vs_ver_tab(i)=0 THEN  --YJ Changed for bug 8736726


              /*Once get ICC id and corresponding version_id get child ICC's for Each ICC*/

              /* Executing cursor to get associated child and their version for passed in icc_id and icc_version*/
              FOR j IN Cur_vs_list(l_dup_vs_id_tab(i), l_dup_vs_ver_tab(i) )
              LOOP
                FOR k IN 1..l_vs_id_tab.Count
                LOOP
                    IF(j.value_set_id=  l_vs_id_tab(k) )
                    THEN

                        IF( j.version_seq_id=l_vs_ver_tab(k) OR
                            (j.version_seq_id IS NULL AND l_vs_ver_tab(k) IS null )  )
                        THEN
                            l_is_duplicate:=TRUE;
                        ELSE
                            l_ref1_value:='DUP';
                        END IF;

                    END IF; --END IF(l_dup_vs_id_tab(i)=  l_vs_id_tab(k) )
                END LOOP; --END FOR k IN 1..l_vs_id_tab.Count


                IF(NOT l_is_duplicate) THEN
                    l_vs_id_tab(l_unique_val_count):= j.value_set_id; -- l_dup_vs_id_tab(i);
                    l_vs_ver_tab(l_unique_val_count):=j.version_seq_id; -- NULL;  l_dup_vs_ver_tab(i);
                    l_unique_val_count:=l_unique_val_count+1;


                    INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value,pk4_value,pk5_value,ref1_value)
                     VALUES (p_session_id,p_odi_session_id,'ValueSet',j.value_set_id,j.version_seq_id,NULL,NULL,NULL,l_ref1_value);


                    IF( j.value_set_id <>  l_dup_vs_ver_tab(i)) THEN   --Bug Fix 8708269.Dont insert record for main Entity again
                                      --Bug 8757388
                                      l_batch_entity_count  :=l_batch_entity_count+1;
                                      batch_entity_rec(l_batch_entity_count).batch_id:=l_batch_id;
                                      batch_entity_rec(l_batch_entity_count).pk1_value:=j.value_set_id;
                                      batch_entity_rec(l_batch_entity_count).pk2_value:=NULL ;  --A child value set can only be created for a non version VS.
                                      batch_entity_rec(l_batch_entity_count).pk3_value:=NULL ;
                                      batch_entity_rec(l_batch_entity_count).pk4_value:=NULL ;
                                      batch_entity_rec(l_batch_entity_count).pk5_value:=NULL ;
                                      batch_entity_rec(l_batch_entity_count).user_entered:= 'N';
                                      --END Bug 8757388
                    END IF; --END  IF( j.value_set_id <>  l_dup_vs_ver_tab(i)) THEN

                END IF; --END IF(NOT l_is_duplicate) THEN
                l_is_duplicate:=FALSE;
                l_ref1_value:=NULL;
              END LOOP; -- end FOR j IN cur_child_vs(l_dup_vs_id_tab(i) )


                  /*FOR k IN 1..l_vs_id_tab.Count
                  LOOP
                      IF(l_dup_vs_id_tab(i)=  l_vs_id_tab(k) )
                      THEN

                          IF( l_dup_vs_ver_tab(i)=l_vs_ver_tab(k) OR
                              (l_dup_vs_ver_tab(i)IS NULL AND l_vs_ver_tab(k) IS null )  )
                          THEN
                              l_is_duplicate:=TRUE;
                          ELSE
                              l_ref1_value:='DUP';
                          END IF;

                      END IF; --END IF(l_dup_vs_id_tab(i)=  l_vs_id_tab(k) )
                  END LOOP; --END FOR k IN 1..l_vs_id_tab.Count


                  IF(NOT l_is_duplicate) THEN
                      l_vs_id_tab(l_unique_val_count):=  l_dup_vs_id_tab(i);
                      l_vs_ver_tab(l_unique_val_count):=  l_dup_vs_ver_tab(i);
                      l_unique_val_count:=l_unique_val_count+1;


                      INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value,pk4_value,pk5_value,ref1_value)
                       VALUES (p_session_id,p_odi_session_id,'ValueSet',l_dup_vs_id_tab(i),l_dup_vs_ver_tab(i),NULL,NULL,NULL,l_ref1_value);

                  END IF;

                  l_is_duplicate:=FALSE;
                l_ref1_value:=NULL;       */

            END LOOP;/*FOR i IN 1..l_dup_vs_id_tab.Count*/
            /*Calling API for derived entity*/
            EGO_PUB_FWK_PK.add_derived_entities(batch_entity_rec,x_return_status,x_msg_count,x_msg_data);


          ELSE -- Case of list mode
              /*Execute cursor to publish data into temporary table */
              FOR i IN 1..l_dup_vs_id_tab.Count
              LOOP

                /*If VS version is not passed then find out current effective version for passed in VS
                and store in version array table*/
                IF  l_dup_vs_ver_tab(i)=-1 THEN
                    BEGIN
                    SELECT version_seq_id INTO l_dup_vs_ver_tab(i)
                    FROM EGO_FLEX_VALUESET_VERSION_B
                    WHERE NVL(end_active_date, sysdate) >=  SYSDATE
                      AND start_active_date <= SYSDATE
                      AND  FLEX_VALUE_SET_ID  = l_dup_vs_id_tab(i)
                      AND version_seq_id > 0;
                   EXCEPTION
                    WHEN No_Data_Found THEN
                        l_dup_vs_ver_tab(i):=NULL;
                    END;
                END IF; --END IF  l_vs_ver_tab(i)=0 THEN

                l_valid_entity:= validate_entity(p_session_id,p_odi_session_id,NULL,G_VS_WEBSERVICE,
                                                 l_dup_vs_id_tab(i),l_dup_vs_ver_tab(i),NULL,NULL,NULL);

                IF (l_valid_entity)
                THEN

                  /* Executing cursor to get associated child and their version for passed in icc_id and icc_version*/
                  FOR j IN Cur_vs_list(l_dup_vs_id_tab(i), l_dup_vs_ver_tab(i) )
                  LOOP
                    FOR k IN 1..l_vs_id_tab.Count
                    LOOP
                            IF(j.value_set_id = l_vs_id_tab(k) )
                            THEN
                                IF( j.version_seq_id=l_vs_ver_tab(k) OR
                                    (j.version_seq_id IS NULL AND l_vs_ver_tab(k) IS null ) )
                                THEN
                                    l_is_duplicate:=TRUE;
                                ELSE
                                    l_ref1_value:='DUP';
                                END IF;

                            END IF;  --END IF(l_dup_vs_id_tab(i)=  l_vs_id_tab(k) )
                    END LOOP; --END FOR k IN 1..l_vs_id_tab.Count

                    IF(NOT l_is_duplicate) THEN
                        l_vs_id_tab(l_unique_val_count):= j.value_set_id;
                        l_vs_ver_tab(l_unique_val_count):= j.version_seq_id;
                        l_unique_val_count:=l_unique_val_count+1;

                        INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value,pk4_value,pk5_value,ref1_value)
                        VALUES (p_session_id,p_odi_session_id,'ValueSet',j.value_set_id,j.version_seq_id,NULL,NULL,NULL,l_ref1_value);

                    END IF;
                    l_is_duplicate:=FALSE;
                    l_ref1_value:=NULL;

                  END LOOP; /*End FOR j IN cur_icc_ver(l_dup_icc_id_tab(i),l_dup_icc_ver_tab(i)) */

                END IF; -- end IF (l_valid_entity)

                l_valid_entity:=TRUE;

              END LOOP;/* FOR i IN 1..l_vs_id_tab.Count*/

          END IF;  --  END IF (l_batch_id >-1 )
          --END Bug 8722729
    END IF; -- END IF(l_access_priv) THEN
    COMMIT;




                    /*FOR k IN 1..l_vs_id_tab.Count
                    LOOP
                        IF(l_dup_vs_id_tab(i)=  l_vs_id_tab(k) )
                        THEN
                            IF( l_dup_vs_ver_tab(i)=l_vs_ver_tab(k) OR
                                (l_dup_vs_ver_tab(i)IS NULL AND l_vs_ver_tab(k) IS null ) )
                            THEN
                                l_is_duplicate:=TRUE;
                            ELSE
                                l_ref1_value:='DUP';
                            END IF;

                        END IF;  --END IF(l_dup_vs_id_tab(i)=  l_vs_id_tab(k) )
                    END LOOP; --END FOR k IN 1..l_vs_id_tab.Count

                    IF(NOT l_is_duplicate) THEN
                        l_vs_id_tab(l_unique_val_count):=  l_dup_vs_id_tab(i);
                        l_vs_ver_tab(l_unique_val_count):=  l_dup_vs_ver_tab(i);
                        l_unique_val_count:=l_unique_val_count+1;

                        INSERT INTO ego_odi_ws_entities ( session_id,odi_session_id,entity_type,pk1_value,pk2_value,pk3_value,pk4_value,pk5_value,ref1_value)
                        VALUES (p_session_id,p_odi_session_id,'ValueSet',l_dup_vs_id_tab(i),l_dup_vs_ver_tab(i),NULL,NULL,NULL,l_ref1_value);

                    END IF;
                    l_is_duplicate:=FALSE;
                    l_ref1_value:=NULL;

                END IF; -- end IF (l_valid_entity)

                l_valid_entity:=TRUE;

              END LOOP; -- FOR i IN 1..l_vs_id_tab.Count

          END IF;  --  END IF (l_batch_id >-1 )
          --END Bug 8722729
    END IF; -- END IF(l_access_priv) THEN
    COMMIT;    */
END Preprocess_Input_valueSet;



/* Function to check for access priviledge to a user and
return boolean value*/
FUNCTION Check_Access_Priv(p_session_id       IN NUMBER,
                           p_odi_session_id   IN NUMBER,
                           p_web_service_name IN VARCHAR2)
RETURN BOOLEAN
IS
  l_user_name       VARCHAR2(100) :=NULL;
  l_appl_name       VARCHAR2(100) :=NULL;
  l_resp_key       VARCHAR2(100) :=NULL;
  l_resp_name       VARCHAR2(100) :=NULL;
  l_user_id         NUMBER;
  l_resp_id         NUMBER;
  l_application_id  NUMBER;
  count_val         NUMBER        :=0;

  /*Cursor to get I/P value for user_name, resp_name and appl_name */
  CURSOR Cur_ws_input (cp_session_id NUMBER )
  IS
  SELECT fnd_user_name,responsibility_appl_name,responsibility_name
  FROM ego_pub_ws_params
  WHERE session_id=cp_session_id;



  /*Cursor to check if access priv is available to a user and to a responsibility for a function */
  CURSOR Cur_priv(cp_user_id NUMBER,
                  cp_resp_id NUMBER)
  IS
  SELECT Count(furgd.responsibility_id) val
  FROM fnd_user_resp_groups_direct furgd, fnd_responsibility fr
  WHERE  furgd.responsibility_id=fr.responsibility_id
    AND  fr.menu_id IN
     (SELECT menu_id
      FROM fnd_menu_entries
        START WITH function_id IN
          (SELECT function_id
           FROM  fnd_form_functions
           WHERE function_name='EGO_ITEM_ADMINISTRATION'
          )
        CONNECT BY PRIOR menu_id=sub_menu_id
      )
    AND furgd.user_id= cp_user_id
    AND furgd.responsibility_id= cp_resp_id
    AND furgd.start_date <=SYSDATE
    AND Nvl(furgd.end_date,sysdate+1) > SYSDATE;



    l_icc_search_str          VARCHAR2(100) :='/ICCQueryParam/BatchId';
    l_vs_search_str           VARCHAR2(100) :='/ValuesetQueryParam/BatchId';
    l_session_id              NUMBER        :=p_session_id;
    l_mode                    VARCHAR2(30);
    l_batch_id                NUMBER:=-1;
BEGIN
    --Dbms_Output.put_line('Start of  Check_Access_Priv ' );
    IF(p_web_service_name=G_ICC_WEBSERVICE)
    THEN
      Invocation_Mode( l_session_id,l_icc_search_str,l_mode,l_batch_id);

    END IF;


    IF(p_web_service_name=G_VS_WEBSERVICE)
    THEN
      Invocation_Mode( l_session_id,l_vs_search_str,l_mode,l_batch_id);
    END IF;

    --If mode is batch then batch_id will have value greater than -1
    IF l_batch_id >-1 THEN
          --retrieving user_id and responsability
        BEGIN

            --Populate batch identifier
            Populate_Input_Identifier(p_session_id,p_odi_session_id,1,'batch_id',l_batch_id);


            SELECT created_by, responsibility_id
            INTO l_user_id,l_resp_id
            FROM EGO_PUB_BAT_HDR_B
            WHERE batch_id = l_batch_id;

        EXCEPTION
        WHEN No_Data_Found THEN
          Log_Error(p_session_id,p_odi_session_id,1,'EGO_INVALID_BATCH','Input batch is not a valid batch. Please publish valid batch id.');
          RETURN FALSE;
        END;

        --retrieving responsability_id
        SELECT application_id
        INTO l_application_id
        FROM FND_RESPONSIBILITY
        WHERE responsibility_id = l_resp_id;


        /*Get username for passed in user id*/
        BEGIN
          SELECT USER_NAME INTO l_user_name
          FROM FND_USER
          WHERE USER_ID =l_user_id;
        EXCEPTION
          WHEN No_Data_Found THEN
            --Dbms_Output.put_line( ' The User name is not a valid user name.');
            RETURN FALSE;
        END;


        /*Get respId for passed in responsibility name*/
        BEGIN
          SELECT responsibility_name INTO l_resp_name
          FROM fnd_responsibility_vl
          WHERE application_id = l_application_id
            AND responsibility_id =l_resp_id ;
        EXCEPTION
          WHEN No_Data_Found THEN
            --Dbms_Output.put_line( ' The responsibility name is not a valid responsibility name.');
            RETURN FALSE;
        END;


    ELSE --Case when mode is LIST


        FOR i IN Cur_ws_input(p_session_id)
        LOOP
          l_user_name:=i.fnd_user_name;
          l_appl_name:=i.responsibility_appl_name;
          l_resp_key:=i.responsibility_name;
        END LOOP;

        /*Get userId for passed in user name*/
        BEGIN
          SELECT USER_ID INTO l_user_id
          FROM FND_USER
          WHERE USER_NAME =l_user_name;
        EXCEPTION
          WHEN No_Data_Found THEN
            --Dbms_Output.put_line( ' The User name is not a valid user name.');
            RETURN FALSE;
        END;


        /*Get appId for passed in application short name*/
        BEGIN
          SELECT application_id INTO l_application_id
          FROM fnd_application
          WHERE application_short_name =l_appl_name;
        EXCEPTION
          WHEN No_Data_Found THEN
            --Dbms_Output.put_line( ' The application name is not a valid application name.');
            RETURN FALSE;
        END;


        /*Get respId for passed in responsibility name*/
        BEGIN
          SELECT responsibility_id,responsibility_name INTO l_resp_id,l_resp_name
          FROM fnd_responsibility_vl
          WHERE application_id = l_application_id
            AND responsibility_key=l_resp_key;
        EXCEPTION
          WHEN No_Data_Found THEN
            --Dbms_Output.put_line( ' The responsibility name is not a valid responsibility name.');
            RETURN FALSE;
        END;
    END IF;


   /*Initialize apps context*/
    FND_GLOBAL.APPS_INITIALIZE( USER_ID=>l_user_id,
                                RESP_ID=>l_resp_id,
                                RESP_APPL_ID=>l_application_id);



    --Check if user for a responsibility has access to a function
    FOR j IN Cur_priv(l_user_id,l_resp_id)
    LOOP
      count_val:=j.val;
    END LOOP;


    IF(count_val>0) --If user for a responsibility has access to a function
    THEN

      RETURN TRUE;
    ELSE
      -- Log error if user does not have access to function 'EGO_ITEM_ADMINISTRATION'
      Log_Error(p_session_id,p_odi_session_id,NULL,'EGO_FUNCTION_ACCESS_SECURITY','User ' ||l_user_name||' logged in with current responsibility '||l_resp_name ||' does not have access to Setup Workbench ');
      RETURN FALSE ;
    END IF;



END Check_Access_Priv;



/*Procedure to insert records into Input Identifiers table*/
PROCEDURE Populate_Input_Identifier(p_session_id       IN NUMBER,
                                    p_odi_session_id   IN NUMBER,
                                    p_input_id         IN NUMBER,
                                    p_param_name       IN VARCHAR2,
                                    p_param_value      IN VARCHAR2)
IS

BEGIN

        INSERT INTO EGO_PUB_WS_INPUT_IDENTIFIERS(session_id,
                                                odi_session_id,
                                                input_id,
                                                param_name,
                                                param_value,
                                                creation_date,
                                                created_by)
                                         VALUES(p_session_id,
                                                p_odi_session_id,
                                                p_input_id,
                                                p_param_name,
                                                p_param_value,
                                                SYSDATE,
                                                -1);


END Populate_Input_Identifier;

/*Procedure to Log Errors*/
PROCEDURE Log_Error(p_session_id       IN NUMBER,
                    p_odi_session_id   IN NUMBER,
                    p_input_id         IN NUMBER,
                    p_err_code         IN VARCHAR2,
                    p_err_message      IN VARCHAR2)
IS

BEGIN

        INSERT INTO EGO_PUB_WS_ERRORS(session_id,
                                      odi_session_id,
                                      input_id,
                                      err_code,
                                      err_message,
                                      creation_date,
                                      created_by)
                               VALUES(p_session_id,
                                      p_odi_session_id,
                                      p_input_id,
                                      p_err_code,
                                      p_err_message,
                                      SYSDATE,
                                      -1);


END Log_Error;

/*Validate batch and list of entities*/
FUNCTION validate_entity(p_session_id         NUMBER,
                         p_odi_session_id     NUMBER,
                         p_batch_id           NUMBER      DEFAULT  NULL,
                         p_webservice_name    VARCHAR2    DEFAULT  NULL,
                         p_pk1_value          VARCHAR2    DEFAULT  NULL,
                         p_pk2_value          VARCHAR2    DEFAULT  NULL,
                         p_pk3_value          VARCHAR2    DEFAULT  NULL,
                         p_pk4_value          VARCHAR2    DEFAULT  NULL,
                         p_pk5_value          VARCHAR2    DEFAULT  NULL)
RETURN BOOLEAN
AS


  l_batch_count        NUMBER         :=0;
  l_icc_count          NUMBER         :=0;
  l_vs_count           NUMBER         :=0;
  l_pk1_value          VARCHAR2(100) := NULL;
  l_pk2_value          VARCHAR2(100) := NULL;
  l_pk3_value          VARCHAR2(100) := NULL;
  l_pk4_value          VARCHAR2(100) := NULL;
  l_pk5_value          VARCHAR2(100) := NULL;
  l_input_id           NUMBER        :=0;

  --Validate if passed in Batch_Id  to webservices are valid.
  CURSOR cur_batch
  IS
  SELECT Count(batch_id) batch_exist
  FROM ego_pub_bat_hdr_b
  WHERE BATCH_ID= p_batch_id;

  --Cursor for versioned ICC
  CURSOR cur_ver_icc(cp_item_catalog_group_id   NUMBER,
                     cp_version_seq_id          NUMBER)
  IS
  SELECT Count(base.item_catalog_group_id)   ver_icc_count
  FROM mtl_item_catalog_groups_b base ,EGO_MTL_CATALOG_GRP_VERS_B vers
  WHERE base.item_catalog_group_id= vers.item_catalog_group_id
    AND base.item_catalog_group_id=cp_item_catalog_group_id
    AND vers.version_seq_id=Nvl(cp_version_seq_id,vers.version_seq_id)
    AND vers.version_seq_id>0;  --Yjain


  --Cursor for non versioned ICC
  CURSOR cur_icc(cp_item_catalog_group_id   NUMBER)
  IS
  SELECT Count(item_catalog_group_id) icc_count
  FROM mtl_item_catalog_groups_b
  WHERE item_catalog_group_id=cp_item_catalog_group_id;



  --Cursor for versioned VS
  CURSOR cur_ver_vs( cp_flex_value_set_id   NUMBER,
                     cp_version_seq_id          NUMBER)
  IS
  SELECT Count(base.flex_value_set_id)  ver_vs_count
  FROM fnd_flex_value_sets base ,EGO_FLEX_VALUESET_VERSION_B vers
  WHERE base.flex_value_set_id= vers.flex_value_set_id
    AND base.flex_value_set_id=cp_flex_value_set_id
    AND vers.version_seq_id =Nvl(cp_version_seq_id,vers.version_seq_id)
    AND vers.version_seq_id >0; --Yjain



  --Cursor for non versioned VS
  CURSOR cur_vs(cp_flex_value_set_id   NUMBER)
  IS
  SELECT Count(flex_value_set_id)  vs_count
  FROM fnd_flex_value_sets
  WHERE flex_value_set_id=cp_flex_value_set_id;


  CURSOR cur_input_id(cp_session_id     NUMBER,
                      cp_odi_session_id NUMBER)
  IS
  SELECT (Nvl(Max(input_id),0)+1) AS input_id
  FROM EGO_PUB_WS_INPUT_IDENTIFIERS
  WHERE  session_id=cp_session_id
     AND odi_session_id= cp_odi_session_id;

BEGIN

  --Dbms_Output.put_line(' Start of Validate_ENTITY' );
  -- If no input has been passed then log error with no input and return with 'FALSE'.
  IF(p_batch_id IS NULL AND p_webservice_name IS NULL AND p_pk1_value IS NULL AND p_pk2_value IS NULL
      AND p_pk3_value IS NULL AND p_pk4_value IS NULL AND p_pk5_value IS NULL )
  THEN

      Log_Error(p_session_id,p_odi_session_id,NULL,'EGO_NO_INPUT','No input has been provided to webservices');

      /*INSERT INTO EGO_PUB_WS_ERRORS (session_id,odi_session_id,input_id,
                                     err_code,err_message,creation_date,created_by)
      VALUES (p_session_id,p_odi_session_id,NULL,'EGO_NO_INPUT','No input has been provided to webservices');*/

      RETURN FALSE;
  END IF;

  --Get Next input_id for identifier
  FOR i IN cur_input_id(p_session_id,p_odi_session_id)
  LOOP
    l_input_id  := i.input_id;
  END LOOP;


  --Batch mode validation
  /*IF (p_batch_id IS NOT NULL)
  THEN
      Dbms_Output.put_line(' Validate_ENTITY : BATCH MODE' );
      FOR i IN cur_batch
      LOOP
        l_batch_count:=i.batch_exist;
      END LOOP;

      --Populate batch identifier
      Populate_Input_Identifier(p_session_id,p_odi_session_id,l_input_id,'batch_id',p_batch_id);

      --Batch count will be '1' if batch is valid, It will be zero if it is invalid.
      --Insert record if batch is not a valid batch
      IF (l_batch_count<>1)
      THEN

        Log_Error(p_session_id,p_odi_session_id,l_input_id,'EGO_INVALID_BATCH','Input batch is not a valid batch. Please publish valid batch id.');
        RETURN FALSE;
        --INSERT INTO EGO_PUB_WS_ERRORS (session_id,odi_session_id,input_id,
          --                             err_code,err_message,creation_date,created_by)
        --VALUES (p_session_id,p_odi_session_id,NULL,'EGO_INVALID_BATCH','Input batch is not a valid batch. Please publish valid batch id.');
      ELSE
        RETURN TRUE;
      END IF;

  --Case of list of entities
  ELSE  */
      IF(p_webservice_name=G_VS_WEBSERVICE)
      THEN
          IF (p_pk1_value IS NOT NULL AND p_pk2_value IS NOT NULL)
          THEN
              FOR i IN cur_ver_vs(p_pk1_value,p_pk2_value)
              LOOP
                 l_vs_count := i.ver_vs_count;

              END LOOP;  -- End FOR i IN cur_ver_vs

              --Populate list identifier
              Populate_Input_Identifier(p_session_id,p_odi_session_id,l_input_id,'value_set_id',p_pk1_value);
              Populate_Input_Identifier(p_session_id,p_odi_session_id,l_input_id,'value_set_version',p_pk2_value);



              IF (l_vs_count=0 )
              THEN

                 Log_Error(p_session_id,p_odi_session_id,l_input_id,'EGO_INVALID_VS_LIST','Input ValueSetId and VersionId combination is not a valid combination. Please publish valid combination of ValueSetId and VersionId.');
                 RETURN FALSE;
                 /*INSERT INTO EGO_PUB_WS_ERRORS (session_id,odi_session_id,input_id,
                                                err_code,err_message,creation_date,created_by)
                 VALUES (p_session_id,p_odi_session_id,l_input_id,'EGO_INVALID_BATCH','Input batch is not a valid batch. Please publish valid batch id.',SYSDATE,G_CURRENT_USER_ID);*/
              ELSE
                 RETURN TRUE;

              END IF;


          ELSIF (p_pk1_value IS NOT NULL AND p_pk2_value IS NULL)
          THEN
              FOR i IN cur_vs(p_pk1_value)
              LOOP
                 l_vs_count := i.vs_count;

              END LOOP;  -- End FOR i IN cur_vs

              --Populate list identifier
              Populate_Input_Identifier(p_session_id,p_odi_session_id,l_input_id,'value_set_id',p_pk1_value);

              IF (l_vs_count=0 )
              THEN
                 Log_Error(p_session_id,p_odi_session_id,l_input_id,'EGO_INVALID_VS_LIST','Input ValueSetId is not a valid id. Please publish valid ValueSetId.');
                 RETURN FALSE;
                 /*INSERT INTO EGO_PUB_WS_ERRORS (session_id,odi_session_id,input_id,
                                                err_code,err_message,creation_date,created_by)
                 VALUES (p_session_id,p_odi_session_id,NULL,'EGO_INVALID_BATCH','Input batch is not a valid batch. Please publish valid batch id.',SYSDATE,G_CURRENT_USER_ID);*/
              ELSE
                 RETURN TRUE;
              END IF;

          END IF; -- END IF (p_pk1_value IS NOT NULL AND p_pk2_value IS NOT NULL)

      END IF;  --END IF(l_web_service_name=G_VS_WEBSERVICE)

      --When ICC webservices are invoked
      IF(p_webservice_name=G_ICC_WEBSERVICE)
      THEN

          IF (p_pk1_value IS NOT NULL AND p_pk2_value IS NOT NULL)
          THEN
              FOR i IN cur_ver_icc(p_pk1_value,p_pk2_value)
              LOOP
                 l_icc_count := i.ver_icc_count;

              END LOOP;  -- End FOR i IN cur_ver_icc

              --Populate list identifier
              Populate_Input_Identifier(p_session_id,p_odi_session_id,l_input_id,'icc_id',p_pk1_value);
              Populate_Input_Identifier(p_session_id,p_odi_session_id,l_input_id,'icc_version',p_pk2_value);

              IF (l_icc_count=0 )
              THEN
                 Log_Error(p_session_id,p_odi_session_id,l_input_id,'EGO_INVALID_ICC_LIST','Input ICCId and VersionId combination is not a valid combination. Please publish valid combination of ICCId and VersionId.');
                 RETURN FALSE;
                 /*INSERT INTO EGO_PUB_WS_ERRORS (session_id,odi_session_id,input_id,
                                                err_code,err_message,creation_date,created_by)
                 VALUES (p_session_id,p_odi_session_id,NULL,'EGO_INVALID_BATCH','Input batch is not a valid batch. Please publish valid batch id.',SYSDATE,G_CURRENT_USER_ID);*/
              ELSE
                 RETURN TRUE;
              END IF;



          ELSIF (p_pk1_value IS NOT NULL AND p_pk2_value IS NULL)
          THEN
              FOR i IN cur_icc(p_pk1_value)
              LOOP
                  l_icc_count  := i.icc_count; --Yjain

              END LOOP;  -- End FOR i IN cur_icc
              --Populate list identifier
              Populate_Input_Identifier(p_session_id,p_odi_session_id,l_input_id,'icc_id',p_pk1_value);

              IF (l_icc_count=0 )
              THEN
                 Log_Error(p_session_id,p_odi_session_id,l_input_id,'EGO_INVALID_ICC_LIST','Input ICCId is not a valid ICCId. Please publish valid ICCId.');
                 RETURN FALSE;
                 /*INSERT INTO EGO_PUB_WS_ERRORS (session_id,odi_session_id,input_id,
                                                err_code,err_message,creation_date,created_by)
                 VALUES (p_session_id,p_odi_session_id,NULL,'EGO_INVALID_BATCH','Input batch is not a valid batch. Please publish valid batch id.',SYSDATE,G_CURRENT_USER_ID);*/
              ELSE
                 RETURN TRUE;

              END IF;


          END IF; -- END IF (p_pk1_value IS NOT NULL AND p_pk2_value IS NOT NULL)

      END IF; -- END IF(l_web_service_name=G_ICC_WEBSERVICE)


  /*END IF; --  IF (p_batch_id IS NOT NULL)*/
END validate_entity;


/* Populate transaction attribute into flat table */
PROCEDURE POPULATE_TRANS_ATTR_LIST(   p_session_id                IN          NUMBER,
                                      p_odi_session_id            IN          NUMBER)

IS

      l_icc_start_active_date        DATE ;/*ICC start effective date*/
      l_icc_create_date                DATE ;/*ICC create  date*/
      l_version_seq_id                  VARCHAR2(5);


      CURSOR Cur_TA_List (cp_item_catalog_category_id  NUMBER,
                          cp_icc_version_number        NUMBER,
                          cp_creation_date             DATE ,
                          cp_start_active_date         DATE )
      IS

      SELECT * FROM
      (
      SELECT  *
      FROM
              (
                      SELECT  versions.item_catalog_group_id,
                              versions.icc_version_NUMBER   ,
                              attrs.attr_id                  ,
                              attrs.attr_name                ,
                              hier.lev     lev
                      FROM    ego_obj_AG_assocs_b assocs       ,
                              ego_attrs_v attrs                ,
                              ego_attr_groups_v ag             ,
                              EGO_TRANS_ATTR_VERS_B versions,
                              mtl_item_catalog_groups_kfv icv  ,
                              (
                                      SELECT  item_catalog_group_id,
                                              LEVEL lev
                                      FROM    mtl_item_catalog_groups_b
                                      START WITH item_catalog_group_id = cp_item_catalog_category_id
                                      CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                              )
                              hier
                      WHERE   ag.attr_group_type                      = 'EGO_ITEM_TRANS_ATTR_GROUP'
                          AND assocs.attr_group_id                    = ag.attr_group_id
                          AND assocs.classification_code              = TO_CHAR(hier.item_catalog_group_id)
                          AND attrs.attr_group_name                   = ag.attr_group_name
                          AND TO_CHAR(icv.item_catalog_group_id)      = assocs.classification_code
                          AND TO_CHAR(versions.association_id)        = assocs.association_id
                          AND TO_CHAR(versions.item_catalog_group_id) = assocs.classification_code
                          AND attrs.attr_id                           = versions.attr_id

              )


      )
      WHERE
      (
        ( LEV = 1 AND ICC_VERSION_number =cp_icc_version_number )
        OR
        ( LEV > 1 AND ( item_catalog_group_id, ICC_VERSION_NUMBER )
                  IN ( SELECT  item_catalog_group_id, VERSION_SEQ_ID
                      FROM EGO_MTL_CATALOG_GRP_VERS_B
                      WHERE (item_catalog_group_id,start_active_date )
                              IN
                            (SELECT  item_catalog_group_id, MAX(start_active_date) start_active_date
                            FROM    EGO_MTL_CATALOG_GRP_VERS_B
                            WHERE  creation_date <= cp_creation_date
                                AND version_seq_id > 0
                                AND  start_active_date <=  cp_start_active_date
                            GROUP BY item_catalog_group_id
                            HAVING MAX(start_active_date)<=cp_start_active_date
                            )
                      AND version_seq_id > 0
                    )
        )
      );


      CURSOR cur_icc_list
      IS
      SELECT sequence_id,parent_sequence_id,pk1_value icc_id ,pk2_value icc_ver
      FROM EGO_PUB_WS_FLAT_RECS
      WHERE session_id= p_session_id
          AND odi_session_id=p_odi_session_id
          AND entity_type ='ICCVersion';


     l_icc_ta_metadata_tbl      EGO_TRAN_ATTR_TBL;
     l_return_status               VARCHAR2(1):=NULL ;
     l_vs_version_number        NUMBER;
     l_is_inherited                  Varchar2(10);
     l_is_modified                   Varchar2(10);

BEGIN
    --Dbms_Output.put_line(' Start point for POPULATE_TRANS_ATTR_LIST ' );
     l_icc_ta_metadata_tbl := EGO_TRAN_ATTR_TBL(NULL);
     /* If input parameter has been passed then process data*/
     FOR j IN cur_icc_list
     LOOP
     --IF(p_item_catalog_category_id IS NOT NULL AND p_icc_version IS NOT NULL AND p_icc_version > 0) THEN

            --Finding out start effcetive date and creation date of ICC Version
                --Dbms_Output.put_line(' In Loop for POPULATE_TRANS_ATTR_LIST  j.icc_id = '|| j.icc_id || ' Ver '|| j.icc_ver );
                SELECT  Nvl(START_ACTIVE_DATE,SYSDATE) ,CREATION_DATE INTO l_icc_start_active_date, l_icc_create_date
                FROM    EGO_MTL_CATALOG_GRP_VERS_B
                WHERE ITEM_CATALOG_GROUP_ID = j.icc_id  AND   VERSION_SEQ_ID =  j.icc_ver;


                FOR k IN Cur_TA_List(j.icc_id,j.icc_ver,l_icc_create_date,l_icc_start_active_date)
                LOOP
                  --Dbms_Output.put_line(' In Loop for POPULATE_TRANS_ATTR_LIST  j.icc_id = '|| j.icc_id || ' Ver '|| j.icc_ver||' TA Id ='||k.attr_id );
                  EGO_TRANSACTION_ATTRS_PVT.GET_TRANS_ATTR_METADATA(
                                               x_ta_metadata_tbl =>l_icc_ta_metadata_tbl,
                                               p_item_catalog_category_id => j.icc_id,
                                               p_icc_version => j.icc_ver,
                                               p_attribute_id =>  k.attr_id,
                                               p_inventory_item_id => null ,
                                               p_organization_id   => null,
                                               p_revision_id   => NULL,
                                               x_return_status => l_return_status,
                                               x_is_inherited =>  l_is_inherited,
                                               x_is_modified => l_is_modified );


                --Dbms_Output.put_line(' Length for table = l_icc_ta_metadata_tbl.last '||l_icc_ta_metadata_tbl.last );
                FOR i IN  l_icc_ta_metadata_tbl.first..l_icc_ta_metadata_tbl.last
                LOOP
                   ego_ext_fwk_pub.get_version_number(1,l_icc_ta_metadata_tbl(i).valuesetid,
                                                      l_icc_start_active_date,l_icc_create_date,l_vs_version_number,l_return_status);


                 INSERT
                  INTO   EGO_PUB_WS_FLAT_RECS
                        (
                                SESSION_ID        ,
                                ODI_SESSION_ID    ,
                                ENTITY_TYPE       ,
                                SEQUENCE_ID       ,
                                PARENT_SEQUENCE_ID,
                                PAYLOAD_SEQUENCE  ,
                                PK1_VALUE         ,
                                REF1_VALUE        ,
                                REF2_VALUE        ,
                                REF3_VALUE        ,
                                REF4_VALUE        ,
                                VALUE             ,
                                CREATION_DATE
                        )
                        (SELECT p_session_id                         ,
                                  p_odi_session_id                     ,
                                  'TransactionAttribute'             ,
                                  EGO_PUB_WS_FLAT_RECS_S.NEXTVAL     ,
                                  j.sequence_id                      ,
                                  1                                  ,
                                  l_icc_ta_metadata_tbl(i).attrid    ,
                                  j.icc_id                           ,
                                  j.icc_ver                          ,
                                  l_icc_ta_metadata_tbl(i).valuesetid,
                                  l_vs_version_number                ,
                                  xmlforest(k.attr_name AS AttrName,
                                            l_icc_ta_metadata_tbl(i).attrid AS AttributeId,
                                            l_icc_ta_metadata_tbl(i).AttrDisplayName AS AttrDisplayName,
                                            l_icc_ta_metadata_tbl(i).SEQUENCE AS AttrSequence,
                                            l_icc_ta_metadata_tbl(i).uomclass AS UOMCLASS,
                                            l_icc_ta_metadata_tbl(i).defaultvalue AS DefaultValue,
                                            l_icc_ta_metadata_tbl(i).rejectedvalue AS RejectedValue,
                                            l_icc_ta_metadata_tbl(i).requiredflag AS RequiredFlag,
                                            l_icc_ta_metadata_tbl(i).readonlyflag AS ReadOnlyFlag,
                                            l_icc_ta_metadata_tbl(i).hiddenflag AS HiddenFlag,
                                            l_icc_ta_metadata_tbl(i).searchableflag AS SearchableFlag,
                                            l_icc_ta_metadata_tbl(i).checkeligibility AS CheckEligibility,
                                            l_is_inherited AS INHERITED,
                                            l_is_modified AS MODIFIED ).getclobval(),
                                  SYSDATE
                         FROM    dual
                      );

                END LOOP;
       END LOOP;

     --END IF;
     END LOOP;
     --Dbms_Output.put_line(' End point for POPULATE_TRANS_ATTR_LIST ' );
     COMMIT;
END  POPULATE_TRANS_ATTR_LIST;

PROCEDURE POPULATE_VSTBLINFO_VSSVC(p_Session_Id    IN NUMBER,
                                   p_ODISession_Id IN NUMBER)
IS

CURSOR  Table_VS_List IS  -- Get all the TableInfo entity type records from Flat table for given Session Id and ODI Session Id
        SELECT ego_pub_ws_flat_recs.sequence_id,
               ego_validation_table_info_v.flex_value_set_id,
               ego_validation_table_info_v.additional_where_clause

        FROM   ego_pub_ws_flat_recs,
               ego_validation_table_info_v

        WHERE      ego_pub_ws_flat_recs.pk1_value      = ego_validation_table_info_v.flex_value_set_id
               AND ego_pub_ws_flat_recs.session_id     = p_Session_Id
               AND ego_pub_ws_flat_recs.odi_session_id = p_ODISession_Id
               AND ego_pub_ws_flat_recs.entity_type    = 'TableInfo';

TempLong LONG;  -- Temporary variable

BEGIN

        /* Insert Table Information into Flat except Where Clause because
           WhereClause Column is of Type 'LONG' and it is working with XML DB Functions*/
        /* Entity Type of the record will be 'TableInfo' which will be child of 'ValueSet' element*/
        INSERT
        INTO   ego_pub_ws_flat_recs
               (
                      session_id        ,
                      odi_session_id    ,
                      entity_type       ,
                      sequence_id       ,
                      parent_sequence_id,
                      pk1_value         ,
                      value             ,
                      creation_date
               )
        SELECT p_Session_Id,
               p_ODISession_Id,
               'TableInfo',
               ego_pub_ws_flat_recs_s.nextval,
               ego_pub_ws_flat_recs.sequence_id,
               ego_validation_table_info_v.flex_value_set_id,
               XMLCONCAT(   XMLELEMENT("AppName",ego_validation_table_info_v.table_application_name),
                            XMLELEMENT("AppId",ego_validation_table_info_v.table_application_id),
                            XMLELEMENT("TableName",ego_validation_table_info_v.application_table_name),
                            XMLELEMENT("ValueColName",ego_validation_table_info_v.value_column_name),
                            XMLELEMENT("ValueColType",ego_validation_table_info_v.value_column_type),
                            XMLELEMENT("ValueColSize",ego_validation_table_info_v.value_column_size),
                            XMLELEMENT("IDColName",ego_validation_table_info_v.id_column_name),
                            XMLELEMENT("IDColType",ego_validation_table_info_v.id_column_type),
                            XMLELEMENT("IDColSize",ego_validation_table_info_v.id_column_size),
                            XMLELEMENT("MeaningColName",ego_validation_table_info_v.meaning_column_name),
                            XMLELEMENT("MeaningColType",ego_validation_table_info_v.meaning_column_type),
                            XMLELEMENT("MeaningColSize",ego_validation_table_info_v.meaning_column_size)
                         ).getClobVal(),
               SYSDATE
        FROM   ego_pub_ws_flat_recs,
               ego_validation_table_info_v
        WHERE  ego_pub_ws_flat_recs.pk1_value=ego_validation_table_info_v.flex_value_set_id
           AND (
                      ego_pub_ws_flat_recs.session_id      = p_Session_Id
                  AND ego_pub_ws_flat_recs.odi_session_id  = p_ODISession_Id
                  AND ego_pub_ws_flat_recs.entity_type     = 'ValueSet'
                  AND ego_pub_ws_flat_recs.pk2_value IS NULL
                  AND ego_pub_ws_flat_recs.ref1_value      = 'F'
               );

        /*Insert WhereClause in to Flat table.This record will be Child of 'TableInfo' element*/
        /*INSERT
        INTO   ego_pub_ws_flat_recs
               (
                      session_id        ,
                      odi_session_id    ,
                      entity_type       ,
                      sequence_id       ,
                      parent_sequence_id,
                      pk1_value         ,
                      value             ,
                      creation_date
               )
        SELECT p_Session_Id,
               p_ODISession_Id,
               'WhereClause',
               ego_pub_ws_flat_recs_s.nextval,
               ego_pub_ws_flat_recs.sequence_id,
               ego_validation_table_info_v.flex_value_set_id,
               To_Lob(ego_validation_table_info_v.additional_where_clause),
               SYSDATE
        FROM   ego_pub_ws_flat_recs,
               ego_validation_table_info_v
        WHERE  ego_pub_ws_flat_recs.pk1_value=ego_validation_table_info_v.flex_value_set_id
           AND (
                      ego_pub_ws_flat_recs.session_id     = p_Session_Id
                  AND ego_pub_ws_flat_recs.odi_session_id = p_ODISession_Id
                  AND ego_pub_ws_flat_recs.entity_type    = 'TableInfo'
               );*/

       FOR rec IN Table_VS_List -- For each 'TableInfo' entity type record in Flat table
       LOOP

        TempLong := '<![CDATA[' || rec.additional_where_clause || ']]>'; --Enclose WhereClause with CDATA to avoid XMLParsing errors if WhereClause contains <,> char.s

        INSERT
        INTO   ego_pub_ws_flat_recs
               (
                      session_id        ,
                      odi_session_id    ,
                      entity_type       ,
                      sequence_id       ,
                      parent_sequence_id,
                      pk1_value         ,
                      value             ,
                      creation_date
               )
               VALUES
               (
                      p_Session_Id                  ,
                      p_ODISession_Id               ,
                      'WhereClause'                 ,
                      ego_pub_ws_flat_recs_s.nextval,  -- Sequence Id for record
                      rec.sequence_id               ,  -- Parent record Sequence Id
                      rec.flex_value_set_id         ,  -- VlaueSet Id
                      TempLong                      ,  -- enclosed WhereClause value
                      SYSDATE
               );
       END LOOP;

       COMMIT; --Commit the Data

END POPULATE_VSTBLINFO_VSSVC;


PROCEDURE POPULATE_VSTBLINFO_ICCSVC(p_Session_Id    IN NUMBER,
                                    p_ODISession_Id IN NUMBER)
IS

CURSOR Table_VS_List IS -- Get all the 'TableInfo' entity type records from Flat table for given Session Id and ODI Session Id
        SELECT ego_pub_ws_flat_recs.sequence_id,
               ego_validation_table_info_v.flex_value_set_id,
               ego_validation_table_info_v.additional_where_clause

        FROM   ego_pub_ws_flat_recs,
               ego_validation_table_info_v

        WHERE  ego_pub_ws_flat_recs.pk1_value      = ego_validation_table_info_v.flex_value_set_id
           AND ego_pub_ws_flat_recs.session_id     = p_Session_Id
           AND ego_pub_ws_flat_recs.odi_session_id = p_ODISession_Id
           AND ego_pub_ws_flat_recs.entity_type    = 'TableInfo';

TempLong LONG; -- Temporary variable

BEGIN

        /* Insert Table Information into Flat except Where Clause because
           WhereClause Column is of Type 'LONG' and it is working with XML DB Functions*/
        /* Entity Type of the record will be 'TableInfo' which will be child of 'ValueSet' element*/
        INSERT
        INTO   ego_pub_ws_flat_recs
               (
                      session_id        ,
                      odi_session_id    ,
                      entity_type       ,
                      sequence_id       ,
                      parent_sequence_id,
                      pk1_value         ,
                      value             ,
                      creation_date
               )
        SELECT p_Session_Id,
               p_ODISession_Id,
               'TableInfo',
               ego_pub_ws_flat_recs_s.nextval,
               ego_pub_ws_flat_recs.sequence_id,
               ego_validation_table_info_v.flex_value_set_id,
               XMLCONCAT(   XMLELEMENT("AppName",ego_validation_table_info_v.table_application_name),
                            XMLELEMENT("AppId",ego_validation_table_info_v.table_application_id),
                            XMLELEMENT("TableName",ego_validation_table_info_v.application_table_name),
                            XMLELEMENT("ValueColName",ego_validation_table_info_v.value_column_name),
                            XMLELEMENT("ValueColType",ego_validation_table_info_v.value_column_type),
                            XMLELEMENT("ValueColSize",ego_validation_table_info_v.value_column_size),
                            XMLELEMENT("IDColName",ego_validation_table_info_v.id_column_name),
                            XMLELEMENT("IDColType",ego_validation_table_info_v.id_column_type),
                            XMLELEMENT("IDColSize",ego_validation_table_info_v.id_column_size),
                            XMLELEMENT("MeaningColName",ego_validation_table_info_v.meaning_column_name),
                            XMLELEMENT("MeaningColType",ego_validation_table_info_v.meaning_column_type),
                            XMLELEMENT("MeaningColSize",ego_validation_table_info_v.meaning_column_size)
                         ).getClobVal(),
               SYSDATE
        FROM   ego_pub_ws_flat_recs,
               ego_validation_table_info_v
        WHERE  ego_pub_ws_flat_recs.pk1_value=ego_validation_table_info_v.flex_value_set_id
           AND (
                      ego_pub_ws_flat_recs.session_id      = p_Session_Id
                  AND ego_pub_ws_flat_recs.odi_session_id  = p_ODISession_Id
                  AND ego_pub_ws_flat_recs.entity_type     = 'Valueset'
                  AND ego_pub_ws_flat_recs.ref1_value      = 'UDA'
      AND ego_pub_ws_flat_recs.ref2_value      = 'F'
               );

        /*Insert WhereClause in to Flat table.This record will be Child of 'TableInfo' element*/
        /*INSERT
        INTO   ego_pub_ws_flat_recs
               (
                      session_id        ,
                      odi_session_id    ,
                      entity_type       ,
                      sequence_id       ,
                      parent_sequence_id,
                      pk1_value         ,
                      value             ,
                      creation_date
               )
        SELECT p_Session_Id,
               p_ODISession_Id,
               'WhereClause',
               ego_pub_ws_flat_recs_s.nextval,
               ego_pub_ws_flat_recs.sequence_id,
               ego_validation_table_info_v.flex_value_set_id,
               To_Lob(ego_validation_table_info_v.additional_where_clause),
               SYSDATE
        FROM   ego_pub_ws_flat_recs,
               ego_validation_table_info_v
        WHERE  ego_pub_ws_flat_recs.pk1_value=ego_validation_table_info_v.flex_value_set_id
           AND (
                      ego_pub_ws_flat_recs.session_id     = p_Session_Id
                  AND ego_pub_ws_flat_recs.odi_session_id = p_ODISession_Id
                  AND ego_pub_ws_flat_recs.entity_type    = 'TableInfo'
               );*/

       FOR rec IN Table_VS_List -- For each 'TableInfo' entity type record in Flat table
       LOOP

        TempLong := '<![CDATA[' || rec.additional_where_clause || ']]>'; --Enclose WhereClause with CDATA to avoid XMLParsing errors if WhereClause contains <,> char.s

        INSERT
        INTO   ego_pub_ws_flat_recs
               (
                      session_id        ,
                      odi_session_id    ,
                      entity_type       ,
                      sequence_id       ,
                      parent_sequence_id,
                      pk1_value         ,
                      value             ,
                      creation_date
               )
               VALUES
               (
                      p_Session_Id                  ,
                      p_ODISession_Id               ,
                      'WhereClause'                 ,
                      ego_pub_ws_flat_recs_s.nextval,  -- Sequence Id for record
                      rec.sequence_id               ,  -- Parent record Sequence Id
                      rec.flex_value_set_id         ,  -- VlaueSet Id
                      TempLong                      ,  -- enclosed WhereClause value
                      SYSDATE
               );
       END LOOP;

       COMMIT; --Commit the Data

END POPULATE_VSTBLINFO_ICCSVC;


END EGO_ODI_PUB;

/
