--------------------------------------------------------
--  DDL for Package Body BOM_RTG_OI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_OI_UTIL" AS
/* $Header: BOMUROIB.pls 120.3.12000000.2 2007/04/11 09:55:50 shchandr ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUROIB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_RTG_OI_UTIL
--
--  NOTES
--
--  HISTORY
--
--  13-DEC-02   Deepak Jebar    Initial Creation
--  15-JUN-05   Abhishek Bhardwaj Added Batch Id
--
***************************************************************************/

G_Create constant varchar2(10) := 'CREATE'; -- transaction type
G_Update constant varchar2(10) := 'UPDATE'; -- transaction type
G_Delete constant varchar2(10) := 'DELETE'; -- transaction type
G_RtgDelEntity constant varchar2(30) := 'BOM_OP_ROUTINGS_INTERFACE';
G_OprDelEntity constant varchar2(30) := 'BOM_OP_SEQUENCES_INTERFACE';

/*--------------------------Process_Header_Info------------------------------

NAME
   Process_Rtg_header
DESCRIPTION
    Populate the user-friendly columns to routing record in the interface table
REQUIRES

MODIFIES
    BOM_OP_ROUTINGS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/

FUNCTION Process_Rtg_header (
    org_id              NUMBER,
    all_org             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
)
    return INTEGER
IS
stmt_num         NUMBER := 0;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN
 stmt_num := 1;
/* Resolve the routing sequence ids for updates and deletes */

   UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
       SET(assembly_item_id, organization_id, alternate_routing_designator)
      = (SELECT assembly_item_id, organization_id , alternate_routing_designator
	         FROM BOM_OPERATIONAL_ROUTINGS BOR1
	         WHERE BOR1.routing_sequence_id = BORI.routing_sequence_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND routing_sequence_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
			 FROM BOM_OPERATIONAL_ROUTINGS BOR2
			 WHERE BOR2.routing_sequence_id = BORI.routing_sequence_id);

 stmt_num := 2;

/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
       SET organization_code = (SELECT organization_code
                                  FROM MTL_PARAMETERS MP1
                             WHERE mp1.organization_id = BORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
         AND organization_code is NULL      -- Bug #3411601
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS MP2
                      WHERE mp2.organization_id = BORI.organization_id);

 stmt_num := 3;
 /* Update Organization_ids if organization code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
         SET organization_id = (SELECT organization_id
                                  FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_code = BORI.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
      	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          );

  stmt_num := 4;
/* Update Assembly Item name */

   UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
       SET assembly_item_number   = (SELECT concatenated_segments
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = BORI.assembly_item_id
                                     and mvl1.organization_id = BORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
	       AND organization_id is not null
      	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_SYSTEM_ITEMS mvl2
                       WHERE mvl2.inventory_item_id = BORI.assembly_item_id
              		     and mvl2.organization_id = BORI.organization_id);



   stmt_num := 5;
   /*  Assign transaction ids */

       UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
       WHERE transaction_id is null
--Bug 3411601  AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete, 'NO_OP')
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));

       UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
         SET transaction_type = upper(transaction_type)
       WHERE upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));


stmt_num := 6;
/* Assign Common Assembly Item id if common_routing_sequence_id is given
and a routing exists with that routing_sequence_id */

  UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
       SET(common_assembly_item_id)
       = (SELECT assembly_item_id
	         FROM BOM_OPERATIONAL_ROUTINGS BOR1
	         WHERE BOR1.routing_sequence_id = BORI.common_routing_sequence_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND common_routing_sequence_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
			 FROM BOM_OPERATIONAL_ROUTINGS BOR2
			 WHERE BOR2.routing_sequence_id = BORI.common_routing_sequence_id);

stmt_num :=7;

/* Update Assembly Item name */

   UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
       SET common_item_number   = (SELECT concatenated_segments
                                   FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                   WHERE mvl1.inventory_item_id = BORI.common_assembly_item_id
                                   and mvl1.organization_id = BORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND common_assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_SYSTEM_ITEMS mvl2
                       WHERE mvl2.inventory_item_id = BORI.common_assembly_item_id
		                   and mvl2.organization_id = BORI.organization_id);


 stmt_num := 8 ;
/* Update the line code from line_id */
   UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
       SET line_code   = (SELECT line_code
                             FROM WIP_LINES wl1
                             WHERE wl1.LINE_ID = BORI.LINE_ID -- Bug Fix 3782414
                             AND wl1.organization_id = BORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND line_id is not null
	 AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM WIP_LINES wl2
                      WHERE wl2.organization_id = BORI.organization_id
		      AND nvl(wl2.disable_date, trunc(sysdate) + 1) > trunc(sysdate));

  stmt_num := 9;
/* Update the delete_group_name from bom_interface_delete_groups */
   UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
       SET (DELETE_GROUP_NAME, DG_DESCRIPTION)
			   = (SELECT DELETE_GROUP_NAME, DESCRIPTION
                             FROM bom_interface_delete_groups
			     Where upper(entity_name) = G_RtgDelEntity
			     And rownum = 1)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete)
	 AND organization_id is not null
	 AND delete_group_name is null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                     FROM bom_interface_delete_groups
		     Where upper(entity_name) = G_RtgDelEntity
                     );

    stmt_num := 10;
/* Update Supply_locator_name */

   UPDATE BOM_OP_ROUTINGS_INTERFACE BORI
       SET  location_name  = (SELECT concatenated_segments
                             FROM MTL_ITEM_LOCATIONS_KFV MIL1
                             WHERE MIL1.inventory_location_id = BORI.COMPLETION_LOCATOR_ID
			     and MIL1.organization_id = BORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND completion_locator_id is not null
	 AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
              OR ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_ITEM_LOCATIONS_KFV mil2
                       WHERE mil2.INVENTORY_LOCATION_ID = BORI.completion_locator_id
			and mil2.organization_id = BORI.organization_id);


   stmt_num := 11;
