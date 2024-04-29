--------------------------------------------------------
--  DDL for Package Body WSH_ASN_RECEIPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ASN_RECEIPT_PVT" as
/* $Header: WSHVASRB.pls 120.2 2005/10/26 02:00:40 rahujain noship $ */


G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ASN_RECEIPT_PVT';
LIMITED_PRECISION NUMBER := 5;

--{ --NNP-WV


-- Start of comments
-- API name : addWeightVolume
-- Type     : Public
-- Pre-reqs : None.
-- Function : To consolidate (aggregate) the volume and weight of a delivery and its corresponding
--            LPN id. This API is called whenever there is a change in quantiy,weight,volume due
--            to split in delivery and also reassignment of lines to new deliveries or an explicit
--            change in the weight or volume.It makes use of  two cache tables (a key-value pair) for
--            this consolidation(aggregate) purpose.
-- Parameters :
-- IN:
--              p_key                  IN          NUMBER
--                The key in key-value pair.
--              p_value                IN          NUMBER
--                The value in key-value pair.
-- IN OUT:
--              x_cachetbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--                The key-value table where the key value is <= ( 2^31 - 1 )
--              x_cacheExttbl          IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--                The key-value table where the key value is > ( 2^31 - 1 )
-- OUT:
--	        x_return_status           OUT NOCOPY  VARCHAR2
-- Cache Tables :
--              ----------------------------------------------------------------------
--              | Cache Table Name  |        Key          |      Value               |
--              ----------------------------------------------------------------------
--              |   x_cachetbl      | Delivery / LPN ID   | The difference in gross  |
--              |                   |                     | weight / net weight /    |
--              |                   |                     | volume to be updated for |
--              |                   |                     | the given key.           |
--              |   x_cacheExttbl   | Delivery / LPN ID   | The difference in gross  |
--              |                   |                     | weight / net weight /    |
--              |                   |                     | volume to be updated for |
--              |                   |                     | the given key.           |
--              -----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE addWeightVolume
            (
              p_key                  IN          NUMBER,
              p_value                IN          NUMBER,
              x_cachetbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
              x_cacheExttbl          IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
              x_return_status           OUT NOCOPY  VARCHAR2
            )
IS
--{
    --
    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    l_value number;
    --
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'addWeightVolume';
--
--}
BEGIN
--{
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_key',p_key);
        WSH_DEBUG_SV.log(l_module_name,'p_value',p_value);
    END IF;
    --
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_cacheTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
		    -- Searching the cache tables to find out, if they already have a entry
		    -- for the given key, if so get the corresponding value.
                    wsh_util_core.get_cached_value
                        (
                            p_cache_tbl         => x_cacheTbl,
                            p_cache_ext_tbl     => x_cacheExtTbl,
                            p_key               => p_key,
                            p_value             => l_value,
                            p_action            => 'GET',
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.log(l_module_name,'l_value',l_value);
                    END IF;
                    --
                    --
                    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                    THEN
                        l_value := 0;
                    END IF;
                    --
                    --
                    l_value := NVL(l_value,0) + NVL(p_value,0);
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_cacheTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.get_cached_value
                        (
                            p_cache_tbl         => x_cacheTbl,
                            p_cache_ext_tbl     => x_cacheExtTbl,
                            p_key               => p_key,
                            p_value             => l_value,
                            p_action            => 'PUT',
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_ASN_RECEIPT_PVT.addWeightVolume');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END addWeightVolume;



-- Start of comments
-- API name : processWeightVolume
-- Type     : Public
-- Pre-reqs : None.
-- Function : The basic job of this API is to take care of the changes in gross weight,net weight
--            and volume changes.This it does by making calls to the API WSH_ASN_RECEIPT_PVT.addWeightVolume
--            by giving the appropriate inputs each time.
-- Parameters :
-- IN:
--              p_delivery_lpn_id         IN          NUMBER
--                The delivery ID for which the change in volume/weight has occured.
--              p_diff_gross_weight       IN          NUMBER
--                The difference in gross weight that has happened for the input Delivery's lines.
--              p_diff_net_weight         IN          NUMBER
--                The difference in net weight that has happened for the input Delivery's lines.
--              p_diff_volume             IN          NUMBER
--		  The difference in volume that has happened for the input Delivery's lines .
-- IN OUT:
--              x_GWTcachetbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--                 The key-value cache table,which contains the gross weight details.
--		   The key's value is <= ( 2^31 - 1 ).
--              x_GWTcacheExttbl          IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--                 The key-value cache table,which contains the gross weight details.
--		   The key's value is > ( 2^31 - 1 ).
--              x_NWTcachetbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--                 The key-value cache table,which contains the net weight details.
--		   The key's value is <= ( 2^31 - 1 ).
--              x_NWTcacheExttbl          IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--                 The key-value cache table,which contains the net weight details.
--		   The key's value is > ( 2^31 - 1 ).
--              x_VOLcachetbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--                 The key-value cache table,which contains the volume details.
--		   The key's value is <= ( 2^31 - 1 ).
--              x_VOLcacheExttbl          IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--                 The key-value cache table,which contains the volume details.
--		   The key's value is > ( 2^31 - 1 ).
-- OUT:
--Cache Tables :
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |x_GWTcachetbl              | LPN ID/Delivery ID | Gross Weight       |
--              |x_GWTcacheExttbl           | LPN ID/Delivery ID | Gross Weight       |
--              -----------------------------------------------------------------------
--              |x_NWTcachetbl              | LPN ID/Delivery ID | Net Weight         |
--              |x_NWTcacheExttbl           | LPN ID/Delivery ID | Net Weight         |
--              -----------------------------------------------------------------------
--              |x_VOLcachetbl              | LPN ID/Delivery ID | Volume             |
--              |x_VOLcacheExttbl           | LPN ID/Delivery ID | Volume             |
--              -----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments




PROCEDURE processWeightVolume
            (
              p_delivery_lpn_id         IN          NUMBER,
              p_diff_gross_weight       IN          NUMBER,
              p_diff_net_weight         IN          NUMBER,
              p_diff_volume             IN          NUMBER,
              x_GWTcachetbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
              x_GWTcacheExttbl          IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
              x_NWTcachetbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
              x_NWTcacheExttbl          IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
              x_VOLcachetbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
              x_VOLcacheExttbl          IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
              x_return_status              OUT NOCOPY  VARCHAR2
            )
IS
--{
    --
    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'processWeightVolume';
--
--}
BEGIN
--{
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_lpn_id',p_delivery_lpn_id);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_gross_weight',p_diff_gross_weight);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_net_weight',p_diff_net_weight);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_volume',p_diff_volume);
    END IF;
    --
    IF p_delivery_lpn_id IS NOT NULL
    THEN
    --{
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.addWeightVolume-GWT',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --

		    --call for changes in gross weight.
                    WSH_ASN_RECEIPT_PVT.addWeightVolume
                        (
                            p_key               => p_delivery_lpn_id,
                            p_value             => p_diff_gross_weight,
                            x_cacheTbl         => x_GWTcacheTbl,
                            x_cacheExtTbl     => x_GWTcacheExtTbl,
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.addWeightVolume-NWT',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
		    --call for changes in net weight.
                    WSH_ASN_RECEIPT_PVT.addWeightVolume
                        (
                            p_key               => p_delivery_lpn_id,
                            p_value             => p_diff_net_weight,
                            x_cacheTbl         => x_NWTcacheTbl,
                            x_cacheExtTbl     => x_NWTcacheExtTbl,
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.addWeightVolume-VOL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
		    --call for changes in volume.
                    WSH_ASN_RECEIPT_PVT.addWeightVolume
                        (
                            p_key               => p_delivery_lpn_id,
                            p_value             => p_diff_volume,
                            x_cacheTbl         => x_VOLcacheTbl,
                            x_cacheExtTbl     => x_VOLcacheExtTbl,
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.api_post_call
                      (
                        p_return_status => l_return_status,
                        x_num_warnings  => l_num_warnings,
                        x_num_errors    => l_num_errors
                      );
                    --
                    --

    --}
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_ASN_RECEIPT_PVT.processWeightVolume');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END processWeightVolume;
--
--

-- Start of comments
-- API name :
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API is used to check for the existence of entry in the cache tables (i/p parameters)
--            for the given input key p_key.If a value is found in the key-value cache tables
--            for the given key, then the two OUT variables for this API(x_diff_net_weight and
--	      x_diff_volume ) are appropriatley updated with the new value.The two main cache
--	      tables are x_NWTcachetbl and x_VOLcachetbl.
-- Parameters :
-- IN:
--              p_key                     IN          NUMBER
--                The key based on which the  cache tables are searched for matching entries.
-- IN OUT:
--              x_NWTcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type
--                The key-value cache table having the net weight details for key values < (2^31 -1).
--              x_NWTcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type
--                The key-value cache table having the net weight details for key values > (2^31 -1).
--              x_VOLcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type
--                The key-value cache table having the volume weight details for key values < (2^31 -1).
--              x_VOLcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type
--                The key-value cache table having the volume weight details for key values > (2^31 -1).
-- OUT:
--	        x_return_status           OUT NOCOPY  VARCHAR2
-- Cache Tables:
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |x_NWTcachetbl              | LPN ID/Delivery ID | Net Weight         |
--              |x_NWTcacheExttbl           | LPN ID/Delivery ID | Net Weight         |
--              -----------------------------------------------------------------------
--              |x_VOLcachetbl              | LPN ID/Delivery ID | Volume             |
--              |x_VOLcacheExttbl           | LPN ID/Delivery ID | Volume             |
--              -----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE getNetWeightVolume
            (
              p_key                     IN          NUMBER,
              x_NWTcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_NWTcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_VOLcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_VOLcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_diff_net_weight         OUT NOCOPY  NUMBER,
              x_diff_volume             OUT NOCOPY  NUMBER,
              x_return_status           OUT NOCOPY  VARCHAR2
            )
IS
--{
    --
    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'getNetWeightVolume';
--
--}
BEGIN
--{
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_key',p_key);
    END IF;
    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_NWTcacheTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.get_cached_value
                        (
                            p_cache_tbl         => x_NWTcacheTbl,
                            p_cache_ext_tbl     => x_NWTcacheExtTbl,
                            p_key               => p_key,
                            p_value             => x_diff_net_weight,
                            p_action            => 'GET',
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.log(l_module_name,'x_diff_net_weight',x_diff_net_weight);
                    END IF;
                    --
                    --
                    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                    THEN
                        x_diff_net_weight := 0;
                    END IF;
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_VOLcacheTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    --
                    wsh_util_core.get_cached_value
                        (
                            p_cache_tbl         => x_VOLcacheTbl,
                            p_cache_ext_tbl     => x_VOLcacheExtTbl,
                            p_key               => p_key,
                            p_value             => x_diff_volume,
                            p_action            => 'GET',
                            x_return_status     => l_return_status
                        );
                    --
                    --
                    IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.log(l_module_name,'x_diff_volume',x_diff_volume);
                    END IF;
                    --
                    --
                    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
                    THEN
                        x_diff_volume := 0;
                    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_ASN_RECEIPT_PVT.getNetWeightVolume');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END getNetWeightVolume;
--
--


-- Start of comments
-- API name : updateDlvyWeightVolume
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API updates the given input deliverie's weight/volume
--            based on the other input parameter values.
-- Parameters :
-- IN:
--              p_deliveryId              IN          NUMBER
--		 The Delivery id for which the update in weight/volume has to be done.
--              p_diff_gross_weight       IN          NUMBER
--               The difference in gross weight, that has to be updated for the Delivery.
--              p_diff_net_weight         IN          NUMBER
--               The difference in net weight, that has to be updated for the Delivery.
--              p_diff_volume             IN          NUMBER
--               The difference in volume, that has to be updated for the Delivery.
-- IN OUT:
--
-- OUT:
--              x_return_status           OUT NOCOPY  VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE updateDlvyWeightVolume
            (
              p_deliveryId              IN          NUMBER,
              p_diff_gross_weight       IN          NUMBER,
              p_diff_net_weight         IN          NUMBER,
              p_diff_volume             IN          NUMBER,
              x_return_status           OUT NOCOPY  VARCHAR2
            )
IS
--{
    --
    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'updateDlvyWeightVolume';
--
--}
BEGIN
--{
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_deliveryId',p_deliveryId);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_gross_weight',p_diff_gross_weight);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_net_weight',p_diff_net_weight);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_volume',p_diff_volume);
    END IF;
    --
    UPDATE wsh_new_deliveries
    SET    gross_weight       = NVL(gross_weight,0) - NVL(p_diff_gross_weight,0),
           net_weight         = NVL(net_weight,0) - NVL(p_diff_net_weight,0),
           volume             = NVL(volume,0) - NVL(p_diff_volume,0),
           LAST_UPDATE_DATE   = SYSDATE,
           LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
    WHERE  delivery_id        = p_deliveryId;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.Del_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_WV_UTILS.Del_WV_Post_Process
      (
        p_delivery_id       => p_deliveryId,
        p_diff_gross_wt => NVL(-1 * p_diff_gross_weight,0),
        p_diff_net_wt   => NVL(-1 * p_diff_net_weight,0),
        p_diff_volume       => NVL(-1 * p_diff_volume,0),
        x_return_status     => l_return_status
      );
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_ASN_RECEIPT_PVT.updateDlvyWeightVolume');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END updateDlvyWeightVolume;
--
--



-- Start of comments
-- API name : updateLPNWeightVolume
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API is used to update any changes in weight/volume happening
--	      for an LPN.
-- Parameters :
-- IN:
--              p_LPNId                   IN          NUMBER
--		 The LPN id for which the update in weight/volume has to be done.
--              p_diff_gross_weight       IN          NUMBER
--               The difference in gross weight, that has to be updated for the LPN.
--              p_diff_net_weight         IN          NUMBER
--               The difference in net weight, that has to be updated for the LPN.
--              p_diff_volume             IN          NUMBER
--               The difference in volume, that has to be updated for the LPN.
-- IN OUT:
-- OUT:
--              x_return_status           OUT NOCOPY  VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE updateLPNWeightVolume
            (
              p_LPNId                   IN          NUMBER,
              p_diff_gross_weight       IN          NUMBER,
              p_diff_net_weight         IN          NUMBER,
              p_diff_volume             IN          NUMBER,
              x_return_status           OUT NOCOPY  VARCHAR2
            )
IS
--{
    --
    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'updateLPNWeightVolume';
--
--}
BEGIN
--{
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_LPNId',p_LPNId);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_gross_weight',p_diff_gross_weight);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_net_weight',p_diff_net_weight);
        WSH_DEBUG_SV.log(l_module_name,'p_diff_volume',p_diff_volume);
    END IF;
    --
    UPDATE wsh_delivery_details
    SET    gross_weight       = NVL(gross_weight,0) - NVL(p_diff_gross_weight,0),
           net_weight         = NVL(net_weight,0) - NVL(p_diff_net_weight,0),
           filled_volume      = NVL(filled_volume,0) - NVL(p_diff_volume,0),
           LAST_UPDATE_DATE   = SYSDATE,
           LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
    WHERE  delivery_detail_id = p_LPNId;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_WV_UTILS.DD_WV_Post_Process
      (
        p_delivery_detail_id  => p_LPNId,
        p_diff_gross_wt   => NVL(-1 * p_diff_gross_weight,0),
        p_diff_net_wt     => NVL(-1 * p_diff_net_weight,0),
        p_diff_fill_volume  => NVL(-1 * p_diff_volume,0),
        x_return_status       => l_return_status
      );
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_ASN_RECEIPT_PVT.updateLPNWeightVolume');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END updateLPNWeightVolume;
--
--

-- Start of comments
-- API name : updateWeightVolume
-- Type     : Public
-- Pre-reqs : None.
-- Function : The main job of this API is to to determine whether any change in values has happened
--             for the deliveries/LPN weight or volume. If there is some change then it takes care of
--             updating the same.
-- Parameters :
-- IN:
--              p_entity                  IN          VARCHAR2
-- IN OUT:
--              x_GWTcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
--              x_GWTcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
--              x_NWTcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
--              x_NWTcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
--              x_VOLcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
--              x_VOLcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
-- OUT:
--              x_return_status           OUT NOCOPY  VARCHAR2
-- Version : 1.0
--Cache Tables:
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |x_GWTcachetbl              | LPN ID/Delivery ID | Gross Weight       |
--              |x_GWTcacheExttbl           | LPN ID/Delivery ID | Gross Weight       |
--              -----------------------------------------------------------------------
--              |x_NWTcachetbl              | LPN ID/Delivery ID | Net Weight         |
--              |x_NWTcacheExttbl           | LPN ID/Delivery ID | Net Weight         |
--              -----------------------------------------------------------------------
--              |x_VOLcachetbl              | LPN ID/Delivery ID | Volume             |
--              |x_VOLcacheExttbl           | LPN ID/Delivery ID | Volume             |
--              -----------------------------------------------------------------------
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE updateWeightVolume
            (
              p_entity                  IN          VARCHAR2,
              x_GWTcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_GWTcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_NWTcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_NWTcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_VOLcachetbl             IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_VOLcacheExttbl          IN OUT NOCOPY          WSH_UTIL_CORE.key_value_tab_type,
              x_return_status           OUT NOCOPY  VARCHAR2
            )
IS
--{
    --
    --
    l_num_warnings              NUMBER  := 0;
    l_num_errors                NUMBER  := 0;
    l_return_status             VARCHAR2(30);
    --
    l_index         NUMBER;
    --
    l_delivery_lpn_id         NUMBER;
    l_diff_gross_weight       NUMBER;
    l_diff_net_weight         NUMBER;
    l_diff_volume             NUMBER;
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'updateWeightVolume';
--
--}
BEGIN
--{
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
    END IF;
    --
    l_index := x_GWTCacheTbl.FIRST;
    --
    --

    -- checking for weight/volume changes for the delivery/lpns present
    -- in the cache table x_GWTCacheTbl, for which the key-value is less
    -- than (2^31)
    WHILE l_index IS NOT NULL
    LOOP
    --{
        l_delivery_lpn_id   := x_GWTCacheTbl(l_index).key;
        l_diff_gross_weight := x_GWTCacheTbl(l_index).value;
        --
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_diff_gross_weight',l_diff_gross_weight);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.getNetWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
	-- This API whether the weight/volume has changed for the given
	-- delivery/LPN and returns the difference if any.
        WSH_ASN_RECEIPT_PVT.getNetWeightVolume
          (
            p_key                        => l_delivery_lpn_id,
            x_NWTcachetbl                => x_NWTcachetbl,
            x_NWTcacheExttbl             => x_NWTcacheExttbl,
            x_VOLcachetbl                => x_VOLcachetbl,
            x_VOLcacheExttbl             => x_VOLcacheExttbl,
            x_diff_net_weight            => l_diff_net_weight,
            x_diff_volume                => l_diff_volume,
            x_return_status              => l_return_status
          );
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        --
	-- If true , it implies that a change in volume/weight has happened for the given
	-- input delivery/LPN.This change in value is determined by the call to the
        IF l_diff_gross_weight > 0
        OR l_diff_net_weight > 0
        OR l_diff_volume > 0
        THEN
        --{
             IF p_entity = 'DLVY'
             THEN
             --{
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.updateDlvyWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 --
                 WSH_ASN_RECEIPT_PVT.updateDlvyWeightVolume
                   (
                     p_deliveryId                 => l_delivery_lpn_id,
                     p_diff_gross_weight          => l_diff_gross_weight,
                     p_diff_net_weight            => l_diff_net_weight,
                     p_diff_volume                => l_diff_volume,
                     x_return_status              => l_return_status
                   );
             --}
             ELSIF p_entity = 'LPN'
             THEN
             --{
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.updateLPNWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 --
                 WSH_ASN_RECEIPT_PVT.updateLPNWeightVolume
                   (
                     p_LPNId                 => l_delivery_lpn_id,
                     p_diff_gross_weight          => l_diff_gross_weight,
                     p_diff_net_weight            => l_diff_net_weight,
                     p_diff_volume                => l_diff_volume,
                     x_return_status              => l_return_status
                   );
             --}
             END IF;
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 wsh_util_core.api_post_call
                   (
                     p_return_status => l_return_status,
                     x_num_warnings  => l_num_warnings,
                     x_num_errors    => l_num_errors
                   );
        --}
        END IF;
        --
        --
        l_index := x_GWTCacheTbl.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    l_index := x_GWTCacheExtTbl.FIRST;
    --
    --
    -- checking for weight/volume changes for the delivery/lpns present
    -- in the cache table x_GWTCacheExtTbl, for which the key-value is greater
    -- than (2^31 - 1)
    WHILE l_index IS NOT NULL
    LOOP
    --{
        l_delivery_lpn_id   := x_GWTCacheExtTbl(l_index).key;
        l_diff_gross_weight := x_GWTCacheExtTbl(l_index).value;
        --
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_diff_gross_weight',l_diff_gross_weight);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.getNetWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
	-- This API whether the weight/volume has changed for the given
	-- delivery/LPN and returns the difference if any.
        WSH_ASN_RECEIPT_PVT.getNetWeightVolume
          (
            p_key                        => l_delivery_lpn_id,
            x_NWTcachetbl                => x_NWTcachetbl,
            x_NWTcacheExttbl             => x_NWTcacheExttbl,
            x_VOLcachetbl                => x_VOLcachetbl,
            x_VOLcacheExttbl             => x_VOLcacheExttbl,
            x_diff_net_weight            => l_diff_net_weight,
            x_diff_volume                => l_diff_volume,
            x_return_status              => l_return_status
          );
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        --
	-- If true , it implies that a change in volume/weight has happened for the given
	-- input delivery/LPN.This change in value is determined by the call to the
        IF l_diff_gross_weight > 0
        OR l_diff_net_weight > 0
        OR l_diff_volume > 0
        THEN
        --{
             IF p_entity = 'DLVY'
             THEN
             --{
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.updateDlvyWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 --
                 WSH_ASN_RECEIPT_PVT.updateDlvyWeightVolume
                   (
                     p_deliveryId                 => l_delivery_lpn_id,
                     p_diff_gross_weight          => l_diff_gross_weight,
                     p_diff_net_weight            => l_diff_net_weight,
                     p_diff_volume                => l_diff_volume,
                     x_return_status              => l_return_status
                   );
             --}
             ELSIF p_entity = 'LPN'
             THEN
             --{
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.updateLPNWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 --
                 WSH_ASN_RECEIPT_PVT.updateLPNWeightVolume
                   (
                     p_LPNId                 => l_delivery_lpn_id,
                     p_diff_gross_weight          => l_diff_gross_weight,
                     p_diff_net_weight            => l_diff_net_weight,
                     p_diff_volume                => l_diff_volume,
                     x_return_status              => l_return_status
                   );
             --}
             END IF;
                 --
                 IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 wsh_util_core.api_post_call
                   (
                     p_return_status => l_return_status,
                     x_num_warnings  => l_num_warnings,
                     x_num_errors    => l_num_errors
                   );
        --}
        END IF;
        --
        --
        l_index := x_GWTCacheExtTbl.NEXT(l_index);
    --}
    END LOOP;
    --
    --
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
                            'Number of Errors='||l_num_errors||',Number of Warnings='||l_num_warnings);
    END IF;
    --
    IF l_num_errors > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF l_num_warnings > 0
    THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
--}
EXCEPTION
--{
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_ASN_RECEIPT_PVT.updateWeightVolume');
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
--}
END updateWeightVolume;
--} --NNP-WV
--
--
-- Start of comments
-- API name : Process_Matched_Txns
-- Type     : Private
-- Pre-reqs : None.
-- Function : The following actions are carried out in this API:
--            1.If the API is called from UI, the p_line_rec structure is empty.
--              Derive the p_line_rec if called from UI.
--            2.Match the ASN/Receipt to wsh_delivery_details, where by records in wsh_delivery_details
--              are updated, new records are created if needed.
--            3.If the original PO record is closed/cancelled, then collect the list of those
--              recrods into x_po_cancel_rec and x_po_close_rec which are the OUT parameters
--              which will be used in Ravi's API to later perform cancle/close action on the
--              delivery details.
--            4.Call initialize_txn API which will create delivery/trip for those recrods for which delivery
--              id is null, created trip id for those records for which delivery id is persent, but trip
--              id is null.
--            5.Call reconfigure_del_trip API which will reconfigure the delviery  and
--              trip based on the grouping criteria.
--            6.Collect the list of unique delivery ids which needs tp be repriced.
--
-- Parameters :
-- IN OUT:
--  p_dd_rec 		IN OUT NOCOPY 	WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type
--  p_line_rec 		IN OUT NOCOPY 	OE_WSH_BULK_GRP.line_rec_type
--  p_action_prms 	IN OUT NOCOPY 	WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type
--IN:
--  p_shipment_header_id 	IN 	NUMBER,
--  p_max_txn_id 		IN 	NUMBER
-- OUT:
--  x_po_cancel_rec    	 OUT NOCOPY 	OE_WSH_BULK_GRP.line_rec_type
--  x_po_close_rec   	 OUT NOCOPY 	OE_WSH_BULK_GRP.line_rec_type
--  x_return_status	 OUT NOCOPY 	VARCHAR2
-- Cache Tables :
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |l_index_dd_ids_cache       | index              | Delivery Detail ID |
--              |l_index_dd_ids_ext_cache   | index              | Delivery Detail ID |
--              |----------------------------------------------------------------------
--              |l_index_del_ids_cache      | index              | Delivery ID        |
--              |l_index_del_ids_ext_cache  | index              | Delivery ID        |
--              |----------------------------------------------------------------------
--              |l_del_ids_del_ids_cache    | Delivery Detail ID | Delivery Detail ID |
--              |l_del_ids_del_ids_ext_cache| Delivery Detail ID | Delivery Detail ID |
--              |----------------------------------------------------------------------
--              |l_sli_qty_cache            | Shipment Line ID   | Quantity           |
--              |l_sli_qty_ext_cache        | Shipment Line ID   | Quantity           |
--              |----------------------------------------------------------------------
--              |l_sli_sli_cache            | Shipment Line ID   | Shipment Line ID   |
--              |l_sli_sli_ext_cache        | Shipment Line ID   | Shipment Line ID   |
--              |----------------------------------------------------------------------
--              |l_del_reprice_tbl          | Delivery ID        | Delivery ID        |
--              |l_del_reprice_ext_tbl      | Delivery ID        | Delivery ID        |
--              -----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE Process_Matched_Txns(
p_dd_rec IN OUT NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
p_line_rec IN OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
p_action_prms IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
p_shipment_header_id IN NUMBER,
p_max_txn_id IN NUMBER,
x_po_cancel_rec        OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
x_po_close_rec        OUT NOCOPY OE_WSH_BULK_GRP.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

IS

-- Cursor to fetch the src_requested_quantity2 for the po_line_location_id

Cursor c_src_qty2(p_line_id NUMBER,p_line_location_id NUMBER)
 is
select src_requested_quantity2,
src_requested_quantity_uom2,
src_requested_quantity,
src_requested_quantity_uom
from WSH_DELIVERY_DETAILS
where
source_line_id   = p_line_id    and                --performance
po_shipment_line_id = p_line_location_id and
source_code = 'PO'
order by decode(Released_status,'X',1,2);
--AND rownum = 1;

-- Cursor to fetch the sum of the requested quantity for the givine po_line_location_id

Cursor c_sum_req_qty(p_line_id NUMBER,p_line_location_id NUMBER)
IS
select sum(requested_quantity)
from wsh_delivery_details
where
source_line_id   = p_line_id    and                --performance
po_shipment_line_id = p_line_location_id and
source_code = 'PO';

-- Cursor to fetch the delivery,delivery leg and trip infrmation for the delivery being processed.
CURSOR get_delivery_info(p_del_id_c1 NUMBER) IS
SELECT t.trip_id
FROM   wsh_new_deliveries dl,
       wsh_delivery_legs dg,
       wsh_trip_stops st,
       wsh_trips t
WHERE  dl.delivery_id = p_del_id_c1 AND
       dl.delivery_id = dg.delivery_id AND
       dg.drop_off_stop_id = st.stop_id AND
       st.stop_location_id = dl.ULTIMATE_DROPOFF_LOCATION_ID AND
       st.trip_id = t.trip_id;

-- Cursor to fing if a particular delivery has legs associated with it or not.

CURSOR c_has_del_leg(p_del_id_c2 NUMBER) IS
SELECT '1'
FROM   wsh_new_deliveries dl,
       wsh_delivery_legs dg
WHERE  dl.delivery_id = p_del_id_c2 AND
       dl.delivery_id = dg.delivery_id;

CURSOR line_csr (p_delivery_detail_id NUMBER)
IS
  SELECT wdd.gross_weight, wdd.net_weight, wdd.volume,
         NVL(wdd.wv_frozen_flag,'Y') wv_frozen_flag,
         wda.parent_delivery_detail_id,
         wda.delivery_id,
         NVL(wdd1.wv_frozen_flag,'Y') lpn_wv_frozen_flag,
         NVL(wnd.wv_frozen_flag,'Y') dlvy_wv_frozen_flag,
         NVL
           (
             wdd.shipped_quantity,
             NVL
               (
                 wdd.picked_quantity,
                 wdd.requested_quantity
               )
           ) wv_qty,
         wdd.requested_quantity requested_quantity
  FROM   wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda,
         wsh_delivery_details  wdd1,
         wsh_new_deliveries wnd
  where  wdd.delivery_detail_id =  p_delivery_detail_id
  AND    wdd.delivery_detail_id = wda.delivery_detail_id
  --AND    wda.delivery_id        = wnd.delivery_id
  AND    wda.parent_delivery_detail_id = wdd1.delivery_detail_id (+)
  AND    wda.delivery_id               = wnd.delivery_id (+);

l_line_rec line_csr%ROWTYPE;
--
--
CURSOR packed_csr(p_wdd_id NUMBER)
IS
		SELECT parent_delivery_Detail_id
		FROM   wsh_delivery_assignments_v
		WHERE  delivery_Detail_id = p_wdd_id;


temp_lpn NUMBER;

p_dd_info         WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Rec_Type;
p_dd_assign_info WSH_DELIVERY_DETAILS_PKG.Delivery_Assignments_Rec_type;

p_dd_list WSH_PO_CMG_PVT.dd_list_type;
l_local_dd_rec        LOCAL_DD_REC_TABLE_TYPE;

l_parent_wdd_id        NUMBER;
l_return_status        VARCHAR2(1);
l_new_dd_id                                   NUMBER;
l_child_rtv_qty_to_consolidate NUMBER;
l_child_remaining_qty                 NUMBER;
l_remaining_qty                       NUMBER;
l_remaining_qty1                      NUMBER;
l_pending_qty                              NUMBER;
l_delivery_detail_id NUMBER;
x_row_id         VARCHAR2(30);
x_rowid          VARCHAR2(30);
x_delivery_detail_id NUMBER;
k    NUMBER;
x_split_weight       NUMBER;
x_split_volume       NUMBER;
x_delivery_assignment_id   NUMBEr;
l_header_id     NUMBER;
l_additional_line_info_rec WSH_BULK_PROCESS_PVT.additional_line_info_rec_type;
l_api_version    CONSTANT NUMBER          :=    1.0;
l_msg_count    NUMBER := 0;
l_msg_data      VARCHAR2(1000) := NULL;
l_release_status   VARCHAR2(1);
l_update_dd_rec update_dd_rec_type;
l_po_line_location_id     NUMBER;
l_index                     NUMBER;
l_i_index  NUMBER;
l_i                           NUMBER;
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_itemp          NUMBER;
l_trip_id NUMBER;
l_temp_char  VARCHAR2(1);


--arun's change
l_dd_ids  WSH_UTIL_CORE.id_tab_type;

l_index_dd_ids_cache        WSH_UTIL_CORE.key_value_tab_type;
l_index_dd_ids_ext_cache    WSH_UTIL_CORE.key_value_tab_type;
l_index_del_ids_cache       WSH_UTIL_CORE.key_value_tab_type;
l_index_del_ids_ext_cache   WSH_UTIL_CORE.key_value_tab_type;

l_uniq_del_ids_tab          wsh_util_core.id_tab_type;

l_del_ids_del_ids_cache     WSH_UTIL_CORE.key_value_tab_type;
l_del_ids_del_ids_ext_cache WSH_UTIL_CORE.key_value_tab_type;

--change for consolidate qty
l_sli_qty_cache                    WSH_UTIL_CORE.key_value_tab_type;
l_sli_qty_ext_cache         WSH_UTIL_CORE.key_value_tab_type;
l_sli_sli_cache                    WSH_UTIL_CORE.key_value_tab_type;
l_sli_sli_ext_cache         WSH_UTIL_CORE.key_value_tab_type;
l_shp_line_id                    NUMBER;
l_quantity                    NUMBER;
l_src_qty  NUMBER;
l_src_qty_uom  VARCHAR2(3);
l_src_qty2  NUMBER;
l_src_qty_uom2  VARCHAR2(3);
l_sum_req_qty  NUMBER;
l_ratio  NUMBER;
--end of change for consolidate qty

--l_action_prms
l_action_prms  WSH_BULK_TYPES_GRP.action_parameters_rectype;
--end of arun's change
l_populate_p_line_rec VARCHAR2(1)  := 'N';


l_del_ids_tab         WSH_UTIL_CORE.id_tab_type;
l_del_reprice_tbl     WSH_UTIL_CORE.key_value_tab_type;
l_del_reprice_ext_tbl WSH_UTIL_CORE.key_value_tab_type;
j   NUMBER;
l_ind NUMBER;
-- code copied after finding the diff
l_object_version_number  NUMBER;

l_outermost_lpn  NUMBER;
l_outermost_lpn_name  VARCHAR2(50);

p_loc_id_index_cache       WSH_UTIL_CORE.key_value_tab_type;
p_loc_id_index_ext_cache   WSH_UTIL_CORE.key_value_tab_type;
l_value NUMBER;
l_cache_return_status VARCHAR2(1);
l_pline_rec_count  NUMBER;

kk  NUMBER;

--{ --NNP-WV
l_lpnGWTcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_lpnGWTcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
l_lpnNWTcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_lpnNWTcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
l_lpnVOLcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_lpnVOLcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
--
--
l_dlvyGWTcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_dlvyGWTcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
l_dlvyNWTcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_dlvyNWTcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
l_dlvyVOLcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_dlvyVOLcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
--
--
l_org_wv_qty                    NUMBER;
l_gross_wt_pc                   NUMBER;
l_net_wt_pc                     NUMBER;
l_vol_pc                        NUMBER;
--
l_old_wv_qty                    NUMBER;
l_new_wv_qty                    NUMBER;
l_old_dd_gross_weight           NUMBER;
l_old_dd_net_weight             NUMBER;
l_old_dd_volume                 NUMBER;
l_diff_dd_gross_weight           NUMBER;
l_diff_dd_net_weight             NUMBER;
l_diff_dd_volume                 NUMBER;
--} --NNP-WV

l_lpnIdCacheTbl                  WSH_UTIL_CORE.key_value_tab_type;
l_lpnIdCacheExtTbl               WSH_UTIL_CORE.key_value_tab_type;

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                    VARCHAR2(1); -- DBI Project

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_MATCHED_TXNS';
--
BEGIN

--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_HEADER_ID',P_SHIPMENT_HEADER_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_MAX_TXN_ID',P_MAX_TXN_ID);
END IF;
--
SAVEPOINT Process_Matched_Txns_PVT;
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
-- When the API is called from UI, p_line_Rec will not be populated.
-- Need to populate the p_line_rec information in this case.
-- If the API is called from matching algorithm, we have the entire p_line_rec
-- populated.
-- The first part of the API is to derive p_line_rec in case it is empty
-- and also assign the p_line_rec index value to p_dd_rec.
-- It is possible that the same po_line_location can have multiple receipt lines.
-- Also same receipt lines can have multiple entries in p_dd_rec.
-- p_line_rec is populated when ever the receipt line id(rcv_shipment_line_id)
-- changes.

IF p_line_rec.po_shipment_line_id.COUNT = 0 THEN
-- Need to populate the p_line_rec information in this case.
-- This is done by setting the flag l_populate_p_line_rec.
  l_populate_p_line_rec := 'Y';
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_populate_p_line_rec',l_populate_p_line_rec);
    WSH_DEBUG_SV.log(l_module_name,'p_line_rec.po_shipment_line_id.COUNT',p_line_rec.po_shipment_line_id.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.transaction_type',p_dd_rec.transaction_type);
END IF;
--

IF p_dd_rec.transaction_type = 'ASN' THEN
--{
  l_release_status := 'C';
ELSIF p_dd_rec.transaction_type = 'RECEIPT' THEN
  l_release_status := 'L';
END IF;

--}
l_po_line_location_id := -99;

FOR i IN 1..p_dd_rec.del_detail_id_tab.COUNT
LOOP
  -- check if the rcv_shipment_line_id is present in the cache table for the current
  -- record
  -- if it is present, return the value from the cache table to
  -- p_dd_rec.shpmt_line_id_idx_tab
  -- if data is not in cache table call WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes() API.
  -- after calling WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes() API, put the value of
  -- rcv_shipment_line_id and the index of p_line_rec to the cache table, so that if
  -- another record belonging to the same rcv_shipment_line_id is encountered, then
  -- the p_line_rec index can be obtained from the cache table.
  -- p_dd_rec.shipment_line_id_idx is the link between the two structures viz.p_line_rec
  -- and p_dd_rec.

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p-dd-rec-index i',i);
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.po_line_location_id_tab(i)',p_dd_rec.po_line_location_id_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.shipment_line_id_tab(i)',p_dd_rec.shipment_line_id_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.process_asn_rcv_flag_tab(i)',p_dd_rec.process_asn_rcv_flag_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.child_index_tab(i)',p_dd_rec.child_index_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.del_detail_id_tab(i)',p_dd_rec.del_detail_id_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.delivery_id_tab(i)',p_dd_rec.delivery_id_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.trip_id_tab(i)',p_dd_rec.trip_id_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.ship_from_location_id_tab(i)',p_dd_rec.ship_from_location_id_tab(i));
  END IF;
  --

  l_cache_return_status := wsh_util_core.g_ret_sts_success;

  IF l_populate_p_line_rec = 'Y'  THEN
  --{
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-p_loc_id_index_cache',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    IF   (p_dd_rec.process_asn_rcv_flag_tab(i) ='Y')
    THEN
    --{
        wsh_util_core.get_cached_value(
          p_cache_tbl       => p_loc_id_index_cache,
          p_cache_ext_tbl   => p_loc_id_index_ext_cache,
          p_value           => l_value,
          p_key             =>  NVL(p_dd_rec.shipment_line_id_tab(i),-99999),
          p_action          => 'GET',
          x_return_status   => l_cache_return_status);

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'pointer to p_line_rec',l_value);
        END IF;
        --
        IF l_cache_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        --{
	    -- rcv_shipment_line_id is present in the cache table.
            p_dd_rec.shpmt_line_id_idx_tab(i) := l_value;
        ELSIF l_cache_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	    -- Need to derive the po information by calling WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes()
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.GET_PO_RCV_ATTRIBUTES',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_INBOUND_UTIL_PKG.get_po_rcv_attributes(
                  p_po_line_location_id  => p_dd_rec.po_line_location_id_tab(i),
                  p_rcv_shipment_line_id => p_dd_rec.shipment_line_id_tab(i),
                  x_line_rec             => p_line_rec,
                  x_return_status        => l_return_status);
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

            l_pline_rec_count := p_line_rec.header_id.COUNT;
            IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'pointer to p_line_rec',l_pline_rec_count);
            END IF;
           --
             p_dd_rec.shpmt_line_id_idx_tab(i) := p_line_rec.header_id.COUNT;

           --
           IF p_dd_rec.shipment_line_id_tab(i) IS NOT NULL
	   THEN
	   -- populate the shipment_line_id to p_dd_rec structure.
           --{
               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-p_loc_id_index_cache',WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               --
                wsh_util_core.get_cached_value(
                   p_cache_tbl       => p_loc_id_index_cache,
                   p_cache_ext_tbl   => p_loc_id_index_ext_cache,
                   p_value           => l_pline_rec_count,
                   p_key             =>  p_dd_rec.shipment_line_id_tab(i),
                   p_action          => 'PUT',
                   x_return_status   => l_cache_return_status);
                IF l_cache_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
                   raise FND_API.G_EXC_ERROR;
                ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR -- Added by NPARIKH
                THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
           --}
           END IF;

          ElSIF l_cache_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
             raise FND_API.G_EXC_ERROR;
          ELSIF l_cache_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR  THEN
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          --}

    --}
    END IF;



  END IF;--End if of l_populate_p_line_rec

  --moved this code from the above if -- end if so that requested quantity uom
  -- populated in p_line_rec even when matching algorithm calls process_matched_txns

    IF   (p_dd_rec.process_asn_rcv_flag_tab(i) ='Y')
    THEN
    --{
      p_line_rec.requested_quantity_uom(p_dd_rec.shpmt_line_id_idx_tab(i)) :=
                       p_dd_rec.requested_qty_uom_tab(i);

      p_line_rec.requested_quantity_uom2(p_dd_rec.shpmt_line_id_idx_tab(i)) :=

                       p_dd_rec.requested_qty_uom2_tab(i);

     IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.requested_quantity_uom ---', p_dd_rec.requested_qty_uom_tab(i));
                                --}
     END IF;
   END IF;

END LOOP;-- End loop of p_dd_rec.(By this time the enitre p_line_rec is populated with the values )



FOR i IN 1..p_dd_rec.del_detail_id_tab.COUNT
LOOP
  l_child_rtv_qty_to_consolidate := 0;
  l_child_remaining_qty          := 0;
  l_remaining_qty                := 0;
  l_remaining_qty1               := 0;
  l_pending_qty                         := 0;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'processing index i in p_dd_rec ---', i);
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.process_asn_rcv_flag_tab(i)', p_dd_rec.process_asn_rcv_flag_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.child_index_tab(i)', p_dd_rec.child_index_tab(i));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.del_detail_id_tab(i)', p_dd_rec.del_detail_id_tab(i));
  END IF;

  -- Process_matched_txn api will process only those records for which
  -- the process_asn_rcv_flag is set to'Y'.
  -- After processing each record, the flag is set to 'X'.

  IF (p_dd_rec.process_asn_rcv_flag_tab(i) ='Y') THEN
  --{

        --{ -- NNP-WV
            l_line_rec.gross_weight              := NULL;
            l_line_rec.net_weight                := NULL;
            l_line_rec.volume                    := NULL;
            l_line_rec.wv_frozen_flag            := NULL;
            l_line_rec.delivery_id               := NULL;
            l_line_rec.parent_delivery_detail_id := NULL;
            l_line_rec.dlvy_wv_frozen_flag       := NULL;
            l_line_rec.lpn_wv_frozen_flag        := NULL;
            l_line_rec.wv_qty                    := NULL;
            l_line_rec.requested_quantity        := NULL;
            --
            l_old_dd_gross_weight                := NULL;
            l_old_dd_net_weight                  := NULL;
            l_old_dd_volume                      := NULL;
            --
            l_diff_dd_gross_weight               := 0;
            l_diff_dd_net_weight                 := 0;
            l_diff_dd_volume                     := 0;
        --}

          --{ --NNP-WV
          IF  p_dd_rec.del_detail_id_tab(i) IS NOT NULL
          --AND p_dd_rec.delivery_id_tab(i) IS NOT NULL
          THEN
          --{
              OPEN  line_csr (p_dd_rec.del_detail_id_tab(i));
              FETCH line_csr INTO l_line_rec;
              --
              -- Need to add error handling for NoDataFound----this should not happen.
              --
              CLOSE line_csr;
              --
              --
              --
              IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_line_rec:l_net_wt '||l_line_rec.net_weight||' l_gross_wt '||l_line_rec.gross_weight||' l_vol '||l_line_rec.volume);
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_line_rec:dlvy_id '||l_line_rec.delivery_id||' parent_wdd_id '||l_line_rec.parent_delivery_detail_id);
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_line_rec:wv_qty '||l_line_rec.wv_qty || ' req qty ' || l_line_rec.requested_quantity);
                   WSH_DEBUG_SV.logmsg(l_module_name, 'wv_frozen_flag:line '||l_line_rec.wv_frozen_flag||' dlvy '||l_line_rec.dlvy_wv_frozen_flag || ' lpn ' || l_line_rec.lpn_wv_frozen_flag);
              END IF;
              --
              --
              IF l_line_rec.wv_frozen_flag = 'Y'
              THEN
              --{
                  l_org_wv_qty := l_line_rec.wv_qty;
                                                                                                                                                /*NVL
                                    (
                                      p_dd_rec.shipped_qty_db_tab(i),
                                      NVL
                                        (
                                          p_dd_rec.picked_qty_db_tab(i),
                                          p_dd_rec.requested_qty_db_tab(i)
                                        )
                                    );
                                                                                                                                                */
                  --
                  --
                  IF l_org_wv_qty <> 0
                  THEN
                      l_gross_wt_pc := l_line_rec.gross_weight / l_org_wv_qty;
                      l_net_wt_pc   := l_line_rec.net_weight / l_org_wv_qty;
                      l_vol_pc      := l_line_rec.volume / l_org_wv_qty;
                  ELSE
                      l_gross_wt_pc := 0;
                      l_net_wt_pc   := 0;
                      l_vol_pc      := 0;
                 END IF;
                 --
                 --
                 IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'Frozen Y l_net_wt_pc '||l_net_wt_pc||' l_gross_wt_pc '||l_gross_wt_pc||' l_vol_pc '||l_vol_pc);
                 END IF;
                 --
                 --
                  l_old_wv_qty := NVL
                                    (
                                      p_dd_rec.received_qty_tab(i),
                                      NVL
                                        (
                                          p_dd_rec.shipped_qty_tab(i),
                                          NVL
                                            (
                                              p_dd_rec.picked_qty_tab(i),
                                              p_dd_rec.requested_qty_tab(i)
                                            )
                                        )
                                    );
                 --
                 IF l_old_wv_qty < l_org_wv_qty
                                                                                                                                        AND (
                                 p_dd_rec.child_index_tab(i) IS NOT NULL
                                 OR l_line_rec.requested_quantity > l_old_wv_qty
                               )
                 THEN
                     l_old_dd_gross_weight := ROUND( l_old_wv_qty * l_gross_wt_pc ,5);
                     l_old_dd_net_weight   := ROUND( l_old_wv_qty * l_net_wt_pc ,5);
                     l_old_dd_volume       := ROUND( l_old_wv_qty * l_vol_pc ,5);
                     --
                     l_diff_dd_gross_weight := l_line_rec.gross_weight - l_old_dd_gross_weight;
                     l_diff_dd_net_weight   := l_line_rec.net_weight - l_old_dd_net_weight;
                     l_diff_dd_volume       := l_line_rec.volume - l_old_dd_volume;
                 END IF;
                 --
              --}
              ELSE
              --{
                 l_old_dd_gross_weight := NULL;
                 l_old_dd_net_weight   := NULL;
                 l_old_dd_volume       := NULL;
                 --
                 l_diff_dd_gross_weight := 0;
                 l_diff_dd_net_weight   := 0;
                 l_diff_dd_volume       := 0;
              --}
              END IF;
              --
              --
              IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_old_dd:l_net_wt '||l_old_dd_net_weight||' l_gross_wt '||l_old_dd_gross_weight||' l_vol '||l_old_dd_volume);
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_diff_dd-Orig:l_net_wt '||l_diff_dd_net_weight||' l_gross_wt '||l_diff_dd_gross_weight||' l_vol '||l_diff_dd_volume);
              END IF;
          --}
          END IF;
          --}

    -- In the p_dd_rec structure, we can have records for which child index is populated.
    -- This means that certain split has happened in memory and child records are derived
    -- out of the current line.
    -- First we loop through all the recors for which child index is not null
    -- Start from the parent record and process all the child records till the last level is reached.
    -- Once the records are processed, then the process_asn_rcv_flag is set to 'X'
    -- inorder to avoid selecting the same records later in the loop.
    -- After processing the records for which child index is not null, we process those records
    -- for which p_dd_rec.child_index is NULL.

    IF (p_dd_rec.child_index_tab(i) IS NOT NULL) THEN
    --{
      IF p_dd_rec.del_detail_id_tab(i) IS NOT NULL THEN
      -- bulk update those records whose delivery detail id is not null in p_dd_rec.
      -- This is done by populating l_update_dd_rec structure which is later used for bulk update.
      IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit populate_update_dd_rec',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --{
        populate_update_dd_rec(
          p_dd_rec       => p_dd_rec,
          p_index        => i,
          p_line_rec     => p_line_rec,
          p_gross_weight  => l_old_dd_gross_weight,
          p_net_weight  => l_old_dd_net_weight,
          p_volume  => l_old_dd_volume,
          x_release_status => l_release_status,
          l_update_dd_rec  => l_update_dd_rec,
          x_lpnIdCacheTbl  => l_lpnIdCacheTbl,
          x_lpnIdCacheExtTbl => l_lpnIdCacheExtTbl,
          x_return_status  => l_return_status);


        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);


      ELSE
        -- p_dd_rec.delivery_detail_id is null.Need to insert record into wsh_delivery_details.
	-- This is done by first populating addtional line information using
	-- WSH_PO_CMG_PVT.populate_additional_line_info API and then calling
	-- WSH_BULK_PROCESS_PVT.bulk_insert_details API to do the insert operation.
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.POPULATE_ADDITIONAL_LINE_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
	-- calling WSH_PO_CMG_PVT.populate_additional_line_info
        WSH_PO_CMG_PVT.populate_additional_line_info(
           p_line_rec                  => p_line_rec,
           p_index                     => p_dd_rec.shpmt_line_id_idx_tab(i),
           p_additional_line_info_rec  => l_additional_line_info_rec ,
           x_return_status             => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_BULK_PROCESS_PVT.BULK_INSERT_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'P_line_rec.requested_quantity is', P_line_rec.requested_quantity(p_dd_rec.shpmt_line_id_idx_tab(i)));
            WSH_DEBUG_SV.log(l_module_name,'P_line_rec.received_quantity is', P_line_rec.received_quantity(p_dd_rec.shpmt_line_id_idx_tab(i)));
            WSH_DEBUG_SV.log(l_module_name,'P_line_recs index is ', p_dd_rec.shpmt_line_id_idx_tab(i));
        END IF;
        --
        l_action_prms.org_id := p_line_rec.org_id(p_dd_rec.shpmt_line_id_idx_tab(i));

        p_line_rec.requested_quantity_uom(p_dd_rec.shpmt_line_id_idx_tab(i)) :=
                       p_dd_rec.requested_qty_uom_tab(i);

        p_line_rec.requested_quantity_uom2(p_dd_rec.shpmt_line_id_idx_tab(i)) :=
                       p_dd_rec.requested_qty_uom2_tab(i);

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.requested_quantity_uom 2nd occurance ', p_dd_rec.requested_qty_uom_tab(i));
        END IF;
	-- Calling WSH_BULK_PROCESS_PVT.bulk_insert_details
        WSH_BULK_PROCESS_PVT.bulk_insert_details(
           P_line_rec       => P_line_rec,
           p_index          => p_dd_rec.shpmt_line_id_idx_tab(i),
           p_action_prms    => l_action_prms,--change by arun
           p_additional_line_info_rec => l_additional_line_info_rec,
           X_return_status  => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

        IF p_dd_rec.delivery_id_tab(i) is NOT NULL THEN
        --
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'updating WDA');
            WSH_DEBUG_SV.log(l_module_name,'p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i))',p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i)));
        END IF;

	-- Updating wsh_delivery_assignments_v after the insert into wsh_delivery_details.

	update wsh_delivery_assignments_v
        set delivery_id = p_dd_rec.delivery_id_tab(i),
               last_update_date = SYSDATE,
               last_updated_by =  FND_GLOBAL.USER_ID,
               last_update_login =  FND_GLOBAL.LOGIN_ID
        where delivery_detail_id =
              p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i));
        END IF;
        --
	-- populating p_dd_rec.delivery_detail id with the new delivery_detail id.
	-- Also setting the p_line_rec.delivery_detail_id to NULL as the same p_line_rec
	-- may used later for another record.

        p_dd_rec.del_detail_id_tab(i) := p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i));
        p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i)):= NULL;
        p_dd_rec.last_update_date_tab(i) := NULL;
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit populate_update_dd_rec',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        -- Once delivery_detail_id is populated, populate the update_dd_rec which will be used at the end
	-- for bulk update.

        populate_update_dd_rec(
          p_dd_rec       => p_dd_rec,
          p_index        => i,
          p_line_rec     => p_line_rec,
          x_release_status => l_release_status,
          l_update_dd_rec  => l_update_dd_rec,
          x_lpnIdCacheTbl  => l_lpnIdCacheTbl,
          x_lpnIdCacheExtTbl => l_lpnIdCacheExtTbl,
          x_return_status  => l_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

      END IF;
      --}

      k := i;
      p_dd_rec.process_asn_rcv_flag_tab(k) := 'X';
                                                --
      WHILE p_dd_rec.child_index_tab(k) IS NOT NULL
      LOOP

       IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'k',k);
       END IF;
       --
       IF (p_dd_rec.process_asn_rcv_flag_tab(p_dd_rec.child_index_tab(k)) ='Y')
       THEN
       --{
       -- Start with the child record and populate the necessary
       -- fields only and create a new delivery detail from the
       -- parent delivery detail.

        p_dd_info.rcv_shipment_line_id := p_dd_rec.shipment_line_id_tab(p_dd_rec.child_index_tab(k));
        --p_dd_info.requested_quantity:=  p_dd_rec.shipped_qty_tab(p_dd_rec.child_index_tab(k));
        p_dd_info.requested_quantity:=  p_dd_rec.requested_qty_tab(p_dd_rec.child_index_tab(k));
        p_dd_info.picked_quantity :=FND_API.G_MISS_NUM;
        p_dd_info.picked_quantity2 :=FND_API.G_MISS_NUM;
        p_dd_info.shipped_quantity:=p_dd_rec.shipped_qty_tab(p_dd_rec.child_index_tab(k));
        p_dd_info.returned_quantity:= p_dd_rec.returned_qty_tab(p_dd_rec.child_index_tab(k));
        p_dd_info.received_quantity:=p_dd_rec.received_qty_tab(p_dd_rec.child_index_tab(k));
        p_dd_info.requested_quantity2:=p_dd_rec.requested_qty2_tab(p_dd_rec.child_index_tab(k));
        p_dd_info.shipped_quantity2:=p_dd_rec.shipped_qty2_tab(p_dd_rec.child_index_tab(k));
        p_dd_info.returned_quantity2:=p_dd_rec.returned_qty2_tab(p_dd_rec.child_index_tab(k));
        p_dd_info.received_quantity2:=p_dd_rec.received_qty2_tab(p_dd_rec.child_index_tab(k));

                                                                /* added by NNP */
        p_dd_info.tracking_number:=
            p_line_rec.tracking_number(p_dd_rec.shpmt_line_id_idx_tab(p_dd_rec.child_index_tab(k)));
        p_dd_info.ship_from_location_id:=p_dd_rec.ship_from_location_id_tab(p_dd_rec.child_index_tab(k));

                                                                /* added by NNP */


/*
       p_dd_info.inventory_item_id:=
        nvl(p_line_rec.rcv_inventory_item_id(p_dd_rec.shpmt_line_id_idx_tab(k)),
        p_line_rec.inventory_item_id(p_dd_rec.shpmt_line_id_idx_tab(k)) );
        p_dd_info.item_description:=
        nvl(p_line_rec.rcv_item_description(p_dd_rec.shpmt_line_id_idx_tab(k)),
        p_line_rec.item_description(p_dd_rec.shpmt_line_id_idx_tab(k)));
*/
/* commented above and replaced with the following
   replaced k with p_dd_rec.child_index_tab(k)
-- NNP */
       -- Check for substitue item.
       -- Receipt can be made against the inventory item that is mentioned in the PO
       -- or against the subtitute item.
       -- If the item is different at the time of matching the ASN/Receipt, precedence
       -- is given to the substitute item that is mentioned in the ASN/Receipt.

       p_dd_info.inventory_item_id:=
        nvl
          (
            p_line_rec.rcv_inventory_item_id(p_dd_rec.shpmt_line_id_idx_tab(p_dd_rec.child_index_tab(k))),
            p_line_rec.inventory_item_id(p_dd_rec.shpmt_line_id_idx_tab(p_dd_rec.child_index_tab(k)))
          );
        p_dd_info.item_description:=
        nvl
          (
            p_line_rec.rcv_item_description(p_dd_rec.shpmt_line_id_idx_tab(p_dd_rec.child_index_tab(k))),
            p_line_rec.item_description(p_dd_rec.shpmt_line_id_idx_tab(p_dd_rec.child_index_tab(k)))
          );

        l_child_rtv_qty_to_consolidate := p_dd_rec.returned_qty_tab(p_dd_rec.child_index_tab(k));

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'p_dd_info.requested_quantity', p_dd_info.requested_quantity);
          WSH_DEBUG_SV.log(l_module_name,'p_dd_info.received_quantity', p_dd_info.received_quantity);
	  WSH_DEBUG_SV.log(l_module_name,'p_dd_info.rcv_shipment_line_id',p_dd_info.rcv_shipment_line_id);
          WSH_DEBUG_SV.log(l_module_name,'p_dd_info.picked_quantity',p_dd_info.picked_quantity);
   	  WSH_DEBUG_SV.log(l_module_name,'p_dd_info.picked_quantity2',p_dd_info.picked_quantity2);
	  WSH_DEBUG_SV.log(l_module_name,'p_dd_info.shipped_quantity',p_dd_info.shipped_quantity);
	  WSH_DEBUG_SV.log(l_module_name,'p_dd_info.returned_quantity',p_dd_info.returned_quantity);
	  WSH_DEBUG_SV.log(l_module_name,'p_dd_info.requested_quantity2',p_dd_info.requested_quantity2);
	  WSH_DEBUG_SV.log(l_module_name,'p_dd_info.shipped_quantity2',p_dd_info.shipped_quantity2);
	  WSH_DEBUG_SV.log(l_module_name,'p_dd_info.returned_quantity2',p_dd_info.returned_quantity2);
	  WSH_DEBUG_SV.log(l_module_name,'p_dd_info.received_quantity2',p_dd_info.received_quantity2);
      END IF;
        -- set the released status to 'C'-Shipped if transaction type is ASN and
	-- shipped qty is not null.
	-- set the released status to 'L'-Closed if transaction type is Receipt
	-- and received qty is not null.
        -- Calculates the remaining qty to see if the case is that of a partial shipment/receipt
	-- All the remaining quantities for a particular po_line_location_id
	-- will be cosolidated and a single record will be inserted into wsh_delivery_details
	-- in case if there are no open delivery_details present for the same.

        IF p_dd_rec.transaction_type = 'ASN' THEN
	--{
          IF p_dd_rec.shipped_qty_tab(p_dd_rec.child_index_tab(k)) IS NULL AND
             p_dd_rec.received_qty_tab(p_dd_rec.child_index_tab(k)) IS NULL
          THEN
          --{
            p_dd_info.released_status := 'X';
          ELSE
            p_dd_info.released_status := 'C';
            p_dd_info.requested_quantity:=
            least(p_dd_rec.requested_qty_tab(p_dd_rec.child_index_tab(k)),
            p_dd_rec.shipped_qty_tab(p_dd_rec.child_index_tab(k)) );
                                                                /* added by NNP */
            p_dd_info.requested_quantity2:=
            least(p_dd_rec.requested_qty2_tab(p_dd_rec.child_index_tab(k)),
            p_dd_rec.shipped_qty2_tab(p_dd_rec.child_index_tab(k)) );
                                                                /* added by NNP */
          END IF;
          --}
	  l_child_remaining_qty :=
          p_dd_rec.requested_qty_tab(p_dd_rec.child_index_tab(k))-
          nvl(p_dd_rec.shipped_qty_tab(p_dd_rec.child_index_tab(k)),0);
        END IF;
        --}

        IF p_dd_rec.transaction_type = 'RECEIPT' THEN
        --{
          IF p_dd_rec.shipped_qty_tab(p_dd_rec.child_index_tab(k)) IS NULL AND
             p_dd_rec.received_qty_tab(p_dd_rec.child_index_tab(k)) IS NULL
          THEN
          --{
            p_dd_info.released_status := 'X';
          ELSE
            p_dd_info.released_status := 'L';
            p_dd_info.requested_quantity:=
            least(p_dd_rec.requested_qty_tab(p_dd_rec.child_index_tab(k)),
            p_dd_rec.received_qty_tab(p_dd_rec.child_index_tab(k)) );
                                                                /* added by NNP */
            p_dd_info.requested_quantity2:=
            least(p_dd_rec.requested_qty2_tab(p_dd_rec.child_index_tab(k)),
            p_dd_rec.received_qty2_tab(p_dd_rec.child_index_tab(k)) );
                                                                /* added by NNP */
          END IF;
          --}
          l_child_remaining_qty :=
          p_dd_rec.requested_qty_tab(p_dd_rec.child_index_tab(k))-
          nvl(p_dd_rec.received_qty_tab(p_dd_rec.child_index_tab(k)),0);
        END IF;
        --}

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_child_remaining_qty',l_child_remaining_qty);
        END IF;
        --
	 -- if the remaining qty greater than zero, then the requested qty of the child is
	 -- set to the corresponding shipped qty.Else it is left untouched.

         IF l_child_remaining_qty <= 0 THEN
         --{
           p_dd_info.requested_quantity := p_dd_rec.requested_qty_tab(p_dd_rec.child_index_tab(k));
         ELSIF l_child_remaining_qty > 0 THEN
           IF p_dd_rec.transaction_type = 'ASN' THEN
           --{
              p_dd_info.requested_quantity := p_dd_rec.shipped_qty_tab(p_dd_rec.child_index_Tab(k));
           ELSIF p_dd_rec.transaction_type ='RECEIPT' THEN
              p_dd_info.requested_quantity := p_dd_rec.received_qty_tab(p_dd_rec.child_index_tab(k));
           --}
           END IF;
         --}
         END IF;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'p_dd_info.requested_quantity',p_dd_info.requested_quantity);
        END IF;

        -- Create New Detail from old Delivery detail having the above attributes
        -- being different.
        -- The check on released status id done because all the open quantities are getting
	-- consolidated at the end.
        IF  p_dd_info.released_status <> 'X' THEN
        --{
            --{ --NNP-WV
                IF l_line_rec.wv_frozen_flag = 'Y'
                THEN
                --{
                    l_new_wv_qty := NVL
                                    (
                                      p_dd_info.received_quantity,
                                      NVL
                                        (
                                          p_dd_info.shipped_quantity,
                                          p_dd_info.requested_quantity
                                        )
                                    );
                 --
                 p_dd_info.gross_weight := ROUND( l_new_wv_qty * l_gross_wt_pc ,5);
                 p_dd_info.net_weight   := ROUND( l_new_wv_qty * l_net_wt_pc ,5);
                 p_dd_info.volume       := ROUND( l_new_wv_qty * l_vol_pc ,5);
                 --
                 l_diff_dd_gross_weight := l_diff_dd_gross_weight - p_dd_info.gross_weight;
                 l_diff_dd_net_weight   := l_diff_dd_net_weight - p_dd_info.net_weight;
                 l_diff_dd_volume       := l_diff_dd_volume - p_dd_info.volume;
                 --
              --}
              ELSE
              --{
                 p_dd_info.gross_weight := 0;
                 p_dd_info.net_weight   := 0;
                 p_dd_info.volume       := 0;
              --}
              END IF;
              --
              --
              IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'p_dd_info:l_net_wt '||p_dd_info.net_weight||' l_gross_wt '||p_dd_info.gross_weight||' l_vol '||p_dd_info.volume);
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_diff_dd-Curr:l_net_wt '||l_diff_dd_net_weight||' l_gross_wt '||l_diff_dd_gross_weight||' l_vol '||l_diff_dd_volume);
              END IF;
            --}

          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_NEW_DETAIL_FROM_OLD',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
	  -- Calling WSH_DELIVERY_DETAILS_PKG.CREATE_NEW_DETAIL_FROM_OLD() to create new delivery detail
	  -- from old.

          WSH_DELIVERY_DETAILS_PKG.CREATE_NEW_DETAIL_FROM_OLD(
               p_delivery_detail_rec   => p_dd_info,
               --p_delivery_detail_id    => p_dd_rec.del_detail_id_tab(k),
               p_delivery_detail_id    => p_dd_rec.parent_delivery_detail_id_tab(p_dd_rec.child_index_tab(k)),
               x_row_id                          => x_row_id,
               x_delivery_detail_id    =>  x_delivery_detail_id,
               x_return_status              => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'x_delivery_detail_id-new split ddid',x_delivery_detail_id);
            WSH_DEBUG_SV.log(l_module_name,'requested qty of record inserted is',p_dd_info.requested_quantity);
            WSH_DEBUG_SV.log(l_module_name,'received qty of record inserted is',p_dd_info.received_quantity);
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);


              l_delivery_detail_id := x_delivery_detail_id;

          -- Create delivery assignments for the newly created delivery detail

            p_dd_assign_info.delivery_detail_id := l_delivery_detail_id;
                 p_dd_rec.del_detail_id_tab(p_dd_rec.child_index_tab(k)) := l_delivery_detail_id;

                 IF p_dd_rec.delivery_id_tab(p_dd_rec.child_index_tab(k)) IS NOT NULL
                 THEN
                 --{
                     p_dd_assign_info.delivery_id := p_dd_rec.delivery_id_tab(p_dd_rec.child_index_tab(k));
                 ELSE
                     p_dd_assign_info.delivery_id := NULL;
                 END IF;
                 --}
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.CREATE_DELIVERY_ASSIGNMENTS',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 WSH_DELIVERY_DETAILS_PKG.Create_Delivery_Assignments(
            p_delivery_assignments_info => p_dd_assign_info,
            x_rowid                     => x_rowid,
            x_delivery_assignment_id    => x_delivery_assignment_id,
            x_return_status             => l_return_status);
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

         END IF; -- End if for released status
         --}

       -- mark the records both child and parent as Processed so that they are not
       -- eligible for reprocessing as we traverse in the loop.

        p_dd_rec.process_asn_rcv_flag_tab(k) := 'X';
        p_dd_rec.process_asn_rcv_flag_tab(p_dd_rec.child_index_tab(k)) := 'X';


        --Update l_remaining_qty with the remaining qty to be shipped and return
        --to vendor qty of child.

       IF l_child_remaining_qty > 0 THEN
          l_remaining_qty := l_remaining_qty + (l_child_remaining_qty + nvl(l_child_rtv_qty_to_consolidate,0));
       ELSE
          l_remaining_qty := l_remaining_qty + nvl(l_child_rtv_qty_to_consolidate,0);
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_remaining_qty',l_remaining_qty);
         WSH_DEBUG_SV.log(l_module_name,'l_child_rtv_qty_to_consolidate',l_child_rtv_qty_to_consolidate);
       END IF;

       --Reset k to the child index of present record.
       --}
       END IF;-- end if for asn_rec_flag for child
       --
       -- This should be outside if, otherwise will result into infinite loop
       --
       k := p_dd_rec.child_index_tab(k);
      END LOOP; --While loop ends here.

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'outside child index recvursive loop');
      END IF;

      --Add Parent rtv quantity to remaining quantity for consolidation.

      l_remaining_qty := l_remaining_qty + nvl(p_dd_rec.returned_qty_tab(i),0);

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_remaining_qty',l_remaining_qty);
        WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.returned_qty_tab(i)',p_dd_rec.returned_qty_tab(i));
      END IF;

      --Check if remaining quantity is greater than zero.

      IF nvl(l_remaining_qty,0) > 0 THEN
      -- Consolidate all the open quantities agains the same po line location to insert one
      -- record at the end into wsh_delivery_details.
      --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit Consolidate_qty',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        consolidate_qty(
          p_sli_qty_cache       => l_sli_qty_cache,
          p_sli_qty_ext_cache   => l_sli_qty_ext_cache,
          p_remaining_qty       => l_remaining_qty,
          po_shipment_line_id   => p_dd_rec.po_line_location_id_tab(i),
          x_return_status       => l_return_status);
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

      END IF;--For remaining qty.
      --}

    ELSE--child Index.
      -- Process p_dd_rec records whose child index is null.
      IF p_dd_rec.del_detail_id_tab(i) is not NULL THEN
      -- bulk update those records whose delivery detail id is not null in p_dd_rec.
      -- This is done by populating l_updae_dd_rec structure which is later used for bulk update.
      --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit populate_update_dd_rec',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        populate_update_dd_rec(
          p_dd_rec       => p_dd_rec,
          p_index        => i,
          p_line_rec     => p_line_rec,
          p_gross_weight  => l_old_dd_gross_weight,
          p_net_weight  => l_old_dd_net_weight,
          p_volume  => l_old_dd_volume,
          x_release_status => l_release_status,
          l_update_dd_rec  => l_update_dd_rec,
          x_lpnIdCacheTbl  => l_lpnIdCacheTbl,
          x_lpnIdCacheExtTbl => l_lpnIdCacheExtTbl,
          x_return_status  => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

       --}
      ELSIF p_dd_rec.transaction_type = 'ASN'
                                                AND    nvl(p_dd_rec.shipped_qty_tab(i),0) = 0
                                                THEN
                                                --{ --- Added by NPARIKH

          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.shipped_qty_tab(i)', p_dd_rec.shipped_qty_tab(i));
           END IF;

                                                --}
      ELSIF p_dd_rec.transaction_type = 'RECEIPT'
                                                AND    nvl(p_dd_rec.received_qty_tab(i),0) = 0
                                                THEN
                                                --{ --- Added by NPARIKH

          IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.received_qty_tab(i)', p_dd_rec.received_qty_tab(i));
           END IF;

                                                --}
      ELSE
        -- delivery_detail_id is null.
	-- need to insert record into wdd.
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.POPULATE_ADDITIONAL_LINE_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
	-- Calling WSH_PO_CMG_PVT.populate_additional_line_info
        WSH_PO_CMG_PVT.populate_additional_line_info(
           p_line_rec                  => p_line_rec,
           p_index                     => p_dd_rec.shpmt_line_id_idx_tab(i),
           p_additional_line_info_rec  => l_additional_line_info_rec ,
           x_return_status             => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_BULK_PROCESS_PVT.BULK_INSERT_DETAILS - 2 ',WSH_DEBUG_SV.C_PROC_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'P_line_rec.requested_quantity is', P_line_rec.requested_quantity(p_dd_rec.shpmt_line_id_idx_tab(i)));
            WSH_DEBUG_SV.log(l_module_name,'P_line_rec.received_quantity is', P_line_rec.received_quantity(p_dd_rec.shpmt_line_id_idx_tab(i)));
            WSH_DEBUG_SV.log(l_module_name,'P_line_recs index is ', p_dd_rec.shpmt_line_id_idx_tab(i));
        END IF;
        --
        l_action_prms.org_id := p_line_rec.org_id(p_dd_rec.shpmt_line_id_idx_tab(i));

        p_line_rec.requested_quantity_uom(p_dd_rec.shpmt_line_id_idx_tab(i)) :=
                       p_dd_rec.requested_qty_uom_tab(i);

        p_line_rec.requested_quantity_uom2(p_dd_rec.shpmt_line_id_idx_tab(i)) :=
                       p_dd_rec.requested_qty_uom2_tab(i);
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.requested_quantity_uom 3rd occurance ', p_dd_rec.requested_qty_uom_tab(i));
        END IF;

        -- Calling WSH_BULK_PROCESS_PVT.bulk_insert_details

        WSH_BULK_PROCESS_PVT.bulk_insert_details (
          P_line_rec       => P_line_rec,
          p_index          => p_dd_rec.shpmt_line_id_idx_tab(i),
          p_action_prms    => l_action_prms,--change by arun
          p_additional_line_info_rec => l_additional_line_info_rec,
          X_return_status  => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);

        IF p_dd_rec.delivery_id_tab(i) is NOT NULL THEN
        --
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'updating WDA-#2');
           WSH_DEBUG_SV.log(l_module_name,'p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i))',p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i)));
         END IF;
         -- updating delivery assignments

         update wsh_delivery_assignments_v
         set delivery_id = p_dd_rec.delivery_id_tab(i),
                 last_update_date = SYSDATE,
               last_updated_by =  FND_GLOBAL.USER_ID,
               last_update_login =  FND_GLOBAL.LOGIN_ID
         where delivery_detail_id = p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i));
        END IF;
        --
        p_dd_rec.del_detail_id_tab(i) := p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i));
        p_line_rec.delivery_detail_id(p_dd_rec.shpmt_line_id_idx_tab(i)):= NULL;
        p_dd_rec.last_update_date_tab(i) := NULL;

	IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit populate_update_dd_rec',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

	-- Once delviery detail is created, populate the l_update_dd_rec to do the bulk_update at the end

        populate_update_dd_rec(
          p_dd_rec       => p_dd_rec,
          p_index        => i,
          p_line_rec     => p_line_rec,
          x_release_status => l_release_status,
          l_update_dd_rec  => l_update_dd_rec,
          x_lpnIdCacheTbl  => l_lpnIdCacheTbl,
          x_lpnIdCacheExtTbl => l_lpnIdCacheExtTbl,
          x_return_status  => l_return_status);

      END IF;
      --}
       p_dd_rec.process_asn_rcv_flag_tab(i) := 'X';

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.requested_qty_tab(i)', p_dd_rec.requested_qty_tab(i));
          WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.received_qty_tab(i)', p_dd_rec.received_qty_tab(i));
      END IF;
       IF p_dd_rec.transaction_type = 'ASN' THEN
      --{
               l_pending_qty := (nvl(p_dd_rec.requested_qty_tab(i),0) -
                          nvl(p_dd_rec.shipped_qty_tab(i),0));
      ELSIF p_dd_rec.transaction_type = 'RECEIPT' then
        l_pending_qty := (nvl(p_dd_rec.requested_qty_tab(i),0) -
                          nvl(p_dd_rec.received_qty_tab(i),0));
      END IF;
      --]

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_pending_qty',l_pending_qty);
       WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.returned_qty_tab(i)',p_dd_rec.returned_qty_tab(i));
     END IF;

     IF l_pending_qty > 0 THEN
      --{
        l_remaining_qty1 := nvl(p_dd_rec.returned_qty_tab(i),0) + l_pending_qty;
      ELSE
        l_remaining_qty1 := nvl(p_dd_rec.returned_qty_tab(i),0);
      END IF;
      --}
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_remaining_qty1',l_remaining_qty1);
      END IF;
      --
      IF nvl(l_remaining_qty1,0) > 0 THEN
      -- Consolidate all the open quantities of the same po line location.
      --{
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit consolidate_qty',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        consolidate_qty(
          p_sli_qty_cache       => l_sli_qty_cache,
          p_sli_qty_ext_cache   => l_sli_qty_ext_cache,
          p_remaining_qty       => l_remaining_qty1,
          po_shipment_line_id   => p_dd_rec.po_line_location_id_tab(i),
          x_return_status       => l_return_status);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
           p_return_status => l_return_status,
           x_num_warnings  => l_num_warnings,
           x_num_errors    => l_num_errors);
      END IF; --For remaining qty1.
      --}
    END IF;--Child index
    --}

            --{ --NNP-WV
              --
              --
              IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_line_rec:wv_frozen_flag '||l_line_rec.wv_frozen_flag);
                   WSH_DEBUG_SV.logmsg(l_module_name, 'l_diff_dd-final:l_net_wt '||l_diff_dd_net_weight||' l_gross_wt '||l_diff_dd_gross_weight||' l_vol '||l_diff_dd_volume);
              END IF;
              --
                IF l_line_rec.wv_frozen_flag = 'Y'
                THEN
                --{
                    IF l_diff_dd_gross_weight > 0
                    OR l_diff_dd_net_weight > 0
                    OR l_diff_dd_volume > 0
                    THEN
                    --{
                        IF l_line_rec.parent_delivery_detail_id IS NOT NULL
                        THEN
                        --{
                           IF l_line_rec.lpn_wv_frozen_flag <> 'Y'
                           THEN
                           --{
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.processWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            WSH_ASN_RECEIPT_PVT.processWeightVolume
                               (
                                 p_delivery_lpn_id            => l_line_rec.parent_delivery_detail_id,
                                 p_diff_gross_weight          => l_diff_dd_gross_weight,
                                 p_diff_net_weight            => l_diff_dd_net_weight,
                                 p_diff_volume                => l_diff_dd_volume,
                                 x_GWTcachetbl                => l_lpnGWTcachetbl,
                                 x_GWTcacheExttbl             => l_lpnGWTcacheExttbl,
                                 x_NWTcachetbl                => l_lpnNWTcachetbl,
                                 x_NWTcacheExttbl             => l_lpnNWTcacheExttbl,
                                 x_VOLcachetbl                => l_lpnVOLcachetbl,
                                 x_VOLcacheExttbl             => l_lpnVOLcacheExttbl,
                                 x_return_status              => l_return_status
                               );
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            wsh_util_core.api_post_call
                              (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                              );
                           --}
                           END IF;
                        --}
                        ELSIF l_line_rec.delivery_id IS NOT NULL
                        AND l_line_rec.dlvy_wv_frozen_flag <> 'Y'
                        THEN
                        --{
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.processWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            WSH_ASN_RECEIPT_PVT.processWeightVolume
                               (
                                 p_delivery_lpn_id            => l_line_rec.delivery_id,
                                 p_diff_gross_weight          => l_diff_dd_gross_weight,
                                 p_diff_net_weight            => l_diff_dd_net_weight,
                                 p_diff_volume                => l_diff_dd_volume,
                                 x_GWTcachetbl                => l_dlvyGWTcachetbl,
                                 x_GWTcacheExttbl             => l_dlvyGWTcacheExttbl,
                                 x_NWTcachetbl                => l_dlvyNWTcachetbl,
                                 x_NWTcacheExttbl             => l_dlvyNWTcacheExttbl,
                                 x_VOLcachetbl                => l_dlvyVOLcachetbl,
                                 x_VOLcacheExttbl             => l_dlvyVOLcacheExttbl,
                                 x_return_status              => l_return_status
                               );
                            --
                            IF l_debug_on THEN
                                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
                            END IF;
                            --
                            wsh_util_core.api_post_call
                              (
                                p_return_status => l_return_status,
                                x_num_warnings  => l_num_warnings,
                                x_num_errors    => l_num_errors
                              );
                        --}
                        END IF;
                    --}
                    END IF;
                --}
                END IF;
            --}
  END IF;--Process Flag
  --}
