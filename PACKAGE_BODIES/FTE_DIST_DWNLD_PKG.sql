--------------------------------------------------------
--  DDL for Package Body FTE_DIST_DWNLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_DIST_DWNLD_PKG" AS
/* $Header: FTEDISDB.pls 115.11 2004/03/18 20:20:07 ablundel noship $ */
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_DIST_DWNLD_PKG                                            --
-- TYPE:        PACKAGE BODY                                                  --
-- DESCRIPTION: Contains core procedures for creating an OD download file     --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created.                           --
--                                                                            --
-- 2003/12/17  J        ABLUNDEL  3325486  PROCEDURE: CREATE_DWNLD_FILE       --
--                                         Commented out the code that creates--
--                                         the spaces in the line for return  --
--                                         distance and return time. Now the  --
--                                         download file only contains the    --
--                                         origin and destination columns     --
--                                                                            --
-- 2003/12/19  J        ABLUNDEL  3330390  GLOBAL PACKAGE VARIABLES           --
--                                         Changed the value for              --
--                                         g_default_file_ext to be lowercase --
--                                         'in' instead of 'IN' as the linux  --
--                                         version of batchpro only works     --
--                                         with a lowercase file extension    --
--                                                                            --
-- 2004/03/05  J        ABLUNDEL  3487060  PROCEDURE: CREATE_DWNLD_FILE       --
--                                         Need to check that region values   --
--                                         exist for translated values for    --
--                                         the return from c_get_region_values--
--                                         from WSH_REGIONS_V (changed to the --
--                                         view, VL) from the TL table        --
--                                                                            --
-- -------------------------------------------------------------------------- --

-- -------------------------------------------------------------------------- --
-- Global Package Variables                                                   --
-- ------------------------                                                   --
--                                                                            --
-- -------------------------------------------------------------------------- --
g_file_prefix       CONSTANT VARCHAR2(3)  := 'DLF';

-- [ABLUNDEL][12/19/2003][BUG# 3330390]
-- Change default file extension to be lowercase - in
--
-- g_default_file_ext  CONSTANT VARCHAR2(2)   := 'IN';
--
g_default_file_ext  CONSTANT VARCHAR2(2)   := 'in';


g_filename_length   CONSTANT NUMBER       := 8;
g_file_ext_length   CONSTANT NUMBER       := 3;
g_y_flag            CONSTANT VARCHAR2(1)  := 'Y';
g_n_flag            CONSTANT VARCHAR2(1)  := 'N';
g_ret_dist_col_name CONSTANT VARCHAR2(30) := 'RETURNDIST';
g_ret_time_col_name CONSTANT VARCHAR2(30) := 'RETURNTIME';
g_origin_col_name   CONSTANT VARCHAR2(30) := 'ORIGIN';
g_dest_col_name     CONSTANT VARCHAR2(30) := 'DESTINATION';
g_postal_code_name  CONSTANT VARCHAR2(30) := 'POSTAL_CODE';
g_city_code_name    CONSTANT VARCHAR2(30) := 'CITY';
g_state_code_name   CONSTANT VARCHAR2(30) := 'STATE';
g_county_code_name  CONSTANT VARCHAR2(30) := 'COUNTY';
g_country_code_name CONSTANT VARCHAR2(30) := 'COUNTRY';


--
-- For debug
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_DIST_INT_PKG';


-- -------------------------------------------------------------------------- --
--                                                                            --
-- PRIVATE PROCEDURE DEFINITIONS                                              --
-- -----------------------------                                              --
-- Described in Procedure code below                                          --
-- -------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                PROCEDURE BULK_DOWNLOAD_DTT                           --
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
--                      Called from $fte/java/mileage/FteMileDwnldCO.java for --
--                      Downloading DTT file                                  --
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
PROCEDURE BULK_DOWNLOAD_DTT(p_load_id                      IN NUMBER,
                            p_template_id                  IN NUMBER,
                            p_origin_facility_id           IN VARCHAR2,
                            p_origin_region_id             IN VARCHAR2,
                            p_origin_all_fac_flag          IN VARCHAR2,
                            p_all_fac_no_data_flag         IN VARCHAR2,
                            p_dest_facility_id             IN VARCHAR2,
                            p_dest_region_id               IN VARCHAR2,
                            p_dest_all_fac_flag            IN VARCHAR2,
                            p_file_extension               IN VARCHAR2,
                            p_src_filename                 IN VARCHAR2,
                            p_resp_id                      IN NUMBER,
                            p_resp_appl_id                 IN NUMBER,
                            p_user_id                      IN NUMBER,
                            p_user_debug                   IN NUMBER,
                            x_filename                     OUT NOCOPY VARCHAR2,
                            x_request_id                   OUT NOCOPY NUMBER,
                            x_error_msg_text               OUT NOCOPY VARCHAR2) IS


x_src_filedir  VARCHAR2(100);
l_debug_on     BOOLEAN;
l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' ||'BULK_DOWNLOAD_DTT';
l_file_extension VARCHAR2(3);
l_filename       VARCHAR2(50);
l_return_status VARCHAR2(1);
l_return_message VARCHAR2(2000);
l_user_debug     VARCHAR2(1);

l_origin_facility_id     NUMBER;
l_origin_region_id       NUMBER;
l_dest_facility_id       NUMBER;
l_dest_region_id         NUMBER;


FTE_DIST_NO_FILENAME          EXCEPTION;
FTE_DIST_ERR_CREATE_FILENAME  EXCEPTION;

BEGIN

   l_user_debug := 'N';

   IF ((p_user_debug = 0) OR (p_user_debug is null)) THEN
      l_user_debug := 'N';
   END IF;

   g_user_debug     := p_user_debug;
   --
   -- SETUP DEBUGGING
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF ((g_user_debug is not null) AND (g_user_debug = 1)) THEN
     l_debug_on := TRUE;
     l_user_debug := 'Y';
   END IF;


   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
      WSH_DEBUG_SV.log(l_module_name,'p_load_id',p_template_id);
      WSH_DEBUG_SV.log(l_module_name,'p_template_id',p_origin_facility_id);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_facility_id',p_origin_region_id);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_region_id',p_origin_all_fac_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_all_fac_no_data_flag',p_all_fac_no_data_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_facility_id',p_dest_facility_id);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_region_id',p_dest_region_id);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_all_fac_flag',p_dest_all_fac_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_file_extension',p_file_extension);
      WSH_DEBUG_SV.log(l_module_name,'p_src_filename',p_src_filename);
      WSH_DEBUG_SV.log(l_module_name,'p_resp_id',p_resp_id);
      WSH_DEBUG_SV.log(l_module_name,'p_resp_appl_id',p_resp_appl_id);
      WSH_DEBUG_SV.log(l_module_name,'p_user_id',p_user_id);
      WSH_DEBUG_SV.log(l_module_name,'p_user_debug',p_user_debug);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;


   --
   -- The facility and region ids passed in are in tet format as java
   -- seems to have a problem parsing to an integer if the string is big like 1000002008644
   -- so we do it here
   --
   IF (p_origin_facility_id is not null) THEN
      l_origin_facility_id := to_number(p_origin_facility_id);
   ELSE
      l_origin_facility_id := null;
   END IF;

   IF (p_origin_region_id is not null) THEN
      l_origin_region_id := to_number(p_origin_region_id);
   ELSE
      l_origin_region_id := null;
   END IF;

   IF (p_dest_facility_id is not null) THEN
      l_dest_facility_id := to_number(p_dest_facility_id);
   ELSE
      l_dest_facility_id := null;
   END IF;

   IF (p_dest_region_id is not null) THEN
      l_dest_region_id := to_number(p_dest_region_id);
   ELSE
      l_dest_region_id := null;
   END IF;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling fnd_global.apps_initialize p_user_id, p_resp_id, p_resp_appl_id');
   END IF;

   fnd_global.apps_initialize(user_id      => p_user_id,
                              resp_id      => p_resp_id,
                              resp_appl_id => p_resp_appl_id);


    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling FTE_BULKLOAD_PKG.GET_UPLOAD_DIR');
    END IF;

    x_src_filedir := FTE_BULKLOAD_PKG.GET_UPLOAD_DIR;


    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_src_filedir', x_src_filedir);
    END IF;



    --
    -- Create the filename
    --
    l_file_extension := p_file_extension;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME');
    END IF;

    FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME(p_user_debug_flag => l_user_debug,
                                             x_file_extension  => l_file_extension,
                                             x_file_name       => l_filename,
                                             x_return_message  => l_return_message,
                                             x_return_status   => l_return_status);


    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Error from FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME , l_return_status = '||l_return_status);
          WSH_DEBUG_SV.logmsg(l_module_name,'RAISE FTE_DIST_ERR_CREATE_FILENAME');
       END IF;

       RAISE FTE_DIST_ERR_CREATE_FILENAME;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN;
    END IF;

    IF (l_filename is null) THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'l_filename is null - RAISE FTE_DIST_NO_FILENAME');
       END IF;
       --
       RAISE FTE_DIST_NO_FILENAME;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN;
    END IF;

    x_filename := l_filename;

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_filename = ',x_filename);
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling FND_REQUEST.SUBMIT_REQUEST for FTE FTE_BULK_DTT_DOWNLOAD');
    END IF;



    x_request_id := FND_REQUEST.SUBMIT_REQUEST(application  => 'FTE',
                                               program      => 'FTE_BULK_DTT_DOWNLOAD',
                                               description  => null,
                                               start_time   => null,
                                               sub_request  => false,
                                               argument1    => p_load_id,
                                               argument2    => x_filename,
                                               argument3    => x_src_filedir,
                                               argument4    => p_user_debug,
                                               argument5    => p_template_id,
                                               argument6    => l_origin_facility_id,
                                               argument7    => l_origin_region_id,
                                               argument8    => p_origin_all_fac_flag,
                                               argument9    => p_all_fac_no_data_flag,
                                               argument10   => l_dest_facility_id,
                                               argument11   => l_dest_region_id,
                                               argument12   => p_dest_all_fac_flag,
                                               argument13   => l_file_extension);


     x_error_msg_text := fnd_message.get;

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_request_id',x_request_id);
       WSH_DEBUG_SV.log(l_module_name,'x_error_msg_text',x_error_msg_text);
     END IF;


     commit;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
     END IF;
     --

    RETURN;



EXCEPTION
   WHEN FTE_DIST_ERR_CREATE_FILENAME THEN
      x_request_id := 0;
      x_error_msg_text := l_return_message;
      Fnd_File.Put_Line(Fnd_File.Log, x_error_msg_text);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_ERR_CREATE_FILENAME FTE_DIST_DWNLD_PKG.BULK_DOWNLOAD_DTT: '||x_error_msg_text);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_ERR_CREATE_FILENAME');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

    WHEN FTE_DIST_NO_FILENAME THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_FILENAME');
      x_error_msg_text := FND_MESSAGE.GET;
      Fnd_File.Put_Line(Fnd_File.Log, x_error_msg_text);
      x_request_id := 0;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'ERROR FTE_DIST_NO_FILENAME FTE_DIST_DWNLD_PKG.BULK_DOWNLOAD_DTT: '||x_error_msg_text);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION: FTE_DIST_NO_FILENAME');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

    WHEN OTHERS THEN
       x_error_msg_text := sqlerrm;
       Fnd_File.Put_Line(Fnd_File.Log, 'Unexpected Error in Procedure BULK_DOWNLOAD_DTT' || sqlerrm);
       x_request_id := 0;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'THE UNEXPECTED ERROR FROM FTE_DIST_DWNLD_PKG.BULK_DOWNLOAD_DTT IS: '||x_error_msg_text);
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||x_error_msg_text,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
    RETURN;


END BULK_DOWNLOAD_DTT;



-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                PROCEDURE DOWNLOAD_DTT_FILE                           --
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
-- DESCRIPTION:         Runs the entire DTT downloading process               --
--                      Called from the FTE_BULK_DTT_DOWNLOAD concurrent      --
--                      program                                               --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created                            --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE DOWNLOAD_DTT_FILE(p_errbuf        OUT NOCOPY VARCHAR2,
                            p_retcode       OUT NOCOPY VARCHAR2,
                            p_load_id       IN NUMBER,
                            p_src_filename  IN VARCHAR2,
                            p_src_filedir   IN VARCHAR2,
                            p_user_debug    IN NUMBER,
                            p_template_id   IN NUMBER,
                            p_origin_facility_id IN NUMBER,
                            p_origin_region_id   IN NUMBER,
                            p_origin_all_fac_flag IN VARCHAR2,
                            p_all_fac_no_data_flag IN VARCHAR2,
                            p_dest_facility_id IN NUMBER,
                            p_dest_region_id IN NUMBER,
                            p_dest_all_fac_flag IN VARCHAR2,
                            p_file_extension IN VARCHAR2)  IS



g_first_time           BOOLEAN;
l_return_status        VARCHAR2(1);
l_return_message       VARCHAR2(2000);
l_filename             VARCHAR2(50);
l_dtt_file_name        VARCHAR2(50);


l_debug_on     BOOLEAN;
l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' ||'DOWNLOAD_DTT_FILE';


BEGIN

   g_user_debug      := p_user_debug;

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
      WSH_DEBUG_SV.logmsg(l_module_name,'-------DOWNLOAD_DTT_FILE-------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
      WSH_DEBUG_SV.log(l_module_name,'p_load_id',p_load_id);
      WSH_DEBUG_SV.log(l_module_name,'p_src_filename',p_src_filename);
      WSH_DEBUG_SV.log(l_module_name,'p_src_filedir',p_src_filedir);
      WSH_DEBUG_SV.log(l_module_name,'p_user_debug',p_user_debug);
      WSH_DEBUG_SV.log(l_module_name,'p_template_id',p_template_id);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_facility_id',p_origin_facility_id);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_region_id',p_origin_region_id);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_all_fac_flag',p_origin_all_fac_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_all_fac_no_data_flag',p_all_fac_no_data_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_facility_id',p_dest_facility_id);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_region_id',p_dest_region_id);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_all_fac_flag',p_dest_all_fac_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_file_extension',p_file_extension);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;


   l_return_status   := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   g_first_time      := FIRST_TIME;
   l_filename        := p_src_filename;




   IF (FIRST_TIME) THEN

      IF (l_filename is not null) THEN

         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_filename is not null - stripping the extension');
         END IF;

         l_dtt_file_name := substr(l_filename,1,(instr(l_filename,'.')-1));

         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_dtt_file_name',l_dtt_file_name);
         END IF;

      END IF;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA');
       END IF;

       FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA(p_template_id          => p_template_id,
                                           p_origin_facility_id   => p_origin_facility_id,
                                           p_origin_region_id     => p_origin_region_id,
                                           p_origin_all_fac_flag  => p_origin_all_fac_flag,
                                           p_all_fac_no_data_flag => p_all_fac_no_data_flag,
                                           p_dest_facility_id     => p_dest_facility_id,
                                           p_dest_region_id       => p_dest_region_id,
                                           p_dest_all_fac_flag    => p_dest_all_fac_flag,
                                           p_file_extension       => p_file_extension,
                                           p_user_debug_flag      => null,
                                           x_filename             => l_dtt_file_name,
                                           x_return_message       => l_return_message,
                                           x_return_status        => l_return_status);



   END IF;

   IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      --
      -- Concurrent Manager expects 0 for success.
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'COMPLETED DTT DOWNLOAD SUCCESSFULLY');
      END IF;
      p_retcode := 0;
      p_errbuf := 'COMPLETED DTT DOWNLOAD SUCCESSFULLY';
   ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,l_return_message);
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'DTT DOWNLOAD Completed with errors');
         WSH_DEBUG_SV.log(l_module_name,'l_return_message',l_return_message);
      END IF;
      --
      p_retcode := 2;
      p_errbuf := 'COMPLETED WITH ERRORS. ' || p_errbuf ||': '||l_return_message||'. Please Check Logs for more details.';
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '*****ERROR****' || SQLERRM);
      p_retcode := 2;
      p_errbuf  := p_errbuf || sqlerrm;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'THE UNEXPECTED ERROR FROM FTE_DIST_DWNLD_PKG.DOWNLOAD_DTT_FILE IS: '||p_errbuf);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||p_errbuf,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --

END DOWNLOAD_DTT_FILE;





-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                DOWNLOAD_OD_DATA                                      --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT): p_template_id                  IN  NUMBER             --
--                      p_origin_facility_id           IN  NUMBER             --
--                      p_origin_region_id             IN  NUMBER             --
--                      p_origin_all_fac_flag          IN  VARCHAR2           --
--                      p_all_fac_no_data_flag  IN  VARCHAR2           --
--                      p_dest_facility_id             IN  NUMBER             --
--                      p_dest_region_id               IN  NUMBER             --
--                      p_dest_all_fac_flag            IN  VARCHAR2           --
--                                                                            --
-- PARAMETERS (OUT):    x_return_message       OUT NOCOPY VARCHAR2            --
--                      x_return_status        OUT NOCOPY VARCHAR2            --
--                                                                            --
-- RETURN:              n/a                                                   --
--                                                                            --
-- DESCRIPTION:         This procedure initiates the creation of an OD        --
--                      pair download file based on the input criteria        --
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
PROCEDURE DOWNLOAD_OD_DATA(p_template_id                  IN NUMBER,
                           p_origin_facility_id           IN NUMBER,
                           p_origin_region_id             IN NUMBER,
                           p_origin_all_fac_flag          IN VARCHAR2,
                           p_all_fac_no_data_flag         IN VARCHAR2,
                           p_dest_facility_id             IN NUMBER,
                           p_dest_region_id               IN NUMBER,
                           p_dest_all_fac_flag            IN VARCHAR2,
                           p_file_extension               IN VARCHAR2,
                           p_user_debug_flag              IN VARCHAR2,
                           x_filename                     IN OUT NOCOPY VARCHAR2,
                           x_return_message               OUT NOCOPY VARCHAR2,
                           x_return_status                OUT NOCOPY VARCHAR2) IS


--
-- Local Variable Definitions
--
l_distance_profile  VARCHAR2(30);         -- holds the FTE_DISTANCE_LVL profile option value
l_return_message    VARCHAR2(2000);       -- Return message from API (if error in API)
l_return_status     VARCHAR2(1);          -- Return Status from called API (values = S,E,W,U)
l_error_text        VARCHAR2(2000);       -- Holds the unexpected error text
l_filename          VARCHAR2(240);        -- holds the name of the download file
l_file_extension    VARCHAR2(10);         -- holds the file extension of the download file
l_ctr               PLS_INTEGER;          -- Used to check the input parameters
l_region_type       NUMBER;               -- holds the type of the region to download
l_origin_id         NUMBER;               -- holds the region or location origin id
l_origin_route      PLS_INTEGER;          -- holds the origin query route to take based on input
l_destination_route PLS_INTEGER;          -- holds the destination query route to take based on input
l_destination_id    NUMBER;               -- holds the region or location destination id
l_user_debug_flag   VARCHAR2(1);          -- holds the debug flag from the java calling method


