--------------------------------------------------------
--  DDL for Package Body BOM_BILL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BILL_API" AS
/* $Header: BOMOIBMB.pls 115.6 2002/06/14 12:33:05 pkm ship      $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMOIBMB.pls                                               |
| DESCRIPTION  : This package contains functions used to assign, validate   |
|                and transact Bill of Material data in the                  |
|		 BOM_BILL_OF_MATLS_INTERFACE table.			    |
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
|    03/10/97   Julie Maeyama   Created this new package		    |
+==========================================================================*/

/* ------------------------------ Assign_Bill -------------------------------*/
/*
NAME
    Assign_Bill
DESCRIPTION
    Assign defaults and ID's to bill record in the interface table
REQUIRES
    err_text    out buffer to return error message
MODIFIES
    BOM_BILL_OF_MATLS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Assign_Bill (
    org_id              NUMBER,
    all_org             NUMBER := 2,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
    stmt_num            NUMBER := 0;
    ret_code            NUMBER;
    commit_cnt          NUMBER;
    continue_loop       BOOLEAN := TRUE;
    X_rev_exists        NUMBER := 0;
    x_bom_item_type     NUMBER;
/*
** Select all INSERTS
*/
    CURSOR c1 IS
       SELECT organization_id OI, organization_code OC,
              assembly_item_id AII, item_number AIN,
              common_assembly_item_id CAII, common_item_number CAIN,
              common_organization_id COI, common_org_code COC,
              alternate_bom_designator ABD, transaction_id TI,
              bill_sequence_id BSI, common_bill_sequence_id CBSI,
              revision R, last_update_date LUD, last_updated_by LUB,
              creation_date CD, created_by CB, last_update_login LUL,
              transaction_type A, assembly_type AST
         FROM bom_bill_of_mtls_interface
        WHERE process_flag = 1
          AND transaction_type = G_Insert
          AND (all_org = 1
               OR
               (all_org = 2 AND organization_id = org_id))
          AND rownum < G_rows_to_commit;

/*
** Select all UPDATEs and DELETEs
*/
    CURSOR c2 IS
       SELECT organization_id OI, organization_code OC,
              assembly_item_id AII, item_number AIN,
              common_assembly_item_id CAII, common_item_number CAIN,
              common_organization_id COI, common_org_code COC,
              alternate_bom_designator ABD, transaction_id TI,
              bill_sequence_id BSI, common_bill_sequence_id CBSI,
              revision R, last_update_date LUD, last_updated_by LUB,
              creation_date CD, created_by CB, last_update_login LUL,
              transaction_type A, assembly_type AST
         FROM bom_bill_of_mtls_interface
        WHERE process_flag = 1
          AND transaction_type in (G_Update, G_Delete)
          AND (all_org = 1
               OR
               (all_org = 2 AND organization_id = org_id))
          AND rownum < G_rows_to_commit;

BEGIN
/** G_INSERT is 'CREATE'. Update 'INSERT' to 'CREATE' **/
   stmt_num := 0.5 ;
   LOOP
      UPDATE bom_bill_of_mtls_interface
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
      UPDATE bom_bill_of_mtls_interface ori
         SET organization_id = (SELECT organization_id
                                  FROM mtl_parameters a
                             WHERE a.organization_code = ori.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Insert, G_Delete, G_Update)
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
** FOR ALL - Assign transaction ids and bill sequence ids
*/
   stmt_num := 2;
   LOOP
      UPDATE bom_bill_of_mtls_interface ori
         SET transaction_id = mtl_system_items_interface_s.nextval,
             transaction_type = upper(transaction_type),
             bill_sequence_id = decode(upper(transaction_type), G_Insert,
		bom_inventory_components_s.nextval,
		bill_sequence_id)
       WHERE transaction_id is null
         AND upper(transaction_type) in (G_Insert, G_Update, G_Delete)
         AND process_flag = 1
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;
      stmt_num := 3;
      COMMIT;
   END LOOP;

/*
** FOR INSERTs - Assign values
*/
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c1rec IN c1 LOOP
         commit_cnt := commit_cnt + 1;
         x_bom_item_type := null;
         stmt_num := 4;
/*
** Check if Org Id is null
*/
         IF (c1rec.OI is null) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
            UPDATE bom_bill_of_mtls_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            GOTO continue_loop1;
         END IF;
/*
** Set assembly item ids
*/
         stmt_num := 5;
         IF (c1rec.AII is null) THEN
            ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id => c1rec.OI,
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop1;
            END IF;
         END IF;
/*
** Check for Product Family item
*/
         stmt_num := 5.1;
         DECLARE
            CURSOR GetBOMItemType IS
               SELECT bom_item_type
                 FROM mtl_system_items
                WHERE organization_id = c1rec.OI
		  AND inventory_item_id = c1rec.AII;
         BEGIN
            FOR c1 IN GetBOMItemType LOOP
               x_bom_item_type := c1.bom_item_type;
            END LOOP;

            IF (x_bom_item_type is null) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop1;
            ELSIF (x_bom_item_type = G_ProductFamily) THEN
               stmt_num := 5.2;
/*
** For Product Families - Insert revision record
*/
               IF (c1rec.R is not null) THEN
                  INSERT into mtl_item_revisions_interface
                     (INVENTORY_ITEM_ID,
                      ORGANIZATION_ID,
                      REVISION,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN,
                      EFFECTIVITY_DATE,
                      IMPLEMENTATION_DATE,
                      TRANSACTION_ID,
                      PROCESS_FLAG,
                      TRANSACTION_TYPE,
                      REQUEST_ID,
                      PROGRAM_APPLICATION_ID,
                      PROGRAM_ID,
                      PROGRAM_UPDATE_DATE)
                    VALUES
                      (c1rec.AII, c1rec.OI, UPPER(c1rec.R),
                       nvl(c1rec.LUD, sysdate),
                       nvl(c1rec.LUB, user_id),
                       nvl(c1rec.CD, sysdate),
                       nvl(c1rec.CB, user_id),
                       nvl(c1rec.LUL, user_id),
                       sysdate,
                       sysdate,
                       mtl_system_items_interface_s.nextval,
                       2,
                       G_Insert,
                       req_id,
                       prog_appid,
                       prog_id,
                       sysdate);
               END IF;

               stmt_num := 5.3;
               UPDATE bom_bill_of_mtls_interface
                  SET organization_id = nvl(organization_id, c1rec.OI),
                      assembly_item_id = nvl(assembly_item_id, c1rec.AII),
                      alternate_bom_designator = null,
		      specific_assembly_comment = null,
		      pending_from_ecn = null,
                      common_bill_sequence_id = c1rec.BSI,
                      common_organization_id = null,
                      common_assembly_item_id = null,
                      assembly_type = 1,
                      last_update_date = nvl(last_update_date, sysdate),
                      last_updated_by = nvl(last_updated_by, user_id),
                      creation_date = nvl(creation_date, sysdate),
                      created_by = nvl(created_by, user_id),
                      last_update_login = nvl(last_update_login, user_id),
                      request_id = nvl(request_id, req_id),
                      program_application_id =nvl(program_application_id,prog_appid),
                      program_id = nvl(program_id, prog_id),
                      program_update_date = nvl(program_update_date, sysdate),
                      process_flag = 2
                WHERE transaction_id = c1rec.TI;

               IF (SQL%NOTFOUND) THEN
                  err_text := 'Bom_Bill_Api('||stmt_num||')'||substrb(SQLERRM,1, 60);
                  RETURN(SQLCODE);
               END IF;
               GOTO continue_loop1;
            END IF;
         END;

         IF (c1rec.COI is null) AND (c1rec.COC is not null) AND
            (c1rec.CBSI is null) THEN
            ret_code := INVPUOPI.mtl_pr_trans_org_id(
                org_code => c1rec.COC,
                org_id => c1rec.COI,
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COMMON_ORG_MISSING',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop1;
            END IF;
         END IF;

/*
** Get common organization id
*/
         stmt_num := 6;
         If (c1rec.COI is null) AND (c1rec.COC is not null) AND
            (c1rec.CBSI is null) THEN
            ret_code := INVPUOPI.mtl_pr_trans_org_id(
                org_code => c1rec.COC,
                org_id => c1rec.COI,
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COMMON_ORG_MISSING',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop1;
            END IF;
         END IF;
/*
** Set common assembly item ids
*/
         stmt_num := 7;
         IF (c1rec.caii is null AND c1rec.CAIN is not null AND
            c1rec.CBSI is null) THEN
            IF (c1rec.COI is null) THEN
               c1rec.COI := c1rec.OI;
            END IF;
            ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id => c1rec.COI,
                flex_code => 'MSTK',
                flex_name => c1rec.CAIN,
                flex_id => c1rec.CAII,
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_CMN_ASSY_ITEM_INVALID',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop1;
            END IF;
         END IF;
/*
** Get Common bill info
*/
         stmt_num :=8;
         IF (c1rec.CBSI is null) THEN
            IF (c1rec.CAII is null) THEN
               c1rec.CBSI := c1rec.BSI;
	       c1rec.COI := null;
            ELSE
               BEGIN
                  SELECT bill_sequence_id
                    INTO c1rec.CBSI
                    FROM bom_bill_of_materials
                   WHERE organization_id = nvl(c1rec.COI, c1rec.OI)
                     AND assembly_item_id = c1rec.CAII
                     AND nvl(alternate_bom_designator, 'NONE') =
                         nvl(c1rec.ABD, 'NONE');
                  GOTO skip_interface1;
               EXCEPTION
                  WHEN no_data_found THEN
                     null;
               END;

               stmt_num := 9;
               BEGIN
                  SELECT bill_sequence_id
                    INTO c1rec.CBSI
                    FROM bom_bill_of_mtls_interface
                   WHERE organization_id = nvl(c1rec.COI, c1rec.OI)
                     AND transaction_type = G_Insert
                     AND assembly_item_id  = c1rec.CAII
                     AND nvl(alternate_bom_designator, 'NONE') =
                         nvl(c1rec.ABD, 'NONE')
                     AND process_flag not in (3,7)
                     AND rownum = 1;
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_CMN_BILL_SEQ_MISSING',
                        err_text => err_text);

                     UPDATE bom_bill_of_mtls_interface
                        SET process_flag = 3
                      WHERE transaction_id = c1rec.TI;

                     IF (ret_code <> 0) THEN
                        RETURN(ret_code);
                     END IF;
                     GOTO continue_loop1;
               END;
            END IF;
         ELSE                   -- Common Bill Sequence Id given
            stmt_num := 10;
            BEGIN
               SELECT assembly_item_id, organization_id
                 INTO c1rec.CAII, c1rec.COI
                 FROM bom_bill_of_materials
                WHERE bill_sequence_id = c1rec.CBSI;
                GOTO skip_interface1;
            EXCEPTION
               WHEN no_data_found THEN
                  null;
            END;

            stmt_num := 11;
            BEGIN
               SELECT assembly_item_id, organization_id
                 INTO c1rec.CAII, c1rec.COI
                 FROM bom_bill_of_mtls_interface
                WHERE bill_sequence_id = c1rec.CBSI
                  AND transaction_type = G_Insert
                  AND process_flag not in (3,7)
                  AND rownum = 1;
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
                     tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                     msg_name => 'BOM_CMN_BILL_SEQ_MISSING',
                     err_text => err_text);
                  UPDATE bom_bill_of_mtls_interface
                     SET process_flag = 3
                   WHERE transaction_id = c1rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop1;
            END;
         END IF;

         <<skip_interface1>>
         IF (c1rec.CBSI = c1rec.BSI) THEN
            c1rec.COI := NULL;
            c1rec.CAII := NULL;
         END IF;
