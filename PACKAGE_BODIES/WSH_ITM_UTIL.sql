--------------------------------------------------------
--  DDL for Package Body WSH_ITM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_UTIL" AS
/* $Header: WSHUTITB.pls 120.0.12010000.3 2009/09/23 12:39:51 gbhargav ship $ */


  -- Name
  --   GET_SERVICE_DETAILS
  --   Purpose
  --   On passing the p_application_id, p_master_organization_id and
  --   p_organization_id this procedure returns the services defined for
  --   user and the additional country codes for all the services.
  -- Arguments
  --   p_application_id               p_application_id of a request
  --   p_master_organization_id       p_master_organization_id of a request
  --   p_organization_id              p_organization_id of a request
  --   x_service_tbl                  service types and addl_country_codes
  --                                  returned as a PLSQL table Service_Rec_Type
  --   x_supports_combination_flag    A flag indicating whether a combined
  --                                  request for all the services returned
  --                                  by x_service_types_rec is supported or
  --                                  not.
  --   x_return_status                Return Status
  -- Notes
  --   Refer the record T_SERVICE_TYPES_REC



PROCEDURE GET_SERVICE_DETAILS (
       p_application_id              IN  NUMBER,
       p_master_organization_id      IN  NUMBER,
       p_organization_id             IN  NUMBER,
       x_service_tbl                 OUT NOCOPY  Service_Tbl_Type,
       x_supports_combination_flag   OUT NOCOPY  VARCHAR2,
       x_return_status               OUT NOCOPY  VARCHAR2)
