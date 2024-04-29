--------------------------------------------------------
--  DDL for Package Body BOM_OPEN_INTERFACE_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OPEN_INTERFACE_UTL" AS
/* $Header: BOMUBOIB.pls 120.14 2007/05/24 09:50:20 dikrishn ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMUBOIB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Open_Interface_Utl
--
--  NOTES
--
--  HISTORY
--
--  22-NOV-02   Vani Hymavathi    Initial Creation
--  01-JUN-05   Bhavnesh Patel    Added Batch Id
***************************************************************************/
/*--------------------------Process_Header_Info------------------------------

NAME
   Process_Header_Info
DESCRIPTION
    Populate the user-friendly columns to bill record in the interface table
REQUIRES

MODIFIES
    BOM_BILL_OF_MTLS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/

FUNCTION Process_Header_Info (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN  NUMBER
)
    return INTEGER
IS
 stmt_num            NUMBER := 0;
l_sysdate        DATE  :=  SYSDATE;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN

 stmt_num := 1;
/* Resolve the Bill sequence ids for updates and deletes */

   UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET(assembly_item_id, organization_id, alternate_bom_designator)
      = (SELECT assembly_item_id, organization_id , alternate_bom_designator
           FROM bom_structures_b BBM1
           WHERE BBM1.bill_sequence_id = BBMI.bill_sequence_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND bill_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          )
         AND exists (SELECT 'x'
       FROM bom_structures_b BBM2
       WHERE BBM2.bill_sequence_id = BBMI.bill_sequence_id);



 stmt_num := 2;

/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET organization_code = (SELECT organization_code
                                FROM MTL_PARAMETERS MP1
                                WHERE mp1.organization_id = BBMI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update,G_NoOp)
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          )
         AND exists (SELECT 'x'
                     FROM MTL_PARAMETERS MP2
                     WHERE mp2.organization_id = BBMI.organization_id);



 stmt_num := 3;
 /* Update Organization_ids if organization code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
         SET organization_id = (SELECT organization_id
                                  FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_code = BBMI.organization_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update,G_NoOp)
         AND organization_id is null
         AND organization_code is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          );

  stmt_num := 3.1;
    /* Update Assembly Item name */
    UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
    SET  item_number   = (SELECT concatenated_segments
                          FROM MTL_SYSTEM_ITEMS_KFV mvl1
                          WHERE mvl1.inventory_item_id = BBMI.assembly_item_id
                          and mvl1.organization_id = BBMI.organization_id)
    WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
    AND upper(transaction_type) in (G_Create, G_Delete, G_Update,G_NoOp)
    AND assembly_item_id is not null
    AND organization_id is not null
    AND
    (
    ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
    OR  ( p_batch_id = BBMI.batch_id )
    )
    AND exists (SELECT 'x'
                FROM MTL_SYSTEM_ITEMS MKFV
                WHERE MKFV.inventory_item_id = BBMI.assembly_item_id
                AND MKFV.organization_id = BBMI.organization_id);

  stmt_num := 4;

    /* Update Assembly Item Id*/
    UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
    SET assembly_item_id = (SELECT inventory_item_id
                            FROM MTL_SYSTEM_ITEMS_KFV mvl1
                            WHERE mvl1.concatenated_segments = BBMI.item_number
                            AND  mvl1.organization_id = BBMI.organization_id)
    WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
    AND upper(transaction_type) in (G_Create, G_Delete, G_Update,G_NoOp)
    AND item_number is not null
    AND organization_id is not null
    AND assembly_item_id is null
    AND
    (
         ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
      OR ( p_batch_id = BBMI.batch_id )
     );

   stmt_num := 5;
   /*  Assign transaction ids */

       UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete,'NO_OP')
         AND (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          )
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id));



stmt_num := 6;
/* Assign Common Item id and Common Organization id if common_bill_sequence_id is given
and a bill exists with that bill_sequence_id */

  UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET(common_assembly_item_id, common_organization_id)
       = (SELECT assembly_item_id, organization_id
           FROM bom_structures_b BBM1
           WHERE BBM1.bill_sequence_id = BBMI.common_bill_sequence_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update,G_NoOp)
         AND common_bill_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          )
         AND exists (SELECT 'x'
       FROM bom_structures_b BBM2
       WHERE BBM2.bill_sequence_id = BBMI.common_bill_sequence_id);



stmt_num :=7;
/* Assign common_organization_code if common_organization_id is populated */

    UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET common_org_code = (SELECT organization_code
                                 FROM MTL_PARAMETERS mp1
               WHERE mp1.organization_id = BBMI.common_organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update,G_NoOp)
         AND common_organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          )
         AND exists (SELECT 'x'
                      FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BBMI.common_organization_id);



 stmt_num :=8 ;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET common_organization_id = (SELECT organization_id
                                       FROM MTL_PARAMETERS MP1
                                       WHERE mp1.organization_code = BBMI.common_org_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
       AND upper(transaction_type) in (G_Create, G_Delete, G_Update,G_NoOp)
       AND common_organization_id is null
       AND common_org_code is not null
       AND
        (
            ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
        OR  ( p_batch_id = BBMI.batch_id )
        );

  stmt_num := 9;
/* Update Assembly Item name */

       UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET common_item_number   = (SELECT concatenated_segments
                                   FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                   WHERE mvl1.inventory_item_id = BBMI.common_assembly_item_id
                                   AND mvl1.organization_id = BBMI.common_organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update,G_NoOp)
         AND common_assembly_item_id is not null
         AND common_organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          )
         AND exists (SELECT 'x'
                     FROM MTL_SYSTEM_ITEMS mvl2
                     WHERE mvl2.inventory_item_id = BBMI.common_assembly_item_id
                     AND mvl2.organization_id = BBMI.common_organization_id);

/* Update the delete_group_name from bom_interface_delete_groups */
   stmt_num := 9.5;
   UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET (DELETE_GROUP_NAME, DG_DESCRIPTION)
                           = (SELECT DELETE_GROUP_NAME, DESCRIPTION
                             FROM bom_interface_delete_groups
                             Where upper(entity_name) = 'BOM_BILL_OF_MTLS_INTERFACE'
                             And rownum = 1)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete)
         AND organization_id is not null
         AND delete_group_name is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          )
         AND exists (SELECT 'x'
                     FROM bom_interface_delete_groups
                     Where upper(entity_name) = 'BOM_BILL_OF_MTLS_INTERFACE'
                     );

  stmt_num := 9.6;
/* Update Bill Sequence Id when there are IDs available */

   UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET bill_sequence_id  = (SELECT bill_sequence_id
                                FROM bom_structures_b bom
                                WHERE bom.assembly_item_id = BBMI.assembly_item_id
                                AND   bom.organization_id = BBMI.organization_id
                                AND   NVL(bom.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BBMI.alternate_bom_designator,FND_API.G_MISS_CHAR))
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          )
         AND exists (SELECT 1
                       FROM bom_structures_b bom1
                      WHERE bom1.assembly_item_id = BBMI.assembly_item_id
                      AND   bom1.organization_id = BBMI.organization_id
                      AND   NVL(bom1.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BBMI.alternate_bom_designator,FND_API.G_MISS_CHAR));

  /* Commented for Performance Fix . We will have the ids before reaching this point
     So we dont need to resolve bill_seq_id using UUs

   stmt_num := 9.7;
   UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET bill_sequence_id  = (SELECT bill_sequence_id
                             FROM  bom_bill_of_materials bom, mtl_system_items_vl mvll
                             WHERE mvll.concatenated_segments = BBMI.item_number
                             AND   mvll.organization_id = BBMI.organization_id
                             AND   bom.assembly_item_id = mvll.inventory_item_id
                             AND   bom.organization_id = mvll.organization_id
                             AND   NVL(bom.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BBMI.alternate_bom_designator,FND_API.G_MISS_CHAR))
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND item_number is not null
         AND organization_id is not null
         AND bill_sequence_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
          OR  ( p_batch_id = BBMI.batch_id )
          );
     */


  stmt_num := 9.8;
/* Update structure type name to the internal name from the display name  */
  UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
     SET structure_type_name = (SELECT structure_type_name
                                FROM  BOM_STRUCTURE_TYPES_VL bstv
                                WHERE decode(BBMI.structure_type_name, null, to_char(bstv.structure_type_id), bstv.display_name)
                                 = decode(BBMI.structure_type_name, null, to_char(BBMI.structure_type_id), BBMI.structure_type_name))
     WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
       AND (structure_type_name is not null OR structure_type_id is not null)
       AND upper(transaction_type) in (G_Create,G_Update,G_NoOp)
       AND
        (
            ( (p_batch_id IS NULL) AND (BBMI.batch_id IS NULL) )
        OR  ( p_batch_id = BBMI.batch_id )
        )
       AND exists (SELECT null
                   FROM  BOM_STRUCTURE_TYPES_VL bstv
                   WHERE decode(BBMI.structure_type_name, null, to_char(bstv.structure_type_id), bstv.display_name) =
                     decode(BBMI.structure_type_name, null, to_char(BBMI.structure_type_id), BBMI.structure_type_name));

   stmt_num := 10;
