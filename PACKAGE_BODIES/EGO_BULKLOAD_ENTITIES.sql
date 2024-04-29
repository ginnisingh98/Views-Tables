--------------------------------------------------------
--  DDL for Package Body EGO_BULKLOAD_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_BULKLOAD_ENTITIES" AS
/* $Header: EGOBKUPB.pls 120.13 2007/07/12 12:14:08 rsoundar ship $ */

  -------------------------------------------------------------------------
  -- Global constants
  -------------------------------------------------------------------------
  G_DATA_ROWS_READY_FOR_API NUMBER;
  G_DATA_ROWS_UPLOADED_NEW  NUMBER;
  G_ITEM_API                NUMBER;
  G_BOM_API                 NUMBER;
  --
  -- defining return statuses
  --
  G_RET_STS_SUCCESS        VARCHAR2(1);
  G_RET_STS_WARNING        VARCHAR2(1);
  G_RET_STS_ERROR          VARCHAR2(1);
  G_RET_STS_UNEXP_ERROR    VARCHAR2(1);
  -------------------------------------------------------------------------
  --  Debug Profile option used to write Error_Handler.Write_Debug       --
  --  Profile option name = INV_DEBUG_TRACE ;                            --
  --  User Profile Option Name = INV: Debug Trace                        --
  --  Values: 1 (True) ; 0 (False)                                       --
  --  NOTE: This better than MRP_DEBUG which is used at many places.     --
  -------------------------------------------------------------------------
  G_DEBUG            VARCHAR2(10);

-----------------------------------------------
-- Write Debug statements to Concurrent Log  --
-----------------------------------------------
PROCEDURE Write_Debug (p_msg  IN  VARCHAR2) IS
 l_err_msg VARCHAR2(240);
BEGIN
  -- If Profile set to TRUE --
  IF (G_DEBUG = 1) THEN
    FND_FILE.put_line(FND_FILE.LOG, p_msg);
  END IF;
-- sri_debug('EGOBKUPB: '||p_msg);
  EXCEPTION
   WHEN OTHERS THEN
    l_err_msg := SUBSTRB(SQLERRM, 1,240);
    FND_FILE.put_line(FND_FILE.LOG, 'LOGGING SQL ERROR => '||l_err_msg);
END Write_Debug;


------------------------------------------------
-- Defining the constants used in the program --
------------------------------------------------
PROCEDURE SetProcessConstants IS
BEGIN
  G_DATA_ROWS_READY_FOR_API := 1;
  G_DATA_ROWS_UPLOADED_NEW  := 0;
  G_ITEM_API                := 10;
  G_BOM_API                 := 20;

--  G_CONC_RET_STS_SUCCESS  CONSTANT  VARCHAR2(1) := '0';
--  G_CONC_RET_STS_WARNING  CONSTANT  VARCHAR2(1) := '1';
--  G_CONC_RET_STS_ERROR    CONSTANT  VARCHAR2(1) := '2';

  G_RET_STS_SUCCESS      := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_WARNING      := 'W';
  G_RET_STS_ERROR        := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR  := FND_API.G_RET_STS_UNEXP_ERROR;

   ------------------------------------------------------------------------
   --  Debug Profile option used to write Error_Handler.Write_Debug      --
   --  Profile option name = INV_DEBUG_TRACE ;                           --
   --  User Profile Option Name = INV: Debug Trace                       --
   --  Values: 1 (True) ; 0 (False)                                      --
   --  NOTE: This better than MRP_DEBUG which is used at many places.    --
   ------------------------------------------------------------------------
  G_DEBUG                := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

END SetProcessConstants;

PROCEDURE updateUploadedRowsToIntfTable (p_result_format_usage_id IN  NUMBER)
IS
  l_intf_status_tobe_process  NUMBER;
  l_intf_status_upload_done   NUMBER;

BEGIN
  l_intf_status_tobe_process  := 1;
  l_intf_status_upload_done   := 99;
  -- the bulkload line status must be changed
  -- to uploaded to appropriate interface tables
  UPDATE EGO_BULKLOAD_INTF
  SET process_status = l_intf_status_upload_done
  WHERE resultfmt_usage_id = p_result_format_usage_id
    AND process_status = l_intf_status_tobe_process;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END updateUploadedRowsToIntfTable;
  ---------------------------------------------------------------------
  -- Main Concurrent Program API called by Excel Loaders             --
  -- Currently handles Item and BOM related Bulkload.                --
  ---------------------------------------------------------------------
