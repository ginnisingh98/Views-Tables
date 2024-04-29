--------------------------------------------------------
--  DDL for Package Body BOM_REFERENCE_DESIGNATOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_REFERENCE_DESIGNATOR_API" AS
/* $Header: BOMOIRDB.pls 115.13 2002/05/08 12:14:16 pkm ship      $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMOIRDB.pls                                               |
| DESCRIPTION  : This package contains functions used to assign, validate   |
|                and transact Reference Designator data in the              |
|		 BOM_REF_DESGS_INTERFACE table.				    |
| Parameters:   org_id          organization_id                             |
|               all_org         process all orgs or just current org        |
|                               1 - all orgs                                |
|                               2 - only org_id                             |
|               prog_appid      program application_id                      |
|               prog_id         program id                                  |
|               req_id          request_id                                  |
|               user_id         user id                                     |
|               login_id        login id                                    |
| History:                                                                  |
|    11/22/93   Shreyas Shah    creation date                               |
|    04/24/94   Julie Maeyama   Modified code                               |
|    03/06/97   Julie Maeyama   Created this new package		    |
+==========================================================================*/

/* ----------------------- Assign_Reference_Designator ----------------------*/
/*
NAME
    Assign_Reference_Designator
DESCRIPTION
    Assign defaults and ID's to reference designator record in the interface
    table
REQUIRES
    err_text    out buffer to return error message
MODIFIES
    BOM_REF_DESGS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Assign_Reference_Designator (
    org_id              NUMBER,
    all_org             NUMBER := 2,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id 	        NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
   curr_org_id          NUMBER;
   curr_txn_id          NUMBER;
   ret_code             NUMBER;
   dummy_txn            NUMBER;
   commit_cnt           NUMBER;
   continue_loop        BOOLEAN := TRUE;
   total_recs           NUMBER;
   stmt_num             NUMBER := 0;
   X_dummy              NUMBER;

/*
** Null Component_Sequence_Id
*/
   CURSOR c1 IS
      SELECT component_sequence_id CSI,
             transaction_id TI, organization_id OI,
             bill_sequence_id BSI, assembly_item_id AII,
             assembly_item_number AIN, alternate_bom_designator ABD,
             component_item_id CII, component_item_number CIN,
             operation_seq_num OSN, transaction_type A,
             to_char(effectivity_date,'YYYY/MM/DD HH24:MI:SS') ED
        FROM bom_ref_desgs_interface
       WHERE process_flag = 1
         AND transaction_type in (G_Insert, G_Update, G_Delete)
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
         AND component_sequence_id is null
         AND (all_org = 1
              OR
             (all_org = 2 and organization_id = org_id))
         AND rownum < G_rows_to_commit;
/*
** Component_Sequence_Id filled in
*/
   CURSOR c2 IS
      SELECT transaction_id TI, organization_id OI,
             component_sequence_id CSI, transaction_type A
        FROM bom_ref_desgs_interface
       WHERE process_flag = 1
         AND transaction_type in (G_Insert, G_Update, G_Delete)
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
         AND component_sequence_id is not null
         AND (all_org = 1
              OR
             (all_org = 2 and organization_id = org_id))
         AND rownum < G_rows_to_commit;
/*
** Record passed assignment
*/
/**************************** Removed code as a fix for 916428 ************
   CURSOR c3 IS
      SELECT component_sequence_id CSI
        FROM bom_ref_desgs_interface
       WHERE process_flag = 99
         AND transaction_type in (G_Insert,G_Update)
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
         AND (all_org = 1
              OR
             (all_org = 2 and organization_id = org_id))
    GROUP BY component_sequence_id;

*****************************************************************************/
BEGIN
/** G_INSERT is 'CREATE'. Update 'INSERT' to 'CREATE' **/
   stmt_num := 0.5 ;
   LOOP
      UPDATE bom_ref_desgs_interface
         SET transaction_type = G_Insert
       WHERE process_flag = 1
         AND upper(transaction_type) = 'INSERT'
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;
      COMMIT;
   END LOOP;

/*
** ALL RECORDS - Assign Org Id
*/
   stmt_num := 1;
   LOOP
      UPDATE bom_ref_desgs_interface ori
         SET organization_id = (SELECT organization_id
                                  FROM mtl_parameters a
                             WHERE a.organization_code = ori.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Insert, G_Delete, G_Update)
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
         AND organization_id is null
         AND organization_code is not null
         AND exists (SELECT organization_code
                       FROM mtl_parameters b
                      WHERE b.organization_code = ori.organization_code)
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;
      COMMIT;
   END LOOP;

/*
** ALL RECORDS - Assign transaction ids
*/
   stmt_num := 2;
   LOOP
      UPDATE bom_ref_desgs_interface
         SET transaction_id = mtl_system_items_interface_s.nextval,
             transaction_type = upper(transaction_type)
       WHERE transaction_id is null
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
         AND process_flag = 1
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;

      COMMIT;
   END LOOP;

 /*
** FOR ALL RECORDS - Get Component Sequence Id
*/
/*
** Check if organization id is null
*/
   stmt_num := 3;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c1rec in c1 LOOP
         commit_cnt := commit_cnt + 1;
         IF (c1rec.OI is null and c1rec.BSI is null) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
            UPDATE bom_ref_desgs_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RETURN(ret_code);
            END IF;
            GOTO continue_loop;
         END IF;