/*
** Insert revision record
*/
         stmt_num := 12;
         IF (c1rec.R is not null) THEN
            INSERT into mtl_item_revisions_interface
                     (INVENTORY_ITEM_ID,
                      ORGANIZATION_ID,
                      REVISION,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN,
                      EFFECTIVITY_DATE,
                      IMPLEMENTATION_DATE,
                      TRANSACTION_ID,
                      PROCESS_FLAG,
                      TRANSACTION_TYPE,
                      REQUEST_ID,
                      PROGRAM_APPLICATION_ID,
                      PROGRAM_ID,
                      PROGRAM_UPDATE_DATE)
                    VALUES
                      (c1rec.AII, c1rec.OI, UPPER(c1rec.R),
                       nvl(c1rec.LUD, sysdate),
                       nvl(c1rec.LUB, user_id),
                       nvl(c1rec.CD, sysdate),
                       nvl(c1rec.CB, user_id),
                       nvl(c1rec.LUL, user_id),
                       sysdate,
                       sysdate,
                       mtl_system_items_interface_s.nextval,
                       2,
                       G_Insert,
                       req_id,
                       prog_appid,
                       prog_id,
                       sysdate);
         END IF;

         stmt_num := 13;
         UPDATE bom_bill_of_mtls_interface
            SET organization_id = nvl(organization_id, c1rec.OI),
                assembly_item_id = nvl(assembly_item_id, c1rec.AII),
                common_bill_sequence_id = c1rec.CBSI,
                common_organization_id = c1rec.COI,
                common_assembly_item_id = c1rec.CAII,
                assembly_type = nvl(c1rec.AST, 1),
                last_update_date = nvl(last_update_date, sysdate),
                last_updated_by = nvl(last_updated_by, user_id),
                creation_date = nvl(creation_date, sysdate),
                created_by = nvl(created_by, user_id),
                last_update_login = nvl(last_update_login, user_id),
                request_id = nvl(request_id, req_id),
                program_application_id =nvl(program_application_id,prog_appid),
                program_id = nvl(program_id, prog_id),
                program_update_date = nvl(program_update_date, sysdate),
                process_flag = 2
          WHERE transaction_id = c1rec.TI;

         IF (SQL%NOTFOUND) THEN
            err_text := 'Bom_Bill_Api('||stmt_num||')'||substrb(SQLERRM,1, 60);
            RETURN(SQLCODE);
         END IF;

         GOTO continue_loop1;

         <<continue_loop1>>
         NULL;
      END LOOP;

      stmt_num := 14;
      COMMIT;

      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

/*
** FOR UPDATES AND DELETES - Assign Values
*/
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c2rec IN c2 LOOP
         commit_cnt := commit_cnt + 1;
         x_bom_item_type := null;
         stmt_num := 15;
/*
** Assign primary key info
*/
         IF (c2rec.BSI is null) THEN
            -- Check if Org Id is null
            IF (c2rec.OI is null) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c2rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop2;
            END IF;

            -- Get Assembly Item Id
            stmt_num := 16;
            IF (c2rec.AII is null) THEN
               ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                  org_id => c2rec.OI,
                  flex_code => 'MSTK',
                  flex_name => c2rec.AIN,
                  flex_id => c2rec.AII,
                  set_id => -1,
                  err_text => err_text);
               IF (ret_code <> 0) THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_INV_ITEM_ID_MISSING',
                        err_text => err_text);
                  UPDATE bom_bill_of_mtls_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop2;
               END IF;
            END IF;
            stmt_num := 17;
/*
**  Get Bill Sequence Id
*/
            BEGIN
               SELECT bom.bill_sequence_id, bom.assembly_type,
		      msi.bom_item_type
                 INTO c2rec.BSI, c2rec.AST, x_bom_item_type
                 FROM bom_bill_of_materials bom,
		      mtl_system_items msi
                WHERE bom.organization_id = c2rec.OI
                  AND bom.assembly_item_id = c2rec.AII
                  AND nvl(bom.alternate_bom_designator, 'NONE') =
		      nvl(c2rec.ABD, 'NONE')
		  AND msi.organization_id = bom.organization_id
		  AND msi.inventory_item_id = bom.assembly_item_id;
            EXCEPTION
               WHEN no_data_found THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_BILL_SEQ_MISSING',
                        err_text => err_text);
                  UPDATE bom_bill_of_mtls_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop2;
            END;
/*
** Get Bill Info
*/
         ELSE	-- bill_sequence_id is given
            stmt_num := 18;
            BEGIN
               SELECT bom.assembly_item_id, bom.organization_id,
		      bom.alternate_bom_designator, bom.assembly_type,
		      msi.bom_item_type
                 INTO c2rec.AII, c2rec.OI, c2rec.ABD, c2rec.AST,
		      x_bom_item_type
                 FROM bom_bill_of_materials bom,
		      mtl_system_items msi
                WHERE bom.bill_sequence_id = c2rec.BSI
		  AND msi.organization_id = bom.organization_id
		  AND msi.inventory_item_id = bom.assembly_item_id;
            EXCEPTION
               WHEN no_data_found THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_BILL_SEQ_MISSING',
                        err_text => err_text);
                  UPDATE bom_bill_of_mtls_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop2;
            END;
         END IF;
