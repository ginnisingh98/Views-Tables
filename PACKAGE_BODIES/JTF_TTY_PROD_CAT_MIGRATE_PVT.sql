--------------------------------------------------------
--  DDL for Package Body JTF_TTY_PROD_CAT_MIGRATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_PROD_CAT_MIGRATE_PVT" as
/* $Header: jtftrmpb.pls 120.3 2006/07/12 17:31:23 mhtran noship $ */

--*****************************************************************************

/* This procedure calls other procedure(s) to migrate the interest types, primary
   interest codes and secondary interest codes for Opportunity Expected Purchase
   and Lead Expected Purchase in the JTF_TERR_VALUES_ALL table. It also updates
   the JTF_TERR_QUAL_ALL table with new qual_usg_ids */

PROCEDURE Migrate_All ( ERRBUF         OUT NOCOPY    VARCHAR2,
                        RETCODE        OUT NOCOPY    VARCHAR2,
                        p_Debug_Flag   IN  VARCHAR2  default 'N') IS
BEGIN

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Migration started for Opportunity Expected Purchase');
   --Pass qual_usg_id for Opportunity Expected Purchase
   Migrate_Product_Cat_Terr(-1023, -1142, p_Debug_Flag);

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Migration started for Lead Expected Purchase');
   --Pass qual_usg_id for Lead Expected Purchase
   Migrate_Product_Cat_Terr(-1018, -1131, p_Debug_Flag);

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Migration started for Interest Types in JTF_TTY_ROLE_PROD_INT');
   --Updating JTF_TTY_ROLE_PROD_INT table
   Migrate_Product_Cat_Role(p_Debug_Flag);

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Migration completed successfully');

   FND_FILE.PUT_LINE(FND_FILE.LOG,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

EXCEPTION
   WHEN OTHERS THEN
      Rollback;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in Product Catalog data migration '||SQLERRM);
END Migrate_All;

/* This procedure migrates interest types, primary interest codes and secondary
   interest codes in the JTF_TERR_VALUES_ALL table */
PROCEDURE Migrate_Product_Cat_Terr(p_Qual_Usg_Id     IN NUMBER,
                                   p_Qual_Usg_Id_New IN NUMBER,
                                   p_Debug_Flag      IN VARCHAR2 Default 'N') IS

   TYPE NumTableType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_terr_val_ids_arr  NumTableType;

   -- Cursor for Interest Type Updates
   CURSOR c_int_type_upd_list(l_qual_usg_id NUMBER, l_qual_usg_id_new NUMBER ) IS
   SELECT a.terr_value_id
   FROM   jtf_terr_values_all a, jtf_terr_qual_all b
   WHERE  a.terr_qual_id =  b.terr_qual_id
   AND    b.qual_usg_id IN (l_qual_usg_id, l_qual_usg_id_new)
   AND    a.interest_type_id is not null
   AND    a.primary_interest_code_id is null
   AND    a.secondary_interest_code_id is null;

   -- Cursor for Primary Interest Code Updates
   CURSOR c_pri_int_upd_list(l_qual_usg_id NUMBER, l_qual_usg_id_new NUMBER) IS
   SELECT a.terr_value_id
   FROM   jtf_terr_values_all a, jtf_terr_qual_all b
   WHERE  a.terr_qual_id =  b.terr_qual_id
   AND    b.qual_usg_id IN (l_qual_usg_id, l_qual_usg_id_new)
   AND    a.primary_interest_code_id is not null
   AND    a.secondary_interest_code_id is null;

   -- Cursor for Secondary Interest Code Updates
   CURSOR c_sec_int_upd_list(l_qual_usg_id NUMBER, l_qual_usg_id_new NUMBER) IS
   SELECT a.terr_value_id
   FROM   jtf_terr_values_all a, jtf_terr_qual_all b
   WHERE  a.terr_qual_id =  b.terr_qual_id
   AND    b.qual_usg_id IN (l_qual_usg_id, l_qual_usg_id_new)
   AND    a.secondary_interest_code_id is not null;

BEGIN

   if (upper(p_Debug_Flag) = 'Y') then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Start: Migrating Interest Types');
   end if;

   -- Interest Types
   OPEN c_int_type_upd_list(p_Qual_Usg_Id, p_Qual_Usg_Id_New);
   FETCH c_int_type_upd_list BULK COLLECT INTO l_terr_val_ids_arr;
   IF (NVL(l_terr_val_ids_arr.COUNT,0) > 0) THEN
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Interest Types: Rows to be migrated: ' || l_terr_val_ids_arr.COUNT);
      end if;
      FORALL j IN l_terr_val_ids_arr.FIRST..l_terr_val_ids_arr.LAST
         UPDATE jtf_terr_values_all jtv
         SET    (value1_id, value2_id) =
                                         (SELECT int.product_category_id, int.product_cat_set_id
                                          FROM   as_interest_types_b int
                                          WHERE  jtv.interest_type_id = int.interest_type_id)
         WHERE jtv.terr_value_id  = l_terr_val_ids_arr(j);
         if (upper(p_Debug_Flag) = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Interest Types: Rows migrated: ' || SQL%ROWCOUNT);
         end if;
   ELSE
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Interest Types: Rows to be migrated: 0');
      end if;
   END IF;
   CLOSE c_int_type_upd_list;

   if (upper(p_Debug_Flag) = 'Y') then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'End: Migrating Interest Types');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Start: Migrating Primary Interest Codes');
   end if;

   -- Primary Interest Codes
   OPEN c_pri_int_upd_list(p_Qual_Usg_Id, p_Qual_Usg_Id_New);
   FETCH c_pri_int_upd_list BULK COLLECT INTO l_terr_val_ids_arr;
   IF (NVL(l_terr_val_ids_arr.COUNT,0) > 0) THEN
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Primary Interest Codes: Rows to be migrated: ' || l_terr_val_ids_arr.COUNT);
      end if;
      FORALL j IN l_terr_val_ids_arr.FIRST..l_terr_val_ids_arr.LAST
         UPDATE jtf_terr_values_all jtv
         SET    (value1_id, value2_id) =
                                         (SELECT int.product_category_id, int.product_cat_set_id
                                          FROM   as_interest_codes_b int
                                          WHERE  jtv.primary_interest_code_id = int.interest_code_id)
         WHERE jtv.terr_value_id  = l_terr_val_ids_arr(j);
         if (upper(p_Debug_Flag) = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Primary Interest codes: Rows migrated: ' || SQL%ROWCOUNT);
         end if;
   ELSE
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Interest Types: Rows to be migrated: 0');
      end if;
   END IF;
   CLOSE c_pri_int_upd_list;

   if (upper(p_Debug_Flag) = 'Y') then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'End: Migrating Primary Interest Codes');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Start: Migrating Secondary Interest Codes');
   end if;

   -- Secondary Interest Codes
   OPEN c_sec_int_upd_list(p_Qual_Usg_Id, p_Qual_Usg_Id_New);
   FETCH c_sec_int_upd_list BULK COLLECT INTO l_terr_val_ids_arr;
   IF (NVL(l_terr_val_ids_arr.COUNT,0) > 0) THEN
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Secondary Interest Codes: Rows to be migrated: ' || l_terr_val_ids_arr.COUNT);
      end if;
      FORALL j IN l_terr_val_ids_arr.FIRST..l_terr_val_ids_arr.LAST
         UPDATE jtf_terr_values_all jtv
         SET    (value1_id, value2_id) =
                                         (SELECT int.product_category_id, int.product_cat_set_id
                                          FROM   as_interest_codes_b int
                                          WHERE  jtv.secondary_interest_code_id = int.interest_code_id)
         WHERE jtv.terr_value_id  = l_terr_val_ids_arr(j);
         if (upper(p_Debug_Flag) = 'Y') then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Secondary Interest Codes: Rows migrated: ' || SQL%ROWCOUNT);
         end if;
   ELSE
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Interest Types: Rows to be migrated: 0');
      end if;
   END IF;
   CLOSE c_sec_int_upd_list;

   if (upper(p_Debug_Flag) = 'Y') then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'End: Migrating Secondary Interest Codes');
   end if;

   if (p_Qual_Usg_Id = -1023) then

      --Update Qualifiers
      UPDATE jtf_terr_qual_all qual
      SET    qual_usg_id = -1142
      WHERE  qual_usg_id = -1023;
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated Qualifier Opportunity Expected Purchase to Opportunity Product Category');
      end if;

      --Disable usage of old qualifier
	  /*
	  commented out 07/10/2006, ref bug 5193133 replaced below
      UPDATE jtf_qual_usgs_all
      SET    enabled_flag = 'N'
      WHERE  qual_usg_id = -1023;
	  */

	  delete from jtf_seeded_qual_all_b
      where seeded_qual_id = -1024;

      delete from jtf_seeded_qual_all_tl
      where seeded_qual_id = -1024;

	  DELETE FROM jtf_qual_usgs_all
      WHERE  qual_usg_id = -1023;

      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Disabled Qualifier Opportunity Expected Purchase');
      end if;

      --Enable usage of new qualifier
      UPDATE jtf_qual_usgs_all
      SET    enabled_flag = 'Y'
      WHERE  qual_usg_id = -1142;
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Enabled Qualifier Opportunity Product Category');
      end if;

   elsif (p_Qual_Usg_Id = -1018) then
      UPDATE jtf_terr_qual_all qual
      SET    qual_usg_id = -1131
      WHERE  qual_usg_id = -1018;
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Updated Qualifier Lead Expected Purchase to Lead Product Category');
      end if;

      --Disable usage of old qualifier, lead expected
	  /*
	  commented out 07/10/2006, ref bug 5193133 replaced below
	  UPDATE jtf_qual_usgs_all
      SET    enabled_flag = 'N'
      WHERE  qual_usg_id = -1018;
	  */

	  delete from jtf_seeded_qual_all_b
      where seeded_qual_id = -1019;

      delete from jtf_seeded_qual_all_tl
      where seeded_qual_id = -1019;

	  DELETE FROM jtf_qual_usgs_all
      WHERE  qual_usg_id = -1018;

      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Disabled Qualifier Lead Expected Purchase');
      end if;

      UPDATE jtf_qual_usgs_all
      SET    enabled_flag = 'Y'
      WHERE  qual_usg_id = -1131;
      if (upper(p_Debug_Flag) = 'Y') then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Enabled Qualifier Lead Product Category');
      end if;

   end if;
   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      Rollback;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Product Catalog data migration: ' || SQLERRM);
      RAISE;
END Migrate_Product_Cat_Terr;

/* This procedure migrates interest types in the JTF_TTY_ROLE_PROD_INT table */
PROCEDURE Migrate_Product_Cat_Role(p_Debug_Flag IN VARCHAR2 Default 'N') IS

BEGIN

   if (upper(p_Debug_Flag) = 'Y') then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Start: Migrating Interest Types in JTF_TTY_ROLE_PROD_INT table');
   end if;

   UPDATE jtf_tty_role_prod_int jtr
   SET    (product_category_id, product_category_set_id) =
                                                            (SELECT int.product_category_id, int.product_cat_set_id
                                                             FROM   as_interest_types_b int
                                                             WHERE  jtr.interest_type_id = int.interest_type_id);
   COMMIT;

   if (upper(p_Debug_Flag) = 'Y') then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'End: Migrating Interest Types in JTF_TTY_ROLE_PROD_INT table');
   end if;

EXCEPTION
   WHEN OTHERS THEN
      Rollback;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Product Catalog data migration: ' || SQLERRM);
      RAISE;
END Migrate_Product_Cat_Role;

END JTF_TTY_PROD_CAT_MIGRATE_PVT;


/
