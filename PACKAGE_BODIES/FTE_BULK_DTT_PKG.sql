--------------------------------------------------------
--  DDL for Package Body FTE_BULK_DTT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_BULK_DTT_PKG" AS
/* $Header: FTEDISUB.pls 115.7 2004/01/27 00:41:21 ablundel noship $ */
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_BULK_DTT_PKG                                              --
--                                                                            --
-- TYPE:        PACKAGE BODY                                                  --
--                                                                            --
-- DESCRIPTION: Read a file containing DTT data from the directory specified  --
--              in FTE_BULKLOAD_PKG.GET_DIRNAME and create location/mileage   --
--              records in FTE_LOCATION_MILEAGES table                        --
--                                                                            --
--              PROCEDURE BULK_LOAD_DTT called from BulkLoadDataCO.java to    --
--              start the loading process. submits a request to a concurrent  --
--              program to execute the loading process                        --
--                                                                            --
--              PROCEDURE LOAD_DTT_FILE called by the concurrent program to   --
--              execute the loading of the Distance and Transit Tine (DTT)    --
--              file                                                          --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created.                           --
--                                                                            --
-- 2003/12/08  J        ABLUNDEL  3301222  PROCEDURE: READ_DTT_FILE           --
--                                         replaced the MERGE INTO statement  --
--                                         with some code that is 8i compatibl--
--                                         as the MERGE statement can only be --
--                                         used with 8i or higher             --
--                                                                            --
-- 2003/12/17  J        ABLUNDEL  3325486  PROCEDURE: READ_DTT_FILE           --
--                                         Added a REPLACE in the substring   --
--                                         to remove tabs from the mileage and--
--                                         time return values. NB The TAB     --
--                                         equates to 1 space                 --
--                                                                            --
-- 2004/01/22  J        ABLUNDEL  3381771  PROCEDURE: READ_DTT_FILE           --
--                                         Added a check to se if the input   --
--                                         line is blank or contains only     --
--                                         space or tab chars                 --
--                                                                            --
-- -------------------------------------------------------------------------- --

-- -------------------------------------------------------------------------- --
-- Global Package Variables                                                   --
-- ------------------------                                                   --
--                                                                            --
-- -------------------------------------------------------------------------- --
G_PKG_NAME               CONSTANT VARCHAR2(50)   := 'FTE_BULK_DTT_PKG';
g_user_id                CONSTANT NUMBER         := FND_GLOBAL.USER_ID;

g_bulk_insert_limit      CONSTANT NUMBER := 250;
g_total_numcharts        NUMBER;
g_chart_count_temp       NUMBER         := 0;

g_valid_date             DATE;
g_valid_date_string      VARCHAR2(20);
g_scac                   VARCHAR2(10);

g_ret_dist_col_name      CONSTANT VARCHAR2(30) := 'RETURNDIST';
g_ret_time_col_name      CONSTANT VARCHAR2(30) := 'RETURNTIME';


-- AXE
g_time_hour              CONSTANT VARCHAR2(4)  := 'Hour';
g_time_minute            CONSTANT VARCHAR2(6)  := 'Minute';
g_distance_mile          CONSTANT VARCHAR2(4)  := 'Mile';
g_distance_kilometer     CONSTANT VARCHAR2(9)  := 'Kilometer';


-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                PROCEDURE BULK_LOAD_DTT                               --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT): p_load_id        IN NUMBER   The load id of the job   --
--                      p_src_filename   IN VARCHAR2                          --
--                      p_resp_id        IN NUMBER                            --
--                      p_resp_appl_id   IN NUMBER                            --
--                      p_user_id        IN NUMBER                            --
--                      p_user_debug     IN NUMBER                            --
--                                                                            --
-- PARAMETERS (OUT):    x_request_id: The request id of the bulkload process  --
--                      x_error_msg_text:                                     --
--                                                                            --
-- RETURN:              n/a                                                   --
--                                                                            --
-- DESCRIPTION:         Purpose This is the starting point of the bulkloading --
--                      process. Submits a request to a concurrent program,   --
--                      that starts the location/mileage loading process      --
--                      Called from $fte/java/catalog/BulkLoadDataCO.java for --
--                      Uploading DTT file                                    --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE BULK_LOAD_DTT(p_load_id        IN         NUMBER,
                        p_src_filename   IN         VARCHAR2,
                        p_resp_id        IN         NUMBER,
                        p_resp_appl_id   IN         NUMBER,
                        p_user_id        IN         NUMBER,
                        p_user_debug     IN         NUMBER,
                        x_request_id     OUT NOCOPY NUMBER,
                        x_error_msg_text OUT NOCOPY VARCHAR2) IS



x_src_filedir  VARCHAR2(100);
l_debug_on     BOOLEAN;
l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' ||'BULK_LOAD_DTT';
l_error_text   VARCHAR2(2000);


BEGIN


   g_user_debug     := p_user_debug;
   --
   -- SETUP DEBUGGING
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF (g_user_debug = 1) THEN
     l_debug_on := TRUE;
   END IF;


    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
      WSH_DEBUG_SV.log(l_module_name,'Procedure = ',l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_load_id',p_load_id);
      WSH_DEBUG_SV.log(l_module_name,'p_src_filename',p_src_filename);
      WSH_DEBUG_SV.log(l_module_name,'p_resp_id',p_resp_id);
      WSH_DEBUG_SV.log(l_module_name,'p_resp_appl_id',p_resp_appl_id);
      WSH_DEBUG_SV.log(l_module_name,'p_user_id',p_user_id);
      WSH_DEBUG_SV.log(l_module_name,'p_user_debug',p_user_debug);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling fnd_global.apps_initialize with p_user_id,p_resp_id,p_resp_appl_id');
   END IF;

   fnd_global.apps_initialize(user_id      => p_user_id,
                              resp_id      => p_resp_id,
                              resp_appl_id => p_resp_appl_id);



    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling FTE_BULKLOAD_PKG.GET_UPLOAD_DIR to get the file directory');
    END IF;


    x_src_filedir := FTE_BULKLOAD_PKG.GET_UPLOAD_DIR;


    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_src_filedir = ',x_src_filedir);
    END IF;


    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling FND_REQUEST.SUBMIT_REQUEST to submoit the request to the concurrent program');
    END IF;


    x_request_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'FTE',
                                               program      => 'FTE_BULK_DTT_LOADER',
                                               description  => null,
                                               start_time   => null,
                                               sub_request  => false,
                                               argument1    => p_load_id,
                                               argument2    => p_src_filename,
                                               argument3    => x_src_filedir,
                                               argument4    => p_user_debug);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_request_id = ',x_request_id);
    END IF;


    x_error_msg_text := fnd_message.get;

    commit;

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name, 'x_error_msg_text', x_error_msg_text);
       WSH_DEBUG_SV.log(l_module_name, 'x_src_filedir', x_src_filedir);
       WSH_DEBUG_SV.log(l_module_name, 'x_request_id', x_request_id);
       WSH_DEBUG_SV.log(l_module_name, 'p_user_id', p_user_id);
       WSH_DEBUG_SV.log(l_module_name, 'p_resp_id', p_resp_id);
       WSH_DEBUG_SV.log(l_module_name, 'p_resp_appl_id', p_resp_appl_id);
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    RETURN;

EXCEPTION
   WHEN OTHERS THEN
      l_error_text := sqlerrm;
      Fnd_File.Put_Line(Fnd_File.Log, 'Unexpected Error in Procedure BULK_LOAD_DTT' || sqlerrm);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'THE UNEXPECTED ERROR FROM FTE_BULK_DTT_PKG.BULK_LOAD_DTT IS ' ||l_error_text);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||l_error_text,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

      RETURN;


END BULK_LOAD_DTT;




-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                PROCEDURE LOAD_DTT_FILE                               --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT): p_load_id        IN NUMBER   The load id of the job   --
--                      p_src_filename   IN VARCHAR2                          --
--                      p_src_filedir    IN VARCHAR2                          --
--                      p_user_debug     IN NUMBER                            --
--                                                                            --
--                      1. p_load_id: The load id of the bulkload job.        --
--                      2. p_src_filename: The filename of the file containing--
--                                         the DTT data.                      --
--                      3. p_src_filedir: The directory containing the DTT    --
--                                        data file. There should be no       --
--                                        trailing '/', and this directory    --
--                                        should be readable by UTL_FILE      --
--                      4. p_user_debug: turns the debugger on                --
--                                                                            --
-- PARAMETERS (OUT):    p_errbuf: A buffer of error messages                  --
--                      p_retcode: The return code. A return code of '2'      --
--                                 specifies ERROR                            --
--                                                                            --
-- RETURN:              n/a                                                   --
--                                                                            --
-- DESCRIPTION:         Runs the entire DTT Bulkloading process               --
--                      Called from the FTE_BULK_DTT_LOADER concurrent program--
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE LOAD_DTT_FILE(p_errbuf        OUT NOCOPY VARCHAR2,
                        p_retcode       OUT NOCOPY VARCHAR2,
                        p_load_id       IN NUMBER,
                        p_src_filename  IN VARCHAR2,
                        p_src_filedir   IN VARCHAR2,
                        p_user_debug    IN NUMBER) IS



g_first_time           BOOLEAN;
x_status               NUMBER;

l_debug_on     BOOLEAN;
l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' ||'LOAD_DTT_FILE';
l_error_text   VARCHAR2(2000);


BEGIN

   FND_FILE.PUT_LINE(FND_FILE.log, 'LOAD_DTT_FILE');

   x_status          := -1;
   g_user_debug      := p_user_debug;
   g_first_time      := FIRST_TIME;

   --
   -- SETUP DEBUGGING
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF (g_user_debug = 1) THEN
     l_debug_on := TRUE;
   END IF;


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'-------LOAD_DTT_FILE-------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
      WSH_DEBUG_SV.log(l_module_name,'p_load_id',p_load_id);
      WSH_DEBUG_SV.log(l_module_name,'p_src_filename',p_src_filename);
      WSH_DEBUG_SV.log(l_module_name,'p_src_filedir',p_src_filedir);
      WSH_DEBUG_SV.log(l_module_name,'p_user_debug',p_user_debug);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Check If this is the first time by calling function FIRST_TIME');
   END IF;

   IF (FIRST_TIME) THEN

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'This is the first time calling FTE_BULK_DTT_PKG.READ_DTT_FILE');
         WSH_DEBUG_SV.logmsg(l_module_name,'with parameters: p_src_filedir,p_src_filename,p_load_id');
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.log, 'Calling READ_DTT_FILE');

      FTE_BULK_DTT_PKG.READ_DTT_FILE(p_src_filedir,
                                     p_src_filename,
                                     p_load_id,
                                     p_errbuf,
                                     x_status);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Back from FTE_BULK_DTT_PKG.READ_DTT_FILE');
         WSH_DEBUG_SV.log(l_module_name,'x_status',x_status);
      END IF;

   END IF;

   IF (x_status = -1) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The file Reading and upload was successful');
      END IF;

      --
      -- Concurrent Manager expects 0 for success.
      --
      p_retcode := 0;
      p_errbuf := 'COMPLETED DTT LOADING SUCCESSFULLY';
   ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Errors occurred during the upload');
      END IF;

      p_retcode := 2;
      p_errbuf := 'COMPLETED WITH ERRORS. ' || p_errbuf || '. Please Check Logs for more details.';
   END IF;


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;


