--------------------------------------------------------
--  DDL for Package WIP_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: WIPSGLBS.pls 115.11 2002/12/01 16:15:42 rmahidha ship $ */

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
G_ENTITY_WIP_ENTITIES          CONSTANT VARCHAR2(30) := 'WIP_ENTITIES';
G_ENTITY_FLOWSCHEDULE          CONSTANT VARCHAR2(30) := 'FLOWSCHEDULE';
G_ENTITY_DISCRETEJOB           CONSTANT VARCHAR2(30) := 'DISCRETEJOB';
G_ENTITY_REPSCHEDULE           CONSTANT VARCHAR2(30) := 'REPSCHEDULE';
G_ENTITY_WIPTRANSACTION        CONSTANT VARCHAR2(30) := 'WIPTRANSACTION';
G_ENTITY_COMPONENTISSUE        CONSTANT VARCHAR2(30) := 'COMPONENTISSUE';
G_ENTITY_OSP                   CONSTANT VARCHAR2(30) := 'OSP';
G_ENTITY_SHOPFLOORMOVE         CONSTANT VARCHAR2(30) := 'SHOPFLOORMOVE';
G_ENTITY_RESOURCE              CONSTANT VARCHAR2(30) := 'RESOURCE';
--  END GEN entities

--  Actions.

G_OPR_CREATE	    CONSTANT	VARCHAR2(30) := 'CREATE';
G_OPR_UPDATE	    CONSTANT	VARCHAR2(30) := 'UPDATE';
G_OPR_DELETE	    CONSTANT	VARCHAR2(30) := 'DELETE';
G_OPR_LOCK	    CONSTANT	VARCHAR2(30) := 'LOCK';
G_OPR_NONE	    CONSTANT	VARCHAR2(30) := FND_API.G_MISS_CHAR;

--  Additional Actions

G_OPR_DEFAULT_USING_KANBAN       CONSTANT   VARCHAR2(50) := 'DFLT_USING_KANBAN';
G_OPR_DEFAULT_USING_PO           CONSTANT   VARCHAR2(50) := 'DFLT_USING_PO';

-- Validation Levels
-- Discrete Jobs  : 10 -> 19
G_VAL_DISCRETE_FULL              CONSTANT   NUMBER := 10;
-- Rep Schedules  : 20 -> 29
G_VAL_REP_SCH_FULL               CONSTANT   NUMBER := 20;
-- Flow Schedules : 40 -> 49
G_VAL_FLOW_SCH_FULL              CONSTANT   NUMBER := 40;


--  Max number of defaulting iterations.

G_MAX_DEF_ITERATIONS          CONSTANT NUMBER:= 5;

--  Index table type used by JVC controllers.

TYPE Index_Tbl_Type IS TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;

--  API Action control flags.

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

-- Table of numbers
TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

--  Initialize control record.

FUNCTION Init_Control_Rec
(   p_action                        IN  VARCHAR2
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

PROCEDURE Add_Error_Message(p_product        VARCHAR2   := 'WIP',
			    p_message_name   VARCHAR2,
			    p_token1_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token1_value   VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token2_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token2_value   VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token3_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token3_value   VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token4_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token4_value   VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token5_name    VARCHAR2   := FND_API.G_MISS_CHAR,
			    p_token5_value   VARCHAR2   := FND_API.G_MISS_CHAR);

-- Displays 'p_msg_count' messages to the screen (dbms) then clears
-- the message stack.
Procedure Display_all_msgs ( p_msg_count  IN NUMBER);

procedure get_locator_control
( p_org_id           IN  NUMBER,
 p_subinventory_code IN  VARCHAR2,
 p_primary_item_id   IN  NUMBER,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2,
 x_locator_control   OUT NOCOPY NUMBER
 );


/*=====================================================================+
 | FUNCTION
 |  USE_PHANTOM_ROUTINGS
 |
 | PURPOSE
 |   To check BOM parameter USE_PHANTOM_ROUTINGS
 |
 | ARGUMENTS
 |   p_org_id : Organization Id
 |
 | NOTE
 |     Returns 1(YES) if USE_PHANTOM_ROUTINGS = 1
 |     Returns 2(NO) if USE_PHANTOM_ROUTINGS <> 1
 |     Return  -2 if application level error
 |     Returns -1 if SQLERROR
 |
 +=====================================================================*/

function USE_PHANTOM_ROUTINGS(p_org_id in number) return number ;

/*=====================================================================+
 | FUNCTION
 |  INHERIT_PHANTOM_OP_SEQ
 |
 | PURPOSE
 |   To check BOM parameter INHERIT_PHANTOM_OP_SEQ
 |
 | ARGUMENTS
 |   p_org_id : Organization Id
 |
 | NOTE
 |     Returns 1(YES) if INHERIT_PHANTOM_OP_SEQ = 1
 |     Returns 2(NO) if INHERIT_PHANTOM_OP_SEQ <> 1
 |     Return  -2 if application level error
 |     Returns -1 if SQLERROR
 |
 +=====================================================================*/

function INHERIT_PHANTOM_OP_SEQ(p_org_id in number) return number ;

END WIP_Globals;

 

/
