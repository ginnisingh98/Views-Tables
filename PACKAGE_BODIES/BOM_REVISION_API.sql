--------------------------------------------------------
--  DDL for Package Body BOM_REVISION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_REVISION_API" AS
/* $Header: BOMOIRVB.pls 115.5 2002/06/14 12:33:30 pkm ship      $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMOIRVB.pls                                               |
| DESCRIPTION  : This package contains functions used to assign, validate   |
|                and transact Item Revision data in the                     |
|		 MTL_ITEM_REVISIONS_INTERFACE table.			    |
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

/* -------------------------- Assign_Item_Revision --------------------------*/
/*
NAME
    Assign_Item_Revision
DESCRIPTION
    Assign defaults and ID's to item revision record in the interface table
REQUIRES
    err_text    out buffer to return error message
MODIFIES
    MTL_ITEM_REVISIONS_INTERFACE
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Assign_Item_Revision (
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
    stmt_num    NUMBER := 0;
    ret_code    NUMBER;
    commit_cnt  NUMBER;
    continue_loop BOOLEAN := TRUE;

    CURSOR c1 IS
        SELECT organization_code OC, organization_id OI,
               revision R, inventory_item_id III, item_number IIN,
               transaction_id TI, implementation_date ID, effectivity_date ED,
               transaction_type A
          FROM mtl_item_revisions_interface
         WHERE process_flag = 1
           and transaction_type in (G_Insert, G_Update)
           and (all_org = 1
                OR
                (all_org = 2 and organization_id = org_id))
           and rownum < G_rows_to_commit;

BEGIN
/** G_INSERT is 'CREATE'. Update 'INSERT' to 'CREATE' **/
   stmt_num := 0.5 ;
   LOOP
      UPDATE mtl_item_revisions_interface
         SET transaction_type = G_Insert
       WHERE process_flag = 1
         AND upper(transaction_type) = 'INSERT'
         AND rownum < G_rows_to_commit;
      EXIT when SQL%NOTFOUND;
      COMMIT;
   END LOOP;

/*
** ALL INSERTS and UPDATES - Assign Org Id
*/
   stmt_num := 1;
   LOOP
      UPDATE mtl_item_revisions_interface ori
         SET organization_id = (SELECT organization_id
                                  FROM mtl_parameters a
                             WHERE a.organization_code = ori.organization_code)
       WHERE process_flag = 1
         AND upper(transaction_type) in (G_Insert, G_Update)
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
** FOR INSERTS and UPDATES - Assign transaction ids
*/
    stmt_num := 2;
    LOOP
       UPDATE mtl_item_revisions_interface
          SET transaction_id = mtl_system_items_interface_s.nextval,
              transaction_type = upper(transaction_type)
        WHERE transaction_id is null
          and process_flag = 1
          and upper(transaction_type) in (G_Insert, G_Update)
          and rownum < G_rows_to_commit;
       EXIT when SQL%NOTFOUND;
       COMMIT;
    END LOOP;
/*
** FOR INSERTS and UPDATES - Check if ORGANIZATION_ID is null
*/
    WHILE continue_loop LOOP
       commit_cnt := 0;
       FOR c1rec IN c1 LOOP
          commit_cnt := commit_cnt + 1;
          stmt_num := 3;
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
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_ORG_ID_MISSING',
                        err_text => err_text);
             UPDATE mtl_item_revisions_interface
                SET process_flag = 3
              WHERE transaction_id = c1rec.TI;

             GOTO continue_loop;
          END IF;
/*
** Check if INVENTORY_ITEM_ID is null
*/
          stmt_num := 4;
          IF (c1rec.III is null) THEN
             ret_code := INVPUOPI.mtl_pr_parse_flex_name(
                org_id => c1rec.OI,
                flex_code => 'MSTK',
                flex_name => c1rec.IIN,
                flex_id => c1rec.III,
                set_id => -1,
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
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_INV_ITEM_ID_MISSING',
                        err_text => err_text);
                UPDATE mtl_item_revisions_interface
                   SET process_flag = 3
                 WHERE transaction_id = c1rec.TI;

                IF (ret_code <> 0) THEN
                   RETURN(ret_code);
                END IF;
                GOTO continue_loop;
             END IF;
          END IF;
