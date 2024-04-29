--------------------------------------------------------
--  DDL for Package Body WSH_DOCUMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DOCUMENT_PVT" AS
-- $Header: WSHVPACB.pls 120.4.12010000.2 2009/06/24 12:13:57 anvarshn ship $

---------------------
-- TYPE  DECLARATIONS
---------------------

TYPE delivery_id_tabtype IS TABLE OF NUMBER;

------------
-- CONSTANTS
------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_Document_PVT';

--------------------
--  GLOBAL VARIABLES
--------------------

-- None

-----------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-----------------------------------

------------------------------------------------------------------------------
-- PROCEDURE  : GET_ChildDeliveryTab    PRIVATE
-- PARAMETER LIST
--   IN
--    p_delivery_id          Delivery for which child deliveries are required
--   OUT
--    x_child_delivery_tab   Table of child delivery records for that delivery
--
-- COMMENT     : For a delivery_id gets the delivery_ids of all
--               the child deliveries (all generations)
-- PRE-COND    : None
-- POST-COND   : None
-- EXCEPTIONS  : None
------------------------------------------------------------------------------

PROCEDURE GET_ChildDeliveryTab
( p_delivery_id        IN  NUMBER
, x_child_delivery_tab OUT NOCOPY delivery_id_tabtype
)
IS
-- Get all child delivery ids (all successive generations)

l_loop_count NUMBER := 1;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CHILDDELIVERYTAB';
--
BEGIN
  -- initialize the table
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
  END IF;
  --
  x_child_delivery_tab := delivery_id_tabtype();
  -- add children of this delivery id into the table
  -- but exclude this delivery id in the table

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_CHILD_DELIVERY_TAB.COUNT',x_child_delivery_tab.count);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
END Get_ChildDeliveryTab;

------------------------------------------------------------------------------
-- FUNCTION  : GET_Sequence_Type    PRIVATE
-- PARAMETER LIST
--   IN
--    p_doc_sequence_id      sequence for which type is required
--   OUT
--    None
--   RETURN
--    Sequence Type          sequence type ('A' for automatic, 'M' for manual)
--
-- COMMENT     : Gets the type of a given sequence
-- PRE-COND    : None
-- POST-COND   : None
-- EXCEPTIONS  : None
------------------------------------------------------------------------------


FUNCTION Get_Sequence_Type ( p_doc_sequence_id IN NUMBER )
  RETURN VARCHAR2
IS
CURSOR type_csr IS
  SELECT
    type
  FROM
    fnd_document_sequences
  WHERE doc_sequence_id = p_doc_sequence_id;
type_rec   type_csr%rowtype;
l_type     VARCHAR2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SEQUENCE_TYPE';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DOC_SEQUENCE_ID',P_DOC_SEQUENCE_ID);
  END IF;
  --
  OPEN type_csr;
  FETCH type_csr INTO type_rec;
  l_type := type_rec.type;
  CLOSE type_csr;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'TYPE',l_type);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN l_type;
END Get_Sequence_Type;

------------------------------------------------------------------------------
-- FUNCTION  : Init_Entity_Name    PRIVATE
-- PARAMETER LIST
--   IN
--    p_document_type        Type codes (PACK_TYPE, BOL, ASN, etc.)
--    p_entity_name          Entity Name (current value)
--   OUT
--    None
--   RETURN                  Entity Name (new initialized value)
--
-- COMMENT     : Initializes the entity name
-- PRE-COND    : None
-- POST-COND   : None
-- EXCEPTIONS  : None
------------------------------------------------------------------------------


FUNCTION Init_Entity_Name ( p_document_type IN VARCHAR2
                          , p_entity_name   IN VARCHAR2 )
RETURN VARCHAR2
IS
  l_entity_name wsh_document_instances.entity_name%type;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INIT_ENTITY_NAME';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
  END IF;
  --
  IF ( p_entity_name IS NOT NULL )
  THEN
    l_entity_name := p_entity_name;
  ELSE
    IF p_document_type = 'PACK_TYPE'
    THEN
      l_entity_name := 'WSH_NEW_DELIVERIES';
    ELSIF p_document_type = 'BOL'
    THEN
      l_entity_name := 'WSH_DELIVERY_LEGS';
    ELSIF p_document_type = 'MBOL'
    THEN
      l_entity_name := 'WSH_TRIPS';
    END IF;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'ENTITY_NAME',l_entity_name);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN l_entity_name;
END Init_Entity_Name;


------------------------------------------------------------------------------
-- FUNCTION  : Get_Delivery_Leg_Id    PRIVATE
-- PARAMETER LIST
--   IN
--    p_delivery_id        Delivery Id for which the leg id is reqd
--    p_pick_up_stop_id    Pick up stop Id
--    p_drop_off_stop_id   Drop off stop Id
--   OUT
--    None
--   RETURN                Delivery Leg Id that corresponds to an unique
--                         combination of the delivery, pick-up, drop-off stops
--
-- COMMENT     : Initializes the entity name
-- PRE-COND    : None
-- POST-COND   : None
-- EXCEPTIONS  : None
-------------------------------------------------------------------------------

FUNCTION Get_Delivery_Leg_id ( p_delivery_id IN NUMBER
			     , p_pick_up_stop_id IN NUMBER
			     , p_drop_off_stop_id IN NUMBER
			     )
RETURN NUMBER
IS
l_delivery_leg_id NUMBER;
CURSOR delivery_leg_csr IS
SELECT
  delivery_leg_id
FROM
  wsh_delivery_legs
WHERE delivery_id = p_delivery_id
  AND pick_up_stop_id = p_pick_up_stop_id
  AND drop_off_stop_id = p_drop_off_stop_id;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DELIVERY_LEG_ID';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PICK_UP_STOP_ID',P_PICK_UP_STOP_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DROP_OFF_STOP_ID',P_DROP_OFF_STOP_ID);
  END IF;
  --
  OPEN delivery_leg_csr;
  FETCH delivery_leg_csr INTO l_delivery_leg_id;
  IF delivery_leg_csr%NOTFOUND
  THEN
    CLOSE delivery_leg_csr;
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_INVALID_DELIVERY');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE delivery_leg_csr;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'DELIVERY_LEG_ID',l_delivery_leg_id);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN l_delivery_leg_id;
END Get_Delivery_Leg_Id;

----------------------------------
-- PUBLIC PROCEDURES AND FUNCTIONS
----------------------------------

-----------------------------------------------------------------------------
--  FUNCTION   : Get_Sequence_Type        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Checks and returns the type of a sequence assigned
--               to a specific document category
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_application_id       appl id of the calling program. Should be same
--                            as the application that owns the doc category
--     p_ledger_id            Ledger id of the calling program. Should be as the
--                            SOB used to setup the doc category/assignment
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_document_code        For pack slips this means document sub types (
--                            'SALES_ORDER') and for BOL ship method codes
--     p_location_id          Ship Location of the current delivery.
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     RETURN                 sequence type ('A' for automatic, 'M' for manual)
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
-----------------------------------------------------------------------------

FUNCTION Get_Sequence_Type
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_application_id            IN  NUMBER
, p_ledger_id                 IN  NUMBER  -- LE Uptake
, p_document_type             IN  VARCHAR2
, p_document_code             IN  VARCHAR2
, p_location_id               IN  NUMBER
)
RETURN VARCHAR2
IS
L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_Sequence_Type';
L_API_VERSION              CONSTANT NUMBER       := 1.0;
l_seq_return               NUMBER;
l_docseq_id                NUMBER;
l_docseq_type              VARCHAR2(1);
l_docseq_name              VARCHAR2(255);
l_db_seq_name              VARCHAR2(255);
l_seq_ass_id               NUMBER;
l_prd_tab_name             VARCHAR2(255);
l_aud_tab_name             VARCHAR2(255);
l_msg_flag                 VARCHAR2(2000);

-- LE Uptake
CURSOR type_csr IS
  SELECT
    wsh.category_code,
    fnd.method_code
  FROM
    wsh_doc_sequence_categories   wsh
  , fnd_doc_sequence_assignments  fnd
  WHERE  wsh.document_type = p_document_type
    AND  wsh.enabled_flag = 'Y'
    AND  ( (wsh.location_id = p_location_id AND
		       wsh.document_code = p_document_code)
           OR
           (wsh.location_id = p_location_id AND wsh.document_code IS NULL)
           OR
           ((nvl(wsh.location_id,-99) = -99) AND wsh.document_code = p_document_code)
           OR
           ((nvl(wsh.location_id,-99) = -99) AND wsh.document_code IS NULL)
	 )
    AND  wsh.category_code = fnd.category_code
    AND  fnd.application_id = p_application_id
    AND  fnd.set_of_books_id = p_ledger_id
    AND  (fnd.end_date is NULL or fnd.end_date >= trunc(sysdate)) --Bug8608685 added trunc to sysdate
    AND  fnd.start_date <= sysdate ;
type_rec   type_csr%rowtype;
l_type     VARCHAR2(255);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_SEQUENCE_TYPE';
--
BEGIN
  -- standard call to check for call compatibility.
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
      WSH_DEBUG_SV.log(l_module_name,'P_APPLICATION_ID',P_APPLICATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LEDGER_ID',P_LEDGER_ID);        -- LE Uptake
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_CODE',P_DOCUMENT_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  OPEN type_csr;
  FETCH type_csr INTO type_rec;
  IF type_csr%NOTFOUND
  THEN
    CLOSE type_csr;
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_ASSIGNMENT_MISSING');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- call FND API to get the sequence type information
  l_seq_return := FND_SEQNUM.get_seq_info
		        ( app_id         => p_application_id
			, cat_code       => type_rec.category_code
			, sob_id         => p_ledger_id     -- LE Uptake
			, met_code       => type_rec.method_code
			, trx_date       => sysdate
			, docseq_id      => l_docseq_id
			, docseq_type    => l_docseq_type
			, docseq_name    => l_docseq_name
			, db_seq_name    => l_db_seq_name
			, seq_ass_id     => l_seq_ass_id
			, prd_tab_name   => l_prd_tab_name
			, aud_tab_name   => l_aud_tab_name
			, msg_flag       => l_msg_flag
			);
  l_type := l_docseq_type;
  CLOSE type_csr;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'TYPE',l_type);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN l_type;
EXCEPTION

  WHEN FND_API.g_exc_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
    RETURN null;

  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
    RETURN null;

  WHEN others THEN
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
    RETURN null;

END Get_Sequence_Type;


------------------------------------------------------------------------------
--  FUNCTION   : Is_Final        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Checks the status of all documents for the delivery
--               including its children.  If any such document is final,
--               returns true.  Else return false.  This is used by
--               print document routine and packing slip report to bail
--               out if any of the document has final_print_date set.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_delivery_id          delivery_id of the delivery to check
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     RETURN                 VARCHAR2, value 'T' or 'F'
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

FUNCTION Is_Final
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_delivery_id               IN  NUMBER
, p_document_type             IN  VARCHAR2
)
RETURN VARCHAR2
IS
L_API_NAME                 CONSTANT VARCHAR2(30) := 'Is_Final';
L_API_VERSION              CONSTANT NUMBER       := 1.0;
l_msg_flag                 VARCHAR2(2000);


l_isfinal VARCHAR2(1);
l_temp_date DATE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_FINAL';
--
BEGIN
  -- standard call to check for call compatibility.
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -- initially l_isfinal=FALSE, means no document is not final
  l_isfinal := FND_API.G_false;

  -- if p_consolidate_option is CONSOLIDATE or BOTH, we need to check
  -- the parent delivery first
    SELECT doc.final_print_date
    INTO l_temp_date
    FROM wsh_document_instances doc
    WHERE doc.entity_id=p_delivery_id
      AND doc.entity_name='WSH_NEW_DELIVERIES'
      AND doc.document_type=p_document_type;
    IF l_temp_date IS NOT NULL
    THEN
      l_isfinal := FND_API.g_true;
    END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'IS FINAL',l_isfinal);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN l_isfinal;

