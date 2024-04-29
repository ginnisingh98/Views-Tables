--------------------------------------------------------
--  DDL for Package Body WSH_DSNO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DSNO" as
/* $Header: WSHDSNOB.pls 120.3.12010000.2 2009/04/21 07:24:08 ueshanka ship $ */


  G_RLM_INSTALL_STATUS VARCHAR2(30);
  G_EDI_INSTALL_STATUS VARCHAR2(30);

  -- bug 1677940: add new parameter x_return_status

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DSNO';
  --
  PROCEDURE ec_document_send (
  p_trip_stop_id  IN  NUMBER,
        x_return_status OUT NOCOPY      VARCHAR2) IS

    CURSOR doc_num IS
    SELECT ece_output_runs_s.nextval
    FROM   dual;

    l_doc_num   NUMBER;
    l_call_status   BOOLEAN;
    l_request_id  BINARY_INTEGER;
    l_msg_count   NUMBER;
    l_msg_data    VARCHAR2(2000);
    l_return_status VARCHAR2(1);
    l_tmp_out   NUMBER;
    l_debug_level NUMBER := 1;
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EC_DOCUMENT_SEND';
    --

    -- Following varibales added as part of Bug# 4255379
    l_output_filename VARCHAR2(100);
    l_output_file_ext VARCHAR2(20);
    -- Added for bug 8424489
    l_output_fileprefix VARCHAR2(30);

  BEGIN

    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRIP_STOP_ID',P_TRIP_STOP_ID);
    END IF;
    --
    OPEN  doc_num;
    FETCH doc_num INTO l_doc_num;
    CLOSE doc_num;

    --Following lines of code added as part of Bug 4255379
    l_output_file_ext := FND_PROFILE.Value('WSH_DSNO_OUTPUT_FILE_EXT');
    -- Bug 8424489 - Start
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_CUSTOM_PUB.Dsno_Output_File_Prefix',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    l_output_fileprefix := WSH_CUSTOM_PUB.Dsno_Output_File_Prefix(
                               p_trip_stop_id  => p_trip_stop_id,
                               p_doc_number    => l_doc_num,
                               p_dsno_file_ext => l_output_file_ext );
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'File prefix returned from custom hook', l_output_fileprefix);
    END IF;
    --
    l_output_fileprefix := nvl(l_output_fileprefix, 'DSNO');
    -- Bug 8424489 - End

    If l_output_file_ext IS NULL THEN
       l_output_filename := l_output_fileprefix || to_char(l_doc_num);
    Else
       l_output_filename := l_output_fileprefix || to_char(l_doc_num) || '.' ||l_output_file_ext;
    End If;
    --Changes for Bug# 4255379 End.

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit EC_DOCUMENT.SEND',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    ec_document.send(
  p_api_version_number => 1.0,
  i_Output_Path      => null,
  i_Output_Filename  => l_output_filename,
  i_Transaction_Type => 'DSNO',
  call_status        => l_call_status,
  request_id         => l_request_id,
  x_msg_count        => l_msg_count,
  x_msg_data         => l_msg_data,
  x_return_status    => l_return_status,
  p_parameter1       => p_trip_stop_id,
  p_parameter2       => null,
  p_parameter3       => null,
  p_parameter4       => null,
  p_parameter5       => null,
  p_parameter6       => null,
  p_parameter7       => null,
  p_parameter8       => null,
  p_parameter9       => null,
  p_parameter10      => null,
  p_parameter11      => null,
  p_parameter12      => null,
  p_parameter13      => null,
  p_parameter14      => null,
  p_parameter15      => null,
  p_parameter16      => null,
  p_parameter17      => null,
  p_parameter18      => null,
  p_parameter19      => null,
  p_parameter20      => null,
  I_DEBUG_MODE      => null);

    -- bug 1677940: let caller know the status
    x_return_status := l_return_status;

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) OR NOT(l_call_status) THEN
      -- Print Error Messages
      FOR i IN 1..l_msg_count LOOP
        fnd_msg_pub.get(
    p_msg_index => i,
    p_encoded   => FND_API.G_FALSE,
    p_data      => l_msg_data,
    p_msg_index_out => l_tmp_out);

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_DATA  );
  END IF;
  --

      END LOOP;

    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END ec_document_send;

  --
  -- PROCEDURE:         Submit
  -- Purpose:           Submit DSNO for a Trip Stop
  -- Arguments:         p_trip_stop_id - Trip Stop Identifier
  -- Description:       Submits DSNO for a trip stop
  --
