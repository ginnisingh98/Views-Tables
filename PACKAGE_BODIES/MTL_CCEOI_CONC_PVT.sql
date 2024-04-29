--------------------------------------------------------
--  DDL for Package Body MTL_CCEOI_CONC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CCEOI_CONC_PVT" AS
/* $Header: INVVCCCB.pls 120.1 2005/06/22 09:48:25 appldev ship $ */

Current_Error_Code VARCHAR2(30) := NULL;
--
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_CCEOI_CONC_PVT';
--
procedure mdebug(msg in varchar2)
is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
--   dbms_output.put_line(msg);
   null;
end;

procedure inv_cceoi_set_log_file is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
declare
   v_db_name VARCHAR2(100);
   v_log_name VARCHAR2(100);
   v_db_name VARCHAR2(100);
   v_st_position number(3);
   v_end_position number(3);
   v_w_position number(3);

 begin
   select INSTR(value,',',1,2),INSTR(value,',',1,3)
   into v_st_position,v_end_position from  v$parameter
   where upper(name) = 'UTL_FILE_DIR';

   v_w_position := v_end_position - v_st_position - 1;

   select substr(value,v_st_position+1,v_w_position)
   into v_log_name from v$parameter
   where upper(name) = 'UTL_FILE_DIR';
   v_log_name := ltrim(v_log_name);
   FND_FILE.PUT_NAMES(v_log_name,v_log_name,v_log_name);
 end;
end;
  --
  -- Concurrent Program Export
  PROCEDURE Export_CCEntriesIface(
  ERRBUF OUT NOCOPY VARCHAR2 ,
  RETCODE OUT NOCOPY VARCHAR2 ,
  P_Cycle_Count_Header_Id IN NUMBER ,
  P_Cycle_Count_Entry_ID IN NUMBER DEFAULT NULL,
  p_cc_entry_iface_group_id IN NUMBER DEFAULT NULL)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name   : Export_CCEntriesIface
    -- TYPE       : Privat
    -- Pre-reqs   :
    -- FUNCTION   :
    -- The Export concurrent program select all unexported rows
    -- from the given cycle count. Each row will be inserted INTO
    -- TABLE MTL_CC_ENTRIES_INTERFACE
    -- by calling the PRIVAT API procedure MTL_CCEOI_ACTION_PVT.
    -- Export_CountRequest). IF the p_cycle_count_entry_id parameter
    -- IS populated only one ROW will be exported.
    -- Parameters :
    --     OUT    :
    --     ERRBUF OUT VARCHAR2 (required)
    --     returns any error message
    --
    --     RETCODE OUT VARCHAR2 (required)
    --     return completion status
    --     0 = 'SUCCESS'
    --     1 = 'WARNING'
    --     2 = 'ERROR'
    --     IN     :
    --     P_Cycle_Count_Header_Id IN NUMBER (required)
    --     Cycle Count Header  ID
    --
    --     P_Cycle_Count_Entry_Id IN NUMBER (optional)
    --     Default NULL
    --     Cycle Count Entry ID. IF the parameter IS populated
    --     this PROCEDURE IS called to process only one record.
    --
    --      p_cc_entry_iface_group_id IN NUMBER (optional)
    --      default NULL
    --      Cycle COUNT interface group ID FOR worker SET
    --      processing. IF this Parameter IS populated the calling
    --      PROCEDURE had selected the value FROM the sequence
    --      mtl_cceoi_entries_interface_s2
    --
    -- Version    : Current Version 0.9
    --
    --                                   initial version 0.9
    -- Notes      :
    -- END OF comments
    DECLARE
       --
       CURSOR L_CC_Header_Records_Csr (cchid number )IS
          SELECT *
          FROM mtl_cycle_count_headers
       WHERE
          (cycle_count_header_id = cchid);
       --
       CURSOR L_CycleCount_Records_Csr(HID NUMBER, CCID IN NUMBER) IS
          SELECT *
          FROM mtl_cycle_count_entries
       WHERE
          (cycle_count_header_id = hid
             OR cycle_count_entry_id = ccid)
          AND NVL(export_flag, 2) = 2
          AND entry_status_code IN(1, 3);
       --
       -- BEGIN INVCONV
       CURSOR cur_get_item_attr (
          cp_inventory_item_id                NUMBER
        , cp_organization_id                  NUMBER
       ) IS
          -- tracking_quantity_ind (P-Primary, PS-Primary and Secondary)
          -- secondary_default_ind (F-Fixed, D-Default, N-No Default)
          SELECT msi.tracking_quantity_ind
               , msi.secondary_default_ind
               , msi.secondary_uom_code
               , msi.process_costing_enabled_flag
               , mtp.process_enabled_flag
            FROM mtl_system_items msi, mtl_parameters mtp
           WHERE mtp.organization_id = cp_organization_id
             AND msi.organization_id = mtp.organization_id
             AND msi.inventory_item_id = cp_inventory_item_id;
       -- END INVCONV

       L_CCEOIEntry_record MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE;
       L_cc_entry_iface_group_id NUMBER;
       L_rec_counter_pos integer := 0;
       L_rec_counter_neg integer := 0;
       L_counter integer := 0;
       L_return_status VARCHAR2(30);
       L_errorcode NUMBER := 0;
       L_msg_count NUMBER;
       L_msg_data VARCHAR2(100);
       L_CONC_STATUS BOOLEAN;
       L_ccHeader_ID NUMBER;
       L_ccEntry_ID NUMBER;
       x_serial_count_option NUMBER;
       x_serial_number_control NUMBER;
       --
    BEGIN
IF (l_debug = 1) THEN
   mdebug('Start export ');
END IF;
       RETCODE := 'SUCCESS';
       --
       inv_cceoi_set_log_file;
       --FND_FILE.PUT_NAMES('/sqlcom/log', '/sqlcom/log', '/sqlcom/log');
       --
       IF p_cycle_count_entry_id IS NULL THEN
          -- Validate Input parameter
          MTL_INV_VALIDATE_GRP.Validate_CountHeader(
             p_api_version => 0.9,
             x_return_status => L_return_status,
             x_msg_count => L_msg_count,
             x_msg_data => L_msg_data,
             X_ErrorCode => L_errorcode,
             p_cycle_count_header_id => p_cycle_count_header_id);
          --
          IF L_errorcode <> 0 THEN
             RETCODE := 'ERROR';
             ERRBUF := L_msg_data;
             APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
       END IF;
       --
       IF RETCODE = 'SUCCESS'THEN
          IF p_cc_entry_iface_group_id IS NOT NULL THEN
             L_cc_entry_iface_group_id :=p_cc_entry_iface_group_id;
          ELSE
             SELECT
                MTL_CC_ENTRIES_INTERFACE_S2.nextval
             INTO
                L_cc_entry_iface_group_id
             FROM
                dual;
          END IF;
          --
          -- Only one parameter can be used
          IF P_Cycle_Count_Entry_Id IS NOT NULL THEN
             L_ccHeader_ID := NULL;
             L_ccEntry_ID := P_Cycle_Count_Entry_Id;
          ELSIF
             P_Cycle_Count_Header_Id IS NOT NULL THEN
             L_ccHeader_ID := P_Cycle_Count_Header_Id;
             L_ccEntry_ID := NULL;
          END IF;
          --
          -- Interface Group-ID of the Exports
IF (l_debug = 1) THEN
   mdebug('Export- Before cursor ');
