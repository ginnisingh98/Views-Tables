--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_OPEN_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_OPEN_INTERFACE_PVT" AS
/* $Header: EGOPOPIB.pls 120.39.12010000.8 2011/07/14 11:55:12 nendrapu ship $ */

  G_SUCCESS          CONSTANT  NUMBER  :=  0;
  G_WARNING          CONSTANT  NUMBER  :=  1;
  G_ERROR            CONSTANT  NUMBER  :=  2;

  PROCEDURE item_open_interface_process(
      ERRBUF            OUT NOCOPY VARCHAR2
     ,RETCODE           OUT NOCOPY VARCHAR2
     ,p_org_id          IN  NUMBER
     ,p_all_org         IN  NUMBER   := 1
     ,p_val_item_flag   IN  NUMBER   := 1
     ,p_pro_item_flag   IN  NUMBER   := 1
     ,p_del_rec_flag    IN  NUMBER   := 1
     ,p_xset_id         IN  NUMBER   := -999
     ,p_run_mode        IN  NUMBER   := 1
     ,p_prog_appid      IN  NUMBER   := -1
     ,p_prog_id         IN  NUMBER   := -1
     ,p_request_id      IN  NUMBER   := -1
     ,p_user_id         IN  NUMBER   := -1
     ,p_login_id        IN  NUMBER   := -1
     ,p_commit_flag     IN  NUMBER   := 1
     ,p_default_flag    IN  NUMBER   DEFAULT 1) IS

     l_retcode         VARCHAR2(100);
     l_source_system_id EGO_IMPORT_BATCHES_B.source_system_id%TYPE;
     l_import_xref_only EGO_IMPORT_OPTION_SETS.import_xref_only%TYPE;
     l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
     l_request_id       NUMBER;
     l_pro_flag_3    NUMBER;
     l_enabled_for_data_pool VARCHAR2(1);
     l_item_interface_rec EGO_IMPORT_USER_HOOKS.ITEM_INTERFACE_REC;

  BEGIN
    INV_EGO_REVISION_VALIDATE.Set_Process_Control('EGO_ITEM_BULKLOAD');
    RETCODE := G_SUCCESS;

    BEGIN
      SELECT batch.source_system_id, NVL(opt.import_xref_only,'N'), NVL(opt.ENABLED_FOR_DATA_POOL, 'N')
      INTO   l_source_system_id, l_import_xref_only, l_enabled_for_data_pool
      FROM   ego_import_batches_b batch
           ,ego_import_option_sets opt
      WHERE  batch.batch_id = p_xset_id
      AND    batch.batch_id = opt.batch_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_source_system_id := EGO_IMPORT_PVT.get_pdh_source_system_id;
        l_import_xref_only := 'N';
        l_enabled_for_data_pool := 'N';
    END;

    IF l_source_system_id <> EGO_IMPORT_PVT.get_pdh_source_system_id AND l_import_xref_only = 'Y' THEN
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_IMPORT_PVT.Process_SSXref_Intf_Rows');
      END IF;
      EGO_IMPORT_PVT.Process_SSXref_Intf_Rows(
          ERRBUF        => ERRBUF
         ,RETCODE       => l_retcode
         ,p_data_set_id => p_xset_id);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_IMPORT_PVT.Process_SSXref_Intf_Rows '||l_retcode);
        INVPUTLI.info(ERRBUF);
      END IF;
      -- Bug: 5565750
      IF ( p_commit_flag = 1 AND NVL(l_retcode, 0) IN (0, 1) ) THEN
        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('EGO_IMPORT_PVT.Process_SSXref_Intf_Rows => COMMITING');
          INVPUTLI.info(ERRBUF);
        END IF;
        COMMIT;
      END IF;
      RETCODE := l_retcode;
    ELSE --l_source_system_id <> EGO_IMPORT_PVT.get_pdh_source_system_id AND l_import_xref_only = 'Y' THEN
      --Adding this If condition as
      --Java concurrent program calls EGOPOPIB as PL/SQL
      --routine and not a concurrent request and passes
      --request id as parameter
      IF p_request_id = -1 OR p_request_id IS NULL THEN
        l_request_id := fnd_global.conc_request_id;
      ELSE
        l_request_id := p_request_id;
      END IF;

      -- Bug#8833123
      -- Calling the Item Import User Hooks
      l_item_interface_rec.org_id         := p_org_id;
      l_item_interface_rec.set_process_id := p_xset_id;
      l_item_interface_rec.request_id     := l_request_id;
      l_item_interface_rec.commit_flag    := p_commit_flag;

      EGO_IMPORT_USER_HOOKS.Default_LC_and_Item_Status
        (ERRBUF  => ERRBUF,
         RETCODE => l_retcode,
         p_item_interface_rec => l_item_interface_rec
        );

      IF l_retcode NOT IN (0, 1) THEN
        RETCODE := G_ERROR;
      END IF;

      -- IF batch is enabled for data pool, then calling IOI in validation mode
      -- and then calling Validate_Timestamp_In_Batch i.e. phase-2 validation
      IF l_enabled_for_data_pool = 'Y' AND NVL(p_pro_item_flag, 0) = 1 THEN
        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('Calling INVPOPIF.inopinp_open_interface_process in validation mode - run mode -> '||p_run_mode);
        END IF;
        l_retcode := INVPOPIF.inopinp_open_interface_process(
                       org_id         => p_org_id
                      ,all_org        => p_all_org
                      ,val_item_flag  => 1
                      ,pro_item_flag  => 2
                      ,del_rec_flag   => 2
                      ,prog_appid     => p_prog_appid
                      ,prog_id        => fnd_global.conc_program_id
                      ,request_id     => l_request_id
                      ,user_id        => p_user_id
                      ,login_id       => fnd_global.conc_login_id
                      ,xset_id        => p_xset_id
                      ,commit_flag    => p_commit_flag
                      ,run_mode       => p_run_mode
                      ,err_text       => ERRBUF);

        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info(' RETCODE for INVPOPIF.inopinp_open_interface_process in validation mode - run mode -> '||p_run_mode ||':'||l_retcode);
          INVPUTLI.info(ERRBUF);
        END IF;

        IF l_retcode NOT IN (0, 1) THEN
          RETCODE := G_ERROR;
        END IF;

        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('Calling EGO_IMPORT_UTIL_PVT.Validate_Timestamp_In_Batch');
        END IF;

        EGO_IMPORT_UTIL_PVT.Validate_Timestamp_In_Batch(
            RETCODE      => l_retcode
           ,ERRBUF       => ERRBUF
           ,p_batch_id   => p_xset_id);

        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info(' RETCODE for EGO_IMPORT_UTIL_PVT.Validate_Timestamp_In_Batch - '||l_retcode);
          INVPUTLI.info(ERRBUF);
        END IF;

        IF l_retcode NOT IN (0, 1) THEN
          RETCODE := G_ERROR;
        END IF;
      END IF; --IF l_enabled_for_data_pool = 'Y' THEN

      -- Call INV Item open interface.
      -- Note: Categories prg is called from INV IOI
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling INVPOPIF.inopinp_open_interface_process - run mode -> '||p_run_mode);
      END IF;
      l_retcode := INVPOPIF.inopinp_open_interface_process(
                     org_id         => p_org_id
                    ,all_org        => p_all_org
                    ,val_item_flag  => p_val_item_flag
                    ,pro_item_flag  => p_pro_item_flag
                    ,del_rec_flag   => p_del_rec_flag
                    ,prog_appid     => p_prog_appid
                    ,prog_id        => fnd_global.conc_program_id
                    ,request_id     => l_request_id
                    ,user_id        => p_user_id
                    ,login_id       => fnd_global.conc_login_id
                    ,xset_id        => p_xset_id
                    ,default_flag   => p_default_flag
                    ,commit_flag    => p_commit_flag
                    ,run_mode       => p_run_mode
                    ,err_text       => ERRBUF);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info(' RETCODE for INVPOPIF.inopinp_open_interface_process - run mode -> '||p_run_mode ||':'||l_retcode);
        INVPUTLI.info(ERRBUF);
      END IF;

      IF l_retcode NOT IN (0, 1) THEN
        /* Bug 5257590 - Checking for run time exceptions so status can be set to ERROR */
        RETCODE := G_ERROR;
      ELSE
	      /* Bug 5257590 - Checking for validation errors so status can be set to WARNING */
        -- Bug: 5529588 - performance issue. Re-writing sql.
        BEGIN
          SELECT 1 INTO l_pro_flag_3
          FROM mtl_system_items_interface
          WHERE process_flag = 3
            AND request_id = l_request_id
            AND set_process_id = p_xset_id
            AND rownum = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          l_pro_flag_3 := 0;
        END;

      /* bug 12603272 if no row in mtl_system_items_interface marks as error status, check mtl_item_revisions_interface */
      IF l_inv_debug_level IN(101, 102) THEN
      	INVPUTLI.info('l_pro_flag_3 from table mtl_system_items_interface ' || l_pro_flag_3 );
      END IF;

      if l_pro_flag_3  = 0 then
       SELECT count(*) INTO l_pro_flag_3
       FROM mtl_item_revisions_interface
       WHERE process_flag = 3
        AND request_id = l_request_id
        AND rownum = 1;
	       IF l_inv_debug_level IN(101, 102) THEN
	       	INVPUTLI.info('l_pro_flag_3 from table mtl_item_revisions_interface ' || l_pro_flag_3 );
	       END IF;
    	end if ;

        IF l_pro_flag_3 > 0 THEN
          IF l_inv_debug_level IN(101, 102) THEN
        		INVPUTLI.info('Validation errors occured during Import Items from EGO_ITEM_OPEN_INTERFACE_PVT.item_open_interface_process' );
        	END IF;
          ERRBUF  := 'Validation errors occured during Import Item';
          RETCODE := G_WARNING;
        ELSE
          RETCODE := G_SUCCESS;
        END IF;

	    END IF; --IF l_retcode NOT IN (0, 1) THEN
    END IF; -- Xref import only

    INV_EGO_REVISION_VALIDATE.Set_Process_Control(NULL);
    --Now returning the highest status recieved and stored in l_retcode
  EXCEPTION
    WHEN OTHERS THEN
      INV_EGO_REVISION_VALIDATE.Set_Process_Control(NULL);
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('WHEN-OTHERS-EXCEPTION item_open_interface_process: ' ||SQLCODE);
        INVPUTLI.info(SQLERRM);
      END IF;
      ERRBUF  := 'Unexpected error in item_open_interface_process: '||SQLERRM;
      RETCODE := G_ERROR;
  END item_open_interface_process;

  --4717744 : All item entities in a new prg
  PROCEDURE process_item_entities(
      ERRBUF            OUT     NOCOPY VARCHAR2
     ,RETCODE           OUT     NOCOPY VARCHAR2
     ,p_del_rec_flag    IN             NUMBER   := 1
     ,p_xset_id         IN             NUMBER   := -999
     ,p_request_id      IN             NUMBER   := -1
     ,p_call_uda_process IN            BOOLEAN  DEFAULT TRUE   -- Bug 12635842
		 ) IS

    CURSOR c_get_revisions IS
        SELECT intf.inventory_item_id
              ,intf.organization_id
              ,intf.revision_id
              ,intf.revision
        FROM   mtl_item_revisions_interface intf
        WHERE  intf.set_process_id   = p_xset_id
        AND    intf.transaction_type = 'CREATE'
	      AND    intf.request_id       = p_request_id
        AND    intf.process_flag     = 7
	AND    intf.revision_id is not null
	/* Bug 7675166 added this validation as revision_id is passed as null	   in case new revision needs to be created with existing items for item effective AG from excel*/
        AND    NOT EXISTS (SELECT NULL
                           FROM   mtl_parameters param
                           WHERE  param.organization_id   =  intf.organization_id
                           AND    param.starting_revision =  intf.revision);

    CURSOR c_get_effective_revision(cp_inventory_item_id NUMBER
                                   ,cp_organization_id   NUMBER
                                   ,cp_revision          VARCHAR2) IS
      SELECT revision_id
      FROM   mtl_item_revisions_b
      WHERE  inventory_item_id = cp_inventory_item_id
        AND    organization_id   = cp_organization_id
        AND    revision          < cp_revision
        AND    implementation_date IS NOT NULL
        AND    effectivity_date  <= sysdate
      ORDER BY effectivity_date desc;

      l_source_revision_id      mtl_item_revisions_b.revision_id%TYPE;
      l_return_status           VARCHAR2(100);
      l_error_code              NUMBER;
      l_msg_count               NUMBER  ;
      l_msg_data                VARCHAR2(100);
      l_pk_item_pairs           EGO_COL_NAME_VALUE_PAIR_ARRAY;
      l_pk_item_rev_pairs_src   EGO_COL_NAME_VALUE_PAIR_ARRAY;
      l_pk_item_rev_pairs_dst   EGO_COL_NAME_VALUE_PAIR_ARRAY;

      l_temp_message    VARCHAR2(2000);
      l_retcode         VARCHAR2(100);
      l_source_system_id EGO_IMPORT_BATCHES_B.source_system_id%TYPE;
      l_import_xref_only EGO_IMPORT_OPTION_SETS.import_xref_only%TYPE;
      l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
      err_msg          VARCHAR2(300);  --Bug: 5473796
      l_batch_id        NUMBER := p_xset_id;
      l_enabled_for_data_pool  VARCHAR2(1);
  BEGIN
    BEGIN
      SELECT batch.source_system_id, NVL(opt.import_xref_only,'N'), NVL(opt.ENABLED_FOR_DATA_POOL,'N')
      INTO   l_source_system_id, l_import_xref_only, l_enabled_for_data_pool
      FROM   ego_import_batches_b batch
           ,ego_import_option_sets opt
      WHERE  batch.batch_id = p_xset_id
      AND    batch.batch_id = opt.batch_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_source_system_id := EGO_IMPORT_PVT.get_pdh_source_system_id;
        l_import_xref_only := 'N';
        l_enabled_for_data_pool := 'N';
    END;

    IF NOT( l_source_system_id <> EGO_IMPORT_PVT.get_pdh_source_system_id AND l_import_xref_only = 'Y' ) THEN
      --Calling Item Intersections Import
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_ITEM_ASSOCIATIONS_PUB.Import_Item_Associations');
      END IF;

      EGO_ITEM_ASSOCIATIONS_PUB.Import_Item_Associations
      ( p_api_version   => 1.0,
        x_batch_id      => l_batch_id,
        x_errbuf        => ERRBUF,
        x_retcode       => RETCODE
      );

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_ITEM_ASSOCIATIONS_PUB.Import_Item_Associations - '||RETCODE);
        INVPUTLI.info(ERRBUF);
      END IF;

      l_retcode := RETCODE;

      --Calling Item People prg
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_ITEM_PEOPLE_IMPORT_PKG.LOAD_INTERFACE_LINES');
      END IF;

      EGO_ITEM_PEOPLE_IMPORT_PKG.LOAD_INTERFACE_LINES(
          X_ERRBUFF      => ERRBUF
         ,X_RETCODE      => RETCODE
         ,p_data_set_id  => p_xset_id
         ,p_delete_lines => p_del_rec_flag);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_ITEM_PEOPLE_IMPORT_PKG.LOAD_INTERFACE_LINES '||RETCODE);
        INVPUTLI.info(ERRBUF);
      END IF;

      l_retcode := RETCODE;

      --Calling AML prg
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_ITEM_AML_PVT.LOAD_INTERFACE_LINES');
      END IF;

      EGO_ITEM_AML_PVT.LOAD_INTERFACE_LINES(
          ERRBUF                   => ERRBUF
         ,RETCODE                  => RETCODE
         ,p_data_set_id            => p_xset_id
         ,p_delete_line_type       => p_del_rec_flag
         ,p_mode                   =>'NORMAL'
         ,P_perform_security_check => FND_API.G_TRUE);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_ITEM_AML_PVT.LOAD_INTERFACE_LINES '||RETCODE);
        INVPUTLI.info(ERRBUF);
      END IF;
      IF RETCODE > l_retcode THEN
       l_retcode := RETCODE;
      END IF;

      --Bug 5498078 : Defaulting UDA's during revision creation.
      --code for this is shifted to EGOVIMUB.pls

      --Calling user attr+gtin prg
      -- Bug 12635842 : In case of SKU creation from API we do not want to process the UDAs as UDA processing will be done as a separate call.
      IF(p_call_uda_process) THEN  -- Bug 12635842 : Call UDA code if the p_call_uda_process is TRUE
        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('Calling EGO_ITEM_USER_ATTRS_CP_PUB.PROCESS_ITEM_USER_ATTRS_DATA');
          EGO_ITEM_USER_ATTRS_CP_PUB.PROCESS_ITEM_USER_ATTRS_DATA(
              ERRBUF        => ERRBUF
             ,RETCODE       => RETCODE
             ,p_data_set_id => p_xset_id
             ,p_debug_level => 3
             ,p_is_id_validations_reqd => FND_API.G_FALSE   /* Fix for bug#9660659 */
             );
        ELSE
          EGO_ITEM_USER_ATTRS_CP_PUB.PROCESS_ITEM_USER_ATTRS_DATA(
              ERRBUF        => ERRBUF
             ,RETCODE       => RETCODE
             ,p_data_set_id => p_xset_id
             ,p_is_id_validations_reqd => FND_API.G_FALSE   /* Fix for bug#9660659 */
             );

        END IF;

        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('Returned EGO_ITEM_USER_ATTRS_CP_PUB.PROCESS_ITEM_USER_ATTRS_DATA '||RETCODE);
          INVPUTLI.info(ERRBUF);
        END IF;
        IF RETCODE > l_retcode THEN
         l_retcode := RETCODE;
        END IF;
      END IF;   -- Bug 12635842 : End of IF(p_call_uda_process)
    END IF; -- Xref import only

    --Now returning the highest status recieved and stored in l_retcode
    RETCODE := l_retcode;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('WHEN-OTHERS-EXCEPTION process_item_entities: ' ||SQLCODE);
        INVPUTLI.info(SQLERRM);
      END IF;
      RETCODE := G_ERROR;
      ERRBUF := 'Unexpected error in process_item_entities: '||SQLERRM;
  END process_item_entities;

