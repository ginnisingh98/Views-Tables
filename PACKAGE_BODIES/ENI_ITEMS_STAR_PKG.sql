--------------------------------------------------------
--  DDL for Package Body ENI_ITEMS_STAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_ITEMS_STAR_PKG" AS
/* $Header: ENIIDBCB.pls 120.11 2007/03/13 08:50:19 lparihar ship $  */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ENI_ITEMS_STAR_PKG';

--5688257 : %Items_In_Star functions to use flex API's to get concatenated segments
G_INSTALL_PHASE     NUMBER := 0;

--G_SYNC_STAR_ITEMS VARCHAR2(15) := 'NOT_CHECKED';

--**************************************************
-- Creates De-normalized Item STAR table
--**************************************************

PROCEDURE Create_Star_Table(errbuf out NOCOPY varchar2, retcode out NOCOPY varchar2)
IS

CURSOR get_po_catset IS
 SELECT category_set_id
 FROM mtl_default_category_sets
 WHERE functional_area_id = 2;

CURSOR c IS
 SELECT category_set_id
 FROM mtl_default_category_sets
 WHERE functional_area_id = 1;

CURSOR c_mult_item_assgn(l_inv_category_set NUMBER, l_vbh_category_set NUMBER, l_po_category_set NUMBER)
IS
 SELECT
    cat.inventory_item_id,
    cat.organization_id,
    cat.category_set_id,
    mti.concatenated_segments,
    -- mtp.organization_code,
    COUNT(category_id)
  FROM
    mtl_system_items_kfv mti,
    -- mtl_parameters mtp,
    mtl_item_categories cat
  WHERE
    mti.inventory_item_id = cat.inventory_item_id      AND
    mti.organization_id = cat.organization_id      AND
    -- mtp.organization_id = mti.organization_id AND
    category_set_id IN (l_vbh_category_set, l_inv_category_set, l_po_category_set)
  GROUP BY
    cat.category_set_id,
    cat.inventory_item_id,
    cat.organization_id,
    mti.concatenated_segments
    -- mtp.organization_code
 HAVING COUNT(category_id) > 1;

-- Cursor to figure out the items having same name with diff. ids
CURSOR c_mult_item IS
  SELECT
    mti.concatenated_segments,
    mti.organization_id,
    COUNT(mti.inventory_item_id)
  FROM
    mtl_system_items_kfv mti
  GROUP BY
     mti.concatenated_segments,
     mti.organization_id
  HAVING COUNT(inventory_item_id) > 1;

-- This cursor is dependent on cursor c_mult_item. This
-- will only print out the item ids that have the same name
CURSOR c_item_id(l_name varchar2) IS
  SELECT
    inventory_item_id,
    organization_id
  FROM
    mtl_system_items_kfv
  WHERE
    concatenated_segments = l_name;

CURSOR c_non_flex_item IS
  SELECT
    count(mti.inventory_item_id),
    mti.organization_id,
    mti.concatenated_segments
  FROM
    mtl_system_items_kfv mti
  WHERE
    mti.concatenated_segments = 'X'
  GROUP BY mti.concatenated_segments, mti.organization_id
  HAVING count(inventory_item_id) > 1;

l_inv_category_set  NUMBER;
l_vbh_category_set  NUMBER;
l_po_category_set   NUMBER;
l_prev_po_catset    NUMBER;
l_record_count      NUMBER;
l_dummy             NUMBER;
l_table_schema      VARCHAR2(4) ;
l_batch_size        NUMBER ;
l_rows_inserted     NUMBER;  -- Bug#2662318 --
l_temp              VARCHAR2(1);
l_top_node          NUMBER;
l_exist_flag        VARCHAR2(240);
l_errors            NUMBER;
l_unique_viol       NUMBER;
l_prev_inv_catset   NUMBER;
l_prev_vbh_catset   NUMBER;
l_full_refresh      VARCHAR2(1);
l_schema            VARCHAR2(10);

snp_not_found       EXCEPTION;
PRAGMA   EXCEPTION_INIT(snp_not_found, -12002);

type recstartyp is table of ENI_OLTP_ITEM_STAR%ROWTYPE;
item_star_record     recstartyp;

unique_cons_violation EXCEPTION;
PRAGMA EXCEPTION_INIT(unique_cons_violation,-1);