/*
** Assign Common Info ONLY for UPDATE's
*/
         IF (c2rec.A = G_Update) THEN
            stmt_num := 18.1;
/*
** For Product Families
*/
            IF (x_bom_item_type = G_ProductFamily) THEN
               UPDATE bom_bill_of_mtls_interface
                  SET organization_id = c2rec.OI,
                      assembly_item_id = c2rec.AII,
                      alternate_bom_designator = c2rec.ABD,
                      bill_sequence_id = c2rec.BSI,
                      last_update_date = nvl(last_update_date, sysdate),
                      last_updated_by = nvl(last_updated_by, user_id),
                      last_update_login = nvl(last_update_login, user_id),
                      request_id = nvl(request_id, req_id),
                      program_application_id =nvl(program_application_id,prog_appid),
                      program_id = nvl(program_id, prog_id),
                      program_update_date = nvl(program_update_date, sysdate),
                      process_flag = 2
                WHERE transaction_id = c2rec.TI;

               IF (SQL%NOTFOUND) THEN
                  err_text := 'Bom_Bill_Api('||stmt_num||')'||substrb(SQLERRM,1,60);
                  RETURN(SQLCODE);
               END IF;
               GOTO continue_loop2;
            END IF;

/*
** Get common organization id
*/
            stmt_num := 19;
            IF (c2rec.COI is null) AND (c2rec.COC is not null) AND
               (c2rec.CBSI is null) THEN
               ret_code := INVPUOPI.mtl_pr_trans_org_id(
                  org_code => c2rec.COC,
                  org_id => c2rec.COI,
                  err_text => err_text);
               IF (ret_code <> 0) THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                     org_id => NULL,
                     user_id => user_id,
                     login_id => login_id,
                     prog_appid => prog_appid,
                     prog_id => prog_id,
                     req_id => req_id,
                     trans_id => c2rec.TI,
                     error_text => err_text,
                     tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                     msg_name => 'BOM_COMMON_ORG_MISSING',
                     err_text => err_text);
                  UPDATE bom_bill_of_mtls_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop2;
               END IF;
            END IF;
/*
** Get common assembly item id
** If common org id is null, set it to org id
*/
            stmt_num := 20;
            IF (c2rec.CAII is null AND c2rec.CAIN is not null AND
               c2rec.CBSI is null) THEN
               IF (c2rec.COI is null) THEN
                  c2rec.COI := c2rec.OI;
               END IF;
               ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                  org_id => c2rec.COI,
                  flex_code => 'MSTK',
                  flex_name => c2rec.CAIN,
                  flex_id => c2rec.CAII,
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
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_CMN_ASSY_ITEM_INVALID',
                        err_text => err_text);
                  UPDATE bom_bill_of_mtls_interface
                     SET process_flag = 3
                   WHERE transaction_id = c2rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop2;
               END IF;
            END IF;

/*
** Get Common bill info
*/
            IF (c2rec.CBSI is null) THEN
               IF (c2rec.CAII is null) THEN
                  c2rec.COI := null;
               ELSE
                  stmt_num :=21;
                  BEGIN
                     SELECT bill_sequence_id
                       INTO c2rec.CBSI
                       FROM bom_bill_of_materials
                      WHERE organization_id = nvl(c2rec.COI, c2rec.OI)
		        AND assembly_item_id = c2rec.CAII
                        AND nvl(alternate_bom_designator, 'NONE') =
			    nvl(c2rec.ABD, 'NONE');
                  GOTO skip_interface2;
                  EXCEPTION
                     WHEN no_data_found THEN
                        null;
                  END;
                  stmt_num := 22;
		  BEGIN
                     SELECT bill_sequence_id
                       INTO c2rec.CBSI
                       FROM bom_bill_of_mtls_interface
                      WHERE organization_id = nvl(c2rec.COI, c2rec.OI)
                        AND transaction_type = G_Insert
                        AND assembly_item_id  = c2rec.CAII
                        AND nvl(alternate_bom_designator, 'NONE') =
			    nvl(c2rec.ABD, 'NONE')
                        AND process_flag not in (3,7)
                        AND rownum = 1;
		  EXCEPTION
 		     WHEN no_data_found THEN
                        ret_code := INVPUOPI.mtl_log_interface_err(
                           org_id => NULL,
                           user_id => user_id,
                           login_id => login_id,
                           prog_appid => prog_appid,
                           prog_id => prog_id,
                           req_id => req_id,
                           trans_id => c2rec.TI,
                           error_text => err_text,
                           tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                           msg_name => 'BOM_CMN_BILL_SEQ_MISSING',
                           err_text => err_text);

                        UPDATE bom_bill_of_mtls_interface
                           SET process_flag = 3
                         WHERE transaction_id = c2rec.TI;

                        IF (ret_code <> 0) THEN
                           RETURN(ret_code);
                        END IF;
                        GOTO continue_loop2;
                  END;
               END IF;
            ELSIF (c2rec.CBSI = G_NullNum) THEN
               c2rec.CAII := null;
               c2rec.COI  := null;
            ELSE                        -- Common Bill Sequence Id given
               stmt_num := 23;
               BEGIN
                  SELECT assembly_item_id, organization_id
                    INTO c2rec.CAII, c2rec.COI
                    FROM bom_bill_of_materials
                   WHERE bill_sequence_id = c2rec.CBSI;
                   GOTO skip_interface2;
               EXCEPTION
                  WHEN no_data_found THEN
		     null;
               END;

               stmt_num := 24;
               BEGIN
                  SELECT assembly_item_id, organization_id
                    INTO c2rec.CAII, c2rec.COI
                    FROM bom_bill_of_mtls_interface
                   WHERE bill_sequence_id = c2rec.CBSI
		     AND transaction_type = G_Insert
                     AND process_flag not in (3,7)
                     AND rownum = 1;
	       EXCEPTION
	          WHEN no_data_found THEN
                     ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_CMN_BILL_SEQ_MISSING',
                        err_text => err_text);
                     UPDATE bom_bill_of_mtls_interface
                        SET process_flag = 3
                      WHERE transaction_id = c2rec.TI;

                     IF (ret_code <> 0) THEN
                        RETURN(ret_code);
                     END IF;
                     GOTO continue_loop2;
               END;
            END IF;

	    <<skip_interface2>>
            stmt_num := 25;
            UPDATE bom_bill_of_mtls_interface
               SET organization_id = c2rec.OI,
                   assembly_item_id = c2rec.AII,
                   alternate_bom_designator = c2rec.ABD,
                   bill_sequence_id = c2rec.BSI,
                   common_bill_sequence_id = c2rec.CBSI,
                   common_organization_id = c2rec.COI,
                   common_assembly_item_id = c2rec.CAII,
                   last_update_date = nvl(last_update_date, sysdate),
                   last_updated_by = nvl(last_updated_by, user_id),
                   last_update_login = nvl(last_update_login, user_id),
                   request_id = nvl(request_id, req_id),
                   program_application_id =nvl(program_application_id,prog_appid),
                   program_id = nvl(program_id, prog_id),
                   program_update_date = nvl(program_update_date, sysdate),
                   process_flag = 2
             WHERE transaction_id = c2rec.TI;

            IF (SQL%NOTFOUND) THEN
               err_text := 'Bom_Bill_Api('||stmt_num||')'||substrb(SQLERRM,1,60);
               RETURN(SQLCODE);
            END IF;
         ELSIF (c2rec.A = G_Delete) THEN
            stmt_num := 26;
            UPDATE bom_bill_of_mtls_interface
               SET organization_id = c2rec.OI,
                   assembly_item_id = c2rec.AII,
                   alternate_bom_designator = c2rec.ABD,
                   assembly_type = c2rec.AST,
                   bill_sequence_id = c2rec.BSI,
                   process_flag = 2
             WHERE transaction_id = c2rec.TI;

            IF (SQL%NOTFOUND) THEN
               err_text := 'Bom_Bill_Api('||stmt_num||')'||substrb(SQLERRM, 1, 60);
               RETURN(SQLCODE);
            END IF;
         END IF;
         <<continue_loop2>>
         NULL;
      END LOOP;

      stmt_num := 27;
      COMMIT;

      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

   RETURN (0);
EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Bill_Api(Assign-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Assign_Bill;


/* ------------------------ Verify_Bom_Seq_Id_Exists  --------------------- */
/*
NAME
    Verify_Bom_Seq_Id_Exists - verify for uniqueness or existence of bom
        sequence id
DESCRIPTION
    Verifies if the given bom sequence id is unique in prod and
        interface tables
REQUIRES
    bom_sq_id   bom_sequecne_id
    mode_type   1 - verify uniqueness of bom
                2 - verify existence of bom
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    count of routings with same bom_sequence_id if any found
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Verify_Bom_Seq_Id_Exists(
        bom_seq_id      NUMBER,
        mode_type       NUMBER,
        err_text  OUT   VARCHAR2
)
    return INTEGER
IS
    cnt         NUMBER := 0;
    NOT_UNIQUE  EXCEPTION;
    stmt_num    NUMBER := 0;
BEGIN
/*
** first check in prod tables
*/
    stmt_num := 1;
    BEGIN
        SELECT bill_sequence_id
          INTO cnt
          FROM bom_bill_of_materials
         WHERE bill_sequence_id = bom_seq_id;

        IF (mode_type = 2) THEN
           RETURN(0);
        ELSE
           raise not_unique;
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
           null;
        WHEN not_unique THEN
           raise not_unique;
    END;
/*
** check in interface table
*/
    stmt_num := 2;
    SELECT count(*)
      INTO cnt
      FROM bom_bill_of_mtls_interface
     WHERE bill_sequence_id = bom_seq_id
       AND transaction_type = G_Insert
       AND process_flag = 4;

    IF (cnt = 0) THEN
       IF (mode_type = 1) THEN
          RETURN(0);
       ELSE
          raise NO_DATA_FOUND;
       END IF;
    END IF;

    IF (cnt > 0) THEN
       IF (mode_type = 1) THEN
          raise NOT_UNIQUE;
       ELSE
          RETURN(0);
       END IF;
    END IF;

EXCEPTION
   WHEN No_Data_Found THEN
      err_text := substrb('Bom_Bill_Api(Exists): Bill does not exist '||
                  SQLERRM,1,70);
      RETURN(9999);
   WHEN Not_Unique THEN
      err_text := 'Bom_Bill_Api(Exists) '||'Duplicate bill sequence id';
      RETURN(9999);
   WHEN others THEN
      err_text := 'Bom_Bill_Api(Exists-'||stmt_num||') '|| substrb(SQLERRM,1,60);
      RETURN(SQLCODE);
END Verify_Bom_Seq_Id_Exists;


/* ------------------------- Verify_Duplicate_Bom -------------------------- */
/*
NAME
    Verify_duplicate_bom
DESCRIPTION
    Verifies in the production and interface tables if bom with
    same alt exists.  Also verifies for an alternate bom, if the
    primary already exists.

REQUIRES
    org_id      organization_id
    assy_id     assembly_item_id
    alt_desg    alternate routing designator
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    cnt  if bom already exists
    9999 if primary does not exist
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Verify_Duplicate_Bom(
        org_id          NUMBER,
        assy_id         NUMBER,
        alt_desg        VARCHAR2,
        assy_type       NUMBER,
        err_text  OUT   VARCHAR2
)
    return INTEGER
IS
    cnt                 NUMBER := 0;
    ALREADY_EXISTS      EXCEPTION;
    stmt_num            NUMBER := 0;
BEGIN
/*
** Check if Bill Exists in Production
*/
    stmt_num := 1;
    BEGIN
       SELECT 1
         INTO cnt
         FROM bom_bill_of_materials
        WHERE organization_id = org_id
          AND assembly_item_id = assy_id
          AND nvl(alternate_bom_designator, 'NONE') =
                nvl(alt_desg, 'NONE');
       RAISE already_exists;
    EXCEPTION
        WHEN already_exists THEN
           err_text := 'Bom_Bill_Api(Duplicate): Bill already exists in production';
           RETURN(cnt);
        WHEN no_data_found THEN
           NULL;
    END;
/*
** Check if Bill Exists in Interface Table
*/
    stmt_num := 2;
    BEGIN
       SELECT 1
         INTO cnt
         FROM bom_bill_of_mtls_interface
        WHERE organization_id = org_id
          AND assembly_item_id = assy_id
          AND nvl(alternate_bom_designator, 'NONE') =
              nvl(alt_desg, 'NONE')
	  AND transaction_type = G_Insert
          AND rownum = 1
          AND process_flag = 4;

       RAISE already_exists;
    EXCEPTION
        WHEN already_exists THEN
           err_text := 'Bom_Bill_Api(Duplicate): Bill already exists in interface';
           RETURN(cnt);
        WHEN no_data_found THEN
            NULL;
    END;

/*
** For alternate bills, verify if primary exists (or will exist)
** Alternate mfg bills cannot have primary eng bills
*/
    stmt_num := 3;
    IF (alt_desg is not null) THEN
       BEGIN
          SELECT 1
            INTO cnt
            FROM bom_bill_of_materials
           WHERE organization_id = org_id
             AND assembly_item_id = assy_id
             AND alternate_bom_designator is null
             AND ((assy_type = 2)
                  OR
                   (assy_type =1 and assembly_type = 1)
                  );
          RETURN(0);
       EXCEPTION
          WHEN no_data_found THEN
             NULL;
       END;

       stmt_num := 4;
       BEGIN
          SELECT bill_sequence_id
            INTO cnt
            FROM bom_bill_of_mtls_interface
           WHERE organization_id = org_id
             AND assembly_item_id = assy_id
             AND alternate_bom_designator is null
             AND ((assy_type = 2)
                  OR
                   (assy_type =1 and assembly_type = 1)
                  )
             AND process_flag = 4
	     AND transaction_type = G_Insert
             AND rownum = 1;
        EXCEPTION
           WHEN no_data_found THEN
              err_text := 'Bom_Bill_Api(Duplicate): Valid primary does not exist';
              RETURN(9999);
        END;
     END IF;

     RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Bill_Api(Duplicate-'||stmt_num||') '||substrb(SQLERRM,1,60);
      return(SQLCODE);
END Verify_Duplicate_Bom;


/* --------------------------- Verify_Common_Bom ----------------------------*/
/*
NAME
    Verify_common_bom
DESCRIPTION
    if bom is mfg then it cannot point to engineerging bom
    if common bom then bill cannot have components
    if inter-org common then all components items must be in both orgs
    Common bill's org and current bill's org must have same master org
    Common bill's alt must be same as current bill's alt
    Common bill cannot have same assembly_item_id/org_id as current bill
    Common bill cannot reference a common bill

REQUIRES
    bom_id      bill_sequence_id
    cmn_bom_id  common bill_seqience_id
    bom_type    assembly_type
    item_id     assembly item id
    cmn_item_id common item id
    org_id      org id
    cmn_org_id  common org id
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    9999 if invalid item
    SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Verify_common_bom(
        bom_id          NUMBER,
        cmn_bom_id      NUMBER,
        bom_type        NUMBER,
        item_id         NUMBER,
        cmn_item_id     NUMBER,
        org_id          NUMBER,
        cmn_org_id      NUMBER,
        alt_desg        VARCHAR2,
        err_text  OUT   VARCHAR2
)
    return INTEGER
IS
    cnt                  NUMBER;
    bit                  NUMBER;
    base_id              NUMBER;
    ato             VARCHAR2(1);
    pto             VARCHAR2(1);
    MISSING_ITEMS     EXCEPTION;
    MISSING_SUB_ITEMS EXCEPTION;
    stmt_num            NUMBER := 0;

BEGIN
/*
** Common bill's org and current bill's org must have same master org
*/
   stmt_num := 1;
   BEGIN
      SELECT 1
        INTO cnt
        FROM mtl_parameters mp1, mtl_parameters mp2
       WHERE mp1.organization_id = org_id
         AND mp2.organization_id = cmn_org_id
         AND mp1.master_organization_id = mp2.master_organization_id;
   EXCEPTION
      WHEN no_data_found THEN
         err_text := 'Bom_Bill_Api(Common): Invalid common master org id';
         RETURN(9999);
   END;
/*
** Common bill's alt must be same as current bill's alt
** Common bill cannot have same assembly_item_id/org_id as current bill
** Common bill must be mfg bill if current bill is a mfg bill
** Common bill cannot reference a common bill
** Common bill sequence id must have the correct common_assembly_item_id
**  and common_organization_id
*/
   stmt_num := 2;
   BEGIN
      SELECT bill_sequence_id
        INTO cnt
        FROM bom_bill_of_materials
       WHERE bill_sequence_id = cmn_bom_id
         AND assembly_item_id = cmn_item_id
         AND organization_id  = cmn_org_id
         AND nvl(alternate_bom_designator, 'NONE') = nvl(alt_desg, 'NONE')
         AND common_bill_sequence_id = bill_sequence_id
         AND (assembly_item_id <> item_id
               OR
               organization_id <> org_id)
         AND ((bom_type <> 1)
               OR
               (bom_type = 1 AND assembly_type = 1));
      GOTO check_ops;
   EXCEPTION
      WHEN no_data_found THEN
         null;
   END;

   stmt_num := 3;
   SELECT bill_sequence_id
     INTO cnt
     FROM bom_bill_of_mtls_interface
    WHERE bill_sequence_id = cmn_bom_id
      AND assembly_item_id = cmn_item_id
      AND organization_id  = cmn_org_id
      AND nvl(alternate_bom_designator, 'NONE') = nvl(alt_desg, 'NONE')
      AND common_bill_sequence_id = bill_sequence_id
      AND (assembly_item_id <> item_id
           OR
           organization_id <> org_id)
      AND process_flag = 4
      AND transaction_type in (G_Insert, G_Update)
      AND ((bom_type <> 1)
            OR
             (bom_type = 1 AND assembly_type = 1));
<<check_ops>>

/*
** check to see if components exist in both orgs for inter-org commons
*/
   stmt_num := 4;
   IF (org_id <> cmn_org_id) THEN
      -- Get item attributes for the bill
      SELECT bom_item_type, base_item_id, replenish_to_order_flag,
             pick_components_flag
        INTO bit, base_id, ato, pto
        FROM mtl_system_items
       WHERE inventory_item_id = item_id
         AND organization_id = org_id;

      stmt_num := 5;
      SELECT count(*)
        INTO cnt
        FROM bom_inventory_components bic
       WHERE bic.bill_sequence_id = cmn_bom_id
         AND not exists
                 (SELECT 'x'
                    FROM mtl_system_items s
                   WHERE s.organization_id = org_id
                     AND s.inventory_item_id = bic.component_item_id
                     AND ((bom_type = 1 AND s.eng_item_flag = 'N')
                           OR (bom_type = 2))
                     AND s.bom_enabled_flag = 'Y'
                     AND s.inventory_item_id <> item_id
                     AND ((bit = 1 AND s.bom_item_type <> 3)
                           OR (bit = 2 AND s.bom_item_type <> 3)
                           OR (bit = 3)
                           OR (bit = 4
                               AND (s.bom_item_type = 4
                                    OR (s.bom_item_type IN (2, 1)
                                        AND s.replenish_to_order_flag = 'Y'
                                        AND base_id IS NOT NULL
                                        AND ato = 'Y'))))
                     AND (bit = 3
                          OR
                          pto = 'Y'
                          OR
                          s.pick_components_flag = 'N')
                     AND (bit = 3
                          OR
                          NVL(s.bom_item_type, 4) <> 2
                          OR
                          (s.bom_item_type = 2
                           AND ((pto = 'Y'
                                 AND s.pick_components_flag = 'Y')
                               OR (ato = 'Y'
                                   AND s.replenish_to_order_flag = 'Y'))))
                     AND not(bit = 4
                             AND pto = 'Y'
                             AND s.bom_item_type = 4
                             AND s.replenish_to_order_flag = 'Y')
                );

      IF (cnt > 0) THEN
         RAISE missing_items;
      END IF;
   END IF;
/*
** check if substitute components exist in both orgs for inter-org commons
*/
   stmt_num := 6;
   IF (org_id <> cmn_org_id) THEN    /* Comp and sub comp in production */
      SELECT count(*)
        INTO cnt
        FROM bom_inventory_components bic,
             bom_substitute_components bsc
       WHERE bic.bill_sequence_id = cmn_bom_id
         AND bic.component_sequence_id = bsc.component_sequence_id
         AND bsc.substitute_component_id not in
               (select msi1.inventory_item_id
                  from mtl_system_items msi1, mtl_system_items msi2
                 where msi1.organization_id = org_id
                   and   msi1.inventory_item_id = bsc.substitute_component_id
                   and   msi2.organization_id = cmn_org_id
                   and   msi2.inventory_item_id = msi1.inventory_item_id);
      IF (cnt > 0) THEN
         raise MISSING_SUB_ITEMS;
      END IF;
    END IF;

/*
** check to see if bill item and common item have same bom_item_type,
** pick_components_flag and replenish_to_order_flag
** Common item must have bom_enabled_flag = 'Y'
*/
    stmt_num := 7;
    BEGIN
       SELECT 1
         INTO cnt
         FROM mtl_system_items msi1, mtl_system_items msi2
        WHERE msi1.organization_id = org_id
          AND msi1.inventory_item_id = item_id
          AND msi2.organization_id = cmn_org_id
          AND msi2.inventory_item_id = cmn_item_id
          AND msi2.bom_enabled_flag = 'Y'
          AND msi1.bom_item_type = msi2.bom_item_type
          AND msi1.pick_components_flag = msi2.pick_components_flag
          AND msi1.replenish_to_order_flag = msi2.replenish_to_order_flag;
    EXCEPTION
       WHEN no_data_found THEN
          err_text := 'Bom_Bill_Api(Common): Invalid item attributes';
          RETURN(9999);
    END;

    RETURN(0);
EXCEPTION
    WHEN No_Data_Found THEN
       err_text := 'Bom_Bill_Api(Common):Invalid common bill';
       RETURN(9999);
    WHEN Missing_Items THEN
       err_text := 'Bom_Bill_Api(Common): Component items not in both orgs or invalid';
       RETURN(9999);
    WHEN Missing_Sub_Items THEN
       err_text := 'Bom_Bill_Api(Common): Substitute items not in both orgs';
       RETURN(9999);
    WHEN others THEN
       err_text := 'Bom_Bill_Api(Common-'||stmt_num||') '||substrb(SQLERRM,1,60);
       RETURN(SQLCODE);
END Verify_Common_Bom;


/* ----------------------------- Validate_Bill ----------------------------- */
/*
NAME
    Validate_Bill
DESCRIPTION
    Validate component sequence id
    Validate substitute component id
    Verify there are no substitute components for Planning bills or
	non-Standard components
    Verify substitute component is unique for a component
    Verify substitute component is not the same as the bill or component
    Verify substitute quantity is not zero
REQUIRES
    err_text    out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Validate_Bill (
    org_id              NUMBER,
    all_org             NUMBER := 2,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
/*
** Select all INSERTS
*/
   CURSOR C1 IS
      SELECT organization_id OI, bill_sequence_id BSI,
             assembly_item_id AII, common_bill_sequence_id CBSI,
             common_assembly_item_id CAII, assembly_type AST,
             common_organization_id COI, transaction_type A,
             alternate_bom_designator ABD, transaction_id TI,
	     pending_from_ecn PFE
        FROM bom_bill_of_mtls_interface
       WHERE process_flag = 2
         AND transaction_type = G_Insert
         AND rownum < G_rows_to_commit;

/*
** Select all UPDATES and DELETES
*/
   CURSOR c2 is
      SELECT organization_id OI, bill_sequence_id BSI,
             assembly_item_id AII, common_bill_sequence_id CBSI,
             common_assembly_item_id CAII, assembly_type AST,
             common_organization_id COI, transaction_type A,
             alternate_bom_designator ABD, transaction_id TI,
             next_explode_date NED, creation_date CD,
             specific_assembly_comment SAC, created_by CB,
             attribute_category AC, attribute1 A1, attribute2 A2,
             attribute3 A3, attribute4 A4, attribute5 A5, attribute6 A6,
             attribute7 A7, attribute8 A8, attribute9 A9, attribute10 A10,
             attribute11 A11, attribute12 A12, attribute13 A13,
             attribute14 A14,attribute15 A15, pending_from_ecn PFE,
             request_id RI, program_application_id PAI, program_id PI,
             program_update_date PUD
        FROM bom_bill_of_mtls_interface
       WHERE process_flag = 2
         AND transaction_type in (G_Update, G_Delete)
         AND rownum < G_rows_to_commit;
/*
** Select UPDATES for Common Bill Verification
*/
   CURSOR c3 is
      SELECT organization_id OI, bill_sequence_id BSI,
             assembly_item_id AII, common_bill_sequence_id CBSI,
             common_assembly_item_id CAII, assembly_type AST,
             common_organization_id COI, transaction_type A,
             alternate_bom_designator ABD, transaction_id TI
        FROM bom_bill_of_mtls_interface
       WHERE process_flag = 99
         AND transaction_type = G_Update
         AND rownum < G_rows_to_commit;

   ret_code                     NUMBER;
   stmt_num                     NUMBER := 0;
   dummy_id                     NUMBER;
   commit_cnt                   NUMBER;
   continue_loop                BOOLEAN := TRUE;
   x_bom_item_type		NUMBER;
   X_creation_date              DATE;
   X_created_by                 NUMBER;
   X_common_assembly_item_id    NUMBER;
   X_specific_assembly_comment  VARCHAR2(240);
   X_pending_from_ecn           VARCHAR2(10);
   X_attribute_category         VARCHAR2(30);
   X_attribute1                 VARCHAR2(150);
   X_attribute2                 VARCHAR2(150);
   X_attribute3                 VARCHAR2(150);
   X_attribute4                 VARCHAR2(150);
   X_attribute5                 VARCHAR2(150);
   X_attribute6                 VARCHAR2(150);
   X_attribute7                 VARCHAR2(150);
   X_attribute8                 VARCHAR2(150);
   X_attribute9                 VARCHAR2(150);
   X_attribute10                VARCHAR2(150);
   X_attribute11                VARCHAR2(150);
   X_attribute12                VARCHAR2(150);
   X_attribute13                VARCHAR2(150);
   X_attribute14                VARCHAR2(150);
   X_attribute15                VARCHAR2(150);
   X_request_id                 NUMBER;
   X_program_application_id     NUMBER;
   X_program_id                 NUMBER;
   X_program_update_date        DATE;
   X_assembly_type              NUMBER;
   X_common_bill_sequence_id    NUMBER;
   X_common_organization_id     NUMBER;
   X_next_explode_date          DATE;

BEGIN
/*
** FOR INSERTS - Validate
*/
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c1rec IN c1 LOOP
         commit_cnt := commit_cnt + 1;
         x_bom_item_type := null;
         stmt_num := 1;
/*
** Verify org id
*/
         BEGIN
            SELECT organization_id
              INTO dummy_id
              FROM mtl_parameters
             WHERE organization_id = c1rec.OI;
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_INVALID_ORG_ID',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
         END;
/*
** Check for Product Family item
*/
         stmt_num := 1.1;
         DECLARE
            CURSOR GetBOMItemType IS
               SELECT bom_item_type
                 FROM mtl_system_items
                WHERE organization_id = c1rec.OI
		  AND inventory_item_id = c1rec.AII;
         BEGIN
            FOR c1 IN GetBOMItemType LOOP
               x_bom_item_type := c1.bom_item_type;
            END LOOP;

            IF (x_bom_item_type is null) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => NULL,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ASSY_ITEM_MISSING',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
            ELSIF (x_bom_item_type = G_ProductFamily) THEN
               GOTO Check_Bill_Seq_Id;
            END IF;
         END;

/*
** Verify Alternate Designator
*/
         stmt_num := 2;
         IF (c1rec.ABD is not null) THEN
            BEGIN
               SELECT 1
                 INTO dummy_id
                 FROM bom_alternate_designators
                WHERE organization_id = c1rec.OI
                  AND alternate_designator_code = c1rec.ABD;
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_INVALID_ALTERNATE',
                        err_text => err_text);
                  UPDATE bom_bill_of_mtls_interface
                     SET process_flag = 3
                   WHERE transaction_id = c1rec.TI;

                  IF (ret_code <> 0) THEN
                     RETURN(ret_code);
                  END IF;
                  GOTO continue_loop;
            END;
         END IF;