/*  Load rows from bill interface into revisions interface*/

                 INSERT into mtl_item_revisions_interface
                     (ITEM_NUMBER,
                      ORGANIZATION_CODE,
                      REVISION,
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
                      SET_PROCESS_ID)
                    select
                      item_number,
                       Organization_Code,
                       REVISION,
                       sysdate,
                       sysdate,
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
                       NVL(BATCH_ID,0) -- Replace NULL batch id with 0 - table level default value for set_process_id
                     FROM BOM_BILL_OF_MTLS_INTERFACE
                     WHERE process_flag = 1
                     AND transaction_type = G_Create
                     AND (all_org = 1
                          OR
                          (all_org = 2 AND organization_id = org_id))
                     AND revision is not null
                     AND
                      (
                          ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
                      OR  ( p_batch_id = batch_id )
                      );

COMMIT;
   stmt_num := 11;

/* Update the interface records with process_flag 3 and insert into
MTL_INTERFACE_ERRORS if Item number or Organization_code  is missing*/

 l_sysdate        :=  SYSDATE;
 msg_name1   := 'BOM_ORG_ID_MISSING';
 msg_name2   := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1   := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2   := FND_MESSAGE.GET;

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
  BBMI.transaction_id,
  MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
  Null,
  null,
  'BOM_BILL_OF_MTLS_INTERFACE',
  decode ( BBMI.Organization_code, null, msg_name1,msg_name2),
  decode ( BBMI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
         req_id,
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)

    from BOM_BILL_OF_MTLS_INTERFACE BBMI
   where (organization_code is null or item_number is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  and
   (
       ( (p_batch_id is null) and (bbmi.batch_id is null) )
   or  ( p_batch_id = bbmi.batch_id )
   );


  Update BOM_BILL_OF_MTLS_INTERFACE BBMI
  set process_flag = 3
  where (item_number is null or Organization_code is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  and
   (
       ( (p_batch_id is null) and (BBMI.batch_id is null) )
   or  ( p_batch_id = BBMI.batch_id )
   ) ;

Commit;

return(0);


EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Open_Interface_Utl(Process_Header_Info-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);

END;


/*--------------------------Process_Comps_Info------------------------------

NAME
   Process_Comps_Info
DESCRIPTION
    Populate the user-friendly columns to Component records in the interface table
REQUIRES

MODIFIES
    BOM_INVENTORY_COMPS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/

FUNCTION Process_Comps_Info (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN  NUMBER
)
    return INTEGER
IS
 stmt_num            NUMBER := 0;
l_sysdate        DATE  :=  SYSDATE;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN

 stmt_num := 1;
/* Resolve the Component_sequence_ids for updates and deletes */

   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET(bill_sequence_id,  component_item_id, effectivity_date,
         operation_seq_num,  from_end_item_unit_number)
       = (SELECT bill_sequence_id,  component_item_id,
    effectivity_date, operation_seq_num,  from_end_item_unit_number
           FROM bom_components_b BIC1
           WHERE BIC1.component_sequence_id = BICI.component_sequence_id )
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND component_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 'x'
           FROM bom_components_b BIC2
           WHERE BIC2.component_sequence_id = BICI.component_sequence_id );


stmt_num := 2;
/* Resolve the Bill sequence ids for updates and deletes */

   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET(assembly_item_id, organization_id, alternate_bom_designator)
       = (SELECT assembly_item_id, organization_id , alternate_bom_designator
           FROM bom_structures_b BBM1
           WHERE BBM1.bill_sequence_id = BICI.bill_sequence_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND bill_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 'x'
       FROM bom_structures_b BBM2
       WHERE BBM2.bill_sequence_id =BICI.bill_sequence_id);


 stmt_num := 3;
/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
   SET organization_code = (SELECT organization_code
                            FROM MTL_PARAMETERS mp1
                            WHERE mp1.organization_id = BICI.organization_id)
   WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
   AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
   AND organization_id is not null
   AND
    (
        ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
    OR  ( p_batch_id = BICI.batch_id )
    )
   AND exists (SELECT 'x'
               FROM MTL_PARAMETERS mp2
               WHERE mp2.organization_id = BICI.organization_id);



 stmt_num := 4;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
      SET organization_id = (SELECT organization_id
                             FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_code = BICI.organization_code)
      WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
      AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
      AND organization_id is null
      AND organization_code is not null
      AND
       (
           ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
       OR  ( p_batch_id = BICI.batch_id )
       );



  stmt_num := 5;
/* Update Assembly Item name */

   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET  assembly_item_number  = (SELECT concatenated_segments
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = BICI.assembly_item_id
                                     AND mvl1.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items mvl12
                      WHERE mvl12.inventory_item_id = BICI.assembly_item_id
                      AND mvl12.organization_id = BICI.organization_id);

   stmt_num := 5.1;
   /* Update the Assembly Item Id */

       UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET  assembly_item_id  = (SELECT inventory_item_id
                                 FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                 WHERE mvl1.concatenated_segments = BICI.assembly_item_number
                                 AND mvl1.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_number is not null
         AND organization_id is not null
         AND assembly_item_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          );


  stmt_num := 6;
  /* Update Component Item name */

   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET  component_item_number   = (SELECT CONCATENATED_SEGMENTS
                                       FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                       WHERE mvl1.inventory_item_id = BICI.component_item_id
                                       AND mvl1.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND COMPONENT_ITEM_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items mvl12
                      WHERE mvl12.inventory_item_id = BICI.component_item_id
                      AND mvl12.organization_id = BICI.organization_id);

  stmt_num := 6.1;
/* Update the component_item_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET component_item_id  = (SELECT inventory_item_id
                                 FROM  mtl_system_items_kfv mvll
                                 WHERE mvll.concatenated_segments = BICI.component_item_number
                                 AND   mvll.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND component_item_number is not null
         AND organization_id is not null
         AND component_item_id IS null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          );


   stmt_num := 7;
   /*  Assign transaction ids */

       UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          );


stmt_num := 8;
/* Update Supply_locator_name */

 UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET  location_name  = (SELECT concatenated_segments
                             FROM MTL_ITEM_LOCATIONS_KFV MIL1
                             WHERE MIL1.inventory_location_id = BICI.supply_locator_id
           and MIL1.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND supply_locator_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_ITEM_LOCATIONS mil2
                       WHERE mil2.INVENTORY_LOCATION_ID = BICI.supply_locator_id
      and mil2.organization_id = BICI.organization_id);

stmt_num := 8.5;
/* Update the delete_group_name from bom_interface_delete_groups */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET (DELETE_GROUP_NAME, DG_DESCRIPTION)
                           = (SELECT DELETE_GROUP_NAME, DESCRIPTION
                             FROM bom_interface_delete_groups
                             Where upper(entity_name) = 'BOM_INVENTORY_COMPS_INTERFACE'
                             And rownum = 1)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete)
         AND organization_id is not null
         AND delete_group_name is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 'x'
                     FROM bom_interface_delete_groups
                     Where upper(entity_name) = 'BOM_INVENTORY_COMPS_INTERFACE'
                     );