/*
** Assign values to interface record
*/
          IF (c1rec.A = G_Insert) THEN
             /* For Inserts */
             stmt_num := 5;
             UPDATE mtl_item_revisions_interface
                SET organization_id = nvl(organization_id, c1rec.OI),
                    inventory_item_id = nvl(inventory_item_id, c1rec.III),
                    revision = UPPER(c1rec.R),
                    process_flag = 2,
                    last_update_date = nvl(last_update_date, sysdate),
                    last_updated_by = nvl(last_updated_by, user_id),
                    creation_date = nvl(creation_date, sysdate),
                    created_by = nvl(created_by, user_id),
                    last_update_login = nvl(last_update_login, user_id),
                    request_id = nvl(request_id, req_id),
                    program_application_id = nvl(program_application_id,
			prog_appid),
                    program_id = nvl(program_id, prog_id),
                    program_update_date = nvl(program_update_date, sysdate),
                    effectivity_date = nvl(effectivity_date, sysdate),
                    implementation_date = nvl(effectivity_date, sysdate)
              WHERE transaction_id = c1rec.TI;

             IF (SQL%NOTFOUND) THEN
                err_text := 'BOM_REVISION_API(' || stmt_num || ')' ||
                            substrb(SQLERRM, 1, 60);
                RETURN(SQLCODE);
             END IF;
          ELSE
             /* For Updates */
             stmt_num := 6;
             UPDATE mtl_item_revisions_interface
                SET organization_id = nvl(organization_id, c1rec.OI),
                    inventory_item_id = nvl(inventory_item_id, c1rec.III),
                    revision = UPPER(c1rec.R),
                    process_flag = 2,
                    last_update_date = nvl(last_update_date, sysdate),
                    last_updated_by = nvl(last_updated_by, user_id),
                    last_update_login = nvl(last_update_login, user_id),
                    implementation_date = nvl(effectivity_date, NULL)
              WHERE transaction_id = c1rec.TI;

             IF (SQL%NOTFOUND) THEN
                err_text := 'BOM_REVISION_API(' || stmt_num || ')' ||
                            substrb(SQLERRM, 1, 60);
                RETURN(SQLCODE);
             END IF;
          END IF;

<<continue_loop>>
          NULL;
       END LOOP;

       stmt_num := 7;
       COMMIT;

       IF (commit_cnt < (G_rows_to_commit - 1)) THEN
          continue_loop := FALSE;
       END IF;
   END LOOP;

   RETURN (0);
EXCEPTION
   WHEN others THEN
      err_text := 'BOM_REVISION_API(Assign-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Assign_Item_Revision;


/* -------------------------- Check_Revision_Order ------------------------- */
/*
NAME
   Check_Revision_Order
DESCRIPTION
   Ensure revs in ascending order
   Ensure no duplicate revs
REQUIRES
    org_id              NUMBER
    assy_id             NUMBER
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Check_Revision_Order (
    org_id              NUMBER,
    assy_id             NUMBER,
    user_id             NUMBER,
    login_id            NUMBER,
    prog_appid          NUMBER,
    prog_id             NUMBER,
    req_id              NUMBER,
    err_text    IN OUT  VARCHAR2
)
    return INTEGER
IS
   CURSOR c1 is
       SELECT revision R, effectivity_date ED,
              transaction_id TI, transaction_type TT
         FROM mtl_item_revisions_interface
        WHERE organization_id = org_id
          and inventory_item_id = assy_id
          and transaction_type in (G_Insert, G_Update)
          and process_flag = 99;
   ret_code            NUMBER;
   err_cnt             NUMBER;
   err_flag            NUMBER;
   stmt_num            NUMBER := 0;

BEGIN
   FOR c1rec IN c1 LOOP
      err_cnt := 0;
      stmt_num := 1;
/*
** FOR INSERTS and UPDATES - Check for ascending order and identical revs
*/
      SELECT count(*)
        INTO err_cnt
        FROM mtl_item_revisions_interface a
       WHERE transaction_id <> c1rec.TI
         and inventory_item_id = assy_id
         and organization_id = org_id
         and process_flag = 4
         and ( (revision = c1rec.R)
              OR
               (effectivity_date > c1rec.ED
                 and revision < c1rec.R)
              OR
               (effectivity_date < c1rec.ED
                 and revision > c1rec.R));

      IF (err_cnt <> 0) THEN
         GOTO write_error;
      END IF;