--
-- Exception Handlers
--
FTE_DIST_INVALID_PROFILE      EXCEPTION;
FTE_DIST_NULL_PROFILE         EXCEPTION;
FTE_DIST_NULL_TEMPLATE_ID     EXCEPTION;
FTE_DIST_NULL_ORIGIN_INPUT    EXCEPTION;
FTE_DIST_NULL_DEST_INPUT      EXCEPTION;
FTE_DIST_MANY_ORIGIN_INPUT    EXCEPTION;
FTE_DIST_MANY_DEST_INPUT      EXCEPTION;
FTE_DIST_NULL_REGION_TYPE     EXCEPTION;
FTE_DIST_NO_FILENAME          EXCEPTION;
FTE_DIST_INVALID_FILE_LENGTH  EXCEPTION;
FTE_DIST_INVALID_FILE_EXT     EXCEPTION;
FTE_DIST_ERR_CREATE_FILENAME  EXCEPTION;
FTE_DIST_DWNLD_FAILED         EXCEPTION;




--
-- Local Debug Variable Definitions
--
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DOWNLOAD_OD_DATA';



BEGIN

   --
   -- set the debug flag
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF (p_user_debug_flag <> 'Y') THEN
      l_user_debug_flag := null;
   ELSE
      l_user_debug_flag := p_user_debug_flag;
   END IF;

   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;

   IF (l_user_debug_flag = 'Y') THEN
      l_debug_on := TRUE;
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
      WSH_DEBUG_SV.log(l_module_name,'p_template_id',p_template_id);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_facility_id',p_origin_facility_id);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_region_id',p_origin_region_id);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_all_fac_flag',p_origin_all_fac_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_all_fac_no_data_flag',p_all_fac_no_data_flag);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_facility_id',p_dest_facility_id);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_region_id',p_dest_region_id);
      WSH_DEBUG_SV.log(l_module_name,'p_dest_all_fac_flag',p_dest_all_fac_flag);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;

   --
   -- Set the return flags for the start of the procedure
   --
   x_return_message := null;
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   --
   -- Set the filename and extension to the local variables
   --
   l_filename := x_filename;
   l_file_extension := p_file_extension;


   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_filename = ',l_filename);
      WSH_DEBUG_SV.log(l_module_name,'l_file_extension = ',l_file_extension);
   END IF;

   --
   -- Check that the input parameters are OK
   --
   IF ((p_template_id is null) OR
       (p_template_id = 0))  THEN
      --
      -- Template Id is null, cannot make a file without a template
      -- Raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'p_template_id is null raise FTE_DIST_NULL_TEMPLATE_ID exception');
      END IF;
      RAISE FTE_DIST_NULL_TEMPLATE_ID;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;



   IF ((p_all_fac_no_data_flag is null) OR
      (p_all_fac_no_data_flag <> 'Y')) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_all_fac_no_data_flag <> Y checking inputs');
      END IF;
      --
      -- Check that there is no more than one origin input value
      -- otherwise we could get very confused
      --
      l_ctr := 0;
      IF (p_origin_facility_id > 0 ) THEN
         l_ctr := l_ctr + 1;
      END IF;

      IF (p_origin_region_id > 0) THEN
         l_ctr := l_ctr + 1;
      END IF;

      IF ((p_origin_all_fac_flag is not null) AND
         (p_origin_all_fac_flag <> 'N')) THEN
         l_ctr := l_ctr + 1;
      END IF;

      IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Origin params l_ctr = ',l_ctr);
      END IF;

      IF (l_ctr = 0) THEN
         --
         -- No origin input provided - raise an error
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'all origin input parameters are null, raise FTE_DIST_NULL_ORIGIN_INPUT exception');
         END IF;

         RAISE FTE_DIST_NULL_ORIGIN_INPUT;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;

      ELSIF (l_ctr > 1) THEN
         --
         -- Too many origin inputs provided - raise an error
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'too many origin input parameters, raise FTE_DIST_MANY_ORIGIN_INPUT exception');
         END IF;

         RAISE FTE_DIST_MANY_ORIGIN_INPUT;
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
      -- reset the counter to check the destination input parameters
      --
      l_ctr := 0;

      --
      -- Check that there is no more than one destination input value
      -- otherwise we could get very confused
      --
      IF (p_dest_facility_id > 0) THEN
         l_ctr := l_ctr + 1;
      END IF;

      IF (p_dest_region_id > 0) THEN
         l_ctr := l_ctr + 1;
      END IF;

      IF ((p_dest_all_fac_flag is not null) AND
         (p_dest_all_fac_flag <> 'N')) THEN
         l_ctr := l_ctr + 1;
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Destination params l_ctr = ',l_ctr);
      END IF;

      IF (l_ctr = 0) THEN
         --
         -- No destination input provided - raise an error
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'all destination input parameters are null, raise FTE_DIST_NULL_DEST_INPUT exception');
         END IF;


         RAISE FTE_DIST_NULL_DEST_INPUT;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;

      ELSIF (l_ctr > 1) THEN
         --
         -- Too many destination inputs provided - raise an error
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'too many destination input parameters , raise FTE_DIST_MANY_DEST_INPUT exception');
         END IF;


         RAISE FTE_DIST_MANY_DEST_INPUT;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;
-- ELSE
      --
      -- all facilities without distance has been selected
      --
   END IF;


   --
   -- Check the filename and file extension parameters
   --
   IF (l_filename is null) THEN
      --
      -- The filename is null we will create one. If the extension is null
      -- then we will make one up
      --

      IF (l_file_extension is not null) THEN
         IF (length(l_file_extension) > g_file_ext_length) THEN
            RAISE FTE_DIST_INVALID_FILE_EXT;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
         END IF;
      END IF;


      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME',WSH_DEBUG_SV.C_PROC_LEVEL);
          WSH_DEBUG_SV.log(l_module_name,'p_user_debug_flag =',l_user_debug_flag);
         WSH_DEBUG_SV.log(l_module_name,'l_file_extension= ',l_file_extension);
         WSH_DEBUG_SV.log(l_module_name,'l_filename = ',l_filename);
         WSH_DEBUG_SV.log(l_module_name,'l_return_message = ',l_return_message);
         WSH_DEBUG_SV.log(l_module_name,'l_return_status = ',l_return_status);
      END IF;
      --

      FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME(p_user_debug_flag => l_user_debug_flag,
                                               x_file_extension  => l_file_extension,
                                               x_file_name       => l_filename,
                                               x_return_message  => l_return_message,
                                               x_return_status   => l_return_status);



      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME failed, return status = ',l_return_status);
            WSH_DEBUG_SV.log(l_module_name,'l_return_message = ',l_return_message);
            WSH_DEBUG_SV.logmsg(l_module_name,'RAISE FTE_DIST_ERR_CREATE_FILENAME');
         END IF;

         RAISE FTE_DIST_ERR_CREATE_FILENAME;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

      IF (l_filename is null) THEN
         RAISE FTE_DIST_NO_FILENAME;
         RETURN;
      END IF;
   ELSE
      --
      -- A filename has been passed in to the API
      --
      IF (length(l_filename) <> g_filename_length) THEN
         --
         -- The filename is incorrect
         --
         RAISE FTE_DIST_INVALID_FILE_LENGTH;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

      IF (l_file_extension is null) THEN
         l_file_extension := g_default_file_ext;
      END IF;
      l_filename := l_filename||'.'||l_file_extension;
   END IF;

   x_filename := l_filename;


   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_filename = ',x_filename);
   END IF;

   --
   -- End of checking input parameters for correctness.
   --



   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Get the profile option value of the distance stuff to see what region level we should be searching for');
   END IF;
   --
   -- Get the profile option value
   --
   --
   -- Get the profile option of the distance stuff to
   -- see what region level we should be searching for
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'getting the distance profile valie fnd_profile.get(FTE_DISTANCE_LVL)');
   END IF;

   fnd_profile.get('FTE_DISTANCE_LVL',l_distance_profile);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'fnd_profile.get(FTE_DISTANCE_LVL)= ',l_distance_profile);
   END IF;

   IF (l_distance_profile is null) THEN
      --
      -- The profile option is null - raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'distance profile is null raise FTE_DIST_NULL_PROFILE exception');
      END IF;
      RAISE FTE_DIST_NULL_PROFILE;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;


   IF ((l_distance_profile <> 'CITYSTATE') AND
       (l_distance_profile <> 'ZIP') AND
       (l_distance_profile <> 'COUNTY')) THEN
      --
      -- The profile option has an invalid value - raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The profile option has an invalid value - raise an error RAISE FTE_DIST_INVALID_PROFILE');
      END IF;

      RAISE FTE_DIST_INVALID_PROFILE;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;


   IF (l_distance_profile = 'CITYSTATE') THEN
      --
      -- region type is city level
      --
      l_region_type := 2;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'distance profile is CITYSTATE - region type = ',l_region_type);
      END IF;
   ELSIF (l_distance_profile = 'ZIP') THEN
      --
      -- region type is zip/postal level
      --
      l_region_type := 3;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'distance profile is ZIP - region type = ',l_region_type);
      END IF;
   ELSIF (l_distance_profile = 'COUNTY') THEN
      --
      -- region type is county level
      --
      l_region_type := 4;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'distance profile is COUNTY - region type = ',l_region_type);
      END IF;
   ELSE
      --
      -- The profile option has an invalid value - raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The profile option has an invalid value - raise an error RAISE FTE_DIST_INVALID_PROFILE');
      END IF;

      RAISE FTE_DIST_INVALID_PROFILE;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;


   IF (l_region_type is null) THEN
      --
      -- region type is null cannot have that Raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'region type is null - raise an error FTE_DIST_NULL_REGION_TYPE');
      END IF;
      RAISE FTE_DIST_NULL_REGION_TYPE;
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
   -- There are 3 scenarios for the origin and 3 for the destination
   -- and 1 for both (facilities w/o distance and t time data) determine
   -- which routes to go for each set
   -- route_1: facility_id
   -- route_2: region_id
   -- route_3: all eligible facilities
   -- route_4: all facilities without distance and transit time data
   --
   IF (p_origin_facility_id > 0) THEN
      l_origin_route := 1;
      l_origin_id := p_origin_facility_id;
   END IF;

   IF (p_origin_region_id  > 0) THEN
      l_origin_route := 2;
      l_origin_id := p_origin_region_id;
   END IF;

   IF ((p_origin_all_fac_flag is not null) AND
       (p_origin_all_fac_flag <> 'N')) THEN
      l_origin_route := 3;
   END IF;

   IF (p_dest_facility_id > 0) THEN
      l_destination_route := 1;
      l_destination_id    := p_dest_facility_id;
   END IF;

   IF (p_dest_region_id > 0) THEN
      l_destination_route := 2;
      l_destination_id := p_dest_region_id;
   END IF;

   IF ((p_dest_all_fac_flag is not null) AND
      (p_dest_all_fac_flag <> 'N')) THEN
      l_destination_route := 3;
   END IF;

   IF (p_all_fac_no_data_flag = 'Y') THEN
      --
      -- this applies to both
      --
      l_origin_route := 4;
      l_destination_route := 4;
   END IF;



   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILE',WSH_DEBUG_SV.C_PROC_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'------------ INPUT PARAMETERS ------------');
      WSH_DEBUG_SV.log(l_module_name,'l_origin_route = ',l_origin_route);
      WSH_DEBUG_SV.log(l_module_name,'l_destination_route = ',l_destination_route);
      WSH_DEBUG_SV.log(l_module_name,'l_origin_id = ',l_origin_id);
      WSH_DEBUG_SV.log(l_module_name,'l_destination_id = ',l_destination_id);
      WSH_DEBUG_SV.log(l_module_name,'p_template_id = ',p_template_id);
      WSH_DEBUG_SV.log(l_module_name,'l_filename = ',l_filename);
      WSH_DEBUG_SV.log(l_module_name,'l_file_extension = ',l_file_extension);
      WSH_DEBUG_SV.log(l_module_name,'l_region_type = ',l_region_type);
      WSH_DEBUG_SV.log(l_module_name,'l_user_debug_flag = ',l_user_debug_flag);
      WSH_DEBUG_SV.log(l_module_name,'l_return_message = ',l_return_message);
      WSH_DEBUG_SV.log(l_module_name,'l_return_status = ',l_return_status);
   END IF;
   --
   --
   -- Create the download file
   --
   FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILE(p_origin_route      => l_origin_route,
                                        p_destination_route => l_destination_route,
                                        p_origin_id         => l_origin_id,
                                        p_destination_id    => l_destination_id,
                                        p_template_id       => p_template_id,
                                        p_file_name         => l_filename,
                                        p_file_extension    => l_file_extension,
                                        p_region_type       => l_region_type,
                                        p_distance_profile  => l_distance_profile,
                                        p_user_debug_flag   => l_user_debug_flag,
                                        x_return_message    => l_return_message,
                                        x_return_status     => l_return_status);


   IF (l_return_message <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
      --
      -- The Download File suffered an error!
      --
      RAISE FTE_DIST_DWNLD_FAILED;

      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   END IF;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --

   --
   -- Everything was OK
   --
   x_return_message := null;
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --
   -- commit the changes
   --
   commit;


   --
   -- Lets go home
   --
   RETURN;


EXCEPTION
   WHEN FTE_DIST_INVALID_PROFILE THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INVALID_PROFILE');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.GET_DISTANCE_TIME FTE_DIST_INVALID_PROFILE RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_INVALID_PROFILE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_INVALID_PROFILE');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NULL_PROFILE THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NULL_PROFILE');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.GET_DISTANCE_TIME FTE_DIST_NULL_PROFILE RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NULL_PROFILE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NULL_PROFILE');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NULL_TEMPLATE_ID THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NULL_TEMPLATE_ID');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_NULL_TEMPLATE_ID RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NULL_TEMPLATE_ID exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NULL_TEMPLATE_ID');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NULL_ORIGIN_INPUT THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NULL_ORIGIN_INPUT');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_NULL_ORIGIN_INPUT RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NULL_ORIGIN_INPUT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NULL_ORIGIN_INPUT');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_NULL_DEST_INPUT THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NULL_DEST_INPUT');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_NULL_DEST_INPUT RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NULL_DEST_INPUT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NULL_DEST_INPUT');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_MANY_ORIGIN_INPUT THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_MANY_ORIGIN_INPUT');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_MANY_ORIGIN_INPUT RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_MANY_ORIGIN_INPUT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_MANY_ORIGIN_INPUT');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_MANY_DEST_INPUT THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_MANY_DEST_INPUT');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_MANY_DEST_INPUT RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_MANY_DEST_INPUT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_MANY_DEST_INPUT');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NULL_REGION_TYPE THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NULL_REGION_TYPE');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_NULL_REGION_TYPE RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NULL_REGION_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NULL_REGION_TYPE');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_FILENAME THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_FILENAME');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_NO_FILENAME RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_FILENAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_FILENAME');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_INVALID_FILE_LENGTH THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INVALID_FILE_LENGTH');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_INVALID_FILE_LENGTH RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_INVALID_FILE_LENGTH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_INVALID_FILE_LENGTH');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_INVALID_FILE_EXT THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INVALID_FILE_EXT');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_INVALID_FILE_EXT RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_INVALID_FILE_EXT exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_INVALID_FILE_EXT');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_ERR_CREATE_FILENAME THEN
      x_return_status  := l_return_status;
      x_return_message := l_return_message;
      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_ERR_CREATE_FILENAME RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_ERR_CREATE_FILENAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_ERR_CREATE_FILENAME');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_DWNLD_FAILED THEN
      x_return_status  := l_return_status;
      x_return_message := l_return_message;
      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA FTE_DIST_DWNLD_FAILED RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_DWNLD_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_DWNLD_FAILED');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN OTHERS THEN
      l_error_text := SQLERRM;

      --
      -- Close any open cursors
      --

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA IS ' ||L_ERROR_TEXT  );
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_DIST_DWNLD_PKG.DOWNLOAD_OD_DATA');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := l_error_text;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

END DOWNLOAD_OD_DATA;




-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                CREATE_DWNLD_FILENAME                                 --
--                                                                            --
-- TYPE:                FUNCTION                                              --
--                                                                            --

PROCEDURE CREATE_DWNLD_FILENAME(p_user_debug_flag IN VARCHAR2,
                                x_file_extension  IN OUT NOCOPY VARCHAR2,
                                x_file_name       OUT NOCOPY VARCHAR2,
                                x_return_message  OUT NOCOPY VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2) IS


--
-- Gets the file id used to create the file name
--
cursor c_get_file_id IS
select fte_mile_dlf_file_s.nextval
from   dual;



l_file_id    NUMBER;
l_file_name  VARCHAR2(30);
l_file_ext   VARCHAR2(3);
l_error_text VARCHAR2(2000);



FTE_DIST_NO_FILE_ID EXCEPTION;

--
-- Local Debug Variable Definitions
--
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DWNLD_FILENAME';

BEGIN


   --
   -- set the debug flag
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF (p_user_debug_flag = 'Y') THEN
      l_debug_on := TRUE;
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'-------CREATE_DWNLD_FILENAME-------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
      WSH_DEBUG_SV.log(l_module_name,'x_file_extension',x_file_extension);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;

   --
   -- Set the return flags for the start of the procedure
   --
   x_return_message := null;
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Opening c_get_file_id cursor');
   END IF;

   OPEN c_get_file_id;
      FETCH c_get_file_id INTO l_file_id;
   CLOSE c_get_file_id;


   IF (l_file_id is null) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_file_id from cursor is null - raise FTE_DIST_NO_FILE_ID');
      END IF;

      RAISE FTE_DIST_NO_FILE_ID;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

      RETURN;
   END IF;

   l_file_name := g_file_prefix||lpad(to_char(l_file_id),5,'0');
   l_file_ext := nvl(x_file_extension,g_default_file_ext);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_file_name = ',l_file_name);
      WSH_DEBUG_SV.log(l_module_name,'l_file_ext = ',l_file_ext);
   END IF;

   x_file_name := l_file_name||'.'||l_file_ext;
   x_file_extension := l_file_ext;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_file_name = ',x_file_name);
      WSH_DEBUG_SV.log(l_module_name,'x_file_extension = ',x_file_extension);
   END IF;

   x_return_message := null;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;


EXCEPTION
   WHEN FTE_DIST_NO_FILE_ID THEN

      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_FILE_ID');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- Close any open cursors
      --
      IF (c_get_file_id%ISOPEN) THEN
         CLOSE c_get_file_id;
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME FTE_DIST_NO_FILE_ID RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_FILE_ID exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_FILE_ID');
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN OTHERS THEN
      l_error_text := SQLERRM;

      --
      -- Close any open cursors
      --
      IF (c_get_file_id%ISOPEN) THEN
         CLOSE c_get_file_id;
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME IS ' ||L_ERROR_TEXT  );
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILENAME');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := x_return_message||' - '||l_error_text;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



END CREATE_DWNLD_FILENAME;




-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                CREATE_DWNLD_FILE                                     --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT):                                                       --
--                                                                            --
-- PARAMETERS (OUT):                                                          --
--                      x_return_message OUT NOCOPY VARCHAR2                  --
--                      x_return_status  OUT NOCOPY VARCHAR2                  --
--                                                                            --
-- RETURN:              none                                                  --
--                                                                            --
-- DESCRIPTION:         This procedure performs the distance and transit time --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
-- ------------------                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created                            --
--                                                                            --
-- 2003/12/17  J        ABLUNDEL  3325486  Commented out the code that creates--
--                                         the spaces in the line for return  --
--                                         distance and return time. Now the  --
--                                         download file only contains the    --
--                                         origin and destination columns     --
--                                                                            --
-- 2004/03/05  J        ABLUNDEL  3487060  Need to check that region values   --
--                                         exist for translated values for    --
--                                         the return from c_get_region_values--
--                                         from WSH_REGIONS_V (changed to the --
--                                         view, VL) from the TL table        --
--                                                                            --
-- -------------------------------------------------------------------------- --
PROCEDURE CREATE_DWNLD_FILE(p_origin_route      IN PLS_INTEGER,
                            p_destination_route IN PLS_INTEGER,
                            p_origin_id         IN NUMBER,
                            p_destination_id    IN NUMBER,
                            p_template_id       IN NUMBER,
                            p_file_name         IN VARCHAR2,
                            p_file_extension    IN VARCHAR2,
                            p_region_type       IN NUMBER,
                            p_distance_profile  IN VARCHAR2,
                            p_user_debug_flag   IN VARCHAR2,
                            x_return_message    OUT NOCOPY VARCHAR2,
                            x_return_status     OUT NOCOPY VARCHAR2) IS