/*
** Verify Assembly Item Id
*/
         stmt_num := 3;
         BEGIN
            SELECT 1
              INTO dummy_id
              FROM mtl_system_items
             WHERE organization_id = c1rec.OI
               AND inventory_item_id = c1rec.AII;
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ASSEMBLY_ITEM_INVALID',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
         END;

/*
** Verify Pending_From_Eco
*/
	 stmt_num := 3.5;
         if ( c1rec.PFE is not null) then
         BEGIN
            SELECT 1
              INTO dummy_id
              FROM eng_engineering_changes
             WHERE organization_id = c1rec.OI
               AND change_notice = c1rec.PFE;
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'ENG_PARENTECO_NOT_EXIST',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
         END;
        END IF;

/*
** Bill must be mfg or eng
*/
         stmt_num := 4;
         IF (c1rec.AST <> 1) AND (c1rec.AST <> 2) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ASSEMBLY_TYPE_INVALID',
                        err_text => err_text);
            UPDATE bom_bill_of_mtls_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RETURN(ret_code);
            END IF;
            GOTO continue_loop;
         END IF;
/*
** Verify bill seq id is unique
*/
         <<Check_Bill_Seq_Id>>
         stmt_num := 5;
         ret_code := Verify_Bom_Seq_Id_Exists(
                bom_seq_id => c1rec.BSI,
                mode_type => 1,
                err_text => err_text);
         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_DUPLICATE_BILL',
                        err_text => err_text);
            UPDATE bom_bill_of_mtls_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RETURN(ret_code);
            END IF;
            goto continue_loop;
         END IF;

