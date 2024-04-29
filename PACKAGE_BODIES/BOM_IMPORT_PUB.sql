--------------------------------------------------------
--  DDL for Package Body BOM_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_IMPORT_PUB" AS
  /* $Header: BOMSIMPB.pls 120.94.12010000.11 2009/09/01 21:42:39 kkonada ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSIMPB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Import_Pub
--
--  NOTES
--
--
--
--  HISTORY
--
-- 04-May-2005    Sreejith Nelloliyil   Initial Creation
--
-- 05-May-2005    Dinu Krishnan         Created hte APIs
--                                      1.RESOLVE_XREFS_FOR_BATCH
--                                      2.Update Match Data
--                                      3.Update Bill Info
--                                      4.Check Component Exist
-- 07-May-2005    Sreejith Nelloliyil   Added Code for data separation
--
BULKLOAD_PVT_PKG.PROCESS_BOM_INTERFACE_LINES
***************************************************************************/
  /* Package Globals */
  pG_batch_options BATCH_OPTIONS;
  pG_ouputFileName      VARCHAR2(30) := 'BOM_IMPORT_PUB';

/****************** Local functions/procedures Section ******************/

FUNCTION Init_Debug RETURN BOOLEAN
IS
  CURSOR c_get_utl_file_dir IS
     SELECT VALUE
      FROM V$PARAMETER
     WHERE NAME = 'utl_file_dir';
  l_debug_file VARCHAR2(80) := pG_ouputFileName||TO_CHAR(SYSDATE,'DDMONYYHH24MISS');

  l_out_dir VARCHAR2(2000);
  l_message_list           Error_Handler.Error_Tbl_Type;
  l_debug_error_status     VARCHAR2(1);
  l_debug_error_mesg       VARCHAR2(2000);

BEGIN
  IF Error_Handler.Get_Debug <> 'Y'
  THEN
    OPEN c_get_utl_file_dir;
    FETCH c_get_utl_file_dir INTO l_out_dir;
    IF c_get_utl_file_dir%FOUND THEN
      ------------------------------------------------------
      -- Trim to get only the first directory in the list --
      ------------------------------------------------------
      IF INSTR(l_out_dir,',') <> 0 THEN
        l_out_dir := SUBSTR(l_out_dir, 1, INSTR(l_out_dir, ',') - 1);
      END IF;
    END IF;
    Error_Handler.Initialize;
    Error_Handler.Set_Debug ('Y');
    Bom_Globals.Set_Debug ('Y');

    Error_Handler.Open_Debug_Session
          (  p_debug_filename    => l_debug_file
           , p_output_dir        => l_out_dir
           , x_return_status     => l_debug_error_status
           , x_error_mesg        => l_debug_error_mesg
          );
  ELSE
    l_debug_error_status := 'S';
  END IF;

  IF l_debug_error_status <> 'S'
  THEN
   RETURN FALSE;
  END IF;

  RETURN TRUE;
END Init_Debug;

FUNCTION Check_Header_Exists
(
 p_parent_id IN NUMBER,
 p_org_id    IN NUMBER,
 p_str_name  IN VARCHAR2
)RETURN NUMBER
IS
l_bill_seq_id NUMBER;
l_item_id     NUMBER;
l_org_id      NUMBER;

CURSOR Get_Bill_Details
IS
  SELECT bill_sequence_id
  FROM bom_structures_b
  WHERE assembly_item_id = p_parent_id
  AND organization_id = p_org_id
  AND nvl(alternate_bom_designator,'Primary') = nvl(p_str_name,'Primary');

BEGIN

  SELECT bill_sequence_id
  INTO l_bill_seq_id
  FROM bom_structures_b
  WHERE assembly_item_id = p_parent_id
  AND organization_id = p_org_id
  AND nvl(alternate_bom_designator,'Primary') = nvl(p_str_name,'Primary');

  RETURN l_bill_seq_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN null;

END Check_Header_Exists;

/**
 * This API will process the reference designators for an All
 * Components Batch.It will compare the reference designators in the
 * interface structure and those in target PIMDH structure and disable those
 * reference designators that are not mentioned in the batch.
 */
PROCEDURE Disable_Refds
(
   p_batch_id IN NUMBER
 , p_comp_seq_id IN NUMBER
 , p_comp_id     IN NUMBER
 , p_parent_id   IN NUMBER
 , p_eff_date    IN DATE
 , p_op_seq_num  IN NUMBER
 , p_org_id      IN NUMBER
)
IS
CURSOR Get_Src_RefDs
IS
SELECT *
FROM bom_ref_desgs_interface
WHERE batch_id = p_batch_id
AND (component_sequence_id = p_comp_seq_id
     OR (component_item_id = p_comp_id
         AND organization_id = p_org_id
         AND assembly_item_id = p_parent_id
         AND nvl(effectivity_date,sysdate) = nvl(p_eff_date,sysdate)
         AND nvl(operation_seq_num,1) = nvl(p_op_seq_num,1)
         )
    )
ORDER BY component_reference_designator;

CURSOR Get_PIMDH_RefDs
IS
SELECT *
FROM bom_reference_designators
WHERE  component_sequence_id = p_comp_seq_id
ORDER BY component_reference_designator;

TYPE ref_intf_type IS TABLE OF bom_ref_desgs_interface%ROWTYPE;
TYPE ref_pimdh_type IS TABLE OF bom_reference_designators%ROWTYPE;

l_src_refds ref_intf_type;
l_pimdh_refds ref_pimdh_type;
l_src_count NUMBER;
l_pimdh_count NUMBER;
l_delete BOOLEAN;

BEGIN


OPEN Get_PIMDH_RefDs;
FETCH Get_PIMDH_RefDs BULK COLLECT INTO l_pimdh_refds;
CLOSE Get_PIMDH_RefDs;



 OPEN Get_Src_RefDs;
 FETCH Get_Src_RefDs BULK COLLECT INTO l_src_refds;
 CLOSE Get_Src_RefDs;

 l_src_count := l_src_refds.COUNT;
 l_pimdh_count := l_pimdh_refds.COUNT;


 IF l_src_count >=  l_pimdh_count  THEN
    FOR i in 1..l_src_count LOOP
     FOR j in 1..l_pimdh_count LOOP
      IF l_pimdh_refds(j).component_reference_designator = l_src_refds(i).component_reference_designator THEN
        l_pimdh_refds(j).attribute1 := 'Y';
      END IF;
     END LOOP; -- pimdh loop
    END LOOP; -- src loop
    FOR i in 1..l_pimdh_count LOOP
      IF nvl(l_pimdh_refds(i).attribute1,'N') <> 'Y' THEN
        INSERT INTO bom_ref_desgs_interface
         (
          COMPONENT_REFERENCE_DESIGNATOR,
          REF_DESIGNATOR_COMMENT,
          CHANGE_NOTICE,
          COMPONENT_SEQUENCE_ID,
          batch_id,
          transaction_type,
          process_flag,
          component_item_id,
          assembly_item_id,
          organization_id
         )
         VALUES
         (
          l_pimdh_refds(i).component_reference_designator,
          l_pimdh_refds(i).REF_DESIGNATOR_COMMENT,
          l_pimdh_refds(i).CHANGE_NOTICE,
          l_pimdh_refds(i).component_sequence_id,
          p_batch_id,
          'DELETE',
          1,
          p_comp_id,
          p_parent_id,
          p_org_id
         );
      END IF;
    END LOOP;
 ELSE

    FOR i in 1..l_pimdh_count LOOP
     l_delete := true;
     FOR j in 1..l_src_count LOOP
      IF l_src_refds(j).component_reference_designator = l_pimdh_refds(i).component_reference_designator THEN
        l_delete := false;
      END IF;
     END LOOP; -- pimdh loop
     IF l_delete THEN
       INSERT INTO bom_ref_desgs_interface
       (
          COMPONENT_REFERENCE_DESIGNATOR,
          REF_DESIGNATOR_COMMENT,
          CHANGE_NOTICE,
          COMPONENT_SEQUENCE_ID,
          batch_id,
          transaction_type,
          process_flag,
          component_item_id,
          assembly_item_id,
          organization_id
       )
       VALUES
        (
          l_pimdh_refds(i).component_reference_designator,
          l_pimdh_refds(i).REF_DESIGNATOR_COMMENT,
          l_pimdh_refds(i).CHANGE_NOTICE,
          l_pimdh_refds(i).component_sequence_id,
          p_batch_id,
          'DELETE',
          1,
          p_comp_id,
          p_parent_id,
          p_org_id
         );
     END IF;
    END LOOP; -- src loop
 END IF; --src_count > pimdh_count

END Disable_Refds;


FUNCTION Header_Not_In_Intf
(
 p_bill_seq_id IN NUMBER,
 p_item_id     IN NUMBER,
 p_org_id      IN NUMBER,
 p_str_name    IN VARCHAR2,
 p_batch_id  IN NUMBER,
 p_request_id IN NUMBER,
 p_bundle_id IN NUMBER
)RETURN BOOLEAN
IS
l_temp VARCHAR2(250);
BEGIN

   SELECT item_number
   INTO l_temp
   FROM bom_bill_of_mtls_interface BBMI,mtl_system_items_vl MSIVL,mtl_parameters MP,bom_structures_b BSB
   WHERE BBMI.batch_id = p_batch_id
   AND BSB.bill_sequence_id = p_bill_seq_id
   AND (BBMI.process_flag = 1 OR BBMI.process_flag = 5 )
   AND (( BBMI.request_id IS NOT NULL AND BBMI.request_id = p_request_id ) OR (BBMI.bundle_id IS NOT NULL AND BBMI.bundle_id = p_bundle_id))
   AND ( BBMI.bill_sequence_id = p_bill_seq_id OR
         ( (BBMI.assembly_item_id = p_item_id OR BBMI.item_number = MSIVL.concatenated_segments OR BBMI.source_system_reference =  MSIVL.concatenated_segments )
            AND (BBMI.organization_id = p_org_id OR BBMI.organization_code = MP.organization_code)
            AND NVL(BBMI.alternate_bom_designator,'Primary') = NVL(p_str_name,'Primary')
         )
       )
   AND MSIVL.inventory_item_id = p_item_id
   AND MSIVl.organization_id = p_org_id
   AND MP.organization_id = p_org_id;

   IF l_temp IS NOT NULL THEN
    RETURN true;
   END IF;

   EXCEPTION WHEN NO_DATA_FOUND THEN
   RETURN FALSE;

END Header_Not_In_Intf;

Procedure write_debug
(
  p_message in VARCHAR2
)
IS
  l_debug BOOLEAN := Init_Debug();
BEGIN
  IF l_debug = true THEN
  Error_Handler.write_debug(p_message);
  END IF;
END;

--Update any rows with null transactionids with proper sequence
--Only updates the rows with null txn ids and processflag 1
Procedure update_transaction_ids
(
  p_batch_id IN NUMBER
)
is
BEGIN
  update
    BOM_BILL_OF_MTLS_INTERFACE
  set
    transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
  where
        transaction_id is null
    and batch_id = p_batch_id
    and process_flag = 1;

  update
    BOM_INVENTORY_COMPS_INTERFACE
  set
    transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
  where
        transaction_id is null
    and batch_id = p_batch_id
    and process_flag = 1;

  update
    BOM_SUB_COMPS_INTERFACE
  set
    transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
  where
        transaction_id is null
    and batch_id = p_batch_id
    and process_flag = 1;

  update
    BOM_REF_DESGS_INTERFACE
  set
    transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
  where
        transaction_id is null
    and batch_id = p_batch_id
    and process_flag = 1;
END update_transaction_ids;

--remove this
FUNCTION Does_Batch_Exist
(
  p_batch_id    IN NUMBER
)
RETURN BOOLEAN
IS
  l_dummy VARCHAR2(20);
BEGIN
  IF p_batch_id IS NOT NULL
  THEN
    BEGIN
      SELECT 'Exist'
      INTO l_dummy
      FROM EGO_IMPORT_BATCHES_B
      WHERE batch_id = p_batch_id
      AND batch_type = 'BOM_STRUCTURE';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
    END;
  END IF;
  RETURN TRUE;
END Does_Batch_Exist;
--remove this

/* Setting the Rows for Enabling Change Management APIs to Pickup
 */
PROCEDURE Process_Batch_Options
    (p_batch_id IN NUMBER)
IS
BEGIN
  --Update Structure Name:Start
  IF (pg_batch_options.structure_name IS NOT NULL
     AND pg_batch_options.structure_name <> bom_globals.get_primary_ui)
  THEN
    UPDATE bom_bill_of_mtls_interface
    SET   alternate_bom_designator = pg_batch_options.structure_name
    WHERE batch_id = p_batch_id
    AND (process_flag = 1 OR process_flag = 5);
    -- AND alternate_bom_designator IS NOT NULL;

    UPDATE bom_inventory_comps_interface
    SET   alternate_bom_designator = pg_batch_options.structure_name
    WHERE batch_id = p_batch_id
    AND  ( process_flag = 1 OR process_flag = 5);
    -- AND alternate_bom_designator IS NOT NULL;
  END IF;
  --Update Structure Name:End

  IF pg_batch_options.structure_type_id IS NOT NULL
  THEN
  UPDATE bom_bill_of_mtls_interface
  SET structure_type_id = pg_batch_options.structure_type_id
  WHERE batch_id = p_batch_id
  AND (process_flag = 1 OR process_flag = 5)
  AND structure_type_id IS NULL;

   UPDATE bom_bill_of_mtls_interface
   SET structure_type_name = (SELECT STV1.structure_type_name
                              FROM bom_structure_types_vl STV1 where
                              STV1.structure_type_id = pg_batch_options.structure_type_id)
  WHERE batch_id = p_batch_id
  AND structure_type_name IS NULL
  AND (process_flag = 1 OR process_flag = 5)
  AND exists (select STV2.structure_type_name from bom_structure_types_vl STV2
  WHERE STV2.structure_type_id = pg_batch_options.structure_type_id);

  END IF;


  --Update Effectivity Details:Start
  IF ( pg_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 1 ) THEN
    UPDATE
      bom_bill_of_mtls_interface
    SET
      EFFECTIVITY_CONTROL = 1
    WHERE
      batch_id = p_batch_id
      AND (process_flag = 1 OR process_flag = 5)
      AND EFFECTIVITY_CONTROL is NULL;

    IF (pg_batch_options.EFFECTIVITY_DATE IS NOT NULL) THEN
      UPDATE
        bom_inventory_comps_interface
      SET
        EFFECTIVITY_DATE = pg_batch_options.EFFECTIVITY_DATE
      WHERE
            EFFECTIVITY_DATE IS NULL
       AND  BATCH_ID = P_BATCH_ID
       AND  EFFECTIVITY_DATE IS NULL
       AND  (PROCESS_FLAG = 1 OR PROCESS_FLAG =5); --Check New effectivity date
    END IF;
  ELSIF (pg_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 2) THEN
    UPDATE
      bom_bill_of_mtls_interface
    SET
      EFFECTIVITY_CONTROL = 2
    WHERE
        batch_id = p_batch_id
    AND (process_flag = 1 OR process_flag = 5)
    AND EFFECTIVITY_CONTROL is NULL;
    IF (pg_batch_options.FROM_END_ITEM_UNIT_NUMBER IS NOT NULL) THEN
      UPDATE
        bom_inventory_comps_interface
      SET
        FROM_END_ITEM_UNIT_NUMBER = pg_batch_options.FROM_END_ITEM_UNIT_NUMBER
      WHERE
            FROM_END_ITEM_UNIT_NUMBER IS NULL
       AND  BATCH_ID = P_BATCH_ID
       AND  FROM_END_ITEM_UNIT_NUMBER IS NULL
       AND  (PROCESS_FLAG = 1 OR PROCESS_FLAG =5); --Check New effectivity date
    END IF;
  END IF;
  --Update Effectivity Details:End
END Process_Batch_Options;



/* Start: Retrieve_Batch_Options Proecudre to retrieve batch option from EGO
 * tables and store in pG_batch_options Global Variable.  This checks whether
 * the value isalready filled in prior to executing the query
 */
  /*PROCEDURE Retrieve_Batch_Options
  (p_batch_id in number,
   x_error_message OUT NOCOPY varchar2,
   x_error_code OUT NOCOPY number)*/

PROCEDURE Retrieve_Batch_Options
  ( p_batch_id          IN NUMBER,
    x_Mesg_Token_Tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type,
    x_error_code        IN OUT NOCOPY VARCHAR2)
IS
  l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
  l_Token_Tbl         Error_Handler.Token_Tbl_Type;
  CURSOR batch_options_cr IS
  SELECT
    b.SOURCE_SYSTEM_ID,
    b.BATCH_TYPE,
    b.ASSIGNEE,
    b.BATCH_STATUS,
    o.MATCH_ON_DATA_LOAD,
    o.IMPORT_ON_DATA_LOAD,
    nvl(o.IMPORT_XREF_ONLY,'N'),
    o.STRUCTURE_TYPE_ID,
    o.STRUCTURE_NAME,
    o.STRUCTURE_EFFECTIVITY_TYPE,
    o.EFFECTIVITY_DATE,
    o.FROM_END_ITEM_UNIT_NUMBER,
    o.STRUCTURE_CONTENT,
    o.CHANGE_NOTICE,
    NVL(o.CHANGE_ORDER_CREATION, 'I'), --I, ignore change,
    DECODE(NVL(b.SOURCE_SYSTEM_ID,0), G_PDH_SRCSYS_ID, 'Y', 'N'),
    o.add_all_to_change_flag
  FROM
    EGO_IMPORT_BATCHES_B b, ego_import_option_sets o
  WHERE
        b.BATCH_ID = o.BATCH_ID
  AND   b.BATCH_ID = p_batch_id;
BEGIN
  IF (pg_batch_options.SOURCE_SYSTEM_ID IS NULL)
  THEN
    OPEN batch_options_cr;
    FETCH batch_options_cr INTO pG_batch_options;
    IF batch_options_cr%ROWCOUNT = 0
    THEN
      SELECT
      G_PDH_SRCSYS_ID,
      'BOM_STRUCTURE',
      null,
      'A',
      null,
      'Y',
      'N',
      103,
      'PIM_PBOM_S',
      1,
      null,
      null,
      'C',
      null,
      'I', --I, ignore change,
      'Y',
      null
     INTO
      pg_batch_options
    FROM
      dual;
      /*
      l_Token_Tbl(1).token_name := 'BATCH_ID';
      l_Token_Tbl(1).token_value := p_batch_id;
      Error_Handler.Add_Error_Token
      (
          p_message_name => 'BOM_SOURCE_SYSTEM_INVALID'
        , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
        , p_Token_Tbl          => l_Token_Tbl
      );
      x_error_code := 'E';
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
     */

    END IF;
    CLOSE batch_options_cr;
  END IF;
  x_error_code := 'S';
EXCEPTION
  WHEN OTHERS THEN
    l_Token_Tbl(1).token_name := 'BATCH_ID';
    l_Token_Tbl(1).token_value := p_batch_id;
    Error_Handler.Add_Error_Token
    (
      p_message_name => 'BOM_SOURCE_SYSTEM_INVALID'
    , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
    , p_Token_Tbl          => l_Token_Tbl
    );
    x_error_code := 'E';
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
END Retrieve_Batch_Options;
/* End: Retrieve_Batch_Options Proecudre */

FUNCTION CHECK_COMP_EXIST(
      p_bill_seq_id IN NUMBER
    , p_effec_control IN NUMBER
    , p_batch_id IN NUMBER
    , p_comp_rec_id IN VARCHAR2
    , p_component_item_id IN NUMBER
    , p_organization_id IN NUMBER
    , p_parent_item_id IN NUMBER
    )
RETURN NUMBER
IS
  l_comp_seq_id  NUMBER := 0;
  TYPE comp_rec_type IS REF CURSOR;
  l_src_attrs comp_rec_type;
  l_comp_id NUMBER;
  l_op_seq_num NUMBER;
  l_effec_date DATE;
  l_from_unit_number VARCHAR2(100);
BEGIN
  IF p_effec_control = 1
  THEN
    /*OPEN l_src_attrs FOR
    SELECT
      component_item_id,
      new_operation_seq_num,
      new_effectivity_date
    FROM
      bom_inventory_comps_interface
    WHERE
      batch_id = p_batch_id AND comp_source_system_reference = p_comp_rec_id;*
    FETCH l_src_attrs INTO l_comp_id,l_op_seq_num,l_effec_date;
    CLOSE l_src_attrs;*/
    BEGIN

      SELECT  BCB.component_sequence_id
      INTO   l_comp_seq_id
      FROM   bom_components_b BCB,bom_inventory_comps_interface BICI
      WHERE  BICI.batch_id = p_batch_id
      AND   (BICI.comp_source_system_reference = p_comp_rec_id OR BICI.component_item_number = p_comp_rec_id)
      AND    (BICI.process_flag = 1 or BICI.process_flag = 5 )
      AND    BCB.bill_sequence_id = p_bill_seq_id
      AND    BCB.component_item_id = p_component_item_id
      AND    BCB.operation_seq_num = nvl(BICI.new_operation_seq_num,BICI.operation_seq_num)
      AND    BCB.effectivity_date = nvl(BICI.new_effectivity_date,BICI.effectivity_date)
      AND    (( pg_batch_options.CHANGE_NOTICE IS NULL AND BCB.implementation_date IS NOT NULL)
             OR(pg_batch_options.CHANGE_NOTICE IS NOT NULL AND BCB.implementation_date IS NULL AND BCB.change_notice = pg_batch_options.CHANGE_NOTICE));


    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      NULL;
    END;
    ELSIF p_effec_control = 2 THEN
      /*OPEN l_src_attrs FOR SELECT component_item_id,operation_seq_num,from_end_item_unit_number
      FROM bom_inventory_comps_interface
      WHERE batch_id = p_batch_id AND comp_source_system_reference = p_comp_rec_id;
      FETCH l_src_attrs INTO l_comp_id,l_op_seq_num,l_from_unit_number;
      CLOSE l_src_attrs;*/
      BEGIN
        SELECT  BCB.component_sequence_id
        INTO   l_comp_seq_id
        FROM   bom_components_b BCB,bom_inventory_comps_interface BICI
        WHERE  BICI.batch_id = p_batch_id
        AND   (BICI.comp_source_system_reference = p_comp_rec_id OR BICI.component_item_number = p_comp_rec_id)
        AND    (BICI.process_flag = 1 or BICI.process_flag = 5 )
        AND    BCB.bill_sequence_id = p_bill_seq_id
        AND    BCB.component_item_id = p_component_item_id
        AND    BCB.operation_seq_num = nvl(BICI.new_operation_seq_num,BICI.operation_seq_num)
        AND    BCB.from_end_item_unit_number = nvl(BICI.new_from_end_item_unit_number,BICI.from_end_item_unit_number)
        AND    (( pg_batch_options.CHANGE_NOTICE IS NULL AND BCB.implementation_date IS NOT NULL)
             OR(pg_batch_options.CHANGE_NOTICE IS NOT NULL AND BCB.implementation_date IS NULL AND BCB.change_notice = pg_batch_options.CHANGE_NOTICE));

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
      END;
    ELSIF p_effec_control = 4 THEN
      BEGIN
        SELECT  BCB.component_sequence_id
        INTO   l_comp_seq_id
        FROM   bom_components_b BCB,bom_inventory_comps_interface BICI,Mtl_Item_Revisions MIR
        WHERE  BICI.batch_id = p_batch_id
        AND   (BICI.comp_source_system_reference = p_comp_rec_id OR BICI.component_item_number = p_comp_rec_id)
        AND    (BICI.process_flag = 1 or BICI.process_flag = 5 )
        AND    BCB.bill_sequence_id = p_bill_seq_id
        AND    BCB.component_item_id = p_component_item_id
        AND    nvl(BCB.operation_seq_num,1) = nvl(BICI.new_operation_seq_num,1)
        AND    MIR.inventory_item_id = p_parent_item_id
        AND    MIR.organization_id = p_organization_id
        AND    MIR.revision = BICI.from_end_item_rev_code
        AND    BCB.from_end_item_rev_id = MIR.Revision_Id
        AND    (( pg_batch_options.CHANGE_NOTICE IS NULL AND BCB.implementation_date IS NOT NULL)
             OR(pg_batch_options.CHANGE_NOTICE IS NOT NULL AND BCB.implementation_date IS NULL AND BCB.change_notice = pg_batch_options.CHANGE_NOTICE));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
      END;
  END IF;
  RETURN l_comp_seq_id;
END CHECK_COMP_EXIST;

/*Created this function for bugfix:8334380 */
FUNCTION NEW_CHECK_COMP_EXIST(
         p_bill_seq_id IN NUMBER
       , p_effec_control IN NUMBER
       , p_batch_id IN NUMBER
       , p_comp_rec_id IN VARCHAR2
       , p_component_item_id IN NUMBER
       , p_organization_id IN NUMBER
       , p_parent_item_id IN NUMBER
       )
   RETURN NUMBER
   IS
     l_comp_seq_id  NUMBER := 0;
     TYPE comp_rec_type IS REF CURSOR;
     l_src_attrs comp_rec_type;
     l_comp_id NUMBER;
     l_op_seq_num NUMBER;
     l_effec_date DATE;
     l_from_unit_number VARCHAR2(100);
   BEGIN
     IF p_effec_control = 1
     THEN
       BEGIN
         SELECT  BCB.component_sequence_id
         INTO   l_comp_seq_id
         FROM   bom_components_b BCB,bom_inventory_comps_interface BICI
         WHERE  BICI.batch_id = p_batch_id
         AND   (BICI.comp_source_system_reference = p_comp_rec_id OR BICI.component_item_number = p_comp_rec_id)
         AND    (BICI.process_flag = 1 or BICI.process_flag = 5 )
         AND    BCB.bill_sequence_id = p_bill_seq_id
         AND    BCB.component_item_id = p_component_item_id
         AND    (BICI.new_operation_seq_num IS NULL OR BCB.operation_seq_num = BICI.new_operation_seq_num)
         AND    (BICI.new_effectivity_date IS NULL OR BCB.effectivity_date = BICI.new_effectivity_date)
         AND    (( pg_batch_options.CHANGE_NOTICE IS NULL AND BCB.implementation_date IS NOT NULL)
                OR(pg_batch_options.CHANGE_NOTICE IS NOT NULL AND BCB.implementation_date IS NULL AND BCB.change_notice = pg_batch_options.CHANGE_NOTICE));

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
         NULL;
       END;
     ELSIF p_effec_control = 2 THEN
         BEGIN
           SELECT  BCB.component_sequence_id
           INTO   l_comp_seq_id
           FROM   bom_components_b BCB,bom_inventory_comps_interface BICI
           WHERE  BICI.batch_id = p_batch_id
           AND   (BICI.comp_source_system_reference = p_comp_rec_id OR BICI.component_item_number = p_comp_rec_id)
           AND    (BICI.process_flag = 1 or BICI.process_flag = 5 )
           AND    BCB.bill_sequence_id = p_bill_seq_id
           AND    BCB.component_item_id = p_component_item_id
           AND    (BICI.new_operation_seq_num IS NULL OR BCB.operation_seq_num = BICI.new_operation_seq_num)
           AND    (BICI.new_from_end_item_unit_number IS NULL OR BCB.from_end_item_unit_number = BICI.new_from_end_item_unit_number)
           AND    (( pg_batch_options.CHANGE_NOTICE IS NULL AND BCB.implementation_date IS NOT NULL)
                OR(pg_batch_options.CHANGE_NOTICE IS NOT NULL AND BCB.implementation_date IS NULL AND BCB.change_notice = pg_batch_options.CHANGE_NOTICE));

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
           NULL;
         END;
     ELSIF p_effec_control = 4 THEN
         BEGIN
           SELECT  BCB.component_sequence_id
           INTO   l_comp_seq_id
           FROM   bom_components_b BCB,bom_inventory_comps_interface BICI,Mtl_Item_Revisions MIR
           WHERE  BICI.batch_id = p_batch_id
           AND   (BICI.comp_source_system_reference = p_comp_rec_id OR BICI.component_item_number = p_comp_rec_id)
           AND    (BICI.process_flag = 1 or BICI.process_flag = 5 )
           AND    BCB.bill_sequence_id = p_bill_seq_id
           AND    BCB.component_item_id = p_component_item_id
           AND    nvl(BCB.operation_seq_num,1) = nvl(BICI.new_operation_seq_num,1)
           AND    MIR.inventory_item_id = p_parent_item_id
           AND    MIR.organization_id = p_organization_id
           AND    MIR.revision = BICI.from_end_item_rev_code
           AND    BCB.from_end_item_rev_id = MIR.Revision_Id
           AND    (( pg_batch_options.CHANGE_NOTICE IS NULL AND BCB.implementation_date IS NOT NULL)
                OR(pg_batch_options.CHANGE_NOTICE IS NOT NULL AND BCB.implementation_date IS NULL AND BCB.change_notice = pg_batch_options.CHANGE_NOTICE));
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
           NULL;
         END;
     END IF;
     RETURN l_comp_seq_id;
END NEW_CHECK_COMP_EXIST;

FUNCTION Item_Exist_In_Mtl_Intf
(
    p_ss_reference IN VARCHAR2
  , p_batch_id     IN NUMBER
  , p_org_code     IN VARCHAR2
  , p_item_number  IN VARCHAR2
  , p_ss_desc      IN VARCHAR2
  , p_item_desc    IN VARCHAR2
  , p_org_id       IN NUMBER
)
RETURN BOOLEAN
IS
  l_dummy VARCHAR2(20);
