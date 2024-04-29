--------------------------------------------------------
--  DDL for Package MRP_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: MRPSGLBS.pls 115.2 99/07/16 12:37:22 porting ship $ */

--  Procedure Get_Entities_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  entity constants.
--
--  DO NOT MODIFY

PROCEDURE Get_Entities_Tbl;

--  Product entity constants.

--  START GEN entities
G_ENTITY_ALL                   CONSTANT VARCHAR2(30) := 'ALL';
G_ENTITY_FLOW_SCHEDULE         CONSTANT VARCHAR2(30) := 'FLOW_SCHEDULE';
G_ENTITY_ASSIGNMENT_SET        CONSTANT VARCHAR2(30) := 'ASSIGNMENT_SET';
G_ENTITY_ASSIGNMENT            CONSTANT VARCHAR2(30) := 'ASSIGNMENT';
G_ENTITY_SOURCING_RULE         CONSTANT VARCHAR2(30) := 'SOURCING_RULE';
G_ENTITY_RECEIVING_ORG         CONSTANT VARCHAR2(30) := 'RECEIVING_ORG';
G_ENTITY_SHIPPING_ORG          CONSTANT VARCHAR2(30) := 'SHIPPING_ORG';
--  END GEN entities

--  Operations.

G_OPR_CREATE	    CONSTANT	VARCHAR2(30) := 'CREATE';
G_OPR_UPDATE	    CONSTANT	VARCHAR2(30) := 'UPDATE';
G_OPR_DELETE	    CONSTANT	VARCHAR2(30) := 'DELETE';
G_OPR_LOCK	    CONSTANT	VARCHAR2(30) := 'LOCK';
G_OPR_NONE	    CONSTANT	VARCHAR2(30) := FND_API.G_MISS_CHAR;

--  Max number of defaulting tterations.

G_MAX_DEF_ITERATIONS          CONSTANT NUMBER:= 5;

--  Index table type used by JVC controllers.

TYPE Index_Tbl_Type IS TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;

--  API Operation control flags.

TYPE Control_Rec_Type IS RECORD
(   controlled_operation          BOOLEAN := FALSE
,   default_attributes            BOOLEAN := TRUE
,   change_attributes             BOOLEAN := TRUE
,   validate_entity               BOOLEAN := TRUE
,   write_to_db                   BOOLEAN := TRUE
,   process                       BOOLEAN := TRUE
,   process_entity                VARCHAR2(30) := G_ENTITY_ALL
,   clear_api_cache               BOOLEAN := TRUE
,   clear_api_requests            BOOLEAN := TRUE
,   request_category              VARCHAR2(30):= NULL
,   request_name                  VARCHAR2(30):= NULL
);

--  Variable representing missing control record.

G_MISS_CONTROL_REC            Control_Rec_Type;

--  API request record type.

TYPE Request_Rec_Type IS RECORD
(   entity                        VARCHAR2(30) := NULL
,   step                          VARCHAR2(30) := NULL
,   name                          VARCHAR2(30) := NULL
,   category                      VARCHAR2(30) := NULL
,   processed                     BOOLEAN := FALSE
,   attribute1                    VARCHAR2(240) := NULL
,   attribute2                    VARCHAR2(240) := NULL
,   attribute3                    VARCHAR2(240) := NULL
,   attribute4                    VARCHAR2(240) := NULL
,   attribute5                    VARCHAR2(240) := NULL
);

--  API Request table type.

TYPE Request_Tbl_Type IS TABLE OF Request_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Initialize control record.

FUNCTION Init_Control_Rec
(   p_operation                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
)RETURN Control_Rec_Type;

--  Function Equal
--  Number comparison.

FUNCTION Equal
(   p_attribute1                    IN  NUMBER
,   p_attribute2                    IN  NUMBER
)RETURN BOOLEAN;

--  Varchar2 comparison.

FUNCTION Equal
(   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
)RETURN BOOLEAN;

--  Date comparison.

FUNCTION Equal
(   p_attribute1                    IN  DATE
,   p_attribute2                    IN  DATE
)RETURN BOOLEAN;

END MRP_Globals;

 

/