EXCEPTION
   WHEN OTHERS THEN
      l_error_text := SQLERRM;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '*****ERROR**** '||l_error_text);
      p_retcode := 2;
      p_errbuf  := p_errbuf || sqlerrm;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'THE UNEXPECTED ERROR FROM FTE_BULK_DTT_PKG.LOAD_DTT_FILE IS ' ||l_error_text);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||l_error_text,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

      RETURN;


END LOAD_DTT_FILE;



-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                READ_DTT_FILE                                         --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT): p_source_file_directory  IN VARCHAR2                  --
--                      p_source_file_name       IN VARCHAR2                  --
--                      p_load_id                IN VARCHAR2                  --
--                                                                            --
-- PARAMETERS (OUT):    x_return_message       OUT NOCOPY VARCHAR2            --
--                      x_return_status        OUT NOCOPY NUMBER              --
--                                                                            --
-- RETURN:              n/a                                                   --
--                                                                            --
-- DESCRIPTION:         Reads the DTT data file. Gets the relevant origin and --
--                      destination ids from fte_mile_download_lines and      --
--                      stores the information in a global temp table:        --
--                      FTE_DISTANCE_LOADER_TMP and then inserts or updates   --
--                      the values into the FTE_LOCATION_MILEAGES table       --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created                            --
--                                                                            --
-- 2003/12/08  J        ABLUNDEL  3301222  replaced the MERGE INTO statement  --
--                                         with some code that is 8i compatibl--
--                                         as the MERGE statement can only be --
--                                         used with 8i or higher             --
--                                                                            --
-- 2003/12/17  J        ABLUNDEL  3325486  Added a REPLACE in the substring   --
--                                         to remove tabs from the mileage and--
--                                         time return values. NB The TAB     --
--                                         equates to 1 space                 --
--                                                                            --
-- 2004/01/22  J        ABLUNDEL  3381771  Added a check to se if the input   --
--                                         line is blank or contains only     --
--                                         space or tab chars                 --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE READ_DTT_FILE(p_source_file_directory  IN VARCHAR2,
                        p_source_file_name       IN VARCHAR2,
                        p_load_id                IN VARCHAR2,
                        x_return_message         OUT NOCOPY VARCHAR2,
                        x_return_status          OUT NOCOPY NUMBER) IS



l_upload_date              DATE;
l_dtt_file                 UTL_FILE.file_type;
l_line                     VARCHAR2(2000);
l_load_ctr                 PLS_INTEGER;
l_cur_date                 DATE;
l_line_ctr                 PLS_INTEGER;
l_dtt_file_name            VARCHAR2(50);
l_download_file_id         NUMBER;
l_template_id              NUMBER;
l_download_date            DATE;
l_download_count           NUMBER;
l_ret_dist_col_id          NUMBER;
l_ret_dist_start_pos       NUMBER;
l_ret_dist_length          NUMBER;
l_ret_dist_enabled_flag    VARCHAR2(1);
l_ret_dist_return_format   VARCHAR2(10);
l_ret_dist_db_uom          VARCHAR2(3);
l_ret_time_col_id          NUMBER;
l_ret_time_start_pos       NUMBER;
l_ret_time_length          NUMBER;
l_ret_time_enabled_flag    VARCHAR2(1);
l_ret_time_return_format   VARCHAR2(10);
l_ret_time_db_uom          VARCHAR2(3);
l_identifier_type          VARCHAR2(30);
l_conv_flag                VARCHAR2(10);
l_ret_time_val             VARCHAR2(50);
l_ret_dist_val             VARCHAR2(50);
l_ret_time                 NUMBER;
l_ret_dist                 NUMBER;
l_ret_mins                 NUMBER;
l_ret_hrs                  NUMBER;
l_tmp_count                PLS_INTEGER;
l_number_of_table_lines    NUMBER;



l_origin_id_tab                   FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_destination_id_tab              FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_origin_id              FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_destination_id         FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_identifier_type        FTE_BULK_DTT_PKG.fte_distu_tmp_code_table;
l_location_distance               FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_distance_uom           FTE_BULK_DTT_PKG.fte_distu_tmp_uom_table;
l_location_transit_time           FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_transit_time_uom       FTE_BULK_DTT_PKG.fte_distu_tmp_uom_table;
l_location_creation_date          FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_location_created_by             FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_last_update_date       FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_location_last_updated_by        FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_last_update_login      FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_program_app_id         FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_program_id             FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_location_program_update_date    FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_location_request_id             FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_deleted_download_ids            FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;



cursor c_check_download_lines(cp_download_file_id NUMBER) IS
select count(fmdl.download_file_id)
from   fte_mile_download_lines fmdl
where  fmdl.download_file_id = cp_download_file_id;


cursor c_get_file_info(cp_file_name VARCHAR2) IS
select fmdf.download_file_id,
       fmdf.template_id,
       fmdf.download_date,
       fmdf.upload_date,
       fmdf.identifier_type
from   fte_mile_download_files fmdf
where  fmdf.file_name = cp_file_name;


cursor c_get_download_lines(cp_download_file_id NUMBER) IS
select fmdl.origin_id,
       fmdl.destination_id
from   fte_mile_download_lines fmdl
where  fmdl.download_file_id = cp_download_file_id;


cursor c_get_ret_col_info(cp_column_type VARCHAR2,
                          cp_template_id NUMBER) IS
select fmtc.column_id,
       fmtc.start_position,
       fmtc.length
from   fte_mile_template_columns fmtc
where  fmtc.column_type = cp_column_type
and    fmtc.template_id = cp_template_id;


cursor c_get_ret_enabled(cp_column_id NUMBER) IS
select fmca.enabled_flag,
       fmca.return_format,
       fmca.db_uom
from   fte_mile_column_attributes fmca
where  fmca.column_id = cp_column_id;



FTE_DIST_NULL_FILE_NAME        EXCEPTION;
FTE_DIST_INV_FILENAME_LGTH     EXCEPTION;
FTE_DIST_NO_FILE_DOWNLOAD      EXCEPTION;
FTE_DIST_NO_FILE_TEMPLATE      EXCEPTION;
FTE_DIST_NO_FILE_DOWNLOAD_DATE EXCEPTION;
FTE_DIST_FILE_UPLOAD_DONE_PREV EXCEPTION;
FTE_DIST_NO_DOWNLOAD_LINES     EXCEPTION;
FTE_DIST_RET_DIST_COL_NO_DATA  EXCEPTION;
FTE_DIST_RET_TIME_COL_NO_DATA  EXCEPTION;
FTE_DIST_NO_RET_COL_ENABLED    EXCEPTION;
FTE_DIST_LESS_FILE_LINES       EXCEPTION;
FTE_DIST_MANY_FILE_LINES       EXCEPTION;




l_debug_on     BOOLEAN;
l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' ||'READ_DTT_FILE';
l_error_text   VARCHAR2(2000);