/*
** Check for duplicate assy,org,alt combo
** Check for primary/alternate rule violation
*/
         stmt_num := 6;
         ret_code := Verify_Duplicate_Bom(
                org_id => c1rec.OI,
                assy_id => c1rec.AII,
                alt_desg => c1rec.ABD,
                assy_type => c1rec.AST,
                err_text => err_text);
         IF (ret_code <> 0) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_BILL_VALIDATION_ERR',
                        err_text => err_text);
            UPDATE bom_bill_of_mtls_interface
               SET process_flag = 3
             WHERE transaction_id = c1rec.TI;

            IF (ret_code <> 0) THEN
               RETURN(ret_code);
            END IF;
            GOTO continue_loop;
         END IF;

/*
** Skip logic for Product Family items
*/
         IF (x_bom_item_type = G_ProductFamily) THEN
            GOTO Set_Process_Flag;
         END IF;
/*
** Check assembly type and BOM enabled flag
*/
         stmt_num := 7;
         BEGIN
            SELECT 1
              INTO dummy_id
              FROM mtl_system_items
             WHERE organization_id = c1rec.OI
               AND inventory_item_id = c1rec.AII
               AND bom_enabled_flag = 'Y'
               AND ((c1rec.AST = 2)
                    OR
                    (c1rec.AST = 1 AND
                     eng_item_flag = 'N'));
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
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_ASSY_TYPE_ERR',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
          END;