stmt_num := 8.6;
/* Update the bill_sequence_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET bill_sequence_id  =  (SELECT bill_sequence_id
                                 FROM  bom_structures_b bom
                                 WHERE bom.assembly_item_id = BICI.assembly_item_id
                                 AND   bom.organization_id = BICI.organization_id
                                 AND   NVL(bom.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BICI.alternate_bom_designator,FND_API.G_MISS_CHAR))
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 'x'
                     FROM bom_structures_b bsb
                     WHERE bsb.assembly_item_id = BICI.assembly_item_id
                     AND bsb.organization_id = BICI.organization_id
                     AND NVL(BSB.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BICI.alternate_bom_designator,FND_API.G_MISS_CHAR)
                     );



stmt_num := 8.8;
/* Update the component_sequence_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET COMPONENT_SEQUENCE_ID
                           = (SELECT COMPONENT_SEQUENCE_ID
                             FROM bom_components_b BIC
                             Where BIC.bill_sequence_id = BICI.bill_Sequence_id
                             And BIC.component_item_id = BICI.component_item_id
                             AND BIC.operation_seq_num = BICI.operation_seq_num
                             AND BIC.effectivity_date = BICI.effectivity_date)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Update, G_Delete)
         AND COMPONENT_SEQUENCE_ID is null
         AND bill_sequence_id is not null
         AND component_item_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          );

stmt_num := 8.9;
/* Defaulting the effectivity_date to sysdate if the transaction_type is create
   and effectivity date is null */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE
       SET EFFECTIVITY_DATE = SYSDATE
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(Transaction_Type) = G_Create
         AND Effectivity_Date IS NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
          OR  ( p_batch_id = batch_id )
          );

   stmt_num := 9;
 /* INSERTS ONLY - Load rows from component interface into sub comp interface*/
   INSERT into bom_sub_comps_interface (
        SUBSTITUTE_COMPONENT_ID,
        SUBSTITUTE_COMP_NUMBER,
        ORGANIZATION_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        COMPONENT_SEQUENCE_ID,
        PROCESS_FLAG,
        TRANSACTION_TYPE,
        SUBSTITUTE_ITEM_QUANTITY,
  BILL_SEQUENCE_ID,
        ASSEMBLY_ITEM_ID,
        ALTERNATE_BOM_DESIGNATOR,
        COMPONENT_ITEM_ID,
        OPERATION_SEQ_NUM,
        EFFECTIVITY_DATE,
        ORGANIZATION_CODE,
        COMPONENT_ITEM_NUMBER,
        ASSEMBLY_ITEM_NUMBER,
        FROM_END_ITEM_UNIT_NUMBER,
        BATCH_ID)
      SELECT
             SUBSTITUTE_COMP_ID,
             SUBSTITUTE_COMP_NUMBER,
             ORGANIZATION_ID,
             NVL(LAST_UPDATE_DATE, SYSDATE),
             NVL(LAST_UPDATED_BY, user_id),
             NVL(CREATION_DATE,SYSDATE),
             NVL(CREATED_BY, user_id),
             NVL(LAST_UPDATE_LOGIN, user_id),
             NVL(REQUEST_ID, req_id),
             NVL(PROGRAM_APPLICATION_ID, prog_appid),
             NVL(PROGRAM_ID, prog_id),
             NVL(PROGRAM_UPDATE_DATE, sysdate),
             COMPONENT_SEQUENCE_ID,
             1,
             G_Create,
             COMPONENT_QUANTITY,
        BILL_SEQUENCE_ID,
             ASSEMBLY_ITEM_ID,
             ALTERNATE_BOM_DESIGNATOR,
             COMPONENT_ITEM_ID,
             OPERATION_SEQ_NUM,
             EFFECTIVITY_DATE,
             ORGANIZATION_CODE,
             COMPONENT_ITEM_NUMBER,
             ASSEMBLY_ITEM_NUMBER,
             FROM_END_ITEM_UNIT_NUMBER,
             BATCH_ID
        FROM bom_inventory_comps_interface
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND transaction_type = G_Create
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND (substitute_comp_id is not null
              OR
              substitute_comp_number is not null)
         AND
          (
              ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
          OR  ( p_batch_id = batch_id )
          );


   stmt_num := 10;

/* INSERTS ONLY - Load rows from component interface into ref desgs interface*/

   INSERT INTO bom_ref_desgs_interface (
        COMPONENT_REFERENCE_DESIGNATOR,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        COMPONENT_SEQUENCE_ID,
        TRANSACTION_TYPE,
        PROCESS_FLAG,
  BILL_SEQUENCE_ID,
        ASSEMBLY_ITEM_ID,
        ALTERNATE_BOM_DESIGNATOR,
        ORGANIZATION_ID,
        COMPONENT_ITEM_ID,
        ASSEMBLY_ITEM_NUMBER,
        COMPONENT_ITEM_NUMBER,
        ORGANIZATION_CODE,
        EFFECTIVITY_DATE,
        OPERATION_SEQ_NUM,
        FROM_END_ITEM_UNIT_NUMBER,
        BATCH_ID)
   SELECT
        REFERENCE_DESIGNATOR,
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate),
        COMPONENT_SEQUENCE_ID,
        G_Create,
        1,
  BILL_SEQUENCE_ID,
        ASSEMBLY_ITEM_ID,
        ALTERNATE_BOM_DESIGNATOR,
        ORGANIZATION_ID,
        COMPONENT_ITEM_ID,
        ASSEMBLY_ITEM_NUMBER,
        COMPONENT_ITEM_NUMBER,
        ORGANIZATION_CODE,
        EFFECTIVITY_DATE,
        OPERATION_SEQ_NUM,
        FROM_END_ITEM_UNIT_NUMBER,
        BATCH_ID
    FROM bom_inventory_comps_interface
   WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
     AND transaction_type = G_Create
     AND (all_org = 1
          OR
          (all_org = 2 AND organization_id = org_id))
     AND reference_designator is not null
     AND
      (
          ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
      OR  ( p_batch_id = batch_id )
      );
 COMMIT;

   stmt_num := 11;