--
-- [ABLUNDEL][12/08/2003][BUG# 3301222]
--
-- The following variable declarations were added to support the bug fix for the
-- 8i - 9i compatibility problem with the MERGE statement
--
--
cursor c_get_merge_data is
select tt.origin_id,
       tt.destination_id,
       fdlt.origin_id,
       fdlt.destination_id,
       fdlt.identifier_type,
       fdlt.distance,
       fdlt.distance_uom,
       fdlt.transit_time,
       fdlt.transit_time_uom,
       fdlt.creation_date,
       fdlt.created_by,
       fdlt.last_update_date,
       fdlt.last_updated_by,
       fdlt.last_update_login,
       fdlt.program_application_id,
       fdlt.program_id,
       fdlt.program_update_date,
       fdlt.request_id
from (SELECT origin_id,
             destination_id,
             identifier_type,
             distance,
             distance_uom,
             transit_time,
             transit_time_uom,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             program_application_id,
             program_id,
             program_update_date,
             request_id FROM FTE_DISTANCE_LOADER_TMP) fdlt,
      FTE_LOCATION_MILEAGES tt
where fdlt.origin_id      = tt.origin_id(+)
and   fdlt.destination_id = tt.destination_id(+);


l_u_origin_id_tab                 FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_u_destination_id_tab            FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_u_identifier_type_tab           FTE_BULK_DTT_PKG.fte_distu_tmp_code_table;
l_u_distance_tab                  FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_u_distance_uom_tab              FTE_BULK_DTT_PKG.fte_distu_tmp_uom_table;
l_u_transit_time_tab              FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_u_transit_time_uom_tab          FTE_BULK_DTT_PKG.fte_distu_tmp_uom_table;
l_u_last_update_date_tab          FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_u_last_updated_by_tab           FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_u_last_update_login_tab         FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_u_program_app_id_tab            FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_u_program_id_tab                FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_u_program_update_date_tab       FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_u_request_id_tab                FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;

l_i_origin_id_tab                 FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_destination_id_tab            FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_identifier_type_tab           FTE_BULK_DTT_PKG.fte_distu_tmp_code_table;
l_i_distance_tab                  FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_distance_uom_tab              FTE_BULK_DTT_PKG.fte_distu_tmp_uom_table;
l_i_transit_time_tab              FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_transit_time_uom_tab          FTE_BULK_DTT_PKG.fte_distu_tmp_uom_table;
l_i_creation_date_tab             FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_i_created_by_tab                FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_last_update_date_tab          FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_i_last_updated_by_tab           FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_last_update_login_tab         FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_program_app_id_tab            FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_program_id_tab                FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_i_program_update_date_tab       FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_i_request_id_tab                FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;

l_old_origin_id_tab               FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_old_destination_id_tab          FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_origin_id_tab               FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_destination_id_tab          FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_identifier_type_tab         FTE_BULK_DTT_PKG.fte_distu_tmp_code_table;
l_new_distance_tab                FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_distance_uom_tab            FTE_BULK_DTT_PKG.fte_distu_tmp_uom_table;
l_new_transit_time_tab            FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_transit_time_uom_tab        FTE_BULK_DTT_PKG.fte_distu_tmp_uom_table;
l_new_creation_date_tab           FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_new_created_by_tab              FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_last_update_date_tab        FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_new_last_updated_by_tab         FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_last_update_login_tab       FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_program_app_id_tab          FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_program_id_tab              FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;
l_new_program_update_date_tab     FTE_BULK_DTT_PKG.fte_distu_tmp_date_table;
l_new_request_id_tab              FTE_BULK_DTT_PKG.fte_distu_tmp_num_table;


l_insert_ctr                      PLS_INTEGER;
l_update_ctr                      PLS_INTEGER;
l_current_rows                    PLS_INTEGER;
l_remaining_rows                  PLS_INTEGER;
l_previous_rows                   PLS_INTEGER;
l_bulk_collect_size               PLS_INTEGER := 500;



FTE_DIST_ORIG_DEST_LOAD_ERR       EXCEPTION;
--
--
-- [ABLUNDEL][12/08/2003][BUG# 3301222] End of new variable declaration additions
--

--
-- [ABLUNDEL][12/08/2003][BUG#        ]AXE
-- New cursors/variables to get the correct Time and Distance Uom
--
cursor c_get_time_uom(x_unit_of_measure VARCHAR2,
                      x_language        VARCHAR2) IS
select muomv.uom_code
from   mtl_units_of_measure_vl muomv,
       wsh_global_parameters   wgp
where  wgp.gu_time_class     = muomv.uom_class
and    muomv.unit_of_measure = x_unit_of_measure
and    muomv.language        = x_language;

cursor c_get_distance_uom(y_unit_of_measure VARCHAR2,
                          y_language        VARCHAR2) IS
select muomv.uom_code
from   mtl_units_of_measure_vl muomv,
       wsh_global_parameters wgp
where  wgp.GU_DISTANCE_CLASS  = muomv.uom_class
and    muomv.UNIT_OF_MEASURE  = y_unit_of_measure
and    muomv.language         = y_language;


l_time_uom_code               VARCHAR2(50);
l_time_unit_of_measure        VARCHAR2(50);
l_distance_uom_code           VARCHAR2(50);
l_distance_unit_of_measure    VARCHAR2(50);
l_language                    VARCHAR2(50);

FTE_DIST_INV_TEMP_TIME_UOM    EXCEPTION;
FTE_DIST_NO_TIME_UOM          EXCEPTION;
FTE_DIST_INV_TEMP_DIST_UOM    EXCEPTION;
FTE_DIST_NO_DISTANCE_UOM      EXCEPTION;
--
--
--




l_line_length                     NUMBER;
l_colon_check                     PLS_INTEGER;

FTE_DIST_INV_LINE_LENGTH          EXCEPTION;
FTE_DIST_INV_TIME_FORMAT          EXCEPTION;



BEGIN

   --
   -- SETUP DEBUGGING
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF (g_user_debug = 1) THEN
     l_debug_on := TRUE;
   END IF;


    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------READ_DTT_FILE------------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
      WSH_DEBUG_SV.log(l_module_name,'Procedure = ',l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'p_source_file_directory',p_source_file_directory);
      WSH_DEBUG_SV.log(l_module_name,'p_source_file_name',p_source_file_name);
      WSH_DEBUG_SV.log(l_module_name,'p_load_id',p_load_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;


     FND_FILE.PUT_LINE(FND_FILE.log, 'READ_DTT_FILE');

     --
     -- Set the date variable
     --
     l_cur_date := sysdate;

     --
     -- Set the language
     --
     l_language := userenv('LANG');

     --
     -- Check the input file name is not null
     --
     IF (p_source_file_name is null) THEN
        --
        -- Input file name is null raise an error
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Input file name is null raise FTE_DIST_NULL_FILE_NAME exception');
        END IF;

        RAISE FTE_DIST_NULL_FILE_NAME;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;



     --
     -- Take off the file extension
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Take off the file extension');
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.log, 'Removing File Extension from file');

     l_dtt_file_name := substr(p_source_file_name,1,(instr(p_source_file_name,'.')-1));

     --
     -- DTT Upload file should be 8 chars in length
     --
     IF (length(l_dtt_file_name) <> 8) THEN

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Input file name is not 8 chars in length raise FTE_DIST_INV_FILENAME_LGTH exception');
        END IF;

        RAISE FTE_DIST_INV_FILENAME_LGTH;

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;


     FND_FILE.PUT_LINE(FND_FILE.log, 'Retrieving the download file id');
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Get the download file id open cursor c_get_file_info l_dtt_file_name = ',l_dtt_file_name);
     END IF;
     --
     -- Get the download file id
     --
     OPEN c_get_file_info(l_dtt_file_name);
        FETCH c_get_file_info INTO l_download_file_id,
                                   l_template_id,
                                   l_download_date,
                                   l_upload_date,
                                   l_identifier_type;
     CLOSE c_get_file_info;


     IF (l_download_file_id is null) THEN
        --
        -- No download took place for this file
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Download file id is null, RAISE FTE_DIST_NO_FILE_DOWNLOAD exception');
        END IF;
        --
        RAISE FTE_DIST_NO_FILE_DOWNLOAD;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;

     IF (l_template_id is null) THEN
        --
        -- There is no template associated with the file
        --
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'There is no template associated with the file, RAISE FTE_DIST_NO_FILE_TEMPLATE exception');
        END IF;
        --
        RAISE FTE_DIST_NO_FILE_TEMPLATE;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;


     IF (l_download_date is null) THEN
        --
        -- The download must not have completed correctly
        -- for this file
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'l_download_date is null, The download must not have completed correctly for this file, RAISE FTE_DIST_NO_FILE_DOWNLOAD_DATE exception');
        END IF;
        --
        RAISE FTE_DIST_NO_FILE_DOWNLOAD_DATE;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;

     IF (l_upload_date is not null) THEN
        --
        -- This file has already been uploaded successfull
        -- doing it again makes no sense raise an error
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'l_upload_date is not null, This file has already been uploaded successfully doing it again makes no sense raise an error RAISE FTE_DIST_FILE_UPLOAD_DONE_PREV exception');
        END IF;
        --
        RAISE FTE_DIST_FILE_UPLOAD_DONE_PREV;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;


     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'For return distance column OPEN c_get_ret_col_info,g_ret_dist_col_name = ',g_ret_dist_col_name);
         WSH_DEBUG_SV.log(l_module_name,'l_template_id = ',l_template_id);
     END IF;
     --
     -- For return distance column
     --
     OPEN c_get_ret_col_info(g_ret_dist_col_name,
                             l_template_id);
        FETCH c_get_ret_col_info INTO l_ret_dist_col_id,
                                      l_ret_dist_start_pos,
                                      l_ret_dist_length;
     CLOSE c_get_ret_col_info;


     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'See if it is enabled  OPEN c_get_ret_enabled, l_ret_dist_col_id = ',l_ret_dist_col_id);
     END IF;
     --
     -- See if it is enabled
     --
     OPEN c_get_ret_enabled(l_ret_dist_col_id);
        FETCH c_get_ret_enabled INTO l_ret_dist_enabled_flag,
                                     l_ret_dist_return_format,
                                     l_ret_dist_db_uom;
     CLOSE c_get_ret_enabled;



     IF (l_ret_dist_enabled_flag = 'Y') THEN


        IF ((l_ret_dist_start_pos is null) OR
            (l_ret_dist_length is null)) THEN
           --
           -- The column is enabled but there is no start or length or both
           -- we will not be able to parse the file
           --
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'l_ret_dist_enabled_flag = Y, The column is enabled but there is no start or length or both we will not be able to parse the file RAISE FTE_DIST_RET_DIST_COL_NO_DATA exception');
           END IF;
           --
           RAISE FTE_DIST_RET_DIST_COL_NO_DATA;
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
        END IF;

        -- AXE
        --
        -- [AAB][02/23/2004][BUG#          ]AXE
        --
        -- Distance is enabled get the acutal Distance UoM to store in the database
        --
        IF (l_ret_dist_db_uom = 'MI') THEN
           l_distance_unit_of_measure := g_distance_mile;
        ELSIF (l_ret_dist_db_uom = 'KM') THEN
           l_distance_unit_of_measure := g_distance_kilometer;
        ELSE
           --
           -- Error, must be mile or kilometer
           --
           RAISE FTE_DIST_INV_TEMP_DIST_UOM;
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
        END IF;

        --
        -- Get the correct code from the mtl table
        --
        OPEN c_get_distance_uom(l_distance_unit_of_measure,
                                l_language);
           FETCH c_get_distance_uom INTO l_distance_uom_code;
        CLOSE c_get_distance_uom;

        IF (l_distance_uom_code is null) THEN
           --
           -- There is no Distance UoM code from mtl table
           --
           RAISE FTE_DIST_NO_DISTANCE_UOM;
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
        END IF;
        --
        --
        --
     END IF;


     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Get the return time column g_ret_time_col_name = ',g_ret_time_col_name);
        WSH_DEBUG_SV.log(l_module_name,'l_template_id = ',l_template_id);
     END IF;
     --
     -- Get the return time column
     --
     OPEN c_get_ret_col_info(g_ret_time_col_name,
                             l_template_id);
        FETCH c_get_ret_col_info INTO l_ret_time_col_id,
                                      l_ret_time_start_pos,
                                      l_ret_time_length;
     CLOSE c_get_ret_col_info;


     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,' See if it is enabled OPEN c_get_ret_enabled, l_ret_time_col_id = ',l_ret_time_col_id);
     END IF;
     --
     -- See if it is enabled
     --
     OPEN c_get_ret_enabled(l_ret_time_col_id);
        FETCH c_get_ret_enabled INTO l_ret_time_enabled_flag,
                                     l_ret_time_return_format,
                                     l_ret_time_db_uom;
     CLOSE c_get_ret_enabled;


     IF (l_ret_time_enabled_flag = 'Y') THEN
        IF ((l_ret_time_start_pos is null) OR
            (l_ret_time_length is null)) THEN
           --
           -- The column is enabled but there is no start or length or both
           -- we will not be able to parse the file
           --
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'l_ret_time_enabled_flag = Y, The column is enabled but there is no start or length or both we will not be able to parse the file RAISE FTE_DIST_RET_TIME_COL_NO_DATA exception');
           END IF;
           --
           RAISE FTE_DIST_RET_TIME_COL_NO_DATA;
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;
        END IF;

        --
        -- [AAB][02/23/2004][BUG#          ]AXE
        --
        -- Time is enabled get the acutal Time UoM to store in the database
        --
        IF (l_ret_time_db_uom = 'HR') THEN
           l_time_unit_of_measure := g_time_hour;
        ELSIF (l_ret_time_db_uom = 'MIN') THEN
           l_time_unit_of_measure := g_time_minute;
        ELSE
           --
           -- Error, must be minute or hour
           --
           RAISE FTE_DIST_INV_TEMP_TIME_UOM;
           RETURN;
        END IF;

        --
        -- Get the correct code from the mtl table
        --
        OPEN c_get_time_uom(l_time_unit_of_measure,
                            l_language);
           FETCH c_get_time_uom INTO l_time_uom_code;
        CLOSE c_get_time_uom;

        IF (l_time_uom_code is null) THEN
           --
           -- There is no Time UoM code from mtl table
           --
           RAISE FTE_DIST_NO_TIME_UOM;
           RETURN;
        END IF;

        --


     END IF;


     IF ((l_ret_dist_enabled_flag <> 'Y') AND
         (l_ret_time_enabled_flag <> 'Y')) THEN
        --
        -- Neither column is enabled? Therefore we cannot
        -- parse the data
        --
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'l_ret_time_enabled_flag and l_ret_dist_enabled_flag <> Y, Neither column is enabled Therefore we cannot parse the data, RAISE FTE_DIST_NO_RET_COL_ENABLED exception');
        END IF;
        --
        RAISE FTE_DIST_NO_RET_COL_ENABLED;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;


     --
     -- So we are here at least one column is enabled
     --
     -- For the return time we may have to convert from the Return Format" to
     -- the DB uom
     -- The DB UoM is either HR - Hours or MIN -  Minutes
     -- The return format is MIN Minutes, or HR Hours or HR:MIN Hours colon Minutes
     --
     --      UoM HR            MIN
     -- Format
     -- MIN       /60           --
     -- HR       --            *60
     -- HR:MIN    parse MIN      parse HR
     --          /60           *60
     --          add to HR     add to MIN
     --



     IF ((l_ret_time_return_format = 'MIN') AND
         (l_ret_time_db_uom = 'HR')) THEN
        l_conv_flag := 'MINHR';
     ELSIF ((l_ret_time_return_format = 'HR') AND
            (l_ret_time_db_uom = 'MIN')) THEN
        l_conv_flag := 'HRMIN';
     ELSIF ((l_ret_time_return_format = 'HR:MIN') AND
            (l_ret_time_db_uom = 'MIN')) THEN
        l_conv_flag := 'HMMIN';
     ELSIF ((l_ret_time_return_format = 'HR:MIN') AND
            (l_ret_time_db_uom = 'HR')) THEN
        l_conv_flag := 'HMHR';
     ELSE
        l_conv_flag := null;
     END IF;




     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_conv_flag',l_conv_flag);
     END IF;


     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Get the download lines OPEN c_get_download_lines, l_download_file_id = ',l_download_file_id);
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.log, 'Retrieving the download lines '||l_download_file_id);
     --
     -- Get the download lines
     --
     OPEN c_get_download_lines(l_download_file_id);
        FETCH c_get_download_lines BULK COLLECT INTO
           l_origin_id_tab,
           l_destination_id_tab;
     CLOSE c_get_download_lines;


     IF ((l_origin_id_tab.COUNT = 0) OR
         (l_destination_id_tab.COUNT = 0)) THEN
        --
        -- There are no download lines in the table?
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'There are no download lines in the table RAISE FTE_DIST_NO_DOWNLOAD_LINES exception');
        END IF;
        --
        RAISE FTE_DIST_NO_DOWNLOAD_LINES;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
     END IF;



     --
     -- Get the count of lines from the table
     -- we can only insert records into the table is the number of lines
     -- in the file matches with the number of lines in the table
     --

     l_number_of_table_lines := l_origin_id_tab.COUNT;

     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_number_of_table_lines = ',l_number_of_table_lines);
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.log, 'Number of lines in table = '||to_char(l_number_of_table_lines));



     --
     -- Lets read the file
     --
     FND_FILE.PUT_LINE(FND_FILE.log, 'READING FILE ' || p_source_file_directory || '/' || p_source_file_name);


     --
     -- The file is read in a separate plsql block as when it is finished
     -- we get a no data found exception - which in this case is good
     --
     BEGIN

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Open the file Set the full file name for utl_file');
        END IF;
        --
        -- Set the full file name for utl_file
        --
        l_dtt_file := utl_file.fopen(p_source_file_directory, p_source_file_name, 'R');


        --
        -- Reset the line and loader counters
        --
        l_line_ctr := 0;
        l_load_ctr := 0;


        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Start a loop to read the file contents one line at a time');
        END IF;
        --
        -- Start a loop to read the file
        --
        LOOP


           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Get the next line out of the file');
           END IF;
           --
           -- Get the next line out of the file
           --
           utl_file.get_line(l_dtt_file, l_line);


           --
           -- [AAB][01/22/04][BUG# 3381771]
           -- Check that the line contains something
           --
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'check the file length');
           END IF;
           l_line_length := 0;
           l_line_length :=  NVL(LENGTH(l_line),0);

           IF (l_line_length <= 0) THEN
              RAISE FTE_DIST_INV_LINE_LENGTH;
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.pop(l_module_name);
              END IF;
              --
              RETURN;
           ELSE
              --
              -- Line length is greater than 0, lets get rid of all spaces and see if
              -- there is any length left
              --
              l_line_length := NVL(LENGTH(RTRIM(LTRIM(REPLACE(substr(l_line,1, l_line_length),FND_GLOBAL.local_chr(9),' '),' '),' ')),0);
              IF (l_line_length <= 0) THEN
                 RAISE FTE_DIST_INV_LINE_LENGTH;
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.pop(l_module_name);
                 END IF;
                 --
                 RETURN;
              END IF;
           END IF;

           --

           --
           -- Increment the line counter
           --
           l_line_ctr := l_line_ctr + 1;

           FND_FILE.PUT_LINE(FND_FILE.log, 'File Line #'||to_char(l_line_ctr)||': '||l_line);

           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'File Line #'||to_char(l_line_ctr)||': '||l_line);
           END IF;

           --
           -- Get the distance if applicable
           --
           IF (l_ret_dist_enabled_flag = 'Y') THEN
              --
              -- get rid of trailing and leading spaces
              --
              --
              -- [AAB][12/16/03][BUG# 3325486]
              -- Added Replace to the extraction to replace all occurances of TAB in the string with a space,
              -- The spaces are then trimmed off the left and right end
              --
              l_ret_dist_val := RTRIM(LTRIM(REPLACE(substr(l_line,l_ret_dist_start_pos, l_ret_dist_length),FND_GLOBAL.local_chr(9),' '),' '),' ');

              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Converting distance value to a number');
              END IF;

              FND_FILE.PUT_LINE(FND_FILE.log, 'Converting distance value to a number');
              --
              -- Convert the value to a number
              --
              IF (l_ret_dist_val is not null) THEN
                 l_ret_dist := to_number(l_ret_dist_val);
              ELSE
                 l_ret_dist := 0;
              END IF;
           ELSE
              l_ret_dist := null;
           END IF;


           --
           -- Get the return time if applicable
           --
           IF (l_ret_time_enabled_flag = 'Y') THEN
              --
              -- get rid of trailing and leading spaces
              --

              --
              -- [AAB][12/16/03][BUG# 3325486]
              -- Added Replace to the extraction to replace all occurances of TAB in the string with a space,
              -- The spaces are then trimmed off the left and right end
              --
              l_ret_time_val := RTRIM(LTRIM(REPLACE(substr(l_line,l_ret_time_start_pos, l_ret_time_length),FND_GLOBAL.local_chr(9),' '),' '),' ');


              l_colon_check := 0;

              IF (l_ret_time_val is not null) THEN

                 IF (l_conv_flag is not null) THEN
                    IF (l_conv_flag = 'MINHR') THEN
                       l_ret_time := (to_number(l_ret_time_val) / 60);
                    ELSIF (l_conv_flag = 'HRMIN') THEN
                       l_ret_time := (to_number(l_ret_time_val) * 60);
                    ELSIF (l_conv_flag = 'HMMIN') THEN

                       -- AXE
                       -- [AAB][01/23/2004][BUG#      ]
                       -- Check that the return value has a colon in it otherwise we could get
                       -- a weird value for the time
                       --
                       l_colon_check := instr(l_ret_time_val,':');

                       IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'check HMMIN return time for a colon, l_colon_check = ',l_colon_check);
                       END IF;

                       IF (l_colon_check <= 0) THEN
                          --
                          -- Error no colon in the return time string
                          --
                          RAISE FTE_DIST_INV_TIME_FORMAT;
                          --
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.pop(l_module_name);
                          END IF;
                          --
                          RETURN;
                       END IF;


                       --
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'converting HR:MIN to Minutes');
                       END IF;

                       l_ret_mins := to_number(substr(l_ret_time_val, (instr(l_ret_time_val,':')+1),LENGTH(l_ret_time_val)));
                       l_ret_hrs  := to_number(substr(l_ret_time_val,1,(instr(l_ret_time_val,':')-1)));
                       l_ret_time := ((l_ret_hrs * 60) + l_ret_mins);

                       IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'END OF converting HR:MIN to Hours');
                       END IF;
                    ELSIF (l_conv_flag = 'HMHR') THEN

                       -- AXE
                       -- [AAB][01/23/2004][BUG#      ]
                       -- Check that the return value has a colon in it otherwise we could get
                       -- a weird value for the time
                       --
                       l_colon_check := instr(l_ret_time_val,':');

                       IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'check HMHR return time for a colon, l_colon_check = ',l_colon_check);
                       END IF;

                       IF (l_colon_check <= 0) THEN
                          --
                          -- Error no colon in the return time string
                          --
                          RAISE FTE_DIST_INV_TIME_FORMAT;
                          --
                          IF l_debug_on THEN
                             WSH_DEBUG_SV.pop(l_module_name);
                          END IF;
                          --
                          RETURN;
                       END IF;

                       IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'converting HR:MIN to Hours');
                       END IF;

                       l_ret_mins := to_number(substr(l_ret_time_val, (instr(l_ret_time_val,':')+1),LENGTH(l_ret_time_val)));
                       l_ret_hrs  := to_number(substr(l_ret_time_val,1,(instr(l_ret_time_val,':')-1)));
                       l_ret_time := ((l_ret_mins /60) + l_ret_hrs);

                       IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name,'END OF converting HR:MIN to Hours');
                       END IF;
                    END IF;
                 ELSE
                    l_ret_time := to_number(l_ret_time_val);
                 END IF;
              ELSE
                 l_ret_time := 0;
              END IF;
           ELSE
              l_ret_time := null;
           END IF;


           --
           -- Now we have to get the orign and destination regions from
           -- the download line table
           --
           -- Increment the load counter
           --
           l_load_ctr := l_load_ctr + 1;

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_load_ctr',l_load_ctr);
           END IF;

           l_location_origin_id(l_load_ctr)              := l_origin_id_tab(l_line_ctr);
           l_location_destination_id(l_load_ctr)         := l_destination_id_tab(l_line_ctr);
           l_location_identifier_type(l_load_ctr)        := l_identifier_type;
           l_location_distance(l_load_ctr)               := l_ret_dist;
           l_location_distance_uom(l_load_ctr)           := l_distance_uom_code;    -- AXE l_ret_dist_db_uom;
           l_location_transit_time(l_load_ctr)           := l_ret_time;
           l_location_transit_time_uom(l_load_ctr)       := l_time_uom_code;        -- AXE l_ret_time_db_uom;
           l_location_creation_date(l_load_ctr)          := l_cur_date;
           l_location_created_by(l_load_ctr)             := g_user_id;
           l_location_last_update_date(l_load_ctr)       := l_cur_date;
           l_location_last_updated_by(l_load_ctr)        := g_user_id;
           l_location_last_update_login(l_load_ctr)      := null;
           l_location_program_app_id(l_load_ctr)         := null;
           l_location_program_id(l_load_ctr)             := null;
           l_location_program_update_date(l_load_ctr)    := null;
           l_location_request_id(l_load_ctr)             := p_load_id;

           IF (l_load_ctr = 250) THEN
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'we are going to insert 250 at a time into the global temp table insert into fte_distance_loader_tmp');
              END IF;
              --
              FND_FILE.PUT_LINE(FND_FILE.log, 'Inserting 250 records into temp table');
              --
              -- we are going to insert 250 at a time into the global
              -- temp table
              --
              FORALL i in l_location_origin_id.FIRST..l_location_origin_id.LAST
                 insert into fte_distance_loader_tmp(ORIGIN_ID,
                                                     DESTINATION_ID,
                                                     IDENTIFIER_TYPE,
                                                     DISTANCE,
                                                     DISTANCE_UOM,
                                                     TRANSIT_TIME,
                                                     TRANSIT_TIME_UOM,
                                                     CREATION_DATE,
                                                     CREATED_BY,
                                                     LAST_UPDATE_DATE,
                                                     LAST_UPDATED_BY,
                                                     LAST_UPDATE_LOGIN,
                                                     PROGRAM_APPLICATION_ID,
                                                     PROGRAM_ID,
                                                     PROGRAM_UPDATE_DATE,
                                                     REQUEST_ID)
                                              values(l_location_origin_id(i),
                                                     l_location_destination_id(i),
                                                     l_location_identifier_type(i),
                                                     l_location_distance(i),
                                                     l_location_distance_uom(i),
                                                     l_location_transit_time(i),
                                                     l_location_transit_time_uom(i),
                                                     l_location_creation_date(i),
                                                     l_location_created_by(i),
                                                     l_location_last_update_date(i),
                                                     l_location_last_updated_by(i),
                                                     l_location_last_update_login(i),
                                                     l_location_program_app_id(i),
                                                     l_location_program_id(i),
                                                     l_location_program_update_date(i),
                                                     l_location_request_id(i));


              --
              -- Clear the tables for the next pass
              --
              IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Clearing the temp tables for the next pass');
              END IF;

              l_location_origin_id.DELETE;
              l_location_destination_id.DELETE;
              l_location_identifier_type.DELETE;
              l_location_distance.DELETE;
              l_location_distance_uom.DELETE;
              l_location_transit_time.DELETE;
              l_location_transit_time_uom.DELETE;
              l_location_creation_date.DELETE;
              l_location_created_by.DELETE;
              l_location_last_update_date.DELETE;
              l_location_last_updated_by.DELETE;
              l_location_last_update_login.DELETE;
              l_location_program_app_id.DELETE;
              l_location_program_id.DELETE;
              l_location_program_update_date.DELETE;
              l_location_request_id.DELETE;

              l_load_ctr := 0;
           END IF;

        --
        -- End of reading the line
        --
        END LOOP;


        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Close the file');
        END IF;
        --
        -- End of reading the file - close it out
        --
        utl_file.fclose(l_dtt_file);


     EXCEPTION
        WHEN FTE_DIST_INV_TIME_FORMAT THEN
           --
           -- Close the file
           --
           IF (utl_file.is_open(l_dtt_file)) THEN
              utl_file.fclose(l_dtt_file);
           END IF;
           FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INV_TIME_FORMAT');
           x_return_status  := 2;
           x_return_message := FND_MESSAGE.GET;
           FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - INV TIME FORMAT. '||x_return_message);

           --
           -- Close the cursors
           --
           IF (c_check_download_lines%ISOPEN) THEN
              CLOSE c_check_download_lines;
           END IF;

           IF (c_get_file_info%ISOPEN) THEN
              CLOSE c_get_file_info;
           END IF;

           IF (c_get_download_lines%ISOPEN) THEN
              CLOSE c_get_download_lines;
           END IF;

           IF (c_get_ret_col_info%ISOPEN) THEN
              CLOSE c_get_ret_col_info;
           END IF;

           IF (c_get_ret_enabled%ISOPEN) THEN
              CLOSE c_get_ret_enabled;
           END IF;

           IF (c_get_merge_data%ISOPEN) THEN
              CLOSE c_get_merge_data;
           END IF;

           IF (c_get_time_uom%ISOPEN) THEN
              CLOSE c_get_time_uom;
           END IF;

           IF (c_get_distance_uom%ISOPEN) THEN
              CLOSE c_get_distance_uom;
           END IF;

           --
           -- Debug Statements
           --
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_INV_TIME_FORMAT FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_INV_TIME_FORMAT');
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;


        WHEN FTE_DIST_INV_LINE_LENGTH THEN
           --
           -- Close the file
           --
           IF (utl_file.is_open(l_dtt_file)) THEN
              utl_file.fclose(l_dtt_file);
           END IF;
           FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INV_LINE_LENGTH');
           x_return_status  := 2;
           x_return_message := FND_MESSAGE.GET;
           FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - INV LINE LENGTH. '||x_return_message);

           --
           -- Close the cursors
           --
           IF (c_check_download_lines%ISOPEN) THEN
              CLOSE c_check_download_lines;
           END IF;

           IF (c_get_file_info%ISOPEN) THEN
              CLOSE c_get_file_info;
           END IF;

           IF (c_get_download_lines%ISOPEN) THEN
              CLOSE c_get_download_lines;
           END IF;

           IF (c_get_ret_col_info%ISOPEN) THEN
              CLOSE c_get_ret_col_info;
           END IF;

           IF (c_get_ret_enabled%ISOPEN) THEN
              CLOSE c_get_ret_enabled;
           END IF;

           IF (c_get_merge_data%ISOPEN) THEN
              CLOSE c_get_merge_data;
           END IF;

           IF (c_get_time_uom%ISOPEN) THEN
              CLOSE c_get_time_uom;
           END IF;

           IF (c_get_distance_uom%ISOPEN) THEN
              CLOSE c_get_distance_uom;
           END IF;

           --
           -- Debug Statements
           --
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_INV_LINE_LENGTH FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_INV_LINE_LENGTH');
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;


        WHEN NO_DATA_FOUND THEN
           --
           -- Occurs when the entire file has been read, this is OK
           -- Close the file
           --
           IF (utl_file.is_open(l_dtt_file)) THEN
              utl_file.fclose(l_dtt_file);
           END IF;
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Finished reading file');
           END IF;

           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Finished Reading File.');
           x_return_status := -1;


        WHEN UTL_FILE.INVALID_PATH THEN
           --
           -- Close the file
           --
           IF (utl_file.is_open(l_dtt_file)) THEN
              utl_file.fclose(l_dtt_file);
           END IF;
           x_return_message := 'FILE ' || p_source_file_directory || '/' || p_source_file_name || ' NOT ACCESSIBLE';
           x_return_message := x_return_message||' Also please make sure that the directory is accessible to UTL_FILE.';
           fnd_file.put_line(FND_FILE.log, x_return_message);
           x_return_status := 2;
           --
           --
           -- Close the cursors
           --
           IF (c_check_download_lines%ISOPEN) THEN
              CLOSE c_check_download_lines;
           END IF;

           IF (c_get_file_info%ISOPEN) THEN
              CLOSE c_get_file_info;
           END IF;

           IF (c_get_download_lines%ISOPEN) THEN
              CLOSE c_get_download_lines;
           END IF;

           IF (c_get_ret_col_info%ISOPEN) THEN
              CLOSE c_get_ret_col_info;
           END IF;

           IF (c_get_ret_enabled%ISOPEN) THEN
              CLOSE c_get_ret_enabled;
           END IF;

           IF (c_get_merge_data%ISOPEN) THEN
              CLOSE c_get_merge_data;
           END IF;

           IF (c_get_time_uom%ISOPEN) THEN
              CLOSE c_get_time_uom;
           END IF;

           IF (c_get_distance_uom%ISOPEN) THEN
              CLOSE c_get_distance_uom;
           END IF;

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'ERROR UTL_FILE.INVALID_PATH FTE_BULK_DTT_PKG.READ_DTT_FILE  ' ||x_return_message);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UTL_FILE.INVALID_PATH');
              WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           --
           RETURN;


        WHEN OTHERS THEN
           --
           -- Close the file
           --
           IF (utl_file.is_open(l_dtt_file)) THEN
              utl_file.fclose(l_dtt_file);
           END IF;

           FND_FILE.PUT_LINE(FND_FILE.log, 'UNEXPECTED ERROR IN PROCEDURE READ_DTT_FILE.'||sqlerrm);
           FND_FILE.PUT_LINE(FND_FILE.log, 'OFFENDING_LINE: ' || l_line);
           FND_FILE.PUT_LINE(FND_FILE.Log, sqlerrm);
           x_return_status := 2;
           x_return_message := ('UNEXPECTED ERROR IN PROCEDURE FTE_BULK_DTT_PKG.READ_DTT_FILE: '||sqlerrm);

           --
           -- Close the cursors
           --
           IF (c_check_download_lines%ISOPEN) THEN
              CLOSE c_check_download_lines;
           END IF;

           IF (c_get_file_info%ISOPEN) THEN
              CLOSE c_get_file_info;
           END IF;

           IF (c_get_download_lines%ISOPEN) THEN
              CLOSE c_get_download_lines;
           END IF;

           IF (c_get_ret_col_info%ISOPEN) THEN
              CLOSE c_get_ret_col_info;
           END IF;

           IF (c_get_ret_enabled%ISOPEN) THEN
              CLOSE c_get_ret_enabled;
           END IF;

           IF (c_get_merge_data%ISOPEN) THEN
              CLOSE c_get_merge_data;
           END IF;

           IF (c_get_time_uom%ISOPEN) THEN
              CLOSE c_get_time_uom;
           END IF;

           IF (c_get_distance_uom%ISOPEN) THEN
              CLOSE c_get_distance_uom;
           END IF;

           --
           -- Debug Statements
           --
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'THE UNEXPECTED ERROR FROM FTE_BULK_DTT_PKG.READ_DTT_FILE IS ' ||sqlerrm);
              WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||sqlerrm,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
              WSH_DEBUG_SV.logmsg(l_module_name,'OFFENDING_LINE: ' ||l_line);
              WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;

           RAISE;


     END;



     --
     -- insert the last few lines that did not sum upto 250
     -- into the Global temp table
     --
     IF (l_location_origin_id.COUNT > 0) THEN

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'insert the last few lines that did not sum upto 250 into the Global temp table');
        END IF;

        FND_FILE.PUT_LINE(FND_FILE.log, 'Inserting remainder of records into temp table');

        FORALL i in l_location_origin_id.FIRST..l_location_origin_id.LAST
           insert into fte_distance_loader_tmp(ORIGIN_ID,
                                               DESTINATION_ID,
                                               IDENTIFIER_TYPE,
                                               DISTANCE,
                                               DISTANCE_UOM,
                                               TRANSIT_TIME,
                                               TRANSIT_TIME_UOM,
                                               CREATION_DATE,
                                               CREATED_BY,
                                               LAST_UPDATE_DATE,
                                               LAST_UPDATED_BY,
                                               LAST_UPDATE_LOGIN,
                                               PROGRAM_APPLICATION_ID,
                                               PROGRAM_ID,
                                               PROGRAM_UPDATE_DATE,
                                               REQUEST_ID)
                                        values(l_location_origin_id(i),
                                               l_location_destination_id(i),
                                               l_location_identifier_type(i),
                                               l_location_distance(i),
                                               l_location_distance_uom(i),
                                               l_location_transit_time(i),
                                               l_location_transit_time_uom(i),
                                               l_location_creation_date(i),
                                               l_location_created_by(i),
                                               l_location_last_update_date(i),
                                               l_location_last_updated_by(i),
                                               l_location_last_update_login(i),
                                               l_location_program_app_id(i),
                                               l_location_program_id(i),
                                               l_location_program_update_date(i),
                                               l_location_request_id(i));

        --
        -- Clean the local tables
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Clean the temp tables');
        END IF;
        --
        l_location_origin_id.DELETE;
        l_location_destination_id.DELETE;
        l_location_identifier_type.DELETE;
        l_location_distance.DELETE;
        l_location_distance_uom.DELETE;
        l_location_transit_time.DELETE;
        l_location_transit_time_uom.DELETE;
        l_location_creation_date.DELETE;
        l_location_created_by.DELETE;
        l_location_last_update_date.DELETE;
        l_location_last_updated_by.DELETE;
        l_location_last_update_login.DELETE;
        l_location_program_app_id.DELETE;
        l_location_program_id.DELETE;
        l_location_program_update_date.DELETE;
        l_location_request_id.DELETE;

        l_load_ctr := 0;
     END IF;

     --
     -- Only insert all records if the number of lines in the file mathes the number of lines in the table
     --
     IF (l_number_of_table_lines = l_line_ctr) THEN

        FND_FILE.PUT_LINE(FND_FILE.log, 'Number of lines in the table matched the number of lines in the file, inserting and/or updating into the location mileages table');

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Number of lines in the table matched the number of lines in the file, inserting and/or updating into the location mileages table');
        END IF;
        --