/*
** Check if common bill seq id exists
*/
         stmt_num := 8;
         IF (c1rec.BSI = c1rec.CBSI) THEN
            null;
         ELSE
            ret_code :=Verify_Bom_Seq_Id_Exists(
                bom_seq_id => c1rec.CBSI,
                mode_type => 2,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COMMON_BILL_NOT_EXIST',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
            END IF;
/*
** Verify common bill attributes
*/
            stmt_num := 9;
            ret_code :=Verify_Common_Bom(
                   bom_id => c1rec.BSI,
                   cmn_bom_id => c1rec.CBSI,
                   bom_type => c1rec.AST,
                   item_id => c1rec.AII,
                   cmn_item_id => c1rec.CAII,
                   org_id => c1rec.OI,
                   cmn_org_id => c1rec.COI,
                   alt_desg => c1rec.ABD,
                   err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c1rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COMMON_BOM_ERROR',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c1rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop;
            END IF;
         END IF;
/*
** Set Process Flag to 4
*/

         <<Set_Process_Flag>>
         stmt_num := 10;
         UPDATE bom_bill_of_mtls_interface
            SET process_flag = 4
          WHERE transaction_id = c1rec.TI;

<<continue_loop>>
         NULL;
      END LOOP;

      stmt_num := 11;
      COMMIT;

      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;
   END LOOP;


/*
** Update "Update" Records and validate "Delete" records
*/
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c2rec IN c2 LOOP
         commit_cnt := commit_cnt + 1;
         x_bom_item_type := null;
/*
** Check if record exists in Production
*/
         stmt_num := 12;
         BEGIN
            SELECT bom.creation_date, bom.created_by,
		   bom.common_assembly_item_id,
                   bom.specific_assembly_comment, bom.pending_from_ecn,
                   bom.attribute_category, bom.attribute1,
                   bom.attribute2, bom.attribute3, bom.attribute4,
		   bom.attribute5,
                   bom.attribute6, bom.attribute7, bom.attribute8,
		   bom.attribute9,
                   bom.attribute10, bom.attribute11, bom.attribute12,
		   bom.attribute13,
                   bom.attribute14, bom.attribute15, bom.request_id,
                   bom.program_application_id, bom.program_id,
		   bom.program_update_date,
                   bom.assembly_type, bom.common_bill_sequence_id,
                   bom.common_organization_id, bom.next_explode_date,
		   msi.bom_item_type
              INTO X_creation_date, X_created_by, X_common_assembly_item_id,
                   X_specific_assembly_comment, X_pending_from_ecn,
                   X_attribute_category, X_attribute1,
                   X_attribute2, X_attribute3, X_attribute4, X_attribute5,
                   X_attribute6, X_attribute7, X_attribute8, X_attribute9,
                   X_attribute10, X_attribute11, X_attribute12, X_attribute13,
                   X_attribute14, X_attribute15, X_request_id,
                   X_program_application_id, X_program_id,
                   X_program_update_date,
                   X_assembly_type, X_common_bill_sequence_id,
                   X_common_organization_id, X_next_explode_date,
		   x_bom_item_type
              FROM bom_bill_of_materials bom,
		   mtl_system_items msi
             WHERE bill_sequence_id = c2rec.BSI
	       AND msi.organization_id = bom.organization_id
	       AND msi.inventory_item_id = bom.assembly_item_id;
         EXCEPTION
            WHEN No_Data_Found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_BILL_RECORD_MISSING',
                        err_text => err_text);

               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c2rec.TI;

               IF (ret_code <> 0) THEN
                   return(ret_code);
               END IF;
               GOTO continue_loop1;
         END;
/*
** ONLY for "Updates"
*/
         IF (c2rec.A = G_Update) THEN
            IF (x_bom_item_type <> G_ProductFamily) THEN
/*
** Check if column is non-updatable
*/
   	       stmt_num := 13;
               IF (c2rec.CD is not null
                   OR c2rec.CB is not null
                   OR c2rec.PFE is not null
                   OR c2rec.AST is not null
                   OR c2rec.NED is not null) THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COLUMN_NOT_UPDATABLE',
                        err_text => err_text);

                  UPDATE bom_bill_of_mtls_interface
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

               stmt_num := 14;
               UPDATE bom_bill_of_mtls_interface
                  SET creation_date = X_creation_date,
                      created_by = X_created_by,
                      assembly_type = X_assembly_type,
                      next_explode_date = X_next_explode_date,
                      common_assembly_item_id = decode(c2rec.CBSI, null,
                         X_common_assembly_item_id, G_NullNum, '',
   	   	         c2rec.CAII),
                      common_bill_sequence_id = decode(c2rec.CBSI, null,
                         X_common_bill_sequence_id, G_NullNum, c2rec.BSI,
                         c2rec.CBSI),
                      common_organization_id = decode(c2rec.CBSI, null,
                         X_common_organization_id, G_NullNum, '', c2rec.COI),
                      specific_assembly_comment = decode(c2rec.SAC, G_NullChar,
		          null, null, X_specific_assembly_comment, c2rec.SAC),
                      pending_from_ecn = X_pending_from_ecn,
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
                                           NULL,X_program_update_date, c2rec.PUD),
                      process_flag = 99
                WHERE transaction_id = c2rec.TI;
            ELSE
/*
** For Product Families
*/
   	       stmt_num := 13;
               IF (c2rec.CD is not null
                   OR c2rec.CB is not null
                   OR c2rec.CAII is not null
                   OR c2rec.CBSI is not null
                   OR c2rec.COI is not null
                   OR c2rec.SAC is not null
                   OR c2rec.PFE is not null
                   OR c2rec.AST is not null
                   OR c2rec.NED is not null) THEN
                  ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c2rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c2rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COLUMN_NOT_UPDATABLE',
                        err_text => err_text);

                  UPDATE bom_bill_of_mtls_interface
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

               stmt_num := 14;
               UPDATE bom_bill_of_mtls_interface
                  SET creation_date = X_creation_date,
                      created_by = X_created_by,
                      assembly_type = X_assembly_type,
                      next_explode_date = X_next_explode_date,
                      common_assembly_item_id = X_common_assembly_item_id,
                      common_bill_sequence_id = X_common_bill_sequence_id,
                      common_organization_id =  X_common_organization_id,
                      specific_assembly_comment = X_specific_assembly_comment,
                      pending_from_ecn = X_pending_from_ecn,
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
                                           NULL,X_program_update_date, c2rec.PUD),
                      process_flag = 4 -- Don't pick up records in cursor c3
                WHERE transaction_id = c2rec.TI;
            END IF;
         ELSIF (c2rec.A =  G_Delete) THEN
/*
** Set Process Flag to 4 for "Deletes"
*/
            stmt_num := 15;
            UPDATE bom_bill_of_mtls_interface
               SET process_flag = 4
             WHERE transaction_id = c2rec.TI;
         END IF;
<<continue_loop1>>
         NULL;
      END LOOP;

      stmt_num := 16;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;
/*
** Validate "Update" Records
*/
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c3rec IN c3 LOOP
         commit_cnt := commit_cnt + 1;
         stmt_num := 17;
/*
** Check if common bill seq id exists
*/
         IF (c3rec.BSI = c3rec.CBSI) THEN
            null;
         ELSIF (c3rec.CBSI = G_NullNum) THEN
            null;
         ELSE
            ret_code :=Verify_Bom_Seq_Id_Exists(
                bom_seq_id => c3rec.CBSI,
                mode_type => 2,
                err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COMMON_BILL_NOT_EXIST',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop2;
            END IF;
/*
** Verify common bill attributes
*/
            stmt_num := 18;
            ret_code :=Verify_Common_Bom(
                   bom_id => c3rec.BSI,
                   cmn_bom_id => c3rec.CBSI,
                   bom_type => c3rec.AST,
                   item_id => c3rec.AII,
                   cmn_item_id => c3rec.CAII,
                   org_id => c3rec.OI,
                   cmn_org_id => c3rec.COI,
                   alt_desg => c3rec.ABD,
                   err_text => err_text);
            IF (ret_code <> 0) THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'BOM_BILL_OF_MTLS_INTERFACE',
                        msg_name => 'BOM_COMMON_BOM_ERROR',
                        err_text => err_text);
               UPDATE bom_bill_of_mtls_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop2;
            END IF;
         END IF;
/*
** Set Process Flag to 4
*/
         stmt_num := 19;
         UPDATE bom_bill_of_mtls_interface
            SET process_flag = 4
          WHERE transaction_id = c3rec.TI;

