--------------------------------------------------------
--  DDL for Package Body WSH_CAL_ASG_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CAL_ASG_VALIDATIONS" AS
-- $Header: WSHCAVLB.pls 120.2.12010000.3 2009/11/02 12:41:58 skanduku ship $

/*+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     WSHCAVLB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Validation API for transportation calendar                        |
--|                                                                       |
--| HISTORY                                                               |
--|     06/29/99 dmay            Created                                  |
--+======================================================================*/
--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_CAL_ASG_VALIDATIONS';
-- add your constants here if any

--===================
-- PUBLIC VARIABLES
--===================
-- add your public global variables here if any
wsh_missing_mandatory_attr EXCEPTION;
wsh_bad_parameter EXCEPTION;

--===================
-- PROCEDURES
--===================
--First, private procedure declarations
--========================================================================
-- PROCEDURE : Find_Valid_Date    GROUP
-- PARAMETERS:
--             p_input_date            Date to validate
--             p_calendar_type         Calendar type -- SHIPPING, RECEIVING, or
--                                     CARRIER
--             p_location_id           Location ID (optional)
--             p_vendor_site_id        Vendor Site ID (optional)
--             p_customer_site_use_id  Customer Site Use ID (optional)
--             p_freight_code          Carrier code (optional)
--             p_freight_org_id        Carrier Organization ID (optional)
--             x_suggest_date          Suggested valid date
--             x_success               Did we find a date?
--             p_threshold             Number of dates to try before failure
--             p_which_way             FORWARD or BACK -- which way to search
--             p_time_matters          Is time important for this date?
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Searches for a valid date near a given date by checking
--             nearby dates against a given calendar.  Decrement if
--             finding ship date, increment if finding receive date
--========================================================================
PROCEDURE Find_Valid_Date
( p_input_date            IN  DATE
, p_calendar_type         IN  VARCHAR2
, p_assoc_type            IN  VARCHAR2
, p_location_id           IN  NUMBER
, p_vendor_site_id        IN  NUMBER
, p_customer_site_use_id  IN  NUMBER
, p_freight_code          IN  VARCHAR2
, p_freight_org_id        IN  NUMBER
, x_suggest_date          OUT NOCOPY  DATE
, x_success               OUT NOCOPY  BOOLEAN
, p_threshold             IN  NUMBER
, p_which_way             IN  VARCHAR2
, p_time_matters          IN  BOOLEAN
);
--========================================================================
-- PROCEDURE : Single_Date    PRIVATE
-- PARAMETERS:
--             p_date                  Date to validate
--             p_calendar_type         Calendar type -- SHIPPING, RECEIVING, or
--                                     CARRIER
--             p_assoc_type            Type of site
--             p_location_id           Location ID (optional)
--             p_vendor_site_id        Vendor Site ID (optional)
--             p_customer_site_use_id  Customer Site Use ID (optional)
--             p_freight_code          Carrier code (optional)
--             p_freight_org_id        Carrier Organization ID (optional)
--             p_date_is_valid         Return information
--             p_time_matters          Is time important for this date?
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Validates a shipping or receiving date against a shipping
--             calendar and against a carrier calendar
--========================================================================
PROCEDURE Single_Date
( p_date                  IN  DATE
, p_calendar_type         IN  VARCHAR2
, p_assoc_type            IN  VARCHAR2
, p_location_id           IN  NUMBER
, p_vendor_site_id        IN  NUMBER
, p_customer_site_use_id  IN  NUMBER
, p_freight_code          IN  VARCHAR2
, p_freight_org_id        IN  NUMBER
, p_date_is_valid         OUT NOCOPY  BOOLEAN
, p_time_matters          IN  BOOLEAN
);
--Now the package body

--========================================================================
-- PROCEDURE : Get_Calendar            PUBLIC
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_entity_type           Entity - 'CUSTOMER','ORG','VENDOR'
--             p_entity_id             Entity Id - Customer_id, vendor_id, org_id
--             p_location_id           Location ID (optional)
--             x_calendar_code         Return calendar code
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Returns a calendar code for a given customer,vendor or org and
--             location combination. If location is not specified then this
--             returns the default calendar code
--========================================================================

PROCEDURE Get_Calendar
( p_api_version_number IN NUMBER
, p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY  VARCHAR2
, x_msg_count     OUT NOCOPY  NUMBER
, x_msg_data      OUT NOCOPY  VARCHAR2
, p_entity_type   IN  VARCHAR2
, p_entity_id     IN  NUMBER
, p_location_id   IN  NUMBER
, x_calendar_code OUT NOCOPY  VARCHAR2
) IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Get_Calendar';
-- <insert here your local variables declaration>
-- order by location_id is to ensure that the default calendar entry is
-- selected last.

CURSOR customer_cal IS
SELECT calendar_code
FROM   wsh_calendar_assignments
WHERE  customer_id = p_entity_id AND
	  calendar_type = 'RECEIVING' AND
	  nvl(location_id, nvl(p_location_id, -1)) = nvl(p_location_id, -1) AND
	  enabled_flag = 'Y'
ORDER BY location_id;

CURSOR org_cal IS
SELECT calendar_code
FROM   wsh_calendar_assignments
WHERE  organization_id = p_entity_id AND
	  calendar_type = 'SHIPPING' AND
	  nvl(location_id, nvl(p_location_id, -1)) = nvl(p_location_id,-1) AND
	  enabled_flag = 'Y'