l_ctr                       PLS_INTEGER;
l_cd                        PLS_INTEGER;
l_error_text                VARCHAR2(2000);
l_download_dir              VARCHAR2(100);
l_origin_col_id             NUMBER;
l_ret_time_col_id           NUMBER;
l_ret_dist_col_id           NUMBER;
l_use_length                VARCHAR2(1);
l_ret_dist_length           VARCHAR2(1);
l_ret_time_length            VARCHAR2(1);
l_ret_dist_yn               VARCHAR2(1);
l_ret_time_yn               VARCHAR2(1);
l_origin_seq                PLS_INTEGER;
l_dest_seq                  PLS_INTEGER;
l_ret_dist_seq              PLS_INTEGER;
l_ret_time_seq              PLS_INTEGER;
l_col1_type                 VARCHAR2(30);
l_col2_type                 VARCHAR2(30);
l_idx1                      PLS_INTEGER;
l_idx2                      PLS_INTEGER;
l_col1_start_pos            NUMBER;
l_col1_length               NUMBER;
l_col_length                NUMBER;
l_col1_delim                VARCHAR2(10);
l_col2_start_pos            NUMBER;
l_col2_length               NUMBER;
l_col2_delim                VARCHAR2(10);
l_idx                       PLS_INTEGER;
l_found                     PLS_INTEGER;
l_distance_count            NUMBER;
l_origin_route              NUMBER;
l_destination_route         NUMBER;
l_language                  VARCHAR2(4);
l_od_idx                    PLS_INTEGER;
l_code_idx                  PLS_INTEGER;
l_str_length                NUMBER;
l_dest_attr_string          VARCHAR2(2000);
l_origin_attr_string        VARCHAR2(2000);
l_target_file               utl_file.file_type;
l_origin_reg_id             NUMBER;
l_dest_reg_id               NUMBER;
l_download_file_id          NUMBER;
l_line_ctr                  PLS_INTEGER;
l_rmve_ctr                  PLS_INTEGER;
l_file_string               VARCHAR2(4000);
l_ret_dist_string           VARCHAR2(4000);
l_ret_time_string           VARCHAR2(4000);
l_dest_attr_value           VARCHAR2(4000);
l_origin_attr_value         VARCHAR2(4000);
l_dest_attr_found           VARCHAR2(1);
l_orig_attr_found           VARCHAR2(1);
l_match_flag                  VARCHAR2(1);
l_check_region_type           NUMBER;
l_orig_reg_ctr                PLS_INTEGER;
l_parent_loop                 PLS_INTEGER;
l_reg_ctr                     PLS_INTEGER;
l_preg_ctr                    PLS_INTEGER;
l_cont_ctr                    PLS_INTEGER;

l_orig_denorm_id            FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_dest_denorm_id            FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_od_pair_tab               FTE_DIST_DWNLD_PKG.fte_distd_od_pair_tab;

l_col_tab                   FTE_DIST_DWNLD_PKG.fte_distd_col_tab;
l_tmplt_col_tab             FTE_DIST_DWNLD_PKG.fte_distd_tmplt_col_tab;
l_attr_tab                  FTE_DIST_DWNLD_PKG.fte_distd_attr_tab;

l_column_id_tab             FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_column_type_tab           FTE_DIST_DWNLD_PKG.fte_distd_tmp_code_table;
l_column_start_position_tab FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_column_length_tab         FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_column_delimiter_tab      FTE_DIST_DWNLD_PKG.fte_distd_tmp_flag_table;
l_column_sequence_id_tab    FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;

l_odattr_column_attr_id_tab FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_odattr_code_tab           FTE_DIST_DWNLD_PKG.fte_distd_tmp_code_table;
l_odattr_attr_delimiter_tab FTE_DIST_DWNLD_PKG.fte_distd_tmp_flag_table;
l_odattr_space_padding_tab  FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_odattr_sequence_id_tab    FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_odattr_length_tab         FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;

l_retdis_column_attr_id_tab FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_retdis_code_tab           FTE_DIST_DWNLD_PKG.fte_distd_tmp_code_table;
l_retdis_attr_delimiter_tab FTE_DIST_DWNLD_PKG.fte_distd_tmp_flag_table;
l_retdis_space_padding_tab  FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_retdis_sequence_id_tab    FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_retdis_length_tab         FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;

l_rettim_column_attr_id_tab FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_rettim_code_tab           FTE_DIST_DWNLD_PKG.fte_distd_tmp_code_table;
l_rettim_attr_delimiter_tab FTE_DIST_DWNLD_PKG.fte_distd_tmp_flag_table;
l_rettim_space_padding_tab  FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_rettim_sequence_id_tab    FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_rettim_length_tab         FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;

l_origin_location_id        FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_origin_region_id          FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_elig_locs_id_tab          FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_destination_location_id   FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_destination_region_id     FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;

l_reg_region_id_tab         FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_reg_postal_code_from_tab  FTE_DIST_DWNLD_PKG.fte_distd_tmp_code_table;
l_reg_city_tab              FTE_DIST_DWNLD_PKG.fte_distd_tmp_char60_table;
l_reg_state_tab             FTE_DIST_DWNLD_PKG.fte_distd_tmp_char60_table;
l_reg_county_tab            FTE_DIST_DWNLD_PKG.fte_distd_tmp_char60_table;
l_reg_country_tab           FTE_DIST_DWNLD_PKG.fte_distd_tmp_char80_table;

l_reg_table                 FTE_DIST_DWNLD_PKG.fte_distd_region_tab;
l_reg_code_region_id_tab    FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_reg_code_state_tab        FTE_DIST_DWNLD_PKG.fte_distd_tmp_char10_table;
l_reg_code_country_tab      FTE_DIST_DWNLD_PKG.fte_distd_tmp_char10_table;

l_reg_code_table            FTE_DIST_DWNLD_PKG.fte_distd_reg_code_tab;

l_remove_idx_tab               FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_distance_tab_origin_id_tab   FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_distance_tab_distance_id_tab FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_orig_location_id             FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_orig_region_id               FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_dest_location_id         FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_dest_region_id           FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;

l_match_locations_tab         FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_sub_regions_tab             FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_sub_region_type_tab         FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_match_region_id             FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_parent_sub_regions_tab      FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_parent_regions_tab          FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_sub_par_cont_tab            FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_tmp_orig_reg                FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_tmp_orig_loc                FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_tmp_dest_reg                FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;
l_tmp_dest_loc                FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;

l_od_check_tab                FTE_DIST_DWNLD_PKG.fte_distd_tmp_num_table;

cursor c_get_distance_tab_pairs IS
select flm.origin_id,
       flm.destination_id
from   fte_location_mileages flm;


cursor c_get_region_codes(cp_region_id NUMBER) IS
select wr.region_id,
       wr.state_code,
       wr.country_code
from   wsh_regions wr
where  region_id = cp_region_id;


-- [BUG:3487060]
-- Replace the base table query with a query on the view and remove county
--
-- cursor c_get_region_values(cp_region_id NUMBER,
--                           cp_language  VARCHAR2) IS
-- select wrtl.region_id,
--       wrtl.postal_code_from,
--       wrtl.city,
--       wrtl.state,
--       wrtl.county,
--       wrtl.country
-- from   wsh_regions_tl wrtl
-- where  wrtl.region_id = cp_region_id
-- and    wrtl.language  = cp_language;
--


cursor c_get_region_values(cp_region_id NUMBER) IS
select wrtl.region_id,
       wrtl.postal_code_from,
       wrtl.city,
       wrtl.state,
       null,
       wrtl.country
from   wsh_regions_v wrtl
where  wrtl.region_id = cp_region_id;





cursor c_check_distance_table IS
select count(origin_id)
from   fte_location_mileages;


cursor c_get_all_elig_fac(cp_enabled_flag_y VARCHAR2) IS
select flp.location_id
from   fte_location_parameters flp
where  flp.include_mileage_flag = cp_enabled_flag_y;


cursor c_get_region_for_facility(cp_location_id NUMBER,
                                 cp_region_type NUMBER) IS
select wrl.location_id,
       wrl.region_id
from   wsh_region_locations wrl
where  wrl.location_id = cp_location_id
and    wrl.region_type = cp_region_type;



cursor c_get_template_columns(cp_template_id NUMBER) IS
select fmtc.column_id,
       fmtc.column_type,
       fmtc.start_position,
       fmtc.length,
       fmtc.column_delimiter,
       fmtc.column_sequence
from   fte_mile_template_columns fmtc
where  fmtc.template_id = cp_template_id
order by fmtc.column_sequence;


cursor c_get_col_attrs(cp_column_id    NUMBER,
                       cp_enabled_flag VARCHAR2) IS
select fmca.column_attribute_id,
       fmca.code,
       fmca.attribute_delimiter,
       fmca.space_padding,
       fmca.sequence_id,
       fmca.length
from   fte_mile_column_attributes fmca
where  fmca.column_id = cp_column_id
and    fmca.enabled_flag = cp_enabled_flag
order by fmca.sequence_id;


cursor c_get_col_attr(cp_column_id    NUMBER,
                      cp_enabled_flag VARCHAR2,
                      cp_seq_id       NUMBER) IS
select fmca.column_attribute_id,
       fmca.code,
       fmca.attribute_delimiter,
       fmca.space_padding,
       fmca.sequence_id,
       fmca.length
from   fte_mile_column_attributes fmca
where  fmca.column_id = cp_column_id
and    fmca.enabled_flag = cp_enabled_flag
and    fmca.sequence_id = cp_seq_id;


cursor c_check_region_type(cp_region_id NUMBER) IS
select region_type
from   wsh_regions
where  region_id = cp_region_id;

cursor c_get_sub_regions(cp_region_id NUMBER) IS
select region_id,
       region_type
from   wsh_regions
where  parent_region_id = cp_region_id;

cursor c_check_matching_locs(cp_region_id NUMBER) IS
select location_id
from   wsh_region_locations
where  region_id = cp_region_id;

cursor c_check_mile_flag(cp_location_id NUMBER) IS
select include_mileage_flag
from   fte_location_parameters
where  location_id = cp_location_id;



FTE_DIST_NO_COLS_FOR_TEMPLATE EXCEPTION;
FTE_DIST_NO_RET_COLS          EXCEPTION;
FTE_DIST_NO_OD_COLS           EXCEPTION;
FTE_DIST_NO_RET_ATTRS         EXCEPTION;
FTE_DIST_NO_OD_ATTRS          EXCEPTION;
FTE_DIST_INVALID_START_POS    EXCEPTION;
FTE_DIST_INVALID_COL_LENGTHS  EXCEPTION;
FTE_DIST_NO_LOC_REG_MAP       EXCEPTION;
FTE_DIST_NO_LOC_SPEC_R1       EXCEPTION;
FTE_DIST_NO_REGION_SPEC_R2    EXCEPTION;
FTE_DIST_NO_ELIG_FACILI_R3    EXCEPTION;
FTE_DIST_NO_DWNLD_DIR         EXCEPTION;
FTE_DIST_COL_ZERO_START       EXCEPTION;
FTE_DIST_NO_RET_LENGTH        EXCEPTION;
FTE_DIST_NO_RET_ATTR          EXCEPTION;
FTE_DIST_RET_DIST_INV_LENGTH  EXCEPTION;
FTE_DIST_RET_DIST_INV_START   EXCEPTION;
FTE_DIST_RET_TIME_INV_LENGTH  EXCEPTION;
FTE_DIST_RET_TIME_INV_START   EXCEPTION;
FTE_DIST_NO_OD_PAIRS          EXCEPTION;
FTE_DIST_NO_MATCH_REGIONS_FND EXCEPTION;
FTE_DIST_INV_REGION_LOW       EXCEPTION;
FTE_DIST_NO_ORIG_REG_VALS     EXCEPTION;
FTE_DIST_NO_DEST_REG_VALS     EXCEPTION;



--
-- Local Debug Variable Definitions
--
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DWNLD_FILE';

l_spacer VARCHAR2(2000);