/* Update the interface records with process_flag 3 and insert into
mtl_interface_errors if Item_number or Organization_code  is missing*/

 l_sysdate        :=  SYSDATE;
 msg_name1   := 'BOM_ORG_ID_MISSING';
 msg_name2   := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1   := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2   := FND_MESSAGE.GET;
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
  BICI.transaction_id,
  MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
  Null,
  null,
  'BOM_INVENTORY_COMPS_INTERFACE',
  decode ( BICI.Organization_code, null, msg_name1,msg_name2),
  decode ( BICI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)

   from BOM_INVENTORY_COMPS_INTERFACE BICI
   where (organization_code is null or ASSEMBLY_ITEM_NUMBER is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  AND
   (
       ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
   OR  ( p_batch_id = BICI.batch_id )
   );



  Update BOM_INVENTORY_COMPS_INTERFACE
  set process_flag = 3
  where (ASSEMBLY_ITEM_NUMBER is null or Organization_code is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  AND
   (
       ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
   OR  ( p_batch_id = batch_id )
   );
Commit;

return (0);


EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Open_Interface_Utl(Process_component_Info-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);
END;


/*--------------------------Process_Ref_Degs_Info------------------------------

NAME
   Process_Ref_Degs_Info
DESCRIPTION
   Populate the user-friendly columns to Reference Designator records
   in the interface table
REQUIRES

MODIFIES
    BOM_REF_DESGS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Process_Ref_Degs_Info  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN  NUMBER
)
    return INTEGER
IS
  stmt_num            NUMBER := 0;
l_sysdate        DATE  :=  SYSDATE;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN

 stmt_num := 1;
/* Resolve the Component_sequence_id for all the records */

   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET(bill_sequence_id,  component_item_id, effectivity_date,
         operation_seq_num,  from_end_item_unit_number)
       = (SELECT bill_sequence_id,  component_item_id,
    effectivity_date, operation_seq_num,  from_end_item_unit_number
           FROM bom_components_b BIC1
           WHERE BIC1.component_sequence_id = BRDI.component_sequence_id )
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND COMPONENT_SEQUENCE_ID is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
         AND exists (SELECT 'x'
           FROM bom_components_b BIC2
           WHERE BIC2.COMPONENT_SEQUENCE_ID = BRDI.COMPONENT_SEQUENCE_ID );


stmt_num := 2;
/* Resolve the Bill sequence ids for updates and deletes */

   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET(assembly_item_id, organization_id, ALTERNATE_BOM_DESIGNATOR)
       = (SELECT assembly_item_id, organization_id , alternate_bom_designator
           FROM bom_structures_b BBM1
           WHERE BBM1.bill_sequence_id = BRDI.bill_sequence_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND bill_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
         AND exists (SELECT 'x'
       FROM bom_structures_b BBM2
       WHERE BBM2.bill_sequence_id = BRDI.bill_sequence_id);


 stmt_num := 3;
/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET organization_code = (SELECT organization_code
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_id = BRDI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BRDI.organization_id);



 stmt_num := 4;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_REF_DESGS_INTERFACE BRDI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BRDI.organization_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );



  stmt_num := 5;
/* Update Assembly Item name */

   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET  ASSEMBLY_ITEM_NUMBER  = (SELECT CONCATENATED_SEGMENTS
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = BRDI.assembly_item_id
                                     and mvl1.organization_id = BRDI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
          AND exists (select 'x'
                      FROM mtl_system_items MKFV
                      WHERE MKFV.inventory_item_id = BRDI.assembly_item_id
                      AND MKFV.organization_id = BRDI.organization_id );


  stmt_num := 6;
/* Update Component Item name */

   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET  COMPONENT_ITEM_NUMBER   = (SELECT CONCATENATED_SEGMENTS
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.inventory_item_id = BRDI.component_item_id
                             AND mvl1.organization_id = BRDI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND COMPONENT_ITEM_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
         AND exists (SELECT 'x'
                     FROM mtl_system_items MKFV
                     WHERE MKFV.inventory_item_id = BRDI.component_item_id
                     AND MKFV.organization_id = BRDI.organization_id);


   stmt_num := 7;
   /*  Assign transaction ids */

       UPDATE BOM_REF_DESGS_INTERFACE BRDI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );

  COMMIT;

   stmt_num := 8;
/* Update the interface records with process_flag 3 and insert into
mtl_interface_errors if Item_number or Organization_code  is missing*/

 l_sysdate        :=  SYSDATE;
 msg_name1   := 'BOM_ORG_ID_MISSING';
 msg_name2   := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1   := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2   := FND_MESSAGE.GET;
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
  BRDI.transaction_id,
  MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
  Null,
  null,
  'BOM_REF_DESGS_INTERFACE',
  decode ( BRDI.Organization_code, null, msg_name1,msg_name2),
  decode ( BRDI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
    from BOM_REF_DESGS_INTERFACE BRDI
   where (organization_code is null or ASSEMBLY_ITEM_NUMBER is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  AND
   (
       ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
   OR  ( p_batch_id = BRDI.batch_id )
   );

  Update BOM_REF_DESGS_INTERFACE
  set process_flag = 3
  where (ASSEMBLY_ITEM_NUMBER is null or Organization_code is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  AND
   (
       ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
   OR  ( p_batch_id = batch_id )
   );
Commit;

return(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Open_Interface_Utl(Process_ref_desgs_Info-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);
END;

/*--------------------------Process_Sub_Comps_Info------------------------------

NAME
  Process_Sub_Comps_Info
DESCRIPTION
   Populate the user-friendly columns to Substitute Component records
   in the interface table
REQUIRES

MODIFIES
    BOM_SUB_COMPS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Process_Sub_Comps_Info  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN  NUMBER
)
    return INTEGER
IS
 stmt_num            NUMBER := 0;
l_sysdate        DATE  :=  SYSDATE;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN

 stmt_num := 1;
/* Resolve the Component_sequence_id for all the records */

   UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET(bill_sequence_id,  component_item_id, effectivity_date,
         operation_seq_num,  from_end_item_unit_number)
       = (select bill_sequence_id,  component_item_id,
    EFFECTIVITY_DATE, OPERATION_SEQ_NUM,  FROM_END_ITEM_UNIT_NUMBER
           FROM bom_components_b BIC1
           WHERE BIC1.COMPONENT_SEQUENCE_ID = BSCI.component_sequence_id )
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND COMPONENT_SEQUENCE_ID is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
         AND exists (SELECT 'x'
           FROM bom_components_b BIC2
           WHERE BIC2.COMPONENT_SEQUENCE_ID = BSCI.COMPONENT_SEQUENCE_ID );


stmt_num := 2;
/* Resolve the Bill sequence ids for updates and deletes */

   UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET(assembly_item_id, organization_id, alternate_bom_designator)
       = (SELECT assembly_item_id, organization_id , alternate_bom_designator
           FROM bom_structures_b BBM1
           WHERE BBM1.bill_sequence_id = BSCI.bill_sequence_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND bill_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
         AND exists (SELECT 'x'
       FROM bom_structures_b BBM2
       WHERE BBM2.bill_sequence_id = BSCI.bill_sequence_id);


 stmt_num := 3;
/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET organization_code = (SELECT organization_code
                                  FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BSCI.organization_id);



 stmt_num := 4;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_SUB_COMPS_INTERFACE BSCI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BSCI.organization_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );



  stmt_num := 5;
/* Update Assembly Item name */

   UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET  ASSEMBLY_ITEM_NUMBER  = (SELECT CONCATENATED_SEGMENTS
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = BSCI.assembly_item_id
                                     AND mvl1.organization_id = BSCI.organization_id)
         WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items MKFV
                      WHERE MKFV.inventory_item_id = BSCI.assembly_item_id
                      AND MKFV.organization_id = BSCI.organization_id);


  stmt_num := 6;
/* Update Component Item name */

   UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET  COMPONENT_ITEM_NUMBER   = (SELECT CONCATENATED_SEGMENTS
                                       FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                       WHERE mvl1.inventory_item_id = BSCI.component_item_id
                                       AND mvl1.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND COMPONENT_ITEM_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items MKFV
                      WHERE MKFV.inventory_item_id = BSCI.component_item_id
                      AND MKFV.organization_id = BSCI.organization_id);


 stmt_num := 7;
/* Update Substitute Component name if Id is given */

   UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET  SUBSTITUTE_COMP_NUMBER = (SELECT CONCATENATED_SEGMENTS
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.inventory_item_id = BSCI.SUBSTITUTE_COMPONENT_ID
                             and mvl1.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND SUBSTITUTE_COMPONENT_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items MKFV
                      WHERE MKFV.inventory_item_id = BSCI.substitute_component_id
                      AND MKFV.organization_id = BSCI.organization_id);



 stmt_num := 8;
/* Update new Substitute Component name if Id is given */

   UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET  NEW_SUB_COMP_NUMBER = (SELECT CONCATENATED_SEGMENTS
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.inventory_item_id = BSCI.NEW_SUB_COMP_ID
                             and mvl1.organization_id = BSCI.organization_id)
       WHERE  (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND NEW_SUB_COMP_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items MKFV
                      WHERE MKFV.inventory_item_id = BSCI.new_sub_comp_id
                      AND MKFV.organization_id = BSCI.organization_id);

   stmt_num := 9;
   /*  Assign transaction ids */

       UPDATE BOM_SUB_COMPS_INTERFACE BSCI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );

  COMMIT;
   stmt_num := 10;
/* Update the interface records with process_flag 3 and insert into
mtl_interface_errors if Item_number or Organization_code  is missing*/

 l_sysdate        :=  SYSDATE;
 msg_name1   := 'BOM_ORG_ID_MISSING';
 msg_name2   := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1   := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2   := FND_MESSAGE.GET;
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
  BSCI.transaction_id,
  MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
  Null,
  null,
  'BOM_INVENTORY_COMPS_INTERFACE',
  decode ( BSCI.Organization_code, null, msg_name1,msg_name2),
  decode ( BSCI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        NVL(REQUEST_ID, req_id),
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)

    from BOM_SUB_COMPS_INTERFACE BSCI
   where (organization_code is null or ASSEMBLY_ITEM_NUMBER is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  AND
   (
       ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
   OR  ( p_batch_id = BSCI.batch_id )
   );

  Update BOM_SUB_COMPS_INTERFACE
  set process_flag = 3
  where (ASSEMBLY_ITEM_NUMBER is null or Organization_code is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  AND
   (
       ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
   OR  ( p_batch_id = batch_id )
   );
Commit;

return(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Open_Interface_Utl(Process_sub_comps_Info-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);
END;

/*--------------------------Process_Comp_Ops_Info------------------------------

NAME
  Process_Comp_Ops_Info
DESCRIPTION
   Populate the user-friendly columns to Component Operations records
   in the interface table
REQUIRES

MODIFIES
    BOM_COMPONENT_OPS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/

FUNCTION Process_Comp_Ops_Info  (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN  NUMBER
   )
    return INTEGER
IS
 stmt_num            NUMBER := 0;
l_sysdate        DATE  :=  SYSDATE;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);

BEGIN

 stmt_num := 1;
/* Resolve the Component_sequence_id for all the records */

   UPDATE BOM_COMPONENT_OPS_INTERFACE BCOI
       SET(bill_sequence_id,  component_item_id, effectivity_date,
         operation_seq_num,  from_end_item_unit_number)
       = (SELECT bill_sequence_id,  component_item_id,
    effectivity_date, operation_seq_num,  from_end_item_unit_number
           FROM bom_components_b BIC1
           WHERE BIC1.component_sequence_id = BCOI.component_sequence_id )
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND COMPONENT_SEQUENCE_ID is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BCOI.batch_id IS NULL) )
          OR  ( p_batch_id = BCOI.batch_id )
          )
         AND exists (SELECT 'x'
           FROM BOM_INVENTORY_COMPONENTS BIC2
           WHERE BIC2.COMPONENT_SEQUENCE_ID = BCOI.COMPONENT_SEQUENCE_ID );


stmt_num := 2;
/* Resolve the Bill sequence ids for updates and deletes */

   UPDATE BOM_COMPONENT_OPS_INTERFACE BCOI
       SET(assembly_item_id, organization_id, alternate_bom_designator)
       = (SELECT assembly_item_id, organization_id , alternate_bom_designator
           FROM bom_structures_b BBM1
           WHERE BBM1.bill_sequence_id = BCOI.bill_sequence_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND bill_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BCOI.batch_id IS NULL) )
          OR  ( p_batch_id = BCOI.batch_id )
          )
         AND exists (SELECT 'x'
       FROM bom_structures_b BBM2
       WHERE BBM2.bill_sequence_id = BCOI.bill_sequence_id);


 stmt_num := 3;
/* Update Organization Code using Organization_id
this also needed if orgnaization_id is given and code is not given*/

   UPDATE BOM_COMPONENT_OPS_INTERFACE BCOI
       SET organization_code = (SELECT organization_code
                                  FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_id = BCOI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BCOI.batch_id IS NULL) )
          OR  ( p_batch_id = BCOI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BCOI.organization_id);



 stmt_num := 4;
 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_COMPONENT_OPS_INTERFACE BCOI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BCOI.organization_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BCOI.batch_id IS NULL) )
          OR  ( p_batch_id = BCOI.batch_id )
          );



  stmt_num := 5;
