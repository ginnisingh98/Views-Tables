--------------------------------------------------------
--  DDL for Package Body WSH_MBOLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_MBOLS_PVT" AS
-- $Header: WSHMBTHB.pls 120.8.12000000.2 2007/01/24 18:10:02 bsadri ship $
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_MBOLS_PVT';
--
--========================================================================
-- PROCEDURE : Generate_MBOL
--
-- PARAMETERS: p_trip_id              trip id
--             x_sequence_number      MBOL number
--             x_return_status        return status
--
--========================================================================
PROCEDURE Generate_MBOL(
  p_trip_id          IN         NUMBER,
  x_sequence_number  OUT NOCOPY VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2
) IS

  CURSOR c_get_trip_info(l_trip_id NUMBER) IS
  SELECT
  wt.name,
  wc.freight_code
  FROM
  wsh_trips wt,
  wsh_carrier_services wcs,
  wsh_carriers wc
  WHERE
  wt.ship_method_code = wcs.ship_method_code(+) AND
  wcs.carrier_id = wc.carrier_id(+) AND
  trip_id = l_trip_id;

  CURSOR c_get_seq_num (l_trip_id NUMBER) IS
  SELECT sequence_number
  FROM   wsh_document_instances
  WHERE  entity_name = 'WSH_TRIPS'
  AND    entity_id   = l_trip_id
  AND    status     <> 'CANCELLED';

  l_trip_name        WSH_TRIPS.NAME%TYPE;
  l_freight_code     WSH_CARRIERS.FREIGHT_CODE%TYPE;
  l_document_number  WSH_DOCUMENT_INSTANCES.SEQUENCE_NUMBER%TYPE;
  l_ledger_id        NUMBER;  -- LE Uptake
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_return_status    VARCHAR2(1);
  -- COMMENTED
  l_func_currency    VARCHAR2(15); --GL_LEDGERS_PUBLIC_V.currency_code%type;  -- LE Uptake

  l_org_id           NUMBER;
  l_organization_id  NUMBER;

  wsh_create_document_error EXCEPTION;

  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GENERATE_MBOL';
  --

BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
    --
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --

  OPEN c_get_seq_num(p_trip_id);
  FETCH c_get_seq_num INTO x_sequence_number;
  CLOSE c_get_seq_num;

  IF x_sequence_number IS NOT NULL THEN
     RETURN;
  END IF;

  --Get Trip Info.
  OPEN c_get_trip_info(p_trip_id);
  FETCH c_get_trip_info INTO l_trip_name, l_freight_code;
  CLOSE c_get_trip_info;

  SAVEPOINT Print_Mbol_Pvt;

  IF l_freight_code IS NULL THEN
    --
    IF l_debug_on THEN
      --
      WSH_DEBUG_SV.logmsg(l_module_name, 'Trip does not have a valid Freight Code, so MBOL cannot be Created.');
      --
    END IF;

    FND_MESSAGE.SET_NAME('WSH','WSH_MBOL_NULL_FREIGHT_CODE');
    FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
    x_return_status := wsh_util_core.g_ret_sts_error;
    wsh_util_core.add_message(x_return_status);
    RAISE wsh_create_document_error;
  END IF;

  WSH_FTE_INTEGRATION.GET_ORG_ORGANIZATION_INFO(
         p_init_msg_list => FND_API.G_FALSE,
         x_return_status => l_return_status,
         x_msg_count     => l_msg_count,
         x_msg_data      => l_msg_data,
         x_organization_id => l_organization_id,
         x_org_id          => l_org_id,
         p_entity_id       => p_trip_id,
         p_entity_type     => WSH_FTE_INTEGRATION.C_ORG_INFO_TRIP,
         p_org_id_flag     => FND_API.G_TRUE);
  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
     l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'ORG_ID not found, so MBOL cannot be Created.');
     END IF;
     RAISE wsh_create_document_error;
  END IF;

  IF l_org_id IS NULL THEN
    -- ECO:bug 4500358
    -- if operating unit/organization cannot be associated with the trip,
    -- let the user know what to do in order to generate MBOL.
    FND_MESSAGE.SET_NAME('WSH', 'WSH_TRIP_NO_ORG_FOR_MBOL');
    FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    wsh_util_core.add_message(x_return_status);
    RAISE wsh_create_document_error;
  END IF;


  -- LE Uptake
  --R12: MOAC passing ORG_ID
  --Get Ledger ID into l_ledger_id.
      WSH_UTIL_CORE.Get_Ledger_id_Func_Currency(
         p_org_id        => l_org_id,
         x_ledger_id	 => l_ledger_id,
         x_func_currency => l_func_currency,
         x_return_status => l_return_status);

  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
     l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
     --
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'Ledger ID not found, so MBOL cannot be Created.');
     END IF;
     RAISE wsh_create_document_error;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_freight_code', l_freight_code);
    WSH_DEBUG_SV.log(l_module_name, 'l_trip_name', l_trip_name);
    WSH_DEBUG_SV.log(l_module_name, 'l_ledger_id', l_ledger_id);
  END IF;
  --
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_PVT.CREATE_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --

  WSH_Document_PVT.Create_Document
    ( p_api_version            => 1.0
    , p_init_msg_list          => 'F'
    , p_commit                 => NULL
    , p_validation_level       => NULL
    , x_return_status          => l_return_status
    , x_msg_count              => l_msg_count
    , x_msg_data               => l_msg_data
    , p_entity_name            => 'WSH_TRIPS'
    , p_entity_id              => p_trip_id
    , p_application_id         => 665
    , p_location_id            => NULL
    , p_document_type          => 'MBOL'
    , p_document_sub_type      => l_freight_code
    , p_ledger_id              => l_ledger_id
    , p_consolidate_option     => 'BOTH'
    , p_manual_sequence_number => 200
    , x_document_number        => l_document_number);

   x_sequence_number := l_document_number;

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     RAISE wsh_create_document_error;
   END IF;

   Generate_Bols( p_trip_id       => p_trip_id,
                  x_return_status => l_return_status );

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     RAISE wsh_create_document_error;
   END IF;
   --
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
EXCEPTION
  WHEN wsh_create_document_error THEN
    ROLLBACK TO Print_Mbol_Pvt;
    x_return_status := wsh_util_core.g_ret_sts_error;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DOCUMENT_ERROR');
    END IF;
     --
  WHEN OTHERS THEN
    wsh_util_core.default_handler('WSH_MBOLS_PVT.Generate_MBOL',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name,'When Others');
    END IF;

END Generate_MBOL;

