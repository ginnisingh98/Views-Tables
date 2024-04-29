--------------------------------------------------------
--  DDL for Package Body WSH_TP_RELEASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TP_RELEASE_GRP" as
/* $Header: WSHTPGPB.pls 115.2 2003/10/24 19:22:47 wrudge noship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TP_RELEASE_GRP';



--
--  Procedure:   action
--  Parameters:
--               p_id_tab          list of ids to process, depending on action.
--                                   For actions 'RELEASE' and 'PURGE', list of group_id
--                                   identifies the trips in WSH_TRIPS_INTERFACE
--                                   with INTERFACE_ACTION_CODE = 'TP_RELEASE'
--                                   and their related records in other interface tables.
--               p_input_rec       input parameters:
--                                   action_code:
--                                     'RELEASE' - release the plan
--
--                                       if some groups fail, returns warning
--                                       if all fail, returns error
--                                     'PURGE'   - purge interface tables
--                                   commit_flag:
--                                     'Y' - commit each group
--                                     'N' - do not commit
--               p_output_rec_type output parameters:
--                                   placeholder for future
--               x_return_status   return status
--                                   FND_API.G_RET_STS_SUCCESS - success
--                                   'W' - warning (WSH_UTIL_CORE.G_RET_STS_WARNING)
--                                   FND_API.G_RET_STS_ERROR
--                                   FND_API.G_RET_STS_UNEXP_ERROR
--
--  Description:
--    Perform an action relating to TP integration, based on p_input_rec.action_code:
--                  Release Plan
--                  Purge Interface Tables
--
--
PROCEDURE action(
  p_id_tab                 IN            id_tab_type,
  p_input_rec              IN            input_rec_type,
  x_ouput_rec_type         OUT NOCOPY    output_rec_type,
  x_return_status          OUT NOCOPY    VARCHAR2)
IS
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'action';
  --
  l_debug_on BOOLEAN;
  --
BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'p_id_tab.COUNT', p_id_tab.COUNT);
    WSH_DEBUG_SV.log(l_module_name, 'p_input_rec.action_code', p_input_rec.action_code);
    WSH_DEBUG_SV.log(l_module_name, 'p_input_rec.commit_flag', p_input_rec.commit_flag);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  --
  --

  IF p_id_tab.COUNT > 0 THEN

    IF p_input_rec.action_code = G_ACTION_RELEASE THEN
      WSH_TP_RELEASE_INT.release_plan(
        p_group_ids     => p_id_tab,
        p_commit_flag   => p_input_rec.commit_flag,
        x_return_status => x_return_status);

    ELSIF p_input_rec.action_code = G_ACTION_PURGE THEN
      WSH_TP_RELEASE_INT.purge_interface_tables(
        p_group_ids     => p_id_tab,
        p_commit_flag   => p_input_rec.commit_flag,
        x_return_status => x_return_status);

    END IF;

  END IF;

  --
  --

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                      'WSH_TP_RELEASE_GRP.action',
                      l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END action;


END WSH_TP_RELEASE_GRP;

/
