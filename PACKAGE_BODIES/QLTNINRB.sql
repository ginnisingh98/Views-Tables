--------------------------------------------------------
--  DDL for Package Body QLTNINRB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTNINRB" as
/* $Header: qltninrb.plb 120.3.12010000.2 2008/10/17 06:38:45 skolluku ship $ */
-- A Server Side Name In
-- By Kevin Wiggen



/*
  --
  -- Changed to use two cursors for performance reason.
  -- See Bug 1293975.
  -- bso Sun May 28 16:07:56 PDT 2000
  --
  CURSOR table_stuff(X_TXN_HEADER_ID NUMBER, X_COLLECTIOn_ID NUMBER) IS
     SELECT * from QA_RESULTS
     WHERE TXN_HEADER_ID = NVL (X_TXN_HEADER_ID, TXN_HEADER_ID )
     AND   Collection_id = NVL( X_COLLECTION_ID, Collection_id );
*/

  -- See comments in INIT_CURSOR
  CURSOR qa_results_txn(x NUMBER) IS
      SELECT *
      FROM qa_results
      WHERE txn_header_id = x;

  CURSOR qa_results_col(x NUMBER) IS
      SELECT *
      FROM qa_results
      WHERE collection_id = x;

  -- Added for bug1843356. kabalakr
  CURSOR qa_results_occ(planID NUMBER, col_id NUMBER, occ NUMBER) IS
      SELECT *
      FROM qa_results
      WHERE plan_id = planID
      AND collection_id = col_id
      AND occurrence = occ;

  table_rec qa_results%ROWTYPE;

  --
  -- g_column can be TXN_HEADER_ID or COLLECTION_ID
  -- There is no default value.  It will be init by init_cursor.
  --
  g_column VARCHAR2(15);

--
-- Removed the DEFAULT clause to make the code GSCC compliant
-- List of changed arguments.
-- Old
--    X_PLAN_ID NUMBER DEFAULT NULL
--    X_COLLECTION_ID NUMBER DEFAULT NULL
--    X_OCCURRENCE NUMBER DEFAULT NULL
-- New
--    X_PLAN_ID NUMBER
--    X_COLLECTION_ID NUMBER
--    X_OCCURRENCE NUMBER
--
---------------------------------------------------------
  PROCEDURE INIT_CURSOR(X_PLAN_ID NUMBER, X_TXN_HEADER_ID NUMBER,
            X_COLLECTION_ID NUMBER, X_OCCURRENCE NUMBER) IS
----------------------------------------------------------

  BEGIN
      --
      -- OBSOLETE:  The old table_stuff cursor is not performant.
      -- OPEN table_stuff(X_TXN_HEADER_ID , X_COLLECTION_ID);

      --
      -- This is an interesting exclusive OR situation.
      -- The user must pass x_txn_header_id xor x_collection_id
      -- into INIT_CURSOR.  Hence, we select records from
      -- qa_results based on either txn_header_id or collection_id
      -- column.  (Required two new indexes for these).
      --
      -- The natural implementation for this exclusive OR selection
      -- is to declare a ref cursor at the package level and initialize
      -- it in this procedure.
      --
      -- Unfortunately, Oracle 8 or 8i don't let us define a ref cursor
      -- variable at the package level.  Therefore, we define two
      -- different cursors and set a "mode" variable named g_column
      -- to indicate which column should be used as where condition.
      --
      -- bso Sun May 28 16:26:53 PDT 2000

      -- Bug1843356. Added the first IF condition.
      -- kabalakr 22 feb 02

      IF x_occurrence IS NOT NULL THEN
	  g_column := 'OCCURRENCE';
	  OPEN qa_results_occ(x_plan_id, x_collection_id, x_occurrence);
      ELSIF x_txn_header_id IS NOT NULL THEN
          g_column := 'TXN_HEADER_ID';
          OPEN qa_results_txn(x_txn_header_id);
      ELSE -- x_collection_id IS NOT NULL
          g_column := 'COLLECTION_ID';
          OPEN qa_results_col(x_collection_id);
      END IF;

  END INIT_CURSOR;

---------------------------------------------------------
  FUNCTION NEXT_ROW RETURN BOOLEAN IS
----------------------------------------------------------

  BEGIN

    --
    -- This is an interesting exclusive OR situation.
    -- The user must pass x_txn_header_id xor x_collection_id
    -- into INIT_CURSOR.  Hence, we select records from
    -- qa_results based on either txn_header_id or collection_id
    -- column.
    -- bso Sun May 28 16:24:10 PDT 2000
    --

    -- Bug1843356. Added the first IF condition.
    -- kabalakr 22 feb 02

    IF g_column = 'OCCURRENCE' THEN
	FETCH qa_results_occ INTO table_rec;
	RETURN qa_results_occ%FOUND;
    ELSIF g_column = 'TXN_HEADER_ID' THEN
        FETCH qa_results_txn INTO table_rec;
        RETURN qa_results_txn%FOUND;
    ELSIF g_column = 'COLLECTION_ID' THEN
        FETCH qa_results_col INTO table_rec;
        RETURN qa_results_col%FOUND;
    END IF;

    RETURN FALSE;  -- just in case g_column is not set!

  END NEXT_ROW;

---------------------------------------------------------
  FUNCTION NAME_IN(X_COL_NAME VARCHAR2)
           RETURN VARCHAR2 IS