BEGIN
  SELECT
    'Exist'
  INTO
    l_dummy
  FROM
    mtl_system_items_interface MSII
 WHERE
          MSII.set_process_id = p_batch_id
    AND  (  (MSII.source_system_reference = p_ss_reference AND  MSII.source_system_reference_desc = p_ss_desc )
          OR(MSII.item_number = p_item_number AND MSII.description = p_item_desc)
         )
    AND (MSII.organization_code = p_org_code OR MSII.organization_id = p_org_id)
    AND process_flag = 1;

  IF l_dummy IS NOT NULL
  THEN
    RETURN TRUE;
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END Item_Exist_In_Mtl_Intf;

/****************** Local Procedures Section Ends ******************/
/*
 * The  Method that willl be invoked by JCP
 */

PROCEDURE Process_Structure_Data
(
  p_batch_id              IN         NUMBER
)
IS
  l_errbuff VARCHAR2(3000);
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_retCode VARCHAR2(1);
BEGIN
  Retrieve_Batch_Options(p_batch_id => p_batch_id,
                         x_Mesg_Token_Tbl => l_Mesg_Token_Tbl,
                         x_error_code => l_retcode);

  Process_Batch_Options(p_batch_id => p_batch_id);
  Process_CM_Options(p_batch_id => p_batch_id);
  /*
   * As this API is called from BOMJCP we need to explicitly commit the data.
   */
  commit;
END Process_Structure_Data;

/*
 * The Main Method that willl be invoked by all external programs
 */
PROCEDURE Process_Structure_Data
( p_batch_id              IN         NUMBER,
  p_resultfmt_usage_id    IN         NUMBER,
  p_user_id               IN         NUMBER,
  p_conc_request_id       IN         NUMBER,
  p_language_code         IN         VARCHAR2,
  p_start_upload          IN         VARCHAR2,
  x_errbuff               IN OUT NOCOPY VARCHAR2,
  x_retcode               IN OUT NOCOPY VARCHAR2
)
IS
l_ret_code VARCHAR2(2);
l_err_buff VARCHAR2(1000);
l_message_list           Error_Handler.Error_Tbl_Type;
l_request_id NUMBER := 0;
l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type;
l_from_jcp VARCHAR2(1) := 'N';
l_start_upload VARCHAR(1) :=  p_start_upload;
G_EXC_SEV_QUIT_OBJECT EXCEPTION;
BEGIN
  -- We will call the xisting EGO_BOM_BULKLOAD_PVT_PKG for
  -- data separation.  As an initial test we are passing
  -- concurrent request id as not NULL to invoke the jcp
  --logMessage_forsnell('Called Method process_structure_data with flag '|| p_start_upload);
  write_debug('Retrieving the batch options');
  Write_Debug('Procedure is being called from EGO p_start_upload' || p_start_upload);

  update_transaction_ids(p_batch_id);

  Retrieve_Batch_Options
    (
      p_batch_id => p_batch_id
    , x_Mesg_Token_Tbl => l_mesg_token_tbl
    , x_error_code => l_ret_code
    );

  --logMessage_forsnell('done doing batch options' || 459);

  IF l_ret_code <> 'S' THEN
   RAISE G_EXC_SEV_QUIT_OBJECT;
  END IF;

  --J represents from JCP to avoid cyclic calls
  IF (p_start_upload = 'J')
  THEN
    l_from_jcp := 'Y';
    IF (pG_batch_options.IMPORT_ON_DATA_LOAD = 'Y')
    THEN
      l_start_upload := 'T';
    END IF;
  END IF;

  --logMessage_forsnell('reaching the process structure data call pG_batch_options.SOURCE_SYSTEM_ID' || pG_batch_options.SOURCE_SYSTEM_ID);

  /* only if rfusageid is not null, we should do data separation */
  IF  p_resultfmt_usage_id IS NOT NULL
  THEN
    BOM_BULKLOAD_PVT_PKG.PROCESS_BOM_INTERFACE_LINES
    (
     p_batch_id              => p_batch_id,
     p_resultfmt_usage_id    => p_resultfmt_usage_id,
     p_user_id               => p_user_id,
     p_conc_request_id       => p_conc_request_id  ,
     p_language_code         => p_language_code,
     p_is_pdh_batch          => pG_batch_options.PDH_BATCH,
     x_errbuff               => l_err_buff,
     x_retcode               => l_ret_code
    );
  END IF;

  -- Update Matched Items

  Write_Debug('Updating match data');

  UPDATE_MATCH_DATA
   (
    p_batch_id => p_batch_id,
    p_source_system_id => NULL,
    x_Mesg_Token_Tbl => l_mesg_token_tbl,
    x_Return_Status => x_retcode
   );
   IF (x_retcode = 'E') THEN
    RAISE G_EXC_SEV_QUIT_OBJECT;
   END IF;

  --logMessage_forsnell(' Done with Separation' || pG_batch_options.PDH_BATCH);
  Write_Debug('pG_batch_options.STRUCTURE_CONTENT--' || pG_batch_options.STRUCTURE_CONTENT);

  IF NVL(pG_batch_options.STRUCTURE_CONTENT,'C') <> 'C' AND l_start_upload = 'T'
  THEN
     Write_Debug('CAlling the process_All_Comps_batch');
     PROCESS_ALL_COMPS_BATCH
     (
        p_batch_id => p_batch_id
      , x_Mesg_Token_Tbl =>  l_Mesg_Token_Tbl
      , x_Return_Status   => x_retcode
     );
     Write_Debug('After calling process_all_comp--return_code--' || x_retcode);
  END IF;

  Write_Debug('Merging the duplicate Rows');
   Merge_Duplicate_Rows
   (
    p_batch_id => p_batch_id,
    x_Error_Mesg => x_errbuff,
    x_Ret_Status => x_retcode
    );

   Write_Debug('After Merging rows ret_sts = ' || x_retcode);

  IF (pG_batch_options.PDH_BATCH = 'Y') THEN
    write_debug('Inside PDH');
    Process_Batch_Options(p_batch_id => p_batch_id);
    write_debug(' Done with Process_Batch_Options l_start_upload ' || l_start_upload || 'l_from_jcp ' || l_from_jcp);

    IF (l_start_upload = 'T' AND l_from_jcp = 'N') THEN
      write_debug('ready to lanuch jcp with p_batch_id ' || p_batch_id || ' and request id ' || l_request_id);
      l_request_id := Fnd_Request.Submit_Request(
                      application => G_APP_SHORT_NAME,
                      program     => 'BOMJCP',
                      sub_request => FALSE,
                      argument1   => p_conc_request_id,
                      argument2   => p_batch_id);
      write_debug('the new request id ' ||  l_request_id);
    END IF;
  ELSE --If not PDH Batch
    write_debug(' Reaching IMPORT_STRUCTURE_DATA for NON-PDH ');
    IF (l_start_upload = 'T' and pG_batch_options.IMPORT_XREF_ONLY = 'Y') THEN
      write_debug('The Process Returned because of Cross References Only');
      return;
    END IF;

    write_debug(' Reaching IMPORT_STRUCTURE_DATA ');
    IMPORT_STRUCTURE_DATA
    (
        p_batch_id              => p_batch_id
      , p_items_import_complete => l_start_upload
      , p_callFromJCP           => l_from_jcp
      , p_request_id            => p_conc_request_id
      , x_error_message         => l_err_buff
      , x_return_code           => l_ret_code
    );
  END IF;

  x_retcode := l_ret_code;
  x_errbuff := l_err_buff;
EXCEPTION
  WHEN G_EXC_SEV_QUIT_OBJECT THEN
    write_debug('Exception Occured');
    x_retcode := 'E';
    Error_Handler.Get_Message_List( x_message_list => l_message_list);
END Process_Structure_Data;

/****************** Resolve Cross References **************************
 * Procedure : RESOLVE_XREFS_FOR_BATCH
 * Purpose   : This procedure will  update the Bom Structure and Components
 *             Interface tables with the cross reference data obtained from
 *             Mtl_Cross_References.This API will update the Cross Referenced data
 *             for record in a batch which have matching entries in
 *             Mtl_Cross_References table.
 *             ??This should also insert customer xrefed rows
 *             Will return with success for Xreferences only
 **********************************************************************/

PROCEDURE  RESOLVE_XREFS_FOR_BATCH
(
   p_batch_id   IN NUMBER
  ,x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  ,x_Return_Status      IN OUT NOCOPY VARCHAR2
)
IS
  l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
  l_Token_Tbl             Error_Handler.Token_Tbl_Type;
  l_err_text              VARCHAR2(1000);

  TYPE num_type IS TABLE OF NUMBER;
  TYPE var_type IS TABLE OF VARCHAR2(1000);

  l_item_id_table num_type;
  l_org_id_table num_type;
  l_ss_record_table var_type;
  l_count         NUMBER;
  l_item_num_table var_type;

  CURSOR  Process_Header(l_batch_id IN NUMBER)
  IS
  SELECT  MCR.inventory_item_id,MCR.organization_id,BBMI.source_system_reference,MSI.segment1
  FROM  bom_bill_of_mtls_interface BBMI,mtl_cross_references MCR,ego_import_batches_b EIBB,mtl_system_items MSI
  WHERE BBMI.batch_id = l_batch_id
  AND EIBB.batch_id = BBMI.batch_id
  AND MCR.source_system_id = EIBB.source_system_id
  AND MCR.cross_reference = BBMI.source_system_reference
  AND MCR.cross_reference_type = 'SS_ITEM_XREF'
  AND MSI.inventory_item_id = MCR.inventory_item_id
  AND MSI.organization_id = MCR.organization_id
  AND BBMI.assembly_item_id IS NULL
  AND (BBMI.process_flag = 1 OR BBMI.process_flag = 5);

  CURSOR Process_Comp(l_batch_id IN NUMBER)
  IS
  SELECT  MCR.inventory_item_id,MCR.organization_id,BICI.comp_source_system_reference,MSI.segment1
  FROM  bom_inventory_comps_interface BICI,mtl_cross_references MCR,ego_import_batches_b EIBB,mtl_system_items MSI
  WHERE BICI.batch_id = l_batch_id
  AND EIBB.batch_id = BICI.batch_id
  AND MCR.source_system_id = EIBB.source_system_id
  AND MCR.cross_reference = BICI.comp_source_system_reference
  AND MCR.cross_reference_type = 'SS_ITEM_XREF'
  AND MSI.inventory_item_id = MCR.inventory_item_id
  AND MSI.organization_id = MCR.organization_id
  AND BICI.component_item_id IS NULL
  AND (BICI.process_flag = 1 OR BICI.process_flag = 5);

  CURSOR Process_Header_For_Comp
  IS
  SELECT  MCR.inventory_item_id,MCR.organization_id,BICI.comp_source_system_reference,MSI.segment1
  FROM  bom_inventory_comps_interface BICI,mtl_cross_references MCR,ego_import_batches_b EIBB,mtl_system_items MSI
  WHERE BICI.batch_id = p_batch_id
  AND EIBB.batch_id = BICI.batch_id
  AND MCR.source_system_id = EIBB.source_system_id
  AND MCR.cross_reference = BICI.parent_source_system_reference
  AND MCR.cross_reference_type = 'SS_ITEM_XREF'
  AND MSI.inventory_item_id = MCR.inventory_item_id
  AND MSI.organization_id = MCR.organization_id
  AND BICI.assembly_item_id IS NULL
  AND (BICI.process_flag = 1 OR BICI.process_flag = 5);

BEGIN

  write_debug('In Resolve Xrefs ');

  IF pG_batch_options.IMPORT_XREF_ONLY = 'Y' THEN
    write_debug('The Process Returned because of Cross References Only');
    x_return_status := 'S';
    RETURN;
  END IF;

  OPEN Process_Header(p_batch_id);
  FETCH Process_Header BULK COLLECT INTO l_item_id_table,l_org_id_table,l_ss_record_table,l_item_num_table;
  CLOSE Process_Header;

  l_count := l_ss_record_table.COUNT;
  FOR  i IN 1..l_count
  LOOP
  IF l_ss_record_table(i) IS NULL OR l_ss_record_table(i) = FND_API.G_MISS_CHAR
  THEN
    Error_Handler.Add_Error_Token
    (
     p_message_name => 'BOM_SOURCE_SYS_REF_INVALID'
    ,p_Mesg_token_Tbl => l_Mesg_Token_Tbl
    ,x_Mesg_token_Tbl => l_Mesg_Token_Tbl
    ,p_token_Tbl => l_Token_Tbl
    ,p_message_type => 'E'
    );
    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSE
    write_debug('Updating the header x-refs ');

    UPDATE bom_bill_of_mtls_interface
    SET   assembly_item_id = l_item_id_table(i),
          organization_id = l_org_id_table(i),
          item_number = l_item_num_table(i)
    WHERE batch_id = p_batch_id
    AND   source_system_reference = l_ss_record_table(i)
    AND (process_flag = 1 OR process_flag  = 5);
  END IF;
  END LOOP;

  OPEN Process_Comp (p_batch_id);
  FETCH Process_Comp BULK COLLECT INTO l_item_id_table,l_org_id_table,l_ss_record_table,l_item_num_table;
  CLOSE Process_Comp;

  l_count := l_ss_record_table.COUNT;
  FOR i IN 1..l_count
  LOOP
  IF l_ss_record_table(i) IS NULL OR l_ss_record_table(i) = FND_API.G_MISS_CHAR
  THEN
    Error_Handler.Add_Error_Token
    (
     p_message_name => 'BOM_SOURCE_SYS_REF_INVALID'
    ,p_Mesg_token_Tbl => l_Mesg_Token_Tbl
    ,x_Mesg_token_Tbl => l_Mesg_Token_Tbl
    ,p_token_Tbl => l_Token_Tbl
    ,p_message_type => 'E'
    );
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    write_debug('Updating the component x-refs ');

    UPDATE bom_inventory_comps_interface
    SET    component_item_id = l_item_id_table(i),
           organization_id = l_org_id_table(i),
           component_item_number = l_item_num_table(i)
    WHERE  batch_id = p_batch_id
    AND    comp_source_system_reference = l_ss_record_table(i)
    AND ( process_flag = 1 OR process_flag = 5) ;
    END IF;
  END LOOP;

  OPEN Process_Header_For_Comp;
  FETCH Process_Header_For_Comp BULK COLLECT INTO l_item_id_table,l_org_id_table,l_ss_record_table,l_item_num_table;
  CLOSE Process_Header_For_Comp;

  l_count := l_ss_record_table.COUNT;

  FOR i in 1..l_count LOOP
   UPDATE bom_inventory_comps_interface
   SET assembly_item_id = l_item_id_table(i),
       organization_id = l_org_id_table(i),
       assembly_item_number = l_item_num_table(i)
   WHERE  batch_id = p_batch_id
   AND    comp_source_system_reference = l_ss_record_table(i)
   AND ( process_flag = 1 OR process_flag = 5) ;
  END LOOP;

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
  WHEN OTHERS THEN

  Write_Debug('Unexpected Error occured '|| SQLERRM);

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
  l_err_text := SUBSTR(SQLERRM, 1, 200);
  Error_Handler.Add_Error_Token
    (
     p_Message_Name => NULL
   , p_Message_Text => l_err_text
   , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
    );
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
   END IF;
  x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END RESOLVE_XREFS_FOR_BATCH;

/* Update Match Data */

PROCEDURE UPDATE_MATCH_DATA
(
  p_batch_id              IN NUMBER
, p_source_system_id      IN NUMBER
, x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status         IN OUT NOCOPY VARCHAR2
)
IS
  l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
  l_Token_Tbl             Error_Handler.Token_Tbl_Type;
  l_err_text              VARCHAR2(1000);

  TYPE num_type IS TABLE OF NUMBER;
  TYPE var_type IS TABLE OF VARCHAR2(1000);

  l_item_id_table num_type;
  l_org_id_table num_type;
  l_ss_record_table var_type;
  l_count         NUMBER;
  l_item_num_table var_type;
  l_request_id NUMBER := nvl(FND_GLOBAL.conc_request_id,-1);
CURSOR  Process_Header
  IS
  SELECT  MSII.inventory_item_id,MSII.organization_id,MSII.source_system_reference,MSII.item_number
  FROM  bom_bill_of_mtls_interface BBMI,mtl_system_items_interface MSII
  WHERE BBMI.batch_id = p_batch_id
  AND (BBMI.process_flag = 1 OR BBMI.process_flag = 5)
  AND MSII.set_process_id = BBMI.batch_id
  AND MSII.process_flag IN (0,1,7)
  AND ((l_request_id <> -1 AND MSII.request_id = l_request_id) OR (l_request_id = -1 AND BBMI.request_id = MSII.request_id))
  AND (MSII.source_system_reference = BBMI.source_system_reference OR MSII.item_number = BBMI.item_number)
  AND (MSII.organization_code = BBMI.organization_code OR MSII.organization_id = BBMI.organization_id);

  CURSOR Process_Comp
  IS
  SELECT  MSII.inventory_item_id,MSII.organization_id,MSII.source_system_reference,MSII.item_number
  FROM  bom_inventory_comps_interface BICI,mtl_system_items_interface MSII
  WHERE BICI.batch_id = p_batch_id
  AND (BICI.process_flag = 1 OR BICI.process_flag = 5)
  AND MSII.set_process_id = BICI.batch_id
  AND MSII.process_flag IN (0,1,7)
  AND ((l_request_id <> -1 AND MSII.request_id = l_request_id) OR (l_request_id = -1 AND BICI.request_id = MSII.request_id))
  AND (MSII.source_system_reference = BICI.comp_source_system_reference OR MSII.item_number = BICI.component_item_number)
  AND (MSII.organization_code = BICI.organization_code OR MSII.organization_id = BICI.organization_id);

  Cursor Process_Header_For_Comp
  IS
  SELECT  MSII.inventory_item_id,MSII.organization_id,MSII.source_system_reference,MSII.item_number
  FROM  bom_inventory_comps_interface BICI,mtl_system_items_interface MSII
  WHERE BICI.batch_id = p_batch_id
  AND (BICI.process_flag = 1 OR BICI.process_flag = 5)
  AND MSII.set_process_id = BICI.batch_id
  AND MSII.process_flag IN (0,1,7)
  AND ((l_request_id <> -1 AND MSII.request_id = l_request_id) OR (l_request_id = -1 AND BICI.request_id = MSII.request_id))
  AND ( MSII.source_system_reference = BICI.parent_source_system_reference OR MSII.item_number = BICI.assembly_item_number )
  AND (MSII.organization_code = BICI.organization_code OR MSII.organization_id = BICI.organization_id);


