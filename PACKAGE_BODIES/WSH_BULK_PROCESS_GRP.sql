--------------------------------------------------------
--  DDL for Package Body WSH_BULK_PROCESS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_BULK_PROCESS_GRP" as
/* $Header: WSHBPGPB.pls 120.2 2007/01/03 23:07:11 parkhj noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_BULK_PROCESS_GRP';

--========================================================================
-- PROCEDURE : Create_update_delivery_details
--
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_commit                FND_API.G_TRUE to perform a commit
--	       p_action_prms           Additional attributes needed
--	       x_Out_Rec               Place holder
--	       p_line_rec              Line record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   :  This API is called from ONT to import delivery details and
--              delivery_assignments
--              At this time only insert operation (action='CREATE') is
--              supported for OM lines.
--              This API is also called from PO.
--========================================================================
  PROCEDURE Create_update_delivery_details(
                  p_api_version_number IN   NUMBER,
                  p_init_msg_list          IN   VARCHAR2,
                  p_commit         IN   VARCHAR2,
                  p_action_prms      IN
                              WSH_BULK_TYPES_GRP.action_parameters_rectype,
                  p_line_rec  IN OUT NOCOPY OE_WSH_BULK_GRP.Line_rec_type,
                  x_Out_Rec               OUT NOCOPY
                                WSH_BULK_TYPES_GRP.Bulk_process_out_rec_type,
                  x_return_status          OUT  NOCOPY VARCHAR2,
                  x_msg_count              OUT  NOCOPY NUMBER,
                  x_msg_data               OUT  NOCOPY VARCHAR2
  )
  IS
    l_debug_on BOOLEAN;
    --
    l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
               '.' || 'CREATE_UPDATE_DELIVERY_DETAILS';
    l_api_name     CONSTANT VARCHAR2(40):= 'CREATE_UPDATE_DELIVERY_DETAILS';
    l_api_version_number      CONSTANT NUMBER := 1.0;
    l_token_name              VARCHAR2(200);
    l_return_status           VARCHAR2(1);
    l_num_warnings            NUMBER;
    l_num_errors              NUMBER;
    l_action_prms             WSH_BULK_TYPES_GRP.action_parameters_rectype;

    --Bugfix 4070732
    l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_reset_flags BOOLEAN;
    l_otm_installed VARCHAR2(1) ;
    e_success       EXCEPTION;

  BEGIN

    IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null THEN  --Bugfix 4070732
      WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
      WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
    END IF;

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;

    SAVEPOINT S_CREATE_UPDATE_DETAILS_BULK;

    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    IF l_debug_on THEN
      wsh_debug_sv.push (l_module_name);
      wsh_debug_sv.log (l_module_name,'p_api_version_number',p_api_version_number);
      wsh_debug_sv.log (l_module_name,'p_init_msg_list',p_init_msg_list);
      wsh_debug_sv.log (l_module_name,'p_commit',p_commit);
      wsh_debug_sv.log (l_module_name,'Caller',p_action_prms.Caller);
      wsh_debug_sv.log (l_module_name,'action_code',p_action_prms.action_code);
      wsh_debug_sv.log (l_module_name,'Org_id',p_action_prms.Org_id);
    END IF;

    IF NOT FND_API.Compatible_API_Call
      ( l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
       )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    IF p_action_prms.caller IS NULL THEN
       l_token_name := 'p_action_prms.caller';
    ELSIF p_action_prms.action_code IS NULL THEN
       l_token_name := 'p_action_prms.action_code';
    END IF;

    IF l_token_name IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('WSH','WSH_REQUIRED_FIELD_NULL');
      FND_MESSAGE.SET_TOKEN('FIELD_NAME',l_token_name);
      l_return_status:=wsh_util_core.g_ret_sts_unexp_error;
      wsh_util_core.add_message(x_return_status,l_module_name);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;  --bms should we raise unexpected??
    END IF;

    -- IF caller is neither 'OM' or 'PO', raise an exception.
    IF p_action_prms.caller NOT IN ('OM','PO') THEN
       IF l_debug_on THEN
          wsh_debug_sv.log (l_module_name,'bad caller',p_action_prms.Caller);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_otm_installed := WSH_UTIL_CORE.Get_Otm_Install_Profile_Value;
    IF l_otm_installed IN ( 'Y','P')
     AND NVL(p_action_prms.caller,'PO') <> 'OM'
    THEN --{
       RAISE e_success;
    END IF;


    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--  Added the condition on caller for Inbound logistics.
-- added for testing purpose
/*
    if p_action_prms.action_code = 'REOPEN_PO'
    then
       p_action_prms.action_code := 'APPROVE_PO';
    end if;
*/

    -- IF True -> Calls API WSH_bulk_process_pvt.create_delivery_details to create
    --            new delivery lines.
    IF p_action_prms.action_code = 'CREATE' OR
       (p_action_prms.caller like '%PO%' AND
        wsh_util_core.fte_is_installed = 'Y' AND
        p_action_prms.action_code in ('APPROVE_PO','FINAL_CLOSE','CANCEL_PO',
                                 'CLOSE_PO','CLOSE_PO_FOR_RECEIVING',
				'PURGE_PO','REOPEN_PO')) THEN
          l_action_prms := p_action_prms;

       WSH_bulk_process_pvt.create_delivery_details(
                    p_action_prms    => l_action_prms,
                    p_line_rec       => p_line_rec,
                    x_return_status  => l_return_status
       );

    --Calls API WSH_IB_TXN_MATCH_PKG.matchTransaction to match the Records
    --based on Action code.
    elsif
       (p_action_prms.caller like '%PO%' AND
        wsh_util_core.fte_is_installed = 'Y' AND
        p_action_prms.action_code in
	    (
                'ASN',
                'CANCEL_ASN',
                'RECEIPT',
                'MATCH',
                'RECEIPT_CORRECTION',
                'RTV',
                'RTV_CORRECTION',
                'RECEIPT_ADD',
                'RECEIPT_HEADER_UPD'
	    )
	)
         THEN

       --l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       --l_action_prms := p_action_prms;
       WSH_IB_TXN_MATCH_PKG.matchTransaction
	 (
                    p_action_prms    => p_action_prms,
                    p_line_rec       => p_line_rec,
                    x_return_status  => l_return_status
         );


    END IF;

    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'return status from create_delivery_details',l_return_status);
    END IF;

    wsh_util_core.api_post_call(
         p_return_status    => l_return_status,
         x_num_warnings     => l_num_warnings,
         x_num_errors       => l_num_errors);
    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'after api_post_call');
    END IF;

    IF (l_num_errors > 0 ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;


    IF FND_API.To_Boolean( p_commit ) THEN

      --bug 4070732
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{

          l_reset_flags := FALSE;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                      x_return_status => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            RAISE WSH_UTIL_CORE.G_EXC_WARNING;
          END IF;

      --}
      END IF;
      --bug 4070732

      COMMIT WORK;
    END IF;
    --
    --bug 4070732
    IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
    --{
        IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
        --{

           IF FND_API.To_Boolean( p_commit ) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);

           ELSE

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);
           END IF;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
            END IF;

            IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                   WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
              x_return_status := l_return_status;
            END IF;

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
              IF NOT FND_API.To_Boolean( p_commit ) THEN
                ROLLBACK TO S_CREATE_UPDATE_DETAILS_BULK;
              END IF;
            END IF;

        --}
        END IF;
    --}
    END IF;

    --bug 4070732
    --
    IF l_debug_on THEN
      wsh_debug_sv.log (l_module_name,'getting the messages');
    END IF;
    FND_MSG_PUB.Count_And_Get
      (
       p_count  => x_msg_count,
       p_data  =>  x_msg_data,
       p_encoded => FND_API.G_FALSE
      );
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION
    WHEN e_success THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      --

     /*
           if any messages are set before this exception is
           called then this should be uncommented.
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
       */
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'e_success');
      END IF;

    WHEN FND_API.G_EXC_ERROR THEN
      --ROLLBACK TO S_CREATE_UPDATE_DETAILS; bms
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has '
          || 'occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO S_CREATE_UPDATE_DETAILS_BULK;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. ' ||
        'Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN WSH_UTIL_CORE.G_EXC_WARNING THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => TRUE,
                                                          x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                     WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                x_return_status := l_return_status;
              END IF;
              IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
                ROLLBACK TO S_CREATE_UPDATE_DETAILS_BULK;
              END IF;

          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UTIL_CORE.G_EXC_WARNING '||
           'exception has occured ',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UTIL_CORE.G_EXC_WARNING');
      END IF;
      --

    WHEN OTHERS THEN
      ROLLBACK TO S_CREATE_UPDATE_DETAILS_BULK;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      wsh_util_core.default_handler('WSH_BULK_PROCESS_GRP.CREATE_UPDATE_DELIVERY_DETAILS');
      --
      --
      -- Start code for Bugfix 4070732
      --
      IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
      --{
          IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                        x_return_status => l_return_status);


              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
              END IF;

              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
          --}
          END IF;
      --}
      END IF;
      --
      -- End of Code Bugfix 4070732
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '||
           'Oracle error message is '||
           SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;

  END Create_update_delivery_details;



END WSH_bulk_process_grp;

/
