--------------------------------------------------------
--  DDL for Package Body MODAL_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MODAL_DELETE" AS
/*$Header: BOMMDELB.pls 120.1 2005/06/21 05:24:45 appldev ship $*/

/* ---------------------------- Delete_Manager ------------------------------*/
/*
NAME
     Delete_Manager
DESCRIPTION
     Create Delete Groups for Bills, Components, Routings and Operations for
     Bill and Routing forms.
REQUIRES
                new_group_seq_id        Seq Id of new group
                name                    Delete Group name
                group_desc              Delete Group description
                org_id                  Org Id
                bom_or_eng              1 - bom
					2 - eng
                del_type		2 - Bill
					3 - Routing
					4 - Component
					5 - Operation
                ent_bill_seq_id         Bill Seq Id
                ent_rtg_seq_id          Routing Seq Id
                ent_inv_item_id         Bill or Routing Item Id
                ent_alt_designator      Bill or Routing Alternate
                ent_comp_seq_id         Component Sequence Id
                ent_op_seq_id           Operation Sequence Id
                user_id                 User Id
MODIFIES
     BOM_DELETE_GROUPS
     BOM_DELETE_ENTITIES
     BOM_DELETE_SUB_ENTITIES
RETURNS
     New Delete Group Sequence Id
NOTES
     Function sends error message to Forms message line and raises an
     exception if there is an error.
-----------------------------------------------------------------------------*/
FUNCTION DELETE_MANAGER(
                new_group_seq_id        IN NUMBER,
                name                    IN VARCHAR2,
                group_desc              IN VARCHAR2,
                org_id                  IN NUMBER,
                bom_or_eng              IN NUMBER,
                del_type                IN NUMBER,
                ent_bill_seq_id         IN NUMBER,
                ent_rtg_seq_id          IN NUMBER,
                ent_inv_item_id         IN NUMBER,
                ent_alt_designator      IN VARCHAR2,
                ent_comp_seq_id         IN NUMBER,
                ent_op_seq_id           IN NUMBER,
                user_id                 IN NUMBER
                   ) RETURN NUMBER IS
ITEM    CONSTANT NUMBER 			:= 1;
BOM	CONSTANT NUMBER				:= 2;
ROUTING CONSTANT NUMBER				:= 3;
COMP    CONSTANT NUMBER 			:= 4;
OPER    CONSTANT NUMBER 			:= 5;

new_group_seq_id_v 		NUMBER := new_group_seq_id;
err_msg			 	VARCHAR2(240);
sql_stmt_num			NUMBER;
status_value			NUMBER;
del_header			NUMBER;
Cursor GetNewGroup is
  SELECT BOM_DELETE_GROUPS_S.NEXTVAL group_id
  FROM SYS.DUAL;
Cursor GetEntity is
  Select bde.delete_entity_sequence_id
  From   bom_delete_entities bde
  Where  bde.delete_group_sequence_id = new_group_seq_id_v
  And    nvl(bde.bill_sequence_id, 0) = nvl(ent_bill_seq_id, 0)
  And	 nvl(bde.routing_sequence_id, 0) = nvl(ent_rtg_seq_id, 0)
  And    nvl(bde.inventory_item_id, 0) = nvl(ent_inv_item_id, 0)
  And	 nvl(bde.organization_id, 0) = nvl(org_id, 0);
X_EntSeqId bom_delete_entities.delete_entity_sequence_id%type := null;
Cursor GetNewEntity is
  Select BOM_DELETE_ENTITIES_S.NEXTVAL Entity_Id
  From sys.dual;