BEGIN

  write_debug('In Update Match Data');

  OPEN Process_Header;
  FETCH Process_Header BULK COLLECT INTO l_item_id_table,l_org_id_table,l_ss_record_table,l_item_num_table;
  CLOSE Process_Header;

  l_count := l_ss_record_table.COUNT;

  FOR i IN 1..l_count
  LOOP
    IF ( (l_ss_record_table(i) IS NULL AND l_item_num_table(i) IS NULL ) OR ( l_ss_record_table(i) = FND_API.G_MISS_CHAR AND l_item_num_table(i) = FND_API.G_MISS_CHAR) )
    THEN
      Error_Handler.Add_Error_Token
      (
      p_message_name => 'BOM_SOURCE_SYS_REF_INVALID'
      ,p_Mesg_token_Tbl => l_Mesg_Token_Tbl
      ,x_Mesg_token_Tbl => l_Mesg_Token_Tbl
      ,p_token_Tbl => l_Token_Tbl
      ,p_message_type => 'E'
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      write_debug('Updating the Header matches ');

      UPDATE bom_bill_of_mtls_interface
      SET assembly_item_id = l_item_id_table(i),
      Organization_id = l_org_id_table(i),
      item_number = l_item_num_table(i),
      bill_sequence_id = null,
      transaction_type = 'SYNC'
      WHERE batch_id = p_batch_id
      AND (process_flag = 1 OR process_flag = 5)
      AND (source_system_reference = l_ss_record_table(i) OR item_number = l_item_num_table(i)) ;
    END IF;
  END LOOP;
  write_debug('After Updating Header Matches');
  OPEN Process_Comp;
  FETCH  Process_Comp BULK COLLECT INTO l_item_id_table,l_org_id_table,l_ss_record_table,l_item_num_table;
  CLOSE Process_Comp;
  l_count := l_ss_record_table.COUNT;


  FOR i IN 1..l_count
  LOOP
    IF ( (l_ss_record_table(i) IS NULL AND l_item_num_table(i) IS NULL ) OR ( l_ss_record_table(i) = FND_API.G_MISS_CHAR AND l_item_num_table(i) = FND_API.G_MISS_CHAR) )
    THEN
      Error_Handler.Add_Error_Token
      (
       p_message_name => 'BOM_SOURCE_SYS_REF_INVALID'
      ,p_Mesg_token_Tbl => l_Mesg_Token_Tbl
      ,x_Mesg_token_Tbl => l_Mesg_Token_Tbl
      ,p_token_Tbl => l_Token_Tbl
      ,p_message_type => 'E'
      );
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      write_debug('Updating the Component Matches');
      UPDATE bom_inventory_comps_interface
      SET component_item_id = l_item_id_table(i),
      Organization_id = l_org_id_table(i),
      component_item_number = l_item_num_table(i)
      WHERE batch_id = p_batch_id
      AND (process_flag = 1 OR process_flag = 5)
      AND (comp_source_system_reference = l_ss_record_table(i) OR component_item_number = l_item_num_table(i));
    END IF;
  END LOOP;

  OPEN Process_Header_For_Comp;
  FETCH Process_Header_For_Comp BULK COLLECT INTO l_item_id_table,l_org_id_table,l_ss_record_table,l_item_num_table;
  CLOSE Process_Header_For_Comp;

  l_count := l_ss_record_table.COUNT;
  FOR i in 1..l_count LOOP
      write_debug('Updating the Header matches in Component');
      UPDATE bom_inventory_comps_interface
      SET assembly_item_id = l_item_id_table(i),
      Organization_id = l_org_id_table(i),
      assembly_item_number = l_item_num_table(i)
      WHERE batch_id = p_batch_id
      and (process_flag = 1 OR process_flag = 5)
      AND ( parent_source_system_reference = l_ss_record_table(i) OR assembly_item_number = l_item_num_table(i)) ;
  END LOOP;

  update_bill_info(p_batch_id => p_batch_id,
                   x_Mesg_Token_Tbl => l_Mesg_Token_Tbl,
                   x_Return_Status => x_return_status);

EXCEPTION
  WHEN OTHERS
  THEN
    Write_Debug('Unexpected Error occured..'|| SQLERRM);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      l_err_text := SUBSTR(SQLERRM, 1, 200);
      Error_Handler.Add_Error_Token
      (
         p_Message_Name => NULL
       , p_Message_Text => l_err_text
       , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
       , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
      );
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END UPDATE_MATCH_DATA;

  /* End Update Match Data */    --??DInu why two

PROCEDURE UPDATE_BILL_INFO
  (
    p_batch_id            IN NUMBER
  , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  , x_Return_Status         IN OUT NOCOPY VARCHAR2
  )
  IS


  TYPE  bom_comp_intf_type  IS  TABLE OF bom_inventory_comps_interface%ROWTYPE;
  TYPE  bom_comp_type  IS TABLE OF bom_components_b%ROWTYPE;
  TYPE num_type IS TABLE OF NUMBER;
  TYPE var_type IS TABLE OF VARCHAR2(1000);

l_err_text VARCHAR2(1000);
l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;

  l_comp_seq_id NUMBER;
  l_header_count NUMBER;
  l_comp_count NUMBER;
  l_comp_seq_count NUMBER;
  l_bill_seq_id NUMBER;
  l_effec_ctrl NUMBER;
  l_txn_table var_type;
  l_org_id NUMBER;
  l_header_rec_table var_type;
  l_str_name   var_type;
  l_comp_table bom_comp_intf_type;
  l_comp_pdh_table bom_comp_type;
  l_item_id_table num_type;
  l_org_id_table num_type;
  l_not_exist BOOLEAN;
  l_exist_table num_type;
  l_str_type_id NUMBER;
  l_org_code_table var_type;
  l_item_name_table var_type;
  l_old_comp_seq_id  NUMBER := NULL;
  l_comp_id NUMBER;
  l_wrong_comp BOOLEAN;

  CURSOR Get_Header(l_batch_id IN NUMBER)
  IS
  SELECT BBMI.assembly_item_id,BBMI.organization_id,BBMI.alternate_bom_designator,BBMI.source_system_reference,UPPER(BBMI.transaction_type),BBMI.organization_code,BBMI.item_number
  FROM bom_bill_of_mtls_interface BBMI
  WHERE batch_id = l_batch_id
  AND process_flag NOT IN(3,7,-1);

  CURSOR  Process_Header(l_batch_id IN NUMBER,l_item_id IN NUMBER,l_org_id IN NUMBER,l_name IN VARCHAR2)
  IS
  SELECT BSB.bill_sequence_id,BSB.effectivity_control,BSB.organization_id
  FROM  bom_bill_of_mtls_interface BBMI,
  bom_Structures_b BSB
  WHERE BBMI.batch_id = l_batch_id
  AND process_flag NOT IN(3,7,-1)
  AND BSB.assembly_item_id = l_item_id
  AND BSB.organization_id = l_org_id
  AND NVL(BSB.alternate_bom_designator,'Y') = NVL(l_name,'Y');

  CURSOR Process_Comp(l_batch_id IN NUMBER,p_parent_reference IN VARCHAR2,l_parent_name IN VARCHAR2)
  IS
  SELECT *
  FROM bom_inventory_comps_interface BICI
  WHERE batch_id = l_batch_id
  AND process_flag NOT IN(3,7,-1)
  AND (parent_source_system_reference = p_parent_reference OR assembly_item_number = l_parent_name);

  CURSOR Process_Unmatched_Comps(l_bill_seq_id IN NUMBER)
  IS
  SELECT *
  FROM Bom_Components_B BCB
  WHERE BCB.bill_sequence_id = l_bill_seq_id;

  BEGIN


    write_debug('In Update Bill Info');

    OPEN Get_Header(p_batch_id);
    FETCH Get_Header BULK COLLECT INTO l_item_id_table,l_org_id_table,l_str_name,l_header_rec_table,l_txn_table,l_org_code_table,l_item_name_table;
    CLOSE Get_Header;

    l_header_count := l_header_rec_table.COUNT;

    FOR i IN 1..l_header_count
    LOOP    --Header Loop

     write_debug('Updating the Bill for Header '|| l_header_rec_table(i));

     l_bill_seq_id := NULL;

     BEGIN
     IF l_org_id_table(i) IS NULL THEN
       SELECT organization_id
       INTO l_org_id_table(i)
       FROM mtl_parameters
       WHERE organization_code = l_org_code_table(i);
     END IF;


     IF l_item_id_table(i) IS NULL THEN
       SELECT inventory_item_id
       INTO l_item_id_table(i)
       FROM mtl_system_items_vl
       WHERE (concatenated_segments = l_header_rec_table(i) OR concatenated_segments = l_item_name_table(i))
       AND organization_id = l_org_id_table(i);
     END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL; --new item creation
     END;


    IF l_item_id_table(i) IS NOT NULL AND l_org_id_table(i) IS NOT NULL
    THEN
      OPEN Process_Header(p_batch_id,l_item_id_table(i),l_org_id_table(i),l_str_name(i));
      FETCH Process_Header INTO l_bill_seq_id,l_effec_ctrl,l_org_id;
      CLOSE Process_Header;
    END IF;


      OPEN Process_Comp(p_batch_id,l_header_rec_table(i),l_item_name_table(i));
      FETCH Process_Comp BULK COLLECT INTO l_comp_table;
      CLOSE Process_Comp;

      l_comp_count := l_comp_table.COUNT;

      IF (l_bill_seq_id IS NULL)
        THEN
          write_debug('Bill sequence id is null--Create header');

          IF (l_txn_table(i) = 'SYNC' OR l_txn_table(i) = 'CREATE' OR l_txn_table(i) = 'UPDATE')
          THEN
          l_txn_table(i) := 'CREATE';
          END IF;

          FOR j IN 1..l_comp_count
          LOOP
          IF (l_comp_table(j).transaction_type = 'SYNC' OR
              l_comp_table(j).transaction_type = 'CREATE' OR
              l_comp_table(j).transaction_type = 'UPDATE')
          THEN
           IF l_comp_table(j).component_sequence_id IS NULL THEN
             l_comp_table(j).transaction_type := 'CREATE';
           ELSE
             l_comp_table(j).transaction_type := 'UPDATE';
           END IF;
          END IF;
        END LOOP;
    ELSE
      write_debug('Bill sequence id is not null--Update header bill_seq_id ' || l_bill_seq_id);
      IF (l_txn_table(i) ='SYNC' OR l_txn_table(i) ='CREATE' OR l_txn_table(i) ='UPDATE')
      THEN
        l_txn_table(i) := 'UPDATE';
      END IF;

      l_comp_count := l_comp_table.COUNT;

      FOR  j IN 1..l_comp_count
      LOOP

        IF l_comp_table(j).comp_source_system_reference IS NULL THEN
           l_comp_table(j).comp_source_system_reference := l_comp_table(j).component_item_number;
        END IF;

        l_comp_table(j).transaction_type := UPPER(l_comp_table(j).transaction_type);

        l_comp_table(j).bill_sequence_id := l_bill_seq_id;


        IF l_comp_table(j).component_sequence_id IS NOT  NULL THEN
         BEGIN
          SELECT component_item_id
          into l_comp_id
          from bom_components_b
          where component_sequence_id = l_comp_table(j).component_sequence_id;

          IF l_comp_table(j).component_item_id = l_comp_id THEN
             l_wrong_comp := false;
          ELSE
             l_wrong_comp := true;
          END IF;

         EXCEPTION WHEN NO_DATA_FOUND THEN
         l_wrong_comp := true;
        END;
       ELSE
         l_wrong_comp := true;
       END IF;

        IF l_wrong_comp THEN

          BEGIN
           IF l_comp_table(j).component_item_id IS NULL THEN
             SELECT inventory_item_id
             INTO l_comp_table(j).component_item_id
             FROM mtl_system_items_vl
             WHERE concatenated_segments = l_comp_table(j).component_item_number
             AND organization_id = l_org_id_table(i);
           END IF;
           EXCEPTION WHEN NO_DATA_FOUND THEN
           -- l_comp_table(j).component_item_id := null;
            NULL; -- new item creation
           END;

          IF (l_comp_table(j).transaction_type = 'DELETE') THEN
           IF (l_comp_table(j).disable_date IS NULL) THEN
              l_comp_table(j).disable_date := sysdate;
           END IF;
          END IF;
            /* bugfix:8334380.Changed to NEW_CHECK_COMP_EXIST */
          l_comp_seq_id  := NEW_CHECK_COMP_EXIST(l_bill_seq_id,
                                             l_effec_ctrl,
                                             p_batch_id,
                                             l_comp_table(j).comp_source_system_reference,
                                             l_comp_table(j).component_item_id,
                                             l_org_id_table(i),
                                             l_item_id_table(i)
                                            );


          IF(l_comp_seq_id <> 0)
          THEN

             IF l_comp_table(j).process_flag = 5 THEN
             l_comp_table(j).old_component_sequence_id := l_comp_seq_id;
             END IF;

            IF (l_comp_table(j).transaction_type = 'SYNC' OR l_comp_table(j).transaction_type = 'CREATE' OR l_comp_table(j).transaction_type = 'UPDATE') THEN
                l_comp_table(j).transaction_type := 'UPDATE';
                l_comp_table(j).component_sequence_id := l_comp_seq_id;
            ELSIF l_comp_table(j).transaction_type = 'UPDATE' THEN
               IF l_comp_table(j).component_sequence_id IS NULL THEN
                  l_comp_table(j).component_sequence_id := l_comp_seq_id;
               END IF;
            END IF;
            IF (l_comp_table(j).transaction_type = 'DELETE') THEN
                IF (l_comp_table(j).component_sequence_id IS NULL) THEN
                    l_comp_table(j).component_sequence_id := l_comp_seq_id;
                END IF;
            END IF;
          ELSE
            IF (l_comp_table(j).transaction_type = 'SYNC' OR l_comp_table(j).transaction_type = 'UPDATE' OR l_comp_table(j).transaction_type = 'CREATE') THEN
                l_comp_table(j).transaction_type := 'CREATE';
                l_comp_table(j).component_sequence_id := NULL;
            END IF;
          END IF;
       ELSE
           IF l_comp_table(j).process_flag = 5 THEN
              l_comp_table(j).old_component_sequence_id := l_comp_table(j).component_sequence_id;
           END IF;
           IF l_comp_table(j).transaction_type = 'SYNC' THEN
              l_comp_table(j).transaction_type := 'UPDATE';
           END IF;
           IF l_comp_table(j).transaction_type = 'DELETE' THEN
              IF l_comp_table(j).disable_date IS NULL THEN
                 l_comp_table(j).disable_date := sysdate;
              END IF;
           END IF;
       END IF;
      END LOOP;
    END IF; /*bill_seq_id null IF */

    l_comp_count := l_comp_table.COUNT;

    FOR j IN 1..l_comp_count
    LOOP
      write_debug('updating comp -'|| l_comp_table(j).comp_source_system_reference);
      write_debug('with parent -'|| l_comp_table(j).parent_source_system_reference);
      UPDATE bom_inventory_comps_interface
      SET bill_sequence_id = l_comp_table(j).bill_sequence_id ,
          transaction_type = l_comp_table(j).transaction_type,
          component_sequence_id = l_comp_table(j).component_sequence_id,
          old_component_sequence_id = l_comp_table(j).old_component_sequence_id,
          disable_date = l_comp_table(j).disable_date,
          component_item_id = l_comp_table(j).component_item_id
      WHERE batch_id = l_comp_table(j).batch_id
      AND (process_flag = 1 or process_flag = 5)
      AND ( component_sequence_id = l_comp_table(j).component_sequence_id
         OR (/*component_sequence_id IS NULL
            AND*/(comp_source_system_reference = l_comp_table(j).comp_source_system_reference OR component_item_number = l_comp_table(j).component_item_number)
            AND (parent_source_system_reference = l_comp_table(j).parent_source_system_reference OR assembly_item_number =  l_comp_table(j).assembly_item_number)));

--      IF l_comp_table(j).transaction_id IS NOT NULL THEN
       UPDATE bom_cmp_usr_attr_interface
       SET item_number = l_comp_table(j).component_item_number,
           assembly_item_number = l_comp_table(j).assembly_item_number,
           comp_source_system_reference = l_comp_table(j).comp_source_system_reference,
           parent_source_system_reference = l_comp_table(j).parent_source_system_reference,
           organization_id = l_org_id_table(i),
           attr_group_type = 'BOM_COMPONENTMGMT_GROUP' ,
           component_item_id = l_comp_table(j).component_item_id
           --process_status = 2
       WHERE batch_id = p_batch_id
       AND item_number = l_comp_table(j).component_item_number
       AND assembly_item_number = l_comp_table(j).assembly_item_number
       AND process_status NOT IN (3,4);
       --  AND transaction_id = l_comp_table(j).transaction_id;
--      END IF;
    END LOOP;

    UPDATE bom_bill_of_mtls_interface
    SET transaction_type = l_txn_table(i),
    Bill_sequence_id = l_bill_seq_id,
    assembly_item_id = l_item_id_table(i)
    WHERE batch_id = p_batch_id
    AND  (source_system_reference = l_header_rec_table(i) OR item_number = l_item_name_table(i))
    AND (process_flag = 1 or process_flag = 5);

  END LOOP; --End Header Loop
  x_Return_Status := 'S';

EXCEPTION
WHEN OTHERS THEN
  Write_Debug('Unexpected Error occured' || SQLERRM);
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   l_err_text := SUBSTR(SQLERRM, 1, 200);
   Error_Handler.Add_Error_Token
       (
      p_Message_Name => NULL
      , p_Message_Text => l_err_text
        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
     );
  x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
   END IF;
   x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END UPDATE_BILL_INFO;

/* End Update Bill Info */

/**
 * This procedure is the starting point for the existing open interface
 * tables being used to create batches.
 * Users will call this API once the data load for a batch is done in the
 * bom interface tables.
 *
*/
PROCEDURE DATA_UPLOAD_COMPLETE
(
  p_batch_id               IN NUMBER
, p_init_msg_list           IN VARCHAR2
, x_return_status            IN OUT NOCOPY VARCHAR2
, x_Error_Mesg              IN OUT NOCOPY VARCHAR2
, p_debug                   IN  VARCHAR2
, p_output_dir              IN  VARCHAR2
, p_debug_filename          IN  VARCHAR2
)
IS
  G_EXC_SEV_QUIT_OBJECT EXCEPTION;

  l_message_list    Error_Handler.Error_Tbl_Type;
  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_other_message   VARCHAR2(50);
  l_Token_Tbl       Error_Handler.Token_Tbl_Type;
  l_err_text        VARCHAR2(2000);
  l_return_status   VARCHAR2(1);
  l_debug_flag      VARCHAR2(1) := p_debug;
  l_debug           BOOLEAN := FALSE;

  TYPE var_type IS TABLE OF VARCHAR2(50);
  TYPE num_type IS TABLE OF NUMBER;

  TYPE bom_intf_header IS TABLE OF Bom_Bill_of_Mtls_Interface%ROWTYPE;
  TYPE bom_intf_comp IS TABLE OF Bom_Inventory_Comps_Interface%ROWTYPE;
  TYPE batch_options IS TABLE OF Ego_Import_Option_Sets%ROWTYPE;

  l_header_table  bom_intf_header;
  l_comp_table    bom_intf_comp;
  l_header_count  NUMBER;
  l_comp_count    NUMBER;
  l_dummy         VARCHAR2(10);
  l_user_name     FND_USER.USER_NAME%TYPE := FND_GLOBAL.USER_NAME;
  l_user_id       NUMBER;
  l_language      VARCHAR2(100);
  l_resp_id       NUMBER;
  l_request_id    NUMBER;
  l_app_id        NUMBER;
  l_batch_option_table batch_options;


  l_submit_failure_exc   EXCEPTION;

  l_ss_ref_table              var_type;
  l_ss_desc_table             var_type;
  l_cat_name_table            var_type;
  l_cat_grp_table             num_type;
  l_uom_table                 var_type;
  l_ss_id_table               var_type;
  l_org_id_table     num_type;
  l_org_code_table   var_type;
  l_item_id_table             num_type;
  l_item_number_table         var_type;
  l_txn_type_table            var_type;
  l_item_desc_table           var_type;

  l_str_type_id   NUMBER;
  l_str_name      VARCHAR2(100);
  l_effec_control VARCHAR2(100);
  l_process_flag  NUMBER;

  l_match_req_id NUMBER;
  l_import_req_id   NUMBER;

  CURSOR Get_Structure_Details
  (
    p_batch_id IN NUMBER
  )
  IS
    SELECT
      structure_type_id,
      structure_name,
      structure_effectivity_type
    FROM
      ego_import_option_sets
    WHERE
      batch_id = p_batch_id;

  CURSOR Upload_Header
  (
    l_batch_id IN NUMBER
  )
  IS
    SELECT
      BBMI.SOURCE_SYSTEM_REFERENCE,
      BBMI.SOURCE_SYSTEM_REFERENCE_DESC,
      BBMI.CATALOG_CATEGORY_NAME,
      BBMI.ITEM_CATALOG_GROUP_ID,
      BBMI.PRIMARY_UNIT_OF_MEASURE,
      EIBB.SOURCE_SYSTEM_ID,
      BBMI.ORGANIZATION_ID,
      BBMI.ORGANIZATION_CODE,
      BBMI.ASSEMBLY_ITEM_ID,
      BBMI.ITEM_NUMBER,
      UPPER(BBMI.TRANSACTION_TYPE),
      BBMI.ITEM_DESCRIPTION
    FROM
      bom_bill_of_mtls_interface BBMI,
      ego_import_batches_b EIBB
    WHERE
          BBMI.batch_id = l_batch_id
      AND EIBB.batch_id = BBMI.batch_id
      AND BBMI.PROCESS_FLAG NOT IN (3,7,-1);

  CURSOR Upload_Comp
  (
    l_batch_id IN NUMBER
  )
  IS
    SELECT
      BICI.comp_source_system_reference,
      BICI.COMP_SOURCE_SYSTEM_REFER_DESC,
      BICI.CATALOG_CATEGORY_NAME,
      BICI.ITEM_CATALOG_GROUP_ID,
      BICI.PRIMARY_UNIT_OF_MEASURE,
      EIBB.SOURCE_SYSTEM_ID,
      BICI.COMPONENT_ITEM_ID,
      BICI.COMPONENT_ITEM_NUMBER,
      BICI.ORGANIZATION_ID,
      BICI.ORGANIZATION_CODE,
      UPPER(BICI.TRANSACTION_TYPE),
      BICI.ITEM_DESCRIPTION
  FROM
      bom_inventory_comps_interface BICI,
      ego_import_batches_b EIBB
  WHERE
        BICI.batch_id = l_batch_id
    AND EIBB.batch_id = BICI.batch_id
    AND BICI.PROCESS_FLAG NOT IN (3,7,-1);

    Cursor Get_Batch_Options
    (
      l_batch_id IN NUMBER
    )
    IS
      SELECT *
      FROM ego_import_option_sets
      WHERE batch_id = l_batch_id;

BEGIN
  IF p_init_msg_list = 'Y'
  THEN
    Error_Handler.Initialize();
  END IF;

  IF l_debug_flag = 'Y'
  THEN
    IF trim(p_output_dir) IS NULL OR
    trim(p_output_dir) = ''
    THEN
      -- IF debug is Y THEN out dir must be
      -- specified
      Error_Handler.Add_Error_Token
      (  p_Message_text       =>
      'Debug is set to Y so an output directory' ||
      ' must be specified. Debug will be turned' ||
      ' off since no directory is specified'
      , p_Mesg_Token_Tbl     => l_Mesg_Token_tbl
      , x_Mesg_Token_Tbl     => l_Mesg_Token_tbl
      , p_Token_Tbl          => l_Token_Tbl
      );
     l_debug_flag := 'N';
    END IF;

    IF trim(p_debug_filename) IS NULL OR
    trim(p_debug_filename) = ''
    THEN
      Error_Handler.Add_Error_Token
      (  p_Message_text       =>
      'Debug is set to Y so an output filename' ||
      ' must be specified. Debug will be turned' ||
      ' off since no filename is specified'
      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
      , p_Token_Tbl          => l_token_tbl
      );
      l_debug_flag := 'N';
    END IF;
    Bom_Globals.Set_Debug(l_debug_flag);

    IF Bom_Globals.Get_Debug = 'Y'
    THEN
      Error_Handler.Open_Debug_Session
      (  p_debug_filename     => p_debug_filename
      , p_output_dir         => p_output_dir
      , x_return_status      => l_return_status
      , p_mesg_token_tbl     => l_mesg_token_tbl
      , x_mesg_token_tbl     => l_mesg_token_tbl
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        l_debug_flag := 'N';
      END IF;
    END IF;
  END IF;

  Bom_Globals.Set_Debug(l_debug_flag);

   IF Error_Handler.get_debug <> 'Y' THEN
    l_debug := Init_Debug;
  ELSE
    l_debug := TRUE;
  END IF;

  SELECT userenv('LANG')
  INTO l_language
  FROM dual;

  l_user_id := FND_GLOBAL.USER_ID;
  l_resp_id := FND_GLOBAL.RESP_ID;
  l_app_id  := FND_GLOBAL.RESP_APPL_ID;

  IF (NVL(l_user_id,-1)=-1 OR NVL(l_resp_id,-1)=-1 OR NVL(l_app_id,-1)=-1)
  THEN
    Error_Handler.Add_Error_Token
		(  p_Message_Name       => 'BOM_IMPORT_USER_INVALID'
		 , p_Mesg_Token_Tbl     => l_Mesg_Token_tbl
		 , x_Mesg_Token_Tbl     => l_Mesg_Token_tbl
		 , p_Token_Tbl          => l_token_tbl
		);

    Error_Handler.Translate_And_Insert_Messages
		(  p_mesg_token_tbl     => l_Mesg_Token_tbl
		 , p_application_id     => 'BOM'
		);

    Error_Handler.Get_Message_List( x_message_list => l_message_list);
	    x_Error_Mesg := l_message_list(1).Message_Text;
	    x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
  END IF;

  Write_Debug('In Data Upld Complete Retrieving Batch Options');

  Retrieve_Batch_Options( p_batch_id,l_mesg_token_tbl,l_return_status);

  IF l_return_status <> 'S'
  THEN
   --x_Error_Mesg := l_err_text;
   RAISE G_EXC_SEV_QUIT_OBJECT;
  END IF;

  Write_Debug('Resolving X-Refs');

  RESOLVE_XREFS_FOR_BATCH
  (
    p_batch_id
  , l_Mesg_Token_Tbl
  , l_return_status
  );
  IF l_return_status <> 'S'
  THEN
    Error_Handler.Add_Error_Token
      (
        p_message_name => NULL
      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
      , p_Token_Tbl          => l_token_tbl
      );
  END IF;

  Write_Debug('Uploading the Header');

  IF pG_batch_options.IMPORT_XREF_ONLY = 'Y' THEN
   l_process_flag := 0;
  ELSE
   l_process_flag := 1;
  END If;


    OPEN  Upload_Header(p_batch_id);
    FETCH
      Upload_Header
    BULK COLLECT INTO
      l_ss_ref_table,
      l_ss_desc_table,
      l_cat_name_table,
      l_cat_grp_table,
      l_uom_table,
      l_ss_id_table,
      l_org_id_table,
      l_org_code_table,
      l_item_id_table,
      l_item_number_table,
      l_txn_type_table,
      l_item_desc_table;
    CLOSE Upload_Header;

    l_header_count := l_ss_ref_table.COUNT;

    FOR i IN 1..l_header_count
    LOOP
      IF NOT Item_Exist_In_Mtl_Intf(l_ss_ref_table(i),p_batch_id,l_org_code_table(i),l_item_number_table(i),l_ss_desc_table(i),l_item_desc_table(i),l_org_id_table(i))
      THEN
        Write_Debug('Inserting into Mtl_Interface for Header');
        INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
        ( set_process_id
        , source_system_id
        , source_system_reference
        , SOURCE_SYSTEM_REFERENCE_DESC
        , item_catalog_group_id
        , primary_unit_of_measure
        , organization_id
        , organization_code
        , inventory_item_id
        , item_number
        , transaction_type
        , process_flag
        , description
        )
        VALUES
        (
          p_batch_id
        , l_ss_id_table(i)
        , l_ss_ref_table(i)
        , l_ss_desc_table(i)
        , l_cat_grp_table(i)
        , l_uom_table(i)
        , l_org_id_table(i)
        , l_org_code_table(i)
        , l_item_id_table(i)
        , l_item_number_table(i)
        , l_txn_type_table(i)
        , l_process_flag
        , l_item_desc_table(i)
        );
      END IF;
    END LOOP;

    OPEN Upload_Comp(p_batch_id);
    FETCH
      Upload_Comp
    BULK COLLECT INTO
        l_ss_ref_table
      , l_ss_desc_table
      , l_cat_name_table
      , l_cat_grp_table
      , l_uom_table
      , l_ss_id_table
      , l_item_id_table
      , l_item_number_table
      , l_org_id_table
      , l_org_code_table
      , l_txn_type_table
      , l_item_desc_table;
    CLOSE Upload_Comp;

    l_comp_count := l_ss_ref_table.COUNT;

    FOR i IN 1..l_comp_count
    LOOP
      IF NOT Item_Exist_In_Mtl_Intf(l_ss_ref_table(i),p_batch_id,l_org_code_table(i),l_item_number_table(i),l_ss_desc_table(i),l_item_desc_table(i),l_org_id_table(i))
      THEN
       Write_Debug('Inserting into Mtl_Interface for Comps');

        INSERT INTO MTL_SYSTEM_ITEMS_INTERFACE
        (
          set_process_id
        , source_system_id
        , source_system_reference
        , SOURCE_SYSTEM_REFERENCE_DESC
        , item_catalog_group_id
        , primary_unit_of_measure
        , organization_id
        , organization_code
        , inventory_item_id
        , item_number
        , transaction_type
        , process_flag
        , description
        )
        VALUES
        (
          p_batch_id
        , l_ss_id_table(i)
        , l_ss_ref_table(i)
        , l_ss_desc_table(i)
        , l_cat_grp_table(i)
        , l_uom_table(i)
        , l_org_id_table(i)
        , l_org_code_table(i)
        , l_item_id_table(i)
        , l_item_number_table(i)
        , l_txn_type_table(i)
        , l_process_flag
        , l_item_desc_table(i)
        );

      END IF;
    END LOOP;



  /* we need to trigger the EgoIJAVA in case of
   * import_on_data_load = Y or match_on_data_load = Y
   * as EGOIJAVA itself triggers the matching CP.
   */
IF ( pG_batch_options.IMPORT_ON_DATA_LOAD = 'Y' OR pG_batch_options.MATCH_ON_DATA_LOAD = 'Y' ) THEN
        IF NOT FND_REQUEST.Set_Options
                          ( implicit  => 'WARNING'
                          , protected => 'YES'
                          )
        THEN
                RAISE l_submit_failure_exc;
        END IF;
        OPEN Get_Batch_Options(p_batch_id);
        FETCH Get_Batch_Options BULK COLLECT INTO l_batch_option_table;
        CLOSE Get_Batch_Options;

        l_request_id := Fnd_Request.Submit_Request(
                      application => 'EGO',
                      program     => 'EGOIJAVA',
                      sub_request => FALSE,
                      argument1   => null,-- result fmt
                      argument2   => l_user_id,
                      argument3   => l_language,-- lang
                      argument4   => l_resp_id,-- Respo
                      argument5   => l_app_id,-- App Id
                      argument6   => 2,-- Run From - API
                      argument7   => null,-- Create New Batch
                      argument8   => p_batch_id,-- Batch Id
                      argument9   => null,-- Batch Name
                      argument10  => l_batch_option_table(1).import_on_data_load,-- Import on Data Load
                      argument11  => l_batch_option_table(1).match_on_data_load,-- Match on Data Load
                      argument12  => l_batch_option_table(1).add_all_to_change_flag,-- Use CO
                      argument13  => l_batch_option_table(1).change_order_creation,-- Add/Create CO
                      argument14  => l_batch_option_table(1).change_mgmt_type_code,-- CO category
                      argument15  => l_batch_option_table(1).change_type_id,-- CO type
                      argument16  => l_batch_option_table(1).change_notice,-- CO Name
                      argument17  => l_batch_option_table(1).change_name,-- CO Number
                      argument18  => l_batch_option_table(1).change_description-- CO Desc
                      );

         /**
          * Changes for bug 5395935
          * Calling the Ego API to update the request_id to the batch.
          * if Match On Data Load is Yes then the same request id will be passed in
          * p_match_request_id
          */
          IF l_request_id IS NOT NULL THEN
            IF ( nvl(pG_batch_options.IMPORT_ON_DATA_LOAD,'N') = 'Y') THEN
              l_import_req_id := l_request_id;
            END IF;
            IF ( nvl(pG_batch_options.MATCH_ON_DATA_LOAD,'N') = 'Y') THEN
              l_match_req_id := l_request_id;
            END IF;
            Ego_Import_Pvt.Update_Request_Id_To_Batch
                           (p_import_request_id  => l_import_req_id,
                            p_match_request_id   => l_match_req_id,
                            p_batch_id           => p_batch_id
                            );
          END IF;

          commit;
          --arudresh_debug('l_req_id--' || l_request_id);
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          return;
    END IF;

    EXCEPTION
    WHEN l_submit_failure_exc THEN
        write_debug('Got Exception while Submitting Conc Request');
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN G_EXC_SEV_QUIT_OBJECT THEN
        write_debug('Got User Defined Exception ');
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        write_debug('Got Other Exception');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;




    -- No need for this.This is necessary only if the user visits the UI.
    -- For that we have a call from the UI.
    /*
    UPDATE_BILL_INFO
    (
      p_batch_id => p_batch_id,
      x_Mesg_Token_Tbl => l_Mesg_Token_Tbl,
      x_Return_Status => l_return_status
    );
    IF l_return_status <> 'S'
    THEN

      Error_Handler.Add_Error_Token
        (
          p_message_name => NULL
        , p_Mesg_Token_Tbl     => l_mesg_token_tbl
        , x_Mesg_Token_Tbl     => l_mesg_token_tbl
        , p_Token_Tbl          => l_token_tbl
        );
    END IF;


  x_return_status := l_return_status;
  Error_Handler.Get_Message_List( x_message_list => l_message_list);
  x_Error_Mesg := l_message_list(1).Message_Text;

  EXCEPTION


    Error_Handler.Add_Error_Token
      (
        p_message_name => NULL
      , p_Mesg_token_Tbl => l_Mesg_Token_Tbl
      , x_Mesg_token_Tbl => l_Mesg_Token_Tbl
      , p_token_Tbl => l_Token_Tbl
      , p_message_type => 'E'
      );

    x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
    Error_Handler.Get_Message_List( x_message_list => l_message_list);
    x_Error_Mesg := l_message_list(1).Message_Text;

    IF Bom_Globals.Get_Debug = 'Y'
    THEN
      Error_Handler.Write_Debug('After getting exception for invalid batch id ');
      Error_Handler.Write_To_DebugFile;
      Error_Handler.Dump_Message_List;
      Error_Handler.Close_Debug_Session;
    END IF;
    */

END Data_Upload_Complete;

/* End Data Upload Complete - Duplicate?? */

FUNCTION BOM_GET_COMP_ATTR_DATA
(
  p_batch_id    NUMBER
, p_ss_record_id    VARCHAR2
, p_comp_seq_id   NUMBER
, p_str_type_id   NUMBER
, p_effec_date    DATE
, p_op_seq_num    NUMBER
, p_item_id       NUMBER
, p_org_id        NUMBER
, p_intf_uniq_id  NUMBER
) RETURN Bom_Attr_Diff_Table_Type
IS
TYPE tab_typ IS TABLE OF VARCHAR2(3200);
TYPE num_type IS TABLE OF NUMBER;

l_dummy    VARCHAR2(20);
l_attr_sql  VARCHAR2(10000);
l_attr_sql1  VARCHAR2(10000);
l_pdh_query VARCHAR2(1000);
l_src_query VARCHAR2(1000);
l_where_clause VARCHAR2(1000);
l_attr_diff  Bom_Attr_Diff_Table_Type := Bom_Attr_Diff_Table_Type();
l_temp_table num_type;
l_name_table tab_typ;

l_eff_date_intf DATE;
l_new_eff_date_intf DATE;
l_dis_date_intf DATE;
l_from_num_intf VARCHAR2(100);
l_new_from_num_intf VARCHAR2(100);
l_to_unit_num_intf VARCHAR2(100);
l_from_rev_intf VARCHAR2(50);
l_to_item_rev_intf VARCHAR2(50);

l_eff_date_pdh DATE;
l_dis_date_pdh DATE;
l_from_num_pdh VARCHAR2(100);
l_to_unit_num_pdh VARCHAR2(100);
l_from_rev_pdh VARCHAR2(50);
l_to_item_rev_pdh VARCHAR2(50);
l_eff_sql VARCHAR2(1000);

attr_grp tab_typ;
attr tab_typ;
attr_name tab_typ;
src_attr tab_typ;
pdh_attr tab_typ;
batch_identifier tab_typ;

l_count NUMBER;
l_temp_count NUMBER;
l_name_count NUMBER;
l_attr_row Bom_Attribute_Row_Type := Bom_Attribute_Row_Type(1,1,1,1,1,1);

CURSOR Get_Attr_Details(p_str_type_id IN NUMBER,p_attr_grp_id IN NUMBER)
IS
SELECT BCEB.component_sequence_id
FROM bom_components_ext_b BCEB
WHERE BCEB.structure_type_id = p_str_type_id
AND BCEB.attr_group_id = p_attr_grp_id;

CURSOR Get_Src_Attr(p_str_type_id IN NUMBER,p_attr_grp_id IN NUMBER,p_attr_grp_name IN VARCHAR2)
IS
SELECT BCUA.attr_group_int_name
FROM bom_cmp_usr_attr_interface BCUA
WHERE BCUA.batch_id = p_batch_id
AND BCUA.structure_type_id = p_str_type_id
AND (BCUA.attr_group_id = p_attr_grp_id OR BCUA.attr_group_int_name = p_attr_grp_name);

BEGIN

   IF p_intf_uniq_id IS NOT NULL THEN
   SELECT effectivity_date,new_effectivity_date,disable_date,from_end_item_unit_number,new_from_end_item_unit_number,to_end_item_unit_number,from_end_item_rev_code,to_end_item_rev_code
   INTO l_eff_date_intf,l_new_eff_date_intf,l_dis_date_intf,l_from_num_intf ,l_new_from_num_intf,l_to_unit_num_intf,l_from_rev_intf ,l_to_item_rev_intf
   FROM bom_inventory_comps_interface
   WHERE batch_id = p_batch_id
   AND interface_table_unique_id = p_intf_uniq_id;
 END IF;

 IF p_comp_seq_id IS NOT NULL THEN
   SELECT effectivity_date,disable_date,from_end_item_unit_number,to_end_item_unit_number,from_end_item_rev_id,to_end_item_rev_id
   INTO l_eff_date_pdh,l_dis_date_pdh,l_from_num_pdh,l_to_unit_num_pdh,l_from_rev_pdh,l_to_item_rev_pdh
   from bom_components_b
   where  component_sequence_id = p_comp_seq_id;
 END IF;

 l_eff_sql := ' SELECT ' ;

 IF l_from_rev_intf IS NOT NULL THEN
    l_eff_sql := l_eff_sql || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_REVISION_EFF'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_FROM_END_ITEM_REV_LABEL'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_FROM_END_ITEM_REV_LABEL'||'''), '
                           ||   p_batch_id || ', '
                           || '''' ||  l_from_rev_intf || ''', ' ;
    IF l_from_rev_pdh IS NOT NULL THEN
       l_eff_sql := l_eff_sql || '''' || l_from_rev_pdh || '''';
    ELSE
       l_eff_sql := l_eff_sql ||   ' null ' ;
    END IF;
    l_eff_sql := l_eff_sql ||   ' FROM DUAL '
                           || ' UNION ALL SELECT '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_REVISION_EFF'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_TO_END_ITEM_REV_LABEL'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_TO_END_ITEM_REV_LABEL'||'''), '
                           ||   p_batch_id || ', ' ;
     IF l_to_item_rev_intf IS NOT NULL THEN
        l_eff_sql := l_eff_sql ||  '''' || l_to_item_rev_intf  || ''' , ';
     ELSE
        l_eff_sql := l_eff_sql ||   ' null , ' ;
     END IF;

     IF l_to_item_rev_pdh IS NOT NULL THEN
       l_eff_sql := l_eff_sql ||   '''' || l_to_item_rev_pdh || '''';
     ELSE
       l_eff_sql := l_eff_sql || ' null ' ;
     END IF;
     l_eff_sql := l_eff_sql || ' FROM DUAL ';
 ELSIF (l_new_from_num_intf IS NOT NULL OR l_from_num_intf IS NOT NULL) THEN
    l_eff_sql := l_eff_sql || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_UNIT_EFF'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_EFF_FROM_NUMBER'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_EFF_FROM_NUMBER'||'''), '
                           ||   p_batch_id || ', ';
    IF l_new_from_num_intf IS NOT NULL THEN
       l_eff_sql := l_eff_sql || '''' || l_new_from_num_intf || ''' , ' ;
    ELSIF  l_from_num_intf IS NOT NULL THEN
       l_eff_sql := l_eff_sql || '''' || l_from_num_intf || ''' , ' ;
    ELSE
       l_eff_sql := l_eff_sql || ' null , ' ;
    END IF;
    IF l_from_num_pdh IS NOT NULL THEN
       l_eff_sql := l_eff_sql ||  '''' || l_from_num_pdh || '''';
    ELSE
       l_eff_sql := l_eff_sql ||   ' null ' ;
    END IF;
    l_eff_sql := l_eff_sql || ' FROM DUAL '
                           || ' UNION ALL SELECT '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_UNIT_EFF'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_EFF_TO_NUMBER'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_EFF_TO_NUMBER'||'''), '
                           ||   p_batch_id || ', ';
    IF l_to_unit_num_intf IS NOT NULL THEN
       l_eff_sql := l_eff_sql || '''' || l_to_unit_num_intf || ''' , ';
    ELSE
       l_eff_sql := l_eff_sql ||  ' NULL , ' ;
    END IF;
    IF l_to_unit_num_pdh IS NOT NULL THEN
       l_eff_sql := l_eff_sql || '''' || l_to_unit_num_pdh || '''' ;
    ELSE
       l_eff_sql := l_eff_sql || ' NULL ';
    END IF;
    l_eff_sql := l_eff_sql || ' FROM DUAL ';
 ELSE
    l_eff_sql := l_eff_sql || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_EFF_DATE_CHOICE'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_EFFECTIVITY_DATE'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_EFFECTIVITY_DATE'||'''), '
                           ||   p_batch_id || ', ';
    IF l_eff_date_intf IS NOT NULL THEN
       l_eff_sql := l_eff_sql || '''' || FND_DATE.DATE_TO_DISPLAYDT(l_eff_date_intf) || ''' , ' ;
    ELSIF l_new_eff_date_intf IS  NOT NULL THEN
       l_eff_sql := l_eff_sql || '''' || FND_DATE.DATE_TO_DISPLAYDT(l_new_eff_date_intf) || ''' , ' ;
    ELSE
       l_eff_sql := l_eff_sql || ' NULL , ' ;
    END IF;

    IF l_eff_date_pdh IS NOT NULL THEN
       l_eff_sql := l_eff_sql || '''' || FND_DATE.DATE_TO_DISPLAYDT(l_eff_date_pdh) || '''';
    ELSE
       l_eff_sql := l_eff_sql || ' NULL '  ;
    END IF;
    l_eff_sql := l_eff_sql || ' FROM DUAL '
                           || ' UNION ALL SELECT '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_EFF_DATE_CHOICE'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_DISABLE_DATE'||'''), '
                           || ' Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_DISABLE_DATE'||'''), '
                           ||   p_batch_id || ', ' ;
   IF l_dis_date_intf IS NOT NULL THEN
      l_eff_sql := l_eff_sql || '''' || FND_DATE.DATE_TO_DISPLAYDT(l_dis_date_intf) || ''', ' ;
   ELSE
      l_eff_sql := l_eff_sql || ' NULL , ' ;
   END IF;
   IF l_dis_date_pdh IS NOT NULL THEN
      l_eff_sql := l_eff_sql || '''' || FND_DATE.DATE_TO_DISPLAYDT(l_dis_date_pdh) || '''';
   ELSE
      l_eff_sql := l_eff_sql || ' NULL ';
   END IF;
   l_eff_sql := l_eff_sql  || ' FROM DUAL ';

 END IF;

  l_attr_sql := l_eff_sql || ' UNION ALL ';


  l_attr_sql  := l_attr_sql || 'SELECT distinct(attr_group_disp_name), attr_display_name,attr_name , batch_id batch_identifier ,';--decode(attr.attr_name, ';
  l_attr_sql1  := 'SELECT grps.attr_group_disp_name, attrs.attr_display_name , attr_name , ' ;
  IF  p_ss_record_id IS NULL THEN
    l_attr_sql1  := l_attr_sql1 ||  ' null batch_identifier , decode(attrs.database_column, ';
  ELSE
    l_attr_sql1  := l_attr_sql1 ||  ' batch_id batch_identifier , decode(attrs.database_column, ';
  END IF;

  l_temp_count := 1;
  l_name_count := 1;
  FOR attr IN (SELECT * FROM bom_attrs_v)
  LOOP
   IF attr.attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
   THEN
   OPEN Get_Src_Attr(p_str_type_id,attr.attr_group_id,attr.attr_group_name);
   FETCH Get_Src_Attr  BULK COLLECT INTO l_name_table;
   CLOSE Get_Src_Attr;

   IF l_name_table.COUNT > 0 THEN

   IF l_name_count = 1 THEN
    l_attr_sql := l_attr_sql || 'decode(attr.attr_name, ';
    l_name_count := 2;
   END IF;

   BEGIN
     SELECT 'Exist'
     INTO l_dummy
     FROM  bom_cmp_usr_attr_interface BCUI
     WHERE (BCUI.comp_source_system_reference = p_ss_record_id OR BCUI.component_sequence_id = p_comp_seq_id)
     AND  ( BCUI.attr_group_id = attr.attr_group_id OR BCUI.attr_group_int_name = attr.attr_group_name)
     AND BCUI.attr_int_name = attr.attr_name
    AND   BCUI.batch_id = p_batch_id;

     IF l_dummy IS NOT NULL
     THEN

      l_attr_sql := l_attr_sql || '''' || attr.attr_name || ''',BCUA.attr_disp_value,';--(SELECT to_char(decode( ';
/*  IF SUBSTR(attr.database_column,1,LENGTH(attr.database_column)-10) = 'N' OR SUBSTR(attr.database_column,1,LENGTH(attr.database_column)-11) = 'N'
    THEN
       l_attr_sql := l_attr_sql || 'attr_value_num,null,attr_disp_value,attr_value_num)';
    END IF;
    IF SUBSTR(attr.database_column,1,LENGTH(attr.database_column)-10) = 'C' OR SUBSTR(attr.database_column,1,LENGTH(attr.database_column)-11) = 'C'
    THEN
     l_attr_sql := l_attr_sql || 'attr_value_str,null,attr_disp_value,attr_value_str)';
    END IF;
    IF SUBSTR(attr.database_column,1,LENGTH(attr.database_column)-10) = 'D' OR SUBSTR(attr.database_column,1,LENGTH(attr.database_column)-11) = 'D'
    THEN
     l_attr_sql := l_attr_sql || 'attr_value_date,null,attr_disp_value,attr_value_date)';
      END IF;*/
/*   l_attr_sql := l_attr_sql || ') from bom_cmp_usr_attr_interface where process_status <> -1 AND comp_source_system_reference = ' || ''''||
                 p_ss_record_id ||''' and ( attr_group_id = ' ||
                 attr.attr_group_id || ' or attr_group_int_name = '|| ''''||attr.attr_group_name || ''' ) and attr_int_name = ' || '''' || attr.attr_name || ''' ),';*/
  END IF;

   EXCEPTION WHEN NO_DATA_FOUND THEN
       l_attr_sql := l_attr_sql || '''' || attr.attr_name || ''',(SELECT null from dual),';
   END;

   END IF;--l_dummy not null

  ELSE
    IF attr.attr_group_type = 'BOM_COMPONENT_BASE' THEN
      l_attr_sql1 := l_attr_sql1 || '''' || attr.database_column ||  ''', to_char(src_val.' || attr.database_column || ') ,';
    END IF;
  END IF;
  END LOOP;
  IF l_name_count = 1
  THEN
  l_attr_sql := l_attr_sql || ' null src_attr_value,';
  ELSE
  l_attr_sql := SUBSTR(l_attr_sql,1,LENGTH(l_attr_sql)-1) || ' ) src_attr_value, ';-- decode(attr.attr_name, ';
  END IF;
  l_attr_sql1 := SUBSTR(l_attr_sql1,1,LENGTH(l_attr_sql1)-1) || ' ) src_attr_value, decode(attrs.database_column, ';

  l_temp_count := 1;

  FOR attr IN (SELECT * FROM bom_attrs_v )
  LOOP
    IF attr.attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
    THEN
     OPEN Get_Attr_Details(p_str_type_id,attr.attr_group_id);
   FETCH Get_Attr_Details BULK COLLECT INTO l_temp_table;
   CLOSE Get_Attr_Details;

   IF l_temp_table.COUNT > 0
   THEN

       IF l_temp_count = 1
     THEN
     l_attr_sql := l_attr_sql || ' decode(attr.attr_name, ';
     l_temp_count := 2;
     END IF;

   BEGIN
     SELECT 'Exist'
     INTO l_dummy
     FROM  bom_components_ext_b BCEB
     WHERE BCEB.component_sequence_id = p_comp_seq_id
     AND   BCEB.attr_group_id = attr.attr_group_id;

     IF l_dummy IS NOT NULL
     THEN
       l_attr_sql := l_attr_sql || '''' || attr.attr_name ||  ''' ,BCEB.' ||attr.database_column || ',';
--(SELECT to_char(' || attr.database_column || ') FROM bom_components_ext_b where component_sequence_id =  '|| p_comp_seq_id
--|| ' AND attr_group_id = ' || attr.attr_group_id || '),';
     END IF;

   EXCEPTION WHEN NO_DATA_FOUND THEN
     l_attr_sql := l_attr_sql || '''' || attr.attr_name ||  ''' ,(SELECT null from dual),';
   END;

   END IF;--l_dummy

    ELSE
      IF attr.attr_group_type = 'BOM_COMPONENT_BASE' THEN
        l_attr_sql1 := l_attr_sql1 || '''' || attr.database_column ||  ''' ,to_char(pdh_value.' || attr.database_column || '),';
      END IF;
  END IF;
  END LOOP;

  IF l_temp_count = 1
  THEN
  l_attr_sql := l_attr_sql || ' null pdh_attr_value';
  ELSE
  l_attr_sql := SUBSTR(l_attr_sql,1,LENGTH(l_attr_sql)-1) || ' ) pdh_attr_value' ;
  END IF;

  l_attr_sql1 := SUBSTR(l_attr_sql1,1,LENGTH(l_attr_sql1)-1) || ' ) pdh_attr_value' ;
  IF p_comp_seq_id IS NOT NULL
  THEN
    l_pdh_query := ' (SELECT * FROM bom_components_b WHERE component_sequence_id = :3 ) pdh_value' ;
  ELSE
    l_pdh_query := '(SELECT ';
    FOR attr IN (SELECT * FROM bom_attrs_v)
    LOOP
     IF attr.attr_group_type <> 'BOM_COMPONENTMGMT_GROUP'
     THEN
       IF attr.attr_group_type = 'BOM_COMPONENT_BASE' THEN
        l_pdh_query := l_pdh_query || ' null as ' || attr.database_column || ' ,';
       END IF;
    END IF;
    END LOOP;
    l_pdh_query := SUBSTR(l_pdh_query, 1, LENGTH(l_pdh_query)-1);
    l_pdh_query := l_pdh_query|| ' from dual ';
    l_pdh_query :=  l_pdh_query || '  ) pdh_value ';
  END IF;

  IF p_ss_record_id IS NOT NULL
  THEN
    l_src_query := '  (SELECT * FROM bom_inventory_comps_interface WHERE batch_id = :1 ' ||
                   ' AND ( (comp_source_system_reference = :2 OR component_item_number = ' || '''' || p_ss_record_id || ''' )' ||
                   ' AND interface_table_unique_id = ' || p_intf_uniq_id ||
                   ' AND organization_id = ' || p_org_id ||
                   '     ) ) src_val ,';
  ELSE
    l_src_query := '(SELECT ';
    FOR attr IN (SELECT * FROM bom_attrs_v)
    LOOP
    IF attr.attr_group_type <> 'BOM_COMPONENTMGMT_GROUP'
    THEN
      IF attr.attr_group_type = 'BOM_COMPONENT_BASE' THEN
        l_src_query := l_src_query || ' null as ' || attr.database_column || ' ,';
      END IF;
    END IF;
    END LOOP;
    l_src_query := SUBSTR(l_src_query, 1, LENGTH(l_src_query)-1);
    l_src_query := l_src_query || ' from dual ) src_val, ';
  END IF;
    IF p_comp_seq_id IS NOT NULL THEN
    l_where_clause := ' WHERE ((BCEB.component_sequence_id = :9 AND BCEB.structure_type_id = :4 AND attr.attr_group_id = BCEB.ATTR_GROUP_ID) AND (';
  ELSE
    l_where_clause := 'WHERE ((BCEB.component_sequence_id = :9 AND BCEB.structure_type_id = :4 AND 1=2 ) OR (';
  END IF;
    l_where_clause := l_where_clause || ' BCUA.batch_id = :10 AND (BCUA.comp_source_system_reference = :11 OR BCUA.component_sequence_id = :12) '
                    || ' AND BCUA.attr_int_name = attr.attr_name AND '
                    || ' BCUA.structure_type_id = '|| p_str_type_id || ' AND BCUA.attr_disp_value IS NOT NULL AND attr.attr_group_type = ' || ''''
                    || 'BOM_COMPONENTMGMT_GROUP' || ''' AND (BCUA.ATTR_GROUP_ID = '
                    || ' attr.attr_group_id  OR BCUA.attr_group_int_name = attr.attr_group_name )))';


/*  l_where_clause := ' WHERE (( BCEB.structure_type_id = :4 '
                    || ' AND attr.attr_group_type = ' || ''''|| 'BOM_COMPONENTMGMT_GROUP'|| ''' AND attr.attr_group_id = BCEB.ATTR_GROUP_ID ) OR '
                    || '(BCUA.batch_id = ' || p_batch_id ||' AND BCUA.comp_source_system_reference = ' || '''' || p_ss_record_id || ''' AND BCUA.attr_int_name = attr.attr_name AND '
                    || ' BCUA.structure_type_id = '|| p_str_type_id || ' AND BCUA.attr_disp_value IS NOT NULL AND attr.attr_group_type = ' || ''''|| 'BOM_COMPONENTMGMT_GROUP' || ''' AND (BCUA.ATTR_GROUP_ID = '
                    || ' attr.attr_group_id  OR BCUA.attr_group_int_name = attr.attr_group_name )))';*/

--dinu_log_message(l_attr_sql);
  l_attr_sql := l_attr_sql || ' FROM bom_attrs_v attr, bom_components_ext_b BCEB,bom_cmp_usr_attr_interface BCUA '||l_where_clause ;
--dinu_log_message(' FROM bom_attrs_v attr, bom_components_ext_b BCEB '||l_where_clause);

  l_attr_sql := l_attr_sql || ' UNION ALL ' || l_attr_sql1
                || ' FROM (SELECT attr_group_name,attr_group_disp_name FROM ego_attr_groups_v WHERE attr_group_type = '||''''|| 'BOM_COMPONENT_BASE' || ''' AND application_id  = 702 ORDER BY attr_group_name) grps,'
                || '(SELECT attr_name,attr_display_name,database_column,attr_group_name FROM ego_attrs_v WHERE attr_group_type = '|| ''''|| 'BOM_COMPONENT_BASE' || ''' AND application_id  = 702 ORDER BY attr_group_name) attrs,'
                || l_src_query || l_pdh_query ||
                ' WHERE attrs.attr_group_name = grps.attr_group_name';
--dinu_log_message(' UNION ALL ' );
--dinu_log_message(l_attr_sql1 );
--dinu_log_message(' FROM bom_attrs_v attr,');
--dinu_log_message(l_src_query );
--dinu_log_message(l_pdh_query );
--dinu_log_message( ' WHERE attr.attr_group_type = '|| '''' || 'BOM_COMPONENT_BASE'||'''' );
  l_attr_sql := l_attr_sql || ' UNION ALL  SELECT Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_IMPORT_REF_DESGS'||'''),null,null, ' || p_batch_id || ' batch_identifier '
                ||',bom_import_pub.get_ref_desgs(:1,:2,:3,1,:5,:6,:7,:8),bom_import_pub.get_ref_desgs(:1,:2,:3,null,:5,:6,:7,:8) from dual' ;

/*dinu_log_message(' UNION ALL  SELECT Bom_Globals.Retrieve_Message('|| '''' || 'BOM' || ''','||''''|| 'BOM_IMPORT_REF_DESGS'||'''),null,' || p_batch_id || ' batch_identifier ,';
                   ||'bom_import_pub.get_ref_desgs(:1,:2,:3,1,:5,:6,:7,:8),');*/
