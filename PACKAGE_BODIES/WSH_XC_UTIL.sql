--------------------------------------------------------
--  DDL for Package Body WSH_XC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_XC_UTIL" as
/* $Header: WSHXCUTB.pls 120.12.12010000.3 2009/02/09 12:07:57 skanduku ship $ */

	-- standard global constants
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_XC_UTIL';
	p_message_type	CONSTANT VARCHAR2(1) := 'E';


	C_ACTION_SEMICLOSED    CONSTANT VARCHAR2(11) := 'SEMI-CLOSED';  -- FP bug 4370532
	C_STATUS_CLOSED        CONSTANT VARCHAR2(6) := 'CLOSED';
	C_SEVERITY_INFO        CONSTANT VARCHAR2(4) := 'INFO';

        C_OTM_EXC_NAME         CONSTANT VARCHAR2(22) := 'WSH_OTM_SHIPMENT_ERROR';

	-- exception shared between validate_location_id() and
	-- log_exception()

	WSH_XC_INVALID_LOCATION			EXCEPTION;

  -- bug 5183769 : BEGIN
  -- following types/variable are added to cache Exception Definitions

  TYPE Exception_Def_Rec_Typ IS RECORD(
        DEFAULT_SEVERITY   WSH_EXCEPTION_DEFINITIONS_VL.DEFAULT_SEVERITY%TYPE,
        EXCEPTION_HANDLING WSH_EXCEPTION_DEFINITIONS_VL.EXCEPTION_HANDLING%TYPE,
        INITIATE_WORKFLOW  WSH_EXCEPTION_DEFINITIONS_VL.INITIATE_WORKFLOW%TYPE,
        ENABLED            WSH_EXCEPTION_DEFINITIONS_VL.ENABLED%TYPE
  );

  TYPE Exception_Def_Tab_Typ IS TABLE OF Exception_Def_Rec_Typ INDEX BY VARCHAR2(30);

  g_exception_defs Exception_Def_Tab_Typ;

  -- bug 5183769 : END

-- -------------------------------------------------------------------
-- Start of comments
-- API name        : Get_Exception_Def
--     Type        : private
-- Function        : return the attributes for the given exception name
--                   added to fix bug 5183769(Caching of Exception Definitions)
--
-- IN  Parameters  : p_exception_name      Exception Name
-- OUT Parameters  : x_exception_def_info  Record of Exception Attributes
--                   x_return_status       Return Status
-- End of comments
-- ---------------------------------------------------------------------
PROCEDURE Get_Exception_Def(
                p_exception_name     IN         VARCHAR2,
                x_exception_def_info OUT NOCOPY Exception_Def_Rec_Typ,
                x_return_status      OUT NOCOPY VARCHAR2) IS

  -- cursor to get exception attributes
  CURSOR C_EXC_DEF(c_exception_name VARCHAR2) IS
     SELECT UPPER(default_severity),
            UPPER(exception_handling),
            UPPER(initiate_workflow),
            enabled
       FROM wsh_exception_definitions_vl
      WHERE exception_name = c_exception_name;

  l_debug_on BOOLEAN;
  l_msg_data VARCHAR(2000);
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_EXCEPTION_DEF';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME', p_exception_name);
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if exception definition is already cached
  IF (g_exception_defs.count <> 0 AND
      g_exception_defs.EXISTS(p_exception_name)) THEN

    x_exception_def_info := g_exception_defs(p_exception_name);

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'CACHED:EXCEPTION_NAME ',p_exception_name);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    RETURN;

  END IF;

  -- Need to fetch and cache exception definition info

  OPEN c_exc_def(p_exception_name);
  FETCH c_exc_def INTO x_exception_def_info;

  IF c_exc_def%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE c_exc_def;
  g_exception_defs(p_exception_name) := x_exception_def_info;

  -- Debug Statements
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'CACHING:EXCEPTION_NAME ',p_exception_name);
    WSH_DEBUG_SV.log(l_module_name,'CACHING:EXCEPTION_HANDLING ',g_exception_defs(p_exception_name).exception_handling);
    WSH_DEBUG_SV.log(l_module_name,'CACHING:INITIATE_WORKFLOW ',g_exception_defs(p_exception_name).initiate_workflow);
    WSH_DEBUG_SV.log(l_module_name,'CACHING:DEFAULT_SEVERITY ',g_exception_defs(p_exception_name).default_severity);
    WSH_DEBUG_SV.log(l_module_name,'CACHING:ENABLED ',g_exception_defs(p_exception_name).enabled);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.Set_Name('WSH', 'WSH_XC_DEF_NOT_FOUND');
      IF c_exc_def%ISOPEN THEN
        CLOSE c_exc_def;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'ERROR: ','Exception Not Defined:'||p_exception_name);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      -- end of NO_DATA_FOUND exception handling
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('WSH','WSH_UNEXP_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','WSH_XC_UTIL.GET_EXCEPTION_DEF');
      FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
      FND_MESSAGE.Set_Token('ORA_TEXT','');
      IF c_exc_def%ISOPEN THEN
        CLOSE c_exc_def;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      -- end of OTHERS exception handling
END Get_Exception_Def;

-- -----------------------------------------------------------------
-- Start of comments
-- API name	: log_exception
--	Type			: Public
--	Function		: This function is to log a new exception or to restrictly
--						update an existing exception. Update is allowed only
--						for the fields which are NULL due to the nature of
--						exceptions. The update function is mostly useful to
--						add exception name to an open exception
-- Pre-reqs		: None
--	Version		: Initial version 1.0
-- Notes			: please use :set tabstop=3 to view this file in vi to get
--						proper alignment
--
-- BUG#: 1549665 hwahdani :   added p_request_id parameter
-- BUG#: 1900149 hwahdani :   added opm attributes to the parameter list
-- BUG#: 1729516 rvarghes :   added batch_id (Picking Batch id)
-- End of comments
-- ------------------------------------------------------------------
PROCEDURE log_exception(

		-- Standard parameters
		p_api_version					IN NUMBER,
		p_init_msg_list				IN VARCHAR2,
		p_commit							IN VARCHAR2,
		p_validation_level			IN NUMBER,
		x_return_status				OUT NOCOPY  VARCHAR2,
		x_msg_count						OUT NOCOPY  NUMBER,
		x_msg_data						OUT NOCOPY  VARCHAR2,

		-- Program Specific parameters
		x_exception_id					IN OUT NOCOPY  NUMBER,
		p_exception_location_id 	IN	NUMBER,
		p_logged_at_location_id		IN	NUMBER,
		p_logging_entity				IN	VARCHAR2,
		p_logging_entity_id			IN	NUMBER,
		p_exception_name				IN	VARCHAR2,
		p_message						IN	VARCHAR2,
		p_severity						IN	VARCHAR2,
		p_manually_logged				IN VARCHAR2,
		p_exception_handling		   IN VARCHAR2,
		p_trip_id						IN	NUMBER,
		p_trip_name						IN	VARCHAR2,
		p_trip_stop_id					IN	NUMBER,
		p_delivery_id					IN	NUMBER,
		p_delivery_name				IN	VARCHAR2,
		p_delivery_detail_id			IN NUMBER,
		p_delivery_assignment_id	IN NUMBER,
		p_container_name         	IN	VARCHAR2,
		p_inventory_item_id			IN	NUMBER,
		p_lot_number					IN	VARCHAR2,
-- HW OPMCONV - No need for sublot_number
--              p_sublot_number            IN VARCHAR2,
		p_revision						IN	VARCHAR2,
		p_serial_number				IN	VARCHAR2,
		p_unit_of_measure		      IN	VARCHAR2,
                p_quantity						IN	NUMBER,
                p_unit_of_measure2			IN	VARCHAR2,
		p_quantity2						IN	NUMBER,
		p_subinventory					IN	VARCHAR2,
		p_locator_id					IN	NUMBER,
		p_arrival_date					IN	DATE,
		p_departure_date				IN	DATE,
		p_error_message				IN	VARCHAR2,
		p_attribute_category			IN	VARCHAR2,
		p_attribute1					IN	VARCHAR2,
		p_attribute2					IN	VARCHAR2,
		p_attribute3					IN	VARCHAR2,
		p_attribute4					IN	VARCHAR2,
		p_attribute5					IN	VARCHAR2,
		p_attribute6					IN	VARCHAR2,
		p_attribute7					IN	VARCHAR2,
		p_attribute8					IN	VARCHAR2,
		p_attribute9					IN	VARCHAR2,
		p_attribute10					IN	VARCHAR2,
		p_attribute11					IN	VARCHAR2,
		p_attribute12					IN	VARCHAR2,
		p_attribute13					IN	VARCHAR2,
		p_attribute14					IN	VARCHAR2,
		p_attribute15					IN	VARCHAR2,
      p_request_id               IN NUMBER,
      p_batch_id                 IN NUMBER,
--bug 3362060
      p_creation_date          IN     DATE     DEFAULT NULL,
      p_created_by             IN     NUMBER   DEFAULT NULL,
      p_last_update_date       IN     DATE     DEFAULT NULL,
      p_last_updated_by        IN     NUMBER   DEFAULT NULL,
      p_last_update_login      IN     NUMBER   DEFAULT NULL,
      p_program_application_id IN     NUMBER   DEFAULT NULL,
      p_program_id             IN     NUMBER   DEFAULT NULL,
      p_program_update_date    IN     DATE     DEFAULT NULL,
      p_status                 IN     VARCHAR2 DEFAULT NULL,
      p_action                 IN     VARCHAR2 DEFAULT NULL
)  IS

	-- standard version infermation
   l_api_version	CONSTANT	NUMBER		:= 1.0;
   l_api_name		CONSTANT	VARCHAR2(30):= 'log_exception';

	-- cursor to validate logging_entity
	CURSOR C2 (c_logging_entity VARCHAR2) IS
		SELECT	lookup_code
		FROM		fnd_lookup_values_vl
		WHERE		lookup_type = 'LOGGING_ENTITY' AND
					lookup_code = c_logging_entity AND
					enabled_flag = 'Y' AND
					(sysdate BETWEEN NVL(start_date_active,sysdate) AND
										NVL(end_date_active, sysdate));

	-- cursor for update
	CURSOR C3 (c_exception_id NUMBER) IS
	--Changed for BUG#3330869
	--	SELECT *
		SELECT
			exception_id,
                      	message,
		      	exception_name,
		      	status,
		      	severity,
			trip_id,
			trip_name,
			trip_stop_id,
			delivery_id,
			delivery_name,
			delivery_detail_id,
			delivery_assignment_id,
			container_name,
			inventory_item_id,
			lot_number,
-- HW OPMCONV - No need for sublot_number
--                      sublot_number,
			revision,
			serial_number,
			unit_of_measure,
			quantity,
			unit_of_measure2,
			quantity2,
			subinventory,
			locator_id,
			arrival_date,
			departure_date,
			error_message,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15,
			request_id,
			logged_at_location_id,
			logging_entity,
			logging_entity_id,
			exception_location_id,
			manually_logged
		FROM	wsh_exceptions
		WHERE	exception_id = c_exception_id FOR UPDATE;


	-- local variables
	l_exception_id					NUMBER 			:= NULL;
	l_severity						VARCHAR2(10)	:= NULL;
        l_exc_def_info                                  Exception_Def_Rec_Typ;
	l_manually_logged				VARCHAR2(1) 	:= FND_API.G_FALSE;
   -- Shipping exception enhancement : changed default to 'NO_ACTION_REQUIRED'
	l_status						   VARCHAR2(30) 	:='NO_ACTION_REQUIRED';
	l_exception_name				VARCHAR2(30) 	:= NULL;
	l_applicatoin_id				NUMBER;
	l_xcp_record					C3%ROWTYPE;
	l_logging_entity				VARCHAR2(30)	:= NULL;
-- Bug# 1924574 , added l_return_status, l_location_id
        l_return_status                         VARCHAR2(30);
        l_location_id                           NUMBER;
	-- local variable to hold token for exception WSH_XC_INVALID_OPERATION
	l_msg_name                                      VARCHAR2(30)    := NULL;
	l_field_name                                    VARCHAR2(30)    := NULL;
	l_msg_summary					VARCHAR2(2000) := NULL;
	l_msg_details					VARCHAR2(4000) := NULL;

	WSH_XC_INVALID_LOGGING_ENTITY	EXCEPTION;
	WSH_XC_INVALID_SEVERITY			EXCEPTION;
	WSH_XC_INVALID_OPERATION		EXCEPTION;
	WSH_XC_NOT_FOUND					EXCEPTION;
	WSH_XC_DEF_NOT_FOUND				EXCEPTION;
	WSH_XC_DATA_ERROR					EXCEPTION;

   -- Raising Event for Workflow Enabled exception
   l_msg_parameter_list     WF_PARAMETER_LIST_T;
   l_event_name             VARCHAR2(120) := 'oracle.apps.wsh.excp.log';
   l_event_key              VARCHAR2(30);
   l_p_entity_name          VARCHAR2(30);
   l_p_entity_id            VARCHAR2(30);
   l_exception_name_exists  BOOLEAN := TRUE;
-- Bug 3711661 , added l_request_id, l_batch_id
        l_request_id            number;
        l_batch_id              number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_EXCEPTION';
--