/*
** FOR INSERTS - Check production table
*/
      stmt_num := 2;
      IF (c1rec.TT = G_Insert) THEN
         SELECT count(*)
           INTO err_cnt
           FROM mtl_item_revisions mir
          WHERE inventory_item_id = assy_id
            and organization_id = org_id
            and NOT EXISTS (select 'x'
                   from mtl_item_revisions_interface miri
                  where miri.inventory_item_id = mir.inventory_item_id
                    and miri.organization_id = mir.organization_id
                    and miri.revision = mir.revision
                    and miri.process_flag = 4)
            and ((revision = c1rec.R)
                 OR
                  (effectivity_date > c1rec.ED
                   AND revision < c1rec.R)
                 OR
                  (effectivity_date < c1rec.ED
                   AND revision > c1rec.R));

         IF (err_cnt <> 0) THEN
            GOTO write_error;
         END IF;
      ELSE
/*
** FOR UPDATES - Check production table
*/
         stmt_num := 3;
         SELECT count(*)
           INTO err_cnt
           FROM mtl_item_revisions mir
          WHERE inventory_item_id = assy_id
            and organization_id = org_id
            and revision <> c1rec.R
            and NOT EXISTS (select 'x'
                   from mtl_item_revisions_interface miri
                  where miri.inventory_item_id = mir.inventory_item_id
                    and miri.organization_id = mir.organization_id
                    and miri.revision = mir.revision
                    and miri.process_flag = 4)
            and ((effectivity_date > c1rec.ED
                   AND revision < c1rec.R)
                 OR
                  (effectivity_date < c1rec.ED
                   AND revision > c1rec.R));

         IF (err_cnt <> 0) THEN
            GOTO write_error;
         END IF;
      END IF;

      stmt_num := 4;
      UPDATE mtl_item_revisions_interface
         SET process_flag = 4
       WHERE transaction_id = c1rec.TI;
      GOTO continue_loop;

<<write_error>>
      ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => org_id,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c1rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_REV_INVALID',
                        err_text => err_text);
      UPDATE mtl_item_revisions_interface
         SET process_flag = 3
       WHERE transaction_id = c1rec.TI;
<<continue_loop>>
      null;
   END LOOP;
   return(0);
EXCEPTION
   WHEN others THEN
      err_text := 'BOM_REVISION_API(Check-'||stmt_num||') '||substrb(SQLERRM,1,60);
      return(SQLCODE);
END Check_Revision_Order;


