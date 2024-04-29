--------------------------------------------------------
--  DDL for Package Body EC_MAPPING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EC_MAPPING_UTILS" AS
-- $Header: ECMAPUTB.pls 120.2 2005/09/29 10:50:29 arsriniv ship $

   TYPE t_layout_record IS RECORD(
      interface_column_id     ece_interface_columns.interface_column_id%TYPE,
      record_number           ece_interface_columns.record_number%TYPE,
      position                ece_interface_columns.position%TYPE,
      width                   ece_interface_columns.width%TYPE,
      conversion_sequence     ece_interface_columns.conversion_sequence%TYPE,
      record_layout_code      ece_interface_columns.record_layout_code%TYPE,
      record_layout_qualifier ece_interface_columns.record_layout_qualifier%TYPE);

   CURSOR c_external_levels_upg(xMap_ID NUMBER) IS
      SELECT external_level_id
      FROM   ece_external_levels_upg
      WHERE  map_id = xMap_ID;

   CURSOR c_interface_columns_upg(xMap_ID NUMBER) IS
      SELECT eicu.interface_column_id  interface_column_id
      FROM   ece_interface_cols_upg    eicu,
             ece_interface_tbls_upg    eitu
      WHERE  eicu.interface_table_id = eitu.interface_table_id AND
             eitu.map_id = xMap_ID;

   CURSOR c_interface_tables_upg(xMap_ID NUMBER) IS
      SELECT interface_table_id
      FROM   ece_interface_tbls_upg
      WHERE  map_id = xMap_ID;

   CURSOR c_maps (xTransactionType ece_interface_tables.transaction_type%TYPE,
                  xMapType         ece_mappings.map_type%TYPE) IS
      SELECT map_id,
             map_code
      FROM   ece_mappings
      WHERE  transaction_type = xTransactionType AND
             map_type         = NVL(xMapType,map_type);

   CURSOR c_maps_upg(xTransactionType ece_interface_tables.transaction_type%TYPE,
                     xMapType         ece_mappings.map_type%TYPE) IS
      SELECT map_id,
             map_code
      FROM   ece_mappings_upg
      WHERE  transaction_type = xTransactionType AND
             map_type         = NVL(xMapType,map_type);

   CURSOR c_process_rules(xMap_ID NUMBER) IS
      SELECT rule_type,
             action_code
      FROM   ece_process_rules
      WHERE  map_id = xMap_ID;

   CURSOR c_process_rules_upg(xMap_ID NUMBER) IS
      SELECT rule_type,
             action_code
      FROM   ece_process_rules_upg
      WHERE  map_id = xMap_ID;

   CURSOR c_tran_stage_data_upg(xMap_ID NUMBER) IS
      SELECT transtage_id
      FROM   ece_tran_stage_data_upg
      WHERE  map_id = xMap_ID;

   --Return map_id based on map_code
   FUNCTION ec_get_map_id(
      xMapCode          IN ece_mappings.map_code%TYPE,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') RETURN NUMBER AS

      iMap_ID           NUMBER;

      BEGIN
         IF  xUpgradeFlag = 'Y' THEN
            SELECT map_id INTO iMap_ID
            FROM   ece_mappings_upg
            WHERE  map_code = xMapCode;
         ELSE
            SELECT map_id INTO iMap_ID
            FROM   ece_mappings
            WHERE  map_code = xMapCode;
         END IF;

         RETURN iMap_ID;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;

      END ec_get_map_id;

   --Return map_code based on map_id
   FUNCTION ec_get_map_code(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') RETURN ece_mappings.map_code%TYPE AS

      cMapCode          ece_mappings.map_code%TYPE;

      BEGIN
         IF  xUpgradeFlag = 'Y' THEN
            SELECT map_code INTO cMapCode
            FROM   ece_mappings_upg
            WHERE  map_id = xMap_ID;
         ELSE
            SELECT map_code INTO cMapCode
            FROM   ece_mappings
            WHERE  map_id = xMap_ID;
         END IF;

         RETURN cMapCode;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;

      END ec_get_map_code;

   FUNCTION ec_get_upgrade_map_id(
      xMap_ID           IN NUMBER) RETURN NUMBER AS

      iMap_ID           NUMBER;

      BEGIN
         SELECT ecmu.map_id INTO iMap_ID
         FROM   ece_mappings_upg    ecmu,
                ece_mappings        ecm
         WHERE  ecmu.map_code = ecm.map_code AND
                ecm.map_id = xMap_ID;

         RETURN iMap_ID;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;

      END ec_get_upgrade_map_id;

   FUNCTION ec_get_main_map_id(
      xMap_ID           IN NUMBER) RETURN NUMBER AS

      iMap_ID           NUMBER;

      BEGIN
         SELECT ecm.map_id INTO iMap_ID
         FROM   ece_mappings_upg    ecmu,
                ece_mappings        ecm
         WHERE  ecm.map_code = ecmu.map_code AND
                ecmu.map_id = xMap_ID;

         RETURN iMap_ID;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;

      END ec_get_main_map_id;

   --This procedure tells you whether your transaction has seed data
   --reconciliation pending or not.
   --U = Reconciliation Pending
   --N = Transaction Clean
   FUNCTION ec_get_trans_upgrade_status(
      xTransactionType  IN ece_interface_tables.transaction_type%TYPE,
      iMapId            IN ece_interface_tables.map_id%TYPE) RETURN VARCHAR2 AS

      cUpgradedFlag     ece_interface_tables.upgraded_flag%TYPE;

      BEGIN
         SELECT NVL(upgraded_flag,'N') INTO cUpgradedFlag
         FROM   ece_interface_tables
         WHERE  transaction_type = xTransactionType AND
                map_id           = iMapId AND
                ROWNUM           = 1;

         IF cUpgradedFlag = 'Y' THEN
            RETURN 'U';
         ELSE
            RETURN 'N';
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;

      END ec_get_trans_upgrade_status;

   FUNCTION ec_get_trans_upgrade_status(
      xTransactionType  IN ece_interface_tables.transaction_type%TYPE) RETURN VARCHAR2 AS

      cUpgradedFlag     ece_interface_tables.upgraded_flag%TYPE;

      BEGIN
         SELECT NVL(upgraded_flag,'N') INTO cUpgradedFlag
         FROM   ece_interface_tables
         WHERE  transaction_type = xTransactionType AND
                ROWNUM            = 1;

         IF cUpgradedFlag = 'Y' THEN
            RETURN 'U';
         ELSE
            RETURN 'N';
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;

      END ec_get_trans_upgrade_status;

   PROCEDURE ec_upgrade_code_cat(
      xInterface_Column_ID_Main  IN NUMBER,
      xInterface_Column_ID_Upg   IN NUMBER) IS

      iXref_Category_ID          NUMBER;
      iKey1                      ece_interface_columns.xref_key1_source_column%TYPE;
      iKey2                      ece_interface_columns.xref_key2_source_column%TYPE;
      iKey3                      ece_interface_columns.xref_key3_source_column%TYPE;
      iKey4                      ece_interface_columns.xref_key4_source_column%TYPE;
      iKey5                      ece_interface_columns.xref_key5_source_column%TYPE;

      BEGIN
         SELECT xref_category_id,
                xref_key1_source_column,
                xref_key2_source_column,
                xref_key3_source_column,
                xref_key4_source_column,
                xref_key5_source_column
         INTO   iXref_Category_ID,
                iKey1,
                iKey2,
                iKey3,
                iKey4,
                iKey5
         FROM   ece_interface_columns
         WHERE  interface_column_id = xInterface_Column_ID_Main;

         IF iXref_Category_ID IS NOT NULL THEN
            UPDATE ece_interface_cols_upg
            SET    xref_category_id          = iXref_Category_ID,
                   xref_key1_source_column   = iKey1,
                   xref_key2_source_column   = iKey2,
                   xref_key3_source_column   = iKey3,
                   xref_key4_source_column   = iKey4,
                   xref_key5_source_column   = iKey5
            WHERE  interface_column_id = xInterface_Column_ID_Upg;
            ec_debug.pl(0,'*Code Conversion Assignment found for this column and reconciled.');
         ELSE
            ec_debug.pl(0,'*No Code Conversion Assignment found for this column.');
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;

      END ec_upgrade_code_cat;

   PROCEDURE ec_upgrade_column_rules(
      xInterface_Column_ID_Main  IN NUMBER,
      xInterface_Column_ID_Upg   IN NUMBER) IS

      iCount                     NUMBER DEFAULT 0;

      CURSOR c_column_rules(xInterface_Column_ID NUMBER) IS
         SELECT   column_rule_id,
                  interface_column_id,
                  sequence,
                  rule_type,
                  action_code
         FROM     ece_column_rules
         WHERE    interface_column_id = xInterface_Column_ID
         ORDER BY sequence;

      BEGIN
         FOR v_column_rules IN c_column_rules(xInterface_Column_ID_Main) LOOP
            UPDATE ece_column_rules
            SET    interface_column_id = xInterface_Column_ID_Upg
            WHERE  column_rule_id      = v_column_rules.column_rule_id;
            --v_column_rules.interface_column_id := xInterface_Column_ID_Upg;
            ec_debug.pl(0,'*Column Rule Sequence: ' || v_column_rules.sequence || ', Rule Type: ' ||
                        v_column_rules.rule_type || ', Action Code: ' || v_column_rules.action_code ||
                        ' found and reconciled for this column.');
            iCount := iCount + 1;
         END LOOP;

         IF iCount = 0 THEN
            ec_debug.pl(0,'*This column has no Column Rules assigned.');
         END IF;

      END ec_upgrade_column_rules;

   PROCEDURE ec_upgrade_layout(
      xMap_ID_Upg                IN NUMBER,
      xUpgrade_Column_Rules_Flag IN VARCHAR2,
      xUpgrade_Code_Cat_Flag     IN VARCHAR2) IS

      iCount            NUMBER DEFAULT 0;
      iMap_ID_Main      NUMBER;
      v_layout_record   t_layout_record;
      xDirection        ece_interface_tables.direction%type;
      xExt_Col_Count    number;

/* Bug 2138714 Removed the nvl conditions on Record no,position,width,conversion_sequence */

      CURSOR c_interface_columns_layout_upg(xMap_ID NUMBER) IS
         SELECT   eitu.interface_table_id                interface_table_id,
                  eitu.interface_table_name              interface_table_name,
                  eitu.output_level                      output_level,
                  eicu.interface_column_id               interface_column_id,
                  eicu.interface_column_name             interface_column_name,
                  eicu.record_number                     record_number,
                  eicu.position                      position,
                  eicu.width                     width,
                  eicu.conversion_sequence       conversion_sequence,
                  NVL(eicu.record_layout_code,' ')       record_layout_code,
                  NVL(eicu.record_layout_qualifier,' ')  record_layout_qualifier
         FROM     ece_interface_cols_upg        eicu,
                  ece_interface_tbls_upg        eitu
         WHERE    eicu.interface_table_id       = eitu.interface_table_id AND
                  eitu.map_id                   = xMap_ID AND
                  eicu.interface_column_name    IS NOT NULL
         ORDER BY TO_NUMBER(eitu.output_level),
                  eicu.interface_column_name;

      CURSOR c_interface_columns_dups_upg(xMap_ID NUMBER) IS
         SELECT   TO_NUMBER(eitu.output_level)  output_level,
                  eicu.record_number            record_number,
                  eicu.position                 position,
                  eitu.map_id                   map_id,
                  COUNT(*)                      count
         FROM     ece_interface_cols_upg        eicu,
                  ece_interface_tbls_upg        eitu
         WHERE    eitu.map_id                   = xMap_ID AND
                  eitu.interface_table_id       = eicu.interface_table_id AND
                  eicu.record_number            IS NOT NULL AND --These lines are used to filter out unmapped
                  eicu.position                 IS NOT NULL     --records which are not true duplicates.
         GROUP BY eicu.record_number,
                  eicu.position,
                  eitu.map_id,
                  TO_NUMBER(eitu.output_level)
         HAVING   COUNT(*) > 1
         ORDER BY TO_NUMBER(eitu.output_level),
                  eicu.record_number,
                  eicu.position;

      CURSOR c_interface_tables_upg2(xMap_ID NUMBER) IS
         SELECT   eitu.interface_table_id       interface_table_id,
                  eitu.output_level             output_level,
                  eitu.map_id                   map_id
         FROM     ece_interface_tbls_upg        eitu
         WHERE    eitu.map_id                   = xMap_ID;

      BEGIN
         iMap_ID_Main := ec_get_main_map_id(xMap_ID_Upg);

         FOR v_interface_columns_layout_upg IN c_interface_columns_layout_upg(xMap_ID_Upg) LOOP
	 --Loop through ece_interface_cols_upg
            BEGIN
               --Look for matching Interface Column Name
/* Bug 2138714 Removed the nvl conditions on Record no,position,width,conversion_sequence */

               SELECT   eic.interface_column_id,
                        eic.record_number,
                        eic.position,
                        eic.width,
                        eic.conversion_sequence,
                        NVL(eic.record_layout_code,' '),
                        NVL(eic.record_layout_qualifier,' ')
               INTO     v_layout_record
               FROM     ece_interface_columns   eic,
                        ece_interface_tables    eit
               WHERE    eic.interface_table_id = eit.interface_table_id AND
                        eit.map_id = iMap_ID_Main AND
                        eit.output_level = v_interface_columns_layout_upg.output_level AND
                        eic.interface_column_name = v_interface_columns_layout_upg.interface_column_name;
			--AND ROWNUM = 2;

               ec_debug.pl(0,'*****Column: "' || v_interface_columns_layout_upg.interface_column_name || '"');

               --Reconcile Column Rules?
               IF xUpgrade_Column_Rules_Flag = 'Y' THEN
                  ec_debug.pl(0,'*Checking to see if any Column Rules need to be reconciled...');
                  ec_upgrade_column_rules(v_layout_record.interface_column_id,v_interface_columns_layout_upg.interface_column_id); --(Main,Upgrade)
               ELSE
                  ec_debug.pl(0,'*Column Rule Reconciliation not enabled.');
               END IF;

               --Reconcile Code Conversion Categories?
               IF xUpgrade_Code_Cat_Flag = 'Y' THEN
                  ec_debug.pl(0,'*Checking to see if any Code Conversion Assignments need to be reconciled...');
                  ec_upgrade_code_cat(v_layout_record.interface_column_id,v_interface_columns_layout_upg.interface_column_id); --(Main,Upgrade)
               ELSE
                  ec_debug.pl(0,'*Code Conversion Assignment Reconciliation not enabled.');
               END IF;

               --Do the Record Number and Position match?
               IF v_layout_record.record_number = v_interface_columns_layout_upg.record_number AND
                  v_layout_record.position      = v_interface_columns_layout_upg.position THEN
                  ec_debug.pl(0,'*Record Number and Position for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' unchanged.');
               ELSE
                  ec_debug.pl(0,'*Record Number and Position for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' changed to ' ||
                              v_interface_columns_layout_upg.record_number || '/' || v_interface_columns_layout_upg.position ||
                              '. old Record Number and Position: ' || v_layout_record.record_number || '/' || v_layout_record.position ||
                              ' will be preserved.');

                  UPDATE ece_interface_cols_upg
                  SET    record_number = v_layout_record.record_number,
                         position      = v_layout_record.position
                  WHERE  interface_column_id = v_interface_columns_layout_upg.interface_column_id;
                  --v_interface_columns_layout_upg.record_number := v_layout_record.record_number;
                  --v_interface_columns_layout_upg.position := v_layout_record.position;
               END IF;

               --Does the Width Match?
               IF v_layout_record.width = v_interface_columns_layout_upg.width THEN
                  ec_debug.pl(0,'*Width for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' unchanged.');
               ELSE
                  ec_debug.pl(0,'*Width for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' changed to ' ||
                              v_interface_columns_layout_upg.width || '. old Width: ' || v_layout_record.width || ' will be preserved.');
                  UPDATE ece_interface_cols_upg
                  SET    width = v_layout_record.width
                  WHERE  interface_column_id = v_interface_columns_layout_upg.interface_column_id;
                  --v_interface_columns_layout_upg.width := v_layout_record.width;
               END IF;

               --Does Conversion Sequence Match?
               IF v_layout_record.conversion_sequence= v_interface_columns_layout_upg.conversion_sequence THEN
                  ec_debug.pl(0,'*Conversion Sequence for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' unchanged.');
               ELSE
                  ec_debug.pl(0,'*Conversion Sequence for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' changed to ' ||
                              v_interface_columns_layout_upg.conversion_sequence || '. old Conversion Sequence: ' ||
                              v_layout_record.conversion_sequence || ' will be preserved.');
                  UPDATE ece_interface_cols_upg
                  SET    conversion_sequence = v_layout_record.conversion_sequence
                  WHERE  interface_column_id = v_interface_columns_layout_upg.interface_column_id;
                  --v_interface_columns_layout_upg.conversion_sequence := v_layout_record.conversion_sequence;
               END IF;

               --Does Record Layout Code Match?
               IF v_layout_record.record_layout_code= v_interface_columns_layout_upg.record_layout_code THEN
                  ec_debug.pl(0,'*Record Layout Code for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' unchanged.');
               ELSE
                  ec_debug.pl(0,'*Record Layout Code for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' changed to ' ||
                              v_interface_columns_layout_upg.record_layout_code || '. old Record Layout Code: ' ||
                              v_layout_record.record_layout_code || ' will be preserved.');
                  UPDATE ece_interface_cols_upg
                  SET    record_layout_code = v_layout_record.record_layout_code
                  WHERE  interface_column_id = v_interface_columns_layout_upg.interface_column_id;
                  --v_interface_columns_layout_upg.record_layout_code := v_layout_record.record_layout_code;
               END IF;

               --Does Record Layout Qualifier Match?
               IF v_layout_record.record_layout_qualifier= v_interface_columns_layout_upg.record_layout_qualifier THEN
                  ec_debug.pl(0,'*Record Layout Qualifier for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' unchanged.');
               ELSE
                  ec_debug.pl(0,'*Record Layout Qualifier for Column: "' || v_interface_columns_layout_upg.interface_column_name ||
                              '" at Output Level: ' || v_interface_columns_layout_upg.output_level || ' changed to ' ||
                              v_interface_columns_layout_upg.record_layout_qualifier || '. old Record Layout Qualifier: ' ||
                              v_layout_record.record_layout_qualifier || ' will be preserved.');
                  UPDATE ece_interface_cols_upg
                  SET    record_layout_qualifier = v_layout_record.record_layout_qualifier
                  WHERE  interface_column_id = v_interface_columns_layout_upg.interface_column_id;
                  --v_interface_columns_layout_upg.record_layout_qualifier := v_layout_record.record_layout_qualifier;
               END IF;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  --This must be a new column in new seed data since no matching column name was found in
                  --old seed data.
                  ec_debug.pl(0,'*New column found: "' || v_interface_columns_layout_upg.interface_column_name || '".');

            END;

         END LOOP;

	 -- 2839189
	 -- The following preserves custom columns for Transactions using
	 -- the 11.0 architechure.
	 BEGIN
           select direction
	   into   xDirection
           from ece_interface_tables
           where map_id = iMap_ID_Main
	   and rownum=1;

           IF xDirection='OUT'  THEN

	    select count(*)
	    into  xExt_Col_Count
	    from  ece_interface_columns
	    where record_number like '_9__'
	    and   map_id = iMap_ID_Main;

	     ec_debug.pl(0,'xExt_Col_Count',xExt_Col_Count);

            IF xExt_Col_Count >0 THEN
              FOR v_interface_tables_upg IN c_interface_tables_upg2(xMap_ID_Upg)
	      LOOP

                INSERT INTO ece_interface_cols_upg(
                     interface_column_id,
                     interface_table_id,
                     interface_column_name,
                     base_table_name,
                     base_column_name,
                     table_name,
                     column_name,
                     record_number,
                     position,
                     width,
                     data_type,
                     conversion_sequence,
                     record_layout_code,
                     record_layout_qualifier,
                     conversion_group_id,
                     xref_category_allowed,
                     xref_category_id,
                     xref_key1_source_column,
                     xref_key2_source_column,
                     xref_key3_source_column,
                     xref_key4_source_column,
                     xref_key5_source_column,
                     external_level,
                     map_id,
                     creation_date,
                     created_by,
                     last_update_date,
                     last_updated_by,
                     last_update_login)
                     SELECT   ece_interface_column_id_s.NEXTVAL,
                              v_interface_tables_upg.interface_table_id,
                              eic.interface_column_name,
                              eic.base_table_name,
                              eic.base_column_name,
                              eic.table_name,
                              eic.column_name,
                              eic.record_number,
                              eic.position,
                              eic.width,
                              eic.data_type,
                              eic.conversion_sequence,
                              eic.record_layout_code,
                              eic.record_layout_qualifier,
                              eic.conversion_group_id,
                              eic.xref_category_allowed,
                              eic.xref_category_id,
                              eic.xref_key1_source_column,
                              eic.xref_key2_source_column,
                              eic.xref_key3_source_column,
                              eic.xref_key4_source_column,
                              eic.xref_key5_source_column,
                              eic.external_level,
                              v_interface_tables_upg.map_id,
                              SYSDATE,
                              1,
                              SYSDATE,
                              1,
                              1
               FROM     ece_interface_columns eic,
                        ece_interface_tables eit
               WHERE    eic.map_id=iMap_ID_Main
               AND      eic.record_number like '_9__'
               AND      eic.interface_table_id = eit.interface_table_id
	       AND	eic.map_id = eit.map_id
               AND      eit.output_level = v_interface_tables_upg.output_level
	       AND      eic.interface_column_name not in(select interface_column_name
						         from ece_interface_cols_upg
							 where record_number like '_9__'
							 and map_id=v_interface_tables_upg.map_id);
	      END LOOP;
              ec_debug.pl(0,'Custom Columns are presevered');
	    ELSE
		ec_debug.pl(0,'No Custom Columns are present');
	    END IF;

	  END IF;
	 EXCEPTION
	   WHEN others THEN
		ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	 END;

         --Now that we're done looping through ece_interface_cols_upg table, let's check to see what Record Number
         --and Positions are now duplicated because of Reconciliation Process
         ec_debug.pl(0,'*****Following Record Numbers and Positions are duplicated due to reconciliation process.');
         FOR v_interface_columns_dups_upg IN c_interface_columns_dups_upg(xMap_ID_Upg) LOOP
            ec_debug.pl(0,'Output Level: ' || v_interface_columns_dups_upg.output_level ||
                        ', Record Number: ' || v_interface_columns_dups_upg.record_number ||
                        ', Position: ' || v_interface_columns_dups_upg.position || '.');
            iCount := iCount + 1;
         END LOOP;

         IF iCount = 0 THEN
            ec_debug.pl(0,'*****There were no duplicate Record Numbers and Positions.');
         END IF;

      END ec_upgrade_layout;

   PROCEDURE ec_upgrade_process_rules(
      xMap_ID           IN NUMBER) IS --Upgrade Table Map_ID

      iMap_ID_Main      NUMBER;

      BEGIN
         iMap_ID_Main := ec_get_main_map_id(xMap_ID);

         FOR v_process_rules IN c_process_rules(iMap_ID_Main) LOOP
            UPDATE ece_process_rules_upg
            SET    action_code = v_process_rules.action_code
            WHERE  map_id = xMap_ID AND
                   rule_type = v_process_rules.rule_type;
         END LOOP;
      END ec_upgrade_process_rules;

   --Copy data from ECE_COLUMN_RULES_UPG to ECE_COLUMN_RULES.
   PROCEDURE ec_copy_column_rules(
      xMap_ID           IN NUMBER) AS

      BEGIN
         FOR v_interface_columns_upg IN c_interface_columns_upg(xMap_ID) LOOP
            INSERT INTO ece_column_rules(
               column_rule_id,
               interface_column_id,
               sequence,
               rule_type,
               action_code,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               request_id,
               program_application_id,
               program_id,
               program_update_date)
               SELECT   column_rule_id,
                        interface_column_id,
                        sequence,
                        rule_type,
                        action_code,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date
               FROM     ece_column_rules_upg
               WHERE    interface_column_id = v_interface_columns_upg.interface_column_id;
         END LOOP;

      END ec_copy_column_rules;

   --Copy data from ece_proc_mappings_upg to ECE_PROCEDURE_MAPPINGS and
   --          from ECE_TRAN_STAGE_DATA_UPG to ECE_TRAN_STAGE_DATA.
   PROCEDURE ec_copy_dynamic_actions(
      xMap_ID           IN NUMBER) AS

      BEGIN
         --Copy data in ece_proc_mappings_upg
         FOR v_tran_stage_data_upg IN c_tran_stage_data_upg(xMap_ID) LOOP
            INSERT INTO ece_procedure_mappings(
               procmap_id,
               transtage_id,
               parameter_name,
               action_type,
               variable_level,
               variable_name)
               SELECT   procmap_id,
                        transtage_id,
                        parameter_name,
                        action_type,
                        variable_level,
                        variable_name
               FROM     ece_proc_mappings_upg
               WHERE    transtage_id = v_tran_stage_data_upg.transtage_id;
         END LOOP;

         --Copy data in ECE_TRAN_STAGE_DATA_UPG
         INSERT INTO ece_tran_stage_data(
            transaction_type,
            transaction_level,
            stage,
            seq_number,
            action_type,
            variable_level,
            variable_name,
            variable_value,
            default_value,
            previous_variable_level,
            previous_variable_name,
            sequence_name,
            custom_procedure_name,
            data_type,
            function_name,
            next_variable_name,
            where_clause,
            map_id,
            transtage_id)
            SELECT   transaction_type,
                     transaction_level,
                     stage,
                     seq_number,
                     action_type,
                     variable_level,
                     variable_name,
                     variable_value,
                     default_value,
                     previous_variable_level,
                     previous_variable_name,
                     sequence_name,
                     custom_procedure_name,
                     data_type,
                     function_name,
                     next_variable_name,
                     where_clause,
                     map_id,
                     transtage_id
            FROM     ece_tran_stage_data_upg
            WHERE    map_id = xMap_ID;
      END ec_copy_dynamic_actions;

   PROCEDURE ec_copy_external_levels(
      xMap_ID           IN NUMBER) AS

      BEGIN
         INSERT INTO ece_external_levels(
            external_level_id,
            external_level,
            description,
            map_id,
            transaction_type,
            created_by,
            creation_date,
            last_update_login,
            last_update_date,
            last_updated_by,
            start_element,
            parent_level,
            enabled_flag)
            SELECT   external_level_id,
                     external_level,
                     description,
                     map_id,
                     transaction_type,
                     created_by,
                     creation_date,
                     last_update_login,
                     last_update_date,
                     last_updated_by,
                     start_element,
                     parent_level,
                     enabled_flag
            FROM     ece_external_levels_upg
            WHERE    map_id = xMap_ID;
      END ec_copy_external_levels;

   PROCEDURE ec_copy_interface_columns(
      xMap_ID           IN NUMBER) AS

      BEGIN
         FOR v_interface_tables_upg IN c_interface_tables_upg(xMap_ID) LOOP
            INSERT INTO ece_interface_columns(
               interface_column_id,
               interface_table_id,
               interface_column_name,
               base_table_name,
               base_column_name,
               table_name,
               column_name,
               record_number,
               position,
               width,
               conversion_sequence,
               data_type,
               conversion_group_id,
               xref_category_allowed,
               xref_category_id,
               xref_key1_source_column,
               xref_key2_source_column,
               xref_key3_source_column,
               xref_key4_source_column,
               xref_key5_source_column,
               record_layout_code,
               record_layout_qualifier,
               data_loc_id,
               created_by,
               creation_date,
               last_update_login,
               last_update_date,
               last_updated_by,
               request_id,
               program_application_id,
               program_id,
               program_update_date,
               staging_column,
               element_tag_name,
               map_id,
               external_level)
               SELECT   interface_column_id,
                        interface_table_id,
                        interface_column_name,
                        base_table_name,
                        base_column_name,
                        table_name,
                        column_name,
                        record_number,
                        position,
                        width,
                        conversion_sequence,
                        data_type,
                        conversion_group_id,
                        xref_category_allowed,
                        xref_category_id,
                        xref_key1_source_column,
                        xref_key2_source_column,
                        xref_key3_source_column,
                        xref_key4_source_column,
                        xref_key5_source_column,
                        record_layout_code,
                        record_layout_qualifier,
                        data_loc_id,
                        created_by,
                        creation_date,
                        last_update_login,
                        last_update_date,
                        last_updated_by,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        staging_column,
                        element_tag_name,
                        map_id,
                        external_level
               FROM     ece_interface_cols_upg
               WHERE    interface_table_id = v_interface_tables_upg.interface_table_id;
         END LOOP;
      END ec_copy_interface_columns;

   PROCEDURE ec_copy_interface_tables(
      xMap_ID           IN NUMBER) AS

      BEGIN
         INSERT INTO ece_interface_tables(
            interface_table_id,
            transaction_type,
            output_level,
            interface_table_name,
            extension_table_name,
            key_column_name,
            start_number,
            created_by,
            creation_date,
            last_update_login,
            last_update_date,
            last_updated_by,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            flatfile_version,
            direction,
            primary_address_type,
            parent_level,
            installed_flag,
            map_id,
            enabled,
            upgraded_flag)
            SELECT   interface_table_id,
                     transaction_type,
                     output_level,
                     interface_table_name,
                     extension_table_name,
                     key_column_name,
                     start_number,
                     created_by,
                     creation_date,
                     last_update_login,
                     last_update_date,
                     last_updated_by,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     flatfile_version,
                     direction,
                     primary_address_type,
                     parent_level,
                     installed_flag,
                     map_id,
                     enabled,
                     upgraded_flag
            FROM     ece_interface_tbls_upg
            WHERE    map_id = xMap_ID;
      END ec_copy_interface_tables;

   PROCEDURE ec_copy_level_matrices(
      xMap_ID           IN NUMBER) AS

      BEGIN
         FOR v_external_levels IN c_external_levels_upg(xMap_ID) LOOP
            INSERT INTO ece_level_matrices(
               matrix_level_id,
               external_level_id,
               interface_table_id)
               SELECT   matrix_level_id,
                        external_level_id,
                        interface_table_id
               FROM     ece_level_matrices_upg
               WHERE    external_level_id = v_external_levels.external_level_id;
         END LOOP;
      END ec_copy_level_matrices;

   PROCEDURE ec_copy_mappings(
      xMap_ID           IN NUMBER) AS

      BEGIN
         INSERT INTO ece_mappings(
            map_id,
            description,
            map_type,
            transaction_type,
            root_element,
            enabled,
            map_code)
            SELECT   map_id,
                     description,
                     map_type,
                     transaction_type,
                     root_element,
                     enabled,
                     map_code
            FROM     ece_mappings_upg
            WHERE    map_id = xMap_ID;
      END ec_copy_mappings;

   PROCEDURE ec_copy_process_rules(
      xMap_ID           IN NUMBER) AS

      BEGIN
         INSERT INTO ece_process_rules(
            process_rule_id,
            transaction_type,
            rule_type,
            action_code,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            map_id)
            SELECT   process_rule_id,
                     transaction_type,
                     rule_type,
                     action_code,
                     creation_date,
                     created_by,
                     last_update_date,
                     last_updated_by,
                     last_update_login,
                     request_id,
                     program_application_id,
                     program_id,
                     program_update_date,
                     map_id
            FROM     ece_process_rules_upg
            WHERE    map_id = xMap_ID;
      END ec_copy_process_rules;

   --Copy all data for a given Map Code.
   PROCEDURE ec_copy_map_data_by_mapcode(
      xMapCode          IN ece_mappings.map_code%TYPE) AS

      iMap_ID           NUMBER;

      BEGIN
         iMap_ID := ec_get_map_id(xMapCode,'Y');

         ec_copy_dynamic_actions(iMap_ID);
         ec_copy_process_rules(iMap_ID);
         ec_copy_column_rules(iMap_ID);
         ec_copy_interface_columns(iMap_ID);
         ec_copy_interface_tables(iMap_ID);
         ec_copy_level_matrices(iMap_ID);
         ec_copy_external_levels(iMap_ID);
         ec_copy_mappings(iMap_ID);
      END ec_copy_map_data_by_mapcode;

   --Copy all data for a given Map ID.
   PROCEDURE ec_copy_map_data_by_mapid(
      xMap_ID           IN NUMBER) AS

      BEGIN
         ec_copy_dynamic_actions(xMap_ID);
         ec_copy_process_rules(xMap_ID);
         ec_copy_column_rules(xMap_ID);
         ec_copy_interface_columns(xMap_ID);
         ec_copy_interface_tables(xMap_ID);
         ec_copy_level_matrices(xMap_ID);
         ec_copy_external_levels(xMap_ID);
         ec_copy_mappings(xMap_ID);
      END ec_copy_map_data_by_mapid;

   --Copies all maps/data for a given transaction, optionally by Map Type.
   PROCEDURE ec_copy_map_data_by_trans(
      xTransactionType  IN ece_interface_tables.transaction_type%TYPE,
      xMapType          IN ece_mappings.map_type%TYPE) AS

      BEGIN
         FOR v_maps_upg IN c_maps_upg(xTransactionType,xMapType) LOOP
            ec_copy_map_data_by_mapid(v_maps_upg.map_id);
         END LOOP;
      END ec_copy_map_data_by_trans;

   --Deletes entries in ECE_COLUMN_RULES.
   PROCEDURE ec_delete_column_rules(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         IF xUpgradeFlag = 'Y' THEN
            DELETE FROM ece_column_rules_upg
            WHERE       interface_column_id IN (SELECT eic.interface_column_id
                                                FROM   ece_interface_cols_upg    eic,
                                                       ece_interface_tbls_upg     eit
                                                WHERE  eic.interface_table_id = eit.interface_table_id AND
                                                       eit.map_id             = xMap_ID);
         ELSE
            DELETE FROM ece_column_rules
            WHERE       interface_column_id IN (SELECT eic.interface_column_id
                                                FROM   ece_interface_columns     eic,
                                                       ece_interface_tables      eit
                                                WHERE  eic.interface_table_id = eit.interface_table_id AND
                                                       eit.map_id             = xMap_ID);
         END IF;
      END ec_delete_column_rules;

   --Deletes from ECE_TRAN_STAGE_DATA and ECE_PROCEDURE_MAPPINGS
   PROCEDURE ec_delete_dynamic_action(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         IF xUpgradeFlag = 'Y' THEN
            DELETE FROM ece_proc_mappings_upg
            WHERE       transtage_id IN (SELECT transtage_id
                                         FROM   ece_tran_stage_data_upg
                                         WHERE  map_id = xMap_ID);
            DELETE FROM ece_tran_stage_data_upg
            WHERE       map_id = xMap_ID;
         ELSE
            DELETE FROM ece_procedure_mappings
            WHERE       transtage_id IN (SELECT transtage_id
                                         FROM   ece_tran_stage_data
                                         WHERE  map_id = xMap_ID);
            DELETE FROM ece_tran_stage_data
            WHERE       map_id = xMap_ID;
         END IF;
      END ec_delete_dynamic_action;

   --Deletes entries in ECE_EXTERNAL_LEVELS.
   PROCEDURE ec_delete_external_levels(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         IF xUpgradeFlag = 'Y' THEN
            DELETE FROM ece_external_levels_upg
            WHERE       map_id = xMap_ID;
         ELSE
            DELETE FROM ece_external_levels
            WHERE       map_id = xMap_ID;
         END IF;
      END ec_delete_external_levels;

   --Deletes from ECE_INTERFACE_COLUMNS.
   --WARNING: If you're going to delete from ECE_COLUMN_RULES, do that first or the
   --         records in that table will become orphaned!
   PROCEDURE ec_delete_interface_columns(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS
      BEGIN
        IF xUpgradeFlag = 'Y' THEN
            DELETE FROM ece_interface_cols_upg
            WHERE       interface_table_id IN (SELECT interface_table_id
                                               FROM   ece_interface_tbls_upg
                                               WHERE  map_id = xMap_ID);
         ELSE
            DELETE FROM ece_interface_columns
            WHERE       interface_table_id IN (SELECT interface_table_id
                                               FROM   ece_interface_tables
                                               WHERE  map_id = xMap_ID);
         END IF;
      END ec_delete_interface_columns;

   --Deletes entries in ECE_INTERFACE_TABLES.
   PROCEDURE ec_delete_interface_tables(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         IF xUpgradeFlag = 'Y' THEN
            DELETE FROM ece_interface_tbls_upg
            WHERE       map_id = xMap_ID;
         ELSE
            DELETE FROM ece_interface_tables
            WHERE       map_id = xMap_ID;
         END IF;
      END ec_delete_interface_tables;

   --Deletes entries in ECE_LEVEL_MATRICES.
   PROCEDURE ec_delete_level_matrices(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         IF xUpgradeFlag = 'Y' THEN
            DELETE FROM ece_level_matrices_upg
            WHERE       external_level_id IN (SELECT external_level_id
                                              FROM   ece_external_levels_upg
                                              WHERE  map_id = xMap_ID);
         ELSE
            DELETE FROM ece_level_matrices
            WHERE       external_level_id IN (SELECT external_level_id
                                              FROM   ece_external_levels
                                              WHERE  map_id = xMap_ID);
         END IF;
      END ec_delete_level_matrices;

   --Deletes entries in ECE_MAPPINGS.
   PROCEDURE ec_delete_mappings(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         IF xUpgradeFlag = 'Y' THEN
            DELETE FROM ece_mappings_upg
            WHERE       map_id = xMap_ID;
         ELSE
            DELETE FROM ece_mappings
            WHERE       map_id = xMap_ID;
         END IF;
      END ec_delete_mappings;

   --Deletes entries in ECE_PROCESS_RULES.
   PROCEDURE ec_delete_process_rules(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         IF xUpgradeFlag = 'Y' THEN
            DELETE FROM ece_process_rules_upg
            WHERE       map_id = xMap_ID;
         ELSE
            DELETE FROM ece_process_rules
            WHERE       map_id = xMap_ID;
         END IF;
      END ec_delete_process_rules;

   --Delete all data for a given Map Code.
   PROCEDURE ec_delete_map_data_by_mapcode(
      xMapCode          IN ece_mappings.map_code%TYPE,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      iMap_ID           NUMBER;

      BEGIN
         iMap_ID := ec_get_map_id(xMapCode,xUpgradeFlag);

         ec_delete_dynamic_action(iMap_ID,xUpgradeFlag);
         ec_delete_process_rules(iMap_ID,xUpgradeFlag);
         ec_delete_column_rules(iMap_ID,xUpgradeFlag);
         ec_delete_interface_columns(iMap_ID,xUpgradeFlag);
         ec_delete_interface_tables(iMap_ID,xUpgradeFlag);
         ec_delete_level_matrices(iMap_ID,xUpgradeFlag);
         ec_delete_external_levels(iMap_ID,xUpgradeFlag);
         ec_delete_mappings(iMap_ID,xUpgradeFlag);
      END ec_delete_map_data_by_mapcode;

   --Deletes all data for a given Map ID.
   PROCEDURE ec_delete_map_data_by_mapid(
      xMap_ID           IN NUMBER,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         ec_delete_dynamic_action(xMap_ID,xUpgradeFlag);
         ec_delete_process_rules(xMap_ID,xUpgradeFlag);
         ec_delete_column_rules(xMap_ID,xUpgradeFlag);
         ec_delete_interface_columns(xMap_ID,xUpgradeFlag);
         ec_delete_interface_tables(xMap_ID,xUpgradeFlag);
         ec_delete_level_matrices(xMap_ID,xUpgradeFlag);
         ec_delete_external_levels(xMap_ID,xUpgradeFlag);
         ec_delete_mappings(xMap_ID,xUpgradeFlag);
      END ec_delete_map_data_by_mapid;

   --Deletes all maps/data for a given transaction, optionally by Map Type.
   PROCEDURE ec_delete_map_data_by_trans(
      xTransactionType  IN ece_interface_tables.transaction_type%TYPE,
      xMapType          IN ece_mappings.map_type%TYPE,
      xUpgradeFlag      IN VARCHAR2 DEFAULT 'N') AS

      BEGIN
         IF xUpgradeFlag = 'Y' THEN
            FOR v_maps_upg IN c_maps_upg(xTransactionType,xMapType) LOOP
               ec_delete_map_data_by_mapid(v_maps_upg.map_id,xUpgradeFlag);
            END LOOP;
         ELSE
            FOR v_maps IN c_maps(xTransactionType,xMapType) LOOP
               ec_delete_map_data_by_mapid(v_maps.map_id,xUpgradeFlag);
            END LOOP;
         END IF;
      END ec_delete_map_data_by_trans;

   PROCEDURE ec_migrate_map_to_production(
      xMapCode          IN ece_mappings.map_code%TYPE,
      xTransExists      IN BOOLEAN) AS

      BEGIN
         --DELETE from PRODUCTION
         IF xTransExists = TRUE THEN
            ec_delete_map_data_by_mapcode(xMapCode,'N');
         END IF;

         --COPY from UPGRADE
         ec_copy_map_data_by_mapcode(xMapCode);

         --DELETE from UPGRADE
         ec_delete_map_data_by_mapcode(xMapCode,'Y');

      END ec_migrate_map_to_production;

   PROCEDURE ec_reconcile_seed(
      errbuf               OUT NOCOPY  VARCHAR2,
      retcode              OUT NOCOPY  VARCHAR2,
      transaction_type     IN    VARCHAR2,
      preserve_layout      IN    VARCHAR2,
      preserve_proc_rules  IN    VARCHAR2,
      preserve_col_rules   IN    VARCHAR2,
      preserve_cc_cat      IN    VARCHAR2,
      v_debug_mode         IN    NUMBER DEFAULT 3) IS

      n_map_count          NUMBER;
      n_staged_doc_count   NUMBER;
      iMap_ID_Main         NUMBER;

      b_trans_exists       BOOLEAN := FALSE;

      stage_doc_exception  EXCEPTION;

      BEGIN
         ec_debug.enable_debug(v_debug_mode);
         ec_debug.push('ec_mapping_utils.ec_reconcile_seed');
         ec_debug.pl(0,'transaction_type:    ',transaction_type);
         ec_debug.pl(0,'preserve_layout:     ',preserve_layout);
         ec_debug.pl(0,'preserve_proc_rules: ',preserve_proc_rules);
         ec_debug.pl(0,'preserve_col_rules:  ',preserve_col_rules);
         ec_debug.pl(0,'preserve_cc_cat:     ',preserve_cc_cat);
         ec_debug.pl(0,'v_debug_mode:        ',v_debug_mode);

         FOR v_maps_upg IN c_maps_upg(transaction_type,NULL) LOOP --Loop through each map for this transaction.
            ec_debug.pl(0,'Processing Map: ' || v_maps_upg.map_code);

            --Let's check to see if map exists in main tables...
            SELECT COUNT(*) INTO n_map_count
            FROM   ece_mappings
            WHERE  map_code =  v_maps_upg.map_code;

            IF n_map_count > 0 THEN
               b_trans_exists := TRUE;
            ELSE
               b_trans_exists := FALSE;
            END IF;

            IF b_trans_exists = TRUE THEN --We only need to check the staging table if the map exists...
               --Let's check to see if there is any data in staging table w/ map_id in question.
               iMap_ID_Main := ec_get_main_map_id(v_maps_upg.map_id);

               SELECT COUNT(*) INTO n_staged_doc_count
               FROM   ece_stage
               WHERE  map_id = iMap_ID_Main;

               IF n_staged_doc_count > 0 THEN --There are documents in staging table still. Abort.
                  RAISE stage_doc_exception;
               END IF;
            END IF;

            IF preserve_layout = 'N' OR b_trans_exists = FALSE THEN --Do a straight copy if map doesn't already exist
               IF (preserve_col_rules = 'Y' OR preserve_cc_cat = 'Y') AND b_trans_exists = TRUE THEN
                  ec_debug.pl(0,'*****Column Rules and Code Conversion Categories cannot be reconciled if Column Layout is not reconciled.');
               END IF;
            ELSE --Do preserve layout
               ec_upgrade_layout(
                  v_maps_upg.map_id,
                  preserve_col_rules,
                  preserve_cc_cat);

               IF preserve_col_rules = 'Y' THEN
                  ec_delete_column_rules(v_maps_upg.map_id,'Y');
               END IF;
            END IF;

            --Preserve Process Rule Actions?
            IF preserve_proc_rules = 'Y' AND b_trans_exists = TRUE THEN
               ec_upgrade_process_rules(v_maps_upg.map_id);
            END IF;

            IF b_trans_exists = TRUE THEN
               ec_remap_tp_details(v_maps_upg.map_id);
            END IF;

            ec_migrate_map_to_production(v_maps_upg.map_code,b_trans_exists);

         END LOOP;

         ec_debug.pop('ec_mapping_utils.ec_reconcile_seed');
         ec_debug.disable_debug;
         retcode := '0';
         COMMIT;

      EXCEPTION
         WHEN stage_doc_exception THEN
            ec_debug.pl(0,'*****There are still documents in staging table for this map. Aborting Reconciliation.');
            retcode := 1;
            ec_debug.disable_debug;
            ROLLBACK;

         WHEN OTHERS THEN
            --ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
            ROLLBACK;

      END ec_reconcile_seed;

   PROCEDURE ec_remap_tp_details(
      xMap_ID           IN NUMBER) AS --Upgrade Table Map_ID

      iMap_ID_Main      NUMBER;

      BEGIN
         iMap_ID_Main := ec_get_main_map_id(xMap_ID);

         UPDATE ece_tp_details
         SET    map_id = xMap_ID
         WHERE  map_id = iMap_ID_Main;
      END ec_remap_tp_details;

END;


/
