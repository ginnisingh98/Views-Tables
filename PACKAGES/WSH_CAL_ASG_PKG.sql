--------------------------------------------------------
--  DDL for Package WSH_CAL_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CAL_ASG_PKG" AUTHID CURRENT_USER AS
-- $Header: WSHCAPKS.pls 115.7 2003/07/22 07:48:53 msutar ship $

TYPE CalAsgRecType IS RECORD (
CALENDAR_CODE                   VARCHAR2(10),
CALENDAR_TYPE                   VARCHAR2(10),
ENABLED_FLAG                    VARCHAR2(1),
ASSOCIATION_TYPE                VARCHAR2(20),
LOCATION_ASSOCIATION_ID         NUMBER,
ORGANIZATION_ID                 NUMBER,
VENDOR_ID                       NUMBER,
CUSTOMER_ID                     NUMBER,
CUSTOMER_SITE_USE_ID            NUMBER,
FREIGHT_CODE                    VARCHAR2(25),
FREIGHT_ORG_ID                  NUMBER,
HR_LOCATION_ID                  NUMBER,
VENDOR_SITE_ID                  NUMBER,
ATTRIBUTE_CATEGORY              VARCHAR2(150),
ATTRIBUTE1                      VARCHAR2(150),
ATTRIBUTE2                      VARCHAR2(150),
ATTRIBUTE3                      VARCHAR2(150),
ATTRIBUTE4                      VARCHAR2(150),
ATTRIBUTE5                      VARCHAR2(150),
ATTRIBUTE6                      VARCHAR2(150),
ATTRIBUTE7                      VARCHAR2(150),
ATTRIBUTE8                      VARCHAR2(150),
ATTRIBUTE9                      VARCHAR2(150),
ATTRIBUTE10                     VARCHAR2(150),
ATTRIBUTE11                     VARCHAR2(150),
ATTRIBUTE12                     VARCHAR2(150),
ATTRIBUTE13                     VARCHAR2(150),
ATTRIBUTE14                     VARCHAR2(150),
ATTRIBUTE15                     VARCHAR2(150),
LOCATION_ID                     NUMBER,
CARRIER_ID                      NUMBER,
CARRIER_SITE_ID                 NUMBER
);

--===================
-- PROCEDURES
--===================
--========================================================================
-- PROCEDURE : Create_Cal_Asg         PUBLIC
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Sets up a transportation calendar with a location, vendor,
--             customer, org, or carrier
--========================================================================
PROCEDURE Create_Cal_Asg
( p_api_version_number      IN  NUMBER
, p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
, p_cal_asg_info            IN  CalAsgRecType DEFAULT NULL
, x_return_status           OUT NOCOPY  VARCHAR2
, x_msg_count               OUT NOCOPY  NUMBER
, x_msg_data                OUT NOCOPY  VARCHAR2
, x_Calendar_Aassignment_Id OUT NOCOPY     NUMBER
);

--========================================================================
-- PROCEDURE : Update_Cal_Asg            PUBLIC
-- PARAMETERS: p_api_version_number    known api versionerror buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_calendar_assignment_id  Primary Key
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Updates the calendar code for an association
--========================================================================
PROCEDURE Update_Cal_Asg
( p_api_version_number    IN  NUMBER
, p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
, p_calendar_asgmt_id     IN  NUMBER
, p_cal_asg_info          IN  CalAsgRecType DEFAULT NULL
, x_return_status         OUT NOCOPY  VARCHAR2
, x_msg_count             OUT NOCOPY  NUMBER
, x_msg_data              OUT NOCOPY  VARCHAR2
);
--========================================================================
-- PROCEDURE : Lock_Cal_Asg            PUBLIC
-- PARAMETERS: p_Calendar_assignment_id  primary key
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Locks a row in the WSH_CALENDAR_ASSIGNMENTS table
--========================================================================
PROCEDURE Lock_Cal_Asg
( p_Calendar_assignment_id     IN  NUMBER
, p_cal_asg_info               IN  CalAsgRecType DEFAULT NULL
);
--========================================================================
-- PROCEDURE : Delete_Cal_Asg            PUBLIC
-- PARAMETERS: p_api_version_number      known api versionerror buffer
--             p_init_msg_list           FND_API.G_TRUE to reset list
--             x_return_status           return status
--             x_msg_count               number of messages in the list
--             x_msg_data                text of messages
--             p_calendar_assignment_id  primary key
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Deletes a calendar assignment.
--                      The order in which it looks at the parameters
--                      are:
--                      - p_rowid
--                      - p_calendar_assignment_id
--========================================================================
PROCEDURE Delete_Cal_Asg
( p_api_version_number IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_calendar_assignment_id IN  NUMBER
);
END WSH_CAL_ASG_PKG;

 

/
