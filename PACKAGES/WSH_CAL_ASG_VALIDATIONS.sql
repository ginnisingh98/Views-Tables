--------------------------------------------------------
--  DDL for Package WSH_CAL_ASG_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CAL_ASG_VALIDATIONS" AUTHID CURRENT_USER AS
-- $Header: WSHCAVLS.pls 120.0.12010000.1 2008/07/29 05:58:48 appldev ship $

/*+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     WSHCAVLS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Validation API for transportation calendar                        |
--|                                                                       |
--| HISTORY                                                               |
--|     06/29/99 dmay            Created                                  |
--+======================================================================*/
--Similar in structure to the existing Bill of Materials Workday Calendar,
--the Transportation Calendar defines the valid shipping days for a location,
--supplier, customer, or carrier, and consists of a repeating pattern of days
--on and days off and exceptions to that pattern.   Shifts associated with
--these calendars determine specific times during the day when material may be
--shipped or received.
--===================
-- PROCEDURES
--===================
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
, x_calendar_code OUT NOCOPY  VARCHAR2);


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
--             p_ship_time_matters  Flag:  is time important in ship date?
--             p_freight_code          Carrier code (optional)
--             p_freight_org_id        Carrier Organization ID (optional)
--             p_receive_date             Date to validate
--             p_receive_assoc_type       Association type for ship location
--             p_receive_location_id   Location ID (optional)
--             p_receive_vendor_site_id   Vendor Site ID (optional)
--             p_receive_customer_site_use_id  Customer Site Use ID (optional)
--             p_receive_time_matters  Flag:  is time important in receive date?
--             x_return code           Return code
--             x_suggest_ship_date     Ship date suggestion
--             x_suggest_receive_date  Receiving date suggestion
--             p_primary_threshold     Threshold for most important date
--             p_secondary_threshold   Threshold for least important date
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Validates a shipping or receiving date, or both, against a
--             transportation calendar and against a carrier calendar
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
, p_primary_threshold                     IN NUMBER
, p_secondary_threshold                     IN NUMBER
);
END WSH_CAL_ASG_VALIDATIONS;

/