/* Update Assembly Item name */

   UPDATE BOM_COMPONENT_OPS_INTERFACE BCOI
       SET  ASSEMBLY_ITEM_NUMBER  = (SELECT CONCATENATED_SEGMENTS
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.inventory_item_id = BCOI.assembly_item_id
           and mvl1.organization_id = BCOI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BCOI.batch_id IS NULL) )
          OR  ( p_batch_id = BCOI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items MKFV
                      WHERE MKFV.inventory_item_id = BCOI.assembly_item_id
                      AND MKFV.organization_id = BCOI.organization_id);


  stmt_num := 6;
/* Update Component Item name */

   UPDATE BOM_COMPONENT_OPS_INTERFACE BCOI
       SET  COMPONENT_ITEM_NUMBER   = (SELECT CONCATENATED_SEGMENTS
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.inventory_item_id = BCOI.component_item_id
           and mvl1.organization_id = BCOI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND COMPONENT_ITEM_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BCOI.batch_id IS NULL) )
          OR  ( p_batch_id = BCOI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items MKFV
                      WHERE MKFV.inventory_item_id = BCOI.component_item_id
                      AND MKFV.organization_id = BCOI.organization_id);


   stmt_num := 8;
   /*  Assign transaction ids */

       UPDATE BOM_COMPONENT_OPS_INTERFACE BCOI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND
          (
              ( (p_batch_id IS NULL) AND (BCOI.batch_id IS NULL) )
          OR  ( p_batch_id = BCOI.batch_id )
          );

  COMMIT;

   stmt_num := 9;