EXCEPTION

  WHEN FND_API.g_exc_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
    RETURN null;

  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
    RETURN null;

  WHEN others THEN
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
    RETURN null;

END Is_Final;

------------------------------------------------------------------------------
--  PROCEDURE  : Set_Final_Print_Date        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Set the FINAL_PRINT_DATE column of all document instances
--               of the delivery and/or its child delivery to SYSDATE.
--               This procedure is called when user chooses print option
--               as FINAL.  This means later the same document instances
--               cannot be printed as they fail the Is_Final check.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_delivery_id          delivery_id of the delivery to check
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_final_print_date     the final_print_date to be set
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--
--     PRE-CONDITIONS  :  FINAL_PRINT_DATE column of WSH_DOCUMENT_INSTANCES
--                        rows of related deliveries have NULL value
--     POST-CONDITIONS :  such FINAL_PRINT_DATE columns have SYSDATE value
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Set_Final_Print_Date
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_delivery_id               IN  NUMBER
, p_document_type             IN  VARCHAR2
, p_final_print_date          IN  DATE
)
IS

L_API_NAME                 CONSTANT VARCHAR2(30) := 'Set_Final_Print_Date';
L_API_VERSION              CONSTANT NUMBER       := 1.0;
l_msg_flag                 VARCHAR2(2000);
l_temp_date DATE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'SET_FINAL_PRINT_DATE';
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
      WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_FINAL_PRINT_DATE',P_FINAL_PRINT_DATE);
  END IF;
  --
  SAVEPOINT WSH_Document_PVT;

  -- standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -- initialize l_temp_date to p_final_print_date
  l_temp_date := p_final_print_date;

    UPDATE
      wsh_document_instances doc
    SET
      doc.final_print_date = l_temp_date
    WHERE doc.entity_id=p_delivery_id
      AND doc.entity_name='WSH_NEW_DELIVERIES'
      AND doc.document_type=p_document_type;

  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);

  -- Standard check of p_commit.
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN FND_API.g_exc_error THEN

    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.g_exc_unexpected_error THEN

    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                                END IF;
                                --
  WHEN others THEN

    ROLLBACK to WSH_Document_PVT;
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Set_Final_Print_Date;

-----------------------------------------------------------------------------
--  PROCEDURE  : Create_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Creates a document (packing slip, bill of lading) for a
--               delivery and assigns(or validates) a sequence number
--               as per pre-defined document category definitions
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being created
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_application_id       Application which is creating the document (
--                            should be same as the one that owns the
--			      document category )
--     p_location_id          Location id which the document is being created
--     p_document_type        type codes (PACK_TYPE, BOL, ASN, etc.)
--     p_document_sub_type    for packing slips (SALES_ORDER, etc) and
--                            for Bills of Lading the ship method codes
--     p_pod_flag             pod_flag for the document
--     p_pod_by               pod_by for the document
--     p_pod_date             pod_date for the document
--     p_reason_of_transport  reason of transport that describes the delivery
--     p_description          external aspect of the delivery
--     p_cod_amount           cod_amount of the document
--     p_cod_currency_code    cod_currency_code of the document
--     p_cod_remit_to         cod_remit_to of the document
--     p_cod_charge_paid_by   cod_charge_paid_by of the document
--     p_problem_contact_reference   problem_contact_referene of the document
--     p_bill_freight_to      bill_freight_to of the document
--     p_carried_by           carried_by of the document
--     p_port_of_loading      port_of_loading of the docucent
--     p_port_of_discharge    port_of_discharge of the document
--     p_booking_office       booking_office of the document
--     p_booking_number       booking_number of the document
--     p_service_contract     service_contract of the document
--     p_shipper_export_ref   shipper_export_ref of the document
--     p_carrier_export_ref   carrier_export_ref of the document
--     p_bol_notify_party     bol_notify_party of the document
--     p_supplier_code        supplier_code of the document
--     p_aetc_number          aetc_number of the document
--     p_shipper_signed_by    shipper_signed_by of the document
--     p_shipper_date         shipper_date of the document
--     p_carrier_signed_by    carrier_signed_by of the document
--     p_carrier_date         carrier_date of the document
--     p_bol_issue_office     bol_issue_office of the document
--     p_bol_issued_by        bol_issued_by of the document
--     p_bol_date_issued      bol_date_issued of the document
--     p_shipper_hm_by        shipper_bm_by of the document
--     p_shipper_hm_date      shipper_hm_date of the document
--     p_carrier_hm_by        carrier_hm_by of the document
--     p_carrier_hm_date      carrier_hm_date of the document
--     p_ledger_id            Ledger id attached to the calling program (
--                            should be same as SOB used to setup the
--                            document category/assignment )
--     p_consolidate_option   calling program's choice to create document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--     p_manual_sequence_number  user defined sequence number ( used only
--                            if the document falls in a category  that has
--                            manual type suquence assigned to it (else null)
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_document_number      the document number (generated/manual sequence
--                            with concatenated prefix and suffix).
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  The delivery should be existing in the Database
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
-----------------------------------------------------------------------------

PROCEDURE Create_Document
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_entity_name               IN  VARCHAR2 DEFAULT NULL
, p_entity_id                 IN  NUMBER
, p_application_id            IN  NUMBER
, p_location_id               IN  NUMBER
, p_document_type             IN  VARCHAR2
, p_document_sub_type         IN  VARCHAR2
, p_ledger_id                 IN  NUMBER    -- LE Uptake
, p_consolidate_option        IN  VARCHAR2 DEFAULT 'BOTH'
, p_manual_sequence_number    IN  NUMBER   DEFAULT NULL
, x_document_number           OUT NOCOPY  VARCHAR2)
IS
L_API_NAME                 CONSTANT VARCHAR2(30) := 'Create_Document';
L_API_VERSION              CONSTANT NUMBER       := 1.0;
l_sequence_id              fnd_sequences.sequence_id%type;
l_sequence_name            fnd_sequences.sequence_name%type;
l_sequence_number          NUMBER(38);
l_delivery_id              NUMBER(38);
l_delivery_leg_id          NUMBER(38);
l_delivery_id_tab          delivery_id_tabtype := delivery_id_tabtype();
l_table_count              NUMBER;
l_doc_sequence_id          fnd_document_sequences.doc_sequence_id%type;
l_doc_sequence_category_id
wsh_doc_sequence_categories.doc_sequence_category_id%type;
l_document_number          VARCHAR2(255);
l_seq_return               NUMBER;
l_seq_type                 VARCHAR2(255);
l_entity_name              wsh_document_instances.entity_name%type;
l_debug_msg                VARCHAR2(32000);
l_prefix                   VARCHAR2(10);
l_suffix                   VARCHAR2(10);
l_delivery_name		   VARCHAR2(30);
l_status                   VARCHAR2(10) := 'OPEN'; -- bug 3761178
l_entity_id                NUMBER(38);             -- bug 3761178

CURSOR trip_stop_csr IS
SELECT
  delivery_id
, pick_up_stop_id
, drop_off_stop_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = p_entity_id;


CURSOR document_csr ( c_entity_name IN VARCHAR2
		    , c_entity_id IN NUMBER )
IS
SELECT
  sequence_number
FROM
  wsh_document_instances
WHERE entity_name = c_entity_name
  AND entity_id = c_entity_id
  AND status <> 'CANCELLED'
  -- AND status = 'OPEN'
  AND document_type = p_document_type;

-- identify the category that is defined for this location
-- and document sub type or for all locations or all sub types

CURSOR category_csr IS
SELECT
  doc_sequence_category_id
, category_code
, prefix
, suffix
, delimiter
FROM
  wsh_doc_sequence_categories
WHERE  document_type = p_document_type
  AND  enabled_flag = 'Y'
  AND  ((location_id = p_location_id AND document_code = p_document_sub_type)
       OR
       (location_id = p_location_id AND document_code IS NULL)
       OR
--       (location_id IS NULL AND document_code = p_document_sub_type)
--	change location_id is null to location_id = -99 (all locations => -99)
       (location_id = -99 AND document_code = p_document_sub_type)
       OR
       (location_id = -99 AND document_code IS NULL));

-- get the method code for the sequence assigned to this category.
-- does not support multiple sequences being assigned to a category.
-- in such cases the first assignment's method code only is used.

-- LE Uptake
CURSOR assignment_csr (c_category_code IN VARCHAR2) IS
SELECT
  method_code,
  doc_sequence_id
FROM
  fnd_doc_sequence_assignments
WHERE  application_id  = p_application_id
  AND  set_of_books_id = p_ledger_id
  AND  category_code   = c_category_code
  AND  start_date <= sysdate
  AND  ( (end_date IS NULL)
	 OR
	 (end_date >= trunc(sysdate)) --Bug8608685 added trunc to sysdate
  AND  start_date <= sysdate
       );

CURSOR delivery_csr (c_delivery_id IN NUMBER) IS
SELECT
  delivery_id
FROM
  wsh_new_deliveries
WHERE delivery_id = c_delivery_id;

CURSOR delivery_id_csr (c_delivery_leg_id IN NUMBER) IS
SELECT
  delivery_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = c_delivery_leg_id;

--
--Bug 4284167 (FP Bug 4149501)
--
CURSOR  get_lock_on_leg(p_delivery_leg_id IN NUMBER) IS
SELECT  p_delivery_leg_id
FROM    wsh_delivery_legs
WHERE   delivery_leg_id  = p_delivery_leg_id
FOR UPDATE NOWAIT;

document_rec       document_csr%rowtype;
category_rec       category_csr%rowtype;
assignment_rec     assignment_csr%rowtype;
delivery_rec       delivery_csr%rowtype;
delivery_id_rec    delivery_id_csr%rowtype;
trip_stop_rec      trip_stop_csr%rowtype;

--Bug 4284167 (FP Bug 4149501)
lock_detected	EXCEPTION;
PRAGMA EXCEPTION_INIT( lock_detected, -00054);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DOCUMENT';
--
BEGIN
  -- since this procedure does DML issue savepoint
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
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_APPLICATION_ID',P_APPLICATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_SUB_TYPE',P_DOCUMENT_SUB_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_LEDGER_ID',P_LEDGER_ID);    -- LE Uptake
      WSH_DEBUG_SV.log(l_module_name,'P_CONSOLIDATE_OPTION',P_CONSOLIDATE_OPTION);
      WSH_DEBUG_SV.log(l_module_name,'P_MANUAL_SEQUENCE_NUMBER',P_MANUAL_SEQUENCE_NUMBER);
  END IF;
  --
  SAVEPOINT WSH_Document_PVT;

  -- standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;
  OPEN category_csr;
  FETCH category_csr INTO category_rec;
  IF category_csr%NOTFOUND
  THEN
    CLOSE category_csr;
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_CATEGORY_MISSING');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_doc_sequence_category_id := category_rec.doc_sequence_category_id;
  CLOSE category_csr;

  -- get the method code for the sequence assigned to this category.
  -- does not support multiple sequences being assigned to a category.
  -- in such cases the first assignment's method code only is used.

  OPEN assignment_csr(category_rec.category_code);
  FETCH assignment_csr INTO assignment_rec;
  IF assignment_csr%NOTFOUND THEN
    CLOSE assignment_csr;
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_ASSIGNMENT_MISSING');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_doc_sequence_id := assignment_rec.doc_sequence_id;
  CLOSE assignment_csr;

  -------------------------------------------------------------
  -- Initialize the entity_name based on the document type   --
  -- If the entity is Delivery leg,  look up its delivery id --
  -- to be used to build the child delivery table later      --
  -------------------------------------------------------------

  l_entity_name := Init_Entity_Name (p_document_type, p_entity_name);
  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN delivery_id_csr (p_entity_id);
    FETCH delivery_id_csr INTO delivery_id_rec;
    l_delivery_id := delivery_id_rec.delivery_id;
    CLOSE delivery_id_csr;
  ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
  THEN
    l_delivery_id := p_entity_id;
  END IF;

  ----------------------------------------------
  -- if the document is for delivery leg      --
  -- get its pick up and drop off trip stops  --
  ----------------------------------------------
  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN trip_stop_csr;
    FETCH trip_stop_csr INTO trip_stop_rec;
    CLOSE trip_stop_csr;
  END IF;