END IF;

          FOR c_rec IN L_CycleCount_Records_Csr(L_ccHeader_ID, L_ccEntry_ID) LOOP
             --
             -- START: prepare the input parameter FOR the Public API PROCEDURE
             L_CCEOIEntry_record.Organization_id := c_rec. Organization_id;
             L_CCEOIEntry_record.cc_entry_interface_group_id :=
             L_cc_entry_iface_group_id;
             L_CCEOIEntry_record.Cycle_Count_Header_id := c_rec.
             Cycle_Count_Header_id;
             L_CCEOIEntry_record.Count_List_Sequence := c_rec.Count_List_Sequence;
             L_CCEOIEntry_record.inventory_item_id := c_rec.inventory_item_id;
             L_CCEOIEntry_record.revision := c_rec.revision;
             L_CCEOIEntry_record.subinventory := c_rec.subinventory;
             L_CCEOIEntry_record.locator_id := c_rec.locator_id;
             L_CCEOIEntry_record.lot_number := c_rec.lot_number;
             L_CCEOIEntry_record.serial_number := c_rec.serial_number;
             L_CCEOIEntry_record.system_quantity := c_rec.system_quantity_current;
	     -- BEGIN INVCONV
	     OPEN cur_get_item_attr (c_rec.inventory_item_id, c_rec.organization_id);
             FETCH cur_get_item_attr
              INTO MTL_CCEOI_VAR_PVT.g_tracking_quantity_ind,
                   MTL_CCEOI_VAR_PVT.g_secondary_default_ind,
		   MTL_CCEOI_VAR_PVT.g_secondary_uom_code,
                   MTL_CCEOI_VAR_PVT.g_process_costing_enabled_flag,
                   MTL_CCEOI_VAR_PVT.g_process_enabled_flag;
             CLOSE cur_get_item_attr;

             L_CCEOIEntry_record.secondary_uom := MTL_CCEOI_VAR_PVT.g_secondary_uom_code;
             L_CCEOIEntry_record.secondary_system_quantity := c_rec.secondary_system_qty_current;
             -- END INVCONV

              -- This code is added for the bug 2311404 by aapaul
             if (c_rec.system_quantity_current is null) then
                 select SERIAL_NUMBER_CONTROL_CODE into x_serial_number_control
                   from mtl_system_items
                  where organization_id = c_rec.organization_id
                    and inventory_item_id = c_rec.inventory_item_id;
                 select SERIAL_COUNT_OPTION into x_serial_count_option
                   from mtl_cycle_count_headers
                  where cycle_count_header_id = c_rec.Cycle_Count_Header_id;
             if c_rec.parent_lpn_id is not null then
                     if c_rec.inventory_item_id is not null then
                                MTL_INV_UTIL_GRP.Get_LPN_Item_SysQty
                                   (
                                           p_api_version           => 1.0
                                   ,       p_init_msg_lst          => fnd_api.g_true
                                   ,       p_commit                => fnd_api.g_true
                                   ,       x_return_status         => L_return_status
                                   ,       x_msg_count             => L_msg_count
                                   ,       x_msg_data              => L_msg_data
                                   ,       p_organization_id       => c_rec.Organization_id
                                   ,       p_lpn_id                => c_rec.parent_lpn_id
                                   ,       p_inventory_item_id     => c_rec.inventory_item_id
                                   ,       p_lot_number            => c_rec.lot_number
                                   ,       p_revision              => c_rec.revision
                                   ,       p_serial_number         => c_rec.serial_number
                                   ,       p_cost_group_id         => c_rec.cost_group_id
                                   ,       x_lpn_systemqty         => L_CCEOIEntry_record.system_quantity
                                   ,       x_lpn_sec_systemqty     => L_CCEOIEntry_record.secondary_system_quantity -- INVCONV
                                  );
				  -- BEGIN INVCONV
                                  IF MTL_CCEOI_VAR_PVT.g_tracking_quantity_ind <> 'PS' THEN
                                        L_CCEOIEntry_record.secondary_system_quantity := NULL;
				  END IF;
				  -- END INVCONV
                    else
                              L_CCEOIEntry_record.system_quantity := NULL;
			      L_CCEOIEntry_record.secondary_system_quantity := NULL; -- INVCONV
                    end if;
             else
                              MTL_INV_UTIL_GRP.Calculate_Systemquantity
                                 (
                                          p_api_version           => 0.9
                                 ,        x_return_status         => L_return_status
                                 ,        x_msg_count             => L_msg_count
                                 ,        x_msg_data              => L_msg_data
                                 ,        p_organization_id       => c_rec.organization_id
                                 ,        p_inventory_item_id     => c_rec.inventory_item_id
                                 ,        p_subinventory          => c_rec.subinventory
                                 ,        p_lot_number            => c_rec.lot_number
                                 ,        p_revision              => c_rec.revision
                                 ,        p_locator_id            => c_rec.locator_id
                                 ,        p_cost_group_id         => c_rec.cost_group_id
                                 ,        p_serial_number         => c_rec.serial_number
                                 ,        p_serial_number_control => x_serial_number_control
                                 ,        p_serial_count_option   => x_serial_count_option
                                 ,        x_system_quantity       => L_CCEOIEntry_record.system_quantity
				 ,        x_sec_system_quantity   => L_CCEOIEntry_record.secondary_system_quantity -- INVCONV
                                 );
				 -- BEGIN INVCONV
                                 IF MTL_CCEOI_VAR_PVT.g_tracking_quantity_ind <> 'PS' THEN
                                       L_CCEOIEntry_record.secondary_system_quantity := NULL;
				 END IF;
				 -- END INVCONV
            end if;
       end if;
             L_CCEOIEntry_record.adjustment_account_id :=
             c_rec.inventory_adjustment_account;
             L_CCEOIEntry_record.parent_lpn_id := c_rec.parent_lpn_id;
             L_CCEOIEntry_record.outermost_lpn_id := c_rec.outermost_lpn_id;
             L_CCEOIEntry_record.cost_group_id := c_rec.cost_group_id;
             if L_CCEOIEntry_record.adjustment_account_id is null then
                FOR hc_rec IN L_CC_Header_Records_Csr(c_rec.Cycle_Count_Header_id)
                LOOP
                   L_CCEOIEntry_record.adjustment_account_id :=
                        hc_rec.inventory_adjustment_account;
                END LOOP;
             end if;
             L_CCEOIEntry_record.reference := c_rec.reference_current;
             L_CCEOIEntry_record.lock_flag := 2;
             -- no LOCK
             L_CCEOIEntry_record.process_flag := 1;
             -- Ready
             L_CCEOIEntry_record.process_mode := 3;
             -- Export
             L_CCEOIEntry_record.ATTRIBUTE_CATEGORY := c_rec.ATTRIBUTE_CATEGORY;
             L_CCEOIEntry_record.ATTRIBUTE1 := c_rec.ATTRIBUTE1;
             L_CCEOIEntry_record.ATTRIBUTE2 := c_rec.ATTRIBUTE2;
             L_CCEOIEntry_record.ATTRIBUTE3 := c_rec.ATTRIBUTE3;
             L_CCEOIEntry_record.ATTRIBUTE4 := c_rec.ATTRIBUTE4;
             L_CCEOIEntry_record.ATTRIBUTE5 := c_rec.ATTRIBUTE5;
             L_CCEOIEntry_record.ATTRIBUTE6 := c_rec.ATTRIBUTE6;
             L_CCEOIEntry_record.ATTRIBUTE7 := c_rec.ATTRIBUTE7;
             L_CCEOIEntry_record.ATTRIBUTE8 := c_rec.ATTRIBUTE8;
             L_CCEOIEntry_record.ATTRIBUTE9 := c_rec.ATTRIBUTE9;
             L_CCEOIEntry_record.ATTRIBUTE10 := c_rec.ATTRIBUTE10;
             L_CCEOIEntry_record.ATTRIBUTE11 := c_rec.ATTRIBUTE11;
             L_CCEOIEntry_record.ATTRIBUTE12 := c_rec.ATTRIBUTE12;
             L_CCEOIEntry_record.ATTRIBUTE13 := c_rec.ATTRIBUTE13;
             L_CCEOIEntry_record.ATTRIBUTE14 := c_rec.ATTRIBUTE14;
             L_CCEOIEntry_record.ATTRIBUTE15 := c_rec.ATTRIBUTE15;
             -- Export STATI
             L_CCEOIEntry_record.VALID_FLAG := 1;
             L_CCEOIEntry_record.cycle_count_entry_id :=
             c_rec.cycle_count_entry_id;
             L_CCEOIEntry_record.action_code := MTL_CCEOI_VAR_PVT.G_PROCESS;
             L_CCEOIEntry_record.STATUS_FLAG := NULL;
             -- END: prepare the input parameter FOR the Public API PROCEDURE
             --