-- arun's change



IF (p_dd_rec.process_asn_rcv_flag_tab(i) ='X')
AND ( p_dd_rec.del_detail_id_tab(i) IS NOT NULL )
THEN
 -- populate the local dd rec structure from p_dd_rec for those records for which
 -- the process_asn_rcv_flag is 'X'.

 --kk is the index of the local dd_rec
  kk :=  l_local_dd_rec.COUNT + 1;

  l_local_dd_rec(kk).del_detail_id            := p_dd_rec.del_detail_id_tab(i);
  l_local_dd_rec(kk).delivery_id               := p_dd_rec.delivery_id_tab(i);
  l_local_dd_rec(kk).shipment_line_id          := p_dd_rec.shipment_line_id_tab(i);
  l_local_dd_rec(kk).shpmt_line_id_idx         := p_dd_rec.shpmt_line_id_idx_tab(i);
  l_local_dd_rec(kk).transaction_type          := p_dd_rec.transaction_type;
  l_local_dd_rec(kk).shipment_header_id        := p_dd_rec.shipment_header_id;
  l_local_dd_rec(kk).bol                       := p_line_rec.bill_of_lading(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).lpn_id                       := p_line_rec.lpn_id(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).lpn_name                       := NULL;
  l_local_dd_rec(kk).psno                        := p_line_rec.packing_slip_number(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).waybill                       := p_line_rec.tracking_number(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).trip_id                        := p_dd_rec.trip_id_tab(i);
  l_local_dd_rec(kk).truck_num                 := p_line_rec.truck_num(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).rcv_gross_weight          := p_line_rec.rcv_gross_weight(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).rcv_gross_weight_uom_code := p_line_rec.rcv_gross_weight_uom_code(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).rcv_net_weight            := p_line_rec.rcv_net_weight(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).rcv_net_weight_uom_code   := p_line_rec.rcv_net_weight_uom_code(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).rcv_Tare_weight           := p_line_rec.rcv_Tare_weight(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).rcv_Tare_weight_uom_code  := p_line_rec.rcv_Tare_weight_uom_code(l_local_dd_rec(kk).shpmt_line_id_idx);

  l_local_dd_rec(kk).schedule_ship_date := p_line_rec.schedule_ship_date(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).initial_pickup_date    :=  p_line_rec.shipped_date(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).expected_receipt_date  :=  p_line_rec.expected_receipt_date(l_local_dd_rec(kk).shpmt_line_id_idx);
  l_local_dd_rec(kk).rcv_carrier_id  :=  p_line_rec.rcv_carrier_id(l_local_dd_rec(kk).shpmt_line_id_idx);



  -- populate the trip_id field based on
  -- as trip_id returned if we get the trip id corresponding to the last leg of this delivery
  --

  IF p_dd_rec.delivery_id_tab(i) IS NOT NULL THEN
    OPEN get_delivery_info(p_dd_rec.delivery_id_tab(i));
    FETCH get_delivery_info INTO l_trip_id;

        IF get_delivery_info%FOUND THEN

            l_local_dd_rec(kk).trip_id  := l_trip_id;
            p_dd_rec.trip_id_tab(i)    := l_trip_id;

        ELSIF get_delivery_info%NOTFOUND THEN

           OPEN  c_has_del_leg(p_dd_rec.delivery_id_tab(i));
           FETCH c_has_del_leg INTO l_temp_char;

           IF c_has_del_leg%FOUND THEN

               l_local_dd_rec(kk).trip_id  := -1;
               p_dd_rec.trip_id_tab(i)    := -1;

           ELSIF c_has_del_leg%NOTFOUND THEN

               l_local_dd_rec(kk).trip_id := NULL;
               p_dd_rec.trip_id_tab(i)   := NULL;

           END IF;

           CLOSE c_has_del_leg;
        END IF;
    CLOSE  get_delivery_info;
  END IF;



  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.transaction_type        ',p_dd_rec.transaction_type);
    WSH_DEBUG_SV.log(l_module_name,'$$$$$$$$$$$$ ',l_return_status);
    WSH_DEBUG_SV.log(l_module_name,'delivery_id  ',l_local_dd_rec(kk).delivery_id);
    WSH_DEBUG_SV.log(l_module_name,'del_detail_id',l_local_dd_rec(kk).del_detail_id);
    WSH_DEBUG_SV.log(l_module_name,'index        ',kk);
    WSH_DEBUG_SV.log(l_module_name,'trip_id      ',l_local_dd_rec(kk).trip_id);
  END IF;

  IF p_dd_rec.transaction_type = 'RECEIPT'
  THEN
  --{
     l_parent_wdd_id := NULL;
     --
     --
     FOR packed_rec IN packed_csr(l_local_dd_Rec(kk).del_detail_id)
     LOOP
         l_parent_wdd_id := packed_rec.parent_Delivery_detail_id;
     END LOOP;
     --
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_local_dd_rec(kk).del_detail_id        ',l_local_dd_rec(kk).del_detail_id);
         WSH_DEBUG_SV.log(l_module_name,'l_parent_wdd_id        ',l_parent_wdd_id);
     END IF;
     --
     --
     IF l_parent_wdd_id IS NOT NULL
     THEN
        l_local_dd_rec(kk).lpn_id := NULL;
     END IF;
  --}
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_local_dd_rec(kk).lpn_id        ',l_local_dd_rec(kk).lpn_id);
  END IF;

  IF l_local_dd_rec(kk).lpn_id IS NOT NULL
  THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.GET_OUTERMOST_LPN',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    -- Goods can me packed in multiple containers.
    -- So the lpn id that is passed need not necessary be the outermost lpn.
    -- So we derive the outermost lpn using the GET_OUTERMOST_LPN API.

    WSH_INBOUND_UTIL_PKG.GET_OUTERMOST_LPN(
        p_lpn_id => l_local_dd_rec(kk).lpn_id,
        p_shipment_header_id => l_local_dd_rec(kk).shipment_header_id,
        p_lpn_context => 7,
        x_outermost_lpn => l_outermost_lpn,
        x_outermost_lpn_name => l_outermost_lpn_name,
        x_return_status => l_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call(
       p_return_status => l_return_status,
       x_num_warnings  => l_num_warnings,
       x_num_errors    => l_num_errors);

    IF l_outermost_lpn IS NOT NULL THEN
     l_local_dd_rec(kk).lpn_id := l_outermost_lpn;
     l_local_dd_rec(kk).lpn_name := l_outermost_lpn_name;
    END IF;

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_local_dd_rec(kk).lpn_id        ',l_local_dd_rec(kk).lpn_id);
       WSH_DEBUG_SV.log(l_module_name,'l_local_dd_rec(kk).lpn_name        ',l_local_dd_rec(kk).lpn_name);
     END IF;

  END IF;


  --IF BOL IS NULL THEN THIS IS DONE TO AVOID THE CREATION OF MULTIPLE DELIVERY IDS
  --FOR A DELIVERY ID HAVING MORE THAN ONE NULL BOL.


  IF  l_local_dd_rec(kk).delivery_id  IS NULL THEN
    -- collecting del det ids . key will be the index and value will be del det id
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_index_dd_ids_cache',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.get_cached_value(
      p_cache_tbl       => l_index_dd_ids_cache,
      p_cache_ext_tbl   => l_index_dd_ids_ext_cache,
      p_value           => l_local_dd_rec(kk).del_detail_id ,
      p_key             =>  kk,
      p_action          => 'PUT',
      x_return_status   => l_return_status);
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
       raise FND_API.G_EXC_ERROR;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR -- Added by NPARIKH
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSIF l_local_dd_rec(kk).trip_id IS NULL THEN
    --COOLECTING ALL THOSE DELIVERY IDS WHICH HAVE NULL TRIP IDS
    --FOR CREATING TRIPS AT INITILIZE
    --HERE THERE WIL BE TWO CALLS TO GET CACHED VALUE
    --THE FIRST ONE IS FOR COLLECTING THE INDEX AND THE DELIVERY IDS
    --SO FOR THIS ONE THE P_KEY WILL BE THE INDEX AND THE P_VALUE
    --WILL BE THE DELIVERY ID..THIS WILL HAVE DUPLICATE VALUES IN THE
    --P_VALUE I.E DUPLICATE DELIVERY IDS..
    --THE SECOND GET CACHE VALUE WILL HAVE BOTH THE P_KEY AND P_VALUE
    --AS THE DELIVERY ID ITSELF, SINCE ONLY FROM THIS THE DELIVERY IDS
    --WILL BE COLLECTED AND SENT TO AUTOCREATE TRIPS AT DELIVERY LEVEL.

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_index_del_ids_cache',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.get_cached_value(
      p_cache_tbl       => l_index_del_ids_cache,
      p_cache_ext_tbl   => l_index_del_ids_ext_cache,
      p_value           => l_local_dd_rec(kk).delivery_id,
      p_key             => kk,
      p_action          => 'PUT',
      x_return_status   => l_return_status);
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR -- Added by NPARIKH
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_del_ids_del_ids_cache',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.get_cached_value(
      p_cache_tbl       => l_del_ids_del_ids_cache,
      p_cache_ext_tbl   => l_del_ids_del_ids_ext_cache,
      p_value           => l_local_dd_rec(kk).delivery_id,
      p_key             => l_local_dd_rec(kk).delivery_id,
      p_action          => 'PUT',
      x_return_status   => l_return_status);
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR -- Added by NPARIKH
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  IF   l_local_dd_rec(kk).delivery_id IS NOT NULL THEN

    --start of code for bug # 3179040
    --collecting unique delivery ids which are to be passed to unassign_open_det_from_del
    --from the Initilize_txns API.
    l_uniq_del_ids_tab(l_local_dd_rec(kk).delivery_id) := l_local_dd_rec(kk).delivery_id;
    --end of code for bug # 3179040

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-l_del_reprice_tbl',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.get_cached_value(
      p_cache_tbl       => l_del_reprice_tbl,
      p_cache_ext_tbl   => l_del_reprice_ext_tbl,
      p_value           => l_local_dd_rec(kk).delivery_id,
      p_key             => l_local_dd_rec(kk).delivery_id,
      p_action          => 'PUT',
      x_return_status   => l_return_status);
    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR -- Added by NPARIKH
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

