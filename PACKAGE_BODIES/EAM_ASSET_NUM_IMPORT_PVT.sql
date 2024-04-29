--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_NUM_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_NUM_IMPORT_PVT" as
/* $Header: EAMVANIB.pls 120.2 2006/07/17 07:40:26 sshahid noship $*/

   -- Start of comments
   -- API name : Load_Asset_Number
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters :
   -- IN       p_batch_id         IN      NUMBER Required,
   --          p_purge_option     IN      VARCHAR2 Optional Default = 'N'
   -- OUT      ERRBUF OUT VARCHAR2,
   --          RETCODE OUT VARCHAR2
   --
   -- Version  Initial version    1.0     Anirban Dey
   --
   -- Notes    : This public API imports asset numbers into
   --            MTL_SERIAL_NUMBERS
   --
   -- End of comments

-- global variable to turn on/off debug logging.

 g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_ASSET_NUM_IMPORT_PVT';

PROCEDURE Load_Asset_Numbers
    (ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY VARCHAR2,
     p_batch_id IN NUMBER,
     p_purge_option IN VARCHAR2 := 'N'
     ) IS

    l_retcode Number;
    CONC_STATUS BOOLEAN;

    l_api_name			CONSTANT VARCHAR2(30)	:= 'Load_Asset_Numbers';

    l_module             varchar2(200);
    l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
    l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
    l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;


BEGIN
        if(l_ulog) then
	      l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
        end if;
        l_retcode := import_asset_numbers(p_batch_id, p_purge_option);

        if l_retcode = 1 then

		IF (l_slog) THEN
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Completed Successfully.');
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,Current_Error_Code);
          	END IF;

		RETCODE := 'Success';

		while FND_CONCURRENT.CHILDREN_DONE(Interval => 20, Max_Wait => 120) = FALSE loop
                      fnd_file.put_line(FND_FILE.LOG, 'Waiting for all the workers to complete.');
               	end loop;

                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);
        elsif l_retcode = 3 then

		IF (l_slog) THEN
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Completed with Warning.');
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,Current_Error_Code);
          	END IF;

		RETCODE := 'Warning';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);
        else

		IF (l_slog) THEN
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Completed with Error.');
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,Current_Error_Code);
          	END IF;

		RETCODE := 'Error';
                CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
        end if;

END Load_Asset_Numbers;

PROCEDURE Launch_Worker
  (
    p_group_id                NUMBER,
    p_batch_id                NUMBER,
    p_purge_option            VARCHAR2,
    p_count                   NUMBER
   ) IS

    l_request_id              NUMBER  := 0;
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Launch_Worker';

    l_module           varchar2(200);
    l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
    l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
    l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

BEGIN
   if(l_ulog) then
	      l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
   end if;

  IF (l_slog) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Submitting Import Worker '||p_group_id
                               || ' to process ' || p_count || ' assets');
  END IF;

  --have to commit here so that worker process sees the changes
  COMMIT;
  l_request_id := FND_REQUEST.submit_request(
                              'EAM',
                              'EAMANIMW',
                              NULL,
                              NULL,
                              FALSE,
                              p_group_id,
                              p_purge_option
                              );

  IF (l_request_id = 0 OR l_request_id IS NULL) then
      -- failed to launch the process
      UPDATE  mtl_eam_asset_num_interface meani
      SET     meani.error_code = 9999,
              meani.process_flag = 'E',
              meani.error_message = 'Failed to submit worker '||p_group_id
      WHERE   meani.process_flag = 'P'
      AND     meani.batch_id = p_batch_id
      AND     meani.interface_group_id = p_group_id;
      COMMIT;


      IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Failed to submit worker '||p_group_id);
      END IF;


      RAISE fnd_api.g_exc_error;
   ELSE

      IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Request id '|| l_request_id
                     || ' for Import Worker '||p_group_id||' successfully submitted');
      END IF;

   END IF;

   IF (l_slog) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'');
   END IF;

END Launch_Worker;