IF (l_debug = 1) THEN
   mdebug('Before call Export_CountRequest export ');
END IF;

             MTL_CCEOI_ACTION_PVT.Export_CountRequest(
                p_api_version => 0.9,
                X_return_status => L_return_status,
                x_msg_count => L_msg_count,
                x_msg_data => L_msg_data,
                p_interface_rec => L_CCEOIEntry_record);
IF (l_debug = 1) THEN
   mdebug('after  call Export_CountRequeSt export ');
END IF;

             --
             -- Error Validation/Replace all NULL statements
             --
             IF(L_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                -- no errors
                --
IF (l_debug = 1) THEN
   mdebug('success  '||L_return_status||'='||FND_API.G_RET_STS_SUCCESS);
END IF;
                L_rec_counter_pos := L_rec_counter_pos + 1;
                --
             ELSE
IF (l_debug = 1) THEN
   mdebug('error  '||L_return_status );
END IF;
                -- an error IS occured.Write error output
                --
                L_rec_counter_neg := L_rec_counter_neg + 1;
                --
                -- Write Text according to the error code to ERRBUF
                ERRBUF := L_msg_data;
                FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
             END IF;
             L_counter := L_counter + 1;
          END LOOP;
    --      COMMIT;
       END IF;
/*
-- Due to error it is commented out
IF (l_debug = 1) THEN
   mdebug('debug - 1');
END IF;
       -- How many rows are exported
       FND_FILE.PUT_LINE(FND_FILE.LOG,
          'Exported rows     ='|| TO_CHAR(L_rec_counter_pos));
IF (l_debug = 1) THEN
   mdebug('debug - 2');
END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Not Exported rows ='
          || TO_CHAR(L_rec_counter_neg));
IF (l_debug = 1) THEN
   mdebug('debug - 3');
END IF;
       --
*/
       IF L_counter <> L_rec_counter_pos THEN
          RETCODE := 'ERROR';
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
             L_msg_data);
       ELSIF
          L_counter = L_rec_counter_pos THEN
          RETCODE := 'SUCCESS';
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',
             L_msg_data);
       END IF;
IF (l_debug = 1) THEN
   mdebug('debug - 4');
END IF;
    END;
  END;
  --
  -- Concurrent Program Import
  PROCEDURE Import_CCEntriesIface(
  ERRBUF  OUT NOCOPY VARCHAR2 ,
  RETCODE OUT NOCOPY VARCHAR2 ,
  P_Cycle_Count_Header_ID IN NUMBER DEFAULT NULL,
  P_Number_of_Worker IN NUMBER ,
  P_Commit_point IN NUMBER DEFAULT 100,
  P_ErrorReportLev IN NUMBER DEFAULT 2,
  P_DeleteProcRec IN NUMBER DEFAULT 2)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Import_CCEntriesIface
    -- TYPE        : Private
    -- Pre-reqs   :
    -- FUNCTION:
    -- Parameters:
    -- Parameters :
    --     OUT    :
    --     ERRBUF OUT VARCHAR2 (required)
    --     returns any error message
    --
    --     RETCODE OUT VARCHAR2 (required)
    --     return completion status
    --     0 = 'SUCCESS'
    --     1 = 'WARNING'
    --     2 = 'ERROR'
    --
    --     IN           :
    --     P_Cycle_Count_Header_Id IN NUMBER (optional)
    --     Default = NULL
    --     Cycle Count Header  ID
    --
    --     P_Number_Of_Workers IN NUMBER (required)
    --     COUNT OF workers
    --
    --     P_Commit_point IN NUMBER (optional)
    --     default = 100
    --     COMMIT Point FOR the worker process
    --
    --     P_ErrorReportLev NUMBER DEFAULT 2 (required - defaulted)
    --     Error Reporting Level
    --     1=Abort on first error. This means the worker aborts at first error
    --     2=Process all errors and warnings.
    --
    --     P_DeleteProcRec NUMBER DEFAULT 2 (required - defaulted)
    --     DELETE Processed Record
    --     1=DELETE successfully processed rows.
    --     2=Do not delete processed rows.
    --
    -- Version : Current Version 0.9
    --
    --                                   initial version 0.9
    --
    -- Notes  :
    -- END OF comments
    DECLARE
       L_MaxNumRows NUMBER;
       L_NextGroupID NUMBER;
       L_ErrorText VARCHAR2(2000);
       L_Condition BOOLEAN := TRUE;
       L_CountWorker NUMBER;
       L_CountRows NUMBER;
       L_CONC_STATUS BOOLEAN;
       L_return_status VARCHAR2(30);
       L_msg_count NUMBER;
       L_msg_data VARCHAR2(240);
       L_errorcode NUMBER;
       L_NewReqID NUMBER;
       --
    BEGIN
--dbms_output.put_line('Begin-Import ');

       RETCODE := 'SUCCESS';
       --
       inv_cceoi_set_log_file;
       --FND_FILE.PUT_NAMES('/sqlcom/log', '/sqlcom/log', '/sqlcom/log');
       --
       -- Validate the input parameter before calling another procedures
       IF p_number_of_worker < 1 THEN
          RETCODE := 'ERROR';
          ERRBUF := FND_MESSAGE.GET_STRING('INV', 'INV_CCEOI_WRONG_COUNTOFWORKER');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       IF p_commit_point < 1 THEN
          RETCODE := 'ERROR';
          ERRBUF := FND_MESSAGE.GET_STRING('INV', 'INV_CCEOI_WRONG_COMMITPOINT');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       IF P_ErrorReportLev NOT IN(1, 2) THEN
          RETCODE := 'ERROR';
          ERRBUF :=FND_MESSAGE.GET_STRING('INV', 'INV_CCEOI_WRONG_ERRORLEVEL');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       IF P_DeleteProcRec NOT IN(1, 2) THEN
          RETCODE := 'ERROR';
          ERRBUF :=FND_MESSAGE.GET_STRING('INV', 'INV_CCEOI_WRONG_DELETEREC');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       --
       IF p_cycle_count_header_id IS NOT NULL THEN
          MTL_INV_VALIDATE_GRP.Validate_CountHeader(
             p_api_version => 0.9,
             p_validation_level => 0,
             -- Only FOR export, no derivation
             x_return_status => L_return_status,
             x_msg_count => L_msg_count,
             x_msg_data => L_msg_data,
             X_ErrorCode => L_errorcode,
             p_cycle_count_header_id => p_cycle_count_header_id);
          --
          IF L_errorcode <> 0 THEN
             RETCODE := 'ERROR';
             ERRBUF := L_msg_data;
             FND_FILE.PUT_LINE(FND_FILE.LOG, L_msg_data);
             APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
       END IF;
       -- END OF VALIDATION
       --
       IF RETCODE = 'SUCCESS' THEN
          --
          -- Calculate max rows according to the count of worker
          /* Bug #2650761 - Added NVL(status_flag,4) since when exporting from the form,
             status flag is NULL */
          IF p_cycle_count_header_id IS NULL THEN
             SELECT COUNT(*)
             INTO L_MaxNumRows
             FROM MTL_CC_ENTRIES_INTERFACE
             WHERE NVL(STATUS_FLAG, 4) = 4
             --   STATUS_FLAG = 4
             AND NVL(LOCK_FLAG, 2) =2
             AND NVL(DELETE_FLAG, 2) = 2
             AND NVL(PROCESS_FLAG, 1) = 1
             AND NVL(PROCESS_MODE, 3) = 3;
          ELSE
             SELECT COUNT(*)
             INTO L_MaxNumRows
             FROM MTL_CC_ENTRIES_INTERFACE
             WHERE CYCLE_COUNT_HEADER_ID = P_CYCLE_COUNT_HEADER_ID
             AND NVL(STATUS_FLAG, 4) = 4
             --AND STATUS_FLAG = 4
             AND NVL(LOCK_FLAG, 2) =2
             AND NVL(DELETE_FLAG, 2) = 2
             AND NVL(PROCESS_FLAG, 1) = 1
             AND NVL(PROCESS_MODE, 3) = 3;
          END IF;