BEGIN

  l_dummy :=0;
  l_rows_inserted := 0;
  l_schema := 'ENI';

  If BIS_COLLECTION_UTILITIES.SETUP(p_object_name => 'ENI_OLTP_ITEM_STAR')=false then
    RAISE_APPLICATION_ERROR(-20000,errbuf);
  End if;

  -- Calculating batchsize
  -- BIS_COLLECTION_UTILITIES.log('Push Size: '||to_char(FND_PROFILE.value('EDW_PUSH_SIZE')));
  -- BIS_COLLECTION_UTILITIES.log('Complexity: '||to_char(BIS_COMMON_PARAMETERS.MEDIUM));

  -- Setting hash_area_size and sort_area_size for this session
  BIS_COLLECTION_UTILITIES.log('Altering hash area and sort area size ');

  EXECUTE IMMEDIATE 'alter session set hash_area_size = 200000000';
  EXECUTE IMMEDIATE 'alter session set sort_area_size = 50000000';

  BIS_COLLECTION_UTILITIES.log('Fetching default INV category set...');
  OPEN c;
  FETCH c into l_inv_category_set;
  IF c%NOTFOUND THEN l_inv_category_set := null; END IF;
  CLOSE c;

  BIS_COLLECTION_UTILITIES.log('Fetching VBH category set...');
  l_vbh_category_set := ENI_DENORM_HRCHY.get_category_set_id;

  BIS_COLLECTION_UTILITIES.log('Fetching PO category set...');
  OPEN get_po_catset;
  FETCH get_po_catset INTO l_po_category_set;
  CLOSE get_po_catset;

  BIS_COLLECTION_UTILITIES.log('Default category sets are:' );
  BIS_COLLECTION_UTILITIES.log('      Product    functional area ==> ' || to_char(l_vbh_category_set));
  BIS_COLLECTION_UTILITIES.log('      Inventory  functional area ==> ' || to_char(l_inv_category_set));
  BIS_COLLECTION_UTILITIES.log('      Purchasing functional area ==> ' || to_char(l_po_category_set));

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.ENI_ITEM_STAR_VALID_ERR';

  BIS_COLLECTION_UTILITIES.log('');
  BIS_COLLECTION_UTILITIES.log('Validation Checks');
  BIS_COLLECTION_UTILITIES.log('----------------------');
  BIS_COLLECTION_UTILITIES.log('');
  BIS_COLLECTION_UTILITIES.log('');


  l_temp := 'N';

  BIS_COLLECTION_UTILITIES.log('----------------------------------------------');
  BIS_COLLECTION_UTILITIES.log('Checking for multiple item-category assignment');
  BIS_COLLECTION_UTILITIES.log('----------------------------------------------');

  FOR c2 in c_mult_item_assgn(l_inv_category_set, l_vbh_category_set, l_po_category_set)
  LOOP
    l_temp := 'Y';

    BIS_COLLECTION_UTILITIES.log(c2.concatenated_segments);
    retcode := 1;

    INSERT INTO ENI_ITEM_STAR_VALID_ERR(
      inventory_item_id,
      organization_id,
      item_name,
      category_set_id,
      error_message)
    VALUES(
      c2.inventory_item_id,
      c2.organization_id,
      c2.concatenated_segments,
      -- c2.organization_code,
      c2.category_set_id,
      'ITEMS WITH MULTIPLE CATEGORY ASSIGNMENT'
     );
  END LOOP;

  if l_temp = 'N' then
     BIS_COLLECTION_UTILITIES.log(' -- No issues found -- ');
  else
     BIS_COLLECTION_UTILITIES.log('Suggestion: Items can only be assigned to one category');
     BIS_COLLECTION_UTILITIES.log('in the default catalog of Inventory, PO and/ or Product reporting');
     BIS_COLLECTION_UTILITIES.log('functional area. Please ensure that this criteria is met');
     BIS_COLLECTION_UTILITIES.log('for the items failing this test.');
  end if;


  l_temp := 'N';

  BIS_COLLECTION_UTILITIES.log('');
  BIS_COLLECTION_UTILITIES.log('--------------------------------------------');
  BIS_COLLECTION_UTILITIES.log('Checking if item flexfield has been compiled');
  BIS_COLLECTION_UTILITIES.log('--------------------------------------------');

  FOR c3 in c_non_flex_item LOOP
    l_temp := 'Y';
    BIS_COLLECTION_UTILITIES.log('Item Flexfield has not been compiled. ');
  END LOOP;

  if l_temp = 'N' then
     BIS_COLLECTION_UTILITIES.log(' -- No issues found -- ');
  else
    BIS_COLLECTION_UTILITIES.log('Please compile item flexfield and then run the item dimension load');
    RAISE_APPLICATION_ERROR(-20001, 'ERROR: Item flexfield has not been compiled');
  end if;


  l_temp := 'N';
  BIS_COLLECTION_UTILITIES.log('');
  BIS_COLLECTION_UTILITIES.log('----------------------------------------------');
  BIS_COLLECTION_UTILITIES.log('Checking for multiple items with the same name');
  BIS_COLLECTION_UTILITIES.log('----------------------------------------------');

  FOR c4 in c_mult_item LOOP
    l_temp := 'Y';

    BIS_COLLECTION_UTILITIES.log(c4.concatenated_segments);
    retcode := 1;

    FOR c5 in c_item_id(c4.concatenated_segments) LOOP

      INSERT INTO ENI_ITEM_STAR_VALID_ERR(
        inventory_item_id,
        organization_id,
        item_name,
        error_message)
      VALUES(
        c5.inventory_item_id,
        c5.organization_id,
        c4.concatenated_segments,
        'MULTIPLE ITEMS WITH SAME NAME'
       );
    END LOOP;
  END LOOP;

  if l_temp = 'N' then
     BIS_COLLECTION_UTILITIES.log(' -- No issues found -- ');
  else
     BIS_COLLECTION_UTILITIES.log('Suggestion: Item names need to be unique. Ensure the ');
     BIS_COLLECTION_UTILITIES.log('item names that failed the test are unique in the system. ');
  end if;


  -- Deciding if the load has to be fully refreshed or partially refreshed
  -- Full refresh it if:
  --   1. STAR table is empty
  --   2. Default category set of INV and VBH functional area has changed

  BEGIN
    -- Added for Bug 4747510
   SELECT vbh_category_set_id, inv_category_set_id, po_category_set_id
     INTO l_prev_vbh_catset, l_prev_inv_catset, l_prev_po_catset
     FROM eni_oltp_item_star
    WHERE inventory_item_id = -1
     AND organization_id = -99
     AND rownum = 1;

    SELECT vbh_category_set_id, inv_category_set_id, po_category_set_id
      INTO l_prev_vbh_catset, l_prev_inv_catset, l_prev_po_catset
      FROM eni_oltp_item_star
     WHERE inventory_item_id <> -1
      AND organization_id <> -99
      AND rownum = 1;

   IF (l_prev_vbh_catset    <> l_vbh_category_set OR
       l_prev_inv_catset    <> l_inv_category_set OR
   NVL(l_prev_po_catset,-1) <> l_po_category_set)    THEN
      l_full_refresh := 'Y';
   ELSE
      l_full_refresh := 'N';
   END IF;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_full_refresh := 'Y';

   END;

   IF l_full_refresh = 'Y' THEN

    BIS_COLLECTION_UTILITIES.log('');
    BIS_COLLECTION_UTILITIES.log('Running in full mode');
    BIS_COLLECTION_UTILITIES.log('--------------------');
    BIS_COLLECTION_UTILITIES.log('');
    BIS_COLLECTION_UTILITIES.log('Clearing STAR table');
    BIS_COLLECTION_UTILITIES.log('--------------------');

    EXECUTE IMMEDIATE 'truncate table ' || l_schema || '.eni_oltp_item_star purge materialized view log';

    BIS_COLLECTION_UTILITIES.log('Inserting UNASSIGNED row into STAR table');

    INSERT INTO ENI_OLTP_ITEM_STAR (
        id
      , value
      , organization_code
      , inventory_item_id
      , organization_id
      , po_category_id
      , po_category_set_id
      , po_concat_seg
      , inv_category_id
      , inv_category_set_id
      , inv_concat_seg
      , vbh_category_id
      , vbh_category_set_id
      , vbh_concat_seg
      , master_id
      , creation_date
      , last_update_date
      , item_catalog_group_id
      , primary_uom_code
      , unit_weight
      , unit_volume
      , weight_uom_code
      , volume_uom_code
      , eam_item_type
        )
      VALUES ('-1--99',
        'Product not specified',
        NULL,
        -1,
        -99,
        -1,
        l_po_category_set,
        'Unassigned',
        -1,
        l_inv_category_set,
        'Unassigned',
        -1,
        l_vbh_category_set,
        'Unassigned',
        NULL,
        SYSDATE,
        SYSDATE,
        -1,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
        );

    BIS_COLLECTION_UTILITIES.log('Inserted UNASSIGNED item row');

    COMMIT;

    BEGIN
        -- Main insert of items

        BIS_COLLECTION_UTILITIES.log('Inserting all ITEM MASTER items into STAR table');

        INSERT /*+ append parallel */ INTO ENI_OLTP_ITEM_STAR (
        id
        , value
        , organization_code
        , inventory_item_id
        , organization_id
        , po_category_id
        , po_category_set_id
        , po_concat_seg
        , inv_category_id
        , inv_category_set_id
        , inv_concat_seg
        , vbh_category_id
        , vbh_category_set_id
        , vbh_concat_seg
        , master_id
        , creation_date
        , last_update_date
        , item_catalog_group_id
        , primary_uom_code
        , unit_weight
        , unit_volume
        , weight_uom_code
        , volume_uom_code
        , eam_item_type
        )
        SELECT  /*+ ordered parallel(mti) parallel(mic) parallel(mic1) */
        mti.inventory_item_id || '-' || mti.organization_id id,
        mti.CONCATENATED_SEGMENTS || ' (' || mtp.organization_code || ')' value,
        null organization_code,
        mti.inventory_item_id inventory_item_id,
        mti.organization_id organization_id,
        Nvl(mic2.category_id,-1) po_category_id,
        Nvl(mic2.category_set_id, l_po_category_set) po_category_set_id,
        Nvl(kfv2.concatenated_segments,'Unassigned') po_concat_seg,
        nvl(mic.category_id,-1) inv_category_id,
        nvl(mic.category_Set_id,l_inv_category_set) inv_category_Set_id,
        nvl(kfv.concatenated_segments,'Unassigned') inv_concat_seg,
        nvl(mic1.category_id, -1) vbh_category_id,
        nvl(mic1.category_set_id, l_vbh_category_set) vbh_category_set_id,
        nvl(kfv1.concatenated_segments, 'Unassigned') vbh_concat_seg,
        decode(mti.organization_id,mtp.master_organization_id,null,
              mti.inventory_item_id || '-' || mtp.master_organization_id)
        master_id,
        mti.creation_date creation_date,
        mti.last_update_date last_update_date,
        nvl(mti.item_catalog_group_id,-1) item_catalog_group_id,
        mti.primary_uom_code,
        mti.unit_weight,
        mti.unit_volume,
        mti.weight_uom_code,
        mti.volume_uom_code,
        mti.eam_item_type
        FROM mtl_system_items_b_kfv mti,
                mtl_parameters mtp,
                mtl_item_categories mic  ,
                mtl_item_categories mic1 ,
                mtl_item_categories mic2 ,
                mtl_categories_b_kfv kfv ,
                mtl_categories_b_kfv kfv1,
                mtl_categories_b_kfv kfv2
        WHERE  mtp.organization_id=mti.organization_id
        AND mic.organization_id(+) = mti.organization_id
        AND mic.inventory_item_id(+) = mti.inventory_item_id
        AND mic.category_id  = kfv.category_id (+)
        and mic.category_set_id(+) = l_inv_category_set
        AND mic1.organization_id(+) = mti.organization_id
        AND mic1.inventory_item_id(+) = mti.inventory_item_id
        AND mic1.category_id  = kfv1.category_id (+)
        and mic1.category_set_id(+) = l_vbh_category_set
        AND mic2.organization_id(+) = mti.organization_id
        AND mic2.inventory_item_id(+) = mti.inventory_item_id
        AND mic2.category_id  = kfv2.category_id (+)
        and mic2.category_set_id(+) = l_po_category_set
                AND NOT EXISTS(select 'X' from eni_item_star_valid_err
                        WHERE inventory_item_id = mti.inventory_item_id
                          AND organization_id = mti.organization_id);

        l_rows_inserted := sql%rowcount;

        BIS_COLLECTION_UTILITIES.log('Rows inserted into table:'||l_rows_inserted);

        COMMIT; --Added for Bug 4525918

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
      WHEN OTHERS THEN
        BIS_COLLECTION_UTILITIES.log(sqlerrm);
        -- Delete UNASSIGNED row as the main insert of items was not successful.
        DELETE FROM ENI_OLTP_ITEM_STAR WHERE inventory_item_id = -1 AND organization_id = -99;
        BIS_COLLECTION_UTILITIES.log('Removed UNASSIGNED row as main insert of items was not successful');
        COMMIT;
    END;


    -- If records exist in the temporary table it means that
    -- some records got updated from the API calls during the main insert.
    -- Update those records from the temporary table to the STAR table

    begin

      BIS_COLLECTION_UTILITIES.log(' Checking Temp table for any records ');
        select 1 into l_exist_flag from eni_item_star_temp
       where rownum = 1;

      if l_exist_flag = 1 then
        BIS_COLLECTION_UTILITIES.log('Updating STAR table with records from temp table');

        UPDATE eni_oltp_item_star a
          SET ( value
              , last_update_date
              , po_category_set_id
              , po_category_id
              , po_concat_seg
              , inv_category_set_id
              , inv_category_id
              , inv_concat_seg
              , vbh_category_set_id
              , vbh_category_id
              , vbh_concat_seg
              , item_catalog_group_id
              , primary_uom_code
              , unit_weight
              , unit_volume
              , weight_uom_code
              , volume_uom_code
              , eam_item_type
              )=
              ( SELECT
                     nvl(value, a.value)
                   , nvl(last_update_date, a.last_update_date)
                   , nvl(po_category_set_id, a.po_category_set_id)
                   , nvl(po_category_id, a.po_category_id)
                   , nvl(po_concat_seg, a.po_concat_seg)
                   , nvl(inv_category_set_id, a.inv_category_set_id)
                   , nvl(inv_category_id, a.inv_category_id)
                   , nvl(inv_concat_seg, a.inv_concat_seg)
                   , nvl(vbh_category_set_id, a.vbh_category_set_id)
                   , nvl(vbh_category_id, a.vbh_category_id)
                   , nvl(vbh_concat_seg, a.vbh_concat_seg)
                   , nvl(item_catalog_group_id, a.item_catalog_group_id)
                   , nvl(primary_uom_code, a.primary_uom_code)
                   , nvl(unit_weight, a.unit_weight)
                   , nvl(unit_volume, a.unit_volume)
                   , nvl(weight_uom_code, a.weight_uom_code)
                   , nvl(volume_uom_code, a.volume_uom_code)
                   , nvl(eam_item_type, a.eam_item_type)
                FROM eni_item_star_temp
                WHERE a.inventory_item_id = inventory_item_id
                AND a.organization_id = organization_id )
          WHERE EXISTS( SELECT 'X' from eni_item_star_temp
                        WHERE a.inventory_item_id = inventory_item_id
                        AND a.organization_id = organization_id );

      BIS_COLLECTION_UTILITIES.log('Rows updated from temp table:'||sql%rowcount);

      BIS_COLLECTION_UTILITIES.log('Deleting from the temp table');
      DELETE FROM eni_item_star_temp;

    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         null;
      WHEN OTHERS THEN
         BIS_COLLECTION_UTILITIES.log(sqlerrm);
    END;

  END IF; -- l_full_refresh = 'Y'

  IF l_full_refresh = 'N' THEN
     BIS_COLLECTION_UTILITIES.log('');
     BIS_COLLECTION_UTILITIES.log('Running in partial mode');
     BIS_COLLECTION_UTILITIES.log('-----------------------');
     BIS_COLLECTION_UTILITIES.log('');

     INSERT INTO eni_oltp_item_star (
          id
        , value
        , inventory_item_id
        , organization_id
        , po_category_id
        , po_category_set_id
        , po_concat_seg
        , inv_category_id
        , inv_category_set_id
        , inv_concat_seg
        , vbh_category_id
        , vbh_category_set_id
        , vbh_concat_seg
        , master_id
        , item_catalog_group_id
        , primary_uom_code
        , unit_weight
        , unit_volume
        , weight_uom_code
        , volume_uom_code
        , eam_item_type
        , creation_date
        , last_update_date
        )
     SELECT
        mti.inventory_item_id || '-' || mti.organization_id,
        mti.concatenated_segments || '(' || mtp.organization_code || ')',
        mti.inventory_item_id,
        mti.organization_id,
        nvl(mic2.category_id, -1) po_category_id,
        nvl(mic2.category_set_id, l_po_category_set) po_category_set_id,
        nvl(kfv2.concatenated_segments, 'Unassigned') po_concat_seg,
        nvl(mic.category_id,-1) inv_category_id,
        nvl(mic.category_set_id, l_inv_category_set) inv_category_set_id,
        nvl(kfv.concatenated_segments,'Unassigned') inv_concat_seg,
        nvl(mic1.category_id, -1) vbh_category_id,
        nvl(mic1.category_set_id, l_vbh_category_set) vbh_category_set_id,
        nvl(kfv1.concatenated_segments, 'Unassigned') vbh_concat_seg,
        decode(mti.organization_id,mtp.master_organization_id,null,
                mti.inventory_item_id || '-' || mtp.master_organization_id)
         master_id,
        nvl(item_catalog_group_id,-1) item_catalog_group_id,
        mti.primary_uom_code,
        mti.unit_weight,
        mti.unit_volume,
        mti.weight_uom_code,
        mti.volume_uom_code,
        mti.eam_item_type,
        mti.creation_date,
        mti.last_update_date
     FROM
        mtl_system_items_b_kfv mti,
        mtl_parameters mtp,
        mtl_item_categories mic,
        mtl_item_categories mic1,
        mtl_item_categories mic2,
        mtl_categories_b_kfv kfv,
        mtl_categories_b_kfv kfv1,
        mtl_categories_b_kfv kfv2
     WHERE
        mtp.organization_id = mti.organization_id AND
        mic.organization_id(+) = mti.organization_id AND
        mic.inventory_item_id(+) = mti.inventory_item_id AND
        mic.category_id = kfv.category_id(+) AND
        mic.category_set_id(+) = l_inv_category_set AND
        mic1.organization_id(+) = mti.organization_id AND
        mic1.inventory_item_id(+) = mti.inventory_item_id AND
        mic1.category_id = kfv1.category_id(+) AND
        mic1.category_set_id(+) = l_vbh_category_set AND
        mic2.organization_id(+) = mti.organization_id AND
        mic2.inventory_item_id(+) = mti.inventory_item_id AND
        mic2.category_id  = kfv2.category_id (+)  AND
        mic2.category_set_id(+) = l_po_category_set AND
        NOT EXISTS(SELECT 'X' FROM eni_oltp_item_star eni
                    WHERE mti.inventory_item_id = eni.inventory_item_id
                      AND mti.organization_id = eni.organization_id) AND
        NOT EXISTS(SELECT 'X' FROM eni_item_star_valid_err err
                    WHERE mti.inventory_item_id = err.inventory_item_id
                      AND mti.organization_id = err.organization_id
                  );

    l_rows_inserted := SQL%ROWCOUNT;

    BIS_COLLECTION_UTILITIES.log('Records inserted into STAR table: '|| l_rows_inserted);

  END IF; -- if l_full_refresh = 'N'

  BIS_COLLECTION_UTILITIES.log('Collection completed successfully.');

  BIS_COLLECTION_UTILITIES.log('Gathering statistics on table: ENI_OLTP_ITEM_STAR ');
  FND_STATS.gather_table_stats (ownname=>'ENI', tabname=>'ENI_OLTP_ITEM_STAR');

  Exception
  When no_data_found then
    BIS_COLLECTION_UTILITIES.log(sqlerrm);
    errbuf := 'Error: No Data Found';
    retcode := 2;
  When unique_cons_violation then
    BIS_COLLECTION_UTILITIES.log('Error: ' || sqlerrm );
    BIS_COLLECTION_UTILITIES.log('Could be for one of two possible reasons: ');
    BIS_COLLECTION_UTILITIES.log('1. Items cannot be assigned to multiple categories of a default category set');
    BIS_COLLECTION_UTILITIES.log('2. The item flexfields have not been compiled');
    errbuf := 'Error: ' || sqlerrm;
    --dbms_output.put_line('Items cannot be assigned to mul...');
    retcode := 2;
  When others then
    BIS_COLLECTION_UTILITIES.log(sqlerrm);
    --dbms_output.put_line('Error '|| sqlerrm);
    errbuf := 'Error: ' || sqlerrm;
    retcode := 2;