<<continue_loop2>>
         NULL;
      END LOOP;

      stmt_num := 20;
      COMMIT;

      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;
   END LOOP;

   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Bill_Api(Validate-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Validate_Bill;


/* ----------------------------- Transact_Bill ------------------------------*/
/*
NAME
     Transact_Bill
DESCRIPTION
     Insert, update and delete bill data from the interface
     table, BOM_BILL_OF_MTLS_INTERFACE, into the production table,
     BOM_BILL_OF_MATERIALS.
REQUIRES
     prog_appid              Program application id
     prog_id                 Program id
     req_id                  Request id
     user_id                 User id
     login_id                Login id
MODIFIES
     BOM_BILL_OF_MATERIALS
     BOM_BILL_OF_MTLS_INTERFACE
RETURNS
     0 if successful
     SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Transact_Bill
(       user_id                 NUMBER,
        login_id                NUMBER,
	prog_appid              NUMBER,
 	prog_id                 NUMBER,
        req_id                  NUMBER,
        err_text           OUT   VARCHAR2)
   return integer
IS
   ret_code			NUMBER;
   stmt_num                     NUMBER := 0;
   continue_loop                BOOLEAN := TRUE;
   commit_cnt                   NUMBER;
   X_bill_group_name            VARCHAR2(10);
   X_bill_group_description     VARCHAR2(240);
   X_delete_group_seq_id        NUMBER;
   X_new_group_seq_id           NUMBER;
   X_delete_type		NUMBER;
   X_error_message		VARCHAR2(240);

/*
** Select "Update" bill records
*/
   CURSOR c1 IS
      SELECT bill_sequence_id BSI, common_assembly_item_id CAII,
             specific_assembly_comment SAC, common_bill_sequence_id CBSI,
             common_organization_id COI,
             last_update_date LUD, last_updated_by LUB,
             last_update_login LUL,
             attribute_category AC, attribute1 A1, attribute2 A2,
             attribute3 A3, attribute4 A4, attribute5 A5, attribute6 A6,
             attribute7 A7, attribute8 A8, attribute9 A9, attribute10 A10,
             attribute11 A11, attribute12 A12, attribute13 A13,
             attribute14 A14, attribute15 A15, request_id RI,
             program_application_id PAI, program_id PI,
             program_update_date PUD, transaction_id TI
        FROM bom_bill_of_mtls_interface
       WHERE process_flag = 4
         AND transaction_type = G_Update
         AND rownum < G_rows_to_commit;
/*
** Select "Delete" bill records
*/
   CURSOR c2 IS
      SELECT bill_sequence_id BSI, assembly_type AST, organization_id OI,
             assembly_item_id AII, alternate_bom_designator ABD,
             transaction_id TI
        FROM bom_bill_of_mtls_interface
       WHERE process_flag = 4
         AND transaction_type = G_Delete
         AND rownum < G_rows_to_commit;
BEGIN
/*
** Insert bills
*/
   stmt_num := 1;
   LOOP
      INSERT INTO bom_bill_of_materials(
                        assembly_item_id,
                        organization_id,
                        alternate_bom_designator,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        common_assembly_item_id,
                        specific_assembly_comment,
                        attribute_category,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        assembly_type,
                        common_bill_sequence_id,
                        bill_sequence_id,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        common_organization_id,
                        next_explode_date
                        )
                SELECT
                        assembly_item_id,
                        organization_id,
                        alternate_bom_designator,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        common_assembly_item_id,
                        specific_assembly_comment,
                        attribute_category,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        assembly_type,
                        common_bill_sequence_id,
                        bill_sequence_id,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        common_organization_id,
                        next_explode_date
                FROM  bom_bill_of_mtls_interface
               WHERE  process_flag = 4
                 AND  transaction_type = G_Insert
                 AND  rownum < 500;

      EXIT when SQL%NOTFOUND;

      stmt_num := 2;
      UPDATE bom_bill_of_mtls_interface bi
         SET process_flag = 7
       WHERE process_flag = 4
         AND transaction_type = G_Insert
         AND exists (SELECT null
                       FROM bom_bill_of_materials bom
                      WHERE bom.bill_sequence_id = bi.bill_sequence_id);
      stmt_num := 3;
      COMMIT;

   END LOOP;
/*
** Update Bills
*/
   stmt_num := 4;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c1rec IN c1 LOOP
         commit_cnt := commit_cnt + 1;
         UPDATE bom_bill_of_materials
            SET last_update_date    = c1rec.LUD,
                last_updated_by     = c1rec.LUB,
                last_update_login   = c1rec.LUL,
                common_assembly_item_id = c1rec.CAII,
                specific_assembly_comment = c1rec.SAC,
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
                program_update_date = c1rec.PUD,
                common_bill_sequence_id = c1rec.CBSI,
                common_organization_id = c1rec.COI
          WHERE bill_sequence_id = c1rec.BSI;

         stmt_num := 5;
         UPDATE bom_bill_of_mtls_interface
            SET process_flag = 7
          WHERE transaction_id = c1rec.TI;
      END LOOP;

      stmt_num := 6;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;
/*
** Delete Bills
*/
   stmt_num := 7;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c2rec IN c2 LOOP
         commit_cnt := commit_cnt + 1;
/*
** Get the Bill Delete Group name
*/
         IF (X_bill_group_name is null) THEN
	    stmt_num := 8;
            DECLARE
               CURSOR GetBillGroup IS
                  SELECT delete_group_name, description
                    FROM bom_interface_delete_groups
                   WHERE UPPER(entity_name) = G_DeleteEntity;
            BEGIN
               FOR X_billgroup IN GetBillGroup LOOP
                  X_bill_group_name := X_billgroup.delete_group_name;
                  X_bill_group_description := X_billgroup.description;
               END LOOP;

               IF (X_bill_group_name is null) THEN
                  X_error_message := FND_MESSAGE.Get_String('BOM',
			 	     'BOM_BILL_DELETE_GROUP_MISSING');
                  err_text := 'Bom_Bill_Api:'||to_char(stmt_num)||'-'||
                                        X_error_message;
                  RETURN(-9999);
               END IF;
            END;
         END IF;

         stmt_num := 9;
	 BEGIN
            SELECT delete_group_sequence_id, delete_type
              INTO X_delete_group_seq_id, X_delete_type
              FROM bom_delete_groups
             WHERE delete_group_name = X_bill_group_name
               AND organization_id = c2rec.OI;

/*  if delete group if of type routings.  make it
 *  of type bill, routings
*/
            if X_delete_type = 3 then
               update bom_delete_groups
               set delete_type = 6
               WHERE delete_group_name = X_bill_group_name
               AND organization_id = c2rec.OI;

               COMMIT;
               X_delete_type := 6;
            end if;

            IF (X_delete_type not in (2,6)) THEN
               X_error_message := FND_MESSAGE.Get_String('BOM',
			 	     'BOM_DELETE_GROUP_INVALID');
               err_text := 'Bom_Bill_Api('||to_char(stmt_num)||') - '||
                         X_error_message;
               RETURN(-9999);
            END IF;
         EXCEPTION
               WHEN no_data_found THEN
                  null;
         END;

	 stmt_num := 10;
         ret_code := Modal_Delete.Delete_Manager_Oi(
            new_group_seq_id => X_delete_group_seq_id,
            name => X_bill_group_name,
            group_desc => X_bill_group_description,
            org_id => c2rec.OI,
            bom_or_eng => c2rec.AST,
            del_type => 2,
            ent_bill_seq_id => c2rec.BSI,
            ent_rtg_seq_id => null,
            ent_inv_item_id => c2rec.AII,
            ent_alt_designator => c2rec.ABD,
            ent_comp_seq_id => null,
            ent_op_seq_id => null,
            user_id => user_id,
	    err_text => err_text);

         IF (ret_code <> 0) THEN
	    RETURN(ret_code);
         END IF;

         stmt_num := 11;
         UPDATE bom_bill_of_mtls_interface
            SET process_flag = 7
          WHERE transaction_id = c2rec.TI;

      END LOOP;

      stmt_num := 12;
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
      err_text := 'Bom_Bill_Api(Transact-'||stmt_num||') '||substrb(SQLERRM,1,500);
      return(SQLCODE);

END Transact_Bill;

/* -------------------------------- Import_Bill ---------------------------- */
/*
NAME
    Import_Bill
DESCRIPTION
    Assign, Validate, and Transact the Bill of Material record in the
    interface table, BOM_BILL_OF_MTLS_INTERFACE.
REQUIRES
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Import_Bill (
    org_id              NUMBER,
    all_org             NUMBER := 1,
    user_id             NUMBER := -1,
    login_id            NUMBER := -1,
    prog_appid          NUMBER := -1,
    prog_id             NUMBER := -1,
    req_id              NUMBER := -1,
    del_rec_flag	NUMBER := 1,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
   err_msg	VARCHAR2(2000);
   ret_code     NUMBER := 1;
   stmt_num	NUMBER := 0;
BEGIN
   stmt_num := 1;
   ret_code := Assign_Bill (
      org_id => org_id,
      all_org => all_org,
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);
   IF (ret_code <> 0) THEN
      err_text := 'Assign_Bill '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 2;
   ret_code := Validate_Bill (
      org_id => org_id,
      all_org => all_org,
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);
   IF (ret_code <> 0) THEN
      err_text := 'Validate_Bill '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 3;
   ret_code := Transact_Bill (
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);

   IF (ret_code <> 0) THEN
      err_text := 'Transact_Bill '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 4;
   IF (del_rec_flag = 1) THEN
      LOOP
         DELETE from bom_bill_of_mtls_interface
          WHERE process_flag = 7
            AND rownum < G_rows_to_commit;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;
   END IF;

   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'Bom_Bill_Api(Import-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(ret_code);
END Import_Bill;


END Bom_Bill_Api;

/