/* ------------------------- Validate_Item_Revision ------------------------ */
/*
NAME
    Validate_Item_Revision
DESCRIPTION
REQUIRES
    org_id      org id to validate
    all_org     all_org flag
    user_id     user id
    login_id    login id
    prog_appid  program application id
    prod_id     program id
    req_id      request id
    err_text    out buffer to return error message
MODIFIES
    MTL_INTERFACE_ERRORS
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Validate_Item_Revision (
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
    ret_code                    NUMBER;
    dummy                       NUMBER;
    dummy_id                    NUMBER;
    stmt_num                    NUMBER := 0;
    commit_cnt                  NUMBER;
    dummy_bill                  NUMBER;
    continue_loop1              BOOLEAN := TRUE;
    continue_loop2              BOOLEAN := TRUE;
    X_creation_date             DATE;
    X_created_by                NUMBER;
    X_change_notice             VARCHAR2(10);
    X_ecn_initiation_date       DATE;
    X_implementation_date       DATE;
    X_effectivity_date          DATE;
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
    X_revised_item_sequence_id  NUMBER;
    X_description               VARCHAR2(240);
/*
** All "Insert" records
*/
    CURSOR c0 IS
        select inventory_item_id AII, organization_id OI,
               revision R, transaction_id TI,
               change_notice CN
          from mtl_item_revisions_interface
         where process_flag = 2
           and transaction_type = G_Insert
           and rownum < G_rows_to_commit;
/*
** All "Insert" and "Update" records grouped by Item
*/
    CURSOR c1 IS
        select inventory_item_id AII, organization_id OI
          from mtl_item_revisions_interface
         where process_flag = 99
           and transaction_type in (G_Insert, G_Update)
      group by organization_id, inventory_item_id;

/*
** All "Update" records
*/
    CURSOR c3 IS
        select inventory_item_id III, organization_id OI,
               revision R, transaction_id TI,
               creation_date CD, created_by CB, change_notice CN,
               ecn_initiation_date EID, implementation_date ID,
               effectivity_date ED, revised_item_sequence_id RISI,
               attribute_category AC, attribute1 A1, attribute2 A2,
               attribute3 A3, attribute4 A4, attribute5 A5, attribute6 A6,
               attribute7 A7, attribute8 A8, attribute9 A9, attribute10 A10,
               attribute11 A11, attribute12 A12, attribute13 A13,
               attribute14 A14, attribute15 A15, request_id RI,
               program_application_id PAI, program_id PI,
               program_update_date PUD, description D
          from mtl_item_revisions_interface
         where process_flag = 2
           and transaction_type = G_Update
           and rownum < G_rows_to_commit;

BEGIN
/*
** FOR UPDATES - Validate
*/

   stmt_num := 1;
   WHILE continue_loop1 LOOP
      commit_cnt := 0;
      FOR c3rec IN c3 LOOP
         commit_cnt := commit_cnt + 1;
/*
** Check if implemented "update" record exists in Production
*/
         stmt_num := 2;
         BEGIN
            SELECT creation_date, created_by, change_notice,
                   ecn_initiation_date, implementation_date,
                   effectivity_date, attribute_category, attribute1,
                   attribute2, attribute3, attribute4, attribute5,
                   attribute6, attribute7, attribute8, attribute9,
                   attribute10, attribute11, attribute12, attribute13,
                   attribute14, attribute15, request_id,
                   program_application_id, program_id, program_update_date,
                   revised_item_sequence_id, description
              INTO X_creation_date, X_created_by, X_change_notice,
                   X_ecn_initiation_date, X_implementation_date,
                   X_effectivity_date, X_attribute_category, X_attribute1,
                   X_attribute2, X_attribute3, X_attribute4, X_attribute5,
                   X_attribute6, X_attribute7, X_attribute8, X_attribute9,
                   X_attribute10, X_attribute11, X_attribute12, X_attribute13,
                   X_attribute14, X_attribute15, X_request_id,
                   X_program_application_id, X_program_id,
                   X_program_update_date, X_revised_item_sequence_id,
                   X_description
              FROM mtl_item_revisions
             WHERE organization_id = c3rec.OI
               and inventory_item_id = c3rec.III
               and revision = c3rec.R
               and implementation_date is NOT NULL;
         EXCEPTION
            WHEN No_Data_Found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_REV_RECORD_MISSING',
                        err_text => err_text);

               UPDATE mtl_item_revisions_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

               IF (ret_code <> 0) THEN
                   return(ret_code);
               END IF;
               GOTO continue_loop1;
         END;