--
BEGIN

  	-- Standard begin of API savepoint
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
	    WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
	    WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
	    WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
	    WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
	    WSH_DEBUG_SV.log(l_module_name,'X_EXCEPTION_ID',X_EXCEPTION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_LOCATION_ID',P_EXCEPTION_LOCATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_LOGGED_AT_LOCATION_ID',P_LOGGED_AT_LOCATION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY',P_LOGGING_ENTITY);
	    WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY_ID',P_LOGGING_ENTITY_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME',P_EXCEPTION_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_MESSAGE',P_MESSAGE);
	    WSH_DEBUG_SV.log(l_module_name,'P_MANUALLY_LOGGED',P_MANUALLY_LOGGED);
	    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_NAME',P_TRIP_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_TRIP_STOP_ID',P_TRIP_STOP_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_NAME',P_DELIVERY_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ASSIGNMENT_ID',P_DELIVERY_ASSIGNMENT_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_CONTAINER_NAME',P_CONTAINER_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
-- HW OPMCONV - No need for sublot_number
--          WSH_DEBUG_SV.log(l_module_name,'P_SUBLOT_NUMBER',P_SUBLOT_NUMBER);
	    WSH_DEBUG_SV.log(l_module_name,'P_REVISION',P_REVISION);
	    WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_NUMBER',P_SERIAL_NUMBER);
	    WSH_DEBUG_SV.log(l_module_name,'P_UNIT_OF_MEASURE',P_UNIT_OF_MEASURE);
	    WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY',P_QUANTITY);
	    WSH_DEBUG_SV.log(l_module_name,'P_UNIT_OF_MEASURE2',P_UNIT_OF_MEASURE2);
	    WSH_DEBUG_SV.log(l_module_name,'P_QUANTITY2',P_QUANTITY2);
	    WSH_DEBUG_SV.log(l_module_name,'P_SUBINVENTORY',P_SUBINVENTORY);
	    WSH_DEBUG_SV.log(l_module_name,'P_LOCATOR_ID',P_LOCATOR_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_ARRIVAL_DATE',P_ARRIVAL_DATE);
	    WSH_DEBUG_SV.log(l_module_name,'P_DEPARTURE_DATE',P_DEPARTURE_DATE);
	    WSH_DEBUG_SV.log(l_module_name,'P_ERROR_MESSAGE',P_ERROR_MESSAGE);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
	    WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_BATCH_ID',P_BATCH_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_STATUS',P_STATUS);
	    WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
	END IF;
	--
	SAVEPOINT	Log_Exception_PUB;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.compatible_api_call(	l_api_version,
 														p_api_version,
														l_api_name,
														G_PKG_NAME) THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_boolean(p_init_msg_list)	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF x_exception_id IS NULL THEN
		-- insert record

  		-- validate required parameters
		IF p_logged_at_location_id IS NULL OR
			p_logging_entity IS NULL OR
			p_logging_entity_id IS NULL OR
			p_message IS NULL
		THEN
		        l_msg_name := 'WSH_XC_MIS_REQ_PARAM';
			RAISE WSH_XC_INVALID_OPERATION;
		END IF;

		-- validate logging entity
		OPEN C2(p_logging_entity);
		FETCH C2 INTO	l_logging_entity;
		IF C2%NOTFOUND THEN
			CLOSE C2;
			RAISE WSH_XC_INVALID_LOGGING_ENTITY;
		END IF;
		CLOSE C2;

		-- validate p_exception_location_id
      -- 1924574 Changes, Calling API and removing earlier Cursors
      l_location_id := p_exception_location_id;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_UTIL_VALIDATE.Validate_Location (
                      p_location_id      => l_location_id,
                      p_location_code    => NULL ,
                      x_return_status    => l_return_status);
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			RAISE WSH_XC_INVALID_LOCATION;
      END IF;

		-- validate p_logged_at_location_id
      l_location_id := p_logged_at_location_id;
      -- 1924574 Changes, Calling Procedure and removing earlier Cursors
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_UTIL_VALIDATE.Validate_Location (
                      p_location_id      => l_location_id,
                      p_location_code    => null,
                      x_return_status    => l_return_status);
      IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			RAISE WSH_XC_INVALID_LOCATION;
      END IF;

		-- set default value for p_manually_logged is 'F'
		IF p_manually_logged=FND_API.G_TRUE
		THEN
			l_manually_logged := p_manually_logged;
                ELSE                                                    -- Bugfix 3711661
                        IF (p_request_id is null) THEN
                                l_request_id := fnd_global.conc_request_id;
                        ELSE
                                l_request_id := p_request_id;
                        END IF;

                        IF (p_batch_id is null)
                        THEN
                                l_batch_id := WSH_PICK_LIST.G_BATCH_ID;
                        ELSE
                                l_batch_id := p_batch_id;
                        END IF;
                END IF;

		-- check if exception name is null
		IF p_exception_name IS NULL THEN
         -- Shipping exception enhancement :
         -- changed default status from OPEN to NO_ACTION_REQUIRED
         -- added default severity as INFO
			l_status   := 'NO_ACTION_REQUIRED';  -- default status
         l_severity := 'INFO';
		ELSE -- exception name is not null

			-- validate exception_name and get default attr
                        -- bug 5183769, call get_exception for caching

                        Get_Exception_Def(
                           p_exception_name     => p_exception_name,
                           x_exception_def_info => l_exc_def_info,
                           x_return_status      => l_return_status);

                        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
				RAISE WSH_XC_DEF_NOT_FOUND;
                        ELSIF l_exc_def_info.enabled = 'N' THEN
                          IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,'Not logging exception since the exception is not enabled',WSH_DEBUG_SV.C_PROC_LEVEL);
                          END IF;
                          GOTO end_proc;
			END IF;

			-- set default severity	if it is not passed
                        -- Shipping exception enhancement : assign default severity, exception_handling
			l_severity := l_exc_def_info.default_severity;

			-- set default status
                        -- Shipping Exception enhancement

                        If p_action = 'SPLIT-LINE' and p_status is not null and p_exception_name is not null then
                          l_status := p_status;
                        else
                          IF l_severity IN ( 'ERROR' , 'WARNING' ) THEN
                            l_status := 'OPEN';
                          ELSE
                            l_status := 'NO_ACTION_REQUIRED';
                          End if;
                        END IF;

			l_exception_name := UPPER(p_exception_name);
                        l_exception_name_exists := FALSE; -- since exception_name was NULL
		END IF; -- check if exception name is NULL

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Logging exception with severity '||l_severity||' , status '||l_status ,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

		-- populate l_exception_id
		-- Bug 6615016 using the wsh_exceptions_s.nextval directly in the insert statement.
		-- SELECT wsh_exceptions_s.nextval INTO l_exception_id FROM SYS.DUAL;

		IF l_debug_on THEN
		  wsh_debug_sv.logmsg(l_module_name, '**** Actual values ****');
		  -- Bug 6615016
		  --wsh_debug_Sv.log(l_module_name, 'Exception ID', l_exception_id);
		  wsh_debug_sv.log(l_module_name, 'Exception Loc ID', p_exception_location_id);
		  wsh_debug_sv.log(l_module_name, 'Logged at loc Id', p_logged_at_location_id);
		  wsh_debug_Sv.log(l_module_name, 'Logging Entity', p_logging_entity);
		  wsh_debug_Sv.log(l_module_name, 'Logging Entity ID', p_logging_entity_id);
		  wsh_debug_sv.log(l_module_name, 'Exception Name', l_exception_name);
		  wsh_debug_sv.log(l_module_name, 'Message', p_message);
		  wsh_debug_sv.log(l_module_name, 'Severity', l_severity);
		  wsh_debug_Sv.log(l_module_name, 'Manually Logged?', l_manually_logged);
		  wsh_debug_sv.log(l_module_name, 'Status', l_status);
		  wsh_debug_sv.log(l_module_name, 'Trip ID', p_trip_id);
		  wsh_debug_sv.log(l_module_name, 'Trip Name', p_trip_name);
		  wsh_debug_sv.log(l_module_name, 'Trip Stop Id', p_trip_stop_id);
		  wsh_debug_sv.log(l_module_name, 'Delivery Id', p_delivery_id);
		  wsh_debug_sv.log(l_module_name, 'Delivery name', p_delivery_name);
		  wsh_debug_sv.log(l_module_name, 'Delivery Detail ID', p_delivery_detail_id);
		  wsh_debug_Sv.log(l_module_name, 'Assignment Id', p_delivery_assignment_id);
		  wsh_debug_sv.log(l_module_name, 'Request Id', l_request_id);  -- Bugfix 3711661, previously p_request_id was passed.
		  wsh_debug_sv.log(l_module_name, 'Batch Id', l_batch_id);  -- Bugfix 3711661, previously p_batch_id was passed.
		END IF;
		--
		IF (p_container_name is not null) and (p_delivery_detail_id is null) then --LPN Synch Up..samanna
		    l_msg_name := 'WSH_MISSING_DETAILS';
		    raise WSH_XC_INVALID_OPERATION;
	        END IF;
		--
		INSERT INTO wsh_exceptions(
			exception_id,
			exception_location_id,
			logged_at_location_id,
			logging_entity,
			logging_entity_id,
			exception_name,
			message,
			severity,
			manually_logged,
			status,
			trip_id,
			trip_name,
			trip_stop_id,
			delivery_id,
			delivery_name,
			delivery_detail_id,
			delivery_assignment_id,
			container_name,
			inventory_item_id,
			lot_number,
			revision,
			serial_number,
			unit_of_measure,
			quantity,
			subinventory,
			locator_id,
			arrival_date,
			departure_date,
			error_message,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
-- BUG#:1549665 hwahdani added request_id
               request_id ,
-- HW BUG#:1900149
-- HW OPMCONV - No need for sublot_number
--                      sublot_number,
			unit_of_measure2,
			quantity2,
-- HW end of 1900149
                        batch_id,
                        program_application_id,
                        program_id,
                        program_update_date
    )
    VALUES (
		-- Bug 6615016 using the wsh_exceptions_s.nextval directly in the insert statement.
    		--l_exception_id,
    		wsh_exceptions_s.nextval,
		p_exception_location_id,
		p_logged_at_location_id,
		UPPER(p_logging_entity),
		p_logging_entity_id,
		DECODE(l_exception_name, NULL, NULL, UPPER(l_exception_name)),
		p_message,
      -- Shipping Exception enhancement
      l_severity,
		l_manually_logged,
		l_status,
		p_trip_id,
		p_trip_name,
		p_trip_stop_id,
		p_delivery_id,
		p_delivery_name,
		p_delivery_detail_id,
		p_delivery_assignment_id,
		null,			--LPN_conv Synch Up..samanna
		p_inventory_item_id,
		p_lot_number,
		p_revision,
		p_serial_number,
		p_unit_of_measure,
		p_quantity,
		p_subinventory,
		p_locator_id,
		p_arrival_date,
		p_departure_date,
		p_error_message,
		p_attribute_category,
		p_attribute1,
		p_attribute2,
		p_attribute3,
		p_attribute4,
		p_attribute5,
		p_attribute6,
		p_attribute7,
		p_attribute8,
		p_attribute9,
		p_attribute10,
		p_attribute11,
		p_attribute12,
		p_attribute13,
		p_attribute14,
		p_attribute15,
                NVL(p_creation_date,SYSDATE),
                NVL(p_created_by,FND_GLOBAL.USER_ID),
                NVL(p_last_update_date,SYSDATE),
                NVL(p_last_updated_by,FND_GLOBAL.USER_ID),
                NVL(p_last_update_login,FND_GLOBAL.LOGIN_ID),
-- BUG#:1549665 hwahdani added request_id
		l_request_id,	-- Bugfix 3711661, previously p_request_id was passed.
-- HW BUG#:1900149 added opm columns
-- HW OPMCONV - No need for sublot_number
--              p_sublot_number,
		p_unit_of_measure2,
		p_quantity2,
-- HW end of 1900149
                l_batch_id,	-- Bugfix 3711661, previously p_batch_id was passed.
                p_program_application_id,
                p_program_id,
                p_program_update_date
    );

	IF FND_API.TO_BOOLEAN(p_commit) THEN
		COMMIT WORK;
	END IF;

	x_exception_id := l_exception_id;




 ELSE -- update

		-- validate x_exception_id
		OPEN C3(x_exception_id);
		FETCH C3 INTO l_xcp_record;
		IF C3%NOTFOUND THEN
			CLOSE C3;
			RAISE WSH_XC_NOT_FOUND;
		END IF;

		l_exception_id := l_xcp_record.exception_id;

		-- update an existing exception,the required fields can't be changed.
		IF  ( p_logged_at_location_id IS NOT NULL) OR
	   	    (p_exception_location_id IS NOT NULL)  OR
                    (p_logging_entity IS NOT NULL) OR
                    (p_logging_entity_id IS NOT NULL)
		THEN
		        l_msg_name := 'WSH_XC_CHANGE_REQ_FIELD';
			RAISE WSH_XC_INVALID_OPERATION;
		END IF;


		-- append p_message to the current message text if p_message is
		-- not NULL
		IF p_message is NOT NULL then
			-- l_xcp_record.message := l_xcp_record.message || p_message;
			 l_xcp_record.message :=  p_message;
		END IF;

		-- Only update on a NULL field is allowed.
		-- If the current value is already the same with the parameter,
		-- the current value is not changed and the procedure won't fail.

		IF p_exception_name IS NOT NULL THEN
		  IF l_xcp_record.exception_name IS NOT NULL  and
		     l_xcp_record.exception_name <> p_exception_name THEN
		    l_msg_name := 'WSH_XC_EXP_NAME_EXIST';
		    RAISE WSH_XC_INVALID_OPERATION;
                  ELSIF l_xcp_record.exception_name IS NULL THEN
                    l_exception_name_exists := FALSE; -- since exception_name was NULL
		  END IF;

		  -- validate exception_name
                  -- bug 5183769, call get_exception for caching

                  Get_Exception_Def(
                           p_exception_name     => p_exception_name,
                           x_exception_def_info => l_exc_def_info,
                           x_return_status      => l_return_status);

                  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		    RAISE WSH_XC_DEF_NOT_FOUND;
                  ELSIF l_exc_def_info.enabled = 'N' THEN
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Not logging exception since the exception is not enabled',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF;
                    GOTO end_proc;
		  END IF;

		  -- get default status
                  -- Shipping Exception enhancement
                  IF l_exc_def_info.default_severity IN ( 'ERROR' , 'WARNING' ) THEN
                     l_xcp_record.status := 'OPEN';
                     l_status            := 'OPEN';
                  ELSE
                     l_xcp_record.status := 'NO_ACTION_REQUIRED';
                     l_status            := 'NO_ACTION_REQUIRED';
                  END IF;

		  l_xcp_record.exception_name := UPPER(p_exception_name);

		  -- set default severity
		  l_xcp_record.severity := UPPER(l_exc_def_info.default_severity);
                  l_severity := l_xcp_record.severity;

		END IF; -- end of IF p_exception_name IS NOT NULL THEN

		IF p_trip_id IS NOT NULL THEN
			IF l_xcp_record.trip_id IS NULL THEN
				l_xcp_record.trip_id:= p_trip_id;
			ELSE
				IF l_xcp_record.trip_id <> p_trip_id THEN
				        l_msg_name := 'WSH_XC_TRIP_NUM_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;

		IF p_trip_name IS NOT NULL THEN
			IF l_xcp_record.trip_name IS NULL THEN
				l_xcp_record.trip_name:= p_trip_name;
			ELSE
				IF l_xcp_record.trip_name <> p_trip_name THEN
				        l_msg_name := 'WSH_XC_TRIP_NAME_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;

		IF p_trip_stop_id IS NOT NULL THEN
			IF l_xcp_record.trip_stop_id IS NULL THEN
				l_xcp_record.trip_stop_id:= p_trip_stop_id;
			ELSE
				IF l_xcp_record.trip_stop_id <> p_trip_stop_id THEN
				        l_msg_name := 'WSH_XC_STOP_NUM_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;

		IF p_delivery_id IS NOT NULL THEN
			IF l_xcp_record.delivery_id IS NULL THEN
				l_xcp_record.delivery_id:= p_delivery_id;
			ELSE
				IF l_xcp_record.delivery_id <> p_delivery_id THEN
				        l_msg_name := 'WSH_XC_DEL_NUM_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;

		IF p_delivery_name IS NOT NULL THEN
			IF l_xcp_record.delivery_name IS NULL THEN
				l_xcp_record.delivery_name:= p_delivery_name;
			ELSE
				IF l_xcp_record.delivery_name <> p_delivery_name THEN
				        l_msg_name := 'WSH_XC_DEL_NAME_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
    END IF;

		IF p_delivery_detail_id IS NOT NULL THEN
	  	 	IF l_xcp_record.delivery_detail_id IS NULL THEN
				l_xcp_record.delivery_detail_id:= p_delivery_detail_id;
	   	ELSE
				IF l_xcp_record.delivery_detail_id <> p_delivery_detail_id THEN
				        l_msg_name := 'WSH_XC_DET_NUM_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
	   		END IF;
	   	END IF;
		END IF;

		IF p_delivery_assignment_id IS NOT NULL THEN
	   	IF l_xcp_record.delivery_assignment_id IS NULL THEN
				l_xcp_record.delivery_assignment_id:= p_delivery_assignment_id;
	   	ELSE
				IF l_xcp_record.delivery_assignment_id <> p_delivery_assignment_id THEN
				        l_msg_name := 'WSH_XC_ASSIGN_NUM_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
	   		END IF;
	   	END IF;
		END IF;


		/*IF p_container_name IS NOT NULL THEN
			IF l_xcp_record.container_name IS NULL THEN
				l_xcp_record.container_name:= p_container_name;
			ELSE
				IF l_xcp_record.container_name <> p_container_name THEN
				        l_msg_name := 'WSH_XC_CON_NAME_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;*/--LPN Synch Up ..samanna

		IF p_inventory_item_id IS NOT NULL THEN
			IF l_xcp_record.inventory_item_id IS NULL THEN
				l_xcp_record.inventory_item_id :=  p_inventory_item_id;
			ELSE
				IF l_xcp_record.inventory_item_id <> p_inventory_item_id THEN
				        l_msg_name := 'WSH_XC_INV_ITEM_ID_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;


		IF p_lot_number IS NOT NULL THEN
			IF l_xcp_record.lot_number IS NULL THEN
				l_xcp_record.lot_number:=p_lot_number ;
			ELSE
				IF l_xcp_record.lot_number <> p_lot_number THEN
				        l_msg_name := 'WSH_XC_LOT_NUM_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;
-- HW BUG#:1900149
-- HW OPMCONV - Removed sublot code

-- HW end of 1900149

		IF p_revision IS NOT NULL THEN
			IF l_xcp_record.revision IS NULL THEN
				l_xcp_record.revision:=p_revision ;
			ELSE
				IF l_xcp_record.revision <> p_revision THEN
				        l_msg_name := 'WSH_XC_REVSION_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;

		IF p_serial_number IS NOT NULL THEN
			IF l_xcp_record.serial_number IS NULL THEN
				l_xcp_record.serial_number := p_serial_number ;
			ELSE
				IF l_xcp_record.serial_number <> p_serial_number THEN
				        l_msg_name := 'WSH_XC_SER_NUM_EXIST';
					RAISE WSH_XC_INVALID_OPERATION;
				END IF;
			END IF;
		END IF;

	IF p_unit_of_measure IS NOT NULL THEN
		IF l_xcp_record.unit_of_measure IS NULL THEN
			l_xcp_record.unit_of_measure :=p_unit_of_measure  ;
		ELSE
			IF l_xcp_record.unit_of_measure <> p_unit_of_measure THEN
			        l_msg_name := 'WSH_XC_UOM_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_quantity IS NOT NULL THEN
		IF l_xcp_record.quantity IS NULL THEN
			l_xcp_record.quantity := p_quantity ;
		ELSE
			IF l_xcp_record.quantity <> p_quantity THEN
			        l_msg_name := 'WSH_XC_QUANTITY_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

-- HW BUG#:1900149
	IF p_unit_of_measure2 IS NOT NULL THEN
		IF l_xcp_record.unit_of_measure2 IS NULL THEN
			l_xcp_record.unit_of_measure2 :=p_unit_of_measure2  ;
		ELSE
			IF l_xcp_record.unit_of_measure2 <> p_unit_of_measure2 THEN
			        l_msg_name := 'WSH_XC_SEC_UOM_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_quantity2 IS NOT NULL THEN
		IF l_xcp_record.quantity2 IS NULL THEN
			l_xcp_record.quantity2 := p_quantity2 ;
		ELSE
			IF l_xcp_record.quantity2 <> p_quantity2 THEN
			        l_msg_name := 'WSH_XC_SEC_QUANTITY_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;
-- HW end of 1900149


	IF p_subinventory IS NOT NULL THEN
		IF l_xcp_record.subinventory IS NULL THEN
			l_xcp_record.subinventory := p_subinventory ;
		ELSE
			IF l_xcp_record.subinventory <> p_subinventory THEN
			        l_msg_name := 'WSH_XC_SUBINVENTORY_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_locator_id IS NOT NULL THEN
		IF l_xcp_record.locator_id IS NULL THEN
			l_xcp_record.locator_id := p_locator_id  ;
		ELSE
			IF l_xcp_record.locator_id <> p_locator_id THEN
			        l_msg_name := 'WSH_XC_LOCATOR_NUM_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_arrival_date IS NOT NULL THEN
		IF l_xcp_record.arrival_date IS NULL THEN
			l_xcp_record.arrival_date := p_arrival_date   ;
		ELSE
			IF l_xcp_record.arrival_date <> p_arrival_date THEN
			        l_msg_name := 'WSH_XC_ARR_DATE_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_departure_date IS NOT NULL THEN
		IF l_xcp_record.departure_date IS NULL THEN
			l_xcp_record.departure_date := p_departure_date  ;
		ELSE
			IF l_xcp_record.departure_date <> p_departure_date THEN
			        l_msg_name := 'WSH_XC_DEP_DATE_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;



		-- update p_error_message to the current message text if p_error_message is
		-- not NULL
		IF p_error_message is NOT NULL then
			 l_xcp_record.error_message :=  p_error_message;
		END IF;

/*-- Bug No:2363908 ---> Fix : Update is allowed for all the DFF attributes appearing in SHipping Exception Form
Fix is done by commenting all the checks

	IF p_attribute_category IS NOT NULL THEN
		IF l_xcp_record.attribute_category IS NULL THEN
			l_xcp_record.attribute_category := p_attribute_category  ;
		ELSE
			IF l_xcp_record.attribute_category <> p_attribute_category THEN
			        l_msg_name := 'WSH_XC_ATTR_CATEGORY_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute1 IS NOT NULL THEN
		IF l_xcp_record.attribute1 IS NULL THEN
			l_xcp_record.attribute1 := p_attribute1;
		ELSE
			IF l_xcp_record.attribute1 <> p_attribute1 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE1';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute2 IS NOT NULL THEN
		IF l_xcp_record.attribute2 IS NULL THEN
			l_xcp_record.attribute2 := p_attribute2;
		ELSE
			IF l_xcp_record.attribute2 <> p_attribute2 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE2';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute3 IS NOT NULL THEN
		IF l_xcp_record.attribute3 IS NULL THEN
			l_xcp_record.attribute3 := p_attribute3;
		ELSE
			IF l_xcp_record.attribute3 <> p_attribute3 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE3';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute4 IS NOT NULL THEN
		IF l_xcp_record.attribute4 IS NULL THEN
			l_xcp_record.attribute4 := p_attribute4;
		ELSE
			IF l_xcp_record.attribute4 <> p_attribute4 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE4';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute5 IS NOT NULL THEN
		IF l_xcp_record.attribute5 IS NULL THEN
			l_xcp_record.attribute5 := p_attribute5;
		ELSE
			IF l_xcp_record.attribute5 <> p_attribute5 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE5';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute6 IS NOT NULL THEN
		IF l_xcp_record.attribute6 IS NULL THEN
			l_xcp_record.attribute6 := p_attribute6;
		ELSE
			IF l_xcp_record.attribute6 <> p_attribute6 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE6';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute7 IS NOT NULL THEN
		IF l_xcp_record.attribute7 IS NULL THEN
			l_xcp_record.attribute7 := p_attribute7;
		ELSE
			IF l_xcp_record.attribute7 <> p_attribute7 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE7';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute8 IS NOT NULL THEN
		IF l_xcp_record.attribute8 IS NULL THEN
			l_xcp_record.attribute8 := p_attribute8;
		ELSE
			IF l_xcp_record.attribute8 <> p_attribute8 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE8';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute9 IS NOT NULL THEN
		IF l_xcp_record.attribute9 IS NULL THEN
			l_xcp_record.attribute9 := p_attribute9;
		ELSE
			IF l_xcp_record.attribute9 <> p_attribute9 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE9';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute10 IS NOT NULL THEN
		IF l_xcp_record.attribute10 IS NULL THEN
			l_xcp_record.attribute10 := p_attribute10;
		ELSE
			IF l_xcp_record.attribute10 <> p_attribute10 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE10';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute11 IS NOT NULL THEN
		IF l_xcp_record.attribute11 IS NULL THEN
			l_xcp_record.attribute11 := p_attribute11;
		ELSE
			IF l_xcp_record.attribute11 <> p_attribute11 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE11';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute12 IS NOT NULL THEN
		IF l_xcp_record.attribute12 IS NULL THEN
			l_xcp_record.attribute12 := p_attribute12;
		ELSE
			IF l_xcp_record.attribute12 <> p_attribute12 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE12';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute13 IS NOT NULL THEN
		IF l_xcp_record.attribute13 IS NULL THEN
			l_xcp_record.attribute13 := p_attribute13;
		ELSE
			IF l_xcp_record.attribute13 <> p_attribute13 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE13';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF p_attribute14 IS NOT NULL THEN
		IF l_xcp_record.attribute14 IS NULL THEN
			l_xcp_record.attribute14 := p_attribute14;
		ELSE
			IF l_xcp_record.attribute14 <> p_attribute14 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE14';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

	IF l_debug_on THEN

	    WSH_DEBUG_SV.log(l_module_name,'p_attribute15',p_attribute15);
	    WSH_DEBUG_SV.log(l_module_name,'l_xcp_record.attribute15',l_xcp_record.attribute15);
	END IF;
	IF p_attribute15 IS NOT NULL THEN

		IF l_xcp_record.attribute15 IS NULL THEN
			l_xcp_record.attribute15 := p_attribute15;
		ELSE
			IF l_xcp_record.attribute15 <> p_attribute15 THEN
			        l_msg_name := 'WSH_XC_ATTR_EXIST';
			        l_field_name := 'ATTRIBUTE15';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;

-- End of fix for Bug:2363908  */


-- BUG#:1549665 hwahdani added p_request_id
	IF p_request_id IS NOT NULL THEN
		IF l_xcp_record.request_id IS NULL THEN
			l_xcp_record.request_id := p_request_id ;
		ELSE
			IF l_xcp_record.request_id <> p_request_id THEN
			        l_msg_name := 'WSH_XC_REQ_ID_EXIST';
				RAISE WSH_XC_INVALID_OPERATION;
			END IF;
		END IF;
	END IF;


	UPDATE wsh_exceptions
	SET
		logged_at_location_id = l_xcp_record.logged_at_location_id,
		logging_entity = l_xcp_record.logging_entity,
		logging_entity_id = l_xcp_record.logging_entity_id,
		exception_name = l_xcp_record.exception_name,
		exception_location_id = l_xcp_record.exception_location_id,
		message = l_xcp_record.message,
		severity = l_xcp_record.severity,
		manually_logged = l_xcp_record.manually_logged,
		status = l_xcp_record.status,
		trip_id = l_xcp_record.trip_id,
		trip_name = l_xcp_record.trip_name,
		trip_stop_id = l_xcp_record.trip_stop_id,
		delivery_id = l_xcp_record.delivery_id,
		delivery_name = l_xcp_record.delivery_name,
		delivery_detail_id = l_xcp_record.delivery_detail_id,
		delivery_assignment_id = l_xcp_record.delivery_assignment_id,
		container_name =l_xcp_record.container_name,
		inventory_item_id = l_xcp_record.inventory_item_id,
		lot_number = l_xcp_record.lot_number,
-- HW BUG#:1900149 added sublot
-- HW OPMCONV - No need for sublot_number
--              sublot_number = l_xcp_record.sublot_number,
		revision = l_xcp_record.revision,
		serial_number = l_xcp_record.serial_number,
		unit_of_measure = l_xcp_record.unit_of_measure,
		quantity = l_xcp_record.quantity,
-- HW BUG#:1900149 added uom2 and qty2
		unit_of_measure2 = l_xcp_record.unit_of_measure2,
		quantity2 = l_xcp_record.quantity2,