--dbms_output.put_line(to_number(L_MaxNumRows)||' will be processed by the Import concurrent program. ');
          FND_FILE.PUT_LINE(FND_FILE.LOG, to_number(L_MaxNumRows)||' will be processed by the Import concurrent program.');
          IF L_MaxNumRows = 0 THEN
             -- No rows retrieved
             RETCODE := 'WARNING';
             ERRBUF := 'No rows retrieved.';
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'No rows retrieved!'||
                ' Worker do not started.');
             L_CountWorker := 0;
          ELSIF L_MaxNumRows <= P_Number_Of_Worker THEN
             -- only one worker neccessary
             L_CountWorker := 1;
             L_CountRows := L_MaxNumRows;
          ELSE
             -- share rows to each worker
             -- e.g.
             -- P_Count_Of_Worker = 10
             -- L_MaxNumRows = 1001
             -- L_CountRows = ROUND(L_MaxNumRows/P_Count_Of_Worker) = 100
             -- Rows = L_CountRows*P_Count_Of_Worker =
             --              1000 (smaller than L_MaxNumRows)
             -- L_CountRows = 100 + L_MaxNumRows - Rows = 101
             --
             L_CountWorker := NVL(P_Number_Of_Worker,1); --4182975
             --
             SELECT ROUND(L_MaxNumRows/L_CountWorker)
             INTO
                L_CountRows
             FROM
                DUAL;
             --
             IF(L_CountRows*L_CountWorker<L_MaxNumRows) THEN
                L_CountRows := L_CountRows + (L_MaxNumRows-(L_CountRows*L_CountWorker));
             END IF;
          END IF;
          --
--dbms_output.put_line('Worker');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker = '||
             TO_CHAR(L_CountWorker));
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rows/Worker = '||
             TO_CHAR(L_CountRows));
          --
          -- New Logic to initialize the grpId before assign
                UPDATE mtl_cc_entries_interface
                SET
                   cc_entry_interface_group_id = NULL,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = MTL_CCEOI_VAR_PVT.G_UserID,
                   LAST_UPDATE_LOGIN = MTL_CCEOI_VAR_PVT.G_LoginID,
                   PROGRAM_APPLICATION_ID = MTL_CCEOI_VAR_PVT.G_ProgramAppID,
                   PROGRAM_ID = MTL_CCEOI_VAR_PVT.G_ProgramID,
                   REQUEST_ID = MTL_CCEOI_VAR_PVT.G_RequestID,
                   PROGRAM_UPDATE_DATE = SYSDATE
                WHERE
                   CYCLE_COUNT_HEADER_ID = NVL(P_Cycle_Count_Header_Id,CYCLE_COUNT_HEADER_ID)
                   AND NVL(PROCESS_FLAG, 1) = 1
                   AND NVL(LOCK_FLAG, 2) = 2
                   AND NVL(PROCESS_MODE, 3) = 3
                   AND NVL(STATUS_FLAG,4) = 4
                   AND NVL(DELETE_FLAG, 2) = 2;
          --
          FOR i IN 1..L_CountWorker LOOP
             --
             SELECT MTL_CC_ENTRIES_INTERFACE_S1.NEXTVAL
             INTO
                L_NextGroupID
             FROM
                DUAL;
             -- UPDATE the interface entries with the group ID
             IF p_cycle_count_header_id IS NULL THEN
--dbms_output.put_line('Updating with cc header is null');
                UPDATE mtl_cc_entries_interface
                SET
                   cc_entry_interface_group_id = L_NextGroupID,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = MTL_CCEOI_VAR_PVT.G_UserID,
                   LAST_UPDATE_LOGIN = MTL_CCEOI_VAR_PVT.G_LoginID,
                   PROGRAM_APPLICATION_ID = MTL_CCEOI_VAR_PVT.G_ProgramAppID,
                   PROGRAM_ID = MTL_CCEOI_VAR_PVT.G_ProgramID,
                   REQUEST_ID = MTL_CCEOI_VAR_PVT.G_RequestID,
                   PROGRAM_UPDATE_DATE = SYSDATE
                WHERE
                   NVL(PROCESS_FLAG, 1) = 1
                   AND NVL(LOCK_FLAG, 2) = 2
                   AND NVL(PROCESS_MODE, 3) = 3
                   AND NVL(STATUS_FLAG,4) = 4
                   AND NVL(DELETE_FLAG, 2) = 2
                   AND cc_entry_interface_group_id IS NULL
                   AND ROWNUM <= L_CountRows;
             ELSE
                UPDATE mtl_cc_entries_interface
                SET
                   cc_entry_interface_group_id = L_NextGroupID,
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = MTL_CCEOI_VAR_PVT.G_UserID,
                   LAST_UPDATE_LOGIN = MTL_CCEOI_VAR_PVT.G_LoginID,
                   PROGRAM_APPLICATION_ID = MTL_CCEOI_VAR_PVT.G_ProgramAppID,
                   PROGRAM_ID = MTL_CCEOI_VAR_PVT.G_ProgramID,
                   REQUEST_ID = MTL_CCEOI_VAR_PVT.G_RequestID,
                   PROGRAM_UPDATE_DATE = SYSDATE
                WHERE
                   CYCLE_COUNT_HEADER_ID = P_Cycle_Count_Header_Id
                   AND NVL(PROCESS_FLAG, 1) = 1
                   AND NVL(LOCK_FLAG, 2) = 2
                   AND NVL(PROCESS_MODE, 3) = 3
                   AND NVL(STATUS_FLAG,4) = 4
                   AND NVL(DELETE_FLAG, 2) = 2
                   AND cc_entry_interface_group_id IS NULL
                   AND ROWNUM <= L_CountRows;
             END IF;
             --
             -- Launch a worker request for the current header id.
--dbms_output.put_line('Launching Worker');
             L_NewReqID := FND_REQUEST.SUBMIT_REQUEST(
                application => 'INV',
                program => 'MTL_CCEOI_WORKER',
                description => 'Cycle Count Entries Open Interface Worker',
--                start_time => NULL,
                argument1 => to_char(L_NextGroupID),
                argument2 => to_char(P_Commit_point),
                argument3 => to_char(P_ErrorReportLev),
                argument4 => to_char(P_DeleteProcRec));