--dinu_log_message(' bom_import_pub.get_ref_desgs(:1,:2,:3,null,:5,:6,:7,:8) from dual' );


    l_dummy := NULL;

  IF p_ss_record_id IS NOT NULL
  THEN
    IF p_comp_seq_id IS NOT NULL
    THEN
      EXECUTE IMMEDIATE l_attr_sql bulk collect INTO  attr_grp,attr,attr_name,batch_identifier,src_attr,pdh_attr USING p_comp_seq_id,p_str_type_id,p_batch_id,
      p_ss_record_id,p_comp_seq_id,p_batch_id,
      p_ss_record_id,p_comp_seq_id,p_batch_id,p_ss_record_id,p_comp_seq_id,p_effec_date,p_op_seq_num,p_item_id,p_org_id,p_batch_id,p_ss_record_id,p_comp_seq_id,p_effec_date,p_op_seq_num,p_item_id,p_org_id;
    ELSE
      EXECUTE IMMEDIATE l_attr_sql bulk collect INTO  attr_grp,attr,attr_name,batch_identifier,src_attr,pdh_attr USING p_comp_seq_id,p_str_type_id,p_batch_id,
      p_ss_record_id,p_comp_seq_id,p_batch_id,
      p_ss_record_id,p_batch_id,p_ss_record_id,l_dummy,p_effec_date,p_op_seq_num,p_item_id,p_org_id,p_batch_id,p_ss_record_id,l_dummy,p_effec_date,p_op_seq_num,p_item_id,p_org_id;
    END IF;
  ELSE
    EXECUTE IMMEDIATE l_attr_sql bulk collect INTO  attr_grp,attr,attr_name,batch_identifier,src_attr,pdh_attr USING p_comp_seq_id,p_str_type_id,p_batch_id,p_ss_record_id,p_comp_seq_id,
    p_comp_seq_id,p_batch_id,p_ss_record_id,l_dummy,p_effec_date,p_op_seq_num,p_item_id,p_org_id,p_batch_id,p_ss_record_id,l_dummy,p_effec_date,p_op_seq_num,p_item_id,p_org_id;

    /*EXECUTE IMMEDIATE l_attr_sql bulk collect INTO  attr_grp,attr,batch_identifier,src_attr,pdh_attr USING p_str_type_id,
    p_batch_id,l_dummy,p_comp_seq_id,p_effec_date,p_op_seq_num,p_item_id,p_org_id,p_batch_id,l_dummy,p_comp_seq_id,p_effec_date,p_op_seq_num,p_item_id,p_org_id;*/

  END IF;

  l_count := attr_grp.COUNT;


  FOR i IN 1..l_count
  LOOP
    l_attr_diff.extend();
    l_attr_row.attr_grp_display_name := attr_grp(i);
    l_attr_row.attr_display_name  := attr(i);
    l_attr_row.attr_name := attr_name(i);
    l_attr_row.batch_identifier := batch_identifier(i);
    l_attr_row.src_attr_value  := src_attr(i);
    l_attr_row.pdh_attr_value  := pdh_attr(i);
    l_attr_diff(i) := l_attr_row;
  END LOOP;
  RETURN l_attr_diff;

END BOM_GET_COMP_ATTR_DATA;


  /**
   * This procedure is used by the EGO team to notify that
   * matching of all the uploaded records is over and
   * further processing can be continued.
   */
PROCEDURE Matching_Complete
(
  p_batch_id IN NUMBER
, x_return_status            IN OUT NOCOPY VARCHAR2
, x_Error_Mesg              IN OUT NOCOPY VARCHAR2
)
IS

BEGIN

BOM_IMPORT_PUB.Matching_Complete
(
  p_batch_id => p_batch_id
, x_return_status => x_return_status
, x_Error_Mesg => x_Error_Mesg
, p_init_msg_list => 'N'
, p_debug => 'N'
, p_output_dir => NULL
, p_debug_filename => NULL
);

END Matching_Complete;


  /**
   * This procedure is used by the EGO team to notify that
   * matching of all the uploaded records is over and
   * further processing can be continued.
   */
PROCEDURE Matching_Complete
(
  p_batch_id IN NUMBER
, p_init_msg_list           IN VARCHAR2
, x_return_status           IN OUT NOCOPY VARCHAR2
, x_Error_Mesg              IN OUT NOCOPY VARCHAR2
, p_debug                   IN  VARCHAR2
, p_output_dir              IN  VARCHAR2
, p_debug_filename          IN  VARCHAR2
)
IS
G_EXC_SEV_QUIT_OBJECT EXCEPTION;

l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
l_other_message   VARCHAR2(50);
l_Token_Tbl       Error_Handler.Token_Tbl_Type;
l_err_text        VARCHAR2(2000);
l_return_status   VARCHAR2(1);
l_Debug_flag      VARCHAR2(1) := p_debug;
l_source_system_id NUMBER;
l_debug BOOLEAN := FALSE;

BEGIN
  IF p_init_msg_list = 'Y'
  THEN
    Error_Handler.Initialize();
  END IF;

  IF l_debug_flag = 'Y'
  THEN
    IF trim(p_output_dir) IS NULL OR
    trim(p_output_dir) = ''
    THEN