/*
**  Get assembly item id
*/
         stmt_num := 4;
         IF (c1rec.AII is null and c1rec.BSI is null) THEN
            ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id=> c1rec.OI,
                flex_code => 'MSTK',
                flex_name => c1rec.AIN,
                flex_id => c1rec.AII,
                set_id => -1,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
               UPDATE bom_ref_desgs_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
            END IF;
         END IF;

/*
**  Get bill sequence id
*/
         stmt_num := 5;
         IF (c1rec.BSI is null) THEN
            BEGIN
               SELECT bill_sequence_id, assembly_type
                 INTO c1rec.BSI, X_dummy
                 FROM bom_bill_of_materials
                WHERE organization_id = c1rec.OI
                  AND assembly_item_id = c1rec.AII
                  AND nvl(alternate_bom_designator, 'NONE') =
		      nvl(c1rec.ABD, 'NONE');
            EXCEPTION
               WHEN no_data_found THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                      org_id => NULL,
                      user_id => user_id,
                      login_id => login_id,
                      prog_appid => prog_appid,
                      prog_id => prog_id,
                      req_id => req_id,
                      trans_id => c1rec.TI,
                      error_text => err_text,
                      tbl_name => 'BOM_REF_DESGS_INTERFACE',
                      msg_name => 'BOM_BILL_SEQ_MISSING',
                      err_text => err_text);
               UPDATE bom_ref_desgs_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  return(ret_code);
               END IF;
               GOTO continue_loop;
            END;
         END IF;

/*
**  Get component item id
*/
         stmt_num := 6;
         IF (c1rec.CII is null) THEN
            ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id=> c1rec.OI,
                flex_code => 'MSTK',
                flex_name => c1rec.CIN,
                flex_id => c1rec.CII,
                set_id => -1,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_COMP_ID_MISSING',
                        err_text => err_text);
               UPDATE bom_ref_desgs_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  return(ret_code);
               END IF;
               GOTO continue_loop;
            END IF;
         END IF;

/*
**  Get component sequence id
*/
         stmt_num := 7;
         BEGIN
            SELECT component_sequence_id
              INTO c1rec.CSI
              FROM bom_inventory_components
             WHERE bill_sequence_id = c1rec.BSI
               AND component_item_id = c1rec.CII
               AND operation_seq_num = c1rec.OSN
               AND effectivity_date = to_date(c1rec.ED,'YYYY/MM/DD HH24:MI:SS');
         EXCEPTION
            WHEN no_data_found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                      org_id => NULL,
                      user_id => user_id,
                      login_id => login_id,
                      prog_appid => prog_appid,
                      prog_id => prog_id,
                      req_id => req_id,
                      trans_id => c1rec.TI,
                      error_text => err_text,
                      tbl_name => 'BOM_REF_DESGS_INTERFACE',
                      msg_name => 'BOM_COMP_SEQ_MISSING',
                      err_text => err_text);
               UPDATE bom_ref_desgs_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
         END;

         stmt_num := 8;
         UPDATE bom_ref_desgs_interface
            SET component_sequence_id = c1rec.CSI,
                assembly_item_id = c1rec.AII,
                component_item_id = c1rec.CII,
                bill_sequence_id = c1rec.BSI,
		organization_id = c1rec.OI
          WHERE transaction_id = c1rec.TI;

<<continue_loop>>
         NULL;
      END LOOP;

      stmt_num := 9;
      COMMIT;

      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;
   END LOOP;

/*
** FOR ALL RECORDS - Set defaults and process_flag for valid records
*/
   stmt_num := 10;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c2rec in c2 LOOP
         commit_cnt := commit_cnt + 1;
         IF (c2rec.A = G_Insert) THEN
            stmt_num := 11;
            UPDATE bom_ref_desgs_interface
               SET process_flag = 2, -- Changed from 99 to 2, bug 1342291
 		   acd_type = null,
                   last_update_date = nvl(last_update_date,sysdate),
                   last_updated_by = nvl(last_updated_by,user_id),
                   creation_date = nvl(creation_date,sysdate),
                   created_by = nvl(created_by,user_id),
                   last_update_login = nvl(last_update_login, user_id),
                   request_id = nvl(request_id, req_id),
                   program_application_id = nvl(program_application_id,
                                                prog_appid),
                   program_id = nvl(program_id, prog_id),
                   program_update_date = nvl(program_update_date, sysdate)
             WHERE transaction_id = c2rec.TI;
         ELSIF (c2rec.A = G_Update) THEN
            stmt_num := 12;
            UPDATE bom_ref_desgs_interface
               SET process_flag = 2, -- Changed from 99 to 2, bug 1342291
                   last_update_date = nvl(last_update_date,sysdate),
                   last_updated_by = nvl(last_updated_by,user_id),
                   last_update_login = nvl(last_update_login, user_id)
             WHERE transaction_id = c2rec.TI;

            IF (SQL%NOTFOUND) THEN
               err_text := 'Bom_Reference_Designator_Api('||stmt_num||')'||
                            substrb(SQLERRM, 1, 60);
               RETURN(SQLCODE);
            END IF;
         ELSIF (c2rec.A = G_Delete) THEN
            stmt_num := 13;
            UPDATE bom_ref_desgs_interface
               SET process_flag = 2
             WHERE transaction_id = c2rec.TI;

            IF (SQL%NOTFOUND) THEN
               err_text := 'Bom_Reference_Designator_Api('||stmt_num||')'||
                            substrb(SQLERRM, 1, 60);
               RETURN(SQLCODE);
            END IF;
         END IF;

