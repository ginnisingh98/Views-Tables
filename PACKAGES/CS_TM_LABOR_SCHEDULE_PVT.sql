--------------------------------------------------------
--  DDL for Package CS_TM_LABOR_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_TM_LABOR_SCHEDULE_PVT" AUTHID CURRENT_USER  AS
/* $Header: csxvtmss.pls 120.1 2006/02/09 18:05:55 mviswana noship $ */


-- PL/SQL Specification
-- Datastructure Definitions

-- Time and Material Labor Schedule record type
TYPE TM_SCHEDULE_REC_TYPE IS RECORD
( TM_LABOR_SCHEDULE_ID 		NUMBER,
  BUSINESS_PROCESS_ID           NUMBER,
  START_TIME                    DATE,
  END_TIME                      DATE,
  MONDAY_FLAG                   VARCHAR2(1),
  TUESDAY_FLAG                  VARCHAR2(1),
  WEDNESDAY_FLAG                VARCHAR2(1),
  THURSDAY_FLAG                 VARCHAR2(1),
  FRIDAY_FLAG                   VARCHAR2(1),
  SATURDAY_FLAG                 VARCHAR2(1),
  SUNDAY_FLAG                   VARCHAR2(1),
  HOLIDAY_FLAG                  VARCHAR2(1),
  INVENTORY_ITEM_ID             NUMBER,
  ATTRIBUTE_CATEGORY            VARCHAR2(30),
  ATTRIBUTE1                    VARCHAR2(240),
  ATTRIBUTE2                    VARCHAR2(240),
  ATTRIBUTE3                    VARCHAR2(240),
  ATTRIBUTE4                    VARCHAR2(240),
  ATTRIBUTE5                    VARCHAR2(240),
  ATTRIBUTE6                    VARCHAR2(240),
  ATTRIBUTE7                    VARCHAR2(240),
  ATTRIBUTE8                    VARCHAR2(240),
  ATTRIBUTE9                    VARCHAR2(240),
  ATTRIBUTE10                   VARCHAR2(240),
  ATTRIBUTE11                   VARCHAR2(240),
  ATTRIBUTE12                   VARCHAR2(240),
  ATTRIBUTE13                   VARCHAR2(240),
  ATTRIBUTE14                   VARCHAR2(240),
  ATTRIBUTE15                   VARCHAR2(240)
);

 TYPE TM_SCHEDULE_TBL_TYPE IS TABLE OF TM_SCHEDULE_REC_TYPE INDEX BY BINARY_INTEGER;
-- Time and Material Labor Coverage record type
TYPE TM_COVERAGE_REC_TYPE IS RECORD
( LABOR_START_DATE_TIME         DATE,
  LABOR_END_DATE_TIME           DATE,
  INVENTORY_ITEM_ID             NUMBER
);

 TYPE TM_COVERAGE_TBL_TYPE IS TABLE OF TM_COVERAGE_REC_TYPE INDEX BY BINARY_INTEGER;

-- Global variable
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CS_TM_LABOR_SCHEDULE_PVT';

-- API specifications

-- Procedure to validate that a labor schedule is not overlapping with other existing                                                 -- labor schedules for a specific business process.
-- Note: The labor schedule being validated may not exist in the TM Labor Schedule                                                    -- Table


PROCEDURE VALIDATE_SCHEDULE_OVERLAP(
   P_LABOR_SCHEDULE_TBL IN TM_SCHEDULE_TBL_TYPE,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY NUMBER,
   X_MSG_DATA           OUT NOCOPY VARCHAR2,
   P_API_VERSION        IN NUMBER,
   P_INIT_MSG_LIST      IN VARCHAR2 := FND_API.G_FALSE
);

-- Procedure to validate if there is a completed labor schedule defines for a specific business                                       -- process.
-- Note: Passing in a complete set of records each represents schedule line from the TM Labor                                         -- Schedule Setup UI for a specific business process

PROCEDURE VALIDATE_SCHEDULE_MISSING(
   P_LABOR_SCHEDULE_TBL IN TM_SCHEDULE_TBL_TYPE,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY NUMBER,
   X_MSG_DATA           OUT NOCOPY VARCHAR2,
   P_API_VERSION        IN  NUMBER,
   P_INIT_MSG_LIST      IN  VARCHAR2 := FND_API.G_FALSE
);

-- Procedure to break down a service debrief labor activity into several labor coverage time segments                                 -- based on the time and material labor schedule

PROCEDURE GET_LABOR_COVERAGES(
   P_BUSINESS_PROCESS_ID IN NUMBER,
   P_ACTIVITY_START_DATE_TIME IN         DATE,
   P_ACTIVITY_END_DATE_TIME   IN         DATE,
   X_LABOR_COVERAGE_TBL       OUT NOCOPY TM_COVERAGE_TBL_TYPE,
   X_RETURN_STATUS            OUT NOCOPY VARCHAR2,
   X_MSG_COUNT                OUT NOCOPY NUMBER,
   X_MSG_DATA                 OUT NOCOPY VARCHAR2,
   P_API_VERSION              IN         NUMBER,
   P_INIT_MSG_LIST            IN         VARCHAR2
);


END CS_TM_LABOR_SCHEDULE_PVT;

 

/