IF l_entity_name <> 'WSH_TRIPS' THEN
  ----------------------------------------------
  -- Validate the delivery id                 --
  ----------------------------------------------
  OPEN delivery_csr (l_delivery_id);
  FETCH delivery_csr INTO delivery_rec;
  IF delivery_csr%NOTFOUND
  THEN
    CLOSE delivery_csr;
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_INVALID_DELIVERY');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE delivery_csr;

  ---------------------------------------------------------------
  -- based on the consolidate_option identify the delivery ids --
  -- to create documents for                                   --
  ---------------------------------------------------------------

  IF (p_consolidate_option IN ('BOTH', 'SEPARATE'))
  THEN
    GET_ChildDeliveryTab ( l_delivery_id , l_delivery_id_tab );
  END IF;

  IF p_consolidate_option IN ('BOTH', 'CONSOLIDATE') THEN
    l_table_count := l_delivery_id_tab.count;
    l_delivery_id_tab.extend;
    l_delivery_id_tab(l_table_count+1) := l_delivery_id;
  END IF;

  IF NOT l_delivery_id_tab.EXISTS(1) THEN
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_INVALID_DELIVERY');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  FOR ctr IN 1..l_delivery_id_tab.count LOOP

    -----------------------------------------------------------
    -- For each delivery, if the docuement is required for   --
    -- delivery leg entity then identify the delivery leg id --
    -----------------------------------------------------------

    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN

     l_delivery_leg_id := Get_Delivery_Leg_Id ( l_delivery_id_tab(ctr)
                                              , trip_stop_rec.pick_up_stop_id
  		                              , trip_stop_rec.drop_off_stop_id
					      );
    END IF;

    -----------------------------------------------------------
    -- For every entity check if a document of this type     --
    -- already exists with OPEN status ( Here the entity     --
    -- would be Deliveries in case of packing slips and      --
    -- Delivery legs in case of Bill of Lading )             --
    -----------------------------------------------------------

    IF document_csr%ISOPEN
    THEN
      CLOSE document_csr;
    END IF;
    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
      OPEN document_csr ( l_entity_name
			, l_delivery_leg_id
			) ;
    ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
    THEN
      OPEN document_csr (l_entity_name, l_delivery_id_tab(ctr));
    END IF;

    FETCH document_csr INTO document_rec;
    IF document_csr%FOUND THEN
      CLOSE document_csr;

     --Fix for bug 3878973
     --If document exists already, just return success

      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Doc Number exists already');
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       RETURN;
    END IF;
    CLOSE document_csr;

    l_seq_type := get_sequence_type (l_doc_sequence_id);

    -- for manual seq the user input is considered
    IF l_seq_type = 'M'
    THEN
      l_sequence_number := p_manual_sequence_number;
    END IF;

    -------------------------------------------------------------------------
    -- if the sequence type is automatic                                   --
    --   call the FND API to get a new number for each delivery            --
    -- if the sequence type is manual                                      --
    --   if this is a parent delivery                                      --
    --     call the FND API to validate the number given by the user       --
    --   if this is a child delivery                                       --
    --     use the same number given by the user for all child deliveries  --
    -------------------------------------------------------------------------
-- 2695602: Added type = 'G' below for handling Gapless Sequences

    IF (l_seq_type = 'A')
       OR
       (l_seq_type = 'G')
       OR
       ((l_seq_type = 'M') AND (l_delivery_id_tab(ctr) = l_delivery_id) )
    THEN
      l_seq_return := FND_SEQNUM.get_seq_val
                           ( app_id    => p_application_id
                           , cat_code  => category_rec.category_code
                           , sob_id    => p_ledger_id   -- LE Uptake
                           , met_code  => assignment_rec.method_code
                           , trx_date  => sysdate
			   , seq_val   => l_sequence_number
                           , docseq_id => l_sequence_id );
    END IF;
    IF NVL(l_sequence_number,0) = 0
    THEN
      FND_MESSAGE.set_name ('WSH', 'WSH_DOC_SEQ_ERROR');
      WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* l_document_number := LTRIM(RTRIM(category_rec.prefix)) ||
                         category_rec.delimiter ||
                         LTRIM(RTRIM(TO_CHAR(l_sequence_number))) ||
                         category_rec.delimiter ||
                         LTRIM(RTRIM(category_rec.suffix)); */

    /* Bug 1973913 begins */

    IF category_rec.prefix is not NULL THEN
      l_prefix:= LTRIM(RTRIM(category_rec.prefix))||category_rec.delimiter;
    END IF;
    IF category_rec.suffix is not NULL THEN
      l_suffix:= category_rec.delimiter||LTRIM(RTRIM(category_rec.suffix));
    END IF;

      -------------------------------------------------------------
      -- Bug 2310825 : Removed the LPAD which was being used to pad
      -- the sequence number with 0's.
      -------------------------------------------------------------

    l_document_number:=l_prefix||LTRIM(RTRIM(TO_CHAR(l_sequence_number))) ||l_suffix;

    /* Bug 1973913 ends */

    -- if this is the parent delivery id then
    -- return the seq number to the calling program

    IF l_delivery_id_tab(ctr) = l_delivery_id THEN
      x_document_number := l_document_number;
    END IF;

    --{ Bug 3761178
     --
     -- The decode statements that were in the values clause of the coming insert stmt
     -- have been modified to make use of local variables for performance reasons.
     --

    IF l_entity_name = 'WSH_DELIVERY_LEGS' THEN
       l_status := 'PLANNED';
       l_entity_id := l_delivery_leg_id;
    ELSIF l_entity_name ='WSH_NEW_DELIVERIES' THEN
       l_status := 'OPEN';
       l_entity_id := l_delivery_id_tab(ctr);
    END IF;

    --}

    ---------------------------------------------------------
    --  logic in insert statement:                         --
    --                                                     --
    --  if the entity is delivery ( packing slips )        --
    --    then entity_name is WSH_NEW_DELIVERIES           --
    --         and entity_id is delivery_id                --
    --           and if there is consolidation             --
    --               then for child deliveries             --
    --                   entity_name is WSH_NEW_DELIVERIES --
    --                   entity_id is child delivery_id    --
    --  if the entity is delivery leg ( bill of lading )   --
    --    then entity_name is WSH_DELIVERY_LEGS            --
    --         and entity_id is delivery_leg_id            --
    --           and if there is consolidation             --
    --               then for child deliveries             --
    --                   entity_name is WSH_DELIVERY_LEGS  --
    --                   entity_id is the delivery_leg_id  --
    --                       that corresponds to the       --
    --                           child delivery_id,        --
    --                           master pick_up_stop_id,   --
    --                           master drop_off_stop_id   --
    -- - - - - - - - - - - - - - - - - - - - - - - - - - - --
    -- Assumption here:                                    --
    --                                                     --
    -- All deliveries (even those contained in another     --
    -- delivery for consolidation purposes) will have a    --
    -- delivery leg created before the Bill of Lading can  --
    -- be created.                                         --
    ---------------------------------------------------------
    INSERT INTO wsh_document_instances
    ( document_instance_id
    , document_type
    , sequence_number
    , status
    , final_print_date
    , entity_name
    , entity_id
    , doc_sequence_category_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_application_id
    , program_id
    , program_update_date
    , request_id
    , attribute_category
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    )
    VALUES
    ( wsh_document_instances_s.nextval
    , p_document_type
    , l_document_number
    , l_status
    , null
    , l_entity_name
    , l_entity_id
    , l_doc_sequence_category_id
    , fnd_global.user_id
    , sysdate
    , fnd_global.user_id
    , sysdate
    , fnd_global.login_id
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    );

	--
	--Bug 4284167 (FP Bug 4149501)ISSUED DATE OF A BOL IS NOT GETTING SYSTEM GENERATED.
	--

	IF l_entity_name = 'WSH_DELIVERY_LEGS'  THEN

	 OPEN get_lock_on_leg(l_delivery_leg_id);

	   FETCH get_lock_on_leg INTO l_delivery_leg_id;
		IF (get_lock_on_leg%FOUND) THEN
			UPDATE  wsh_delivery_legs
			SET  doc_date_issued = SYSDATE
			WHERE  current of get_lock_on_leg;
		END IF;
  	   CLOSE get_lock_on_leg;

	END IF;

  END LOOP;

    ELSE--for l_entity_name <> 'WSH_TRIPS'

--Check if document number for the entity type and the name
--already exists.
      OPEN document_csr (p_entity_name, p_entity_id);
      FETCH document_csr INTO document_rec;
      IF document_csr%FOUND THEN
        CLOSE document_csr;

     --Fix for bug 3878973
     --If document exists already, just return success
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Doc Number exists already');
           WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        RETURN;
      END IF;
      CLOSE document_csr;

      l_seq_type := get_sequence_type (l_doc_sequence_id);
    -- for manual seq the user input is considered
    IF l_seq_type = 'M'
    THEN
      l_sequence_number := p_manual_sequence_number;
    END IF;

    -------------------------------------------------------------------------
    -- if the sequence type is automatic or Gapless                        --
    --   call the FND API to get a new number                              --
    -- if the sequence type is manual                                      --
    --     use the number given by the user                                --
    -------------------------------------------------------------------------

    IF (l_seq_type = 'A')
       OR
       (l_seq_type = 'G')
    THEN
      l_seq_return := FND_SEQNUM.get_seq_val
                           ( app_id    => p_application_id
                           , cat_code  => category_rec.category_code
                           , sob_id    => p_ledger_id   -- LE Uptake
                           , met_code  => assignment_rec.method_code
                           , trx_date  => sysdate
                           , seq_val   => l_sequence_number
                           , docseq_id => l_sequence_id );
    END IF;

    IF NVL(l_sequence_number,0) = 0
    THEN
      FND_MESSAGE.set_name ('WSH', 'WSH_DOC_SEQ_ERROR');
      WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF category_rec.prefix is not NULL THEN
      l_prefix:= LTRIM(RTRIM(category_rec.prefix))||category_rec.delimiter;
    END IF;
    IF category_rec.suffix is not NULL THEN
      l_suffix:= category_rec.delimiter||LTRIM(RTRIM(category_rec.suffix));
    END IF;

    l_document_number:=l_prefix||LTRIM(RTRIM(TO_CHAR(l_sequence_number))) ||l_suffix;

    x_document_number := l_document_number;

    l_status := 'OPEN'; --bug # 3789154

    INSERT INTO wsh_document_instances
    ( document_instance_id
    , document_type
    , sequence_number
    , status
    , final_print_date
    , entity_name
    , entity_id
    , doc_sequence_category_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_application_id
    , program_id
    , program_update_date
    , request_id
    , attribute_category
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    )
    VALUES
    ( wsh_document_instances_s.nextval
    , p_document_type
    , l_document_number
    , l_status --Bug# 3789154
    , null
    , p_entity_name
    , p_entity_id
    , l_doc_sequence_category_id
    , fnd_global.user_id
    , sysdate
    , fnd_global.user_id
    , sysdate
    , fnd_global.login_id
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    );
    END IF;--for l_entity_name <> 'WSH_TRIPS'

  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);

  -- Standard check of p_commit.
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN lock_detected THEN --Bug 4284167 (FP Bug 4149501)

     IF (get_lock_on_leg%ISOPEN) THEN
	CLOSE get_lock_on_leg;
     END IF;
     ROLLBACK to WSH_Document_PVT;

     SELECT wnd.name INTO l_delivery_name
     FROM   wsh_new_deliveries wnd, wsh_delivery_legs wdl
     WHERE  wnd.delivery_id = wdl.delivery_id
     AND    wdl.delivery_leg_id  = l_delivery_leg_id;

     FND_MESSAGE.SET_NAME('WSH',' WSH_DLVY_DEL_LEG_LOCK');
     FND_MESSAGE.SET_TOKEN('DEL_NAME',l_delivery_name);
     x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
     wsh_util_core.add_message(WSH_UTIL_CORE.g_ret_sts_error,l_module_name);

     FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                 p_data => x_msg_data );
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Cannot lock delivery leg for update');
     END IF;

  WHEN FND_API.g_exc_error THEN
    --Bug 4284167 (FP Bug 4149501)
    IF (get_lock_on_leg%ISOPEN) THEN
		CLOSE get_lock_on_leg;
    END IF;

    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
                                END IF;
                                --
  WHEN FND_API.g_exc_unexpected_error THEN
    --Bug 4284167 (FP Bug 4149501)
    IF (get_lock_on_leg%ISOPEN) THEN
		CLOSE get_lock_on_leg;
    END IF;

    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                                END IF;
                                --
  WHEN others THEN
    --Bug 4284167 (FP Bug 4149501)
    IF (get_lock_on_leg%ISOPEN) THEN
	CLOSE get_lock_on_leg;
    END IF;

    ROLLBACK to WSH_Document_PVT;
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Create_Document;