-- IF debug is Y THEN out dir must be
-- specified

      Error_Handler.Add_Error_Token
      (  p_Message_text       =>
      'Debug is set to Y so an output directory' ||
      ' must be specified. Debug will be turned' ||
      ' off since no directory is specified'
      , p_Mesg_Token_Tbl     => l_Mesg_Token_tbl
      , x_Mesg_Token_Tbl     => l_Mesg_Token_tbl
      , p_Token_Tbl          => l_Token_Tbl
      );
      l_debug_flag := 'N';
    END IF;

    IF trim(p_debug_filename) IS NULL OR
    trim(p_debug_filename) = ''
    THEN
      Error_Handler.Add_Error_Token
      (  p_Message_text       =>
      'Debug is set to Y so an output filename' ||
      ' must be specified. Debug will be turned' ||
      ' off since no filename is specified'
      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
      , p_Token_Tbl          => l_token_tbl
      );
      l_debug_flag := 'N';
    END IF;
    BOM_Globals.Set_Debug(l_debug_flag);

    IF BOM_Globals.Get_Debug = 'Y'
    THEN
      Error_Handler.Open_Debug_Session
      (  p_debug_filename     => p_debug_filename
      , p_output_dir         => p_output_dir
      , x_return_status      => l_return_status
      , p_mesg_token_tbl     => l_mesg_token_tbl
      , x_mesg_token_tbl     => l_mesg_token_tbl
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        l_debug_flag := 'N';
      END IF;
    END IF;
  END IF;

  Bom_Globals.Set_Debug(l_debug_flag);

  /*IF NOT Does_Batch_Exist(p_batch_id)
  THEN
    l_other_message := 'BOM_BATCH_NOT_VALID';
    l_Token_Tbl(1).token_name := 'BATCH_ID';
    l_Token_Tbl(1).token_value := p_batch_id;
    RAISE G_EXC_SEV_QUIT_OBJECT;
  END IF;*/

    IF Error_Handler.Get_Debug <> 'Y' THEN
      l_debug := Init_Debug();
    ELSE
      l_debug := TRUE;
    END IF;

   Write_Debug('after validatng batch_ id in Matching Complete');

/*  BEGIN
    SELECT
      source_system_id
    INTO
      l_source_system_id
    FROM
      ego_import_batches_b
    WHERE
      batch_id = p_batch_id;

  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      l_other_message := 'BOM_SOURCE_SYSTEM_INVALID';
      l_Token_Tbl(1).token_name := 'BATCH_ID';
      l_Token_Tbl(1).token_value := p_batch_id;
      RAISE G_EXC_SEV_QUIT_OBJECT;
  END;
*/
  Write_Debug('Calling Update Match Data');

  UPDATE_MATCH_DATA
  (
  p_batch_id => p_batch_id,
  p_source_system_id => NULL,
  x_Mesg_Token_Tbl => l_Mesg_Token_Tbl,
  x_Return_Status => l_return_status
  );
  IF l_return_status <> 'S'
  THEN
    Error_Handler.Add_Error_Token
      (
        p_message_name => NULL
      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
      , p_Token_Tbl          => l_token_tbl
      );

  END IF;

  /*Write_Debug('after updating match data before update_bill_info');


  UPDATE_BILL_INFO
  (
  p_batch_id => p_batch_id,
  x_Mesg_Token_Tbl => l_Mesg_Token_Tbl,
  x_Return_Status => l_return_status
  );

  IF l_return_status <> 'S'
  THEN
    Error_Handler.Add_Error_Token
      (
        p_message_name => NULL
      , p_Mesg_Token_Tbl     => l_mesg_token_tbl
      , x_Mesg_Token_Tbl     => l_mesg_token_tbl
      , p_Token_Tbl          => l_token_tbl
      );
  END IF;

  Write_Debug('after updating bill info');*/

  x_Return_Status := l_Return_Status;
  -- As the Concurrent Manager is now using connection pooling adding
  -- the commit to explicitly commit the matching complete changes.
  COMMIT;

  EXCEPTION
  WHEN G_EXC_SEV_QUIT_OBJECT THEN

     Error_Handler.Add_Error_Token
      (
        p_message_name => NULL
      , p_Mesg_token_Tbl => l_Mesg_Token_Tbl
      , x_Mesg_token_Tbl => l_Mesg_Token_Tbl
      , p_token_Tbl => l_Token_Tbl
      , p_message_type => 'E'
      );
    x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
    x_Error_Mesg := l_other_message;

    IF Bom_Globals.Get_Debug = 'Y'
    THEN
      Error_Handler.Write_Debug('After getting exception for invalid batch id');
      Error_Handler.Write_To_DebugFile;
      Error_Handler.Dump_Message_List;
      Error_Handler.Close_Debug_Session;
    END IF;

END Matching_Complete;





FUNCTION get_G_MISS_NUM
RETURN NUMBER
IS
 BEGIN
 RETURN FND_API.G_MISS_NUM;

END get_G_MISS_NUM;

FUNCTION get_G_MISS_CHAR RETURN VARCHAR
IS
BEGIN
RETURN FND_API.G_MISS_CHAR;

END get_G_MISS_CHAR;

FUNCTION get_G_MISS_DATE RETURN DATE
IS
BEGIN
RETURN FND_API.G_MISS_DATE;

END get_G_MISS_DATE;

FUNCTION get_ref_desgs
  (
    p_batch_id    IN NUMBER
  , p_comp_rec_id IN VARCHAR2
  , p_comp_seq_id IN NUMBER
  , p_mode        IN NUMBER
  , p_effec_date  IN DATE
  , p_op_seq_num  IN NUMBER
  , p_item_id     IN NUMBER
  , p_org_id      IN NUMBER
  )RETURN VARCHAR2
  IS
   CURSOR c_src_ref_desg ( p_batch_id IN NUMBER,p_ss_ref IN VARCHAR2,p_comp_seq_id IN NUMBER)
   IS
   SELECT component_reference_designator
   FROM bom_ref_desgs_interface
   WHERE batch_id = p_batch_id
   AND ( (   (comp_source_system_reference = p_ss_ref OR component_item_number = p_ss_ref OR component_item_id = p_item_id )
        -- AND effectivity_date = p_effec_date
        -- AND operation_seq_num = p_op_seq_num
         AND organization_id = p_org_id
        )
        OR component_sequence_id = p_comp_seq_id
       )
    AND process_flag <> -1
   ORDER BY 1 DESC;

   CURSOR c_pdh_ref_desg (p_comp_seq_id IN NUMBER)
   IS
   SELECT component_reference_designator
   FROM bom_reference_designators
   WHERE component_sequence_id = p_comp_seq_id
   ORDER BY 1 DESC;

   l_ref_desg VARCHAR2(32000);
 BEGIN
        IF p_mode = 1
  THEN
        l_ref_desg := NULL;
        FOR c IN c_src_ref_desg(p_batch_id => p_batch_id,p_ss_ref =>p_comp_rec_id,p_comp_seq_id => p_comp_seq_id)
        LOOP
                l_ref_desg := c.component_reference_designator || ',' || l_ref_desg;
        END LOOP;
        IF (l_ref_desg IS NOT NULL) THEN
          l_ref_desg := SUBSTR(l_ref_desg, 1, LENGTH(l_ref_desg) - 1);
        END IF;
        RETURN l_ref_desg;
  ELSE
   l_ref_desg := NULL;
        FOR c IN c_pdh_ref_desg(p_comp_seq_id => p_comp_seq_id)
        LOOP
                l_ref_desg := c.component_reference_designator || ',' || l_ref_desg;
        END LOOP;
        IF (l_ref_desg IS NOT NULL) THEN
          l_ref_desg := SUBSTR(l_ref_desg, 1, LENGTH(l_ref_desg) - 1);
        END IF;
        RETURN l_ref_desg;
    END IF;

END get_ref_desgs;

PROCEDURE Update_User_Attr_Data
  (
    p_batch_id           IN NUMBER
  , p_transaction_id     IN NUMBER
  , p_comp_seq_id        IN NUMBER
  , p_bill_seq_id        IN NUMBER
  , p_call_Ext_Api       IN VARCHAR2
  , p_parent_id          IN NUMBER
  , p_org_id             IN NUMBER
  , x_Return_Status      IN OUT NOCOPY VARCHAR2
  , x_Error_Text         IN OUT NOCOPY VARCHAR2
  )
 IS

 l_comp_id  NUMBER;
 l_org_id  NUMBER;
 l_txn_type VARCHAR2(1000);

 TYPE  bom_cmp_usr_type    IS  TABLE OF bom_cmp_usr_attr_interface%ROWTYPE;

 l_attr_table    bom_cmp_usr_type;
 l_debug         BOOLEAN := false;
 l_return_status VARCHAR2(1);
 l_err_text      VARCHAR2(5000);
 l_count         NUMBER;
 l_comp_seq_id   NUMBER := p_comp_seq_id;
 l_err_code      NUMBER;
 l_msg_count     NUMBER;
 l_user_name     FND_USER.USER_NAME%TYPE := FND_GLOBAL.USER_NAME;
 l_gz_party_id   VARCHAR2(30);
 l_bill_seq_id   NUMBER := p_bill_seq_id;
 l_comp_name     VARCHAR2(100);
 l_parent_name   VARCHAR2(100);
 l_target_sql    VARCHAR2(1000);
 l_add_class     VARCHAR2(1000);
 l_edit_prvlg    VARCHAR2(20);
 l_par_edit_prvlg VARCHAR2(10);
 l_parent_id     NUMBER;

 /*Cursor c_get_attr_group_id (p_data_set_id in number) is
 select distinct efd.attr_group_id,
                 efd.descriptive_flex_context_code attr_group_name,
                 efd.descriptive_flexfield_name attr_group_type,
                 bcua.structure_type_id
 from ego_fnd_dsc_flx_ctx_ext efd,
       bom_cmp_usr_attr_interface bcua
 where efd.application_id = 702
 and efd.descriptive_flexfield_name = 'BOM_COMPONENTMGMT_GROUP'
 and efd.descriptive_flex_context_code = bcua.attr_group_int_name
 and bcua.data_set_id = p_data_set_id;


 Cursor c_get_attr_value (p_data_set_id in number,p_attr_grp_int_name in varchar2,p_row_identifier in number) is
 Select bcu.attr_int_name attr_int_name,
        decode(efc.data_type,'C',bcu.attr_value_str,
                             'N',bcu.attr_value_num,
                             'D',bcu.attr_value_date,null) attr_value,
        bcu.attr_disp_value,
        efc.data_type data_type
 from
 bom_cmp_usr_attr_interface bcu,
 fnd_descr_flex_column_usages fd,
 ego_fnd_df_col_usgs_ext efc
 where
 bcu.data_set_id = p_data_set_id
 and bcu.attr_group_int_name = p_attr_grp_int_name
 and bcu.row_identifier = p_row_identifier
 and efc.descriptive_flex_context_code = bcu.attr_group_int_name
 and efc.application_id = 702
 and efc.descriptive_flexfield_name = 'BOM_COMPONENTMGMT_GROUP'
 and fd.application_id = efc.application_id
 and fd.descriptive_flexfield_name = efc.descriptive_flexfield_name
 and fd.descriptive_flex_context_code = efc.descriptive_flex_context_code
 and fd.application_column_name = efc.application_column_name
 and fd.end_user_column_name = bcu.attr_int_name;

 Cursor c_get_row_identifier(p_data_set_id number,p_attr_grp_int_name in varchar2)is
 Select distinct row_identifier
 from bom_cmp_usr_attr_interface
 where
 data_set_id = p_data_set_id
 and attr_group_int_name = p_attr_grp_int_name;
 */
 l_curr_data_element                 EGO_USER_ATTR_DATA_OBJ;
 l_curr_pk_col_name_val_element      EGO_COL_NAME_VALUE_PAIR_OBJ;
 l_attributes_data_table             EGO_USER_ATTR_DATA_TABLE;
 l_pk_column_name_value_pairs        EGO_COL_NAME_VALUE_PAIR_ARRAY;
 l_error_col_name_pairs              EGO_COL_NAME_VALUE_PAIR_ARRAY;
 i                                   NUMBER;
 l_error_attr_name                   VARCHAR2(2000);
 l_dynamic_sql                       VARCHAR2(2000);
 l_attr_group_name                   VARCHAR2(250);
 l_error_message                     VARCHAR2(250);
 l_err_token_table                   ERROR_HANDLER.Token_Tbl_Type;
 --l_com_error_status                  VARCHAR2(1);

 BEGIN

   -- l_debug := Init_Debug();

   IF p_call_Ext_Api <> 'T' THEN
   -- write_debug('In Update User Attr');

    IF l_comp_seq_id IS NULL THEN

       SELECT component_sequence_id
       INTO l_comp_seq_id
       FROM bom_inventory_comps_interface
       WHERE batch_id = p_batch_id
       AND (process_flag = 1 OR process_flag = 5)
       AND transaction_id = p_transaction_id;
     END IF;

    IF l_bill_seq_id IS NULL THEN

     SELECT bill_sequence_id
     INTO l_bill_seq_id
     FROM bom_inventory_comps_interface
     WHERE batch_id = p_batch_id
     AND (process_flag = 1 OR process_flag = 5)
     AND transaction_id = p_transaction_id;
   END IF;

   IF ( p_transaction_id IS NOT NULL OR p_comp_seq_id IS NOT NULL )THEN

     SELECT component_item_number,assembly_item_number,component_item_id,organization_id,UPPER(transaction_type)
     INTO l_comp_name,l_parent_name,l_comp_id,l_org_id,l_txn_type
     FROM bom_inventory_comps_interface
     WHERE batch_id = p_batch_id
     AND (process_flag = 1 or process_flag = 5)
     AND (component_sequence_id = p_comp_seq_id OR transaction_id = p_transaction_id);
   END IF;


/*
 * we need to update the pks here as the Insert_Default_Val_Rows ext api checks for these pks before inserting the default rows.
 * if we dont update the pks , then in case we have some rows for some attrs in the excel and if that attr has default values, ext
 * api will once again insert the default rows.Also we need to update the attr group id.
 */


 UPDATE bom_cmp_usr_attr_interface BCUA
 SET component_sequence_id = l_comp_seq_id,
     bill_sequence_id = l_bill_seq_id,
     process_status = 2,
     attr_group_id = (select attr_group_id from EGO_FND_DSC_FLX_CTX_EXT where application_id = 702 and DESCRIPTIVE_FLEXFIELD_NAME = 'BOM_COMPONENTMGMT_GROUP' and DESCRIPTIVE_FLEX_CONTEXT_CODE = BCUA.attr_group_int_name),
     attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
 WHERE (BCUA.data_set_id = p_batch_id  or BCUA.batch_id = p_batch_id )
 AND BCUA.process_status NOT in (3,4)
 AND (   (BCUA.component_sequence_id = l_comp_seq_id)
       OR (BCUA.component_sequence_id  IS NULL
       AND BCUA.item_number = l_comp_name
       AND BCUA.assembly_item_number = l_parent_name
       AND BCUA.transaction_id = p_transaction_id)
      );
 /**
  * Only for new component creation use the attribute default logic.
  */
 IF l_txn_type = 'CREATE' THEN

     /* The target sql should give the pk values,class code and data level values to Ext API.
      * We have them in this context and so no need to query them again
      */
 /* vggarg Bug 7640305 PIM4TELCO - Backward Compatibility Project - added default value of data level id and context id*/
     l_target_sql := 'SELECT ' || l_comp_seq_id || ' component_sequence_id , ' || l_bill_seq_id ||
     ' bill_sequence_id, ' || pG_batch_options.structure_type_id ||
     ' structure_type_id , null DATA_LEVEL_COLUMN, 70201 DATA_LEVEL_ID, null CONTEXT_ID, '|| p_transaction_id || ' transaction_id  FROM dual  ';
 /* vggarg Bug 7640305 start */

     l_add_class := 'SELECT bst.structure_type_id FROM BOM_STRUCTURE_TYPES_B bst START WITH bst.structure_type_id = ' || pG_batch_options.structure_type_id || '  CONNECT BY PRIOR bst.parent_structure_type_id = bst.structure_type_id ';


     EGO_USER_ATTRS_BULK_PVT.Insert_Default_Val_Rows (
      p_api_version => 1.0
     ,p_application_id  => 702
     ,p_attr_group_type => 'BOM_COMPONENTMGMT_GROUP'
     ,p_object_name => 'BOM_COMPONENTS'
     ,p_interface_table_name => 'BOM_CMP_USR_ATTR_INTERFACE'
     ,p_data_set_id => p_batch_id
     ,p_target_entity_sql => l_target_sql
     ,p_additional_class_Code_query => l_add_class
     ,p_commit => 'T'
     ,x_return_status => l_return_status
     ,x_msg_data  => l_err_text
     );
  END IF;

 /*
  * Update comp_item_id and org_id.Otherwise ext bulkload will fail for privilege check.We check for
  * Edit item and View Item privileges.For this we need the comp ids and org ids.
  */

 UPDATE bom_cmp_usr_attr_interface
 SET   component_item_id = l_comp_id,
       organization_id = l_org_id,
       attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
 WHERE (data_set_id = p_batch_id  or batch_id = p_batch_id )
 AND (   (component_sequence_id = l_comp_seq_id)
      OR (component_sequence_id  IS NULL
      AND item_number = l_comp_name
      AND assembly_item_number = l_parent_name
      AND transaction_id = p_transaction_id)
     );

ELSE

    IF l_user_name IS NOT NULL THEN
      SELECT 'HZ_PARTY:'||TO_CHAR(PERSON_ID)
      INTO l_gz_party_id
      FROM ego_people_v
      WHERE  USER_NAME = l_user_name;
    END IF;


/*    IF l_bill_seq_id IS NOT NULL THEN
     UPDATE bom_cmp_usr_attr_interface
     SET process_status = 2
     WHERE data_set_id = p_batch_id
     AND bill_sequence_id = l_bill_seq_id
     AND process_status = 0;
    END IF;*/

    /*
     * When the parent item has edit item privilege , even if there's no edit privilege on the  component
     * the user attributes should be processed.
     */

    l_edit_prvlg := 'EGO_EDIT_ITEM';
    l_par_edit_prvlg := null;

    /*IF l_bill_seq_id IS NOT NULL THEN
       SELECT assembly_item_id,organization_id
       INTO l_parent_id,l_org_id
       FROM bom_structures_b
       WHERE bill_sequence_id = l_bill_seq_id;*/
     IF p_parent_id IS NOT NULL AND p_org_id IS NOT NULL THEN
       l_par_edit_prvlg := EGO_DATA_SECURITY.CHECK_FUNCTION(1.0,'EGO_EDIT_ITEM','EGO_ITEM',p_parent_id,p_org_id,null,null,null,l_gz_party_id);
    END IF;

    IF nvl(l_par_edit_prvlg,'F') = 'T' THEN
       l_edit_prvlg := null;
    END IF;

    /*--
    -- Code to call common API to validate Seeded
    -- Telco Attributes
    -- Telco Library validation is commented as it was
    -- decided not to provide/support validations for this attributes.

    -- IF (nvl(fnd_profile.value('EGO_ENABLE_P4T'),'N') = 'Y') THEN
    --
    --  l_com_error_status := 'S';
    --
    --  FOR c_attr_grp IN c_get_attr_group_id (p_batch_id )
    --  LOOP
    --
    --    IF (EGO_COM_ATTR_VALIDATION.Is_Attribute_Group_Telco(c_attr_grp.attr_group_name,c_attr_grp.attr_group_type)) THEN
    --      l_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();
    -- 	  FOR c_curr_row_identfier IN c_get_row_identifier (p_batch_id,c_attr_grp.attr_group_name)
    --    LOOP

    --        FOR c_attr_value IN c_get_attr_value (p_batch_id ,c_attr_grp.attr_group_name,c_curr_row_identfier.row_identifier)
    --        LOOP

    --          IF (c_attr_value.data_type = 'C') THEN

    --            l_curr_data_element := EGO_USER_ATTR_DATA_OBJ(c_curr_row_identfier.row_identifier
    --                                , c_attr_value.attr_int_name
    --                                , nvl(c_attr_value.attr_value,c_attr_value.attr_disp_value)
    --                                , NULL
    --                                , NULL
    --                                , NULL
    --                                , NULL
    --                                , NULL
    --                                );

    --            l_attributes_data_table.EXTEND();
    --            l_attributes_data_table(l_attributes_data_table.LAST) := l_curr_data_element;

    --          ELSIF (c_attr_value.data_type = 'N') THEN

    --            l_curr_data_element := EGO_USER_ATTR_DATA_OBJ(c_curr_row_identfier.row_identifier
    --                                , c_attr_value.attr_int_name
    --                                , NULL
    --                                , nvl(c_attr_value.attr_value,c_attr_value.attr_disp_value)
    --                                , NULL
    --                                , NULL
    --                                , NULL
    --                                , NULL
    --                                );

    --            l_attributes_data_table.EXTEND();
    --            l_attributes_data_table(l_attributes_data_table.LAST) := l_curr_data_element;

    --          ELSIF (c_attr_value.data_type = 'C') THEN

    --            l_curr_data_element := EGO_USER_ATTR_DATA_OBJ(c_curr_row_identfier.row_identifier
    --                              , c_attr_value.attr_int_name
    --                              , NULL
    --                              , NULL
    --                              , nvl(c_attr_value.attr_value,c_attr_value.attr_disp_value)
    --                              , NULL
    --                              , NULL
    --                              , NULL
    --                               );

    --            l_attributes_data_table.EXTEND();
    --        l_attributes_data_table(l_attributes_data_table.LAST) := l_curr_data_element;

    --          END IF;

    --        END LOOP;

    --        l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY (
    --            EGO_COL_NAME_VALUE_PAIR_OBJ('BILL_SEQUENCE_ID', l_bill_Seq_id)
    --           ,EGO_COL_NAME_VALUE_PAIR_OBJ('STRUCTURE_TYPE_ID', c_attr_grp.structure_type_id)
    --           ,EGO_COL_NAME_VALUE_PAIR_OBJ('COMPONENT_SEQUENCE_ID',l_comp_seq_id));


    --        EGO_COM_ATTR_VALIDATION.Validate_Attributes
    --          (p_attr_group_type             => 'BOM_COMPONENTMGMT_GROUP'
    --          ,p_attr_group_name             => c_attr_grp.attr_group_name
    --          ,p_attr_group_id               => c_attr_grp.attr_group_id
    --          ,p_attr_name_value_pairs       => l_attributes_data_table
    --          ,p_pk_column_name_value_pairs  => l_pk_column_name_value_pairs
    --          ,x_return_status               => l_return_status
    --          ,x_error_messages              => l_error_col_name_pairs);

    --        IF (l_return_status = 'E' ) THEN

    --          l_com_error_status := 'E';

    --          IF ( l_error_col_name_pairs.count > 0) THEN
    --
    --            FOR i IN l_error_col_name_pairs.FIRST .. l_error_col_name_pairs.LAST
    --            LOOP
    --              -- Update the Attributes with the error message
    --              -- in interface table
    --              IF (l_error_col_name_pairs(i).NAME = 'ATTR_INT_NAME') THEN

    --                IF (l_error_attr_name is NULL) THEN
    --                  l_error_attr_name := ''''||l_error_col_name_pairs(i).VALUE||'''';
    --                ELSE
    --                  l_error_attr_name := l_error_attr_name || ','||'''' ||l_error_col_name_pairs(i).VALUE||'''';
    --                END IF;

    --              ELSIF (l_error_col_name_pairs(i).NAME = 'ERROR_MESSAGE_NAME') THEN
    --
    --                l_error_message := l_error_col_name_pairs(i).VALUE;
    --
    --              ELSIF (l_error_col_name_pairs(i).NAME = 'ATTR_GROUP_NAME') THEN
    --
    --                l_attr_group_name := l_error_col_name_pairs(i).VALUE;
    --
    --              END IF;
    --
    --            END LOOP;

    --            -- Log error messages

    --            l_error_attr_name := '  ('||l_error_attr_name||')';

    --            l_dynamic_sql :=
    --	              'UPDATE  bom_cmp_usr_attr_interface '||
    --                ' SET PROCESS_STATUS = '||G_COM_VALDN_FAIL||
    --	              ' WHERE DATA_SET_ID = '||p_batch_id||
    --	              ' AND ATTR_INT_NAME in '||l_error_attr_name||
    --	              ' AND row_identifier = '||c_curr_row_identfier.row_identifier;

    --                EXECUTE IMMEDIATE l_dynamic_sql;

    --                l_err_token_table(1).token_name  := 'ATTR_GROUP_NAME';
    --                l_err_token_table(1).token_value := l_attr_group_name;


    --               ERROR_HANDLER.Add_Error_Message
    --                  (p_message_name              => l_error_message
    --               ,p_application_id            => 'EGO'
    --               ,p_token_tbl                 => l_err_token_table
    --               ,p_message_type              => 'E'
    --               ,p_row_identifier            =>  NULL
    --               ,p_entity_id                 =>  NULL
    --               ,p_entity_index              =>  NULL
    --               ,p_table_name                => 'BOM_CMP_USR_ATTR_INTERFACE'
    --               ,p_entity_code               =>  NULL
    --               );


    --             ERROR_HANDLER.Log_Error
    --               (p_write_err_to_inttable    => 'Y'
    --               ,p_write_err_to_conclog     => 'Y'
    --               ,p_write_err_to_debugfile   => ERROR_HANDLER.Get_Debug()
    --               );
    --
    --             -- Calling commit to save data into interface errors table
    --             commit;

    --            END IF;

    --          END IF;

    --        END LOOP; -- row identifier loop

    --      END IF;

    --    END LOOP; -- AG loop

    --END IF; */

    EGO_USER_ATTRS_BULK_PVT.Bulk_Load_User_Attrs_Data
    (
      p_api_version => 1.0
    , p_application_id => 702
    , p_attr_group_type => 'BOM_COMPONENTMGMT_GROUP'
    , p_object_name => 'BOM_COMPONENTS'
    , p_hz_party_id => l_gz_party_id
    , p_interface_table_name => 'BOM_CMP_USR_ATTR_INTERFACE'
    , p_data_set_id => p_batch_id
    , p_related_class_codes_query => 'SELECT bst.structure_type_id FROM BOM_STRUCTURE_TYPES_B bst START WITH bst.structure_type_id = UAI2.STRUCTURE_TYPE_ID CONNECT BY PRIOR bst.parent_structure_type_id = bst.structure_type_id '
    , p_init_fnd_msg_list => 'F'
    , p_log_errors => 'T'
    , p_add_errors_to_fnd_stack => 'T'
    , p_commit => 'T'
    , p_default_view_privilege => 'EGO_VIEW_ITEM'
    , p_default_edit_privilege => l_edit_prvlg
    , p_privilege_predicate_api_name => 'Bom_Import_Pub.Get_Item_Security_Predicate'
    , p_validate => true
    , p_do_dml => true
    , x_return_status => l_return_status
    , x_errorcode => l_err_code
    , x_msg_count => l_msg_count
    , x_msg_data => l_err_text
   );

   -- If the bulkload is successfull then we need to update the process_status of
   -- interface rows to 4 , so that if again uploaded these rows are not processed.
   -- our processing cycle is for each header, so updating the process_status for processed headers

   IF  l_return_status = 'S' THEN
    UPDATE bom_cmp_usr_attr_interface
    SET  process_status = 4
    WHERE ( data_set_id = p_batch_id or batch_id = p_batch_id)
    AND process_status = 2
    AND bill_sequence_id = l_bill_seq_id;
   END IF;

END IF;

/*IF (nvl(l_return_status,'S') = 'S' and l_com_error_status = 'E') THEN
  x_Return_Status := l_com_error_status;
ELSE
  x_Return_Status := l_return_status;
  x_Error_Text    := l_err_text;
END IF;
*/

  x_Return_Status := l_return_status;
  x_Error_Text    := l_err_text;

EXCEPTION
WHEN OTHERS THEN
 x_Return_Status := 'U';
 x_Error_Text := SUBSTR(SQLERRM, 1, 200);

 END Update_User_Attr_Data;

/************************************************************************
* Procedure: Data_Upload_Complete
* Purpose  : This method will be called by users after uploading batch data
*            in bom interface tables.
*             This will do the following steps
*                1.  Resolve the XREFs for existing cross references
*                2.  Call Item APIs to upload unmatched data
*                  a.  IF unmatched items are inserted Notify
*                      Item Ego Data Upload Complete API
*                3.  Check Batch for Options - IF automated call import
**************************************************************************/

  PROCEDURE Data_Upload_Complete
  (  p_batch_id                   IN  NUMBER
   , x_error_message              OUT NOCOPY VARCHAR2
   , x_return_code                OUT NOCOPY VARCHAR2
  )
  IS
  BEGIN
   BOM_IMPORT_PUB.DATA_UPLOAD_COMPLETE
   (
    p_batch_id => p_batch_id,
    x_Error_Mesg => x_error_message,
    p_init_msg_list => 'N',
    x_return_status  => x_return_code,
    p_debug => 'N',
    p_output_dir  => NULL,
    p_debug_filename => NULL
  );

  END Data_Upload_Complete;

/************************************************************************
* Procedure: IMPORT_STRUCTURE_DATA
* Purpose  : This method will be called by users after uploading batch data
*            in bom interface tables.

**************************************************************************/
  PROCEDURE IMPORT_STRUCTURE_DATA
  (
      p_batch_id              IN NUMBER
    , p_items_import_complete IN VARCHAR2
    , p_callFromJCP           IN VARCHAR2
    , p_request_id            IN NUMBER
    , x_error_message         OUT NOCOPY VARCHAR2
    , x_return_code           OUT NOCOPY VARCHAR2
  )
  IS
    l_debug BOOLEAN := FALSE;
    l_request_id  NUMBER;
    l_Mesg_Token_Tbl     Error_Handler.Mesg_Token_Tbl_Type;
  BEGIN

    --Update the Batch Record for reference
    IF Error_Handler.get_debug = 'Y' THEN
      l_debug := TRUE;
    ELSE
      l_debug := Init_Debug();
    END IF;

    Retrieve_Batch_Options(p_batch_id => p_batch_id,
                           x_Mesg_Token_Tbl => l_Mesg_Token_Tbl,
                           x_error_code => x_return_code);

    Write_Debug(' Calling the PRE_PROCESS_IMPORT_ROWS with p_batch_id ' || p_batch_id || ' item_complt ' ||p_items_import_complete );

    PRE_PROCESS_IMPORT_ROWS
    (   p_batch_id          => p_batch_id
      , x_error_message   => x_error_message
      , p_items_import_complete => p_items_import_complete
      , x_return_code     => x_return_code
      , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
    );

    Write_Debug('After PRE_PROCESS_IMPORT_ROWS with ret code-'||x_return_code);

    Write_Debug('p_callFromJCP -'|| p_callFromJCP);

    IF (p_callFromJCP = 'Y') THEN
      RETURN;
    ELSE
--      Call to launch the Java Concurrent Program - is this required??
      IF (p_request_id IS NOT NULL) THEN
        l_request_id :=  p_request_id;
      END IF;
      Write_Debug('Launching JCP p_items_import_complete='||p_items_import_complete);

      IF (p_items_import_complete = 'T') THEN

        l_request_id := Fnd_Request.Submit_Request(
                      application => G_APP_SHORT_NAME,
                      program     => 'BOMJCP',
                      sub_request => FALSE,
                      argument1   => l_request_id,
                      argument2   => p_batch_id);
        Write_Debug('Launched JCP with rqst id-'||l_request_id);
      END IF;
    END IF;



    --IF nto we will launch the JCP

    --(Once JCP is done - it will call our procedure for UA
    -- Propagate the failures or update the ids
    --JCP will actually kick off the User Attributes Stuff)

  END IMPORT_STRUCTURE_DATA;


/************************************************************************
* Procedure: PRE_PROCESS_IMPORT_ROWS
* Purpose  : This method will be called by users after uploading batch data
*            in bom interface tables.
 Check Rows in MTL_INTERFACES WITH SAME BATCH ID
         AND PROCESS_FLAG 1
          IF (EXISTS) THEN
            NOTIFY ITEMS DATA LOAD.
          ELSE
            RUN XREF-MATCHES
            IF ANY UNMATCHED RECORDS THEN
              INSERT INTO ITEMS AND NOTIFY ITEMS DATALOAD
            ELSE
              CALL BOM JCP
            END IF;
          END IF;
          Update the bill information - Call Dinu's API
          UPdate IF change required  to 5.
*************************************************************************/

  PROCEDURE PRE_PROCESS_IMPORT_ROWS
  (
    p_batch_id         IN NUMBER
  , p_items_import_complete IN VARCHAR2
  , x_error_message      OUT NOCOPY VARCHAR2
  , x_return_code        OUT NOCOPY VARCHAR2
  , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
  )
  IS
    l_item_infcrows_exists NUMBER;
  BEGIN
    --Already Updated the Batch Record for reference
    x_return_code := NULL;

    Write_Debug('Inside pre_preocess_import starting process batch options');

    Process_Batch_Options(p_batch_id => p_batch_id);

    IF (pG_batch_options.PDH_BATCH = 'Y') THEN
      Write_Debug('Returning as this is a pdh batch');
      RETURN;
    END IF;

    Write_Debug('p_items_import_complete = ' || p_items_import_complete);

    IF (p_items_import_complete = 'T')
    THEN
     -- Update Cross References
      Write_Debug('Resolving X-REfs');
      RESOLVE_XREFS_FOR_BATCH
      (
         p_batch_id   => p_batch_id
        ,x_Mesg_Token_Tbl     => x_Mesg_Token_Tbl
        ,x_Return_Status      => x_return_code
      );

      Write_Debug('After Resolving X-REfs with ret code = ' || x_return_code);


      IF (x_return_code = 'E') THEN
       RETURN;
      END IF;
      -- Propagate confirmation status

      Write_Debug('Propagating Confirm Status');

      PROPAGATE_CONFIRMATION_STATUS
      (
        p_batch_id        => p_batch_id
      , x_error_message   => x_error_message
      , x_return_code     => x_return_code
      );
      IF (x_return_code = 'E') THEN
       --handle error
        RETURN;
      END IF;
      -- finally Call BOM JCP
    ELSE
      SELECT COUNT(*) INTO l_item_infcrows_exists FROM
      (   SELECT
        'X'
      FROM
        mtl_system_items_interface
      WHERE EXISTS
        (SELECT
          process_flag
         FROM
          mtl_system_items_interface
        WHERE
            set_process_id = p_batch_id
        AND process_flag = 1
        UNION ALL
        SELECT
          process_flag
         FROM
          mtl_item_revisions_interface
        WHERE
            set_process_id = p_batch_id
        AND process_flag = 1) ) QRSLT;

      IF (l_item_infcrows_exists = 1) THEN
          --logMessage_forsnell('Call Item API?? - Verifying');
          NULL;
      ELSE
        -- Update Cross References
        RESOLVE_XREFS_FOR_BATCH
        (
           p_batch_id   => p_batch_id
          ,x_Mesg_Token_Tbl     => x_Mesg_Token_Tbl
          ,x_Return_Status      => x_return_code
        );

        IF (pG_batch_options.IMPORT_XREF_ONLY <> 'Y')
        THEN
                --logMessage_forsnell('Import NON Xrefs also');
          --check IF dinu has one??
          Write_Debug('INSERT INTO ITEMS AND NOTIFY ITEMS DATALOAD AND NOTIFY ITEMS');
          /*  IF ANY UNMATCHED RECORDS THEN   INSERT INTO ITEMS AND NOTIFY ITEMS DATALOAD AND NOTIFY ITEMS */
          NULL;
        END IF; -- Import Xrefs Only
      END IF;  -- IF item interface rows exist
    END IF;    -- ELSE of item import complete

    --commenting this out as matching complete already has this call
/*    Update_Bill_Info
    (
        p_batch_id => p_batch_id
      , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
      , x_Return_Status => x_Return_code
     );*/

   --Change Management Check
   Process_Batch_Options(p_batch_id => p_batch_id);

  EXCEPTION
    WHEN OTHERS THEN
      --logMessage_forsnell('reching here p_organization_id' || SQLERRM);
      x_Return_code := 'E';

  END PRE_PROCESS_IMPORT_ROWS;

/************************************************************************
* Procedure: PROPAGATE_CONFIRMATION_STATUS
* Purpose  : This method will propagate the confirmation status for
*            the import rows from EGO tables to Structure Entities
* Program Logic:  For all Unconfirmed and Excluded Items do not process
*                 their children For all uncofirmed children do not process
*                 their Parent
*                 The above is accomplished by setting the id columns to null
*****************************************************************************/
  PROCEDURE PROPAGATE_CONFIRMATION_STATUS
  (
    p_batch_id         IN NUMBER
  , x_error_message      OUT NOCOPY VARCHAR2
  , x_return_code        OUT NOCOPY VARCHAR2
  )
  IS
  /* Cursor to select confirm_status 'E' and 'U' rows for all Item Rows */
    CURSOR Item_Intf_NotReadyCr IS
    SELECT
      source_system_reference,
      inventory_item_id,
      organization_id,
      confirm_status,
      process_flag
    FROM
      mtl_system_items_interface
    WHERE
      set_process_id = p_batch_id
      AND  confirm_status IN ('US','UM','UN','EX');

    CURSOR Item_Intf_ReadyCr IS
    SELECT
      source_system_reference,
      inventory_item_id,
      organization_id,
      confirm_status,
      process_flag
    FROM
      mtl_system_items_interface
    WHERE
      set_process_id = p_batch_id
      AND  confirm_status IN ('CC','CM','CN');

  BEGIN
    x_return_code := NULL;


    /* we also need to propagate if a row got confirmed later from an
       unconfirmed or excluded state */

    FOR iicr IN Item_Intf_ReadyCr
    LOOP --iicr cursor loop start
    -- Update Bill of materials for Unconfirmed and Excluded
      UPDATE
        bom_bill_of_mtls_interface
      SET
        process_flag = 1
      WHERE
          batch_id = p_batch_id
      AND source_system_reference = iicr.source_system_reference
      AND process_flag = 0;

   -- Update Bill of materials for Unconfirmed Children
      UPDATE
        bom_bill_of_mtls_interface   bmi
      SET
        process_flag = 1
      WHERE
            bmi.batch_id = p_batch_id
        AND bmi.process_flag = 0
        AND bmi.source_system_reference =
          ( SELECT DISTINCT
              bci.parent_source_system_reference
            FROM   bom_inventory_comps_interface bci
            WHERE
                bci.batch_id = p_batch_id
            AND bci.comp_source_system_reference =  iicr.source_system_reference
            AND iicr.confirm_status in ('CC','CM','CN'));
   -- Update Components for Unconfirmed and Excluded
      UPDATE
        bom_inventory_comps_interface
      SET
        process_flag = 1
      WHERE
            batch_id = p_batch_id
       and  process_flag = 0
      AND (   comp_source_system_reference = iicr.source_system_reference
           OR parent_source_system_reference = iicr.source_system_reference);
     --Update other Entities here
    END LOOP; --iicr cursor loop end


    FOR iicr IN Item_Intf_NotReadyCr
    LOOP --iicr cursor loop start
    -- Update Bill of materials for Unconfirmed and Excluded
      UPDATE
        bom_bill_of_mtls_interface
      SET
        process_flag = 0
      WHERE
          batch_id = p_batch_id
      AND source_system_reference = iicr.source_system_reference
      AND process_flag = 1;

   -- Update Bill of materials for Unconfirmed Children
      UPDATE
        bom_bill_of_mtls_interface   bmi
      SET
        process_flag = 0
      WHERE
            bmi.batch_id = p_batch_id
        AND bmi.process_flag = 1
        AND bmi.source_system_reference =
          ( SELECT DISTINCT
              bci.parent_source_system_reference
            FROM   bom_inventory_comps_interface bci
            WHERE
                bci.batch_id = p_batch_id
            AND bci.comp_source_system_reference =  iicr.source_system_reference
            AND iicr.confirm_status in ('US','UM','UN'));
   -- Update Components for Unconfirmed and Excluded
      UPDATE
        bom_inventory_comps_interface
      SET
        process_flag = 0
      WHERE
            batch_id = p_batch_id
       and  process_flag = 1
      AND (   comp_source_system_reference = iicr.source_system_reference
           OR parent_source_system_reference = iicr.source_system_reference);
     --Update other Entities here
    END LOOP; --iicr cursor loop end


  END PROPAGATE_CONFIRMATION_STATUS;

/**
 * Concurrent Program Replacement for BMCOIN
 * @param p_batch_id Batch Identifier for the batch being Imported
 * @param x_error_message Error Message
 * @param x_return_code Return code holding return status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Pre-Process Import Rows
 */
  PROCEDURE Import_Interface_Rows
  (
    x_err_buffer            OUT NOCOPY     VARCHAR2,
    x_return_code           OUT NOCOPY     VARCHAR2,
    p_organization_id       IN      NUMBER,
    p_all_organization      IN      VARCHAR2,
    p_import_routings       IN      VARCHAR2,
    p_import_bills          IN      VARCHAR2,
    p_delete_rows           IN      VARCHAR2,
    p_batch_id              IN      NUMBER
  )
  IS
    l_error_code VARCHAR2(1);
    l_error_message VARCHAR2(3000);
    l_return_code NUMBER;
    l_batch_metadata_exists NUMBER := NULL;
    l_conc_status BOOLEAN;
  BEGIN
    IF (p_batch_id IS NOT NULL) THEN
     SELECT batch_id INTO l_batch_metadata_exists FROM
         EGO_IMPORT_BATCHES_B
         WHERE BATCH_ID = p_batch_id;
      IF (l_batch_metadata_exists IS NOT  NULL) THEN
         x_return_code := 'E';
         x_err_buffer := FND_MESSAGE.GET_STRING(G_APP_SHORT_NAME,'BOM_BATCH_EXIST');
         FND_FILE.put_line(FND_FILE.LOG, x_err_buffer);
         RETURN;
      END IF;
    END IF;

     l_return_code := BOMPOPIF.bmopinp_open_interface_process(
            org_id => p_organization_id,
            all_org => p_all_organization,
            val_rtg_flag => p_import_routings,
            val_bom_flag => p_import_bills,
            pro_rtg_flag => p_import_routings,
            pro_bom_flag => p_import_bills,
            del_rec_flag => p_delete_rows,
            prog_appid => FND_GLOBAL.prog_appl_id,
            prog_id => FND_GLOBAL.conc_program_id,
            request_id => FND_GLOBAL.conc_request_id,
            user_id => FND_GLOBAL.login_id,
            login_id => FND_GLOBAL.login_id,
            p_batch_id =>  p_batch_id,
            err_text => x_err_buffer);
  --logMessage_forsnell('after import' || l_return_code );

      --bug:5235742 Change the concurrent program completion status. Set warning, if
      --some of the entities errored out during delete.
      IF ( l_return_code = 0 ) THEN
         x_return_code := '0';
         Fnd_Message.Set_Name('INV','INV_STATUS_SUCCESS');
         x_err_buffer := Fnd_Message.Get;
      ELSIF ( l_return_code = 1 ) THEN
         x_return_code := '1';
         Fnd_Message.Set_Name('BOM','BOM_CONC_REQ_WARNING');
         x_err_buffer := Fnd_Message.Get;
      ELSE
         x_return_code := '2';
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      l_return_code := BOMPOPIF.bmopinp_open_interface_process(
            org_id => p_organization_id,
            all_org => p_all_organization,
            val_rtg_flag => p_import_routings,
            val_bom_flag => p_import_bills,
            pro_rtg_flag => p_import_routings,
            pro_bom_flag => p_import_bills,
            del_rec_flag => p_delete_rows,
            prog_appid => FND_GLOBAL.prog_appl_id,
            prog_id => FND_GLOBAL.conc_program_id,
            request_id => FND_GLOBAL.conc_request_id,
            user_id => FND_GLOBAL.login_id,
            login_id => FND_GLOBAL.login_id,
            p_batch_id =>  p_batch_id,
            err_text => x_err_buffer);

          IF ( l_return_code = 0 ) THEN
             x_return_code := '0';
             Fnd_Message.Set_Name('INV','INV_STATUS_SUCCESS');
             x_err_buffer := Fnd_Message.Get;
          ELSIF ( l_return_code = 1 ) THEN
             x_return_code := '1';
             Fnd_Message.Set_Name('BOM','BOM_CONC_REQ_WARNING');
             x_err_buffer := Fnd_Message.Get;
          ELSE
             x_return_code := '2';
          END IF;

  END Import_Interface_Rows;

 /**
  * This is the procedure for updating the Bill with item names
  * for a Pdh Batch Import.IF it is a Pdh Batch Import this
  * API will be called and this API will do the id to val
  * conversion  IF needed.This will also populate the
  * source_system_reference with the Item Names or Component
  * names.This is for the Structure Import UI to show the
  * details of the batch even for a Pdh Batch Import which will
  * not have any source_system_reference.
  */

  PROCEDURE Update_Bill_Val_Id
  (
  p_batch_id               IN NUMBER
, x_return_status            IN OUT NOCOPY VARCHAR2
, x_Error_Mesg              IN OUT NOCOPY VARCHAR2
)
  IS

  G_EXC_SEV_QUIT_OBJECT EXCEPTION;

  TYPE num_type IS TABLE OF NUMBER;
  TYPE var_type IS TABLE OF VARCHAR2(1000);
  TYPE date_type IS TABLE OF DATE;

  l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type;
  l_other_message   VARCHAR2(50);
  l_Token_Tbl       Error_Handler.Token_Tbl_Type;
  l_err_text        VARCHAR2(2000);
  l_return_status   VARCHAR2(1);
  l_message_list           Error_Handler.Error_Tbl_Type;
--  l_debug_flag      VARCHAR2(1) := p_debug;
  l_debug BOOLEAN := FALSE;


  l_comp_item_id_table num_type;
  l_head_item_id_table num_type;
  l_org_id_table num_type;
  l_bill_seq_table num_type;
  l_op_seq_table num_type;
  l_head_name_table var_type;
  l_comp_name_table var_type;
  l_alt_desg_table var_type;
  l_org_code_table var_type;
  l_effectivity_table date_type;
  l_count NUMBER;
  l_comp_seq_table num_type;

  l_request_id NUMBER;

  CURSOR Get_Header(p_batch_id IN NUMBER)
  IS
  SELECT assembly_item_id,organization_id,bill_sequence_id,alternate_bom_designator,item_number,organization_code
  FROM   bom_bill_of_mtls_interface
  WHERE  batch_id = p_batch_id
  --AND    (process_flag = 1 OR process_flag = 5)
  AND    (assembly_item_id IS NOT NULL OR item_number IS NOT NULL);

  CURSOR Get_Comps(p_batch_id IN NUMBER)
  IS
  SELECT BICI.component_item_id,BICI.organization_id,BICI.bill_sequence_id,BBMI.assembly_item_id,decode(BICI.operation_seq_num,null,
         BICI.new_operation_seq_num,BICI.operation_seq_num),decode(BICI.effectivity_date,null,BICI.new_effectivity_date,BICI.effectivity_date),
         BICI.component_item_number,BICI.assembly_item_number,BICI.organization_code,BICI.component_sequence_id
  FROM bom_inventory_comps_interface BICI,
       bom_bill_of_mtls_interface BBMI
  WHERE BBMI.batch_id = p_batch_id
  AND BICI.batch_id = BBMI.batch_id
  --AND (BBMI.process_flag = 1 OR BBMI.process_flag = 5)
  --AND (BICI.process_flag = 1 OR BICI.process_flag = 5)
  AND   (BICI.bill_sequence_id = BBMI.bill_sequence_id OR BICI.assembly_item_id = BBMI.assembly_item_id OR BICI.assembly_item_number = BBMI.item_number)
  AND   (BICI.component_item_id IS NOT NULL OR BICI.component_item_number IS NOT NULL);


  BEGIN
    update_transaction_ids(p_batch_id);

    IF Error_Handler.Get_Debug <> 'Y' THEN
     l_debug := Init_Debug();
    ELSE
     l_debug := TRUE;
    END IF;

    Write_Debug('Inside Upd_Bill_Val before Retr Batch Options');


    Retrieve_Batch_Options(p_batch_id,l_Mesg_Token_Tbl,l_return_status);

    IF l_return_status <> 'S'
    THEN
     RAISE G_EXC_SEV_QUIT_OBJECT;
    END IF;

    /*calling the OI util method for pre processing all entities*/
    --l_request_id :=  Bom_Open_Interface_Utl.Process_All_Entities(1,1, -1, -1, -1, -1,null,l_err_text,p_batch_id);

    Write_Debug('Fetching the Header');


    OPEN Get_Header(p_batch_id);
    FETCH Get_Header BULK COLLECT INTO l_head_item_id_table,l_org_id_table,l_bill_seq_table,l_alt_desg_table,l_head_name_table,l_org_code_table;
    CLOSE Get_Header;

    l_count := l_head_item_id_table.COUNT;

    FOR i IN 1..l_count
    LOOP

    BEGIN

     IF  l_org_id_table(i) IS NULL
     THEN
      SELECT organization_id
      INTO l_org_id_table(i)
      FROM mtl_parameters
      WHERE organization_code = l_org_code_table(i);
     END IF;

     IF l_head_item_id_table(i) IS NULL
     THEN
      SELECT inventory_item_id
      INTO l_head_item_id_table(i)
      FROM mtl_system_items_kfv
      WHERE concatenated_segments = l_head_name_table(i)
      AND organization_id = l_org_id_table(i);
     END IF;

    --do we need this....?
     IF l_head_name_table(i) IS NULL
     THEN
        SELECT concatenated_segments
        INTO   l_head_name_table(i)
        FROM mtl_system_items_vl
        WHERE inventory_item_id = l_head_item_id_table(i)
        AND organization_id = l_org_id_table(i);
      END IF;

      EXCEPTION WHEN NO_DATA_FOUND THEN
       --No data found  is because its a new item creation.So dont do anything
       NULL;

      END;

     Write_Debug('Updating the Header with Ids');

     IF pG_batch_options.PDH_BATCH = 'Y' THEN
        UPDATE bom_bill_of_mtls_interface
        SET source_system_reference = l_head_name_table(i),
            item_number = l_head_name_table(i),
            assembly_item_id = l_head_item_id_table(i),
            organization_id = l_org_id_table(i)
        WHERE ((assembly_item_id = l_head_item_id_table(i)  AND   organization_id = l_org_id_table(i)) OR (item_number = l_head_name_table(i) AND organization_code = l_org_code_table(i)))
        AND   NVL(alternate_bom_designator,'Primary') = NVL(l_alt_desg_table(i),'Primary')
        --AND (process_flag = 1 OR process_flag = 5)
        AND   batch_id = p_batch_id;
     ELSE
        UPDATE bom_bill_of_mtls_interface
        SET item_number = l_head_name_table(i),
            assembly_item_id = l_head_item_id_table(i),
            organization_id = l_org_id_table(i)
        WHERE ((assembly_item_id = l_head_item_id_table(i)  AND   organization_id = l_org_id_table(i)) OR (item_number = l_head_name_table(i) AND organization_code = l_org_code_table(i)))
        AND   NVL(alternate_bom_designator,'Primary') = NVL(l_alt_desg_table(i),'Primary')
        AND (process_flag = 1 OR process_flag = 5)
        AND   batch_id = p_batch_id;
     END IF;

    END LOOP;--Loop for header ends here

    Write_Debug('Fetching the Comps');

    OPEN Get_Comps(p_batch_id);
    FETCH Get_Comps BULK COLLECT INTO l_comp_item_id_table,l_org_id_table,l_bill_seq_table,l_head_item_id_table,l_op_seq_table,l_effectivity_table,l_comp_name_table,l_head_name_table,l_org_code_table,l_comp_seq_table;
    CLOSE Get_Comps;

    l_count := l_comp_item_id_table.COUNT;

    FOR i IN 1..l_count
    LOOP

    BEGIN

    IF l_org_id_table(i) IS NULL
    THEN
      SELECT organization_id
      INTO l_org_id_table(i)
      FROM mtl_parameters
      WHERE organization_code = l_org_code_table(i);
    END IF;

    IF l_comp_item_id_table(i) IS NULL
    THEN
      SELECT inventory_item_id
      INTO l_comp_item_id_table(i)
      FROM mtl_system_items_kfv
      WHERE concatenated_segments = l_comp_name_table(i)
      AND organization_id = l_org_id_table(i);
    END IF;

    IF l_comp_name_table(i) IS NULL
    THEN
    SELECT concatenated_segments
    INTO l_comp_name_table(i)
    FROM mtl_system_items_vl
    WHERE inventory_item_id = l_comp_item_id_table(i)
    AND organization_id = l_org_id_table(i);
    END IF;

    IF l_head_item_id_table(i) IS NULL
     THEN
      SELECT inventory_item_id
      INTO l_head_item_id_table(i)
      FROM mtl_system_items_kfv
      WHERE concatenated_segments = l_head_name_table(i)
      AND organization_id = l_org_id_table(i);
     END IF;

-- do we need this ....?
    IF l_head_name_table(i) IS NULL
    THEN
      SELECT concatenated_segments
      INTO l_head_name_table(i)
      FROM mtl_system_items_vl
      WHERE inventory_item_id = l_head_item_id_table(i)
      AND organization_id = l_org_id_table(i);
    END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      --No data found  is because its a new item creation.So dont do anything
      NULL;
    END;

    Write_Debug('Updating the Comps-- ' ||l_comp_name_table(i) );
    Write_Debug('With Parent -- ' || l_head_name_table(i));

    IF pG_batch_options.PDH_BATCH = 'Y' THEN
      UPDATE bom_inventory_comps_interface
      SET comp_source_system_reference = l_comp_name_table(i),
          parent_source_system_reference = l_head_name_table(i),
          component_item_number = l_comp_name_table(i),
          component_item_id = l_comp_item_id_table(i),
          assembly_item_number  = l_head_name_table(i),
          assembly_item_id = l_head_item_id_table(i),
          organization_id = l_org_id_table(i)
      WHERE ((component_item_id = l_comp_item_id_table(i) AND   organization_id = l_org_id_table(i)) OR (component_item_number = l_comp_name_table(i) AND organization_code = l_org_code_table(i)))
         AND (assembly_item_id = l_head_item_id_table(i) OR assembly_item_number = l_head_name_table(i))
         --AND (process_flag = 1 OR process_flag = 5)
       --AND new_operation_seq_num = l_op_seq_table(i)
       --AND new_effectivity_date = l_effectivity_table(i)
         AND batch_id = p_batch_id;
    ELSE
      UPDATE bom_inventory_comps_interface
      SET component_item_number = l_comp_name_table(i),
          component_item_id = l_comp_item_id_table(i),
          assembly_item_number  = l_head_name_table(i),
          assembly_item_id = l_head_item_id_table(i),
          organization_id = l_org_id_table(i)
      WHERE ((component_item_id = l_comp_item_id_table(i) AND   organization_id = l_org_id_table(i)) OR (component_item_number = l_comp_name_table(i) AND organization_code = l_org_code_table(i)))
         AND (assembly_item_id = l_head_item_id_table(i) OR assembly_item_number = l_head_name_table(i))
         AND (process_flag = 1 OR process_flag = 5)
       --AND new_operation_seq_num = l_op_seq_table(i)
       --AND new_effectivity_date = l_effectivity_table(i)
         AND batch_id = p_batch_id;
     END IF;

    UPDATE bom_ref_desgs_interface
    SET component_sequence_id = l_comp_seq_table(i),
        component_item_id = l_comp_item_id_table(i),
        organization_id = l_org_id_table(i),
        assembly_item_id = l_head_item_id_table(i)
    WHERE batch_id = p_batch_id
    AND ((component_item_number = l_comp_name_table(i) AND organization_code = l_org_code_table(i) ) OR (component_item_id = l_comp_item_id_table(i) AND organization_id = l_org_id_table(i)))
    AND (assembly_item_number = l_head_name_table(i) OR assembly_item_id = l_head_item_id_table(i) )
    AND nvl(operation_seq_num,1) = nvl(l_op_seq_table(i),1)
    AND nvl(effectivity_date,sysdate) = nvl(l_effectivity_table(i),sysdate)
    AND component_sequence_id IS NULL;

    END LOOP; --Loop for comps ends here.

    /*
     * For a PDH batch IF the user comes to the UI THEN
     * we will not have the bill_seq_id and comp_seq_id
     * So calling the Update_Bill_Info so that when the
     * user comes to the UI we'll have all the data
     * to show.
    */

    Write_Debug('Calling the Update Bill Info');

    IF pG_batch_options.STRUCTURE_CONTENT <> 'A' THEN


    BOM_IMPORT_PUB.UPDATE_BILL_INFO
     (
        p_batch_id => p_batch_id
      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
      , x_Return_Status => l_Return_Status
     );
    END IF;

     x_Return_Status := l_Return_Status;
     IF x_Return_Status <> 'S' THEN
     Error_Handler.Get_Message_List( x_message_list => l_message_list);
     x_Error_Mesg := l_message_list(1).Message_Text;
     END IF;

     EXCEPTION
      WHEN G_EXC_SEV_QUIT_OBJECT THEN

      Error_Handler.Add_Error_Token
      (
        p_message_name => NULL
      , p_Mesg_token_Tbl => l_Mesg_Token_Tbl
      , x_Mesg_token_Tbl => l_Mesg_Token_Tbl
      , p_token_Tbl => l_Token_Tbl
      , p_message_type => 'E'
      );

    x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
    Error_Handler.Get_Message_List( x_message_list => l_message_list);
    x_Error_Mesg := l_message_list(1).Message_Text;

  END Update_Bill_Val_Id;




PROCEDURE Update_Confirmed_Items
  (
    p_batch_id IN NUMBER
  , p_ssRef_varray IN VARCHAR2_VARRAY
  , x_Error_Message IN OUT NOCOPY VARCHAR2
  , x_Return_Status IN OUT NOCOPY VARCHAR2
  )
  IS
  TYPE var_type IS TABLE OF VARCHAR2(1000);
  l_head_ref_table var_type;
  l_count NUMBER;
 l_item_id NUMBER;

  BEGIN

  IF p_ssRef_varray IS NOT NULL
  THEN
   l_count := p_ssRef_varray.FIRST;
   IF l_count >= 1
   THEN
    FOR i IN 1..l_count
    LOOP
   SELECT inventory_item_id
  INTO l_item_id
  FROM mtl_system_items_interface
  WHERE set_process_id = p_batch_id
  AND source_system_reference = p_ssRef_varray(i);

  --Update the header

     UPDATE bom_bill_of_mtls_interface
     SET assembly_item_id = l_item_id
     WHERE batch_id = p_batch_id
     AND source_system_reference = p_ssRef_varray(i);

 -- Update the comps

     UPDATE bom_inventory_comps_interface BICI
     SET component_item_id = l_item_id
     WHERE batch_id = p_batch_id
     AND comp_source_system_reference = p_ssRef_varray(i);

    END LOOP;--varray loop ends here
   END IF;
  END IF;

  END Update_Confirmed_Items;

/*
*  Function will check the internal value is PRIMARY_UI
*  value from BOM_GLOBALS and return the display name for
*  primary structure Name
*/
FUNCTION Get_Primary_StructureName
  (p_struct_Internal_Name     IN VARCHAR2)
  RETURN VARCHAR2
IS
  l_primary_internal VARCHAR2(50) := BOM_GLOBALS.GET_PRIMARY_UI;
  l_primary_display VARCHAR2(50) := bom_globals.RETRIEVE_MESSAGE('BOM','BOM_PRIMARY');
BEGIN
  IF ((p_struct_Internal_Name IS NULL) OR (p_struct_Internal_Name = l_primary_internal)) THEN
    RETURN l_primary_display;
  ELSE
    RETURN p_struct_Internal_Name;
  END IF;
END Get_Primary_StructureName;

PROCEDURE Check_Change_Options
(
  p_batch_id    IN NUMBER,
  x_error_code IN OUT NOCOPY VARCHAR2,
  x_Mesg_Token_Tbl IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
)
IS
TYPE num_type IS TABLE OF NUMBER;
l_bill_seq_table num_type;
l_change_policy  VARCHAR2(500);
l_change_flag    VARCHAR2(1);
l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl      Error_Handler.Token_Tbl_Type;

CURSOR Get_Bill_Seq_Id
IS
SELECT bill_sequence_id
FROM bom_bill_of_mtls_interface
WHERE batch_id = p_batch_id;

CURSOR Get_Change_Option
IS
SELECT add_all_to_change_flag
FROM ego_import_option_sets
WHERE batch_id = p_batch_id;

BEGIN

    OPEN Get_Change_Option;
    FETCH Get_Change_Option INTO l_change_flag;
    CLOSE Get_Change_Option;

    OPEN Get_Bill_Seq_Id;
    FETCH Get_Bill_Seq_Id BULK COLLECT INTO l_bill_seq_table;
    CLOSE Get_Bill_Seq_Id;

    FOR i IN 1..l_bill_seq_table.COUNT LOOP

    IF l_change_flag = 'N' OR l_change_flag IS NULL THEN
      l_change_policy := Bom_Globals.Get_Change_Policy_Val(l_bill_seq_table(i),NULL);
      IF l_change_policy = 'NOT_ALLOWED'  THEN
          -- Thorw error
          Error_Handler.Add_Error_Token
              (
                p_message_name => 'BOM_CHANGES_NOT_ALLOWED'
              , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
              , p_Token_Tbl          => l_Token_Tbl
              );
              x_error_code := 'E';
              x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
      ELSIF l_change_policy = 'CHANGE_ORDER_REQUIRED' THEN
            l_change_flag := 'Y';
      END IF;
      IF l_change_flag = 'Y' THEN
          --Update the Header rows with process flag = 5
            UPDATE Bom_Bill_Of_Mtls_Interface
            SET process_flag = 5
            WHERE batch_id = p_batch_id
            AND bill_sequence_id = l_bill_seq_table(i);

         -- Update the direct Component rows with process Flag = 5
            UPDATE Bom_Inventory_Comps_Interface
            SET Process_Flag  = 5
            WHERE batch_id = p_batch_id
            AND bill_sequence_id = l_bill_seq_table(i);
     END IF;
    END IF;
   END LOOP;
END Check_Change_Options;

PROCEDURE PROCESS_ALL_COMPS_BATCH
(
   p_batch_id IN NUMBER
 , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status         IN OUT NOCOPY VARCHAR2
)
IS
  TYPE  bom_comp_intf_type  IS  TABLE OF bom_inventory_comps_interface%ROWTYPE;
  TYPE  bom_comp_type  IS TABLE OF bom_components_b%ROWTYPE;
  TYPE num_type IS TABLE OF NUMBER;
  TYPE var_type IS TABLE OF VARCHAR2(1000);
  l_err_text VARCHAR2(1000);
  l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
  l_comp_seq_id NUMBER;
  l_header_count NUMBER;
  l_comp_count NUMBER;
  l_comp_seq_count NUMBER;
  l_bill_seq_id NUMBER;
  l_effec_ctrl NUMBER;
  l_txn_table var_type;
  l_org_id NUMBER;
  l_header_rec_table var_type;
  l_str_name   var_type;
  l_comp_table bom_comp_intf_type;
  l_comp_pdh_table bom_comp_type;
  l_unmatch_comp bom_comp_type;
  l_item_id_table num_type;
  l_org_id_table num_type;
  l_not_exist BOOLEAN;
  l_exist_table num_type;
  l_str_type_id NUMBER;
  l_debug BOOLEAN := FALSE;
  l_org_code_table var_type;
  l_unmatch_count NUMBER;
  l_bill_sequence_id NUMBER;
  l_comp_match_found BOOLEAN;
  l_par_eff_date DATE;
  l_req_id_table num_type;
  l_bundle_id_table num_type;

  CURSOR Get_Header(l_batch_id IN NUMBER)
  IS
  SELECT
    BBMI.assembly_item_id,BBMI.organization_id,BBMI.alternate_bom_designator,BBMI.source_system_reference,UPPER(BBMI.transaction_type),request_id,bundle_id
  FROM bom_bill_of_mtls_interface BBMI
  WHERE batch_id = l_batch_id
  AND process_flag NOT IN (3,7,-1,0);

  CURSOR  Process_Header(l_batch_id IN NUMBER,l_item_id IN NUMBER,l_org_id IN NUMBER,l_name IN VARCHAR2)
  IS
  SELECT
    BSB.bill_sequence_id,BSB.effectivity_control,BSB.organization_id
  FROM
        bom_bill_of_mtls_interface BBMI,
        bom_Structures_b BSB
  WHERE
    BBMI.batch_id = l_batch_id
    AND BBMI.process_flag NOT IN (3,7,-1,0)
    AND BSB.assembly_item_id = l_item_id
    AND BSB.organization_id = l_org_id
    AND NVL(BSB.alternate_bom_designator,'Y') = NVL(l_name,'Y');

  CURSOR Process_Comp(l_batch_id IN NUMBER,p_parent_reference IN VARCHAR2)
  IS
  SELECT *
  FROM bom_inventory_comps_interface BICI
  WHERE batch_id = l_batch_id
  AND process_flag NOT IN(3,7,0,-1)
  AND parent_source_system_reference = p_parent_reference;


  CURSOR Process_Unmatched_Comps(l_bill_seq_id IN NUMBER)
  IS
  SELECT *
  FROM Bom_Components_B BCB
  WHERE BCB.bill_sequence_id = l_bill_seq_id;

BEGIN

  --logMessage_forsnell(' Inside New method' || 2933);

  IF Error_Handler.get_debug <> 'Y' THEN
    l_debug := Init_Debug;
  ELSE
    l_debug := TRUE;
  END IF;

  write_debug('In Process_All_Comp_Batch');
  write_debug('Calling update_bill_val');
  Update_Bill_Val_Id
  (
    p_batch_id => p_batch_id
  , x_return_status => x_Return_Status
  , x_Error_Mesg  =>  l_err_text
  );

  write_debug('After updating bill val--ret_status--' || x_Return_Status);
  write_debug('After updating bill val --err_text--' || l_err_text);

  OPEN Get_Header(p_batch_id);
  FETCH Get_Header BULK COLLECT INTO l_item_id_table,l_org_id_table,l_str_name,l_header_rec_table,l_txn_table,l_req_id_table,l_bundle_id_table;
  CLOSE Get_Header;

  l_header_count := l_header_rec_table.COUNT;

  FOR i IN 1..l_header_count
  LOOP    --Header Loop

    write_debug('Updating the Bill for Header '|| l_header_rec_table(i));
    l_bill_seq_id := NULL;

    BEGIN
     IF l_org_id_table(i) IS NULL THEN
       SELECT organization_id
       INTO l_org_id_table(i)
       FROM mtl_parameters
       WHERE organization_code = l_org_code_table(i);
     END IF;


     IF l_item_id_table(i) IS NULL THEN
       SELECT inventory_item_id
       INTO l_item_id_table(i)
       FROM mtl_system_items_vl
       WHERE concatenated_segments = l_header_rec_table(i)
       AND organization_id = l_org_id_table(i);
     END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL; --new item creation
   END;

    IF l_item_id_table(i) IS NOT NULL AND l_org_id_table(i) IS NOT NULL
    THEN
      OPEN Process_Header(p_batch_id,l_item_id_table(i),l_org_id_table(i),l_str_name(i));
      FETCH Process_Header INTO l_bill_seq_id,l_effec_ctrl,l_org_id;
      CLOSE Process_Header;
    END IF;

    write_debug('pG_batch_options.PDH_BATCH--' || pG_batch_options.PDH_BATCH);
    write_debug('pG_batch_options.STRUCTURE_CONTENT--' || pG_batch_options.STRUCTURE_CONTENT);
    write_debug('bill sequence_id --' || l_bill_seq_id);
    write_debug('header rec --' || l_header_rec_table(i) );

    OPEN Process_Comp(p_batch_id,l_header_rec_table(i));
    FETCH Process_Comp BULK COLLECT INTO l_comp_table;
    CLOSE Process_Comp;

    l_comp_count := l_comp_table.COUNT;

    write_debug('intf comp count--' || l_comp_count);

    FOR  j IN 1..l_comp_count
    LOOP
      l_comp_table(j).bill_sequence_id := l_bill_seq_id;
      IF l_comp_table(j).component_sequence_id IS NULL
      THEN

         BEGIN
           IF l_comp_table(j).component_item_id IS NULL THEN
             SELECT inventory_item_id
             INTO l_comp_table(j).component_item_id
             FROM mtl_system_items_vl
             WHERE concatenated_segments = l_comp_table(j).comp_source_system_reference
             AND organization_id = l_org_id_table(i);
           END IF;
           EXCEPTION WHEN NO_DATA_FOUND THEN
            NULL; -- new item creation
         END;

        l_comp_seq_id  := CHECK_COMP_EXIST(l_bill_seq_id,
                                           l_effec_ctrl,
                                           p_batch_id,
                                           l_comp_table(j).comp_source_system_reference,
                                           l_comp_table(j).component_item_id,
                                           l_org_id_table(i),
                                           l_item_id_table(i)
                                          );
        write_debug('comp seq id after check_comp' || l_comp_seq_id);
        IF(l_comp_seq_id <> 0) THEN
          l_comp_table(j).component_sequence_id := l_comp_seq_id;
        END IF;
      END IF;
    END LOOP;

    OPEN Process_Unmatched_Comps(l_bill_seq_id);
    FETCH Process_Unmatched_Comps BULK COLLECT INTO l_comp_pdh_table;
    CLOSE Process_Unmatched_Comps;

    l_comp_seq_count := l_comp_pdh_table.COUNT;

    write_debug('pdh cmp count--' || l_comp_seq_count );
    IF(l_comp_count >= l_comp_seq_count)
    THEN

      FOR j IN 1..l_comp_count
      LOOP
        FOR k IN 1..l_comp_seq_count
        LOOP
          l_bill_sequence_id := Check_Header_Exists(l_comp_pdh_table(k).component_item_id,l_org_id_table(i),l_str_name(i));
          IF l_bill_sequence_id IS NOT NULL THEN
             IF NOT  Header_Not_In_Intf(l_bill_sequence_id,l_comp_pdh_table(k).component_item_id,l_org_id_table(i),l_str_name(i),p_batch_id,l_req_id_table(i),l_bundle_id_table(i)) THEN
                OPEN Process_Unmatched_Comps(l_bill_sequence_id);
                FETCH Process_Unmatched_Comps BULK COLLECT INTO l_unmatch_comp;
                CLOSE Process_Unmatched_Comps;

                l_unmatch_count := l_unmatch_comp.COUNT;

                FOR m in 1..l_unmatch_count LOOP
                  IF l_unmatch_comp(m).disable_date IS NULL  OR (l_unmatch_comp(m).disable_date IS NOT NULL AND l_unmatch_comp(m).disable_date > sysdate) THEN
                     INSERT INTO
                      bom_inventory_comps_interface
                      (
                        component_item_id,
                        organization_id,
                        component_sequence_id,
                        bill_sequence_id,
                        parent_source_system_reference,
                        batch_id,
                        transaction_type,
                        disable_date,
                        process_flag,
                        component_item_number,
                        assembly_item_number,
                        organization_code,
                        alternate_bom_designator,
                        assembly_item_id,
                        transaction_id
                      )
                    VALUES
                    (
                      l_unmatch_comp(m).component_item_id,
                      l_org_id_table(i),
                      l_unmatch_comp(m).component_sequence_id,
                      l_unmatch_comp(m).bill_sequence_id,
                      (SELECT concatenated_segments FROM mtl_system_items_vl MSIVL
                       WHERE MSIVL.inventory_item_id = l_comp_pdh_table(k).component_item_id
                       AND organization_id = l_org_id_table(i)),
                      p_batch_id,
                      'DELETE',
                      SYSDATE,
                      1,
                      (SELECT concatenated_segments FROM mtl_system_items_vl WHERE inventory_item_id =  l_unmatch_comp(m).component_item_id AND organization_id = l_org_id_table(i)),
                      (SELECT concatenated_segments FROM mtl_system_items_vl WHERE inventory_item_id = l_comp_pdh_table(k).component_item_id AND organization_id = l_org_id_table(i)),
                      (SELECT organization_code FROM mtl_parameters WHERE organization_id = l_org_id_table(i)),
                      l_str_name(i),
                      l_comp_pdh_table(k).component_item_id,
                      MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
                    );

                    Disable_Refds
                     (
                       p_batch_id => p_batch_id,
                       p_comp_seq_id => l_unmatch_comp(m).component_sequence_id,
                       p_comp_id => l_unmatch_comp(m).component_item_id,
                       p_parent_id => l_comp_pdh_table(k).component_item_id,
                       p_eff_date  => l_unmatch_comp(m).effectivity_date,
                       p_op_seq_num  => l_unmatch_comp(m).operation_seq_num,
                       p_org_id => l_org_id_table(i)
                     );

                  END IF; -- Disable Date Null
                END LOOP;
             END IF; -- Header Not In Intf
          END IF; -- Bill Seq Null
          IF (l_comp_table(j).component_item_id = l_comp_pdh_table(k).component_item_id
              AND l_comp_table(j).organization_id = l_org_id_table(i)
              AND l_comp_table(j).assembly_item_id = l_item_id_table(i))
          THEN
            l_comp_match_found := false;

            IF l_comp_table(j).parent_revision_code IS NOT NULL THEN
              SELECT effectivity_date
              INTO l_par_eff_date
              from mtl_item_revisions
              WHERE inventory_item_id = l_comp_table(j).assembly_item_id
              AND organization_id = l_comp_table(j).organization_id
              AND revision = l_comp_table(j).parent_revision_code;
            END IF;
            /*
             If no effectivity info is given then match the component based on either parent rev or current eff date
            */
            IF pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 1 THEN
              IF l_comp_table(j).effectivity_date IS NULL AND l_comp_table(j).new_effectivity_date IS NULL THEN -- when no eff info
                 IF l_comp_table(j).parent_revision_code IS NOT NULL AND l_par_eff_date > sysdate THEN -- check for parent rev eff if provided
                    IF (l_par_eff_date >= l_comp_pdh_table(k).effectivity_date   AND (l_comp_pdh_table(k).disable_date IS NULL OR  l_comp_pdh_table(k).disable_date >= l_par_eff_date ) ) THEN
                      l_comp_match_found := true;
                    END IF;
                 ELSE -- if parent rev not provided then chek for current eff comp
                   IF (l_comp_pdh_table(k).effectivity_date <= SYSDATE AND (l_comp_pdh_table(k).disable_date IS NULL OR l_comp_pdh_table(k).disable_date >= SYSDATE) ) THEN
                      l_comp_match_found := true;
                   END IF;
                 END IF;
              ELSE --if eff info if given then use that
                 IF (l_comp_pdh_table(k).effectivity_date = nvl(l_comp_table(j).new_effectivity_date,l_comp_table(j).effectivity_date)
                    AND (l_comp_pdh_table(k).disable_date is NULL OR l_comp_pdh_table(k).disable_date > l_comp_pdh_table(k).effectivity_date) )
                 THEN
                    l_comp_match_found := true;
                 END IF;
              END IF; -- eff info is null
            ELSIF (pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 2 AND  NVL(l_comp_pdh_table(k).to_end_item_unit_number,99999) >= NVL(l_comp_table(j).from_end_item_unit_number,99999)) THEN
                  l_comp_match_found := true;
            ELSIF (pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 4 AND  NVL(l_comp_pdh_table(k).to_end_item_rev_id,99999) >= NVL(l_comp_table(j).from_end_item_rev_id,99999)) THEN
                  l_comp_match_found := true;
            END IF; -- eff type is 1


            IF l_comp_match_found THEN
               l_comp_table(j).transaction_type := 'UPDATE';
               l_comp_pdh_table(k).bill_sequence_id := 0;
               IF nvl(l_comp_table(j).component_sequence_id,-1) <> l_comp_pdh_table(k).component_sequence_id  THEN
                  l_comp_table(j).component_sequence_id := l_comp_pdh_table(k).component_sequence_id;
               END IF;
            END IF;


            /*IF( (     pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 1
                   AND (l_comp_table(j).parent_revision_code IS NOT NULL AND l_comp_pdh_table(k).effectivity_date > l_par_eff_date AND
                   NVL(l_comp_pdh_table(k).disable_date,NVL(l_comp_table(j).effectivity_date,NVL(l_comp_table(j).new_effectivity_date,sysdate))) >= NVL(l_comp_table(j).effectivity_date,NVL(l_comp_table(j).new_effectivity_date,sysdate))
                )
                OR
                (       pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 2
                   AND  NVL(l_comp_pdh_table(k).to_end_item_unit_number,99999) >= NVL(l_comp_table(j).from_end_item_unit_number,99999)
                )
                OR
                (       pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 4
                   AND  NVL(l_comp_pdh_table(k).to_end_item_rev_id,99999) >= NVL(l_comp_table(j).from_end_item_rev_id,99999)
                )
             )
            THEN
              l_comp_table(j).transaction_type := 'UPDATE';
              IF nvl(l_comp_table(j).component_sequence_id,-1) <> l_comp_pdh_table(k).component_sequence_id  THEN
                l_comp_table(j).component_sequence_id := l_comp_pdh_table(k).component_sequence_id;
              END IF;
            END IF;*/
          ELSE
            IF l_comp_pdh_table(k).disable_date is NOT NULL AND l_comp_pdh_table(k).disable_date < sysdate THEN
              l_comp_pdh_table(k).bill_sequence_id := 0;
            END IF;
          END IF;
        END LOOP;
      END LOOP;
      write_debug('before inserting the delete rows first');
      FOR k IN 1..l_comp_seq_count
      LOOP
         IF l_comp_pdh_table(k).bill_sequence_id <> 0  THEN
          write_debug('inserting delete for comp --' ||l_comp_pdh_table(k).component_item_id );
          INSERT INTO
            bom_inventory_comps_interface
            (
              component_item_id,
              organization_id,
              component_sequence_id,
              bill_sequence_id,
              parent_source_system_reference,
              batch_id,
              transaction_type,
              disable_date,
              process_flag,
              component_item_number,
              assembly_item_number,
              organization_code,
              alternate_bom_designator,
              transaction_id
            )
          VALUES
          (
            l_comp_pdh_table(k).component_item_id,
            l_org_id_table(i),
            l_comp_pdh_table(k).component_sequence_id,
            l_bill_seq_id,
            l_header_rec_table(i),
            p_batch_id,
            'DELETE',
            SYSDATE,
            1,
            (SELECT concatenated_segments FROM mtl_system_items_vl WHERE inventory_item_id =l_comp_pdh_table(k).component_item_id AND organization_id = l_org_id_table(i)),
            (SELECT concatenated_segments FROM mtl_system_items_vl WHERE inventory_item_id = l_item_id_table(i) AND organization_id = l_org_id_table(i)),
            (SELECT organization_code FROM mtl_parameters WHERE organization_id = l_org_id_table(i)),
            l_str_name(i),
            MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
          );
          END IF;
          Disable_Refds
          (
           p_batch_id => p_batch_id,
           p_comp_seq_id => l_comp_pdh_table(k).component_sequence_id ,
           p_comp_id => l_comp_pdh_table(k).component_item_id,
           p_parent_id => l_item_id_table(i),
           p_eff_date  => l_comp_pdh_table(k).effectivity_date,
           p_op_seq_num  => l_comp_pdh_table(k).operation_seq_num,
           p_org_id => l_org_id_table(i)
          );
      END LOOP;
    ELSE
      FOR j IN 1..l_comp_seq_count
      LOOP
        l_not_exist := TRUE;
        l_bill_sequence_id := Check_Header_Exists(l_comp_pdh_table(j).component_item_id,l_org_id_table(i),l_str_name(i));
          IF l_bill_sequence_id IS NOT NULL THEN
             IF NOT  Header_Not_In_Intf(l_bill_sequence_id,l_comp_pdh_table(j).component_item_id,l_org_id_table(i),l_str_name(i),p_batch_id,l_req_id_table(i),l_bundle_id_table(i)) THEN
                OPEN Process_Unmatched_Comps(l_bill_sequence_id);
                FETCH Process_Unmatched_Comps BULK COLLECT INTO l_unmatch_comp;
                CLOSE Process_Unmatched_Comps;

                l_unmatch_count := l_unmatch_comp.COUNT;

                FOR m in 1..l_unmatch_count LOOP
                  IF l_unmatch_comp(m).disable_date IS NULL OR (l_unmatch_comp(m).disable_date IS NOT NULL AND l_unmatch_comp(m).disable_date > sysdate) THEN
                     INSERT INTO
                      bom_inventory_comps_interface
                      (
                        component_item_id,
                        organization_id,
                        component_sequence_id,
                        bill_sequence_id,
                        parent_source_system_reference,
                        batch_id,
                        transaction_type,
                        disable_date,
                        process_flag,
                        component_item_number,
                        assembly_item_number,
                        organization_code,
                        alternate_bom_designator,
                        assembly_item_id,
                        transaction_id
                      )
                    VALUES
                    (
                      l_unmatch_comp(m).component_item_id,
                      l_org_id_table(i),
                      l_unmatch_comp(m).component_sequence_id,
                      l_unmatch_comp(m).bill_sequence_id,
                      (SELECT concatenated_segments FROM mtl_system_items_vl MSIVL
                       WHERE MSIVL.inventory_item_id = l_comp_pdh_table(j).component_item_id
                       AND organization_id = l_org_id_table(i)),
                      p_batch_id,
                      'DELETE',
                      SYSDATE,
                      1,
                      (SELECT concatenated_segments FROM mtl_system_items_vl WHERE inventory_item_id =  l_unmatch_comp(m).component_item_id AND organization_id = l_org_id_table(i)),
                      (SELECT concatenated_segments FROM mtl_system_items_vl WHERE inventory_item_id =  l_comp_pdh_table(j).component_item_id  AND organization_id = l_org_id_table(i)),
                      (SELECT organization_code FROM mtl_parameters WHERE organization_id = l_org_id_table(i)),
                      l_str_name(i),
                      l_comp_pdh_table(j).component_item_id ,
                      MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
                    );

                    Disable_Refds
                    (
                      p_batch_id => p_batch_id,
                      p_comp_seq_id => l_unmatch_comp(m).component_sequence_id,
                      p_comp_id => l_unmatch_comp(m).component_item_id,
                      p_parent_id => l_comp_pdh_table(j).component_item_id,
                      p_eff_date  => l_unmatch_comp(m).effectivity_date,
                      p_op_seq_num  => l_unmatch_comp(m).operation_seq_num,
                      p_org_id => l_org_id_table(i)
                    );
                  END IF; -- Disable Date Null
                END LOOP;
             END IF; -- Header Not In Intf
          END IF; -- Bill Seq Null
        FOR k IN 1..l_comp_count
        LOOP
          IF (l_comp_table(k).component_item_id = l_comp_pdh_table(j).component_item_id
              AND l_comp_table(k).organization_id = l_org_id_table(i)
              AND l_comp_table(k).assembly_item_id = l_item_id_table(i) ) THEN

            l_comp_match_found := false;
            IF l_comp_table(k).parent_revision_code IS NOT NULL THEN
              SELECT effectivity_date
              INTO l_par_eff_date
              from mtl_item_revisions
              WHERE inventory_item_id = l_comp_table(k).assembly_item_id
              AND organization_id = l_comp_table(k).organization_id
              AND revision = l_comp_table(k).parent_revision_code;
            END IF;
            /*
             If no effectivity info is given then match the component based on either parent rev or current eff date
            */
            IF pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 1 THEN
              IF l_comp_table(k).effectivity_date IS NULL AND l_comp_table(k).new_effectivity_date IS NULL THEN -- when no eff info
                 IF l_comp_table(k).parent_revision_code IS NOT NULL AND l_par_eff_date > sysdate THEN -- check for parent rev eff if provided
                    IF (l_par_eff_date >= l_comp_pdh_table(j).effectivity_date   AND (l_comp_pdh_table(j).disable_date IS NULL OR  l_comp_pdh_table(j).disable_date >= l_par_eff_date ) ) THEN
                      l_comp_match_found := true;
                      l_not_exist := FALSE;
                    END IF;
                 ELSE -- if parent rev not provided then chek for current eff comp
                   IF (l_comp_pdh_table(j).effectivity_date <= SYSDATE AND (l_comp_pdh_table(j).disable_date IS NULL OR l_comp_pdh_table(j).disable_date >= SYSDATE ))THEN
                      l_comp_match_found := true;
                      l_not_exist := FALSE;
                   END IF;
                 END IF;
              ELSE --if eff info if given then use that
                 IF (l_comp_pdh_table(j).effectivity_date = nvl(l_comp_table(k).new_effectivity_date,l_comp_table(k).effectivity_date)
                    AND (l_comp_pdh_table(j).disable_date is NULL OR l_comp_pdh_table(j).disable_date > l_comp_pdh_table(j).effectivity_date) )
                 THEN
                    l_comp_match_found := true;
                    l_not_exist := FALSE;
                 END IF;
              END IF; -- eff info is null
            ELSIF (pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 2 AND  NVL(l_comp_pdh_table(j).to_end_item_unit_number,99999) >= NVL(l_comp_table(k).from_end_item_unit_number,99999)) THEN
                  l_comp_match_found := true;
                  l_not_exist := FALSE;
            ELSIF (pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 4 AND  NVL(l_comp_pdh_table(j).to_end_item_rev_id,99999) >= NVL(l_comp_table(k).from_end_item_rev_id,99999)) THEN
                  l_comp_match_found := true;
                  l_not_exist := FALSE;
            END IF; -- eff type is 1


            IF l_comp_match_found THEN
               l_comp_table(k).transaction_type := 'UPDATE';
               IF nvl(l_comp_table(k).component_sequence_id,-1) <> l_comp_pdh_table(j).component_sequence_id  THEN
                  l_comp_table(k).component_sequence_id := l_comp_pdh_table(j).component_sequence_id;
               END IF;
            END IF;

              /*IF( (pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 1
                   AND NVL(l_comp_pdh_table(j).disable_date,NVL(l_comp_table(k).effectivity_date,NVL(l_comp_table(k).new_effectivity_date,sysdate))) >= NVL(l_comp_table(k).effectivity_date,NVL(l_comp_table(k).new_effectivity_date,sysdate)))
                 OR (pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 2 AND NVL(l_comp_pdh_table(j).to_end_item_unit_number,99999) >= NVL(l_comp_table(k).from_end_item_unit_number,99999))
                 OR (pG_batch_options.STRUCTURE_EFFECTIVITY_TYPE = 4 AND NVL(l_comp_pdh_table(j).to_end_item_rev_id,99999) >= NVL(l_comp_table(k).from_end_item_rev_id,99999))
                )
              THEN
               l_comp_table(k).transaction_type := 'UPDATE';
               IF nvl(l_comp_table(k).component_sequence_id,-1) <> l_comp_pdh_table(j).component_sequence_id  THEN
                 l_comp_table(k).component_sequence_id := l_comp_pdh_table(j).component_sequence_id;
               END IF;
              END IF;*/
          END IF;
        END LOOP;
        write_debug('before inserting the delete rows second');
        IF l_not_exist AND (l_comp_pdh_table(j).disable_date IS NULL OR (l_comp_pdh_table(j).disable_date IS NOT NULL AND l_comp_pdh_table(j).disable_date > sysdate)) THEN
        write_debug('inserting delete for comp --' ||l_comp_pdh_table(j).component_item_id );
          INSERT INTO
           bom_inventory_comps_interface
           (
            component_item_id,
            organization_id,
            component_sequence_id,
            bill_sequence_id,
            parent_source_system_reference,
            batch_id,
            transaction_type,
            disable_date,
            process_flag,
            component_item_number,
            assembly_item_number,
            organization_code,
            alternate_bom_designator,
            transaction_id
          )
          VALUES
          (
            l_comp_pdh_table(j).component_item_id,
            l_org_id_table(i),
            l_comp_pdh_table(j).component_sequence_id,
            l_bill_seq_id,
            l_header_rec_table(i),
            p_batch_id,
            'DELETE',
            SYSDATE,
            1,
            (SELECT concatenated_segments FROM mtl_system_items_vl WHERE inventory_item_id =l_comp_pdh_table(j).component_item_id AND organization_id = l_org_id_table(i)),
            (SELECT concatenated_segments FROM mtl_system_items_vl WHERE inventory_item_id = l_item_id_table(i) AND organization_id = l_org_id_table(i)),
            (SELECT organization_code FROM mtl_parameters WHERE organization_id = l_org_id_table(i)),
            l_str_name(i),
            MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
          );
          END IF;
           Disable_Refds
            (
              p_batch_id => p_batch_id,
              p_comp_seq_id => l_comp_pdh_table(j).component_sequence_id,
              p_comp_id => l_comp_pdh_table(j).component_item_id,
              p_parent_id => l_item_id_table(i),
              p_eff_date  => l_comp_pdh_table(j).effectivity_date,
              p_op_seq_num  => l_comp_pdh_table(j).operation_seq_num,
              p_org_id => l_org_id_table(i)
            );
      END LOOP;
    END IF;

   l_comp_count := l_comp_table.COUNT;
   FOR i in 1..l_comp_count LOOP
     UPDATE bom_inventory_comps_interface
     SET component_sequence_id = l_comp_table(i).component_sequence_id,
         transaction_type = UPPER(l_comp_table(i).transaction_type)
     WHERE batch_id = p_batch_id
     AND (process_flag = 1 OR process_flag = 5)
     AND UPPER(transaction_type) <> 'DELETE'
     AND ( interface_table_unique_id = l_comp_table(i).interface_table_unique_id
          OR component_sequence_id = l_comp_table(i).component_sequence_id
          OR ( (component_item_id = l_comp_table(i).component_item_id OR component_item_number = l_comp_table(i).component_item_number)
              AND (organization_id = l_comp_table(i).organization_id OR organization_code = l_comp_table(i).organization_code)
              AND (assembly_item_id = l_comp_table(i).assembly_item_id OR assembly_item_number = l_comp_table(i).assembly_item_number)
             )
         );
   END LOOP;

  END LOOP; --End Header Loop
  x_Return_Status := 'S';
EXCEPTION
  WHEN OTHERS THEN
    Write_Debug('Unexpected Error occured' || SQLERRM);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      l_err_text := SUBSTR(SQLERRM, 1, 200);
      Error_Handler.Add_Error_Token
      (
        p_Message_Name => NULL
      , p_Message_Text => l_err_text
      , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
      , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
      );
      x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
    END IF;
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END PROCESS_ALL_COMPS_BATCH;

/**
 * This function is a public api that should be called by Ebusiness Suite Open
 * Interface Structure and Routings Import users for grouping of rows
 * Any other team using interface tables will use this method to get the batchId
 * sequence
*/
  FUNCTION Get_BatchId RETURN NUMBER
  IS
  L_NEXT_VALUE NUMBER;
  BEGIN
    SELECT
        MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
      INTO
        L_NEXT_VALUE
    FROM DUAL;
    RETURN L_NEXT_VALUE;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
  END Get_BatchId;

/*
 * This API will delete all the records from all the
 * BOM interface tables for the given batch id.
 */

 PROCEDURE Delete_Interface_Records
 (
    p_batch_id     IN NUMBER
  , x_Error_Mesg   IN OUT NOCOPY VARCHAR2
  , x_Ret_Code     IN OUT NOCOPY VARCHAR2
 )
 IS
 l_debug BOOLEAN := FALSE;
 stmt_num NUMBER;
 BEGIN

  stmt_num := 0;
  IF Error_Handler.get_debug <> 'Y' THEN
    l_debug := Init_Debug;
  ELSE
    l_debug := TRUE;
  END IF;

  Write_Debug('Inside Delete Interface Records');

  stmt_num := 1;
  Write_Debug('Deleting the header rows');

  DELETE bom_bill_of_mtls_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 2;
  Write_Debug('Deleting the component rows');

  Delete bom_inventory_comps_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 3;
  Write_Debug('Deleting the Ref Desgs interface');

  DELETE bom_ref_desgs_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 4;
  Write_Debug('Deleting the Sub Comps Rows');

  DELETE bom_sub_comps_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 5;
  Write_Debug('Deleting the component attr rows');

  DELETE bom_cmp_usr_attr_interface
  WHERE (batch_id = p_batch_id or data_set_id = p_batch_id);

  stmt_num := 6;
  Write_Debug('Deleting the Comp Operation Rows');

  DELETE bom_component_ops_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 7;
  Write_Debug('Deleting the Network Operation Rows');

  DELETE bom_op_networks_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 8;
  Write_Debug('Deleting the Operation Resources Rows');

  DELETE bom_op_resources_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 9;
  Write_Debug('Deleting the Operation Routings Rows');

  DELETE bom_op_routings_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 10;
  Write_Debug('Deleting the Operation Sequences Rows');

  DELETE bom_op_sequences_interface
  WHERE batch_id = p_batch_id;

  stmt_num := 11;
  Write_Debug('Deleting the Sub Operation Resources Rows');

  DELETE bom_sub_op_resources_interface
  WHERE batch_id = p_batch_id;

  x_Ret_Code := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
  WHEN OTHERS THEN
    x_Error_Mesg := 'Delete Intf Rec (' || stmt_num || ') ' || SQLERRM;
    x_Ret_Code := FND_API.G_RET_STS_UNEXP_ERROR;

 End Delete_Interface_Records;

 /*
 * Procedure to merge the duplicate records
 */
  --Duplicate Records
PROCEDURE Merge_Duplicate_Rows
 (
  p_batch_id    IN NUMBER,
  x_Ret_Status  IN OUT NOCOPY VARCHAR2,
  x_Error_Mesg  IN OUT NOCOPY VARCHAR2
 )
 IS
 TYPE  bom_comp_intf_type  IS  TABLE OF bom_inventory_comps_interface%ROWTYPE;
 l_comp_table bom_comp_intf_type;
 l_merge_comp bom_comp_intf_type;
 l_count NUMBER;
 l_merge_count NUMBER;
 l_temp_count NUMBER;


 CURSOR Get_Same_Comps
 (
  l_comp_seq    IN NUMBER,
  l_comp_name   IN VARCHAR2,
  l_par_name    IN VARCHAR2,
  l_eff_date    IN DATE,
  l_new_eff     IN DATE,
  l_op_seq      IN NUMBER,
  l_new_op_seq  IN NUMBER,
  l_unit_num    IN VARCHAR2,
  l_item_rev    IN NUMBER,
  l_comp_ref    IN VARCHAR2,
  l_par_ref     IN VARCHAR2,
  l_txn_type    IN VARCHAR2
 )
 IS
 SELECT *
 FROM bom_inventory_comps_interface
 WHERE batch_id = p_batch_id
 AND  ( component_sequence_id = l_comp_seq
      OR (component_sequence_id is NULL
        AND ( (component_item_number = l_comp_name OR comp_source_system_reference = l_comp_ref)
             AND (assembly_item_number = l_par_name OR parent_source_system_reference = l_par_ref)
             AND (operation_seq_num = l_op_seq OR new_operation_seq_num = l_new_op_seq)
             AND (( effectivity_date = l_eff_date OR new_effectivity_date = l_new_eff)
                  OR from_end_item_unit_number = l_unit_num
                  OR from_end_item_rev_id = l_item_rev
                 )
           )
       )
      )
  AND UPPER(transaction_type) = l_txn_type
  AND process_flag = 1
  ORDER by interface_table_unique_id DESC;

 CURSOR Get_Comp
 IS
 SELECT *
 FROM  bom_inventory_comps_interface
 WHERE batch_id = p_batch_id
 AND   process_flag = 1;

BEGIN

Open Get_Comp;
FETCH Get_Comp BULK COLLECT INTO l_comp_table;
CLOSE Get_Comp;

l_count := l_comp_table.COUNT;

FOR i in 1..l_count
LOOP
  IF l_comp_table(i).process_flag = 1 THEN
    OPEN Get_Same_Comps
     (
      l_comp_table(i).component_sequence_id,
      l_comp_table(i).component_item_number,
      l_comp_table(i).assembly_item_number,
      l_comp_table(i).effectivity_date,
      l_comp_table(i).new_effectivity_date,
      l_comp_table(i).operation_seq_num,
      l_comp_table(i).new_operation_seq_num,
      l_comp_table(i).from_end_item_unit_number,
      l_comp_table(i).from_end_item_rev_id,
      l_comp_table(i).comp_source_system_reference,
      l_comp_table(i).parent_source_system_reference,
      l_comp_table(i).transaction_type
     );
     FETCH Get_Same_Comps BULK COLLECT INTO l_merge_comp;
     CLOSE Get_Same_Comps;

     l_merge_count := l_merge_comp.COUNT;
    IF l_merge_count > 1 THEN

     FOR j in 2..l_merge_count
     LOOP
      IF l_merge_comp(1).operation_seq_num IS NULL THEN
         l_merge_comp(1).operation_seq_num := l_merge_comp(j).operation_seq_num;
      END IF;
      IF l_merge_comp(1).new_operation_seq_num IS NULL THEN
         l_merge_comp(1).new_operation_seq_num := l_merge_comp(j).new_operation_seq_num;
      END IF;
      IF l_merge_comp(1).basis_type IS NULL THEN
         l_merge_comp(1).basis_type := l_merge_comp(j).basis_type;
      END IF;
      IF l_merge_comp(1).component_quantity IS NULL THEN
         l_merge_comp(1).component_quantity := l_merge_comp(j).component_quantity;
      END IF;
      IF l_merge_comp(1).inverse_quantity IS NULL THEN
         l_merge_comp(1).inverse_quantity := l_merge_comp(j).inverse_quantity;
      END IF;
      IF l_merge_comp(1).component_yield_factor IS NULL THEN
         l_merge_comp(1).component_yield_factor := l_merge_comp(j).component_yield_factor;
      END IF;
      IF l_merge_comp(1).planning_factor IS NULL THEN
         l_merge_comp(1).planning_factor := l_merge_comp(j).planning_factor;
      END IF;
      IF l_merge_comp(1).quantity_related IS NULL THEN
         l_merge_comp(1).quantity_related := l_merge_comp(j).quantity_related;
      END IF;
      IF l_merge_comp(1).so_basis IS NULL THEN
         l_merge_comp(1).so_basis := l_merge_comp(j).so_basis;
      END IF;
      IF l_merge_comp(1).optional IS NULL THEN
         l_merge_comp(1).optional := l_merge_comp(j).optional;
      END IF;
      IF l_merge_comp(1).mutually_exclusive_options IS NULL THEN
         l_merge_comp(1).mutually_exclusive_options := l_merge_comp(j).mutually_exclusive_options;
      END IF;
      IF l_merge_comp(1).include_in_cost_rollup IS NULL THEN
         l_merge_comp(1).include_in_cost_rollup := l_merge_comp(j).include_in_cost_rollup;
      END IF;
      IF l_merge_comp(1).check_atp IS NULL THEN
         l_merge_comp(1).check_atp := l_merge_comp(j).check_atp;
      END IF;
      IF l_merge_comp(1).shipping_allowed IS NULL THEN
         l_merge_comp(1).shipping_allowed := l_merge_comp(j).shipping_allowed;
      END IF;
      IF l_merge_comp(1).required_to_ship IS NULL THEN
         l_merge_comp(1).required_to_ship := l_merge_comp(j).required_to_ship;
      END IF;
      IF l_merge_comp(1).required_for_revenue IS NULL THEN
         l_merge_comp(1).required_for_revenue := l_merge_comp(j).required_for_revenue;
      END IF;
      IF l_merge_comp(1).include_on_ship_docs IS NULL THEN
         l_merge_comp(1).include_on_ship_docs := l_merge_comp(j).include_on_ship_docs;
      END IF;
      IF l_merge_comp(1).low_quantity IS NULL THEN
         l_merge_comp(1).low_quantity := l_merge_comp(j).low_quantity;
      END IF;
      IF l_merge_comp(1).high_quantity IS NULL THEN
         l_merge_comp(1).high_quantity := l_merge_comp(j).high_quantity;
      END IF;
      IF l_merge_comp(1).acd_type IS NULL THEN
         l_merge_comp(1).acd_type := l_merge_comp(j).acd_type;
      END IF;
      IF l_merge_comp(1).wip_supply_type IS NULL THEN
         l_merge_comp(1).wip_supply_type := l_merge_comp(j).wip_supply_type;
      END IF;
      IF l_merge_comp(1).supply_subinventory IS NULL THEN
         l_merge_comp(1).supply_subinventory := l_merge_comp(j).supply_subinventory;
      END IF;
      IF l_merge_comp(1).supply_locator_id IS NULL THEN
         l_merge_comp(1).supply_locator_id := l_merge_comp(j).supply_locator_id;
      END IF;
      IF l_merge_comp(1).location_name IS NULL THEN
         l_merge_comp(1).location_name := l_merge_comp(j).location_name;
      END IF;
      IF l_merge_comp(1).bom_item_type IS NULL THEN
         l_merge_comp(1).bom_item_type := l_merge_comp(j).bom_item_type;
      END IF;
      IF l_merge_comp(1).operation_lead_time_percent IS NULL THEN
         l_merge_comp(1).operation_lead_time_percent := l_merge_comp(j).operation_lead_time_percent;
      END IF;
      IF l_merge_comp(1).cost_factor IS NULL THEN
         l_merge_comp(1).cost_factor := l_merge_comp(j).cost_factor;
      END IF;
      IF l_merge_comp(1).include_on_bill_docs IS NULL THEN
         l_merge_comp(1).include_on_bill_docs := l_merge_comp(j).include_on_bill_docs;
      END IF;
      IF l_merge_comp(1).pick_components IS NULL THEN
         l_merge_comp(1).pick_components := l_merge_comp(j).pick_components;
      END IF;
      IF l_merge_comp(1).original_system_reference IS NULL THEN
         l_merge_comp(1).original_system_reference := l_merge_comp(j).original_system_reference;
      END IF;
      IF l_merge_comp(1).enforce_int_requirements IS NULL THEN
         l_merge_comp(1).enforce_int_requirements := l_merge_comp(j).enforce_int_requirements;
      END IF;
      IF l_merge_comp(1).optional_on_model IS NULL THEN
         l_merge_comp(1).optional_on_model := l_merge_comp(j).optional_on_model;
      END IF;
      IF l_merge_comp(1).auto_request_material IS NULL THEN
         l_merge_comp(1).auto_request_material := l_merge_comp(j).auto_request_material;
      END IF;
      IF l_merge_comp(1).suggested_vendor_name IS NULL THEN
         l_merge_comp(1).suggested_vendor_name := l_merge_comp(j).suggested_vendor_name;
      END IF;
      IF l_merge_comp(1).unit_price IS NULL THEN
         l_merge_comp(1).unit_price := l_merge_comp(j).unit_price;
      END IF;

      l_temp_count := l_comp_table.COUNT;
      FOR k in 1..l_temp_count
      LOOP
       IF l_comp_table(k).process_flag <> -1 THEN
        IF l_comp_table(k).interface_table_unique_id = l_merge_comp(j).interface_table_unique_id THEN
         l_comp_table(k).process_flag := -1;
        END IF;
       END IF;
      END LOOP;

     l_merge_comp(j).process_flag := -1;
     END LOOP; -- merge table loop

     UPDATE bom_inventory_comps_interface
     SET operation_seq_num          = l_merge_comp(1).operation_seq_num,
        new_operation_seq_num       = l_merge_comp(1).new_operation_seq_num,
        basis_type                  = l_merge_comp(1).basis_type,
        component_quantity          = l_merge_comp(1).component_quantity,
        inverse_quantity            = l_merge_comp(1).inverse_quantity,
        component_yield_factor      = l_merge_comp(1).component_yield_factor,
        planning_factor             = l_merge_comp(1).planning_factor,
        quantity_related            = l_merge_comp(1).quantity_related,
        so_basis                    = l_merge_comp(1).so_basis,
        optional                    = l_merge_comp(1).optional,
        mutually_exclusive_options  = l_merge_comp(1).mutually_exclusive_options,
        include_in_cost_rollup      = l_merge_comp(1).include_in_cost_rollup,
        check_atp                   = l_merge_comp(1).check_atp,
        shipping_allowed            = l_merge_comp(1).shipping_allowed,
        required_to_ship            = l_merge_comp(1).required_to_ship,
        required_for_revenue        = l_merge_comp(1).required_for_revenue,
        include_on_ship_docs        = l_merge_comp(1).include_on_ship_docs,
        low_quantity                = l_merge_comp(1).low_quantity,
        high_quantity               = l_merge_comp(1).high_quantity,
        acd_type                    = l_merge_comp(1).acd_type ,
        wip_supply_type             = l_merge_comp(1).wip_supply_type,
        supply_subinventory         = l_merge_comp(1).supply_subinventory,
        supply_locator_id           = l_merge_comp(1).supply_locator_id,
        location_name               = l_merge_comp(1).location_name,
        bom_item_type               = l_merge_comp(1).bom_item_type,
        operation_lead_time_percent = l_merge_comp(1).operation_lead_time_percent,
        cost_factor                 = l_merge_comp(1).cost_factor,
        include_on_bill_docs        = l_merge_comp(1).include_on_bill_docs,
        pick_components             = l_merge_comp(1).pick_components,
        original_system_reference   = l_merge_comp(1).original_system_reference,
        enforce_int_requirements    = l_merge_comp(1).enforce_int_requirements,
        optional_on_model           = l_merge_comp(1).optional_on_model,
        auto_request_material       = l_merge_comp(1).auto_request_material,
        suggested_vendor_name       = l_merge_comp(1).suggested_vendor_name,
        unit_price                  = l_merge_comp(1).unit_price
     WHERE batch_id = p_batch_id
     AND interface_table_unique_id = l_merge_comp(1).interface_table_unique_id;

     UPDATE bom_inventory_comps_interface
     SET process_flag = -1
     WHERE batch_id = p_batch_id
     AND  ( component_sequence_id = l_merge_comp(1).component_sequence_id
        OR ( component_sequence_id IS NULL
             AND (component_item_number = l_merge_comp(1).component_item_number OR comp_source_system_reference = l_merge_comp(1).comp_source_system_reference)
             AND (assembly_item_number = l_merge_comp(1).assembly_item_number OR parent_source_system_reference = l_merge_comp(1).parent_source_system_reference)
             AND (operation_seq_num = l_merge_comp(1).operation_seq_num OR new_operation_seq_num = l_merge_comp(1).new_operation_seq_num)
             AND (( effectivity_date = l_merge_comp(1).effectivity_date OR new_effectivity_date = l_merge_comp(1).new_effectivity_date)
                  OR from_end_item_unit_number = l_merge_comp(1).from_end_item_unit_number
                  OR from_end_item_rev_id = l_merge_comp(1).from_end_item_rev_id
                 )
           )
       )
     AND interface_table_unique_id <> l_merge_comp(1).interface_table_unique_id;

     Merge_Ref_Desgs
     (
     p_batch_id    => p_batch_id,
     p_comp_seq_id => l_merge_comp(1).component_sequence_id,
     p_comp_name   => l_merge_comp(1).component_item_number,
     p_comp_ref    => l_merge_comp(1).comp_source_system_reference,
     p_effec_date  => l_merge_comp(1).effectivity_date,
     p_op_seq      => l_merge_comp(1).operation_seq_num,
     p_new_effec_date => l_merge_comp(1).new_effectivity_date,
     p_new_op_seq => l_merge_comp(1).new_operation_seq_num,
     p_from_unit   => l_merge_comp(1).from_end_item_unit_number,
     p_from_item_id => l_merge_comp(1).from_end_item_rev_id,
     p_parent_name  => l_merge_comp(1).assembly_item_number,
     p_parent_ref   => l_merge_comp(1).parent_source_system_reference,
     x_Ret_Status   => x_Ret_Status,
     x_Error_Mesg  => x_Error_Mesg
     );

     Merge_User_Attrs
     (
     p_batch_id => p_batch_id,
     p_comp_seq => l_merge_comp(1).component_sequence_id,
     p_comp_name => l_merge_comp(1).component_item_number,
     p_comp_ref => l_merge_comp(1).comp_source_system_reference,
     p_txn_id => l_merge_comp(1).transaction_id,
     p_par_name => l_merge_comp(1).assembly_item_number,
     p_par_ref => l_merge_comp(1).parent_source_system_reference,
     p_org_id  => l_merge_comp(1).organization_id,
     p_org_code => l_merge_comp(1).organization_code,
     x_Ret_Status => x_Ret_Status,
     x_Error_Mesg => x_Error_Mesg);

     END IF; -- merge count >1

END IF; --comp_table.process_flag = 1
END LOOP; -- comp_table loop
x_Ret_Status :=  FND_API.G_RET_STS_SUCCESS;
END Merge_Duplicate_Rows;

PROCEDURE Merge_Ref_Desgs
(
 p_batch_id    IN NUMBER,
 p_comp_seq_id IN NUMBER,
 p_comp_name   IN VARCHAR2,
 p_comp_ref    IN VARCHAR2,
 p_effec_date  IN DATE,
 p_op_seq      IN NUMBER,
 p_new_effec_date IN DATE,
 p_new_op_seq  IN NUMBER,
 p_from_unit   IN VARCHAR2,
 p_from_item_id IN NUMBER,
 p_parent_name IN VARCHAR2,
 p_parent_ref  IN VARCHAR2,
 x_Ret_Status  IN OUT NOCOPY VARCHAR2,
 x_Error_Mesg  IN OUT NOCOPY VARCHAR2
)
IS

TYPE num_type IS TABLE OF NUMBER;
TYPE var_type IS TABLE OF VARCHAR2(100);

l_max_unique_id num_type;
l_comp_ref_des var_type;
l_count NUMBER;

CURSOR Get_Ref_Desgs
IS
SELECT COMPONENT_REFERENCE_DESIGNATOR,MAX(interface_table_unique_id)
   FROM bom_ref_desgs_interface
   where batch_id = p_batch_id
   and process_flag = 1
   and (    component_sequence_id = p_comp_seq_id
         OR (     (component_item_number = p_comp_name OR comp_source_system_reference = p_comp_ref)
              and (nvl(operation_seq_num,1) = nvl(p_op_seq,1) OR nvl(operation_seq_num,1) = nvl(p_new_op_seq,1) )
              and (( nvl(effectivity_date,sysdate) = nvl(p_effec_date,sysdate) OR nvl(effectivity_date,sysdate) = nvl(p_new_effec_date,sysdate))
                    or from_end_item_unit_number = p_from_unit
                    --or from_end_item_rev_id   = p_from_item_id
                   )
              and (assembly_item_number = p_parent_name OR parent_source_system_reference = p_parent_ref)
             )
        )
     GROUP BY component_reference_designator;


BEGIN

OPEN Get_Ref_Desgs;
FETCH Get_Ref_Desgs BULK COLLECT INTO l_comp_ref_des,l_max_unique_id;
CLOSE Get_Ref_Desgs;

l_count := l_max_unique_id.COUNT;

FOR i in 1..l_count
LOOP
  UPDATE bom_ref_desgs_interface
  SET process_flag = -1
  WHERE batch_id = p_batch_id
  AND ( process_flag = 1 OR process_flag = 5)
  AND (    component_sequence_id = p_comp_seq_id
           OR (     (component_item_number = p_comp_name OR comp_source_system_reference = p_comp_ref)
                AND (nvl(operation_seq_num,1) = nvl(p_op_seq,1) OR nvl(operation_seq_num,1) = nvl(p_new_op_seq,1) )
                AND (( nvl(effectivity_date,sysdate) = nvl(p_effec_date,sysdate) OR nvl(effectivity_date,sysdate) = nvl(p_new_effec_date,sysdate))
                      or from_end_item_unit_number = p_from_unit
                      --or from_end_item_rev_id   = p_from_item_id
                     )
                AND (assembly_item_number = p_parent_name OR parent_source_system_reference = p_parent_ref)
               )
          )
  AND component_reference_designator = l_comp_ref_des(i)
  AND interface_table_unique_id <> l_max_unique_id(i);
END LOOP;
x_Ret_Status := FND_API.G_RET_STS_SUCCESS;
END Merge_Ref_Desgs;

PROCEDURE Merge_User_Attrs
(
  p_batch_id    IN NUMBER,
  p_comp_seq IN NUMBER,
  p_comp_name IN VARCHAR2,
  p_comp_ref    IN VARCHAR2,
  p_txn_id      IN NUMBER,
  p_par_name    IN VARCHAR2,
  p_par_ref     IN VARCHAR2,
  p_org_id      IN NUMBER,
  p_org_code    IN VARCHAR2,
  x_Ret_Status  IN OUT NOCOPY VARCHAR2,
  x_Error_Mesg  IN OUT NOCOPY VARCHAR2
)
IS

 TYPE  bom_comp_attr_type  IS  TABLE OF bom_cmp_usr_attr_interface%ROWTYPE;
 l_attr_table bom_comp_attr_type;
 l_merge_table bom_comp_attr_type;
 l_count NUMBER;
 l_merge_count NUMBER;
 l_temp_count NUMBER;
 l_multi_row VARCHAR2(5);

 CURSOR Get_User_Attrs
 IS
 SELECT *
 FROM bom_cmp_usr_attr_interface
 WHERE (data_set_id = p_batch_id OR batch_id = p_batch_id)
 AND ( component_sequence_id = p_comp_seq
       OR( (item_number = p_comp_name or comp_source_system_reference = p_comp_ref)
          AND (assembly_item_number = p_par_name OR parent_source_system_reference = p_par_ref)
         )
      )
 AND process_status = 0
 AND (organization_id = p_org_id OR organization_code =  p_org_code);
-- AND transaction_id = p_txn_id;

 CURSOR Get_Same_Attrs
 (
 l_grp_int_name IN VARCHAR2,
 l_attr_int_name IN VARCHAR2,
 l_str_type_id IN NUMBER
 )
 IS
 SELECT *
 FROM bom_cmp_usr_attr_interface
 WHERE (data_set_id = p_batch_id OR batch_id = p_batch_id)
 AND ( component_sequence_id = p_comp_seq
       OR ( (item_number = p_comp_name or comp_source_system_reference = p_comp_ref)
           AND (assembly_item_number = p_par_name OR parent_source_system_reference = p_par_ref)
          )
      )
 --AND transaction_id = p_txn_id
 ANd process_status = 0
 AND (organization_id = p_org_id OR organization_code =  p_org_code)
 AND attr_group_int_name = l_grp_int_name
 AND attr_int_name = l_attr_int_name
 AND structure_type_id = l_str_type_id
 ORDER BY interface_table_unique_id DESC;

BEGIN
 OPEN Get_User_Attrs;
 FETCH Get_User_Attrs BULK COLLECT INTO l_attr_table;
 CLOSE Get_User_Attrs;

 l_count := l_attr_table.COUNT;
 FOR i in 1..l_count
 LOOP
   BEGIN
   SELECT multi_row_code
   INTO l_multi_row
   FROM ego_attr_groups_v
   WHERE attr_group_name = l_attr_table(i).ATTR_GROUP_INT_NAME
   AND attr_group_type = 'BOM_COMPONENTMGMT_GROUP';

   EXCEPTION WHEN NO_DATA_FOUND THEN
    /*
     This error will be handled by the EXT API.
     All Attr Group related validations are handled by EXT API.
     */
    NULL;
   END;

   IF nvl(l_multi_row,'N') <> 'Y' THEN
   IF l_attr_table(i).process_status = 0 THEN
     OPEN Get_Same_Attrs
     (
      l_attr_table(i).attr_group_int_name,
      l_attr_table(i).attr_int_name,
      l_attr_table(i).structure_type_id
     );
     FETCH Get_Same_Attrs BULK COLLECT INTO l_merge_table;
     CLOSE Get_Same_Attrs;

     l_merge_count := l_merge_table.COUNT;

    IF l_merge_count > 1 THEN

     FOR j in 2..l_merge_count
     LOOP
      IF l_merge_table(1).attr_value_str IS NULL THEN
         l_merge_table(1).attr_value_str := l_merge_table(j).attr_value_str;
      END IF;
      IF l_merge_table(1).attr_value_num IS NULL THEN
         l_merge_table(1).attr_value_num := l_merge_table(j).attr_value_num;
      END IF;
      IF l_merge_table(1).attr_value_date IS NULL THEN
         l_merge_table(1).attr_value_date := l_merge_table(j).attr_value_date;
      END IF;
      IF l_merge_table(1).attr_disp_value IS NULL THEN
         l_merge_table(1).attr_disp_value := l_merge_table(j).attr_disp_value;
      END IF;

      l_temp_count := l_attr_table.COUNT;
      FOR k in 1..l_temp_count
      LOOP
       IF l_attr_table(k).process_status <> -1 THEN
        IF
         l_attr_table(k).interface_table_unique_id = l_merge_table(j).interface_table_unique_id THEN
          l_attr_table(k).process_status := -1;
        END IF;
       END IF;
      END LOOP;

     l_merge_table(j).process_status := -1;
     END LOOP; --same attrs loop

     UPDATE bom_cmp_usr_attr_interface
     SET attr_value_str = l_merge_table(1).attr_value_str,
         attr_value_num = l_merge_table(1).attr_value_num,
         attr_value_date = l_merge_table(1).attr_value_date,
         attr_disp_value = l_merge_table(1).attr_disp_value
     WHERE (data_set_id = p_batch_id OR batch_id = p_batch_id)
     AND interface_table_unique_id = l_merge_table(1).interface_table_unique_id;

     UPDATE bom_cmp_usr_attr_interface
     SET process_status = -1
     WHERE (batch_id = p_batch_id or data_set_id = p_batch_id)
     AND ( component_sequence_id = l_merge_table(1).component_sequence_id
       OR ( (item_number = l_merge_table(1).item_number or comp_source_system_reference = l_merge_table(1).comp_source_system_reference)
           AND (assembly_item_number = l_merge_table(1).assembly_item_number OR parent_source_system_reference = l_merge_table(1).parent_source_system_reference )
          )
      )
     --AND transaction_id = l_merge_table(1).transaction_id
     AND attr_group_int_name = l_merge_table(1).attr_group_int_name
     AND attr_int_name = l_merge_table(1).attr_int_name
     AND structure_type_id = l_merge_table(1).structure_type_id
     AND interface_table_unique_id <> l_merge_table(1).interface_table_unique_id;

   END IF; -- merge count >1

   END IF; -- process flag = 1
  END IF; -- Multi Row
 END LOOP; -- attrs loop

x_Ret_Status := FND_API.G_RET_STS_SUCCESS;
END Merge_User_Attrs;

PROCEDURE Process_CM_Options(p_batch_id IN NUMBER)
IS
CURSOR Get_Header
IS
  SELECT *
  FROM bom_bill_of_mtls_interface
  WHERE batch_id = p_batch_id
  AND process_flag = 1;

TYPE  bom_header_type  IS  TABLE OF bom_bill_of_mtls_interface%ROWTYPE;
l_header_table bom_header_type;
l_str_chng_policy VARCHAR2(50);
l_count NUMBER;
l_rev_id NUMBER;

BEGIN
  --Update Change Required :Start
  IF (  pG_batch_options.CHANGE_ORDER_CREATION = 'N' OR
        pG_batch_options.CHANGE_ORDER_CREATION = 'E')
  THEN
    IF nvl(pG_batch_options.ADD_ALL_TO_CHANGE_FLAG,'N') = 'Y'  THEN
      -- Only for header setting the process flag to 5  even for already
      -- process_flag = 7 records for bug 	4686771
      UPDATE bom_bill_of_mtls_interface
      SET process_flag = 5
          --pending_from_ecn = nvl(pending_from_ecn,pG_batch_options.CHANGE_NOTICE) we need not do this
      WHERE batch_id = p_batch_id
      AND (process_flag = 1 OR process_flag = 7);

      UPDATE bom_inventory_comps_interface
      SET process_flag = 5
          --change_notice = nvl(change_notice,pG_batch_options.CHANGE_NOTICE) we need not do this
      WHERE batch_id = p_batch_id
      AND process_flag = 1;

     --Update other entities also
      UPDATE bom_ref_desgs_interface
      SET process_flag = 5
      WHERE batch_id = p_batch_id
      AND process_flag = 1;

      UPDATE bom_sub_comps_interface
      SET process_flag = 5
      WHERE batch_id = p_batch_id
      AND process_flag = 1;

      UPDATE bom_component_ops_interface
      SET process_flag = 5
      WHERE batch_id = p_batch_id
      AND process_flag = 1;
    ELSE
       OPEN Get_Header;
       FETCH Get_Header BULK COLLECT INTO l_header_table;
       CLOSE Get_Header;

       l_count := l_header_table.COUNT;
       FOR i in 1..l_count LOOP

        IF l_header_table(i).revision IS NOT NULL THEN
          SELECT mrb.revision_id
          INTO l_rev_id
          FROM  mtl_item_revisions_b mrb
          WHERE mrb.inventory_item_id = l_header_table(i).assembly_item_id
          AND   mrb.organization_id = l_header_table(i).organization_id
          AND   mrb.revision = l_header_table(i).revision;
        END IF;

        IF l_rev_id IS NOT NULL THEN
          l_str_chng_policy := BOM_GLOBALS.Get_Change_Policy_Val (l_header_table(i).assembly_item_id,
                                                                  l_header_table(i).organization_id,
                                                                  l_rev_id,
                                                                  null,
                                                                  l_header_table(i).structure_type_id);
        ELSE
          l_str_chng_policy := BOM_GLOBALS.Get_Change_Policy_Val (l_header_table(i).assembly_item_id,
                                                                l_header_table(i).organization_id,
                                                                NULL,
                                                                SYSDATE,
                                                                l_header_table(i).structure_type_id);
        END IF;

        IF l_str_chng_policy = 'CHANGE_ORDER_REQUIRED' THEN
         UPDATE bom_bill_of_mtls_interface
         SET process_flag = 5
         WHERE batch_id = p_batch_id
         AND (process_flag = 1 OR process_flag = 7)
         AND interface_table_unique_id = l_header_table(i).interface_table_unique_id;


         UPDATE bom_inventory_comps_interface
         SET process_flag = 5
         WHERE batch_id = p_batch_id
         AND process_flag = 1
         AND (   bill_sequence_id = l_header_table(i).bill_sequence_id
               OR ( assembly_item_id = l_header_table(i).assembly_item_id
                    AND organization_id = l_header_table(i).organization_id
                    AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
               OR ( assembly_item_number = l_header_table(i).item_number
                    AND organization_code = l_header_table(i).organization_code
                    AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
             );

         UPDATE bom_ref_desgs_interface
         SET process_flag = 5
         WHERE batch_id = p_batch_id
         AND process_flag = 1
         AND (   bill_sequence_id = l_header_table(i).bill_sequence_id
               OR ( assembly_item_id = l_header_table(i).assembly_item_id
                    AND organization_id = l_header_table(i).organization_id
                    AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
               OR ( assembly_item_number = l_header_table(i).item_number
                    AND organization_code = l_header_table(i).organization_code
                    AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
             );

         UPDATE bom_sub_comps_interface
         SET process_flag = 5
         WHERE batch_id = p_batch_id
         AND process_flag = 1
         AND (   bill_sequence_id = l_header_table(i).bill_sequence_id
               OR ( assembly_item_id = l_header_table(i).assembly_item_id
                    AND organization_id = l_header_table(i).organization_id
                    AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
               OR ( assembly_item_number = l_header_table(i).item_number
                    AND organization_code = l_header_table(i).organization_code
                    AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
             );

         UPDATE bom_component_ops_interface
         SET process_flag = 5
         WHERE batch_id = p_batch_id
         AND process_flag = 1
         AND (   bill_sequence_id = l_header_table(i).bill_sequence_id
               OR ( assembly_item_id = l_header_table(i).assembly_item_id
                    AND organization_id = l_header_table(i).organization_id
                    AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
               OR ( assembly_item_number = l_header_table(i).item_number
                    AND organization_code = l_header_table(i).organization_code
                    AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
             );

         UPDATE bom_cmp_usr_attr_interface
         SET process_status = 5
         WHERE batch_id = p_batch_id
         AND process_status= 1
         AND (   bill_sequence_id = l_header_table(i).bill_sequence_id
               OR ( assembly_item_number = l_header_table(i).item_number
                    AND organization_code = l_header_table(i).organization_code
                    --AND nvl(alternate_bom_designator,'Primary') = nvl(l_header_table(i).alternate_bom_designator,'Primary')
                  )
             );

        END IF;
       END LOOP;
  --Update Change Required :End
    END IF;
   END IF;
 End Process_CM_Options;

 PROCEDURE Get_Item_Security_Predicate
   (
    p_object_name IN   VARCHAR2,
    p_party_id    IN   VARCHAR2,
    p_privilege_name  IN   VARCHAR2,
    p_table_alias     IN   VARCHAR2,
    x_security_predicate  OUT NOCOPY VARCHAR2
   )
   IS
   l_temp_predicate VARCHAR2(2000);
   l_pk_column VARCHAR2(50);
   BEGIN

     SELECT PK1_COLUMN_NAME
     INTO l_pk_column
     FROM fnd_objects
     WHERE obj_name = 'EGO_ITEM';

     EGO_ITEM_USER_ATTRS_CP_PUB.Get_Item_Security_Predicate
                                ( p_object_name => 'EGO_ITEM',
                                  p_party_id => p_party_id,
                                  p_privilege_name => p_privilege_name,
                                  p_table_alias => p_table_alias,
                                  x_security_predicate => x_security_predicate
                                );
     l_temp_predicate := x_security_predicate;
     l_temp_predicate := replace(l_temp_predicate,'UAI2.'||l_pk_column,'UAI2.COMPONENT_ITEM_ID');
     x_security_predicate := l_temp_predicate;


  END Get_Item_Security_Predicate;

  FUNCTION Get_Item_Matches
    (
     p_batch_id     IN NUMBER,
     p_ss_ref       IN VARCHAR2
    )
  RETURN VARCHAR2
  IS
   CURSOR Get_Matches IS
   SELECT match_id
   FROM ego_item_matches
   WHERE batch_id = p_batch_id
   AND source_system_reference = p_ss_ref;

   TYPE num_type IS TABLE OF NUMBER;
   l_match_tab num_type;
   l_count NUMBER;
   l_ret_status VARCHAR2(3);

  BEGIN

   OPEN Get_Matches;
   FETCH Get_Matches BULK COLLECT INTO l_match_tab;
   CLOSE Get_Matches;

   l_count := l_match_tab.COUNT;
   l_ret_status := 'N';
   IF l_count > 1 THEN
    l_ret_status := 'M';
   ELSIF l_count = 1 THEN
    l_ret_status := 'S';
   END IF;
  RETURN l_ret_status;

  END Get_Item_Matches;


END Bom_Import_Pub;

/