------------------------------------------------------------------------------------
/*
   Procedure for Displaying Error in the Concurrent Log.
   In case the Error Page is not working, helps in Debugging.
   Fix for Bug#4540712 (RSOUNDAR)

   param p_entity_name:Entity for which the Error is reported.
   param p_table_name :Table from which the Error is generated.
   param p_selectQuery:Query for getting ITEM_NUMBER,ORGANIZATION_CODE,ERROR_MESSAGE
                       from the respective interface tables calling this API.
   param p_request_id :Request ID of the transaction.
   param x_return_status:Returns the unexpected error encountered during processing.
   param x_msg_count: Indicates how many messages exist on ERROR_HANDLER
                      message stack upon completion of processing.
   param x_msg_data:Contains message in ERROR_HANDLER message stack
                    upon completion of processing.
 */
--------------------------------------------------------------------------------------
PROCEDURE Write_Error_into_ConcurrentLog  (
	      p_entity_name      IN VARCHAR2,
	      p_table_name       IN VARCHAR2,
	      p_selectQuery      IN VARCHAR2,
	      p_request_id       IN NUMBER,
	      x_return_status    OUT NOCOPY VARCHAR2,
	      x_msg_count        OUT NOCOPY NUMBER,
         x_msg_data         OUT NOCOPY VARCHAR2 ) IS

   l_dyn_sql        VARCHAR2(10000);
   l_temp_text      VARCHAR2(2000);
   l_item_number    VARCHAR2(81);
   l_org_code       VARCHAR2(3);
   l_error_msg      VARCHAR2(2000);
   l_flash_heading  BOOLEAN;

   TYPE DYNAMIC_CUR IS REF CURSOR;
   c_error_result DYNAMIC_CUR;