ORDER BY location_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CALENDAR';
--
BEGIN
  --  Standard call to check for call compatibility
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',P_ENTITY_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , l_api_name
         ,   G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

-- BEGIN PROCEDURE LOGIC

  IF (p_entity_type = 'CUSTOMER') THEN
     OPEN  customer_cal;
     FETCH customer_cal INTO x_calendar_code;
     CLOSE customer_cal;
  ELSIF (p_entity_type = 'ORG') THEN
     OPEN  org_cal;
     FETCH org_cal INTO x_calendar_code;
     CLOSE org_cal;
  END IF;

-- END PROCEDURE LOGIC
-- report success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_Get
  ( p_count => x_msg_count
  , p_data  => x_msg_data
  );
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , '_x_'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Get_Calendar;

--========================================================================
-- PROCEDURE : Transport_Dates           PUBLIC
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_priority              'SHIP' or 'RECEIVE': which is
--                                     more important
--             p_ship_date             Date to validate
--             p_ship_assoc_type       Association type for ship location
--             p_ship_location_id      Location ID (optional)
--             p_ship_vendor_site_id   Vendor Site ID (optional)
--             p_ship_customer_site_use_id  Customer Site Use ID (optional)
--             p_ship_time_matters     Should we care about ship time?
--             p_freight_code          Carrier code (optional)
--             p_freight_org_id        Carrier Organization ID (optional)
--             p_receive_date             Date to validate
--             p_receive_assoc_type       Association type for ship location
--             p_receive_location_id   Location ID (optional)
--             p_receive_vendor_site_id   Vendor Site ID (optional)
--             p_receive_customer_site_use_id  Customer Site Use ID (optional)
--             p_receive_time_matters     Should we care about receive time?
--             x_return code           Return code
--             x_suggest_ship_date     Ship date suggestion
--             x_suggest_receive_date  Receiving date suggestion
--             p_primary_threshold     Threshold for most important date
--             p_secondary_threshold   Threshold for least important date
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Validates a shipping or receiving date, or both, against a
--             transportation calendar and against a carrier calendar
--Similar in structure to the existing Bill of Materials Workday Calendar,
--the Transportation Calendar defines the valid shipping days for a location,
--supplier, customer, or carrier, and consists of a repeating pattern of days
--on and days off and exceptions to that pattern.   Shifts associated with
--these calendars determine specific times during the day when material may be
--shipped or received.
--  This routine accepts a shipping date, or a receiving date, or both.
--Whatever dates it receives it validates against calendars, also provided as
--parameters.  If a carrier and carrier calendar are specified the date(s) are
--validated against that calendar as well.  If both ship and receive dates are
--provided, the user must also specify which date is more important, the
--ship or receive date.  The more important date is validated first. Dates may
--slip within a user-provided tolerance:  ship dates slip back, receive dates
--slip forward.  The user may also specify whether time of day is important.
--If so, dates will only validate if they are valid for that specific time.
--             Value of parameter x_return_code indicates the following:
--                0    Complete success
--                1    dates slid, within tolerance
--                2    lead time had to expand
--                3    carrier calendar fails
--                4    secondary date out of tolerance
--                5    primary date out of tolerance
--                6    error condition -- bad parameters
--             Higher-numbered error conditions take precedence.  For
--             instance, if the primary date is out of tolerance AND
--             a carrier calendar fails, return code 5 is generated
--========================================================================
PROCEDURE Transport_Dates
( p_api_version_number IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_priority           IN  VARCHAR2
, p_ship_date               IN  DATE
, p_ship_assoc_type         IN  VARCHAR2
, p_ship_location_id     IN  NUMBER       := NULL
, p_ship_vendor_site_id     IN  NUMBER       := NULL
, p_ship_customer_site_use_id     IN  NUMBER := NULL
, p_ship_time_matters       IN  BOOLEAN
, p_freight_code       IN  VARCHAR2
, p_freight_org_id     IN  NUMBER
, p_receive_date              IN DATE
, p_receive_assoc_type         IN  VARCHAR2
, p_receive_location_id     IN  NUMBER    := NULL
, p_receive_vendor_site_id     IN  NUMBER    := NULL
, p_receive_customer_site_use_id  IN  NUMBER := NULL
, p_receive_time_matters       IN  BOOLEAN
, x_return_code                   OUT NOCOPY  NUMBER
, x_suggest_ship_date             OUT NOCOPY  DATE
, x_suggest_receive_date          OUT NOCOPY  DATE
, p_primary_threshold             IN  NUMBER
, p_secondary_threshold             IN  NUMBER
) IS
l_api_version_number CONSTANT NUMBER := 1.0;
l_api_name           CONSTANT VARCHAR2(30):= 'Transport_Dates';
l_found_good_date       BOOLEAN;
l_lead_time          NUMBER;
--Added for the bug 8567091
l_primary_threshold  NUMBER;
l_suggest_ship_date  DATE;