--                argument5 => chr(0));
             -- If the new request id = 0, abort because the
             -- request submission failed, otherwise commit
             -- the request.
             IF L_NewReqID = 0 THEN
                -- Write error to log file and exit.
                L_ErrorText := FND_MESSAGE.GET;
                FND_FILE.PUT_LINE(FND_FILE.LOG, L_ErrorText);
                APP_EXCEPTION.RAISE_EXCEPTION;
             ELSE
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Record  set with '||
                   'CC_ENTRY_INTERFACE_GROUP_ID = '||
                   TO_CHAR(L_NextGroupID) || 'created.');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Record  set processed'||
                   ' by the worker request '|| TO_CHAR(L_NewReqID));
                COMMIT;
             END IF;
          END LOOP;
       END IF;
       IF RETCODE = 'SUCCESS'THEN
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',
             NULL);
       ELSIF
          RETCODE = 'WARNING'THEN
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
             NULL);
       ELSE
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',

             NULL);
       END IF;
    END;
  END;
  --
  -- Concurrent program Purge
  PROCEDURE Purge_CCEntriesIface(
  ERRBUF  OUT NOCOPY VARCHAR2 ,
  RETCODE OUT NOCOPY VARCHAR2 )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Purge_CCEntriesIface
    -- TYPE        : Private
    -- Pre-reqs   :
    -- FUNCTION:
    -- purges all records that are marked FOR deletion
    -- OR successfully processed
    -- Parameters:
    --     OUT    :
    --     ERRBUF OUT VARCHAR2 (required)
    --     returns any error message
    --
    --     RETCODE OUT VARCHAR2 (required)
    --     return completion status
    --     0 = 'SUCCESS'
    --     1 = 'WARNING'
    --     2 = 'ERROR'
    --
    -- Version : Current Version 0.9
    --
    --                                   initial version 0.9
    -- Notes  :
    -- END OF comments
    DECLARE
       --
       -- All successfully processed records without errors
       -- OR records which marks FOR deletion
       CURSOR L_Purge_Iface_Csr IS
          SELECT
          *
          FROM
          MTL_CC_ENTRIES_INTERFACE
       WHERE
          (ERROR_FLAG = 2
             AND STATUS_FLAG IN(0, 1))
          OR DELETE_FLAG = 1;
       --
       L_return_status VARCHAR2(30);
       L_msg_count NUMBER;
       L_msg_data VARCHAR2(2000);
       L_errorcode NUMBER;
       L_counter NUMBER := 0;
       L_CONC_STATUS BOOLEAN;
       L_recs NUMBER := 0;
       --
    BEGIN
       --
       RETCODE := 'SUCCESS';
       --
       inv_cceoi_set_log_file ;
       --FND_FILE.PUT_NAMES('/sqlcom/log', '/sqlcom/log', '/sqlcom/log');
       -- Test area
       begin
          select count(*)
          into L_recs
          FROM
          MTL_CC_ENTRIES_INTERFACE
       WHERE
          (ERROR_FLAG = 2 AND STATUS_FLAG IN (0, 1))
          OR DELETE_FLAG = 1;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deleting rows : '||to_char(L_recs));
       RETCODE := 'SUCCESS';
       exception
         when others then null;
       end;
       --
       FOR c_rec IN L_Purge_Iface_Csr LOOP
          -- IS it an exported RECORD
          IF c_rec.cycle_count_entry_id IS NOT NULL THEN
             -- reset the export_flag in the mtl_cycle_count_entries table
             MTL_CCEOI_PROCESS_PVT.Set_CCExport(
                p_api_version => 0.9,
                X_return_status=> L_return_status,
                x_msg_count => L_msg_count,
                x_msg_data => L_msg_data,
                p_cycle_count_entry_id =>
                c_rec.cycle_count_entry_id,
                p_export_flag=> 2);
             --
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                ERRBUF := L_msg_data;
                RETCODE:= 'ERROR';
             ELSE
                RETCODE := 'SUCCESS';
             END IF;
          END IF;
          --
          --
          IF RETCODE = 'SUCCESS'THEN
             -- DELETE errors
             MTL_CCEOI_PROCESS_PVT.Delete_CCEOIError(
                p_cc_entry_interface_id => c_rec.cc_entry_interface_id);
             --
             -- DELETE interface RECORD
             MTL_CCEOI_PROCESS_PVT.Delete_CCIEntry(
                p_cc_entry_interface_id => c_rec.cc_entry_interface_id);
             --
             L_counter := L_counter + 1;
          END IF;
       END LOOP;
       --
    --   COMMIT;
       --
       -- How many rows are deleted
       FND_FILE.PUT_LINE(FND_FILE.LOG,
          'Deleted rows     ='|| TO_CHAR(L_counter));
       --
       IF RETCODE = 'SUCCESS'THEN
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',
             L_return_status);
       ELSIF
          RETCODE = 'WARNING'THEN
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
             L_return_status);
       ELSE
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
             L_return_status);
       END IF;
    END;
  END;
  --
  -- Worker for record processing
  PROCEDURE Worker_CCEntriesIface(
  ERRBUF  OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY VARCHAR2,
  P_CC_Interface_Group_Id IN NUMBER ,
  p_commit_point IN NUMBER DEFAULT 100,
  P_ErrorReportLev IN NUMBER DEFAULT 2,
  P_DeleteProcRec IN NUMBER DEFAULT 2)
  IS
     l_interface_id NUMBER;
     l_errorcode NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Worker_CCEntriesIface
    -- TYPE        : Private
    -- Pre-reqs   :
    -- FUNCTION:
    -- processed interface ROW sets AND calls according to the
    -- action code the apprepriate Private action API procedures
    -- Parameters :
    --     OUT    :
    --     ERRBUF OUT VARCHAR2 (required)
    --     returns any error message
    --
    --     RETCODE OUT VARCHAR2 (required)
    --     return completion status
    --     0 = 'SUCCESS'
    --     1 = 'WARNING'
    --     2 = 'ERROR'
    --
    --     IN           :
    --     P_CC_Interface_Group_Id IN NUMBER (required)
    --     Cycle COUNT Entries interface Group ID FOR RECORD processing
    --
    --     P_Commit_point IN NUMBER (required - defaulted)
    --     default = 100
    --     COMMIT Point FOR the worker process
    --
    --     P_ErrorReportLev NUMBER DEFAULT 2 (required - defaulted)
    --     Error Reporting Level
    --     1=Abort on first error.
    --     2=Process all errors and warnings.
    --
    --     P_DeleteProcRec NUMBER DEFAULT 2 (required - defaulted)
    --     DELETE Processed Record
    --     1=DELETE successfully processed rows.
    --     2=Do not delete processed rows.
    --
    -- Version : Current Version 0.9
    --
    --                                   initial version 0.9
    --
    -- Notes  :
    -- END OF comments
    DECLARE
       --
       CURSOR L_CCEOI_records_CSR(id IN NUMBER) IS
          SELECT * FROM MTL_CC_ENTRIES_INTERFACE
       WHERE
          CC_ENTRY_INTERFACE_GROUP_ID = id