-----------------------------------------------------------------------------
--  PROCEDURE  : Update_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates a document (pack slip, bill of lading) for a delivery
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being updated
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_pod_flag             pod_flag for the document
--     p_pod_by               pod_by for the document
--     p_pod_date             pod_date for the document
--     p_reason_of_transport  reason of transport that describes the delivery
--     p_description          external aspect of the delivery
--     p_cod_amount           cod_amount of the document
--     p_cod_currency_code    cod_currency_code of the document
--     p_cod_remit_to         cod_remit_to of the document
--     p_cod_charge_paid_by   cod_charge_paid_by of the document
--     p_problem_contact_reference   problem_contact_referene of the document
--     p_bill_freight_to      bill_freight_to of the document
--     p_carried_by           carried_by of the document
--     p_port_of_loading      port_of_loading of the docucent
--     p_port_of_discharge    port_of_discharge of the document
--     p_booking_office       booking_office of the document
--     p_booking_number       booking_number of the document
--     p_service_contract     service_contract of the document
--     p_shipper_export_ref   shipper_export_ref of the document
--     p_carrier_export_ref   carrier_export_ref of the document
--     p_bol_notify_party     bol_notify_party of the document
--     p_supplier_code        supplier_code of the document
--     p_aetc_number          aetc_number of the document
--     p_shipper_signed_by    shipper_signed_by of the document
--     p_shipper_date         shipper_date of the document
--     p_carrier_signed_by    carrier_signed_by of the document
--     p_carrier_date         carrier_date of the document
--     p_bol_issue_office     bol_issue_office of the document
--     p_bol_issued_by        bol_issued_by of the document
--     p_bol_date_issued      bol_date_issued of the document
--     p_shipper_hm_by        shipper_bm_by of the document
--     p_shipper_hm_date      shipper_hm_date of the document
--     p_carrier_hm_by        carrier_hm_by of the document
--     p_carrier_hm_date      carrier_hm_date of the document
--     p_ledger_id            LEDGER id attached to the calling program (
--                            should be same as SOB used to setup the
--                            document category/assignment )
--     p_consolidate_option   calling program's choice to update document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
-----------------------------------------------------------------------------

PROCEDURE Update_Document
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_entity_name               IN  VARCHAR2 DEFAULT NULL
, p_entity_id                 IN  NUMBER
, p_document_type             IN  VARCHAR2
, p_ledger_id                 IN  NUMBER   -- LE Uptake
, p_consolidate_option        IN  VARCHAR2 DEFAULT 'BOTH'
) IS
L_API_NAME           CONSTANT VARCHAR2(30) := 'Update_Document';
L_API_VERSION        CONSTANT NUMBER       := 1.0;
l_delivery_id_tab    delivery_id_tabtype   := delivery_id_tabtype();
l_delivery_id        wsh_new_deliveries.delivery_id%type;
l_delivery_leg_id    wsh_delivery_legs.delivery_leg_id%type;
l_table_count        NUMBER;
l_entity_name        wsh_document_instances.entity_name%type;

CURSOR old_values_csr (c_entity_name IN VARCHAR2, c_entity_id IN NUMBER) IS

--Changed for BUG#3330869
SELECT status
--SELECT *
FROM
  wsh_document_instances
WHERE entity_name = c_entity_name
  AND entity_id = c_entity_id
  AND document_type = p_document_type
  AND status not in ('COMPLETE', 'CANCELLED')
  FOR UPDATE;

CURSOR trip_stop_csr IS
SELECT
  delivery_id
, pick_up_stop_id
, drop_off_stop_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = p_entity_id;

CURSOR delivery_id_csr (c_delivery_leg_id IN NUMBER) IS
SELECT
  delivery_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = c_delivery_leg_id;

old_values_rec    old_values_csr%rowtype;
trip_stop_rec     trip_stop_csr%rowtype;
delivery_id_rec   delivery_id_csr%rowtype;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_DOCUMENT';
--
BEGIN

  -- since this procedure does DML issue savepoint

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
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_LEDGER_ID',P_LEDGER_ID);    -- LE Uptake
      WSH_DEBUG_SV.log(l_module_name,'P_CONSOLIDATE_OPTION',P_CONSOLIDATE_OPTION);
  END IF;
  --
  SAVEPOINT WSH_Document_PVT;

  -- standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -------------------------------------------------------------
  -- Initialize the entity_name based on the document type   --
  -- If the entity is Delivery leg,  look up its delivery id --
  -- to be used to build the child delivery table later      --
  -------------------------------------------------------------

  l_entity_name := Init_Entity_Name (p_document_type, p_entity_name);
  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN delivery_id_csr (p_entity_id);
    FETCH delivery_id_csr INTO delivery_id_rec;
    l_delivery_id := delivery_id_rec.delivery_id;
    CLOSE delivery_id_csr;
  ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
  THEN
    l_delivery_id := p_entity_id;
  END IF;

  ----------------------------------------------
  -- if the document is for delivery leg      --
  -- get its pick up and drop off trip stops  --
  ----------------------------------------------

  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN trip_stop_csr;
    FETCH trip_stop_csr INTO trip_stop_rec;
    CLOSE trip_stop_csr;
  END IF;

  ---------------------------------------------------------------
  -- based on the consolidate_option identify the delivery ids --
  -- to make the document updates                              --
  ---------------------------------------------------------------

  IF (p_consolidate_option IN ('BOTH', 'SEPARATE')) THEN
    GET_ChildDeliveryTab ( l_delivery_id
                         , l_delivery_id_tab );
  END IF;

  IF p_consolidate_option IN ('BOTH', 'CONSOLIDATE') THEN
    l_table_count := l_delivery_id_tab.count;
    l_delivery_id_tab.extend;
    l_delivery_id_tab(l_table_count+1) := l_delivery_id;
  END IF;

  IF NOT l_delivery_id_tab.EXISTS(1) THEN
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_INVALID_DELIVERY');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR ctr IN 1..l_delivery_id_tab.count LOOP

    -----------------------------------------------------------
    -- For each delivery, if the docuement relates to        --
    -- delivery leg entity then identify the delivery leg id --
    -----------------------------------------------------------

    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
     l_delivery_leg_id := Get_Delivery_Leg_Id ( l_delivery_id_tab(ctr)
                                              , trip_stop_rec.pick_up_stop_id
  		                              , trip_stop_rec.drop_off_stop_id
					      );
    END IF;

    IF old_values_csr%ISOPEN
    THEN
      CLOSE old_values_csr;
    END IF;
    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
      OPEN old_values_csr (l_entity_name, l_delivery_leg_id);
    ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
    THEN
      OPEN old_values_csr (l_entity_name, l_delivery_id_tab(ctr));
    END IF;

    FETCH old_values_csr INTO old_values_rec;
    IF old_values_csr%NOTFOUND THEN
      CLOSE old_values_csr;
      FND_MESSAGE.set_name ('WSH', 'WSH_DOC_MISSING');
      WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- if the document is cancelled, raise error
    IF old_values_rec.status = 'CANCELLED' THEN
      FND_MESSAGE.set_name ('WSH', 'WSH_DOC_INVALID_DELIVERY');
      WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- need to change this update within loop to a bulk update later.
    -- probably use temporary tables with a join

    UPDATE wsh_document_instances
    SET
      last_update_date           = sysdate
    , last_updated_by            = fnd_global.user_id
    , last_update_login          = fnd_global.login_id
    WHERE CURRENT OF old_values_csr;

  END LOOP;
  IF old_values_csr%ISOPEN
  THEN
    CLOSE old_values_csr;
  END IF;

  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);
  -- Standard check of p_commit.
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN FND_API.g_exc_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
  WHEN others THEN
    ROLLBACK to WSH_Document_PVT;
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                                END IF;
                                --
END Update_Document;


-----------------------------------------------------------------------------
--  PROCEDURE  : Cancel_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates the status of a document to 'CANCELLED'
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being cancelled
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_consolidate_option   calling program's choice to cancel document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
-----------------------------------------------------------------------------


PROCEDURE Cancel_Document
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_entity_name        IN  VARCHAR2 DEFAULT NULL
, p_entity_id          IN  NUMBER
, p_document_type      IN  VARCHAR2
, p_consolidate_option IN  VARCHAR2 DEFAULT 'BOTH'
)
IS
L_API_NAME           CONSTANT VARCHAR2(30) := 'WSH_Document_PVT';
L_API_VERSION        CONSTANT NUMBER       := 1.0;
l_delivery_id_tab    delivery_id_tabtype   := delivery_id_tabtype();
l_table_count        NUMBER;
l_entity_name        wsh_document_instances.entity_name%type;
l_delivery_id        wsh_new_deliveries.delivery_id%type;
l_delivery_leg_id    wsh_delivery_legs.delivery_leg_id%type;


-------------------------------------------------------------------------
--   cursor to fetch the current document (in PLAN/OPEN status) of     --
--   the entity. Assumes to get only one row because the delivery UI   --
--   currently enforces it (for both BOL and Pack Slips). If there is  --
--   a change to this behavior the cursor definition would need change --
-------------------------------------------------------------------------

CURSOR status_csr (c_entity_name IN VARCHAR2, c_entity_id IN NUMBER) IS
SELECT
  entity_id
  , status
FROM
  wsh_document_instances
WHERE entity_name = c_entity_name
  AND entity_id = c_entity_id
  AND document_type = p_document_type
  AND status in ('OPEN', 'PLANNED')
  FOR UPDATE;

CURSOR trip_stop_csr IS
SELECT
  delivery_id
, pick_up_stop_id
, drop_off_stop_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = p_entity_id;

CURSOR delivery_id_csr (c_delivery_leg_id IN NUMBER) IS
SELECT
  delivery_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = c_delivery_leg_id;