-- <insert here your local variables declaration>
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRANSPORT_DATES';
--
BEGIN
  --  Standard call to check for call compatibility
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_PRIORITY',P_PRIORITY);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_DATE',P_SHIP_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_ASSOC_TYPE',P_SHIP_ASSOC_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_LOCATION_ID',P_SHIP_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_VENDOR_SITE_ID',P_SHIP_VENDOR_SITE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_CUSTOMER_SITE_USE_ID',P_SHIP_CUSTOMER_SITE_USE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TIME_MATTERS',P_SHIP_TIME_MATTERS);
      WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',P_FREIGHT_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_ORG_ID',P_FREIGHT_ORG_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_DATE',P_RECEIVE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_ASSOC_TYPE',P_RECEIVE_ASSOC_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_LOCATION_ID',P_RECEIVE_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_VENDOR_SITE_ID',P_RECEIVE_VENDOR_SITE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_CUSTOMER_SITE_USE_ID',P_RECEIVE_CUSTOMER_SITE_USE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_RECEIVE_TIME_MATTERS',P_RECEIVE_TIME_MATTERS);
      WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_THRESHOLD',P_PRIMARY_THRESHOLD);
      WSH_DEBUG_SV.log(l_module_name,'P_SECONDARY_THRESHOLD',P_SECONDARY_THRESHOLD);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , l_api_name
         ,   G_PKG_NAME
         )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message stack if required
  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF;

-- BEGIN PROCEDURE LOGIC
  x_suggest_ship_date := p_ship_date;
  x_suggest_receive_date := p_receive_date;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_ship_date IS NULL THEN
    IF p_receive_date IS NULL THEN
-- no dates to validate
      RAISE wsh_missing_mandatory_attr;
    ELSE
-- validate receive date
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.FIND_VALID_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
        ( p_receive_date
        , 'RECEIVING'
        , p_receive_assoc_type
        , p_receive_location_id
        , p_receive_vendor_site_id
        , p_receive_customer_site_use_id
        , p_freight_code
        , p_freight_org_id
        , x_suggest_receive_date
        , l_found_good_date
        , p_primary_threshold
        , 'BACK'
        , p_receive_time_matters
        );
      IF l_found_good_date THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.SINGLE_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_CAL_ASG_VALIDATIONS.Single_Date(
            x_suggest_receive_date
          , 'CARRIER'
          , 'CARRIER'
          , p_receive_location_id
          , p_receive_vendor_site_id
          , p_receive_customer_site_use_id
          , p_freight_code
          , p_freight_org_id
          , l_found_good_date
          , p_receive_time_matters
          );
        IF l_found_good_date THEN
          IF x_suggest_receive_date = p_receive_date THEN
            x_return_code := 0;
          ELSE
             x_return_code := 1;
          END IF;
        ELSE
            x_return_code := 3;
        END IF;
      ELSE
        x_return_code := 5;
      END IF;
    END IF;
  ELSE
    IF p_receive_date IS NULL THEN
-- validate ship date
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.FIND_VALID_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
        ( p_ship_date
        , 'SHIPPING'
        , p_ship_assoc_type
        , p_ship_location_id
        , p_ship_vendor_site_id
        , p_ship_customer_site_use_id
        , p_freight_code
        , p_freight_org_id
        , x_suggest_ship_date
        , l_found_good_date
        , p_primary_threshold
        , 'BACK'
        , p_ship_time_matters
        );
      IF l_found_good_date THEN
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.SINGLE_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_CAL_ASG_VALIDATIONS.Single_Date(
            x_suggest_ship_date
          , 'CARRIER'
          , 'CARRIER'
          , p_ship_location_id
          , p_ship_vendor_site_id
          , p_ship_customer_site_use_id
          , p_freight_code
          , p_freight_org_id
          , l_found_good_date
          , p_ship_time_matters
          );
        IF l_found_good_date THEN
          IF x_suggest_ship_date = p_ship_date THEN
            x_return_code := 0;
          ELSE
            x_return_code := 1;
          END IF;
        ELSE
            x_return_code := 3;
        END IF;
      ELSE
        x_return_code := 5;
      END IF;
    ELSE
-- Need to validate both dates
      l_lead_time := p_receive_date - p_ship_date;
      IF l_lead_time < 0 THEN
        RAISE wsh_bad_parameter;
      END IF;
      IF p_priority = 'SHIP' THEN