--          AND LOCK_FLAG = 1  -- record will be locked by public API
          AND NVL(PROCESS_FLAG, 1) = 1
          AND NVL(PROCESS_MODE, 3) IN(2, 3)
          AND NVL(STATUS_FLAG,4)=4
          AND NVL(DELETE_FLAG,2)=2;
       --
       L_iface_rec MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE;
       L_errorcode NUMBER;
       L_return_status VARCHAR2(30);
       L_msg_count NUMBER;
       L_msg_data VARCHAR2(32000);
       L_CONC_STATUS BOOLEAN;
       L_counter integer := 0;
       --
    BEGIN

       --
       inv_cceoi_set_log_file ;
       ---FND_FILE.PUT_NAMES('/sqlcom/log', '/sqlcom/log', '/sqlcom/log');
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker');
       --
       -- Validate the input parameters
       IF P_CC_Interface_Group_Id < 1 THEN
          ERRBUF := FND_MESSAGE.GET_STRING('INV', 'INV_CCEOI_WRONG_GROUPID');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       --

       IF p_commit_point < 1 THEN
          ERRBUF := FND_MESSAGE.GET_STRING('INV', 'INV_CCEOI_WRONG_COMMITPOINT');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       --

       IF P_ErrorReportLev NOT IN(1, 2) THEN
          ERRBUF := FND_MESSAGE.GET_STRING('INV', 'INV_CCEOI_WRONG_ERRORLEVEL');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       --

       IF P_DeleteProcRec NOT IN(1, 2) THEN
          ERRBUF := FND_MESSAGE.GET_STRING('INV', 'INV_CCEOI_WRONG_DELETEREC');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

       -- END OF VALIDATION
       --
       -- Before processing lock all records for this worker
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: before process lock all recs');
       UPDATE mtl_cc_entries_interface
       SET
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = MTL_CCEOI_VAR_PVT.G_UserID,
          LAST_UPDATE_LOGIN = MTL_CCEOI_VAR_PVT.G_LoginID,
          PROGRAM_APPLICATION_ID = MTL_CCEOI_VAR_PVT.G_ProgramAppID,
          PROGRAM_ID = MTL_CCEOI_VAR_PVT.G_ProgramID,
          REQUEST_ID = MTL_CCEOI_VAR_PVT.G_RequestID,
          PROGRAM_UPDATE_DATE = sysdate
--          LOCK_FLAG = 1
       WHERE
          cc_entry_interface_group_id = P_CC_Interface_Group_ID
          AND NVL(lock_flag, 2) = 2
          AND NVL(PROCESS_FLAG, 1) = 1
          AND NVL(PROCESS_MODE, 3) IN(2, 3);
       commit;

       --
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: After process lock all recs');
       FOR c_rec IN L_CCEOI_records_CSR(P_CC_Interface_Group_ID) LOOP

          -- Current processed interface RECORD
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: Inside Loop-process IR ');
          MTL_CCEOI_VAR_PVT.G_cc_entry_interface_id :=
          c_rec.cc_entry_interface_id;
-- Defined by suresh
          MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID := c_rec.inventory_item_id;
          MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID := c_rec.cycle_count_header_id;
          MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY := c_rec.count_quantity;
          MTL_CCEOI_VAR_PVT.G_SECONDARY_COUNT_QUANTITY := c_rec.secondary_count_quantity; -- INVCONV
          MTL_CCEOI_VAR_PVT.G_COUNT_DATE := c_rec.count_date;
          MTL_CCEOI_VAR_PVT.G_LOCATOR_ID := c_rec.locator_id;
          MTL_CCEOI_VAR_PVT.G_SUBINVENTORY := c_rec.subinventory;
          -- Adding by suresh
          MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION := c_rec.revision;
          MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER := c_rec.LOT_NUMBER;
          MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER := c_rec.SERIAL_NUMBER;

          --p_sku_rec.revision := c_rec.revision;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'System Qty before assign IRec '||to_char(c_rec.system_quantity));