BEGIN

   --
   -- set the debug flag
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF (p_user_debug_flag = 'Y') THEN
      l_debug_on := TRUE;
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.logmsg(l_module_name,'-------CREATE_DWNLD_FILE-------');
      WSH_DEBUG_SV.logmsg(l_module_name,'-------- INPUT PARAMETERS ------');
      WSH_DEBUG_SV.log(l_module_name,'p_origin_route',p_origin_route);
      WSH_DEBUG_SV.log(l_module_name,'p_destination_route',p_destination_route);
      WSH_DEBUG_SV.log(l_module_name,'p_origin_id',p_origin_id);
      WSH_DEBUG_SV.log(l_module_name,'p_destination_id',p_destination_id);
      WSH_DEBUG_SV.log(l_module_name,'p_template_id',p_template_id);
      WSH_DEBUG_SV.log(l_module_name,'p_file_name',p_file_name);
      WSH_DEBUG_SV.log(l_module_name,'p_file_extension',p_file_extension);
      WSH_DEBUG_SV.log(l_module_name,'p_region_type',p_region_type);
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;

   --
   -- Set the return flags for the start of the procedure
   --
   x_return_message := null;
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   --
   -- reset the tables
   --
   l_column_id_tab.DELETE;
   l_column_type_tab.DELETE;
   l_column_start_position_tab.DELETE;
   l_column_length_tab.DELETE;
   l_column_delimiter_tab.DELETE;
   l_column_sequence_id_tab.DELETE;

   l_odattr_column_attr_id_tab.DELETE;
   l_odattr_code_tab.DELETE;
   l_odattr_attr_delimiter_tab.DELETE;
   l_odattr_space_padding_tab.DELETE;
   l_odattr_sequence_id_tab.DELETE;
   l_odattr_length_tab.DELETE;

   l_retdis_column_attr_id_tab.DELETE;
   l_retdis_code_tab.DELETE;
   l_retdis_attr_delimiter_tab.DELETE;
   l_retdis_space_padding_tab.DELETE;
   l_retdis_sequence_id_tab.DELETE;
   l_retdis_length_tab.DELETE;

   l_rettim_column_attr_id_tab.DELETE;
   l_rettim_code_tab.DELETE;
   l_rettim_attr_delimiter_tab.DELETE;
   l_rettim_space_padding_tab.DELETE;
   l_rettim_sequence_id_tab.DELETE;
   l_rettim_length_tab.DELETE;


   --
   -- Set the language for getting info from wsh_regions_v -- [BUG:3487060] not used anymore but keep for debug messages
   --
   l_language := nvl(userenv('LANG'),'US');

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_language := ',l_language);
   END IF;
   --
   -- Get the download_directory
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'gettting the bulkload directory from FTE_BULKLOAD_DIR profile ');
   END IF;
   fnd_profile.get('FTE_BULKLOAD_DIR',l_download_dir);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'FTE_BULKLOAD_DIR,l_download_dir = ',l_download_dir);
   END IF;

   IF (l_download_dir is null) THEN
      RAISE FTE_DIST_NO_DWNLD_DIR;
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
   -- Get the template column and attribute data
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'OPENING CURSOR c_get_template_columns with template_id',p_template_id);
   END IF;


   OPEN c_get_template_columns(p_template_id);
      FETCH c_get_template_columns BULK COLLECT INTO
         l_column_id_tab,
         l_column_type_tab,
         l_column_start_position_tab,
         l_column_length_tab,
         l_column_delimiter_tab,
         l_column_sequence_id_tab;
   CLOSE c_get_template_columns;

   IF (l_column_id_tab.COUNT = 0) THEN
      --
      -- No columns for the template were found
      -- Raise an error
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'No columns for the template were found raise FTE_DIST_NO_COLS_FOR_TEMPLATE');
      END IF;
      RAISE FTE_DIST_NO_COLS_FOR_TEMPLATE;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Retrieved column tables ---------------------');
      WSH_DEBUG_SV.log(l_module_name,'l_column_id_tab.COUNT = ',l_column_id_tab.COUNT);
      FOR ddd IN l_column_delimiter_tab.FIRST..l_column_delimiter_tab.LAST LOOP
         WSH_DEBUG_SV.log(l_module_name,'l_column_id_tab(ddd) = ',l_column_id_tab(ddd));
      END LOOP;
   END IF;



   --
   -- Now get the attribute information for the columns
   --
   FOR aaa IN l_column_type_tab.FIRST..l_column_type_tab.LAST LOOP
      IF (l_column_type_tab(aaa) = g_origin_col_name) THEN
         --
         -- OD attributes are only stored with the origin id
         --
         l_origin_col_id := l_column_id_tab(aaa);
         IF (l_origin_col_id is null) THEN
            --
            -- No OD column exists - raise an error
            --
            RAISE FTE_DIST_NO_OD_COLS;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.pop(l_module_name);
            END IF;
            --
            RETURN;
         END IF;
      END IF;

      IF (l_column_type_tab(aaa) = g_ret_dist_col_name) THEN
         --
         -- Return Distance col id
         --
         l_ret_dist_col_id := l_column_id_tab(aaa);

         IF (l_column_length_tab(aaa) is null) THEN
            l_ret_dist_length := 'N';
         ELSE
            l_ret_dist_length := 'Y';
         END IF;
      END IF;

      IF (l_column_type_tab(aaa) = g_ret_time_col_name) THEN
         --
         -- Return Time col id
         --
         l_ret_time_col_id := l_column_id_tab(aaa);
         IF (l_column_length_tab(aaa) is null) THEN
            l_ret_time_length := 'N';
         ELSE
            l_ret_time_length := 'Y';
         END IF;
      END IF;
   END LOOP;


   IF ((l_ret_dist_col_id is null) AND
       (l_ret_time_col_id is null)) THEN
      --
      -- There must be at least one return column
      -- but there isnt - rasie an error
      --
      RAISE FTE_DIST_NO_RET_COLS;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;

   IF ((l_ret_time_length = 'N') AND
       (l_ret_dist_length = 'N')) THEN
      --
      -- There are no lengths specified for the return columns
      -- Raise an error
      --
      RAISE FTE_DIST_NO_RET_LENGTH;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'OPENING CURSOR c_get_col_attrs');
      WSH_DEBUG_SV.log(l_module_name,'PARAMETER l_origin_col_id=  ',l_origin_col_id);
      WSH_DEBUG_SV.log(l_module_name,'PARAMETER g_y_flag = ',g_y_flag);
   END IF;
   --
   -- Get the OD attributes
   --
   OPEN c_get_col_attrs(l_origin_col_id,
                        g_y_flag);
      FETCH c_get_col_attrs BULK COLLECT INTO
         l_odattr_column_attr_id_tab,
         l_odattr_code_tab,
         l_odattr_attr_delimiter_tab,
         l_odattr_space_padding_tab,
         l_odattr_sequence_id_tab,
         l_odattr_length_tab;
   CLOSE c_get_col_attrs;


   --
   -- Get the return distance attribute
   --
   OPEN c_get_col_attrs(l_ret_dist_col_id,
                        g_y_flag);
     FETCH c_get_col_attrs BULK COLLECT INTO
        l_retdis_column_attr_id_tab,
        l_retdis_code_tab,
        l_retdis_attr_delimiter_tab,
        l_retdis_space_padding_tab,
        l_retdis_sequence_id_tab,
        l_retdis_length_tab;
   CLOSE c_get_col_attrs;

   --
   -- Get the return time attribute
   --
   OPEN c_get_col_attrs(l_ret_time_col_id,
                        g_y_flag);
     FETCH c_get_col_attrs BULK COLLECT INTO
        l_rettim_column_attr_id_tab,
        l_rettim_code_tab,
        l_rettim_attr_delimiter_tab,
        l_rettim_space_padding_tab,
        l_rettim_sequence_id_tab,
        l_rettim_length_tab;
   CLOSE c_get_col_attrs;


   IF ((l_rettim_column_attr_id_tab.COUNT = 0) AND
       (l_retdis_column_attr_id_tab.COUNT = 0)) THEN
      l_ret_dist_yn := 'N';
      l_ret_time_yn := 'N';
      --
      -- Neither of the return attributes have been enabled
      -- at least 1 must be
      --
      RAISE FTE_DIST_NO_RET_ATTR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   ELSIF ((l_rettim_column_attr_id_tab.COUNT > 0) AND
       (l_retdis_column_attr_id_tab.COUNT = 0)) THEN
      l_ret_time_yn := 'Y';
      l_ret_dist_yn := 'N';
   ELSIF ((l_rettim_column_attr_id_tab.COUNT = 0) AND
       (l_retdis_column_attr_id_tab.COUNT > 0)) THEN
      l_ret_time_yn := 'N';
      l_ret_dist_yn := 'Y';
   ELSIF ((l_rettim_column_attr_id_tab.COUNT > 0) AND
       (l_retdis_column_attr_id_tab.COUNT > 0)) THEN
      l_ret_time_yn := 'Y';
      l_ret_dist_yn := 'Y';
   END IF;



   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Setting all sequences for columns - if their sequence is null');
   END IF;
   --
   -- make sure all the columns have sequences
   --
   FOR colseq IN l_column_id_tab.FIRST..l_column_id_tab.LAST LOOP
      IF (l_column_type_tab(colseq) = g_origin_col_name) THEN
         IF (l_column_sequence_id_tab(colseq) is null) THEN
            l_column_sequence_id_tab(colseq) := 1;
         END IF;
      ELSIF (l_column_type_tab(colseq) = g_dest_col_name) THEN
         IF (l_column_sequence_id_tab(colseq) is null) THEN
            l_column_sequence_id_tab(colseq) := 2;
         END IF;
      ELSIF (l_column_type_tab(colseq) = g_ret_dist_col_name) THEN
         IF (l_column_sequence_id_tab(colseq) is null) THEN
            l_column_sequence_id_tab(colseq) := 3;
         END IF;
      ELSIF (l_column_type_tab(colseq) = g_ret_time_col_name) THEN
         IF (l_column_sequence_id_tab(colseq) is null) THEN
            l_column_sequence_id_tab(colseq) := 4;
         END IF;
      END IF;
   END LOOP;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Put the columns in a new table in the correct sequence, 1 to 4');
   END IF;
   --
   -- Put the columns in a new table in the correct sequence, 1 to 4
   --
   l_found := 0;
   FOR jjj in 1..4 LOOP
      FOR fff IN l_column_id_tab.FIRST..l_column_id_tab.LAST LOOP
         IF (l_column_sequence_id_tab(fff) = jjj) THEN

             IF ((l_column_type_tab(fff) = g_ret_dist_col_name) AND
                 (l_ret_dist_yn = 'Y')) THEN

                l_found := l_found + 1;
                l_col_tab(l_found).seq  := l_found;
                l_col_tab(l_found).code := l_column_type_tab(fff);
                IF ((l_column_length_tab(fff) is not null) AND
                    (l_column_length_tab(fff) > 0)) THEN
                   l_col_tab(l_found).length := l_column_length_tab(fff);
                ELSE
                   --
                   -- Return column is enabled but there is no length
                   -- raise an error
                   --
                   RAISE FTE_DIST_RET_DIST_INV_LENGTH;
                   RETURN;
                END IF;
                l_col_tab(l_found).delim := l_column_delimiter_tab(fff);
                IF ((l_column_start_position_tab(fff) is not null) AND
                    (l_column_start_position_tab(fff) > 0)) THEN
                    l_col_tab(l_found).start_pos := l_column_start_position_tab(fff);
                ELSE
                   --
                   -- Return column is enabled but there is no start pos
                   --
                   RAISE FTE_DIST_RET_DIST_INV_START;
                   RETURN;
                END IF;
                l_col_tab(l_found).id        := l_column_id_tab(fff);
                l_ret_dist_seq := l_col_tab(l_found).seq;
             END IF;

             IF ((l_column_type_tab(fff) =g_ret_time_col_name) AND
                 (l_ret_time_yn = 'Y')) THEN

                l_found := l_found + 1;
                l_col_tab(l_found).seq  := l_found;
                l_col_tab(l_found).code := l_column_type_tab(fff);
                IF ((l_column_length_tab(fff) is not null) AND
                    (l_column_length_tab(fff) > 0)) THEN
                   l_col_tab(l_found).length := l_column_length_tab(fff);
                ELSE
                   --
                   -- Return column is enabled but there is no length
                   -- raise an error
                   --
                   RAISE FTE_DIST_RET_TIME_INV_LENGTH;
                   RETURN;
                END IF;

                l_col_tab(l_found).delim := l_column_delimiter_tab(fff);

                IF ((l_column_start_position_tab(fff) is not null) AND
                    (l_column_start_position_tab(fff) > 0)) THEN
                    l_col_tab(l_found).start_pos := l_column_start_position_tab(fff);
                ELSE
                   --
                   -- Return column is enabled but there is no start pos
                   --
                   RAISE FTE_DIST_RET_TIME_INV_START;
                   RETURN;
                END IF;
                l_col_tab(l_found).id        := l_column_id_tab(fff);
                l_ret_time_seq := l_col_tab(l_found).seq;
            END IF;

            IF (l_column_type_tab(fff) = g_origin_col_name) THEN

               l_found := l_found + 1;
               l_col_tab(l_found).seq  := l_found;
               l_col_tab(l_found).code := l_column_type_tab(fff);
               l_col_tab(l_found).length := l_column_length_tab(fff);
               l_col_tab(l_found).delim := l_column_delimiter_tab(fff);
               l_col_tab(l_found).start_pos := l_column_start_position_tab(fff);
               l_col_tab(l_found).id        := l_column_id_tab(fff);
               l_origin_seq := l_col_tab(l_found).seq;
            END IF;

            IF (l_column_type_tab(fff) = g_dest_col_name) THEN
               l_found := l_found + 1;
                l_col_tab(l_found).seq  := l_found;
                l_col_tab(l_found).code := l_column_type_tab(fff);
                l_col_tab(l_found).length := l_column_length_tab(fff);
                l_col_tab(l_found).delim := l_column_delimiter_tab(fff);
                l_col_tab(l_found).start_pos := l_column_start_position_tab(fff);
                l_col_tab(l_found).id        := l_column_id_tab(fff);
               l_dest_seq   := l_col_tab(l_found).seq;
            END IF;

         END IF;
      END LOOP;
   END LOOP;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Setting all sequences for attributes - if their sequence is null');
   END IF;
   --
   -- make sure all the attributes have sequences
   --
   FOR attrs IN l_odattr_column_attr_id_tab.FIRST..l_odattr_column_attr_id_tab.LAST LOOP
      IF (l_odattr_code_tab(attrs) = g_postal_code_name) THEN
         IF (l_odattr_sequence_id_tab(attrs) is null) THEN
            l_odattr_sequence_id_tab(attrs) := 1;
         END IF;
      ELSIF (l_odattr_code_tab(attrs) = g_city_code_name) THEN
         IF (l_odattr_sequence_id_tab(attrs) is null) THEN
            l_odattr_sequence_id_tab(attrs) := 2;
         END IF;
      ELSIF (l_odattr_code_tab(attrs) = g_state_code_name) THEN
         IF (l_odattr_sequence_id_tab(attrs) is null) THEN
            l_odattr_sequence_id_tab(attrs) := 3;
         END IF;
      ELSIF (l_odattr_code_tab(attrs) = g_county_code_name) THEN
         IF (l_odattr_sequence_id_tab(attrs) is null) THEN
            l_odattr_sequence_id_tab(attrs) := 4;
         END IF;
      ELSIF (l_odattr_code_tab(attrs) = g_country_code_name) THEN
         IF (l_odattr_sequence_id_tab(attrs) is null) THEN
            l_odattr_sequence_id_tab(attrs) := 5;
         END IF;
      END IF;
   END LOOP;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Put the attributes in a new table in the correct sequence, 1 to 5');
   END IF;
   --
   -- Put the attibutes in a new table in the correct sequence, 1 to 5
   --
   l_found := 0;
   FOR jjj in 1..5 LOOP
      FOR fff IN l_odattr_column_attr_id_tab.FIRST..l_odattr_column_attr_id_tab.LAST LOOP
         IF (l_odattr_sequence_id_tab(fff) = jjj) THEN
            l_found := l_found + 1;
            l_attr_tab(l_found).seq  := l_found;
            l_attr_tab(l_found).code := l_odattr_code_tab(fff);
            l_attr_tab(l_found).length := l_odattr_length_tab(fff);
            l_col_length := l_col_length + nvl(l_odattr_length_tab(fff),0);
            l_attr_tab(l_found).delim := l_odattr_attr_delimiter_tab(fff);
            IF (l_found < l_odattr_column_attr_id_tab.COUNT) THEN
               IF (l_odattr_attr_delimiter_tab(fff) is not null) THEN
                  l_col_length := l_col_length + 1;
               END IF;
            ELSE
               l_attr_tab(l_found).delim := null;
            END IF;
         END IF;
      END LOOP;
   END LOOP;


   --
   -- Now we have to determine the start positions and the lengths
   -- for the download we only care about the ORIGIN and DESTIANTION columns
   -- and the OD attributes
   --
   -- a column has a start pos and a length and a delimiter
/* ********************************************************   */
   FOR ccc IN l_col_tab.FIRST..l_col_tab.LAST LOOP
      IF (l_col_tab(ccc).code = g_origin_col_name) THEN
         l_origin_seq := l_col_tab(ccc).seq;
      ELSIF (l_col_tab(ccc).code = g_dest_col_name) THEN
         l_dest_seq   := l_col_tab(ccc).seq;
      ELSIF (l_col_tab(ccc).code = g_ret_dist_col_name) THEN
         l_ret_dist_seq := l_col_tab(ccc).seq;
      ELSIF (l_col_tab(ccc).code = g_ret_time_col_name) THEN
         l_ret_time_seq := l_col_tab(ccc).seq;
      END IF;

      IF (l_col_tab(ccc).seq = 1) THEN
         --
         IF (l_col_tab(ccc).start_pos is null) THEN
            -- set start pos to 1
            l_col1_start_pos := 1;
            l_col_tab(ccc).start_pos := 1;
         END IF;

         IF ((l_col_tab(ccc).code = g_origin_col_name) OR
             (l_col_tab(ccc).code = g_dest_col_name)) THEN
            IF (l_col_tab(ccc).length is not null) THEN
               l_col1_length := l_col_tab(ccc).length;
               l_use_length := 'C';
            ELSE
               --
               -- use the attribute length
               --
               l_col1_length := l_col_length;
               l_col_tab(ccc).length := l_col_length;
               l_use_length := 'A';
            END IF;
         END IF;


         IF (l_col_tab(ccc).delim is not null) THEN
            l_col1_delim := l_col_tab(ccc).delim;
         ELSE
            l_col1_delim := null;
            l_col_tab(ccc).delim := null;
         END IF;
      ELSIF  (l_col_tab(ccc).seq = 2) THEN
         IF (l_col_tab(ccc).start_pos is null) THEN
            l_col_tab(ccc).start_pos := l_col_tab(1).start_pos + l_col_tab(1).length;
            IF (l_col_tab(1).delim is not null) THEN
               l_col_tab(ccc).start_pos := l_col_tab(ccc).start_pos + 1;
            END IF;
         END IF;

         IF ((l_col_tab(ccc).code = g_origin_col_name) OR
             (l_col_tab(ccc).code = g_dest_col_name)) THEN
            IF (l_use_length is null) THEN
               IF (l_col_tab(ccc).length is not null) THEN
                  l_use_length := 'C';
               ELSE
                  l_col_tab(ccc).length := l_col_length;
                  l_use_length := 'A';
               END IF;
            ELSIF (l_use_length = 'A') THEN
               l_col_tab(ccc).length := l_col_length;
            ELSIF (l_use_length = 'C') THEN
               IF (l_col_tab(ccc).length is null) THEN
                  IF (l_col_tab(ccc).code = g_origin_col_name) THEN
                     l_col_tab(ccc).length := l_col_tab(l_dest_seq).length;
                  ELSIF (l_col_tab(ccc).code = g_dest_col_name) THEN
                     l_col_tab(ccc).length := l_col_tab(l_origin_seq).length;
                  END IF;
               END IF;
            END IF;
         END IF;

      ELSIF  (l_col_tab(ccc).seq = 3) THEN
         IF (l_col_tab(ccc).start_pos is null) THEN
            l_col_tab(ccc).start_pos := l_col_tab(2).start_pos + l_col_tab(2).length;
            IF (l_col_tab(2).delim is not null) THEN
               l_col_tab(ccc).start_pos := l_col_tab(ccc).start_pos + 1;
            END IF;
         END IF;

         IF ((l_col_tab(ccc).code = g_origin_col_name) OR
             (l_col_tab(ccc).code = g_dest_col_name)) THEN
            IF (l_use_length is null) THEN
               IF (l_col_tab(ccc).length is not null) THEN
                  l_use_length := 'C';
               ELSE
                  l_col_tab(ccc).length := l_col_length;
                  l_use_length := 'A';
               END IF;
            ELSIF (l_use_length = 'A') THEN
               l_col_tab(ccc).length := l_col_length;
            ELSIF (l_use_length = 'C') THEN
               IF (l_col_tab(ccc).length is null) THEN
                  IF (l_col_tab(ccc).code = g_origin_col_name) THEN
                     l_col_tab(ccc).length := l_col_tab(l_dest_seq).length;
                  ELSIF (l_col_tab(ccc).code = g_dest_col_name) THEN
                     l_col_tab(ccc).length := l_col_tab(l_origin_seq).length;
                  END IF;
               END IF;
            END IF;
         END IF;

      ELSIF  (l_col_tab(ccc).seq = 4) THEN
         IF (l_col_tab(ccc).start_pos is null) THEN
            l_col_tab(ccc).start_pos := l_col_tab(3).start_pos + l_col_tab(3).length;
            IF (l_col_tab(3).delim is not null) THEN
               l_col_tab(ccc).start_pos := l_col_tab(ccc).start_pos + 1;
            END IF;
         END IF;

         IF ((l_col_tab(ccc).code = g_origin_col_name) OR
             (l_col_tab(ccc).code = g_dest_col_name)) THEN
            IF (l_use_length is null) THEN
               IF (l_col_tab(ccc).length is not null) THEN
                  l_use_length := 'C';
               ELSE
                  l_col_tab(ccc).length := l_col_length;
                  l_use_length := 'A';
               END IF;
            ELSIF (l_use_length = 'A') THEN
               l_col_tab(ccc).length := l_col_length;
            ELSIF (l_use_length = 'C') THEN
               IF (l_col_tab(ccc).length is null) THEN
                  IF (l_col_tab(ccc).code = g_origin_col_name) THEN
                     l_col_tab(ccc).length := l_col_tab(l_dest_seq).length;
                  ELSIF (l_col_tab(ccc).code = g_dest_col_name) THEN
                     l_col_tab(ccc).length := l_col_tab(l_origin_seq).length;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END LOOP;
/* *******************************************************  */
IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'---------- L_COL_TAB --------------');
      FOR zzz in l_col_tab.FIRST..l_col_tab.LAST LOOP
         WSH_DEBUG_SV.log(l_module_name,'idx = ',zzz);
         WSH_DEBUG_SV.log(l_module_name,'l_col_tab(zzz).seq = ',l_col_tab(zzz).seq);
         WSH_DEBUG_SV.log(l_module_name,'l_col_tab(zzz).code = ',l_col_tab(zzz).code);
         WSH_DEBUG_SV.log(l_module_name,'l_col_tab(zzz).start_pos = ',l_col_tab(zzz).start_pos);
         WSH_DEBUG_SV.log(l_module_name,'l_col_tab(zzz).length = ',l_col_tab(zzz).length);
         WSH_DEBUG_SV.log(l_module_name,'l_col_tab(zzz).delim = ',l_col_tab(zzz).delim);
         WSH_DEBUG_SV.log(l_module_name,'l_col_tab(zzz).id = ',l_col_tab(zzz).id);
      END LOOP;
END IF;