--
  --end of arun's change
END IF;-- end if of process_ans_rcv_flag
END LOOP;--For p_dd_rec

j := 1;
l_ind := l_del_reprice_tbl.FIRST;
WHILE l_ind IS NOT NULL
LOOP
  l_del_ids_tab(j) := l_del_reprice_tbl(l_ind).value;
  j := j + 1;
  l_ind := l_del_reprice_tbl.NEXT(l_ind);
END LOOP;
l_ind := l_del_reprice_ext_tbl.FIRST;
WHILE l_ind IS NOT NULL
LOOP
  l_del_ids_tab(j) := l_del_reprice_ext_tbl(l_ind).value;
  j := j + 1;
  l_ind := l_del_reprice_ext_tbl.NEXT(l_ind);
END LOOP;

-- Once deliveries has been reconfigured, need to reprice the delivery.
-- The unique list of deliveries is collected in l_del_ids_tab structure.
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_ACTIONS.MARK_REPRICE_REQUIRED',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
  p_entity_type     => 'DELIVERY',
  p_entity_ids      => l_del_ids_tab,
  p_consolidation_change => 'N',
  x_return_status        => l_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_util_core.api_post_call(
   p_return_status => l_return_status,
   x_num_warnings  => l_num_warnings,
   x_num_errors    => l_num_errors);



IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'UPDATING WDD-Main');
    WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.delivery_detail_id.COUNT',l_update_dd_rec.delivery_detail_id.COUNT);
    l_itemp := l_update_dd_rec.delivery_detail_id.first;
    while l_itemp is not null
    loop
      WSH_DEBUG_SV.log(l_module_name,'l_itemp',l_itemp);
      WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.requested_quantity(l_itemp)',l_update_dd_rec.requested_quantity(l_itemp));
      WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.received_quantity(l_itemp)',l_update_dd_rec.received_quantity(l_itemp));
      WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.delivery_detail_id(l_itemp)',l_update_dd_rec.delivery_detail_id(l_itemp));
      WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.released_status(l_itemp)',l_update_dd_rec.released_status(l_itemp));
      WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.released_status_db(l_itemp)',l_update_dd_rec.released_status_db(l_itemp));
      WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.gross_weight(l_itemp)',l_update_dd_rec.gross_weight(l_itemp));
      WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.net_weight(l_itemp)',l_update_dd_rec.net_weight(l_itemp));
      WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.volume(l_itemp)',l_update_dd_rec.volume(l_itemp));
    WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.ship_from_location_id(l_itemp)',l_update_dd_rec.ship_from_location_id(l_itemp));
    WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.last_update_date(l_itemp)',l_update_dd_rec.last_update_date(l_itemp));
     l_itemp := l_update_dd_rec.delivery_detail_id.next(l_itemp);
    end loop;
END IF;
--
-- Bulk updating all the delivery_detail records using the l_update_dd_rec which was populated in the
-- main loop above.

FORALL i in 1..l_update_dd_rec.delivery_detail_id.COUNT
   update wsh_delivery_details
   set requested_quantity       = l_update_dd_rec.requested_quantity(i),
       shipped_quantity         = l_update_dd_rec.shipped_quantity(i),
       returned_quantity        = l_update_dd_rec.returned_quantity(i),
       received_quantity        = l_update_dd_rec.received_quantity(i),
       requested_quantity2      = l_update_dd_rec.requested_quantity2(i),
       shipped_quantity2        = l_update_dd_rec.shipped_quantity2(i),
       returned_quantity2       = l_update_dd_rec.returned_quantity2(i),
       received_quantity2       = l_update_dd_rec.received_quantity2(i),
       released_status          = l_update_dd_rec.released_status(i),
       rcv_shipment_line_id     = l_update_dd_rec.rcv_shipment_line_id(i),
       inventory_item_id        = l_update_dd_rec.inventory_item_id(i),
       ship_from_location_id    = NVL(l_update_dd_rec.ship_from_location_id(i),ship_from_location_id),
       item_description         = l_update_dd_rec.item_description(i),
       tracking_number          = l_update_dd_rec.waybill_num(i),
       gross_weight             = NVL(l_update_dd_rec.gross_weight(i), gross_weight),
       net_weight               = NVL(l_update_dd_rec.net_weight(i), net_weight),
       volume                   = NVL(l_update_dd_rec.volume(i), volume),
       earliest_pickup_date     = NVL(earliest_pickup_date, l_update_dd_rec.shipped_date(i)),
       latest_pickup_date       = NVL(latest_pickup_date, l_update_dd_rec.shipped_date(i)),
       last_update_date = SYSDATE,
       last_updated_by =  FND_GLOBAL.USER_ID,
       last_update_login =  FND_GLOBAL.LOGIN_ID
       where delivery_detail_id = l_update_dd_rec.delivery_detail_id(i)
       and   released_status    = l_update_dd_rec.released_status_db(i)
       AND   last_update_date   = NVL(l_update_dd_rec.last_update_date(i), last_update_date)
       RETURNING delivery_detail_id BULK COLLECT INTO l_detail_tab;