trip_stop_rec     trip_stop_csr%rowtype;
delivery_id_rec   delivery_id_csr%rowtype;
status_rec        status_csr%rowtype;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_DOCUMENT';
--
BEGIN
  -- since this procedure does DML issue savepoint
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
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_CONSOLIDATE_OPTION',P_CONSOLIDATE_OPTION);
  END IF;
  --
  SAVEPOINT WSH_Document_PVT;

  -- standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -------------------------------------------------------------
  -- Initialize the entity_name based on the document type   --
  -- If the entity is Delivery leg,  look up its delivery id --
  -- to be used to build the child delivery table later      --
  -------------------------------------------------------------

  l_entity_name := Init_Entity_Name (p_document_type, p_entity_name);

  IF l_entity_name <> 'WSH_TRIPS' THEN

  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN delivery_id_csr (p_entity_id);
    FETCH delivery_id_csr INTO delivery_id_rec;
    l_delivery_id := delivery_id_rec.delivery_id;
    CLOSE delivery_id_csr;
  ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
  THEN
    l_delivery_id := p_entity_id;
  END IF;

  ----------------------------------------------
  -- if the document is for delivery leg      --
  -- get its pick up and drop off trip stops  --
  ----------------------------------------------

  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN trip_stop_csr;
    FETCH trip_stop_csr INTO trip_stop_rec;
    CLOSE trip_stop_csr;
  END IF;

  ---------------------------------------------------------------
  -- based on the consolidate_option identify the delivery ids --
  -- to cancel documents for                                   --
  ---------------------------------------------------------------

  IF (p_consolidate_option IN ('BOTH', 'SEPARATE')) THEN
    GET_ChildDeliveryTab ( l_delivery_id
                         , l_delivery_id_tab );
  END IF;

  IF p_consolidate_option IN ('BOTH', 'CONSOLIDATE') THEN
    l_table_count := l_delivery_id_tab.count;
    l_delivery_id_tab.extend;
    l_delivery_id_tab(l_table_count+1) := l_delivery_id;
  END IF;

  IF NOT l_delivery_id_tab.EXISTS(1) THEN
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_INVALID_DELIVERY');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR ctr IN 1..l_delivery_id_tab.count LOOP

    -----------------------------------------------------------
    -- For each delivery, if the docuement relates to        --
    -- delivery leg entity then identify the delivery leg id --
    -----------------------------------------------------------

    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
     l_delivery_leg_id := Get_Delivery_Leg_Id ( l_delivery_id_tab(ctr)
                                              , trip_stop_rec.pick_up_stop_id
  		                              , trip_stop_rec.drop_off_stop_id
					      );
    END IF;

    IF status_csr%ISOPEN
    THEN
      CLOSE status_csr;
    END IF;
    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
      OPEN status_csr (l_entity_name, l_delivery_leg_id);
    ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
    THEN
      OPEN status_csr (l_entity_name, l_delivery_id_tab(ctr));
    END IF;

    FETCH status_csr INTO status_rec;
    IF status_csr%NOTFOUND THEN
      CLOSE status_csr;
      FND_MESSAGE.set_name ('WSH', 'WSH_DOC_MISSING');
      WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE wsh_document_instances
    SET status = 'CANCELLED'
    , last_update_date           = sysdate
    , last_updated_by            = fnd_global.user_id
    , last_update_login          = fnd_global.login_id
     WHERE CURRENT OF status_csr;

  END LOOP;
  IF status_csr%ISOPEN
  THEN
    CLOSE status_csr;
  END IF;

  ELSIF l_entity_name = 'WSH_TRIPS' THEN

    UPDATE wsh_document_instances
    SET status = 'CANCELLED'
    , last_update_date           = sysdate
    , last_updated_by            = fnd_global.user_id
    , last_update_login          = fnd_global.login_id
     WHERE entity_name = l_entity_name
     AND entity_id = p_entity_id
     AND document_type = p_document_type
     AND status in ('OPEN', 'PLANNED');

  END IF;
  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);
  -- Standard check of p_commit.
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN FND_API.g_exc_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
WHEN others THEN
    ROLLBACK to WSH_Document_PVT;
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                                END IF;
                                --
END Cancel_Document;

-----------------------------------------------------------------------------
--  PROCEDURE  : Open_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates the status of a document to 'OPEN'
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being opened
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_consolidate_option   calling program's choice to open document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
-----------------------------------------------------------------------------


PROCEDURE Open_Document
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_entity_name        IN  VARCHAR2 DEFAULT NULL
, p_entity_id          IN  NUMBER
, p_document_type      IN  VARCHAR2
, p_consolidate_option IN  VARCHAR2 DEFAULT 'BOTH'
)
IS
L_API_NAME           CONSTANT VARCHAR2(30) := 'WSH_Document_PVT';
L_API_VERSION        CONSTANT NUMBER       := 1.0;
l_delivery_id_tab    delivery_id_tabtype   := delivery_id_tabtype();
l_table_count        NUMBER;
l_entity_name        wsh_document_instances.entity_name%type;
l_delivery_id        wsh_new_deliveries.delivery_id%type;
l_delivery_leg_id    wsh_delivery_legs.delivery_leg_id%type;

CURSOR status_csr (c_entity_name IN VARCHAR2, c_entity_id IN NUMBER) IS
SELECT
  entity_id
  , status
FROM
  wsh_document_instances
WHERE entity_name = c_entity_name
  AND entity_id = c_entity_id
  AND document_type = p_document_type
  AND status = 'PLANNED'
  FOR UPDATE;

CURSOR trip_stop_csr IS
SELECT
  delivery_id
, pick_up_stop_id
, drop_off_stop_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = p_entity_id;

CURSOR delivery_id_csr (c_delivery_leg_id IN NUMBER) IS
SELECT
  delivery_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = c_delivery_leg_id;

trip_stop_rec     trip_stop_csr%rowtype;
delivery_id_rec   delivery_id_csr%rowtype;
status_rec        status_csr%rowtype;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'OPEN_DOCUMENT';
--
BEGIN
  -- since this procedure does DML issue savepoint
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
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_CONSOLIDATE_OPTION',P_CONSOLIDATE_OPTION);
  END IF;
  --
  SAVEPOINT WSH_Document_PVT;

  -- standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -------------------------------------------------------------
  -- Initialize the entity_name based on the document type   --
  -- If the entity is Delivery leg,  look up its delivery id --
  -- to be used to build the child delivery table later      --
  -------------------------------------------------------------

  l_entity_name := Init_Entity_Name (p_document_type, p_entity_name);
  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN delivery_id_csr (p_entity_id);
    FETCH delivery_id_csr INTO delivery_id_rec;
    l_delivery_id := delivery_id_rec.delivery_id;
    CLOSE delivery_id_csr;
  ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
  THEN
    l_delivery_id := p_entity_id;
  END IF;

  ----------------------------------------------
  -- if the document is for delivery leg      --
  -- get its pick up and drop off trip stops  --
  ----------------------------------------------

  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN trip_stop_csr;
    FETCH trip_stop_csr INTO trip_stop_rec;
    CLOSE trip_stop_csr;
  END IF;

  ---------------------------------------------------------------
  -- based on the consolidate_option identify the delivery ids --
  -- to cancel documents for                                   --
  ---------------------------------------------------------------

  IF (p_consolidate_option IN ('BOTH', 'SEPARATE')) THEN
    GET_ChildDeliveryTab ( l_delivery_id
                         , l_delivery_id_tab );
  END IF;

  IF p_consolidate_option IN ('BOTH', 'CONSOLIDATE') THEN
    l_table_count := l_delivery_id_tab.count;
    l_delivery_id_tab.extend;
    l_delivery_id_tab(l_table_count+1) := l_delivery_id;
  END IF;

  IF NOT l_delivery_id_tab.EXISTS(1) THEN
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_INVALID_DELIVERY');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR ctr IN 1..l_delivery_id_tab.count LOOP

    -----------------------------------------------------------
    -- For each delivery, if the docuement relates to        --
    -- delivery leg entity then identify the delivery leg id --
    -----------------------------------------------------------

    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
     l_delivery_leg_id := Get_Delivery_Leg_Id ( l_delivery_id_tab(ctr)
                                              , trip_stop_rec.pick_up_stop_id
  		                              , trip_stop_rec.drop_off_stop_id
					      );
    END IF;

    IF status_csr%ISOPEN
    THEN
      CLOSE status_csr;
    END IF;
    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
      OPEN status_csr (l_entity_name, l_delivery_leg_id);
    ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
    THEN
      OPEN status_csr (l_entity_name, l_delivery_id_tab(ctr));
    END IF;

    FETCH status_csr INTO status_rec;
    IF status_csr%NOTFOUND THEN
      CLOSE status_csr;
      FND_MESSAGE.set_name ('WSH', 'WSH_DOC_MISSING');
      WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE wsh_document_instances
    SET status = 'OPEN'
    , last_update_date           = sysdate
    , last_updated_by            = fnd_global.user_id
    , last_update_login          = fnd_global.login_id
     WHERE CURRENT OF status_csr;

  END LOOP;
  IF status_csr%ISOPEN
  THEN
    CLOSE status_csr;
  END IF;

  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);
  -- Standard check of p_commit.
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN FND_API.g_exc_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
WHEN others THEN
    ROLLBACK to WSH_Document_PVT;
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                                END IF;
                                --
END Open_Document;

-----------------------------------------------------------------------------
--  PROCEDURE  : Complete_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates the status of a document to 'COMPLETE'
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being completed
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_consolidate_option   calling program's choice to complete document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
-----------------------------------------------------------------------------



PROCEDURE Complete_Document
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_entity_name        IN  VARCHAR2 DEFAULT NULL
, p_entity_id          IN  NUMBER
, p_document_type      IN  VARCHAR2
, p_consolidate_option IN  VARCHAR2 DEFAULT 'BOTH'
)
IS
L_API_NAME           CONSTANT VARCHAR2(30) := 'WSH_Document_PVT';
L_API_VERSION        CONSTANT NUMBER       := 1.0;
l_delivery_id_tab    delivery_id_tabtype   := delivery_id_tabtype();
l_table_count        NUMBER;
l_entity_name        wsh_document_instances.entity_name%type;
l_delivery_id        wsh_new_deliveries.delivery_id%type;
l_delivery_leg_id    wsh_delivery_legs.delivery_leg_id%type;

CURSOR status_csr (c_entity_name IN VARCHAR2, c_entity_id IN NUMBER) IS
SELECT
  entity_id
  , status
FROM
  wsh_document_instances
WHERE entity_name = c_entity_name
  AND entity_id = c_entity_id
  AND document_type = p_document_type
  AND status not in ('CANCELLED')
  FOR UPDATE;

CURSOR trip_stop_csr IS
SELECT
  delivery_id
, pick_up_stop_id
, drop_off_stop_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = p_entity_id;

CURSOR delivery_id_csr (c_delivery_leg_id IN NUMBER) IS
SELECT
  delivery_id
FROM
  wsh_delivery_legs
WHERE delivery_leg_id = c_delivery_leg_id;