<<continue_loop2>>
         NULL;
      END LOOP;

      stmt_num := 14;
      COMMIT;

      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

   commit_cnt := 0;

/******************* Removed as a fix for bug 916428 *************************
   stmt_num := 16;
   FOR c3rec in c3 LOOP
         commit_cnt := commit_cnt + 1;
         SELECT mtl_system_items_interface_s.nextval
           INTO dummy_txn
           FROM sys.dual;

         stmt_num := 17;

	 -- Only INSERTS and UPDATES have process_flag = 99

         UPDATE bom_ref_desgs_interface
            SET transaction_id = dummy_txn,
                process_flag = 2
          WHERE component_sequence_id = c3rec.CSI
            AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
            AND process_flag = 99;

      IF (commit_cnt = G_rows_to_commit) THEN
         COMMIT;
         commit_cnt := 0;
      END IF;
   END LOOP;
 ***************************************************************************/

   stmt_num := 18;
   COMMIT;

   RETURN (0);
EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Reference_Designator_Api(Assign-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Assign_Reference_Designator;

/* ---------------------- Verify_Unique_Designator --------------------------*/
/*
NAME
   Verify_Unique_Designator - Verify reference designator is unique for its
   			      component
DESCRIPTION
   Verify that the reference designator is unique in the production table
   Verify that the reference designator is unique in the interface table
REQUIRES
    trans_id    transaction_id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Verify_Unique_Designator (
    trans_id            NUMBER,
    err_text    OUT     VARCHAR2
)
    return INTEGER
IS
    dummy       NUMBER;
    not_unique  EXCEPTION;
    stmt_num    NUMBER := 0;
BEGIN
/*
** First check in prod tables.
** If it's an UPDATE, then this check is unnecessary if new_designator is
** not filled in.
*/
   stmt_num := 1;
   BEGIN
      SELECT 1
        INTO dummy
        FROM bom_reference_designators a, bom_ref_desgs_interface b
       WHERE b.transaction_id = trans_id
         AND (b.transaction_type = G_Insert
              OR (b.transaction_type= G_Update
                  AND b.new_designator is not null))
         AND (UPPER(b.interface_entity_type) = 'BILL'
	      OR b.interface_entity_type is null)
         AND a.component_sequence_id = b.component_sequence_id
         AND a.component_reference_designator = decode(b.transaction_type,
	     G_Insert, b.component_reference_designator, G_Update,
	     b.new_designator)
         AND rownum = 1;
      RAISE not_unique;
   EXCEPTION
      WHEN no_data_found THEN
         NULL;
      WHEN not_unique THEN
         RAISE not_unique;
   END;
/*
** Check in interface table
*/
   stmt_num := 2;
   SELECT count(*)
     INTO dummy
     FROM bom_ref_desgs_interface a
    WHERE transaction_id = trans_id
      AND (transaction_type = G_Insert
           OR (transaction_type= G_Update AND new_designator is not null))
      AND (UPPER(a.interface_entity_type) = 'BILL'
	      OR a.interface_entity_type is null)
      AND exists
          (SELECT 'same designator'
             FROM bom_ref_desgs_interface b
            WHERE b.rowid <> a.rowid
              AND (b.transaction_type = G_Insert
                   OR (b.transaction_type = G_Update
                       AND b.new_designator is not null))
              AND (UPPER(b.interface_entity_type) = 'BILL'
	           OR b.interface_entity_type is null)
              AND decode(b.transaction_type, G_Insert,
                    b.component_reference_designator, G_Update,
		    b.new_designator) = decode(a.transaction_type, G_Insert,
                    a.component_reference_designator, G_Update,
		    a.new_designator)
              AND b.component_sequence_id = a.component_sequence_id
              AND b.process_flag not in (3,7))
      AND process_flag not in (3,7);

   IF (dummy > 0) THEN
      RAISE not_unique;
   ELSE
      RETURN(0);
   END IF;
EXCEPTION
   WHEN Not_Unique THEN
      err_text := 'Bom_Reference_Designator_Api(Unique) ' ||'Duplicate reference designators';
      RETURN(9999);
   WHEN others THEN
      err_text := 'Bom_Reference_Designator_Api(Unique-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Verify_Unique_Designator;

/* --------------------------- Count_Designators  -------------------------- */
/*
NAME
    Count_Designators
DESCRIPTION
    Ensure that the number of ref desgs is same as component quantity
    since Quantity Related = Yes
REQUIRES
    trans_id    transaction_id
    cmp_seq_id  component_sequence_id
    quantity	component_quantity
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Count_Designators (
    trans_id    NUMBER,
    cmp_seq_id  NUMBER,
    quantity	NUMBER,
    err_text  OUT  VARCHAR2
)
    return INTEGER
IS
   ref_qty     		NUMBER;
   int_ref_qty 		NUMBER;
   int_del_ref_qty 	NUMBER;
   stmt_num    		NUMBER := 0;
BEGIN

   stmt_num := 1;
   SELECT count(*)
     INTO ref_qty
     FROM bom_reference_designators
    WHERE component_sequence_id = cmp_seq_id;

   stmt_num := 2;
   SELECT count(*)
     INTO int_ref_qty
     FROM bom_ref_desgs_interface
    WHERE component_sequence_id = cmp_seq_id
      AND transaction_type = G_Insert
      AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
      AND process_flag not in (3,7);

   stmt_num := 3;
   SELECT count(*)
     INTO int_del_ref_qty
     FROM bom_ref_desgs_interface
    WHERE component_sequence_id = cmp_seq_id
      AND transaction_type = G_Delete
      AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
      AND process_flag not in (3,7);

   IF (ref_qty + int_ref_qty - int_del_ref_qty <> quantity) THEN
      err_text := 'Bom_Reference_Designator_Api(Count) ' || 'Number of ref desg not equal to component qty';
      return (9999);
   END IF;

   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Reference_Designator_Api(Count-'||stmt_num||') '||substrb(SQLERRM,1,60);
      return(SQLCODE);
END Count_Designators;


/*---------------------- Validate_Reference_Designator ---------------------*/
/*
NAME
    Validate_Reference_Designator
DESCRIPTION
    Validate component sequence id
    Verify there are no reference designators for Planning bills or
	non-Standard components
    Verify reference designator is unique for a component
    If Quantity Related, then number of reference designators must equal
        Component Quantity
REQUIRES
    err_text    out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Validate_Reference_Designator (
    org_id              NUMBER,
    all_org             NUMBER := 2,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id	        NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
    ret_code                    NUMBER;
    stmt_num                    NUMBER := 0;
    dummy                       NUMBER;
    assy_id_dummy               NUMBER;
    org_id_dummy                NUMBER;
    assy_type_dummy             NUMBER;
    comp_id_dummy               NUMBER;
    commit_cnt                  NUMBER;
    comp_type                   NUMBER;
    continue_loop               BOOLEAN := TRUE;
    total_recs                  NUMBER;
    X_creation_date             DATE;
    X_created_by                NUMBER;
    X_ref_designator_comment	VARCHAR2(240);
    X_acd_type                  NUMBER;
    X_change_notice             VARCHAR2(10);
    X_attribute_category        VARCHAR2(30);
    X_attribute1                VARCHAR2(150);
    X_attribute2                VARCHAR2(150);
    X_attribute3                VARCHAR2(150);
    X_attribute4                VARCHAR2(150);
    X_attribute5                VARCHAR2(150);
    X_attribute6                VARCHAR2(150);
    X_attribute7                VARCHAR2(150);
    X_attribute8                VARCHAR2(150);
    X_attribute9                VARCHAR2(150);
    X_attribute10               VARCHAR2(150);
    X_attribute11               VARCHAR2(150);
    X_attribute12               VARCHAR2(150);
    X_attribute13               VARCHAR2(150);
    X_attribute14               VARCHAR2(150);
    X_attribute15               VARCHAR2(150);
    X_request_id                NUMBER;
    X_program_application_id    NUMBER;
    X_program_id                NUMBER;
    X_program_update_date       DATE;
    X_component_quantity	NUMBER;
    X_quantity_related		NUMBER;
/*
** Get UPDATE and DELETEs for row by row processing
*/
   CURSOR c2 IS
      SELECT component_sequence_id CSI, component_reference_designator CRD,
	     ref_designator_comment RDC,
             creation_date CD, created_by CB, change_notice CN,
             attribute_category AC, attribute1 A1, attribute2 A2,
             attribute3 A3, attribute4 A4, attribute5 A5, attribute6 A6,
             attribute7 A7, attribute8 A8, attribute9 A9, attribute10 A10,
             attribute11 A11, attribute12 A12, attribute13 A13,
             attribute14 A14,attribute15 A15,
             request_id RI, program_application_id PAI, program_id PI,
             program_update_date PUD, acd_type ACD,
             transaction_id TI, transaction_type A
        FROM bom_ref_desgs_interface
       WHERE process_flag = 2
         AND transaction_type in (G_Update, G_Delete)
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
         AND rownum < G_rows_to_commit;
/*
** Get UPDATE and INSERTs for set processing
*/
    CURSOR c1 IS
       SELECT component_sequence_id CSI, count(*) CNT,
              transaction_id TI, assembly_item_id AII,
              organization_id OI
         FROM bom_ref_desgs_interface
        WHERE process_flag = 2
          AND transaction_type in (G_Insert, G_Update)
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
     GROUP BY transaction_id, component_sequence_id,
              organization_id, assembly_item_id;
/*
** Get INSERTS for set processing
*/
    CURSOR c3 IS
	SELECT   change_notice CN, transaction_id TI,
                 organization_id OI
          FROM   bom_ref_desgs_interface
         WHERE   process_flag = 2
           AND   transaction_type in (G_Insert)
  	   AND   (UPPER(interface_entity_type) = 'BILL'
		 OR interface_entity_type is null);


BEGIN
/*
** FOR UPDATES and DELETES
*/
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c2rec IN c2 LOOP
         commit_cnt := commit_cnt + 1;
         stmt_num := 1;
/*
** Check if implemented record exists in Production
*/
         BEGIN
            SELECT brd.creation_date, brd.created_by,
                   brd.ref_designator_comment, brd.acd_type,
		   brd.change_notice,
                   brd.attribute_category, brd.attribute1,
                   brd.attribute2, brd.attribute3, brd.attribute4,
		   brd.attribute5, brd.attribute6, brd.attribute7,
		   brd.attribute8, brd.attribute9,
                   brd.attribute10, brd.attribute11, brd.attribute12,
		   brd.attribute13,
                   brd.attribute14, brd.attribute15, brd.request_id,
                   brd.program_application_id, brd.program_id,
		   brd.program_update_date, bic.quantity_related,
		   bic.component_quantity
              INTO X_creation_date, X_created_by,
                   X_ref_designator_comment, X_acd_type,
		   X_change_notice,
                   X_attribute_category, X_attribute1,
                   X_attribute2, X_attribute3, X_attribute4, X_attribute5,
                   X_attribute6, X_attribute7, X_attribute8, X_attribute9,
                   X_attribute10, X_attribute11, X_attribute12, X_attribute13,
                   X_attribute14, X_attribute15, X_request_id,
                   X_program_application_id, X_program_id,
                   X_program_update_date, X_quantity_related,
		   X_component_quantity
              FROM bom_reference_designators brd,
		   bom_inventory_components bic
             WHERE brd.component_sequence_id = c2rec.CSI
               AND brd.component_reference_designator = c2rec.CRD
	       AND brd.component_sequence_id = bic.component_sequence_id
	       AND bic.implementation_date is not null;

         EXCEPTION
            WHEN No_Data_Found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_REF_DESG_RECORD_MISSING',
                        err_text => err_text);

               UPDATE bom_ref_desgs_interface
                  SET process_flag = 3
                WHERE transaction_id = c2rec.TI;

               IF (ret_code <> 0) THEN
                   return(ret_code);
               END IF;
               GOTO continue_loop1;
         END;