--========================================================================
-- PROCEDURE : Generate_BOLs
--
-- PARAMETERS: p_trip_id              trip id
--             x_return_status        return status
--
--========================================================================
PROCEDURE Generate_BOLs(
  p_trip_id          IN          NUMBER,
  x_return_status    OUT  NOCOPY VARCHAR2
) IS

  CURSOR  c_get_delivery_info(l_trip_id IN NUMBER) IS
  SELECT  del.delivery_id,
          dlg.delivery_leg_id,
          wt.ship_method_code,
          del.initial_pickup_location_id,
          wt.name
  FROM    wsh_new_deliveries del,
          wsh_delivery_legs dlg,
          wsh_trip_stops st,
          wsh_trips wt
  WHERE   del.delivery_id = dlg.delivery_id
  AND     dlg.pick_up_stop_id = st.stop_id
  AND     dlg.parent_delivery_leg_id IS NULL
  AND     st.trip_id = wt.trip_id
  AND     del.initial_pickup_location_id = st.stop_location_id
  AND     wt.trip_id = l_trip_id;

  CURSOR  c_get_ledger_id(p_delivery_id IN NUMBER) IS
  SELECT  ood.set_of_books_id
  FROM    org_organization_definitions ood,
          wsh_new_deliveries del
  WHERE   ood.organization_id = del.organization_id
  AND     del.delivery_id = p_delivery_id;

  l_delivery_id         NUMBER;
  l_delivery_leg_id     NUMBER;
  l_ship_method_code    VARCHAR2(30);
  l_pickup_location_id  NUMBER;
  l_document_number     VARCHAR2(50);
  l_trip_name           VARCHAR2(50);
  l_ledger_id           NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_return_status       VARCHAR2(1);
  l_bol_count           NUMBER;

  wsh_create_document_error EXCEPTION;

  --
  l_debug_on            BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GENERATE_BOLS';
  --
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
    --
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --

  OPEN c_get_delivery_info(p_trip_id);
  LOOP
    FETCH c_get_delivery_info INTO l_delivery_id,
                                   l_delivery_leg_id,
                                   l_ship_method_code,
                                   l_pickup_location_id,
                                   l_trip_name;
    EXIT WHEN c_get_delivery_info%NOTFOUND;

    SELECT count(*)
    INTO   l_bol_count
    FROM   wsh_document_instances
    WHERE  entity_name = 'WSH_DELIVERY_LEGS'
    AND    entity_id   = l_delivery_leg_id
    AND    status     <> 'CANCELLED';

    IF l_bol_count = 0 THEN

      IF l_ship_method_code IS NULL THEN
        FND_MESSAGE.SET_NAME('WSH','WSH_BOL_NULL_SHIP_METHOD_ERROR');
        FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
        x_return_status := wsh_util_core.g_ret_sts_error;
        wsh_util_core.add_message(x_return_status);
        CLOSE c_get_delivery_info;
        RAISE wsh_create_document_error;
      END IF;

      OPEN c_get_ledger_id(l_delivery_id);
      FETCH c_get_ledger_id INTO l_ledger_id;
      IF c_get_ledger_id%NOTFOUND THEN
         FND_MESSAGE.SET_NAME('WSH','WSH_LEDGER_ID_NOT_FOUND');
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         wsh_util_core.add_message(x_return_status);
         CLOSE c_get_delivery_info;
         RAISE wsh_create_document_error;
      END IF;
      IF c_get_ledger_id%ISOPEN THEN
        CLOSE c_get_ledger_id;
      END IF;

      WSH_Document_PVT.Create_Document
        ( p_api_version            => 1.0
        , p_init_msg_list          => 'F'
        , p_commit                 => NULL
        , p_validation_level       => NULL
        , x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , x_msg_data               => l_msg_data
        , p_entity_name            => 'WSH_DELIVERY_LEGS'
        , p_entity_id              => l_delivery_leg_id
        , p_application_id         => 665
        , p_location_id            => l_pickup_location_id
        , p_document_type          => 'BOL'
        , p_document_sub_type      => l_ship_method_code
        , p_ledger_id              => l_ledger_id
        , p_consolidate_option     => 'BOTH'
        , p_manual_sequence_number => 200
        , x_document_number        => l_document_number);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         CLOSE c_get_delivery_info;
        RAISE wsh_create_document_error;
      END IF;
      --
    END IF;
  END LOOP;
  IF c_get_delivery_info%ISOPEN THEN
    CLOSE c_get_delivery_info;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN wsh_create_document_error THEN
    x_return_status := wsh_util_core.g_ret_sts_error;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DOCUMENT_ERROR');
    END IF;
   --
  WHEN OTHERS THEN
    wsh_util_core.default_handler('WSH_MBOLS_PVT.Generate_BOLs',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name,'When Others');
    END IF;

END Generate_BOLs;