-- find valid ship date first
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.FIND_VALID_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --

        /*
        WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
          ( p_ship_date
          , 'SHIPPING'
          , p_ship_assoc_type
          , p_ship_location_id
          , p_ship_vendor_site_id
          , p_ship_customer_site_use_id
          , p_freight_code
          , p_freight_org_id
          , x_suggest_ship_date
          , l_found_good_date
          , p_primary_threshold
          , 'FORWARD'
          , p_ship_time_matters
          );
        IF l_found_good_date THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.FIND_VALID_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
             ( p_receive_date - (p_ship_date - x_suggest_ship_date)
             , 'RECEIVING'
             , p_receive_assoc_type
             , p_receive_location_id
             , p_receive_vendor_site_id
             , p_receive_customer_site_use_id
             , p_freight_code
             , p_freight_org_id
             , x_suggest_receive_date
             , l_found_good_date
             , p_secondary_threshold
             , 'FORWARD'
             , p_receive_time_matters
            );
          IF l_found_good_date THEN
            IF (p_receive_date - x_suggest_receive_date)
                    <=  p_secondary_threshold THEN
              IF x_suggest_receive_date - x_suggest_ship_date
                      = l_lead_time THEN
                IF x_suggest_ship_date = p_ship_date THEN
                  x_return_code := 0;
                ELSE
                  x_return_code := 1;
                END IF;
              ELSE
                x_return_code := 2;
              END IF;
            ELSE
              x_return_code := 4;
            END IF;
          ELSE
            x_return_code := 4;
          END IF;
        ELSE
          x_return_code := 5;
        END IF;
        IF x_return_code IN (0,1,2) THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.SINGLE_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_CAL_ASG_VALIDATIONS.Single_Date(
            x_suggest_ship_date
          , 'CARRIER'
          , p_ship_assoc_type
          , p_ship_location_id
          , p_ship_vendor_site_id
          , p_ship_customer_site_use_id
          , p_freight_code
          , p_freight_org_id
          , l_found_good_date
          , p_ship_time_matters
          );
          IF l_found_good_date then
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.SINGLE_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_CAL_ASG_VALIDATIONS.Single_Date(
              x_suggest_receive_date
            , 'CARRIER'
            , p_receive_assoc_type
            , p_receive_location_id
            , p_receive_vendor_site_id
            , p_receive_customer_site_use_id
            , p_freight_code
            , p_freight_org_id
            , l_found_good_date
            , p_receive_time_matters
            );
            IF l_found_good_date then
              x_return_code := x_return_code;
            ELSE
              x_return_code := 3;
            END IF;
          ELSE
            x_return_code := 3;
          END IF;
        END IF;*/
        l_suggest_ship_date := p_ship_date;
        l_primary_threshold := 0;

         --bug 8567091: Doing the Calendar validation in a loop
         --             Previously if the suggested_ship_date is not valid as per Org's Carrier Calendar,
         --             no message was displayed.Neither was a next valid date calculated.
         --             As per the bug 8567091,the nearest valid ship date as per carrier calendar
         --             should be calculated.(So Find_Valid_Date is called for carrier Calendar validation
         --             instead of Single_Date)
         --             And the new suggested ship date should again be validated against Shipping Calendar.
         --             Hence the loop.

         WHILE l_primary_threshold <= p_primary_threshold LOOP
         --{
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_suggest_ship_date',l_suggest_ship_date);
                 WSH_DEBUG_SV.log(l_module_name,'l_primary_threshold',l_primary_threshold);
             END IF;

             WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
               ( l_suggest_ship_date
               , 'SHIPPING'
               , p_ship_assoc_type
               , p_ship_location_id
               , p_ship_vendor_site_id
               , p_ship_customer_site_use_id
               , p_freight_code
               , p_freight_org_id
               , x_suggest_ship_date
               , l_found_good_date
               , (p_primary_threshold - l_primary_threshold )
               , 'FORWARD'
               , p_ship_time_matters
               );
             IF l_found_good_date THEN
             --{
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'x_suggest_ship_date',x_suggest_ship_date);
                 END IF;

                 l_primary_threshold :=  l_primary_threshold + (x_suggest_ship_date - l_suggest_ship_date);
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_primary_threshold',l_primary_threshold);
                 END IF;
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.FIND_VALID_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
                    ( p_receive_date - (p_ship_date - x_suggest_ship_date)
                    , 'RECEIVING'
                    , p_receive_assoc_type
                    , p_receive_location_id
                    , p_receive_vendor_site_id
                    , p_receive_customer_site_use_id
                    , p_freight_code
                    , p_freight_org_id
                    , x_suggest_receive_date
                    , l_found_good_date
                    , p_secondary_threshold
                    , 'FORWARD'
                    , p_receive_time_matters
                   );
                 IF l_found_good_date THEN
                 --{
                     IF (p_receive_date - x_suggest_receive_date)
                               <=  p_secondary_threshold THEN
                         IF x_suggest_receive_date - x_suggest_ship_date
                                 = l_lead_time THEN
                             IF x_suggest_ship_date = p_ship_date THEN
                                 x_return_code := 0;
                             ELSE
                                 x_return_code := 1;
                             END IF;
                         ELSE
                             x_return_code := 2;
                         END IF;
                     ELSE
                         x_return_code := 4;
                         EXIT;
                     END IF;
                 ELSE
                     x_return_code := 4;
                     EXIT;
                 --}
                 END IF;
             ELSE
                 x_return_code := 5;
                 --Bug 8567091: Resetting suggested_receive_date to 'p_receive_date',
                 --             in the case where no suggested Ship date is not found in 10 days
                 x_suggest_receive_date := p_receive_date;
                 EXIT;
             --}
             END IF;
             IF x_return_code IN (0,1,2) THEN
                 --
                 -- Debug Statements
                 --
                 l_suggest_ship_date := x_suggest_ship_date;
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'l_suggest_ship_date',l_suggest_ship_date);
                     WSH_DEBUG_SV.log(l_module_name,'l_primary_threshold',l_primary_threshold);
                 END IF;
                 --Bug 8567091 :  'Find_Valid_Date' is called for carrier Calendar validation instead of 'Single_Date'

                 WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
                 ( l_suggest_ship_date
                 , 'CARRIER'
                 , p_ship_assoc_type
                 , p_ship_location_id
                 , p_ship_vendor_site_id
                 , p_ship_customer_site_use_id
                 , p_freight_code
                 , p_freight_org_id
                 , x_suggest_ship_date
                 , l_found_good_date
                 , (p_primary_threshold  - l_primary_threshold)
                 , 'FORWARD'
                 , p_ship_time_matters
                 );
                 IF l_found_good_date then

                     IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'x_suggest_ship_date',x_suggest_ship_date);
                     END IF;

                     IF x_suggest_ship_date = l_suggest_ship_date THEN
                         --
                         -- Debug Statements
                         --
                         IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.SINGLE_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
                         END IF;
                         --
                         WSH_CAL_ASG_VALIDATIONS.Single_Date(
                           x_suggest_receive_date
                         , 'CARRIER'
                         , p_receive_assoc_type
                         , p_receive_location_id
                         , p_receive_vendor_site_id
                         , p_receive_customer_site_use_id
                         , p_freight_code
                         , p_freight_org_id
                         , l_found_good_date
                         , p_receive_time_matters
                         );
                         IF l_found_good_date then
                             x_return_code := x_return_code;
                         ELSE
                             x_return_code := 3;
                         END IF;
                         EXIT;
                     ELSE
                         l_primary_threshold :=  l_primary_threshold + (x_suggest_ship_date - l_suggest_ship_date);
                         l_suggest_ship_date := x_suggest_ship_date ;
                         x_return_code := 3;
                     END IF;
                 ELSE
                    --Bug 8567091 : Return code as 5 when a valid date in Org's carrier calendar is not
                    --              found with in the threshold(10 days)
                    x_return_code := 5;
                    --Bug 8567091: Resetting suggested_receive_date to 'p_receive_date',
                    --             in the case where no suggested Ship date is not found in 10 days
                    x_suggest_receive_date := p_receive_date;
                    EXIT;
                 END IF;
             END IF;
         --}
         END LOOP;

      ELSIF p_priority = 'RECEIVE' THEN