/*  Load rows from routing interface into revisions interface*/
-- Bug 5970070. Adding 1 min to the effectivity date and implementation date
-- as the revision entered by user should be created after default revision.
                 INSERT into MTL_RTG_ITEM_REVS_INTERFACE
                     (INVENTORY_ITEM_NUMBER,
                      ORGANIZATION_CODE,
                      PROCESS_REVISION,
                      EFFECTIVITY_DATE,
                      IMPLEMENTATION_DATE,
                      PROCESS_FLAG,
                      TRANSACTION_TYPE,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN,
                      REQUEST_ID,
                      PROGRAM_APPLICATION_ID,
                      PROGRAM_ID,
                      PROGRAM_UPDATE_DATE,
		      BATCH_ID
                     )
                    select
                      assembly_item_number,
                      Organization_Code,
                      upper(PROCESS_REVISION),
                      sysdate + 1/1440,
                      sysdate + 1/1440,
                      1,
                      G_Create,
                      NVL(LAST_UPDATE_DATE, SYSDATE),
                      NVL(LAST_UPDATED_BY, user_id),
                      NVL(CREATION_DATE,SYSDATE),
                      NVL(CREATED_BY, user_id),
                      NVL(LAST_UPDATE_LOGIN, user_id),
                      NVL(REQUEST_ID, req_id),
                      NVL(PROGRAM_APPLICATION_ID, prog_appid),
                      NVL(PROGRAM_ID, prog_id),
                      NVL(PROGRAM_UPDATE_DATE, sysdate),
		      BATCH_ID
                    FROM BOM_OP_ROUTINGS_INTERFACE
                     WHERE process_flag = 1
                     AND transaction_type = G_Create
		     AND
                      (
                          ( (p_batch_id is null) AND (batch_id is null) )
                          OR ( p_batch_id = batch_id )
                      )
                     AND (all_org = 1
                          OR
                          (all_org = 2 AND organization_id = org_id))
                     AND process_revision is not null;

COMMIT;
   stmt_num := 12;

/* Update the interface records with process_flag 3 and insert into
MTL_INTERFACE_ERRORS if Item number or Organization_code  is missing*/

 msg_name1	 := 'BOM_ORG_ID_MISSING';
 msg_name2	 := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1	 := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2	 := FND_MESSAGE.GET;

   INSERT INTO MTL_INTERFACE_ERRORS
   (
 	TRANSACTION_ID,
 	UNIQUE_ID,
	ORGANIZATION_ID,
	COLUMN_NAME,
 	TABLE_NAME,
 	MESSAGE_NAME,
 	ERROR_MESSAGE,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_LOGIN,
 	REQUEST_ID,
 	PROGRAM_APPLICATION_ID,
 	PROGRAM_ID,
 	PROGRAM_UPDATE_DATE
   )
  Select
	BORI.transaction_id,
	MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
	Null,
	null,
	'BOM_OP_ROUTINGS_INTERFACE',
	decode ( BORI.Organization_code, null, msg_name1,msg_name2),
	decode ( BORI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
         req_id,
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
    from BOM_OP_ROUTINGS_INTERFACE BORI
   where (organization_code is null or assembly_item_number is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;

	Update BOM_OP_ROUTINGS_INTERFACE BORI
	set process_flag = 3
	where (assembly_item_number is null or Organization_code is null)
	and transaction_id is not null
	and process_flag = 1
	and
         (
             ( (p_batch_id is null) AND (batch_id is null) )
             OR ( p_batch_id = batch_id )
         )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;

Commit;

return(0);


EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Rtg_OI_Util(Process_Rtg_header-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);

END Process_Rtg_header;


/*--------------------------Process_Op_Seqs------------------------------

NAME
   Process_Op_Seqs
DESCRIPTION
    Populate the user-friendly columns to operation records in the interface table
REQUIRES

MODIFIES
    BOM_OP_SEQUENCES_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/

FUNCTION Process_Op_Seqs (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
)
    return INTEGER
IS
 stmt_num            NUMBER := 0;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN
 stmt_num := 1;
/* Resolve the routing_sequence_ids for updates and deletes */

   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET(routing_sequence_id, effectivity_date,
	       operation_seq_num, operation_type)
       = (SELECT routing_sequence_id, effectivity_date, operation_seq_num, operation_type
	         FROM BOM_OPERATION_SEQUENCES BOS1
	         WHERE BOS1.operation_sequence_id = BOSI.operation_sequence_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND operation_sequence_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
	         FROM BOM_OPERATION_SEQUENCES BOS2
	         WHERE BOS2.operation_sequence_id = BOSI.operation_sequence_id );


stmt_num := 2;
/* Resolve the assembly item ids */

   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET(assembly_item_id, organization_id, alternate_routing_designator)
       = (SELECT assembly_item_id, organization_id , alternate_routing_designator
	         FROM BOM_OPERATIONAL_ROUTINGS BOR1
	         WHERE BOR1.routing_sequence_id = BOSI.routing_sequence_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND routing_sequence_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
			 FROM BOM_OPERATIONAL_ROUTINGS BOR2
			 WHERE BOR2.routing_sequence_id = BOSI.routing_sequence_id);


 stmt_num := 3;
/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET organization_code = (SELECT organization_code
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_id = BOSI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
	       AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BOSI.organization_id);



 stmt_num := 4;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BOSI.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
	       AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          );



  stmt_num := 5;
/* Update Assembly Item name */

   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET assembly_item_number  = (SELECT concatenated_segments
                                   FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                   WHERE mvl1.inventory_item_id = BOSI.assembly_item_id
                                   and mvl1.organization_id = BOSI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
                      FROM MTL_SYSTEM_ITEMS mvl2
                      WHERE mvl2.inventory_item_id = BOSI.assembly_item_id
		                  and mvl2.organization_id = BOSI.organization_id);


  stmt_num := 6;
   /*  Assign transaction ids */

       UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));

       UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
         SET transaction_type = upper(transaction_type)
       WHERE upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));


   stmt_num := 7;
