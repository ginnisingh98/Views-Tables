--------------------------------------------------------
--  DDL for Package Body EGO_BROWSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_BROWSE_PVT" AS
/* $Header: EGOVBRWB.pls 120.2.12010000.2 2009/07/13 14:42:44 snandana ship $ */

 PROCEDURE Reload_ICG_Denorm_Hier_Table
    (x_return_status    OUT     NOCOPY VARCHAR2)
 IS
  CURSOR item_catalog_group_cursor
    IS
    SELECT ITEM_CATALOG_GROUP_ID
    FROM MTL_ITEM_CATALOG_GROUPS_B;

    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);
    l_num_rows_inserted      NUMBER := 0;

  BEGIN --{

    IF FND_INSTALLATION.GET_APP_INFO('EGO', l_status, l_industry, l_schema) THEN --{
       IF l_schema IS NULL    THEN
          Raise_Application_Error (-20001, 'EGO Schema could not be located.');
       END IF; --}
    ELSE --{
       Raise_Application_Error (-20001, 'EGO Schema could not be located.');
    END IF; --}


    --First delete all records in the denorm table.
    DELETE EGO_ITEM_CAT_DENORM_HIER;

    --Now for each record in the MTL_ITEM_CATALOG_GROUPS_B table
    --insert the complete child heirarchy into the denorm table.
    FOR cat_rec IN item_catalog_group_cursor
    LOOP --{
      INSERT INTO EGO_ITEM_CAT_DENORM_HIER(PARENT_CATALOG_GROUP_ID, CHILD_CATALOG_GROUP_ID)
      SELECT  cat_rec.ITEM_CATALOG_GROUP_ID PARENT_CATALOG_GROUP_ID
            , IC.ITEM_CATALOG_GROUP_ID CHILD_CATALOG_GROUP_ID
      FROM MTL_ITEM_CATALOG_GROUPS_B IC
      CONNECT BY PRIOR ITEM_CATALOG_GROUP_ID = PARENT_CATALOG_GROUP_ID
      START WITH ITEM_CATALOG_GROUP_ID = cat_rec.ITEM_CATALOG_GROUP_ID;

      l_num_rows_inserted := l_num_rows_inserted + SQL%ROWCOUNT;
    END LOOP; --}

    --Comupte stats on EGO_ITEM_CAT_DENORM_HIER
    /* Bug 7042156. Collect statistics only if the no.of records is bigger than the profile
       option threshold */
    IF (l_num_rows_inserted > nvl(fnd_profile.value('EGO_GATHER_STATS'),100)) THEN --{
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'EGO_ITEM_CAT_DENORM_HIER');
      FND_STATS.GATHER_INDEX_STATS(l_schema, 'EGO_ITEM_CAT_DENORM_HIER_U1');
    END IF; --}

    x_return_status := 'S';

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := 'U';

  END Reload_ICG_Denorm_Hier_Table; --}

  PROCEDURE Sync_ICG_Denorm_Hier_Table (
	             p_catalog_group_id         IN NUMBER,
	             p_old_parent_id            IN NUMBER DEFAULT NULL,
                     x_return_status    OUT     NOCOPY VARCHAR2
                     ) IS
  --{
      CURSOR old_parent_hierarchy
      IS
        SELECT PARENT_CATALOG_GROUP_ID
        FROM MTL_ITEM_CATALOG_GROUPS_B IC
        CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
        START WITH ITEM_CATALOG_GROUP_ID = p_old_parent_id;

      CURSOR new_parent_hierarchy
      IS
        SELECT PARENT_CATALOG_GROUP_ID
        FROM MTL_ITEM_CATALOG_GROUPS_B IC
        CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
        START WITH ITEM_CATALOG_GROUP_ID = p_catalog_group_id;

      l_num_rows_updated      NUMBER := 0;
      l_status                 VARCHAR2(1);
      l_industry               VARCHAR2(1);
      l_schema                 VARCHAR2(30);
  --}
  BEGIN
  --{

      IF FND_INSTALLATION.GET_APP_INFO('EGO', l_status, l_industry, l_schema) THEN --{
         IF l_schema IS NULL    THEN
            Raise_Application_Error (-20001, 'EGO Schema could not be located.');
         END IF; --}
      ELSE --{
         Raise_Application_Error (-20001, 'EGO Schema could not be located.');
      END IF; --}

      --First delete the child hierarchy entries for the item catalog being create/updated
      DELETE FROM EGO_ITEM_CAT_DENORM_HIER
      WHERE PARENT_CATALOG_GROUP_ID = p_catalog_group_id;
      l_num_rows_updated := l_num_rows_updated + SQL%ROWCOUNT;

      --Now insert the child hierarchy for the item catalog being create/updated
      INSERT INTO EGO_ITEM_CAT_DENORM_HIER(PARENT_CATALOG_GROUP_ID
	                                 , CHILD_CATALOG_GROUP_ID)
          ( SELECT p_catalog_group_id PARENT_CATALOG_GROUP_ID,
	           IC.ITEM_CATALOG_GROUP_ID CHILD_CATALOG_GROUP_ID
            FROM MTL_ITEM_CATALOG_GROUPS_B IC
            CONNECT BY PRIOR ITEM_CATALOG_GROUP_ID = PARENT_CATALOG_GROUP_ID
            START WITH ITEM_CATALOG_GROUP_ID = p_catalog_group_id );
      l_num_rows_updated := l_num_rows_updated + SQL%ROWCOUNT;

      IF(p_old_parent_id IS NOT NULL AND p_old_parent_id <> -1) THEN
      --{

	  --Delete the records for the current child hierarchy from the old parent hierarchy
          DELETE FROM EGO_ITEM_CAT_DENORM_HIER
          WHERE PARENT_CATALOG_GROUP_ID = p_old_parent_id
            AND CHILD_CATALOG_GROUP_ID IN
	      ( SELECT IC.ITEM_CATALOG_GROUP_ID
                FROM MTL_ITEM_CATALOG_GROUPS_B IC
                CONNECT BY PRIOR ITEM_CATALOG_GROUP_ID = PARENT_CATALOG_GROUP_ID
                START WITH ITEM_CATALOG_GROUP_ID = p_catalog_group_id );
          l_num_rows_updated := l_num_rows_updated + SQL%ROWCOUNT;

	  --Now delete the records for the current child hierarchy for each parent in the old parent hierarchy,
	  FOR old_parent_rec IN old_parent_hierarchy
	  LOOP
	  --{
              IF (old_parent_rec.PARENT_CATALOG_GROUP_ID IS NOT NULL) THEN
	      --{
                  DELETE FROM EGO_ITEM_CAT_DENORM_HIER
                  WHERE PARENT_CATALOG_GROUP_ID = old_parent_rec.PARENT_CATALOG_GROUP_ID
                    AND CHILD_CATALOG_GROUP_ID IN
        	      ( SELECT IC.ITEM_CATALOG_GROUP_ID
                        FROM MTL_ITEM_CATALOG_GROUPS_B IC
                        CONNECT BY PRIOR ITEM_CATALOG_GROUP_ID = PARENT_CATALOG_GROUP_ID
                        START WITH ITEM_CATALOG_GROUP_ID = p_catalog_group_id );
                  l_num_rows_updated := l_num_rows_updated + SQL%ROWCOUNT;
	      --}
	      END IF;
	  --}
	  END LOOP;

      --}
      END IF;

      --Now insert the records for the current child hierarchy for each parent in the new parent hierarchy,
      FOR new_parent_rec IN new_parent_hierarchy
      LOOP
      --{
          IF (new_parent_rec.PARENT_CATALOG_GROUP_ID IS NOT NULL) THEN
          --{
              INSERT INTO EGO_ITEM_CAT_DENORM_HIER(PARENT_CATALOG_GROUP_ID
	                                         , CHILD_CATALOG_GROUP_ID)
        	  ( SELECT new_parent_rec.PARENT_CATALOG_GROUP_ID PARENT_CATALOG_GROUP_ID,
		           IC.ITEM_CATALOG_GROUP_ID CHILD_CATALOG_GROUP_ID
                    FROM MTL_ITEM_CATALOG_GROUPS_B IC
                    CONNECT BY PRIOR ITEM_CATALOG_GROUP_ID = PARENT_CATALOG_GROUP_ID
                    START WITH ITEM_CATALOG_GROUP_ID = p_catalog_group_id );
              l_num_rows_updated := l_num_rows_updated + SQL%ROWCOUNT;
          --}
	  END IF;
      --}
      END LOOP;

    --Comupte stats on EGO_ITEM_CAT_DENORM_HIER
    /* Bug 7042156. Collect statistics only if the no.of records is bigger than the profile
       option threshold */
    IF (l_num_rows_updated > nvl(fnd_profile.value('EGO_GATHER_STATS'),100)) THEN --{
      FND_STATS.GATHER_TABLE_STATS(l_schema, 'EGO_ITEM_CAT_DENORM_HIER');
      FND_STATS.GATHER_INDEX_STATS(l_schema, 'EGO_ITEM_CAT_DENORM_HIER_U1');
    END IF; --}

      x_return_status := 'S';

      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := 'U';

  --}
  END Sync_ICG_Denorm_Hier_Table;




END EGO_BROWSE_PVT;

/