-- HW end of 1900149
		subinventory = l_xcp_record.subinventory,
		locator_id = l_xcp_record.locator_id,
		arrival_date = l_xcp_record.arrival_date,
		departure_date = l_xcp_record.departure_date,
		error_message = l_xcp_record.error_message,
		attribute_category = p_attribute_category,
		attribute1 = p_attribute1,
		attribute2 = p_attribute2,
		attribute3 = p_attribute3,
		attribute4 = p_attribute4,
		attribute5 = p_attribute5,
		attribute6 = p_attribute6,
		attribute7 = p_attribute7,
		attribute8 = p_attribute8,
		attribute9 = p_attribute9,
		attribute10 = p_attribute10,
		attribute11 = p_attribute11,
		attribute12 = p_attribute12,
		attribute13 = p_attribute13,
		attribute14 = p_attribute14,
		attribute15 = p_attribute15,
		last_update_date = NVL(p_last_update_date,SYSDATE),
   	last_updated_by = NVL(p_last_updated_by,FND_GLOBAL.USER_ID),
		last_update_login = NVL(p_last_update_login,FND_GLOBAL.LOGIN_ID),
--BUG#:1549665 hwahdani added request_id
		request_id = l_xcp_record.request_id
	WHERE CURRENT OF C3;

	IF FND_API.TO_BOOLEAN(p_commit) THEN
		COMMIT WORK;
		x_exception_id := l_exception_id;
	END IF;
	CLOSE C3;


END IF;

  -- Raise Business Event , if exception is workflow enabled and Exception name is being passed first time
  IF p_exception_name IS NOT NULL AND NOT (l_exception_name_exists)
  AND nvl(l_exc_def_info.initiate_workflow,'N') = 'Y' THEN
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Raising Business event for exception : '||l_exception_id,WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     l_event_key := x_exception_id;
     IF p_delivery_detail_id IS NOT NULL THEN
        l_p_entity_name := 'LINE';
        l_p_entity_id   := p_delivery_detail_id;
     ELSIF p_trip_stop_id IS NOT NULL THEN
        l_p_entity_name := 'STOP';
        l_p_entity_id   := p_trip_stop_id;
     ELSIF p_delivery_id IS NOT NULL THEN
        l_p_entity_name := 'DELIVERY';
        l_p_entity_id   := p_delivery_id;
     ELSIF p_trip_id IS NOT NULL THEN
        l_p_entity_name := 'TRIP';
        l_p_entity_id   := p_trip_id;
     ELSE
        l_p_entity_name := NULL;
        l_p_entity_id   := NULL;
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Entity Name : '||l_p_entity_name||' Entity Id : '||l_p_entity_id ,WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     WF_EVENT.AddParameterToList ( p_name  => 'EXCEPTION_NAME',
                                   p_value => p_exception_name,
                                   p_parameterlist => l_msg_parameter_list);
     WF_EVENT.AddParameterToList ( p_name  => 'EXCEPTION_ID',
                                   p_value => x_exception_id,
                                   p_parameterlist => l_msg_parameter_list);
     WF_EVENT.AddParameterToList ( p_name  => 'ENTITY_NAME',
                                   p_value => l_p_entity_name,
                                   p_parameterlist => l_msg_parameter_list);
     WF_EVENT.AddParameterToList ( p_name  => 'ENTITY_ID',
                                   p_value => l_p_entity_id,
                                   p_parameterlist => l_msg_parameter_list);
     WF_EVENT.AddParameterToList ( p_name  => 'EXCEPTION_BEHAVIOR',
                                   p_value => l_severity,
                                   p_parameterlist => l_msg_parameter_list);
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WF_EVENT.RAISE' ,WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     WF_EVENT.Raise ( p_event_name => l_event_name,
                      p_event_key  => 'EXCP'||l_event_key,
                      p_parameters => l_msg_parameter_list );
  END IF;

<<end_proc>>

    WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      IF l_debug_on THEN
        wsh_debug_sv.logmsg(l_module_name, 'x_msg_count > 1');
      END IF;
      x_msg_data := SUBSTRB((l_msg_summary || l_msg_details),1, 2000);
    else
      IF l_debug_on THEN
       wsh_debug_sv.logmsg(l_module_name, 'x_msg_count < 1');
      END IF;
      x_msg_data := SUBSTRB(l_msg_summary, 1, 2000);
    end if;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
    EXCEPTION


		WHEN WSH_XC_INVALID_OPERATION THEN
			IF C3%ISOPEN THEN
				CLOSE C3;
			END IF;

			FND_MESSAGE.SET_NAME('WSH', l_msg_name);
			IF l_msg_name = 'WSH_XC_ATTR_EXIST' THEN
			   FND_MESSAGE.SET_TOKEN('FIELD', l_field_name , TRUE);
			END IF;

			IF l_msg_name = 'WSH_MISSING_DETAILS' THEN   --LPN Synch Up..samanna
			   FND_MESSAGE.SET_TOKEN('Cont_name',p_container_name);
			END IF;

--l_msg_summary := fnd_message.get;

			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;

			WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
                        END IF;
                        --
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
			end if;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_OPERATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_OPERATION');
END IF;
--
		WHEN WSH_XC_INVALID_LOGGING_ENTITY THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_INVALID_LOGGING_ENTITY');

--l_msg_summary := fnd_message.get;

			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
                        END IF;
                        --
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_LOGGING_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_LOGGING_ENTITY');
END IF;
--
		WHEN WSH_XC_INVALID_SEVERITY THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_INVALID_SEVERITY');

--l_msg_summary := fnd_message.get;

			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
                        END IF;
                        --
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_SEVERITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_SEVERITY');
END IF;
--
		WHEN WSH_XC_INVALID_LOCATION THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_INVALID_LOCATION');

--l_msg_summary := fnd_message.get;

			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
                        END IF;
                        --
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_LOCATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_LOCATION');
END IF;
--
		WHEN WSH_XC_NOT_FOUND THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_NOT_FOUND');

--l_msg_summary := fnd_message.get;

			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
                        END IF;
                        --
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_NOT_FOUND');
END IF;
--
		WHEN WSH_XC_DEF_NOT_FOUND THEN

			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
                        END IF;
                        --
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_DEF_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_DEF_NOT_FOUND');
END IF;
--
		WHEN WSH_XC_DATA_ERROR THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_DATA_ERROR');

--l_msg_summary := fnd_message.get;

			WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
			x_return_status := FND_API.G_RET_STS_ERROR;
			WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
                        END IF;
                        --
			if x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			else
				x_msg_data := l_msg_summary;
		   end if;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_DATA_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_DATA_ERROR');
END IF;
--
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			ROLLBACK TO Log_Exception_PUB ;

l_msg_summary := 'unexpected error';
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,  L_MSG_SUMMARY  );
END IF;
--

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			IF	FND_MSG_PUB.check_msg_level
		        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
					FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
			END IF;
			FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
		WHEN OTHERS THEN
			ROLLBACK TO Log_Exception_PUB ;
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			IF	FND_MSG_PUB.check_msg_level
		        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
					FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
			END IF;
			FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END log_exception;

-- ---------------------------------------------------------------------
-- Start of comments
-- API name		: change_status
--	Type			: Public
--	Function		: If the p_old_status matches the current exception status,
--						this procedure will change the status in two ways:
--						1) if p_set_default_status = FND_API.G_TRUE (i.e. 'T'),
--							then it sets the exception to default status
--						2) if p_set_default_status is missing, it sets the
--							exception to x_new_status
--
-- Pre-reqs		: The existance of the exception
--	Version		:  Initial version 1.0
-- Notes			:
--
-- End of comments
-- ---------------------------------------------------------------------


PROCEDURE change_status(
		-- standard parameters
		p_api_version			IN			NUMBER,
		p_init_msg_list		IN 		VARCHAR2,
		p_commit					IN			VARCHAR2,
		p_validation_level	IN 		NUMBER,
		x_return_status		OUT NOCOPY  		VARCHAR2,
		x_msg_count				OUT NOCOPY  		NUMBER,
		x_msg_data				OUT NOCOPY  		VARCHAR2,

		-- program specific parameters
		p_exception_id			IN			NUMBER,
		p_old_status			IN			VARCHAR2,
		p_set_default_status	IN			VARCHAR2,
		x_new_status			IN	OUT NOCOPY 	VARCHAR2
) IS

	l_api_version	CONSTANT	NUMBER := 1.0;
	l_api_name		CONSTANT	VARCHAR2(30) := 'Change_Status';


	CURSOR C1(c_exception_id2 NUMBER) IS
			SELECT UPPER(exception_name),
                DECODE( UPPER(status), 'MANUAL','OPEN' ,
                                       'LOGGED','OPEN' ,
                                       'IN_PROCESS','OPEN' ,
                                       'ERROR','OPEN' ,
                                       'NOT_HANDLED','NO_ACTION_REQUIRED' ,
                                        NULL,'NO_ACTION_REQUIRED' ,
                                        UPPER(status)
                       )
			FROM wsh_exceptions
			WHERE exception_id = c_exception_id2;

	CURSOR C2(c_exception_id NUMBER) IS
			SELECT UPPER(default_severity), UPPER(exception_handling),
					UPPER(initiate_workflow)
			FROM wsh_exception_definitions_vl
			WHERE exception_name = (
				SELECT exception_name
				FROM wsh_exceptions
			   WHERE exception_id = c_exception_id);

		l_exception_name				VARCHAR2(30);
		l_new_status					VARCHAR2(30)	:= NULL;
		l_old_status					VARCHAR2(30);
		l_p_old_status					VARCHAR2(30);

		l_lookups_status				VARCHAR2(30);
		l_status_valid					VARCHAR2(1) 	:= FND_API.G_FALSE;
		l_exception_handling			VARCHAR2(16);
		l_initiate_workflow			VARCHAR2(1)		:= 'N';
		l_severity			         VARCHAR2(10);

		-- local variable to hold the token for WSH_XC_INVALID_OPERATION
		l_msg_name                                      VARCHAR2(30)    := NULL;
		l_msg_summary					VARCHAR2(2000) := NULL;
		l_msg_details					VARCHAR2(4000) := NULL;


		WSH_XC_STATUS_MISMATCH		EXCEPTION;

		-- current status does not match p_old_status
		WSH_XC_NOT_FOUND					EXCEPTION; -- exception not found
		WSH_XC_INVALID_OPERATION		EXCEPTION; -- operation not allowed
		WSH_XC_INVALID_STATUS			EXCEPTION; -- the new status is not valid
		WSH_XC_DATA_ERROR             EXCEPTION;
		WSH_XC_EXCEPTION_CLOSED			EXCEPTION;
                WSH_XC_OTM_ERROR                        EXCEPTION; -- OTM R12 glog project

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_STATUS';
--
BEGIN
    -- Standard begin of API savepoint
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
		    WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
		    WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
		    WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
		    WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
		    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_ID',P_EXCEPTION_ID);
		    WSH_DEBUG_SV.log(l_module_name,'P_OLD_STATUS',P_OLD_STATUS);
		    WSH_DEBUG_SV.log(l_module_name,'P_SET_DEFAULT_STATUS',P_SET_DEFAULT_STATUS);
		    WSH_DEBUG_SV.log(l_module_name,'X_NEW_STATUS',X_NEW_STATUS);
		END IF;
		--
		SAVEPOINT	Change_Status_PUB;
		-- Standard call to check for call compatibility.
		IF NOT FND_API.compatible_api_call(l_api_version,
											p_api_version,
											l_api_name,
											G_PKG_NAME)	THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- Check p_init_msg_list
		IF FND_API.to_boolean(p_init_msg_list)	THEN
			FND_MSG_PUB.initialize;
		END IF;

		-- initialize API return status to success
			x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Converting the p_old_status to applicable status (OPEN,CLOSED,NO_ACTION_REQUIRED) since we do not upgrade old exceptions status to new
   -- However new exceptions will be logged with new valid status
   -- If p_old_status is CLOSED, then raise error
   IF p_old_status IN ('MANUAL','LOGGED','IN_PROCESS','ERROR') THEN
      l_p_old_status := 'OPEN';
   ELSIF p_old_status IN ('NOT_HANDLED',NULL) THEN
      l_p_old_status := 'NO_ACTION_REQUIRED';
   ELSIF p_old_status IN ('CLOSED') THEN
		RAISE WSH_XC_EXCEPTION_CLOSED;
   ELSE
      l_p_old_status := UPPER(p_old_status);
   END IF;

	-- validate existence of this exception
	OPEN C1(p_exception_id);
	FETCH C1 INTO l_exception_name, l_old_status;
	IF (C1%FOUND) THEN
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_old_status:'||l_old_status||' l_p_old_status:'||l_p_old_status, WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
		IF l_old_status <> UPPER(l_p_old_status) THEN
			CLOSE C1;
			RAISE WSH_XC_STATUS_MISMATCH;
		END IF;
	ELSE
		CLOSE C1;
		RAISE WSH_XC_NOT_FOUND;
	END IF;

	-- validate parameters, p_set_default_status and x_new_status is mutually exclusive
	--
	IF p_set_default_status = FND_API.G_TRUE THEN
		x_new_status := NULL;
		OPEN C2(p_exception_id);
		FETCH C2 INTO l_severity, l_exception_handling, l_initiate_workflow;

		IF (C2%FOUND) THEN
         -- Shipping exception enhancement
         IF l_severity IN ('ERROR', 'WARNING') THEN
            l_new_status := 'OPEN';
         ELSE
            l_new_status := 'NO_ACTION_REQUIRED';
			END IF;

		ELSE
			-- exception name not found in wsh_exception_definitions_vl
			CLOSE C2;
			RAISE WSH_XC_DATA_ERROR;
		END IF;

		CLOSE C2;

	ELSE -- p_set_default_status is false

		IF x_new_status IS NULL  THEN
		        l_msg_name := 'WSH_XC_STATUS_REQUIRED';
			RAISE WSH_XC_INVALID_OPERATION;
		ELSIF l_p_old_status = 'CLOSED' THEN
			RAISE WSH_XC_EXCEPTION_CLOSED;
		ELSIF UPPER(x_new_status) = 'CLOSED' THEN
		   l_new_status := UPPER(x_new_status);
		ELSE
			RAISE WSH_XC_INVALID_STATUS;
		END IF;

	END IF;

        -- OTM R12 glog project
        --IF l_exception_name = 'WSH_OTM_SHIPMENT_ERROR' AND
        IF l_exception_name = C_OTM_EXC_NAME AND
           l_new_status = 'CLOSED' THEN
           RAISE WSH_XC_OTM_ERROR;
         END IF;
        -- OTM R12 end of glog project

	UPDATE wsh_exceptions
		SET 	status = l_new_status,
				last_update_date = SYSDATE,
				last_updated_by = FND_GLOBAL.USER_ID,
				last_update_login = FND_GLOBAL.LOGIN_ID
		WHERE exception_id = p_exception_id
      AND   DECODE( UPPER(status),
                    'MANUAL','OPEN' ,
                    'LOGGED','OPEN' ,
                    'IN_PROCESS','OPEN' ,
                    'ERROR','OPEN' ,
                    'NOT_HANDLED','NO_ACTION_REQUIRED' ,
                     NULL,'NO_ACTION_REQUIRED' ,
                    UPPER(status)
                  ) = l_p_old_status ;

	IF FND_API.TO_BOOLEAN(p_commit) THEN
		COMMIT WORK;
	END IF;

	x_new_status := l_new_status;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

                -- OTM R12 glog project
WHEN  WSH_XC_OTM_ERROR THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_OTM_EXCEPTION');
    WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
    WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
      x_msg_data := l_msg_summary || l_msg_details;
    else
      x_msg_data := l_msg_summary;
    end if;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_OTM_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_OTM_ERROR');
    END IF;
  -- OTM R12 end of glog project

WHEN  WSH_XC_INVALID_STATUS THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_INVALID_STATUS');
    WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
    WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
	x_msg_data := l_msg_summary || l_msg_details;
    else
	x_msg_data := l_msg_summary;
    end if;


    --
    -- Debug Statements
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_STATUS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_STATUS');
    END IF;
    --
WHEN WSH_XC_INVALID_OPERATION THEN
    FND_MESSAGE.SET_NAME('WSH', l_msg_name);
    WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
    WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
    	x_msg_data := l_msg_summary || l_msg_details;
    else
    	x_msg_data := l_msg_summary;
    end if;

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_OPERATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_OPERATION');
   END IF;
   --
WHEN WSH_XC_STATUS_MISMATCH THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_STATUS_MISMATCH');
    WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
    WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
    	x_msg_data := l_msg_summary || l_msg_details;
    else
    	x_msg_data := l_msg_summary;
    end if;


    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_STATUS_MISMATCH exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_STATUS_MISMATCH');
    END IF;
    --
WHEN WSH_XC_NOT_FOUND THEN
     IF C1%ISOPEN THEN
     CLOSE C1;
     END IF;
     FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_NOT_FOUND');
     WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
     x_return_status := FND_API.G_RET_STS_ERROR;
     WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
     if x_msg_count > 1 then
     	x_msg_data := l_msg_summary || l_msg_details;
     else
     	x_msg_data := l_msg_summary;
     end if;


     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_NOT_FOUND');
     END IF;
     --
WHEN WSH_XC_DATA_ERROR THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_DATA_ERROR');
    WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
    WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
    	x_msg_data := l_msg_summary || l_msg_details;
    else
    	x_msg_data := l_msg_summary;
    end if;


    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_DATA_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_DATA_ERROR');
    END IF;
    --
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Change_Status_PUB ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF	FND_MSG_PUB.check_msg_level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);


    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --

WHEN WSH_XC_EXCEPTION_CLOSED THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_EXCEPTION_CLOSED');
    FND_MESSAGE.SET_TOKEN('EXCEPTION_ID', P_EXCEPTION_ID);
    WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
    WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
    if x_msg_count > 1 then
       x_msg_data := l_msg_summary || l_msg_details;
    else
       x_msg_data := l_msg_summary;
    end if;


    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_EXCEPTION_CLOSED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_OPERATION');
    END IF;


WHEN OTHERS THEN
    ROLLBACK TO Change_Status_PUB ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF	FND_MSG_PUB.check_msg_level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END change_status;


-- -------------------------------------------------------------------
-- Start of comments
-- API name			: insert_xc_def_form
--	Type				: public
--	Function			: insert exception definitions, called by form
--	Version			: Initial version 1.0
--
-- End of comments
-- ---------------------------------------------------------------------

procedure insert_xc_def_form (
		x_exception_definition_id in out NOCOPY  NUMBER,
		p_exception_name			in VARCHAR2,
		p_description				in VARCHAR2,
		p_exception_type			in VARCHAR2,
		p_default_severity  		in VARCHAR2,
		p_exception_handling		in VARCHAR2,
	  	p_workflow_item_type		in VARCHAR2,
	  	p_workflow_process  	 	in VARCHAR2,
		p_initiate_workflow 		in VARCHAR2,
		p_update_allowed 			in VARCHAR2,
		p_enabled 			      in VARCHAR2,
		p_attribute_category 	in VARCHAR2,
		p_attribute1				in VARCHAR2,
		p_attribute2				in VARCHAR2,
		p_attribute3	         in VARCHAR2,
		p_attribute4	   		in VARCHAR2,
		p_attribute5	         in VARCHAR2,
		p_attribute6	 			in VARCHAR2,
		p_attribute7				in VARCHAR2,
		p_attribute8				in VARCHAR2,
		p_attribute9				in VARCHAR2,
		p_attribute10				in VARCHAR2,
		p_attribute11	  			in VARCHAR2,
		p_attribute12	 			in VARCHAR2,
		p_attribute13				in VARCHAR2,
		p_attribute14				in VARCHAR2,
		p_attribute15	   		in VARCHAR2,
		p_creation_date  			in DATE,
  		p_created_by       		in NUMBER,
  		p_last_update_date 		in DATE,
  		p_last_updated_by  		in NUMBER,
  		p_last_update_login		in NUMBER
)  is

cursor C1 (c_exception_name VARCHAR2) is
		select exception_name
		from wsh_exception_definitions_vl
		where exception_name = c_exception_name;

cursor C2 (c_exception_definition_id NUMBER) is
 select ROWID from WSH_EXCEPTION_DEFINITIONS_B
    where EXCEPTION_DEFINITION_ID =
			 c_exception_definition_id;

l_exception_name VARCHAR2(30);
l_exception_definition_id NUMBER;
l_rowid				VARCHAR2(30) := NULL;

WSH_XC_DEF_DUP				exception;
WSH_XC_DEF_NOT_FOUND		exception;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_XC_DEF_FORM';
--
begin

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
    WSH_DEBUG_SV.log(l_module_name,'X_EXCEPTION_DEFINITION_ID',X_EXCEPTION_DEFINITION_ID);
    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME',P_EXCEPTION_NAME);
    WSH_DEBUG_SV.log(l_module_name,'P_DESCRIPTION',P_DESCRIPTION);
    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_TYPE',P_EXCEPTION_TYPE);
    WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_SEVERITY',P_DEFAULT_SEVERITY);
    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_HANDLING',P_EXCEPTION_HANDLING);
    WSH_DEBUG_SV.log(l_module_name,'P_WORKFLOW_ITEM_TYPE',P_WORKFLOW_ITEM_TYPE);
    WSH_DEBUG_SV.log(l_module_name,'P_WORKFLOW_PROCESS',P_WORKFLOW_PROCESS);
    WSH_DEBUG_SV.log(l_module_name,'P_INITIATE_WORKFLOW',P_INITIATE_WORKFLOW);
    WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_ALLOWED',P_UPDATE_ALLOWED);
    WSH_DEBUG_SV.log(l_module_name,'P_ENABLED',P_ENABLED);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
    WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE',P_CREATION_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_CREATED_BY',P_CREATED_BY);
    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