/* Update the interface records with process_flag 3 and insert into
mtl_interface_errors if Item_number or Organization_code  is missing*/

 l_sysdate        :=  SYSDATE;
 msg_name1   := 'BOM_ORG_ID_MISSING';
 msg_name2   := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1   := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2   := FND_MESSAGE.GET;
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
  BCOI.transaction_id,
  MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
  Null,
  null,
  'BOM_COMPONENT_OPS_INTERFACE',
  decode ( BCOI.Organization_code, null, msg_name1,msg_name2),
  decode ( BCOI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
        req_id,
  NVL(PROGRAM_APPLICATION_ID, prog_appid),
  NVL(PROGRAM_ID, prog_id),
  NVL(PROGRAM_UPDATE_DATE, sysdate)
    from BOM_COMPONENT_OPS_INTERFACE BCOI
   where (organization_code is null or ASSEMBLY_ITEM_NUMBER is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  AND
   (
       ( (p_batch_id IS NULL) AND (BCOI.batch_id IS NULL) )
   OR  ( p_batch_id = BCOI.batch_id )
   );

  Update BOM_COMPONENT_OPS_INTERFACE
  set process_flag = 3
  where (ASSEMBLY_ITEM_NUMBER is null or Organization_code is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  AND
   (
       ( (p_batch_id IS NULL) AND (batch_id IS NULL) )
   OR  ( p_batch_id = batch_id )
   );
Commit;

return(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Open_Interface_Utl(Process_comp_ops_Info-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);
END;

FUNCTION Process_Revision_Info (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_set_process_id  IN  NUMBER
)return integer is
 stmt_num            NUMBER := 0;
l_sysdate        DATE  :=  SYSDATE;
msg_name1 varchar2(30);
msg_name2 varchar2(30);
msg_text1 varchar2(2000);
msg_text2 varchar2(2000);
l_set_process_id NUMBER := 0;
begin
  --if set_process_id is null then set it to 0 which is table level default value
  IF ( p_set_process_id IS NULL ) THEN
    l_set_process_id := 0;
  ELSE
    l_set_process_id := p_set_process_id;
  END IF;

  stmt_num := 1;

/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
       SET organization_code = (SELECT organization_code
                                  FROM MTL_PARAMETERS MP1
                             WHERE mp1.organization_id = MIRI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is not null
         AND MIRI.set_process_id = l_set_process_id
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS MP2
                      WHERE mp2.organization_id = MIRI.organization_id);



 stmt_num := 2;
 /* Update Organization_ids if organization code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
         SET organization_id = (SELECT organization_id
                                  FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_code = MIRI.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_id is null
         AND organization_code is not null
         AND MIRI.set_process_id = l_set_process_id;



  stmt_num := 3;
/* Update Assembly Item name */

   UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
       SET  item_number   = (SELECT concatenated_segments
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.inventory_item_id = MIRI.inventory_item_id
           and mvl1.organization_id = MIRI.organization_id)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND inventory_item_id is not null
         AND organization_id is not null
         AND MIRI.set_process_id = l_set_process_id
         AND exists (SELECT 'x'
                       FROM mtl_system_items mvl2
                      WHERE mvl2.inventory_item_id = MIRI.inventory_item_id
          and mvl2.organization_id = MIRI.organization_id);



   stmt_num := 5;
   /*  Assign transaction ids */

       UPDATE MTL_ITEM_REVISIONS_INTERFACE MIRI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND process_flag = 1
         AND (all_org = 1
             OR
          (all_org = 2 AND organization_id = org_id))
         AND MIRI.set_process_id = l_set_process_id;

COMMIT;
   stmt_num := 6;

/* Update the interface records with process_flag 3 and insert into
MTL_INTERFACE_ERRORS if Item number or Organization_code  is missing*/

 l_sysdate        :=  SYSDATE;
 msg_name1   := 'BOM_ORG_ID_MISSING';
 msg_name2   := 'BOM_ASSY_ITEM_MISSING';
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ORG_ID_MISSING');
 msg_text1   := FND_MESSAGE.GET;
 FND_MESSAGE.SET_NAME('BOM', 'BOM_ASSY_ITEM_MISSING');
 msg_text2   := FND_MESSAGE.GET;

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
  MIRI.transaction_id,
  MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
  Null,
  null,
  'MTL_ITEM_REVISIONS_INTERFACE',
  decode ( MIRI.Organization_code, null, msg_name1,msg_name2),
  decode ( MIRI.Organization_code, null, msg_text1,msg_text2),
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, user_id),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, user_id),
        NVL(LAST_UPDATE_LOGIN, user_id),
         req_id,
        NVL(PROGRAM_APPLICATION_ID, prog_appid),
        NVL(PROGRAM_ID, prog_id),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
    from MTL_ITEM_REVISIONS_INTERFACE MIRI
   where (organization_code is null or item_number is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  and MIRI.set_process_id = l_set_process_id;


  Update  MTL_ITEM_REVISIONS_INTERFACE MIRI
  set process_flag = 3
  where (item_number is null or Organization_code is null)
  and transaction_id is not null
  and process_flag =1
  and (all_org = 1 OR (all_org = 2 AND organization_id = org_id))
  and MIRI.set_process_id = l_set_process_id;

Commit;

return(0);


EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Open_Interface_Utl(Process_Revision_Info-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(SQLCODE);

end;

/*--------------------------Process_All_Entities------------------------------

NAME
   Process_All_Entities
DESCRIPTION
    Process all the entities - Bill, Components, Substitute Components,
                               Reference Designators and Component Operations
    It will process all the entities with null batch id.
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Process_All_Entities (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2
)
    return INTEGER
IS
  l_return_status INTEGER := 0;
BEGIN

  --call the process_all_entities with null batch id.
  l_return_status := Process_All_Entities (
                        org_id => org_id,
                        all_org => all_org,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        err_text => err_text,
                        p_batch_id  => NULL
                      );

  RETURN l_return_status;
END;

/*--------------------------Process_All_Entities------------------------------

NAME
   Process_All_Entities
DESCRIPTION
    Process all the entities - Bill, Components, Substitute Components,
                               Reference Designators and Component Operations
    It will process all the entities for given batch id .
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Process_All_Entities (
    org_id            NUMBER,
    all_org             NUMBER ,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT NOCOPY  VARCHAR2,
    p_batch_id  IN  NUMBER
)
    return INTEGER
IS
  l_return_status INTEGER := 0;
BEGIN
  l_return_status := Process_Header_Info
                     (org_id,
                      all_org,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      req_id,
                      err_text,
                      p_batch_id);
   IF l_return_status <> 0 THEN
      RETURN l_return_status;
   END IF;

   /* Set PK3_value if the value for revision exists */
   UPDATE BOM_BILL_OF_MTLS_INTERFACE BBMI
       SET pk3_value  = (SELECT mrb.revision_id
                             FROM  mtl_item_revisions_b mrb
                             WHERE mrb.inventory_item_id = BBMI.Assembly_item_id
                             AND   mrb.organization_id = BBMI.organization_id
                             AND   mrb.revision = BBMI.REVISION)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND Assembly_item_id is not null
         AND Revision is not null
         AND organization_id is not null
         AND exists (SELECT 1
                      FROM  mtl_item_revisions_b mrb
                      WHERE mrb.inventory_item_id = BBMI.Assembly_item_id
                      AND   mrb.organization_id = BBMI.organization_id
                      AND   mrb.revision = BBMI.Revision);

   /* If SYNC rows has valid ComponentSequenceId then update the transaction type to UPDATE */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI SET transaction_type = G_Update
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND UPPER(transaction_type) = 'SYNC'
         AND component_sequence_id IS NOT NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND EXISTS (SELECT 'x'
           FROM BOM_INVENTORY_COMPONENTS BIC2
           WHERE BIC2.component_sequence_id = BICI.component_sequence_id );

   /* If SYNC rows don't have ComponentSequenceId value then update the transaction type to CREATE */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI SET transaction_type = G_Create
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND UPPER(transaction_type) = 'SYNC'
         AND component_sequence_id IS NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          );

 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BICI.organization_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
         AND organization_code is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_code = BICI.organization_code);

 /* Update the Assembly_item_number */
    UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET assembly_item_number  = (SELECT concatenated_segments
                             FROM  mtl_system_items_kfv MKFV
                             WHERE MKFV.inventory_item_id = BICI.Assembly_item_id
                             AND   MKFV.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create,G_NoOp)
         AND Assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM  mtl_system_items MKFV2
                      WHERE MKFV2.inventory_item_id = BICI.Assembly_item_id
                      AND   MKFV2.organization_id = BICI.organization_id);



 /* Update the Assembly_item_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET Assembly_item_id  = (SELECT inventory_item_id
                             FROM  mtl_system_items_kfv mvll
                             WHERE mvll.concatenated_segments = BICI.Assembly_item_number
                             AND   mvll.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create,G_NoOp)
         AND Assembly_item_number is not null
         AND organization_id is not null
         AND assembly_item_id is NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          );

/* Update component_item_number */
     UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET component_item_number  = (SELECT concatenated_segments
                             FROM  mtl_system_items_kfv mvll
                             WHERE mvll.inventory_item_id = BICI.Component_item_id
                             AND   mvll.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND Component_item_id is not null
         AND Organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items MKFV
                      WHERE MKFV.inventory_item_id = BICI.Component_item_id
                      AND   MKFV.organization_id = BICI.organization_id);

   /* Update the component_item_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET component_item_id  = (SELECT inventory_item_id
                                 FROM  mtl_system_items_kfv mvll
                                 WHERE mvll.concatenated_segments = BICI.Component_item_number
                                 AND   mvll.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND Component_item_number is not null
         AND Organization_id is not null
         AND Component_item_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          );

/* Update the bill_sequence_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET bill_sequence_id  = (SELECT bill_sequence_id
                             FROM  bom_structures_b bom
                             WHERE bom.assembly_item_id = BICI.assembly_item_id
                             AND   bom.organization_id = BICI.organization_id
                             AND   NVL(bom.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BICI.alternate_bom_designator,FND_API.G_MISS_CHAR))
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update)
         AND assembly_item_number is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM bom_structures_b bom2
                      WHERE bom2.assembly_item_id = BICI.assembly_item_id
                      AND   bom2.organization_id = BICI.organization_id
                      AND   NVL(bom2.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BICI.alternate_bom_designator,FND_API.G_MISS_CHAR));

    /*

   l_return_status := Process_Comps_Info
                     (org_id,
                      all_org,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      req_id,
                      err_text,
                      p_batch_id);
   IF l_return_status <> 0 THEN
      RETURN l_return_status;
   END IF;
*/
/* Resolve the Component_sequence_ids for updates and deletes */

   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET(component_item_id, effectivity_date,
         operation_seq_num,  from_end_item_unit_number)
       = (SELECT component_item_id,
    effectivity_date, operation_seq_num,  from_end_item_unit_number
           FROM BOM_INVENTORY_COMPONENTS BIC1
           WHERE BIC1.component_sequence_id = BICI.component_sequence_id )
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND UPPER(transaction_type) IN (G_Delete, G_Update)
         AND component_sequence_id IS NOT NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND EXISTS (SELECT 'x'
           FROM BOM_INVENTORY_COMPONENTS BIC2
           WHERE BIC2.component_sequence_id = BICI.component_sequence_id );


/* Update the component_sequence_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET COMPONENT_SEQUENCE_ID
                           = (SELECT COMPONENT_SEQUENCE_ID
                             FROM BOM_INVENTORY_COMPONENTS BIC
                             WHERE BIC.bill_sequence_id = BICI.bill_Sequence_id
                             AND BIC.component_item_id = BICI.component_item_id
                             AND BIC.operation_seq_num = BICI.operation_seq_num
                             AND BIC.effectivity_date = BICI.effectivity_date)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND UPPER(transaction_type) IN (G_Update, G_Delete)
         AND COMPONENT_SEQUENCE_ID IS NULL
         AND bill_sequence_id IS NOT NULL
         AND component_item_id IS NOT NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND EXISTS (SELECT 'x'
                     FROM BOM_INVENTORY_COMPONENTS BIC
                     WHERE BIC.bill_sequence_id = BICI.bill_Sequence_id
                     AND BIC.component_item_id = BICI.component_item_id
                     AND BIC.operation_seq_num = BICI.operation_seq_num
                     AND BIC.effectivity_date = BICI.effectivity_date);



   /* Update the From_end_item_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET From_End_Item_id = (SELECT inventory_item_id
                             FROM  mtl_system_items_kfv mvll
                             WHERE mvll.concatenated_segments = BICI.From_End_Item
                             AND   mvll.organization_id = BICI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND From_End_Item is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM  mtl_system_items_kfv mvll2
                      WHERE mvll2.concatenated_segments = BICI.From_End_Item
                      AND   mvll2.organization_id = BICI.organization_id);

   /* Update the From_end_item_rev_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET From_end_item_rev_id  = (SELECT mrb.revision_id
                             FROM  mtl_item_revisions_b mrb
                             WHERE mrb.inventory_item_id = BICI.From_End_Item_id
                             AND   mrb.organization_id = BICI.organization_id
                             AND   mrb.revision = BICI.From_end_item_rev_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND From_End_Item is not null
         AND From_end_item_rev_code is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 1
                      FROM  mtl_item_revisions_b mrb
                      WHERE mrb.inventory_item_id = BICI.From_End_Item_id
                      AND   mrb.organization_id = BICI.organization_id
                      AND   mrb.revision = BICI.From_end_item_rev_code);

   /* Update the To_end_item_rev_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET To_end_item_rev_id  = (SELECT mrb.revision_id
                             FROM  mtl_item_revisions_b mrb
                             WHERE mrb.inventory_item_id = BICI.From_End_Item_id
                             AND   mrb.organization_id = BICI.organization_id
                             AND   mrb.revision = BICI.To_end_item_rev_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND From_End_Item is not null
         AND To_end_item_rev_code is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 1
                      FROM  mtl_item_revisions_b mrb
                      WHERE mrb.inventory_item_id = BICI.From_End_Item_id
                      AND   mrb.organization_id = BICI.organization_id
                      AND   mrb.revision = BICI.To_end_item_rev_code);

   /* Update the component_revision_id */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET Component_revision_id  = (SELECT mrb.revision_id
                             FROM  mtl_item_revisions_b mrb
                             WHERE mrb.inventory_item_id = BICI.component_item_id
                             AND   mrb.organization_id = BICI.organization_id
                             AND   mrb.revision = BICI.Component_revision_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND component_item_id is not null
         AND Component_revision_code is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
         AND exists (SELECT 1
                      FROM  mtl_item_revisions_b mrb
                      WHERE mrb.inventory_item_id = BICI.component_item_id
                      AND   mrb.organization_id = BICI.organization_id
                      AND   mrb.revision = BICI.Component_revision_code);

   /* Update the assembly items pk3 value */
   UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET Parent_Revision_Id  = (SELECT mrb.revision_id
                             FROM  mtl_item_revisions_b mrb
                             WHERE mrb.inventory_item_id = BICI.Assembly_item_id
                             AND   mrb.organization_id = BICI.organization_id
                             AND   mrb.revision = BICI.Parent_revision_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND UPPER(transaction_type) in (G_Delete, G_Update, G_Create)
         AND Assembly_item_id is not null
         AND Parent_revision_code is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          );


  /* Update Supply_locator_name */

  UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
       SET  supply_locator_id  = (SELECT inventory_location_id
                            FROM MTL_ITEM_LOCATIONS_KFV MIL1
                            WHERE MIL1.concatenated_segments = BICI.location_name
                            AND MIL1.organization_id = BICI.organization_id)
      WHERE process_flag = 1
        AND upper(transaction_type) in (G_Create, G_Delete, G_Update)
        AND location_name is not null
        AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
          OR  ( p_batch_id = BICI.batch_id )
          )
          AND exists (SELECT 'x'
                     FROM MTL_ITEM_LOCATIONS_KFV mil2
                     WHERE mil2.concatenated_segments = BICI.location_name
                     AND mil2.organization_id = BICI.organization_id);

  UPDATE BOM_INVENTORY_COMPS_INTERFACE BICI
  SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
      transaction_type = upper(transaction_type)
  WHERE transaction_id is null
  AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
  AND (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
  AND
   (
       ( (p_batch_id IS NULL) AND (BICI.batch_id IS NULL) )
   OR  ( p_batch_id = BICI.batch_id )
   );



   -- Reference Designator Changes for PLM Import--
   /*
   l_return_status := Process_Ref_Degs_Info
                     (org_id,
                      all_org,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      req_id,
                      err_text,
                      p_batch_id);
   IF l_return_status <> 0 THEN
      RETURN l_return_status;
   END IF;
   */

      UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET(bill_sequence_id,  component_item_id, effectivity_date,
         operation_seq_num,  from_end_item_unit_number)
       = (SELECT bill_sequence_id,  component_item_id,
    effectivity_date, operation_seq_num,  from_end_item_unit_number
           FROM BOM_INVENTORY_COMPONENTS BIC1
           WHERE BIC1.component_sequence_id = BRDI.component_sequence_id )
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND COMPONENT_SEQUENCE_ID is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
         AND exists (SELECT 'x'
           FROM BOM_INVENTORY_COMPONENTS BIC2
           WHERE BIC2.COMPONENT_SEQUENCE_ID = BRDI.COMPONENT_SEQUENCE_ID );


/* Resolve the Bill sequence ids for updates and deletes */

   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET(assembly_item_id, organization_id, ALTERNATE_BOM_DESIGNATOR)
       = (SELECT assembly_item_id, organization_id , alternate_bom_designator
           FROM BOM_BILL_OF_MATERIALS BBM1
           WHERE BBM1.bill_sequence_id = BRDI.bill_sequence_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND bill_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
         AND exists (SELECT 'x'
       FROM BOM_BILL_OF_MATERIALS BBM2
       WHERE BBM2.bill_sequence_id = BRDI.bill_sequence_id);


/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET organization_code = (SELECT organization_code
                                  FROM MTL_PARAMETERS mp1
                             WHERE mp1.organization_id = BRDI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BRDI.organization_id);



 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE BOM_REF_DESGS_INTERFACE BRDI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BRDI.organization_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND organization_id is null
         AND organization_code is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );



/* Update Assembly Item name */

   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET  ASSEMBLY_ITEM_NUMBER  = (SELECT CONCATENATED_SEGMENTS
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = BRDI.assembly_item_id
                                     AND mvl1.organization_id = BRDI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items mvl12
                      WHERE mvl12.inventory_item_id = BRDI.assembly_item_id
                      AND mvl12.organization_id = BRDI.organization_id);

   /* Update the Assembly_item_id */
   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET Assembly_item_id  = (SELECT inventory_item_id
                             FROM  mtl_system_items_kfv mvll
                             WHERE mvll.concatenated_segments = BRDI.Assembly_item_number
                             AND   mvll.organization_id = BRDI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND Assembly_item_number is not null
         AND organization_id is not null
         AND Assembly_item_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );

/* Update Component Item name */
   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET  COMPONENT_ITEM_NUMBER   = (SELECT CONCATENATED_SEGMENTS
                                       FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                       WHERE mvl1.inventory_item_id = BRDI.component_item_id
                                       AND mvl1.organization_id = BRDI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND COMPONENT_ITEM_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items mvl12
                      WHERE mvl12.inventory_item_id = BRDI.component_item_id
                      AND mvl12.organization_id = BRDI.organization_id);


   /* Update the Component_item_id */
   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET Component_item_id  = (SELECT inventory_item_id
                                 FROM  mtl_system_items_kfv mvll
                                 WHERE mvll.concatenated_segments = BRDI.Component_item_number
                                 AND   mvll.organization_id = BRDI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND Component_item_number is not null
         AND organization_id is not null
         AND component_item_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );

   /* Set the Bill Seqeunce Ids */
   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET bill_sequence_id  = (SELECT bill_sequence_id
                             FROM  bom_structures_b bom
                             WHERE bom.assembly_item_id = BRDI.assembly_item_id
                             AND   bom.organization_id = BRDI.organization_id
                             AND   NVL(bom.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BRDI.alternate_bom_designator,FND_API.G_MISS_CHAR))
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, 'SYNC', G_Create)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND bill_sequence_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );

   /* Update the component_sequence_id */
   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET COMPONENT_SEQUENCE_ID
                           = (SELECT COMPONENT_SEQUENCE_ID
                             FROM bom_components_b BIC
                             WHERE BIC.bill_sequence_id = BRDI.bill_Sequence_id
                             AND BIC.component_item_id = BRDI.component_item_id
                             AND BIC.operation_seq_num = BRDI.operation_seq_num
                             AND BIC.effectivity_date = BRDI.effectivity_date)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND UPPER(transaction_type) IN (G_Update, G_Delete, 'SYNC', G_Create)
         AND COMPONENT_SEQUENCE_ID IS NULL
         AND bill_sequence_id IS NOT NULL
         AND component_item_id IS NOT NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );


   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET Assembly_Item_Revision_Id  = (SELECT mrb.revision_id
                             FROM  mtl_item_revisions_b mrb
                             WHERE mrb.inventory_item_id = BRDI.Assembly_item_id
                             AND   mrb.organization_id = BRDI.organization_id
                             AND   mrb.revision = BRDI.Assembly_Item_Revision_Code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND UPPER(transaction_type) IN (G_Update, G_Delete, 'SYNC', G_Create)
         AND Assembly_item_id IS NOT NULL
         AND Assembly_Item_Revision_Code IS NOT NULL
         AND Organization_Id IS NOT NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );

    /*Update the transaction_types */
   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET Transaction_Type = G_Update
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND transaction_type = 'SYNC'
         AND COMPONENT_SEQUENCE_ID is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          )
         AND exists (SELECT 'x'
           FROM BOM_REFERENCE_DESIGNATORS BRDI2
           WHERE BRDI2.COMPONENT_SEQUENCE_ID = BRDI.COMPONENT_SEQUENCE_ID
           AND BRDI2.COMPONENT_REFERENCE_DESIGNATOR = BRDI.COMPONENT_REFERENCE_DESIGNATOR
           AND NVL(BRDI2.ACD_TYPE, 1) = NVL(BRDI.ACD_TYPE, 1) );

    /*Update the transaction_types */
   UPDATE BOM_REF_DESGS_INTERFACE BRDI
       SET Transaction_Type = G_Create
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND transaction_type = 'SYNC'
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );

   /*  Assign transaction ids */

       UPDATE BOM_REF_DESGS_INTERFACE BRDI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND
          (
              ( (p_batch_id IS NULL) AND (BRDI.batch_id IS NULL) )
          OR  ( p_batch_id = BRDI.batch_id )
          );


   /*l_return_status := Process_Sub_Comps_Info
                     (org_id,
                      all_org,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      req_id,
                      err_text,
                      p_batch_id);
   IF l_return_status <> 0 THEN
      RETURN l_return_status;
   END IF;
   */

     UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET(bill_sequence_id,  component_item_id, effectivity_date,
         operation_seq_num,  from_end_item_unit_number)
       = (select bill_sequence_id,  component_item_id,
    EFFECTIVITY_DATE, OPERATION_SEQ_NUM,  FROM_END_ITEM_UNIT_NUMBER
           FROM BOM_INVENTORY_COMPONENTS BIC1
           WHERE BIC1.COMPONENT_SEQUENCE_ID = BSCI.component_sequence_id )
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, G_Create)
         AND COMPONENT_SEQUENCE_ID is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
         AND exists (SELECT 'x'
           FROM BOM_INVENTORY_COMPONENTS BIC2
           WHERE BIC2.COMPONENT_SEQUENCE_ID = BSCI.COMPONENT_SEQUENCE_ID );