/*



   IF (l_origin_seq < l_dest_seq) THEN
      -- origin col is first
      l_col1_type := 'ORIGIN';
      l_col2_type := 'DESTINATION';
      l_idx1 := l_origin_seq;
      l_idx2 := l_dest_seq;
   ELSE
      l_col1_type := 'DESTINATION';
      l_col2_type := 'ORIGIN';
      l_idx1 := l_dest_seq;
      l_idx2 := l_origin_seq;
   END IF;

   --
   -- Do Column 1
   --
   IF (l_col_tab(l_idx1).start_pos is not null) THEN
      l_col1_start_pos := l_col_tab(l_idx1).start_pos;
   ELSE
      -- set start pos to 1
      l_col1_start_pos := 1;
   END IF;

   IF (l_col_tab(l_idx1).length is not null) THEN
      l_col1_length := l_col_tab(l_idx1).length;
      l_use_length := 'C';
   ELSE
      --
      -- use the attribute length
      --
      l_col1_length := l_col_length;
      l_use_length := 'A';
   END IF;

   IF (l_col_tab(l_idx1).delim is not null) THEN
      l_col1_delim := l_col_tab(l_idx1).delim;
   ELSE
      l_col1_delim := null;
   END IF;

   --
   -- now do col2
   --
   IF (l_col_tab(l_idx2).start_pos is not null) THEN
      l_col2_start_pos := l_col_tab(l_idx2).start_pos;
   ELSE
      -- set start pos to the start1 pos + start 1 length
      l_col2_start_pos := l_col1_start_pos + l_col1_length;
      IF (l_col1_delim is not null) THEN
         l_col2_start_pos := l_col2_start_pos + 1;
      END IF;
   END IF;

   IF (l_col_tab(l_idx2).length is not null) THEN
      l_col2_length := l_col_tab(l_idx2).length;
   ELSE
      --
      -- use the col1 length
      --
      l_col2_length := l_col1_length;
   END IF;

   IF (l_col_tab(l_idx2).delim is not null) THEN
      l_col2_delim := l_col_tab(l_idx2).delim;
   ELSE
      l_col2_delim := null;
   END IF;

   --
   -- Now we should have all the information about the columns and
   -- the atttrributes we need to validate the positions and lengths
   --
   IF (l_col1_start_pos >= l_col2_start_pos) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_col1_start_pos >= l_col2_start_pos');
         WSH_DEBUG_SV.log(l_module_name,'l_col1_start_pos = ',l_col1_start_pos);
         WSH_DEBUG_SV.log(l_module_name,'l_col2_start_pos = ',l_col2_start_pos);
         WSH_DEBUG_SV.logmsg(l_module_name,'RAISE FTE_DIST_INVALID_START_POS');
      END IF;

      RAISE FTE_DIST_INVALID_START_POS;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;

   IF ((l_col1_start_pos <= 0) OR
       (l_col2_start_pos <= 0)) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_col1_start_pos <= 0');
         WSH_DEBUG_SV.log(l_module_name,'l_col1_start_pos = ',l_col1_start_pos);
         WSH_DEBUG_SV.logmsg(l_module_name,'l_col2_start_pos <= 0');
         WSH_DEBUG_SV.log(l_module_name,'l_col2_start_pos = ',l_col2_start_pos);
         WSH_DEBUG_SV.logmsg(l_module_name,'RAISE FTE_DIST_COL_ZERO_START');
      END IF;
      RAISE FTE_DIST_COL_ZERO_START;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;


   IF ((l_col1_length <= 0) OR
       (l_col2_length <= 0)) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_col1_length <= 0 and so is col2_length');
         WSH_DEBUG_SV.log(l_module_name,'l_col1_length = ',l_col1_length);
         WSH_DEBUG_SV.log(l_module_name,'l_col2_length = ',l_col2_length);
         WSH_DEBUG_SV.logmsg(l_module_name,'RAISE FTE_DIST_INVALID_COL_LENGTHS');
      END IF;
      RAISE FTE_DIST_INVALID_COL_LENGTHS;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
   END IF;
*/
/*

   --
   -- Now we should have all the information to build the template
   -- Store the information in a table
   --
   l_idx := 0;

   l_idx := l_idx + 1;
   l_tmplt_col_tab(l_idx).seq  := l_idx;
   l_tmplt_col_tab(l_idx).type := l_col1_type;
   l_tmplt_col_tab(l_idx).start_pos := l_col1_start_pos;
   l_tmplt_col_tab(l_idx).length := l_col1_length;
   l_tmplt_col_tab(l_idx).delim := l_col1_delim;
   l_idx := l_idx + 1;
   l_tmplt_col_tab(l_idx).seq  := l_idx;
   l_tmplt_col_tab(l_idx).type := l_col2_type;
   l_tmplt_col_tab(l_idx).start_pos := l_col2_start_pos;
   l_tmplt_col_tab(l_idx).length := l_col2_length;
   l_tmplt_col_tab(l_idx).delim := l_col2_delim;

*/


   IF l_debug_on THEN
/*
      WSH_DEBUG_SV.logmsg(l_module_name,'----------  COLUMNS --------------');
      FOR zzz in l_tmplt_col_tab.FIRST..l_tmplt_col_tab.LAST LOOP
         WSH_DEBUG_SV.log(l_module_name,'idx = ',zzz);
         WSH_DEBUG_SV.log(l_module_name,'l_tmplt_col_tab(zzz).seq = ',l_tmplt_col_tab(zzz).seq);
         WSH_DEBUG_SV.log(l_module_name,'l_tmplt_col_tab(zzz).type = ',l_tmplt_col_tab(zzz).type);
         WSH_DEBUG_SV.log(l_module_name,'l_tmplt_col_tab(zzz).start_pos = ',l_tmplt_col_tab(zzz).start_pos);
         WSH_DEBUG_SV.log(l_module_name,'l_tmplt_col_tab(zzz).length = ',l_tmplt_col_tab(zzz).length);
         WSH_DEBUG_SV.log(l_module_name,'l_tmplt_col_tab(zzz).delim = ',l_tmplt_col_tab(zzz).delim);
      END LOOP;
*/
      WSH_DEBUG_SV.logmsg(l_module_name,'------------ --------------');
      WSH_DEBUG_SV.logmsg(l_module_name,'------------ ATTRIBUTES ------------');
      FOR vvv IN l_attr_tab.FIRST..l_attr_tab.LAST LOOP
         WSH_DEBUG_SV.log(l_module_name,'l_attr_tab(vvv).seq  := ',l_attr_tab(vvv).seq);
         WSH_DEBUG_SV.log(l_module_name,'l_attr_tab(vvv).code = ',l_attr_tab(vvv).code);
         WSH_DEBUG_SV.log(l_module_name,'l_attr_tab(vvv).length = ',l_attr_tab(vvv).length);
         WSH_DEBUG_SV.log(l_module_name,'l_attr_tab(vvv).delim = ',l_attr_tab(vvv).delim);
      END LOOP;
      WSH_DEBUG_SV.logmsg(l_module_name,'------------ --------------');
      WSH_DEBUG_SV.log(l_module_name,'l_use_length := '||l_use_length);
   END IF;


   --
   -- Now we have a table of column and attribute data
   -- lets get the data and populate the file
   --
   l_origin_route := p_origin_route;
   l_destination_route := p_destination_route;

   IF ((l_origin_route = 4) OR
       (l_destination_route = 4)) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'origin route and destination route is 4 - big one');
      END IF;
      --
      -- The call is for all eligible facilities without distance or transit time information
      -- This means all OD pairs that do not have a record in the distance table
      -- in order to do this we have to get all OD pairs of origin and destination
      -- do route 3 for both origin and destination
      -- format them into an OD pairing table
      -- get all OD pairs from the distance table
      -- compare each table to each other
      --
      --
      -- If the distance table is completely empty we can do a straight route 3 for both
      -- origin and destination
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'OPENING CURSOR c_check_distance_table');
      END IF;

      OPEN c_check_distance_table;
         FETCH c_check_distance_table INTO l_distance_count;
      CLOSE c_check_distance_table;

      IF (l_distance_count = 0) THEN
         --
         -- the table is empty - go route 3
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'No distance records exist - go route 3');
         END IF;
         l_origin_route := 3;
         l_destination_route := 3;
      END IF;
   END IF;


   IF (l_origin_route = 1) THEN

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Origin Route = 1');
      END IF;
      IF (p_origin_id is null) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Origin id is null - RAISE FTE_DIST_NO_LOC_SPEC_R1');
         END IF;

         RAISE FTE_DIST_NO_LOC_SPEC_R1;
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
      -- The origin is a facility p_origin_id is a location
      -- get the region with the region type
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Opening cursor c_get_region_for_facility');
         WSH_DEBUG_SV.log(l_module_name,'PARAMETER p_origin_id = ',p_origin_id);
         WSH_DEBUG_SV.log(l_module_name,'PARAMETER p_region_type = ',p_region_type);
      END IF;

      OPEN c_get_region_for_facility(p_origin_id,
                                     p_region_type);
         FETCH c_get_region_for_facility BULK COLLECT INTO
             l_origin_location_id,
             l_origin_region_id;
      CLOSE c_get_region_for_facility;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_origin_location_id.COUNT = ',l_origin_location_id.COUNT);
         IF (l_origin_location_id.COUNT > 0) THEN
            FOR ggg IN l_origin_location_id.FIRST..l_origin_location_id.LAST LOOP
               WSH_DEBUG_SV.log(l_module_name,'l_origin_location_id(ggg) = ',l_origin_location_id(ggg));
               WSH_DEBUG_SV.log(l_module_name,'l_origin_region_id(ggg) = ',l_origin_region_id(ggg));
            END LOOP;
         END IF;
      END IF;


      IF (l_origin_location_id.COUNT = 0) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_origin_location_id.COUNT = 0 RAISE FTE_DIST_NO_LOC_REG_MAP');
         END IF;

         RAISE FTE_DIST_NO_LOC_REG_MAP;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

   ELSIF (l_origin_route = 2) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_origin_route = 2');
      END IF;
      --
      -- The origin is a region p_origin_id is a region
      -- get the region
      --
      IF (p_origin_id is null) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'p_origin_id is null - RAISE FTE_DIST_NO_REGION_SPEC_R2');
         END IF;

         RAISE FTE_DIST_NO_REGION_SPEC_R2;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

-- -------------------------------------------------------------------
-- New Code if the region is a parent of the profile level get the
-- children of the parent and go down until the regions of the profile
-- level are found
-- -------------------------------------------------------------------

      l_reg_ctr := 0;
      l_check_region_type := null;
      --
      -- Check that the region matches with the distance level
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_origin_id = ',p_origin_id);
         WSH_DEBUG_SV.log(l_module_name,'p_region_type = ',p_region_type);
      END IF;


      OPEN c_check_region_type(p_origin_id);
         FETCH c_check_region_type INTO l_check_region_type;
      CLOSE c_check_region_type;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'after c_check_region_type');
         WSH_DEBUG_SV.log(l_module_name,'l_check_region_type = ',l_check_region_type);
      END IF;


      IF (l_check_region_type is not null) THEN
         IF (l_check_region_type = p_region_type) THEN

            l_origin_location_id(1) := null;
            l_origin_region_id(1) := p_origin_id;

         ELSIF (l_check_region_type < p_region_type) THEN
            --
            -- The region passed in is a parent of the profile level
            -- get all sub levels that match the profile and check that
            -- there is at least one eligible facility
            --
            l_parent_regions_tab(1) := p_origin_id;
            l_parent_loop := 0;

            LOOP

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'IN FIRST LOOP');
               END IF;

               l_sub_regions_tab.DELETE;
               l_sub_region_type_tab.DELETE;

               IF (l_parent_regions_tab.COUNT > 0) THEN
                  l_parent_loop := l_parent_loop + 1;

                  FOR kkk IN l_parent_regions_tab.FIRST..l_parent_regions_tab.LAST LOOP

                     IF (l_parent_regions_tab.EXISTS(kkk)) THEN

                        OPEN c_get_sub_regions(l_parent_regions_tab(kkk));
                           FETCH c_get_sub_regions BULK COLLECT INTO
                              l_sub_regions_tab,
                              l_sub_region_type_tab;
                        CLOSE c_get_sub_regions;

                        -- l_reg_ctr := 0;
                        l_preg_ctr := 0;

                        IF (l_sub_regions_tab.COUNT > 0) THEN

                           FOR pppp IN l_sub_regions_tab.FIRST..l_sub_regions_tab.LAST LOOP
                              IF (l_sub_regions_tab.EXISTS(pppp)) THEN

                                 IF (l_sub_region_type_tab(pppp) = p_region_type) THEN
                                    --
                                    -- region types match put them in a table
                                    --
                                    l_reg_ctr := l_reg_ctr + 1;
                                    l_origin_location_id(l_sub_regions_tab(pppp)) := null;
                                    l_match_region_id(l_sub_regions_tab(pppp)) := l_sub_regions_tab(pppp);

                                 ELSIF (l_sub_region_type_tab(pppp) < p_region_type) THEN
                                    --
                                    -- These are still parents
                                    --
                                    l_preg_ctr := l_preg_ctr + 1;
                                    l_parent_sub_regions_tab(l_preg_ctr) := l_sub_regions_tab(pppp);

                                 END IF;
                              END IF;

                           END LOOP;

                        END IF;

                        l_cont_ctr := 0;

                        IF (l_parent_sub_regions_tab.COUNT > 0) THEN
                           FOR nnn IN l_parent_sub_regions_tab.FIRST..l_parent_sub_regions_tab.LAST LOOP
                              IF (l_parent_sub_regions_tab.EXISTS(nnn)) THEN
                                 l_cont_ctr := l_sub_par_cont_tab.COUNT + 1;
                                 l_sub_par_cont_tab(l_cont_ctr) := l_parent_sub_regions_tab(nnn);
                              END IF;
                           END LOOP;
                           l_parent_sub_regions_tab.DELETE;
                        -- ELSE
                        --
                        -- All matching sub regions for parent have been found
                        --
                        END IF;
                     END IF;
                  END LOOP;

                  --
                  -- Loop for parent (original region) has completed
                  -- we may have some more parents
                  --
                  IF (l_sub_par_cont_tab.COUNT = 0) THEN
                     EXIT;
                  ELSE
                     l_parent_regions_tab := l_sub_par_cont_tab;
                     l_sub_par_cont_tab.DELETE;
                  END IF;

               END IF;

            END LOOP;

            --
            -- now we have a complete table of sub regions that match the profile level
            --
            -- For each region we have to check that there are eligible facilities for
            -- those regions
            --
            l_orig_reg_ctr := 0;

            FOR uuuu IN l_match_region_id.FIRST..l_match_region_id.LAST LOOP
               l_match_flag := 'N';
               l_match_locations_tab.DELETE;

               IF (l_match_region_id.EXISTS(uuuu)) THEN

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_match_region_id(uuuu) = ',l_match_region_id(uuuu));
                  END IF;


                  OPEN c_check_matching_locs(l_match_region_id(uuuu));
                     FETCH c_check_matching_locs BULK COLLECT INTO
                        l_match_locations_tab;
                  CLOSE c_check_matching_locs;


                  IF (l_match_locations_tab.COUNT > 0) THEN

                     FOR vvvv IN l_match_locations_tab.FIRST..l_match_locations_tab.LAST LOOP
                        IF (l_match_locations_tab.EXISTS(vvvv)) THEN

                           OPEN c_check_mile_flag(l_match_locations_tab(vvvv));
                              FETCH c_check_mile_flag INTO
                                 l_match_flag;
                           CLOSE c_check_mile_flag;

                           IF ((l_match_flag is not null) AND
                               (l_match_flag = 'Y')) THEN
                              -- This region has an eligible location

                              l_orig_reg_ctr := l_orig_reg_ctr + 1;
                              l_origin_region_id(l_match_region_id(uuuu)) := l_match_region_id(uuuu);
                              l_origin_location_id(l_match_region_id(uuuu)) := null;

                           END IF;
                        END IF;
                     END LOOP;
                   -- ELSE
                   -- region has no facilities/locations
                   -- null;
                  END IF;
               END IF;
            END LOOP;

         ELSIF (l_check_region_type > p_region_type) THEN
            RAISE FTE_DIST_INV_REGION_LOW;
            RETURN;
        END IF;
     END IF;


     IF (l_origin_region_id.COUNT <= 0) THEN

        RAISE FTE_DIST_NO_MATCH_REGIONS_FND;
        RETURN;
     END IF;



     IF (l_origin_region_id.COUNT > 0) THEN
        l_ctr := 0;
        FOR ggg IN l_origin_region_id.FIRST..l_origin_region_id.LAST LOOP
           IF (l_origin_region_id.EXISTS(ggg)) THEN
              l_ctr := l_ctr + 1;
              l_tmp_orig_reg(l_ctr) := l_origin_region_id(ggg);
              l_tmp_orig_loc(l_ctr) := null;
           END IF;
        END LOOP;
        l_origin_region_id.DELETE;
        l_origin_location_id.DELETE;
        l_origin_region_id := l_tmp_orig_reg;
        l_origin_location_id := l_tmp_orig_loc;
        l_tmp_orig_reg.DELETE;
        l_tmp_orig_loc.DELETE;
      END IF;

-- ---------------------------------------------------------------------
-- End of new code
-- ---------------------------------------------------------------------



      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_origin_region_id.COUNT = ',l_origin_region_id.COUNT);
         IF (l_origin_region_id.COUNT > 0) THEN
            FOR ggg IN l_origin_region_id.FIRST..l_origin_region_id.LAST LOOP
               WSH_DEBUG_SV.log(l_module_name,'l_origin_location_id(ggg) = ',l_origin_location_id(ggg));
               WSH_DEBUG_SV.log(l_module_name,'l_origin_region_id(ggg) = ',l_origin_region_id(ggg));
            END LOOP;
         END IF;
      END IF;

   ELSIF ((l_origin_route = 3) OR
          (l_origin_route = 4)) THEN
      --
      -- The call is for all eligible facilities for origin
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_origin_route = 3');
         WSH_DEBUG_SV.logmsg(l_module_name,'Opening cursor c_get_all_elig_fac');
         WSH_DEBUG_SV.log(l_module_name,'PARAMETER g_y_flag = ',g_y_flag);
      END IF;

      OPEN c_get_all_elig_fac(g_y_flag);
         FETCH c_get_all_elig_fac BULK COLLECT INTO
            l_elig_locs_id_tab;
      CLOSE c_get_all_elig_fac;

      IF (l_elig_locs_id_tab.COUNT = 0) THEN
         --
         -- There are no eligible facilities
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'There are no eligible facilities RAISE  FTE_DIST_NO_ELIG_FACILI_R3');
         END IF;

         RAISE  FTE_DIST_NO_ELIG_FACILI_R3;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;



      FOR ppp IN l_elig_locs_id_tab.FIRST..l_elig_locs_id_tab.LAST LOOP
         --
         -- get the regions for the locations
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'There are eligible facilities - get the regions for the locations - Opening cursor c_get_region_for_facility');
            WSH_DEBUG_SV.log(l_module_name,'PARAMETERS l_elig_locs_id_tab(ppp) = ',l_elig_locs_id_tab(ppp));
            WSH_DEBUG_SV.log(l_module_name,'PARAMETERS p_region_type = ',p_region_type);
         END IF;


         OPEN c_get_region_for_facility(l_elig_locs_id_tab(ppp),
                                        p_region_type);
            FETCH c_get_region_for_facility BULK COLLECT INTO
               l_orig_location_id,
               l_orig_region_id;
         CLOSE c_get_region_for_facility;

           IF (l_orig_location_id.COUNT > 0) THEN
              FOR ioi IN l_orig_location_id.FIRST..l_orig_location_id.LAST LOOP
               l_cd := l_origin_location_id.COUNT + 1;
               l_origin_location_id(l_cd) := l_orig_location_id(ioi);
               l_origin_region_id(l_cd) := l_orig_region_id(ioi);
             END LOOP;
           END IF;
      END LOOP;

      IF (l_origin_location_id.COUNT = 0) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_origin_location_id.COUNT = 0 - RAISE FTE_DIST_NO_LOC_REG_MAP');
         END IF;

         RAISE FTE_DIST_NO_LOC_REG_MAP;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_origin_location_id.COUNT = ',l_origin_location_id.COUNT);
         IF (l_origin_location_id.COUNT > 0) THEN
            FOR ppp IN l_origin_location_id.FIRST..l_origin_location_id.LAST LOOP
               WSH_DEBUG_SV.log(l_module_name,'l_origin_location_id(ppp) = ',l_origin_location_id(ppp));
               WSH_DEBUG_SV.log(l_module_name,'l_origin_region_id(ppp) = ',l_origin_region_id(ppp));
            END LOOP;
         END IF;
      END IF;
   END IF;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Get the destination regions');
   END IF;
   --
   -- Get the destination regions
   --
   IF (l_destination_route = 1) THEN

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_destination_route = 1');
      END IF;

      IF (p_destination_id is null) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'p_destination_id is null - RAISE FTE_DIST_NO_LOC_SPEC_R1');
         END IF;

         RAISE FTE_DIST_NO_LOC_SPEC_R1;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;


      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'The destination is a facility p_destination_id is a location get the region with the region type');
         WSH_DEBUG_SV.logmsg(l_module_name,'OPENING cursor c_get_region_for_facility');
         WSH_DEBUG_SV.log(l_module_name,'PARAMETERS p_destination_id = ',p_destination_id);
         WSH_DEBUG_SV.log(l_module_name,'PARAMETERS p_region_type = ',p_region_type);
      END IF;

      --
      -- The destination is a facility p_destination_id is a location
      -- get the region with the region type
      --
      OPEN c_get_region_for_facility(p_destination_id,
                                     p_region_type);
         FETCH c_get_region_for_facility BULK COLLECT INTO
             l_destination_location_id,
             l_destination_region_id;
      CLOSE c_get_region_for_facility;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_destination_location_id.COUNT =',l_destination_location_id.COUNT);
         IF (l_destination_location_id.COUNT > 0) THEN
            FOR gggd IN l_destination_location_id.FIRST..l_destination_location_id.LAST LOOP
               WSH_DEBUG_SV.log(l_module_name,'l_destination_location_id(gggd) = ',l_destination_location_id(gggd));
               WSH_DEBUG_SV.log(l_module_name,'l_destination_region_id(gggd) = ',l_destination_region_id(gggd));
            END LOOP;
         END IF;
      END IF;


      IF (l_destination_location_id.COUNT = 0) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_destination_location_id.COUNT = 0 - RAISE FTE_DIST_NO_LOC_REG_MAP');
         END IF;

         RAISE FTE_DIST_NO_LOC_REG_MAP;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

   ELSIF (l_destination_route = 2) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_destination_route = 2');
      END IF;

      --
      -- The destination is a region p_destination_id is a region
      -- get the region
      --
      IF (p_destination_id is null) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'p_destination_id is null - RAISE FTE_DIST_NO_REGION_SPEC_R2');
         END IF;

         RAISE FTE_DIST_NO_REGION_SPEC_R2;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