-- find valid receive date first
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.FIND_VALID_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
          ( p_receive_date
          , 'RECEIVING'
          , p_receive_assoc_type
          , p_receive_location_id
          , p_receive_vendor_site_id
          , p_receive_customer_site_use_id
          , p_freight_code
          , p_freight_org_id
          , x_suggest_receive_date
          , l_found_good_date
          , p_primary_threshold
          , 'BACK'
          , p_receive_time_matters
          );
        IF l_found_good_date THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.FIND_VALID_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_CAL_ASG_VALIDATIONS.Find_Valid_Date
             ( p_ship_date - (p_receive_date - x_suggest_receive_date)
             , 'SHIPPING'
             , p_ship_assoc_type
             , p_ship_location_id
             , p_ship_vendor_site_id
             , p_ship_customer_site_use_id
             , p_freight_code
             , p_freight_org_id
             , x_suggest_ship_date
             , l_found_good_date
             , p_secondary_threshold
             , 'BACK'
             , p_ship_time_matters
            );
          IF l_found_good_date THEN
            IF (p_ship_date - x_suggest_ship_date)
                    <=  p_secondary_threshold THEN
              IF x_suggest_receive_date - x_suggest_ship_date
                      = l_lead_time THEN
                IF x_suggest_ship_date = p_ship_date THEN
                  x_return_code := 0;
                ELSE
                  x_return_code := 1;
                END IF;
              ELSE
                x_return_code := 2;
              END IF;
            ELSE
              x_return_code := 4;
            END IF;
          ELSE
            x_return_code := 4;
          END IF;
        ELSE
          x_return_code := 5;
        END IF;
        IF x_return_code IN (0,1,2) THEN
          --
          -- Debug Statements
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.SINGLE_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_CAL_ASG_VALIDATIONS.Single_Date(
            x_suggest_ship_date
          , 'CARRIER'
          , p_ship_assoc_type
          , p_ship_location_id
          , p_ship_vendor_site_id
          , p_ship_customer_site_use_id
          , p_freight_code
          , p_freight_org_id
          , l_found_good_date
          , p_ship_time_matters
          );
          IF l_found_good_date then
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.SINGLE_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            WSH_CAL_ASG_VALIDATIONS.Single_Date(
              x_suggest_receive_date
            , p_receive_assoc_type
            , 'CARRIER'
            , p_receive_location_id
            , p_receive_vendor_site_id
            , p_receive_customer_site_use_id
            , p_freight_code
            , p_freight_org_id
            , l_found_good_date
            , p_receive_time_matters
            );
            IF l_found_good_date then
              x_return_code := x_return_code;
            ELSE
              x_return_code := 3;
            END IF;
          ELSE
            x_return_code := 3;
          END IF;
        END IF;
      ELSE
        RAISE wsh_bad_parameter;
      END IF;
    END IF;
  END IF;
-- END PROCEDURE LOGIC
-- report success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Count_And_Get
  ( p_count => x_msg_count
  , p_data  => x_msg_data
  );
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
-- If we get no calendars to validate against, return success
  WHEN wsh_missing_mandatory_attr THEN
    x_return_code := 0;
-- If we get bad parameters, return error
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_MISSING_MANDATORY_ATTR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_MISSING_MANDATORY_ATTR');
END IF;
--
  WHEN wsh_bad_parameter THEN
    x_return_code := 6;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_BAD_PARAMETER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_BAD_PARAMETER');