END Create_Star_Table;


--**********************************************************************
-- Check if STAR table should be synchronized with Item Master when there
-- are Item Master Updates.
--**********************************************************************
FUNCTION Sync_Star_Items RETURN BOOLEAN IS
   l_sync_star_items VARCHAR2(10) := 'NO SYNC';
BEGIN

   -- If we've already performed this check within this session,
   -- just return the cached result
   -- IF G_SYNC_STAR_ITEMS = 'SYNC' THEN RETURN true;
   -- ELSIF G_SYNC_STAR_ITEMS = 'NO_SYNC' THEN RETURN false;
   -- END IF;

   -- Check if UNASSIGNED row exists
   SELECT 'SYNC'
   INTO l_sync_star_items
   FROM eni_oltp_item_star
   WHERE inventory_item_id = -1
   AND organization_id = -99;

   -- Cache the result of the above UNASSIGNED row check for the session
   --G_SYNC_STAR_ITEMS := 'SYNC';
   RETURN true;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- Cache the result of the above UNASSIGNED row check for the session
      --G_SYNC_STAR_ITEMS := 'NO_SYNC';
      RETURN false;

END Sync_Star_Items;



--**********************************************************************
-- Maintain STAR table when changes are detected on MTL_SYSTEM_ITEMS
--**********************************************************************

--Start :5688257 : %Items_In_Star functions to use flex API's to get concatenated segments
FUNCTION Get_Item_Number(P_Inventory_Item_Id   MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE
                        ,P_Organization_Id     MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE)
RETURN VARCHAR2 IS
   l_delimiter        VARCHAR2(10);
   l_segs             FND_FLEX_EXT.SegmentArray;
   l_n_segs           NUMBER;
   l_item_exist       BOOLEAN;
   l_concat_segs      VARCHAR2(1000);


BEGIN
   -- Get delimiter
   l_delimiter := fnd_flex_ext.get_delimiter(application_short_name => 'INV'
					    ,key_flex_code          => 'MSTK'
       					    ,structure_number       => 101);
   -- Get segments
   l_item_exist := fnd_flex_ext.get_segments(application_short_name => 'INV'
                                            ,key_flex_code          => 'MSTK'
                                            ,structure_number       => 101
                                            ,combination_id         => P_Inventory_Item_Id
                                            ,n_segments             => l_n_segs
                                            ,segments               => l_segs
                                            ,data_set               => P_Organization_Id);
  -- Get concatenated segments
  IF l_item_exist THEN
     l_concat_segs := fnd_flex_ext.concatenate_segments(n_segments => l_n_segs
	                                               ,segments   => l_segs
				                       ,delimiter  => l_delimiter);
  END IF;

  RETURN l_concat_segs;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'ENI_ITEMS_STAR_PKG.GET_CONCAT_SEGS', SQLERRM);
      END IF;
      RAISE;
END Get_Item_Number;
--End   :5688257 : %Items_In_Star functions to use flex API's to get concatenated segments

PROCEDURE Insert_Items_In_Star( p_api_version NUMBER
                              , p_init_msg_list VARCHAR2 := 'F'
                              , p_inventory_item_id NUMBER
                              , p_organization_id NUMBER
                              , x_return_status OUT NOCOPY VARCHAR2
                              , x_msg_count OUT NOCOPY NUMBER
                              , x_msg_data OUT NOCOPY VARCHAR2 )
IS
CURSOR get_po_catset IS
 SELECT category_set_id
 FROM mtl_default_category_sets
 WHERE functional_area_id = 2;

CURSOR category_rec IS
 SELECT category_set_id
 FROM mtl_default_category_sets
 WHERE functional_area_id = 1;

l_inv_category_set NUMBER;
l_vbh_category_set NUMBER;
l_po_category_set  NUMBER;
l_item_number      VARCHAR2(1000);
BEGIN

  -- Check if this synchronization should happen; if no, exit; if yes, continue
  if Sync_Star_Items = false then
     X_RETURN_STATUS := 'S';
     return;
  end if;

  OPEN category_rec;
  FETCH category_rec into l_inv_category_set;

  IF category_rec%NOTFOUND THEN
    l_inv_category_set := null;
  END IF;
  CLOSE category_rec;

  l_vbh_category_set := ENI_DENORM_HRCHY.get_category_set_id;

  OPEN get_po_catset;
  FETCH get_po_catset INTO l_po_category_set;
  CLOSE get_po_catset;

  --5688257 : %Items_In_Star functions to use flex API's to get concatenated segments
  IF G_INSTALL_PHASE = 0 THEN
    l_item_number := Get_Item_Number(P_Inventory_Item_Id => p_inventory_item_id
                                    ,P_Organization_Id   => p_organization_id);
  END IF;

  -- Insert Item

     --dbms_output.put_line('Inserting into table...');
     INSERT INTO ENI_OLTP_ITEM_STAR (
        id
        , value
        , inventory_item_id
        , organization_id
        , master_id
        , item_catalog_group_id
        , primary_uom_code
        , unit_weight
        , unit_volume
        , weight_uom_code
        , volume_uom_code
        , eam_item_type
        , po_category_id
        , po_category_set_id
        , po_concat_seg
        , inv_category_id
        , inv_category_set_id
        , inv_concat_seg
        , vbh_category_id
        , vbh_category_set_id
        , vbh_concat_seg
        , creation_date
        , last_update_date
        )
     SELECT
        mti.inventory_item_id || '-' || mti.organization_id,
        DECODE(TO_CHAR(G_INSTALL_PHASE),'0',l_item_number || ' (' || mtp.organization_code || ')',mti.concatenated_segments || ' (' || mtp.organization_code || ')'),
        mti.inventory_item_id,
        mti.organization_id,
        decode( mti.organization_id,mtp.master_organization_id, null,
                mti.inventory_item_id || '-' || mtp.master_organization_id ),
        nvl(mti.item_catalog_group_id,-1),
        mti.primary_uom_code,
        mti.unit_weight,
        mti.unit_volume,
        mti.weight_uom_code,
        mti.volume_uom_code,
        mti.eam_item_type,
        -1,
        l_po_category_set,
        'Unassigned',
        -1,
        l_inv_category_set,
        'Unassigned',
        -1,
        l_vbh_category_set,
        'Unassigned',
        mti.creation_date,
        mti.last_update_date
     FROM mtl_system_items_b_kfv mti,
          mtl_parameters mtp
     WHERE mti.inventory_item_id = p_inventory_item_id
       AND mti.organization_id = p_organization_id
       AND mti.organization_id= mtp.organization_id;

      X_RETURN_STATUS := 'S';