IF SQL%ROWCOUNT <> l_update_dd_rec.delivery_detail_id.COUNT THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'NUMBER OF ROWS UPDATED IS NOT EQUAL TO THE NUMBER OF ROWS THAT HAD TO BE BULK UPDATED');
     WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT',SQL%ROWCOUNT);
     WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.delivery_detail_id.COUNT',l_update_dd_rec.delivery_detail_id.COUNT);
   END IF;

   FND_MESSAGE.SET_NAME('WSH','WSH_DELIVERY_LINES_CHANGED');
   wsh_util_core.add_message(WSH_UTIL_CORE.G_RET_STS_ERROR,l_module_name);
   RAISE FND_API.G_EXC_ERROR;
END IF;
--
-- DBI Project
-- Update of wsh_delivery_details where requested_quantity/released_status
-- are changed, call DBI API after the update.
-- This API will also check for DBI Installed or not
IF l_debug_on THEN
 WSH_DEBUG_SV.log(l_module_name,'Calling DBI API. delivery details count l_detail_tab : ',l_detail_tab.count);
END IF;
WSH_INTEGRATION.DBI_Update_Detail_Log
 (p_delivery_detail_id_tab => l_detail_tab,
  p_dml_type               => 'UPDATE',
  x_return_status          => l_dbi_rs);

IF l_debug_on THEN
 WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
END IF;
IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
  x_return_status := l_dbi_rs;
  -- just pass this return status to caller API
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  ROLLBACK;
  return;
END IF;

-- End of Code for DBI Project
--

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_sli_qty_cache.COUNT',l_sli_qty_cache.COUNT);
END IF;
--
IF l_sli_qty_cache.COUNT > 0
OR l_sli_qty_ext_cache.COUNT > 0 THEN
-- populate the p_line_rec.consolidate_quantity with the consolidated qty for
-- particular po_line_location_id.
--{
p_line_rec.consolidate_quantity.EXTEND(p_line_rec.po_shipment_line_id.COUNT);

l_index :=  p_line_rec.po_shipment_line_id.FIRST;
IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_index',l_index);
END IF;
WHILE l_index IS NOT NULL
LOOP
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.get_cached_value(
    p_cache_tbl     =>  l_sli_qty_cache,
    p_cache_ext_tbl =>  l_sli_qty_ext_cache,
    p_value         =>  l_quantity,
    p_key           =>  p_line_rec.po_shipment_line_id(l_index),
    p_action        =>  'GET',
    x_return_status =>  l_return_status );

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p_line_rec.po_shipment_line_id(l_index)',p_line_rec.po_shipment_line_id(l_index));
    WSH_DEBUG_SV.log(l_module_name,'sli_qty_cache: l_quantity',l_quantity);
END IF;
--
  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_util_core.get_cached_value(
        p_cache_tbl     =>  l_sli_sli_cache,
        p_cache_ext_tbl =>  l_sli_sli_ext_cache,
        p_value         =>  l_shp_line_id,
        p_key           =>  p_line_rec.po_shipment_line_id(l_index),
        p_action        =>  'GET',
        x_return_status =>  l_return_status );

     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        p_line_rec.consolidate_quantity(l_index) := 0;

     ElSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING  THEN

        p_line_rec.consolidate_quantity(l_index) := l_quantity;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.get_cached_value(
           p_cache_tbl     =>  l_sli_sli_cache,
           p_cache_ext_tbl =>  l_sli_sli_ext_cache,
           p_value         =>  p_line_rec.po_shipment_line_id(l_index),
           p_key           =>  p_line_rec.po_shipment_line_id(l_index),
           p_action        =>  'PUT',
           x_return_status =>  l_return_status );
     ElSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
       raise FND_API.G_EXC_ERROR;
     ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR  THEN
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  ElSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
    raise FND_API.G_EXC_ERROR;
  ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR  THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN c_src_qty2(p_line_rec.line_id(l_index),p_line_rec.po_shipment_line_id(l_index)); --performance
  FETCH c_src_qty2
                into l_src_qty2,l_src_qty_uom2,
                     l_src_qty,l_src_qty_uom;
  CLOSE c_src_qty2;

/*
  OPEN c_sum_req_qty(p_line_rec.line_id(l_index),p_line_rec.po_shipment_line_id(l_index)); --performance
  FETCH c_sum_req_qty into l_sum_req_qty;
  CLOSE c_sum_req_qty;


  l_ratio := l_src_qty2/l_sum_req_qty;
*/

  l_ratio := l_src_qty2/l_src_qty;
-- HW OPMCONV - No need to use OPM precision. Use current INV which is 5
  p_line_rec.requested_quantity2(l_index)
          := ROUND(l_ratio*l_quantity,WSH_UTIL_CORE.C_MAX_DECIMAL_DIGITS_INV); -- RV DEC_QTY
  p_line_rec.requested_quantity_uom2(l_index)
          := l_src_qty_uom2;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_ratio',l_ratio);
    WSH_DEBUG_SV.log(l_module_name,'l_src_qty2',l_src_qty2);
    WSH_DEBUG_SV.log(l_module_name,'l_sum_req_qty',l_sum_req_qty);
    WSH_DEBUG_SV.log(l_module_name,'p_line_rec.requested_quantity2(l_index)',p_line_rec.requested_quantity2(l_index));
    WSH_DEBUG_SV.log(l_module_name,'l_src_qty_uom2',l_src_qty_uom2);
END IF;
--

  l_index := p_line_rec.po_shipment_line_id.NEXT(l_index);
END LOOP;

--l_action_prms.action_code  := p_dd_rec.transaction_type;

END IF;
--}

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.INITIALIZE_TXNS',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;


Initialize_txns(
  p_local_dd_rec    => l_local_dd_rec,
  p_index_dd_ids_cache => l_index_dd_ids_cache,
  p_index_dd_ids_ext_cache => l_index_dd_ids_ext_cache,
  p_index_del_ids_cache => l_index_del_ids_cache,
  p_index_del_ids_ext_cache => l_index_del_ids_ext_cache,
  p_del_ids_del_ids_cache => l_del_ids_del_ids_cache,
  p_del_ids_del_ids_ext_cache => l_del_ids_del_ids_ext_cache,
  p_uniq_del_ids_tab  =>  l_del_ids_tab,  -- changed by NPARIKH, l_uniq_del_ids_tab,
  p_action_prms   => p_action_prms,
		p_shipment_header_id => p_dd_Rec.shipment_header_id,
  x_return_status    => l_return_status) ;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_util_core.api_post_call(
  p_return_status => l_return_status,
  x_num_warnings  => l_num_warnings,
  x_num_errors    => l_num_errors);

IF l_sli_qty_cache.COUNT > 0
OR l_sli_qty_cache.COUNT > 0 THEN
--{
l_action_prms.action_code  := p_dd_rec.transaction_type;

-- Call Reapprove_PO API to insert new record into wsh_delivery_details
-- for the consolidated qty.
-- When this API is called with p_line_rec.consolidated_qty duly populated,
-- we set the case as increment in the REAPPROVE_PO API.
-- The Update_quantity API checks if there are any open delivery details record
-- present for the same po_line_location id.If present, it adds the
-- p_line_rec.consolidated_qty to the open delviery_detail.
-- If not, it creates a new records for the consolidated_qty.
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.REAPPROVE_PO',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
WSH_PO_CMG_PVT.Reapprove_PO(
  p_line_rec      => p_line_rec,
  p_action_prms   => l_action_prms,
  p_dd_list       => p_dd_list,
  x_return_status => l_return_status);


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_util_core.api_post_call(
   p_return_status => l_return_status,
   x_num_warnings  => l_num_warnings,
   x_num_errors    => l_num_errors);

END IF;
--}

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.RECONFIGURE_DEL_TRIPS',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;


Reconfigure_del_trips(
  p_local_dd_rec   => l_local_dd_rec,
  p_action_prms    => p_action_prms,
  x_lpnGWTcachetbl                => l_lpnGWTcachetbl,          --NNP-WV
  x_lpnGWTcacheExttbl             => l_lpnGWTcacheExttbl,
  x_lpnNWTcachetbl                => l_lpnNWTcachetbl,
  x_lpnNWTcacheExttbl             => l_lpnNWTcacheExttbl,
  x_lpnVOLcachetbl                => l_lpnVOLcachetbl,
  x_lpnVOLcacheExttbl             => l_lpnVOLcacheExttbl,
  x_dlvyGWTcachetbl                => l_dlvyGWTcachetbl,
  x_dlvyGWTcacheExttbl             => l_dlvyGWTcacheExttbl,
  x_dlvyNWTcachetbl                => l_dlvyNWTcachetbl,
  x_dlvyNWTcacheExttbl             => l_dlvyNWTcacheExttbl,
  x_dlvyVOLcachetbl                => l_dlvyVOLcachetbl,
  x_dlvyVOLcacheExttbl             => l_dlvyVOLcacheExttbl,
  p_shipment_header_id => p_dd_Rec.shipment_header_id,
  x_return_status  => l_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_util_core.api_post_call(
  p_return_status => l_return_status,
  x_num_warnings  => l_num_warnings,
  x_num_errors    => l_num_errors);


/* Commenting this as post_process will be now called in the wsh_ib_ui_recon_grp.match_shipemtns API.

  IF p_action_prms.caller not like 'WSH_IB_MATCH%' THEN
--{
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.post_process',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  WSH_INBOUND_TXN_HISTORY_PKG.post_process(
    p_shipment_header_id  => p_shipment_header_id,
    p_max_rcv_txn_id      => p_max_txn_id,
    p_action_code         => 'MATCHED',
    p_txn_type            => p_dd_rec.transaction_type,
    p_object_version_number => l_object_version_number,
    x_return_status       => l_return_status);

  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);
--}
END IF;
*/

For h in p_line_rec.header_id.FIRST..p_line_rec.header_id.LAST
LOOP
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p_line_rec.closed_flag(h)',p_line_rec.closed_flag(h));
    WSH_DEBUG_SV.log(l_module_name,'p_line_rec.closed_code(h)',p_line_rec.closed_code(h));
    WSH_DEBUG_SV.log(l_module_name,'p_line_rec.cancelled_flag(h)',p_line_rec.cancelled_flag(h));
END IF;
--
-- If PO has done a cancel/close operation on a particular record, and due to
-- the fact that the corresponding transaction was in pending status, it could not
-- be updated at that point of time, for such records, once the matching has been done,
-- the recrods need to be updated to the status of the corresponding po record.

/* For cancelled recrods also the closed code is populated as CLOSED.
   So instead of populating the cancel rec, the close rec is getting populated
   and the open lines are getting closed instead of cancelled.Putting additional
   check on the cancelled_flag to avoid this.*/

  IF ((p_line_rec.closed_code(h) = 'CLOSED' OR
      p_line_rec.closed_code(h) = 'CLOSED FOR RECEIVING' OR
      p_line_rec.closed_code(h) = 'FINALLY CLOSED') AND
      p_line_rec.cancelled_flag(h) <> 'Y')  THEN
  --{
     x_po_close_rec.header_id.EXTEND;
     x_po_close_rec.line_id.EXTEND;
     x_po_close_rec.po_shipment_line_id.EXTEND;
     x_po_close_rec.source_blanket_reference_id.EXTEND;

     x_po_close_rec.header_id(x_po_close_rec.header_id.COUNT)
        := p_line_rec.header_id(h);
     x_po_close_rec.line_id(x_po_close_rec.header_id.COUNT )
        := p_line_rec.line_id(h);
     x_po_close_rec.po_shipment_line_id(x_po_close_rec.header_id.COUNT)
        := p_line_rec.po_shipment_line_id(h);
     x_po_close_rec.source_blanket_reference_id(x_po_close_rec.header_id.COUNT)
        := p_line_rec.source_blanket_reference_id(h);
  ELSIF p_line_rec.cancelled_flag(h) = 'Y' THEN

     x_po_cancel_rec.header_id.EXTEND;
     x_po_cancel_rec.line_id.EXTEND;
     x_po_cancel_rec.po_shipment_line_id.EXTEND;
     x_po_cancel_rec.source_blanket_reference_id.EXTEND;

     x_po_cancel_rec.header_id(x_po_cancel_rec.header_id.COUNT)
          := p_line_rec.header_id(h);
     x_po_cancel_rec.line_id(x_po_cancel_rec.header_id.COUNT )
        := p_line_rec.line_id(h);
     x_po_cancel_rec.po_shipment_line_id(x_po_cancel_rec.header_id.COUNT )
        := p_line_rec.po_shipment_line_id(h);
     x_po_cancel_rec.source_blanket_reference_id(x_po_cancel_rec.header_id.COUNT)
        := p_line_rec.source_blanket_reference_id(h);
  END IF;
  --}
END LOOP;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Process_Matched_Txns_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN OTHERS THEN
    ROLLBACK TO Process_Matched_Txns_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_ASN_RECEIPT_PVT.Process_Matched_Txns',l_module_name);


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Process_Matched_Txns;

/*========================================================================
-- PROCEDURE : Cancel_ASN
-- HISTORY   : Created the API.
--========================================================================*/
--Start of comments
-- API name :  Cancel_ASN
-- Type     : Private
-- Pre-reqs : None.
-- Function : From purchasing side we get the list of ASN_SHIPMENT_HEADER_ID
--            to be cancelled.Get all the delivery details for the
--            ASN_SHIPMENT_HEADER_ID having the RELEASED_STATUS as C.
--            Get the most recent data from the purchasing tables PO_HEADERS,
--            PO_LINES and PO_LINE_LOCATIONS which need to be propagated to
--            the delivery details becoming OPEN after the cancellation of
--            the ASN. Call Update_attributes(by calling Reapprove_PO) by passing the list of delivery
--            details on which the Purchasing attributes need to be propagated.
--            We need to unpack the delivery details getting OPENED from the
--            outermost LPN corresponding to the LPN_id and also unassign
--            the container from the delivery.
--            Get the list of deliveries, trips and trip stops for updating the status on the entities
-- Parameters :
-- IN OUT:
--  p_action_prms 	IN OUT NOCOPY 	WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type
--IN:
--  p_header_id 	IN 	NUMBER,
-- OUT:
--  x_return_status	 OUT NOCOPY 	VARCHAR2
--Cache Tables:
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |l_lpnGWTcachetbl           | LPN ID             | Gross Weight       |
--              |l_lpnGWTcacheExttbl        | LPN ID             | Gross Weight       |
--              -----------------------------------------------------------------------
--              |l_lpnNWTcachetbl           | LPN ID             | Net Weight         |
--              |l_lpnNWTcacheExttbl        | LPN ID             | Net Weight         |
--              -----------------------------------------------------------------------
--              |l_lpnVOLcachetbl           | LPN ID             | Volume             |
--              |l_lpnVOLcacheExttbl        | LPN ID             | Volume             |
--              -----------------------------------------------------------------------
--              |l_dlvyGWTcachetbl          | Delivery ID        | Gross Weight       |
--              |l_dlvyGWTcacheExttbl       | Delivery ID        | Gross Weight       |
--              -----------------------------------------------------------------------
--              |l_dlvyNWTcachetbl          | Delivery ID        | Net Weight         |
--              |l_dlvyNWTcacheExttbl       | Delivery ID        | Net Weight         |
--              -----------------------------------------------------------------------
--              |l_dlvyVOLcachetbl          | Delivery ID        | Volume             |
--              |l_dlvyVOLcacheExttbl       | Delivery ID        | Volume             |
--              -----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE Cancel_ASN(
p_header_id IN NUMBER,
p_action_prms IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
x_return_status OUT NOCOPY VARCHAR2) IS

/*Cursor c_get_dds(p_header_id NUMBER) IS
SELECT
Wdd.delivery_detail_id,
Wda.parent_delivery_detail_id,
wdd.po_shipment_line_id
FROM
WSH_DELIVERY_DETAILS WDD,
wsh_delivery_assignments_v WDA,
WSH_NEW_DELIVERIES WND
WHERE wdd.delivery_detail_id = wda.delivery_detail_id and
wdd.line_direction not in ('O','IO') and
Wda.delivery_id = wnd.delivery_id and
Wnd.asn_shipment_header_id = p_header_id;*/

-- Cursor to get the delivery_id associated with the asn_shipment_header_id
-- that is passed for cancellation.

Cursor c_get_deliveries(p_header_id NUMBER) IS
SELECT
Delivery_id
FROM
Wsh_new_deliveries
WHERE ASN_SHIPMENT_HEADER_ID = p_header_id;

l_line_rec  OE_WSH_BULK_GRP.line_rec_type;
l_max_txn_id   NUMBER;
l_dd_list        WSH_PO_CMG_PVT.dd_list_type;
l_Stop_ids        wsh_util_core.Id_Tab_Type;
l_Trip_ids        wsh_util_core.Id_Tab_Type;
l_Delivery_ids        wsh_util_core.Id_Tab_Type;
l_sf_locn_id_tbl  wsh_util_core.Id_Tab_Type;
l_picked_qty_tbl  wsh_util_core.Id_Tab_Type;
l_validate_flag VARCHAR2(1) := 'Y';
l_return_status VARCHAR2(1);
l_dd_list_count NUMBER;

l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_object_version_number  NUMBER;
--changes made by arun
l_initial_pickup_date_tab   wsh_util_core.Date_Tab_Type;
l_expected_receipt_date_tab wsh_util_core.Date_Tab_Type;
l_rcv_carrier_id_tab        wsh_util_core.Id_Tab_Type;
l_gross_weight_of_first  NUMBER;
l_net_weight_of_first    NUMBER;
l_shipment_header_id_tab wsh_util_core.id_Tab_Type;


l_dd_unassigned_tbl wsh_util_core.Id_Tab_Type;
l_wdd_tbl  wsh_util_core.Id_Tab_Type;

--changes made by arun
l_action_prms WSH_BULK_TYPES_GRP.action_parameters_rectype;
l_status  VARCHAR2(50);
l_txn_type   VARCHAR2(50);
l_local_ddrec  LOCAL_DD_REC_TABLE_TYPE;

l_unassign_action_prms WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
--
l_lpnGWTcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_lpnGWTcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
l_lpnNWTcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_lpnNWTcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
l_lpnVOLcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_lpnVOLcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
--
--
l_dlvyGWTcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_dlvyGWTcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
l_dlvyNWTcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_dlvyNWTcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;
l_dlvyVOLcachetbl               WSH_UTIL_CORE.key_value_tab_type;
l_dlvyVOLcacheExttbl            WSH_UTIL_CORE.key_value_tab_type;

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                       VARCHAR2(1); -- DBI Project

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_ASN';
--
BEGIN

--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_HEADER_ID',P_HEADER_ID);
END IF;
--
SAVEPOINT Cancel_ASN_PVT;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'updating WDD');
END IF;
--
  -- Updating the all the records in wsh_delivery_details
  -- corresponding to the shipment_header_id that is being passed
  -- for cancellation.

  UPDATE WSH_DELIVERY_DETAILS
  SET released_status = 'X',
  Shipped_quantity = NULL,
  received_quantity = NULL,
  shipped_quantity2 = NULL,
  received_quantity2 = NULL,
  rcv_shipment_line_id = NULL,
  LAST_UPDATE_DATE   = SYSDATE,
  LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
  LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
  where delivery_detail_id in (select wdd.delivery_detail_id
                              from wsh_delivery_details wdd,
                               wsh_delivery_assignments_v wda,
                              wsh_new_deliveries wnd
                              where wdd.delivery_detail_id = wda.delivery_detail_id
                              and wda.delivery_id = wnd.delivery_id
                                   and wnd.asn_shipment_header_id = p_header_id
                              and wdd.line_direction not in ('O','IO'))
  and released_status = 'C'
  returning delivery_detail_id,po_shipment_line_id,ship_from_location_id, picked_quantity
  BULK COLLECT INTO l_dd_list.delivery_detail_id,l_dd_list.po_shipment_line_id,l_sf_locn_id_tbl, l_picked_qty_tbl;
    -- DBI Project
    -- Update of wsh_delivery_details where requested_quantity/released_status
    -- are changed, call DBI API after the update.
    -- This API will also check for DBI Installed or not
    FOR i in 1..l_dd_list.delivery_detail_id.count LOOP
      l_detail_tab(i) :=  l_dd_list.delivery_detail_id(i) ;
    END LOOP;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Calling DBI API. delivery detail l_detail_tab count : ',l_detail_tab.count);
    END IF;
    WSH_INTEGRATION.DBI_Update_Detail_Log
     (p_delivery_detail_id_tab => l_detail_tab,
      p_dml_type               => 'UPDATE',
      x_return_status          => l_dbi_rs);
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
    END IF;
    IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_dbi_rs;
          rollback to Cancel_ASN_PVT;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
    END IF;
    -- End of Code for DBI Project
    --

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.REAPPROVE_PO',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   l_action_prms.action_code := 'CANCEL_ASN';

   -- Call Reapprove_PO with action code as 'CANCEL_ASN'.
   -- This will inturn call Update_Atributes to update the non quantity attributes.

   WSH_PO_CMG_PVT.Reapprove_PO(
     p_line_rec         => l_line_rec,
     p_action_prms      => l_action_prms,
     p_dd_list          => l_dd_list,
     x_return_status    => l_return_status);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_util_core.api_post_call(
     p_return_status => l_return_status,
     x_num_warnings  => l_num_warnings,
     x_num_errors    => l_num_errors);

    l_dd_list_count := l_dd_list.delivery_detail_id.COUNT;


   For v_get_deliveries IN c_get_deliveries(p_header_id)  LOOP
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.UNPACK_INBOUND_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
         WSH_DEBUG_SV.log(l_module_name,'delivery id',v_get_deliveries.delivery_id);
     END IF;
     --
     -- unpack the delivery.

     WSH_CONTAINER_ACTIONS.unpack_inbound_delivery(
       p_delivery_id  => v_get_deliveries.delivery_id,
       x_return_status  => l_return_status);

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_util_core.api_post_call(
       p_return_status => l_return_status,
       x_num_warnings  => l_num_warnings,
       x_num_errors    => l_num_errors);

       l_Delivery_ids(l_delivery_ids.count + 1) := v_get_deliveries.delivery_id;
   END LOOP;

   --
   FOR i in 1..l_dd_list.delivery_detail_id.count LOOP
     IF (l_sf_locn_id_tbl(i) = -1
         OR nvl(l_picked_qty_tbl(i),0) = 0
        )
     THEN
       -- Collect the list of delivery detail ids that needs to be unassigned from the delivery.
       l_dd_unassigned_tbl(l_dd_unassigned_tbl.count + 1) :=  l_dd_list.delivery_detail_id(i) ;
       l_wdd_tbl(l_wdd_tbl.count + 1) := l_dd_list.delivery_detail_id(i) ;

     END IF;

   END LOOP;

   IF l_dd_unassigned_tbl.COUNT > 0 THEN

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit  WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_MULTIPLE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

       l_unassign_action_prms        := p_action_prms;
       --l_unassign_action_prms.caller := wsh_util_core.C_IB_RECEIPT_PREFIX;
       l_unassign_action_prms.caller := wsh_util_core.C_IB_ASN_PREFIX;

       WSH_DELIVERY_DETAILS_ACTIONS.unassign_multiple_details(
                p_rec_of_detail_ids  =>  l_dd_unassigned_tbl,
                p_from_delivery      => 'Y',
                p_from_container     => 'N',
                x_return_status      =>  l_return_status,
                p_validate_flag      =>  'Y',
                p_action_prms        =>  l_unassign_action_prms);

       wsh_util_core.api_post_call(
               p_return_status => l_return_status,
               x_num_warnings  => l_num_warnings,
               x_num_errors    => l_num_errors);

   END IF;


    --

    --Call Update status by passing list of the deliveries, trips and trip stops.
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.UPDATE_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    update_status(
     p_action_prms   => p_action_prms,
     p_del_ids       => l_delivery_ids,
     p_trip_ids      => l_trip_ids,
     p_stop_ids      => l_stop_ids,
     p_shipment_header_id_tab => l_shipment_header_id_tab,
     p_initial_pickup_date_tab => l_initial_pickup_date_tab,
     p_expected_receipt_date_tab => l_expected_receipt_date_tab,
     p_rcv_carrier_id_tab        => l_rcv_carrier_id_tab,
     p_local_dd_rec              => l_local_ddrec,
     x_lpnGWTcachetbl                => l_lpnGWTcachetbl,          --NNP-WV
     x_lpnGWTcacheExttbl             => l_lpnGWTcacheExttbl,
     x_lpnNWTcachetbl                => l_lpnNWTcachetbl,
     x_lpnNWTcacheExttbl             => l_lpnNWTcacheExttbl,
     x_lpnVOLcachetbl                => l_lpnVOLcachetbl,
     x_lpnVOLcacheExttbl             => l_lpnVOLcacheExttbl,
     x_dlvyGWTcachetbl                => l_dlvyGWTcachetbl,
     x_dlvyGWTcacheExttbl             => l_dlvyGWTcacheExttbl,
     x_dlvyNWTcachetbl                => l_dlvyNWTcachetbl,
     x_dlvyNWTcacheExttbl             => l_dlvyNWTcacheExttbl,
     x_dlvyVOLcachetbl                => l_dlvyVOLcachetbl,
     x_dlvyVOLcacheExttbl             => l_dlvyVOLcacheExttbl,
     x_return_status => l_return_status);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_warnings  => l_num_warnings,
      x_num_errors    => l_num_errors);


  -- update the trips by passing delivery_ids.
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.SETTRIPSTOPSTATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_INBOUND_UTIL_PKG.setTripStopStatus(
        p_transaction_code => 'ASN',
        p_action_code      => 'CANCEL',
        p_delivery_id_tab  => l_delivery_ids,
        x_return_status    => l_return_status);

   wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_warnings  => l_num_warnings,
      x_num_errors    => l_num_errors);

-- Calling reprice API
   WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
      p_entity_type => 'DELIVERY',
      p_entity_ids   => l_delivery_ids,
      x_return_status => l_return_status);

   wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_warnings  => l_num_warnings,
      x_num_errors    => l_num_errors);

        IF l_wdd_tbl.count > 0
        THEN
-- Calling wt/vol API
   --WSH_WV_UTILS.Delivery_Weight_Volume(
      --p_del_rows           => l_delivery_ids,
                                                /* changed by Nikhil */
   WSH_WV_UTILS.detail_weight_volume(
      p_detail_rows           => l_wdd_tbl,
      p_override_flag        => 'Y',
      p_calc_wv_if_frozen  => 'N',
      x_return_status      => l_return_status);

   wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_warnings  => l_num_warnings,
      x_num_errors    => l_num_errors);
   --
        END IF;

   WSH_TP_RELEASE.calculate_cont_del_tpdates(
     p_entity        => 'DLVY',
     p_entity_ids    => l_delivery_ids,
     x_return_status => l_return_status);
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Return Status after calling calculate_cont_del_tpdates',l_return_status);
   END IF;
   --
   wsh_util_core.api_post_call(
     p_return_status    => l_return_status,
     x_num_warnings     => l_num_warnings,
     x_num_errors       => l_num_errors);


-- Call WSH_INBOUND_TXN_HISTORY_PKG.post_process() API to update the status in TXN_HISTORY_TABLe.
-- Pass 'CANCELLEd' as the status for cancel_asn and 'MAnual reconciliation reqd for revert_ASN.
-- Commenting out the call as per Nikhil's e-mail udpate.

/*  IF p_action_prms.action_code = 'CANCEL_ASN' then
    l_status := 'CANCEL';
    l_txn_type := 'ASN';
  ELSE
    --l_status := 'Manual Reconciliation Required';
    l_status := 'REVERT';
    l_txn_type := 'ASN';
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_TXN_HISTORY_PKG.POST_PROCESS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_INBOUND_TXN_HISTORY_PKG.post_process(
    p_shipment_header_id  => p_header_id,
    p_max_rcv_txn_id      => l_max_txn_id,
    p_action_code         => l_status,
    p_txn_type            => l_txn_type,
    p_object_version_number => l_object_version_number,
    x_return_status       => l_return_status);

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);
*/
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Cancel_ASN_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN OTHERS THEN
    ROLLBACK TO Cancel_ASN_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_ASN_RECEIPT_PVT.Cancel_ASN');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Cancel_ASN;


-- Start of comments
-- API name : unassign_open_det_from_del
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API finds the open delivery detail lines for the given input
--            deliveries (i/p parameter p_del_ids) and unassigns them from their
--            respective deliveries.
-- Parameters :
-- IN:
--		p_del_ids      IN wsh_util_core.id_tab_type
--                A table containing the list of delivery IDs for which the action
--                should be carried out.
--		p_action_prms  IN WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type
--                contains the action code ,the caller ,the transaction type etc.
-- IN OUT:
-- OUT:
--		x_return_status OUT NOCOPY  VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments

PROCEDURE unassign_open_det_from_del(
  p_del_ids      IN wsh_util_core.id_tab_type,
  p_action_prms  IN WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
  p_shipment_header_id         IN      NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2 ) IS

--Cursor to get the open lines for a Delivery ID.
cursor c_get_open_dds(p_del_id NUMBER) IS
SELECT
wdd.delivery_detail_id
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments_v wda
WHERE
wdd.delivery_detail_id = wda.delivery_detail_id AND
wda.delivery_id = p_del_id AND
wdd.released_status = 'X';

--Cursor to get the closed and open lines  for a given Delivery ID.
cursor c_get_open_closed_dds(v_del_id NUMBER) IS
SELECT
wdd.delivery_detail_id, nvl(wdd.container_flag,'N') container_flag
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments_v wda
WHERE
wdd.delivery_detail_id = wda.delivery_detail_id AND
wda.delivery_id = v_del_id AND
wdd.released_status in ('X', 'C');


--Cursor to get the shipped lines  for a given shipment header id
cursor c_get_shipped_dds(p_shipment_header_id NUMBER) IS
SELECT
wdd.delivery_detail_id, nvl(wdd.container_flag,'N') container_flag
FROM
wsh_delivery_details wdd,
wsh_delivery_assignments_v wda,
wsh_new_deliveries wnd
WHERE
wdd.delivery_detail_id = wda.delivery_detail_id AND
wda.delivery_id = wnd.delivery_id AND
wnd.asn_shipment_header_id = p_shipment_header_id AND
wdd.released_status in ( 'C')
and not exists
		(
    SELECT 1
    FROM   wsh_delivery_details wdd1,
           wsh_delivery_assignments_v wda1
    WHERE   wdd1.delivery_detail_id = wda1.delivery_detail_id
				AND     wda1.delivery_id = wnd.delivery_id
				AND     wdd1.released_status in ( 'L')
		);