trip_stop_rec     trip_stop_csr%rowtype;
delivery_id_rec   delivery_id_csr%rowtype;
status_rec        status_csr%rowtype;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COMPLETE_DOCUMENT';
--
BEGIN
  -- since this procedure does DML issue savepoint
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
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_CONSOLIDATE_OPTION',P_CONSOLIDATE_OPTION);
  END IF;
  --
  SAVEPOINT WSH_Document_PVT;

  -- standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -------------------------------------------------------------
  -- Initialize the entity_name based on the document type   --
  -- If the entity is Delivery leg,  look up its delivery id --
  -- to be used to build the child delivery table later      --
  -------------------------------------------------------------

  l_entity_name := Init_Entity_Name (p_document_type, p_entity_name);
  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN delivery_id_csr (p_entity_id);
    FETCH delivery_id_csr INTO delivery_id_rec;
    l_delivery_id := delivery_id_rec.delivery_id;
    CLOSE delivery_id_csr;
  ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
  THEN
    l_delivery_id := p_entity_id;
  END IF;

  ----------------------------------------------
  -- if the document is for delivery leg      --
  -- get its pick up and drop off trip stops  --
  ----------------------------------------------

  IF l_entity_name = 'WSH_DELIVERY_LEGS'
  THEN
    OPEN trip_stop_csr;
    FETCH trip_stop_csr INTO trip_stop_rec;
    CLOSE trip_stop_csr;
  END IF;

  ---------------------------------------------------------------
  -- based on the consolidate_option identify the delivery ids --
  -- to cancel documents for                                   --
  ---------------------------------------------------------------

  IF (p_consolidate_option IN ('BOTH', 'SEPARATE')) THEN
    GET_ChildDeliveryTab ( l_delivery_id
                         , l_delivery_id_tab );
  END IF;

  IF p_consolidate_option IN ('BOTH', 'CONSOLIDATE') THEN
    l_table_count := l_delivery_id_tab.count;
    l_delivery_id_tab.extend;
    l_delivery_id_tab(l_table_count+1) := l_delivery_id;
  END IF;

  IF NOT l_delivery_id_tab.EXISTS(1) THEN
    FND_MESSAGE.set_name ('WSH', 'WSH_DOC_INVALID_DELIVERY');
    WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR ctr IN 1..l_delivery_id_tab.count LOOP

    -----------------------------------------------------------
    -- For each delivery, if the docuement relates to        --
    -- delivery leg entity then identify the delivery leg id --
    -----------------------------------------------------------

    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
     l_delivery_leg_id := Get_Delivery_Leg_Id ( l_delivery_id_tab(ctr)
                                              , trip_stop_rec.pick_up_stop_id
  		                              , trip_stop_rec.drop_off_stop_id
					      );
    END IF;

    IF status_csr%ISOPEN
    THEN
      CLOSE status_csr;
    END IF;
    IF l_entity_name = 'WSH_DELIVERY_LEGS'
    THEN
      OPEN status_csr (l_entity_name, l_delivery_leg_id);
    ELSIF l_entity_name = 'WSH_NEW_DELIVERIES'
    THEN
      OPEN status_csr (l_entity_name, l_delivery_id_tab(ctr));
    END IF;

    FETCH status_csr INTO status_rec;
    IF status_csr%NOTFOUND THEN
      CLOSE status_csr;
      FND_MESSAGE.set_name ('WSH', 'WSH_DOC_MISSING');
      WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.g_ret_sts_error);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE wsh_document_instances
    SET status = 'COMPLETE'
    , last_update_date           = sysdate
    , last_updated_by            = fnd_global.user_id
    , last_update_login          = fnd_global.login_id
     WHERE CURRENT OF status_csr;

  END LOOP;
  IF status_csr%ISOPEN
  THEN
    CLOSE status_csr;
  END IF;

  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);
  -- Standard check of p_commit.
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN FND_API.g_exc_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
WHEN others THEN
    ROLLBACK to WSH_Document_PVT;
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                                END IF;
                                --
END Complete_Document;


------------------------------------------------------------------------------
--  PROCEDURE  : Print_Document       PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Submit the report WSHRDPAK.rdf to print the packing slip.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_delivery_id          delivery id for which document is being printed
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_departure_date_lo    delivery date (low)
--     p_departure_date_hi    delivery date (high)
--     p_item_display         display FLEX, DESC or BOTH (default BOTH)
--     p_print_cust_item      print customer item information or not (default
--                            NO)
--     p_print_mode           print FINAL or DRAFT (default DRAFT)
--     p_print_all            calling program's choice to cancel document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--     p_sort                 sort the report by customer item or inventory
--                            item (INV or CUST, default INV)
--     p_freight_carrier      carrier_id of the freight carrier
--     p_warehouse_id         current organization_id
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Print_Document
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_delivery_id        IN  NUMBER
, p_document_type      IN  VARCHAR2
, p_departure_date_lo  IN  DATE     DEFAULT NULL
, p_departure_date_hi  IN  DATE     DEFAULT NULL
, p_item_display       IN  VARCHAR2 DEFAULT 'D'
, p_print_cust_item    IN  VARCHAR2 DEFAULT 'N'
, p_print_mode         IN  VARCHAR2 DEFAULT 'DRAFT'
, p_print_all          IN  VARCHAR2 DEFAULT 'BOTH'
, p_sort               IN  VARCHAR2 DEFAULT 'INV'
, p_freight_carrier    IN  VARCHAR2 DEFAULT NULL
, p_warehouse_id       IN  NUMBER
, x_conc_request_id    OUT NOCOPY  NUMBER
)
IS
l_api_name           CONSTANT VARCHAR2(30) := 'Print_Document';
l_api_version        CONSTANT NUMBER       := 1.0;
l_conc_request_id    NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_DOCUMENT';
--
BEGIN
  -- standard call to check for call compatibility.
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_DEPARTURE_DATE_LO',P_DEPARTURE_DATE_LO);
      WSH_DEBUG_SV.log(l_module_name,'P_DEPARTURE_DATE_HI',P_DEPARTURE_DATE_HI);
      WSH_DEBUG_SV.log(l_module_name,'P_ITEM_DISPLAY',P_ITEM_DISPLAY);
      WSH_DEBUG_SV.log(l_module_name,'P_PRINT_CUST_ITEM',P_PRINT_CUST_ITEM);
      WSH_DEBUG_SV.log(l_module_name,'P_PRINT_MODE',P_PRINT_MODE);
      WSH_DEBUG_SV.log(l_module_name,'P_PRINT_ALL',P_PRINT_ALL);
      WSH_DEBUG_SV.log(l_module_name,'P_SORT',P_SORT);
      WSH_DEBUG_SV.log(l_module_name,'P_FREIGHT_CARRIER',P_FREIGHT_CARRIER);
      WSH_DEBUG_SV.log(l_module_name,'P_WAREHOUSE_ID',P_WAREHOUSE_ID);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -- call FND_REQUEST.SUBMIT_REQUEST to run the WSHRDPAK.rdf report
  l_conc_request_id := FND_REQUEST.SUBMIT_REQUEST
                       ( 'WSH'
                       , 'WSHRDPAK'
                       , 'Packing Slip Report'
                       , NULL
                       , FALSE
                       , p_delivery_id
                       , p_print_cust_item
                       , p_item_display
                       , p_print_mode
                       , p_print_all
                       , p_sort
                       , p_departure_date_lo
                       , p_departure_date_hi
                       , p_freight_carrier
                       , p_warehouse_id
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', ''
                       , '', '', '', '', '', '', '', '', '', '');

  -- must commit in order to submit the request
  COMMIT WORK;

  x_conc_request_id := l_conc_request_id;

  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'REQUEST ID',x_conc_request_id);
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN FND_API.g_exc_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
                                END IF;
                                --
  WHEN others THEN
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                                END IF;
                                --
END Print_Document;

------------------------------------------------------------------------------
--  FUNCTION   : Get_CumQty        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Obtain cummulative quantity value based on the inputs
--               by calling Automotive's CUM Management API.  Return such
--               value.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_customer_id          from delivery details
--     p_oe_order_line_id     from delivery details for getting line level
--                            information to be passed to cal_cum api
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     RETURN                 NUMBER, cum quantity value
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

FUNCTION Get_CumQty
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_customer_id               IN  NUMBER
, p_oe_order_line_id          IN  NUMBER
)
RETURN NUMBER
IS
L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_CumQty';
L_API_VERSION              CONSTANT NUMBER       := 1.0;
l_msg_flag                 VARCHAR2(2000);
l_cum_qty                  NUMBER;
l_customer_item_id         RLM_CUST_ITEM_CUM_KEYS.CUSTOMER_ITEM_ID%TYPE;
l_ship_from_org_id         RLM_CUST_ITEM_CUM_KEYS.SHIP_FROM_ORG_ID%TYPE;
l_ship_to_address_id       RLM_CUST_ITEM_CUM_KEYS.SHIP_TO_ADDRESS_ID%TYPE;
l_bill_to_address_id       RLM_CUST_ITEM_CUM_KEYS.BILL_TO_ADDRESS_ID%TYPE;
l_po_number                RLM_CUST_ITEM_CUM_KEYS.PURCHASE_ORDER_NUMBER%TYPE;
l_cust_record_year         RLM_CUST_ITEM_CUM_KEYS.CUST_RECORD_YEAR%TYPE;
l_inventory_item_id        OE_ORDER_LINES_ALL.INVENTORY_ITEM_ID%TYPE;
l_cum_key_record           RLM_CUM_SV.cum_key_attrib_rec_type;
l_cum_record               RLM_CUM_SV.cum_rec_type;
-- 1711448
l_source_doc_hdr_id        NUMBER;
l_source_doc_line_id       NUMBER;
l_cum_start_date           DATE;
l_return_message           VARCHAR2(4000);
l_msg_data                 VARCHAR2(4000);
l_return_status            BOOLEAN;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_CUMQTY';
--
BEGIN
  -- standard call to check for call compatibility.
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
      WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_CUSTOMER_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_OE_ORDER_LINE_ID',P_OE_ORDER_LINE_ID);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -- initially l_cum_qty=0
  l_cum_qty :=0;

  -- get information required about that order line from OE
  -- 1711448, changed to hz Tables from oe views
  SELECT
    ol.ship_from_org_id
  , ol.source_document_id
  , ol.source_document_line_id
  , ss.cust_acct_site_id
  , bs.cust_acct_site_id
  , DECODE (ol.item_identifier_type,
		  'CUST', ol.ordered_item_id, NULL)
  , ol.cust_po_number
  , ol.industry_attribute1
  , ol.inventory_item_id
  INTO
    l_ship_from_org_id
  , l_source_doc_hdr_id
  , l_source_doc_line_id
  , l_ship_to_address_id
  , l_bill_to_address_id
  , l_customer_item_id
  , l_po_number
  , l_cust_record_year
  , l_inventory_item_id
  FROM
    oe_order_lines_all ol
  , hz_cust_acct_sites_all ss
  , hz_cust_site_uses_all ssu
  , hz_cust_acct_sites_all bs
  , hz_cust_site_uses_all bsu
  WHERE ol.line_id=p_oe_order_line_id
    and ol.ship_to_org_id = ssu.site_use_id (+)
    and ssu.site_use_code = 'SHIP_TO'
    and ol.invoice_to_org_id = bsu.site_use_id (+)
    and bsu.site_use_code = 'BILL_TO'
    and ssu.cust_acct_site_ID = ss.cust_acct_site_ID
    and bsu.cust_acct_site_ID = bs.cust_acct_site_ID;

  IF SQL%NOTFOUND or SQL%ROWCOUNT > 1
  THEN
    RAISE FND_API.g_exc_error;
  END IF;

  -- 1711448,  Added this API to get CUM Start Date
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit RLM_CUM_SV.GETCUMSTARTDATE',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  RLM_CUM_SV.GetCumStartDate(
         i_schedule_header_id => l_source_doc_hdr_id,
         i_schedule_line_id   => l_source_doc_line_id,
         o_cum_start_date     => l_cum_start_date,
         o_cust_record_year   => l_cust_record_year,
         o_return_message     => l_msg_data,
         o_return_status      => l_return_status
  );

  -- prepare the record parameters for use by the cum apis
  l_cum_key_record.customer_id:=p_customer_id;
  l_cum_key_record.customer_item_id:=l_customer_item_id;
  l_cum_key_record.ship_from_org_id:=l_ship_from_org_id;
  l_cum_key_record.ship_to_address_id:=l_ship_to_address_id;
  l_cum_key_record.bill_to_address_id:=l_bill_to_address_id;
  l_cum_key_record.purchase_order_number:=l_po_number;
  l_cum_key_record.cust_record_year:=l_cust_record_year;
  l_cum_key_record.create_cum_key_flag:='N';
  -- 1711448,  Added Cum start Dt.
  l_cum_key_record.cum_start_date:=l_cum_start_date;

  --BUG 1932236
  l_cum_key_record.inventory_item_id:=l_inventory_item_id;

  -- get cum_key by calling calculate_cum_key routine in RLM_CUM_SV
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit RLM_TPA_SV.CALCULATECUMKEY',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  RLM_TPA_SV.CalculateCumKey( x_cum_key_record=>l_cum_key_record
                            , x_cum_record=>l_cum_record);

  -- get cum_qty by calling calculate_supplier_cum in RLM_CUM_SV
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit RLM_TPA_SV.CALCULATESUPPLIERCUM',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  RLM_TPA_SV.CalculateSupplierCum( x_cum_key_record=>l_cum_key_record
                                 , x_cum_record=>l_cum_record);

  l_cum_qty:=l_cum_record.cum_qty;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'L_CUM_QTY',l_cum_qty);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  RETURN l_cum_qty;