Cursor GetComponent is
  SELECT BIC.COMPONENT_SEQUENCE_ID,
         BIC.EFFECTIVITY_DATE,
         BIC.DISABLE_DATE,
         BIC.FROM_END_ITEM_UNIT_NUMBER,
         BIC.TO_END_ITEM_UNIT_NUMBER,
         BIC.ITEM_NUM,
         BIC.OPERATION_SEQ_NUM,
         BIC.COMPONENT_ITEM_ID,
         MSIK.CONCATENATED_SEGMENTS,
         MSIK.DESCRIPTION
  FROM MTL_SYSTEM_ITEMS_KFV MSIK,
       BOM_INVENTORY_COMPONENTS BIC
  WHERE BIC.COMPONENT_SEQUENCE_ID = ent_comp_seq_id
  AND MSIK.INVENTORY_ITEM_ID = BIC.COMPONENT_ITEM_ID
  AND MSIK.ORGANIZATION_ID = org_id
  AND NOT EXISTS (
    SELECT NULL
    FROM BOM_DELETE_SUB_ENTITIES BDSE
    WHERE BDSE.DELETE_ENTITY_SEQUENCE_ID = X_EntSeqId
    AND   BDSE.COMPONENT_SEQUENCE_ID = BIC.COMPONENT_SEQUENCE_ID);
Cursor GetOperation is
  SELECT BOS.OPERATION_SEQUENCE_ID,
         BOS.EFFECTIVITY_DATE,
         BOS.DISABLE_DATE,
         BOS.OPERATION_SEQ_NUM,
         BOS.OPERATION_DESCRIPTION,
         BD.DEPARTMENT_CODE
  FROM BOM_DEPARTMENTS BD,
       BOM_OPERATION_SEQUENCES BOS
  WHERE BOS.OPERATION_SEQUENCE_ID = ent_op_seq_id
  AND BOS.DEPARTMENT_ID = BD.DEPARTMENT_ID
  AND NOT EXISTS (
    SELECT NULL
    FROM BOM_DELETE_SUB_ENTITIES BDSE
    WHERE BDSE.DELETE_ENTITY_SEQUENCE_ID = X_EntSeqId
    AND   BDSE.OPERATION_SEQUENCE_ID = BOS.OPERATION_SEQUENCE_ID);
BEGIN
     SAVEPOINT BEGIN_DELETE;

     IF new_group_seq_id IS NULL THEN
       sql_stmt_num :=10;
       For X_NewGroup in GetNewGroup loop
         new_group_seq_id_v := X_NewGroup.group_id;

         sql_stmt_num :=20;

          INSERT INTO BOM_DELETE_GROUPS
		(DELETE_GROUP_SEQUENCE_ID,
 	 	DELETE_GROUP_NAME,
		ORGANIZATION_ID,
	 	DELETE_TYPE,
	 	ACTION_TYPE,
	 	DATE_LAST_SUBMITTED,
	 	DESCRIPTION,
	 	ENGINEERING_FLAG,
	 	LAST_UPDATE_DATE,
	 	LAST_UPDATED_BY,
	 	CREATION_DATE,
	 	CREATED_BY,
	 	LAST_UPDATE_LOGIN,
	 	REQUEST_ID,
	 	PROGRAM_APPLICATION_ID,
	 	PROGRAM_ID,
	 	PROGRAM_UPDATE_DATE,
                ORGANIZATION_HIERARCHY,
                DELETE_ORG_TYPE,
                DELETE_COMMON_BILL_FLAG)
     	  VALUES
		(new_group_seq_id_v,
	 	name,
	 	org_id,
	 	del_type,
	 	1,
	 	NULL,
	 	group_desc,
	 	bom_or_eng,
	 	SYSDATE,
	 	user_id,
	 	SYSDATE,
	 	user_id,
	 	user_id,
	 	NULL,
	 	NULL,
	 	NULL,
	 	NULL,
                NULL,
                1,
                2);
       End loop;
     END IF;
IF del_type = COMP THEN
        status_value := NULL;
	del_header := BOM;
ELSIF del_type = OPER then
	status_value := NULL;
	del_header := ROUTING;
ELSE
	status_value := 1;
	del_header := del_type;
END IF;

-- Check for duplicate Entities
For X_Entity in GetEntity loop
  X_EntSeqId := X_Entity.delete_entity_sequence_id;