---  Bug  2425936  : added a parameter p_trip_id which is
---                  is included in concurrent program for performace
  PROCEDURE Submit (
  errbuf          OUT NOCOPY      VARCHAR2,
  retcode         OUT NOCOPY      VARCHAR2,
  p_trip_id IN  NUMBER DEFAULT NULL,
  p_trip_stop_id  IN  NUMBER) IS
    l_completion_status VARCHAR2(30);
    l_temp              BOOLEAN;
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SUBMIT';
    --
  BEGIN
    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRIP_STOP_ID',P_TRIP_STOP_ID);
    END IF;
    --
    Submit_Trip_Stop(p_trip_stop_id, l_completion_status);
    wsh_util_core.enable_concurrent_log_print;
    l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status, '');
    IF l_completion_status = 'NORMAL' THEN
       errbuf := 'DSNO submission is completed successfully';
       retcode := '0';
    ELSIF l_completion_status = 'WARNING' THEN
       errbuf := 'DSNO submission is completed with warning';
       retcode := '1';
    ELSE
      errbuf := 'DSNO submission is completed with error';
      retcode := '2';
   END IF;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
  END Submit;

-- start bug 1578251: new procedure submit_trip_stop with x_completion_status
  --
  -- PROCEDURE:         Submit_Trip_stop
  -- Purpose:           Submit DSNO for a Trip Stop
  -- Arguments:         p_trip_stop_id - Trip Stop Identifier
  --                    x_completion_status - result of this submission
  -- Description:       Submits DSNO for a trip stop
  --

PROCEDURE Submit_Trip_Stop (
  p_trip_stop_id      IN  NUMBER,
        x_completion_status OUT NOCOPY  VARCHAR2) IS

  l_industry    VARCHAR2(30);
  l_rlm_install_status  VARCHAR2(30);
  l_edi_install_status  VARCHAR2(30);
  l_delivery_count  NUMBER := 0;
  l_return_status BOOLEAN;
  l_msg_count   NUMBER := 0;
  l_msg_data    VARCHAR2(2000);
  l_tmp_out   NUMBER;
  i     NUMBER;
  l_submit_ret_sts      VARCHAR2(1);
  l_completion_status   VARCHAR2(30) := 'NORMAL';


  -- CSUN 16-AUG-2000, replace select (*) by this cursor for better performance
  l_trip_stop_id NUMBER;

cursor c_dsno_deliveries(c_trip_stop_id number ) is
  SELECT
  DECODE(HCAS.ORG_ID,WSH_UTIL_CORE.GET_OPERATINGUNIT_ID(wnd.delivery_id),1,NULL,1, NULL) record_exists
  FROM WSH_TRIP_STOPS        WTS,
    WSH_TRIPS                WTP,
    WSH_TRIP_STOPS           WTS2,
    WSH_DELIVERY_LEGS        WDL,
    WSH_NEW_DELIVERIES       WND,
    WSH_LOCATIONS            WSHL,
    WSH_LOCATIONS            WSHL2,
    HR_ORGANIZATION_UNITS    HOU,
    MTL_PARAMETERS           MTP,
    HZ_PARTY_SITES           HPS,
    HZ_CUST_ACCT_SITES_ALL   HCAS,
    HZ_CUST_SITE_USES_ALL    HCSU,
    ECE_TP_HEADERS           ETH,
    ECE_TP_DETAILS           ETD
  WHERE
     WND.INITIAL_PICKUP_LOCATION_ID = WSHL.WSH_LOCATION_ID AND