END IF;
--
open C1(p_exception_name);
fetch C1 into l_exception_name;
if (C1%NOTFOUND) then
		if (x_exception_definition_id is not NULL)   then
			open C2(x_exception_definition_id);
			fetch C2 into l_rowid;
			if l_rowid is not NULL then
				raise WSH_XC_DEF_DUP;
			else
				l_exception_definition_id := x_exception_definition_id;
			end if;
			close C2;
		else
			-- populate l_exception_id
			SELECT wsh_exception_definitions_s.nextval INTO l_exception_definition_id FROM SYS.DUAL;
		end if;
		insert into wsh_exception_definitions_b (
				exception_definition_id,
				exception_type,
				default_severity,
				exception_handling,
	  			workflow_item_type,
	  			workflow_process,
				initiate_workflow,
				update_allowed,
				enabled,
				attribute_category,
				attribute1,
				attribute2,
				attribute3,
				attribute4,
				attribute5,
				attribute6,
				attribute7,
				attribute8,
				attribute9,
				attribute10,
				attribute11,
				attribute12,
				attribute13,
				attribute14,
				attribute15,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login
			) values (
				l_exception_definition_id,
				UPPER(p_exception_type),
				UPPER(p_default_severity),
				UPPER(p_exception_handling),
	  			UPPER(p_workflow_item_type),
	 		 	UPPER(p_workflow_process),
				UPPER(p_initiate_workflow),
				UPPER(p_update_allowed),
				UPPER(p_enabled),
				p_attribute_category,
				p_attribute1,
				p_attribute2,
				p_attribute3,
				p_attribute4,
				p_attribute5,
				p_attribute6,
				p_attribute7,
				p_attribute8,
				p_attribute9,
				p_attribute10,
				p_attribute11,
				p_attribute12,
				p_attribute13,
				p_attribute14,
				p_attribute15,
				p_creation_date,
				p_created_by,
				p_last_update_date,
				p_last_updated_by,
				p_last_update_login
			);


			insert into WSH_EXCEPTION_DEFINITIONS_TL (
				EXCEPTION_DEFINITION_ID,
				EXCEPTION_NAME,
				DESCRIPTION,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				LANGUAGE,
				SOURCE_LANG
			) select
				l_exception_definition_id,
				p_exception_name,
				p_description,
				p_creation_date,
				p_created_by,
				p_last_update_date,
				p_last_updated_by,
				p_last_update_login,
				L.LANGUAGE_CODE,
				userenv('LANG')
			from FND_LANGUAGES L
				where L.INSTALLED_FLAG in ('I', 'B')
					and not exists
				(select NULL
				 from WSH_EXCEPTION_DEFINITIONS_TL T
				 where T.EXCEPTION_DEFINITION_ID = l_exception_definition_id
				 and T.LANGUAGE = L.LANGUAGE_CODE);



				open C2 (l_exception_definition_id);
				fetch C2 into l_rowid;
				if (C2%notfound) then
					close C2;
					raise WSH_XC_DEF_NOT_FOUND;
				end if;
				close C2;
				close C1;
		else
				close C1;
				raise WSH_XC_DEF_DUP;
		end if;
		x_exception_definition_id := l_exception_definition_id;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
		exception

		WHEN WSH_XC_DEF_DUP THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_DEF_DUP');
			APP_EXCEPTION.RAISE_EXCEPTION;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_DEF_DUP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_DEF_DUP');
END IF;
--
		WHEN WSH_XC_DEF_NOT_FOUND THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_NOT_FOUND');
			APP_EXCEPTION.RAISE_EXCEPTION;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_DEF_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_DEF_NOT_FOUND');
END IF;
--
end insert_xc_def_form;





-- -------------------------------------------------------------------
-- Start of comments
-- API name			: update_xc_def_form
--	Type				: public
--	Function			: update exception definitions, called by form
--	Version			: Initial version 1.0
--
-- End of comments
-- ---------------------------------------------------------------------
procedure	update_xc_def_form (
	   p_exception_definition_id  in NUMBER,
		p_exception_name		in VARCHAR2,
		p_description			in VARCHAR2,
		p_exception_type		in VARCHAR2,
		p_default_severity  	in VARCHAR2,
		p_exception_handling	in VARCHAR2,
	  	p_workflow_item_type	in VARCHAR2,
	  	p_workflow_process   	in VARCHAR2,
		p_initiate_workflow 	in VARCHAR2,
		p_update_allowed 		in VARCHAR2,
		p_enabled 		      in VARCHAR2,
		p_attribute_category 	in VARCHAR2,
		p_attribute1			in VARCHAR2,
		p_attribute2			in VARCHAR2,
		p_attribute3			in VARCHAR2,
		p_attribute4	   		in VARCHAR2,
		p_attribute5			in VARCHAR2,
		p_attribute6	 		in VARCHAR2,
		p_attribute7			in VARCHAR2,
		p_attribute8			in VARCHAR2,
		p_attribute9			in VARCHAR2,
		p_attribute10			in VARCHAR2,
		p_attribute11	  		in VARCHAR2,
		p_attribute12	 		in VARCHAR2,
		p_attribute13			in VARCHAR2,
		p_attribute14			in VARCHAR2,
		p_attribute15	   		in VARCHAR2,
		p_creation_date  		in DATE,
 		p_created_by       		in NUMBER,
		p_last_update_date 		in DATE,
		p_last_updated_by  		in NUMBER,
		p_last_update_login		in NUMBER,
		p_caller                        in VARCHAR2    -- 5986504
	)  is
		l_exception_name VARCHAR2(30);
                l_update_allowed VARCHAR2(1);
                --5986504

                cursor C2 (c_exception_definition_id NUMBER) is
                select update_allowed from WSH_EXCEPTION_DEFINITIONS_B
                   where EXCEPTION_DEFINITION_ID =
			 c_exception_definition_id;
                --
		WSH_XC_DEF_NOT_FOUND		exception;
		--
l_debug_on BOOLEAN;
		--
		l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_XC_DEF_FORM';
		--
begin
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
                -- 5986504
				open C2 (p_exception_definition_id);
				fetch C2 into l_update_allowed;
				close C2;
                --
		IF l_debug_on THEN
		    WSH_DEBUG_SV.push(l_module_name);
		    --
		    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_DEFINITION_ID',P_EXCEPTION_DEFINITION_ID);
		    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME',P_EXCEPTION_NAME);
		    WSH_DEBUG_SV.log(l_module_name,'P_DESCRIPTION',P_DESCRIPTION);
		    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_TYPE',P_EXCEPTION_TYPE);
		    WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_SEVERITY',P_DEFAULT_SEVERITY);
		    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_HANDLING',P_EXCEPTION_HANDLING);
		    WSH_DEBUG_SV.log(l_module_name,'P_WORKFLOW_ITEM_TYPE',P_WORKFLOW_ITEM_TYPE);
		    WSH_DEBUG_SV.log(l_module_name,'P_WORKFLOW_PROCESS',P_WORKFLOW_PROCESS);
		    WSH_DEBUG_SV.log(l_module_name,'P_INITIATE_WORKFLOW',P_INITIATE_WORKFLOW);
		    WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_ALLOWED',P_UPDATE_ALLOWED);
		    WSH_DEBUG_SV.log(l_module_name,'P_ENABLED',P_ENABLED);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
		    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
		    WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE',P_CREATION_DATE);
		    WSH_DEBUG_SV.log(l_module_name,'P_CREATED_BY',P_CREATED_BY);
		    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
		    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
		    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
		    WSH_DEBUG_SV.log(l_module_name,'L_UPDATE_ALLOWED -in Db ', L_UPDATE_ALLOWED); --5986504
		    WSH_DEBUG_SV.log(l_module_name,'L_CALLER  -Loader / Form ', P_CALLER); --5986504
		END IF;
		-- 5986504{ If Caller is Loader then Either p_update_allowed should be N or a Flip (Y -> N or N-Y)
                --           should have taken place to be Elligible for Update.
                --          If Caller is Form , then Updates are Elligible
                if ( nvl(p_caller, 'FORM') = 'LOADER'  and ( upper(p_update_allowed) = 'N'  or
                            (upper(p_update_allowed) = 'Y' and l_update_allowed = 'N')) ) OR
                   ( nvl(p_caller, 'FORM') = 'FORM' )   THEN
		     update wsh_exception_definitions_b
		     set
				exception_type 	= p_exception_type,
				default_severity 	= UPPER(p_default_severity),
				exception_handling	= UPPER(p_exception_handling),
	  			workflow_item_type	= UPPER(p_workflow_item_type),
	  			workflow_process	= UPPER(p_workflow_process),
				initiate_workflow	= UPPER(p_initiate_workflow),
				update_allowed		= UPPER(p_update_allowed),
				enabled		      = UPPER(p_enabled),
				attribute_category	=  p_attribute_category,
				attribute1		=  p_attribute1,
				attribute2		=  p_attribute2,
				attribute3		=  p_attribute3,
				attribute4		=  p_attribute4,
				attribute5		=  p_attribute5,
				attribute6		=  p_attribute6,
				attribute7		=  p_attribute7,
				attribute8		=  p_attribute8,
				attribute9		=  p_attribute9,
				attribute10		=  p_attribute10,
				attribute11		=  p_attribute11,
				attribute12		=  p_attribute12,
				attribute13		=  p_attribute13,
				attribute14		=  p_attribute14,
				attribute15		=  p_attribute15,
				creation_date		=  p_creation_date,
				created_by		=  p_created_by,
				last_update_date	=  p_last_update_date,
				last_updated_by	=  p_last_updated_by,
				last_update_login   =  p_last_update_login
			where EXCEPTION_DEFINITION_ID = p_exception_definition_id ;
			if (sql%notfound) then
				raise WSH_XC_DEF_NOT_FOUND;
			end if;

                        -- 5986504
		        IF l_debug_on THEN
		           WSH_DEBUG_SV.log(l_module_name,'After Base Table Update ... ', P_CALLER);
                        END IF;

			update WSH_EXCEPTION_DEFINITIONS_TL set
				EXCEPTION_NAME = p_exception_name,
				DESCRIPTION = p_description,
				LAST_UPDATE_DATE = p_last_update_date,
				LAST_UPDATED_BY = p_last_updated_by,
				LAST_UPDATE_LOGIN = p_last_update_login,
				SOURCE_LANG = userenv('LANG')
			where EXCEPTION_DEFINITION_ID = p_exception_definition_id
			and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

			if (sql%notfound) then
				raise WSH_XC_DEF_NOT_FOUND;
			end if;

                        -- 5986504
		        IF l_debug_on THEN
		           WSH_DEBUG_SV.log(l_module_name,'After TL Table Update ... ', P_CALLER);
                           WSH_DEBUG_SV.logmsg(l_module_name,'After Updates '||P_EXCEPTION_DEFINITION_ID,WSH_DEBUG_SV.C_EXCEP_LEVEL);
                           WSH_DEBUG_SV.logmsg(l_module_name,'After Updates '||P_CALLER,WSH_DEBUG_SV.C_EXCEP_LEVEL);
                        END IF;

                     end if;  -- 5986504	 }

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
exception

		WHEN WSH_XC_DEF_NOT_FOUND THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_DEF_NOT_FOUND');
                        IF l_debug_on THEN
		           WSH_DEBUG_SV.log(l_module_name,'- Failed in Update .. ', P_CALLER);
                        END IF;
			APP_EXCEPTION.RAISE_EXCEPTION;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_DEF_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_DEF_NOT_FOUND');
END IF;
--
end update_xc_def_form;





-- ---------------------------------------------------------------------
-- procedure: Load_Row
-- description: called by the generic loader to upload exception definition
--              This procedure should be called only by generic loader
--			 no one else should call this procedure.
-- ---------------------------------------------------------------------
procedure Load_Row (
		p_language			in VARCHAR2,
		p_source_lang			in VARCHAR2,
		p_exception_definition_id	in NUMBER,
		p_exception_name		in VARCHAR2,
		p_description			in VARCHAR2,
		p_exception_type		in VARCHAR2,
		p_default_severity  	in VARCHAR2,
		p_exception_handling	in VARCHAR2,
	  	p_workflow_item_type	in VARCHAR2,
	  	p_workflow_process   	in VARCHAR2,
		p_initiate_workflow 	in VARCHAR2,
		p_update_allowed 		in VARCHAR2,
		p_enabled 		      in VARCHAR2,
		p_attribute_category 	in VARCHAR2,
		p_attribute1			in VARCHAR2,
		p_attribute2			in VARCHAR2,
		p_attribute3			in VARCHAR2,
		p_attribute4	   		in VARCHAR2,
		p_attribute5			in VARCHAR2,
		p_attribute6	 		in VARCHAR2,
		p_attribute7			in VARCHAR2,
		p_attribute8			in VARCHAR2,
		p_attribute9			in VARCHAR2,
		p_attribute10			in VARCHAR2,
		p_attribute11	  		in VARCHAR2,
		p_attribute12	 		in VARCHAR2,
		p_attribute13			in VARCHAR2,
		p_attribute14			in VARCHAR2,
		p_attribute15	   	in VARCHAR2,
		p_creation_date 		in DATE,
 		p_created_by       	in NUMBER,
 		p_last_update_date 	in DATE,
 		p_last_updated_by  	in NUMBER,
 		p_last_update_login	in NUMBER,
                p_custom_mode       in VARCHAR2,
                p_upload_mode       in VARCHAR2


) is
--Bug 7694048: Modified the cursor C1 to read 'last_updated_by' as well.
cursor C1 (c_exception_name VARCHAR2) is
	select exception_definition_id , last_updated_by from WSH_EXCEPTION_DEFINITIONS_TL
   where EXCEPTION_NAME = c_exception_name
	and SOURCE_LANG = userenv('LANG');


-- 5986504
l_exception_definition_id NUMBER := NULL;
l_last_updated_by         NUMBER := NULL;
l_caller     VARCHAR2(30) := 'LOADER';

WSH_XC_DEF_DUP				exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOAD_ROW';
--
begin

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
	    WSH_DEBUG_SV.log(l_module_name,'P_LANGUAGE',P_LANGUAGE);
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LANG',P_SOURCE_LANG);
	    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_DEFINITION_ID',P_EXCEPTION_DEFINITION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME',P_EXCEPTION_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_DESCRIPTION',P_DESCRIPTION);
	    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_TYPE',P_EXCEPTION_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_DEFAULT_SEVERITY',P_DEFAULT_SEVERITY);
	    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_HANDLING',P_EXCEPTION_HANDLING);
	    WSH_DEBUG_SV.log(l_module_name,'P_WORKFLOW_ITEM_TYPE',P_WORKFLOW_ITEM_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_WORKFLOW_PROCESS',P_WORKFLOW_PROCESS);
	    WSH_DEBUG_SV.log(l_module_name,'P_INITIATE_WORKFLOW',P_INITIATE_WORKFLOW);
	    WSH_DEBUG_SV.log(l_module_name,'P_UPDATE_ALLOWED',P_UPDATE_ALLOWED);
	    WSH_DEBUG_SV.log(l_module_name,'P_ENABLED',P_ENABLED);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE_CATEGORY',P_ATTRIBUTE_CATEGORY);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE1',P_ATTRIBUTE1);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE2',P_ATTRIBUTE2);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE3',P_ATTRIBUTE3);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE4',P_ATTRIBUTE4);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE5',P_ATTRIBUTE5);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE6',P_ATTRIBUTE6);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE7',P_ATTRIBUTE7);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE8',P_ATTRIBUTE8);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE9',P_ATTRIBUTE9);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE10',P_ATTRIBUTE10);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE11',P_ATTRIBUTE11);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE12',P_ATTRIBUTE12);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE13',P_ATTRIBUTE13);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE14',P_ATTRIBUTE14);
	    WSH_DEBUG_SV.log(l_module_name,'P_ATTRIBUTE15',P_ATTRIBUTE15);
	    WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE',P_CREATION_DATE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CREATED_BY',P_CREATED_BY);
	    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
	    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
	    WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
            WSH_DEBUG_SV.log(l_module_name,'L_CALLER', l_caller);  -- 5986504
	END IF;
	--
	if (p_exception_name is not NULL ) then
		if (p_source_lang = userenv('LANG')) then
			open C1(p_exception_name);
			fetch C1 into l_exception_definition_id ,l_last_updated_by;
			if (C1%NOTFOUND) then
				l_exception_definition_id := p_exception_definition_id;
				insert_xc_def_form(
               		x_exception_definition_id=>l_exception_definition_id,
					p_exception_name=> p_exception_name,
					p_description=> p_description,
					p_exception_type=>p_exception_type,
					p_default_severity=>p_default_severity,
					p_exception_handling=>p_exception_handling,
	  				p_workflow_item_type=>p_workflow_item_type,
	  				p_workflow_process=>p_workflow_process,
					p_initiate_workflow=>p_initiate_workflow,
					p_update_allowed=>p_update_allowed,
					p_enabled=>p_enabled,
					p_attribute_category=>p_attribute_category,
					p_attribute1=>p_attribute1,
					p_attribute2=>p_attribute2,
					p_attribute3=>p_attribute3,
					p_attribute4=>p_attribute4,
					p_attribute5=>p_attribute5,
					p_attribute6=>p_attribute6,
					p_attribute7=>p_attribute7,
					p_attribute8=>p_attribute8,
					p_attribute9=>p_attribute9,
					p_attribute10=>p_attribute10,
					p_attribute11=>p_attribute11,
					p_attribute12=>p_attribute12,
					p_attribute13=>p_attribute13,
					p_attribute14=>p_attribute14,
					p_attribute15=>p_attribute15,
					p_creation_date=> p_creation_date,
 					p_created_by=> p_created_by,
					p_last_update_date=>p_last_update_date,
					p_last_updated_by=>p_last_updated_by,
					p_last_update_login=>p_last_update_login
				);

			else
			--	if l_exception_definition_id <> p_exception_definition_id then
				     /* update all columns except exception_definition_id */
		--			raise WSH_XC_DEF_DUP;
		--		else
                                IF (l_last_updated_by = 1 OR (p_custom_mode = 'FORCE' AND p_upload_mode ='REPLACE')) THEN
					update_xc_def_form(
						p_exception_definition_id=> l_exception_definition_id,
						p_exception_name=> p_exception_name,
						p_description=> p_description,
						p_exception_type=>p_exception_type,
						p_default_severity=>p_default_severity,
						p_exception_handling=>p_exception_handling,
	  					p_workflow_item_type=>p_workflow_item_type,
	  					p_workflow_process=>p_workflow_process,
						p_initiate_workflow=>p_initiate_workflow,
						p_update_allowed=>p_update_allowed,
						p_enabled=>p_enabled,
						p_attribute_category=>p_attribute_category,
						p_attribute1=>p_attribute1,
						p_attribute2=>p_attribute2,
						p_attribute3=>p_attribute3,
						p_attribute4=>p_attribute4,
						p_attribute5=>p_attribute5,
						p_attribute6=>p_attribute6,
						p_attribute7=>p_attribute7,
						p_attribute8=>p_attribute8,
						p_attribute9=>p_attribute9,
						p_attribute10=>p_attribute10,
						p_attribute11=>p_attribute11,
						p_attribute12=>p_attribute12,
						p_attribute13=>p_attribute13,
						p_attribute14=>p_attribute14,
						p_attribute15=>p_attribute15,
						p_creation_date=>p_creation_date,
 						p_created_by=>p_created_by,
						p_last_update_date=>p_last_update_date,
						p_last_updated_by=>p_last_updated_by,
						p_last_update_login=>p_last_update_login,
                                                p_caller=>l_caller
					);
                                END IF;
			--	end if;
			end if;
			close C1;
		end if;
	end if;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
exception

			WHEN WSH_XC_DEF_DUP THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_DEF_DUP');
			APP_EXCEPTION.RAISE_EXCEPTION;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_DEF_DUP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_DEF_DUP');
END IF;
--
end Load_Row;





-- ---------------------------------------------------------------------
-- procedure: Translate_Row
-- description: called by the generic loader to translate exception definition
--              This procedure should be called only by generic loader
--					 no one else should call this procedure.
-- ---------------------------------------------------------------------
procedure Translate_Row (
		p_exception_definition_id		in number,
		p_exception_name				in VARCHAR2,
		p_description					in VARCHAR2,
		p_owner							in VARCHAR2
) is
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRANSLATE_ROW';
--
begin
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
	    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_DEFINITION_ID',P_EXCEPTION_DEFINITION_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME',P_EXCEPTION_NAME);
	    WSH_DEBUG_SV.log(l_module_name,'P_DESCRIPTION',P_DESCRIPTION);
	    WSH_DEBUG_SV.log(l_module_name,'P_OWNER',P_OWNER);
	END IF;
	--
	if p_exception_name is not NULL then
			update WSH_EXCEPTION_DEFINITIONS_TL
			set
				EXCEPTION_NAME = p_exception_name,
				DESCRIPTION    = p_description,
				LAST_UPDATE_DATE = sysdate,
				LAST_UPDATED_BY   = decode(p_owner,'SEED',1,0),
				LAST_UPDATE_LOGIN = 0,
				SOURCE_LANG = userenv('LANG')
			where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
			and EXCEPTION_DEFINITION_ID = p_exception_definition_id;
	end if;
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
	--