/* Update the operation code from the standard operation id */

   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET operation_code  = (SELECT operation_code
                             FROM BOM_STANDARD_OPERATIONS bso
                             WHERE bso.standard_operation_id = BOSI.standard_operation_id
			     and bso.organization_id = BOSI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND standard_operation_id is not null
	 AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
                      FROM  BOM_STANDARD_OPERATIONS bso
                      WHERE bso.standard_operation_id = BOSI.standard_operation_id
		      and bso.organization_id = BOSI.organization_id);

   stmt_num := 8;
/* Update the department code from the department id */

   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET department_code  = (SELECT department_code
                             FROM BOM_DEPARTMENTS bd
                             WHERE bd.department_id = BOSI.department_id
			     and bd.organization_id = BOSI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND department_id is not null
	 AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
                      FROM  BOM_STANDARD_OPERATIONS bso
                      WHERE bso.department_id = BOSI.department_id
		      and bso.organization_id = BOSI.organization_id);

   stmt_num := 9;
/* Resolve the line_op_seq_ids and process_op_seq_ids */

   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET(line_op_seq_number, line_op_code)
       = (SELECT bos1.operation_seq_num, bso1.operation_code
	         FROM BOM_OPERATION_SEQUENCES BOS1, BOM_STANDARD_OPERATIONS BSO1
	         WHERE BOS1.operation_sequence_id = BOSI.line_op_seq_id
		 AND BSO1.organization_id = BOSI.organization_id
		 AND BOS1.standard_operation_id = BSO1.standard_operation_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND line_op_seq_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
	         FROM BOM_OPERATION_SEQUENCES BOS1, BOM_STANDARD_OPERATIONS BSO1
	         WHERE BOS1.operation_sequence_id = BOSI.line_op_seq_id
		 AND BSO1.organization_id = BOSI.organization_id
		 AND BOS1.standard_operation_id = BSO1.standard_operation_id);

   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET(process_seq_number, process_code)
       = (SELECT bos1.operation_seq_num, bso1.operation_code
	         FROM BOM_OPERATION_SEQUENCES BOS1, BOM_STANDARD_OPERATIONS BSO1
	         WHERE BOS1.operation_sequence_id = BOSI.process_op_seq_id
		 AND BSO1.organization_id = BOSI.organization_id
		 AND BOS1.standard_operation_id = BSO1.standard_operation_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND process_op_seq_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
	         FROM BOM_OPERATION_SEQUENCES BOS1, BOM_STANDARD_OPERATIONS BSO1
	         WHERE BOS1.operation_sequence_id = BOSI.process_op_seq_id
		 AND BSO1.organization_id = BOSI.organization_id
		 AND BOS1.standard_operation_id = BSO1.standard_operation_id);

  stmt_num := 10;