----------------------------------------------------------


  BEGIN

    IF X_COL_NAME = 'PO_HEADER_ID' THEN
       return(to_char(table_rec.PO_HEADER_ID));
    END IF;

    IF X_COL_NAME = 'PO_LINE_NUM' THEN
       return(to_char(table_rec.PO_LINE_NUM));
    END IF;

    IF X_COL_NAME = 'PO_SHIPMENT_NUM' THEN
       return(to_char(table_rec.PO_SHIPMENT_NUM));
    END IF;

    IF X_COL_NAME = 'CUSTOMER_ID' THEN
       return(to_char(table_rec.CUSTOMER_ID));
    END IF;

    IF X_COL_NAME = 'SO_HEADER_ID' THEN
       return(to_char(table_rec.SO_HEADER_ID));
    END IF;

    IF X_COL_NAME = 'RMA_HEADER_ID' THEN
       return(to_char(table_rec.RMA_HEADER_ID));
    END IF;

    IF X_COL_NAME = 'CHARACTER1' THEN
       return(table_rec.CHARACTER1);
    END IF;

    IF X_COL_NAME = 'CHARACTER2' THEN
       return(table_rec.CHARACTER2);
    END IF;

    IF X_COL_NAME = 'CHARACTER3' THEN
       return(table_rec.CHARACTER3);
    END IF;

    IF X_COL_NAME = 'CHARACTER4' THEN
       return(table_rec.CHARACTER4);
    END IF;

    IF X_COL_NAME = 'CHARACTER5' THEN
       return(table_rec.CHARACTER5);
    END IF;

    IF X_COL_NAME = 'CHARACTER6' THEN
       return(table_rec.CHARACTER6);
    END IF;

    IF X_COL_NAME = 'CHARACTER7' THEN
       return(table_rec.CHARACTER7);
    END IF;

    IF X_COL_NAME = 'CHARACTER8' THEN
       return(table_rec.CHARACTER8);
    END IF;

    IF X_COL_NAME = 'CHARACTER9' THEN
       return(table_rec.CHARACTER9);
    END IF;

    IF X_COL_NAME = 'CHARACTER10' THEN
       return(table_rec.CHARACTER10);
    END IF;

    IF X_COL_NAME = 'CHARACTER11' THEN
       return(table_rec.CHARACTER11);
    END IF;

    IF X_COL_NAME = 'CHARACTER12' THEN
       return(table_rec.CHARACTER12);
    END IF;

    IF X_COL_NAME = 'CHARACTER13' THEN
       return(table_rec.CHARACTER13);
    END IF;

    IF X_COL_NAME = 'CHARACTER14' THEN
       return(table_rec.CHARACTER14);
    END IF;

    IF X_COL_NAME = 'CHARACTER15' THEN
       return(table_rec.CHARACTER15);
    END IF;

    IF X_COL_NAME = 'CHARACTER16' THEN
       return(table_rec.CHARACTER16);
    END IF;

    IF X_COL_NAME = 'CHARACTER17' THEN
       return(table_rec.CHARACTER17);
    END IF;

    IF X_COL_NAME = 'CHARACTER18' THEN
       return(table_rec.CHARACTER18);
    END IF;

    IF X_COL_NAME = 'CHARACTER19' THEN
       return(table_rec.CHARACTER19);
    END IF;

    IF X_COL_NAME = 'CHARACTER20' THEN
       return(table_rec.CHARACTER20);
    END IF;

    IF X_COL_NAME = 'CHARACTER21' THEN
       return(table_rec.CHARACTER21);
    END IF;

    IF X_COL_NAME = 'CHARACTER22' THEN
       return(table_rec.CHARACTER22);
    END IF;

    IF X_COL_NAME = 'CHARACTER23' THEN
       return(table_rec.CHARACTER23);
    END IF;

    IF X_COL_NAME = 'CHARACTER24' THEN
       return(table_rec.CHARACTER24);
    END IF;

    IF X_COL_NAME = 'CHARACTER25' THEN
       return(table_rec.CHARACTER25);
    END IF;

    IF X_COL_NAME = 'CHARACTER26' THEN
       return(table_rec.CHARACTER26);
    END IF;

    IF X_COL_NAME = 'CHARACTER27' THEN
       return(table_rec.CHARACTER27);
    END IF;

    IF X_COL_NAME = 'CHARACTER28' THEN
       return(table_rec.CHARACTER28);
    END IF;

    IF X_COL_NAME = 'CHARACTER29' THEN
       return(table_rec.CHARACTER29);
    END IF;

    IF X_COL_NAME = 'CHARACTER30' THEN
       return(table_rec.CHARACTER30);
    END IF;

    IF X_COL_NAME = 'CHARACTER31' THEN
       return(table_rec.CHARACTER31);
    END IF;

    IF X_COL_NAME = 'CHARACTER32' THEN
       return(table_rec.CHARACTER32);
    END IF;

    IF X_COL_NAME = 'CHARACTER33' THEN
       return(table_rec.CHARACTER33);
    END IF;

    IF X_COL_NAME = 'CHARACTER34' THEN
       return(table_rec.CHARACTER34);
    END IF;

    IF X_COL_NAME = 'CHARACTER35' THEN
       return(table_rec.CHARACTER35);
    END IF;

    IF X_COL_NAME = 'CHARACTER36' THEN
       return(table_rec.CHARACTER36);
    END IF;

    IF X_COL_NAME = 'CHARACTER37' THEN
       return(table_rec.CHARACTER37);
    END IF;

    IF X_COL_NAME = 'CHARACTER38' THEN
       return(table_rec.CHARACTER38);
    END IF;

    IF X_COL_NAME = 'CHARACTER39' THEN
       return(table_rec.CHARACTER39);
    END IF;

    IF X_COL_NAME = 'CHARACTER40' THEN
       return(table_rec.CHARACTER40);
    END IF;

    IF X_COL_NAME = 'CHARACTER41' THEN
       return(table_rec.CHARACTER41);
    END IF;

    IF X_COL_NAME = 'CHARACTER42' THEN
       return(table_rec.CHARACTER42);
    END IF;

    IF X_COL_NAME = 'CHARACTER43' THEN
       return(table_rec.CHARACTER43);
    END IF;

    IF X_COL_NAME = 'CHARACTER44' THEN
       return(table_rec.CHARACTER44);
    END IF;

    IF X_COL_NAME = 'CHARACTER45' THEN
       return(table_rec.CHARACTER45);
    END IF;

    IF X_COL_NAME = 'CHARACTER46' THEN
       return(table_rec.CHARACTER46);
    END IF;

    IF X_COL_NAME = 'CHARACTER47' THEN
       return(table_rec.CHARACTER47);
    END IF;

    IF X_COL_NAME = 'CHARACTER48' THEN
       return(table_rec.CHARACTER48);
    END IF;

    IF X_COL_NAME = 'CHARACTER49' THEN
       return(table_rec.CHARACTER49);
    END IF;

    IF X_COL_NAME = 'CHARACTER50' THEN
       return(table_rec.CHARACTER50);
    END IF;

    IF X_COL_NAME = 'CHARACTER51' THEN
       return(table_rec.CHARACTER51);
    END IF;

    IF X_COL_NAME = 'CHARACTER52' THEN
       return(table_rec.CHARACTER52);
    END IF;

    IF X_COL_NAME = 'CHARACTER53' THEN
       return(table_rec.CHARACTER53);
    END IF;

    IF X_COL_NAME = 'CHARACTER54' THEN
       return(table_rec.CHARACTER54);
    END IF;

    IF X_COL_NAME = 'CHARACTER55' THEN
       return(table_rec.CHARACTER55);
    END IF;

    IF X_COL_NAME = 'CHARACTER56' THEN
       return(table_rec.CHARACTER56);
    END IF;

    IF X_COL_NAME = 'CHARACTER57' THEN
       return(table_rec.CHARACTER57);
    END IF;

    IF X_COL_NAME = 'CHARACTER58' THEN
       return(table_rec.CHARACTER58);
    END IF;

    IF X_COL_NAME = 'CHARACTER59' THEN
       return(table_rec.CHARACTER59);
    END IF;

    IF X_COL_NAME = 'CHARACTER60' THEN
       return(table_rec.CHARACTER60);
    END IF;

    IF X_COL_NAME = 'CHARACTER61' THEN
       return(table_rec.CHARACTER61);
    END IF;

    IF X_COL_NAME = 'CHARACTER62' THEN
       return(table_rec.CHARACTER62);
    END IF;

    IF X_COL_NAME = 'CHARACTER63' THEN
       return(table_rec.CHARACTER63);
    END IF;

    IF X_COL_NAME = 'CHARACTER64' THEN
       return(table_rec.CHARACTER64);
    END IF;

    IF X_COL_NAME = 'CHARACTER65' THEN
       return(table_rec.CHARACTER65);
    END IF;

    IF X_COL_NAME = 'CHARACTER66' THEN
       return(table_rec.CHARACTER66);
    END IF;

    IF X_COL_NAME = 'CHARACTER67' THEN
       return(table_rec.CHARACTER67);
    END IF;

    IF X_COL_NAME = 'CHARACTER68' THEN
       return(table_rec.CHARACTER68);
    END IF;

    IF X_COL_NAME = 'CHARACTER69' THEN
       return(table_rec.CHARACTER69);
    END IF;

    IF X_COL_NAME = 'CHARACTER70' THEN
       return(table_rec.CHARACTER70);
    END IF;

    IF X_COL_NAME = 'CHARACTER71' THEN
       return(table_rec.CHARACTER71);
    END IF;

    IF X_COL_NAME = 'CHARACTER72' THEN
       return(table_rec.CHARACTER72);
    END IF;

    IF X_COL_NAME = 'CHARACTER73' THEN
       return(table_rec.CHARACTER73);
    END IF;

    IF X_COL_NAME = 'CHARACTER74' THEN
       return(table_rec.CHARACTER74);
    END IF;

    IF X_COL_NAME = 'CHARACTER75' THEN
       return(table_rec.CHARACTER75);
    END IF;

    IF X_COL_NAME = 'CHARACTER76' THEN
       return(table_rec.CHARACTER76);
    END IF;

    IF X_COL_NAME = 'CHARACTER77' THEN
       return(table_rec.CHARACTER77);
    END IF;

    IF X_COL_NAME = 'CHARACTER78' THEN
       return(table_rec.CHARACTER78);
    END IF;

    IF X_COL_NAME = 'CHARACTER79' THEN
       return(table_rec.CHARACTER79);
    END IF;

    IF X_COL_NAME = 'CHARACTER80' THEN
       return(table_rec.CHARACTER80);
    END IF;

    IF X_COL_NAME = 'CHARACTER81' THEN
       return(table_rec.CHARACTER81);
    END IF;

    IF X_COL_NAME = 'CHARACTER82' THEN
       return(table_rec.CHARACTER82);
    END IF;

    IF X_COL_NAME = 'CHARACTER83' THEN
       return(table_rec.CHARACTER83);
    END IF;

    IF X_COL_NAME = 'CHARACTER84' THEN
       return(table_rec.CHARACTER84);
    END IF;

    IF X_COL_NAME = 'CHARACTER85' THEN
       return(table_rec.CHARACTER85);
    END IF;

    IF X_COL_NAME = 'CHARACTER86' THEN
       return(table_rec.CHARACTER86);
    END IF;

    IF X_COL_NAME = 'CHARACTER87' THEN
       return(table_rec.CHARACTER87);
    END IF;

    IF X_COL_NAME = 'CHARACTER88' THEN
       return(table_rec.CHARACTER88);
    END IF;

    IF X_COL_NAME = 'CHARACTER89' THEN
       return(table_rec.CHARACTER89);
    END IF;

    IF X_COL_NAME = 'CHARACTER90' THEN
       return(table_rec.CHARACTER90);
    END IF;

    IF X_COL_NAME = 'CHARACTER91' THEN
       return(table_rec.CHARACTER91);
    END IF;

    IF X_COL_NAME = 'CHARACTER92' THEN
       return(table_rec.CHARACTER92);
    END IF;

    IF X_COL_NAME = 'CHARACTER93' THEN
       return(table_rec.CHARACTER93);
    END IF;

    IF X_COL_NAME = 'CHARACTER94' THEN
       return(table_rec.CHARACTER94);
    END IF;

    IF X_COL_NAME = 'CHARACTER95' THEN
       return(table_rec.CHARACTER95);
    END IF;

    IF X_COL_NAME = 'CHARACTER96' THEN
       return(table_rec.CHARACTER96);
    END IF;

    IF X_COL_NAME = 'CHARACTER97' THEN
       return(table_rec.CHARACTER97);
    END IF;

    IF X_COL_NAME = 'CHARACTER98' THEN
       return(table_rec.CHARACTER98);
    END IF;

    IF X_COL_NAME = 'CHARACTER99' THEN
       return(table_rec.CHARACTER99);
    END IF;

    IF X_COL_NAME = 'CHARACTER100' THEN
       return(table_rec.CHARACTER100);
    END IF;

    IF X_COL_NAME = 'COLLECTION_ID' THEN
       return(to_char(table_rec.COLLECTION_ID));
    END IF;

    IF X_COL_NAME = 'OCCURRENCE' THEN
       return(to_char(table_rec.OCCURRENCE));
    END IF;

    IF X_COL_NAME = 'LAST_UPDATE_DATE' THEN
       return(to_char(table_rec.LAST_UPDATE_DATE));
    END IF;

    IF X_COL_NAME = 'QA_LAST_UPDATE_DATE' THEN
       return(to_char(table_rec.QA_LAST_UPDATE_DATE));
    END IF;

    IF X_COL_NAME = 'LAST_UPDATED_BY' THEN
       return(to_char(table_rec.LAST_UPDATED_BY));
    END IF;

    IF X_COL_NAME = 'QA_LAST_UPDATED_BY' THEN
       return(to_char(table_rec.QA_LAST_UPDATED_BY));
    END IF;

    IF X_COL_NAME = 'CREATION_DATE' THEN
       return(to_char(table_rec.CREATION_DATE));
    END IF;

    IF X_COL_NAME = 'QA_CREATION_DATE' THEN
       return fnd_date.date_to_chardt(table_rec.QA_CREATION_DATE);
    END IF;

    IF X_COL_NAME = 'CREATED_BY' THEN
       return(to_char(table_rec.CREATED_BY));
    END IF;

    IF X_COL_NAME = 'QA_CREATED_BY' THEN
       return(to_char(table_rec.QA_CREATED_BY));
    END IF;

    IF X_COL_NAME = 'LAST_UPDATE_LOGIN' THEN
       return(to_char(table_rec.LAST_UPDATE_LOGIN));
    END IF;

    IF X_COL_NAME = 'TRANSACTION_NUMBER' THEN
       return(to_char(table_rec.TRANSACTION_NUMBER));
    END IF;

    IF X_COL_NAME = 'TXN_HEADER_ID' THEN
       return(to_char(table_rec.TXN_HEADER_ID));
    END IF;

    IF X_COL_NAME = 'ORGANIZATION_ID' THEN
       return(to_char(table_rec.ORGANIZATION_ID));
    END IF;

    IF X_COL_NAME = 'PLAN_ID' THEN
       return(to_char(table_rec.PLAN_ID));
    END IF;

    IF X_COL_NAME = 'SPEC_ID' THEN
       return(to_char(table_rec.SPEC_ID));
    END IF;

    IF X_COL_NAME = 'TRANSACTION_ID' THEN
       return(to_char(table_rec.TRANSACTION_ID));
    END IF;

    IF X_COL_NAME = 'DEPARTMENT_ID' THEN
       return(to_char(table_rec.DEPARTMENT_ID));
    END IF;

    IF X_COL_NAME = 'TO_DEPARTMENT_ID' THEN
       return(to_char(table_rec.DEPARTMENT_ID));
    END IF;

    IF X_COL_NAME = 'RESOURCE_ID' THEN
       return(to_char(table_rec.RESOURCE_ID));
    END IF;

    IF X_COL_NAME = 'QUANTITY' THEN
       return(to_char(table_rec.QUANTITY));
    END IF;

    IF X_COL_NAME = 'ITEM_ID' THEN
       return(to_char(table_rec.ITEM_ID));
    END IF;

    IF X_COL_NAME = 'UOM' THEN
       return(table_rec.UOM);
    END IF;

    IF X_COL_NAME = 'REVISION' THEN
       return(table_rec.REVISION);
    END IF;

    IF X_COL_NAME = 'SUBINVENTORY' THEN
       return(table_rec.SUBINVENTORY);
    END IF;

    IF X_COL_NAME = 'LOCATOR_ID' THEN
       return(to_char(table_rec.LOCATOR_ID));
    END IF;

    IF X_COL_NAME = 'LOT_NUMBER' THEN
       return(table_rec.LOT_NUMBER);
    END IF;

    IF X_COL_NAME = 'SERIAL_NUMBER' THEN
       return(table_rec.SERIAL_NUMBER);
    END IF;

    IF X_COL_NAME = 'COMP_ITEM_ID' THEN
       return(to_char(table_rec.COMP_ITEM_ID));
    END IF;

    IF X_COL_NAME = 'COMP_UOM' THEN
       return(table_rec.COMP_UOM);
    END IF;

    IF X_COL_NAME = 'COMP_REVISION' THEN
       return(table_rec.COMP_REVISION);
    END IF;

    IF X_COL_NAME = 'COMP_SUBINVENTORY' THEN
       return(table_rec.COMP_SUBINVENTORY);
    END IF;

    IF X_COL_NAME = 'COMP_LOCATOR_ID' THEN
       return(to_char(table_rec.COMP_LOCATOR_ID));
    END IF;

    IF X_COL_NAME = 'COMP_LOT_NUMBER' THEN
       return(table_rec.COMP_LOT_NUMBER);
    END IF;

    IF X_COL_NAME = 'COMP_SERIAL_NUMBER' THEN
       return(table_rec.COMP_SERIAL_NUMBER);
    END IF;

    IF X_COL_NAME = 'WIP_ENTITY_ID' THEN
       return(to_char(table_rec.WIP_ENTITY_ID));
    END IF;

    IF X_COL_NAME = 'LINE_ID' THEN
       return(to_char(table_rec.LINE_ID));
    END IF;

    IF X_COL_NAME = 'TO_OP_SEQ_NUM' THEN
       return(to_char(table_rec.TO_OP_SEQ_NUM));
    END IF;

    IF X_COL_NAME = 'FROM_OP_SEQ_NUM' THEN
       return(to_char(table_rec.FROM_OP_SEQ_NUM));
    END IF;

    IF X_COL_NAME = 'VENDOR_ID' THEN
       return(to_char(table_rec.VENDOR_ID));
    END IF;

    IF X_COL_NAME = 'RECEIPT_NUM' THEN
       return(table_rec.RECEIPT_NUM);
    END IF;

    IF X_COL_NAME = 'PO_RELEASE_ID' THEN
       return(to_char(table_rec.PO_RELEASE_ID));
    END IF;

    IF X_COL_NAME = 'STATUS' THEN
       return(to_char(table_rec.STATUS));
    END IF;

    IF X_COL_NAME = 'PROJECT_ID' THEN
       return(to_char(table_rec.PROJECT_ID));
    END IF;

    IF X_COL_NAME = 'TASK_ID' THEN
       return(to_char(table_rec.TASK_ID));
    END IF;

    IF X_COL_NAME = 'LPN_ID' THEN
       return(to_char(table_rec.LPN_ID));
    END IF;

    -- added for new harcoded element Transfer License Plate Number
    -- saugupta Aug 2003
    IF X_COL_NAME = 'XFR_LPN_ID' THEN
       return(to_char(table_rec.XFR_LPN_ID));
    END IF;

    -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
    -- modified to date_to_canon_dt
    IF X_COL_NAME = 'TRANSACTION_DATE' THEN
       return qltdate.date_to_canon_dt(table_rec.TRANSACTION_DATE);
    END IF;

    IF X_COL_NAME = 'ASSET_GROUP_ID' THEN
       return(to_char(table_rec.ASSET_GROUP_ID));
    END IF;

    --dgupta: Start R12 EAM Integration. Bug 4345492
    IF X_COL_NAME = 'ASSET_INSTANCE_ID' THEN
       return(to_char(table_rec.ASSET_INSTANCE_ID));
    END IF;
    --dgupta: End R12 EAM Integration. Bug 4345492

    IF X_COL_NAME = 'ASSET_NUMBER' THEN
       return(table_rec.ASSET_NUMBER);
    END IF;

    IF X_COL_NAME = 'ASSET_ACTIVITY_ID' THEN
       return(to_char(table_rec.ASSET_ACTIVITY_ID));
    END IF;

    -- added for new harcoded element Followup Activity
    -- saugupta Aug 2003
    IF X_COL_NAME = 'FOLLOWUP_ACTIVITY_ID' THEN
       return(to_char(table_rec.FOLLOWUP_ACTIVITY_ID));
    END IF;

    IF X_COL_NAME = 'WORK_ORDER_ID' THEN
       return(to_char(table_rec.WORK_ORDER_ID));
    END IF;

    IF X_COL_NAME = 'SEQUENCE1' THEN
       return(table_rec.SEQUENCE1);
    END IF;

    IF X_COL_NAME = 'SEQUENCE2' THEN
       return(table_rec.SEQUENCE2);
    END IF;

    IF X_COL_NAME = 'SEQUENCE3' THEN
       return(table_rec.SEQUENCE3);
    END IF;

    IF X_COL_NAME = 'SEQUENCE4' THEN
       return(table_rec.SEQUENCE4);
    END IF;

    IF X_COL_NAME = 'SEQUENCE5' THEN
       return(table_rec.SEQUENCE5);
    END IF;

    IF X_COL_NAME = 'SEQUENCE6' THEN
       return(table_rec.SEQUENCE6);
    END IF;

    IF X_COL_NAME = 'SEQUENCE7' THEN
       return(table_rec.SEQUENCE7);
    END IF;

    IF X_COL_NAME = 'SEQUENCE8' THEN
       return(table_rec.SEQUENCE8);
    END IF;

    IF X_COL_NAME = 'SEQUENCE9' THEN
       return(table_rec.SEQUENCE9);
    END IF;

    IF X_COL_NAME = 'SEQUENCE10' THEN
       return(table_rec.SEQUENCE10);
    END IF;

    IF X_COL_NAME = 'SEQUENCE11' THEN
       return(table_rec.SEQUENCE11);
    END IF;

    IF X_COL_NAME = 'SEQUENCE12' THEN
       return(table_rec.SEQUENCE12);
    END IF;

    IF X_COL_NAME = 'SEQUENCE13' THEN
       return(table_rec.SEQUENCE13);
    END IF;

    IF X_COL_NAME = 'SEQUENCE14' THEN
       return(table_rec.SEQUENCE14);
    END IF;

    IF X_COL_NAME = 'SEQUENCE15' THEN
       return(table_rec.SEQUENCE15);
    END IF;

    IF X_COL_NAME = 'PARTY_ID' THEN
       return(to_char(table_rec.PARTY_ID));
    END IF;

    IF X_COL_NAME = 'COMMENT1' THEN
       return(table_rec.COMMENT1);
    END IF;

    IF X_COL_NAME = 'COMMENT2' THEN
       return(table_rec.COMMENT2);
    END IF;

    IF X_COL_NAME = 'COMMENT3' THEN
       return(table_rec.COMMENT3);
    END IF;

    IF X_COL_NAME = 'COMMENT4' THEN
       return(table_rec.COMMENT4);
    END IF;

    IF X_COL_NAME = 'COMMENT5' THEN
       return(table_rec.COMMENT5);
    END IF;

    IF X_COL_NAME = 'CONTRACT_ID' THEN
       return(to_char(table_rec.CONTRACT_ID));
    END IF;

    IF X_COL_NAME = 'CONTRACT_LINE_ID' THEN
       return(to_char(table_rec.CONTRACT_LINE_ID));
    END IF;

    IF X_COL_NAME = 'DELIVERABLE_ID' THEN
       return(to_char(table_rec.DELIVERABLE_ID));
    END IF;

    --
    -- Included the following newly added columns in
    -- QA_RESULTS table for ASO project
    -- rkunchal Thu Jul 25 01:43:48 PDT 2002
    --

    IF X_COL_NAME = 'CSI_INSTANCE_ID' THEN
       return(to_char(table_rec.CSI_INSTANCE_ID));
    END IF;

    IF X_COL_NAME = 'COUNTER_ID' THEN
       return(to_char(table_rec.COUNTER_ID));
    END IF;

    IF X_COL_NAME = 'COUNTER_READING_ID' THEN
       return(to_char(table_rec.COUNTER_READING_ID));
    END IF;

    IF X_COL_NAME = 'AHL_MR_ID' THEN
       return(to_char(table_rec.AHL_MR_ID));
    END IF;

    IF X_COL_NAME = 'CS_INCIDENT_ID' THEN
       return(to_char(table_rec.CS_INCIDENT_ID));
    END IF;

    IF X_COL_NAME = 'WIP_REWORK_ID' THEN
       return(to_char(table_rec.WIP_REWORK_ID));
    END IF;

    IF X_COL_NAME = 'DISPOSITION_SOURCE' THEN
       return(table_rec.DISPOSITION_SOURCE);
    END IF;

    IF X_COL_NAME = 'DISPOSITION' THEN
       return(table_rec.DISPOSITION);
    END IF;

    IF X_COL_NAME = 'DISPOSITION_ACTION' THEN
       return(table_rec.DISPOSITION_ACTION);
    END IF;

    IF X_COL_NAME = 'DISPOSITION_STATUS' THEN
       return(table_rec.DISPOSITION_STATUS);
    END IF;

    --
    -- See Bug 2588213
    -- To support the element Maintenance Op Seq Number
    -- to be used along with Maintenance Workorder
    -- rkunchal Mon Sep 23 23:46:28 PDT 2002
    --

    IF X_COL_NAME = 'MAINTENANCE_OP_SEQ' THEN
       return(table_rec.MAINTENANCE_OP_SEQ);
    END IF;

    --
    -- End of additions for ASO project
    -- rkunchal Thu Jul 25 01:43:48 PDT 2002
    --

    -- Start of inclusions for NCM Hardcode Elements.
    -- suramasw Thu Oct 31 10:48:59 PST 2002.
    -- Bug 2449067.


    IF X_COL_NAME = 'BILL_REFERENCE_ID' THEN
       return(to_char(table_rec.BILL_REFERENCE_ID));
    END IF;

    IF X_COL_NAME = 'ROUTING_REFERENCE_ID' THEN
       return(to_char(table_rec.ROUTING_REFERENCE_ID));
    END IF;

    IF X_COL_NAME = 'CONCURRENT_REQUEST_ID' THEN
       return(to_char(table_rec.CONCURRENT_REQUEST_ID));
    END IF;

    -- Removed the to_char() since it is not needed for Character fields.
    -- Bug 2686970.suramasw Wed Nov 27 05:12:52 PST 2002.

    IF X_COL_NAME = 'TO_SUBINVENTORY' THEN
       return(table_rec.TO_SUBINVENTORY);
    END IF;

    -- End Bug 2686970.

    IF X_COL_NAME = 'TO_LOCATOR_ID' THEN
       return(to_char(table_rec.TO_LOCATOR_ID));
    END IF;

    IF X_COL_NAME = 'LOT_STATUS_ID' THEN
       return(to_char(table_rec.LOT_STATUS_ID));
    END IF;

    IF X_COL_NAME = 'SERIAL_STATUS_ID' THEN
       return(to_char(table_rec.SERIAL_STATUS_ID));
    END IF;

    -- Removed the to_char() since it is not needed for Character fields.
    -- Bug 2686970.suramasw Wed Nov 27 05:12:52 PST 2002.

    IF X_COL_NAME = 'NONCONFORMANCE_SOURCE' THEN
       return(table_rec.NONCONFORMANCE_SOURCE);
    END IF;

    IF X_COL_NAME = 'NONCONFORM_SEVERITY' THEN
       return(table_rec.NONCONFORM_SEVERITY);
    END IF;

    IF X_COL_NAME = 'NONCONFORM_PRIORITY' THEN
       return(table_rec.NONCONFORM_PRIORITY);
    END IF;

    IF X_COL_NAME = 'NONCONFORMANCE_TYPE' THEN
       return(table_rec.NONCONFORMANCE_TYPE);
    END IF;

    IF X_COL_NAME = 'NONCONFORMANCE_CODE' THEN
       return(table_rec.NONCONFORMANCE_CODE);
    END IF;

    IF X_COL_NAME = 'NONCONFORMANCE_STATUS' THEN
       return(table_rec.NONCONFORMANCE_STATUS);
    END IF;

    -- End Bug 2686970.

    -- Bug 3179845. Timezone Project. rponnusa Fri Oct 17 10:34:50 PDT 2003
    -- added date_to_canon_dt
    IF X_COL_NAME = 'DATE_OPENED' THEN
       return qltdate.date_to_canon_dt(table_rec.DATE_OPENED);
    END IF;

    IF X_COL_NAME = 'DATE_CLOSED' THEN
       return qltdate.date_to_canon_dt(table_rec.DATE_CLOSED);
    END IF;

    IF X_COL_NAME = 'DAYS_TO_CLOSE' THEN
       return(to_char(table_rec.DAYS_TO_CLOSE));
    END IF;

    IF X_COL_NAME = 'RCV_TRANSACTION_ID' THEN
       return(to_char(table_rec.RCV_TRANSACTION_ID));
    END IF;

    -- End of inclusions for NCM Hardcode Elements.

    --anagarwa Thu Nov 14 13:31:42 PST 2002
    -- Start inclusion for CAR Hardcoded Elements

    -- Removed the to_char() since it is not needed for Character fields.
    -- Bug 2686970.suramasw Wed Nov 27 05:12:52 PST 2002.

    IF X_COL_NAME = 'REQUEST_SOURCE' THEN
       return(table_rec.REQUEST_SOURCE);
    END IF;

    IF X_COL_NAME = 'REQUEST_PRIORITY' THEN
       return(table_rec.REQUEST_PRIORITY);
    END IF;

    IF X_COL_NAME = 'REQUEST_SEVERITY' THEN
       return(table_rec.REQUEST_SEVERITY);
    END IF;

    IF X_COL_NAME = 'REQUEST_STATUS' THEN
       return(table_rec.REQUEST_STATUS);
    END IF;

    IF X_COL_NAME = 'ECO_NAME' THEN
       return(table_rec.ECO_NAME);
    END IF;

    -- End Bug 2686970.

    -- End of inclusions for CAR Hardcode Elements.

    -- R12 OPM Deviations. Bug 4345503 Start
    IF X_COL_NAME = 'PROCESS_BATCH_ID' THEN
       return(to_char(table_rec.PROCESS_BATCH_ID));
    END IF;

    IF X_COL_NAME = 'PROCESS_BATCHSTEP_ID' THEN
       return(to_char(table_rec.PROCESS_BATCHSTEP_ID));
    END IF;

    IF X_COL_NAME = 'PROCESS_OPERATION_ID' THEN
       return(to_char(table_rec.PROCESS_OPERATION_ID));
    END IF;

    IF X_COL_NAME = 'PROCESS_ACTIVITY_ID' THEN
       return(to_char(table_rec.PROCESS_ACTIVITY_ID));
    END IF;

    IF X_COL_NAME = 'PROCESS_RESOURCE_ID' THEN
       return(to_char(table_rec.PROCESS_RESOURCE_ID));
    END IF;

    IF X_COL_NAME = 'PROCESS_PARAMETER_ID' THEN
       return(to_char(table_rec.PROCESS_PARAMETER_ID));
    END IF;
    -- R12 OPM Deviations. Bug 4345503 End

    /* R12 DR Integration. Bug 4345489 */
    IF X_COL_NAME = 'REPAIR_LINE_ID' THEN
       return(to_char(table_rec.REPAIR_LINE_ID));
    END IF;

    IF X_COL_NAME = 'JTF_TASK_ID' THEN
       return(to_char(table_rec.JTF_TASK_ID));
    END IF;
    /* R12 DR Integration. Bug 4345489 */

    FND_MESSAGE.SET_NAME('QA', 'Column Not Found In Table');
    FND_MESSAGE.RAISE_ERROR;


  END NAME_IN;

  PROCEDURE CLOSE_CURSOR IS

  BEGIN

    -- Bug 1843356. Added the IF condition below.
    -- kabalakr 22 feb 02

    IF g_column = 'OCCURRENCE' THEN
	CLOSE qa_results_occ;
    ELSIF g_column = 'TXN_HEADER_ID' THEN
        CLOSE qa_results_txn;
    ELSE -- g_column = 'COLLECTION_ID'
        CLOSE qa_results_col;
    END IF;

  END CLOSE_CURSOR;

  FUNCTION RES_CHAR_COLUMNS

    RETURN NUMBER IS

  BEGIN

    RETURN (100);

  END RES_CHAR_COLUMNS;

  --
  -- Bug 7491253. 12.1.1 FP for Bug 6599571
  -- Added this procedure to set value to the record
  -- in session for collection import for action_id=24
  -- skolluku
  PROCEDURE set_value(X_COL_NAME VARCHAR2,return_value VARCHAR2) IS
  BEGIN

    IF X_COL_NAME = 'PO_HEADER_ID' THEN
       table_rec.PO_HEADER_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'PO_LINE_NUM' THEN
       table_rec.PO_LINE_NUM:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'PO_SHIPMENT_NUM' THEN
       table_rec.PO_SHIPMENT_NUM:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'CUSTOMER_ID' THEN
       table_rec.CUSTOMER_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'SO_HEADER_ID' THEN
       table_rec.SO_HEADER_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'RMA_HEADER_ID' THEN
       table_rec.RMA_HEADER_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER1' THEN
       table_rec.CHARACTER1:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER2' THEN
       table_rec.CHARACTER2:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER3' THEN
       table_rec.CHARACTER3:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER4' THEN
       table_rec.CHARACTER4:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER5' THEN
       table_rec.CHARACTER5:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER6' THEN
       table_rec.CHARACTER6:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER7' THEN
       table_rec.CHARACTER7:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER8' THEN
       table_rec.CHARACTER8:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER9' THEN
       table_rec.CHARACTER9:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER10' THEN
       table_rec.CHARACTER10:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER11' THEN
       table_rec.CHARACTER11:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER12' THEN
       table_rec.CHARACTER12:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER13' THEN
       table_rec.CHARACTER13:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER14' THEN
       table_rec.CHARACTER14:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER15' THEN
       table_rec.CHARACTER15:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER16' THEN
       table_rec.CHARACTER16:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER17' THEN
       table_rec.CHARACTER17:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER18' THEN
       table_rec.CHARACTER18:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER19' THEN
       table_rec.CHARACTER19:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER20' THEN
       table_rec.CHARACTER20:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER21' THEN
       table_rec.CHARACTER21:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER22' THEN
       table_rec.CHARACTER22:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER23' THEN
       table_rec.CHARACTER23:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER24' THEN
       table_rec.CHARACTER24:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER25' THEN
       table_rec.CHARACTER25:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER26' THEN
       table_rec.CHARACTER26:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER27' THEN
       table_rec.CHARACTER27:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER28' THEN
       table_rec.CHARACTER28:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER29' THEN
       table_rec.CHARACTER29:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER30' THEN
       table_rec.CHARACTER30:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER31' THEN
       table_rec.CHARACTER31:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER32' THEN
       table_rec.CHARACTER32:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER33' THEN
       table_rec.CHARACTER33:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER34' THEN
       table_rec.CHARACTER34:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER35' THEN
       table_rec.CHARACTER35:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER36' THEN
       table_rec.CHARACTER36:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER37' THEN
       table_rec.CHARACTER37:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER38' THEN
       table_rec.CHARACTER38:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER39' THEN
       table_rec.CHARACTER39:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER40' THEN
       table_rec.CHARACTER40:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER41' THEN
       table_rec.CHARACTER41:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER42' THEN
       table_rec.CHARACTER42:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER43' THEN
       table_rec.CHARACTER43:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER44' THEN
       table_rec.CHARACTER44:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER45' THEN
       table_rec.CHARACTER45:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER46' THEN
       table_rec.CHARACTER46:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER47' THEN
       table_rec.CHARACTER47:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER48' THEN
       table_rec.CHARACTER48:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER49' THEN
       table_rec.CHARACTER49:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER50' THEN
       table_rec.CHARACTER50:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER51' THEN
       table_rec.CHARACTER51:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER52' THEN
       table_rec.CHARACTER52:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER53' THEN
       table_rec.CHARACTER53:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER54' THEN
       table_rec.CHARACTER54:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER55' THEN
       table_rec.CHARACTER55:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER56' THEN
       table_rec.CHARACTER56:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER57' THEN
       table_rec.CHARACTER57:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER58' THEN
       table_rec.CHARACTER58:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER59' THEN
       table_rec.CHARACTER59:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER60' THEN
       table_rec.CHARACTER60:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER61' THEN
       table_rec.CHARACTER61:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER62' THEN
       table_rec.CHARACTER62:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER63' THEN
       table_rec.CHARACTER63:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER64' THEN
       table_rec.CHARACTER64:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER65' THEN
       table_rec.CHARACTER65:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER66' THEN
       table_rec.CHARACTER66:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER67' THEN
       table_rec.CHARACTER67:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER68' THEN
       table_rec.CHARACTER68:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER69' THEN
       table_rec.CHARACTER69:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER70' THEN
       table_rec.CHARACTER70:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER71' THEN
       table_rec.CHARACTER71:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER72' THEN
       table_rec.CHARACTER72:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER73' THEN
       table_rec.CHARACTER73:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER74' THEN
       table_rec.CHARACTER74:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER75' THEN
       table_rec.CHARACTER75:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER76' THEN
       table_rec.CHARACTER76:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER77' THEN
       table_rec.CHARACTER77:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER78' THEN
       table_rec.CHARACTER78:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER79' THEN
       table_rec.CHARACTER79:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER80' THEN
       table_rec.CHARACTER80:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER81' THEN
       table_rec.CHARACTER81:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER82' THEN
       table_rec.CHARACTER82:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER83' THEN
       table_rec.CHARACTER83:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER84' THEN
       table_rec.CHARACTER84:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER85' THEN
       table_rec.CHARACTER85:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER86' THEN
       table_rec.CHARACTER86:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER87' THEN
       table_rec.CHARACTER87:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER88' THEN
       table_rec.CHARACTER88:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER89' THEN
       table_rec.CHARACTER89:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER90' THEN
       table_rec.CHARACTER90:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER91' THEN
       table_rec.CHARACTER91:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER92' THEN
       table_rec.CHARACTER92:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER93' THEN
       table_rec.CHARACTER93:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER94' THEN
       table_rec.CHARACTER94:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER95' THEN
       table_rec.CHARACTER95:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER96' THEN
       table_rec.CHARACTER96:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER97' THEN
       table_rec.CHARACTER97:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER98' THEN
       table_rec.CHARACTER98:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER99' THEN
       table_rec.CHARACTER99:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CHARACTER100' THEN
       table_rec.CHARACTER100:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COLLECTION_ID' THEN
       table_rec.COLLECTION_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'OCCURRENCE' THEN
       table_rec.OCCURRENCE:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'LAST_UPDATE_DATE' THEN
       table_rec.LAST_UPDATE_DATE:=qltdate.any_to_date(return_value);
    END IF;

    IF X_COL_NAME = 'QA_LAST_UPDATE_DATE' THEN
       table_rec.QA_LAST_UPDATE_DATE:=(return_value);
    END IF;

    IF X_COL_NAME = 'LAST_UPDATED_BY' THEN
       table_rec.LAST_UPDATED_BY:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'QA_LAST_UPDATED_BY' THEN
       table_rec.QA_LAST_UPDATED_BY:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'CREATION_DATE' THEN
       table_rec.CREATION_DATE:=qltdate.any_to_date(return_value);
    END IF;

    IF X_COL_NAME = 'QA_CREATION_DATE' THEN
      table_rec.QA_CREATION_DATE:=qltdate.any_to_date(return_value);
    END IF;

    IF X_COL_NAME = 'CREATED_BY' THEN
       table_rec.CREATED_BY:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'QA_CREATED_BY' THEN
       table_rec.QA_CREATED_BY:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'LAST_UPDATE_LOGIN' THEN
       table_rec.LAST_UPDATE_LOGIN:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'TRANSACTION_NUMBER' THEN
       table_rec.TRANSACTION_NUMBER:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'TXN_HEADER_ID' THEN
       table_rec.TXN_HEADER_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'ORGANIZATION_ID' THEN
       table_rec.ORGANIZATION_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'PLAN_ID' THEN
       table_rec.PLAN_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'SPEC_ID' THEN
       table_rec.SPEC_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'TRANSACTION_ID' THEN
       table_rec.TRANSACTION_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'DEPARTMENT_ID' THEN
       table_rec.DEPARTMENT_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'TO_DEPARTMENT_ID' THEN
       table_rec.DEPARTMENT_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'RESOURCE_ID' THEN
       table_rec.RESOURCE_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'QUANTITY' THEN
       table_rec.QUANTITY:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'ITEM_ID' THEN
       table_rec.ITEM_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'UOM' THEN
       table_rec.UOM:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'REVISION' THEN
       table_rec.REVISION:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SUBINVENTORY' THEN
       table_rec.SUBINVENTORY:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'LOCATOR_ID' THEN
       table_rec.LOCATOR_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'LOT_NUMBER' THEN
       table_rec.LOT_NUMBER:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SERIAL_NUMBER' THEN
       table_rec.SERIAL_NUMBER:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMP_ITEM_ID' THEN
       table_rec.COMP_ITEM_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'COMP_UOM' THEN
       table_rec.COMP_UOM:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMP_REVISION' THEN
       table_rec.COMP_REVISION:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMP_SUBINVENTORY' THEN
       table_rec.COMP_SUBINVENTORY:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMP_LOCATOR_ID' THEN
       table_rec.COMP_LOCATOR_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'COMP_LOT_NUMBER' THEN
       table_rec.COMP_LOT_NUMBER:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMP_SERIAL_NUMBER' THEN
       table_rec.COMP_SERIAL_NUMBER:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'WIP_ENTITY_ID' THEN
       table_rec.WIP_ENTITY_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'LINE_ID' THEN
       table_rec.LINE_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'TO_OP_SEQ_NUM' THEN
       table_rec.TO_OP_SEQ_NUM:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'FROM_OP_SEQ_NUM' THEN
       table_rec.FROM_OP_SEQ_NUM:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'VENDOR_ID' THEN
       table_rec.VENDOR_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'RECEIPT_NUM' THEN
       table_rec.RECEIPT_NUM:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'PO_RELEASE_ID' THEN
       table_rec.PO_RELEASE_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'STATUS' THEN
       table_rec.STATUS:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'PROJECT_ID' THEN
       table_rec.PROJECT_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'TASK_ID' THEN
       table_rec.TASK_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'LPN_ID' THEN
       table_rec.LPN_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'XFR_LPN_ID' THEN
       table_rec.XFR_LPN_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'TRANSACTION_DATE' THEN
      table_rec.TRANSACTION_DATE:=qltdate.any_to_date(return_value);
    END IF;

    IF X_COL_NAME = 'ASSET_GROUP_ID' THEN
       table_rec.ASSET_GROUP_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'ASSET_NUMBER' THEN
       table_rec.ASSET_NUMBER:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'ASSET_ACTIVITY_ID' THEN
       table_rec.ASSET_ACTIVITY_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'FOLLOWUP_ACTIVITY_ID' THEN
       table_rec.FOLLOWUP_ACTIVITY_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'WORK_ORDER_ID' THEN
       table_rec.WORK_ORDER_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE1' THEN
       table_rec.SEQUENCE1:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE2' THEN
       table_rec.SEQUENCE2:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE3' THEN
       table_rec.SEQUENCE3:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE4' THEN
       table_rec.SEQUENCE4:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE5' THEN
       table_rec.SEQUENCE5:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE6' THEN
       table_rec.SEQUENCE6:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE7' THEN
       table_rec.SEQUENCE7:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE8' THEN
       table_rec.SEQUENCE8:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE9' THEN
       table_rec.SEQUENCE9:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE10' THEN
       table_rec.SEQUENCE10:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE11' THEN
       table_rec.SEQUENCE11:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE12' THEN
       table_rec.SEQUENCE12:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE13' THEN
       table_rec.SEQUENCE13:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE14' THEN
       table_rec.SEQUENCE14:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'SEQUENCE15' THEN
       table_rec.SEQUENCE15:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'PARTY_ID' THEN
       table_rec.PARTY_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'COMMENT1' THEN
       table_rec.COMMENT1:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMMENT2' THEN
       table_rec.COMMENT2:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMMENT3' THEN
       table_rec.COMMENT3:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMMENT4' THEN
       table_rec.COMMENT4:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'COMMENT5' THEN
       table_rec.COMMENT5:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'CONTRACT_ID' THEN
       table_rec.CONTRACT_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'CONTRACT_LINE_ID' THEN
       table_rec.CONTRACT_LINE_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'DELIVERABLE_ID' THEN
       table_rec.DELIVERABLE_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'CSI_INSTANCE_ID' THEN
       table_rec.CSI_INSTANCE_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'COUNTER_ID' THEN
       table_rec.COUNTER_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'COUNTER_READING_ID' THEN
       table_rec.COUNTER_READING_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'AHL_MR_ID' THEN
       table_rec.AHL_MR_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'CS_INCIDENT_ID' THEN
       table_rec.CS_INCIDENT_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'WIP_REWORK_ID' THEN
       table_rec.WIP_REWORK_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'DISPOSITION_SOURCE' THEN
       table_rec.DISPOSITION_SOURCE:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'DISPOSITION' THEN
       table_rec.DISPOSITION:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'DISPOSITION_ACTION' THEN
       table_rec.DISPOSITION_ACTION:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'DISPOSITION_STATUS' THEN
       table_rec.DISPOSITION_STATUS:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'MAINTENANCE_OP_SEQ' THEN
       table_rec.MAINTENANCE_OP_SEQ:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'BILL_REFERENCE_ID' THEN
       table_rec.BILL_REFERENCE_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'ROUTING_REFERENCE_ID' THEN
       table_rec.ROUTING_REFERENCE_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'CONCURRENT_REQUEST_ID' THEN
       table_rec.CONCURRENT_REQUEST_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'TO_SUBINVENTORY' THEN
       table_rec.TO_SUBINVENTORY:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'TO_LOCATOR_ID' THEN
       table_rec.TO_LOCATOR_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'LOT_STATUS_ID' THEN
       table_rec.LOT_STATUS_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'SERIAL_STATUS_ID' THEN
       table_rec.SERIAL_STATUS_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'NONCONFORMANCE_SOURCE' THEN
       table_rec.NONCONFORMANCE_SOURCE:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'NONCONFORM_SEVERITY' THEN
       table_rec.NONCONFORM_SEVERITY:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'NONCONFORM_PRIORITY' THEN
       table_rec.NONCONFORM_PRIORITY:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'NONCONFORMANCE_TYPE' THEN
       table_rec.NONCONFORMANCE_TYPE:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'NONCONFORMANCE_CODE' THEN
       table_rec.NONCONFORMANCE_CODE:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'NONCONFORMANCE_STATUS' THEN
       table_rec.NONCONFORMANCE_STATUS:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'DATE_OPENED' THEN
       table_rec.DATE_OPENED:=qltdate.any_to_date(return_value);
    END IF;

    IF X_COL_NAME = 'DATE_CLOSED' THEN
       table_rec.DATE_CLOSED:=qltdate.any_to_date(return_value);
    END IF;

    IF X_COL_NAME = 'DAYS_TO_CLOSE' THEN
       table_rec.DAYS_TO_CLOSE:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'RCV_TRANSACTION_ID' THEN
       table_rec.RCV_TRANSACTION_ID:=to_number(return_value);
    END IF;

    IF X_COL_NAME = 'REQUEST_SOURCE' THEN
       table_rec.REQUEST_SOURCE:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'REQUEST_PRIORITY' THEN
       table_rec.REQUEST_PRIORITY:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'REQUEST_SEVERITY' THEN
       table_rec.REQUEST_SEVERITY:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'REQUEST_STATUS' THEN
       table_rec.REQUEST_STATUS:=to_char(return_value);
    END IF;

    IF X_COL_NAME = 'ECO_NAME' THEN
       table_rec.ECO_NAME:=to_char(return_value);
    END IF;

  END set_value;
  -- End of Bug 7491253

 END qltninrb;


/