IS
    priority               NUMBER := 0;
    service_tbl            Service_Tbl_Type;
    G_MISS_SERVICE_TBL     Service_Tbl_Type;
    vendor_id              WSH_ITM_VENDORS.VENDOR_ID%TYPE := 0;
    comb_flag              WSH_ITM_VENDORS.SUPPORTS_COMBINATION_FLAG%TYPE := 'Y';
    l_addl_country_code    VARCHAR2(5);
    l_sql_error            VARCHAR2(2000);
    i                      NUMBER := 1;

    CURSOR Get_Services(
	p_application_id NUMBER,
	p_master_organization_id NUMBER) IS
    --Bug3330869        SELECT * from (
    SELECT      priority                        ,
                service_type                    ,
                addl_country_check_req          ,
                vendor_id                       ,
                supports_combination_flag
    FROM (
       SELECT 1 priority,
              s.service_type,
              s.addl_country_check_req,
              v.vendor_id,
              v.supports_combination_flag
       FROM   WSH_ITM_SERVICE_PREFERENCES us1,
	      WSH_ITM_VENDOR_SERVICES s,
	      WSH_ITM_VENDORS v
       WHERE  us1.application_id         = p_application_id   and
              us1.master_organization_id = p_master_organization_id  and
              us1.vendor_service_id      = s.vendor_service_id and
              us1.active_flag            = 'Y'and
              s.vendor_id                = v.vendor_id
       UNION
       SELECT 2 priority,
              s.service_type,
              s.addl_country_check_req,
              v.vendor_id,
              v.supports_combination_flag
       FROM   WSH_ITM_SERVICE_PREFERENCES us1,
	      WSH_ITM_VENDOR_SERVICES s,
	      WSH_ITM_VENDORS v
       WHERE  us1.application_id         = p_application_id   and
              us1.master_organization_id   is null  and
              us1.active_flag            = 'Y'and
              us1.vendor_service_id      = s.vendor_service_id and
              s.vendor_id                = v.vendor_id
	     ) order by priority;

  BEGIN
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    oe_debug_pub.add('***Inside the procedure WSH_ITM_UTIL.GET_SERVICE_DETAILS***');
    oe_debug_pub.add('Application Id ' || p_application_id);
    oe_debug_pub.add('Master Organization  Id ' || p_master_organization_id);
    oe_debug_pub.add('Organization Id ' || p_organization_id);

    service_tbl := G_MISS_SERVICE_TBL;

    BEGIN
        SELECT ITM_ADDITIONAL_COUNTRY_CODE
        INTO l_addl_country_code
        FROM WSH_SHIPPING_PARAMETERS
        WHERE organization_id = p_organization_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           l_addl_country_code := '';
    END;

    oe_debug_pub.add('Additional Country Code is ' || l_addl_country_code);

    FOR ser_details IN Get_Services(p_application_id, p_master_organization_id)
    LOOP

      IF ser_details.priority >= priority THEN
       priority := ser_details.priority;
      ELSE
       EXIT;
      END IF;

      service_tbl(i).service_type_code := ser_details.service_type;
      IF ser_details.addl_country_check_req = 'Y' then
        service_tbl(i).addl_country_code := l_addl_country_code;
      ELSE
        service_tbl(i).addl_country_code := '';
      END IF;

      oe_debug_pub.add('Service Type ' || service_tbl(i).service_type_code);
      oe_debug_pub.add('Additional Country Code ' || service_tbl(i).addl_country_code );

      i := i + 1;

      IF vendor_id = 0 then
        vendor_id := ser_details.vendor_id;
      END IF;

      IF vendor_id <> ser_details.vendor_id OR ser_details.supports_combination_flag = 'N' THEN
        comb_flag := 'N';
      END IF;

      vendor_id := ser_details.vendor_id;

    END LOOP;

    oe_debug_pub.add('Supports Combination Flag ' || comb_flag );
    x_supports_combination_flag := comb_flag;
    x_service_tbl               := service_tbl;
    oe_debug_pub.add('***End of  the procedure WSH_ITM_UTIL.GET_SERVICE_DETAILS***');


  EXCEPTION

    WHEN OTHERS THEN
      l_sql_error := SQLERRM;
      OE_DEBUG_PUB.Add('Processing Failed with an Error');
      OE_DEBUG_PUB.Add('The unexpected error is :' || l_sql_error);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END GET_SERVICE_DETAILS;


  -- Name
  --   UPDATE_PROCESS_FLAG
  --   Purpose
  --   To update the process_flag of a request.
  -- Arguments
  --   p_control_id_list              A PLSQL Table containing the list of transaction control id values
  --   p_process_flag                 process_flag value
  --   x_return_status                Return Status


PROCEDURE UPDATE_PROCESS_FLAG (
       p_control_id_list             IN  CONTROL_ID_LIST,
       p_process_flag                IN  NUMBER,
       x_return_status               OUT NOCOPY  VARCHAR2)
IS
    l_sql_error            VARCHAR2(2000);
    i                      NUMBER;

  BEGIN

    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    oe_debug_pub.add('In the procedure WSH_ITM_UTIL.UPDATE_PROCESS_FLAG');

    FORALL i IN p_control_id_list.FIRST..p_control_id_list.LAST
     UPDATE WSH_ITM_REQUEST_CONTROL
     SET
        PROCESS_FLAG = p_process_flag
     WHERE REQUEST_CONTROL_ID = p_control_id_list(i);

    oe_debug_pub.add('End of the procedure WSH_ITM_UTIL.UPDATE_PROCESS_FLAG');

  EXCEPTION

    WHEN OTHERS THEN
      l_sql_error := SQLERRM;
      oe_debug_pub.add('Processing Failed with an Error');
      oe_debug_pub.add('The unexpected error is :' || l_sql_error);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END UPDATE_PROCESS_FLAG;

  -- Name
  --   get vendor
  --   Purpose
  --   To get the Vendor name from the Request Control ID
  -- Arguments
  --   p_request_control_id        p_request_control_id of a request
  --   x_service_provider          VendorName
  PROCEDURE GET_SERVICE_PROVIDER(
        p_request_control_id    IN NUMBER,
        x_service_provider      OUT NOCOPY VARCHAR2) IS
  BEGIN
	SELECT VENDOR INTO x_service_provider FROM
	( SELECT 1 PRIORITY, V.SERVICE_PROVIDER VENDOR
  	  FROM WSH_ITM_SERVICE_PREFERENCES US1,
	  WSH_ITM_VENDOR_SERVICES S, WSH_ITM_VENDORS V,
  		WSH_ITM_REQUEST_CONTROL RC
  	  WHERE US1.APPLICATION_ID = RC.APPLICATION_ID AND
  	        US1.MASTER_ORGANIZATION_ID = RC.MASTER_ORGANIZATION_ID  AND
  		US1.VENDOR_SERVICE_ID = S.VENDOR_SERVICE_ID AND
  		S.VENDOR_ID = V.VENDOR_ID AND
  		US1.ACTIVE_FLAG = 'Y' AND
  		S.SERVICE_TYPE = RC.SERVICE_TYPE_CODE AND
  		RC.REQUEST_CONTROL_ID = p_request_control_id
  	 UNION
  	 SELECT 2 PRIORITY, V.SERVICE_PROVIDER VENDOR
  	 FROM WSH_ITM_SERVICE_PREFERENCES US1,
  		WSH_ITM_VENDOR_SERVICES S, WSH_ITM_VENDORS V,
  		WSH_ITM_REQUEST_CONTROL RC
  	 WHERE US1.APPLICATION_ID = RC.APPLICATION_ID AND
  		US1.MASTER_ORGANIZATION_ID IS NULL AND
  		US1.VENDOR_SERVICE_ID = S.VENDOR_SERVICE_ID AND
  		S.VENDOR_ID = V.VENDOR_ID AND
  		US1.ACTIVE_FLAG = 'Y' AND
  		S.SERVICE_TYPE = RC.SERVICE_TYPE_CODE AND
  		RC.REQUEST_CONTROL_ID = p_request_control_id
  	ORDER BY PRIORITY
	) WHERE ROWNUM < 2;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_service_provider := NULL;
        WHEN OTHERS THEN
	   x_service_provider := NULL;
  END GET_SERVICE_PROVIDER;

--Added in Bug 8916313
--===================================================================================================
   -- Start of comments
   --
   -- API Name          : GET_COMPLIANCE_STATUS
   -- Type              : Public
   -- Purpose           : Called by OM to get the ITM request control compliance status.
   -- Pre-reqs          : None
   -- Function          : This API can be used to get the compliance status of the ITM request control lines
   --                     In case if multiple request lines are present this will only return the first record
   --                     found with the matching i/p criteria
   --                     Before OM inserts a record in Wsh_Itm_Request_Control table, if there exists a record
   --                     in WIRC table for same order line then OM (OEXVITMB.pls) calls API
   --                     WSH_ITM_UTIL.Update_process_Flag to update the process_flag value to 4.
   --                     So, while querying from WIRC table ignore record with process_flag value 4.
   --
   -- PARAMETERS        : p_appliciation_id                 i/p Appliciation id
   --                     p_original_sys_reference          i/p Original system reference
   --                     p_original_sys_line_reference     i/p Original system line reference
   --                     x_process_flag                    o/p compliance status.
   --                     x_request_control_id              o/p request_control_id ,
   --                     x_request_set_id                  o/p request_set_id  ,
   --                     x_return_status                   o/p return status
   -- VERSION          :  current version                   1.0
   --                     initial version                   1.0
   -- End of comments
--===================================================================================================

PROCEDURE  GET_COMPLIANCE_STATUS ( p_appliciation_id  IN NUMBER,
                            p_original_sys_reference  IN NUMBER,
                            p_original_sys_line_reference IN NUMBER,
                            x_process_flag OUT NOCOPY NUMBER,
                            x_request_control_id OUT NOCOPY NUMBER,
                            x_request_set_id OUT NOCOPY NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2)
IS
  l_sql_error   VARCHAR2(2000);
  l_process_flag NUMBER ;
  l_request_control_id  NUMBER;
  l_request_set_id NUMBER  ;

  --Cursor to get the compliance details of the ITM request lines
  CURSOR c_get_compliance_details(l_appliciation_id NUMBER,l_original_sys_reference NUMBER ,l_original_sys_line_reference NUMBER) IS
  SELECT process_flag,
         request_control_id,
         request_set_id
  FROM   wsh_itm_request_control WRC
  WHERE  wrc.application_id = l_appliciation_id     AND
         wrc.original_system_reference = l_original_sys_reference  AND
         wrc.original_system_line_reference  = l_original_sys_line_reference AND
         wrc.process_flag <> 4;

  MISSING_INPUT EXCEPTION;
  INVALID_APPLICATION EXCEPTION;

BEGIN

   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   oe_debug_pub.add('In the procedure WSH_ITM_UTIL.GET_COMPLIANCE_STATUS');
   oe_debug_pub.add('p_appliciation_id :' || p_appliciation_id );
   oe_debug_pub.add('p_original_sys_reference :' || p_original_sys_reference );
   oe_debug_pub.add('p_original_sys_line_reference :' || p_original_sys_line_reference );

   IF p_appliciation_id IS NOT NULL THEN
   --{

       IF p_appliciation_id = 660 THEN
       --{
            IF ( p_original_sys_reference IS NULL OR p_original_sys_line_reference IS NULL ) THEN
            --{
                 oe_debug_pub.add('P_original_sys_reference and p_original_sys_line_reference are mandatory parameter for appplication_id 660');
                 RAISE MISSING_INPUT ;
            --}
            END IF;

            --Get the compliance details of the ITM request lines
            --API will return compliance data for only first reqest line (in case of multiple lines are present)
            OPEN c_get_compliance_details(p_appliciation_id,p_original_sys_reference,p_original_sys_line_reference);
            FETCH c_get_compliance_details INTO l_process_flag , l_request_control_id ,l_request_set_id;
            CLOSE c_get_compliance_details;
       --}
       ELSE
       --{
            oe_debug_pub.add('Applciation_id is invalid');
            RAISE INVALID_APPLICATION;
       --}
       END IF;
   --}
   ELSE
   --{
        oe_debug_pub.add('Application_id is mandatory');
        RAISE MISSING_INPUT ;
   --}
   END IF;

   x_process_flag := l_process_flag;
   x_request_control_id := l_request_control_id;
   x_request_set_id := l_request_set_id;

   oe_debug_pub.add('End of the procedure WSH_ITM_UTIL.GET_COMPLIANCE_STATUS');
   --
  EXCEPTION

    WHEN INVALID_APPLICATION THEN
      oe_debug_pub.add('Processing Failed as application_id provided is invalid ');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN MISSING_INPUT THEN
      oe_debug_pub.add('Processing Failed as some mandatory parameters are missing ');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN

      IF c_get_compliance_details%ISOPEN THEN
        CLOSE c_get_compliance_details;
      END IF;
      l_sql_error := SQLERRM;
      oe_debug_pub.add('Processing Failed with an Error');
      oe_debug_pub.add('The unexpected error is :' || l_sql_error);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END GET_COMPLIANCE_STATUS;

END WSH_ITM_UTIL;

/