--========================================================================
-- PROCEDURE : Print_MBOL
--
-- PARAMETERS: p_trip_id              trip id
--             p_generate_bols        generate related BOLs if 'Y'
--             x_return_status        return status
--
--========================================================================
PROCEDURE Print_MBOL(
  p_trip_id          IN          NUMBER,
  p_generate_bols    IN          VARCHAR2,
  x_return_status    OUT  NOCOPY VARCHAR2
)IS

  l_conc_program_id     NUMBER;
  l_cp_printer_name     VARCHAR2(30);
  l_print_style         VARCHAR2(60);
  l_save_output_flag    VARCHAR2(30);
  l_print_flag          VARCHAR2(1);
  l_return_status       VARCHAR2(1);
  l_application_id      NUMBER;
  l_printer_name        VARCHAR2(32000);
  l_error_message       VARCHAR2(32000);
  l_copies              NUMBER := 0;
  l_save_output         BOOLEAN;
  l_printer_setup       BOOLEAN;
  l_request_id          NUMBER;
  x_organization_id     NUMBER;
  l_org_id           NUMBER;
  l_report_name         VARCHAR2(10);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

  CURSOR c_conc_prog_csr(p_conc_prog_name VARCHAR2) IS
  SELECT concurrent_program_id,
         output_print_style,
         save_output_flag,
         print_flag,
         printer_name
  FROM   fnd_concurrent_programs_vl
  WHERE  application_id = 665
  AND    concurrent_program_name = p_conc_prog_name;

  err_mbol_submission EXCEPTION;

  --
  l_debug_on            BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_MBOL';
  --
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
    --
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --



  OPEN c_conc_prog_csr('WSHRDMBL');
  FETCH c_conc_prog_csr INTO l_conc_program_id,
                             l_print_style,
                             l_save_output_flag,
                             l_print_flag,
                             l_cp_printer_name;
  CLOSE c_conc_prog_csr;





  IF l_print_flag = 'Y' THEN

     WSH_REPORT_PRINTERS_PVT.Get_Printer(
         p_concurrent_program_id => l_conc_program_id,
         p_organization_id       => null,
         p_equipment_type_id     => null,
         p_equipment_instance    => null,
         p_user_id               => fnd_global.user_id,
         p_zone                  => null,
         p_department_id         => null,
         p_responsibility_id     => fnd_global.resp_id,
         p_application_id        => 665,
         p_site_id               => 0,
         x_printer               => l_printer_name,
         x_api_status            => l_return_status,
         x_error_message         => l_error_message);

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'x_printer', l_printer_name);
        wsh_debug_sv.log(l_module_name, 'x_api_status', l_return_status);
        IF l_error_message IS NOT NULL THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'GET_PRINTER: ' || l_error_message);
        END IF;
     END IF;

     -- Set Print Options
     l_copies := to_number(NVL(FND_PROFILE.VALUE('CONC_COPIES'),'1')) ;

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_copies', l_copies);
        wsh_debug_sv.log(l_module_name, 'l_print_style', l_print_style);
        wsh_debug_sv.log(l_module_name, 'l_save_output_flag', l_save_output_flag);
     END IF;

     IF l_printer_name IS NULL OR l_printer_name = 'No Printer' THEN

        l_printer_name := l_cp_printer_name;

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'PRINTER NAME IS NULL AND THE DEFAULT PRINTER IS '||L_PRINTER_NAME  );
        END IF;
     END IF;

     IF l_save_output_flag = 'Y' THEN
        l_save_output := TRUE;
     ELSE
        l_save_output := FALSE;
     END IF;

     l_printer_setup := fnd_request.set_print_options
                          (l_printer_name,
                           l_print_style,
                           l_copies,
                           l_save_output,
                           'N');

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'Set_Print_Options', l_printer_setup);
     END IF;
  END IF; -- if print_flag = Y

  -- Call Submit Request
  l_request_id := FND_REQUEST.SUBMIT_REQUEST
                       ( 'WSH'
                       , 'WSHRDMBL'
                       , ''
                       , ''
                       , FALSE
                       , p_trip_id
                       , nvl(p_generate_bols, 'N')
                       , ''
                       , ''
                       , ''
                       , ''
                       , ''
                       , ''
                       , ''
                       , ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', '');

  IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_request_id', l_request_id);
  END IF;

  IF (l_request_id = 0) THEN
    raise err_mbol_submission;
  ELSE
    FND_MESSAGE.SET_NAME('WSH', 'WSH_MBOL_SUBMITTED');
    FND_MESSAGE.SET_TOKEN('REQ_ID', to_char(l_request_id));
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
  END if;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

EXCEPTION
  WHEN err_mbol_submission THEN
    x_return_status := wsh_util_core.g_ret_sts_error;
    fnd_message.set_name('WSH', 'WSH_MBOL_FAILED');
    WSH_UTIL_CORE.ADD_MESSAGE(x_return_status,l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'err_mbol_submission exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:err_mbol_submission');
    END IF;
    --
  WHEN OTHERS THEN
    wsh_util_core.default_handler('WSH_MBOLS_PVT.Print_MBOL',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Print_MBOL;

--========================================================================
-- PROCEDURE : Print_BOLs
--
-- PARAMETERS: p_trip_id              trip id
--             p_conc_request_id      Concurrent Request Id (Added for XDO Integration)
--             x_return_status        return status
--
--========================================================================
PROCEDURE Print_BOLs(
  p_trip_id          IN          NUMBER,
  p_conc_request_id  IN		 NUMBER,
  x_return_status    OUT  NOCOPY VARCHAR2
)IS

  l_conc_program_id     NUMBER;
  l_cp_printer_name     VARCHAR2(30);
  l_print_style         VARCHAR2(60);
  l_save_output_flag    VARCHAR2(30);
  l_print_flag          VARCHAR2(1);
  l_return_status       VARCHAR2(1);
  l_application_id      NUMBER;
  l_printer_name        VARCHAR2(32000);
  l_error_message       VARCHAR2(32000);
  l_copies              NUMBER := 0;
  l_save_output         BOOLEAN;
  l_printer_setup       BOOLEAN;
  l_request_id          NUMBER;
  l_output_file_type    VARCHAR2(10);
  l_report_name		VARCHAR2(10);
  x_organization_id	NUMBER;
  l_org_id              NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  CURSOR c_conc_prog_csr(p_conc_prog_name NUMBER) IS
  SELECT concurrent_program_id,
         output_print_style,
         save_output_flag,
         print_flag,
         printer_name
  FROM   fnd_concurrent_programs_vl
  WHERE  application_id = 665
  AND    concurrent_program_name = p_conc_prog_name;




  err_bol_submission EXCEPTION;

  --
  l_debug_on            BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_BOLs';
  --
BEGIN
  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
    wsh_debug_sv.log(l_module_name, 'p_conc_request_id', p_conc_request_id );
    --
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --


  OPEN c_conc_prog_csr('WSHRDBOL');
  FETCH c_conc_prog_csr INTO l_conc_program_id,
                             l_print_style,
                             l_save_output_flag,
                             l_print_flag,
                             l_cp_printer_name;

  CLOSE c_conc_prog_csr;


  IF l_print_flag = 'Y' THEN

     WSH_REPORT_PRINTERS_PVT.Get_Printer(
         p_concurrent_program_id => l_conc_program_id,
         p_organization_id       => null,
         p_equipment_type_id     => null,
         p_equipment_instance    => null,
         p_user_id               => fnd_global.user_id,
         p_zone                  => null,
         p_department_id         => null,
         p_responsibility_id     => fnd_global.resp_id,
         p_application_id        => 665,
         p_site_id               => 0,
         x_printer               => l_printer_name,
         x_api_status            => l_return_status,
         x_error_message         => l_error_message);

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'x_printer', l_printer_name);
        wsh_debug_sv.log(l_module_name, 'x_api_status', l_return_status);
        IF l_error_message IS NOT NULL THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'GET_PRINTER: ' || l_error_message);
        END IF;
     END IF;

     -- Set Print Options
     l_copies := to_number(NVL(FND_PROFILE.VALUE('CONC_COPIES'),'1')) ;

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'l_copies', l_copies);
        wsh_debug_sv.log(l_module_name, 'l_print_style', l_print_style);
        wsh_debug_sv.log(l_module_name, 'l_save_output_flag', l_save_output_flag);
     END IF;

     IF l_printer_name IS NULL OR l_printer_name = 'No Printer' THEN

        l_printer_name := l_cp_printer_name;

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'PRINTER NAME IS NULL AND THE DEFAULT PRINTER IS '||L_PRINTER_NAME  );
        END IF;
     END IF;

     IF l_save_output_flag = 'Y' THEN
        l_save_output := TRUE;
     ELSE
        l_save_output := FALSE;
     END IF;

     l_printer_setup := fnd_request.set_print_options
                          (l_printer_name,
                           l_print_style,
                           l_copies,
                           l_save_output,
                           'N');

     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name, 'Set_Print_Options', l_printer_setup);
     END IF;
  END IF; -- if print_flag = Y

  -- Call Submit Request
  l_request_id := FND_REQUEST.SUBMIT_REQUEST
                       ( 'WSH'
                       , 'WSHRDBOL'
                       , ''
                       , ''
                       , FALSE
                       , ''
                       , ''
                       , ''
                       , ''
                       , ''
                       , p_trip_id
                       , ''
                       , ''
                       , ''
                       , ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', '');

  IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name, 'l_request_id', l_request_id);
  END IF;

  IF (l_request_id = 0) THEN
     raise err_bol_submission;
  ELSE
     WSH_UTIL_CORE.PrintMsg('Bill of Lading concurrent request submitted for request ID:' || to_char(l_request_id) );
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN err_bol_submission THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    WSH_UTIL_CORE.PrintMsg('ERROR: Failed to submit Bill of Lading concurrent request');
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'err_bol_submission exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:err_bol_submission');
    END IF;
    --
  WHEN OTHERS THEN
    wsh_util_core.default_handler('WSH_MBOLS_PVT.Print_MBOL',l_module_name);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Print_BOLs;