EXCEPTION
      WHEN OTHERS THEN
          X_RETURN_STATUS := 'U';
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'INSERT_ITEMS_IN_STAR', SQLERRM);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);

END Insert_Items_In_Star;

PROCEDURE Delete_Items_In_Star( p_api_version NUMBER
                              , p_init_msg_list VARCHAR2 := 'F'
                              , p_inventory_item_id NUMBER
                              , p_organization_id NUMBER
                              , x_return_status OUT NOCOPY VARCHAR2
                              , x_msg_count OUT NOCOPY NUMBER
                              , x_msg_data OUT NOCOPY VARCHAR2 )
IS
BEGIN

  -- Delete Item

     DELETE FROM ENI_OLTP_ITEM_STAR
     WHERE inventory_item_id = p_inventory_item_id
       AND organization_id = p_organization_id;

      X_RETURN_STATUS := 'S';

EXCEPTION
      WHEN OTHERS THEN
          X_RETURN_STATUS := 'U';
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'DELETE_ITEMS_IN_STAR', SQLERRM);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);

END Delete_Items_In_Star;


-- Contains Bug fix 4173443.
/* If organization is master then update items in master org & child org
   with entries from MSIB. If the organization is child org then
   update all the attributes in Items_star with entries in MISB.
   We don't have to find out if the attributes are master controlled or
   org controlled as Items takes care of this.
*/

PROCEDURE Update_Items_In_Star( p_api_version       NUMBER
                              , p_init_msg_list     VARCHAR2 := 'F'
                              , p_inventory_item_id NUMBER
                              , p_organization_id   NUMBER
                              , x_return_status     OUT NOCOPY VARCHAR2
                              , x_msg_count         OUT NOCOPY NUMBER
                              , x_msg_data          OUT NOCOPY VARCHAR2 )
IS
   -- updates to master-level attributes must capture the resulting propagations to child orgs
   CURSOR c_items_in_master IS
      SELECT    mti.concatenated_segments || ' (' || b.organization_code || ')' value
              , b.organization_code
              , b.organization_id
              , mti.last_update_date
              , nvl(mti.item_catalog_group_id,-1) item_catalog_group_id
              , mti.primary_uom_code
              ,mti.unit_weight
              ,mti.unit_volume
              ,mti.weight_uom_code
              ,mti.volume_uom_code
              ,mti.eam_item_type
      FROM    mtl_system_items_b_kfv mti
            , mtl_parameters b
      WHERE   mti.inventory_item_id    = p_inventory_item_id
        AND   mti.organization_id      = b.organization_id
        AND   b.master_organization_id = p_organization_id;
    -- updates to child-org-level attributes are confined to that organization

    CURSOR c_items_in_child IS
        SELECT  mti.organization_id
              , mti.unit_weight
              , mti.unit_volume
              , mti.weight_uom_code
              , mti.volume_uom_code
              , primary_uom_code
              , eam_item_type
              , mti.last_update_date
        FROM    mtl_system_items_b mti
        WHERE   mti.inventory_item_id    = p_inventory_item_id
            AND mti.organization_id      = p_organization_id;

   isMasterOrg        NUMBER;
   l_item_number      VARCHAR2(1000);
BEGIN

   -- Check if this synchronization should happen; if no, exit; if yes, continue
   if Sync_Star_Items = false then
      X_RETURN_STATUS := 'S';
      return;
   end if;

   isMasterOrg := 0;

   SELECT COUNT(master_organization_id) INTO isMasterOrg
   FROM   mtl_parameters
   WHERE  master_organization_id = p_organization_id AND ROWNUM < 2;

   IF isMasterOrg = 1 THEN
      FOR c_items_in_master_rec IN c_items_in_master
      LOOP
	--5688257 : %Items_In_Star functions to use flex API's to get concatenated segments
	--FND API is caches the values..get_item_number should be used only during install phase.
	IF G_INSTALL_PHASE = 0 THEN
           l_item_number := Get_Item_Number(P_Inventory_Item_Id => p_inventory_item_id
                                           ,P_Organization_Id   => c_items_in_master_rec.organization_id);

           l_item_number := l_item_number || ' (' || c_items_in_master_rec.organization_code || ')';
	END IF;

        UPDATE ENI_OLTP_ITEM_STAR
           SET  VALUE                   = DECODE(TO_CHAR(G_INSTALL_PHASE),'0',l_item_number,c_items_in_master_rec.value)
              , ITEM_CATALOG_GROUP_ID   = c_items_in_master_rec.item_catalog_group_id
              , PRIMARY_UOM_CODE        = c_items_in_master_rec.primary_uom_code
              , LAST_UPDATE_DATE        = c_items_in_master_rec.last_update_date
              , UNIT_WEIGHT             = c_items_in_master_rec.unit_weight
              , UNIT_VOLUME             = c_items_in_master_rec.unit_volume
              , WEIGHT_UOM_CODE         = c_items_in_master_rec.weight_uom_code
              , VOLUME_UOM_CODE         = c_items_in_master_rec.volume_uom_code
              , EAM_ITEM_TYPE           = c_items_in_master_rec.eam_item_type
        WHERE  inventory_item_id        = p_inventory_item_id
        AND    organization_id          = c_items_in_master_rec.organization_id;

        -- The following block will only be called when an
        -- user updates an item when the load is running. Since
        -- the load truncates the table, the update will not go
        -- thru. So it is stored temporarily into a TEMP table.

        -- There is a separate insert and an update because the
        -- the user can modify the same item twice while the load
        -- is running. This would create duplicate records in the
        -- TEMP table. To avoid duplicacy there is a insert and an update.

        IF sql%rowcount = 0 THEN
           UPDATE eni_item_star_temp
             SET  VALUE                 = DECODE(TO_CHAR(G_INSTALL_PHASE),'0',l_item_number,c_items_in_master_rec.value)
                , LAST_UPDATE_DATE      = c_items_in_master_rec.last_update_date
                , ITEM_CATALOG_GROUP_ID = c_items_in_master_rec.item_catalog_group_id
                , PRIMARY_UOM_CODE      = c_items_in_master_rec.primary_uom_code
                , UNIT_WEIGHT           = c_items_in_master_rec.unit_weight
                , UNIT_VOLUME           = c_items_in_master_rec.unit_volume
                , WEIGHT_UOM_CODE       = c_items_in_master_rec.weight_uom_code
                , VOLUME_UOM_CODE       = c_items_in_master_rec.volume_uom_code
               , EAM_ITEM_TYPE          = c_items_in_master_rec.eam_item_type
           WHERE inventory_item_id      = p_inventory_item_id
             AND organization_id        = c_items_in_master_rec.organization_id;

           IF sql%rowcount = 0 THEN
              INSERT INTO eni_item_star_temp(
                   inventory_item_id
                 , organization_id
                 , value
                 , last_update_date
                 , item_catalog_group_id
                 , primary_uom_code
                 , unit_weight
                 , unit_volume
                 ,weight_uom_code
                 ,volume_uom_code
                 ,eam_item_type)
              VALUES(
                   p_inventory_item_id
                 , c_items_in_master_rec.organization_id
                 , DECODE(TO_CHAR(G_INSTALL_PHASE),'0',l_item_number,c_items_in_master_rec.value)
                 , c_items_in_master_rec.last_update_date
                 , c_items_in_master_rec.item_catalog_group_id
                 , c_items_in_master_rec.primary_uom_code
                 , c_items_in_master_rec.unit_weight
                 , c_items_in_master_rec.unit_volume
                 , c_items_in_master_rec.weight_uom_code
                 , c_items_in_master_rec.volume_uom_code
                 , c_items_in_master_rec.eam_item_type);
           END IF;
        END IF;
     END LOOP;

  ELSE   --- Update done in Child Org

     FOR c_items_in_child_rec IN c_items_in_child
     LOOP
         UPDATE eni_oltp_item_star
            SET  UNIT_WEIGHT         = c_items_in_child_rec.unit_weight
               , UNIT_VOLUME         = c_items_in_child_rec.unit_volume
               , WEIGHT_UOM_CODE     = c_items_in_child_rec.weight_uom_code
               , VOLUME_UOM_CODE     = c_items_in_child_rec.volume_uom_code
               , LAST_UPDATE_DATE    = c_items_in_child_rec.last_update_date
               , PRIMARY_UOM_CODE    = c_items_in_child_rec.primary_uom_code
               , EAM_ITEM_TYPE       = c_items_in_child_rec.eam_item_type
          WHERE inventory_item_id    = p_inventory_item_id
            AND organization_id      = c_items_in_child_rec.organization_id;

         -- The following block will only be called when an
         -- user updates an item when the load is running. Since
         -- the load truncates the table, the update will not go
         -- thru. So it is stored temporarily into a TEMP table.

         -- There is a separate insert and an update because the
         -- the user can modify the same item twice while the load
         -- is running. This would create duplicate records in the
         -- TEMP table. To avoid duplicacy there is a insert and an update.

         IF sql%rowcount = 0 THEN
            UPDATE eni_item_star_temp
                SET   UNIT_WEIGHT         = c_items_in_child_rec.unit_weight
                    , UNIT_VOLUME        = c_items_in_child_rec.unit_volume
                    , WEIGHT_UOM_CODE    = c_items_in_child_rec.weight_uom_code
                    , VOLUME_UOM_CODE    = c_items_in_child_rec.volume_uom_code
                    , LAST_UPDATE_DATE   = c_items_in_child_rec.last_update_date
                    , PRIMARY_UOM_CODE   = c_items_in_child_rec.primary_uom_code
                    , EAM_ITEM_TYPE      = c_items_in_child_rec.eam_item_type
            WHERE inventory_item_id      = p_inventory_item_id
              AND organization_id        = c_items_in_child_rec.organization_id;

            IF sql%rowcount = 0 THEN
               INSERT INTO eni_item_star_temp(
	            inventory_item_id
                  , organization_id
                  , last_update_date
                  , unit_weight
                  , unit_volume
                  , weight_uom_code
                  , volume_uom_code
                  , primary_uom_code
                  , eam_item_type)
               VALUES(
                    p_inventory_item_id
                  , c_items_in_child_rec.organization_id
                  , c_items_in_child_rec.last_update_date
                  , c_items_in_child_rec.unit_weight
                  , c_items_in_child_rec.unit_volume
                  , c_items_in_child_rec.weight_uom_code
                  , c_items_in_child_rec.volume_uom_code
                  , c_items_in_child_rec.primary_uom_code
                  , c_items_in_child_rec.eam_item_type);
            END IF;
         END IF;
      END LOOP;
   END IF;

    X_RETURN_STATUS := 'S';