-- -------------------------------------------------------------------
-- New Code if the region is a parent of the profile level get the
-- children of the parent and go down until the regions of the profile
-- level are found (Destination)
-- -------------------------------------------------------------------
      l_reg_ctr := 0;
      l_check_region_type := null;
      l_parent_regions_tab.DELETE;
      l_match_region_id.DELETE;
      l_sub_par_cont_tab.DELETE;
      l_match_locations_tab.DELETE;
      l_destination_region_id.DELETE;
      l_destination_location_id.DELETE;
      l_tmp_dest_reg.DELETE;
      l_tmp_dest_loc.DELETE;

      --
      -- Check that the region matches with the distance level
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_destination_id = ',p_destination_id);
         WSH_DEBUG_SV.log(l_module_name,'p_region_type = ',p_region_type);
      END IF;


      OPEN c_check_region_type(p_destination_id);
         FETCH c_check_region_type INTO l_check_region_type;
      CLOSE c_check_region_type;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'after c_check_region_type (destination)');
         WSH_DEBUG_SV.log(l_module_name,'l_check_region_type = ',l_check_region_type);
      END IF;


      IF (l_check_region_type is not null) THEN
         IF (l_check_region_type = p_region_type) THEN

            l_destination_location_id(1) := null;
            l_destination_region_id(1) := p_destination_id;

         ELSIF (l_check_region_type < p_region_type) THEN
            --
            -- The region passed in is a parent of the profile level
            -- get all sub levels that match the profile and check that
            -- there is at least one eligible facility
            --
            l_parent_regions_tab(1) := p_destination_id;
            l_parent_loop := 0;

            LOOP

               IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'IN FIRST LOOP');
               END IF;

               l_sub_regions_tab.DELETE;
               l_sub_region_type_tab.DELETE;

               IF (l_parent_regions_tab.COUNT > 0) THEN
                  l_parent_loop := l_parent_loop + 1;

                  FOR kkk IN l_parent_regions_tab.FIRST..l_parent_regions_tab.LAST LOOP

                     IF (l_parent_regions_tab.EXISTS(kkk)) THEN

                        OPEN c_get_sub_regions(l_parent_regions_tab(kkk));
                           FETCH c_get_sub_regions BULK COLLECT INTO
                              l_sub_regions_tab,
                              l_sub_region_type_tab;
                        CLOSE c_get_sub_regions;

                        -- l_reg_ctr := 0;
                        l_preg_ctr := 0;

                        IF (l_sub_regions_tab.COUNT > 0) THEN

                           FOR pppp IN l_sub_regions_tab.FIRST..l_sub_regions_tab.LAST LOOP
                              IF (l_sub_regions_tab.EXISTS(pppp)) THEN

                                 IF (l_sub_region_type_tab(pppp) = p_region_type) THEN
                                    --
                                    -- region types match put them in a table
                                    --
                                    l_reg_ctr := l_reg_ctr + 1;
                                    l_destination_location_id(l_sub_regions_tab(pppp)) := null;
                                    l_match_region_id(l_sub_regions_tab(pppp)) := l_sub_regions_tab(pppp);
                                 ELSIF (l_sub_region_type_tab(pppp) < p_region_type) THEN
                                    --
                                    -- These are still parents
                                    --
                                    l_preg_ctr := l_preg_ctr + 1;
                                    l_parent_sub_regions_tab(l_preg_ctr) := l_sub_regions_tab(pppp);

                                 END IF;
                              END IF;

                           END LOOP;

                        END IF;

                        l_cont_ctr := 0;

                        IF (l_parent_sub_regions_tab.COUNT > 0) THEN
                           FOR nnn IN l_parent_sub_regions_tab.FIRST..l_parent_sub_regions_tab.LAST LOOP
                              IF (l_parent_sub_regions_tab.EXISTS(nnn)) THEN
                                 l_cont_ctr := l_sub_par_cont_tab.COUNT + 1;
                                 l_sub_par_cont_tab(l_cont_ctr) := l_parent_sub_regions_tab(nnn);
                              END IF;
                           END LOOP;
                           l_parent_sub_regions_tab.DELETE;
                        -- ELSE
                        --
                        -- All matching sub regions for parent have been found
                        --
                        END IF;
                     END IF;
                  END LOOP;

                  --
                  -- Loop for parent (original region) has completed
                  -- we may have some more parents
                  --
                  IF (l_sub_par_cont_tab.COUNT = 0) THEN
                     EXIT;
                  ELSE
                     l_parent_regions_tab := l_sub_par_cont_tab;
                     l_sub_par_cont_tab.DELETE;
                  END IF;

               END IF;

            END LOOP;

            --
            -- now we have a complete table of sub regions that match the profile level
            --
            -- For each region we have to check that there are eligible facilities for
            -- those regions
            --

            FOR uuuu IN l_match_region_id.FIRST..l_match_region_id.LAST LOOP
               l_match_flag := 'N';
               l_match_locations_tab.DELETE;

               IF (l_match_region_id.EXISTS(uuuu)) THEN

                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_match_region_id(uuuu) = ',l_match_region_id(uuuu));
                  END IF;


                  OPEN c_check_matching_locs(l_match_region_id(uuuu));
                     FETCH c_check_matching_locs BULK COLLECT INTO
                        l_match_locations_tab;
                  CLOSE c_check_matching_locs;

                  IF (l_match_locations_tab.COUNT > 0) THEN

                     FOR vvvv IN l_match_locations_tab.FIRST..l_match_locations_tab.LAST LOOP
                        IF (l_match_locations_tab.EXISTS(vvvv)) THEN

                           OPEN c_check_mile_flag(l_match_locations_tab(vvvv));
                              FETCH c_check_mile_flag INTO
                                 l_match_flag;
                           CLOSE c_check_mile_flag;

                           IF ((l_match_flag is not null) AND
                               (l_match_flag = 'Y')) THEN
                              -- This region has an eligible location

                              l_destination_region_id(l_match_region_id(uuuu)) := l_match_region_id(uuuu);
                              l_destination_location_id(l_match_region_id(uuuu)) := null;

                           END IF;
                        END IF;
                     END LOOP;
                   -- ELSE
                   -- region has no facilities/locations
                   -- null;
                  END IF;
               END IF;
            END LOOP;

         ELSIF (l_check_region_type > p_region_type) THEN
            RAISE FTE_DIST_INV_REGION_LOW;
            RETURN;
        END IF;
     END IF;

     IF (l_destination_region_id.COUNT <= 0) THEN

        RAISE FTE_DIST_NO_MATCH_REGIONS_FND;
        RETURN;
     END IF;



     IF (l_destination_region_id.COUNT > 0) THEN
        l_ctr := 0;
        FOR ggg IN l_destination_region_id.FIRST..l_destination_region_id.LAST LOOP
           IF (l_destination_region_id.EXISTS(ggg)) THEN
              l_ctr := l_ctr + 1;
              l_tmp_dest_reg(l_ctr) := l_destination_region_id(ggg);
              l_tmp_dest_loc(l_ctr) := null;
           END IF;
        END LOOP;
        l_destination_region_id.DELETE;
        l_destination_location_id.DELETE;
        l_destination_region_id := l_tmp_dest_reg;
        l_destination_location_id := l_tmp_dest_loc;
        l_tmp_dest_reg.DELETE;
        l_tmp_dest_loc.DELETE;
      END IF;




--      l_destination_location_id(1) := null;
--      l_destination_region_id(1) := p_destination_id;
-- ---------------------------------------------------------------------
-- End of new code (Destination)
-- ---------------------------------------------------------------------


      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_destination_region_id.COUNT = ',l_destination_region_id.COUNT);
         IF (l_destination_region_id.COUNT > 0) THEN
            FOR gggdd IN l_destination_region_id.FIRST..l_destination_region_id.LAST LOOP
               WSH_DEBUG_SV.log(l_module_name,'l_destination_location_id(gggdd) = ',l_destination_location_id(gggdd));
               WSH_DEBUG_SV.log(l_module_name,'l_destination_region_id(gggdd) = ',l_destination_region_id(gggdd));
            END LOOP;
         END IF;
      END IF;

   ELSIF ((l_destination_route = 3) OR
          (l_destination_route = 4)) THEN
      --
      -- The call is for all eligible facilities for destination
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_destination_route = 3 - The call is for all eligible facilities for destination');
         WSH_DEBUG_SV.logmsg(l_module_name,'Opening cursor c_get_all_elig_fac');
         WSH_DEBUG_SV.log(l_module_name,'PARAMETERS g_y_flag = ',g_y_flag);
      END IF;

      OPEN c_get_all_elig_fac(g_y_flag);
         FETCH c_get_all_elig_fac BULK COLLECT INTO
              l_elig_locs_id_tab;
      CLOSE c_get_all_elig_fac;

      IF (l_elig_locs_id_tab.COUNT = 0) THEN
         --
         -- There are no eligible facilities
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'There are no eligible facilities - RAISE  FTE_DIST_NO_ELIG_FACILI_R3');
         END IF;

         RAISE  FTE_DIST_NO_ELIG_FACILI_R3;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

      FOR qqq IN l_elig_locs_id_tab.FIRST..l_elig_locs_id_tab.LAST LOOP
         --
         -- get the regions for the locations
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Opening cursor c_get_region_for_facility');
            WSH_DEBUG_SV.log(l_module_name,'PARAMETERS l_elig_locs_id_tab(qqq) = ',l_elig_locs_id_tab(qqq));
            WSH_DEBUG_SV.log(l_module_name,'PARAMETERS p_region_type = ',p_region_type);
         END IF;

         OPEN c_get_region_for_facility(l_elig_locs_id_tab(qqq),
                                        p_region_type);
            FETCH c_get_region_for_facility BULK COLLECT INTO
               l_dest_location_id,
               l_dest_region_id;
         CLOSE c_get_region_for_facility;

         IF (l_dest_location_id.COUNT > 0) THEN
              FOR ioi IN l_dest_location_id.FIRST..l_dest_location_id.LAST LOOP
               l_cd := l_destination_location_id.COUNT + 1;
               l_destination_location_id(l_cd) := l_dest_location_id(ioi);
               l_destination_region_id(l_cd) := l_dest_region_id(ioi);
             END LOOP;
           END IF;

      END LOOP;

      IF (l_destination_location_id.COUNT = 0) THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'l_destination_location_id.COUNT = 0 - RAISE FTE_DIST_NO_LOC_REG_MAP');
         END IF;

         RAISE FTE_DIST_NO_LOC_REG_MAP;
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         RETURN;
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_destination_location_id.COUNT =',l_destination_location_id.COUNT);
         IF (l_destination_location_id.COUNT > 0) THEN
            FOR pppddd IN l_destination_location_id.FIRST..l_destination_location_id.LAST LOOP
               WSH_DEBUG_SV.log(l_module_name,'l_destination_location_id(pppddd) = ',l_destination_location_id(pppddd));
               WSH_DEBUG_SV.log(l_module_name,'l_destination_region_id(pppddd) = ',l_destination_region_id(pppddd));
            END LOOP;
         END IF;
      END IF;
   END IF;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Now we have tables of origin and destination regions we need to get the attributes of each region');
      WSH_DEBUG_SV.logmsg(l_module_name,'Opening cursor c_get_region_values');
   END IF;

   --
   -- Now we have tables of origin and destination regions
   -- we need to get the attributes of each region
   --
   FOR kkkk IN l_origin_region_id.FIRST..l_origin_region_id.LAST LOOP

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'PARAMETERS l_origin_region_id(kkkk) = ',l_origin_region_id(kkkk));
         -- [BUG:3487060] WSH_DEBUG_SV.log(l_module_name,'PARAMETERS l_language = ',l_language);
      END IF;

-- [BUG:3487060] Remove Language from the query parameters

      OPEN c_get_region_values(l_origin_region_id(kkkk));      -- l_language);
         FETCH c_get_region_values BULK COLLECT INTO
            l_reg_region_id_tab,
            l_reg_postal_code_from_tab,
            l_reg_city_tab,
            l_reg_state_tab,
            l_reg_county_tab,
            l_reg_country_tab;
       CLOSE c_get_region_values;


       --
       -- [ABLUNDEL][03/05/2004][BUG:3487060]
       -- Need to check that region values exist for the translated values
       -- in WSH_REGIONS_V - if not we log a bug
       --
       IF (l_reg_region_id_tab.COUNT = 0) THEN
          --
          -- There are no region values from WSH_REGIONS_V for the region id and the language
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'c_get_region_values - There are no region values from WSH_REGIONS_V for the region id and the language');
             WSH_DEBUG_SV.log(l_module_name,'l_origin region_id(kkkk)',l_origin_region_id(kkkk));
             WSH_DEBUG_SV.log(l_module_name,'l_language',l_language);
          END IF;

          RAISE FTE_DIST_NO_ORIG_REG_VALS;
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
       -- We also need to get the state and country codes - the mileage engine
       -- uses these
       --
       l_reg_code_region_id_tab.DELETE;
       l_reg_code_state_tab.DELETE;
       l_reg_code_country_tab.DELETE;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Opening cursor c_get_region_codes');
         WSH_DEBUG_SV.log(l_module_name,'PARAMETERS l_origin_region_id(kkkk) = ',l_origin_region_id(kkkk));
       END IF;

       OPEN c_get_region_codes(l_origin_region_id(kkkk));
          FETCH c_get_region_codes BULK COLLECT INTO
            l_reg_code_region_id_tab,
            l_reg_code_state_tab,
            l_reg_code_country_tab;
       CLOSE c_get_region_codes;
--    END LOOP;


    IF (l_reg_code_region_id_tab.COUNT > 0) THEN
       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Index the codes');
       END IF;
       --
       -- Index the codes
       --
       FOR sss IN l_reg_code_region_id_tab.FIRST..l_reg_code_region_id_tab.LAST LOOP
          l_code_idx := l_reg_code_region_id_tab(sss);
          l_reg_code_table(l_code_idx).region_id := l_reg_code_region_id_tab(sss);
          l_reg_code_table(l_code_idx).state_code := l_reg_code_state_tab(sss);
          l_reg_code_table(l_code_idx).country_code := l_reg_code_country_tab(sss);
       END LOOP;
    END IF;





    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Put them in an indexed table');
    END IF;
    --
    -- Put them in an indexed table
    --
    FOR www IN l_reg_region_id_tab.FIRST..l_reg_region_id_tab.LAST LOOP
       l_idx := l_reg_region_id_tab(www);
       l_reg_table(l_idx).region_id := l_reg_region_id_tab(www);
       l_reg_table(l_idx).postal_code := l_reg_postal_code_from_tab(www);
       l_reg_table(l_idx).city := l_reg_city_tab(www);
       l_reg_table(l_idx).state := nvl(l_reg_code_table(l_reg_region_id_tab(www)).state_code,l_reg_state_tab(www));
       l_reg_table(l_idx).county := l_reg_county_tab(www);
       l_reg_table(l_idx).country := nvl(l_reg_code_table(l_reg_region_id_tab(www)).country_code,l_reg_country_tab(www));
    END LOOP;