FUNCTION Import_Asset_Numbers
    (
    p_batch_id           IN   NUMBER,
    p_purge_option       IN   VARCHAR2       := 'N'
    )  RETURN Number IS

    l_max_rows_to_process     NUMBER         := 500;
    l_counter                 NUMBER         := 0;
    l_num_assets              NUMBER         := 0;
    l_num_assets_to_workers   NUMBER         := 0;
    l_num_workers             NUMBER         := 0;
    error_number              NUMBER         := NULL;
    error_message             VARCHAR2(2000) := NULL;
    error_counter             NUMBER         := 0;
    curr_error                VARCHAR2(9)    := 'APP-00000';
    l_group_id                NUMBER         := 0;

    l_success                 NUMBER         := 1;

    l_api_name			CONSTANT VARCHAR2(30)	:= 'Import_Asset_Numbers';

    l_module          varchar2(200);
    l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
    l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
    l_exLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_exception >= l_log_level;
    l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

    CURSOR asset_rows_cur IS
        SELECT  meani.current_organization_id,
                meani.inventory_item_id,
                meani.serial_number,
                count(*) as total
        FROM    MTL_EAM_ASSET_NUM_INTERFACE meani
        WHERE   meani.batch_id = p_batch_id
        AND     meani.interface_group_id IS NULL
        AND     meani.process_flag = 'P'
        AND     meani.error_code IS NULL
        AND     meani.error_message IS NULL
        GROUP BY
                meani.current_organization_id,
                meani.inventory_item_id,
                meani.serial_number;

    -- Cursor for picking out invalid Scope in meani
    CURSOR invalid_scope_asset_cur IS
       SELECT  meani.interface_header_id
       FROM    MTL_EAM_ASSET_NUM_INTERFACE meani
       WHERE   meani.batch_id = p_batch_id
       AND     meani.import_scope NOT IN (0,1,2)
       AND     meani.process_flag = 'P'
       FOR UPDATE;

    invalid_scope_asset_rec invalid_scope_asset_cur%ROWTYPE;

    -- Cursor for picking out invalid Mode in meani
    CURSOR invalid_mode_asset_cur IS
       SELECT  meani.interface_header_id
       FROM    MTL_EAM_ASSET_NUM_INTERFACE meani
       WHERE   meani.batch_id = p_batch_id
       AND     meani.import_mode NOT IN (0,1)
       AND     meani.process_flag = 'P'
       FOR UPDATE;
    invalid_mode_asset_rec invalid_mode_asset_cur%ROWTYPE;

    -- Cursor for picking out NULL organization in meani
    CURSOR null_org_asset_cur IS
       SELECT  meani.interface_header_id
       FROM    MTL_EAM_ASSET_NUM_INTERFACE meani
       WHERE   batch_id = p_batch_id
       AND     (current_organization_id is null
                OR  organization_code is null)
       AND     process_flag = 'P'
       FOR UPDATE;

    null_org_asset_rec null_org_asset_cur%ROWTYPE;


    BEGIN

      if(l_ulog) then
	      l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
      end if;

     IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Batch Id = '||p_batch_id);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Purge Option = '||p_purge_option);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Max Rows to process = '||l_max_rows_to_process);
     END IF;



    -- Validate Scope Values:
    -- 0: Both Asset and Attributes
    -- 1: Asset Only
    -- 2: Attributes Only


    IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Validating Scope Values.');
    END IF;


-- Use Cursor to pick out rows with invalid Scope to synchronize the conditions
-- for updating the row in meani and the corresponding rows in meavi
/* ==
    UPDATE    mtl_eam_asset_num_interface meani
    SET       meani.process_flag = 'E',
              meani.error_code = 9999,
              meani.error_message = 'Incorrect Scope Value'
    WHERE     meani.batch_id = p_batch_id
    AND       meani.import_scope NOT IN (0,1,2)
    AND       meani.process_flag = 'P';
=== */
    OPEN invalid_scope_asset_cur;
    LOOP
       FETCH invalid_scope_asset_cur INTO invalid_scope_asset_rec;
       IF invalid_scope_asset_cur%NOTFOUND
       THEN
          EXIT;
       ELSE
          UPDATE    mtl_eam_asset_num_interface meani
          SET       meani.process_flag = 'E',
                    meani.error_code = 9999,
                    meani.error_message = 'Incorrect Scope Value'
          WHERE     CURRENT OF invalid_scope_asset_cur;

          -- 2001-12-28: chrng: To fix bug 2162520
          -- Flag corresponding rows in meavi as Error as well.
          UPDATE      MTL_EAM_ATTR_VAL_INTERFACE      meavi
          SET         meavi.error_number = 9999,
                      meavi.process_status = 'E',
                      meavi.error_message = 'Corresponding row in MTL_EAM_ASSET_NUM_INTERFACE has invalid Scope value'
          WHERE       meavi.process_status = 'P'
          AND         meavi.interface_header_id = invalid_scope_asset_rec.interface_header_id;
       END IF;
    END LOOP;
    CLOSE invalid_scope_asset_cur;

    -- Validate Mode Values:
    -- 0: Create
    -- 1: Update


    IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Validating Mode Values.');
     END IF;