EXCEPTION

  WHEN FND_API.g_exc_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
    --
    RETURN null;

  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
    RETURN null;

  WHEN others THEN
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
    RETURN null;
END Get_CumQty;

------------------------------------------------------------------------------
--  PROCEDURE  : Cancel_All_Documents       PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates status of all documents of all types that
--               belong to a specific entity
--               to 'CANCELLED'
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being cancelled
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
--     NOTES           :     In consolidation situation, the child documents
--                           are not cancelled. Call this routine recursively
--                           for all entities where cancellation is reqd.
------------------------------------------------------------------------------

PROCEDURE Cancel_All_Documents
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_entity_name        IN  VARCHAR2
, p_entity_id          IN  NUMBER
) IS
L_API_NAME                 CONSTANT VARCHAR2(30) := 'Cancel_All_Documents';
L_API_VERSION              CONSTANT NUMBER       := 1.0;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_ALL_DOCUMENTS';
--
BEGIN
  -- since this procedure does DML issue savepoint
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
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
  END IF;
  --
  SAVEPOINT WSH_Document_PVT;

  -- standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;


  UPDATE wsh_document_instances
  SET status = 'CANCELLED'
  , last_update_date           = sysdate
  , last_updated_by            = fnd_global.user_id
  , last_update_login          = fnd_global.login_id
  WHERE entity_name = p_entity_name
  AND   entity_id = p_entity_id;

  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);
  -- Standard check of p_commit.
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN FND_API.g_exc_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK to WSH_Document_PVT;
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
WHEN others THEN
    ROLLBACK to WSH_Document_PVT;
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                                END IF;
                                --
END Cancel_All_Documents;

------------------------------------------------------------------------------
--  PROCEDURE  : Get_All_Documents        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Returns as an out-param a table of records of all documents
--               (packing slip, bill of lading, etc.) that belong to a
--               specific entity (delivery, delivery_leg, etc.)
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being cancelled
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc

--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--     x_document_tab         table that contains all documents of the entity
--
--     PRE-CONDITIONS      :  None
--     POST-CONDITIONS     :  None
--     EXCEPTIONS          :  None
------------------------------------------------------------------------------

PROCEDURE Get_All_Documents
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_entity_name               IN  VARCHAR2
, p_entity_id                 IN  NUMBER
, x_document_tab              OUT NOCOPY  wsh_document_pub.document_tabtype
) IS
L_API_NAME                 CONSTANT VARCHAR2(30) := 'Get_All_Documents';
L_API_VERSION              CONSTANT NUMBER       := 1.0;
CURSOR doc_csr IS
SELECT document_instance_id
	, document_type
	, entity_name
	, entity_id
	, doc_sequence_category_id
	, sequence_number
	, status
	, final_print_date
	, created_by
	, creation_date
	, last_updated_by
	, last_update_date
	, last_update_login
	, program_application_id
	, program_id
	, program_update_date
	, request_id
	, attribute_category
	, attribute1
	, attribute2
	, attribute3
	, attribute4
	, attribute5
	, attribute6
	, attribute7
	, attribute8
	, attribute9
	, attribute10
	, attribute11
	, attribute12
	, attribute13
	, attribute14
	, attribute15
FROM   wsh_document_instances
WHERE  entity_name = p_entity_name
AND    entity_id = p_entity_id;

i      NUMBER := 1;  -- loop counter

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ALL_DOCUMENTS';
--
BEGIN

  -- standard call to check for call compatibility.
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
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
  END IF;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
        	         	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  -- Initialize the table
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_PUB.DOCUMENT_TABTYPE',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  x_document_tab := wsh_document_pub.document_tabtype();


  FOR doc_rec IN doc_csr
  LOOP
    x_document_tab.extend;
    x_document_tab(i).document_instance_id:= doc_rec.document_instance_id;
    x_document_tab(i).document_type       := doc_rec.document_type;
    x_document_tab(i).entity_name         := doc_rec.entity_name;
    x_document_tab(i).entity_id           := doc_rec.entity_id;
    x_document_tab(i).doc_sequence_category_id
								  := doc_rec.doc_sequence_category_id;
    x_document_tab(i).sequence_number     := doc_rec.sequence_number;
    x_document_tab(i).status              := doc_rec.status;
    x_document_tab(i).final_print_date    := doc_rec.final_print_date;
    x_document_tab(i).created_by          := doc_rec.created_by;
    x_document_tab(i).creation_date       := doc_rec.creation_date;
    x_document_tab(i).last_updated_by     := doc_rec.last_updated_by;
    x_document_tab(i).last_update_date    := doc_rec.last_update_date;
    x_document_tab(i).last_update_login   := doc_rec.last_update_login;
    x_document_tab(i).program_application_id
								  := doc_rec.program_application_id;
    x_document_tab(i).program_id          := doc_rec.program_id;
    x_document_tab(i).program_update_date := doc_rec.program_update_date;
    x_document_tab(i).request_id          := doc_rec.request_id;
    x_document_tab(i).attribute_category  := doc_rec.attribute_category;
    x_document_tab(i).attribute1          := doc_rec.attribute1;
    x_document_tab(i).attribute2          := doc_rec.attribute2;
    x_document_tab(i).attribute3          := doc_rec.attribute3;
    x_document_tab(i).attribute4          := doc_rec.attribute4;
    x_document_tab(i).attribute5          := doc_rec.attribute5;
    x_document_tab(i).attribute6          := doc_rec.attribute6;
    x_document_tab(i).attribute7          := doc_rec.attribute7;
    x_document_tab(i).attribute8          := doc_rec.attribute8;
    x_document_tab(i).attribute9          := doc_rec.attribute9;
    x_document_tab(i).attribute10         := doc_rec.attribute10;
    x_document_tab(i).attribute11         := doc_rec.attribute11;
    x_document_tab(i).attribute12         := doc_rec.attribute12;
    x_document_tab(i).attribute13         := doc_rec.attribute13;
    x_document_tab(i).attribute14         := doc_rec.attribute14;
    x_document_tab(i).attribute15         := doc_rec.attribute15;
    i := i + 1;
  END LOOP;

  -- get message count and the message itself (if only one message)
  FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                             p_data => x_msg_data);
  -- Standard check of p_commit.
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_TAB.COUNT',x_document_tab.count);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

  WHEN FND_API.g_exc_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