END LOOP;




   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Now do the same for the destination regions');
      WSH_DEBUG_SV.logmsg(l_module_name,'Opening cursor c_get_region_values');
   END IF;
   --
   -- Now do the same for the destination regions
   --
   FOR llll IN l_destination_region_id.FIRST..l_destination_region_id.LAST LOOP

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'PARAMETER l_destination_region_id(llll) = ',l_destination_region_id(llll));
         WSH_DEBUG_SV.log(l_module_name,'l_language = ',l_language);
      END IF;

      OPEN c_get_region_values(l_destination_region_id(llll)); -- l_language);
         FETCH c_get_region_values BULK COLLECT INTO
            l_reg_region_id_tab,
            l_reg_postal_code_from_tab,
            l_reg_city_tab,
            l_reg_state_tab,
            l_reg_county_tab,
            l_reg_country_tab;
       CLOSE c_get_region_values;

       --
       -- [ABLUNDEL][03/05/2004][BUG:3487060]
       -- Need to check that region values exist for the translated values
       -- in WSH_REGIONS_V - if not we log a bug
       --
       IF (l_reg_region_id_tab.COUNT = 0) THEN
          --
          -- There are no region values from WSH_REGIONS_V for the region id and the language
          --
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'c_get_region_values - There are no region values from WSH_REGIONS_V for the region id and the language');
             WSH_DEBUG_SV.log(l_module_name,'l_destination_region_id(llll)',l_destination_region_id(llll));
             WSH_DEBUG_SV.log(l_module_name,'l_language',l_language);
          END IF;

          RAISE FTE_DIST_NO_DEST_REG_VALS;
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
       -- We also need to get the state and country codes - the mileage engine
       -- uses these
       --
       l_reg_code_region_id_tab.DELETE;
       l_reg_code_state_tab.DELETE;
       l_reg_code_country_tab.DELETE;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Opening cursor c_get_region_codes');
          WSH_DEBUG_SV.log(l_module_name,'PARAMETER l_destination_region_id(llll) = ',l_destination_region_id(llll));
       END IF;

       OPEN c_get_region_codes(l_destination_region_id(llll));
          FETCH c_get_region_codes BULK COLLECT INTO
            l_reg_code_region_id_tab,
            l_reg_code_state_tab,
            l_reg_code_country_tab;
       CLOSE c_get_region_codes;
       -- END LOOP;


       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Index the codes');
       END IF;
       --
       -- Index the codes
       --
       FOR rrr IN l_reg_code_region_id_tab.FIRST..l_reg_code_region_id_tab.LAST LOOP
          l_code_idx := l_reg_code_region_id_tab(rrr);
          l_reg_code_table(l_code_idx).region_id := l_reg_code_region_id_tab(rrr);
          l_reg_code_table(l_code_idx).state_code := l_reg_code_state_tab(rrr);
          l_reg_code_table(l_code_idx).country_code := l_reg_code_country_tab(rrr);
       END LOOP;

       IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Put them in an indexed table');
       END IF;
       --
       -- Put them in an indexed table
       --
       FOR xxx IN l_reg_region_id_tab.FIRST..l_reg_region_id_tab.LAST LOOP
          l_idx := l_reg_region_id_tab(xxx);
          l_reg_table(l_idx).region_id := l_reg_region_id_tab(xxx);
          l_reg_table(l_idx).postal_code := l_reg_postal_code_from_tab(xxx);
          l_reg_table(l_idx).city := l_reg_city_tab(xxx);
          l_reg_table(l_idx).state := nvl(l_reg_code_table(l_reg_region_id_tab(xxx)).state_code,l_reg_state_tab(xxx));
          l_reg_table(l_idx).county := l_reg_county_tab(xxx);
          l_reg_table(l_idx).country := nvl(l_reg_code_table(l_reg_region_id_tab(xxx)).country_code,l_reg_country_tab(xxx));
      END LOOP;
   END LOOP;


   --
   -- Now we have a complete table of regions and their values
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Now we have a complete table of regions and their values');
      WSH_DEBUG_SV.log(l_module_name,'l_reg_table.COUNT = ',l_reg_table.COUNT);
      IF (l_reg_table.COUNT > 0) THEN
         FOR bbb IN l_reg_table.FIRST..l_reg_table.LAST LOOP
            IF (l_reg_table.EXISTS(bbb)) THEN
               WSH_DEBUG_SV.log(l_module_name,'(bbb) = '||bbb);
               WSH_DEBUG_SV.log(l_module_name,'l_reg_table(bbb).region_id = '||l_reg_table(bbb).region_id);
               WSH_DEBUG_SV.log(l_module_name,'l_reg_table(bbb).postal_code = '||l_reg_table(bbb).postal_code);
               WSH_DEBUG_SV.log(l_module_name,'l_reg_table(bbb).city = '||l_reg_table(bbb).city);
               WSH_DEBUG_SV.log(l_module_name,'l_reg_table(bbb).state = '||l_reg_table(bbb).state);
               WSH_DEBUG_SV.log(l_module_name,'l_reg_table(bbb).county = '||l_reg_table(bbb).county);
               WSH_DEBUG_SV.log(l_module_name,'l_reg_table(bbb).country = '||l_reg_table(bbb).country);
            END IF;
         END LOOP;
      END IF;
   END IF;



   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Now we need to format the Origin and destination pairs into a OD table');
   END IF;

   -- the l_origin_region_id and l_destination_region_id has all regions for all the locations
   -- as many locations can point to the same region this means that we have to denormalize
   -- the list
   FOR mmm IN l_origin_region_id.FIRST..l_origin_region_id.LAST LOOP
      l_orig_denorm_id(l_origin_region_id(mmm)) := l_origin_region_id(mmm);
   END LOOP;

   l_origin_region_id.DELETE;
   l_ctr := 0;
   FOR nnno IN l_orig_denorm_id.FIRST..l_orig_denorm_id.LAST LOOP
      IF (l_orig_denorm_id.EXISTS(nnno)) THEN
         l_ctr := l_ctr + 1;
         l_origin_region_id(l_ctr) := l_orig_denorm_id(nnno);
      END IF;
   END LOOP;


   FOR nnn IN l_destination_region_id.FIRST..l_destination_region_id.LAST LOOP
      l_dest_denorm_id(l_destination_region_id(nnn)) := l_destination_region_id(nnn);
   END LOOP;

   l_destination_region_id.DELETE;
   l_ctr := 0;
   FOR nnnd IN l_dest_denorm_id.FIRST..l_dest_denorm_id.LAST LOOP
      IF (l_dest_denorm_id.EXISTS(nnnd)) THEN
         l_ctr := l_ctr + 1;
         l_destination_region_id(l_ctr) := l_dest_denorm_id(nnnd);
      END IF;
   END LOOP;


   --
   -- Now we need to format the Origin and destination pairs into a OD table
   --
   l_od_check_tab.DELETE;

   l_od_idx := 0;
   FOR mmm IN l_origin_region_id.FIRST..l_origin_region_id.LAST LOOP

      IF ((l_destination_route <> 3) OR (l_origin_route = 3)) THEN
         --
         -- add a check, we only want one record of each, eg with the same orig and dest we dont want
         -- A - A and
         -- A - A
         -- we only want
         -- A - A

         IF (l_od_check_tab.EXISTS(l_origin_region_id(mmm)||l_origin_region_id(mmm)) = FALSE) THEN
            l_od_idx := l_od_idx + 1;
            -- put it in the table
            l_od_pair_tab(l_od_idx).origin_id := l_origin_region_id(mmm);
            l_od_pair_tab(l_od_idx).destination_id := l_origin_region_id(mmm);

            --
            -- add it to the check table
            --
            l_od_check_tab(l_origin_region_id(mmm)||l_origin_region_id(mmm)) := l_origin_region_id(mmm)||l_origin_region_id(mmm);
         END IF;
      END IF;

      --
      -- Loop through the destinations for the origin
      --
      FOR nnn IN l_destination_region_id.FIRST..l_destination_region_id.LAST LOOP
         IF (l_origin_region_id(mmm) <> l_destination_region_id(nnn)) THEN
            IF (l_od_check_tab.EXISTS(l_origin_region_id(mmm)||l_destination_region_id(nnn)) = FALSE) THEN
               l_od_idx := l_od_idx + 1;
               -- put it in the table

               l_od_pair_tab(l_od_idx).origin_id := l_origin_region_id(mmm);
               l_od_pair_tab(l_od_idx).destination_id := l_destination_region_id(nnn);
               --
               -- add it to the check table
               --
               l_od_check_tab(l_origin_region_id(mmm)||l_destination_region_id(nnn)) := l_origin_region_id(mmm)||l_destination_region_id(nnn);
            END IF;
         END IF;
      END LOOP;
   END LOOP;

   IF ((l_origin_route <> 4) AND
       (l_destination_route <> 4)) THEN
      --
      -- Now loop the other way to get the dest - origins
      --
      FOR ooo IN l_destination_region_id.FIRST..l_destination_region_id.LAST LOOP

         IF (l_origin_route <> 3) THEN
            IF (l_od_check_tab.EXISTS(l_destination_region_id(ooo)||l_destination_region_id(ooo)) = FALSE) THEN
               l_od_idx := l_od_idx + 1;
               l_od_pair_tab(l_od_idx).origin_id := l_destination_region_id(ooo);
               l_od_pair_tab(l_od_idx).destination_id := l_destination_region_id(ooo);
               --
               -- add it to the check table
               --
               l_od_check_tab(l_destination_region_id(ooo)||l_destination_region_id(ooo)) := l_destination_region_id(ooo)||l_destination_region_id(ooo);
            END IF;
         END IF;

         IF (((l_origin_route <> 3) AND
              (l_destination_route <> 3)) OR
             ((l_origin_route < 3) AND
              (l_destination_route = 3)) OR
             ((l_origin_route = 3) AND
              (l_destination_route < 3))) THEN

            --
            -- Loop through the destinations for the origin
            --
            FOR yyy IN l_origin_region_id.FIRST..l_origin_region_id.LAST LOOP
               IF (l_destination_region_id(ooo) <> l_origin_region_id(yyy)) THEN
                  IF (l_od_check_tab.EXISTS(l_destination_region_id(ooo)||l_origin_region_id(yyy)) = FALSE) THEN
                     l_od_idx := l_od_idx + 1;
                     l_od_pair_tab(l_od_idx).origin_id := l_destination_region_id(ooo);
                     l_od_pair_tab(l_od_idx).destination_id := l_origin_region_id(yyy);
                     --
                     -- add it to the check table
                     --
                     l_od_check_tab(l_destination_region_id(ooo)||l_origin_region_id(yyy)) := l_destination_region_id(ooo)||l_origin_region_id(yyy);
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END LOOP;
   END IF;

   --
   -- now we have a complete OD pair region  ID table
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'now we have a complete OD pair region  ID table');
      WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab.COUNT = ',l_od_pair_tab.COUNT);
      IF (l_od_pair_tab.COUNT > 0) THEN
         FOR uuu IN l_od_pair_tab.FIRST..l_od_pair_tab.LAST LOOP
            WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab(uuu).origin_id = ',l_od_pair_tab(uuu).origin_id);
            WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab(uuu).destination_id = ',l_od_pair_tab(uuu).destination_id);
         END LOOP;
      END IF;
   END IF;



   IF ((l_origin_route = 4) OR
       (l_destination_route = 4)) THEN

      l_rmve_ctr := 0;
      l_remove_idx_tab.DELETE;
      l_distance_tab_origin_id_tab.DELETE;
      l_distance_tab_distance_id_tab.DELETE;
      --
      -- We have to compare the OD table with the distance table
      --
      IF (l_od_pair_tab.COUNT > 0) THEN

         OPEN c_get_distance_tab_pairs;
            FETCH c_get_distance_tab_pairs BULK COLLECT INTO
                l_distance_tab_origin_id_tab,
                l_distance_tab_distance_id_tab;
         CLOSE c_get_distance_tab_pairs;

         IF (l_distance_tab_origin_id_tab.COUNT > 0) THEN

            FOR eee IN l_od_pair_tab.FIRST..l_od_pair_tab.LAST LOOP
               IF (l_od_pair_tab.EXISTS(eee)) THEN
                  FOR qqq IN l_distance_tab_origin_id_tab.FIRST..l_distance_tab_origin_id_tab.LAST LOOP
                     IF ((l_od_pair_tab(eee).origin_id = l_distance_tab_origin_id_tab(qqq)) AND
                         (l_od_pair_tab(eee).destination_id = l_distance_tab_distance_id_tab(qqq))) THEN
                        l_rmve_ctr := l_rmve_ctr + 1;
                        --
                        -- The OD pair exists in the table we need to remove it from the table
                        --
                        l_remove_idx_tab(l_rmve_ctr) := eee;
                        EXIT;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      IF (l_remove_idx_tab.COUNT > 0) THEN
         --
         -- Records exist to be removed from the l_od_pair_tab table
         --
         FOR jjk IN l_remove_idx_tab.FIRST..l_remove_idx_tab.LAST LOOP
            l_od_pair_tab.DELETE(l_remove_idx_tab(jjk));
         END LOOP;
      END IF;
   END IF;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'populate the FTE_MILE_DOWNLOAD_FILES table NB: download date is null as it has not completed yet');
   END IF;

   --
   -- populate the FTE_MILE_DOWNLOAD_FILES table
   -- NB: download date is null as it has not completed yet.
   --
   insert into fte_mile_download_files(DOWNLOAD_FILE_ID,
                                       FILE_NAME,
                                       DOWNLOAD_FILE_EXTENSION,
                                       TEMPLATE_ID,
                                       DOWNLOAD_DATE,
                                       UPLOAD_ID,
                                       UPLOAD_DATE,
                                       IDENTIFIER_TYPE,
                                       CREATION_DATE,
                                       CREATED_BY,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATED_BY,
                                       LAST_UPDATE_LOGIN,
                                       PROGRAM_APPLICATION_ID,
                                       PROGRAM_ID,
                                       PROGRAM_UPDATE_DATE,
                                       REQUEST_ID)
                                values(FTE_MILE_DOWNLOAD_FILES_S.NEXTVAL,
                                       substr(p_file_name,1,8),
                                       p_file_extension,
                                       p_template_id,
                                       null,
                                       null,
                                       null,
                                       p_distance_profile,
                                       sysdate,
                                       fnd_global.user_id,
                                       sysdate,
                                       fnd_global.user_id,
                                       fnd_global.login_id,
                                       null,
                                       null,
                                       null,
                                       null)
                             RETURNING DOWNLOAD_FILE_ID INTO l_download_file_id;


   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_download_file_id = ',l_download_file_id);
      WSH_DEBUG_SV.logmsg(l_module_name,'Format the values to the file lines');
   END IF;


   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab.COUNT = ',l_od_pair_tab.COUNT);
   END IF;

   IF (l_od_pair_tab.COUNT = 0) THEN
      --
      -- There are no OD pairs to upload
      -- we need to return as success but with a message
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_od_pair_tab.COUNT = 0 - RAISE FTE_DIST_NO_OD_PAIRS');
      END IF;

      RAISE FTE_DIST_NO_OD_PAIRS;
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
   -- Format the values to the file lines
   --
   FOR axe IN l_od_pair_tab.FIRST..l_od_pair_tab.LAST LOOP
      IF (l_od_pair_tab.EXISTS(axe)) THEN
         l_origin_reg_id := l_od_pair_tab(axe).origin_id;
         l_dest_reg_id   := l_od_pair_tab(axe).destination_id;


         l_origin_attr_string := null;
         l_dest_attr_string := null;

         FOR vvv in l_attr_tab.FIRST..l_attr_tab.LAST LOOP

            l_orig_attr_found := 'N';
            l_dest_attr_found := 'N';

            IF (l_attr_tab(vvv).code =  g_postal_code_name) THEN
               IF (l_reg_table(l_origin_reg_id).postal_code is not null) THEN
                  l_origin_attr_string := l_origin_attr_string||l_reg_table(l_origin_reg_id).postal_code;
                  l_origin_attr_value := l_reg_table(l_origin_reg_id).postal_code;
                  l_orig_attr_found := 'Y';
               END IF;
               IF (l_reg_table(l_dest_reg_id).postal_code is not null) THEN
                  l_dest_attr_string   := l_dest_attr_string||l_reg_table(l_dest_reg_id).postal_code;
                  l_dest_attr_value    := l_reg_table(l_dest_reg_id).postal_code;
                  l_dest_attr_found := 'Y';
               END IF;

            ELSIF (l_attr_tab(vvv).code = g_city_code_name) THEN
               IF (l_reg_table(l_origin_reg_id).city is not null) THEN
                  l_origin_attr_string := l_origin_attr_string||l_reg_table(l_origin_reg_id).city;
                  l_origin_attr_value := l_reg_table(l_origin_reg_id).city;
                  l_orig_attr_found := 'Y';
               END IF;
               IF (l_reg_table(l_dest_reg_id).city is not null) THEN
                  l_dest_attr_string   := l_dest_attr_string||l_reg_table(l_dest_reg_id).city;
                  l_dest_attr_value    := l_reg_table(l_dest_reg_id).city;
                  l_dest_attr_found := 'Y';
               END IF;
            ELSIF (l_attr_tab(vvv).code = g_state_code_name) THEN
               IF (l_reg_table(l_origin_reg_id).state is not null) THEN
                  l_origin_attr_string := l_origin_attr_string||l_reg_table(l_origin_reg_id).state;
                  l_origin_attr_value := l_reg_table(l_origin_reg_id).state;
                  l_orig_attr_found := 'Y';
               END IF;
               IF (l_reg_table(l_dest_reg_id).state is not null) THEN
                  l_dest_attr_string   := l_dest_attr_string||l_reg_table(l_dest_reg_id).state;
                  l_dest_attr_value  := l_reg_table(l_dest_reg_id).state;
                  l_dest_attr_found := 'Y';
               END IF;
            ELSIF (l_attr_tab(vvv).code = g_county_code_name) THEN
               IF (l_reg_table(l_origin_reg_id).county is not null) THEN
                  l_origin_attr_string := l_origin_attr_string||l_reg_table(l_origin_reg_id).county;
                  l_origin_attr_value := l_reg_table(l_origin_reg_id).county;
                  l_orig_attr_found := 'Y';
               END IF;
               IF (l_reg_table(l_dest_reg_id).county is not null) THEN
                  l_dest_attr_string   := l_dest_attr_string||l_reg_table(l_dest_reg_id).county;
                  l_dest_attr_value  := l_reg_table(l_dest_reg_id).county;
                  l_dest_attr_found := 'Y';
               END IF;
            ELSIF (l_attr_tab(vvv).code = g_country_code_name) THEN
               IF (l_reg_table(l_origin_reg_id).country is not null) THEN
                  l_origin_attr_string := l_origin_attr_string||l_reg_table(l_origin_reg_id).country;
                  l_origin_attr_value := l_reg_table(l_origin_reg_id).country;
                  l_orig_attr_found := 'Y';
               END IF;
               IF (l_reg_table(l_dest_reg_id).country is not null) THEN
                  l_dest_attr_string   := l_dest_attr_string||l_reg_table(l_dest_reg_id).country;
                  l_dest_attr_value  := l_reg_table(l_dest_reg_id).country;
                  l_dest_attr_found := 'Y';
               END IF;
            END IF;

            IF (l_use_length = 'A') THEN
               IF (l_orig_attr_found = 'Y') THEN
                  FOR fff IN 1..(l_attr_tab(vvv).length - (LENGTH(l_origin_attr_value))) LOOP
                     l_spacer := l_spacer||' ';
                  END LOOP;
                  l_origin_attr_string := l_origin_attr_string||l_spacer;
                  l_spacer := null;
                  l_origin_attr_value := null;
               ELSE
                  FOR fff IN 1..l_attr_tab(vvv).length LOOP
                     l_spacer := l_spacer||' ';
                  END LOOP;
                  l_origin_attr_string := l_origin_attr_string||l_spacer;
                  l_spacer := null;
                  l_origin_attr_value := null;
               END IF;

               IF (l_dest_attr_found = 'Y') THEN
                  FOR fff IN 1..(l_attr_tab(vvv).length - (LENGTH(l_dest_attr_value))) LOOP
                     l_spacer := l_spacer||' ';
                  END LOOP;
                  l_dest_attr_string := l_dest_attr_string||l_spacer;
                  l_spacer := null;
                  l_dest_attr_value := null;
               ELSE
                  FOR fff IN 1..l_attr_tab(vvv).length LOOP
                     l_spacer := l_spacer||' ';
                  END LOOP;
                  l_dest_attr_string := l_dest_attr_string||l_spacer;
                  l_spacer := null;
                  l_origin_attr_value := null;
               END IF;
            END IF;

            IF (l_attr_tab(vvv).delim is not null) THEN
               IF (l_orig_attr_found = 'Y') THEN
                  l_origin_attr_string := l_origin_attr_string||l_attr_tab(vvv).delim;
               ELSE
                  IF (l_use_length = 'A') THEN
                     l_origin_attr_string := l_origin_attr_string||' ';
                  END IF;
               END IF;
               IF (l_dest_attr_found = 'Y') THEN
                  l_dest_attr_string   := l_dest_attr_string||l_attr_tab(vvv).delim;
               ELSE
                  IF (l_use_length = 'A') THEN
                     l_dest_attr_string := l_dest_attr_string||' ';
                  END IF;
               END IF;
            END IF;

         END LOOP;