lpn_ids_tab                 WSH_UTIL_CORE.ID_TAB_TYPE;
dd_ids_tab                 WSH_UTIL_CORE.ID_TAB_TYPE;
l_dd_id                    NUMBER;
l_delivery_flag        VARCHAR2(1) := 'Y';
l_return_status        VARCHAR2(1);
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
i                 NUMBER;
l_index          NUMBER;


l_unassign_action_prms WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_OPEN_DET_FROM_DEL';
--
BEGIN
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Caller',p_action_prms.caller);
    WSH_DEBUG_SV.log(l_module_name,'Action', p_action_prms.action_code);
    WSH_DEBUG_SV.log(l_module_name,'p_del_ids.count',p_del_ids.count);
    WSH_DEBUG_SV.log(l_module_name,'p_shipment_header_id',p_shipment_header_id);
END IF;
--
l_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

i := p_del_ids.FIRST;
WHILE i IS NOT NULL
LOOP

  --If action code is ASN, then only the lines with status 'X' are collected
  --to be unassigned from the delivery.
  IF p_action_prms.action_code = 'ASN' THEN
    FOR v_get_open_dds IN c_get_open_dds(p_del_ids(i)) LOOP
      dd_ids_tab(dd_ids_tab.COUNT+1) := v_get_open_dds.delivery_detail_id;

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'DD ID for unassign from dlvy:',v_get_open_dds.delivery_detail_id);
      END IF;
      --
    END LOOP;
  END IF;

  --If action code is Receipt, then only the lines with status 'X' or 'C' are
  --collected to be unassigned from the delivery.
  IF p_action_prms.action_code = 'RECEIPT' THEN
    FOR v_get_open_closed_dds IN c_get_open_closed_dds(p_del_ids(i)) LOOP

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'DD ID for unassign from dlvy:',v_get_open_closed_dds.delivery_detail_id);
          WSH_DEBUG_SV.log(l_module_name,'container flag for unassign from dlvy:',v_get_open_closed_dds.container_flag);
      END IF;
      --
      IF v_get_open_closed_dds.container_flag = 'Y'
      THEN
      --{
          lpn_ids_tab(lpn_ids_tab.COUNT+1) := v_get_open_closed_dds.delivery_detail_id;
      --}
      ELSE
      --{
          dd_ids_tab(dd_ids_tab.COUNT+1) := v_get_open_closed_dds.delivery_detail_id;
      --}
      END IF;
    END LOOP;
				--
				--
    IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Find any other deliveries shipped but not recieved');
    END IF;
				--
				--
    FOR v_get_shipped_dds IN c_get_shipped_dds(p_shipment_header_id) LOOP

      IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name,'DD ID for unassign from dlvy:',v_get_shipped_dds.delivery_detail_id);
          WSH_DEBUG_SV.log(l_module_name,'container flag for unassign from dlvy:',v_get_shipped_dds.container_flag);
      END IF;
      --
      IF v_get_shipped_dds.container_flag = 'Y'
      THEN
      --{
          lpn_ids_tab(lpn_ids_tab.COUNT+1) := v_get_shipped_dds.delivery_detail_id;
      --}
      ELSE
      --{
          dd_ids_tab(dd_ids_tab.COUNT+1) := v_get_shipped_dds.delivery_detail_id;
      --}
      END IF;

    END LOOP;
  END IF;

  i := p_del_ids.NEXT(i);
END LOOP;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'lpn_ids_tab.count',lpn_ids_tab.count);
END IF;

-- If true ->There are some LPNs to be unassigned from their respective deliveries.
-- Also the delivery detail IDs for which these are assigned as LPNs(parent delivery detail Id)
-- should be updated.
IF lpn_ids_tab.COUNT > 0
THEN
--{     --Deleting the rows in wsh_delivery_assignments_v corresponding to the selected LPNs.
        FORALL i IN lpn_ids_tab.FIRST..lpn_ids_tab.LAST
        DELETE wsh_delivery_assignments_v
        WHERE  delivery_detail_id = lpn_ids_tab(i);

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After delete LPN from WDA',SQL%ROWCOUNT);
        END IF;

        --Deleting the rows in WSH_DELIVERY_DETAILS corresponding to the selected LPNs.
        FORALL i IN lpn_ids_tab.FIRST..lpn_ids_tab.LAST
        DELETE WSH_DELIVERY_DETAILS
        WHERE  delivery_detail_id = lpn_ids_tab(i);

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After delete LPN from WDD',SQL%ROWCOUNT);
        END IF;

        --updating the rows in WDA for which the selected LPNs are parent Delivery Details.
        FORALL i IN lpn_ids_tab.FIRST..lpn_ids_tab.LAST
        UPDATE  wsh_delivery_assignments_v
        SET     parent_delivery_detail_id = NULL
        WHERE   parent_delivery_detail_id = lpn_ids_tab(i);

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'SQL%ROWCOUNT After update contents on WDD',SQL%ROWCOUNT);
        END IF;
--}
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'dd_ids_tab.count',dd_ids_tab.count);
END IF;
--

-- If true -> there are delivery details to be unassigned from thier
-- respective deliveries.
IF dd_ids_tab.count > 0 THEN
--{
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS
_ACTIONS.UNASSIGN_MULTIPLE_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

l_unassign_action_prms        := p_action_prms;
--l_unassign_action_prms.caller := wsh_util_core.C_IB_RECEIPT_PREFIX;
l_unassign_action_prms.caller := wsh_util_core.C_IB_ASN_PREFIX;

--Call API WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details.
WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Multiple_Details(
  P_REC_OF_DETAIL_IDS  =>  dd_ids_tab,
  P_FROM_delivery      =>  'Y',
  P_FROM_container     =>  'N',
  x_return_status      =>  l_return_status,
  p_validate_flag      =>  'Y',
  p_action_prms        =>  l_unassign_action_prms);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_util_core.api_post_call(
  p_return_status => l_return_status,
  x_num_warnings  => l_num_warnings,
  x_num_errors    => l_num_errors);

/*
i := p_del_ids.FIRST;
WHILE i IS NOT NULL
LOOP
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_PO_CMG_PVT.Log_Exception(
    p_entity_id      => p_del_ids(i),
    p_logging_entity_name    => 'DELIVERY_ID',
    p_exception_name => 'WSH_IB_DEL_CHANGE',
    x_return_status  =>  l_return_status);

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);

i := p_del_ids.NEXT(i);

END LOOP;
*/

--}
END IF;
x_return_status := l_return_status;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.UNASSIGN_OPEN_DET_FROM_DEL');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END unassign_open_det_from_del;



-- Start of comments
-- API name : initialize_txns
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API is meant to achieve the following purposes:
--
--                1.It prepares the dd_rec to have the following information like
--                delivery_id and trip id.
--                2.Once the structure is prepared, it identifies the unique
--                deliveries within the list and checks if the deliveries consist
--                of any delivery detail not yet shipped. It unassigns all those
--                delivery details.
--                3.For lines which have a delivery ID but not yet assigned to a
--                Trip, the API WSH_TRIPS_ACTIONS.autocreate_trip_multi to create Trips.
--                4.It identifies the delivery details having null delivery_ids.
--                Invokes WSH_TRIPS_ACTIONS.AUTOCREATE_DEL_TRIP for the entire list of Delivery details
--                so that all the records in the dd_rec structure become uniform
--                in all respect for  further treatment.
-- Parameters :
-- IN:
-- IN OUT:
--			p_local_dd_rec	          IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE
--			p_index_dd_ids_cache      IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--			   A key-value pair cache with the value as the delivery detail id and key
--			   as the index of the corresponding record in p_local_dd_rec.This contains
--			   those delivery detail ids for which both a delivery and a trip has to
--			   be created.The index is useful for populating the correct record in
--			   p_local_dd_rec, once the delivery and trip are created.
--			p_index_dd_ids_ext_cache  IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--			   A key-value pair cache with the value as the delivery detail id and key
--			   as the index of the corresponding record in p_local_dd_rec.This contains
--			   those delivery detail ids for which both a delivery and a trip has to
--			   be created.Records are stored in this cache if the key exceeds 2^31.
--			   The index is useful for populating the correct record in p_local_dd_rec,
--			   once the delivery and trip are created.
--			p_index_del_ids_cache     IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--			   A key-value pair cache with the value as the delivery id and key
--			   as the index of the corresponding record in p_local_dd_rec.This contains
--			   those delivery ids for which a trip has to be created.
--			   The index is useful for populating the correct record in p_local_dd_rec,
--			   once the delivery and trip are created.
--			p_index_del_ids_ext_cache IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--			   A key-value pair cache with the value as the delivery id and key
--			   as the index of the corresponding record in p_local_dd_rec.This contains
--			   those delivery ids for which a trip has to be created.Records are
--			   stored in this cache if the key exceeds 2^31.
--			   The index is useful for populating the correct record in p_local_dd_rec,
--			   once the trip is created.
--			p_del_ids_del_ids_cache   IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--			   A key-value pair cache with the value as the delivery id and key
--			   as delivery id of the corresponding record in p_local_dd_rec.This contains
--			   those delivery ids for which a trip has to be created.This cache is just used
--			   for maintaining non-duplicate delivery ids and not used for mapping purpose
--			   like the previous cache tables viz..p_index_del_ids_cache and p_index_del_ids_ext_cache.
--			p_del_ids_del_ids_ext_cache  IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--			   A key-value pair cache with the value as the delivery id and key
--			   as delivery id of the corresponding record in p_local_dd_rec.This contains
--			   those delivery ids for which a trip has to be created.This cache is just used
--			   for maintaining non-duplicate delivery ids and not used for mapping purpose
--			   like the previous cache tables viz..p_index_del_ids_cache and p_index_del_ids_ext_cache.
--			   Records are stored in this cache if the key exceeds 2^31.
--			p_uniq_del_ids_tab           IN OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE
--			   This is a pl/sql table which contains the unique deliveries passed to this API.
--			   this table is also updated in this API once the deliveries are created for the
--			   delivery detail ids present in the cache tables  p_index_dd_ids_cache and
--			   p_index_dd_ids_ext_cache.This table is not contiguous.
--			p_action_prms         IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type
--			   This contains the caller, type of action to be performed.
--			p_shipment_header_id         IN NUMBER
--			   RCV Shipment header id
-- OUT:
--			x_return_status          OUT NOCOPY VARCHAR2
--Cache Tables
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |p_index_dd_ids_cache       | Index              | Delivery Detail ID |
--              |p_index_dd_ids_ext_cache   | Index              | Delivery Detail ID |
--              -----------------------------------------------------------------------
--              |p_index_del_ids_cache      |Index               | Delivery ID        |
--              |p_index_del_ids_ext_cache  |Index               | Delivery ID        |
--              -----------------------------------------------------------------------
--              |p_del_ids_del_ids_cache    | Delivery ID        | Delivery ID        |
--              |p_del_ids_del_ids_ext_cache| Delivery ID        | Delivery ID        |
--              -----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments





PROCEDURE Initialize_txns(
p_local_dd_rec                      IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
p_index_dd_ids_cache      IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_index_dd_ids_ext_cache  IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_index_del_ids_cache     IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_index_del_ids_ext_cache IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_del_ids_del_ids_cache   IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_del_ids_del_ids_ext_cache  IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_uniq_del_ids_tab           IN OUT NOCOPY WSH_UTIL_CORE.ID_TAB_TYPE,
p_action_prms         IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
p_shipment_header_id         IN      NUMBER,
x_return_status          OUT NOCOPY VARCHAR2  ) IS


--Cursor to get the Trip ID for a Delivery Detail ID.
cursor c_get_del_id_trip_id (p_del_detail_id NUMBER)
is
select wda.delivery_id,
       wt.trip_id
FROM   wsh_delivery_assignments_v wda,
       wsh_delivery_legs        wdl,
       wsh_trip_stops           wts,
       wsh_trips                wt
WHERE  wda.delivery_detail_id = p_del_detail_id
       AND wda.delivery_id    = wdl.delivery_id
       AND wdl.pick_up_stop_id = wts.stop_id
       AND wts.trip_id        = wt.trip_id;

--Cursor to get the Trip ID for a Delivery ID.
cursor c_get_trip_id (p_delivery_id NUMBER)
is
select wt.trip_id
FROM   wsh_delivery_assignments_v wda,
       wsh_delivery_legs        wdl,
       wsh_trip_stops           wts,
       wsh_trips                wt
WHERE  wda.delivery_id = p_delivery_id
       AND wda.delivery_id    = wdl.delivery_id
       AND wdl.pick_up_stop_id = wts.stop_id
       AND wts.trip_id        = wt.trip_id;



l_new_trip_id_count      NUMBER;
l_new_trip_ids           wsh_util_core.id_tab_type;
l_del_ids           wsh_util_core.id_tab_type;
l_del_id_to_assign  wsh_delivery_assignments_v.delivery_id%type;
l_return_status            VARCHAR2(1);
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_index                 NUMBER;
l_del_rows  WSH_UTIL_CORE.id_tab_type;
l_trip_rows WSH_UTIL_CORE.id_tab_type;
l_org_rows  WSH_UTIL_CORE.id_tab_type;
l_dd_ids_tab WSH_UTIL_CORE.id_tab_type;
l_ind      NUMBER;
j          NUMBER := 0;

l_trip_ids      wsh_util_core.id_tab_type;
l_trip_names    wsh_util_core.Column_Tab_Type;
l_carrier_id    NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INITIALIZE_TXNS';
--
BEGIN
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Caller',p_action_prms.caller);
    WSH_DEBUG_SV.log(l_module_name,'Action', p_action_prms.action_code);
    WSH_DEBUG_SV.log(l_module_name,'p_index_dd_ids_cache.count',p_index_dd_ids_cache.count );
    WSH_DEBUG_SV.log(l_module_name,'p_index_dd_ids_ext_cache.count',p_index_dd_ids_ext_cache.count );
    WSH_DEBUG_SV.log(l_module_name,'p_index_del_ids_cache.count',p_index_del_ids_cache.count );
    WSH_DEBUG_SV.log(l_module_name,'p_index_del_ids_ext_cache.count', p_index_del_ids_ext_cache.count);
    WSH_DEBUG_SV.log(l_module_name,'p_del_ids_del_ids_cache.count',p_del_ids_del_ids_cache.count );
    WSH_DEBUG_SV.log(l_module_name,'p_del_ids_del_ids_ext_cache.count',p_del_ids_del_ids_ext_cache.count);
    WSH_DEBUG_SV.log(l_module_name,'p_uniq_del_ids_tab.count',p_uniq_del_ids_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'p_shipment_header_id',p_shipment_header_id);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;

l_carrier_id := p_local_dd_rec(p_local_dd_rec.FIRST).rcv_carrier_id;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_carrier_id',l_carrier_id);
END IF;

--collecting all delivery detaild IDs from the non-contiguous key-value pairs
--p_index_dd_ids_cache and p_index_dd_ids_ext_cache to the contiguous table
--l_dd_ids_tab

j := 1;
l_ind := p_index_dd_ids_cache.FIRST;
WHILE l_ind IS NOT NULL
LOOP
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'DD ID for AUTOCREATE_DEL_TRIP:',p_index_dd_ids_cache(l_ind).value);
  END IF;
  --
  l_dd_ids_tab(j) := p_index_dd_ids_cache(l_ind).value;
  j := j + 1;
  l_ind := p_index_dd_ids_cache.NEXT(l_ind);
END LOOP;
l_ind := p_index_dd_ids_ext_cache.FIRST;
WHILE l_ind IS NOT NULL
LOOP
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'DD ID for AUTOCREATE_DEL_TRIP:',p_index_dd_ids_ext_cache(l_ind).value);
  END IF;
  --
  l_dd_ids_tab(j) := p_index_dd_ids_ext_cache(l_ind).value;
  j := j + 1;
  l_ind := p_index_dd_ids_ext_cache.NEXT(l_ind);
END LOOP;


-- Calls the API WSH_TRIPS_ACTIONS.AUTOCREATE_DEL_TRIP to create delivery and trip for those
-- delivery detail ids not having both.
IF l_dd_ids_tab.count > 0 THEN

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'l_dd_ids_tab.count',l_dd_ids_tab.count);
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.AUTOCREATE_DEL_TRIP',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --


   WSH_TRIPS_ACTIONS.AUTOCREATE_DEL_TRIP(
     p_line_rows         => l_dd_ids_tab,
     p_org_rows          => l_org_rows,
     p_max_detail_commit => 1000,
     x_del_rows          => l_del_rows,
     x_trip_rows         => l_trip_rows,
     x_return_status     => l_return_status);
     --
     -- Debug Statements
     --
   IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_util_core.api_post_call(
     p_return_status => l_return_status,
     x_num_warnings  => l_num_warnings,
     x_num_errors    => l_num_errors);


   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'populating dlvy and trip');
   END IF;
   --
   j := 1;
   l_ind := p_index_dd_ids_cache.FIRST;

   -- populating the p_local_dd_rec structure with the newly created delivery and trip ids
   -- in their appropriate indexes
   -- and also collect all these delivery ids in the unique del ids list

   WHILE l_ind IS NOT NULL
   LOOP
     OPEN   c_get_del_id_trip_id(p_index_dd_ids_cache(l_ind).value);
     FETCH  c_get_del_id_trip_id
         INTO
         p_local_dd_rec(l_ind).delivery_id,
         p_local_dd_rec(l_ind).trip_id;
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'WDD_ID',p_index_dd_ids_cache(l_ind).value);
        WSH_DEBUG_SV.log(l_module_name,'DLVY_ID',p_local_dd_rec(l_ind).delivery_id);
        WSH_DEBUG_SV.log(l_module_name,'TRIP_ID',p_local_dd_rec(l_ind).trip_id);
     END IF;
     --
     CLOSE  c_get_del_id_trip_id;
					--
     l_new_trip_id_count := NVL(l_new_trip_id_count,0) + 1;
					l_new_trip_ids(l_new_trip_id_count) := p_local_dd_rec(l_ind).trip_id;
					--

     l_ind := p_index_dd_ids_cache.NEXT(l_ind);
   END LOOP;

   l_ind := p_index_dd_ids_ext_cache.FIRST;
   WHILE l_ind IS NOT NULL
   LOOP
     OPEN   c_get_del_id_trip_id(p_index_dd_ids_ext_cache(l_ind).value);
     FETCH  c_get_del_id_trip_id
         INTO
         p_local_dd_rec(l_ind).delivery_id,
         p_local_dd_rec(l_ind).trip_id;
     CLOSE  c_get_del_id_trip_id;
					--
     l_new_trip_id_count := NVL(l_new_trip_id_count,0) + 1;
					l_new_trip_ids(l_new_trip_id_count) := p_local_dd_rec(l_ind).trip_id;
					--

     l_ind := p_index_dd_ids_ext_cache.NEXT(l_ind);
   END LOOP;

END IF; --dd_ids tab count > 0


j := 1;
l_del_rows.delete;
l_ind := p_del_ids_del_ids_cache.FIRST;

--collecting all delivery IDs from the non-contiguous key-value pairs
--p_del_ids_del_ids_cache and p_del_ids_del_ids_ext_cache to the contiguous table
--l_del_rows
WHILE l_ind IS NOT NULL
LOOP
  l_del_rows(j) := p_del_ids_del_ids_cache(l_ind).value;
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,' l_del_rows(j)', l_del_rows(j));
  END IF;
  --
  j := j + 1;
  l_ind := p_del_ids_del_ids_cache.NEXT(l_ind);
END LOOP;

l_ind := p_del_ids_del_ids_ext_cache.FIRST;
WHILE l_ind IS NOT NULL
LOOP
  l_del_rows(j) := p_del_ids_del_ids_ext_cache(l_ind).value;
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,' l_del_rows(j)', l_del_rows(j));
  END IF;
  --
  j := j + 1;
  l_ind := p_del_ids_del_ids_ext_cache.NEXT(l_ind);
END LOOP;



-- Calls the API WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP_MULTI to create trip for those
-- delivery ids which have not been assigned to any trip.
IF l_del_rows.COUNT > 0 THEN
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_ACTIONS.AUTOCREATE_TRIP_MULTI',WSH_DEBUG_SV.C_PROC_LEVEL);
       WSH_DEBUG_SV.log(l_module_name,'l_del_rows.count = ',l_del_rows.count);
  END IF;
  --

  WSH_TRIPS_ACTIONS.autocreate_trip_multi(
     p_del_rows       => l_del_rows,
     x_trip_ids       => l_trip_ids,
     x_trip_names     => l_trip_names,
     x_return_status  => l_return_status);

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'RET STS OF WSH_TRIPS_ACTIONS.autocreate_trip_multi IS :', l_return_status);
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);


  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'populating trip only');
  END IF;
  --

  -- populating the dd_rec structure with the newly created  trip ids
  -- in their appropriate indexes.The Delivery IDs for which the Trip has to
  -- be updated is derived from the two cache tables.

  j := 1;
  l_ind := p_index_del_ids_cache.FIRST;
  WHILE l_ind IS NOT NULL
  LOOP

    OPEN   c_get_trip_id(p_index_del_ids_cache(l_ind).value);
    FETCH  c_get_trip_id
         INTO
         p_local_dd_rec(l_ind).trip_id;
    CLOSE  c_get_trip_id;
    IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_module_name,'p_index_del_ids_cache(l_ind).value',p_index_del_ids_cache(l_ind).value);
	WSH_DEBUG_SV.log(l_module_name,'p_local_dd_rec(l_ind).trip_id',p_local_dd_rec(l_ind).trip_id);
    END IF;
    --
					--
     l_new_trip_id_count := NVL(l_new_trip_id_count,0) + 1;
					l_new_trip_ids(l_new_trip_id_count) := p_local_dd_rec(l_ind).trip_id;
					--
    l_ind := p_index_del_ids_cache.NEXT(l_ind);
    j := j+1;
  END LOOP;


  l_ind := p_index_del_ids_ext_cache.FIRST;
  WHILE l_ind IS NOT NULL
  LOOP
    OPEN   c_get_trip_id(p_index_del_ids_ext_cache(l_ind).value);
    FETCH  c_get_trip_id
         INTO
         p_local_dd_rec(l_ind).trip_id;
    CLOSE  c_get_trip_id;
    IF l_debug_on THEN
	WSH_DEBUG_SV.log(l_module_name,'p_index_del_ids_ext_cache(l_ind).value',p_index_del_ids_ext_cache(l_ind).value);
	WSH_DEBUG_SV.log(l_module_name,'p_local_dd_rec(l_ind).trip_id',p_local_dd_rec(l_ind).trip_id);
    END IF;
    --
					--
     l_new_trip_id_count := NVL(l_new_trip_id_count,0) + 1;
					l_new_trip_ids(l_new_trip_id_count) := p_local_dd_rec(l_ind).trip_id;
					--
    l_ind := p_index_del_ids_ext_cache.NEXT(l_ind);
    j := j+1;
  END LOOP;

END IF; --l_del_rows count > 0



   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'updating carrier on trip');
      WSH_DEBUG_SV.log(l_module_name,'l_new_trip_id_count',l_new_trip_id_count);
   END IF;

			IF l_new_trip_id_count > 0
			THEN
			    FORALL i in l_new_trip_ids.FIRST..l_new_trip_ids.LAST
							UPDATE WSH_TRIPS
							SET    carrier_id = l_carrier_id,
              last_update_date = SYSDATE,
              last_updated_by =  FND_GLOBAL.USER_ID,
              last_update_login =  FND_GLOBAL.LOGIN_ID
       WHERE  trip_id = l_new_trip_ids(i);
			END IF;

--collecting unique del ids into a table from a non-contiguous table, to be passed to
--WSH_ASN_RECEIPT_PVT.UNASSIGN_OPEN_DET_FROM_DEL

j := 1;
l_ind :=   p_uniq_del_ids_tab.FIRST;
WHILE l_ind IS NOT NULL
LOOP
  l_del_ids(j) :=  p_uniq_del_ids_tab(l_ind);
  j := j + 1;
  l_ind := p_uniq_del_ids_tab.NEXT(l_ind);
END LOOP;


--call unassign open details for all deliveries i.e basically all the records
--in the p_local_dd_rec structure
IF l_del_ids.count > 0 THEN
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.UNASSIGN_OPEN_DET_FROM_DEL',WSH_DEBUG_SV.C_PROC_LEVEL);
     WSH_DEBUG_SV.log(l_module_name,'l_del_ids.count',l_del_ids.count);
  END IF;
  --
  unassign_open_det_from_del(
    p_del_ids      => l_del_ids,
    p_action_prms  => p_action_prms,
    p_shipment_header_id => p_shipment_header_id,
    x_return_status => l_return_status);
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);

 END IF; --l_del_ids > 0


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.UPDATE_STATUS');

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END initialize_txns;

-- Start of comments
-- API name : reconfigure_del_trips
-- Type     : Public
-- Pre-reqs : None.
-- Function :  The Bill of Lading(From WSH_DOCUMENT_INSTANCES for entity name
--               and entity id) will trigger the reconfiguration of the
--               deliveries and associated trips.
--               For delivery details which will be marked as 'C'-SHIPPED,
--               we need to ensure  that lines having the same Bill of Lading
--               fall in the same delivery leg.
--               1. In this API, first the dd_rec information is arranged in
--                  the ascending order of Trip ID,delivery id, BOL and LPN_ids.
--               2. The sorted records are divided into logical groups based on BOL
--		    and calls are made to the API create_update_waybill_psno_bol
--		    for each such group.
--               4. For every BOL Group, whenever it encounters the change
--                  in the LPN, it packs a group of delivery details into a single
--                  LPN.
-- Parameters :
-- IN:
-- IN OUT:
--  p_local_dd_rec   IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
--     The structure which contains necessary information of the changed attributes
--     of the lines.
--  p_action_prms    IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type
---    A record which contains the action code, transaction type etc..
--  x_lpnGWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as LPN id and value as
--     Gross weight for the corresponding LPN. The key ranges from 1 to (2^31 -1)
--  x_lpnGWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as LPN id and value as
--     Gross weight for the corresponding LPN. The key ranges from 2^31 and greater.
--  x_lpnNWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as LPN id and value as
--     Net weight for the corresponding LPN. The key ranges from 1 to (2^31 -1)
--  x_lpnNWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as LPN id and value as
--     Net weight for the corresponding LPN. The key ranges from 2^31 and greater.
--  x_lpnVOLcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as LPN id and value as
--     Volume for the corresponding LPN. The key ranges from 1 to (2^31 -1)
--  x_lpnVOLcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as LPN id and value as
--     Volume for the corresponding LPN. The key ranges from 2^31 and greater.
--  x_dlvyGWTcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as Delivery id and value as
--     Gross weight for the corresponding LPN. The key ranges from 1 to (2^31 -1)
--  x_dlvyGWTcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as Delivery id and value as
--     Gross weight for the corresponding LPN. The key ranges from 2^31 and greater.
--  x_dlvyNWTcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as Delivery id and value as
--     Net weight for the corresponding LPN. The key ranges from 1 to (2^31 -1)
--  x_dlvyNWTcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as Delivery id and value as
--     Net weight for the corresponding LPN. The key ranges from 2^31 and greater.
--  x_dlvyVOLcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as Delivery id and value as
--     Volume for the corresponding LPN. The key ranges from 1 to (2^31 -1)
--  x_dlvyVOLcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type
--     A key-value cache (mapping table) which has the key as Delivery id and value as
--     Volume for the corresponding LPN. The key ranges from 2^31 and greater.

-- OUT:
--Cache Tables :
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |x_lpnGWTcachetbl           | LPN ID             | Gross Weight       |
--              |x_lpnGWTcacheExttbl        | LPN ID             | Gross Weight       |
--              -----------------------------------------------------------------------
--              |x_lpnNWTcachetbl           | LPN ID             | Net Weight         |
--              |x_lpnNWTcacheExttbl        | LPN ID             | Net Weight         |
--              -----------------------------------------------------------------------
--              |x_lpnVOLcachetbl           | LPN ID             | Volume             |
--              |x_lpnVOLcacheExttbl        | LPN ID             | Volume             |
--              -----------------------------------------------------------------------
--              |x_dlvyGWTcachetbl          | Delivery ID        | Gross Weight       |
--              |x_dlvyGWTcacheExttbl       | Delivery ID        | Gross Weight       |
--              -----------------------------------------------------------------------
--              |x_dlvyNWTcachetbl          | Delivery ID        | Net Weight         |
--              |x_dlvyNWTcacheExttbl       | Delivery ID        | Net Weight         |
--              -----------------------------------------------------------------------
--              |x_dlvyVOLcachetbl          | Delivery ID        | Volume             |
--              |x_dlvyVOLcacheExttbl       | Delivery ID        | Volume             |
--              -----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments



PROCEDURE reconfigure_del_trips(
p_local_dd_rec   IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
p_action_prms    IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
x_lpnGWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnGWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnNWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnNWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnVOLcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnVOLcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyGWTcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyGWTcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyNWTcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyNWTcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyVOLcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyVOLcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
p_shipment_header_id            IN             NUMBER, -- added by NPARIKH
x_return_status  OUT NOCOPY VARCHAR2) IS

--Cursor to get the Stop IDs corresponding to a Trip.
CURSOR c_get_stop_ids(l_cur_trip_id NUMBER)
IS
SELECT
stop_id
FROM
WSH_TRIP_STOPS  WTS
WHERE  WTS.trip_id = l_cur_trip_id;

l_in_rec             WSH_DELIVERY_VALIDATIONS.ChgStatus_in_rec_type;

 CURSOR empty_it_dlvy_csr (p_shipment_header_id IN NUMBER)
 IS
   SELECT delivery_id, ultimate_dropoff_date, name, status_code
   FROM   wsh_new_deliveries wnd
   WHERE  wnd.asn_shipment_header_id = p_shipment_header_id
   AND    wnd.status_code = 'IT'
   AND    NOT EXISTS (
                       select 1
                       FROM   wsh_delivery_assignments_v wda
                       WHERE  wda.delivery_id = wnd.delivery_id
                     );