end Translate_Row;


-- -------------------------------------------------------------------
-- Start of comments
-- API name			: delete_xc_def_form
--	Type				: public
--	Function			: delete exception definitions, called by form
--	Version			: Initial version 1.0
--
-- End of comments
-- ---------------------------------------------------------------------

procedure delete_xc_def_form (
		p_exception_definition_id 		IN NUMBER)
is
		WSH_XC_DEF_NOT_FOUND		exception;
		--
l_debug_on BOOLEAN;
		--
		l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_XC_DEF_FORM';
		--
begin

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
		    WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_DEFINITION_ID',P_EXCEPTION_DEFINITION_ID);
		END IF;
		--
		delete from WSH_EXCEPTION_DEFINITIONS_TL
		where EXCEPTION_DEFINITION_ID = p_exception_definition_id ;

		if (sql%notfound) then
			raise WSH_XC_DEF_NOT_FOUND;
		end if;

		delete from WSH_EXCEPTION_DEFINITIONS_B
		where EXCEPTION_DEFINITION_ID = p_exception_definition_id;

		if (sql%notfound) then
			raise WSH_XC_DEF_NOT_FOUND;
		end if;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
	exception

		WHEN WSH_XC_DEF_NOT_FOUND THEN
			FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_DEF_NOT_FOUND');
			APP_EXCEPTION.RAISE_EXCEPTION;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_DEF_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_DEF_NOT_FOUND');
END IF;
--
end delete_xc_def_form ;