/* Update the delete_group_name from bom_interface_delete_groups */
   UPDATE BOM_OP_SEQUENCES_INTERFACE BOSI
       SET (DELETE_GROUP_NAME, DG_DESCRIPTION)
			   = (SELECT DELETE_GROUP_NAME, DESCRIPTION
                             FROM bom_interface_delete_groups
			     Where upper(entity_name) = G_OprDelEntity
			     And rownum = 1)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete)
	 AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BOSI.batch_id IS NULL) )
          OR  ( p_batch_id = BOSI.batch_id )
          )
         AND exists (SELECT 'x'
                     FROM bom_interface_delete_groups
		     Where upper(entity_name) = G_RtgDelEntity
                     );

 stmt_num := 11;

 /* INSERTS ONLY - Load rows from operation interface into resource interface*/
   INSERT into bom_op_resources_interface (
        RESOURCE_ID,
        RESOURCE_CODE,
        ORGANIZATION_ID,
	ORGANIZATION_CODE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        OPERATION_SEQUENCE_ID,
	OPERATION_SEQ_NUM,
	ASSEMBLY_ITEM_NUMBER,
	ASSEMBLY_ITEM_ID,
	ALTERNATE_ROUTING_DESIGNATOR,
	EFFECTIVITY_DATE,
	RESOURCE_SEQ_NUM,
        PROCESS_FLAG,
        TRANSACTION_TYPE,
	BATCH_ID)
      SELECT
             RESOURCE_ID1,
             RESOURCE_CODE1,
             ORGANIZATION_ID,
	     ORGANIZATION_CODE,
             NVL(LAST_UPDATE_DATE, SYSDATE),
             NVL(LAST_UPDATED_BY, user_id),
             NVL(CREATION_DATE,SYSDATE),
             NVL(CREATED_BY, user_id),
             NVL(LAST_UPDATE_LOGIN, user_id),
             NVL(REQUEST_ID, req_id),
             NVL(PROGRAM_APPLICATION_ID, prog_appid),
             NVL(PROGRAM_ID, prog_id),
             NVL(PROGRAM_UPDATE_DATE, sysdate),
             OPERATION_SEQUENCE_ID,
	     OPERATION_SEQ_NUM,
	     ASSEMBLY_ITEM_NUMBER,
	     ASSEMBLY_ITEM_ID,
	     ALTERNATE_ROUTING_DESIGNATOR,
	     EFFECTIVITY_DATE,
	     10,
             1,
             G_Create,
	     BATCH_ID
        FROM BOM_OP_SEQUENCES_INTERFACE
       WHERE process_flag = 1
         AND transaction_type = G_Create
	 AND
          (
              ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
              OR ( p_batch_id = batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND (RESOURCE_CODE1 is not null
              OR
              RESOURCE_ID1 is not null);

   INSERT into bom_op_resources_interface (
        RESOURCE_ID,
        RESOURCE_CODE,
        ORGANIZATION_ID,
	ORGANIZATION_CODE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        OPERATION_SEQUENCE_ID,
	OPERATION_SEQ_NUM,
	ASSEMBLY_ITEM_NUMBER,
	ASSEMBLY_ITEM_ID,
	ALTERNATE_ROUTING_DESIGNATOR,
	EFFECTIVITY_DATE,
	RESOURCE_SEQ_NUM,
        PROCESS_FLAG,
        TRANSACTION_TYPE,
	BATCH_ID)
      SELECT
             RESOURCE_ID2,
             RESOURCE_CODE2,
             ORGANIZATION_ID,
	     ORGANIZATION_CODE,
             NVL(LAST_UPDATE_DATE, SYSDATE),
             NVL(LAST_UPDATED_BY, user_id),
             NVL(CREATION_DATE,SYSDATE),
             NVL(CREATED_BY, user_id),
             NVL(LAST_UPDATE_LOGIN, user_id),
             NVL(REQUEST_ID, req_id),
             NVL(PROGRAM_APPLICATION_ID, prog_appid),
             NVL(PROGRAM_ID, prog_id),
             NVL(PROGRAM_UPDATE_DATE, sysdate),
             OPERATION_SEQUENCE_ID,
	     OPERATION_SEQ_NUM,
	     ASSEMBLY_ITEM_NUMBER,
	     ASSEMBLY_ITEM_ID,
	     ALTERNATE_ROUTING_DESIGNATOR,
	     EFFECTIVITY_DATE,
	     20,
             1,
             G_Create,
	     BATCH_ID
        FROM BOM_OP_SEQUENCES_INTERFACE
       WHERE process_flag = 1
         AND transaction_type = G_Create
	 AND
          (
              ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
              OR ( p_batch_id = batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND (RESOURCE_CODE2 is not null
              OR
              RESOURCE_ID2 is not null);

   INSERT into bom_op_resources_interface (
        RESOURCE_ID,
        RESOURCE_CODE,
        ORGANIZATION_ID,
	ORGANIZATION_CODE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
      CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        OPERATION_SEQUENCE_ID,
	OPERATION_SEQ_NUM,
	ASSEMBLY_ITEM_NUMBER,
	ASSEMBLY_ITEM_ID,
	ALTERNATE_ROUTING_DESIGNATOR,
	EFFECTIVITY_DATE,
	RESOURCE_SEQ_NUM,
        PROCESS_FLAG,
        TRANSACTION_TYPE,
	BATCH_ID)
      SELECT
             RESOURCE_ID3,
             RESOURCE_CODE3,
             ORGANIZATION_ID,
	     ORGANIZATION_CODE,
             NVL(LAST_UPDATE_DATE, SYSDATE),
             NVL(LAST_UPDATED_BY, user_id),
             NVL(CREATION_DATE,SYSDATE),
             NVL(CREATED_BY, user_id),
             NVL(LAST_UPDATE_LOGIN, user_id),
             NVL(REQUEST_ID, req_id),
             NVL(PROGRAM_APPLICATION_ID, prog_appid),
             NVL(PROGRAM_ID, prog_id),
             NVL(PROGRAM_UPDATE_DATE, sysdate),
             OPERATION_SEQUENCE_ID,
	     OPERATION_SEQ_NUM,
	     ASSEMBLY_ITEM_NUMBER,
	     ASSEMBLY_ITEM_ID,
	     ALTERNATE_ROUTING_DESIGNATOR,
	     EFFECTIVITY_DATE,
	     30,
             1,
             G_Create,
	     BATCH_ID
        FROM BOM_OP_SEQUENCES_INTERFACE
       WHERE process_flag = 1
         AND transaction_type = G_Create
	 AND
          (
              ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
              OR ( p_batch_id = batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND (RESOURCE_CODE3 is not null
              OR
              RESOURCE_ID3 is not null);


 COMMIT;

   stmt_num := 11;

/* Update the interface records with process_flag 3 and insert into
mtl_interface_errors if Item_number or Organization_code  is missing*/

 msg_name1	 := 'BOM_ORG_ID_MISSING';
 msg_name2	 := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1	 := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2	 := FND_MESSAGE.GET;
   INSERT INTO mtl_interface_errors
   (
 	TRANSACTION_ID,
 	UNIQUE_ID,
	ORGANIZATION_ID,
	COLUMN_NAME,
 	TABLE_NAME,
 	MESSAGE_NAME,
 	ERROR_MESSAGE,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_LOGIN,
 	REQUEST_ID,
 	PROGRAM_APPLICATION_ID,
 	PROGRAM_ID,
 	PROGRAM_UPDATE_DATE
   )
  Select
	BOSI.transaction_id,
	MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
	Null,
	null,
	'BOM_OP_SEQUENCES_INTERFACE',
	decode ( BOSI.Organization_code, null, msg_name1,msg_name2),
	decode ( BOSI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
   from BOM_OP_SEQUENCES_INTERFACE BOSI
   where (organization_code is null or ASSEMBLY_ITEM_NUMBER is null)
	and transaction_id is not null
	and process_flag = 1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;

	Update BOM_OP_SEQUENCES_INTERFACE
	set process_flag = 3
	where (ASSEMBLY_ITEM_NUMBER is null or Organization_code is null)
	and transaction_id is not null
	and process_flag = 1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;
Commit;

return (0);


EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Rtg_OI_Util(Process_Op_Seqs-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);
END Process_Op_Seqs;


/*--------------------------Process_Op_Resources------------------------------

NAME
   Process_Op_Resources
DESCRIPTION
   Populate the user-friendly columns to Operation Resources records
   in the interface table
REQUIRES

MODIFIES
    BOM_OP_RESOURCES_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Process_Op_Resources  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
)
    return INTEGER
IS
  stmt_num            NUMBER := 0;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN
 stmt_num := 1;
/* Resolve the operation_sequence_id for all the records */

   UPDATE BOM_OP_RESOURCES_INTERFACE BORI
       SET(routing_sequence_id, effectivity_date, operation_seq_num)
       = (SELECT routing_sequence_id, effectivity_date, operation_seq_num
	         FROM BOM_OPERATION_SEQUENCES BOS1
	         WHERE BOS1.operation_sequence_id = BORI.operation_sequence_id )
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND OPERATION_SEQUENCE_ID is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
          OR  ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
	         FROM BOM_OPERATION_SEQUENCES BOS2
	         WHERE BOS2.OPERATION_SEQUENCE_ID = BORI.OPERATION_SEQUENCE_ID);


stmt_num := 2;
/* Resolve the routing sequence ids */

   UPDATE BOM_OP_RESOURCES_INTERFACE BORI
       SET(assembly_item_id, organization_id, alternate_routing_designator)
       = (SELECT assembly_item_id, organization_id, alternate_routing_designator
	         FROM BOM_OPERATIONAL_ROUTINGS BOR1
	         WHERE BOR1.routing_sequence_id = BORI.routing_sequence_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND routing_sequence_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
          OR  ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
			 FROM BOM_OPERATIONAL_ROUTINGS BOR2
			 WHERE BOR2.routing_sequence_id = BORI.routing_sequence_id);


 stmt_num := 3;
/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_OP_RESOURCES_INTERFACE BORI
       SET organization_code = (SELECT organization_code
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_id = BORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
	       AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
          OR  ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BORI.organization_id);



 stmt_num := 4;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_OP_RESOURCES_INTERFACE BORI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BORI.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
          OR  ( p_batch_id = BORI.batch_id )
          );



  stmt_num := 5;
/* Update Assembly Item name */

   UPDATE BOM_OP_RESOURCES_INTERFACE BORI
       SET ASSEMBLY_ITEM_NUMBER  = (SELECT CONCATENATED_SEGMENTS
                                   FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                   WHERE mvl1.inventory_item_id = BORI.assembly_item_id
                                   and mvl1.organization_id = BORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
          OR  ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                      FROM MTL_SYSTEM_ITEMS mvl2
                      WHERE mvl2.inventory_item_id = BORI.assembly_item_id
		                  and mvl2.organization_id = BORI.organization_id);


  stmt_num := 6;
/* Update resource code */

   UPDATE BOM_OP_RESOURCES_INTERFACE BORI
       SET  resource_code   = (SELECT resource_code
                             FROM BOM_RESOURCES br
                             WHERE br.resource_id = BORI.resource_id
			     and br.organization_id = BORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND resource_id is not null
	 AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
          OR  ( p_batch_id = BORI.batch_id )
          )
         AND exists (SELECT 'x'
                      FROM  BOM_RESOURCES br
                      WHERE br.resource_id = BORI.resource_id
		      and br.organization_id = BORI.organization_id);


   stmt_num := 7;
   /*  Assign transaction ids */

       UPDATE BOM_OP_RESOURCES_INTERFACE BORI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
          OR  ( p_batch_id = BORI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));

       UPDATE BOM_OP_RESOURCES_INTERFACE BORI
         SET transaction_type = upper(transaction_type)
       WHERE upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BORI.batch_id IS NULL) )
          OR  ( p_batch_id = BORI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));

  COMMIT;

   stmt_num := 8;
/* Update the interface records with process_flag 3 and insert into
mtl_interface_errors if Item_number or Organization_code  is missing*/

 msg_name1	 := 'BOM_ORG_ID_MISSING';
 msg_name2	 := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1	 := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2	 := FND_MESSAGE.GET;
   INSERT INTO mtl_interface_errors
   (
 	TRANSACTION_ID,
 	UNIQUE_ID,
	ORGANIZATION_ID,
	COLUMN_NAME,
 	TABLE_NAME,
 	MESSAGE_NAME,
 	ERROR_MESSAGE,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_LOGIN,
 	REQUEST_ID,
 	PROGRAM_APPLICATION_ID,
 	PROGRAM_ID,
 	PROGRAM_UPDATE_DATE
   )
  Select
	BORI.transaction_id,
	MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
	Null,
	null,
	'BOM_OP_RESOURCES_INTERFACE',
	decode ( BORI.Organization_code, null, msg_name1,msg_name2),
	decode ( BORI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
    from BOM_OP_RESOURCES_INTERFACE BORI
   where (organization_code is null or ASSEMBLY_ITEM_NUMBER is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;

	Update BOM_OP_RESOURCES_INTERFACE
	set process_flag = 3
	where (ASSEMBLY_ITEM_NUMBER is null or Organization_code is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;
Commit;

return(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Rtg_OI_Util(Process_Op_Resources-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);
END Process_Op_Resources;

/*--------------------------Process_Sub_Op_Resources------------------------------

NAME
  Process_Sub_Op_Resources
DESCRIPTION
   Populate the user-friendly columns to Substitute Resource records
   in the interface table
REQUIRES

MODIFIES
    BOM_SUB_OP_RESOURCES_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Process_Sub_Op_Resources  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
)
    return INTEGER
IS
 stmt_num            NUMBER := 0;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN
 stmt_num := 1;
/* Resolve the operation_sequence_id for all the records */

   UPDATE BOM_SUB_OP_RESOURCES_INTERFACE BSORI
       SET(routing_sequence_id, effectivity_date, operation_seq_num)
       = (select routing_sequence_id, EFFECTIVITY_DATE, OPERATION_SEQ_NUM
	         FROM BOM_OPERATION_SEQUENCES BOS1
	         WHERE BOS1.OPERATION_SEQUENCE_ID = BSORI.operation_sequence_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND OPERATION_SEQUENCE_ID is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BSORI.batch_id IS NULL) )
          OR  ( p_batch_id = BSORI.batch_id )
          )
         AND exists (SELECT 'x'
	         FROM BOM_OPERATION_SEQUENCES BOS2
	         WHERE BOS2.OPERATION_SEQUENCE_ID = BSORI.OPERATION_SEQUENCE_ID);


stmt_num := 2;
/* Resolve the routing sequence ids */

   UPDATE BOM_SUB_OP_RESOURCES_INTERFACE BSORI
       SET(assembly_item_id, organization_id, alternate_routing_designator)
       = (SELECT assembly_item_id, organization_id , alternate_routing_designator
	         FROM BOM_OPERATIONAL_ROUTINGS BOR1
	         WHERE BOR1.routing_sequence_id = BSORI.routing_sequence_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND routing_sequence_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BSORI.batch_id IS NULL) )
          OR  ( p_batch_id = BSORI.batch_id )
          )
         AND exists (SELECT 'x'
			 FROM BOM_OPERATIONAL_ROUTINGS BOR2
			 WHERE BOR2.routing_sequence_id = BSORI.routing_sequence_id);


 stmt_num := 3;
/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_SUB_OP_RESOURCES_INTERFACE BSORI
       SET organization_code = (SELECT organization_code
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_id = BSORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
	       AND
          (
              ( (p_batch_id IS NULL) AND (BSORI.batch_id IS NULL) )
          OR  ( p_batch_id = BSORI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BSORI.organization_id);



 stmt_num := 4;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_SUB_OP_RESOURCES_INTERFACE BSORI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BSORI.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
      	 AND
          (
              ( (p_batch_id IS NULL) AND (BSORI.batch_id IS NULL) )
          OR  ( p_batch_id = BSORI.batch_id )
          );



  stmt_num := 5;
/* Update Assembly Item name */

   UPDATE BOM_SUB_OP_RESOURCES_INTERFACE BSORI
       SET  ASSEMBLY_ITEM_NUMBER  = (SELECT CONCATENATED_SEGMENTS
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = BSORI.assembly_item_id
                                     and mvl1.organization_id = BSORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSORI.batch_id IS NULL) )
          OR  ( p_batch_id = BSORI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_SYSTEM_ITEMS mvl2
                      WHERE mvl2.inventory_item_id = BSORI.assembly_item_id
		      and mvl2.organization_id = BSORI.organization_id);


  stmt_num := 6;
/* Update resource code */

   UPDATE BOM_SUB_OP_RESOURCES_INTERFACE BSORI
       SET sub_resource_code   = (SELECT resource_code
                             FROM BOM_RESOURCES br
                             WHERE br.resource_id = BSORI.resource_id
			     and br.organization_id = BSORI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND resource_id is not null
	 AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BSORI.batch_id IS NULL) )
          OR  ( p_batch_id = BSORI.batch_id )
          )
         AND exists (SELECT 'x'
                      FROM  BOM_RESOURCES br
                      WHERE br.resource_id = BSORI.resource_id
		      and br.organization_id = BSORI.organization_id);


   stmt_num := 7;
   /*  Assign transaction ids */

       UPDATE BOM_SUB_OP_RESOURCES_INTERFACE BSORI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BSORI.batch_id IS NULL) )
          OR  ( p_batch_id = BSORI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));

       UPDATE BOM_SUB_OP_RESOURCES_INTERFACE BSORI
         SET transaction_type = upper(transaction_type)
       WHERE upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BSORI.batch_id IS NULL) )
          OR  ( p_batch_id = BSORI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));

  COMMIT;
   stmt_num := 8;