/*J Inbound Logistics Changes jckwok*/
     NVL(WND.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO') AND
     WSHL.LOCATION_SOURCE_CODE = 'HR' AND
     HOU.ORGANIZATION_ID = WND.ORGANIZATION_ID AND
     HOU.ORGANIZATION_ID = MTP.ORGANIZATION_ID AND
     WTP.TRIP_ID = WTS.TRIP_ID AND
     WTP.TRIP_ID = WTS2.TRIP_ID AND
     WTS.TRIP_ID = WTS2.TRIP_ID AND
     WND.ULTIMATE_DROPOFF_LOCATION_ID = WTS2.STOP_LOCATION_ID AND
     WND.ULTIMATE_DROPOFF_LOCATION_ID = WSHL2.WSH_LOCATION_ID AND
     WSHL2.LOCATION_SOURCE_CODE = 'HZ' AND
     WSHL2.SOURCE_LOCATION_ID = HPS.LOCATION_ID AND
     NVL(HCAS.ORG_ID, -999) = NVL(HCSU.ORG_ID, -999) AND
     WND.DELIVERY_ID = WDL.DELIVERY_ID AND
     WTS2.STOP_ID = WDL.DROP_OFF_STOP_ID AND
     WDL.PICK_UP_STOP_ID = WTS.STOP_ID AND
     HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID AND
     HCAS.PARTY_SITE_ID = HPS.PARTY_SITE_ID AND
     HCSU.SITE_USE_CODE = 'SHIP_TO' AND
     HCSU.STATUS = 'A' AND
     ETH.TP_HEADER_ID = HCAS.TP_HEADER_ID AND
     ETD.TP_HEADER_ID = ETH.TP_HEADER_ID AND
     ETD.EDI_FLAG = 'Y' AND
     ETD.DOCUMENT_ID = 'DSNO' AND
     WTS.STOP_ID = c_trip_stop_id
     ORDER BY RECORD_EXISTS;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SUBMIT_TRIP_STOP';
--
  BEGIN

    --
    -- Debug Statements
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_TRIP_STOP_ID',P_TRIP_STOP_ID);
    END IF;
    --
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'PROCESSING DSNO IN TRIP STOP ' || TO_CHAR ( P_TRIP_STOP_ID )  );
         END IF;
         --

    IF G_RLM_INSTALL_STATUS IS NULL THEN
      IF NOT (fnd_installation.get(662,662,G_RLM_INSTALL_STATUS,l_industry)) THEN
        G_RLM_INSTALL_STATUS := 'N'; -- invalid application == not installed
      ELSE
        IF G_RLM_INSTALL_STATUS IS NULL THEN
          G_RLM_INSTALL_STATUS := 'N';
        END IF;
      END IF;
    END IF;
    --
    l_rlm_install_status := G_RLM_INSTALL_STATUS;

    IF (l_rlm_install_status = 'I') THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'RLM INSTALLED: YES'  );
      END IF;
      --
      -- RLM is installed, calculate Cum Quantities
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit RLM_TPA_SV.UPDATECUMKEY',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      rlm_tpa_sv.updatecumkey(
                      p_trip_stop_id,
                      l_return_status);

      -- Dump message file information
      l_msg_count := fnd_msg_pub.count_msg;
      FOR i IN 1..l_msg_count LOOP
        fnd_msg_pub.get(
            p_msg_index => i,
            p_encoded   => FND_API.G_FALSE,
            p_data      => l_msg_data,
            p_msg_index_out => l_tmp_out);

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_DATA  );
        END IF;
        --

      END LOOP;

      -- Validate return status
      IF (NOT l_return_status) THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'ERROR OCCURRED IN RLM CUM QTY API'  );
        END IF;
        --
        x_completion_status := 'WARNING';
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        RETURN;
      END IF;
    END IF; /* l_rlm_install_status = 'I' */

    COMMIT;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'CHECKING EDI INSTALLATION STATUS'  );
    END IF;
    --

    IF G_EDI_INSTALL_STATUS IS NULL THEN
      IF NOT (fnd_installation.get(175,175,G_EDI_INSTALL_STATUS,l_industry)) THEN
        G_EDI_INSTALL_STATUS := 'N'; -- invalid application == not installed
      ELSE
        IF G_EDI_INSTALL_STATUS IS NULL THEN
          G_EDI_INSTALL_STATUS := 'N';
        END IF;
      END IF;
    END IF;
    --
    l_edi_install_status := G_EDI_INSTALL_STATUS;

    IF (l_edi_install_status = 'I' ) THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'EDI INSTALLED: YES'  );
      END IF;
      --
    ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'EDI INSTALLED: NO'  );
      END IF;
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'TERMINATING PROGRAM'  );
      END IF;
      --
      x_completion_status := 'NORMAL';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;

    IF (FND_PROFILE.VALUE('ECE_DSNO_ENABLED') = 'Y') THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'DSNO PROFILE: ENABLED'  );
      END IF;
      --
    ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'DSNO PROFILE: DISABLED'  );
      END IF;
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'TERMINATING PROGRAM'  );
      END IF;
      --
      x_completion_status := 'NORMAL';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    END IF;





   -- csun 13-JUN-2000, change for better performance
   open c_dsno_deliveries(p_trip_stop_id);
   fetch c_dsno_deliveries into l_trip_stop_id;
   IF c_dsno_deliveries%NOTFOUND THEN
      l_trip_stop_id := NULL;
   END IF;
   close c_dsno_deliveries;

   if nvl(l_trip_stop_id,0) = 0 then
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'NO ELIGIBLE DELIVERY FOR THE DSNO'  );
    END IF;
    --
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,  'TERMINATING PROGRAM'  );
    END IF;
    --
    x_completion_status := 'NORMAL';
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;

/*   SELECT COUNT(*)
     INTO l_delivery_count
     FROM WSH_DSNO_DELIVERIES_V
    WHERE PICK_UP_STOP_ID = p_trip_stop_id;

      IF(l_delivery_count = 0) THEN
    wsh_util_core.println('No Eligible Delivery for the DSNO');
    wsh_util_core.println('Terminating program');
    RETURN;
*/
   END IF;

      -- Submit EC DSNO
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'CALLING EC SEND'  );
      END IF;
      --
      ec_document_send(p_trip_stop_id, l_submit_ret_sts);

      -- bug 1677940: set completion status of DSNO submit
      IF l_submit_ret_sts = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        x_completion_status := 'NORMAL';
      ELSIF l_submit_ret_sts = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
        x_completion_status := 'ERROR';
      ELSE
        x_completion_status := 'WARNING';
      END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
    WHEN OTHERS THEN
      wsh_util_core.default_handler('WSH_DSNO.Submit');
      x_completion_status := 'ERROR';

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Submit_Trip_Stop;
-- end bug 1578251: new procedure submit_trip_stop with x_completion_status


END WSH_DSNO;

/