-- ----------------------------------------------------------------------------
-- [ABLUNDEL][12/08/2003][BUG# 3301222]
--
-- The following merge SQL statement was removed as it is not compatible
-- with 8i installations only 9i ort higher. This was failing when applied
-- to an 8i instance. It was replaced by the code following the merge statement
-- to allow for 8i compatibility
--
--
--
--      --
--      -- All the records are in the temp table now we have to insert/update them into the
--      -- fte_location_mileages table using the new funky MErGe stuff.....
--      --
--      MERGE INTO fte_location_mileages flm
--      USING (SELECT origin_id,
--                    destination_id,
--                    identifier_type,
--                    distance,
--                    distance_uom,
--                    transit_time,
--                    transit_time_uom,
--                    creation_date,
--                    created_by,
--                    last_update_date,
--                    last_updated_by,
--                    last_update_login,
--                    program_application_id,
--                    program_id,
--                    program_update_date,
--                    request_id  FROM FTE_DISTANCE_LOADER_TMP) fdlt
--      ON (flm.origin_id      = fdlt.origin_id AND
--          flm.destination_id = fdlt.destination_id)
--      WHEN MATCHED THEN UPDATE SET flm.identifier_type        = fdlt.identifier_type,
--                                   flm.distance               = fdlt.distance,
--                                   flm.distance_uom           = fdlt.distance_uom,
--                                   flm.transit_time           = fdlt.transit_time,
--                                   flm.transit_time_uom       = fdlt.transit_time_uom,
--                                   flm.last_update_date       = fdlt.last_update_date,
--                                   flm.last_updated_by        = fdlt.last_updated_by,
--                                   flm.last_update_login      = fdlt.last_update_login,
--                                   flm.program_application_id = fdlt.program_application_id,
--                                   flm.program_id             = fdlt.program_id,
--                                   flm.program_update_date    = fdlt.program_update_date,
--                                   flm.request_id             = fdlt.request_id
--      WHEN NOT MATCHED THEN INSERT (flm.origin_id,
--                                    flm.destination_id,
--                                    flm.identifier_type,
--                                    flm.distance,
--                                    flm.distance_uom,
--                                    flm.transit_time,
--                                    flm.transit_time_uom,
--                                    flm.creation_date,
--                                    flm.created_by,
--                                    flm.last_update_date,
--                                    flm.last_updated_by,
--                                    flm.last_update_login,
--                                    flm.program_application_id,
--                                    flm.program_id,
--                                    flm.program_update_date,
--                                    flm.request_id)
--                            VALUES (fdlt.origin_id,
--                                    fdlt.destination_id,
--                                    fdlt.identifier_type,
--                                    fdlt.distance,
--                                    fdlt.distance_uom,
--                                    fdlt.transit_time,
--                                    fdlt.transit_time_uom,
--                                    fdlt.creation_date,
--                                    fdlt.created_by,
--                                    fdlt.last_update_date,
--                                    fdlt.last_updated_by,
--                                    fdlt.last_update_login,
--                                    fdlt.program_application_id,
--                                    fdlt.program_id,
--                                    fdlt.program_update_date,
--                                    fdlt.request_id);
--
--
--
--
-- [ABLUNDEL][12/08/2003][BUG# 3301222]
--
-- New code to replace the MERGE statement above for 8i compatibility
--
--
        FND_FILE.PUT_LINE(FND_FILE.log,'Clean up the query collections');
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Clean up the query collections');
        END IF;

        --
        -- Clean up the query collections
        --
        l_old_origin_id_tab.DELETE;
        l_old_destination_id_tab.DELETE;
        l_new_origin_id_tab.DELETE;
        l_new_destination_id_tab.DELETE;
        l_new_identifier_type_tab.DELETE;
        l_new_distance_tab.DELETE;
        l_new_distance_uom_tab.DELETE;
        l_new_transit_time_tab.DELETE;
        l_new_transit_time_uom_tab.DELETE;
        l_new_creation_date_tab.DELETE;
        l_new_created_by_tab.DELETE;
        l_new_last_update_date_tab.DELETE;
        l_new_last_updated_by_tab.DELETE;
        l_new_last_update_login_tab.DELETE;
        l_new_program_app_id_tab.DELETE;
        l_new_program_id_tab.DELETE;
        l_new_program_update_date_tab.DELETE;
        l_new_request_id_tab.DELETE;

        --
        -- Set the previous rows counter to zero
        --
        l_previous_rows := 0;

        FND_FILE.PUT_LINE(FND_FILE.log,'Open the cursor, c_get_merge_data, to get the records to update and/or insert');
                 --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Open the cursor, c_get_merge_data, to get the records to update and/or insert');
        END IF;

        --
        -- Open the cursor to get the records to update and/or insert
        --
        OPEN c_get_merge_data;
           LOOP
              FETCH c_get_merge_data BULK COLLECT INTO
                 l_old_origin_id_tab,
                 l_old_destination_id_tab,
                 l_new_origin_id_tab,
                 l_new_destination_id_tab,
                 l_new_identifier_type_tab,
                 l_new_distance_tab,
                 l_new_distance_uom_tab,
                 l_new_transit_time_tab,
                 l_new_transit_time_uom_tab,
                 l_new_creation_date_tab,
                 l_new_created_by_tab,
                 l_new_last_update_date_tab,
                 l_new_last_updated_by_tab,
                 l_new_last_update_login_tab,
                 l_new_program_app_id_tab,
                 l_new_program_id_tab,
                 l_new_program_update_date_tab,
                 l_new_request_id_tab
              LIMIT l_bulk_collect_size;


              --
              -- Set the current rows and remaining rows counters to be
              -- able to see if there are any records left in the cursor
              --
              l_current_rows   := c_get_merge_data%rowcount ;
              l_remaining_rows := l_current_rows - l_previous_rows;



              IF (l_remaining_rows <= 0) then

                 FND_FILE.PUT_LINE(FND_FILE.log,'There are no rows left from the cursor - exit the loop');
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'There are no rows left from the cursor - exit the loop');
                 END IF;
                 --
                 -- There are no rows left from the cursor - exit the loop
                 --
                 EXIT;
              END IF;

              --
              -- Set the previous rows counter to equal the current rows counter
              --
              l_previous_rows := l_current_rows ;



              IF (l_new_origin_id_tab.COUNT > 0) THEN
                 --
                 -- We have records to insert or update
                 -- Clean out the Update anbd insert plsql collections
                 --

                 FND_FILE.PUT_LINE(FND_FILE.log,'cleaning the temp update tables');
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'cleaning the temp update tables');
                 END IF;

                 l_u_origin_id_tab.DELETE;
                 l_u_destination_id_tab.DELETE;
                 l_u_identifier_type_tab.DELETE;
                 l_u_distance_tab.DELETE;
                 l_u_distance_uom_tab.DELETE;
                 l_u_transit_time_tab.DELETE;
                 l_u_transit_time_uom_tab.DELETE;
                 l_u_last_update_date_tab.DELETE;
                 l_u_last_updated_by_tab.DELETE;
                 l_u_last_update_login_tab.DELETE;
                 l_u_program_app_id_tab.DELETE;
                 l_u_program_id_tab.DELETE;
                 l_u_program_update_date_tab.DELETE;
                 l_u_request_id_tab.DELETE;


                 FND_FILE.PUT_LINE(FND_FILE.log,'cleaning the temp insert tables');
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'cleaning the temp insert tables');
                 END IF;

                 l_i_origin_id_tab.DELETE;
                 l_i_destination_id_tab.DELETE;
                 l_i_identifier_type_tab.DELETE;
                 l_i_distance_tab.DELETE;
                 l_i_distance_uom_tab.DELETE;
                 l_i_transit_time_tab.DELETE;
                 l_i_transit_time_uom_tab.DELETE;
                 l_i_creation_date_tab.DELETE;
                 l_i_created_by_tab.DELETE;
                 l_i_last_update_date_tab.DELETE;
                 l_i_last_updated_by_tab.DELETE;
                 l_i_last_update_login_tab.DELETE;
                 l_i_program_app_id_tab.DELETE;
                 l_i_program_id_tab.DELETE;
                 l_i_program_update_date_tab.DELETE;
                 l_i_request_id_tab.DELETE;


                 --
                 -- Reset the insert and update counters
                 --
                 l_insert_ctr := 0;
                 l_update_ctr := 0;



                 FOR kk in l_new_origin_id_tab.FIRST..l_new_origin_id_tab.LAST LOOP  -- LOOP_02
                   --
                   -- Loop through the query return and see which records need
                   -- to be updated or inserted
                   --
                   FND_FILE.PUT_LINE(FND_FILE.log, 'checking for insert and update records');
                   --
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'checking for insert and update records');
                   END IF;

                    IF ((l_old_origin_id_tab(kk) is null) AND
                        (l_old_destination_id_tab(kk) is null)) THEN

                       FND_FILE.PUT_LINE(FND_FILE.log, 'getting insert records');
                       --
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'getting insert records');
                       END IF;
                       --
                       -- Must be for an insert
                       --

                       -- Increment the insert counter
                       l_insert_ctr := l_insert_ctr + 1;

                       --
                       -- Populate the insert collections with the queried data
                       --
                       l_i_origin_id_tab(l_insert_ctr)           := l_new_origin_id_tab(kk);
                       l_i_destination_id_tab(l_insert_ctr)      := l_new_destination_id_tab(kk);
                       l_i_identifier_type_tab(l_insert_ctr)     := l_new_identifier_type_tab(kk);
                       l_i_distance_tab(l_insert_ctr)            := l_new_distance_tab(kk);
                       l_i_distance_uom_tab(l_insert_ctr)        := l_new_distance_uom_tab(kk);
                       l_i_transit_time_tab(l_insert_ctr)        := l_new_transit_time_tab(kk);
                       l_i_transit_time_uom_tab(l_insert_ctr)    := l_new_transit_time_uom_tab(kk);
                       l_i_creation_date_tab(l_insert_ctr)       := l_new_creation_date_tab(kk);
                       l_i_created_by_tab(l_insert_ctr)          := l_new_created_by_tab(kk);
                       l_i_last_update_date_tab(l_insert_ctr)    := l_new_last_update_date_tab(kk);
                       l_i_last_updated_by_tab(l_insert_ctr)     := l_new_last_updated_by_tab(kk);
                       l_i_last_update_login_tab(l_insert_ctr)   := l_new_last_update_login_tab(kk);
                       l_i_program_app_id_tab(l_insert_ctr)      := l_new_program_app_id_tab(kk);
                       l_i_program_id_tab(l_insert_ctr)          := l_new_program_id_tab(kk);
                       l_i_program_update_date_tab(l_insert_ctr) := l_new_program_update_date_tab(kk);
                       l_i_request_id_tab(l_insert_ctr)          := l_new_request_id_tab(kk);

                    ELSIF ((l_old_origin_id_tab(kk) is not null) AND
                       (l_old_destination_id_tab(kk) is not null)) THEN

                       FND_FILE.PUT_LINE(FND_FILE.log, 'getting update records');
                       --
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.logmsg(l_module_name,'getting update records');
                       END IF;

                       --
                       -- must be an update
                       --

                       -- increment the update couter
                       l_update_ctr := l_update_ctr + 1;

                       --
                       -- Populate the update collections with the queried data
                       --
                       l_u_origin_id_tab(l_update_ctr)           := l_old_origin_id_tab(kk);
                       l_u_destination_id_tab(l_update_ctr)      := l_old_destination_id_tab(kk);
                       l_u_identifier_type_tab(l_update_ctr)     := l_new_identifier_type_tab(kk);
                       l_u_distance_tab(l_update_ctr)            := l_new_distance_tab(kk);
                       l_u_distance_uom_tab(l_update_ctr)        := l_new_distance_uom_tab(kk);
                       l_u_transit_time_tab(l_update_ctr)        := l_new_transit_time_tab(kk);
                       l_u_transit_time_uom_tab(l_update_ctr)    := l_new_transit_time_uom_tab(kk);
                       l_u_last_update_date_tab(l_update_ctr)    := l_new_last_update_date_tab(kk);
                       l_u_last_updated_by_tab(l_update_ctr)     := l_new_last_updated_by_tab(kk);
                       l_u_last_update_login_tab(l_update_ctr)   := l_new_last_update_login_tab(kk);
                       l_u_program_app_id_tab(l_update_ctr)      := l_new_program_app_id_tab(kk);
                       l_u_program_id_tab(l_update_ctr)          := l_new_program_id_tab(kk);
                       l_u_program_update_date_tab(l_update_ctr) := l_new_program_update_date_tab(kk);
                       l_u_request_id_tab(l_update_ctr)          := l_new_request_id_tab(kk);
                    ELSE
                       --
                       -- This is an error, there should either be both or neither
                       --
                       RAISE FTE_DIST_ORIG_DEST_LOAD_ERR;
                       --
                       IF l_debug_on THEN
                          WSH_DEBUG_SV.pop(l_module_name);
                       END IF;
                       --
                       RETURN;
                    END IF;

                 END LOOP;    -- END OF LOOP_02 (checking for insert and update records



                 --
                 -- Do the update if any
                 --
                 IF (l_u_origin_id_tab.COUNT > 0) THEN

                    FND_FILE.PUT_LINE(FND_FILE.log, 'Bulk update of mileage records');
                    --
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Bulk update of mileage records');
                    END IF;

                    --
                    -- Update records exist, doing a bulk update
                    --
                    FORALL m in l_u_origin_id_tab.FIRST..l_u_origin_id_tab.LAST
                       UPDATE FTE_LOCATION_MILEAGES
                          SET    identifier_type        = l_u_identifier_type_tab(m),
                                 distance               = l_u_distance_tab(m),
                                 distance_uom           = l_u_distance_uom_tab(m),
                                 transit_time           = l_u_transit_time_tab(m),
                                 transit_time_uom       = l_u_transit_time_uom_tab(m),
                                 last_update_date       = l_u_last_update_date_tab(m),
                                 last_updated_by        = l_u_last_updated_by_tab(m),
                                 last_update_login      = l_u_last_update_login_tab(m),
                                 program_application_id = l_u_program_app_id_tab(m),
                                 program_id             = l_u_program_id_tab(m),
                                 program_update_date    = l_u_program_update_date_tab(m),
                                 request_id             = l_u_request_id_tab(m)
                          WHERE  origin_id = l_u_origin_id_tab(m)
                          AND    destination_id = l_u_destination_id_tab(m);
                 END IF;


                 --
                 -- now do the insert
                 --
                 IF (l_i_origin_id_tab.COUNT > 0) THEN

                    FND_FILE.PUT_LINE(FND_FILE.log, 'Bulk insert of mileage records');
                    --
                    IF l_debug_on THEN
                       WSH_DEBUG_SV.logmsg(l_module_name,'Bulk insert of mileage records');
                    END IF;

                    --
                    -- Insert records exist, doing a bulk insert
                    --
                    FORALL i in l_i_origin_id_tab.FIRST..l_i_origin_id_tab.LAST
                       insert into FTE_LOCATION_MILEAGES(origin_id,
                                                         destination_id,
                                                         identifier_type,
                                                         distance,
                                                         distance_uom,
                                                         transit_time,
                                                         transit_time_uom,
                                                         creation_date,
                                                         created_by,
                                                         last_update_date,
                                                         last_updated_by,
                                                         last_update_login,
                                                         program_application_id,
                                                         program_id,
                                                         program_update_date,
                                                         request_id)
                                                  values(l_i_origin_id_tab(i),
                                                         l_i_destination_id_tab(i),
                                                         l_i_identifier_type_tab(i),
                                                         l_i_distance_tab(i),
                                                         l_i_distance_uom_tab(i),
                                                         l_i_transit_time_tab(i),
                                                         l_i_transit_time_uom_tab(i),
                                                         l_i_creation_date_tab(i),
                                                         l_i_created_by_tab(i),
                                                         l_i_last_update_date_tab(i),
                                                         l_i_last_updated_by_tab(i),
                                                         l_i_last_update_login_tab(i),
                                                         l_i_program_app_id_tab(i),
                                                         l_i_program_id_tab(i),
                                                         l_i_program_update_date_tab(i),
                                                         l_i_request_id_tab(i));

                 END IF;
              END IF;

              EXIT WHEN c_get_merge_data%NOTFOUND OR c_get_merge_data%NOTFOUND IS NULL;
           END LOOP;   -- End of LOOP_01 (Cursor query loop

           --
           -- Close the cursor if open
           --
           IF (c_get_merge_data%ISOPEN) THEN
              CLOSE c_get_merge_data;
           END IF;
--
--
--  [ABLUNDEL][12/08/2003][BUG# 3301222] End of Code Changes for bug
-- ---------------------------------------------------------------------


        FND_FILE.PUT_LINE(FND_FILE.log, 'Updating the Download files table with upload information');
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Updating the Download files table with upload information');
        END IF;
        --
        --
        -- Update FTE_MILE_DOWNLOAD_FILES with the upload date
        --
        update fte_mile_download_files
        set    upload_date = l_cur_date,
               upload_id   = p_load_id
        where  download_file_id =  l_download_file_id;

        --
        -- save all the changes
        --
        commit;


        FND_FILE.PUT_LINE(FND_FILE.log, 'Deleting data from the Download lines table');
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Deleting data from the Download lines table');
        END IF;
        --
        --
        -- Delete the lines
        --
        delete fte_mile_download_lines
        where  download_file_id = l_download_file_id
        returning download_file_id BULK COLLECT INTO l_deleted_download_ids;

        commit;


        FND_FILE.PUT_LINE(FND_FILE.log, 'Returning with success');

        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Returning with success');
        END IF;
        --
        x_return_status  := -1;
        x_return_message := null;

        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;

     ELSIF (l_number_of_table_lines > l_line_ctr) THEN
        --
        -- The file has less lines than when it was created, i.e. lines from the
        -- file have been deleted, thus we cannot load
        --
        -- issue a commit to clear the temp table??
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'The file has less lines than when it was created, i.e. lines from the file have been deleted, thus we cannot load, RAISE FTE_DIST_LESS_FILE_LINES exception');
        END IF;
        --
        RAISE FTE_DIST_LESS_FILE_LINES;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;

     ELSIF (l_number_of_table_lines < l_line_ctr) THEN
        --
        -- There are too many lines in the file i.e. lines have been added
        -- we cannot load this file.
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'There are too many lines in the file i.e. lines have been added we cannot load this file RAISE FTE_DIST_MANY_FILE_LINES exception');
        END IF;
        --
        RAISE FTE_DIST_MANY_FILE_LINES;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;

     END IF;

-- AXE
EXCEPTION
   WHEN FTE_DIST_INV_TEMP_TIME_UOM THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INV_TEMP_TIME_UOM');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - INV TEMP TIME UOM. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_INV_TEMP_TIME_UOM FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_INV_TEMP_TIME_UOM');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_TIME_UOM THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_TIME_UOM');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO TIME UOM. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NO_TIME_UOM FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NO_TIME_UOM');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_INV_TEMP_DIST_UOM THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INV_TEMP_DIST_UOM');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - INV TEMP DIST UOM. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_INV_TEMP_DIST_UOM FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_INV_TEMP_DIST_UOM');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN FTE_DIST_NO_DISTANCE_UOM THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_DISTANCE_UOM');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO DISTANCE UOM. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NO_DISTANCE_UOM FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NO_DISTANCE_UOM');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN FTE_DIST_ORIG_DEST_LOAD_ERR THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_ORIG_DEST_LOAD_ERR');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - ORIG DEST LOAD ERR. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_ORIG_DEST_LOAD_ERR FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_ORIG_DEST_LOAD_ERR');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN FTE_DIST_LESS_FILE_LINES THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_LESS_FILE_LINES');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - LESS FILE LINES. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_LESS_FILE_LINES FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_LESS_FILE_LINES');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_MANY_FILE_LINES THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_MANY_FILE_LINES');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - TOO MANY FILE LINES. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_MANY_FILE_LINES FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_MANY_FILE_LINES');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN FTE_DIST_NULL_FILE_NAME THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NULL_FILE_NAME');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NULL FILE NAME. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NULL_FILE_NAME FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NULL_FILE_NAME');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN FTE_DIST_INV_FILENAME_LGTH THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INVALID_FILE_LENGTH');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - INVALID FILE LENGTH. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_INV_FILENAME_LGTH FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_INV_FILENAME_LGTH');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_NO_FILE_DOWNLOAD THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_FILE_DOWNLOAD');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO FILE DOWNLOAD. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;

      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NO_FILE_DOWNLOAD FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NO_FILE_DOWNLOAD');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_NO_FILE_TEMPLATE THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_FILE_TEMPLATE');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO FILE TEMPLATE. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;
      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NO_FILE_TEMPLATE FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NO_FILE_TEMPLATE');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN FTE_DIST_NO_FILE_DOWNLOAD_DATE THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_FILE_DOWNLOAD_DATE');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO FILE DOWNLOAD_DATE. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;
      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NO_FILE_DOWNLOAD_DATE FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NO_FILE_DOWNLOAD_DATE');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_FILE_UPLOAD_DONE_PREV THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_FILE_UPLOAD_DONE_PREV');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - PREVIOUS FILE UPLOAD EXISTS. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;
      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_FILE_UPLOAD_DONE_PREV FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_FILE_UPLOAD_DONE_PREV');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_DOWNLOAD_LINES THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_DOWNLOAD_LINES');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO DOWNLOAD LINES. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;
      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NO_DOWNLOAD_LINES FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NO_DOWNLOAD_LINES');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_RET_DIST_COL_NO_DATA THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_RET_DIST_COL_NO_DATA');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO RETURN DISTANCE COLUMN DATA. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;
      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_RET_DIST_COL_NO_DATA FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_RET_DIST_COL_NO_DATA');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_RET_TIME_COL_NO_DATA THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_RET_TIME_COL_NO_DATA');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO RETURN TIME COLUMN DATA. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;
      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;

      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_RET_TIME_COL_NO_DATA FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_RET_TIME_COL_NO_DATA');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_RET_COL_ENABLED THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_RET_COL_ENABLED');
      x_return_status  := 2;
      x_return_message := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.log, 'ERROR IN PROCEDURE READ_DTT_FILE - NO RETURN COLUMNS ENABLED. '||x_return_message);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_dtt_file)) THEN
         utl_file.fclose(l_dtt_file);
      END IF;
      --
      -- Close the cursors
      --
      IF (c_check_download_lines%ISOPEN) THEN
         CLOSE c_check_download_lines;
      END IF;

      IF (c_get_file_info%ISOPEN) THEN
         CLOSE c_get_file_info;
      END IF;

      IF (c_get_download_lines%ISOPEN) THEN
         CLOSE c_get_download_lines;
      END IF;

      IF (c_get_ret_col_info%ISOPEN) THEN
         CLOSE c_get_ret_col_info;
      END IF;
      IF (c_get_ret_enabled%ISOPEN) THEN
         CLOSE c_get_ret_enabled;
      END IF;

      IF (c_get_merge_data%ISOPEN) THEN
         CLOSE c_get_merge_data;
      END IF;

      IF (c_get_time_uom%ISOPEN) THEN
         CLOSE c_get_time_uom;
      END IF;

      IF (c_get_distance_uom%ISOPEN) THEN
         CLOSE c_get_distance_uom;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NO_RET_COL_ENABLED FTE_BULK_DTT_PKG.READ_DTT_FILE: '||x_return_message);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NO_RET_COL_ENABLED');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN OTHERS THEN
      x_return_status  := 2;
      x_return_message := sqlerrm;
      FND_FILE.PUT_LINE(FND_FILE.log, 'UNEXPECTED ERROR IN PROCEDURE READ_DTT_FILE. '|| sqlerrm);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'THE UNEXPECTED ERROR FROM FTE_BULK_DTT_PKG.READ_DTT_FILE IS ' ||sqlerrm);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||sqlerrm,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;


      RETURN;

