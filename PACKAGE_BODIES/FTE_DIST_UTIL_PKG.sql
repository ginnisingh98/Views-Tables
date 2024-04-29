--------------------------------------------------------
--  DDL for Package Body FTE_DIST_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_DIST_UTIL_PKG" AS
/* $Header: FTEDISXB.pls 115.1 2003/09/13 19:46:12 ablundel noship $ */
-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:        FTE_DIST_UTIL_PKG                                             --
-- TYPE:        PACKAGE BODY                                                  --
-- DESCRIPTION: Contains util procedures for mileage integration stuff        --
--                                                                            --
--                                                                            --
-- CHANGE CONTROL LOG                                                         --
--                                                                            --
-- DATE        VERSION  BY        BUG      DESCRIPTION                        --
-- ----------  -------  --------  -------  ---------------------------------- --
-- 2003/07/17  J        ABLUNDEL           Created.                           --
--                                                                            --
-- -------------------------------------------------------------------------- --

--
-- For debug
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_DIST_UTILM_PKG';


-- -------------------------------------------------------------------------- --
--                                                                            --
-- PRIVATE PROCEDURE DEFINITIONS                                              --
-- -----------------------------                                              --
-- Described in Procedure code below                                          --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
--                                                                            --
-- NAME:                DELETE_FILES_LINES                                    --
--                                                                            --
-- TYPE:                PROCEDURE                                             --
--                                                                            --
-- PARAMETERS (IN OUT): p_template_id                  IN  NUMBER             --
--                                                                            --
-- PARAMETERS (OUT):    x_return_message       OUT NOCOPY VARCHAR2            --
--                      x_return_status        OUT NOCOPY VARCHAR2            --
--                                                                            --
-- RETURN:              n/a                                                   --
--                                                                            --
-- DESCRIPTION:         This procedure deletes all files and lines for        --
--                      a template                                            --
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
PROCEDURE DELETE_FILES_LINES(p_template_id                  IN  NUMBER,
                             x_return_message               OUT NOCOPY VARCHAR2,
                             x_return_status                OUT NOCOPY VARCHAR2) IS


l_error_text VARCHAR2(2000);



cursor c_get_file_ids(cp_template_id NUMBER) IS
select download_file_id
from   fte_mile_download_files
where  template_id = cp_template_id;

l_file_ids             FTE_DIST_UTIL_PKG.fte_id_tmp_num_table;


--
-- Local Debug Variable Definitions
--
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_FILES_LINES';



BEGIN



   l_file_ids.DELETE;

   IF ((p_template_id = 0) OR
       (p_template_id is null)) THEN
      x_return_message := null;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      RETURN;
   END IF;

   --
   -- set the debug flag
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

   --
   IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
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
      WSH_DEBUG_SV.logmsg(l_module_name,'---------------------------------');
   END IF;

   --
   -- Set the return flags for the start of the procedure
   --
   x_return_message := null;
   x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


   IF (p_template_id is not null) THEN
      --
      -- get the download file ids
      --
      OPEN c_get_file_ids(p_template_id);
         FETCH c_get_file_ids BULK COLLECT INTO
             l_file_ids;
      CLOSE c_get_file_ids;

      IF (l_file_ids.COUNT > 0) THEN

         --
         -- Delete the lines
         --
         FORALL j in l_file_ids.FIRST..l_file_ids.LAST
            DELETE fte_mile_download_lines
            WHERE  download_file_id = l_file_ids(j);

         --
         -- Delete the files
         --
         FORALL j in l_file_ids.FIRST..l_file_ids.LAST
            DELETE fte_mile_download_files
            WHERE  download_file_id = l_file_ids(j);

         commit;
      END IF;
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
   -- Lets go home
   --
   RETURN;


EXCEPTION
   WHEN OTHERS THEN
      l_error_text := SQLERRM;

      --
      -- Close any open cursors
      --
      IF (c_get_file_ids%ISOPEN) THEN
         CLOSE c_get_file_ids;
      END IF;

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'THE UNEXPECTED ERROR FROM FTE_DIST_UTIL_PKG.DELETE_FILES_LINES IS ' ||L_ERROR_TEXT  );
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      WSH_UTIL_CORE.default_handler('FTE_DIST_UTIL_PKG.DELETE_FILES_LINES');
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



END DELETE_FILES_LINES;

FUNCTION GET_REGION_TYPE RETURN NUMBER IS

l_distance_lvl VARCHAR2(50);

BEGIN

   fnd_profile.get('FTE_DISTANCE_LVL', l_distance_lvl);

   IF (l_distance_lvl is null) THEN
      RETURN(NULL);
   ELSIF (l_distance_lvl = 'CITYSTATE') THEN
      RETURN(2);
   ELSIF (l_distance_lvl = 'ZIP') THEN
      RETURN(3);
   ELSIF (l_distance_lvl = 'COUNTY') THEN
      RETURN(4);
   ELSE
      RETURN(NULL);
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      return (null);

END GET_REGION_TYPE;



PROCEDURE GET_DIST_PROFILE (x_profile_value OUT NOCOPY VARCHAR2) IS

BEGIN

   fnd_profile.get('FTE_DISTANCE_LVL',x_profile_value);
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      x_profile_value := null;
      RETURN;

END GET_DIST_PROFILE;

END FTE_DIST_UTIL_PKG;

/