/*
** FOR UPDATES
*/
         IF (c2rec.A = G_Update) THEN
/*
** Check if column is non-updatable and give an error if user filled it in
*/
            stmt_num := 2;
            IF (c2rec.CD is not null
                OR c2rec.CB is not null
                OR c2rec.ACD is not null
                OR c2rec.CN is not null) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => 999999,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_COLUMN_NOT_UPDATABLE',
                        err_text => err_text);

               UPDATE bom_ref_desgs_interface
                  SET process_flag = 3
                WHERE transaction_id = c2rec.TI;

               IF (ret_code <> 0) THEN
                   return(ret_code);
               END IF;
               GOTO continue_loop1;
            END IF;
/*
** Update interface record with production record's values
*/
            stmt_num := 3;
            UPDATE bom_ref_desgs_interface
               SET creation_date = X_creation_date,
                   created_by = X_created_by,
                   ref_designator_comment = nvl(c2rec.RDC,
                                        X_ref_designator_comment),
                   change_notice = X_change_notice,
                   attribute_category = decode(c2rec.AC, G_NullChar, '', NULL,
                                        X_attribute_category, c2rec.AC),
                   attribute1 = decode(c2rec.A1, G_NullChar, '', NULL,
                                        X_attribute1, c2rec.A1),
                   attribute2 = decode(c2rec.A2, G_NullChar, '', NULL,
                                        X_attribute2, c2rec.A2),
                   attribute3 = decode(c2rec.A3, G_NullChar, '', NULL,
                                        X_attribute3, c2rec.A3),
                   attribute4 = decode(c2rec.A4, G_NullChar, '', NULL,
                                        X_attribute4, c2rec.A4),
                   attribute5 = decode(c2rec.A5, G_NullChar, '', NULL,
                                        X_attribute5, c2rec.A5),
                   attribute6 = decode(c2rec.A6, G_NullChar, '', NULL,
                                        X_attribute6, c2rec.A6),
                   attribute7 = decode(c2rec.A7, G_NullChar, '', NULL,
                                        X_attribute7, c2rec.A7),
                   attribute8 = decode(c2rec.A8, G_NullChar, '', NULL,
                                        X_attribute8, c2rec.A8),
                   attribute9 = decode(c2rec.A9, G_NullChar, '', NULL,
                                        X_attribute9, c2rec.A9),
                   attribute10 = decode(c2rec.A10, G_NullChar, '', NULL,
                                        X_attribute10, c2rec.A10),
                   attribute11 = decode(c2rec.A11, G_NullChar, '', NULL,
                                        X_attribute11, c2rec.A11),
                   attribute12 = decode(c2rec.A12, G_NullChar, '', NULL,
                                        X_attribute12, c2rec.A12),
                   attribute13 = decode(c2rec.A13, G_NullChar, '', NULL,
                                        X_attribute13, c2rec.A13),
                   attribute14 = decode(c2rec.A14, G_NullChar, '', NULL,
                                        X_attribute14, c2rec.A14),
                   attribute15 = decode(c2rec.A15, G_NullChar, '', NULL,
                                        X_attribute15, c2rec.A15),
                   request_id = decode(c2rec.RI, G_NullChar, '', NULL,
                                        X_request_id, c2rec.RI),
                   program_application_id = decode(c2rec.PAI, G_NullNum,
                        '', NULL, X_program_application_id, c2rec.PAI),
                   program_id = decode(c2rec.PI, G_NullNum, '', NULL,
                                        X_program_id, c2rec.PI),
                   program_update_date = decode(c2rec.PUD, G_NullDate, '',
                                        NULL,X_program_update_date, c2rec.PUD)
             WHERE transaction_id = c2rec.TI
	       AND transaction_type = G_Update;
         ELSIF (c2rec.A = G_Delete) THEN