/* Update the interface records with process_flag 3 and insert into
mtl_interface_errors if Item_number or Organization_code  is missing*/

 msg_name1	 := 'BOM_ORG_ID_MISSING';
 msg_name2	 := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1	 := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2	 := FND_MESSAGE.GET;
   INSERT INTO mtl_interface_errors
   (
 	TRANSACTION_ID,
 	UNIQUE_ID,
	ORGANIZATION_ID,
	COLUMN_NAME,
 	TABLE_NAME,
 	MESSAGE_NAME,
 	ERROR_MESSAGE,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_LOGIN,
 	REQUEST_ID,
 	PROGRAM_APPLICATION_ID,
 	PROGRAM_ID,
 	PROGRAM_UPDATE_DATE
   )
  Select
	BSORI.transaction_id,
	MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
	Null,
	null,
	'BOM_SUB_OP_RESOURCES_INTERFACE',
	decode ( BSORI.Organization_code, null, msg_name1,msg_name2),
	decode ( BSORI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
    from BOM_SUB_OP_RESOURCES_INTERFACE BSORI
   where (organization_code is null or ASSEMBLY_ITEM_NUMBER is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;

	Update BOM_SUB_OP_RESOURCES_INTERFACE
	set process_flag = 3
	where (ASSEMBLY_ITEM_NUMBER is null or Organization_code is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;
Commit;

return(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Rtg_OI_Util(Process_Sub_Op_Resources-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);
END Process_Sub_Op_Resources;

/*--------------------------Process_Op_Nwks------------------------------

NAME
  Process_Op_Nwks
DESCRIPTION
   Populate the user-friendly columns to Operation network records
   in the interface table
REQUIRES

MODIFIES
    BOM_OP_NETWORKS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/

FUNCTION Process_Op_Nwks  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
   )
    return INTEGER
IS
 stmt_num            NUMBER := 0;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN
 stmt_num := 1;
/* Resolve the from_op_seq_id and to_op_seq_id for all the records */

   UPDATE BOM_OP_NETWORKS_INTERFACE BONI
       SET(routing_sequence_id, from_op_seq_number, from_start_effective_date)
       = (SELECT routing_sequence_id, operation_seq_num, effectivity_date
	         FROM BOM_OPERATION_SEQUENCES BOS1
	         WHERE BOS1.operation_sequence_id = BONI.from_Op_seq_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND BONI.from_Op_seq_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BONI.batch_id IS NULL) )
          OR  ( p_batch_id = BONI.batch_id )
          )
         AND exists (SELECT 'x'
	         FROM BOM_OPERATION_SEQUENCES BOS2
	         WHERE BOS2.OPERATION_SEQUENCE_ID = BONI.FROM_OP_SEQ_ID );

   UPDATE BOM_OP_NETWORKS_INTERFACE BONI
       SET(routing_sequence_id, to_op_seq_number, to_start_effective_date)
       = (SELECT routing_sequence_id, operation_seq_num, effectivity_date
	         FROM BOM_OPERATION_SEQUENCES BOS1
	         WHERE BOS1.operation_sequence_id = BONI.to_Op_seq_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND BONI.to_Op_seq_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BONI.batch_id IS NULL) )
          OR  ( p_batch_id = BONI.batch_id )
          )
         AND exists (SELECT 'x'
	         FROM BOM_OPERATION_SEQUENCES BOS2
	         WHERE BOS2.OPERATION_SEQUENCE_ID = BONI.TO_OP_SEQ_ID );