-- ************************************************* --


         FOR zzz in l_col_tab.FIRST..l_col_tab.LAST LOOP

            IF (l_col_tab(zzz).code = g_origin_col_name) THEN
               -- origin column
               --
               IF (l_use_length = 'C') THEN
                  l_str_length := LENGTH(l_origin_attr_string);
                  IF (l_str_length < l_col_tab(zzz).length) THEN
                     l_origin_attr_string := RPAD(l_origin_attr_string,l_col_tab(zzz).length,' ');
                  ELSIF (l_str_length > l_col_tab(zzz).length) THEN
                     l_origin_attr_string := substr(l_origin_attr_string,1,l_col_tab(zzz).length);
                  END IF;
               END IF;
               IF (l_col_tab(zzz).seq = 1) THEN
                  -- This is the first column, check the start pos
                  --
                  IF (l_col_tab(zzz).start_pos > 1) THEN
                     FOR fff IN 1..(l_col_tab(zzz).start_pos - 1) LOOP
                        l_spacer := l_spacer||' ';
                    END LOOP;
                    l_origin_attr_string := l_spacer||l_origin_attr_string;
                    l_spacer := null;
                  END IF;
               END IF;
               IF (l_col_tab(zzz).delim is not null) THEN
                  l_origin_attr_string := l_origin_attr_string||l_col_tab(zzz).delim;
               END IF;

            ELSIF (l_col_tab(zzz).code = g_dest_col_name) THEN
               -- destination column
               --
               IF (l_use_length = 'C') THEN
                  l_str_length := LENGTH(l_dest_attr_string);
                  IF (l_str_length < l_col_tab(zzz).length) THEN
                     l_dest_attr_string := RPAD(l_dest_attr_string,l_col_tab(zzz).length,' ');
                  ELSIF (l_str_length > l_col_tab(zzz).length) THEN
                     l_dest_attr_string := substr(l_dest_attr_string,1,l_col_tab(zzz).length);
                  END IF;
               END IF;
               IF (l_col_tab(zzz).seq = 1) THEN
                  -- This is the first column, check the start pos
                  --
                  IF (l_col_tab(zzz).start_pos > 1) THEN
                     FOR fff IN 1..(l_col_tab(zzz).start_pos - 1) LOOP
                        l_spacer := l_spacer||' ';
                    END LOOP;
                    l_dest_attr_string := l_spacer||l_dest_attr_string;
                    l_spacer := null;
                  END IF;
               END IF;
               IF (l_col_tab(zzz).delim is not null) THEN
                  l_dest_attr_string := l_dest_attr_string||l_col_tab(zzz).delim;
               END IF;
            ELSIF (l_col_tab(zzz).code = g_ret_dist_col_name) THEN
               -- return  distance
               --
               FOR bb IN 1..l_col_tab(zzz).length LOOP
                   l_ret_dist_string := l_ret_dist_string||' ';
               END LOOP;

               IF (l_col_tab(zzz).seq = 1) THEN
                  -- This is the first column, check the start pos
                  --
                  IF (l_col_tab(zzz).start_pos > 1) THEN
                     FOR fff IN 1..(l_col_tab(zzz).start_pos - 1) LOOP
                        l_spacer := l_spacer||' ';
                    END LOOP;
                    l_ret_dist_string := l_spacer||l_ret_dist_string;
                    l_spacer := null;

                  END IF;
               END IF;
               -- IF (l_col_tab(zzz).delim is not null) THEN
               --    l_ret_dist_string := l_ret_dist_string||l_col_tab(zzz).delim;
               -- END IF;
            ELSIF (l_col_tab(zzz).code = g_ret_time_col_name) THEN
               -- return time
               --
               FOR bb IN 1..l_col_tab(zzz).length LOOP
                   l_ret_time_string := l_ret_time_string||' ';
               END LOOP;

               IF (l_col_tab(zzz).seq = 1) THEN
                  -- This is the first column, check the start pos
                  --
                  IF (l_col_tab(zzz).start_pos > 1) THEN
                    FOR fff IN 1..(l_col_tab(zzz).start_pos - 1) LOOP
                        l_spacer := l_spacer||' ';
                    END LOOP;
                    l_ret_time_string := l_spacer||l_ret_time_string;
                    l_spacer := null;
                  END IF;
               END IF;
               -- IF (l_col_tab(zzz).delim is not null) THEN
               --    l_ret_dist_string := l_ret_dist_string||l_col_tab(zzz).delim;
               -- END IF;

            END IF;


            IF (l_col_tab(zzz).seq = 1) THEN

              IF (l_col_tab(zzz).code = g_origin_col_name) THEN
                 l_file_string := l_origin_attr_string;
              ELSIF (l_col_tab(zzz).code = g_dest_col_name) THEN
                 l_file_string := l_dest_attr_string;
              ELSIF (l_col_tab(zzz).code = g_ret_dist_col_name) THEN
                 l_file_string := l_ret_dist_string;
              ELSIF (l_col_tab(zzz).code = g_ret_time_col_name) THEN
                 l_file_string := l_ret_time_string;
              END IF;
            ELSIF (l_col_tab(zzz).seq > 1) THEN
              IF (l_col_tab(zzz).code = g_origin_col_name) THEN
                 IF (l_col_tab(zzz).start_pos = LENGTH(l_file_string) + 1) THEN
                    l_file_string := l_file_string||l_origin_attr_string;
                 ELSIF (l_col_tab(zzz).start_pos < LENGTH(l_file_string) + 1) THEN
                    l_col_tab(zzz).start_pos := LENGTH(l_file_string) + 1;
                    l_file_string := l_file_string||l_origin_attr_string;
                 ELSIF (l_col_tab(zzz).start_pos > LENGTH(l_file_string) + 1) THEN
                    FOR fff IN 1..((l_col_tab(zzz).start_pos - LENGTH(l_file_string)) - 1) LOOP
                        l_spacer := l_spacer||' ';
                    END LOOP;
                    l_file_string := l_file_string||l_spacer||l_origin_attr_string;
                    l_spacer := null;

                 ELSIF (l_col_tab(zzz).start_pos is null) THEN
                       -- must be using attribute lengths
                       l_file_string := l_file_string||l_origin_attr_string;

                 END IF;
              ELSIF (l_col_tab(zzz).code = g_dest_col_name) THEN
                 IF (l_col_tab(zzz).start_pos = LENGTH(l_file_string) + 1) THEN
                    l_file_string := l_file_string||l_dest_attr_string;
                 ELSIF (l_col_tab(zzz).start_pos < LENGTH(l_file_string) + 1) THEN
                    l_col_tab(zzz).start_pos := LENGTH(l_file_string) + 1;
                    l_file_string := l_file_string||l_dest_attr_string;
                 ELSIF (l_col_tab(zzz).start_pos > LENGTH(l_file_string) + 1) THEN
                    FOR fff IN 1..((l_col_tab(zzz).start_pos - LENGTH(l_file_string)) - 1) LOOP
                        l_spacer := l_spacer||' ';
                    END LOOP;
                    l_file_string := l_file_string||l_spacer||l_dest_attr_string;
                    l_spacer := null;

                 ELSIF (l_col_tab(zzz).start_pos is null) THEN
                       -- must be using attribute lengths
                       l_file_string := l_file_string||l_dest_attr_string;

                 END IF;

              --
              -- [2003/12/17][ABLUNDEL][BUG: 3325486]
              -- Commented out the code that creates the spaces in the line for
              -- return distance and return time. Now the download file only
              -- contains the origin and destination columns
              --

              ELSIF (l_col_tab(zzz).code = g_ret_dist_col_name) THEN
                 IF (l_col_tab(zzz).start_pos = LENGTH(l_file_string) + 1) THEN
                    -- [BUG: 3325486] l_file_string := l_file_string||l_ret_dist_string;
                    null; -- [BUG: 3325486]
                 ELSIF (l_col_tab(zzz).start_pos < LENGTH(l_file_string) + 1) THEN
                    l_col_tab(zzz).start_pos := LENGTH(l_file_string) + 1;
                    -- [BUG: 3325486] l_file_string := l_file_string||l_ret_dist_string;
                 ELSIF (l_col_tab(zzz).start_pos > LENGTH(l_file_string) + 1) THEN
                    FOR fff IN 1..((l_col_tab(zzz).start_pos - LENGTH(l_file_string)) - 1) LOOP
                        l_spacer := l_spacer||' ';
                    END LOOP;
                    -- [BUG: 3325486] l_file_string := l_file_string||l_spacer||l_ret_dist_string;
                    l_spacer := null;

                 ELSIF (l_col_tab(zzz).start_pos is null) THEN
                       -- must be using attribute lengths
                       -- [BUG: 3325486] l_file_string := l_file_string||l_ret_dist_string;
                       null; -- [BUG: 3325486]
                 END IF;
              ELSIF (l_col_tab(zzz).code = g_ret_time_col_name) THEN
                 IF (l_col_tab(zzz).start_pos = LENGTH(l_file_string) + 1) THEN
                    -- [BUG: 3325486] l_file_string := l_file_string||l_ret_time_string;
                    null; -- [BUG: 3325486]
                 ELSIF (l_col_tab(zzz).start_pos < LENGTH(l_file_string) + 1) THEN
                    l_col_tab(zzz).start_pos := LENGTH(l_file_string) + 1;
                    -- [BUG: 3325486] l_file_string := l_file_string||l_ret_time_string;
                 ELSIF (l_col_tab(zzz).start_pos > LENGTH(l_file_string) + 1) THEN
                    FOR fff IN 1..((l_col_tab(zzz).start_pos - LENGTH(l_file_string)) - 1) LOOP
                        l_spacer := l_spacer||' ';
                    END LOOP;
                    -- [BUG: 3325486] l_file_string := l_file_string||l_spacer||l_ret_time_string;
                    l_spacer := null;

                 ELSIF (l_col_tab(zzz).start_pos is null) THEN
                       -- must be using attribute lengths
                       -- [BUG: 3325486] l_file_string := l_file_string||l_ret_time_string;
                       null; -- [BUG: 3325486]
                 END IF;
              END IF;
           END IF;

        END LOOP;

        l_od_pair_tab(axe).origin_line      := l_origin_attr_string;
        l_od_pair_tab(axe).destination_line := l_dest_attr_string;
        l_od_pair_tab(axe).file_line := l_file_string;
        l_ret_dist_string := null;
        l_ret_time_string := null;

      END IF;

   END LOOP;


   IF l_debug_on THEN
      FOR axe1 IN l_od_pair_tab.FIRST..l_od_pair_tab.LAST LOOP
         IF (l_od_pair_tab.EXISTS(axe1)) THEN
            WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab(axe1).origin_id = ',l_od_pair_tab(axe1).origin_id);
            WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab(axe1).destination_id = ',l_od_pair_tab(axe1).destination_id);
            WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab(axe1).origin_line = ',l_od_pair_tab(axe1).origin_line);
            WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab(axe1).destination_line = ',l_od_pair_tab(axe1).destination_line);
            WSH_DEBUG_SV.log(l_module_name,'l_od_pair_tab(axe1).file_line = ',l_od_pair_tab(axe1).file_line);
         END IF;
      END LOOP;
   END IF;



   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'opening the target file with parameters l_target_file := utl_file.fopen(l_download_dir, p_file_name,W,8192');
   END IF;

   l_target_file := utl_file.fopen(l_download_dir, p_file_name, 'W',8192);


   --
   -- Now we create the file data
   --
   l_line_ctr := 0;
   FOR axe1 IN l_od_pair_tab.FIRST..l_od_pair_tab.LAST LOOP
      IF (l_od_pair_tab.EXISTS(axe1)) THEN

         utl_file.put_line(l_target_file,l_od_pair_tab(axe1).file_line);
         utl_file.fflush(l_target_file);

         l_line_ctr := l_line_ctr + 1;
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'insert into fte_mile_download_lines - line number = ',l_line_ctr);
         END IF;
         insert into fte_mile_download_lines(DOWNLOAD_FILE_ID,
                                             LINE_NUMBER,
                                             ORIGIN_ID,
                                             DESTINATION_ID,
                                             CREATION_DATE,
                                             CREATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_LOGIN,
                                             PROGRAM_APPLICATION_ID,
                                             PROGRAM_ID,
                                             PROGRAM_UPDATE_DATE,
                                             REQUEST_ID)
                                      values(l_download_file_id,
                                             l_line_ctr,
                                             l_od_pair_tab(axe1).origin_id,
                                             l_od_pair_tab(axe1).destination_id,
                                             sysdate,
                                             fnd_global.user_id,
                                             sysdate,
                                             fnd_global.user_id,
                                             fnd_global.login_id,
                                             null,
                                             null,
                                             null,
                                             null);


      END IF;
   END LOOP;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,' closing the file ');
   END IF;

   utl_file.fclose(l_target_file);


   --
   -- If we are here then all has gone well
   -- update the fte_mile_download_files table with the download date
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'If we are here then all has gone well update the fte_mile_download_files table with the download date');
   END IF;

   update fte_mile_download_files
   set download_date = sysdate
   where download_file_id = l_download_file_id;


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'set the return status to success and return back to the calling procedure');
   END IF;

   x_return_message := null;
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   RETURN;


EXCEPTION
   WHEN FTE_DIST_NO_ORIG_REG_VALS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_ORIG_REG_VALS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_NO_ORIG_REG_VALS RAISED');
         WSH_DEBUG_SV.log(l_module_name,'FTE_DIST_NO_ORIG_REG_VALS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_ORIG_REG_VALS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_DEST_REG_VALS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_DEST_REG_VALS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_NO_DEST_REG_VALS RAISED');
         WSH_DEBUG_SV.log(l_module_name,'FTE_DIST_NO_DEST_REG_VALS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_DEST_REG_VALS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN FTE_DIST_NO_COLS_FOR_TEMPLATE THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_COLS_FOR_TEMPLATE');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_NO_COLS_FOR_TEMPLATE RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_COLS_FOR_TEMPLATE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_COLS_FOR_TEMPLATE');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;




   WHEN FTE_DIST_NO_OD_COLS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_OD_COLS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);

      --
      -- close file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_NO_OD_COLS RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_OD_COLS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_OD_COLS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_RET_COLS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_RET_COLS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_NO_RET_COLS RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_RET_COLS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_RET_COLS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_RET_ATTRS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_RET_ATTRS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;


      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_NO_RET_ATTRS RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_RET_ATTRS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_RET_ATTRS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_OD_ATTRS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_OD_ATTRS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_NO_OD_ATTRS RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_OD_ATTRS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_OD_ATTRS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_INVALID_START_POS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INVALID_START_POS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;


      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_INVALID_START_POS');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_INVALID_START_POS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_INVALID_START_POS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_INVALID_COL_LENGTHS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INVALID_COL_LENGTHS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;


      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_INT_PKG.FTE_DIST_INVALID_COL_LENGTHS');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_INVALID_COL_LENGTHS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_INVALID_COL_LENGTHS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_LOC_REG_MAP THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_LOC_REG_MAP');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;
      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_LOC_REG_MAP');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_LOC_REG_MAP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_LOC_REG_MAP');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      --
      RETURN;


   WHEN FTE_DIST_NO_LOC_SPEC_R1 THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_LOC_SPEC_R1');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_LOC_SPEC_R1');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_LOC_SPEC_R1 exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_LOC_SPEC_R1');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_NO_REGION_SPEC_R2 THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_REGION_SPEC_R2');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_REGION_SPEC_R2');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_REGION_SPEC_R2 exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_REGION_SPEC_R2');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_NO_ELIG_FACILI_R3 THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_ELIG_FACILI_R3');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;


      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_ELIG_FACILI_R3');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_ELIG_FACILI_R3 exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_ELIG_FACILI_R3');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_NO_DWNLD_DIR THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_DWNLD_DIR');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_DWNLD_DIR RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_DWNLD_DIR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_DWNLD_DIR');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_COL_ZERO_START THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_COL_ZERO_START');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_COL_ZERO_START RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_COL_ZERO_START exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_COL_ZERO_START');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN utl_file.invalid_path THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INV_FILE_PATH');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.utl_file.invalid_path RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'utl_file.invalid_path exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:utl_file.invalid_path');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN utl_file.invalid_mode THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INV_FILE_MODE');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.utl_file.invalid_mode RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'utl_file.invalid_mode exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:utl_file.invalid_mode');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN utl_file.invalid_operation THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INV_FILE_OPERATION');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;


      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.utl_file.invalid_operation RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'utl_file.invalid_operation exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:utl_file.invalid_operation');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_NO_RET_LENGTH THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_RET_LENGTH');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_RET_LENGTH RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_RET_LENGTH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_RET_LENGTH');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_RET_ATTR THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_RET_ATTR');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;

      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_RET_ATTR RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_RET_ATTR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_RET_ATTR');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_RET_DIST_INV_LENGTH THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_RET_DIST_INV_LENGTH');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;
      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_RET_DIST_INV_LENGTH RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_RET_DIST_INV_LENGTH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_RET_DIST_INV_LENGTH');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN FTE_DIST_RET_DIST_INV_START THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_RET_DIST_INV_START');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;
      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_RET_DIST_INV_START RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_RET_DIST_INV_START exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_RET_DIST_INV_START');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_RET_TIME_INV_LENGTH THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_RET_TIME_INV_LENGTH');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;
      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_RET_TIME_INV_LENGTH RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_RET_TIME_INV_LENGTH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_RET_TIME_INV_LENGTH');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;




   WHEN FTE_DIST_RET_TIME_INV_START THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_RET_TIME_INV_START');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;
      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_RET_TIME_INV_START RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_RET_TIME_INV_START exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_RET_TIME_INV_START');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;


   WHEN FTE_DIST_NO_OD_PAIRS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_OD_PAIRS');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;
      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_OD_PAIRS RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_OD_PAIRS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_OD_PAIRS');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_NO_MATCH_REGIONS_FND THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_NO_MATCH_REGIONS_FND');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;
      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_NO_MATCH_REGIONS_FND RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_NO_MATCH_REGIONS_FND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_NO_MATCH_REGIONS_FND');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;

   WHEN FTE_DIST_INV_REGION_LOW THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_DIST_INV_REGION_LOW');
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_return_message := FND_MESSAGE.GET;
      WSH_UTIL_CORE.add_message(x_return_status);
      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;
      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'EXCEPTION FTE_DIST_DWNLD_PKG.FTE_DIST_INV_REGION_LOW RAISED');
         WSH_DEBUG_SV.logmsg(l_module_name,'FTE_DIST_INV_REGION_LOW exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FTE_DIST_INV_REGION_LOW');
         WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;



   WHEN OTHERS THEN
      l_error_text := SQLERRM;

      --
      -- Close the file
      --
      IF (utl_file.is_open(l_target_file)) THEN
         utl_file.fclose(l_target_file);
      END IF;


      --
      -- Close cursors
      --
      IF (c_get_distance_tab_pairs%ISOPEN) THEN
         CLOSE c_get_distance_tab_pairs;
      END IF;
      IF (c_get_region_codes%ISOPEN) THEN
         CLOSE c_get_region_codes;
      END IF;
      IF (c_get_region_values%ISOPEN) THEN
         CLOSE c_get_region_values;
      END IF;
      IF (c_check_distance_table%ISOPEN) THEN
         CLOSE c_check_distance_table;
      END IF;
      IF (c_get_all_elig_fac%ISOPEN) THEN
         CLOSE c_get_all_elig_fac;
      END IF;
      IF (c_get_region_for_facility%ISOPEN) THEN
         CLOSE c_get_region_for_facility;
      END IF;
      IF (c_get_template_columns%ISOPEN) THEN
         CLOSE c_get_template_columns;
      END IF;
      IF (c_get_col_attrs%ISOPEN) THEN
         CLOSE c_get_col_attrs;
      END IF;
      IF (c_get_col_attr%ISOPEN) THEN
         CLOSE c_get_col_attr;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILE IS ' ||l_error_text);
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_DIST_DWNLD_PKG.CREATE_DWNLD_FILE');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_return_message := l_error_text;

      RETURN;

END CREATE_DWNLD_FILE;

FUNCTION FIRST_TIME RETURN BOOLEAN IS

req_data      VARCHAR2(100) := NULL;

BEGIN

   req_data := FND_CONC_GLOBAL.request_data;

   IF (req_data IS NULL) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      Fnd_File.Put_Line(Fnd_File.Log, 'Unexpected Error in Procedure FIRST_TIME' || sqlerrm);


END FIRST_TIME;

END FTE_DIST_DWNLD_PKG;

/