/*
** Count reference designators if quantity related is Yes
*/
            stmt_num := 4;
            IF (X_quantity_related = 1) THEN
               ret_code := Count_Designators (
                   trans_id => c2rec.TI,
                   cmp_seq_id => c2rec.CSI,
		   quantity => X_component_quantity,
                   err_text => err_text);
               IF (ret_code <> 0) THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_REF_DESG_COUNT_INVALID',
                        err_text => err_text);
                  UPDATE bom_ref_desgs_interface
	             SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     return(ret_code);
                  END IF;
                  GOTO continue_loop1;
               END IF;
            END IF;
/*
** Set Process Flag to 4 for "Deletes"
*/
            stmt_num := 5;
            UPDATE bom_ref_desgs_interface
               SET process_flag = 4
             WHERE transaction_id = c2rec.TI;
         END IF;
<<continue_loop1>>
         NULL;
      END LOOP;

      stmt_num := 6;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

   commit_cnt := 0;

/*
** FOR CREATE operation
*/

   FOR c3rec in c3 LOOP
/*
** Verfify Change_Notice
*/
	 stmt_num := 6.5;

         If (c3rec.CN is not NULL) THEN
         BEGIN
            SELECT 1
              INTO dummy
              FROM eng_engineering_changes
             WHERE organization_id = c3rec.OI
               AND change_notice = c3rec.CN;
    	 EXCEPTION
            WHEN no_data_found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'ENG_PARENTECO_NOT_EXIST',
                        err_text => err_text);
               UPDATE bom_ref_desgs_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop3;
         END;
	 END IF;

         /* continue the validation, not setting process_flag to 4 */