/*
** Check if column is non-updatable and give warning if user filled it in
*/
         IF (c3rec.CD is not null
             OR c3rec.CB is not null
             OR c3rec.CN is not null
             OR c3rec.EID is not null
             OR c3rec.RISI is not null) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c3rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c3rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_COLUMN_NOT_UPDATABLE',
                        err_text => err_text);

               UPDATE mtl_item_revisions_interface
                  SET process_flag = 3
                WHERE transaction_id = c3rec.TI;

            IF (ret_code <> 0) THEN
                return(ret_code);
            END IF;
            GOTO continue_loop1;
         END IF;
/*
** Update interface record with production record's values
*/

         stmt_num := 3;
         UPDATE mtl_item_revisions_interface
            SET creation_date = X_creation_date,
                created_by = X_created_by,
                change_notice = X_change_notice,
                ecn_initiation_date = X_ecn_initiation_date,
                revised_item_sequence_id = X_revised_item_sequence_id,
                process_flag = 99,
                effectivity_date = nvl(c3rec.ED, X_effectivity_date),
                implementation_date = nvl(c3rec.ID, X_implementation_date),
                attribute_category = decode(c3rec.AC, G_NullChar, '', NULL,
                                     X_attribute_category, c3rec.AC),
                attribute1 = decode(c3rec.A1, G_NullChar, '', NULL,
                                     X_attribute1, c3rec.A1),
                attribute2 = decode(c3rec.A2, G_NullChar, '', NULL,
                                     X_attribute2, c3rec.A2),
                attribute3 = decode(c3rec.A3, G_NullChar, '', NULL,
                                     X_attribute3, c3rec.A3),
                attribute4 = decode(c3rec.A4, G_NullChar, '', NULL,
                                     X_attribute4, c3rec.A4),
                attribute5 = decode(c3rec.A5, G_NullChar, '', NULL,
                                     X_attribute5, c3rec.A5),
                attribute6 = decode(c3rec.A6, G_NullChar, '', NULL,
                                     X_attribute6, c3rec.A6),
                attribute7 = decode(c3rec.A7, G_NullChar, '', NULL,
                                     X_attribute7, c3rec.A7),
                attribute8 = decode(c3rec.A8, G_NullChar, '', NULL,
                                     X_attribute8, c3rec.A8),
                attribute9 = decode(c3rec.A9, G_NullChar, '', NULL,
                                     X_attribute9, c3rec.A9),
                attribute10 = decode(c3rec.A10, G_NullChar, '', NULL,
                                     X_attribute10, c3rec.A10),
                attribute11 = decode(c3rec.A11, G_NullChar, '', NULL,
                                     X_attribute11, c3rec.A11),
                attribute12 = decode(c3rec.A12, G_NullChar, '', NULL,
                                     X_attribute12, c3rec.A12),
                attribute13 = decode(c3rec.A13, G_NullChar, '', NULL,
                                     X_attribute13, c3rec.A13),
                attribute14 = decode(c3rec.A14, G_NullChar, '', NULL,
                                     X_attribute14, c3rec.A14),
                attribute15 = decode(c3rec.A15, G_NullChar, '', NULL,
                                     X_attribute15, c3rec.A15),
                request_id = decode(c3rec.RI, G_NullChar, '', NULL,
                                     X_request_id, c3rec.RI),
                program_application_id = decode(c3rec.PAI, G_NullNum, '',
				     NULL,
                                     X_program_application_id, c3rec.PAI),
                program_id = decode(c3rec.PI, G_NullNum, '', NULL,
                                     X_program_id, c3rec.PI),
                program_update_date = decode(c3rec.PUD, G_NullDate, '', NULL,
                                     X_program_update_date, c3rec.PUD),
                description = decode(c3rec.D, G_NullChar, '', NULL,
                                     X_description, c3rec.D)
          WHERE transaction_id = c3rec.TI;