EXCEPTION
      WHEN OTHERS THEN
          X_RETURN_STATUS := 'U';
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'UPDATE_ITEMS_IN_STAR', SQLERRM);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);

END Update_Items_In_Star;


--**********************************************************************
-- Maintains STAR table when changes are detected on MTL_CATEGORIES
--**********************************************************************

PROCEDURE Update_Categories( p_api_version NUMBER
                           , p_init_msg_list VARCHAR2 := 'F'
                           , p_category_id NUMBER
                           , p_structure_id NUMBER
                           , x_return_status OUT NOCOPY VARCHAR2
                           , x_msg_count OUT NOCOPY NUMBER
                           , x_msg_data OUT NOCOPY VARCHAR2 )
IS
which_category_set VARCHAR2(15);
l_category_set_id number;
BEGIN


  -- Check if this synchronization should happen; if no, exit; if yes, continue
  if Sync_Star_Items = false then
        X_RETURN_STATUS := 'S';
        return;
  end if;

  begin
  -- Which category set does assignment belong in ?

  SELECT 'INV_CATEGORY' INTO which_category_set
    FROM mtl_default_category_sets a, mtl_category_sets_b b
   WHERE a.functional_area_id = 1
     AND a.category_set_id = b.category_set_id
     AND b.structure_id = p_structure_id;

  exception
  when no_data_found then
     begin
        l_category_set_id := ENI_DENORM_HRCHY.get_category_set_id;

        select 'VBH_CATEGORY' into which_category_set
          from mtl_category_Sets_b
         where structure_id = p_structure_id
           and category_Set_id = l_category_set_id;
     exception
        when no_data_found then
           which_category_set := 'NONE';
     end;
  end;

  -- Update Item-Category Assignment

/* Commented out as fix for Bug 3600364
    IF which_category_set = 'VBH_CATEGORY' and l_category_set_id = 1000000006
    THEN
        UPDATE ENI_OLTP_ITEM_STAR
           SET VBH_CATEGORY_ID = -1
               ,VBH_CONCAT_SEG = 'Unassigned'
         WHERE vbh_category_id = p_category_id
           AND VBH_CONCAT_SEG <> (SELECT CONCATENATED_SEGMENTS
                                    FROM MTL_CATEGORIES_KFV
                                   WHERE CATEGORY_ID = p_category_id);
*/
    IF which_category_set = 'VBH_CATEGORY'
    THEN
        UPDATE ENI_OLTP_ITEM_STAR
           SET VBH_CONCAT_SEG =
                (select concatenated_segments
                   from mtl_categories_b_kfv
                  where category_id = p_category_id)
         WHERE vbh_category_id = p_category_id;
    ELSIF which_category_set = 'INV_CATEGORY'
    THEN
        UPDATE ENI_OLTP_ITEM_STAR
           SET INV_CONCAT_SEG =
                (select concatenated_segments
                   from mtl_categories_b_kfv
                  where category_id = p_category_id)
         WHERE inv_category_id = p_category_id;
    END IF;

      X_RETURN_STATUS := 'S';

EXCEPTION
      WHEN OTHERS THEN
          X_RETURN_STATUS := 'U';
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'UPDATE_CATEGORIES', SQLERRM);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);

END Update_Categories;


--**********************************************************************
-- Maintains STAR table when changes are detected on MTL_ITEM_CATEGORIES
--**********************************************************************

PROCEDURE Sync_Category_Assignments ( p_api_version NUMBER
                                    , p_init_msg_list VARCHAR2 := 'F'
                                    , p_inventory_item_id NUMBER
                                    , p_organization_id NUMBER
                                    , x_return_status OUT NOCOPY VARCHAR2
                                    , x_msg_count OUT NOCOPY NUMBER
                                    , x_msg_data OUT NOCOPY VARCHAR2 )
IS
  l_INV_category_set_id   number;
  l_VBH_category_set_id   number;
  l_PO_category_set_id    number;
  l_old_category_id number;
  l_new_category_id number;
  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(1000);
  l_eni_table_exists number;

  cursor c1(p_inventory_item_id number, p_organization_id number) is
  SELECT    msi.organization_id,
            nvl(mic.category_id, -1) inv_category_id,
            nvl(kfv.concatenated_segments, 'Unassigned') inv_concat_seg,
            nvl(mic.category_Set_id, l_INV_category_set_id) inv_category_Set_id,
            nvl(mic1.category_id, -1) vbh_category_id,
            nvl(kfv1.concatenated_segments, 'Unassigned') vbh_concat_seg,
            nvl(mic1.category_Set_id, l_VBH_category_set_id) vbh_category_set_id,
            nvl(mic2.category_id, -1) po_category_id,
            nvl(kfv2.concatenated_segments, 'Unassigned') po_concat_seg,
            nvl(mic2.category_Set_id, l_PO_category_set_id) po_category_set_id
          FROM
            mtl_system_items_b msi
          , mtl_item_categories mic
          , mtl_categories_b_kfv kfv
          , mtl_item_categories mic1
          , mtl_categories_b_kfv kfv1
          , mtl_item_categories mic2
          , mtl_categories_b_kfv kfv2
          WHERE
            msi.inventory_item_id = p_inventory_item_id
           AND (msi.organization_id = p_organization_id
                or msi.organization_id in (SELECT mp.organization_id
                                             FROM mtl_parameters mp
                                            WHERE
                     mp.master_organization_id = p_organization_id))
           AND mic.inventory_item_id (+) = msi.inventory_item_id
           AND mic.organization_id (+) = msi.organization_id
           AND mic.category_id = kfv.category_id (+)
           AND mic.category_set_id (+) = l_INV_category_set_id
           AND mic1.inventory_item_id (+) = msi.inventory_item_id
           AND mic1.organization_id (+) = msi.organization_id
           AND mic1.category_id = kfv1.category_id (+)
           AND mic1.category_set_id (+) = l_VBH_category_set_id
           AND mic2.inventory_item_id (+) = msi.inventory_item_id
           AND mic2.organization_id (+) = msi.organization_id
           AND mic2.category_id = kfv2.category_id (+)
           AND mic2.category_set_id (+) = l_PO_category_set_id;

CURSOR get_po_catset IS
 SELECT category_set_id
 FROM mtl_default_category_sets
 WHERE functional_area_id = 2;

BEGIN


   -- Check if this synchronization should happen; if no, exit; if yes, continue
   if Sync_Star_Items = false then
        X_RETURN_STATUS := 'S';
        return;
   end if;

   SELECT category_set_id
     INTO l_INV_category_set_id
     FROM mtl_default_category_sets
    WHERE functional_area_id = 1;

  l_VBH_category_set_id := ENI_DENORM_HRCHY.get_category_set_id;

  OPEN get_po_catset;
  FETCH get_po_catset INTO l_po_category_set_id;
  CLOSE get_po_catset;

  FOR sync_c1 IN C1(p_inventory_item_id, p_organization_id)
  LOOP

    UPDATE eni_oltp_item_star
    SET
       INV_CATEGORY_ID = sync_c1.inv_category_id,
       INV_CONCAT_SEG = sync_c1.inv_concat_seg,
       INV_CATEGORY_SET_ID = sync_c1.inv_category_set_id,
       VBH_CATEGORY_ID = sync_c1.vbh_category_id,
       VBH_CONCAT_SEG = sync_c1.vbh_concat_seg,
       VBH_CATEGORY_SET_ID = sync_c1.vbh_category_set_id,
       PO_CATEGORY_ID = sync_c1.po_category_id,
       PO_CONCAT_SEG = sync_c1.po_concat_seg,
       PO_CATEGORY_SET_ID = sync_c1.po_category_set_id
    WHERE inventory_item_id = p_inventory_item_id
      AND organization_id = sync_c1.organization_id;

   -- dbms_output.put_line('after update star:'|| to_char(sql%rowcount));