END IF;
--
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , '_x_'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Transport_Dates;
--========================================================================
-- PROCEDURE : Find_Valid_Date    PRIVATE
-- PARAMETERS:
--             p_input_date            Date to validate
--             p_calendar_type         Calendar type -- SHIPPING, RECEIVING, or
--                                     CARRIER
--             p_location_id        Location ID (optional)
--             p_vendor_site_id        Vendor Site ID (optional)
--             p_customer_site_use_id  Customer Site Use ID (optional)
--             p_carrier_code          Carrier code (optional)
--             p_carrier_org_id        Carrier Organization ID (optional)
--             x_suggest_date          Suggested valid date
--             x_success               Did we find a date?
--             p_threshold             Number of dates to try before failure
--             p_which_way             search FORWARD or BACK
--             p_time_matters          Is time important for this date?
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Searches for a valid date near a given date by checking
--             nearby dates against a given calendar.  Decrement if
--             finding ship date, increment if finding receive date
--========================================================================
PROCEDURE Find_Valid_Date
( p_input_date            IN  DATE
, p_calendar_type         IN  VARCHAR2
, p_assoc_type            IN  VARCHAR2
, p_location_id        IN  NUMBER
, p_vendor_site_id        IN  NUMBER
, p_customer_site_use_id  IN  NUMBER
, p_freight_code          IN  VARCHAR2
, p_freight_org_id        IN  NUMBER
, x_suggest_date          OUT NOCOPY  DATE
, x_success               OUT NOCOPY  BOOLEAN
, p_threshold             IN  NUMBER
, p_which_way             IN  VARCHAR2
, p_time_matters          IN  BOOLEAN
) IS
l_api_name           CONSTANT VARCHAR2(30):= 'Find_Valid_Date';
l_number_tried       NUMBER := 0;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FIND_VALID_DATE';
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
      WSH_DEBUG_SV.log(l_module_name,'P_INPUT_DATE',P_INPUT_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_CALENDAR_TYPE',P_CALENDAR_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_ASSOC_TYPE',P_ASSOC_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_SITE_ID',P_VENDOR_SITE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_SITE_USE_ID',P_CUSTOMER_SITE_USE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',P_FREIGHT_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_ORG_ID',P_FREIGHT_ORG_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_THRESHOLD',P_THRESHOLD);
      WSH_DEBUG_SV.log(l_module_name,'P_WHICH_WAY',P_WHICH_WAY);
      WSH_DEBUG_SV.log(l_module_name,'P_TIME_MATTERS',P_TIME_MATTERS);
  END IF;
  --
  x_success := FALSE;
  WHILE nvl(x_success,FALSE) = FALSE AND l_number_tried <= p_threshold LOOP
    IF p_which_way = 'FORWARD' THEN
      x_suggest_date := p_input_date + l_number_tried;
    ELSE
      x_suggest_date := p_input_date - l_number_tried;
    END IF;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_CAL_ASG_VALIDATIONS.SINGLE_DATE',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_CAL_ASG_VALIDATIONS.Single_Date(
        x_suggest_date
      , p_calendar_type
      , p_assoc_type
      , p_location_id
      , p_vendor_site_id
      , p_customer_site_use_id
      , p_freight_code
      , p_freight_org_id
      , x_success
      , p_time_matters
      );

    l_number_tried := l_number_tried + 1;
  END LOOP;

  IF NOT x_success THEN
    x_suggest_date := p_input_date;
  END IF;
  -- <end of API logic>
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
END Find_Valid_Date;
--========================================================================
-- PROCEDURE : Single_Date    PRIVATE
-- PARAMETERS:
--             p_date                  Date to validate
--             p_calendar_type         Calendar type -- SHIPPING, RECEIVING, or
--                                     CARRIER
--             p_assoc_type            Type of site
--             p_location_id        Location ID (optional)
--             p_vendor_site_id        Vendor Site ID (optional)
--             p_customer_site_use_id  Customer Site Use ID (optional)
--             p_freight_code          Carrier code (optional)
--             p_freight_org_id        Carrier Organization ID (optional)
--             p_date_is_valid         Return information
--             p_time_matters          Is time important for this date?
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Validates a shipping or receiving date against a shipping
--             calendar and against a carrier calendar
--========================================================================
PROCEDURE Single_Date
( p_date                  IN  DATE
, p_calendar_type         IN  VARCHAR2
, p_assoc_type            IN  VARCHAR2
, p_location_id           IN  NUMBER
, p_vendor_site_id        IN  NUMBER
, p_customer_site_use_id  IN  NUMBER
, p_freight_code          IN  VARCHAR2
, p_freight_org_id        IN  NUMBER
, p_date_is_valid         OUT NOCOPY  BOOLEAN
, p_time_matters          IN  BOOLEAN
)
IS
  l_api_name           CONSTANT VARCHAR2(30):= 'Single_Date';
  l_calendar_code      VARCHAR2(10);
  l_err_code           NUMBER;
  l_err_meg            VARCHAR(200);
  l_enabled_flag       VARCHAR2(1);
  l_entity_type        VARCHAR2(12);
  l_site_id            NUMBER;
  l_freight_code       VARCHAR2(30);--6156495:Local variable added

CURSOR c_get_calendar_code IS
SELECT WCA.CALENDAR_CODE,
       WCA.ENABLED_FLAG
  FROM WSH_CALENDAR_ASSIGNMENTS WCA ,
       PO_VENDORS POV ,
       PO_VENDOR_SITES_all POVS ,
       hr_organization_units HR
 WHERE WCA.ASSOCIATION_TYPE = 'VENDOR_SITE'
   AND WCA.VENDOR_SITE_ID = POVS.VENDOR_SITE_ID
   AND POV.VENDOR_ID = POVS.VENDOR_ID
   AND hr.organization_id = povs.org_id
   ---
   AND 'VENDOR' = l_entity_type
   AND WCA.CALENDAR_TYPE = p_calendar_type
   AND WCA.ASSOCIATION_TYPE = p_assoc_type
   AND NVL(WCA.FREIGHT_CODE,'All') = NVL(p_freight_code,'All')
   AND ( POVS.VENDOR_SITE_ID = l_site_id OR
         WCA.LOCATION_ID = p_location_id)