End loop;
If X_EntSeqId is null then
  sql_stmt_num := 30;
  For X_NewEntity in GetNewEntity loop
    X_EntSeqId := X_NewEntity.Entity_Id;

    sql_stmt_num := 40;
    INSERT INTO bom_delete_entities
	(DELETE_ENTITY_SEQUENCE_ID,
	 DELETE_GROUP_SEQUENCE_ID,
	 DELETE_ENTITY_TYPE,
	 BILL_SEQUENCE_ID,
	 ROUTING_SEQUENCE_ID,
	 INVENTORY_ITEM_ID,
	 ORGANIZATION_ID,
	 ALTERNATE_DESIGNATOR,
	 ITEM_DESCRIPTION,
	 ITEM_CONCAT_SEGMENTS,
	 DELETE_STATUS_TYPE,
	 DELETE_DATE,
	 PRIOR_PROCESS_FLAG,
	 PRIOR_COMMIT_FLAG,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID ,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE)
    SELECT
	 X_EntSeqId,
	 new_group_seq_id_v,
	 del_header,
	 ent_bill_seq_id,
	 ent_rtg_seq_id,
	 ent_inv_item_id,
	 org_id,
	 ent_alt_designator,
         MSIK.DESCRIPTION,
	 MSIK.CONCATENATED_SEGMENTS,
	 status_value,  		-- PENDING
	 NULL,		-- Delete date should be null
	 2,		-- Prior process flag
	 1,		-- Prior Commit flag
	 SYSDATE,
	 user_id,
	 SYSDATE,
	 user_id,
	 user_id,
	 NULL,
	 NULL,
	 NULL,
	 NULL
    FROM MTL_SYSTEM_ITEMS_KFV MSIK
    WHERE MSIK.INVENTORY_ITEM_ID = ent_inv_item_id
    AND MSIK.ORGANIZATION_ID = org_id;
  End loop; -- new entity
End if; -- entity did not exist

-- Avoid duplicate subentities.  If Component or Operation already exists,
-- the cursor will be empty.  Otherwise it will have only one row.

If del_type = COMP then
  sql_stmt_num := 50;
  For X_Component in GetComponent loop
    sql_stmt_num := 60;
    INSERT INTO bom_delete_sub_entities
	(DELETE_ENTITY_SEQUENCE_ID,
	 COMPONENT_SEQUENCE_ID,
 	 OPERATION_SEQUENCE_ID,
	 OPERATION_SEQ_NUM,
	 EFFECTIVITY_DATE,
	 FROM_END_ITEM_UNIT_NUMBER,
	 COMPONENT_ITEM_ID,
	 COMPONENT_CONCAT_SEGMENTS,
	 ITEM_NUM,
	 DISABLE_DATE,
	 TO_END_ITEM_UNIT_NUMBER,
	 DESCRIPTION,
	 OPERATION_DEPARTMENT_CODE,
	 DELETE_STATUS_TYPE,
	 DELETE_DATE,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE)
       VALUES
	(X_EntSeqId,
	 X_Component.COMPONENT_SEQUENCE_ID,
 	 null,
	 X_Component.OPERATION_SEQ_NUM,
	 X_Component.EFFECTIVITY_DATE,
	 X_Component.FROM_END_ITEM_UNIT_NUMBER,
	 X_Component.COMPONENT_ITEM_ID,
	 X_Component.CONCATENATED_SEGMENTS,
	 X_Component.ITEM_NUM,
	 X_Component.DISABLE_DATE,
	 X_Component.TO_END_ITEM_UNIT_NUMBER,
	 X_Component.DESCRIPTION,
	 null,
	 1,
	 NULL,
	 SYSDATE,
	 user_id,
	 SYSDATE,
	 user_id,
	 user_id,
	 NULL,
	 NULL,
	 NULL,
	 NULL);
  End loop; -- insert component