PROCEDURE BulkLoadEntities(
        ERRBUF                  OUT NOCOPY VARCHAR2,
        RETCODE                 OUT NOCOPY VARCHAR2,
        result_format_usage_id  IN      NUMBER,
        user_id                 IN      NUMBER,
        language                IN      VARCHAR2,
        resp_id                 IN      NUMBER,
        appl_id                 IN      NUMBER,
        p_start_upload          IN      VARCHAR2,
        p_data_set_id           IN      NUMBER
        )
IS

  l_region_application_id         NUMBER;
  l_customization_application_id  NUMBER;
  l_region_code                   VARCHAR2(30);
  Current_Error_Code              VARCHAR2(20);
  conc_status                     BOOLEAN;
  l_target_api_call               NUMBER;
  l_debug                         VARCHAR2(80);
  l_errbuf                        VARCHAR2(2000);
  l_retcode                       VARCHAR2(2000);

  CURSOR  find_object_type( p_rf_id number) is
  SELECT  CUSTOMIZATION_APPLICATION_ID,
          REGION_APPLICATION_ID,
          REGION_CODE
  FROM  EGO_RESULTS_FMT_USAGES
  WHERE   RESULTFMT_USAGE_ID = p_rf_id;

  ---------------------------------------------------------------------
  -- Enable Debug BOOLEAN Value.                                     --
  -- Only when this value is TRUE, then write the Logging statements --
  ---------------------------------------------------------------------
  l_Enable_Debug     BOOLEAN := FALSE;