UNION ALL

SELECT WCA.CALENDAR_CODE,
       WCA.ENABLED_FLAG
  FROM WSH_CALENDAR_ASSIGNMENTS WCA,
       hz_relationships rel,
       hz_party_sites hps,
       hz_party_site_uses hpsu,
       wsh_locations wl
 WHERE WCA.ASSOCIATION_TYPE = 'VENDOR_LOCATION'
   AND WCA.LOCATION_ID = WL.WSH_LOCATION_ID
   AND hps.party_id = rel.subject_id
   AND hps.party_site_id = hpsu.party_site_id
   AND hps.location_id = wl.wsh_location_id
   AND site_use_type = 'SUPPLIER_SHIP_FROM'
   AND rel.relationship_type = 'POS_VENDOR_PARTY'
   AND rel.object_table_name = 'PO_VENDORS'
   AND rel.object_type = 'POS_VENDOR'
   AND rel.subject_table_name = 'HZ_PARTIES'
   AND rel.subject_type = 'ORGANIZATION'
   ----
   AND 'VENDOR' = l_entity_type
   AND WCA.CALENDAR_TYPE = p_calendar_type
   AND WCA.ASSOCIATION_TYPE = p_assoc_type
   AND NVL(WCA.FREIGHT_CODE,'All') = NVL(p_freight_code,'All')
   AND ( WL.WSH_LOCATION_ID = l_site_id OR
         WCA.LOCATION_ID = p_location_id)
UNION ALL
SELECT WCA.CALENDAR_CODE,
       WCA.ENABLED_FLAG
  FROM HZ_CUST_ACCT_SITES_ALL HCAS,
       HZ_CUST_SITE_USES_ALL HCSU,
       HZ_PARTY_SITES HPS,
       HZ_CUST_ACCOUNTS HCA,
       WSH_LOCATIONS WLO,
       WSH_CALENDAR_ASSIGNMENTS WCA
 WHERE HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
   and HCAS.PARTY_SITE_ID = HPS.PARTY_SITE_ID
   AND HCAS.cust_account_id = hca.cust_account_id
   AND HPS.LOCATION_ID = WLO.source_location_id(+)
   AND WLO.location_source_code(+) ='HZ'
   AND WCA.CUSTOMER_SITE_USE_ID = HCSU.SITE_USE_ID
   AND WCA.ASSOCIATION_TYPE = 'CUSTOMER_SITE'
   ----
   AND 'CUSTOMER' = l_entity_type
   AND WCA.CALENDAR_TYPE = p_calendar_type
   AND WCA.ASSOCIATION_TYPE = p_assoc_type
--   AND NVL(WCA.FREIGHT_CODE,'All') = NVL(p_freight_code,'All')--6156495
   AND NVL(WCA.FREIGHT_CODE,'All') = NVL(l_freight_code,'All')
   AND ( HCSU.SITE_USE_ID = l_site_id OR
         WCA.LOCATION_ID = p_location_id)
UNION ALL

SELECT WCA.CALENDAR_CODE,
       WCA.ENABLED_FLAG
  FROM WSH_CALENDAR_ASSIGNMENTS WCA ,
       WSH_LOCATIONS WLO
 WHERE WCA.ASSOCIATION_TYPE = 'HR_LOCATION'
   AND WCA.LOCATION_ID = WLO.WSH_LOCATION_ID(+)
   ----
   AND 'ORGANIZATION' = l_entity_type
   AND WCA.CALENDAR_TYPE = p_calendar_type
   AND WCA.ASSOCIATION_TYPE = p_assoc_type
--   AND NVL(WCA.FREIGHT_CODE,'All') = NVL(p_freight_code,'All')---6156495
   AND NVL(WCA.FREIGHT_CODE,'All') = NVL(l_freight_code,'All')
   AND (WLO.WSH_LOCATION_ID = l_site_id OR
        WCA.LOCATION_ID =p_location_id)
UNION ALL
SELECT WCA.CALENDAR_CODE,
       WCA.ENABLED_FLAG
  FROM WSH_CALENDAR_ASSIGNMENTS WCA ,
       HZ_PARTY_SITES HPS
 WHERE WCA.ASSOCIATION_TYPE = 'CARRIER_SITE'
   AND WCA.CARRIER_ID = HPS.PARTY_ID
   AND WCA.CARRIER_SITE_ID = HPS.PARTY_SITE_ID
   ----
   AND 'CARRIER' = l_entity_type
   AND WCA.CALENDAR_TYPE = p_calendar_type
   AND WCA.ASSOCIATION_TYPE = p_assoc_type
   AND NVL(WCA.FREIGHT_CODE,'All') = NVL(p_freight_code,'All')
   AND (WCA.CARRIER_SITE_ID = l_site_id OR
        WCA.LOCATION_ID =p_location_id);