-- ---------------------------------------------------------------------
-- procedure: Add_Language
-- description: called by the loader script
--
--
-- ---------------------------------------------------------------------
procedure ADD_LANGUAGE
is
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_LANGUAGE';
--
begin
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
  END IF;
  --
  delete from WSH_EXCEPTION_DEFINITIONS_TL T
  where not exists
    (select to_char(NULL)
    from WSH_EXCEPTION_DEFINITIONS_B B
    where B.EXCEPTION_DEFINITION_ID = T.EXCEPTION_DEFINITION_ID
    );

  update WSH_EXCEPTION_DEFINITIONS_TL T set (
      EXCEPTION_NAME,
      DESCRIPTION
    ) = (select
      B.EXCEPTION_NAME,
      B.DESCRIPTION
    from WSH_EXCEPTION_DEFINITIONS_TL B
    where B.EXCEPTION_DEFINITION_ID = T.EXCEPTION_DEFINITION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXCEPTION_DEFINITION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXCEPTION_DEFINITION_ID,
      SUBT.LANGUAGE
    from WSH_EXCEPTION_DEFINITIONS_TL SUBB, WSH_EXCEPTION_DEFINITIONS_TL SUBT
    where SUBB.EXCEPTION_DEFINITION_ID = SUBT.EXCEPTION_DEFINITION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.EXCEPTION_NAME <> SUBT.EXCEPTION_NAME
      or (SUBB.EXCEPTION_NAME is null and SUBT.EXCEPTION_NAME is not null)
      or (SUBB.EXCEPTION_NAME is not null and SUBT.EXCEPTION_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into WSH_EXCEPTION_DEFINITIONS_TL (
    EXCEPTION_DEFINITION_ID,
    EXCEPTION_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.EXCEPTION_DEFINITION_ID,
    B.EXCEPTION_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WSH_EXCEPTION_DEFINITIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select to_char(NULL)
    from WSH_EXCEPTION_DEFINITIONS_TL T
    where T.EXCEPTION_DEFINITION_ID = B.EXCEPTION_DEFINITION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
end ADD_LANGUAGE;


-- ---------------------------------------------------------------------
-- function: Get_Lookup_Meaning
-- description: called by the view WSH_EXCEPTIONS_V to get meaning
-- for EXCEPTION_SEVERITY and LOGGING_ENTITY
--
-- return: meaning
-- ---------------------------------------------------------------------
function Get_Lookup_Meaning(
	p_lookup_code IN VARCHAR2,
	p_lookup_type IN VARCHAR2 ) return VARCHAR2
is

	CURSOR C1(c_lookup_code VARCHAR2, c_lookup_type VARCHAR2)  is
		select meaning from fnd_lookup_values_vl
		where lookup_code = c_lookup_code and
		 	 lookup_type = c_lookup_type;

	l_lookup_meaning VARCHAR2(80) := NULL;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_LOOKUP_MEANING';
--
begin
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
	    WSH_DEBUG_SV.log(l_module_name,'P_LOOKUP_CODE',P_LOOKUP_CODE);
	    WSH_DEBUG_SV.log(l_module_name,'P_LOOKUP_TYPE',P_LOOKUP_TYPE);
	END IF;
	--
	if p_lookup_code is NULL or p_lookup_type is NULL then
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		--
		return NULL;
	else
	    	open C1(p_lookup_code, p_lookup_type);
	    	fetch C1 into l_lookup_meaning;
	    	if (C1%NOTFOUND) then
		  		close C1;
		  		--
		  		-- Debug Statements
		  		--
		  		IF l_debug_on THEN
		  		    WSH_DEBUG_SV.pop(l_module_name);
		  		END IF;
		  		--
		  		return NULL;
	    	else
		  		close C1;
	       	--
	       	-- Debug Statements
	       	--
	       	IF l_debug_on THEN
	       	    WSH_DEBUG_SV.pop(l_module_name);
	       	END IF;
	       	--
	       	return l_lookup_meaning;
	    	end if;
   end if;
end Get_Lookup_Meaning;


/*-- --------------------------------------------------------------------------
-- Procedure:  Purge
-- Description:  This procedure will purge the exception data based on the
--               given input criteria
-- --------------------------------------------------------------------------
    -- Purpose
   --  Purge the WSH_EXCEPIONS table based on input criteria
   --
   --   Input Parameters
   --   p_api_version
   --      API version number (current version is 1.0)
   --   p_init_msg_list (optional, default FND_API.G_FALSE)
   --          Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
   --                           if set to FND_API.G_TRUE
   --                                   initialize error message list
   --                           if set to FND_API.G_FALSE - not initialize error
   --                                   message list
   --   p_commit (optional, default FND_API.G_FALSE)
   --           whether or not to commit the changes to database
   --
   -- Input parameters for purging the data
   --     See the API for more information
   -- Input parameters for purging the data
   --     See the API for more information
   --         p_action (optional):
   --            NULL:    do nothing
   --           'PURGE': delete closed exceptions
   --           'CLOSED': set all exceptions' status to Closed.
   --           C_ACTION_SEMICLOSED: internal use only -- close all but
   --                                Information Only exceptions.
   --                           When this action is used, only the entity ID
   --                           can be passed.
   --                           Added to resolve bug 4318747 for ITM exceptions
   --                           Frontported by bug 4370532
   --
   -- Output Parameters
   --   x_return_status
   --       if the process succeeds, the value is
   --           fnd_api.g_ret_sts_success;
   --       if there is an expected error, the value is
   --           fnd_api.g_ret_sts_error;
   --       if there is an unexpected error, the value is
   --           fnd_api.g_ret_sts_unexp_error;
   --   x_msg_count
   --       if there is one or more errors, the number of error messages
   --           in the buffer
   --   x_msg_data
   --       if there is one and only one error, the error message
   --   (See fnd_api package for more details about the above output parameters)
   --   x_no_of_records  - Number of Records Deleted
   --*/

PROCEDURE Purge
          (p_api_version            IN     NUMBER,
           p_init_msg_list          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
           p_commit                 IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
           p_validation_level       IN     NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
           x_return_status          OUT NOCOPY     VARCHAR2,
           x_msg_count              OUT NOCOPY     NUMBER,
           x_msg_data               OUT NOCOPY     VARCHAR2,
           p_request_id             IN     NUMBER  DEFAULT NULL ,
           p_exception_name         IN     VARCHAR2 DEFAULT NULL,
           p_logging_entity         IN     VARCHAR2  DEFAULT NULL,
           p_exception_location_id  IN     NUMBER   DEFAULT NULL,
           p_logged_at_location_id  IN     NUMBER DEFAULT NULL ,
           p_inventory_org_id       IN     NUMBER DEFAULT NULL,
           p_exception_type         IN     VARCHAR2 DEFAULT NULL,
           p_severity               IN     VARCHAR2 DEFAULT NULL,
           p_status                 IN     VARCHAR2  DEFAULT NULL,
           p_arrival_date_from      IN     DATE     DEFAULT NULL,
           p_arrival_date_to        IN     DATE    DEFAULT NULL,
           p_departure_date_from    IN     DATE   DEFAULT NULL,
           p_departure_date_to      IN     DATE  DEFAULT NULL,
           p_creation_date_from     IN     DATE DEFAULT NULL,
           p_creation_date_to       IN     DATE   DEFAULT NULL,
	   p_data_older_no_of_days  IN     NUMBER  DEFAULT NULL,
	   x_no_of_recs_purged      OUT NOCOPY     NUMBER,
           p_delivery_id            IN     NUMBER DEFAULT NULL,
           p_trip_id                IN     NUMBER DEFAULT NULL,
           p_trip_stop_id           IN     NUMBER DEFAULT NULL,
           p_delivery_detail_id     IN     NUMBER DEFAULT NULL,
           p_delivery_contents      IN     VARCHAR2 DEFAULT 'Y',
           p_action                 IN     VARCHAR2  DEFAULT NULL
          )
IS
   l_no_of_records   NUMBER ;
   l_api_name        CONSTANT VARCHAR2(30)      := 'Purge';
   l_api_version     number := 1.0;
   l_msg_summary     VARCHAR2(2000) := NULL;
   l_msg_details     VARCHAR2(4000) := NULL;
   WSH_PURGE_FAILED  EXCEPTION;


  /*CURSOR c_exceptions IS
  select we.rowid
  from wsh_exceptions we
  where
      nvl(we.request_id,-999) = nvl(p_request_id , nvl(we.request_id,-999))
  and nvl(we.exception_name,'XXX') = nvl(p_exception_name, nvl(we.exception_name,'XXX'))
  and we.logging_entity = nvl(p_logging_entity, we.logging_entity )
  and we.logged_at_location_id = nvl(p_logged_at_location_id , we.logged_at_location_id )
  and we.exception_location_id = nvl(p_exception_location_id , we.exception_location_id )
  and we.severity = nvl(p_severity, we.severity)
-- If Action=PURGE  , Choose Recs. with Status=CLOSED
-- If Action=CLOSED , if p_status is NULL, then Choose Recs. with Status<>CLOSED
-- If Action=CLOSED , if p_status is NOT NULL, then Choose Recs. with p_status<>CLOSED and p_status = Status
  and ( ( p_action = 'PURGE' AND we.status = 'CLOSED' ) OR
        ( p_action = 'CLOSED' AND ( ( p_status IS NULL and we.status <> 'CLOSED' ) OR
                                    ( p_status IS NOT NULL and p_status <> 'CLOSED' and we.status = p_status )
                                  )
        )
      )
  and to_char(we.creation_date,'YYYY/MM/DD')  BETWEEN
         nvl(TO_CHAR(p_creation_date_from,'YYYY/MM/DD') ,  to_char(we.creation_date,'YYYY/MM/DD') )
         and  nvl(TO_CHAR(p_creation_date_to,'YYYY/MM/DD') ,  to_char(we.creation_date,'YYYY/MM/DD') )
  and to_char(nvl(we.arrival_date,sysdate),'YYYY/MM/DD')  BETWEEN
         nvl(TO_CHAR(nvl(p_arrival_date_from,nvl(we.arrival_date,sysdate)),'YYYY/MM/DD') ,
            to_char(nvl(we.arrival_date,sysdate),'YYYY/MM/DD') )
        and  nvl(TO_CHAR(nvl(p_arrival_date_to,nvl(we.arrival_date,sysdate)),'YYYY/MM/DD') ,
             to_char(nvl(we.arrival_date,sysdate),'YYYY/MM/DD') )
  and to_char(nvl(we.departure_date,sysdate),'YYYY/MM/DD')  BETWEEN
         nvl(TO_CHAR(nvl(p_departure_date_from,nvl(we.departure_date,sysdate)),'YYYY/MM/DD') ,
             to_char(nvl(we.departure_date,sysdate),'YYYY/MM/DD') )
        and  nvl(TO_CHAR(nvl(p_departure_date_to,nvl(we.departure_date,sysdate)),'YYYY/MM/DD') ,
             to_char(nvl(we.departure_date,sysdate),'YYYY/MM/DD') )
  and (sysdate - we.creation_date) > nvl(p_data_older_no_of_days,(sysdate - we.creation_date - 1))
  and (   (we.delivery_detail_id in (select distinct a.delivery_detail_id
                                  from wsh_delivery_assignments_v a, wsh_exceptions b
                                  where  a.delivery_detail_id=b.delivery_detail_id
                                  and    a.delivery_id=p_delivery_id)
           AND p_delivery_id is not null
           AND p_delivery_contents = 'Y')
       /*OR (we.container_name in (select distinct a.container_name --LPN Synch Up..samanna
                              from wsh_delivery_details a, wsh_delivery_assignments_v b
                              where  a.delivery_detail_id = b.delivery_detail_id
                              and    a.container_flag = 'Y'
                              and    b.delivery_id=p_delivery_id)
           AND p_delivery_id is not null
           AND p_delivery_contents = 'Y')
       OR nvl(we.delivery_id,-999) = nvl(p_delivery_id, nvl(we.delivery_id,-999))
      )
   and nvl(we.trip_id,-999) = nvl(p_trip_id, nvl(we.trip_id,-999))
   and nvl(we.trip_stop_id,-999) = nvl(p_trip_stop_id, nvl(we.trip_stop_id,-999))
   and nvl(we.delivery_detail_id,-999) = nvl(p_delivery_detail_id, nvl(we.delivery_detail_id,-999))
 ;*/


  TYPE TableOfROWID is TABLE of ROWID INDEX BY BINARY_INTEGER;

  RowIdList  TableOfROWID;


  Exceptions_SQL	VARCHAR2(32000) := NULL;
  Temp_SQL		VARCHAR2(300)  := NULL;
  c_exceptions		WSH_UTIL_CORE.RefCurType;
  bind_col_tab		WSH_UTIL_CORE.tbl_varchar;

  --Bug 5943326 Variables for bulk purge
  BulkBatchSize  Number := 1000;

  c_cfetch number;
  c_pfetch number;
  l_count number := 0;
  l_use_dynamic varchar2(1);  -- Bug 3582688
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE';
--
begin
  -- Standard Start of API savepoint
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME',P_EXCEPTION_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY',P_LOGGING_ENTITY);
      WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_LOCATION_ID',P_EXCEPTION_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LOGGED_AT_LOCATION_ID',P_LOGGED_AT_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ORG_ID',P_INVENTORY_ORG_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_TYPE',P_EXCEPTION_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_SEVERITY',P_SEVERITY);
      WSH_DEBUG_SV.log(l_module_name,'P_STATUS',P_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_ARRIVAL_DATE_FROM',P_ARRIVAL_DATE_FROM);
      WSH_DEBUG_SV.log(l_module_name,'P_ARRIVAL_DATE_TO',P_ARRIVAL_DATE_TO);
      WSH_DEBUG_SV.log(l_module_name,'P_DEPARTURE_DATE_FROM',P_DEPARTURE_DATE_FROM);
      WSH_DEBUG_SV.log(l_module_name,'P_DEPARTURE_DATE_TO',P_DEPARTURE_DATE_TO);
      WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE_FROM',P_CREATION_DATE_FROM);
      WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE_TO',P_CREATION_DATE_TO);
      WSH_DEBUG_SV.log(l_module_name,'P_DATA_OLDER_NO_OF_DAYS',P_DATA_OLDER_NO_OF_DAYS);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_ID',P_TRIP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_TRIP_STOP_ID',P_TRIP_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
  END IF;
  --
  SAVEPOINT  WSH_XC_UTIL;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version   ,
								   p_api_version   ,
							           l_api_name      ,
							          G_PKG_NAME )
  THEN
     FND_MESSAGE.SET_NAME('WSH', 'WSH_INCOMPATIBLE_API_CALL');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
   -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Bug#3582688: Purge API is also called for closing exceptions (during ship confirm)
  --  for a trip or trip stop or delivery or delivery detail. We should be using static
  --  SQLs in this case since dynamic sql has performance issue if executed multiple
  --  times.

  l_use_dynamic := 'Y';
  IF p_action IN ('CLOSED', C_ACTION_SEMICLOSED) THEN --{ case where purge is called only with entity_id
      IF (p_request_id is NULL and
         p_exception_name is NULL and
         p_logging_entity  is NULL and
         p_exception_location_id  is NULL and
         p_logged_at_location_id  is NULL and
         p_inventory_org_id  is NULL and
         p_exception_type  is NULL and
         p_severity  is NULL and
         p_status is NULL and
         p_arrival_date_from is NULL and
         p_arrival_date_to is NULL and
         p_departure_date_from  is NULL and
         p_departure_date_to is NULL and
         p_creation_date_from   is NULL and
         p_creation_date_to is NULL and
         p_data_older_no_of_days is NULL)  THEN  --{ check for common NULL paramaters

	   IF p_trip_id IS NOT NULL and
           (p_delivery_id is NULL and
            p_trip_stop_id  is NULL and
            p_delivery_detail_id is NULL)    THEN -- { Close for ONLY entity passed

                l_use_dynamic := 'N';
                -- FP bug 4370532: this is the only context where
                -- action C_ACTION_SEMICLOSED can be used.
	        IF (p_action = C_ACTION_SEMICLOSED)  THEN
  		  UPDATE  WSH_EXCEPTIONS
	          SET    status= 'CLOSED',
		         last_update_date = sysdate,
	                 last_updated_by  = FND_GLOBAL.USER_ID,
		         last_update_login = FND_GLOBAL.USER_ID
		  WHERE   trip_id = p_trip_id
		  AND	status <> 'CLOSED'
                  AND   severity <> 'INFO';
                ELSE
   		  UPDATE  WSH_EXCEPTIONS
	          SET    status= 'CLOSED',
		         last_update_date = sysdate,
	                 last_updated_by  = FND_GLOBAL.USER_ID,
		         last_update_login = FND_GLOBAL.USER_ID
		  WHERE   trip_id = p_trip_id
		  AND	status <> 'CLOSED';
                END IF;
                l_count := SQL%rowcount;

	   ELSIF p_trip_stop_id IS NOT NULL and
           (p_delivery_id is NULL and
           p_trip_id  is NULL and
           p_delivery_detail_id  is NULL) THEN

                l_use_dynamic := 'N';
                -- FP bug 4370532: this is the only context where
                -- action C_ACTION_SEMICLOSED can be used.
	        IF (p_action = C_ACTION_SEMICLOSED)  THEN
  		  UPDATE	WSH_EXCEPTIONS
	          SET    status='CLOSED',
		       last_update_date = sysdate,
	               last_updated_by  = FND_GLOBAL.USER_ID,
		       last_update_login = FND_GLOBAL.USER_ID
		  WHERE   trip_stop_id = p_trip_stop_id
		  AND	status <> 'CLOSED'
                  AND   severity <> 'INFO';
                ELSE
  		  UPDATE	WSH_EXCEPTIONS
	          SET    status='CLOSED',
		       last_update_date = sysdate,
	               last_updated_by  = FND_GLOBAL.USER_ID,
		       last_update_login = FND_GLOBAL.USER_ID
		  WHERE   trip_stop_id = p_trip_stop_id
		  AND	status <> 'CLOSED';

                END IF;
                l_count := SQL%rowcount;

	   ELSIF p_delivery_id IS NOT NULL  and
           (p_trip_id  is NULL and
           p_trip_stop_id  is NULL and
           p_delivery_detail_id is NULL)  THEN

              l_use_dynamic := 'N';
	      IF p_delivery_contents = 'Y' THEN
                -- FP bug 4370532: this is the only context where
                -- action C_ACTION_SEMICLOSED can be used.
                IF (p_action = C_ACTION_SEMICLOSED) THEN
                    -- performance bug 5257207: SC-11: split UPDATE to reduce
                    -- the total number of queries on WSH_EXCEPTIONS.
                    --
                    -- This code is part of the ship confirm flow.

  		    UPDATE	WSH_EXCEPTIONS
	            SET    status            = C_STATUS_CLOSED,
		           last_update_date  = sysdate,
	                   last_updated_by   = FND_GLOBAL.USER_ID,
		           last_update_login = FND_GLOBAL.USER_ID
	            WHERE delivery_detail_id IN
                                (SELECT wda.delivery_detail_id
			         FROM   wsh_delivery_assignments wda
			         WHERE  wda.delivery_id = p_delivery_id)
                    AND   status             <> C_STATUS_CLOSED
                    AND   severity           <> C_SEVERITY_INFO;

                    l_count := SQL%rowcount;

  		    UPDATE	WSH_EXCEPTIONS
	            SET    status            = C_STATUS_CLOSED,
		           last_update_date  = sysdate,
	                   last_updated_by   = FND_GLOBAL.USER_ID,
		           last_update_login = FND_GLOBAL.USER_ID
	            WHERE delivery_id =  p_delivery_id
                    AND   status      <> C_STATUS_CLOSED
                    AND   severity    <> C_SEVERITY_INFO;

                    l_count := l_count + SQL%rowcount;

                ELSE
                    -- UPDATES are tuned the same way as above.
  		    UPDATE	WSH_EXCEPTIONS
	            SET    status            = p_action,
		           last_update_date  = sysdate,
	                   last_updated_by   = FND_GLOBAL.USER_ID,
		           last_update_login = FND_GLOBAL.USER_ID
	            WHERE delivery_detail_id IN
                                (SELECT wda.delivery_detail_id
			         FROM   wsh_delivery_assignments wda
			         WHERE  wda.delivery_id = p_delivery_id)
                    AND   status             <> C_STATUS_CLOSED;

                    l_count := SQL%rowcount;

  		    UPDATE	WSH_EXCEPTIONS
	            SET    status            = p_action,
		           last_update_date  = sysdate,
	                   last_updated_by   = FND_GLOBAL.USER_ID,
		           last_update_login = FND_GLOBAL.USER_ID
	            WHERE delivery_id =  p_delivery_id
                    AND   status      <> C_STATUS_CLOSED;

                    l_count := l_count + SQL%rowcount;

                END IF;
	      ELSE
                -- p_delivery_contents is 'N' here.

                -- bug 4318747: this is the only context where
                -- action C_ACTION_SEMICLOSED can be used.
	        IF (p_action = C_ACTION_SEMICLOSED)  THEN
	          UPDATE	WSH_EXCEPTIONS
	          SET    status='CLOSED',
		       last_update_date = sysdate,
	               last_updated_by  = FND_GLOBAL.USER_ID,
		       last_update_login = FND_GLOBAL.USER_ID
		  WHERE   delivery_id = p_delivery_id
		  AND	status <> 'CLOSED'
                  AND   severity <> 'INFO'
                  --AND   exception_name <> 'WSH_OTM_SHIPMENT_ERROR'; -- OTM R12 glog project;
                  AND   exception_name <> C_OTM_EXC_NAME; -- OTM R12 glog project;
                ELSE
	          UPDATE	WSH_EXCEPTIONS
	          SET    status='CLOSED',
		       last_update_date = sysdate,
	               last_updated_by  = FND_GLOBAL.USER_ID,
		       last_update_login = FND_GLOBAL.USER_ID
		  WHERE   delivery_id = p_delivery_id
		  AND	status <> 'CLOSED'
                  --AND   exception_name <> 'WSH_OTM_SHIPMENT_ERROR'; -- OTM R12 glog project;
                  AND   exception_name <> C_OTM_EXC_NAME; -- OTM R12 glog project;
                END IF;
                l_count := SQL%rowcount;
	      END IF;

	  ELSIF p_delivery_detail_id IS NOT NULL  and
          (p_trip_id  is NULL and
           p_trip_stop_id  is NULL and
           p_delivery_id is NULL)  THEN

                l_use_dynamic := 'N';
		UPDATE	WSH_EXCEPTIONS
	        SET    status=p_action ,
		       last_update_date = sysdate,
	               last_updated_by  = FND_GLOBAL.USER_ID,
		       last_update_login = FND_GLOBAL.USER_ID
		WHERE   delivery_detail_id = p_delivery_detail_id
		AND	status <> 'CLOSED';
                l_count := SQL%rowcount;

	END IF; -- }  Close when ONLY the entity is passed
     END IF; ---}  check for common NULL parameters
  END IF; --} p_action = CLOSED, C_ACTION_SEMICLOSED

  IF l_use_dynamic = 'Y' THEN -- Dynamic cusrsor required
   --{
	-- Bug#3200314: Constructing the Dynamic Cursor.
	Exceptions_SQL := Exceptions_SQL || 'SELECT WE.ROWID';
	Exceptions_SQL := Exceptions_SQL || ' FROM WSH_EXCEPTIONS WE';
	Exceptions_SQL := Exceptions_SQL || ' WHERE';
	IF p_request_id IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.REQUEST_ID = :p_request_id AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_request_id);
	END IF;
        IF p_exception_name IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.EXCEPTION_NAME = :p_exception_name AND';
		bind_col_tab(bind_col_tab.COUNT+1) := p_exception_name;
	END IF;
	IF p_logging_entity IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.LOGGING_ENTITY = :p_logging_entity AND';
		bind_col_tab(bind_col_tab.COUNT+1) := p_logging_entity;
	END IF;
	IF p_logged_at_location_id IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.LOGGED_AT_LOCATION_ID = :p_logged_at_location_id AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_logged_at_location_id);
	END IF;
	IF p_exception_location_id IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.EXCEPTION_LOCATION_ID = :p_exception_location_id AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_exception_location_id);
	END IF;
	IF p_severity IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.SEVERITY = :p_severity AND';
		bind_col_tab(bind_col_tab.COUNT+1) := p_severity;
	END IF;

	-- If Action=PURGE  , Choose Recs. with Status=CLOSED
	-- If Action=CLOSED , if p_status is NULL, then Choose Recs. with Status<>CLOSED
	-- If Action=CLOSED , if p_status is NOT NULL, then Choose Recs. with p_status<>CLOSED and p_status = Status

       IF p_action = 'PURGE' THEN
           Exceptions_SQL := Exceptions_SQL || ' we.status = ''CLOSED'' AND';
       ELSIF p_action = 'CLOSED' THEN
          IF p_status IS NULL THEN
                Exceptions_SQL := Exceptions_SQL || ' we.status <> ''CLOSED'' AND';
          ELSIF p_status <> 'CLOSED' THEN
                Exceptions_SQL := Exceptions_SQL || ' we.status = :p_status AND';
                bind_col_tab(bind_col_tab.COUNT+1) := p_status;
          END IF;
      END IF;
        --Bug 7153170:Modified logic so that the index on the column creation_date is picked up
	IF p_creation_date_from IS NOT NULL OR p_creation_date_to IS NOT NULL THEN
                IF p_creation_date_from IS NOT NULL THEN
                   Exceptions_SQL := Exceptions_SQL || ' we.creation_date BETWEEN';
                   Exceptions_SQL := Exceptions_SQL || ' fnd_date.canonical_to_date(:p_creation_date_from) AND ';
		   IF p_creation_date_to IS NOT NULL THEN
                      Exceptions_SQL := Exceptions_SQL || ' fnd_date.canonical_to_date(:p_creation_date_to) AND ';
                      bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_creation_date_from, 'YYYY/MM/DD');
                      bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_creation_date_to, 'YYYY/MM/DD');
                   ELSE
                      Exceptions_SQL := Exceptions_SQL || ' sysdate AND ';
                      bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_creation_date_from, 'YYYY/MM/DD');
                   END IF;
                ELSE
                   Exceptions_SQL := Exceptions_SQL || '  we.creation_date < fnd_date.canonical_to_date(:p_creation_date_to) AND ';
                   bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_creation_date_to, 'YYYY/MM/DD');
                END IF;
          --End of modifications for bug 7153170
	END IF;

	IF p_arrival_date_from IS NOT NULL OR p_arrival_date_to IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' to_char(nvl(we.arrival_date,SYSDATE),''YYYY/MM/DD'') BETWEEN';
		Exceptions_SQL := Exceptions_SQL || ' NVL(:p_arrival_date_from, to_char(nvl(we.arrival_date,SYSDATE),''YYYY/MM/DD'') )';
		Exceptions_SQL := Exceptions_SQL || ' AND NVL(:p_arrival_date_to, to_char(nvl(we.arrival_date,SYSDATE),''YYYY/MM/DD'') ) AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_arrival_date_from,'YYYY/MM/DD');
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_arrival_date_to,'YYYY/MM/DD');
	END IF;

        IF p_departure_date_from IS NOT NULL OR p_departure_date_to IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' to_char(nvl(we.departure_date,SYSDATE),''YYYY/MM/DD'') BETWEEN';
		Exceptions_SQL := Exceptions_SQL || ' NVL(:p_departure_date_from, to_char(nvl(we.departure_date,SYSDATE),''YYYY/MM/DD'') )';
		Exceptions_SQL := Exceptions_SQL || ' AND NVL(:p_departure_date_to, to_char(nvl(we.departure_date,SYSDATE),''YYYY/MM/DD'') ) AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_departure_date_from,'YYYY/MM/DD');
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_departure_date_to,'YYYY/MM/DD');
	END IF;

	IF p_data_older_no_of_days IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' (SYSDATE - :p_data_older_no_of_days ) > we.creation_date AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_data_older_no_of_days);
	END IF;

	IF p_delivery_id IS NOT NULL THEN
	    IF p_delivery_contents = 'Y' THEN
    		  Temp_SQL       :=		' SELECT ROWID';
		  Temp_SQL       := Temp_SQL || ' FROM WSH_EXCEPTIONS';
		  Temp_SQL       := Temp_SQL || ' WHERE';
	    	  Exceptions_SQL := Exceptions_SQL || ' WE.ROWID IN (';
    		  Exceptions_SQL := Exceptions_SQL || Temp_SQL;
		  Exceptions_SQL := Exceptions_SQL ||     ' DELIVERY_DETAIL_ID IN';
		  Exceptions_SQL := Exceptions_SQL ||        ' (SELECT DISTINCT a.delivery_detail_id';
		  Exceptions_SQL := Exceptions_SQL ||         ' FROM wsh_delivery_assignments_v a, wsh_exceptions b';
		  Exceptions_SQL := Exceptions_SQL || 	      ' WHERE  a.delivery_detail_id=b.delivery_detail_id';
		  Exceptions_SQL := Exceptions_SQL || 	      ' AND    a.delivery_id= :p_delivery_id)';
		  Exceptions_SQL := Exceptions_SQL ||     ' UNION ALL';
		  bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_delivery_id);
	  	  /*Exceptions_SQL := Exceptions_SQL || Temp_SQL;
		  Exceptions_SQL := Exceptions_SQL ||     ' CONTAINER_NAME IN';
		  Exceptions_SQL := Exceptions_SQL || 	     ' (SELECT DISTINCT a.container_name';
		  Exceptions_SQL := Exceptions_SQL ||         ' FROM wsh_delivery_details a, wsh_delivery_assignments_v b';
		  Exceptions_SQL := Exceptions_SQL || 	      ' WHERE  a.delivery_detail_id=b.delivery_detail_id';
		  Exceptions_SQL := Exceptions_SQL || 	      ' AND    a.container_flag = ''Y''';
		  Exceptions_SQL := Exceptions_SQL || 	      ' AND    b.delivery_id= :p_delivery_id)';
		  Exceptions_SQL := Exceptions_SQL ||     ' UNION ALL';
		  bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_delivery_id);*/
	     	  Exceptions_SQL := Exceptions_SQL || Temp_SQL;
	    	  Exceptions_SQL := Exceptions_SQL ||     ' delivery_id = :p_delivery_id ) AND';
	  	  bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_delivery_id);
	    ELSE
		  Exceptions_SQL := Exceptions_SQL ||     ' WE.delivery_id = :p_delivery_id AND';
                  -- OTM R12 glog project
                  -- Purge only looks for closed exceptions
                  -- so only for close action, filter out this exception name
                  IF p_action = 'CLOSED' THEN
                    --Exceptions_SQL := Exceptions_SQL ||' WE.exception_name <> ''WSH_OTM_SHIPMENT_ERROR'' AND';
                    Exceptions_SQL := Exceptions_SQL ||' WE.exception_name <> '''|| C_OTM_EXC_NAME ||''' AND';
                  END IF;
                  -- OTM R12 end of glog project
	      	  bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_delivery_id);
	    END IF;
	END IF;

	IF p_trip_id IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.TRIP_ID = :p_trip_id AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_trip_id);
	END IF;
	IF p_trip_stop_id IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.TRIP_STOP_ID = :p_trip_stop_id AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_trip_stop_id);
	END IF;
	IF p_delivery_detail_id IS NOT NULL THEN
		Exceptions_SQL := Exceptions_SQL || ' WE.DELIVERY_DETAIL_ID = :p_delivery_detail_id AND';
		bind_col_tab(bind_col_tab.COUNT+1) := TO_CHAR(p_delivery_detail_id);
	END IF;

	-- Bug#3200314
	-- Process the records based on  the input criteria.
	Exceptions_SQL := Exceptions_SQL ||' 1=1';
	WSH_UTIL_CORE.OpenDynamicCursor(c_exceptions, Exceptions_SQL, bind_col_tab);

	-- Bug 3576661 : TST11510.10: ERROR IN SHIP CONFIRM DELIVERY CANNOT BE SHIP CONFIRMED
	-- Dynamic SQL cannot be used with Bulk Features in pre 9i environments
	-- Either of these can be used, so using Variable Cursor as of now but not
	-- using Bulk Collect feature while fetching the record

        -- bug 5943326 added c_cpfetch and c_pfetch
        c_cfetch := 0;
        c_pfetch := 0;
	l_count := 0;
        IF p_action IN ('PURGE','CLOSED') THEN --{ Closed and purge
        -- bug 5943326 using BULK PURGE
         LOOP
	 /*  FETCH c_exceptions INTO RowIdList(l_count+1) ;
	   EXIT  WHEN (c_exceptions%NOTFOUND);
 	   l_count := l_count+1;
         END LOOP;
         CLOSE c_exceptions;*/
         FETCH c_exceptions BULK COLLECT
           INTO RowIdList LIMIT  BulkBatchSize;
         c_cfetch := c_exceptions%rowcount - c_pfetch;
         EXIT WHEN (c_cfetch=0);
        IF p_action='PURGE' THEN
         FORALL l_counter IN 1..c_cfetch
         DELETE from WSH_EXCEPTIONS where rowid = RowIdList(l_counter);
        ELSE -- 'CLOSED'
         FORALL l_counter IN 1..c_cfetch
         UPDATE WSH_EXCEPTIONS
         SET    status=p_action ,
                last_update_date = sysdate,
                last_updated_by  = FND_GLOBAL.USER_ID,
                last_update_login = FND_GLOBAL.USER_ID
         WHERE  rowid = RowIdList(l_counter);
       END IF;

       --IF (l_count > 0) THEN
         IF SQL%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('WSH', 'WSH_PURGE_FAILED');
           FND_MSG_PUB.ADD;
           RAISE WSH_PURGE_FAILED;
         END IF;

        --END IF;

        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;
        c_pfetch := c_exceptions%rowcount;
        l_count := c_pfetch;
      END LOOP;
      CLOSE c_exceptions;
      END IF; --} End of Closed and Purge
  END IF;  --}  Dynamic cursor required
  IF l_count > 0 THEN
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
  END IF;
  x_no_of_recs_purged  := l_count;

  --
  -- Debug Statements
  --
     IF l_debug_on THEN
	   WSH_DEBUG_SV.log(l_module_name,'Count',x_no_of_recs_purged);
	   WSH_DEBUG_SV.pop(l_module_name);
     END IF;
  --
EXCEPTION
   WHEN WSH_PURGE_FAILED  THEN
     ROLLBACK TO WSH_XC_UTIL;
     x_return_status := FND_API.G_RET_STS_ERROR;
     WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
     if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
     else
         x_msg_data := l_msg_summary;
     end if;
     x_msg_data := nvl(x_msg_data,sqlerrm);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_PURGE_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_PURGE_FAILED');
     END IF;
     --
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO WSH_XC_UTIL;
     x_return_status := FND_API.G_RET_STS_ERROR;
     WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
     if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
     else
         x_msg_data := l_msg_summary;
     end if;
     x_msg_data := nvl(x_msg_data,sqlerrm);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO WSH_XC_UTIL;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
     if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
     else
         x_msg_data := l_msg_summary;
     end if;
     x_msg_data := nvl(x_msg_data,sqlerrm);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
     END IF;
     --
   WHEN OTHERS THEN
     ROLLBACK TO WSH_XC_UTIL;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WSH_UTIL_CORE.get_messages('N', l_msg_summary, l_msg_details, x_msg_count);
     if x_msg_count > 1 then
         x_msg_data := l_msg_summary || l_msg_details;
     else
         x_msg_data := l_msg_summary;
     end if;
     x_msg_data := nvl(x_msg_data,sqlerrm);
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     --
end;



-- -------------------------------------------------------------------------------
-- Start of comments
-- API name  : Check_exceptions
-- Type      : Public
-- Function  : This procedure takes input as Entity Name and Entity Id
--             and finds the maximum severity exception logged against it.
--             Only Error and Warning Exceptions are considered, Information Only
--             are not considered.
--             If p_consider_content is set to 'Y', then the API also looks
--             at the contents of the Entity and checks for the maximum severity
--             against each child entity. This is drilled to lowest child entity.
--             The API returns a PL/SQL table of records with Entity Name, Entity ID
--             Exception Behavior. The table is populated with the Top Most entity
--             followed by its child entities (if exceptions exist against them) in
--             a hierarchial tree structure.
--             Valid Values for p_logging_entity_name : LINE, CONTAINER, DELIVERY,
--             TRIP, STOP
-- End of comments
-- --------------------------------------------------------------------------------

PROCEDURE Check_Exceptions (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_return_status         OUT  NOCOPY    VARCHAR2,
        x_msg_count             OUT  NOCOPY    NUMBER,
        x_msg_data              OUT  NOCOPY    VARCHAR2,

        -- program specific parameters
        p_logging_entity_id	  IN 	NUMBER,
        p_logging_entity_name	  IN	VARCHAR2,
        p_consider_content      IN  VARCHAR2,

         -- program specific out parameters
        x_exceptions_tab	IN OUT NOCOPY 	XC_TAB_TYPE,
        p_caller                IN      VARCHAR2
	) IS

  CURSOR Get_Trip_Exceptions (v_trip_id NUMBER) IS
  SELECT DECODE(severity,'HIGH','ERROR','MEDIUM','WARNING',severity)
  FROM   wsh_exceptions
  WHERE  trip_id = v_trip_id
  AND    status in ('OPEN','ERROR','LOGGED','IN_PROCESS','MANUAL')
  AND    severity in ('HIGH','MEDIUM','ERROR','WARNING')
  ORDER BY decode(severity,'HIGH',1,'ERROR',1,'MEDIUM',2,'WARNING',2,3);

  CURSOR Get_Stop_Exceptions (v_stop_id NUMBER) IS
  SELECT DECODE(severity,'HIGH','ERROR','MEDIUM','WARNING',severity)
  FROM   wsh_exceptions
  WHERE  trip_stop_id = v_stop_id
  AND    status in ('OPEN','ERROR','LOGGED','IN_PROCESS','MANUAL')
  AND    severity in ('HIGH','MEDIUM','ERROR','WARNING')
  ORDER BY decode(severity,'HIGH',1,'ERROR',1,'MEDIUM',2,'WARNING',2,3);

  CURSOR Get_Delivery_Exceptions (v_delivery_id NUMBER) IS
  SELECT DECODE(severity,'HIGH','ERROR','MEDIUM','WARNING',severity)
  FROM   wsh_exceptions
  WHERE  delivery_id = v_delivery_id
  AND    status in ('OPEN','ERROR','LOGGED','IN_PROCESS','MANUAL')
  AND    severity in ('HIGH','MEDIUM','ERROR','WARNING')
  ORDER BY decode(severity,'HIGH',1,'ERROR',1,'MEDIUM',2,'WARNING',2,3);

  CURSOR Get_Detail_Exceptions (v_detail_id NUMBER) IS
  SELECT DECODE(severity,'HIGH','ERROR','MEDIUM','WARNING',severity)
  FROM   wsh_exceptions
  WHERE  delivery_detail_id = v_detail_id
  AND    status in ('OPEN','ERROR','LOGGED','IN_PROCESS','MANUAL')
  AND    severity in ('HIGH','MEDIUM','ERROR','WARNING')
  ORDER BY decode(severity,'HIGH',1,'ERROR',1,'MEDIUM',2,'WARNING',2,3);

  CURSOR Get_Details_Delivery(v_delivery_id NUMBER) IS
  SELECT wdd.delivery_detail_id, wdd.container_flag
  FROM   wsh_delivery_assignments_v wda, wsh_delivery_details wdd
  WHERE  wda.delivery_id = v_delivery_id
  AND    wdd.delivery_detail_id = wda.delivery_detail_id
  ORDER  BY wdd.container_flag;

  -- performance bug 5257207: SC-1: added ALL since the selections
  -- are mutually exclusive (a delivery cannot be both picked up
  -- and dropped off at the same stop).
  -- This is the same cursor as in close_exceptions.
  CURSOR Get_Deliveries_Stop(v_stop_id NUMBER) IS
  -- pick up deliveries
  SELECT dg.delivery_id
  FROM   wsh_new_deliveries dl, wsh_delivery_legs dg, wsh_trip_stops st
  WHERE  dg.delivery_id = dl.delivery_id
  AND    st.stop_location_id = dl.initial_pickup_location_id
  AND    st.stop_id = dg.pick_up_stop_id
  AND    st.stop_id = v_stop_id
  UNION ALL
  -- drop off deliveries
  SELECT dg.delivery_id
  FROM   wsh_new_deliveries dl, wsh_delivery_legs dg, wsh_trip_stops st
  WHERE  dg.delivery_id = dl.delivery_id
  AND    st.stop_location_id = dl.ultimate_dropoff_location_id
  AND    st.stop_id = dg.drop_off_stop_id
  AND    st.stop_id = v_stop_id;

  CURSOR Get_Stops_Trip(v_trip_id NUMBER) IS
  SELECT stop_id
  FROM   wsh_trip_stops
  WHERE  trip_id = v_trip_id
  ORDER  BY stop_sequence_number ASC ;

  CURSOR Get_Contents_Container (v_container_id NUMBER) IS
  SELECT delivery_detail_id
  FROM   wsh_delivery_assignments_v
  START WITH parent_delivery_detail_id = v_container_id
  CONNECT BY PRIOR delivery_detail_id = parent_delivery_detail_id;

  CURSOR Get_Container_Flag (v_delivery_detail_id NUMBER) IS
  SELECT container_flag
  FROM   wsh_delivery_details
  WHERE  delivery_detail_id = v_delivery_detail_id;

  CURSOR c_dummy_stop (v_stop_id NUMBER) IS
  SELECT stop_id
  FROM wsh_trip_stops wts
  WHERE wts.physical_stop_id IS NOT NULL
  AND wts.physical_location_id IS NOT NULL
  AND wts.physical_stop_id=v_stop_id
  AND wts.trip_id =(SELECT trip_id
                    FROM wsh_trip_stops wts1
                    WHERE wts1.stop_id=v_stop_id);

  l_severity VARCHAR2(30);

  -- Standard call to check for call compatibility
  l_api_version          CONSTANT        NUMBER  := 1.0;
  l_api_name             CONSTANT        VARCHAR2(30):= 'Check_Exceptions';

  l_count           NUMBER;
  l_delivery_exists BOOLEAN;
  l_container_flag  VARCHAR2(1);

  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

  c_trip             CONSTANT        VARCHAR2(30):= 'TRIP';
  l_exceptions_tab XC_TAB_TYPE;

  WSH_INVALID_LOGGING_ENTITY EXCEPTION;

  WSH_CHECK_EXCEPTIONS_FAILED EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'|| 'CHECK_EXCEPTIONS';
--
BEGIN

  --
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY_NAME',P_LOGGING_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY_ID',P_LOGGING_ENTITY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CONSIDER_CONTENT',P_CONSIDER_CONTENT);
  END IF;

  IF NOT FND_API.compatible_api_call (
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_count := 0;

  IF (p_logging_entity_name = 'TRIP') THEN
    OPEN Get_Trip_Exceptions(p_logging_entity_id);
    FETCH Get_Trip_Exceptions INTO l_severity;
    IF Get_Trip_Exceptions%NOTFOUND THEN
       l_severity := NULL;
    END IF;
    CLOSE Get_Trip_Exceptions;
    IF l_severity IS NOT NULL THEN
        l_count := x_exceptions_tab.COUNT + 1;
        x_exceptions_tab(l_count).entity_name := p_logging_entity_name;
        x_exceptions_tab(l_count).entity_id   := p_logging_entity_id;
        x_exceptions_tab(l_count).exception_behavior := l_severity;
    END IF;
    IF p_consider_content = 'Y' THEN
       -- check for stop level exceptions
       FOR stop_rec IN Get_Stops_Trip(p_logging_entity_id) LOOP
           Check_Exceptions(
                             -- Standard parameters
                             p_api_version           => 1.0,
                             x_return_status         => l_return_status,
                             x_msg_count             => l_msg_count,
                             x_msg_data              => l_msg_data,
                             -- program specific parameters
                             p_logging_entity_id     => stop_rec.stop_id,
                             p_logging_entity_name   => 'STOP',
                             p_consider_content      => 'Y',
                             -- program specific out parameters
                             x_exceptions_tab        => x_exceptions_tab,
                             p_caller                => p_caller||c_trip
                          );
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg('Check Exception failed for Stop :'||stop_rec.stop_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
              END IF;
              RAISE WSH_CHECK_EXCEPTIONS_FAILED;
           END IF;

       END LOOP;
    END IF;

  ELSIF (p_logging_entity_name = 'STOP') THEN
    OPEN Get_Stop_Exceptions(p_logging_entity_id);
    FETCH Get_Stop_Exceptions INTO l_severity;
    IF Get_Stop_Exceptions%NOTFOUND THEN
       l_severity := NULL;
    END IF;
    CLOSE Get_Stop_Exceptions;
    IF l_severity IS NOT NULL THEN
        l_count := x_exceptions_tab.COUNT + 1;
        x_exceptions_tab(l_count).entity_name := p_logging_entity_name;
        x_exceptions_tab(l_count).entity_id   := p_logging_entity_id;
        x_exceptions_tab(l_count).exception_behavior := l_severity;
    END IF;
    IF p_consider_content = 'Y' THEN
       -- check for the deliveries in the stop
       FOR del_rec IN Get_Deliveries_Stop(p_logging_entity_id) LOOP
           Check_Exceptions(
                             -- Standard parameters
                             p_api_version           => 1.0,
                             x_return_status         => l_return_status,
                             x_msg_count             => l_msg_count,
                             x_msg_data              => l_msg_data,
                             -- program specific parameters
                             p_logging_entity_id     => del_rec.delivery_id,
                             p_logging_entity_name   => 'DELIVERY',
                             p_consider_content      => 'Y',
                             -- program specific out parameters
                             x_exceptions_tab        => x_exceptions_tab
                          );
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg('Check Exception failed for Delivery :'||del_rec.delivery_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
              END IF;
              RAISE WSH_CHECK_EXCEPTIONS_FAILED;
           END IF;

       END LOOP;
    END IF;
    -- get dummy stop if caller is FTE or IB or TP Release.
    -- also caller shud not be TRIP (above), so that there is no dual count
    IF  (  nvl(p_caller,'@@@') like 'FTE%'
           OR nvl(p_caller,'@@@') like 'WSH_IB%'
           OR nvl(p_caller,'@@@') like 'WSH_TP_RELEASE%'
         ) AND NOT ( nvl(p_caller,'@@@') like '%TRIP%') THEN
       FOR stop_rec IN c_dummy_stop(p_logging_entity_id) LOOP
           Check_Exceptions(
                             -- Standard parameters
                             p_api_version           => 1.0,
                             x_return_status         => l_return_status,
                             x_msg_count             => l_msg_count,
                             x_msg_data              => l_msg_data,
                             -- program specific parameters
                             p_logging_entity_id     => stop_rec.stop_id,
                             p_logging_entity_name   => 'STOP',
                             p_consider_content      => p_consider_content,
                             -- program specific out parameters
                             x_exceptions_tab        => l_exceptions_tab,
                             p_caller                => p_caller
                          );
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg('Check Exception failed for Stop :'||stop_rec.stop_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
              END IF;
              RAISE WSH_CHECK_EXCEPTIONS_FAILED;
           END IF;
           IF l_exceptions_tab IS NOT NULL AND l_exceptions_tab.COUNT>0 THEN
              FOR i IN 1..l_exceptions_tab.COUNT LOOP
                  l_count := x_exceptions_tab.COUNT + 1;
                  --if exception is logged against dummy stop, make that to be against physical stop if caller is FTE/IB/TP
                  IF p_logging_entity_name='STOP' AND stop_rec.stop_id=l_exceptions_tab(i).entity_id THEN
                     x_exceptions_tab(l_count).entity_name := p_logging_entity_name;
                     x_exceptions_tab(l_count).entity_id   := p_logging_entity_id;
                     x_exceptions_tab(l_count).exception_behavior := l_exceptions_tab(i).exception_behavior;
                  ELSE
                     x_exceptions_tab(l_count).entity_name := l_exceptions_tab(i).entity_name;
                     x_exceptions_tab(l_count).entity_id   := l_exceptions_tab(i).entity_id;
                     x_exceptions_tab(l_count).exception_behavior := l_exceptions_tab(i).exception_behavior;
                  END IF;
              END LOOP;
           END IF;
       END LOOP;
    END IF; --p_caller

  ELSIF (p_logging_entity_name = 'DELIVERY') THEN
    l_delivery_exists := FALSE;
    FOR j in 1..x_exceptions_tab.COUNT LOOP
        IF x_exceptions_tab(j).entity_name = 'DELIVERY' AND
           x_exceptions_tab(j).entity_id = p_logging_entity_id THEN
           l_delivery_exists := TRUE;
           EXIT;
        END IF;
    END LOOP;
    IF NOT (l_delivery_exists) THEN
       OPEN Get_Delivery_Exceptions(p_logging_entity_id);
       FETCH Get_Delivery_Exceptions INTO l_severity;
       IF Get_Delivery_Exceptions%NOTFOUND THEN
          l_severity := NULL;
       END IF;
       CLOSE Get_Delivery_Exceptions;
       IF l_severity IS NOT NULL THEN
           l_count := x_exceptions_tab.COUNT + 1;
           x_exceptions_tab(l_count).entity_name := p_logging_entity_name;
           x_exceptions_tab(l_count).entity_id   := p_logging_entity_id;
           x_exceptions_tab(l_count).exception_behavior := l_severity;
       END IF;

       IF p_consider_content = 'Y' THEN
          -- go for the contents of the delivery
          FOR detail_rec IN Get_Details_Delivery(p_logging_entity_id) LOOP
              Check_Exceptions(
                                -- Standard parameters
                                p_api_version           => 1.0,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                -- program specific parameters
                                p_logging_entity_id     => detail_rec.delivery_detail_id,
                                p_logging_entity_name   => 'LINE',
                                p_consider_content      => 'Y',
                                -- program specific out parameters
                                x_exceptions_tab        => x_exceptions_tab
                             );
              IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg('Check Exception failed for Detail :'||detail_rec.delivery_detail_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 END IF;
                 RAISE WSH_CHECK_EXCEPTIONS_FAILED;
              END IF;

          END LOOP;
       END IF;
    END IF;

  ELSIF (p_logging_entity_name = 'LINE') THEN
    OPEN Get_Detail_Exceptions(p_logging_entity_id);
    FETCH Get_Detail_Exceptions INTO l_severity;
    IF Get_Detail_Exceptions%NOTFOUND THEN
       l_severity := NULL;
    END IF;
    CLOSE Get_Detail_Exceptions;
    IF l_severity IS NOT NULL THEN
        l_count := x_exceptions_tab.COUNT + 1;
        OPEN Get_Container_Flag(p_logging_entity_id);
        FETCH Get_Container_Flag INTO l_container_flag;
        CLOSE Get_Container_Flag;
        IF l_container_flag = 'Y' THEN
            x_exceptions_tab(l_count).entity_name := 'CONTAINER';
        ELSE
            x_exceptions_tab(l_count).entity_name := 'LINE';
        END IF;
        x_exceptions_tab(l_count).entity_id   := p_logging_entity_id;
        x_exceptions_tab(l_count).exception_behavior := l_severity;
    END IF;

  ELSIF (p_logging_entity_name = 'CONTAINER') THEN
    OPEN Get_Detail_Exceptions(p_logging_entity_id);
    FETCH Get_Detail_Exceptions INTO l_severity;
    IF Get_Detail_Exceptions%NOTFOUND THEN
       l_severity := NULL;
    END IF;
    CLOSE Get_Detail_Exceptions;
    IF l_severity IS NOT NULL THEN
        l_count := x_exceptions_tab.COUNT + 1;
        x_exceptions_tab(l_count).entity_name := p_logging_entity_name;
        x_exceptions_tab(l_count).entity_id   := p_logging_entity_id;
        x_exceptions_tab(l_count).exception_behavior := l_severity;
    END IF;

    IF p_consider_content = 'Y' THEN
          -- go for the contents of the container
          FOR detail_rec IN Get_Contents_Container(p_logging_entity_id) LOOP
              Check_Exceptions(
                                -- Standard parameters
                                p_api_version           => 1.0,
                                x_return_status         => l_return_status,
                                x_msg_count             => l_msg_count,
                                x_msg_data              => l_msg_data,
                                -- program specific parameters
                                p_logging_entity_id     => detail_rec.delivery_detail_id,
                                p_logging_entity_name   => 'LINE',
                                p_consider_content      => 'Y',
                                -- program specific out parameters
                                x_exceptions_tab        => x_exceptions_tab
                             );
              IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg('Check Exception failed for Detail :'||detail_rec.delivery_detail_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 END IF;
                 RAISE WSH_CHECK_EXCEPTIONS_FAILED;
              END IF;

          END LOOP;
    END IF;


  ELSE
    RAISE WSH_INVALID_LOGGING_ENTITY;
  END IF;

  --
  -- Debug Statements
  --
    IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
    END IF;
  --

  EXCEPTION
    WHEN WSH_CHECK_EXCEPTIONS_FAILED THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      FND_MSG_PUB.Count_And_Get(
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => FND_API.G_FALSE
                               );
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CHECK_EXCEPTIONS_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CHECK_EXCEPTIONS_FAILED');
     END IF;
     --

    WHEN WSH_INVALID_LOGGING_ENTITY THEN
      FND_MESSAGE.Set_Name('FND', 'WSH_XC_INVALID_LOGGING_ENTITY');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      FND_MSG_PUB.Count_And_Get(
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                 p_encoded => FND_API.G_FALSE
                               );
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_LOGGING_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_LOGGING_ENTITY');
     END IF;
     --

    WHEN others THEN
      IF Get_Trip_Exceptions%ISOPEN THEN
	      CLOSE Get_Trip_Exceptions;
      END IF;
      IF Get_Stop_Exceptions%ISOPEN THEN
    	   CLOSE Get_Stop_Exceptions;
      END IF;
      IF Get_Delivery_Exceptions%ISOPEN THEN
	      CLOSE Get_Delivery_Exceptions;
      END IF;
      IF Get_Detail_Exceptions%ISOPEN THEN
    	   CLOSE Get_Detail_Exceptions;
      END IF;
      IF Get_Details_Delivery%ISOPEN THEN
	      CLOSE Get_Details_Delivery;
      END IF;
      IF Get_Deliveries_Stop%ISOPEN THEN
	      CLOSE Get_Deliveries_Stop;
      END IF;
      IF Get_Stops_Trip%ISOPEN THEN
	      CLOSE Get_Stops_Trip;
      END IF;

      wsh_util_core.default_handler('WSH_XC_UTIL.CHECK_EXCEPTIONS');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
  END IF;
  --

END Check_Exceptions;


-- -------------------------------------------------------------------------------
-- Start of comments
-- API name  : Close_Exceptions
-- Type      : Public
-- Function  : This procedure takes input as Entity Name and Entity Id
--             and closes all exceptions logged against it.
--             If p_consider_content is set to 'Y', then the API also looks
--             at the contents of the Entity and closes all exceptions for the
--             child entities. This is drilled to lowest child entity.
--             This API should be called ONLY if Check_Exceptions is called before
--             it. This is because this API assumes all Error Exceptions are Resolved
--             prior to this API call and closes OPEN/NO_ACTION_REQUIRED exceptions
--             unless they are Information Only (FP bug 4370532).
--             Valid Values for p_logging_entity_name : LINE, CONTAINER, DELIVERY,
--             TRIP, STOP
-- End of comments
-- --------------------------------------------------------------------------------

PROCEDURE Close_Exceptions (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_return_status         OUT  NOCOPY    VARCHAR2,
        x_msg_count             OUT  NOCOPY    NUMBER,
        x_msg_data              OUT  NOCOPY    VARCHAR2,

        -- program specific parameters
        p_logging_entity_id	IN 	NUMBER,
	p_logging_entity_name	IN	VARCHAR2,
        p_consider_content      IN  VARCHAR2,
        p_caller                IN      VARCHAR2
	) IS

  CURSOR Get_Details_Delivery(v_delivery_id NUMBER) IS
  SELECT wdd.delivery_detail_id, wdd.container_flag
  FROM   wsh_delivery_assignments_v wda, wsh_delivery_details wdd
  WHERE  wda.delivery_id = v_delivery_id
  AND    wdd.delivery_detail_id = wda.delivery_detail_id
  ORDER  BY wdd.container_flag;

  -- performance bug 5257207: SC-1: added ALL since the selections
  -- are mutually exclusive (a delivery cannot be both picked up
  -- and dropped off at the same stop).
  -- This is the same cursor as in check_exceptions.
  CURSOR Get_Deliveries_Stop(v_stop_id NUMBER) IS
  -- pick up deliveries
  SELECT dg.delivery_id
  FROM   wsh_new_deliveries dl, wsh_delivery_legs dg, wsh_trip_stops st
  WHERE  dg.delivery_id = dl.delivery_id
  AND    st.stop_location_id = dl.initial_pickup_location_id
  AND    st.stop_id = dg.pick_up_stop_id
  AND    st.stop_id = v_stop_id
  UNION ALL
  -- drop off deliveries
  SELECT dg.delivery_id
  FROM   wsh_new_deliveries dl, wsh_delivery_legs dg, wsh_trip_stops st
  WHERE  dg.delivery_id = dl.delivery_id
  AND    st.stop_location_id = dl.ultimate_dropoff_location_id
  AND    st.stop_id = dg.drop_off_stop_id
  AND    st.stop_id = v_stop_id;

  CURSOR Get_Stops_Trip(v_trip_id NUMBER) IS
  SELECT stop_id
  FROM   wsh_trip_stops
  WHERE  trip_id = v_trip_id
  ORDER  BY stop_sequence_number ASC ;

  CURSOR c_dummy_stop (v_stop_id NUMBER) IS
  SELECT stop_id
  FROM wsh_trip_stops wts
  WHERE wts.physical_stop_id IS NOT NULL
  AND wts.physical_location_id IS NOT NULL
  AND wts.physical_stop_id=v_stop_id
  AND wts.trip_id =(SELECT trip_id
                    FROM wsh_trip_stops wts1
                    WHERE wts1.stop_id=v_stop_id);

  -- Standard call to check for call compatibility
  l_api_version          CONSTANT        NUMBER  := 1.0;
  l_api_name             CONSTANT        VARCHAR2(30):= 'Close_Exceptions';
  c_trip                 CONSTANT        VARCHAR2(30):= 'TRIP';

  WSH_INVALID_LOGGING_ENTITY   EXCEPTION;
  WSH_PURGE_FAILED             EXCEPTION;
  WSH_CLOSE_EXCEPTIONS_FAILED  EXCEPTION;

  l_count          NUMBER;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'|| 'CLOSE_EXCEPTIONS';
--
BEGIN

  --
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY_NAME',P_LOGGING_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY_ID',P_LOGGING_ENTITY_ID);
  END IF;

  IF NOT FND_API.compatible_api_call (
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF (p_logging_entity_name = 'TRIP') THEN
     WSH_XC_UTIL.Purge (
                          p_api_version       => p_api_version,
                          x_return_status     => l_return_status,
                          x_msg_count         => l_msg_count,
                          x_msg_data          => l_msg_data,
                          x_no_of_recs_purged => l_count,
                          p_trip_id           => p_logging_entity_id,
                          p_action            => C_ACTION_SEMICLOSED
                       );
     IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg('Purge failed for Trip :'||p_logging_entity_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        END IF;
        RAISE WSH_PURGE_FAILED;
     END IF;

     IF p_consider_content = 'Y' THEN
        -- Close all stop level exceptions
        FOR stop_rec IN Get_Stops_Trip(p_logging_entity_id) LOOP
            WSH_XC_UTIL.Close_Exceptions (
                                            p_api_version          => p_api_version,
                                            x_return_status        => l_return_status,
                                            x_msg_count            => l_msg_count,
                                            x_msg_data             => l_msg_data,
                                            p_logging_entity_id    => stop_rec.stop_id,
                                            p_logging_entity_name  => 'STOP',
                                            p_consider_content     => p_consider_content,
                                            p_caller               => p_caller||c_trip
                                         );
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg('Close_Exception failed for Stop :'||stop_rec.stop_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
               END IF;
               RAISE WSH_CLOSE_EXCEPTIONS_FAILED;
            END IF;
        END LOOP;
     END IF;

  ELSIF (p_logging_entity_name = 'STOP') THEN

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg('Calling Purge for Stop '||p_logging_entity_id ,WSH_DEBUG_SV.C_EXCEP_LEVEL);
     END IF;
     WSH_XC_UTIL.Purge (
                          p_api_version       => p_api_version,
                          x_return_status     => x_return_status,
                          x_msg_count         => x_msg_count,
                          x_msg_data          => x_msg_data,
                          x_no_of_recs_purged => l_count,
                          p_trip_stop_id      => p_logging_entity_id,
                          p_action            => C_ACTION_SEMICLOSED
                       );
     IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg('Purge failed for Stop :'||p_logging_entity_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
        END IF;
        RAISE WSH_PURGE_FAILED;
     END IF;

     IF p_consider_content = 'Y' THEN
        -- go for the deliveries, lines and containers
        FOR del_rec IN Get_Deliveries_Stop(p_logging_entity_id) LOOP
            WSH_XC_UTIL.Close_Exceptions (
                                            p_api_version          => p_api_version,
                                            x_return_status        => l_return_status,
                                            x_msg_count            => l_msg_count,
                                            x_msg_data             => l_msg_data,
                                            p_logging_entity_id    => del_rec.delivery_id,
                                            p_logging_entity_name  => 'DELIVERY',
                                            p_consider_content     => p_consider_content
                                         );
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg('Close_Exception failed for Delivery :'||del_rec.delivery_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
                END IF;
                RAISE WSH_CLOSE_EXCEPTIONS_FAILED;
            END IF;
        END LOOP;
     END IF;

    -- get dummy stop if caller is FTE or IB or TP Release.
    -- also caller shud not be TRIP (above), so that there is no dual count
    IF  (  nvl(p_caller,'@@@') like 'FTE%'
           OR nvl(p_caller,'@@@') like 'WSH_IB%'
           OR nvl(p_caller,'@@@') like 'WSH_TP_RELEASE%'
         ) AND NOT ( nvl(p_caller,'@@@') like '%TRIP%') THEN
       FOR stop_rec IN c_dummy_stop(p_logging_entity_id) LOOP
            WSH_XC_UTIL.Close_Exceptions (
                                            p_api_version          => p_api_version,
                                            x_return_status        => l_return_status,
                                            x_msg_count            => l_msg_count,
                                            x_msg_data             => l_msg_data,
                                            p_logging_entity_id    => stop_rec.stop_id,
                                            p_logging_entity_name  => 'STOP',
                                            p_consider_content     => p_consider_content,
                                            p_caller               => p_caller
                                         );
            IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg('Close_Exception failed for Stop :'||stop_rec.stop_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
               END IF;
               RAISE WSH_CLOSE_EXCEPTIONS_FAILED;
            END IF;
       END LOOP;
    END IF;
  ELSIF (p_logging_entity_name = 'DELIVERY') THEN
        WSH_XC_UTIL.Purge (
                              p_api_version       => p_api_version,
                              x_return_status     => x_return_status,
                              x_msg_count         => x_msg_count,
                              x_msg_data          => x_msg_data,
                              x_no_of_recs_purged => l_count,
                              p_delivery_id       => p_logging_entity_id,
                              p_delivery_contents => p_consider_content,
                              p_action            => C_ACTION_SEMICLOSED
                          );
        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg('Purge failed for Delivery :'||p_logging_entity_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
           END IF;
           RAISE WSH_PURGE_FAILED;
        END IF;

  ELSIF (p_logging_entity_name IN ('LINE','CONTAINER')) THEN
        WSH_XC_UTIL.Purge (
                              p_api_version        => p_api_version,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              x_no_of_recs_purged  => l_count,
                              p_delivery_detail_id => p_logging_entity_id,
                              p_action             => C_ACTION_SEMICLOSED
                          );
        IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg('Purge failed for Detail/Container :'||p_logging_entity_id,WSH_DEBUG_SV.C_EXCEP_LEVEL);
           END IF;
           RAISE WSH_PURGE_FAILED;
        END IF;

  ELSE

    RAISE WSH_INVALID_LOGGING_ENTITY;

  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --

  EXCEPTION
    WHEN WSH_CLOSE_EXCEPTIONS_FAILED THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      FND_MSG_PUB.Count_And_Get(
               p_count => x_msg_count,
               p_data  => x_msg_data,
               p_encoded => FND_API.G_FALSE
               );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CLOSE_EXCEPTIONS_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CLOSE_EXCEPTIONS_FAILED');
      END IF;
      --

    WHEN WSH_PURGE_FAILED THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      FND_MSG_PUB.Count_And_Get(
               p_count => x_msg_count,
               p_data  => x_msg_data,
	       p_encoded => FND_API.G_FALSE
               );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_PURGE_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_PURGE_FAILED');
      END IF;
      --

    WHEN WSH_INVALID_LOGGING_ENTITY THEN
      FND_MESSAGE.Set_Name('FND', 'WSH_XC_INVALID_LOGGING_ENTITY');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      FND_MSG_PUB.Count_And_Get(
               p_count => x_msg_count,
               p_data  => x_msg_data,
	       p_encoded => FND_API.G_FALSE
               );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_LOGGING_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_LOGGING_ENTITY');
      END IF;
      --

    WHEN others THEN
      wsh_util_core.default_handler('WSH_XC_UTIL.CLOSE_EXCEPTIONS');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--

END Close_Exceptions;

  --OTM R12
  ----------------------------------------------------------
  -- PROCEDURE CLOSE_OTM_EXCEPTION
  --
  -- parameters:  p_delivery_id              - The ID of the delivery whose exception should be closed.
  --              p_exceptions_to_close_tab  - The Exceptions that are to be closed.
  --              x_return_status            - return status
  --
  -- description: Closes the OTM exceptions passed in 'p_exceptions_to_close_tab' for the delivery p_delivery_id
  --
  ----------------------------------------------------------

  PROCEDURE CLOSE_OTM_EXCEPTION(
    p_delivery_id              IN         WSH_NEW_DELIVERIES.DELIVERY_ID%TYPE,
    p_exceptions_to_close_tab  IN         WSH_UTIL_CORE.COLUMN_TAB_TYPE,
    x_return_status            OUT NOCOPY VARCHAR2) IS

  l_exception_name      WSH_EXCEPTION_DEFINITIONS_TL.EXCEPTION_NAME%TYPE;
  l_debug_on            BOOLEAN;
  l_count               NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(32767);
  l_return_status       VARCHAR2(1);
  i			NUMBER;
  l_num_warn 		NUMBER;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CLOSE_OTM_EXCEPTION';
  --

  BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'delivery id', p_delivery_id);
      WSH_DEBUG_SV.log(l_module_name, 'number of exceptions to close', p_exceptions_to_close_tab.COUNT);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_exception_name := NULL;
    l_count := 0;
    l_msg_count := 0;
    l_msg_data := NULL;
    l_num_warn := 0;
    i := 0;

    IF (p_exceptions_to_close_tab.COUNT > 0 AND p_delivery_id IS NOT NULL) THEN

      i := p_exceptions_to_close_tab.FIRST;
      WHILE i IS NOT NULL LOOP

        l_exception_name := p_exceptions_to_close_tab(i);

        -- call purge with action 'CLOSED'
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.PURGE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

        WSH_XC_UTIL.purge (
            p_api_version       => 1.0,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data,
            x_no_of_recs_purged => l_count,
            p_exception_name    => l_exception_name,
            p_delivery_id       => p_delivery_id,
            p_delivery_contents => 'N',
            p_action            => 'CLOSED'
          );

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_XC_UTIL.purge: ' || l_return_status);
          WSH_DEBUG_SV.log(l_module_name, 'number of exceptions purged', l_count);
        END IF;

        IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
          x_return_status         := l_return_status;
          EXIT;
        ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          l_num_warn := l_num_warn + 1;
        END IF;

        i := p_exceptions_to_close_tab.NEXT(i);
      END LOOP;
    END IF;

    IF l_num_warn > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;

    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

  EXCEPTION
    --
    WHEN OTHERS THEN
      wsh_util_core.default_handler('WSH_XC_UTIL.CLOSE_OTM_EXCEPTION', l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Unexpected error has occured. '|| SQLERRM,  WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

  END CLOSE_OTM_EXCEPTION;

  ----------------------------------------------------------
  -- PROCEDURE LOG_OTM_EXCEPTION
  --
  -- parameters:  p_delivery_info_tab table of deliveries to check and log
  --                                  exceptions for
  --              p_new_interface_flag_tab    the table of new interface flag for
  --                                          the table of deliveries
  --              x_return_status     return status
  --
  -- description: This procedure checks each delivery's tms_interface_flag to
  --      see if it has changed. The new tms_interface_flag is either
  --      calculated or supplied in the parameters. The old
  --      tms_interface_flag is stored in the info table. The procedure
  --      log and close exceptions on the delivery based on the old
  --      and new tms_interface_flag.
  ----------------------------------------------------------

  PROCEDURE LOG_OTM_EXCEPTION(
    p_delivery_info_tab       IN         WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
    p_new_interface_flag_tab  IN         WSH_UTIL_CORE.COLUMN_TAB_TYPE,
    x_return_status           OUT NOCOPY VARCHAR2) IS

  l_msg_count                 	NUMBER;
  l_msg_data                  	VARCHAR2(32767);
  l_exception_id		WSH_EXCEPTIONS.EXCEPTION_ID%TYPE;
  l_exception_message		WSH_EXCEPTIONS.MESSAGE%TYPE;
  l_num_error                   NUMBER;
  l_num_warn                   	NUMBER;
  l_return_status               VARCHAR2(1);

  l_new_interface_flag		WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE;
  l_exception_name              WSH_EXCEPTION_DEFINITIONS_TL.EXCEPTION_NAME%TYPE;
  l_exceptions_to_close_tab     WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  i                             NUMBER;
  --
  l_debug_on                    BOOLEAN;
  --
  l_module_name                 CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
					'.' || 'LOG_OTM_EXCEPTION';
  --
  BEGIN
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'delivery record count', p_delivery_info_tab.COUNT);
      WSH_DEBUG_SV.log(l_module_name, 'interface flag count', p_new_interface_flag_tab.COUNT);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    --initialize
    l_num_warn           := 0;
    l_num_error          := 0;
    l_msg_count          := 0;
    l_msg_data           := NULL;
    l_new_interface_flag := NULL;
    i                    := 0;

    IF (p_delivery_info_tab.COUNT = 0) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'no delivery to log exceptions');
      END IF;
    END IF;

    i := p_delivery_info_tab.FIRST;

    WHILE i IS NOT NULL LOOP

      --this loop is used to figure out the new tms interface flag value depending on the old one
      --when the input tms interface flag was not specified
      IF (p_new_interface_flag_tab.COUNT = 0 OR p_new_interface_flag_tab(i) IS NULL) THEN
        --figure out the new status as if it's just an update on delivery
        IF (p_delivery_info_tab(i).tms_interface_flag IN (WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                                                          WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED,
                                                          WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                                                          WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER,
                                                          WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED)) THEN
          l_new_interface_flag := WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED;
        ELSE
          l_new_interface_flag := p_delivery_info_tab(i).tms_interface_flag;
        END IF;
      ELSE
        l_new_interface_flag := p_new_interface_flag_tab(i);
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'p_delivery_id' , p_delivery_info_tab(i).delivery_id);
        WSH_DEBUG_SV.log(l_module_name, 'l_new_interface_flag', l_new_interface_flag);
        WSH_DEBUG_SV.log(l_module_name, 'p_delivery_info_tab(i).tms_interface_flag', p_delivery_info_tab(i).tms_interface_flag);
        IF p_new_interface_flag_tab.COUNT > 0 THEN
          WSH_DEBUG_SV.log(l_module_name, 'p_delivery_info_tab(i).tms_interface_flag', p_new_interface_flag_tab(i));
        END IF;
      END IF;

      --log and close exceptions only if new status is different and not IN Process status
      IF ((l_new_interface_flag <> p_delivery_info_tab(i).tms_interface_flag)
          AND (l_new_interface_flag NOT IN (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS,
                                            WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS,
                                            WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS))) THEN

        l_exception_id := NULL;
        l_exception_message := NULL;
        l_exception_name := NULL;

        -- Start of Ship Confirm ECO
        -- Close the old exception(s) logged against this delivery, as we are going to
        -- log a new exception based on the l_new_interface_flag.
        --
        IF p_delivery_info_tab(i).tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER THEN
          l_exceptions_to_close_tab(1) := 'WSH_OTM_DEL_AWAIT_TRIP';
        ELSIF p_delivery_info_tab(i).tms_interface_flag IN (WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED,
                                                            WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_IN_PROCESS) THEN
          l_exceptions_to_close_tab(1) := 'WSH_OTM_DEL_UPDATE_REQ';
        ELSIF p_delivery_info_tab(i).tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED THEN
          l_exceptions_to_close_tab(1) := 'WSH_OTM_SHIPMENT_REC';
        ELSIF  p_delivery_info_tab(i).tms_interface_flag IN (WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
                                                             WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_IN_PROCESS) THEN
          l_exceptions_to_close_tab(1) := 'WSH_OTM_DEL_CREATE_REQ';
        ELSIF  p_delivery_info_tab(i).tms_interface_flag IN (WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED,
                                                             WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS) THEN
          l_exceptions_to_close_tab(1) := 'WSH_OTM_DEL_DELETE_REQ';
        END IF;

        IF l_exceptions_to_close_tab.COUNT > 0 THEN

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.CLOSE_OTM_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_XC_UTIL.close_otm_exception(
              p_delivery_id             => p_delivery_info_tab(i).delivery_id,
              p_exceptions_to_close_tab => l_exceptions_to_close_tab,
              x_return_status           => l_return_status
          );

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_XC_UTIL.close_otm_exception: ' || l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            l_num_error := l_num_error + 1;
            EXIT;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_num_warn := l_num_warn + 1;
          END IF;
        END IF;

        --log the deleted exception before the new CR exception is logged

        IF ((l_new_interface_flag IN (WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT,
                                      WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED,
                                      WSH_NEW_DELIVERIES_PVT.C_TMS_COMPLETED))
            AND (p_delivery_info_tab(i).tms_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_IN_PROCESS)) THEN

          --log deleted, only when set from DP to NS or CR or CMP

          l_exception_name := 'WSH_OTM_DEL_DELETED';
          FND_MESSAGE.SET_NAME('WSH',l_exception_name); --message name is same as exception name
          FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', p_delivery_info_tab(i).name);
          l_exception_message := FND_MESSAGE.GET;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_XC_UTIL.log_exception(
              p_api_version           => 1.0,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data,
              x_exception_id          => l_exception_id,
              p_exception_location_id => p_delivery_info_tab(i).INITIAL_PICKUP_LOCATION_ID,
              p_logged_at_location_id => p_delivery_info_tab(i).INITIAL_PICKUP_LOCATION_ID,
              p_logging_entity        => 'SHIPPER',
              p_logging_entity_id     => FND_GLOBAL.USER_ID,
              p_exception_name        => l_exception_name,
              p_delivery_id           => p_delivery_info_tab(i).delivery_id,
	      p_message		      => l_exception_message);


          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_XC_UTIL.log_exception: ' || l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            l_num_error := l_num_error + 1;
            EXIT;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_num_warn := l_num_warn + 1;
          END IF;

        END IF;

        l_exception_name := NULL;

        --logging the new exception
        IF (l_new_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_CREATE_REQUIRED) THEN

          l_exception_name := 'WSH_OTM_DEL_CREATE_REQ';

        ELSIF (l_new_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_UPDATE_REQUIRED) THEN

          l_exception_name := 'WSH_OTM_DEL_UPDATE_REQ';

        ELSIF (l_new_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_DELETE_REQUIRED) THEN

          l_exception_name := 'WSH_OTM_DEL_DELETE_REQ';

        ELSIF (l_new_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER) THEN

          l_exception_name := 'WSH_OTM_DEL_AWAIT_TRIP';

        ELSIF (l_new_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED) THEN

          l_exception_name := 'WSH_OTM_SHIPMENT_REC';

        END IF;

        IF (l_exception_name IS NOT NULL) THEN

          --log the messages, message name is same as exception name
          IF (l_new_interface_flag = WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED) THEN

            FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_DELIVERY_SUCCESS');

          ELSE

            FND_MESSAGE.SET_NAME('WSH',l_exception_name);
            FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', p_delivery_info_tab(i).name);

          END IF;

          l_exception_message := FND_MESSAGE.GET;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_XC_UTIL.log_exception(
              p_api_version           => 1.0,
              x_return_status         => l_return_status,
              x_msg_count             => l_msg_count,
              x_msg_data              => l_msg_data,
              x_exception_id          => l_exception_id,
              p_exception_location_id => p_delivery_info_tab(i).INITIAL_PICKUP_LOCATION_ID,
              p_logged_at_location_id => p_delivery_info_tab(i).INITIAL_PICKUP_LOCATION_ID,
              p_logging_entity        => 'SHIPPER',
              p_logging_entity_id     => FND_GLOBAL.USER_ID,
              p_exception_name        => l_exception_name,
              p_delivery_id           => p_delivery_info_tab(i).delivery_id,
	      p_message	              => l_exception_message);

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'return status from WSH_XC_UTIL.log_exception: ' || l_return_status);
          END IF;

          IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            l_num_error := l_num_error + 1;
            EXIT;
          ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
            l_num_warn := l_num_warn + 1;
          END IF;

        END IF;
      END IF;

      i := p_delivery_info_tab.NEXT(i);

    END LOOP;

    IF (l_num_error > 0)THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSIF (l_num_warn > 0) THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --

  EXCEPTION
    WHEN others THEN
      wsh_util_core.default_handler('WSH_XC_UTIL.LOG_OTM_EXCEPTION',  l_module_name);
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,
          'Unexpected error has occured. Oracle error message is '|| SQLERRM,
          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;

  END LOG_OTM_EXCEPTION;

  ----------------------------------------------------------
  -- PROCEDURE GET_OTM_DELIVERY_EXCEPTION
  --
  -- Parameters
  --
  -- Input p_delivery_id     the delivery to get the OTM exceptions severity.
  --
  -- Output  x_exception_name,     The name of the OTM exception
  --         x_severity,           Severity of the Exception
  --         x_return_status       S when success U when exception is thrown.
  --
  -- description:	This procedure gets the delivery's OTM exception and severity
  ----------------------------------------------------------
  PROCEDURE GET_OTM_DELIVERY_EXCEPTION
  (p_delivery_id	IN         WSH_NEW_DELIVERIES.DELIVERY_ID%TYPE,
   x_exception_name	OUT NOCOPY WSH_EXCEPTIONS.EXCEPTION_NAME%TYPE,
   x_severity        	OUT NOCOPY WSH_EXCEPTIONS.SEVERITY%TYPE,
   x_return_status   	OUT NOCOPY VARCHAR2) IS

  --this cursor gets the delivery's otm exceptions ordered by severity
  --we used order by 1 to take advantage of the alphabetical order of ERROR and WARNING
  CURSOR c_get_delivery_otm_exceptions (p_delivery_id IN NUMBER) IS
    SELECT severity,
           DECODE(severity,'HIGH', 1, 'ERROR', 1, 'MEDIUM', 2, 'WARNING', 2, 3) rank,
           exception_name
    FROM  wsh_exceptions
    WHERE delivery_id = p_delivery_id
    AND status IN ('OPEN','ERROR','LOGGED','IN_PROCESS','MANUAL')
    AND severity IN ('HIGH','MEDIUM','ERROR','WARNING')
    AND exception_name IN
        ('WSH_OTM_DEL_CREATE_REQ','WSH_OTM_DEL_UPDATE_REQ',
         'WSH_OTM_DEL_AWAIT_TRIP')
    ORDER BY rank ASC;

  l_severity          WSH_EXCEPTIONS.SEVERITY%TYPE;
  l_exception_name    WSH_EXCEPTIONS.EXCEPTION_NAME%TYPE;
  l_rank              NUMBER;

  l_debug_on          BOOLEAN;
  l_module_name       CONSTANT VARCHAR2(100) := 'wsh.plsql.' || g_pkg_name || '.' || 'GET_OTM_DELIVERY_EXCEPTION';

  BEGIN

    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

    IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      WSH_DEBUG_SV.log(l_module_name, 'delivery id', p_delivery_id);
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_severity := NULL;
    l_rank := NULL;
    l_exception_name := NULL;

    IF (p_delivery_id IS NULL) THEN
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'delivery id is NULL');
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      x_severity := l_severity;
      x_exception_name := l_exception_name;
      RETURN;
    END IF;


    -- Return the exception with the highest severity.
    OPEN c_get_delivery_otm_exceptions(p_delivery_id);

    FETCH c_get_delivery_otm_exceptions INTO l_severity, l_rank, l_exception_name;

    IF c_get_delivery_otm_exceptions%NOTFOUND THEN
      l_severity := NULL;
      l_exception_name := NULL;
    END IF;

    CLOSE c_get_delivery_otm_exceptions;

    -- Assign to the output variables.
    -- Reason for the coresponding local variables being extendability.

    x_severity := l_severity;
    x_exception_name := l_exception_name;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_severity);
      WSH_DEBUG_SV.log(l_module_name, 'x_exception_name', x_exception_name);
      WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_XC_UTIL.GET_OTM_DELIVERY_EXCEPTION', l_module_name);

      IF c_get_delivery_otm_exceptions%ISOPEN THEN
        CLOSE c_get_delivery_otm_exceptions;
      END IF;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;

  END GET_OTM_DELIVERY_EXCEPTION;
  --END OTM R12

END WSH_XC_UTIL;

/