BEGIN

  l_dyn_sql := p_selectQuery;
  l_flash_heading := TRUE;
  x_msg_count := 0;
  x_msg_data := NULL;
  OPEN c_error_result FOR l_dyn_sql USING p_request_id;
  LOOP
    FETCH c_error_result into l_item_number,l_org_code,l_error_msg;
    EXIT WHEN c_error_result%NOTFOUND;
    IF l_flash_heading THEN
      l_flash_heading := FALSE;
      l_temp_text := 'Entity Name: '||p_entity_name||'  Table Name: '||p_table_name||FND_GLOBAL.Local_Chr(10);
      FND_FILE.put_line(FND_FILE.LOG,'*Error Messages*'||FND_GLOBAL.Local_Chr(10)||l_temp_text);
      l_temp_text:=' Item_Number   '||'   Org_Code   '||'   Message';
      FND_FILE.put_line(FND_FILE.LOG,l_temp_text);
    END IF;
    FND_FILE.put_line(FND_FILE.LOG,l_item_number||' '||l_org_code||' '||l_error_msg);
  END LOOP;
  IF c_error_result%ISOPEN THEN
    CLOSE c_error_result;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
    FND_MESSAGE.Set_Token('PKG_NAME', 'EGO_ITEM_OPEN_INTERFACE_PVT');
    FND_MESSAGE.Set_Token('API_NAME', 'Write_Error_into_ConcurrentLog');
    FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                             ,p_count   => x_msg_count
                             ,p_data    => x_msg_data);