-- Use Cursor to pick out rows with invalid Mode to synchronize the conditions
-- for updating the row in meani and the corresponding rows in meavi
/* ==
    UPDATE    mtl_eam_asset_num_interface meani
    SET       meani.process_flag = 'E',
              meani.error_code = 9999,
              meani.error_message = 'Incorrect Mode Value'
    WHERE     meani.batch_id = p_batch_id
    AND       meani.import_mode NOT IN (0,1)
    AND       meani.process_flag = 'P';
== */

    OPEN invalid_mode_asset_cur;
    LOOP
       FETCH invalid_mode_asset_cur INTO invalid_mode_asset_rec;
       IF invalid_mode_asset_cur%NOTFOUND
       THEN
          EXIT;
       ELSE
          UPDATE    mtl_eam_asset_num_interface meani
          SET       meani.process_flag = 'E',
                    meani.error_code = 9999,
                    meani.error_message = 'Incorrect Mode Value'
          WHERE     CURRENT OF invalid_mode_asset_cur;

          -- Flag corresponding rows in meavi as Error as well.
          UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
          SET       meavi.error_number = 9999,
                    meavi.process_status = 'E',
                    meavi.error_message = 'Corresponding row in MTL_EAM_ASSET_NUM_INTERFACE has invalid Mode value'
          WHERE     meavi.process_status = 'P'
          AND       meavi.interface_header_id = invalid_mode_asset_rec.interface_header_id;
       END IF;
    END LOOP;
    CLOSE invalid_mode_asset_cur;


    -- Validate Organization Code:
    -- If both organization_code and organization_id is provided, organization_id will be used.

    IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Validating Organization Code.');
     END IF;


    UPDATE    mtl_eam_asset_num_interface meani
    SET       organization_code= (select organization_code from mtl_parameters
               where organization_id = meani.current_organization_id
               and maint_organization_id is NOT NULL)
    WHERE     batch_id = p_batch_id
    AND       current_organization_id is not null
    AND       process_flag = 'P';

    UPDATE    mtl_eam_asset_num_interface meani
    SET       current_organization_id= (select organization_id from mtl_parameters
               where organization_code = meani.organization_code
               and maint_organization_id is NOT NULL)
    WHERE     batch_id = p_batch_id
    AND       current_organization_id is null
    AND       organization_code is not null
    AND       process_flag = 'P';