l_stored_del_id  NUMBER;
l_trigger        NUMBER;--set to '1' when ever a new delivery ID has to be created
l_gross_weight   NUMBER;
l_net_weight     NUMBER;
l_volume         NUMBER;
l_return_status  VARCHAR2(1);
l_use_LPNS       NUMBER;
l_psno_flag      NUMBER := 0;
l_waybill_flag   NUMBER := 0;
l_psno           VARCHAR2(250);
l_waybill        VARCHAR2(30);
l_new_del_id     NUMBER;
curr_lpn         NUMBER;
curr_lpn_name    VARCHAR2(50);
curr_bol         VARCHAR2(50);
curr_del         NUMBER;
curr_del_det     NUMBER;
l_found          NUMBER;
temp_ids         wsh_util_core.id_tab_type;
pack_ids         wsh_util_core.id_tab_type;
temp_dels        wsh_util_core.id_tab_type;
l_wdd_tbl	 wsh_util_core.Id_Tab_Type;
unique_trips     wsh_util_core.id_tab_type;
l_trips_tab      wsh_util_core.id_tab_type;
l_pack_status    VARCHAR2(1);
l_stop_ids_tab   wsh_util_core.id_tab_type;
l_stop_id        NUMBER;
l_del_ids_tab    wsh_util_core.id_tab_type;
j                NUMBER;
l_local_dd_rec   LOCAL_DD_REC_TABLE_TYPE;
dd_rec_count     NUMBER;
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_ind            NUMBER;

curr_trip_id	 NUMBER;
curr_truck_num	 VARCHAR2(35);
prev_trip_id	 NUMBER;
prev_truck_num	 VARCHAR2(35);
truck_flag	 NUMBER ;


curr_initial_pickup_date    DATE;
curr_expected_receipt_date  DATE;
curr_rcv_carrier_id	    NUMBER;

l_initial_pickup_date_tab   wsh_util_core.Date_Tab_Type;
l_expected_receipt_date_tab wsh_util_core.Date_Tab_Type;
l_rcv_carrier_id_tab	    wsh_util_core.Id_Tab_Type;

l_gross_weight_of_first  NUMBER;
l_net_weight_of_first    NUMBER;

curr_header_id		 NUMBER;
l_header_ids_for_del_ids_tab  wsh_util_core.id_Tab_Type;

l_dd_index  NUMBER;
--
l_debug_on  BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RECONFIGURE_DEL_TRIPS';
--
BEGIN

--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_action_prms.action_code',p_action_prms.action_code);
    WSH_DEBUG_SV.log(l_module_name,'p_shipment_header_id',p_shipment_header_id);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
SAVEPOINT RECONFIG_DEL_TRIPS_PVT;



l_local_dd_rec :=  p_local_dd_rec;


IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit SORT_DD_REC',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--Arrange the data in p_local_dd_rec in the ascending order of Trip ID,delivery id, BOL and LPN.
sort_dd_rec(
   p_local_dd_rec  => l_local_dd_rec,
   x_return_status => l_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_util_core.api_post_call(
   p_return_status => l_return_status,
   x_num_warnings  => l_num_warnings,
   x_num_errors    => l_num_errors);

--Once sorted, the records of the l_local_dd_rec are considered
--to be in LOGICAL GROUPS based on the BOL. i.e records
--having the same Trip,Delivery ID and BOL
--are considered to be a logical group.
--For every such group we need to execute WSH_ASN_RECEIPT_PVT.SYNCH_BOLS
--for the first group within the delivery. For the subsequent groups, a call is made
--to the API  WSH_INBOUND_UTIL_PKG.SPLIT_INBOUND_DELIVERY to create a new delivery
--for this logical group based on the existing Delivery ID.But the calls to
--above mentioned APIs are not directly made from the current  Procedure, rather the API
--CREATE_UPDATE_WAYBILL_PSNO_BOL takes care of the same.The variable
--l_trigger is used to determine whether a logical group is the first group
--within the delivery.


curr_lpn                   := l_local_dd_rec(1).lpn_id;
curr_lpn_name              := l_local_dd_rec(1).lpn_name;
curr_del                   := l_local_dd_rec(1).delivery_id;
curr_BOL                   := l_local_dd_rec(1).BOL;
curr_del_det               := l_local_dd_rec(1).del_detail_id;
curr_initial_pickup_date   := l_local_dd_rec(1).initial_pickup_date;
curr_expected_receipt_date := l_local_dd_rec(1).expected_receipt_date;
curr_header_id             := l_local_dd_rec(1).shipment_header_id;
curr_rcv_carrier_id        := l_local_dd_rec(1).rcv_carrier_id;


--If it is '0' then it means the logical group is the
--first group.
--If it is '1' then it means the logical group is not
--the first group and thereby requires a new delivery to
--be created for the lines in this logical group.
l_trigger                   := 0;
prev_trip_id                := l_local_dd_rec(1).trip_id;
prev_truck_num              := l_local_dd_rec(1).truck_num;
truck_flag                  := 0;


FOR i IN 1..l_local_dd_rec.COUNT loop


  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'i',i);
    WSH_DEBUG_SV.log(l_module_name,'curr_lpn',curr_lpn);
    WSH_DEBUG_SV.log(l_module_name,'curr_lpn_name',curr_lpn_name);
    WSH_DEBUG_SV.log(l_module_name,'curr_del',curr_del);
    WSH_DEBUG_SV.log(l_module_name,'curr_BOL',curr_BOL);
    WSH_DEBUG_SV.log(l_module_name,'curr_del_det',curr_del_det);
    WSH_DEBUG_SV.log(l_module_name,'curr_header_id',curr_header_id);
    WSH_DEBUG_SV.log(l_module_name,'curr_initial_pickup_date',curr_initial_pickup_date);
    WSH_DEBUG_SV.log(l_module_name,'curr_expected_receipt_date',curr_expected_receipt_date);
    WSH_DEBUG_SV.log(l_module_name,'l_trigger',l_trigger);
    WSH_DEBUG_SV.log(l_module_name,'prev_trip_id',prev_trip_id);
    WSH_DEBUG_SV.log(l_module_name,'prev_truck_num',prev_truck_num);
    WSH_DEBUG_SV.log(l_module_name,'truck_flag',truck_flag);
    WSH_DEBUG_SV.log(l_module_name,'WDD ID',l_local_dd_rec(i).del_detail_id );
  END IF;
  --
  --
  l_wdd_tbl(l_wdd_tbl.count + 1) := l_local_dd_rec(i).del_detail_id ;



  -- WSH_ASN_RECEIPT_PVT.CREATE_UPDATE_WAYBILL_PSNO_BOL() is called
  -- 1. when ever the delivery changes from the previous record of l_local_dd_rec
  -- 2. when ever the BOl changes from the previous record of l_local_dd_rec
  -- 3. After this for loop(the outer most loop of this procedure) so that we don't
  --    miss the call for the last set of records.

  -- WSH_CONTAINER_ACTIONS.PACK_INBOUND_LINES is called
  -- 1. when ever the LPN changes within a LOGICAL GROUP of l_local_dd_rec records.
  -- 2. when ever the BOl changes (gets called thru create_update_waybill_psno_bol)
  -- 3. when ever the Delivery Id changes

  IF (curr_del = l_local_dd_rec(i).delivery_id) THEN

    --The BOL has changed from the previous record, but both records have the
    --same delivery.
    IF (NVL(curr_BOL,'$$$$$$') <> NVL(l_local_dd_rec(i).BOL,'$$$$$$')) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CREATE_UPDATE_WAYBILL_PSNO_BOL 1',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --This API (create_update_waybill_psno_bol) based on the l_trigger (0/1) determines whether
      --a new Delivery ID has to be created for the current logical group.
      create_update_waybill_psno_bol(
        p_local_dd_rec=>  l_local_dd_rec,
        l_loop_index  =>  i,
        pack_ids      =>  pack_ids,
        curr_del      =>  curr_del,
        curr_bol      =>  curr_bol,
        curr_lpn      =>  curr_lpn,
        curr_lpn_name      =>  curr_lpn_name,
        curr_del_det  =>  curr_del_det,
        l_psno        =>  l_psno,
        l_waybill     =>  l_waybill,
        l_psno_flag   =>  l_psno_flag,
        l_trigger     =>  l_trigger,
        l_waybill_flag=>  l_waybill_flag ,
        temp_dels     =>  temp_dels,
        p_action_prms =>  p_action_prms,
        x_return_status=> l_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_util_core.api_post_call(
        p_return_status => l_return_status,
        x_num_warnings  => l_num_warnings,
        x_num_errors    => l_num_errors);

     l_initial_pickup_date_tab(l_initial_pickup_date_tab.COUNT + 1) :=   curr_initial_pickup_date;
     l_expected_receipt_date_tab(l_expected_receipt_date_tab.COUNT + 1) := curr_expected_receipt_date;
     l_header_ids_for_del_ids_tab(l_header_ids_for_del_ids_tab.COUNT + 1) := curr_header_id;
     l_rcv_carrier_id_tab(l_rcv_carrier_id_tab.COUNT + 1) := curr_rcv_carrier_id;

    -- this part (ELSE ) gets executed whenver the BOLs are the same within the same delivery.
    -- i.e the BOL of the previous and current record are the same.
    ELSE -- }{  else for curr_bol --FOR THE IF STMT

      --If true, implies the LPN has changed from the previous record, so pack the previous
      --lines having the same LPN to a Container.
      --{
      IF ( (NVL(curr_lpn,-999) <> NVL(l_local_dd_rec(i).lpn_id,-999) ) AND (curr_lpn IS NOT NULL)) THEN

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.PACK_INBOUND_LINES',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
	--Call wsh_container_actions.pack_inbound_lines to pack lines to LPNs.
        wsh_container_actions.pack_inbound_lines(
          p_lines_tbl  => pack_ids ,
          p_lpn_id     => curr_lpn  ,
          p_lpn_name     => curr_lpn_name  ,
          p_delivery_id=> curr_del ,
										p_transactionType => p_action_prms.action_code,
          x_return_status => l_return_status,
	  p_waybill_number => l_local_dd_rec(i).waybill) ;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);

        --once assigned to a container, the pack_ids is deleted, so that the same lines
	--don't get assigned to another container.
        pack_ids.delete;
      END IF;
      --}
    END IF;
    --}

  --Executed (Else part ) if the delivery ID has changed from the previous record.
  --So things like packing the lines to containers,creating new delivery ID (based on l_trigger value)
  --for the logical group etc are taken care by the call to the API CREATE_UPDATE_WAYBILL_PSNO_BOL.
  ELSE
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CREATE_UPDATE_WAYBILL_PSNO_BOL 2',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
   --Call to  API CREATE_UPDATE_WAYBILL_PSNO_BOL.
   create_update_waybill_psno_bol(
     p_local_dd_rec =>  l_local_dd_rec,
     l_loop_index  =>  i,
     pack_ids      =>  pack_ids,
     curr_del      =>  curr_del,
     curr_bol      =>  curr_bol,
     curr_lpn      =>  curr_lpn,
     curr_lpn_name      =>  curr_lpn_name,
     curr_del_det  =>  curr_del_det,
     l_psno        =>  l_psno,
     l_waybill     =>  l_waybill,
     l_psno_flag   =>  l_psno_flag,
     l_trigger     =>  l_trigger,
     l_waybill_flag=>  l_waybill_flag ,
     temp_dels     =>  temp_dels,
     p_action_prms =>  p_action_prms,
     x_return_status=> l_return_status);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_util_core.api_post_call(
     p_return_status => l_return_status,
     x_num_warnings  => l_num_warnings,
     x_num_errors    => l_num_errors);

   l_initial_pickup_date_tab(l_initial_pickup_date_tab.COUNT + 1) :=   curr_initial_pickup_date;
   l_expected_receipt_date_tab(l_expected_receipt_date_tab.COUNT + 1) := curr_expected_receipt_date;
   l_header_ids_for_del_ids_tab(l_header_ids_for_del_ids_tab.COUNT + 1) := curr_header_id;
   l_rcv_carrier_id_tab(l_rcv_carrier_id_tab.COUNT + 1) := curr_rcv_carrier_id;
   l_trigger          := 0;

 END IF;

 IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_psno_flag',l_psno_flag);
    WSH_DEBUG_SV.log(l_module_name,'l_psno',l_psno);
    WSH_DEBUG_SV.log(l_module_name,'l_waybill_flag',l_waybill_flag);
    WSH_DEBUG_SV.log(l_module_name,'l_waybill',l_waybill);
 END IF;
 --


 -- l_psno_flag : this flag is used to check whether
 -- the psno remains the same within a delivery.
 IF ( l_psno_flag = 0 ) THEN
   IF ( (NVL(l_psno,'$$$') <> NVL(l_local_dd_rec(i).psno,'$$$'))
        AND  (l_psno IS NOT NULL))
   THEN
     l_psno_flag := 1;
   END IF;
 END IF;


 -- l_waybill_flag : this flag is used to check whether
 -- the waybill remains the same within a delivery.
 IF ( l_waybill_flag = 0 ) THEN
   IF ( (NVL(l_waybill,'$$$$$') <> NVL(l_local_dd_rec(i).waybill,'$$$$$'))
        AND (l_waybill IS NOT NULL) )
   THEN
     l_waybill_flag := 1;
   END IF;
 END IF;


 --collects the delivery detail IDs corresponding to a logical group.
 IF ( (curr_del_det <> l_local_dd_rec(i).del_detail_id)  OR (pack_ids.count = 0)  )THEN
   pack_ids(pack_ids.count + 1) := l_local_dd_rec(i).del_detail_id;
 END IF;


 --collecting unique trips
 IF ( l_local_dd_rec(i).trip_id is not null ) AND ( l_local_dd_rec(i).trip_id <> -1 )  THEN
    unique_trips(l_local_dd_rec(i).trip_id) := l_local_dd_rec(i).trip_id;
 END IF;



 curr_del := l_local_dd_rec(i).delivery_id;
 curr_BOL := l_local_dd_rec(i).BOL;
 curr_lpn := l_local_dd_rec(i).lpn_id;
 curr_lpn_name := l_local_dd_rec(i).lpn_name;
 curr_del_det := l_local_dd_rec(i).del_detail_id;
 l_psno   := l_local_dd_rec(i).psno;
 l_waybill:= l_local_dd_rec(i).waybill;
 curr_initial_pickup_date   :=  l_local_dd_rec(i).initial_pickup_date;
 curr_expected_receipt_date :=  l_local_dd_rec(i).expected_receipt_date;
 curr_header_id :=  l_local_dd_rec(i).shipment_header_id;
 curr_trip_id   := l_local_dd_rec(i).trip_id;
 curr_truck_num := l_local_dd_rec(i).truck_num;
 curr_rcv_carrier_id :=  l_local_dd_rec(i).rcv_carrier_id;


-- truck_flag : this flag is used to check whether
-- the truck number remains the same within a trip.
  IF curr_trip_id <> prev_trip_id THEN
    IF (truck_flag = 0) AND  ( prev_trip_id <> -1 ) THEN
      UPDATE wsh_trips
      SET    vehicle_number = prev_truck_num
      WHERE  trip_id = prev_trip_id;
    ELSE

      truck_flag := 0;
    END IF;
  ELSE
    IF truck_flag = 0 THEN
       IF NVL(curr_truck_num,'$$$') <> NVL(prev_truck_num,'$$$') THEN
        truck_flag := 1;
      END IF;
    END IF;
  END IF;

prev_trip_id   := curr_trip_id;
prev_truck_num := curr_truck_num;


--
END LOOP;
--End of the outermost while loop.Once the control comes out of
--this loop, it does not mean that all the records of l_local_dd_rec where succesfully
--processed like packing into containers ,BOL assignments etc..
--There will be atleast a single record in all cases where the above mentioned process
--has to be done, since the above mentioned outermost loop uses such a logic. (current
--record compared against the previous record).So for such left out records (which will
--fall in a single logical group always), the process like creating conatiners, new delievry IDs
--etc..has to be done.So a call to CREATE_UPDATE_WAYBILL_PSNO_BOL is made.

--
IF (truck_flag = 0 ) AND ( curr_trip_id <> -1 ) THEN
  UPDATE wsh_trips
  SET    vehicle_number = curr_truck_num
  WHERE  trip_id = curr_trip_id;
END IF;
--

--True always, since there will be atleast one left out unprocessed record always.
IF (pack_ids.COUNT > 0) THEN

  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit CREATE_UPDATE_WAYBILL_PSNO_BOL 3',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  --Call to API create_update_waybill_psno_bol
  create_update_waybill_psno_bol(
    p_local_dd_rec =>  l_local_dd_rec,
    l_loop_index  =>  l_local_dd_rec.LAST,
    pack_ids      =>  pack_ids,
    curr_del      =>  curr_del,
    curr_bol      =>  curr_bol,
    curr_lpn      =>  curr_lpn,
    curr_lpn_name      =>  curr_lpn_name,
    curr_del_det  =>  curr_del_det,
    l_psno        =>  l_psno,
    l_waybill     =>  l_waybill,
    l_psno_flag   =>  l_psno_flag,
    l_trigger     =>  l_trigger,
    l_waybill_flag=>  l_waybill_flag ,
    temp_dels     =>  temp_dels,
    p_action_prms =>  p_action_prms,
    x_return_status=> l_return_status);
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);

  l_initial_pickup_date_tab(l_initial_pickup_date_tab.COUNT + 1) :=   curr_initial_pickup_date;
  l_expected_receipt_date_tab(l_expected_receipt_date_tab.COUNT + 1) := curr_expected_receipt_date;
  l_header_ids_for_del_ids_tab(l_header_ids_for_del_ids_tab.COUNT + 1) := curr_header_id;
  l_rcv_carrier_id_tab(l_rcv_carrier_id_tab.COUNT + 1) := curr_rcv_carrier_id;
  IF ( l_local_dd_rec(l_local_dd_rec.LAST).trip_id IS NOT NULL )
     AND ( l_local_dd_rec(l_local_dd_rec.LAST).trip_id <> -1 )THEN
    unique_trips(l_local_dd_rec(l_local_dd_rec.LAST).trip_id) := l_local_dd_rec(l_local_dd_rec.LAST).trip_id;
  END IF;


END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_wdd_tbl.count',l_wdd_tbl.count);
    WSH_DEBUG_SV.log(l_module_name,'l_wdd_tbl.first',l_wdd_tbl.first);
    WSH_DEBUG_SV.log(l_module_name,'l_wdd_tbl.last',l_wdd_tbl.last);
END IF;


--IF temp_dels.COUNT > 0 THEN
IF l_wdd_tbl.COUNT > 0 THEN

/*
*By now we have got the following lists, temp_dels  . We need to call the
*following apis to recalculate weight and volume for the deliveries and trips,
*updating the status of the delivery, trip and trip stops and execute the
*rating request for the deliveries.
*/

   WSH_WV_UTILS.detail_weight_volume(
      p_detail_rows           => l_wdd_tbl,
      p_override_flag        => 'Y',
    p_calc_wv_if_frozen => 'N',   --'Y',
    x_return_status     => l_return_status);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
  wsh_util_core.api_post_call(
    p_return_status    => l_return_status,
    x_num_warnings     => l_num_warnings,
    x_num_errors       => l_num_errors);

END IF;

 /*
  FTE_FREIGHT_PRICING.shipment_reprice(
    p_fte_trip_id     =>   NULL, -- Input only ONE of the following FOUR
    p_segment_id      =>   NULL,
    p_delivery_id     =>   temp_dels(i),
    p_delivery_leg_id =>   NULL,
    x_return_status   => l_return_status) ;

  wsh_util_core.api_post_call(
    p_return_status    => l_return_status,
    x_num_warnings     => l_num_warnings,
    x_num_errors       => l_num_errors);
*/


--copying unique trip ids and stop ids  to a table in contigous locations
j := 1;
l_ind := unique_trips.FIRST;
WHILE l_ind IS NOT NULL
LOOP
  l_trips_tab(j) := unique_trips(l_ind);


  OPEN c_get_stop_ids(unique_trips(l_ind));
  FETCH c_get_stop_ids BULK COLLECT INTO l_stop_ids_tab;
  CLOSE c_get_stop_ids;
  j := j + 1;
  l_ind := unique_trips.NEXT(l_ind);
END LOOP;


-- If true -> Then call the the API UPDATE_STATUS of the same package to update various
-- attributes of the delivery which has changed.
IF temp_dels.COUNT > 0 THEN

  update_status(
    p_action_prms => p_action_prms,
    p_del_ids   => temp_dels,
    p_trip_ids  => unique_trips,
    p_stop_ids  => l_stop_ids_tab,
    p_shipment_header_id_tab => l_header_ids_for_del_ids_tab,
    p_initial_pickup_date_tab =>   l_initial_pickup_date_tab,
    p_expected_receipt_date_tab => l_expected_receipt_date_tab,
    p_rcv_carrier_id_tab        => l_rcv_carrier_id_tab,
    p_local_dd_rec              => l_local_dd_rec,
     x_lpnGWTcachetbl                => x_lpnGWTcachetbl,          --NNP-WV
     x_lpnGWTcacheExttbl             => x_lpnGWTcacheExttbl,
     x_lpnNWTcachetbl                => x_lpnNWTcachetbl,
     x_lpnNWTcacheExttbl             => x_lpnNWTcacheExttbl,
     x_lpnVOLcachetbl                => x_lpnVOLcachetbl,
     x_lpnVOLcacheExttbl             => x_lpnVOLcacheExttbl,
     x_dlvyGWTcachetbl                => x_dlvyGWTcachetbl,
     x_dlvyGWTcacheExttbl             => x_dlvyGWTcacheExttbl,
     x_dlvyNWTcachetbl                => x_dlvyNWTcachetbl,
     x_dlvyNWTcacheExttbl             => x_dlvyNWTcacheExttbl,
     x_dlvyVOLcachetbl                => x_dlvyVOLcachetbl,
     x_dlvyVOLcacheExttbl             => x_dlvyVOLcacheExttbl,
    x_return_status => l_return_status);
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status    => l_return_status,
    x_num_warnings     => l_num_warnings,
    x_num_errors       => l_num_errors);

END IF;

--
-- Close empty IT deliveries , associated with ASN (shipped but not received)
--
IF p_action_prms.action_code = 'RECEIPT' -- added by NPARIKH
THEN
--{
    FOR empty_it_dlvy_rec IN empty_it_dlvy_csr (p_shipment_header_id => p_shipment_header_id)
    LOOP
    --{
        l_in_rec.delivery_id := empty_it_dlvy_rec.delivery_id;
        l_in_rec.name        := empty_it_dlvy_rec.name;
        l_in_rec.status_code := empty_it_dlvy_rec.status_code;
        l_in_rec.actual_date := empty_it_dlvy_rec.ultimate_dropoff_date;
        l_in_rec.manual_flag := 'N';
        l_in_rec.caller      := WSH_UTIL_CORE.C_IB_RECEIPT_PREFIX;
        --
        temp_dels(temp_dels.COUNT + 1) :=  empty_it_dlvy_rec.delivery_id;
        --
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'empty_it_dlvy_rec.delivery_id',empty_it_dlvy_rec.delivery_id);
           WSH_DEBUG_SV.log(l_module_name,'empty_it_dlvy_rec.status_code',empty_it_dlvy_rec.status_code);
           WSH_DEBUG_SV.log(l_module_name,'empty_it_dlvy_rec.ultimate_dropoff_date',empty_it_dlvy_rec.ultimate_dropoff_date);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.setClose',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_NEW_DELIVERY_ACTIONS.setClose
          (
            p_in_rec => l_in_rec,
            x_return_status => l_return_status
          );
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call(
          p_return_status    => l_return_status,
          x_num_warnings     => l_num_warnings,
          x_num_errors       => l_num_errors);

    --}
    END LOOP;
--}
END IF;

-- If true -> Then call the the API WSH_INBOUND_UTIL_PKG.SETTRIPSTOPSTATUS to update various
-- trip stop status of the deliveries.
IF temp_dels.COUNT > 0 THEN

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.SETTRIPSTOPSTATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'action code to trip stop :',p_action_prms.action_code);
  END IF;

  WSH_INBOUND_UTIL_PKG.setTripStopStatus(
    p_transaction_code => l_local_dd_rec(1).transaction_type,
    p_action_code      => 'APPLY',
    p_delivery_id_tab  => temp_dels,
    x_return_status    => l_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'ret sts of trip stop :',l_return_status);
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status    => l_return_status,
    x_num_warnings     => l_num_warnings,
    x_num_errors       => l_num_errors);

END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO RECONFIG_DEL_TRIPS_PVT;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

 --
 -- Debug Statements
 --
 IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
 END IF;
 --
  WHEN OTHERS THEN
    ROLLBACK TO RECONFIG_DEL_TRIPS_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.RECONFIGURE_DEL_TRIPS');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END reconfigure_del_trips;


-- Start of comments
-- API name : sort_dd_rec
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API sorts records in the p_local_dd_rec structure on the
--		order of trip id,delivery ids,bill of lading and lpn ids.
-- Parameters :
-- IN:
-- IN OUT:
--        p_local_dd_rec  IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE
--            A record structure with data passed from process_matched_txns API.
-- OUT:
--        x_return_status OUT  NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE sort_dd_rec(
              p_local_dd_rec IN OUT  NOCOPY LOCAL_DD_REC_TABLE_TYPE,
              x_return_status OUT  NOCOPY VARCHAR2) AS

l_return_status varchar2(1);
t_dd_rec LOCAL_DD_REC_TABLE_TYPE;
l_count NUMBER;
l_lb    NUMBER;
l_ub    NUMBER;
l_num_warnings NUMBER := 0;
l_num_errors   NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SORT_DD_REC';
--
begin
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_count := p_local_dd_rec.COUNT;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_count', l_count);
    WSH_DEBUG_SV.logmsg(l_module_name, 'Before the loop - BASED ON TRIP ID');
    WSH_DEBUG_SV.log(l_module_name, 'its first index is', p_local_dd_rec.first);
    WSH_DEBUG_SV.log(l_module_name, 'its last index is', p_local_dd_rec.last);
END IF;

--BUBBLE SORT BASED ON TRIP ID
FOR i in 1..(l_count-1) LOOP
  FOR j in (i+1)..l_count LOOP
    IF p_local_dd_rec(i).trip_id > p_local_dd_rec(j).trip_id THEN
      t_dd_rec(1) := p_local_dd_rec(i);
      p_local_dd_rec(i)   := p_local_dd_rec(j);
      p_local_dd_rec(j)   := t_dd_rec(1);
    END IF;
  END LOOP;
END LOOP;



IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'Before the loop - BASED ON TRIP ID,DEL_ID');
END IF;

--BUBBLE SORT BASED ON TRIP ID,DELIVERY ID
l_ub := 1;
WHILE l_ub < l_count LOOP
  l_lb := l_ub;
  WHILE p_local_dd_rec(l_ub).trip_id = p_local_dd_rec(l_ub+1).trip_id LOOP
    l_ub := l_ub + 1;
      IF l_ub = l_count THEN
        EXIT;
      END IF;
  END LOOP;
  FOR i in l_lb..(l_ub-1) LOOP
    FOR j in (i+1)..l_ub LOOP
      IF p_local_dd_rec(i).delivery_id > p_local_dd_rec(j).delivery_id THEN
        t_dd_rec(1) := p_local_dd_rec(i);
        p_local_dd_rec(i)   := p_local_dd_rec(j);
        p_local_dd_rec(j)   := t_dd_rec(1);
      END IF;
    END LOOP;
  END LOOP;
l_ub := l_ub + 1;
END LOOP;


IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'Before the loop - BASED ON TRIP ID,DELIVERY ID,BOL');
END IF;

l_ub := 1;
--BUBBLE SORT BASED ON TRIP ID,DELIVERY ID,BOL IN THAT ORDER.
WHILE l_ub < l_count LOOP
  l_lb := l_ub;
  WHILE p_local_dd_rec(l_ub).delivery_id = p_local_dd_rec(l_ub+1).delivery_id LOOP
    l_ub := l_ub + 1;
      IF l_ub = l_count THEN
        EXIT;
      END IF;
  END LOOP;
  FOR i in l_lb..(l_ub-1) LOOP
    FOR j in (i+1)..l_ub LOOP
      IF (nvl(p_local_dd_rec(i).bol,'zzzzzz')) > (nvl(p_local_dd_rec(j).bol,'zzzzzz')) THEN
--      IF nvl(p_local_dd_rec(i).bol,'Z') > nvl(p_local_dd_rec(j).bol,'A') THEN
        t_dd_rec(1) := p_local_dd_rec(i);
        p_local_dd_rec(i)   := p_local_dd_rec(j);
        p_local_dd_rec(j)   := t_dd_rec(1);
      END IF;
    END LOOP;
  END LOOP;
l_ub := l_ub + 1;
END LOOP;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'Before the loop - BASED ON TRIP ID,DEL_ID,BOL,LPNS');
END IF;



l_ub := 1;
WHILE l_ub < l_count LOOP
  l_lb := l_ub;
  --BUBBLE SORT BASED ON TRIP ID,DEL_ID,BOL,LPNS
  WHILE ( nvl(p_local_dd_rec(l_ub).bol,'99999999') = nvl(p_local_dd_rec(l_ub+1).bol,'99999999') )
    AND ( p_local_dd_rec(l_ub).delivery_id = p_local_dd_rec(l_ub+1).delivery_id  )LOOP
    -- commented by RV -- bug
                                -- AND ( p_local_dd_rec(l_lb).delivery_id = p_local_dd_rec(l_ub).delivery_id  )LOOP
    l_ub := l_ub + 1;
      IF l_ub = l_count THEN
        EXIT;
      END IF;
  END LOOP;
  FOR i in l_lb..(l_ub - 1) LOOP
    FOR j in (i+1)..l_ub LOOP
      IF NVL(p_local_dd_rec(i).lpn_id,999999) > NVL(p_local_dd_rec(j).lpn_id,999999) THEN
        t_dd_rec(1) := p_local_dd_rec(i);
        p_local_dd_rec(i)   := p_local_dd_rec(j);
        p_local_dd_rec(j)   := t_dd_rec(1);
      END IF;
    END LOOP;
  END LOOP;
l_ub := l_ub + 1;
END LOOP;

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name, 'After the loop - BASED ON TRIP ID,DEL_ID,BOL,LPNS');
END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.SORT_DD_REC');
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END sort_dd_rec;



-- Start of comments
-- API name : synch_bols
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API updates the bill of lading for a Delivery leg ID
--             corresponding to the input parameter(p_del_id)
--             on the shipping tables.If the data is not found in the
--             shipping tables, it takes care of adding the new row to the
--             shipping tables.
-- Parameters :
-- IN:        p_del_id        IN          NUMBER,
--	      p_bol           IN          VARCHAR2,
--	      p_action_prms   IN          WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
-- IN OUT:
--
-- OUT:       x_return_status OUT NOCOPY  VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE synch_bols(
p_del_id        IN          NUMBER,
p_bol           IN          VARCHAR2,
p_action_prms   IN          WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
x_return_status OUT NOCOPY  VARCHAR2) IS

--Cursor to get the BOL and delivery Leg ID of a Delivery ID.
Cursor c_BOL(p_del_id NUMBER ) is
select
WDG.delivery_leg_id,
wdi.sequence_number bol
from
wsh_delivery_legs wdg,
wsh_document_instances wdi
where
wdg.delivery_leg_id = wdi.entity_id and
wdi.entity_name = 'WSH_DELIVERY_LEGS' AND
wdg.delivery_id = p_del_id AND
wdi.document_type= 'BOL';