END Write_Error_into_ConcurrentLog;

   --------------------------------------------------------------------
   -- EGO Concurrent Wrapper API for INV Concurrent API for processing
   -- Item Category Assignments (from MTL_ITEM_CATEGORIES_INTERFACE)
   --
   -- Fix for Bug# 3616946 (PPEDDAMA)
   -- Removed the parameters: Upload Processed Records and Delete
   -- Processed Records from UI. So, defaulting the values in this API:
   -- Upload Processed Records = 1 (Yes)
   -- Delete Processed Records = 0 (No)
   --------------------------------------------------------------------

   PROCEDURE process_Item_Category_records(
       ERRBUF              OUT  NOCOPY VARCHAR2
      ,RETCODE             OUT  NOCOPY VARCHAR2
      ,p_rec_set_id        IN   NUMBER
      ,p_upload_rec_flag   IN   NUMBER    :=  1
      ,p_delete_rec_flag   IN   NUMBER    :=  0
      ,p_commit_flag       IN   NUMBER    :=  1
      ,p_prog_appid        IN   NUMBER    :=  NULL
      ,p_prog_id           IN   NUMBER    :=  NULL
      ,p_request_id        IN   NUMBER    :=  NULL
      ,p_user_id           IN   NUMBER    :=  NULL
      ,p_login_id          IN   NUMBER    :=  NULL) IS

   BEGIN
      INV_EGO_REVISION_VALIDATE.Set_Process_Control('EGO_ITEM_BULKLOAD');

      INV_ITEM_CATEGORY_OI.process_Item_Category_records(
          ERRBUF            => ERRBUF
         ,RETCODE           => RETCODE
         ,p_rec_set_id      => p_rec_set_id
         ,p_upload_rec_flag => p_upload_rec_flag
         ,p_delete_rec_flag => p_delete_rec_flag
         ,p_commit_flag     => p_commit_flag
         ,p_prog_appid      => p_prog_appid
         ,p_prog_id         => fnd_global.conc_program_id
         ,p_request_id      => fnd_global.conc_request_id --4105841
         ,p_user_id         => p_user_id
         ,p_login_id        => fnd_global.conc_login_id);

      INV_EGO_REVISION_VALIDATE.Set_Process_Control(NULL);
   END process_Item_Category_records;