BEGIN

  SetProcessConstants();

  l_region_application_id         := 0;
  l_customization_application_id  := 0;
  Current_Error_Code              := NULL;
  l_target_api_call               :=0;

  ----------------------------------------------------------
  -- Enable Logging, only if Debug Profile is set to TRUE --
  ----------------------------------------------------------
  IF (G_DEBUG = 1) THEN
    l_Enable_Debug := TRUE;
  END IF;

  ----------------------------------------------------------
  -- Print the list of conc program parameters
  ----------------------------------------------------------
  Write_Debug('Following are the parameters to the program EGO_BULKLOAD_ENTITIES.BulkLoadEntities ');
  Write_Debug('************************************************************');
  Write_Debug('RESULT_FORMAT_USAGE_ID : '||to_char(result_format_usage_id));
  Write_Debug('USER_ID : '||to_char(user_id));
  Write_Debug('LANGUAGE : '||language);
  Write_Debug('RESP_ID : '|| to_char(resp_id));
  Write_Debug('APPL_ID : '||to_char(appl_id));
  Write_Debug('************************************************************');
  Write_Debug('Following are the other important values: ');
  Write_Debug('Login id : '||to_char(FND_GLOBAL.login_id));
  Write_Debug('Program Application Id : '||to_char(FND_GLOBAL.prog_appl_id));
  Write_Debug('Concurrent Program Id : '||to_char(FND_GLOBAL.conc_program_id));

  UPDATE EGO_BULKLOAD_INTF
  SET
    PROCESS_STATUS = G_DATA_ROWS_READY_FOR_API,
    LAST_UPDATE_LOGIN = FND_GLOBAL.login_id,
    REQUEST_ID = FND_GLOBAL.conc_request_id,
    PROGRAM_APPLICATION_ID = FND_GLOBAL.prog_appl_id,
    PROGRAM_ID = FND_GLOBAL.conc_program_id
  WHERE RESULTFMT_USAGE_ID = result_format_usage_id
    AND process_status = G_DATA_ROWS_UPLOADED_NEW;

  FOR C1 IN find_object_type(result_format_usage_id)
  LOOP
    l_region_application_id := C1.REGION_APPLICATION_ID;
    l_customization_application_id := C1.CUSTOMIZATION_APPLICATION_ID;
    l_region_code := C1.REGION_CODE;

    EXIT WHEN find_object_type%NOTFOUND;
    IF l_customization_application_id = 431
    AND l_region_application_id = 431
    AND substr(l_region_code,1,8) =  'EGO_ITEM' THEN
      l_target_api_call := G_ITEM_API;
    ELSIF l_customization_application_id = 431
    AND l_region_application_id = 702
    AND substr(l_region_code,1,4) =  'BOM_' THEN
      l_target_api_call := G_BOM_API;
    ELSE
     Write_Debug('THE REGN CODE IS ' || l_region_code);
    END IF;

  END LOOP; --end: FOR C1 IN find_object_type(result_format_usage_id)

  IF l_target_api_call = G_ITEM_API THEN

     FND_FILE.PUT_LINE( FND_FILE.LOG,'Calling Item Bulkload API....');
     ----------------------------------------------------------------------
     -- Process Item Interface Lines
     ----------------------------------------------------------------------
     EGO_ITEM_BULKLOAD_PKG.process_item_interface_lines
               (
                 p_resultfmt_usage_id    => result_format_usage_id,
                 p_user_id               => user_id,
                 p_language_code         => language,
                 p_caller_identifier     => EGO_ITEM_BULKLOAD_PKG.G_ITEM,
                 p_conc_request_id       => FND_GLOBAL.conc_request_id,
                 p_start_upload          => p_start_upload,
                 p_data_set_id           => p_data_set_id,
                 x_errbuff               => l_errbuf,
                 x_retcode               => l_retcode
                );

  ELSIF l_target_api_call = G_BOM_API THEN

     FND_FILE.PUT_LINE( FND_FILE.LOG,'Calling Item Bulkload API AND THEN BOM BULKLOAD....');
     EGO_ITEM_BULKLOAD_PKG.process_item_interface_lines
               (
                 p_resultfmt_usage_id    => result_format_usage_id,
                 p_user_id               => user_id,
                 p_language_code         => language,
                 p_caller_identifier     => EGO_ITEM_BULKLOAD_PKG.G_BOM,
                 p_conc_request_id       => FND_GLOBAL.conc_request_id,
                 p_start_upload          => p_start_upload,
                 p_data_set_id           => p_data_set_id,
                 x_errbuff               => l_errbuf,
                 x_retcode               => l_retcode
                );
      ---------------------------------------------------------------------
      -- Return CODE FOR ITEM IF ANY
      ---------------------------------------------------------------------
      Write_Debug('ITEM ERRORS IF ANY ARE CODE='|| l_retcode);
      Write_Debug('ITEM ERRORS IF ANY ARE BUFFER='|| l_errbuf);

      IF NVL(l_retcode ,G_RET_STS_SUCCESS) NOT IN
            ( G_RET_STS_SUCCESS
            , G_RET_STS_WARNING
            )  THEN
        updateUploadedRowsToIntfTable (p_result_format_usage_id => result_format_usage_id);
        ERRBUF  := l_errbuf;
        RETCODE := l_retcode;
        RETURN;
      END IF;

      ---------------------------------------------------------------------
      -- Setting PROCESS_STATUS to 1 Prior to Calling BOM APIs
      ---------------------------------------------------------------------
      UPDATE  EGO_BULKLOAD_INTF
        SET   PROCESS_STATUS = 1
      WHERE   RESULTFMT_USAGE_ID = result_format_usage_id;

      COMMIT;

      /*
        SNELLOLI: CALL THE BOM API
        after setting the process status to 1 again
        has to check for errors later
        UPDATE EGO_BULKLOAD_INTF SET PROCESS_STATUS = 1
        WHERE RESULTFMT_USAGE_ID = result_format_usage_id;
        commit;
      */
      FND_FILE.PUT_LINE( FND_FILE.LOG,'Calling BOM BULKLOAD AFTER UPDATION');
      Bom_import_pub.Process_Structure_Data
        (  p_batch_id              => p_data_set_id,
           p_resultfmt_usage_id    => result_format_usage_id,
           p_user_id               => user_id,
           p_conc_request_id       => FND_GLOBAL.conc_request_id,
           p_language_code         => language,
           p_start_upload          => FND_API.G_FALSE, -- always send FALSE here
           x_errbuff               => l_errbuf,
           x_retcode               => l_retcode
          );

  END IF; --end: IF l_target_api_call = G_ITEM_API THEN

  -------------------------------------------------------------------------
  -- Setting the last values for l_errbuf, l_retcode to the Concurrent
  -- Program return values. These last values carry the Latest status
  -- of the Concurrent Program.
  -------------------------------------------------------------------------
  updateUploadedRowsToIntfTable (p_result_format_usage_id => result_format_usage_id);
  ERRBUF := NVL(l_errbuf, G_RET_STS_SUCCESS);
  RETCODE := l_retcode;

  Write_Debug('EGO_BULKLOAD_ENTITIES.BulkLoadEntities RETCODE => '|| RETCODE);
  Write_Debug('EGO_BULKLOAD_ENTITIES.BulkLoadEntities ERRBUF => '|| ERRBUF);

  EXCEPTION
    WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Others '||SQLCODE || ':'||SQLERRM);
       RETCODE := G_RET_STS_ERROR;
       Current_Error_Code := To_Char(SQLCODE);
       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', Current_Error_Code);