<<continue_loop1>>
         NULL;
      END LOOP;

      stmt_num := 4;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop1 := FALSE;
      END IF;

   END LOOP;


/*
** FOR INSERTS - Validate
*/
   stmt_num := 5;
   WHILE continue_loop2 LOOP
      commit_cnt := 0;
      FOR c0rec IN c0 LOOP
         commit_cnt := commit_cnt + 1;

/*
** Check if revision is null
*/
         IF (c0rec.R is null) THEN
            ret_code := INVPUOPI.mtl_log_interface_err(
               org_id => org_id,
               user_id => user_id,
               login_id => login_id,
               prog_appid => prog_appid,
               prog_id => prog_id,
               req_id => req_id,
               trans_id => c0rec.TI,
               error_text => err_text,
               tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
               msg_name => 'BOM_NULL_REV',
               err_text => err_text);

            UPDATE mtl_item_revisions_interface
               SET process_flag = 3
             WHERE transaction_id = c0rec.TI;

            IF (ret_code <> 0) THEN
               return(ret_code);
            END IF;
            GOTO continue_loop2;
         END IF;

/*
** Verify org id
*/
         stmt_num := 6;
         BEGIN
            SELECT organization_id
              INTO dummy_id
              FROM mtl_parameters
             WHERE organization_id = c0rec.OI;
         EXCEPTION
            WHEN No_Data_Found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c0rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c0rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_INVALID_ORG_ID',
                        err_text => err_text);

               UPDATE mtl_item_revisions_interface
                  SET process_flag = 3
                WHERE transaction_id = c0rec.TI;

               IF (ret_code <> 0) THEN
                   return(ret_code);
               END IF;
               GOTO continue_loop2;
         END;

/*
** Check if assembly item exists
*/
         stmt_num := 7;
         BEGIN
            select 1
              into dummy
              from mtl_system_items
             where organization_id = c0rec.OI
               and inventory_item_id = c0rec.AII;
         EXCEPTION
            WHEN No_Data_Found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c0rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c0rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'BOM_INV_ITEM_INVALID',
                        err_text => err_text);
               UPDATE mtl_item_revisions_interface
                  SET process_flag = 3
                WHERE transaction_id = c0rec.TI;

               IF (ret_code <> 0) THEN
                  return(ret_code);
               END IF;
               GOTO continue_loop2;
         END;


/*
** Verfify Change_Notice
*/
	 stmt_num := 7.5;

         If (c0rec.CN is not NULL) THEN
         BEGIN
            SELECT 1
              INTO dummy
              FROM eng_engineering_changes
             WHERE organization_id = c0rec.OI
               AND change_notice = c0rec.CN;
         EXCEPTION
          WHEN no_data_found THEN
               ret_code := INVPUOPI.mtl_log_interface_err(
                        org_id => c0rec.OI,
                        user_id => user_id,
                        login_id => login_id,
                        prog_appid => prog_appid,
                        prog_id => prog_id,
                        req_id => req_id,
                        trans_id => c0rec.TI,
                        error_text => err_text,
                        tbl_name => 'MTL_ITEM_REVISIONS_INTERFACE',
                        msg_name => 'ENG_PARENTECO_NOT_EXIST',
                        err_text => err_text);
               UPDATE mtl_item_revisions_interface
                  SET process_flag = 3
                WHERE transaction_id = c0rec.TI;

               IF (ret_code <> 0) THEN
                  RETURN(ret_code);
               END IF;
               GOTO continue_loop2;
      	  END;
	END IF;

         stmt_num := 8;
         UPDATE mtl_item_revisions_interface
            SET process_flag = 99
          WHERE transaction_id = c0rec.TI;