--      rowid = upd_item_star_rec.row_id;

    -- This block will only be called when a user is updating
    -- an item category assignment when the load is running in
    -- parallel.
    -- This block will update into the temporary table while
    -- the STAR table is empty because of the load. The MERGE
    -- statement is written(instead of a single insert) to
    -- prevent duplicate records being inserted into the TEMP
    -- table. Duplicate records will be inserted if the user
    -- makes a change in the category assignment, then makes
    -- another change to the same assignment while the load
    -- is till running.

    if Sql%Rowcount = 0 then

       -- dbms_output.put_line('before update temp....');

       UPDATE ENI_ITEM_STAR_TEMP
          set        inv_category_set_id = sync_c1.inv_category_set_id,
                     inv_category_id = sync_c1.inv_category_id,
                     inv_concat_seg = sync_c1.inv_concat_seg,
                     vbh_category_set_id = sync_c1.vbh_category_set_id,
                     vbh_category_id = sync_c1.vbh_category_id,
                     vbh_concat_seg = sync_c1.vbh_concat_seg,
                     po_category_set_id = sync_c1.po_category_set_id,
                     po_category_id = sync_c1.po_category_id,
                     po_concat_seg = sync_c1.po_concat_seg
          where inventory_item_id = p_inventory_item_id
            and organization_id = sync_c1.organization_id;

         -- dbms_output.put_line('After update temp..'||to_char(sql%rowcount));

        if sql%rowcount = 0 then
          INSERT into ENI_ITEM_STAR_TEMP
                 (inventory_item_id,
                  organization_id,
                  inv_category_set_id,
                  inv_category_id,
                  inv_concat_seg,
                  vbh_category_set_id,
                  vbh_category_id,
                  vbh_concat_seg,
                  po_category_set_id,
                  po_category_id,
                  po_concat_seg)
          VALUES (p_inventory_item_id,
                  sync_c1.organization_id,
                  sync_c1.inv_category_set_id,
                  sync_c1.inv_category_id,
                  sync_c1.inv_concat_seg,
                  sync_c1.vbh_category_set_id,
                  sync_c1.vbh_category_id,
                  sync_c1.vbh_concat_seg,
                  sync_c1.po_category_set_id,
                  sync_c1.po_category_id,
                  sync_c1.po_concat_seg);

          -- dbms_output.put_line('After insert temp..'||to_char(sql%rowcount));

         end if;

     end if;

  END LOOP; -- upd_item_star

  -- IF l_eni_table_exists = 0 THEN

  --   BEGIN  -- Calling Denorm API to set the item_assgn_flag

       -- dbms_output.put_line('in denorm API');

    --    Select vbh_category_id into l_new_category_id
    --      from eni_oltp_item_star
    --     where inventory_item_id = p_inventory_item_id
    --      and organization_id = p_organization_id
    --      and rownum = 1;

    --    IF l_old_category_id <> l_new_category_id THEN

       --  dbms_output.put_line('Inside if old-new category');

      --   ENI_UPD_ASSGN.UPDATE_ASSGN_FLAG
      --        (p_new_category_id => l_new_category_id,
      --         p_old_category_id => l_old_category_id,
      --         x_return_status => l_return_status,
      --         x_msg_count => l_msg_count,
      --         x_msg_data => l_msg_data);
      --  END IF;

  --   EXCEPTION
  --      WHEN no_data_found THEN
  --       null;
  --   END;

  -- END IF;

   if l_return_status = 'U' then
      X_RETURN_STATUS := l_return_status;
      X_MSG_COUNT := l_msg_count;
      X_MSG_DATA := l_msg_data;
   else
      X_RETURN_STATUS := 'S';
   end if;


EXCEPTION
      WHEN OTHERS THEN
          X_RETURN_STATUS := 'U';
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'SYNC_CATEGORY_ASSIGNMENTS', SQLERRM);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);

End Sync_Category_Assignments;

--**************************************************************************
-- Inserts/Updates De-normalized Item STAR table from Item Open Interface
--**************************************************************************

PROCEDURE Sync_Star_Items_From_IOI(p_api_version NUMBER,
                                   p_init_msg_list VARCHAR2 := 'F',
                                   p_set_process_id NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data OUT NOCOPY VARCHAR2)
IS

CURSOR get_po_catset IS
 SELECT category_set_id
 FROM mtl_default_category_sets
 WHERE functional_area_id = 2;

   l_inv_category_set number;
   l_vbh_category_set number;
   l_po_category_set  number;
   l_user_id          number;
   l_conc_request_id  number;
   l_prog_appl_id     number;
   l_conc_program_id  number;
   l_count            number;
   l_sql              VARCHAR2(32000);
   l_rowcount         number;
   l_child_set_id     NUMBER;
BEGIN

   -- Check if this synchronization should happen; if no, exit; if yes, continue
   if Sync_Star_Items = false then
        X_RETURN_STATUS := 'S';
        return;
   end if;

   l_child_set_id := p_set_process_id + 1000000000000;

   l_vbh_category_set := ENI_DENORM_HRCHY.get_category_set_id;
   OPEN get_po_catset;
   FETCH get_po_catset INTO l_po_category_set;
   CLOSE get_po_catset;

   l_user_id          := FND_GLOBAL.USER_ID;
   l_conc_request_id  := FND_GLOBAL.CONC_REQUEST_ID;
   l_prog_appl_id     := FND_GLOBAL.PROG_APPL_ID;
   l_conc_program_id  := FND_GLOBAL.CONC_PROGRAM_ID;

   IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize ;
   END IF;

    SELECT category_set_id INTO l_inv_category_set
      FROM mtl_default_category_sets
     WHERE functional_area_id = 1;

-- Bug : 3671737 made changes to use Bind variables for local variables
    l_sql := 'MERGE INTO eni_oltp_item_star STAR
    USING (SELECT item.inventory_item_id inventory_item_id,
               item.organization_id organization_id,
               item.CONCATENATED_SEGMENTS|| '' ('' || mtp.organization_code || '')''value,
               decode(item.organization_id,mtp.master_organization_id,null,
                item.inventory_item_id || ''-'' || mtp.master_organization_id)
               master_id,
               nvl(mic.category_id,-1) inv_category_id,
               nvl(mic.category_set_id, :l_inv_category_set) inv_category_set_id,
               nvl(kfv.concatenated_segments,''Unassigned'') inv_concat_seg,
               nvl(mic1.category_id,-1) vbh_category_id,
               nvl(mic1.category_set_id, :l_vbh_category_set) vbh_category_set_id,
               nvl(kfv1.concatenated_segments,''Unassigned'') vbh_concat_seg,
               nvl(mic2.category_id,-1) po_category_id,
               nvl(mic2.category_set_id, :l_po_category_set) po_category_set_id,
               nvl(kfv2.concatenated_segments,''Unassigned'') po_concat_seg,
               nvl(item.item_catalog_group_id,-1) item_catalog_group_id,
               item.primary_uom_code
             , item.unit_weight
             , item.unit_volume
             , item.weight_uom_code
             , item.volume_uom_code
             , item.eam_item_type
             , item.creation_date
             , item.last_update_date
           FROM mtl_system_items_interface interface
              , mtl_system_items_b_kfv item
              , mtl_parameters mtp
              , mtl_item_categories mic
              , mtl_categories_b_kfv kfv
              , mtl_item_categories mic1
              , mtl_categories_b_kfv kfv1
              , mtl_item_categories mic2
              , mtl_categories_b_kfv kfv2
           WHERE item.inventory_item_id = interface.inventory_item_id
             AND interface.set_process_id = :p_set_process_id
             AND interface.process_flag = 7
             AND item.organization_id = interface.organization_id
             AND item.organization_id= mtp.organization_id
             AND mic.organization_id(+) = item.organization_id
             AND mic.inventory_item_id(+) = item.inventory_item_id
             AND mic.category_id  = kfv.category_id (+)
             and mic.category_set_id(+) = :l_inv_category_set
             AND mic1.organization_id(+) = item.organization_id
             AND mic1.inventory_item_id(+) = item.inventory_item_id
             AND mic1.category_id  = kfv1.category_id (+)
             and mic1.category_set_id(+) = :l_vbh_category_set
             AND mic2.organization_id(+) = item.organization_id
             AND mic2.inventory_item_id(+) = item.inventory_item_id
             AND mic2.category_id  = kfv2.category_id (+)
             and mic2.category_set_id(+) = :l_po_category_set) mti
       ON (STAR.inventory_item_id = mti.inventory_item_id
           AND STAR.organization_id = mti.organization_id)
     WHEN MATCHED THEN
          UPDATE SET STAR.value                 = mti.value
                   , STAR.po_category_id        = mti.po_category_id
                   , STAR.po_category_set_id    = mti.po_category_set_id
                   , STAR.po_concat_seg         = mti.po_concat_seg
                   , STAR.inv_category_id       = mti.inv_category_id
                   , STAR.inv_category_set_id   = mti.inv_category_set_id
                   , STAR.inv_concat_seg        = mti.inv_concat_seg
                   , STAR.vbh_category_id       = mti.vbh_category_id
                   , STAR.vbh_category_set_id   = mti.vbh_category_set_id
                   , STAR.vbh_concat_seg        = mti.vbh_concat_seg
                   , STAR.master_id             = mti.master_id
                   , STAR.item_catalog_group_id = mti.item_catalog_group_id
                   , STAR.primary_uom_code      = mti.primary_uom_code
                   , STAR.unit_weight           = mti.unit_weight
                   , STAR.unit_volume           = mti.unit_volume
                   , STAR.weight_uom_code       = mti.weight_uom_code
                   , STAR.volume_uom_code       = mti.volume_uom_code
                   , STAR.eam_item_type         = mti.eam_item_type
                   , STAR.last_update_date      = mti.last_update_date
     WHEN NOT MATCHED THEN
          INSERT (
               id,
               value,
               inventory_item_id,
               organization_id,
               po_category_id,
               po_category_set_id,
               po_concat_seg,
               inv_category_id,
               inv_category_set_id,
               inv_concat_seg,
               vbh_category_id,
               vbh_category_set_id,
               vbh_concat_seg,
               master_id,
               item_catalog_group_id,
               primary_uom_code,
               unit_weight,
               unit_volume,
               weight_uom_code,
               volume_uom_code,
               eam_item_type,
               creation_date,
               last_update_date)
          VALUES(
               mti.inventory_item_id || ''-'' || mti.organization_id,
               mti.value,
               mti.inventory_item_id,
               mti.organization_id,
               mti.po_category_id,
               mti.po_category_set_id,
               mti.po_concat_seg,
               mti.inv_category_id,
               mti.inv_category_set_id,
               mti.inv_concat_seg,
               mti.vbh_category_id,
               mti.vbh_category_set_id,
               mti.vbh_concat_seg,
               mti.master_id,
               mti.item_catalog_group_id,
               mti.primary_uom_code,
               mti.unit_weight,
               mti.unit_volume,
               mti.weight_uom_code,
               mti.volume_uom_code,
               mti.eam_item_type,
               mti.creation_date,
               mti.last_update_date)';
-- Bug : 3671737