-- Use Cursor to pick out rows with NULL org to synchronize the conditions
-- for updating the row in meani and the corresponding rows in meavi
/* ==
    UPDATE    mtl_eam_asset_num_interface
    SET       process_flag = 'E' ,
              error_code = 9999,
              error_message = 'Invalid Organization. Check that it is NOT NULL, EXISTS and is EAM ENABLED'
    WHERE     batch_id = p_batch_id
    AND       (current_organization_id is null
               OR  organization_code is null)
    AND       process_flag = 'P';
    COMMIT;
== */

    OPEN null_org_asset_cur;
    LOOP
       FETCH null_org_asset_cur INTO null_org_asset_rec;
       IF null_org_asset_cur%NOTFOUND
       THEN
          EXIT;
       ELSE
          UPDATE    mtl_eam_asset_num_interface
          SET       process_flag = 'E' ,
                    error_code = 9999,
                    error_message = 'Invalid Organization. Check that it is NOT NULL, EXISTS and is EAM ENABLED'
          WHERE     CURRENT OF null_org_asset_cur;

          -- Flag corresponding rows in meavi as Error as well.
          UPDATE      MTL_EAM_ATTR_VAL_INTERFACE      meavi
          SET         meavi.error_number = 9999,
                      meavi.process_status = 'E',
                      meavi.error_message = 'Corresponding row in MTL_EAM_ASSET_NUM_INTERFACE has invalid organzation'
          WHERE       meavi.process_status = 'P'
          AND         meavi.interface_header_id = null_org_asset_rec.interface_header_id;
       END IF;
    END LOOP;
    CLOSE null_org_asset_cur;


    -- ===== Start Processing ======

    IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Start record pre-processing. Time now is ' ||
           to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));
     END IF;


    FOR asset IN asset_rows_cur
    LOOP
      --get a group id for worker
      if (l_counter = 0) then
        SELECT MTL_EAM_ASSET_NUM_INTERFACE_S.nextval
        INTO  l_group_id
        FROM  dual;
      end if;
      --have to update after each record ...
      UPDATE  mtl_eam_asset_num_interface meani
      SET     meani.interface_group_id = l_group_id,
              meani.process_flag = 'R'
      WHERE   meani.process_flag = 'P'
      AND     meani.current_organization_id = asset.current_organization_id
      AND     meani.inventory_item_id = asset.inventory_item_id
      AND     meani.serial_number = asset.serial_number
      AND     meani.batch_id = p_batch_id
      AND     meani.interface_group_id IS NULL;

      -- do not commit here, commit after each row is performance degrading
      -- commit just before launching worker

      l_counter := l_counter + asset.total;
      l_num_assets := l_num_assets + asset.total;

      IF (l_counter > l_max_rows_to_process) THEN
           Launch_Worker(l_group_id, p_batch_id, p_purge_option, l_counter);
           l_num_assets_to_workers := l_num_assets_to_workers + l_counter;
           l_counter := 0;
           l_num_workers := l_num_workers + 1;
      END IF;
    END LOOP;

    if (l_num_assets > l_num_assets_to_workers) then -- we still have more to process
      Launch_Worker(l_group_id, p_batch_id, p_purge_option, l_counter);
      l_num_assets_to_workers := l_num_assets_to_workers + l_counter;
      l_num_workers := l_num_workers + 1;
    end if;

    IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Stop record pre-processing. Time now is ' ||
                  to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));
     END IF;

    IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, l_num_workers ||' Import Workers are processing '
                     ||l_num_assets_to_workers || ' Assets');
     END IF;

    if not (l_num_assets_to_workers = l_num_assets) then

      IF (l_slog) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'WARNING: There is a discrepancy. Total Assets ('
        || l_num_assets || ') does not match total given to workers ('
        || l_num_assets_to_workers || ')');
      END IF;

    end if;

    IF (l_slog) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'');
    END IF;


    COMMIT;
    Return l_success;

EXCEPTION

        WHEN Error THEN

                l_success := 3;
                error_counter   :=      error_counter + 1;
                error_number    := SQLCODE;
                error_message   := SUBSTR(SQLERRM, 1, 512);

                IF invalid_scope_asset_cur%ISOPEN
                THEN
                   CLOSE invalid_scope_asset_cur;
                END IF;
                IF invalid_mode_asset_cur%ISOPEN
                THEN
                   CLOSE invalid_mode_asset_cur;
                END IF;
                IF null_org_asset_cur%ISOPEN
                THEN
                   CLOSE null_org_asset_cur;
                END IF;

                IF (l_exlog) THEN
		   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,error_number);
		   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,error_message);
          	END IF;

                COMMIT;
                Return l_success;

        WHEN OTHERS THEN

                l_success := 2;
                error_counter   := error_counter + 1;
                error_number    := SQLCODE;
                error_message   := SUBSTR(SQLERRM, 1, 512);

                IF invalid_scope_asset_cur%ISOPEN
                THEN
                   CLOSE invalid_scope_asset_cur;
                END IF;
                IF invalid_mode_asset_cur%ISOPEN
                THEN
                   CLOSE invalid_mode_asset_cur;
                END IF;
                IF null_org_asset_cur%ISOPEN
                THEN
                   CLOSE null_org_asset_cur;
                END IF;

                IF (l_exlog) THEN
		   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,error_number);
		   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,error_message);
          	END IF;

                COMMIT;
                Return l_success;

  END Import_Asset_Numbers;

END EAM_ASSET_NUM_IMPORT_PVT;

/