END READ_DTT_FILE;




-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                FIRST_TIME                                            --
--                                                                            --
-- TYPE:                FUNCTION                                              --
--                                                                            --
-- PARAMETERS (IN OUT): none                                                  --
--                                                                            --
-- PARAMETERS (OUT):    none                                                  --
--                                                                            --
-- RETURN:              TRUE, FALSE  (boolean)                                --
--                                                                            --
-- DESCRIPTION:         Return TRUE if this is the first call of the procedure--
--                      LOAD_DTT_FILE by the concurrent manager. FALSE        --
--                      otherwise.  This is necessary because the procedure   --
--                      LOAD_DTT_FILE is called twice by the concurrent       --
--                      manager controlling the bulkloading process. The first--
--                      time to start the  process, and the second time after --
--                      the sub-processes  have finished executing.           --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
FUNCTION FIRST_TIME RETURN BOOLEAN IS

req_data      VARCHAR2(100);

l_debug_on     BOOLEAN;
l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' ||'FIRST_TIME';
l_error_text   VARCHAR2(2000);


BEGIN

   --
   -- SETUP DEBUGGING
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF (g_user_debug = 1) THEN
     l_debug_on := TRUE;
   END IF;


    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------FIRST_TIME------------');
    END IF;


   FND_FILE.PUT_LINE(FND_FILE.log, 'FIRST_TIME');

   req_data := FND_CONC_GLOBAL.request_data;

   IF (req_data IS NULL) THEN
      FND_FILE.PUT_LINE(FND_FILE.log, 'FIRST_TIME returning TRUE');
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN TRUE;
   ELSE
      FND_FILE.PUT_LINE(FND_FILE.log, 'FIRST_TIME returning FALSE');
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN FALSE;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      Fnd_File.Put_Line(Fnd_File.Log, 'Unexpected Error in Procedure FIRST_TIME' || sqlerrm);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'THE UNEXPECTED ERROR FROM FTE_BULK_DTT_PKG.FIRST_TIME IS ' ||sqlerrm);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||sqlerrm,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

      RETURN FALSE;

END FIRST_TIME;



END FTE_BULK_DTT_PKG;

/