<<continue_loop3>>
      IF (commit_cnt = G_rows_to_commit) THEN
         COMMIT;
         commit_cnt := 0;
      END IF;
   END LOOP;


   commit_cnt := 0;

   FOR c1rec in c1 LOOP
/*
** Check for null ref desgs
*/
	 stmt_num := 7;

         commit_cnt := commit_cnt + 1;
         SELECT count(*)
           INTO dummy
           FROM bom_ref_desgs_interface
          WHERE transaction_id = c1rec.TI
            AND component_reference_designator is null;

         IF (dummy = 0) THEN
            null;
         ELSE
            ret_code := INVPUOPI.mtl_log_interface_err(
               org_id => org_id,
               user_id => user_id,
               login_id => login_id,
               prog_appid => prog_appid,
               prog_id => prog_id,
               req_id => req_id,
               trans_id => c1rec.TI,
               error_text => err_text,
               tbl_name => 'BOM_REF_DESGS_INTERFACE',
               msg_name => 'BOM_NULL_REF_DESGS',
               err_text => err_text);
            UPDATE bom_ref_desgs_interface
	       SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               return(ret_code);
            END IF;
            GOTO continue_loop;
         END IF;


/*
** Check if Component_Sequence_Id exists
*/
         stmt_num := 8;

         BEGIN
            SELECT bbom.assembly_item_id, bbom.organization_id,
                   bbom.assembly_type, bic.component_item_id,
                   bic.bom_item_type, mtl.bom_item_type,
		   bic.component_quantity, bic.quantity_related
              INTO assy_id_dummy, org_id_dummy, assy_type_dummy,
                   comp_id_dummy, comp_type, dummy,
		   X_component_quantity, X_quantity_related
              FROM bom_inventory_components bic,
                   bom_bill_of_materials bbom,
                   mtl_system_items mtl
             WHERE bic.component_sequence_id = c1rec.CSI
               AND bic.implementation_date is not null
               AND bbom.bill_sequence_id = bic.bill_sequence_id
               AND mtl.inventory_item_id = bbom.assembly_item_id
               AND mtl.organization_id = bbom.organization_id;

         EXCEPTION
            WHEN no_data_found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_COMP_SEQ_ID_INVALID',
                        err_text => err_text);
               UPDATE bom_ref_desgs_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
         END;
/*
** Reference Designators not allowed for planning bills or
** non-standard components or Product Families
*/
         stmt_num := 9;
         IF (dummy in (3,5) OR comp_type <> 4) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_NO_REF_DESGS_ALLOWED',
                        err_text => err_text);
            UPDATE bom_ref_desgs_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RETURN(ret_code);
            END IF;
            GOTO continue_loop;
         END IF;