Elsif del_type = OPER then
  sql_stmt_num := 70;
  For X_Operation in GetOperation loop
    sql_stmt_num := 80;
    INSERT INTO bom_delete_sub_entities
	(DELETE_ENTITY_SEQUENCE_ID,
	 COMPONENT_SEQUENCE_ID,
 	 OPERATION_SEQUENCE_ID,
	 OPERATION_SEQ_NUM,
	 EFFECTIVITY_DATE,
	 COMPONENT_ITEM_ID,
	 COMPONENT_CONCAT_SEGMENTS,
	 ITEM_NUM,
	 DISABLE_DATE,
	 DESCRIPTION,
	 OPERATION_DEPARTMENT_CODE,
	 DELETE_STATUS_TYPE,
	 DELETE_DATE,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE)
       VALUES
	(X_EntSeqId,
	 null,
 	 X_Operation.OPERATION_SEQUENCE_ID,
	 X_Operation.OPERATION_SEQ_NUM,
	 X_Operation.EFFECTIVITY_DATE,
	 null,
	 null,
	 null,
	 X_Operation.DISABLE_DATE,
	 X_Operation.OPERATION_DESCRIPTION,
	 X_Operation.DEPARTMENT_CODE,
	 1,
	 NULL,
	 SYSDATE,
	 user_id,
	 SYSDATE,
	 user_id,
	 user_id,
	 NULL,
	 NULL,
	 NULL,
	 NULL);
  End loop; -- insert operation
End if;

RETURN new_group_seq_id_v;

EXCEPTION
	WHEN OTHERS THEN
		err_msg := 'MODAL DELETE (' ||sql_stmt_num||' ) ' || SQLERRM;
		FND_MESSAGE.SET_NAME('BOM', 'BOM_SQL_ERR');
		FND_MESSAGE.SET_TOKEN('ENTITY', err_msg);
		ROLLBACK TO BEGIN_DELETE;
		APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_MANAGER;