------------------------------------------------------------------------------------
/*
   Procedure for Applying the specfied template to the specified interface row.
*/
------------------------------------------------------------------------------------

   FUNCTION apply_multiple_template( p_template_id IN NUMBER
                                    ,p_org_id      IN NUMBER
                                    ,p_all_org     IN NUMBER  := 2
                                    ,p_prog_appid  IN NUMBER  := -1
                                    ,p_prog_id     IN NUMBER  := -1
                                    ,p_request_id  IN NUMBER  := -1
                                    ,p_user_id     IN NUMBER  := -1
                                    ,p_login_id    IN NUMBER  := -1
                                    ,p_xset_id     IN NUMBER  := -999
                                    ,x_err_text    IN OUT NOCOPY VARCHAR2)
   RETURN INTEGER
   AS
    l_ret_status NUMBER;
    dumm_status	 NUMBER := 0;
   BEGIN
    /* Set the template id passed to the Function in the interface row */
    UPDATE mtl_system_items_interface
       SET template_id = p_template_id
     WHERE process_flag = 1
       AND set_process_id = p_xset_id
       AND((p_all_org = 1) or (organization_id = p_org_id));

    /* Call method to apply template attributes to the rows */

    l_ret_status := INVPULI2.copy_template_attributes( org_id => p_org_id
                                                      ,all_org => p_all_org
				                      ,prog_appid => p_prog_appid
                      				      ,prog_id => p_prog_id
			                	      ,request_id => p_request_id
                   				      ,user_id => p_user_id
		                     		      ,login_id => p_login_id
				                      ,xset_id => p_xset_id
                				      ,err_text => x_err_text);

    /* Set the template id back to null in the interface row to avoid reapplication */
    UPDATE mtl_system_items_interface
       SET template_id = null
     WHERE process_flag = 1
       AND set_process_id = p_xset_id
       AND((p_all_org = 1) or (organization_id = p_org_id));

     RETURN(l_ret_status);

   EXCEPTION
    WHEN others THEN
      x_err_text := 'Unexpected Error ' || SQLERRM || ' occured during template application';
      return(SQLCODE);
   END apply_multiple_template;


  -------------------------------------------------------------------
  -- In this method we call methods for copying
  --       1. Item People
  --       2. Item LC Project
  --       3. Item Attachments
  -------------------------------------------------------------------
  PROCEDURE Post_Import_Defaulting(ERRBUF            OUT     NOCOPY VARCHAR2,
                                   RETCODE           OUT     NOCOPY VARCHAR2,
                                   p_batch_id        IN             NUMBER,
                                   p_del_rec_flag    IN             NUMBER   := 1)
  IS
    l_retcode                VARCHAR2(100);
    l_inv_debug_level	       NUMBER := INVPUTLI.get_debug_level;
    l_source_system_id       EGO_IMPORT_BATCHES_B.source_system_id%TYPE;
    l_import_xref_only       EGO_IMPORT_OPTION_SETS.import_xref_only%TYPE;
    l_enabled_for_data_pool  VARCHAR2(1);
    l_request_id             NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
    err_msg                  VARCHAR2(300);  --Bug: 5473796
    l_temp_message           VARCHAR2(2000);
  BEGIN
    BEGIN
      SELECT batch.source_system_id, NVL(opt.import_xref_only,'N'), NVL(opt.ENABLED_FOR_DATA_POOL,'N')
      INTO   l_source_system_id, l_import_xref_only, l_enabled_for_data_pool
      FROM
        ego_import_batches_b batch,
        ego_import_option_sets opt
      WHERE batch.batch_id = p_batch_id
        AND batch.batch_id = opt.batch_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_source_system_id := EGO_IMPORT_PVT.get_pdh_source_system_id;
        l_import_xref_only := 'N';
        l_enabled_for_data_pool := 'N';
    END;

    IF NOT( l_source_system_id <> EGO_IMPORT_PVT.get_pdh_source_system_id AND l_import_xref_only = 'Y' ) THEN
      --Calling GTIN bulkloader
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_IMPORT_PVT.Process_Gtin_Intf_Rows');
      END IF;

      EGO_IMPORT_PVT.Process_Gtin_Intf_Rows(
          ERRBUF        => ERRBUF
         ,RETCODE       => RETCODE
         ,p_data_set_id => p_batch_id);

      IF l_inv_debug_level IN(101, 102) THEN
       INVPUTLI.info('Returned EGO_IMPORT_PVT.Process_Gtin_Intf_Rows '||RETCODE);
       INVPUTLI.info(ERRBUF);
      END IF;

      IF RETCODE > l_retcode THEN
        l_retcode := RETCODE;
      END IF;

      --Calling updation of inbound message timestamp
      IF l_enabled_for_data_pool = 'Y' THEN
        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('Calling EGO_IMPORT_UTIL_PVT.Update_Timestamp_In_Prod');
        END IF;

        EGO_IMPORT_UTIL_PVT.Update_Timestamp_In_Prod(
            ERRBUF        => ERRBUF
           ,RETCODE       => RETCODE
           ,p_batch_id    => p_batch_id);

        IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('Returned EGO_IMPORT_UTIL_PVT.Update_Timestamp_In_Prod '||RETCODE);
         INVPUTLI.info(ERRBUF);
        END IF;

        IF RETCODE > l_retcode THEN
          l_retcode := RETCODE;
        END IF;
      END IF; -- IF l_enabled_for_data_pool = 'Y' THEN

      --Calling Item People Defaulting
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_IMPORT_UTIL_PVT.Default_Item_People');
      END IF;

      EGO_IMPORT_UTIL_PVT.Default_Item_People(
          RETCODE      => RETCODE
         ,ERRBUF       => ERRBUF
         ,p_batch_id   => p_batch_id);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_IMPORT_UTIL_PVT.Default_Item_People '||RETCODE);
        INVPUTLI.info(ERRBUF);
      END IF;
      IF RETCODE > l_retcode THEN
       l_retcode := RETCODE;
      END IF;

      --Calling Item LC Project Defaulting
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_IMPORT_UTIL_PVT.Copy_LC_Projects');
      END IF;

      EGO_IMPORT_UTIL_PVT.Copy_LC_Projects(
          RETCODE      => RETCODE
         ,ERRBUF       => ERRBUF
         ,p_batch_id   => p_batch_id);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_IMPORT_UTIL_PVT.Copy_LC_Projects '||RETCODE);
        INVPUTLI.info(ERRBUF);
      END IF;
      IF RETCODE > l_retcode THEN
       l_retcode := RETCODE;
      END IF;

      --Calling Item Attachments Copy
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_IMPORT_UTIL_PVT.Copy_Attachments');
      END IF;

      EGO_IMPORT_UTIL_PVT.Copy_Attachments(
          RETCODE      => RETCODE
         ,ERRBUF       => ERRBUF
         ,p_batch_id   => p_batch_id);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_IMPORT_UTIL_PVT.Copy_Attachments '||RETCODE);
        INVPUTLI.info(ERRBUF);
      END IF;
      IF RETCODE > l_retcode THEN
       l_retcode := RETCODE;
      END IF;

      --Cleaning up dirty SKU entries
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_IMPORT_UTIL_PVT.Clean_Dirty_SKUs');
      END IF;

      EGO_IMPORT_UTIL_PVT.Clean_Dirty_SKUs(
          RETCODE      => RETCODE
         ,ERRBUF       => ERRBUF
         ,p_batch_id   => p_batch_id);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_IMPORT_UTIL_PVT.Clean_Dirty_SKUs '||RETCODE);
        INVPUTLI.info(ERRBUF);
      END IF;
      IF RETCODE > l_retcode THEN
       l_retcode := RETCODE;
      END IF;

      --calling copy people from style to SKU for newly added people
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Calling EGO_IMPORT_UTIL_PVT.Copy_Item_People_From_Style');
      END IF;

      EGO_IMPORT_UTIL_PVT.Copy_Item_People_From_Style(
          RETCODE      => RETCODE
         ,ERRBUF       => ERRBUF
         ,p_batch_id   => p_batch_id);

      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('Returned EGO_IMPORT_UTIL_PVT.Copy_Item_People_From_Style '||RETCODE);
        INVPUTLI.info(ERRBUF);
      END IF;
      IF RETCODE > l_retcode THEN
       l_retcode := RETCODE;
      END IF;


      --Bug: 5473976 Interface rows will be deleted here not in IOI
      IF p_del_rec_flag = 1 THEN
        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('Deleting interface records');
        END IF;
        l_retcode := INVPOPIF.indelitm_delete_item_oi (err_text => err_msg,
                                                       xset_id  => p_batch_id);

        IF l_inv_debug_level IN(101, 102) THEN
          INVPUTLI.info('Returned INVPOPIF.indelitm_delete_item_oi '||err_msg);
        END IF;
        IF RETCODE > l_retcode THEN
          l_retcode := RETCODE;
        END IF;
      END IF;
      --End Bug: 5473976
    END IF;
    ---------------------------------------------
    --For Error Link Display in the Conc. Req Log
    --Bug# 4540712 (RSOUNDAR)
    ---------------------------------------------
    IF NVL(l_request_id, -1) <> -1 THEN
      FND_MESSAGE.SET_NAME('EGO','EGO_ITEM_BULK_ERRS_LINKTXT1');
      FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
      FND_MESSAGE.SET_NAME('EGO','EGO_ITEMBULK_HOSTANDPORT');
      l_temp_message := rtrim(FND_PROFILE.VALUE('APPS_FRAMEWORK_AGENT'), '/');--FND_MESSAGE.GET;
      FND_MESSAGE.SET_NAME('EGO','EGO_ITEM_BULK_ERRS_LINK');
      FND_MESSAGE.SET_TOKEN('HOST_AND_PORT', l_temp_message);
      FND_MESSAGE.SET_TOKEN('CONC_REQ_ID', l_request_id);
      FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

      FND_FILE.put_line(FND_FILE.LOG, 'Following items got processed in this batch');
      FND_FILE.put_line(FND_FILE.LOG, '----------------------------------------------------');
      FND_FILE.put_line(FND_FILE.LOG, 'TRANSACTION TYPE    ORGANIZATION CODE    ITEM NUMBER');
      FND_FILE.put_line(FND_FILE.LOG, '----------------------------------------------------');


      --
      -- Bug 11901255. Log not showing assigned items.
      -- Commenting out the predicate that restricts the
      -- results only to master organization.
      -- sreharih.  Thu Mar 24 12:45:06 PDT 2011
      --
      FOR i IN (SELECT msii.TRANSACTION_TYPE, msii.ITEM_NUMBER, NVL(msii.ORGANIZATION_CODE, mp.ORGANIZATION_CODE) AS ORGANIZATION_CODE
                FROM MTL_SYSTEM_ITEMS_INTERFACE msii, MTL_PARAMETERS mp
                WHERE msii.SET_PROCESS_ID       = p_batch_id
                  AND msii.REQUEST_ID           = l_request_id
                  AND msii.ORGANIZATION_ID      = mp.ORGANIZATION_ID
                  --AND mp.MASTER_ORGANIZATION_ID = mp.ORGANIZATION_ID Bug 11901255
                  AND msii.PROCESS_FLAG         = 7
                  AND NVL(msii.CONFIRM_STATUS, 'X') NOT IN ('CFC', 'CFM', 'FMR', 'UFN', 'UFS', 'UFM', 'FK', 'FEX')
               )
      LOOP
        FND_FILE.put_line(FND_FILE.LOG, RPAD(i.TRANSACTION_TYPE, 16, ' ') ||'    '||RPAD(i.ORGANIZATION_CODE, 17, ' ') ||'    '||i.ITEM_NUMBER);
      END LOOP;
      FND_FILE.put_line(FND_FILE.LOG, '----------------------------------------------------');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('WHEN-OTHERS-EXCEPTION Post_Import_Defaulting: ' ||SQLCODE);
        INVPUTLI.info(SQLERRM);
      END IF;
      RETCODE := G_ERROR;
      ERRBUF := 'Unexpected error in Post_Import_Defaulting: '||SQLERRM;
  END Post_Import_Defaulting;

END EGO_ITEM_OPEN_INTERFACE_PVT;

/