EXECUTE IMMEDIATE l_sql USING l_inv_category_set, l_vbh_category_set, l_po_category_set, p_set_process_id, l_inv_category_set, l_vbh_category_set, l_po_category_set;

    /*Bug 4604523 Splitting the merge to process once rows with set_process_id = N
      and next with set_process_id = N+1000000000000*/
    l_sql := 'MERGE INTO eni_oltp_item_star STAR
    USING (SELECT item.inventory_item_id inventory_item_id,
               item.organization_id organization_id,
               item.CONCATENATED_SEGMENTS|| '' ('' || mtp.organization_code || '')''value,
               decode(item.organization_id,mtp.master_organization_id,null,
                item.inventory_item_id || ''-'' || mtp.master_organization_id)
               master_id,
               nvl(mic.category_id,-1) inv_category_id,
               nvl(mic.category_set_id, :l_inv_category_set) inv_category_set_id,
               nvl(kfv.concatenated_segments,''Unassigned'') inv_concat_seg,
               nvl(mic1.category_id,-1) vbh_category_id,
               nvl(mic1.category_set_id, :l_vbh_category_set) vbh_category_set_id,
               nvl(kfv1.concatenated_segments,''Unassigned'') vbh_concat_seg,
               nvl(mic2.category_id,-1) po_category_id,
               nvl(mic2.category_set_id, :l_po_category_set) po_category_set_id,
               nvl(kfv2.concatenated_segments,''Unassigned'') po_concat_seg,
               nvl(item.item_catalog_group_id,-1) item_catalog_group_id,
               item.primary_uom_code
             , item.unit_weight
             , item.unit_volume
             , item.weight_uom_code
             , item.volume_uom_code
             , item.eam_item_type
             , item.creation_date
             , item.last_update_date
           FROM mtl_system_items_interface interface
              , mtl_system_items_b_kfv item
              , mtl_parameters mtp
              , mtl_item_categories mic
              , mtl_categories_b_kfv kfv
              , mtl_item_categories mic1
              , mtl_categories_b_kfv kfv1
              , mtl_item_categories mic2
              , mtl_categories_b_kfv kfv2
           WHERE item.inventory_item_id = interface.inventory_item_id
             AND interface.set_process_id =
                             :p_set_process_id
             AND interface.process_flag = 7
             AND item.organization_id = interface.organization_id
             AND item.organization_id= mtp.organization_id
             AND mic.organization_id(+) = item.organization_id
             AND mic.inventory_item_id(+) = item.inventory_item_id
             AND mic.category_id  = kfv.category_id (+)
             and mic.category_set_id(+) = :l_inv_category_set
             AND mic1.organization_id(+) = item.organization_id
             AND mic1.inventory_item_id(+) = item.inventory_item_id
             AND mic1.category_id  = kfv1.category_id (+)
             and mic1.category_set_id(+) = :l_vbh_category_set
             AND mic2.organization_id(+) = item.organization_id
             AND mic2.inventory_item_id(+) = item.inventory_item_id
             AND mic2.category_id  = kfv2.category_id (+)
             and mic2.category_set_id(+) = :l_po_category_set) mti
       ON (STAR.inventory_item_id = mti.inventory_item_id
           AND STAR.organization_id = mti.organization_id)
     WHEN MATCHED THEN
          UPDATE SET STAR.value                 = mti.value
                   , STAR.po_category_id        = mti.po_category_id
                   , STAR.po_category_set_id    = mti.po_category_set_id
                   , STAR.po_concat_seg         = mti.po_concat_seg
                   , STAR.inv_category_id       = mti.inv_category_id
                   , STAR.inv_category_set_id   = mti.inv_category_set_id
                   , STAR.inv_concat_seg        = mti.inv_concat_seg
                   , STAR.vbh_category_id       = mti.vbh_category_id
                   , STAR.vbh_category_set_id   = mti.vbh_category_set_id
                   , STAR.vbh_concat_seg        = mti.vbh_concat_seg
                   , STAR.master_id             = mti.master_id
                   , STAR.item_catalog_group_id = mti.item_catalog_group_id
                   , STAR.primary_uom_code      = mti.primary_uom_code
                   , STAR.unit_weight           = mti.unit_weight
                   , STAR.unit_volume           = mti.unit_volume
                   , STAR.weight_uom_code       = mti.weight_uom_code
                   , STAR.volume_uom_code       = mti.volume_uom_code
                   , STAR.eam_item_type         = mti.eam_item_type
                   , STAR.last_update_date      = mti.last_update_date
     WHEN NOT MATCHED THEN
          INSERT (
               id,
               value,
               inventory_item_id,
               organization_id,
               po_category_id,
               po_category_set_id,
               po_concat_seg,
               inv_category_id,
               inv_category_set_id,
               inv_concat_seg,
               vbh_category_id,
               vbh_category_set_id,
               vbh_concat_seg,
               master_id,
               item_catalog_group_id,
               primary_uom_code,
               unit_weight,
               unit_volume,
               weight_uom_code,
               volume_uom_code,
               eam_item_type,
               creation_date,
               last_update_date)
          VALUES(
               mti.inventory_item_id || ''-'' || mti.organization_id,
               mti.value,
               mti.inventory_item_id,
               mti.organization_id,
               mti.po_category_id,
               mti.po_category_set_id,
               mti.po_concat_seg,
               mti.inv_category_id,
               mti.inv_category_set_id,
               mti.inv_concat_seg,
               mti.vbh_category_id,
               mti.vbh_category_set_id,
               mti.vbh_concat_seg,
               mti.master_id,
               mti.item_catalog_group_id,
               mti.primary_uom_code,
               mti.unit_weight,
               mti.unit_volume,
               mti.weight_uom_code,
               mti.volume_uom_code,
               mti.eam_item_type,
               mti.creation_date,
               mti.last_update_date)';

    EXECUTE IMMEDIATE l_sql USING l_inv_category_set, l_vbh_category_set, l_po_category_set, l_child_set_id, l_inv_category_set, l_vbh_category_set, l_po_category_set;

  -- Bug: 4917496 Added child_id= default_category_id predicate
  -- updating Item Assignment flag for all categories,
  -- which have items attached to it
  UPDATE eni_denorm_hierarchies B
  SET
    item_assgn_flag = 'Y',
    last_update_date = sysdate,
    last_updated_by = l_user_id,
    last_update_login = l_user_id,
    request_id = l_conc_request_id,
    program_application_id = l_prog_appl_id,
    program_update_date = sysdate,
    program_id = l_conc_program_id
  WHERE b.object_type = 'CATEGORY_SET'
    AND b.object_id = l_vbh_category_set
    AND b.item_assgn_flag = 'N'
    AND b.child_id = (SELECT DEFAULT_CATEGORY_ID
                      FROM mtl_category_sets_b
                      WHERE category_set_id=l_vbh_category_set)
    AND EXISTS (SELECT NULL
                FROM mtl_item_categories C
                WHERE c.category_set_id = l_vbh_category_set
                  AND c.category_id = b.child_id);

/** Bug: 4917496
    commenting this update as IOI(Item Create) can only result in creation of item assignment
    This update statement will always fetch zero rows.

    -- updating Item Assignment flag for all categories, which does not have items attached to it
  UPDATE eni_denorm_hierarchies b
  SET
    item_assgn_flag = 'N',
    last_update_date = SYSDATE,
    last_updated_by = l_user_id,
    last_update_login = l_user_id,
    request_id = l_conc_request_id,
    program_application_id = l_prog_appl_id,
    program_update_date = SYSDATE,
    program_id = l_conc_program_id
  WHERE b.object_type = 'CATEGORY_SET'
    AND b.object_id = l_vbh_category_set
    AND b.item_assgn_flag = 'Y'
    AND b.child_id <> -1
    AND NOT EXISTS (SELECT NULL
                    FROM mtl_item_categories C
                    WHERE c.category_set_id = l_vbh_category_set
                      AND c.category_id = b.child_id);
**/
   -- Checking Item assignment flag for Unassigned category
  -- if all items are attached to some categories within this category set then
  -- Item assignment flag for Unassigned node will be 'N'

  l_count := 0;

  BEGIN
    SELECT 1 INTO l_count
    FROM ENI_OLTP_ITEM_STAR star
    WHERE star.vbh_category_id = -1
      AND rownum = 1;

/** Bug 4675565
    Replaced with the SQL above
    As UNASSIGNED category is only used by DBI
    we can rely on ENI_OLTP_ITEM_STAR_TABLE to get this info.
    SELECT 1 INTO l_count
    FROM mtl_system_items_b IT
    WHERE ROWNUM = 1
      AND NOT EXISTS (SELECT NULL FROM mtl_item_categories C
                      WHERE c.category_set_id = l_vbh_category_set
                        AND c.inventory_item_id = it.inventory_item_id
                        AND c.organization_id = it.organization_id);
*/
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_count := 0;
  END;

     UPDATE eni_denorm_hierarchies b
     SET
       item_assgn_flag = decode(l_count, 0, 'N', 'Y'),
       last_update_date = sysdate,
       last_updated_by = l_user_id,
       last_update_login = l_user_id,
       request_id = l_conc_request_id,
       program_application_id = l_prog_appl_id,
       program_update_date = sysdate,
       program_id = l_conc_program_id
     WHERE b.object_type = 'CATEGORY_SET'
       AND b.object_id = l_vbh_category_set
       AND b.item_assgn_flag = DECODE(l_count, 0, 'Y', 'N')
       AND b.child_id = -1
       AND b.parent_id = -1;

      X_RETURN_STATUS := 'S';

  EXCEPTION
  WHEN OTHERS THEN
     X_RETURN_STATUS := 'U';
     IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'SYNC_STAR_ITEMS_FROM_IOI',SQLERRM);
     END IF;
     FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);


END Sync_star_items_from_IOI;

-- Inserts/Deletes item category assignment from star table from
-- Categories open interface
PROCEDURE Sync_Star_ItemCatg_From_COI(
                           p_api_version    IN  NUMBER,
                           p_init_msg_list  IN  VARCHAR2 := 'F',
                           p_set_process_id IN  NUMBER,
                           x_return_status  OUT NOCOPY  VARCHAR2,
                           x_msg_count      OUT NOCOPY  NUMBER,
                           X_MSG_DATA       OUT NOCOPY  VARCHAR2) IS