--Bug 8855773:Added the cursor, that would get the default shipping/receiving/carrier Calendar
--            defined for a particular customer or an Organization.
CURSOR c_get_calendar_code_wo_loc IS
    SELECT WCA.CALENDAR_CODE,WCA.ENABLED_FLAG
    FROM HZ_CUST_ACCT_SITES_ALL  HCAS,
         HZ_CUST_SITE_USES_ALL HCSU,
         HZ_CUST_ACCOUNTS HCA,
         HZ_PARTY_SITES HPS,
         WSH_LOCATIONS WLO,
         wsh_calendar_assignments WCA
    WHERE HCAS.party_site_id =  HPS.party_site_id
    AND   HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
    AND   HCAS.cust_account_id = hca.cust_account_id
    AND   (HCSU.SITE_USE_ID = l_site_id OR
           HPS.location_id = p_location_id)
    AND   WCA.customer_id = HCAS.cust_account_id
    AND   HPS.LOCATION_ID = WLO.source_location_id(+)
    AND   WLO.location_source_code(+) ='HZ'
    AND   WCA.CALENDAR_TYPE = p_calendar_type
    AND   wca.location_id IS NULL
    AND   WCA.ASSOCIATION_TYPE =  'CUSTOMER'
    AND   'CUSTOMER' = l_entity_type
    AND   'CUSTOMER_SITE' = p_assoc_type
    AND   NVL(WCA.FREIGHT_CODE,'All') = NVL(l_freight_code,'All')

    UNION ALL

    SELECT WCA.CALENDAR_CODE,
           WCA.ENABLED_FLAG
      FROM WSH_CALENDAR_ASSIGNMENTS WCA ,
           WSH_LOCATIONS WLO,
           HR_ORGANIZATION_UNITS HOU
    WHERE HOU.LOCATION_ID = WLO.source_LOCATION_ID
      And wlo.location_source_code='HR'
      AND WLO.wsh_location_id = p_location_id
      AND WCA.organization_id = HOU.organization_id
      AND 'ORGANIZATION' = l_entity_type
      AND WCA.CALENDAR_TYPE = p_calendar_type
      AND WCA.ASSOCIATION_TYPE = 'ORGANIZATION'
      AND 'HR_LOCATION' = p_assoc_type
      AND NVL(WCA.FREIGHT_CODE,'All') = NVL(l_freight_code,'All');








  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SINGLE_DATE';
  --
BEGIN
  -- <begin procedure logic>
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
      WSH_DEBUG_SV.log(l_module_name,'P_DATE',P_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_CALENDAR_TYPE',P_CALENDAR_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_ASSOC_TYPE',P_ASSOC_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_SITE_ID',P_VENDOR_SITE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_SITE_USE_ID',P_CUSTOMER_SITE_USE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CODE',P_FREIGHT_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_ORG_ID',P_FREIGHT_ORG_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_TIME_MATTERS',P_TIME_MATTERS);
  END IF;
  --
  l_enabled_flag   := 'N';
  l_calendar_code  := NULL;
  l_freight_code   := NULL;--6156495

  IF p_assoc_type = 'CUSTOMER_SITE' THEN
    l_entity_type := 'CUSTOMER';
    l_site_id     := p_customer_site_use_id;
    IF p_calendar_type ='CARRIER' THEN
      l_freight_code:= p_freight_code;--6156495
    END IF;
  ELSIF p_assoc_type = 'HR_LOCATION' THEN
    l_entity_type := 'ORGANIZATION';
    l_site_id     := p_location_id;
    IF p_calendar_type ='CARRIER' THEN
      l_freight_code:= p_freight_code;--6156495
    END IF;
  ELSIF p_assoc_type = 'CARRIER_SITE' THEN
    l_entity_type := 'CARRIER';
    l_freight_code:= p_freight_code;--6156495
  ELSIF p_assoc_type in ('VENDOR_SITE', 'VENDOR_LOCATION') THEN
    l_entity_type := 'VENDOR';
    IF p_assoc_type = 'VENDOR_SITE' THEN
      l_site_id   := p_vendor_site_id;
    ELSE
      l_site_id   := p_location_id;
    END IF;
  END IF;

  OPEN c_get_calendar_code;
  FETCH c_get_calendar_code INTO l_calendar_code, l_enabled_flag;
  --Bug 8855773:When no calendar association is found, for the given location,
  --            should derive the default calendar at the higher level.
  IF c_get_calendar_code%NOTFOUND THEN
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Getting default calendar for Customer/organization as no cal association is found for the location.');
      END IF;

      OPEN c_get_calendar_code_wo_loc;
      FETCH c_get_calendar_code_wo_loc INTO l_calendar_code, l_enabled_flag;
      CLOSE c_get_calendar_code_wo_loc;
  END IF;

  CLOSE c_get_calendar_code;

  p_date_is_valid := TRUE;

  IF l_calendar_code IS NOT NULL AND l_enabled_flag = 'Y' THEN
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'l_calendar_code '||l_calendar_code);
    END IF;
    IF p_time_matters THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit BOM_CALENDAR_API_BK.CHECK_WORKING_SHIFT',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      p_date_is_valid := BOM_CALENDAR_API_BK.Check_Working_Shift(
          l_calendar_code
        , p_date
        , l_err_code
        , l_err_meg);
    ELSE
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit BOM_CALENDAR_API_BK.CHECK_WORKING_DAY',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      BOM_CALENDAR_API_BK.Check_Working_Day(
        l_calendar_code
        ,p_date
        ,p_date_is_valid
        ,l_err_code
        ,l_err_meg);
    END IF;
  END IF;

  -- <end procedure logic>
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_date_is_valid := TRUE;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
    END IF;
    --
  WHEN OTHERS THEN
    RAISE;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END Single_Date;
END WSH_CAL_ASG_VALIDATIONS;

/