<<continue_loop2>>
         NULL;
      END LOOP;

      stmt_num := 9;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop2 := FALSE;
      END IF;

   END LOOP; -- End c0 cursor

/*
** For each Item verify revisions are in correct order
*/
   commit_cnt := 0;

   FOR c1rec IN c1 LOOP
      commit_cnt := commit_cnt + 1;
      stmt_num := 11;
      ret_code := Check_Revision_Order (
                org_id => c1rec.OI,
                assy_id => c1rec.AII,
                user_id => user_id,
                login_id => login_id,
                prog_appid => prog_appid,
                prog_id => prog_id,
                req_id => req_id,
                err_text => err_text);
      IF (ret_code <> 0) THEN
         return(ret_code);
      END IF;

      IF (commit_cnt = G_rows_to_commit) THEN
         COMMIT;
         commit_cnt := 0;
      END IF;
   END LOOP;

   COMMIT;

   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'BOM_REVISION_API(Validate-'||stmt_num||') '||substrb(SQLERRM,1,500);
      RETURN(SQLCODE);
END Validate_Item_Revision;


/* ------------------------- Transact_Item_Revision -------------------------*/
/*
NAME
     Transact_Item_Revision
DESCRIPTION
     Insert and update item revision data from the interface
     table, MTL_ITEM_REVISIONS_INTERFACE, into the production table,
     MTL_ITEM_REVISIONS.
REQUIRES
     prog_appid              Program application id
     prog_id                 Program id
     req_id                  Request id
     user_id                 User id
     login_id                Login id
MODIFIES
     MTL_ITEM_REVISIONS_INTERFACE
     MTL_ITEM_REVISIONS
RETURNS
     0 if successful
     SQLCODE if error
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Transact_Item_Revision
(       user_id                 NUMBER,
        login_id                NUMBER,
	prog_appid              NUMBER,
 	prog_id                 NUMBER,
        req_id                  NUMBER,
        err_text           OUT   VARCHAR2)
   return integer
IS
   stmt_num                     NUMBER := 0;
   continue_loop                BOOLEAN := TRUE;
   commit_cnt                   NUMBER;
/*
** Select "Update" item revision records
*/
   CURSOR c1 IS
      SELECT inventory_item_id III, organization_id OI,
             revision R, last_update_date LUD, last_updated_by LUB,
             last_update_login LUL, implementation_date ID,
             effectivity_date ED,
             attribute_category AC, attribute1 A1, attribute2 A2,
             attribute3 A3, attribute4 A4, attribute5 A5, attribute6 A6,
             attribute7 A7, attribute8 A8, attribute9 A9, attribute10 A10,
             attribute11 A11, attribute12 A12, attribute13 A13,
             attribute14 A14, attribute15 A15, request_id RI,
             program_application_id PAI, program_id PI,
             program_update_date PUD, description D,  transaction_id TI
        FROM mtl_item_revisions_interface
       WHERE process_flag = 4
         AND transaction_type = G_Update
         AND rownum < G_rows_to_commit;
BEGIN
/*
** Insert Item Revisions
*/
   stmt_num := 1;
   LOOP
      INSERT INTO mtl_item_revisions
                        (
                        INVENTORY_ITEM_ID,
                        ORGANIZATION_ID,
                        REVISION,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
			CHANGE_NOTICE,
                        IMPLEMENTATION_DATE,
                        EFFECTIVITY_DATE,
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
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        REQUEST_ID,
                        DESCRIPTION)
                 SELECT
                        INVENTORY_ITEM_ID,
                        ORGANIZATION_ID,
                        REVISION,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
			CHANGE_NOTICE,
                        IMPLEMENTATION_DATE,
                        EFFECTIVITY_DATE,
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
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        REQUEST_ID,
                        DESCRIPTION
                   FROM mtl_item_revisions_interface
                  WHERE process_flag = 4
                    and transaction_type = G_Insert
                    and rownum < 500;

      EXIT when SQL%NOTFOUND;

      stmt_num := 2;
      UPDATE mtl_item_revisions_interface mri
         SET process_flag = 7
       WHERE process_flag = 4
         and transaction_type = G_Insert
         and EXISTS (SELECT NULL
                       FROM mtl_item_revisions mir
                      WHERE mir.inventory_item_id = mri.inventory_item_id
                        AND mir.organization_id = mri.organization_id
                        AND mir.revision = mri.revision);
      stmt_num := 3;
      COMMIT;
   END LOOP;