l_delivery_leg_id    NUMBER;
l_bol                VARCHAR2(50);
l_return_status      VARCHAR2(1);
l_num_warnings  NUMBER;
l_num_errors  NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SYNCH_BOLS';
--
BEGIN
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_DEL_ID',P_DEL_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_BOL',P_BOL);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
OPEN c_BOL(p_del_id);
FETCH C_BOL into
l_delivery_leg_id,
l_bol;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_delivery_leg_id',l_delivery_leg_id);
    WSH_DEBUG_SV.log(l_module_name,'l_bol',l_bol);
END IF;
--


-- If there is a row present in the table wsh_document_instances for this
-- delivery leg id, then the corresponding row is updated with the new BOL,
-- if the BOLs are different i.e if the BOL passed as an input to this API
-- is different from the BOL present in the table.
-- If there is no row in the table wsh_document_instances for this
-- delivery leg id, then the API WSH_ASN_RECEIPT_PVT.CREATE_UPDATE_INBOUND_DOCUMENT
-- is called to create a new row.

IF c_BOL%FOUND THEN
  IF ((p_bol IS NOT NULL) AND (nvl(p_bol,'$$$$') <> nvl(l_bol,'$$$$'))) THEN
    UPDATE wsh_document_instances
    SET sequence_number = p_bol,
      last_update_date = SYSDATE,
      last_updated_by =  FND_GLOBAL.USER_ID,
      last_update_login =  FND_GLOBAL.LOGIN_ID
    WHERE entity_name = 'WSH_DELIVERY_LEGS'
    AND entity_id = l_delivery_leg_id
    AND document_type= 'BOL';
  END IF;
ELSIF (c_BOL%NOTFOUND) AND (p_bol IS NOT NULL) THEN


  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.CREATE_UPDATE_INBOUND_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;


  create_update_inbound_document (
     p_document_number => p_bol,
     p_entity_name => 'WSH_DELIVERY_LEGS',
     p_delivery_id => p_del_id,
     p_transaction_type => p_action_prms.action_code,
     x_return_status => l_return_status);
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status => l_return_status,
    x_num_warnings  => l_num_warnings,
    x_num_errors    => l_num_errors);

END IF;

CLOSE c_bol;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'ret sts at synch bols',x_return_status);
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.SYNCH_BOLS',l_module_name);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END synch_bols;


--========================================================================
-- PROCEDURE :  update_status
--
-- COMMENT   :  This API receives a list of delivery IDs,trip IDs and
--                 stop IDs and updates the status code of the IDs based
--                 on the received action code.
-- HISTORY   : Created the API.
--Cache Tables :
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |x_lpnGWTcachetbl           | LPN ID             | Gross Weight       |
--              |x_lpnGWTcacheExttbl        | LPN ID             | Gross Weight       |
--              -----------------------------------------------------------------------
--              |x_lpnNWTcachetbl           | LPN ID             | Net Weight         |
--              |x_lpnNWTcacheExttbl        | LPN ID             | Net Weight         |
--              -----------------------------------------------------------------------
--              |x_lpnVOLcachetbl           | LPN ID             | Volume             |
--              |x_lpnVOLcacheExttbl        | LPN ID             | Volume             |
--              -----------------------------------------------------------------------
--              |x_dlvyGWTcachetbl          | Delivery ID        | Gross Weight       |
--              |x_dlvyGWTcacheExttbl       | Delivery ID        | Gross Weight       |
--              -----------------------------------------------------------------------
--              |x_dlvyNWTcachetbl          | Delivery ID        | Net Weight         |
--              |x_dlvyNWTcacheExttbl       | Delivery ID        | Net Weight         |
--              -----------------------------------------------------------------------
--              |x_dlvyVOLcachetbl          | Delivery ID        | Volume             |
--              |x_dlvyVOLcacheExttbl       | Delivery ID        | Volume             |
--              -----------------------------------------------------------------------
--========================================================================



PROCEDURE update_status (
p_action_prms			IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
p_del_ids			IN wsh_util_core.id_tab_type,
p_trip_ids			IN wsh_util_core.id_tab_type,
p_stop_ids			IN wsh_util_core.id_tab_type,
p_shipment_header_id_tab        IN wsh_util_core.id_tab_type,
p_initial_pickup_date_tab       IN wsh_util_core.Date_Tab_Type ,
p_expected_receipt_date_tab     IN wsh_util_core.Date_Tab_Type ,
p_rcv_carrier_id_tab            IN wsh_util_core.Id_Tab_Type,
p_local_dd_rec                  IN LOCAL_DD_REC_TABLE_TYPE,
x_lpnGWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnGWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnNWTcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnNWTcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnVOLcachetbl                IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_lpnVOLcacheExttbl             IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyGWTcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyGWTcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyNWTcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyNWTcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyVOLcachetbl               IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_dlvyVOLcacheExttbl            IN OUT NOCOPY  WSH_UTIL_CORE.key_value_tab_type,
x_return_status                 OUT NOCOPY VARCHAR2) IS


l_delivery_info WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
l_num_warnings  NUMBER := 0;
l_num_errors    NUMBER := 0;
l_return_status VARCHAR2(1);
l_organization_id Number;

--Cursor to get the Ship method code for a Delivery ID for a given Carrier.
cursor l_carrier_csr (p_delivery_id IN NUMBER, p_carrier_id IN NUMBER) IS
select wcs.ship_method_code
from  wsh_new_deliveries wnd,
      wsh_carriers_v wcv,
      wsh_carrier_services wcs,
      wsh_org_carrier_services wocs
where wnd.delivery_id = p_delivery_id
and   wcv.carrier_id = p_carrier_id
and   wcv.active = 'A'
and   wocs.organization_id = wnd.organization_id
and   nvl(wcs.enabled_flag, 'N') = 'Y'
and   nvl(wocs.enabled_flag, 'N')= 'Y'
and   wcv.carrier_id = wcs.carrier_id
and   wcs.service_level = wnd.service_level(+)
and   wcs.mode_of_transport = wnd.mode_of_transport(+);

l_update_smc_flag VARCHAR2(1) := 'N';

l_flag boolean := FALSE;

l_ship_method_code VARCHAR2(32767);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_STATUS';
l_wf_rs VARCHAR2(1); --Pick to POD WF Project
--
BEGIN
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_action_prms.action_code',p_action_prms.action_code);
    WSH_DEBUG_SV.log(l_module_name,'p_del_ids.COUNT',p_del_ids.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'p_trip_ids.COUNT',p_trip_ids.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'p_stop_ids.COUNT',p_stop_ids.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'p_shipment_header_id_tab.COUNT',p_shipment_header_id_tab.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'p_initial_pickup_date_tab.COUNT',p_initial_pickup_date_tab.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'p_expected_receipt_date_tab.COUNT',p_expected_receipt_date_tab.COUNT);
    WSH_DEBUG_SV.log(l_module_name,'p_rcv_carrier_id_tab.COUNT',p_rcv_carrier_id_tab.COUNT);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
SAVEPOINT UPDATE_STATUS_PVT;

IF p_del_ids.COUNT > 0 THEN
  FOR i IN 1..p_del_ids.COUNT LOOP

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_del_ids(i)',p_del_ids(i));
    END IF;
    --
    IF ( p_action_prms.action_code IN ('ASN', 'RECEIPT')) THEN
    --{
      l_ship_method_code := NULL;
      l_update_smc_flag := NULL;
      IF (p_rcv_carrier_id_tab(i) is NOT NULL) THEN
      --{
        open  l_carrier_csr(p_del_ids(i), p_rcv_carrier_id_tab(i));
        fetch l_carrier_csr into l_ship_method_code;
        close l_carrier_csr;

        IF l_ship_method_code IS NULL THEN
          l_update_smc_flag := 'Y';
        END IF;
      --}
      END IF;
    --}
    END IF;

    IF p_action_prms.action_code ='ASN' THEN

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_del_ids(i)',p_del_ids(i));
         WSH_DEBUG_SV.log(l_module_name,'p_shipment_header_id_tab(i)',p_shipment_header_id_tab(i));
         WSH_DEBUG_SV.log(l_module_name,'p_initial_pickup_date_tab(i)',p_initial_pickup_date_tab(i));
      END IF;

      UPDATE WSH_NEW_DELIVERIES
      SET status_code = 'IT',
      ASN_SHIPMENT_HEADER_ID = p_shipment_header_id_tab(i),
      INITIAL_PICKUP_DATE = nvl(p_initial_pickup_date_tab(i),INITIAL_PICKUP_DATE),
      ULTIMATE_DROPOFF_DATE = GREATEST
                                (
                                  nvl
                                    (
                                      p_initial_pickup_date_tab(i),
                                      nvl
                                        (
                                          INITIAL_PICKUP_DATE,
                                          nvl(p_expected_receipt_date_tab(i),ULTIMATE_DROPOFF_DATE)
                                        )
                                    ),
                                  nvl
                                    (
                                      p_expected_receipt_date_tab(i),
                                      NVL
                                        (
                                          ULTIMATE_DROPOFF_DATE,
                                          NVL(p_initial_pickup_date_tab(i), INITIAL_PICKUP_DATE)
                                        )
                                    )
                                ),
      carrier_id    = nvl(p_rcv_carrier_id_tab(i), carrier_id),
      ship_method_code = decode(l_update_smc_flag, 'Y', NULL,nvl(l_ship_method_code, ship_method_code)),
      service_level = decode(l_update_smc_flag, 'Y', NULL,service_level),
      mode_of_transport = decode(l_update_smc_flag, 'Y', NULL,mode_of_transport),
      last_update_date = SYSDATE,
      last_updated_by =  FND_GLOBAL.USER_ID,
      last_update_login =  FND_GLOBAL.LOGIN_ID
      Where DELIVERY_ID = p_del_ids(i)
      RETURNING organization_id into l_organization_id ;

      /*CURRENTLY NOT IN USE
      --Raise Event: Pick To Pod Workflow
	  WSH_WF_STD.Raise_Event(
							p_entity_type => 'DELIVERY',
							p_entity_id =>  p_del_ids(i),
							p_event => 'oracle.apps.fte.delivery.ib.asnmatched' ,
							p_organization_id => l_organization_id ,
							x_return_status => l_wf_rs ) ;
		 --Error Handling to be done in WSH_WF_STD.Raise_Event itself
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
		     WSH_DEBUG_SV.log(l_module_name,'Delivery ID is  ',  p_del_ids(i));
		     WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
		 END IF;
	--Done Raise Event: Pick To Pod Workflow
	*/
    ELSIF p_action_prms.action_code = 'CANCEL_ASN' or  p_action_prms.action_code = 'REVERT_ASN' then
      UPDATE WSH_NEW_DELIVERIES
      SET status_code = 'OP',
      Asn_shipment_header_id = NULL,
      last_update_date = SYSDATE,
      last_updated_by =  FND_GLOBAL.USER_ID,
      last_update_login =  FND_GLOBAL.LOGIN_ID
      Where DELIVERY_ID = p_del_ids(i)
      RETURNING organization_id into l_organization_id ;

      /*CURRENTLY NOT IN USE
      --Raise Event: Pick To Pod Workflow
	  WSH_WF_STD.Raise_Event(
							p_entity_type => 'DELIVERY',
							p_entity_id =>  p_del_ids(i),
							p_event => 'oracle.apps.fte.delivery.ib.asnreverted' ,
							p_organization_id => l_organization_id ,
							x_return_status => l_wf_rs ) ;
		 --Error Handling to be done in WSH_WF_STD.Raise_Event itself
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
		     WSH_DEBUG_SV.log(l_module_name,'Delivery ID is  ',  p_del_ids(i));
		     WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
		 END IF;
	--Done Raise Event: Pick To Pod Workflow
	*/
    ELSIF p_action_prms.action_code = 'RECEIPT' THEN

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'p_del_ids(i)',p_del_ids(i));
         WSH_DEBUG_SV.log(l_module_name,'p_shipment_header_id_tab(i)',p_shipment_header_id_tab(i));
         WSH_DEBUG_SV.log(l_module_name,'p_expected_receipt_date_tab(i)',p_expected_receipt_date_tab(i));
      END IF;

      UPDATE WSH_NEW_DELIVERIES
      SET status_code = 'CL',
      RCV_SHIPMENT_HEADER_ID = p_shipment_header_id_tab(i),
      --INITIAL_PICKUP_DATE = p_initial_pickup_date_tab(i),
      --INITIAL_PICKUP_DATE = nvl(p_initial_pickup_date_tab(i),INITIAL_PICKUP_DATE),
      --ULTIMATE_DROPOFF_DATE = GREATEST(nvl(p_initial_pickup_date_tab(i),nvl(INITIAL_PICKUP_DATE, nvl(p_expected_receipt_date_tab(i),ULTIMATE_DROPOFF_DATE))),
                                       --nvl(p_expected_receipt_date_tab(i),ULTIMATE_DROPOFF_DATE)),
      INITIAL_PICKUP_DATE =
                              LEAST
                                (
                                  nvl
                                    (
                                      p_initial_pickup_date_tab(i),
                                      nvl
                                        (
                                          INITIAL_PICKUP_DATE,
                                          nvl(p_expected_receipt_date_tab(i),ULTIMATE_DROPOFF_DATE)
                                        )
                                    ),
                                  nvl
                                    (
                                      p_expected_receipt_date_tab(i),
                                      NVL
                                        (
                                          ULTIMATE_DROPOFF_DATE,
                                          NVL(p_initial_pickup_date_tab(i), INITIAL_PICKUP_DATE)
                                        )
                                    )
                                ),
      ULTIMATE_DROPOFF_DATE =   NVL
                                    (
                                      p_expected_receipt_date_tab(i),
                                      NVL
                                        (
                                          ULTIMATE_DROPOFF_DATE,
                                          NVL(p_initial_pickup_date_tab(i), INITIAL_PICKUP_DATE)
                                        )
                                    ),
      carrier_id    = nvl(p_rcv_carrier_id_tab(i), carrier_id),
      ship_method_code = decode(l_update_smc_flag, 'Y', NULL,nvl(l_ship_method_code, ship_method_code)),
      service_level = decode(l_update_smc_flag, 'Y', NULL,service_level),
      mode_of_transport = decode(l_update_smc_flag, 'Y', NULL,mode_of_transport),
      last_update_date = SYSDATE,
      last_updated_by =  FND_GLOBAL.USER_ID,
      last_update_login =  FND_GLOBAL.LOGIN_ID
      Where DELIVERY_ID = p_del_ids(i)
      RETURNING organization_id into l_organization_id ;

	 /*CURRENTLY NOT IN USE
	 --Raise Event: Pick To Pod Workflow
	  WSH_WF_STD.Raise_Event(
							p_entity_type => 'DELIVERY',
							p_entity_id =>  p_del_ids(i),
							p_event => 'oracle.apps.fte.delivery.ib.receiptreceived' ,
							p_organization_id => l_organization_id ,
							x_return_status => l_wf_rs ) ;
		 --Error Handling to be done in WSH_WF_STD.Raise_Event itself
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.log(l_module_name,'Current Time is ',SYSDATE);
		     WSH_DEBUG_SV.log(l_module_name,'Delivery ID is  ',  p_del_ids(i));
		     WSH_DEBUG_SV.log(l_module_name,'Return Status After Calling WSH_WF_STD.Raise_Event',l_wf_rs);
		 END IF;
	--Done Raise Event: Pick To Pod Workflow
	*/

    END IF;
  END LOOP;

  l_flag := FALSE;

  IF (p_del_ids.COUNT = 1 AND(p_action_prms.action_code ='ASN' OR p_action_prms.action_code ='RECEIPT')
     AND
     (p_local_dd_rec(p_local_dd_rec.FIRST).rcv_gross_weight IS NOT NULL
      AND p_local_dd_rec(p_local_dd_rec.FIRST).rcv_net_weight IS NOT NULL
      AND p_local_dd_rec(p_local_dd_rec.FIRST).rcv_gross_weight_uom_code IS NOT NULL
     )
    )
  THEN
     l_flag := TRUE;
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.POPULATE_RECORD',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_NEW_DELIVERIES_PVT.Populate_Record
        (p_delivery_id         => p_del_ids(p_del_ids.FIRST),
         x_delivery_info => l_delivery_info,
         x_return_status => l_return_status);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings  => l_num_warnings,
         x_num_errors    => l_num_errors);

     l_delivery_info.gross_weight    := p_local_dd_rec(p_local_dd_rec.FIRST).rcv_gross_weight ;
     l_delivery_info.net_weight      := p_local_dd_rec(p_local_dd_rec.FIRST).rcv_net_weight;
     l_delivery_info.WEIGHT_UOM_CODE := p_local_dd_rec(p_local_dd_rec.FIRST).rcv_gross_weight_uom_code;
     l_delivery_info.PRORATE_WT_FLAG := 'Y'; --Set Prorate weight flag
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.UPDATE_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_NEW_DELIVERIES_PVT.Update_Delivery
        (p_rowid                => l_delivery_info.ROWID,
         p_delivery_info        => l_delivery_info,
         x_return_status        => l_return_status);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     wsh_util_core.api_post_call(
         p_return_status => l_return_status,
         x_num_warnings  => l_num_warnings,
         x_num_errors    => l_num_errors);

  END IF;
  --
  --
  --{ --NNP-WV
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_flag',l_flag);
        END IF;

  IF ( NOT(l_flag)  AND(p_action_prms.action_code ='ASN' OR p_action_prms.action_code ='RECEIPT') )
  THEN
  --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.updateWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
        WSH_ASN_RECEIPT_PVT.updateWeightVolume
          (
            p_entity                     => 'DLVY',
            x_GWTcachetbl                => x_dlvyGWTcachetbl,
            x_GWTcacheExttbl             => x_dlvyGWTcacheExttbl,
            x_NWTcachetbl                => x_dlvyNWTcachetbl,
            x_NWTcacheExttbl             => x_dlvyNWTcacheExttbl,
            x_VOLcachetbl                => x_dlvyVOLcachetbl,
            x_VOLcacheExttbl             => x_dlvyVOLcacheExttbl,
            x_return_status              => l_return_status
          );
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.updateWeightVolume',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        --
        WSH_ASN_RECEIPT_PVT.updateWeightVolume
          (
            p_entity                     => 'LPN',
            x_GWTcachetbl                => x_LPNGWTcachetbl,
            x_GWTcacheExttbl             => x_LPNGWTcacheExttbl,
            x_NWTcachetbl                => x_LPNNWTcachetbl,
            x_NWTcacheExttbl             => x_LPNNWTcacheExttbl,
            x_VOLcachetbl                => x_LPNVOLcachetbl,
            x_VOLcacheExttbl             => x_LPNVOLcacheExttbl,
            x_return_status              => l_return_status
          );
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        wsh_util_core.api_post_call
          (
            p_return_status => l_return_status,
            x_num_warnings  => l_num_warnings,
            x_num_errors    => l_num_errors
          );
        --
  --}
  END IF;
  --}

END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_STATUS_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.UPDATE_STATUS',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Update_status;


-- Start of comments
-- API name : consolidate_qty
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API consolidates (aggregates) the quantity pertaining to
--            each unique shipment line ID.
-- Parameters :
-- IN:
--             po_shipment_line_id   IN            NUMBER
--		 The Shipment line ID based on which the quantities are consolidated
--		 against.
-- IN OUT:
--             p_sli_qty_cache	      IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--               A key-value mapping table.The key is the input parameter po_shipment_line_id
--               and the value is the sum of the values of the input parameter p_remaining_qty
--               corresponding to that po_shipment_line_id. Values are stored in this table
--               only if the key value is <= (2^31 -1).
--	       p_sli_qty_ext_cache   IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--               A key-value mapping table.The key is the input parameter po_shipment_line_id
--               and the value is the sum of the values of the input parameter p_remaining_qty
--               corresponding to that po_shipment_line_id. Values are stored in this table
--               only if the key value is > (2^31 -1).
--	       p_remaining_qty       IN OUT NOCOPY NUMBER
--               The quantity to be consilidated against the given po_shipment_line_id.
-- OUT:
--	       x_return_status          OUT NOCOPY VARCHAR2
--Cache Tables:
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |p_sli_qty_cache            | Shipment Line ID   | Quantity           |
--              |p_sli_qty_ext_cache        | Shipment Line ID   | Quantity           |
--              |----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE consolidate_qty(
p_sli_qty_cache              IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_sli_qty_ext_cache   IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
p_remaining_qty       IN OUT NOCOPY NUMBER,
po_shipment_line_id   IN            NUMBER,
x_return_status          OUT NOCOPY VARCHAR2) IS

l_new_qty       NUMBER;
l_return_status   VARCHAR2(1);
l_num_warnings   NUMBER;
l_num_errors     NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CONSOLIDATE_QTY';
--
BEGIN

--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_REMAINING_QTY',P_REMAINING_QTY);
    WSH_DEBUG_SV.log(l_module_name,'PO_SHIPMENT_LINE_ID',PO_SHIPMENT_LINE_ID);
    WSH_DEBUG_SV.log(l_module_name,'p_sli_qty_cache.count',p_sli_qty_cache.count);
    WSH_DEBUG_SV.log(l_module_name,'p_sli_qty_ext_cache.count',p_sli_qty_ext_cache.count);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_new_qty       := p_remaining_qty;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-p_sli_qty_cache',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_util_core.get_cached_value(
              p_cache_tbl     =>  p_sli_qty_cache,
              p_cache_ext_tbl =>  p_sli_qty_ext_cache,
              p_value         =>  p_remaining_qty,
              p_key           =>  po_shipment_line_id,
              p_action        =>  'GET',
              x_return_status =>  l_return_status );

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    WSH_DEBUG_SV.log(l_module_name,'after get-p_remaining_qty',p_remaining_qty);
END IF;
--

  --MEANS THE PO_LINE_LOCATION_ID IS NOT THERE IN THE CACHE
  --SO ADD IT TO THE CACHE WITH THE NEW QTY AS
IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
  p_remaining_qty := l_new_qty;

  --MEANS THE PO_LINE_LOCATION_ID IS ALREADY THERE.SO GET THE QTY(which is now available
  --in the p_remaining_qty)  ...AND ADD THE NEW QTY
  --TO IT..AND ADD THE CONSILADTED QTY BACK TO THE CACHE FOR THIS PO_LINE_LOCATION_ID
ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
   p_remaining_qty :=  p_remaining_qty + l_new_qty;
ElSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
   raise FND_API.G_EXC_ERROR;
ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR  THEN
   raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'final-p_remaining_qty',p_remaining_qty);
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-p_sli_qty_cache',WSH_DEBUG_SV.C_PROC_LEVEL);
END IF;
--
wsh_util_core.get_cached_value(
  p_cache_tbl     =>  p_sli_qty_cache,
  p_cache_ext_tbl =>  p_sli_qty_ext_cache,
  p_value         =>  p_remaining_qty,
  p_key           =>  po_shipment_line_id,
  p_action        =>  'PUT',
  x_return_status =>  l_return_status );

IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR  THEN
  raise FND_API.G_EXC_ERROR;
ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR -- Added by NPARIKH
THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;



IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.CONSOLIDATE_QTY',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END consolidate_qty;



-- Start of comments
-- API name : populate_update_dd_rec
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API is used to populate the o/p paramater l_update_dd_rec (table of records)
--            which is used for the bulk updates at final stages of process_matched_txns API.
--            It derives the information for a particular delivery Detail ID
--            corresponding to the records pointed by the i/p parameter p_index
--            from the other i/p parameters p_line_rec and p_dd_rec. The API also finds out whether
--            the corresponding Delivery detail ID has an LPN.If it has an LPN
--            then it gets the information about that line also and updates the same
--            into a new record of l_update_dd_rec.
-- Parameters:
-- IN:
--	      p_index          IN NUMBER
--              The position of the record of p_dd_rec upon which this API has been called.
--	      p_line_rec       IN OE_WSH_BULK_GRP.line_rec_type
--              A table of records which contains all information got from the PO side.
--              It contains a record for each delivery detail line.
--	      p_gross_weight   IN NUMBER DEFAULT NULL
--	      p_net_weight     IN NUMBER DEFAULT NULL
--	      p_volume         IN NUMBER DEFAULT NULL
--    	      x_release_status IN VARCHAR2
-- IN OUT:
--	      p_dd_rec IN OUT NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type
--              A table of records used only within this package.It gets its data
--              from the record structure p_line_rec and also from other API calls
--              made from the API process_matched_txns of this Package.
--	      l_update_dd_rec    IN OUT NOCOPY update_dd_rec_type
--	      x_lpnIdCacheTbl    IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
--	      x_lpnIdCacheExtTbl IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type
-- OUT:
--	      x_return_status       OUT NOCOPY VARCHAR2
--Cache Tables:
--              ----------------------------------------------------------------------
--              | Cache Table Name          |        Key         |      Value         |
--              ----------------------------------------------------------------------
--              |x_lpnIdCacheTbl            |  LPN ID            |   LPN ID           |
--              |x_lpnIdCacheExtTbl         |  LPN ID            |   LPN ID           |
--              -----------------------------------------------------------------------
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments



Procedure populate_update_dd_rec(
  p_dd_rec IN OUT NOCOPY WSH_IB_UI_RECON_GRP.asn_rcv_del_det_rec_type,
  p_index IN NUMBER,
  p_line_rec IN OE_WSH_BULK_GRP.line_rec_type,
  p_gross_weight IN NUMBER DEFAULT NULL,
  p_net_weight IN NUMBER DEFAULT NULL,
  p_volume IN NUMBER DEFAULT NULL,
  x_release_status IN VARCHAR2,
  l_update_dd_rec IN OUT NOCOPY update_dd_rec_type,
  x_lpnIdCacheTbl IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
  x_lpnIdCacheExtTbl IN OUT NOCOPY WSH_UTIL_CORE.key_value_tab_type,
  x_return_status OUT NOCOPY VARCHAR2
  )

IS

i            NUMBER;
l_index      NUMBER ;
l_return_status VARCHAR2(1);
l_shp_rcv_qty    NUMBER;
l_shp_rcv_qty2    NUMBER;
l_num_warnings NUMBER := 0;
l_num_errors   NUMBER := 0;

CURSOR lpn_csr(p_delivery_detail_id IN NUMBER)
IS
  SELECT parent_delivery_detail_id, wdd.last_update_date
  FROM   wsh_delivery_assignments_v wda, wsh_delivery_details wdd
  WHERE  wda.delivery_detail_id = p_delivery_detail_id
		AND    wdd.delivery_detail_id = wda.parent_delivery_detail_id;
--
l_lpn_id               NUMBER;
l_lpn_last_update_date DATE;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POPULATE_UPDATE_DD_REC';
--
BEGIN

--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_INDEX',P_INDEX);
    WSH_DEBUG_SV.log(l_module_name,'P_gross_weight',P_gross_weight);
    WSH_DEBUG_SV.log(l_module_name,'P_net_weight',P_net_weight);
    WSH_DEBUG_SV.log(l_module_name,'P_volume',P_volume);
    WSH_DEBUG_SV.log(l_module_name,'X_RELEASE_STATUS',X_RELEASE_STATUS);
    WSH_DEBUG_SV.log(l_module_name,'l_update_dd_rec.delivery_detail_id.COUNT',l_update_dd_rec.delivery_detail_id.COUNT);
END IF;
--
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

i:= (l_update_dd_rec.delivery_detail_id.COUNT)+1;
l_index := p_dd_rec.shpmt_line_id_idx_tab(p_index);

l_update_dd_rec.delivery_detail_id.EXTEND;
l_update_dd_rec.requested_quantity.EXTEND;
l_update_dd_rec.shipped_quantity.EXTEND;
l_update_dd_rec.returned_quantity.EXTEND;
l_update_dd_rec.received_quantity.EXTEND;
l_update_dd_rec.requested_quantity2.EXTEND;
l_update_dd_rec.shipped_quantity2.EXTEND;
l_update_dd_rec.returned_quantity2.EXTEND;
l_update_dd_rec.received_quantity2.EXTEND;
l_update_dd_rec.inventory_item_id.EXTEND;
l_update_dd_rec.ship_from_location_id.EXTEND;
l_update_dd_rec.item_description.EXTEND;
l_update_dd_rec.released_status.EXTEND;
l_update_dd_rec.rcv_shipment_line_id.EXTEND;
l_update_dd_rec.waybill_num.EXTEND;
l_update_dd_rec.released_status_db.EXTEND;
l_update_dd_rec.gross_weight.EXTEND;
l_update_dd_rec.net_weight.EXTEND;
l_update_dd_rec.volume.EXTEND;
l_update_dd_rec.last_update_date.EXTEND;
l_update_dd_rec.shipped_date.EXTEND;

IF p_dd_rec.transaction_type = 'ASN' THEN
  l_shp_rcv_qty := p_dd_rec.shipped_qty_tab(p_index);
  l_shp_rcv_qty2 := p_dd_rec.shipped_qty2_tab(p_index); -- NNP
ELSIF p_dd_rec.transaction_type = 'RECEIPT' THEN
  l_shp_rcv_qty := p_dd_rec.received_qty_tab(p_index);
  l_shp_rcv_qty2 := p_dd_rec.received_qty2_tab(p_index); -- NNP
END IF;

IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_shp_rcv_quantity',l_shp_rcv_qty);
    WSH_DEBUG_SV.log(l_module_name,'l_shp_rcv_quantity2',l_shp_rcv_qty2);
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.requested_qty_tab(p_index)',p_dd_rec.requested_qty_tab(p_index));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.ship_from_location_id_tab(p_index)',p_dd_rec.ship_from_location_id_tab(p_index));
    WSH_DEBUG_SV.log(l_module_name,'p_dd_rec.last_update_date_tab(p_index)',p_dd_rec.last_update_date_tab(p_index));
    WSH_DEBUG_SV.log(l_module_name,'p_line_rec.shipped_date(l_index)',p_line_rec.shipped_date(l_index));
END IF;

l_update_dd_rec.delivery_detail_id(i)  := p_dd_rec.del_detail_id_tab(p_index);
l_update_dd_rec.requested_quantity(i)  := least(p_dd_rec.requested_qty_tab(p_index),l_shp_rcv_qty);
l_update_dd_rec.shipped_quantity(i)    := p_dd_rec.shipped_qty_tab(p_index);
l_update_dd_rec.returned_quantity(i)   := p_dd_rec.returned_qty_tab(p_index);
l_update_dd_rec.received_quantity(i)   := p_dd_rec.received_qty_tab(p_index);
l_update_dd_rec.requested_quantity2(i)  := least(p_dd_rec.requested_qty2_tab(p_index),l_shp_rcv_qty2); -- NNP
l_update_dd_rec.shipped_quantity2(i)    := p_dd_rec.shipped_qty2_tab(p_index);
l_update_dd_rec.returned_quantity2(i)   := p_dd_rec.returned_qty2_tab(p_index);
l_update_dd_rec.received_quantity2(i)   := p_dd_rec.received_qty2_tab(p_index);
l_update_dd_rec.inventory_item_id(i)  := nvl(p_line_rec.rcv_inventory_item_id(l_index),p_line_rec.inventory_item_id(l_index));
l_update_dd_rec.item_description(i)  := nvl(p_line_rec.rcv_item_description(l_index),p_line_rec.item_description(l_index));
l_update_dd_rec.released_status(i)     := x_release_status;
l_update_dd_rec.rcv_shipment_line_id(i):= p_dd_rec.shipment_line_id_tab(p_index);
l_update_dd_rec.ship_from_location_id(i):= p_dd_rec.ship_from_location_id_tab(p_index);
l_update_dd_rec.waybill_num(i) := p_line_rec.tracking_number(l_index);
l_update_dd_rec.released_status_db(i) := p_dd_rec.released_status_tab(p_index);
l_update_dd_rec.gross_weight(i) := p_gross_weight;
l_update_dd_rec.net_weight(i) := p_net_weight;
l_update_dd_rec.volume(i) := p_volume;
l_update_dd_rec.last_update_date(i) :=  p_dd_rec.last_update_date_tab(p_index);
l_update_dd_rec.shipped_date(i)  := p_line_rec.shipped_date(l_index);