/* Resolve the Bill sequence ids for updates and deletes */

   UPDATE bom_sub_comps_interface BSCI
       SET(assembly_item_id, organization_id, ALTERNATE_BOM_DESIGNATOR)
       = (SELECT assembly_item_id, organization_id , alternate_bom_designator
           FROM BOM_BILL_OF_MATERIALS BBM1
           WHERE BBM1.bill_sequence_id = BSCI.bill_sequence_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND bill_sequence_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
         AND exists (SELECT 'x'
       FROM BOM_BILL_OF_MATERIALS BBM2
       WHERE BBM2.bill_sequence_id = BSCI.bill_sequence_id);


/* Update Organization Code using Organization_id
this also needed if Organization_id is given and code is not given*/

   UPDATE bom_sub_comps_interface BSCI
       SET organization_code = (SELECT organization_code
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
         AND exists (SELECT 'x'
                       FROM MTL_PARAMETERS mp2
                      WHERE mp2.organization_id = BSCI.organization_id);



 /* Update Organization_ids if organization_code is given org id is null.
  Orgnaization_id information is needed in the next steps */

      UPDATE bom_sub_comps_interface BSCI
         SET organization_id = (SELECT organization_id
                                FROM MTL_PARAMETERS mp1
                                WHERE mp1.organization_code = BSCI.organization_code)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND organization_id is null
         AND organization_code is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );



/* Update Assembly Item name */

   UPDATE bom_sub_comps_interface BSCI
       SET  ASSEMBLY_ITEM_NUMBER  = (SELECT CONCATENATED_SEGMENTS
                                     FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                     WHERE mvl1.inventory_item_id = BSCI.assembly_item_id
                                     AND mvl1.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND assembly_item_id is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items mvl12
                      WHERE mvl12.inventory_item_id = BSCI.assembly_item_id
                      AND mvl12.organization_id = BSCI.organization_id);

   /* Update the Assembly_item_id */
   UPDATE bom_sub_comps_interface BSCI
       SET Assembly_item_id  = (SELECT inventory_item_id
                                FROM  mtl_system_items_kfv mvll
                                WHERE mvll.concatenated_segments = BSCI.Assembly_item_number
                                AND   mvll.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND Assembly_item_number is not null
         AND organization_id is not null
         AND assembly_item_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );

/* Update Component Item name */
   UPDATE bom_sub_comps_interface BSCI
       SET  COMPONENT_ITEM_NUMBER   = (SELECT CONCATENATED_SEGMENTS
                                       FROM MTL_SYSTEM_ITEMS_KFV mvl1
                                       WHERE mvl1.inventory_item_id = BSCI.component_item_id
                                       AND mvl1.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND COMPONENT_ITEM_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items mvl12
                      WHERE mvl12.inventory_item_id = BSCI.component_item_id
                      AND mvl12.organization_id = BSCI.organization_id);


   /* Update the Component_item_id */
   UPDATE bom_sub_comps_interface BSCI
       SET Component_item_id  = (SELECT inventory_item_id
                                 FROM  mtl_system_items_kfv mvll
                                 WHERE mvll.concatenated_segments = BSCI.Component_item_number
                                 AND   mvll.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND Component_item_number is not null
         AND organization_id is not null
         AND component_item_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );

   /* Set the Bill Seqeunce Ids */
   UPDATE bom_sub_comps_interface BSCI
       SET bill_sequence_id  = (SELECT bill_sequence_id
                             FROM  bom_bill_of_materials bom
                             WHERE bom.assembly_item_id = BSCI.assembly_item_id
                             AND   bom.organization_id = BSCI.organization_id
                             AND   NVL(bom.alternate_bom_designator,FND_API.G_MISS_CHAR) = NVL(BSCI.alternate_bom_designator,FND_API.G_MISS_CHAR))
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Delete, G_Update, 'SYNC', G_Create)
         AND assembly_item_id is not null
         AND organization_id is not null
         AND bill_sequence_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );

   /* Update the component_sequence_id */
   UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET COMPONENT_SEQUENCE_ID
                           = (SELECT COMPONENT_SEQUENCE_ID
                             FROM BOM_INVENTORY_COMPONENTS BIC
                             WHERE BIC.bill_sequence_id = BSCI.bill_Sequence_id
                             AND BIC.component_item_id = BSCI.component_item_id
                             AND BIC.operation_seq_num = BSCI.operation_seq_num
                             AND BIC.effectivity_date = BSCI.effectivity_date)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND UPPER(transaction_type) IN (G_Update, G_Delete, 'SYNC', G_Create)
         AND COMPONENT_SEQUENCE_ID IS NULL
         AND bill_sequence_id IS NOT NULL
         AND component_item_id IS NOT NULL
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );


       UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET  SUBSTITUTE_COMP_NUMBER = (SELECT concatenated_segments
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.inventory_item_id = BSCI.SUBSTITUTE_COMPONENT_ID
                             and mvl1.organization_id = BSCI.organization_id)
        WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update,'SYNC')
         AND SUBSTITUTE_COMPONENT_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items mvl12
                      WHERE mvl12.inventory_item_id = BSCI.SUBSTITUTE_COMPONENT_ID
                      AND mvl12.organization_id = BSCI.organization_id);