END BulkLoadEntities;



  /*
   * This Procedure is called from Excel Import
   * it will launch the concurrent program and call API to update
   * the request id into ego_import_batches_b table
   */
  PROCEDURE Run_Import_Program(
            p_resultfmt_usage_id            IN  NUMBER,
            p_user_id                       IN  NUMBER,
            p_language                      IN  VARCHAR2,
            p_resp_id                       IN  NUMBER,
            p_appl_id                       IN  NUMBER,
            p_run_from                      IN  VARCHAR2,
            p_create_new_batch              IN  VARCHAR2,
            p_batch_id                      IN  NUMBER,
            p_batch_name                    IN  VARCHAR2,
            p_auto_imp_on_data_load         IN  VARCHAR2,
            p_auto_match_on_data_load       IN  VARCHAR2,
            p_change_order_option           IN  VARCHAR2,
            p_add_all_items_to_CO           IN  VARCHAR2,
            p_change_order_category         IN  VARCHAR2,
            p_change_order_type             IN  VARCHAR2,
            p_change_order_name             IN  VARCHAR2,
            p_change_order_number           IN  VARCHAR2,
            p_change_order_desc             IN  VARCHAR2,
            p_schedule_date                 IN  DATE,
            p_nir_option                     IN VARCHAR2,
            x_request_id                    OUT NOCOPY NUMBER)
  IS
    l_request_id        NUMBER;
    l_imp_request_id    NUMBER;
    l_match_request_id  NUMBER;
  BEGIN
    Write_Debug('EGO_BULKLOAD_ENTITIES.Run_Import_Program: p_schedule_date: ' || p_schedule_date);
    Write_Debug('EGO_BULKLOAD_ENTITIES.Run_Import_Program: formatted date - p_schedule_date: ' ||  to_char(p_schedule_date, 'YYYY/MM/DD HH24:MI:SS'));
    l_request_id := FND_REQUEST.Submit_Request
                        (
                            application => 'EGO'
                          , program     => 'EGOIJAVA'
                          , argument1   => p_resultfmt_usage_id
                          , argument2   => p_user_id
                          , argument3   => p_language
                          , argument4   => p_resp_id
                          , argument5   => p_appl_id
                          , argument6   => p_run_from
                          , argument7   => p_create_new_batch
                          , argument8   => p_batch_id
                          , argument9   => p_batch_name
                          , argument10  => p_auto_imp_on_data_load
                          , argument11  => p_auto_match_on_data_load
                          , argument12  => p_change_order_option
                          , argument13  => p_add_all_items_to_CO
                          , argument14  => p_change_order_category
                          , argument15  => p_change_order_type
                          , argument16  => p_change_order_name
                          , argument17  => p_change_order_number
                          , argument18  => p_change_order_desc
                          , argument19  => to_char(p_schedule_date, 'YYYY/MM/DD HH24:MI:SS')
                          , argument20  => NULL
                          , argument21  => p_nir_option
                        );

    x_request_id := l_request_id;

    IF l_request_id > 0 THEN
      IF p_auto_imp_on_data_load = 'Y' THEN
        l_imp_request_id := l_request_id;
      END IF;
      IF p_auto_match_on_data_load = 'Y' THEN
        l_match_request_id := l_request_id;
      END IF;

      EGO_IMPORT_PVT.Update_Request_Id_To_Batch(
             p_import_request_id   => l_imp_request_id,
             p_match_request_id    => l_match_request_id,
             p_batch_id            => p_batch_id);
    END IF; --IF l_request_id > 0 THEN
    COMMIT;
  END Run_Import_Program;

END ;

/