/* added by NNP for LPN */


-- If true , then derive the information for the LPN corresponding to the delivery detail ID
IF p_dd_rec.transaction_type = 'RECEIPT'
THEN
--{
            l_lpn_id := NULL;
     --
     OPEN lpn_csr (p_delivery_detail_id => l_update_dd_rec.delivery_detail_id(i) );
     --
     FETCH lpn_csr INTO l_lpn_id, l_lpn_last_update_date;
     --
     CLOSE lpn_csr;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_lpn_id',l_lpn_id);
         WSH_DEBUG_SV.log(l_module_name,'l_lpn_lasT_update_date',l_lpn_last_update_date);
         WSH_DEBUG_SV.log(l_module_name,'contents - WDD ID ',l_update_dd_rec.delivery_detail_id(i));
     END IF;
     --

     --If true, it implies that the current delivery detail has an LPN associated with it.
     IF l_lpn_id IS NOT NULL
     THEN
     --{
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_lpnIdcacheTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --

	 --Check whether the LPN is already there in the cache table. If the LPN is
	 --not in the cache table, this API will return a warning.
         wsh_util_core.get_cached_value
           (
             p_cache_tbl         => x_lpnIdcacheTbl,
             p_cache_ext_tbl     => x_lpnIdcacheExtTbl,
             p_key               => l_lpn_id,
             p_value             => l_lpn_id,
             p_action            => 'GET',
             x_return_status     => l_return_status
           );
         --
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
         END IF;
         --
         --
         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
         THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
         THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
         THEN
         --{
             IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_CACHED_VALUE-x_cacheTbl',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --

	     --Add the LPN ID into this table as it is not existing till now.
             wsh_util_core.get_cached_value
               (
                 p_cache_tbl         => x_lpnIdcacheTbl,
                 p_cache_ext_tbl     => x_lpnIdcacheExtTbl,
                 p_key               => l_lpn_id,
                 p_value             => l_lpn_id,
                 p_action            => 'PUT',
                 x_return_status     => l_return_status
               );
             --
             --
             IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;
             --
             wsh_util_core.api_post_call
               (
                 p_return_status => l_return_status,
                 x_num_warnings  => l_num_warnings,
                 x_num_errors    => l_num_errors
               );
             --
             i:= (l_update_dd_rec.delivery_detail_id.COUNT)+1;
             --

             --updating the l_update_dd_rec with the details of the LPN ID.

             l_update_dd_rec.delivery_detail_id.EXTEND;
             l_update_dd_rec.requested_quantity.EXTEND;
             l_update_dd_rec.shipped_quantity.EXTEND;
             l_update_dd_rec.returned_quantity.EXTEND;
             l_update_dd_rec.received_quantity.EXTEND;
             l_update_dd_rec.requested_quantity2.EXTEND;
             l_update_dd_rec.shipped_quantity2.EXTEND;
             l_update_dd_rec.returned_quantity2.EXTEND;
             l_update_dd_rec.received_quantity2.EXTEND;
             l_update_dd_rec.inventory_item_id.EXTEND;
             l_update_dd_rec.ship_from_location_id.EXTEND;
             l_update_dd_rec.item_description.EXTEND;
             l_update_dd_rec.released_status.EXTEND;
             l_update_dd_rec.rcv_shipment_line_id.EXTEND;
             l_update_dd_rec.waybill_num.EXTEND;
             l_update_dd_rec.released_status_db.EXTEND;
             l_update_dd_rec.gross_weight.EXTEND;
             l_update_dd_rec.net_weight.EXTEND;
             l_update_dd_rec.volume.EXTEND;
             l_update_dd_rec.last_update_date.EXTEND;
             l_update_dd_rec.shipped_date.EXTEND;
             --
             l_update_dd_rec.delivery_detail_id(i) := l_lpn_id;
             l_update_dd_rec.requested_quantity(i)  := 1;
             l_update_dd_rec.shipped_quantity(i)    := 1;
             l_update_dd_rec.returned_quantity(i)   := NULL;
             l_update_dd_rec.received_quantity(i)   := 1;
             l_update_dd_rec.requested_quantity2(i)  := NULL;
             l_update_dd_rec.shipped_quantity2(i)    := NULL;
             l_update_dd_rec.returned_quantity2(i)   := NULL;
             l_update_dd_rec.received_quantity2(i)   := NULL;
             l_update_dd_rec.inventory_item_id(i)  := NULL;
             l_update_dd_rec.item_description(i)  := NULL;
             l_update_dd_rec.released_status(i)     := x_release_status;
             l_update_dd_rec.rcv_shipment_line_id(i):= p_dd_rec.shipment_line_id_tab(p_index);
             l_update_dd_rec.ship_from_location_id(i):= p_dd_rec.ship_from_location_id_tab(p_index);
             l_update_dd_rec.waybill_num(i) := NULL;
             l_update_dd_rec.released_status_db(i) := 'C';
             l_update_dd_rec.gross_weight(i) := NULL;
             l_update_dd_rec.net_weight(i) := NULL;
             l_update_dd_rec.volume(i) := NULL;
             l_update_dd_rec.last_update_date(i) :=  l_lpn_last_update_date;
             l_update_dd_rec.shipped_date(i)  := p_line_rec.shipped_date(l_index);
         --}
         END IF;
     --}
     END IF;
--}
END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.POPULATE_UPDATE_DD_REC',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--


END populate_update_dd_rec;




-- Start of comments
-- API name : create_update_waybill_psno_bol
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API creates/updates the waybill,PSNO or BOL for the
--	      current record of p_local_dd_rec being passed to this API.
-- Parameters:
-- IN:
--	      l_loop_index    IN NUMBER
--              The current record of the i/p parameter p_local_dd_rec .
-- IN OUT:
--  p_local_dd_rec  IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE
--     A record structure which contains all...
--  pack_ids        IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type
--     Contains a list of delivery detail IDs which have a common LPN or no LPN.
--  curr_del        IN OUT NOCOPY NUMBER
--     The current delivery upon which all the other input parameters depend on.
--  curr_bol        IN OUT NOCOPY VARCHAR2
--     The BOL corresponding to the Delivery leg id of the delivery specified in the
--     input parameter curr_del.
--  curr_lpn        IN OUT NOCOPY NUMBER
--     The LPN corresponding to the list of delivery detail IDs of the delivery specified
--     in the input parameter curr_del.
--  curr_lpn_name   IN OUT NOCOPY VARCHAR2
--  curr_del_det    IN OUT NOCOPY NUMBER
--  l_psno          IN OUT NOCOPY VARCHAR2
--     The packing slip number corresponding to the delivery specified in the input parameter
--     curr_del.
--  l_waybill       IN OUT NOCOPY VARCHAR2
--     The waybill number corresponding to the delivery specified in the input parameter
--     curr_del.
--  l_psno_flag     IN OUT NOCOPY NUMBER
--     Can take the value 0 or 1.
--       If the value is 0, it means that the Packing Slip # has remained the same for all
--       those records of p_local_dd_rec which correspond to the current delivery.In this
--       case the PSNO is updated against the delivery ID.
--       If the value is 1, then the PSNO is updated as NULL for the current delivery.
--  l_trigger       IN OUT NOCOPY NUMBER
--     Can take the value 0 or 1.
--      If the value is 0, it means there is no need to create a
--      new delivery based on the existing delivery.
--      If the value is 1, it means a split has to be done for the existing
--      delivery and a new delivery has to be created and also the delivery details
--      present in the input parameter pack_ids have to be re-assigned to this new
--      delivery.
--  l_waybill_flag  IN OUT NOCOPY NUMBER
--     Can take the value 0 or 1.
--       If the value is 0, it means that the waybill # has remained the same for all those records
--       of p_local_dd_rec which correspond to the current delivery.In this case the waybill
--       is updated against the delivery ID.
--       If the value is 1, then the waybill is updated as NULL for the current delivery.
--  temp_dels       IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type
--     Contains non-duplicate delivery IDs belonging to the record structure p_local_dd_rec
--     This is a dynamic container and goes on adding until all the records of the structure
--     are scanned.
--  p_action_prms   IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type
--     The Record which specifies the Caller,Action to Be performed and the transaction type etc.
-- OUT:
--  x_return_status OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE create_update_waybill_psno_bol(
  p_local_dd_rec  IN OUT NOCOPY LOCAL_DD_REC_TABLE_TYPE,
  l_loop_index    IN NUMBER,
  pack_ids        IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
  curr_del        IN OUT NOCOPY NUMBER,
  curr_bol        IN OUT NOCOPY VARCHAR2,
  curr_lpn        IN OUT NOCOPY NUMBER,
  curr_lpn_name   IN OUT NOCOPY VARCHAR2,
  curr_del_det    IN OUT NOCOPY NUMBER,
  l_psno          IN OUT NOCOPY VARCHAR2,
  l_waybill       IN OUT NOCOPY VARCHAR2,
  l_psno_flag     IN OUT NOCOPY NUMBER,
  l_trigger       IN OUT NOCOPY NUMBER,
  l_waybill_flag  IN OUT NOCOPY NUMBER,
  temp_dels       IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
  p_action_prms   IN OUT NOCOPY WSH_GLBL_VAR_STRCT_GRP.dd_action_parameters_rec_type,
  x_return_status OUT NOCOPY VARCHAR2
 )
IS

--Cursor to get the Delivery Leg ID for a given Delivery.
CURSOR get_delivery_info(p_delivery_id NUMBER) IS
SELECT dg.delivery_leg_id
FROM   wsh_new_deliveries dl,
       wsh_delivery_legs dg,
       wsh_trip_stops st,
       wsh_trips t
WHERE  dl.delivery_id = p_delivery_id AND
       dl.delivery_id = dg.delivery_id AND
       dg.pick_up_stop_id = st.stop_id AND
       st.trip_id = t.trip_id;

--Cursor to get the last Delivery Leg ID for a given Delivery.
CURSOR c_get_last_leg(p_delivery_id NUMBER) IS
SELECT wdl.delivery_leg_id
FROM   wsh_new_deliveries wnd,
       wsh_delivery_legs wdl,
       wsh_trip_stops wts,
       wsh_trips wt
WHERE  wnd.delivery_id = p_delivery_id   AND
       wnd.delivery_id = wdl.delivery_id AND
       wdl.drop_off_stop_id = wts.stop_id AND
       wnd.ultimate_dropoff_location_id = wts.stop_location_id AND
       wts.trip_id = wt.trip_id;

l_return_status VARCHAR2(1);
l_pack_status   VARCHAR2(1);
l_stored_del_id NUMBER;
l_delivery_leg_id NUMBER;
l_num_warnings  NUMBER;
l_num_errors    NUMBER;
l_new_del_id    NUMBER;
l_final_del_leg_id  NUMBER;
--
l_row_id        NUMBER;
l_leg_id_tab        WSH_UTIL_CORE.id_tab_type;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_WAYBILL_PSNO_BOL';
--
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'L_LOOP_INDEX',L_LOOP_INDEX);
    WSH_DEBUG_SV.log(l_module_name,'CURR_DEL',CURR_DEL);
    WSH_DEBUG_SV.log(l_module_name,'CURR_BOL',CURR_BOL);
    WSH_DEBUG_SV.log(l_module_name,'CURR_LPN',CURR_LPN);
    WSH_DEBUG_SV.log(l_module_name,'CURR_LPN_NAME',CURR_LPN_NAME);
    WSH_DEBUG_SV.log(l_module_name,'CURR_DEL_DET',CURR_DEL_DET);
    WSH_DEBUG_SV.log(l_module_name,'L_PSNO',L_PSNO);
    WSH_DEBUG_SV.log(l_module_name,'L_WAYBILL',L_WAYBILL);
    WSH_DEBUG_SV.log(l_module_name,'L_PSNO_FLAG',L_PSNO_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'L_TRIGGER',L_TRIGGER);
    WSH_DEBUG_SV.log(l_module_name,'L_WAYBILL_FLAG',L_WAYBILL_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'pack_ids.COUNT',pack_ids.COUNT);
END IF;
--


--Pack the delivery detail IDs into a container and give the curr_lpn name
--as the name for the container.
IF curr_lpn IS NOT NULL THEN
--{
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CONTAINER_ACTIONS.PACK_INBOUND_LINES',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  --Call to API wsh_container_actions.pack_inbound_lines
  wsh_container_actions.pack_inbound_lines(
    p_lines_tbl  => pack_ids ,
    p_lpn_id     => curr_lpn  ,
    p_lpn_name     => curr_lpn_name  ,
    p_delivery_id=> curr_del ,
				p_transactionType => p_action_prms.action_code,
    x_return_status => l_return_status,
    p_waybill_number => p_local_dd_rec(l_loop_index).waybill) ;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
    p_return_status    => l_return_status,
    x_num_warnings     => l_num_warnings,
    x_num_errors       => l_num_errors);
END IF;
--}



--If the value of l_trigger is 1, it means a split has to be done for the existing
--delivery and a new delivery has to be created and also the delivery details
--present in the input parameter pack_ids have to be re-assigned to this newly created
--delivery.
IF l_trigger = 1 THEN
--{
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INBOUND_UTIL_PKG.SPLIT_INBOUND_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  --Call to API WSH_INBOUND_UTIL_PKG.split_inbound_delivery
  WSH_INBOUND_UTIL_PKG.split_inbound_delivery(
    p_delivery_detail_id_tbl => pack_ids,
    p_delivery_id            => curr_del,
    x_delivery_id            => l_new_del_id,
    x_return_status          => l_return_status);
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
     p_return_status    => l_return_status,
     x_num_warnings     => l_num_warnings,
     x_num_errors       => l_num_errors);


  OPEN  c_get_last_leg(l_new_del_id); --code changed to use the newly created Delivery ID
  FETCH c_get_last_leg
        INTO l_final_del_leg_id;

  -- Create a new record in the table wsh_document_instances and update the record
  -- with the BOL number curr_bol for the current Delivery.
  IF (c_get_last_leg%FOUND) AND (curr_bol IS NOT NULL) THEN

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.CREATE_UPDATE_INBOUND_DOCUMENT ',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    --Call to API create_update_inbound_document
    create_update_inbound_document (
       p_document_number => curr_bol,
       p_entity_name => 'WSH_DELIVERY_LEGS',
       p_delivery_id => l_new_del_id,        --code changed to use the newly created Delivery ID
       p_transaction_type => p_action_prms.action_code,
       x_return_status => l_return_status);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_warnings  => l_num_warnings,
      x_num_errors    => l_num_errors);
  END IF;

  CLOSE c_get_last_leg;
  l_stored_del_id := l_new_del_id;


-- The following Else part -> Set the BOL for the last leg of the current Delivery if a matching record
-- is already existing in the table wsh_document_instances.
ELSE -- corresponding to IF l_trigger = 1 THEN
--} {

  OPEN  c_get_last_leg(curr_del);
  FETCH c_get_last_leg
        INTO l_final_del_leg_id;

  IF c_get_last_leg%FOUND THEN

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.SYNCH_BOLS',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    --API to update/synch the BOL.
    synch_bols(
      p_del_id => curr_del,
      p_bol    => curr_bol,
      p_action_prms => p_action_prms,
      x_return_status => l_return_status);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --

    wsh_util_core.api_post_call(
      p_return_status    => l_return_status,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);

  END IF;

  CLOSE c_get_last_leg;

  --l_trigger is set to 1 because for the Delivery ID curr_del, the first set of Detail lines having the same
  --BOL have been processed.
  l_trigger := 1;
  l_stored_del_id :=  curr_del;
END IF;

temp_dels(temp_dels.COUNT + 1) :=  l_stored_del_id;
pack_ids.delete;
pack_ids(pack_ids.count + 1)  := p_local_dd_rec(l_loop_index).del_detail_id;


-- Update the Packing Slip number for the current delivery after checking
-- for the existence of a matching record in wsh_document_instances.
-- If there is no matching record insert a new record using the
-- API WSH_ASN_RECEIPT_PVT.CREATE_UPDATE_INBOUND_DOCUMENT.
IF ((l_psno_flag = 0) AND (l_psno IS NOT NULL) ) THEN
  UPDATE wsh_document_instances
  SET
  sequence_number = l_psno,
  last_update_date = SYSDATE,
  last_updated_by =  FND_GLOBAL.USER_ID,
  last_update_login =  FND_GLOBAL.LOGIN_ID
  where
  entity_id        = l_stored_del_id
  AND entity_name  = 'WSH_NEW_DELIVERIES'
  AND document_type= 'PACK_TYPE';


  IF SQL%NOTFOUND THEN

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_ASN_RECEIPT_PVT.CREATE_UPDATE_INBOUND_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    create_update_inbound_document (
       p_document_number => l_psno,
       p_entity_name => 'WSH_NEW_DELIVERIES',
       p_delivery_id => l_stored_del_id,
       p_transaction_type => p_action_prms.action_code,
       x_return_status => l_return_status);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_warnings  => l_num_warnings,
      x_num_errors    => l_num_errors);
  END IF;
END IF;


-- Update the Packing Slip number for the current delivery iff
-- the waybill has not changed within the lines belonging to the
-- same delivery.
IF ((l_waybill_flag = 0) AND (l_waybill IS NOT NULL) ) THEN
  UPDATE
  wsh_new_deliveries
  SET
  waybill = l_waybill,
  last_update_date  =  SYSDATE,
  last_updated_by   =  FND_GLOBAL.USER_ID,
  last_update_login =  FND_GLOBAL.LOGIN_ID
  WHERE
  delivery_id  = l_stored_del_id;
END IF;

--Reset the Flags.
l_psno_flag := 0;
l_waybill_flag := 0;

curr_del := p_local_dd_rec(l_loop_index).delivery_id;
curr_BOL := p_local_dd_rec(l_loop_index).BOL;
curr_lpn := p_local_dd_rec(l_loop_index).lpn_id;
curr_lpn_name := p_local_dd_rec(l_loop_index).lpn_name;
curr_del_det := p_local_dd_rec(1).del_detail_id;
l_psno   := p_local_dd_rec(l_loop_index).psno;
l_waybill:= p_local_dd_rec(l_loop_index).waybill;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.create_update_waybill_psno_bol',l_module_name);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END create_update_waybill_psno_bol;




-- Start of comments
-- API name : create_update_inbound_document
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API creates/updates documents like BOL,PSNO and waybill depending
--            on whether they are already existing for the Delivery or not.
-- Parameters :
-- IN:
--	      p_document_number IN VARCHAR2
--              This holds the PSNO/BOL depending upon the entity name.If the
--		input p_entity_name is 'WSH_NEW_DELIVERIES', then this parameter holds PSNO.
--              If the input p_entity_name is 'WSH_DELIVERY_LEGS', then this parameter
--              holds BOL.
--	      p_entity_name IN VARCHAR2
--              Specifies what kind of document is present in the input parameter
--              p_document_number.
--	      p_delivery_id IN NUMBER
--	      p_transaction_type IN VARCHAR2
--               Specifies the type od Transaction viz.ASN RECEIPT
-- IN OUT:
-- OUT:
--	      x_return_status OUT NOCOPY  VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE create_update_inbound_document (
     p_document_number IN VARCHAR2,
     p_entity_name IN VARCHAR2,
     p_delivery_id IN NUMBER,
     p_transaction_type IN VARCHAR2,
     x_return_status OUT NOCOPY  VARCHAR2) IS

--Cursor to get a Deliveries Leg ID,ship method Code etc.
CURSOR get_delivery_info IS
SELECT dg.delivery_leg_id,
       dl.initial_pickup_location_id,
       dl.ULTIMATE_DROPOFF_LOCATION_ID,
       t.ship_method_code,
       dl.organization_id,
       t.name
FROM   wsh_new_deliveries dl,
       wsh_delivery_legs dg,
       wsh_trip_stops st,
       wsh_trips t
WHERE  dl.delivery_id = p_delivery_id AND
       dl.delivery_id = dg.delivery_id AND
       dg.drop_off_stop_id = st.stop_id AND
       st.stop_location_id = dl.ULTIMATE_DROPOFF_LOCATION_ID AND
       st.trip_id = t.trip_id;

--Cursor to get the Ledger ID for the Organisation.  -- LE Uptake
CURSOR get_ledger_id (l_org_id NUMBER) IS      --performance
select to_number(ORG_INFORMATION1)
from
HR_ORGANIZATION_INFORMATION
where
ORGANIZATION_ID = l_org_id AND
(ORG_INFORMATION_CONTEXT || '') ='Accounting Information';

--Cursor to get the Documents sequence .
CURSOR get_doc_sequence_category_id(l_doc_type VARCHAR2) IS
select doc_sequence_category_id
from wsh_doc_sequence_categories
where document_type = l_doc_type;

--Cursor to determine the existence of PSNO/BOL for the given Delivery ID and its last Leg.
Cursor c_bol_psno_exists(l_ent_id NUMBER,l_ent_name VARCHAR2,l_doc_type VARCHAR2) is
select
'1'
from
wsh_document_instances wdi
where
wdi.entity_id    = l_ent_id   AND
wdi.entity_name  = l_ent_name AND
wdi.document_type= l_doc_type;


l_return_status varchar2(1);
l_doc_sequence_category_id NUMBER;
l_ledger_id  NUMBER;  -- LE Uptake
l_delivery_leg_id  NUMBER;
l_pickup_location_id  NUMBER;
l_ultimate_dropoff_location_id NUMBER;
l_location_id     NUMBER;
l_ship_method_code  VARCHAR2(30);
l_organization_id  NUMBER;
l_document_number  VARCHAR2(50);
l_pack_slip_flag    VARCHAR2(1);
l_trip_name              VARCHAR2(50);
x_msg_count      NUMBER;
x_msg_data      VARCHAR2(2000);
l_num_warnings  NUMBER;
l_num_errors  NUMBER;

l_entity_id NUMBER;
l_temp NUMBER;
l_document_type VARCHAR2(30);
l_document_sub_type VARCHAR2(30);

l_status      VARCHAR2(25) := 'OPEN'; -- Bug 3761178
l_appl_num NUMBER; --Bug# 3789154
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_INBOUND_DOCUMENT';
--
BEGIN


x_return_status := wsh_util_core.g_ret_sts_success;
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',p_delivery_id);
    WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_NUMBER',p_document_number);
    WSH_DEBUG_SV.log(l_module_name,'p_entity_name',p_entity_name);
    WSH_DEBUG_SV.log(l_module_name,'p_transaction_type',p_transaction_type);
END IF;
--

OPEN  get_delivery_info;
FETCH get_delivery_info INTO l_delivery_leg_id,
               l_pickup_location_id,
               l_ultimate_dropoff_location_id,
               l_ship_method_code,
               l_organization_id,
               l_trip_name;
CLOSE get_delivery_info;



-- LE Uptake
OPEN   get_ledger_id(l_organization_id);
FETCH  get_ledger_id INTO l_ledger_id;

IF (get_ledger_id%NOTFOUND) THEN
  FND_MESSAGE.SET_NAME('WSH','WSH_LEDGER_NOT_FOUND');



  raise FND_API.G_EXC_ERROR;
END IF;

CLOSE  get_ledger_id;


IF p_transaction_type = 'ASN' THEN
  l_location_id := l_pickup_location_id;
ELSIF p_transaction_type = 'RECEIPT' THEN
  l_location_id := l_ultimate_dropoff_location_id;
END IF;



IF    p_entity_name = 'WSH_DELIVERY_LEGS' THEN
  l_document_type      := 'BOL';
  l_document_sub_type  := l_ship_method_code; -- l_document_sub_type used to retrive the prefix and suufix and docuemnt category type .which is not needed
  l_entity_id          := l_delivery_leg_id;

ELSIF p_entity_name = 'WSH_NEW_DELIVERIES' THEN
  l_document_type      := 'PACK_TYPE';
  l_document_sub_type  := 'SALES_ORDER';
  l_entity_id          := p_delivery_id;

END IF;

/*
OPEN  get_doc_sequence_category_id(l_document_type);
FETCH get_doc_sequence_category_id INTO l_doc_sequence_category_id;
CLOSE get_doc_sequence_category_id;
*/

OPEN  c_bol_psno_exists(l_entity_id,p_entity_name,l_document_type);
FETCH c_bol_psno_exists INTO l_temp;


IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_temp',l_temp);
END IF;


--True if record already exists in wsh_document_instances for this delivery leg id
--.So just do an update for the current document number.
IF c_bol_psno_exists%FOUND THEN


   UPDATE wsh_document_instances
    SET sequence_number = p_document_number,
      last_update_date = SYSDATE,
      last_updated_by =  FND_GLOBAL.USER_ID,
      last_update_login =  FND_GLOBAL.LOGIN_ID
    WHERE entity_name  = p_entity_name
    AND   entity_id    = l_entity_id
    AND   document_type= l_document_type;

 --means no matching records in wsh_document_instances
 --so insert a new record
ELSIF c_bol_psno_exists%NOTFOUND THEN

  --{ Bug 3761178
     --
     -- The decode statement that was in the values clause of the coming insert stmt
     -- have been modified to make use of local variable l_status for performance reasons.
     --

    IF p_entity_name = 'WSH_DELIVERY_LEGS' THEN
       l_status := 'PLANNED';
    ELSIF p_entity_name ='WSH_NEW_DELIVERIES' THEN
       l_status := 'OPEN';
    END IF;

  --}

  l_appl_num := 665; --Bug# 3789154

  INSERT INTO wsh_document_instances
  ( document_instance_id
  , document_type
  , sequence_number
  , status
  , final_print_date
  , entity_name
  , entity_id
  , doc_sequence_category_id
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , attribute_category
  , attribute1
  , attribute2
  , attribute3
  , attribute4
  , attribute5
  , attribute6
  , attribute7
  , attribute8
  , attribute9
  , attribute10
  , attribute11
  , attribute12
  , attribute13
  , attribute14
  , attribute15
  )
VALUES
    ( wsh_document_instances_s.nextval
    , l_document_type
    , p_document_number
    , l_status
    , null
    , p_entity_name
    , l_entity_id
    , l_doc_sequence_category_id
    , fnd_global.user_id
    , sysdate
    , fnd_global.user_id
    , sysdate
    , fnd_global.login_id
    , l_appl_num --Bug# 3789154
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    );

END IF;

CLOSE c_bol_psno_exists;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
  END IF;
  --
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.create_update_inbound_document ',l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
end create_update_inbound_document ;




-- Start of comments
-- API name : cancel_close_pending_txns
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API calls the WSH_PO_CMG_PVT.close_cancel_po with two sets of data
--            which were collected in the API WSH_ASN_RECEIPT_PVT.Process_Matched_Txns
--            .These(two sets of data) contain rows which were tried to be closed or
--            cancelled when txns were pending against them and therefore those lines
--            have to be closed when the txns have been matched.This job is taken care
--            of this API.
-- Parameters:
-- IN:
--	p_po_cancel_rec       IN OE_WSH_BULK_GRP.line_rec_type
--        contains details of the lines which are to be cancelled.These details
--        include shipment_line_id, header_id,delivery_detail_id etc.
--	p_po_close_rec        IN OE_WSH_BULK_GRP.line_rec_type
--        contains details of the lines which are to be closed..These details
--        include shipment_line_id, header_id,delivery_detail_id etc.
-- IN OUT:
-- OUT:
-- Version : 1.0
-- Previous version 1.0
-- Initial version  1.0
-- End of comments


PROCEDURE cancel_close_pending_txns(
p_po_cancel_rec       IN OE_WSH_BULK_GRP.line_rec_type,
p_po_close_rec        IN OE_WSH_BULK_GRP.line_rec_type,
x_return_status OUT NOCOPY VARCHAR2)

IS

l_action_prms  WSH_BULK_TYPES_GRP.action_parameters_rectype;
l_num_warnings   NUMBER := 0;
l_num_errors     NUMBER := 0;
l_return_status        VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'cancel_close_pending_txns';
--

BEGIN

x_return_status := wsh_util_core.g_ret_sts_success;
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL
THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;
--
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'l_action_prms.action_code',l_action_prms.action_code);
    WSH_DEBUG_SV.log(l_module_name, 'p_po_cancel_rec.header_id.COUNT',p_po_cancel_rec.header_id.COUNT);
    WSH_DEBUG_SV.log(l_module_name, 'p_po_close_rec.header_id.COUNT',p_po_close_rec.header_id.COUNT);
END IF;
--

-- True if there are any lines(Delivery_detail_id s) to be Cancelled.Typically these are the
-- lines which were tried to be cancelled, when transactions were pending against them.
IF p_po_cancel_rec.line_id.COUNT > 0 THEN
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.CANCEL_CLOSE_PO',WSH_DEBUG_SV.C_PROC_LEVEL);

  END IF;
  --
  l_action_prms.action_code := 'CANCEL_PO';
  --Call API WSH_PO_CMG_PVT.cancel_close_po
  WSH_PO_CMG_PVT.cancel_close_po(
    p_line_rec      => p_po_cancel_rec,
    p_action_prms   => l_action_prms,
    x_return_status => l_return_status);
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
     p_return_status => l_return_status,
     x_num_warnings  => l_num_warnings,
     x_num_errors    => l_num_errors);

END IF;

-- True if there are any lines(Delivery_detail_id s) to be Closed.Typically these are the
-- lines which were tried to be closed, when transactions were pending against them.
IF p_po_close_rec.line_id.COUNT > 0 THEN
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.CANCEL_CLOSE_PO',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  l_action_prms.action_code := 'CLOSE_PO';
  --
  --Call API WSH_PO_CMG_PVT.cancel_close_po
  WSH_PO_CMG_PVT.cancel_close_po(
    p_line_rec      => p_po_close_rec,
    p_action_prms   => l_action_prms,
    x_return_status => l_return_status);
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_util_core.api_post_call(
      p_return_status => l_return_status,
      x_num_warnings  => l_num_warnings,
      x_num_errors    => l_num_errors);

END IF;



--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
IF l_num_errors > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
ELSIF l_num_warnings > 0 THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
  WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
     WSH_UTIL_CORE.Default_Handler('WSH_ASN_RECEIPT_PVT.cancel_close_pending_txns');

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
END cancel_close_pending_txns;

END WSH_ASN_RECEIPT_PVT;

/
