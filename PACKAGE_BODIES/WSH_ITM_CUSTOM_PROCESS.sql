--------------------------------------------------------
--  DDL for Package Body WSH_ITM_CUSTOM_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ITM_CUSTOM_PROCESS" AS
/* $Header: WSHITPPB.pls 120.0.12010000.3 2008/11/28 06:08:40 sankarun ship $ */

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_ITM_CUSTOM_PROCESS';

/*===========================================================================+
| PROCEDURE                                                                 |
|              PRE_PROCESS_REQUEST                                              |
|                                                                           |
| DESCRIPTION                                                               |
|              This procedure is called from Submit Deleiveries for          |
|              Screening concurrent program which populates the interface   |
|              table.                                         |
|              Customers are given the flexibilty of adding additional      |
|              attributes to the Interface table/Additional Logic         |
|              in the code as per their Requirements through THIS procedure |
|                                                                           |
+===========================================================================*/

        PROCEDURE PRE_PROCESS_WSH_REQUEST (
                                            p_request_control_id IN NUMBER
                                           )IS

            l_debug_on BOOLEAN;
            --
            l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRE_PROCESS_WSH_REQUEST';
            --
        BEGIN
            --
            l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
            --
            IF l_debug_on IS NULL
            THEN
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
            END IF;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.push('Entering' || l_module_name);
            END IF;

         --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop('Exiting' || l_module_name);
            END IF;
            --

        END PRE_PROCESS_WSH_REQUEST;


 /*===========================================================================+
| PROCEDURE                                                                 |
|              POST_PROCESS_REQUEST                                                |
|                                                                           |
| DESCRIPTION                                                               |
|              This procedure is called when response is sent for Delivery  |
|              Screening request and is called via XML gateway.             |
|              Customers are given the flexibilty of adding Additional      |
|              Logic in the code as per their Requirements through THIS     |
|              procedure                                                    |
+===========================================================================*/

        PROCEDURE POST_PROCESS_WSH_REQUEST (
                         p_request_control_id IN NUMBER
                                   )IS

            --
            l_debug_on BOOLEAN;
            --
            l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POST_PROCESS_WSH_REQUEST';
            --
        BEGIN
            --
            l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
            --
            IF l_debug_on IS NULL
            THEN
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
            END IF;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.push(' Entering ' || l_module_name);
            END IF;

         --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop('Exiting' || l_module_name);
            END IF;
            --

        END POST_PROCESS_WSH_REQUEST;


/*===========================================================================+
| PROCEDURE                                                                 |
|              PRE_PROCESS_ONT_REQUEST                                          |
| Parameters  :   IN  p_request_control_id                                        |
|                 IN  p_line_id                                             |
| DESCRIPTION                                                               |
|              This procedure is called at the time of Booking Order        |
|              with ITM check included in the Workflow                   |
|              table.                                         |
|              Customers are given the flexibilty of adding additional      |
|              attributes to the Interface table/Additional Logic         |
|              in the code as per their Requirements through THIS procedure |
|                                                                           |
+===========================================================================*/

PROCEDURE PRE_PROCESS_ONT_REQUEST(
                                   p_request_control_id IN NUMBER,
                                   p_line_id     IN  NUMBER
                                 ) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Entering WSH_ITM_CUSTOM_PROCESS.PRE_PROCESS_ONT_REQUEST....' , 4 ) ;
     END IF;


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Exiting WSH_ITM_CUSTOM_PROCESS.PRE_PROCESS_ONT_REQUEST....',4);
     END IF;

Exception
     WHEN NO_DATA_FOUND THEN
        NULL;
END PRE_PROCESS_ONT_REQUEST;



/*===========================================================================+
| PROCEDURE                                                                 |
|              POST_PROCESS_ONT_REQUEST                                         |
| Parameters  :   IN  p_request_control_id                        |
|                 IN  p_line_id                                             |
| DESCRIPTION                                                               |
|              This procedure is called when response is sent for           |
|              Order/DP screening                               |
|              Customers are given the flexibilty of adding additional      |
|              attributes to the Interface table/Additional Logic         |
|              in the code as per their Requirements through THIS procedure |
|                                                                           |
+===========================================================================*/

PROCEDURE POST_PROCESS_ONT_REQUEST(
                                   p_request_control_id IN NUMBER
                                  ) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Entering WSH_ITM_CUSTOM_PROCESS.POST_PROCESS_ONT_REQUEST....' , 4 ) ;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Exiting WSH_ITM_CUSTOM_PROCESS.POST_PROCESS_ONT_REQUEST....',4);
     END IF;

Exception
     WHEN NO_DATA_FOUND THEN
        NULL;
END POST_PROCESS_ONT_REQUEST;

-- Bug 7284454 - Added proc PRE_PROCESS_PTO, to provide option to customer
--               to send all components of PTO model in Single Request XML

/*==================================================================================+
| PROCEDURE   :                                                                     |
|               GRP_MODEL_LINES_IN_SINGLE_REQ                                       |
|                                                                                   |
| DESCRIPTION                                                                       |
|              This procedure is called before task is created, if Return parameter |
|              is set to 'Y' then all Components of a PTO Model will be sent in     |
|              a single Request XML to avoid 'Locking Contention' problem. If it    |
|              set to 'N' then each component of a PTO Model will be sent in        |
|              separate Request XML.                                                |
|                                                                                   |
|              Customer can set it to 'Y', if the ITM Vendor supports Multiple      |
|              line screening (all Components of PTO Model) in Single Request XML.  |
|                                                                                   |
+===================================================================================*/

 FUNCTION GRP_MODEL_LINES_IN_SINGLE_REQ Return Varchar2

 IS

            l_debug_on BOOLEAN;
            --
            l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRE_PROCESS_PTO';
            --
        BEGIN
            --
            l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
            --
            IF l_debug_on IS NULL
            THEN
                l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
            END IF;
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.push('Entering' || l_module_name);
            END IF;

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.pop('Exiting' || l_module_name);
            END IF;
            --
             /*  - By default Return variable is set to 'N', if needed customer
                   can set it to 'Y'
                 - Return variable should not be more than one character        */

	    return 'N';

        END GRP_MODEL_LINES_IN_SINGLE_REQ;

END WSH_ITM_CUSTOM_PROCESS;

/