/*
** Update Item Revisions
*/
   stmt_num := 4;
   continue_loop := TRUE;
   WHILE continue_loop LOOP
      commit_cnt := 0;
      FOR c1rec IN c1 LOOP
         commit_cnt := commit_cnt + 1;
         UPDATE mtl_item_revisions
            SET last_update_date    = c1rec.LUD,
                last_updated_by     = c1rec.LUB,
                last_update_login   = c1rec.LUL,
                implementation_date = c1rec.ID,
                effectivity_date    = c1rec.ED,
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
                description         = c1rec.D
          WHERE inventory_item_id = c1rec.III
            AND organization_id   = c1rec.OI
            AND revision          = c1rec.R;

         stmt_num := 5;
         UPDATE mtl_item_revisions_interface mri
            SET process_flag = 7
          WHERE transaction_id = c1rec.TI;
      END LOOP;

      stmt_num := 6;
      COMMIT;
      IF (commit_cnt < (G_rows_to_commit - 1)) THEN
         continue_loop := FALSE;
      END IF;

   END LOOP;

   RETURN(0);

EXCEPTION
   WHEN no_data_found THEN
      RETURN(0);
   WHEN others THEN
      ROLLBACK;
      err_text := 'BOM_REVISION_API(Transact-'||stmt_num||') '||substrb(SQLERRM,1,500);
      return(SQLCODE);

END Transact_Item_Revision;

/* --------------------------- Import_Item_Revision ----------------------- */
/*
NAME
    Import_Item_Revision
DESCRIPTION
    Assign, Validate, and Transact the Item Revision record in the
    interface table, MTL_ITEM_REVISIONS_INTERFACE.
REQUIRES
    err_text    out buffer to return error message
MODIFIES
RETURNS
    0 if successful
    SQLCODE if unsuccessful
NOTES
-----------------------------------------------------------------------------*/
FUNCTION Import_Item_Revision (
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
   ret_code := Assign_Item_Revision (
      org_id => org_id,
      all_org => all_org,
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);
   IF (ret_code <> 0) THEN
      err_text := 'Assign_Item_Revision '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 2;
   ret_code := Validate_Item_Revision (
      org_id => org_id,
      all_org => all_org,
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);
   IF (ret_code <> 0) THEN
      err_text := 'Validate_Item_Revision '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 3;
   ret_code := Transact_Item_Revision (
      user_id => user_id,
      login_id => login_id,
      prog_appid => prog_appid,
      prog_id => prog_id,
      req_id => req_id,
      err_text => err_msg);

   IF (ret_code <> 0) THEN
      err_text := 'Transact_Item_Revision '||substrb(err_msg, 1,1500);
      ROLLBACK;
      RETURN(ret_code);
   END IF;
   COMMIT;

   stmt_num := 4;
   IF (del_rec_flag = 1) THEN
      LOOP
         DELETE from mtl_item_revisions_interface
          WHERE process_flag = 7
            AND rownum < G_rows_to_commit;

         EXIT when SQL%NOTFOUND;
         COMMIT;
      END LOOP;
   END IF;

   RETURN(0);

EXCEPTION
   WHEN others THEN
      err_text := 'BOM_REVISION_API(Import-'||stmt_num||') '||substrb(SQLERRM,1,1000);
      RETURN(ret_code);
END Import_Item_Revision;


END Bom_Revision_Api;

/