FND_FILE.PUT_LINE(FND_FILE.LOG, 'CCEntry ID '||to_char(c_rec.cycle_count_entry_id));
-- End of definition
          --
          	  L_iface_rec.parent_lpn_id := c_rec.parent_lpn_id;
          	  L_iface_rec.outermost_lpn_id := c_rec.outermost_lpn_id;
          	  L_iface_rec.cost_group_id := c_rec.cost_group_id;
           	  L_iface_rec.cc_entry_interface_id :=	c_rec.cc_entry_interface_id   	 ;
		  L_iface_rec.organization_id :=	c_rec.organization_id     	 ;
		  L_iface_rec.last_update_date :=	c_rec.last_update_date      	 ;
		  L_iface_rec.last_updated_by :=	c_rec.last_updated_by     	 ;
		  L_iface_rec.creation_date :=	c_rec.creation_date       	 ;
		  L_iface_rec.created_by :=	c_rec.created_by  	 ;
		  L_iface_rec.last_update_login :=	c_rec.last_update_login     	 ;
		  L_iface_rec.cc_entry_interface_group_id :=	c_rec.cc_entry_interface_group_id 	 ;
		  L_iface_rec.cycle_count_entry_id :=	c_rec.cycle_count_entry_id    	 ;
		  L_iface_rec.action_code :=	c_rec.action_code     	 ;
		  L_iface_rec.cycle_count_header_id :=	c_rec.cycle_count_header_id   	 ;
		  L_iface_rec.cycle_count_header_name :=	c_rec.cycle_count_header_name   	 ;
		  L_iface_rec.count_list_sequence :=	c_rec.count_list_sequence     	 ;
		  L_iface_rec.inventory_item_id :=	c_rec.inventory_item_id     	 ;
		  L_iface_rec.item_segment1 :=	c_rec.item_segment1       	 ;
		  L_iface_rec.item_segment2 :=	c_rec.item_segment2       	 ;
		  L_iface_rec.item_segment3 :=	c_rec.item_segment3       	 ;
		  L_iface_rec.item_segment4 :=	c_rec.item_segment4       	 ;
		  L_iface_rec.item_segment5 :=	c_rec.item_segment5       	 ;
		  L_iface_rec.item_segment6 :=	c_rec.item_segment6       	 ;
		  L_iface_rec.item_segment7 :=	c_rec.item_segment7       	 ;
		  L_iface_rec.item_segment8 :=	c_rec.item_segment8       	 ;
		  L_iface_rec.item_segment9 :=	c_rec.item_segment9       	 ;
		  L_iface_rec.item_segment10 :=	c_rec.item_segment10      	 ;
		  L_iface_rec.item_segment11 :=	c_rec.item_segment11      	 ;
		  L_iface_rec.item_segment12 :=	c_rec.item_segment12      	 ;
		  L_iface_rec.item_segment13 :=	c_rec.item_segment13      	 ;
		  L_iface_rec.item_segment14 :=	c_rec.item_segment14      	 ;
		  L_iface_rec.item_segment15 :=	c_rec.item_segment15      	 ;
		  L_iface_rec.item_segment16 :=	c_rec.item_segment16      	 ;
		  L_iface_rec.item_segment17 :=	c_rec.item_segment17      	 ;
		  L_iface_rec.item_segment18 :=	c_rec.item_segment18      	 ;
		  L_iface_rec.item_segment19 :=	c_rec.item_segment19      	 ;
		  L_iface_rec.item_segment20 :=	c_rec.item_segment20      	 ;
		  L_iface_rec.revision :=	c_rec.revision 	 ;
		  L_iface_rec.subinventory :=	c_rec.subinventory      	 ;
		  L_iface_rec.locator_id :=	c_rec.locator_id  	 ;
		  L_iface_rec.locator_segment1 :=	c_rec.locator_segment1      	 ;
		  L_iface_rec.locator_segment2 :=	c_rec.locator_segment2      	 ;
		  L_iface_rec.locator_segment3 :=	c_rec.locator_segment3      	 ;
		  L_iface_rec.locator_segment4 :=	c_rec.locator_segment4      	 ;
		  L_iface_rec.locator_segment5 :=	c_rec.locator_segment5      	 ;
		  L_iface_rec.locator_segment6 :=	c_rec.locator_segment6      	 ;
		  L_iface_rec.locator_segment7 :=	c_rec.locator_segment7      	 ;
		  L_iface_rec.locator_segment8 :=	c_rec.locator_segment8      	 ;
		  L_iface_rec.locator_segment9 :=	c_rec.locator_segment9      	 ;
		  L_iface_rec.locator_segment10 :=	c_rec.locator_segment10     	 ;
		  L_iface_rec.locator_segment11 :=	c_rec.locator_segment11     	 ;
		  L_iface_rec.locator_segment12 :=	c_rec.locator_segment12     	 ;
		  L_iface_rec.locator_segment13 :=	c_rec.locator_segment13     	 ;
		  L_iface_rec.locator_segment14 :=	c_rec.locator_segment14     	 ;
		  L_iface_rec.locator_segment15 :=	c_rec.locator_segment15     	 ;
		  L_iface_rec.locator_segment16 :=	c_rec.locator_segment16     	 ;
		  L_iface_rec.locator_segment17 :=	c_rec.locator_segment17     	 ;
		  L_iface_rec.locator_segment18 :=	c_rec.locator_segment18     	 ;
		  L_iface_rec.locator_segment19 :=	c_rec.locator_segment19     	 ;
		  L_iface_rec.locator_segment20 :=	c_rec.locator_segment20     	 ;
		  L_iface_rec.lot_number :=	c_rec.lot_number  	 ;
		  L_iface_rec.serial_number :=	c_rec.serial_number       	 ;
		  L_iface_rec.primary_uom_quantity :=	c_rec.primary_uom_quantity    	 ;
		  L_iface_rec.count_uom :=	c_rec.count_uom 	 ;
		  L_iface_rec.count_unit_of_measure :=	c_rec.count_unit_of_measure   	 ;
		  L_iface_rec.count_quantity :=	c_rec.count_quantity      	 ;
		  L_iface_rec.system_quantity :=	c_rec.system_quantity     	 ;
		  L_iface_rec.adjustment_account_id :=	c_rec.adjustment_account_id   	 ;
		  L_iface_rec.account_segment1 :=	c_rec.account_segment1      	 ;
		  L_iface_rec.account_segment2 :=	c_rec.account_segment2      	 ;
		  L_iface_rec.account_segment3 :=	c_rec.account_segment3      	 ;
		  L_iface_rec.account_segment4 :=	c_rec.account_segment4      	 ;
		  L_iface_rec.account_segment5 :=	c_rec.account_segment5      	 ;
		  L_iface_rec.account_segment6 :=	c_rec.account_segment6      	 ;
		  L_iface_rec.account_segment7 :=	c_rec.account_segment7      	 ;
		  L_iface_rec.account_segment8 :=	c_rec.account_segment8      	 ;
		  L_iface_rec.account_segment9 :=	c_rec.account_segment9      	 ;
		  L_iface_rec.account_segment10 :=	c_rec.account_segment10     	 ;
		  L_iface_rec.account_segment11 :=	c_rec.account_segment11     	 ;
		  L_iface_rec.account_segment12 :=	c_rec.account_segment12     	 ;
		  L_iface_rec.account_segment13 :=	c_rec.account_segment13     	 ;
		  L_iface_rec.account_segment14 :=	c_rec.account_segment14     	 ;
		  L_iface_rec.account_segment15 :=	c_rec.account_segment15     	 ;
		  L_iface_rec.account_segment16 :=	c_rec.account_segment16     	 ;
		  L_iface_rec.account_segment17 :=	c_rec.account_segment17     	 ;
		  L_iface_rec.account_segment18 :=	c_rec.account_segment18     	 ;
		  L_iface_rec.account_segment19 :=	c_rec.account_segment19     	 ;
		  L_iface_rec.account_segment20 :=	c_rec.account_segment20     	 ;
		  L_iface_rec.account_segment21 :=	c_rec.account_segment21     	 ;
		  L_iface_rec.account_segment22 :=	c_rec.account_segment22     	 ;
		  L_iface_rec.account_segment23 :=	c_rec.account_segment23     	 ;
		  L_iface_rec.account_segment24 :=	c_rec.account_segment24     	 ;
		  L_iface_rec.account_segment25 :=	c_rec.account_segment25     	 ;
		  L_iface_rec.account_segment26 :=	c_rec.account_segment26     	 ;
		  L_iface_rec.account_segment27 :=	c_rec.account_segment27     	 ;
		  L_iface_rec.account_segment28 :=	c_rec.account_segment28     	 ;
		  L_iface_rec.account_segment29 :=	c_rec.account_segment29     	 ;
		  L_iface_rec.account_segment30 :=	c_rec.account_segment30     	 ;
		  L_iface_rec.count_date :=	c_rec.count_date  	 ;
		  L_iface_rec.employee_id :=	c_rec.employee_id     	 ;
		  L_iface_rec.employee_full_name :=	c_rec.employee_full_name    	 ;
		  L_iface_rec.reference :=	c_rec.reference 	 ;
		  L_iface_rec.transaction_reason_id :=	c_rec.transaction_reason_id   	 ;
		  L_iface_rec.transaction_reason :=	c_rec.transaction_reason    	 ;
		  L_iface_rec.request_id :=	c_rec.request_id  	 ;
		  L_iface_rec.program_application_id :=	c_rec.program_application_id    	 ;
		  L_iface_rec.program_id :=	c_rec.program_id  	 ;
		  L_iface_rec.program_update_date :=	c_rec.program_update_date     	 ;
		  L_iface_rec.lock_flag :=	c_rec.lock_flag 	 ;
		  L_iface_rec.process_flag :=	c_rec.process_flag      	 ;
		  L_iface_rec.process_mode :=	c_rec.process_mode      	 ;
		  L_iface_rec.valid_flag :=	c_rec.valid_flag  	 ;
		  L_iface_rec.delete_flag :=	c_rec.delete_flag     	 ;
		  L_iface_rec.status_flag :=	c_rec.status_flag     	 ;
		  L_iface_rec.error_flag :=	c_rec.error_flag  	 ;
		  L_iface_rec.attribute_category :=	c_rec.attribute_category    	 ;
		  L_iface_rec.attribute1 :=	c_rec.attribute1  	 ;
		  L_iface_rec.attribute2 :=	c_rec.attribute2  	 ;
		  L_iface_rec.attribute3 :=	c_rec.attribute3  	 ;
		  L_iface_rec.attribute4 :=	c_rec.attribute4  	 ;
		  L_iface_rec.attribute5 :=	c_rec.attribute5  	 ;
		  L_iface_rec.attribute6 :=	c_rec.attribute6  	 ;
		  L_iface_rec.attribute7 :=	c_rec.attribute7  	 ;
		  L_iface_rec.attribute8 :=	c_rec.attribute8  	 ;
		  L_iface_rec.attribute9 :=	c_rec.attribute9  	 ;
		  L_iface_rec.attribute10 :=	c_rec.attribute10     	 ;
		  L_iface_rec.attribute11 :=	c_rec.attribute11     	 ;
		  L_iface_rec.attribute12 :=	c_rec.attribute12     	 ;
		  L_iface_rec.attribute13 :=	c_rec.attribute13     	 ;
		  L_iface_rec.attribute14 :=	c_rec.attribute14     	 ;
		  L_iface_rec.attribute15 :=	c_rec.attribute15     	 ;
		  L_iface_rec.project_id :=	c_rec.project_id  	 ;
		  L_iface_rec.task_id :=	c_rec.task_id 	 ;
		  -- BEGIN INVCONV
		  L_iface_rec.secondary_uom             :=  c_rec.secondary_uom;
		  L_iface_rec.secondary_unit_of_measure :=  c_rec.secondary_unit_of_measure;
		  L_iface_rec.secondary_count_quantity  :=  c_rec.secondary_count_quantity;
		  L_iface_rec.secondary_system_quantity :=  c_rec.secondary_system_quantity;
		  -- END INVCONV


          --
          --
	  FND_FILE.PUT_LINE(FND_FILE.LOG,'Worker :CountQty '||to_char(L_iface_rec.count_quantity));
	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: Action-'||to_char(c_rec.action_code));

	  MTL_CCEOI_ACTION_PUB.Import_CountRequest(
	    p_api_version => 0.9,
	    p_init_msg_list => FND_API.G_TRUE,
	    x_return_status => L_return_status,
	    x_msg_count => L_msg_count,
	    x_msg_data => L_msg_data,
	    x_errorcode => l_errorcode,
	    P_interface_rec => L_iface_rec,
	    x_interface_id=>l_interface_id);