--========================================================================
-- PROCEDURE : Cancel_MBOL
--
-- PARAMETERS: p_trip_id         trip id
--            x_return_status return status
--
--========================================================================

PROCEDURE cancel_mbol
  ( p_trip_id			  IN NUMBER
    , x_return_status		  OUT NOCOPY  VARCHAR2
  )
IS
--
cursor  mbol_num_cur (p_trip_id number) is
select document_instance_id
   from    wsh_document_instances
   where   entity_id = p_trip_id
     AND document_type = 'MBOL'
     AND status in ('OPEN', 'PLANNED');


TYPE Tab_mbol_num_Type IS TABLE OF mbol_num_cur%ROWTYPE INDEX BY BINARY_INTEGER;
l_mbol_num_tab Tab_mbol_num_Type;

--
--
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_okay          BOOLEAN;
--
--
wsh_cancel_mbol_error EXCEPTION;
record_locked        EXCEPTION;
PRAGMA EXCEPTION_INIT(record_locked, -54);
l_tmp NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_MBOL';
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
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  SAVEPOINT cancel_mbol1;

      OPEN mbol_num_cur(p_trip_id);
      LOOP
         FETCH mbol_num_cur INTO l_mbol_num_tab(l_mbol_num_tab.COUNT + 1);
         EXIT WHEN mbol_num_cur%NOTFOUND;
      END LOOP;
      close mbol_num_cur;

    IF l_mbol_num_tab.COUNT <> 0 THEN

	   --- Locking the document instance

	    FOR i IN l_mbol_num_tab.FIRST..l_mbol_num_tab.LAST
		LOOP
		   select  1 into l_tmp
		   from    wsh_document_instances
		   where   document_instance_id = l_mbol_num_tab(i).document_instance_id
		   FOR UPDATE NOWAIT;
	    END LOOP;

	 --- Cancelling the document here
        FOR i IN l_mbol_num_tab.FIRST..l_mbol_num_tab.LAST
        LOOP

	   --
	   wsh_document_pvt.cancel_document
		   (p_api_version               => 1.0,
		    p_init_msg_list             => fnd_api.g_false,
		    p_commit                    => fnd_api.g_false,
		    p_validation_level          => 100,
		    x_return_status             => l_return_status,
		    x_msg_count                 => l_msg_count,
		    x_msg_data                  => l_msg_data,
		    p_entity_name		=> NULL,
		    p_entity_id                 => p_trip_id,
		    p_document_type             => 'MBOL'
		    );

	  IF (l_return_status not in (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
	      raise wsh_cancel_mbol_error;
	  END IF;
          END LOOP;
    END IF;

  IF l_return_status is not null then
    x_return_status := l_return_status;
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
    END IF;
  ELSE
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
--
EXCEPTION
   WHEN wsh_cancel_mbol_error THEN
        ROLLBACK TO cancel_mbol1;
        x_return_status := wsh_util_core.g_ret_sts_error;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CANCEL_MBOL_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CANCEL_MBOL_ERROR');
        END IF;
        --
   WHEN record_locked THEN
        x_return_status := wsh_util_core.g_ret_sts_error;
        FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
        WSH_UTIL_CORE.add_message (x_return_status, l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
        END IF;
        --
   WHEN OTHERS THEN
        ROLLBACK TO cancel_mbol1;
        wsh_util_core.default_handler('WSH_MBOLS_PVT.cancel_mbol',l_module_name);
	x_return_status := wsh_util_core.g_ret_sts_unexp_error;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
	--
END cancel_mbol;

--========================================================================
-- PROCEDURE : Get_Organization_of_MBOL
--
-- PARAMETERS: p_trip_id              trip id
--             x_return_status        return status
--
--========================================================================
PROCEDURE Get_Organization_of_MBOL(
  p_trip_id          IN         NUMBER,
  x_organization_id  OUT NOCOPY NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2
) IS

l_shipments_type_flag	VARCHAR2(1);
l_location_id		NUMBER;
l_organization_id	NUMBER;
l_first_delivery_id     NUMBER;
cursor get_shipments_type_flag is
        select shipments_type_flag
	from wsh_trips
	where trip_id = p_trip_id;

cursor locations_csr is
	select stop_location_id into l_location_id
	from
	wsh_trip_stops
	where trip_id = p_trip_id
	order by stop_sequence_number desc;

cursor organizations_csr(p_location_id NUMBER) is
	select organization_id
	from hr_all_organization_units
	where location_id = p_location_id;

l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Organization_of_MBOL';
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
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        open get_shipments_type_flag;
	fetch get_shipments_type_flag into l_shipments_type_flag;
	close get_shipments_type_flag;
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_shipments_type_flag',l_shipments_type_flag);
        END IF;
	open locations_csr;
	LOOP
		fetch locations_csr into l_location_id;
                IF l_debug_on THEN
	           WSH_DEBUG_SV.log(l_module_name,'l_location_id', l_location_id);
                END IF;
		if ( l_shipments_type_flag = 'I') then
			exit;
		end if;
		EXIT WHEN locations_csr%NOTFOUND;
	END LOOP;
	open organizations_csr(l_location_id);
	fetch organizations_csr into l_organization_id;
	close organizations_csr;

        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_organization_id', l_organization_id);
        END IF;

	If l_organization_id is null then
	--{
		select min(delivery_id)
		into l_first_delivery_id
		from wsh_trip_stops wts, wsh_delivery_legs wdl
		where wts.trip_id = p_trip_id
		and wts.stop_id = wdl.pick_up_stop_id;
                IF l_debug_on THEN
	           WSH_DEBUG_SV.log(l_module_name,'l_first_delivery_id', l_first_delivery_id);
                END IF;

		select organization_id
		into l_organization_id
		from wsh_new_deliveries
		where delivery_id = l_first_delivery_id;
                IF l_debug_on THEN
	           WSH_DEBUG_SV.log(l_module_name,'l_organization_id', l_organization_id);
                END IF;
	--}
	end if;
	x_organization_id := l_organization_id;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN

        wsh_util_core.default_handler('WSH_MBOLS_PVT.Get_Organization_of_MBOL',l_module_name);
	x_return_status := wsh_util_core.g_ret_sts_unexp_error;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;

END Get_Organization_of_MBOL;


END wsh_mbols_pvt;

/