END IF;
--
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
END IF;
--
WHEN others THEN
    FND_MESSAGE.set_name ('WSH','WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token ('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token ('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token ('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count,
                                p_data => x_msg_data );
                                --
                                -- Debug Statements
                                --
                                IF l_debug_on THEN
                                    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                                    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                                END IF;
                                --
END Get_All_Documents;

------------------------------------------------------------------------------
--  PROCEDURE  : Lock_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Locks a document row
--
--  PARAMETER LIST :
--
--     IN
--
--     p_rowid                Rowid of wsh_document_instances table
--     p_document_instance_id document instance id
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_sequence_number      sequence number of the document
--     p_status               status of the document
--     p_final_print_date     final print date
--     p_entity_name          Entity for which the document is being updated
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_doc_sequence_category_id   document sequence category id
--     p_pod_flag             pod_flag for the document
--     p_pod_by               pod_by for the document
--     p_pod_date             pod_date for the document
--     p_reason_of_transport  reason of transport that describes the delivery
--     p_description          external aspect of the delivery
--     p_cod_amount           cod_amount of the document
--     p_cod_currency_code    cod_currency_code of the document
--     p_cod_remit_to         cod_remit_to of the document
--     p_cod_charge_paid_by   cod_charge_paid_by of the document
--     p_problem_contact_reference   problem_contact_referene of the document
--     p_bill_freight_to      bill_freight_to of the document
--     p_carried_by           carried_by of the document
--     p_port_of_loading      port_of_loading of the docucent
--     p_port_of_discharge    port_of_discharge of the document
--     p_booking_office       booking_office of the document
--     p_booking_number       booking_number of the document
--     p_service_contract     service_contract of the document
--     p_shipper_export_ref   shipper_export_ref of the document
--     p_carrier_export_ref   carrier_export_ref of the document
--     p_bol_notify_party     bol_notify_party of the document
--     p_supplier_code        supplier_code of the document
--     p_aetc_number          aetc_number of the document
--     p_shipper_signed_by    shipper_signed_by of the document
--     p_shipper_date         shipper_date of the document
--     p_carrier_signed_by    carrier_signed_by of the document
--     p_carrier_date         carrier_date of the document
--     p_bol_issue_office     bol_issue_office of the document
--     p_bol_issued_by        bol_issued_by of the document
--     p_bol_date_issued      bol_date_issued of the document
--     p_shipper_hm_by        shipper_bm_by of the document
--     p_shipper_hm_date      shipper_hm_date of the document
--     p_carrier_hm_by        carrier_hm_by of the document
--     p_carrier_hm_date      carrier_hm_date of the document
--     p_created_by           standard who column
--     p_creation_date        standard who column
--     p_last_updated_by      standard who column
--     p_last_update_date     standard who column
--     p_last_update_login    standard who column
--     p_program_applicaiton_id   standard who column
--     p_program_id           standard who column
--     p_program_update_date  standard who column
--     p_request_id           standard who column
--     p_attribute_category   Descriptive Flex field context
--     p_attribute1           Descriptive Flex field
--     p_attribute2           Descriptive Flex field
--     p_attribute3           Descriptive Flex field
--     p_attribute4           Descriptive Flex field
--     p_attribute5           Descriptive Flex field
--     p_attribute6           Descriptive Flex field
--     p_attribute7           Descriptive Flex field
--     p_attribute8           Descriptive Flex field
--     p_attribute9           Descriptive Flex field
--     p_attribute10          Descriptive Flex field
--     p_attribute11          Descriptive Flex field
--     p_attribute12          Descriptive Flex field
--     p_attribute13          Descriptive Flex field
--     p_attribute14          Descriptive Flex field
--     p_attribute15          Descriptive Flex field
--
--     OUT
--
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
--
--     NOTES           :  1. Called from Shipping trx form only. Not an API.
--					    Does not conform to API standards.
--
--					 2. In a consolidation situation, this routine looks
--					    for a lock only on the parent document only.
--
------------------------------------------------------------------------------


PROCEDURE Lock_Document
( p_rowid                     IN  VARCHAR2
, p_document_instance_id      IN  NUMBER
, p_document_type             IN  VARCHAR2
, p_sequence_number           IN  VARCHAR2
, p_status                    IN  VARCHAR2
, p_final_print_date          IN  DATE
, p_entity_name               IN  VARCHAR2
, p_entity_id                 IN  NUMBER
, p_doc_sequence_category_id  IN  NUMBER
, p_created_by                IN  NUMBER
, p_creation_date             IN  DATE
, p_last_updated_by           IN  NUMBER
, p_last_update_date          IN  DATE
, p_last_update_login         IN  NUMBER
, p_program_application_id    IN  NUMBER
, p_program_id                IN  NUMBER
, p_program_update_date       IN  DATE
, p_request_id                IN  NUMBER
, p_attribute_category        IN  VARCHAR2
, p_attribute1                IN  VARCHAR2
, p_attribute2                IN  VARCHAR2
, p_attribute3                IN  VARCHAR2
, p_attribute4                IN  VARCHAR2
, p_attribute5                IN  VARCHAR2
, p_attribute6                IN  VARCHAR2
, p_attribute7                IN  VARCHAR2
, p_attribute8                IN  VARCHAR2
, p_attribute9                IN  VARCHAR2
, p_attribute10               IN  VARCHAR2
, p_attribute11               IN  VARCHAR2
, p_attribute12               IN  VARCHAR2
, p_attribute13               IN  VARCHAR2
, p_attribute14               IN  VARCHAR2
, p_attribute15               IN  VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
) IS

  counter NUMBER;
  CURSOR  lock_csr IS
    SELECT
      document_instance_id
    , document_type
    , sequence_number
    , status
    , final_print_date
    , entity_name
    , entity_id
    , doc_sequence_category_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_application_id
    , program_id
    , program_update_date
    , request_id
    , attribute_category
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    FROM
      wsh_document_instances
    WHERE rowid = p_rowid
    FOR UPDATE OF document_instance_id NOWAIT;
  lock_rec lock_csr%rowtype;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DOCUMENT';
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
      WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_INSTANCE_ID',P_DOCUMENT_INSTANCE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'P_SEQUENCE_NUMBER',P_SEQUENCE_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_STATUS',P_STATUS);
      WSH_DEBUG_SV.log(l_module_name,'P_FINAL_PRINT_DATE',P_FINAL_PRINT_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_DOC_SEQUENCE_CATEGORY_ID',P_DOC_SEQUENCE_CATEGORY_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_CREATED_BY',P_CREATED_BY);
      WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE',P_CREATION_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
      WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
      WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_APPLICATION_ID',P_PROGRAM_APPLICATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_ID',P_PROGRAM_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_UPDATE_DATE',P_PROGRAM_UPDATE_DATE);
      WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
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
  END IF;
  --
  OPEN lock_csr;
  FETCH lock_csr INTO lock_rec;
  IF lock_csr%NOTFOUND
  THEN
    CLOSE lock_csr;
    FND_MESSAGE.set_name ('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.raise_exception;
  END IF;
  CLOSE lock_csr;

  -- verify the not null columns are identical
  IF (  lock_rec.document_instance_id = p_document_instance_id
    AND lock_rec.document_type        = p_document_type
    AND lock_rec.sequence_number      = p_sequence_number
    AND lock_rec.entity_name          = p_entity_name
    AND lock_rec.entity_id            = p_entity_id
    AND lock_rec.created_by           = p_created_by
    AND lock_rec.creation_date        = p_creation_date
    AND lock_rec.last_updated_by      = p_last_updated_by
    AND lock_rec.last_update_date     = p_last_update_date

    -- verify the nullable columns are either identical or both null
    AND ((lock_rec.status = p_status)
        OR
        (lock_rec.status IS NULL AND p_status IS NULL))
    AND ((lock_rec.final_print_date = p_final_print_date)
	   OR
	   (lock_rec.final_print_date IS NULL AND p_final_print_date IS NULL))
    AND ((lock_rec.doc_sequence_category_id = p_doc_sequence_category_id)
	   OR
	   (lock_rec.doc_sequence_category_id IS NULL AND
								  p_doc_sequence_category_id IS NULL))
    AND ((lock_rec.last_update_login = p_last_update_login)
	   OR
	   (lock_rec.last_update_login IS NULL AND p_last_update_login IS NULL))
    AND ((lock_rec.program_application_id = p_program_application_id)
	   OR
	   (lock_rec.program_application_id IS NULL AND
									 p_program_application_id IS NULL))
    AND ((lock_rec.program_id = p_program_id)
	   OR
	   (lock_rec.program_id IS NULL AND p_program_id IS NULL))
    AND ((lock_rec.program_update_date = p_program_update_date)
	   OR
       (lock_rec.program_update_date IS NULL AND p_program_update_date IS NULL))
    AND ((lock_rec.request_id = p_request_id)
	   OR
	   (lock_rec.request_id IS NULL AND p_request_id IS NULL))
    AND ((lock_rec.attribute_category = p_attribute_category)
	   OR
	   (lock_rec.attribute_category IS NULL AND p_attribute_category IS NULL))
    AND ((lock_rec.attribute1 = p_attribute1)
	   OR
	   (lock_rec.attribute1 IS NULL AND p_attribute1 IS NULL))
    AND ((lock_rec.attribute2 = p_attribute2)
	   OR
	   (lock_rec.attribute2 IS NULL AND p_attribute2 IS NULL))
    AND ((lock_rec.attribute3 = p_attribute3)
	   OR
	   (lock_rec.attribute3 IS NULL AND p_attribute3 IS NULL))
    AND ((lock_rec.attribute4 = p_attribute4)
	   OR
	   (lock_rec.attribute4 IS NULL AND p_attribute4 IS NULL))
    AND ((lock_rec.attribute5 = p_attribute5)
	   OR
	   (lock_rec.attribute5 IS NULL AND p_attribute5 IS NULL))
    AND ((lock_rec.attribute6 = p_attribute6)
	   OR
	   (lock_rec.attribute6 IS NULL AND p_attribute6 IS NULL))
    AND ((lock_rec.attribute7 = p_attribute7)
	   OR
	   (lock_rec.attribute7 IS NULL AND p_attribute7 IS NULL))
    AND ((lock_rec.attribute8 = p_attribute8)
	   OR
	   (lock_rec.attribute8 IS NULL AND p_attribute8 IS NULL))
    AND ((lock_rec.attribute9 = p_attribute9)
	   OR
	   (lock_rec.attribute9 IS NULL AND p_attribute9 IS NULL))
    AND ((lock_rec.attribute10 = p_attribute10)
	   OR
	   (lock_rec.attribute10 IS NULL AND p_attribute10 IS NULL))
    AND ((lock_rec.attribute11 = p_attribute11)
	   OR
	   (lock_rec.attribute11 IS NULL AND p_attribute11 IS NULL))
    AND ((lock_rec.attribute12 = p_attribute12)
	   OR
	   (lock_rec.attribute12 IS NULL AND p_attribute12 IS NULL))
    AND ((lock_rec.attribute13 = p_attribute13)
	   OR
	   (lock_rec.attribute13 IS NULL AND p_attribute13 IS NULL))
    AND ((lock_rec.attribute14 = p_attribute14)
	   OR
	   (lock_rec.attribute14 IS NULL AND p_attribute14 IS NULL))
    AND ((lock_rec.attribute15 = p_attribute15)
	   OR
	   (lock_rec.attribute15 IS NULL AND p_attribute15 IS NULL))
     )
  THEN
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    return;
  ELSE
    FND_MESSAGE.set_name('FND','FORM_RECORD_CHANGED');
    APP_EXCEPTION.raise_exception;
  END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Lock_Document;


------------------------------------------------------------------------------
--  PROCEDURE   : set_template        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : This procedure is called before calling fnd_request.submit to
--               set the layout template so that pdf output is generated.
--		 Template is obtained from shipping parameters based on the
--               organization_id.
--  PARAMETER LIST :
--
--     IN
--
--     p_organization_id          Organization Id
--     p_report                   'BOL'/'MBOL'/'PAK'
--
--     OUT
--
--     x_conc_prog_name       'WSHRDBOL'/'WSHRDBOLX'/'WSHRDMBL'/'WSHRDMBLX'/'WSHRDPAK'/'WSHRDPAKX'
--     x_return_status        API return status ('S', 'E', 'U')
--
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------


PROCEDURE set_template ( p_organization_id	NUMBER,
			 p_report		VARCHAR2,
			 p_template_name        VARCHAR2,
			 x_conc_prog_name	OUT NOCOPY VARCHAR2,
			 x_return_status        OUT NOCOPY VARCHAR2	) IS

    l_language          VARCHAR2(100);
    l_territory         VARCHAR2(100);
    l_param_value_info  WSH_SHIPPING_PARAMS_PVT.parameter_value_rec_typ;
    l_report_template   VARCHAR2(80);
    l_return_status	VARCHAR2(1);
    l_status            BOOLEAN;
    l_conc_prog_name    VARCHAR2(10);
    get_shipping_param_err	EXCEPTION;

    l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'set_template';

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
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_REPORT',P_REPORT);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_param_value_info.organization_id	:= p_organization_id;
  l_param_value_info.class_code(1)	:= 'XDO_TEMPLATE';
  l_param_value_info.param_name(1)	:= p_template_name;

  IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_SHIPPING_PARAMS_PVT.Get',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;

  wsh_shipping_params_pvt.get(l_param_value_info,l_return_status);
  IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR))
  THEN
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'WSH_SHIPPING_PARAMS_PVT.Get returned '||l_return_status);
	END IF;
        RAISE get_shipping_param_err;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'param_name.count '||l_param_value_info.param_name.COUNT);
    WSH_DEBUG_SV.logmsg(l_module_name,'param_name_chr.count '||l_param_value_info.param_value_chr.COUNT);
  END IF;
  --
  IF (l_param_value_info.param_value_chr.COUNT >0 and l_param_value_info.param_name.COUNT >0) THEN
	  IF (l_param_value_info.param_name(1) = p_template_name) THEN
		l_report_template := l_param_value_info.param_value_chr(1);
	  END IF;
  ELSE
  	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'No Parameters returned from WSH_SHIPPING_PARAMS_PVT.Get ');
	END IF;
        RAISE get_shipping_param_err;
  END IF;

  IF l_debug_on THEN
	wsh_debug_sv.log(l_module_name, 'Report Template from Shipping Parameters ',l_report_template);
  END IF;

  IF (l_report_template IS NULL ) THEN
	l_conc_prog_name := 'WSHRD' || p_report;
  ELSE
   --{
	l_conc_prog_name := 'WSHRD' || p_report || 'X';
	SELECT ISO_LANGUAGE, ISO_TERRITORY INTO l_language, l_territory
	FROM FND_LANGUAGES
	WHERE LANGUAGE_CODE = userenv('LANG');

        IF l_debug_on THEN
            wsh_debug_sv.log(l_module_name, 'language ', l_language);
            wsh_debug_sv.log(l_module_name, 'territory ', l_territory);
	END IF;

	l_status := fnd_request.add_layout
			    ('WSH',
			     l_report_template,
			     l_language,
			     l_territory,
			     'PDF');
	IF l_debug_on THEN
		wsh_debug_sv.log(l_module_name,'Return Status After Calling fnd_request.add_layout ',l_status);
	END IF;
	IF (l_status=FALSE) THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status,l_module_name);
	END IF;
  --}
  END IF;
  x_conc_prog_name := l_conc_prog_name;

  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
    WHEN get_shipping_param_err THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('WSH', 'WSH_PARAM_NOT_DEFINED');
      FND_MESSAGE.Set_Token('ORGANIZATION_CODE',
                        wsh_util_core.get_org_name(p_organization_id));
      wsh_util_core.add_message(x_return_status,l_module_name);

      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Failed to get Shipping Parameters',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:GET_SHIPPING_PARAM_ERR');
      END IF;

   WHEN OTHERS THEN

        wsh_util_core.default_handler('WSH_DOCUMENT_PVT.set_template',l_module_name);
	x_return_status := wsh_util_core.g_ret_sts_unexp_error;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	END IF;
End set_template;


END WSH_Document_PVT;

/