stmt_num := 2;
/* Resolve the routing sequence ids for updates and deletes */

   UPDATE BOM_OP_NETWORKS_INTERFACE BONI
       SET(assembly_item_id, organization_id, alternate_routing_designator)
       = (SELECT assembly_item_id, organization_id , alternate_routing_designator
	         FROM BOM_OPERATIONAL_ROUTINGS BOR1
	         WHERE BOR1.routing_sequence_id = BONI.routing_sequence_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND routing_sequence_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BONI.batch_id IS NULL) )
          OR  ( p_batch_id = BONI.batch_id )
          )
         AND exists (SELECT 'x'
			 FROM BOM_OPERATIONAL_ROUTINGS BOR2
			 WHERE BOR2.routing_sequence_id = BONI.routing_sequence_id);


 stmt_num := 3;
/* Update Organization Code using Organization_id
this also needed if orgnaization_id is given and code is not given*/

   UPDATE BOM_OP_NETWORKS_INTERFACE BONI
       SET organization_code = (SELECT organization_code
                                  FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_id = BONI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BONI.batch_id IS NULL) )
          OR  ( p_batch_id = BONI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BONI.organization_id);



 stmt_num := 4;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_OP_NETWORKS_INTERFACE BONI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BONI.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
      	 AND
          (
              ( (p_batch_id IS NULL) AND (BONI.batch_id IS NULL) )
          OR  ( p_batch_id = BONI.batch_id )
          );



  stmt_num := 5;