--Update Sub Comp Number If id is given

       UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET  SUBSTITUTE_COMPONENT_ID = (SELECT inventory_item_id
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.concatenated_segments = BSCI.SUBSTITUTE_COMP_NUMBER
                             and mvl1.organization_id = BSCI.organization_id)
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update,'SYNC')
         AND substitute_comp_number is not null
         AND organization_id is not null
         AND substitute_component_id is null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );

--Update New Sub Comp Number

       UPDATE BOM_SUB_COMPS_INTERFACE BSCI
       SET  NEW_SUB_COMP_NUMBER = (SELECT CONCATENATED_SEGMENTS
                             FROM MTL_SYSTEM_ITEMS_KFV mvl1
                             WHERE mvl1.inventory_item_id = BSCI.NEW_SUB_COMP_ID
                             and mvl1.organization_id = BSCI.organization_id)
       WHERE  (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND upper(transaction_type) in (G_Create, G_Delete, G_Update,'SYNC')
         AND NEW_SUB_COMP_ID is not null
         AND organization_id is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
          AND exists (SELECT 'x'
                      FROM mtl_system_items mvl12
                      WHERE mvl12.inventory_item_id = BSCI.NEW_SUB_COMP_ID
                      and mvl12.organization_id = BSCI.organization_id);




    /*Update the transaction_types */
   UPDATE bom_sub_comps_interface BSCI
       SET Transaction_Type = G_Update
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND transaction_type = 'SYNC'
         AND COMPONENT_SEQUENCE_ID is not null
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          )
         AND exists (SELECT 'x'
           FROM BOM_SUBSTITUTE_COMPONENTS BSCI2
           WHERE BSCI2.COMPONENT_SEQUENCE_ID = BSCI.COMPONENT_SEQUENCE_ID
           AND NVL(BSCI2.ACD_TYPE, 1) = NVL(BSCI.ACD_TYPE, 1) );

    /*Update the transaction_types */
   UPDATE bom_sub_comps_interface BSCI
       SET Transaction_Type = G_Create
       WHERE (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND transaction_type = 'SYNC'
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );

   /*  Assign transaction ids */

       UPDATE bom_sub_comps_interface BSCI
         SET transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Create, G_Update, G_Delete)
         AND (process_flag = 1 or process_flag = 5) --CM Changes for Structure Import
         AND (all_org = 1
             OR
            (all_org = 2 AND organization_id = org_id))
         AND
          (
              ( (p_batch_id IS NULL) AND (BSCI.batch_id IS NULL) )
          OR  ( p_batch_id = BSCI.batch_id )
          );



   l_return_status := Process_Comp_Ops_Info
                     (org_id,
                      all_org,
                      user_id,
                      login_id,
                      prog_appid,
                      prog_id,
                      req_id,
                      err_text,
                      p_batch_id);
   IF l_return_status <> 0 THEN
      RETURN l_return_status;
   END IF;

   RETURN l_return_status;
END;

end Bom_Open_Interface_Utl;

/