CURSOR get_po_catset IS
 SELECT category_set_id
 FROM mtl_default_category_sets
 WHERE functional_area_id = 2;

   l_user_id          number;
   l_conc_request_id  number;
   l_prog_appl_id     number;
   l_conc_program_id  number;
   l_count            number;
   l_INV_category_set_id   number;
   l_VBH_category_set_id   number;
   l_PO_category_set_id    number;
   l_process_flag     NUMBER;
   l_num_updates      NUMBER := 0;

CURSOR icoi_csr (p_set_process_id NUMBER) IS
   SELECT mici.inventory_item_id
         ,mp.organization_id
   FROM  mtl_item_categories_interface mici
        ,mtl_parameters mp
   WHERE     mici.set_process_id   = p_set_process_id
         AND mici.request_id       = l_conc_request_id
         AND mici.process_flag     = l_process_flag
         AND (   mici.category_set_id = l_INV_category_set_id
              OR mici.category_set_id = l_VBH_category_set_id
              OR mici.category_set_id = l_PO_category_set_id)
         AND (   mici.organization_id = mp.organization_id
              OR mici.organization_id = mp.master_organization_id);


BEGIN


   -- Check if this synchronization should happen: if no, exit, if yes, continue
   if Sync_Star_Items = false  then
        X_RETURN_STATUS := 'S';
        return;
   end if;

   l_vbh_category_set_id := ENI_DENORM_HRCHY.get_category_set_id;
   OPEN get_po_catset;
   FETCH get_po_catset INTO l_po_category_set_id;
   CLOSE get_po_catset;
   l_user_id             := FND_GLOBAL.USER_ID;
   l_conc_request_id     := FND_GLOBAL.CONC_REQUEST_ID;
   l_prog_appl_id        := FND_GLOBAL.PROG_APPL_ID;
   l_conc_program_id     := FND_GLOBAL.CONC_PROGRAM_ID;
   l_process_flag        := 7;

   IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.Initialize ;
   END IF;

   SELECT category_set_id INTO l_inv_category_set_id
     FROM mtl_default_category_sets
   WHERE functional_area_id = 1;


   FOR sync_itmcatg IN icoi_csr(
        p_set_process_id => p_set_process_id)
   LOOP
      UPDATE eni_oltp_item_star star
      SET (
            star.INV_CATEGORY_ID
           ,star.INV_CONCAT_SEG
           ,star.INV_CATEGORY_SET_ID
           ,star.VBH_CATEGORY_ID
           ,star.VBH_CONCAT_SEG
           ,star.VBH_CATEGORY_SET_ID
           ,star.PO_CATEGORY_ID
           ,star.PO_CONCAT_SEG
           ,star.PO_CATEGORY_SET_ID)
         =
          ( SELECT
            nvl(mic.category_id, -1) inv_category_id
           ,nvl(kfv.concatenated_segments, 'Unassigned') inv_concat_seg
           ,nvl(mic.category_Set_id, l_INV_category_set_id) inv_category_Set_id
           ,nvl(mic1.category_id, -1) vbh_category_id
           ,nvl(kfv1.concatenated_segments, 'Unassigned') vbh_concat_seg
           ,nvl(mic1.category_Set_id, l_VBH_category_set_id) vbh_category_set_id
           ,nvl(mic2.category_id, -1) po_category_id
           ,nvl(kfv2.concatenated_segments, 'Unassigned') po_concat_seg
           ,nvl(mic2.category_Set_id, l_PO_category_set_id) po_category_set_id
          FROM
            mtl_system_items_b msi
          , mtl_item_categories mic
          , mtl_categories_b_kfv kfv
          , mtl_item_categories mic1
          , mtl_categories_b_kfv kfv1
          , mtl_item_categories mic2
          , mtl_categories_b_kfv kfv2
          WHERE
               msi.inventory_item_id = star.inventory_item_id
           AND msi.organization_id   = star.organization_id
           AND mic.inventory_item_id (+) = msi.inventory_item_id
           AND mic.organization_id (+) = msi.organization_id
           AND mic.category_id = kfv.category_id (+)
           AND mic.category_set_id (+) = l_INV_category_set_id
           AND mic1.inventory_item_id (+) = msi.inventory_item_id
           AND mic1.organization_id (+) = msi.organization_id
           AND mic1.category_id = kfv1.category_id (+)
           AND mic1.category_set_id (+) = l_VBH_category_set_id
           AND mic2.inventory_item_id (+) = msi.inventory_item_id
           AND mic2.organization_id (+) = msi.organization_id
           AND mic2.category_id = kfv2.category_id (+)
           AND mic2.category_set_id (+) = l_PO_category_set_id)
      WHERE   star.inventory_item_id = sync_itmcatg.inventory_item_id
         AND  star.organization_id   = sync_itmcatg.organization_id;
   END LOOP;

/**Bug: 4917496
   Only update the categories which are modified in this run
   Only Create, update can cause an assigment creation
**/

  -- updating Item Assignment flag for all categories,
  -- which have items attached to it
  FOR intf_categories_add IN (SELECT DISTINCT CATEGORY_ID
                            FROM mtl_item_categories_interface
                            WHERE process_flag    = 7
                            AND   transaction_type IN ('CREATE','UPDATE')
                            AND   set_process_id  = p_set_process_id
                            AND   category_set_id = l_vbh_category_set_id)
  LOOP
     UPDATE eni_denorm_hierarchies B
     SET
       item_assgn_flag = 'Y',
       last_update_date = sysdate,
       last_updated_by = l_user_id,
       last_update_login = l_user_id,
       request_id = l_conc_request_id,
       program_application_id = l_prog_appl_id,
       program_update_date = sysdate,
       program_id = l_conc_program_id
     WHERE b.object_type = 'CATEGORY_SET'
       AND b.object_id = l_vbh_category_set_id
       AND b.item_assgn_flag = 'N'
       AND b.child_id = intf_categories_add.category_id
       AND EXISTS (SELECT NULL
                FROM mtl_item_categories C
                WHERE c.category_set_id = l_vbh_category_set_id
                  AND c.category_id = b.child_id);

       l_num_updates := l_num_updates + SQL%ROWCOUNT;
   END LOOP;

  -- updating Item Assignment flag for all categories, which do not have items attached to it
   FOR intf_categories_del IN
                 (SELECT DISTINCT
                         Decode(TRANSACTION_TYPE,
                                        'UPDATE',OLD_CATEGORY_ID,
                                                     CATEGORY_ID) AS CATEGORY_ID
                  FROM mtl_item_categories_interface
                  WHERE process_flag    = 7
                  AND   TRANSACTION_TYPE IN ('DELETE','UPDATE')
                  AND   set_process_id  = p_set_process_id
                  AND   category_set_id = l_vbh_category_set_id)
   LOOP

     UPDATE eni_denorm_hierarchies b
      SET
        item_assgn_flag = 'N',
        last_update_date = SYSDATE,
        last_updated_by = l_user_id,
        last_update_login = l_user_id,
        request_id = l_conc_request_id,
        program_application_id = l_prog_appl_id,
        program_update_date = SYSDATE,
        program_id = l_conc_program_id
     WHERE b.object_type = 'CATEGORY_SET'
       AND b.object_id = l_vbh_category_set_id
       AND b.item_assgn_flag = 'Y'
       AND b.child_id = intf_categories_del.category_id
       AND NOT EXISTS (SELECT NULL
                    FROM mtl_item_categories C
                    WHERE c.category_set_id = l_vbh_category_set_id
                      AND c.category_id = b.child_id);

     l_num_updates := l_num_updates + SQL%ROWCOUNT;

   END LOOP;


   -- Checking Item assignment flag for Unassigned category
  -- if all items are attached to some categories within this category set then
  -- Item assignment flag for Unassigned node will be 'N'
/** Bug: 4917496
    We need to update UNSASSIGNED category only if there is
    any upate on ENI_DENORM table in the above two SQLs
**/
  IF l_num_updates <> 0 THEN
  l_count := 0;

  BEGIN
    SELECT 1 INTO l_count
    FROM ENI_OLTP_ITEM_STAR star
    WHERE star.vbh_category_id = -1
      AND rownum = 1;

/** Bug 4675565
    Replaced with the SQL above
    As UNASSIGNED category is only used by DBI
    we can rely on ENI_OLTP_ITEM_STAR_TABLE to get this info.
    SELECT 1 INTO l_count
    FROM mtl_system_items_b IT
    WHERE ROWNUM = 1
      AND NOT EXISTS (SELECT NULL FROM mtl_item_categories C
                      WHERE c.category_set_id = l_vbh_category_set_id
                        AND c.inventory_item_id = it.inventory_item_id
                        AND c.organization_id = it.organization_id);
*/
  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_count := 0;
  END;

     UPDATE eni_denorm_hierarchies b
     SET
       item_assgn_flag = decode(l_count, 0, 'N', 'Y'),
       last_update_date = sysdate,
       last_updated_by = l_user_id,
       last_update_login = l_user_id,
       request_id = l_conc_request_id,
       program_application_id = l_prog_appl_id,
       program_update_date = sysdate,
       program_id = l_conc_program_id
     WHERE b.object_type = 'CATEGORY_SET'
       AND b.object_id = l_vbh_category_set_id
       AND b.item_assgn_flag = DECODE(l_count, 0, 'Y', 'N')
       AND b.child_id = -1
       AND b.parent_id = -1;

      X_RETURN_STATUS := 'S';

  END IF;

  EXCEPTION
  WHEN OTHERS THEN
     X_RETURN_STATUS := 'U';
     IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.ADD_EXC_MSG( g_pkg_name, 'SYNC_STAR_ITEMS_FROM_COI',SQLERRM);
     END IF;
     FND_MSG_PUB.COUNT_AND_GET( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);

END Sync_Star_ItemCatg_From_COI;

--Start :5688257 : %Items_In_Star functions to use flex API's to get concatenated segments
BEGIN
   SELECT NVL(LENGTH(CONCATENATED_SEGMENTS),0)  INTO G_INSTALL_PHASE
   FROM MTL_SYSTEM_ITEMS_B_KFV
   WHERE ROWNUM = 1;
EXCEPTION
   WHEN OTHERS THEN
      G_INSTALL_PHASE := 0;
--End :5688257 : %Items_In_Star functions to use flex API's to get concatenated segments

End ENI_ITEMS_STAR_PKG;

/