/* Update Assembly Item name */

   UPDATE BOM_OP_NETWORKS_INTERFACE BONI
       SET  ASSEMBLY_ITEM_NUMBER  = (SELECT CONCATENATED_SEGMENTS
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = BONI.assembly_item_id
                                     and mvl1.organization_id = BONI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
	 AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (BONI.batch_id IS NULL) )
          OR  ( p_batch_id = BONI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_SYSTEM_ITEMS mvl2
                      WHERE mvl2.inventory_item_id = BONI.assembly_item_id
		      and mvl2.organization_id = BONI.organization_id);


   stmt_num := 6;
   /*  Assign transaction ids */
       UPDATE BOM_OP_NETWORKS_INTERFACE BONI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BONI.batch_id IS NULL) )
          OR  ( p_batch_id = BONI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));

       UPDATE BOM_OP_NETWORKS_INTERFACE BONI
         SET transaction_type = upper(transaction_type)
       WHERE upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (BONI.batch_id IS NULL) )
          OR  ( p_batch_id = BONI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));

  COMMIT;

   stmt_num := 7;
/* Update the interface records with process_flag 3 and insert into
mtl_interface_errors if Item_number or Organization_code  is missing*/

 msg_name1	 := 'BOM_ORG_ID_MISSING';
 msg_name2	 := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1	 := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2	 := FND_MESSAGE.GET;
   INSERT INTO mtl_interface_errors
   (
 	TRANSACTION_ID,
 	UNIQUE_ID,
	ORGANIZATION_ID,
	COLUMN_NAME,
 	TABLE_NAME,
 	MESSAGE_NAME,
 	ERROR_MESSAGE,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_LOGIN,
 	REQUEST_ID,
 	PROGRAM_APPLICATION_ID,
 	PROGRAM_ID,
 	PROGRAM_UPDATE_DATE
   )
  Select
	BONI.transaction_id,
	MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
	Null,
	null,
	'BOM_OP_NETWORKS_INTERFACE',
	decode ( BONI.Organization_code, null, msg_name1,msg_name2),
	decode ( BONI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        req_id,
	NVL(PROGRAM_APPLICATION_ID, prog_appid),
	NVL(PROGRAM_ID, prog_id),
	NVL(PROGRAM_UPDATE_DATE, sysdate)
    from BOM_OP_NETWORKS_INTERFACE BONI
   where (organization_code is null or ASSEMBLY_ITEM_NUMBER is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;

	Update BOM_OP_NETWORKS_INTERFACE
	set process_flag = 3
	where (ASSEMBLY_ITEM_NUMBER is null or Organization_code is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;
Commit;

return(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Rtg_OI_Util(Process_Op_Nwks-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);
END Process_Op_Nwks;

/*--------------------------Process_Rtg_Revisions------------------------------

NAME
  Process_Rtg_Revisions
DESCRIPTION
   Populate the user-friendly columns to unique index records
   in the interface table
REQUIRES

MODIFIES
    MTL_RTG_ITEM_REVS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/

FUNCTION Process_Rtg_Revisions (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  	NUMBER
)return integer is
 stmt_num            NUMBER := 0;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

begin
 stmt_num := 1;
/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE MTL_RTG_ITEM_REVS_INTERFACE MRIRI
       SET organization_code = (SELECT organization_code
                                  FROM MTL_PARAMETERS MP1
                             WHERE mp1.organization_id = MRIRI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (MRIRI.batch_id IS NULL) )
          OR  ( p_batch_id = MRIRI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS MP2
                      WHERE mp2.organization_id = MRIRI.organization_id);



 stmt_num := 2;
 /* Update Organization_ids if organization code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE MTL_RTG_ITEM_REVS_INTERFACE MRIRI
         SET organization_id = (SELECT organization_id
                                  FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_code = MRIRI.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
	 AND
          (
              ( (p_batch_id IS NULL) AND (MRIRI.batch_id IS NULL) )
          OR  ( p_batch_id = MRIRI.batch_id )
          );



  stmt_num := 3;
/* Update Assembly Item name */

   UPDATE MTL_RTG_ITEM_REVS_INTERFACE MRIRI
       SET inventory_item_number   = (SELECT concatenated_segments
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = MRIRI.inventory_item_id
                                     and mvl1.organization_id = MRIRI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND inventory_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (MRIRI.batch_id IS NULL) )
          OR  ( p_batch_id = MRIRI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_SYSTEM_ITEMS mvl2
                      WHERE mvl2.inventory_item_id = MRIRI.inventory_item_id
		      and mvl2.organization_id = MRIRI.organization_id);



   stmt_num := 4;
   /*  Assign transaction ids */

       UPDATE MTL_RTG_ITEM_REVS_INTERFACE MRIRI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (MRIRI.batch_id IS NULL) )
          OR  ( p_batch_id = MRIRI.batch_id )
          )
         AND (all_org = 1
             OR
          (all_org = 2 AND organization_id = org_id));

       UPDATE MTL_RTG_ITEM_REVS_INTERFACE MRIRI
         SET transaction_type = upper(transaction_type),
             process_revision = upper(process_revision) -- bug 3756121
       WHERE upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
	 AND
          (
              ( (p_batch_id IS NULL) AND (MRIRI.batch_id IS NULL) )
          OR  ( p_batch_id = MRIRI.batch_id )
          )
         AND (all_org = 1
             OR
          (all_org = 2 AND organization_id = org_id));

COMMIT;
   stmt_num := 5;

/* Update the interface records with process_flag 3 and insert into
MTL_INTERFACE_ERRORS if Item number or Organization_code  is missing*/

 msg_name1	 := 'BOM_ORG_ID_MISSING';
 msg_name2	 := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1	 := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2	 := FND_MESSAGE.GET;

   INSERT INTO MTL_INTERFACE_ERRORS
   (
 	TRANSACTION_ID,
 	UNIQUE_ID,
	ORGANIZATION_ID,
	COLUMN_NAME,
 	TABLE_NAME,
 	MESSAGE_NAME,
 	ERROR_MESSAGE,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_LOGIN,
 	REQUEST_ID,
 	PROGRAM_APPLICATION_ID,
 	PROGRAM_ID,
 	PROGRAM_UPDATE_DATE
   )
  Select
	MRIRI.transaction_id,
	MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
	Null,
	null,
	'MTL_RTG_ITEM_REVS_INTERFACE',
	decode ( MRIRI.Organization_code, null, msg_name1,msg_name2),
	decode ( MRIRI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
         req_id,
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
    from MTL_RTG_ITEM_REVS_INTERFACE MRIRI
   where (organization_code is null or inventory_item_number is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;

	Update  MTL_RTG_ITEM_REVS_INTERFACE MRIRI
	set process_flag = 3
	where (inventory_item_number is null or Organization_code is null)
	and transaction_id is not null
	and process_flag =1
	and
	 (
	     ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
	     OR ( p_batch_id = batch_id )
	 )
	and (all_org = 1 OR (all_org = 2 AND organization_id = org_id)) ;

Commit;

return(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Rtg_OI_Util(Process_Rtg_Revisions-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);

end Process_Rtg_Revisions;
end Bom_Rtg_OI_Util;

/