/*
** Verify Reference Designator is unique for a component
*/
         stmt_num := 10;
         ret_code := Verify_Unique_Designator (
                trans_id => c1rec.TI,
                err_text => err_text);
         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id_dummy,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_DUPLICATE_REF_DESG',
                        err_text => err_text);
            UPDATE bom_ref_desgs_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RETURN(ret_code);
            END IF;
            GOTO continue_loop;
         END IF;

/*
** Count reference designators if quantity related is Yes
*/
         stmt_num := 11;
         IF (X_quantity_related = 1) THEN
            ret_code := Count_Designators (
                trans_id => c1rec.TI,
                cmp_seq_id => c1rec.CSI,
		quantity => X_component_quantity,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_REF_DESGS_INTERFACE',
                        msg_name => 'BOM_REF_DESG_COUNT_INVALID',
                        err_text => err_text);
               UPDATE bom_ref_desgs_interface
	          SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  return(ret_code);
               END IF;
               GOTO continue_loop;
            END IF;
         END IF;

         stmt_num := 12;
         UPDATE bom_ref_desgs_interface
            SET process_flag = 4
          WHERE transaction_id = c1rec.TI;

<<continue_loop>>
      IF (commit_cnt = G_rows_to_commit) THEN
         COMMIT;
         commit_cnt := 0;
      END IF;
   END LOOP;

   stmt_num := 13;
   COMMIT;

   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Reference_Designator_Api(Validate-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Validate_Reference_Designator;


/* --------------------- Transact_Reference_Designator ----------------------*/
/*
NAME
     Transact_Reference_Designator
DESCRIPTION
     Insert, update and delete reference designator data from the interface
     table, BOM_REF_DESGS_INTERFACE, into the production table,
     BOM_REFERENCE_DESIGNATORS.
REQUIRES
     prog_appid              Program application id
     prog_id                 Program id
     req_id 	             Request id
     user_id                 User id
     login_id                Login id
MODIFIES
     BOM_REFERENCE_DESIGNATORS
     BOM_REF_DESGS_INTERFACE
RETURNS
     0 if successful
     SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Transact_Reference_Designator
(       user_id                 NUMBER,
        login_id                NUMBER,
	prog_appid              NUMBER,
 	prog_id                 NUMBER,
        req_id 		        NUMBER,
        err_text           OUT   VARCHAR2)
   return integer
IS
   stmt_num                     NUMBER := 0;
   continue_loop                BOOLEAN := TRUE;
   commit_cnt                   NUMBER;

/*
** Select "Update" reference designator records
*/
   CURSOR c1 IS
      SELECT component_sequence_id CSI, component_reference_designator CRD,
             new_designator ND, ref_designator_comment RDC,
             last_update_date LUD, last_updated_by LUB,
             last_update_login LUL,
             attribute_category AC, attribute1 A1, attribute2 A2,
             attribute3 A3, attribute4 A4, attribute5 A5, attribute6 A6,
             attribute7 A7, attribute8 A8, attribute9 A9, attribute10 A10,
             attribute11 A11, attribute12 A12, attribute13 A13,
             attribute14 A14, attribute15 A15, request_id RI,
             program_application_id PAI, program_id PI,
             program_update_date PUD, transaction_id TI
        FROM bom_ref_desgs_interface
       WHERE process_flag = 4
         AND transaction_type = G_Update
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
         AND rownum < G_rows_to_commit;
/*
** Select "Delete" reference designators records
*/
   CURSOR c2 IS
      SELECT component_sequence_id CSI, component_reference_designator CRD,
             transaction_id TI
        FROM bom_ref_desgs_interface
       WHERE process_flag = 4
         AND transaction_type = G_Delete
         AND (UPPER(interface_entity_type) = 'BILL'
	      OR interface_entity_type is null)
         AND rownum < G_rows_to_commit;

BEGIN
/*
** Insert Reference Designators
*/
   stmt_num := 1;
   LOOP
      INSERT into BOM_REFERENCE_DESIGNATORS
                        (
                         COMPONENT_REFERENCE_DESIGNATOR,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
			 REF_DESIGNATOR_COMMENT,
			 CHANGE_NOTICE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         COMPONENT_SEQUENCE_ID,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID     ,
                         PROGRAM_UPDATE_DATE
                        )
                  SELECT
                         COMPONENT_REFERENCE_DESIGNATOR,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         REF_DESIGNATOR_COMMENT,
			 CHANGE_NOTICE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         COMPONENT_SEQUENCE_ID,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID     ,
                         PROGRAM_UPDATE_DATE
                    FROM bom_ref_desgs_interface
                   WHERE process_flag = 4
                     AND transaction_type = G_Insert
                     AND (UPPER(interface_entity_type) = 'BILL'
	                  OR interface_entity_type is null)
                     AND rownum < 500;

      EXIT when SQL%NOTFOUND;

      stmt_num := 2;
      UPDATE bom_ref_desgs_interface brdi
         SET process_flag = 7
       WHERE process_flag = 4
         AND transaction_type = G_Insert
         AND (UPPER(interface_entity_type) = 'BILL'
              OR interface_entity_type is null)
         AND exists
             (SELECT null
                FROM bom_reference_designators brd
               WHERE brd.component_sequence_id = brdi.component_sequence_id
                 AND brd.component_reference_designator =
                     brdi.component_reference_designator
                 AND nvl(brd.acd_type,999) = nvl(brdi.acd_type,999));
      COMMIT;

  END LOOP;


/* Bug 1322500 :
  Moved the UPDATE bom_ref_desgs_interface brdi  outside
 the LOOP as this was causing the Performance Issues when there are
 large number record in the interface table.
 This is due to the reason that for every 500 records inserted in
 the production table, the interface table is being updated once,
which is not required.
So moving this outside the loop, this ensures that the process flag is
updated to 7 for all processed rows only once after all the rows
are inserted.
The 11.0 bug fix uses a HINT on BOM_REFERENCE_DESIGNATORS Table in the
update stmt to force the Unique Index. This might not be acceptable in 11.5
given the difference in the optimizer. This is therefore removed in 11.5.
If the 11.5 instance faces performance issues, this hint can be introduced
to see if there is any performance benefit.
*/

/*
** Update Reference Designators
*/
   stmt_num := 3;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c1rec IN c1 LOOP
         commit_cnt := commit_cnt + 1;
         UPDATE bom_reference_designators
            SET component_reference_designator = nvl(c1rec.ND, c1rec.CRD),
                ref_designator_comment = c1rec.RDC,
                last_update_date    = c1rec.LUD,
                last_updated_by     = c1rec.LUB,
                last_update_login   = c1rec.LUL,
                attribute_category  = c1rec.AC,
                attribute1          = c1rec.A1,
                attribute2          = c1rec.A2,
                attribute3          = c1rec.A3,
                attribute4          = c1rec.A4,
                attribute5          = c1rec.A5,
                attribute6          = c1rec.A6,
                attribute7          = c1rec.A7,
                attribute8          = c1rec.A8,
                attribute9          = c1rec.A9,
                attribute10         = c1rec.A10,
                attribute11         = c1rec.A11,
                attribute12         = c1rec.A12,
                attribute13         = c1rec.A13,
                attribute14         = c1rec.A14,
                attribute15         = c1rec.A15,
                request_id          = c1rec.RI,
                program_application_id = c1rec.PAI,
                program_id          = c1rec.PI,
                program_update_date = c1rec.PUD
          WHERE component_sequence_id = c1rec.CSI
            AND component_reference_designator = c1rec.CRD;

         stmt_num := 4;
         UPDATE bom_ref_desgs_interface
            SET process_flag = 7
          WHERE transaction_id = c1rec.TI;
      END LOOP;

      stmt_num := 5;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

/*
** Delete Reference Designators
*/
   stmt_num := 6;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c2rec IN c2 LOOP
         commit_cnt := commit_cnt + 1;
         DELETE FROM bom_reference_designators
          WHERE component_sequence_id = c2rec.CSI
            AND component_reference_designator = c2rec.CRD;

         stmt_num := 7;
         UPDATE bom_ref_desgs_interface
            SET process_flag = 7
          WHERE transaction_id = c2rec.TI;
      END LOOP;

      stmt_num := 8;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;
   END LOOP;


   RETURN(0);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN(0);
   WHEN OTHERS THEN
      ROLLBACK;
      err_text := 'Bom_Reference_Designator_Api(Transact-'||stmt_num||') '||substrb(SQLERRM,1,500);
      return(SQLCODE);

END Transact_Reference_Designator;

/* ----------------------- Import_Reference_Designator -------------------- */
/*
NAME
    Import_Reference_Designator
DESCRIPTION
    Assign, Validate, and Transact the Reference Designator record in the
    interface table, BOM_REF_DESGS_INTERFACE.
REQUIRES
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Import_Reference_Designator (
    org_id              NUMBER,
    all_org             NUMBER := 1,
    user_id             NUMBER := -1,
    login_id            NUMBER := -1,
    prog_appid          NUMBER := -1,
    prog_id             NUMBER := -1,
    req_id 	        NUMBER := -1,
    del_rec_flag	NUMBER := 1,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
   err_msg	VARCHAR2(2000);
   ret_code     NUMBER := 1;
   stmt_num	NUMBER;
BEGIN
   stmt_num := 1;
   ret_code := Assign_Reference_Designator (
      org_id => org_id,
      all_org => all_org,
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);
   IF (ret_code <> 0) THEN
      err_text := 'Assign_Reference_Designator '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 2;
   ret_code := Validate_Reference_Designator (
      org_id => org_id,
      all_org => all_org,
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);
   IF (ret_code <> 0) THEN
      err_text := 'Validate_Reference_Designator '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 3;
   ret_code := Transact_Reference_Designator (
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);

   IF (ret_code <> 0) THEN
      err_text := 'Transact_Reference_Designator '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 4;
   IF (del_rec_flag = 1) THEN
      LOOP
         DELETE from bom_ref_desgs_interface
          WHERE process_flag = 7
            AND (UPPER(interface_entity_type) = 'BILL'
	         OR interface_entity_type is null)
            AND rownum < G_rows_to_commit;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;
   END IF;

   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Reference_Designator_Api(Import-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(ret_code);
END Import_Reference_Designator;


END Bom_Reference_Designator_Api;

/