/*	  -- switched to calling public API instead of repeating same code
          IF c_rec.action_code = 10 THEN
             -- Export not supported by the worker
             ERRBUF := FND_MESSAGE.GET_STRING('INV',
                'INV_CCEOI_UNKNOWN_ACTION_CODE');
             FND_FILE.PUT_LINE(FND_FILE.LOG,
                ERRBUF);
          ELSIF
             c_rec.action_code = MTL_CCEOI_VAR_PVT.G_VALIDATE THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: Action-is Vaildate ');
             MTL_CCEOI_ACTION_PVT.Validate_CountRequest(
                p_api_version => 0.9,
                p_init_msg_list => FND_API.G_TRUE,
                x_return_status => L_return_status,
                x_msg_count => L_msg_count,
                x_msg_data => L_msg_data,
                P_interface_rec => L_iface_rec);
          ELSIF
             c_rec.action_code = MTL_CCEOI_VAR_PVT.G_CREATE THEN
             MTL_CCEOI_ACTION_PVT.Create_CountRequest(
                p_api_version => 0.9,
                p_init_msg_list => FND_API.G_TRUE,
                x_return_status => L_return_status,
                x_msg_count => L_msg_count,
                x_msg_data => L_msg_data,
                P_interface_rec => L_iface_rec);
          ELSIF
             c_rec.action_code = MTL_CCEOI_VAR_PVT.G_VALSIM THEN
             MTL_CCEOI_ACTION_PVT.ValSim_CountRequest(
                p_api_version => 0.9,
                p_init_msg_list => FND_API.G_TRUE,
                x_return_status => L_return_status,
                x_msg_count => L_msg_count,
                x_msg_data => L_msg_data,
                P_interface_rec => L_iface_rec);
          ELSIF
             c_rec.action_code = MTL_CCEOI_VAR_PVT.G_PROCESS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: Action-is process ');
             MTL_CCEOI_ACTION_PVT.Process_CountRequest(
                p_api_version => 0.9,
                p_init_msg_list => FND_API.G_TRUE,
                x_return_status => L_return_status,
                x_msg_count => L_msg_count,
                x_msg_data => L_msg_data,
                P_interface_rec => L_iface_rec);
          ELSE
             --Action code NOT known
             ERRBUF :=FND_MESSAGE.GET_STRING('INV',
                'INV_CCEOI_UNKNOWN_ACTION_CODE');
             FND_FILE.PUT_LINE(FND_FILE.LOG,
                ERRBUF);

             IF p_errorreportlev = 1 THEN
                --
                -- Reswitch the Lockflag after failure
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: switch back lockflag-After Failure ');
                UPDATE mtl_cc_entries_interface
                SET
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = MTL_CCEOI_VAR_PVT.G_UserID,
                   LAST_UPDATE_LOGIN = MTL_CCEOI_VAR_PVT.G_LoginID,
                   PROGRAM_APPLICATION_ID = MTL_CCEOI_VAR_PVT.G_ProgramAppID,
                   PROGRAM_ID = MTL_CCEOI_VAR_PVT.G_ProgramID,
                   REQUEST_ID = MTL_CCEOI_VAR_PVT.G_RequestID,
                   PROGRAM_UPDATE_DATE = SYSDATE
--                   LOCK_FLAG = 2
                WHERE
                   cc_entry_interface_group_id = P_CC_Interface_Group_Id;
                COMMIT;
                --
                APP_EXCEPTION.RAISE_EXCEPTION;
             END IF;
          END IF;
*/
          --
IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             ERRBUF := L_msg_data;
             FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);
             --
             IF P_ErrorReportLev = 1 THEN
                --
                -- Reswitch the Lockflag after failure
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: switch back lock-flag -2 ');
                UPDATE mtl_cc_entries_interface
                SET
                   LAST_UPDATE_DATE = SYSDATE,
                   LAST_UPDATED_BY = MTL_CCEOI_VAR_PVT.G_UserID,
                   LAST_UPDATE_LOGIN = MTL_CCEOI_VAR_PVT.G_LoginID,
                   PROGRAM_APPLICATION_ID = MTL_CCEOI_VAR_PVT.G_ProgramAppID,
                   PROGRAM_ID = MTL_CCEOI_VAR_PVT.G_ProgramID,
                   REQUEST_ID = MTL_CCEOI_VAR_PVT.G_RequestID,
                   PROGRAM_UPDATE_DATE = SYSDATE
--                   LOCK_FLAG = 2
                WHERE
                   cc_entry_interface_group_id = P_CC_Interface_Group_ID;
                COMMIT;
                --
                APP_EXCEPTION.RAISE_EXCEPTION;
             END IF;
END IF;

          L_counter := L_counter + 1;
          IF L_counter = p_commit_point THEN
             COMMIT;
             L_counter :=0;
          END IF;
       END LOOP;
       commit;
       --
       -- Reswitch the Lockflag after failure
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: switch back lock-flag -3 ');
       UPDATE mtl_cc_entries_interface
       SET
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = MTL_CCEOI_VAR_PVT.G_UserID,
          LAST_UPDATE_LOGIN = MTL_CCEOI_VAR_PVT.G_LoginID,
          PROGRAM_APPLICATION_ID = MTL_CCEOI_VAR_PVT.G_ProgramAppID,
          PROGRAM_ID = MTL_CCEOI_VAR_PVT.G_ProgramID,
          REQUEST_ID = MTL_CCEOI_VAR_PVT.G_RequestID,
          PROGRAM_UPDATE_DATE = SYSDATE
  --        LOCK_FLAG = 2
       WHERE
          cc_entry_interface_group_id = P_CC_Interface_Group_ID;
       --
       commit;
       begin
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: Unexport all of them successfully processed');
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker:'||to_char(P_CC_Interface_Group_ID));
         Update mtl_cycle_count_entries
         set export_flag = 2
         where cycle_count_entry_id
         in (select cycle_count_entry_id
            from mtl_cc_entries_interface where
            cc_entry_interface_group_id = P_CC_Interface_Group_ID
            and status_flag = 0 );
         --
         commit;
       exception
       when others
       then
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Worker: Unexport Not updated ');
       end;
       IF P_DeleteProcRec = 1 THEN
          -- DELETE completed interface records
          -- All records which are marked FOR deletion delete_flag =1
          -- OR status_flag IN (0,1) AND error_flag = 2 will be deleted
          Purge_CCEntriesIface(ERRBUF => ERRBUF, RETCODE => RETCODE);
       END IF;
/*       IF RETCODE = 'SUCCESS'THEN
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',
             L_return_status);

       ELSIF
          RETCODE = 'WARNING'THEN
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',
             l_return_status);
       ELSE
          L_CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
             L_return_status);
       END IF;
*/
    END;
  END;
END MTL_CCEOI_CONC_PVT;

/