/* --------------------------- Delete_Manager_Oi ----------------------------*/
/*
NAME
     Delete_Manager_Oi
DESCRIPTION
     Create Delete Groups for Bills, Components, Routings and Operations for
     the Open Interface program.
REQUIRES
                new_group_seq_id        Seq Id of new group
                name                    Delete Group name
                group_desc              Delete Group description
                org_id                  Org Id
                bom_or_eng              1 - bom
					2 - eng
                del_type		2 - Bill
					3 - Routing
					4 - Component
					5 - Operation
                ent_bill_seq_id         Bill Seq Id
                ent_rtg_seq_id          Routing Seq Id
                ent_inv_item_id         Bill or Routing Item Id
                ent_alt_designator      Bill or Routing Alternate
                ent_comp_seq_id         Component Sequence Id
                ent_op_seq_id           Operation Sequence Id
                user_id                 User Id
MODIFIES
     BOM_DELETE_GROUPS
     BOM_DELETE_ENTITIES
     BOM_DELETE_SUB_ENTITIES
RETURNS
     0 if successful
     SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION DELETE_MANAGER_OI(
                new_group_seq_id        IN NUMBER,
                name                    IN VARCHAR2,
                group_desc              IN VARCHAR2,
                org_id                  IN NUMBER,
                bom_or_eng              IN NUMBER,
                del_type                IN NUMBER,
                ent_bill_seq_id         IN NUMBER,
                ent_rtg_seq_id          IN NUMBER,
                ent_inv_item_id         IN NUMBER,
                ent_alt_designator      IN VARCHAR2,
                ent_comp_seq_id         IN NUMBER,
                ent_op_seq_id           IN NUMBER,
                user_id                 IN NUMBER,
		err_text	       IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                   ) RETURN NUMBER IS
   ITEM    CONSTANT NUMBER 			:= 1;
   BOM	   CONSTANT NUMBER			:= 2;
   ROUTING CONSTANT NUMBER			:= 3;
   COMP    CONSTANT NUMBER 			:= 4;
   OPER    CONSTANT NUMBER 			:= 5;

   new_group_seq_id_v 		NUMBER := new_group_seq_id;
   sql_stmt_num			NUMBER;
   status_value			NUMBER;
   del_header			NUMBER;
   INVALID_GRP                  EXCEPTION;

   Cursor DelGrpType is
     Select delete_type
     From BOM_DELETE_GROUPS
     WHERE DELETE_GROUP_NAME = name;

   Cursor GetNewGroup is
     SELECT BOM_DELETE_GROUPS_S.NEXTVAL group_id
       FROM SYS.DUAL;

   Cursor GetEntity is
     Select bde.delete_entity_sequence_id
       From bom_delete_entities bde
      Where bde.delete_group_sequence_id = new_group_seq_id_v
        And nvl(bde.bill_sequence_id, 0) = nvl(ent_bill_seq_id, 0)
        And nvl(bde.routing_sequence_id, 0) = nvl(ent_rtg_seq_id, 0)
        And nvl(bde.inventory_item_id, 0) = nvl(ent_inv_item_id, 0)
        And nvl(bde.organization_id, 0) = nvl(org_id, 0);

   X_EntSeqId bom_delete_entities.delete_entity_sequence_id%type := null;

   Cursor GetNewEntity is
     Select BOM_DELETE_ENTITIES_S.NEXTVAL Entity_Id
       From sys.dual;

   Cursor GetComponent is
     SELECT BIC.COMPONENT_SEQUENCE_ID,
            BIC.EFFECTIVITY_DATE,
            BIC.DISABLE_DATE,
            BIC.ITEM_NUM,
            BIC.OPERATION_SEQ_NUM,
            BIC.COMPONENT_ITEM_ID,
            MSIK.CONCATENATED_SEGMENTS,
            MSIK.DESCRIPTION
       FROM MTL_SYSTEM_ITEMS_KFV MSIK,
            BOM_INVENTORY_COMPONENTS BIC
      WHERE BIC.COMPONENT_SEQUENCE_ID = ent_comp_seq_id
        AND MSIK.INVENTORY_ITEM_ID = BIC.COMPONENT_ITEM_ID
        AND MSIK.ORGANIZATION_ID = org_id
        AND NOT EXISTS (
            SELECT NULL
              FROM BOM_DELETE_SUB_ENTITIES BDSE
             WHERE BDSE.DELETE_ENTITY_SEQUENCE_ID = X_EntSeqId
               AND BDSE.COMPONENT_SEQUENCE_ID = BIC.COMPONENT_SEQUENCE_ID);

   Cursor GetOperation is
     SELECT BOS.OPERATION_SEQUENCE_ID,
            BOS.EFFECTIVITY_DATE,
            BOS.DISABLE_DATE,
            BOS.OPERATION_SEQ_NUM,
            BOS.OPERATION_DESCRIPTION,
            BD.DEPARTMENT_CODE
       FROM BOM_DEPARTMENTS BD,
            BOM_OPERATION_SEQUENCES BOS
      WHERE BOS.OPERATION_SEQUENCE_ID = ent_op_seq_id
        AND BOS.DEPARTMENT_ID = BD.DEPARTMENT_ID
        AND NOT EXISTS (
            SELECT NULL
              FROM BOM_DELETE_SUB_ENTITIES BDSE
             WHERE BDSE.DELETE_ENTITY_SEQUENCE_ID = X_EntSeqId
               AND BDSE.OPERATION_SEQUENCE_ID = BOS.OPERATION_SEQUENCE_ID);
l_UserId                NUMBER;
l_LoginId               NUMBER;
l_RequestId             NUMBER;
l_ProgramId             NUMBER;
l_ApplicationId         NUMBER;
BEGIN
  -- who columns
  l_UserId := nvl(Fnd_Global.USER_ID, -1);
  l_LoginId := Fnd_Global.LOGIN_ID;
  l_RequestId := Fnd_Global.CONC_REQUEST_ID;
  l_ProgramId := Fnd_Global.CONC_PROGRAM_ID;
  l_ApplicationId := Fnd_Global.PROG_APPL_ID;

   SAVEPOINT BEGIN_DELETE;

   For X_DelType in DelGrpType loop

     if (del_type = BOM) then
      if  (X_DelType.delete_type not in (2,6)) then
       err_text:= 'Delete Grp type:'||to_char(X_DelType.delete_type) ||
                 'Delete Type:'||to_char(del_type)||
                 'Invalid delete group type';
       raise INVALID_GRP;
      end if;
     elsif (del_type = ROUTING) then
       if (X_DelType.delete_type not in (3,6)) then
        err_text:= 'Delete Grp type:'||to_char(X_DelType.delete_type) ||
                 'Delete Type:'||to_char(del_type)||
                 'Invalid delete group type';
        raise INVALID_GRP;
       end if;
     elsif X_DelType.delete_type <> del_type then
        err_text:= 'Delete Grp type:'||to_char(X_DelType.delete_type) ||
                 'Delete Type:'||to_char(del_type)||
                 'Invalid delete group type';
        raise INVALID_GRP;
     end if;
   end loop;

   IF new_group_seq_id IS NULL THEN
       sql_stmt_num :=10;
       For X_NewGroup in GetNewGroup loop
         new_group_seq_id_v := X_NewGroup.group_id;

         sql_stmt_num :=20;

          INSERT INTO BOM_DELETE_GROUPS
		(DELETE_GROUP_SEQUENCE_ID,
 	 	DELETE_GROUP_NAME,
		ORGANIZATION_ID,
	 	DELETE_TYPE,
	 	ACTION_TYPE,
	 	DATE_LAST_SUBMITTED,
	 	DESCRIPTION,
	 	ENGINEERING_FLAG,
	 	LAST_UPDATE_DATE,
	 	LAST_UPDATED_BY,
	 	CREATION_DATE,
	 	CREATED_BY,
	 	LAST_UPDATE_LOGIN,
	 	REQUEST_ID,
	 	PROGRAM_APPLICATION_ID,
	 	PROGRAM_ID,
	 	PROGRAM_UPDATE_DATE,
                ORGANIZATION_HIERARCHY,
                DELETE_ORG_TYPE,
                DELETE_COMMON_BILL_FLAG)
     	  VALUES
		(new_group_seq_id_v,
	 	name,
	 	org_id,
	 	del_type,
	 	1,
	 	NULL,
	 	group_desc,
	 	bom_or_eng,
	 	SYSDATE,
	 	l_UserId,
	 	SYSDATE,
	 	l_UserId,
	 	l_LoginId,
	 	l_RequestId,
	 	l_ApplicationId,
	 	l_ProgramId,
	 	sysdate,
                NULL,
                1,
                2);
       End loop;
     END IF;
IF del_type = COMP THEN
        status_value := NULL;
	del_header := BOM;
ELSIF del_type = OPER then
	status_value := NULL;
	del_header := ROUTING;
ELSE
	status_value := 1;
	del_header := del_type;
END IF;

-- Check for duplicate Entities
For X_Entity in GetEntity loop
  X_EntSeqId := X_Entity.delete_entity_sequence_id;
End loop;
If X_EntSeqId is null then
  sql_stmt_num := 30;
  For X_NewEntity in GetNewEntity loop
    X_EntSeqId := X_NewEntity.Entity_Id;

    sql_stmt_num := 40;
    INSERT INTO bom_delete_entities
	(DELETE_ENTITY_SEQUENCE_ID,
	 DELETE_GROUP_SEQUENCE_ID,
	 DELETE_ENTITY_TYPE,
	 BILL_SEQUENCE_ID,
	 ROUTING_SEQUENCE_ID,
	 INVENTORY_ITEM_ID,
	 ORGANIZATION_ID,
	 ALTERNATE_DESIGNATOR,
	 ITEM_DESCRIPTION,
	 ITEM_CONCAT_SEGMENTS,
	 DELETE_STATUS_TYPE,
	 DELETE_DATE,
	 PRIOR_PROCESS_FLAG,
	 PRIOR_COMMIT_FLAG,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID ,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE)
    SELECT
	 X_EntSeqId,
	 new_group_seq_id_v,
	 del_header,
	 ent_bill_seq_id,
	 ent_rtg_seq_id,
	 ent_inv_item_id,
	 org_id,
	 ent_alt_designator,
         MSIK.DESCRIPTION,
	 MSIK.CONCATENATED_SEGMENTS,
	 status_value,  		-- PENDING
	 NULL,		-- Delete date should be null
	 2,		-- Prior process flag
	 1,		-- Prior Commit flag
	 SYSDATE,
	 l_UserId,
	 SYSDATE,
	 l_UserId,
	 l_LoginId,
	 l_RequestId,
	 l_ApplicationId,
	 l_ProgramId,
	 sysdate
    FROM MTL_SYSTEM_ITEMS_KFV MSIK
    WHERE MSIK.INVENTORY_ITEM_ID = ent_inv_item_id
    AND MSIK.ORGANIZATION_ID = org_id;
  End loop; -- new entity
End if; -- entity did not exist

-- Avoid duplicate subentities.  If Component or Operation already exists,
-- the cursor will be empty.  Otherwise it will have only one row.

If del_type = COMP then
  sql_stmt_num := 50;
  For X_Component in GetComponent loop
    sql_stmt_num := 60;
    INSERT INTO bom_delete_sub_entities
	(DELETE_ENTITY_SEQUENCE_ID,
	 COMPONENT_SEQUENCE_ID,
 	 OPERATION_SEQUENCE_ID,
	 OPERATION_SEQ_NUM,
	 EFFECTIVITY_DATE,
	 COMPONENT_ITEM_ID,
	 COMPONENT_CONCAT_SEGMENTS,
	 ITEM_NUM,
	 DISABLE_DATE,
	 DESCRIPTION,
	 OPERATION_DEPARTMENT_CODE,
	 DELETE_STATUS_TYPE,
	 DELETE_DATE,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE)
       VALUES
	(X_EntSeqId,
	 X_Component.COMPONENT_SEQUENCE_ID,
 	 null,
	 X_Component.OPERATION_SEQ_NUM,
	 X_Component.EFFECTIVITY_DATE,
	 X_Component.COMPONENT_ITEM_ID,
	 X_Component.CONCATENATED_SEGMENTS,
	 X_Component.ITEM_NUM,
	 X_Component.DISABLE_DATE,
	 X_Component.DESCRIPTION,
	 null,
	 1,
	 NULL,
	 SYSDATE,
	 l_UserId,
	 SYSDATE,
	 l_UserId,
	 l_LoginId,
	 l_RequestId,
	 l_ApplicationId,
	 l_ProgramId,
	 sysdate);
  End loop; -- insert component
Elsif del_type = OPER then
  sql_stmt_num := 70;
  For X_Operation in GetOperation loop
    sql_stmt_num := 80;
    INSERT INTO bom_delete_sub_entities
	(DELETE_ENTITY_SEQUENCE_ID,
	 COMPONENT_SEQUENCE_ID,
 	 OPERATION_SEQUENCE_ID,
	 OPERATION_SEQ_NUM,
	 EFFECTIVITY_DATE,
	 COMPONENT_ITEM_ID,
	 COMPONENT_CONCAT_SEGMENTS,
	 ITEM_NUM,
	 DISABLE_DATE,
	 DESCRIPTION,
	 OPERATION_DEPARTMENT_CODE,
	 DELETE_STATUS_TYPE,
	 DELETE_DATE,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE)
       VALUES
	(X_EntSeqId,
	 null,
 	 X_Operation.OPERATION_SEQUENCE_ID,
	 X_Operation.OPERATION_SEQ_NUM,
	 X_Operation.EFFECTIVITY_DATE,
	 null,
	 null,
	 null,
	 X_Operation.DISABLE_DATE,
	 X_Operation.OPERATION_DESCRIPTION,
	 X_Operation.DEPARTMENT_CODE,
	 1,
	 NULL,
	 SYSDATE,
	 l_UserId,
	 SYSDATE,
	 l_UserId,
	 l_LoginId,
	 l_RequestId,
	 l_ApplicationId,
	 l_ProgramId,
	 sysdate);
  End loop; -- insert operation
End if;

RETURN(0);

EXCEPTION
  WHEN INVALID_GRP THEN
     ROLLBACK TO BEGIN_DELETE;
     RETURN(-1);

   WHEN OTHERS THEN
      err_text := 'BOMMDELB(OI-' ||sql_stmt_num||' ) '||substrb(SQLERRM,1,500);
      ROLLBACK TO BEGIN_DELETE;
      RETURN(SQLCODE);
END DELETE_MANAGER_OI;


END MODAL_DELETE;

/
