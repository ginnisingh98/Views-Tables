--------------------------------------------------------
--  DDL for Package EGO_ODI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ODI_PUB" AUTHID CURRENT_USER as
/* $Header: EGOODIXS.pls 120.1.12010000.14 2009/11/07 01:33:41 emtapia noship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : EGOODIXS.pls                                               |
| DESCRIPTION  : This file is a packaged procedure for the BOM exploders    |
|                                                                           |
|                                                                           |
+==========================================================================*/


--  ============================================================================
--  Name        : Generate_XML
--  Description : This procedure generates the ODI output XML from the results
--                stored in intermediate table EGO_PUB_WS_FLAT_RECS
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--                p_web_service_name    IN      VARCHAR2
--                The name of the web service for which the output will be
--                generated
--
--                p_xml_root_element    IN      VARCHAR2
--                The name to give to the root element containing the XML output
--
--                p_transform_xml       IN      BOOLEAN DEFAULT TRUE
--                Tells if the ODI output XML will be transformed into the
--                final output XML using the XSL data contained in table
--                EGO_ODI_WS_XSL for a given web service.
--  ============================================================================

PROCEDURE Generate_XML(p_session_id       IN NUMBER,
                       p_odi_session_id   IN NUMBER,
                       p_web_service_name IN VARCHAR2,
                       p_xml_root_element IN VARCHAR2,
                       p_transform_xml IN BOOLEAN DEFAULT TRUE);



--  ============================================================================
--  Name        : Preprocess_Input_Structure
--  Description : This procedure will be used to pre-process input xml for Entity
--                type as BOM or Structure. This procedure performs the following
--                actions:
--                1. Reads the input parameters contained in the XML payload
--                   stored in table EGO_PUB_WS_PARAMS using session_id and
--                   stores them in table EGO_PUB_WS_CONFIG.
--                2. Populates ODI input table BOM_ODI_WS_ENTITIES for entity BOM
--                   based on the invokation type (e.g. batch, list, H-MDM)
--                3. Explodes the bom for all the end-items to process
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--  ============================================================================

PROCEDURE Preprocess_Input_Structure(p_session_id IN NUMBER,
                                     p_odi_session_id IN NUMBER);



--  ============================================================================
--  Name        : Preprocess_Input_valueSet
--  Description : This procedure will be used to pre-process input xml for Entity
--                type as ValueSets.
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--
--  ============================================================================


   PROCEDURE Preprocess_Input_valueSet(  p_session_id      IN NUMBER,
                                         p_odi_session_id  IN NUMBER );



--  ============================================================================
--  Name        : Invocation_Mode
--  Description : This procedure will be used to get invocation mode used for xml
--                input and will return Batch Id,if invocation mode is 'BATCH'
--                It will return Batch Id as -1,If mode is 'LIST'.
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_search_str          IN      VARCHAR2
--                Input string passed to find invocation mode for that string
--                String can be for ICC,ValueSet etc.
--
--        OUT   :
--                x_mode                IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                x_batch_id            IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.

--  ============================================================================
   PROCEDURE Invocation_Mode( p_session_id    IN          NUMBER,
                              p_search_str    IN          VARCHAR2,
                              x_mode          OUT NOCOPY  VARCHAR2,
                              x_batch_id      OUT NOCOPY  NUMBER ) ;


--  ============================================================================
--  Name        : Preprocess_Input_ICC
--  Description : This procedure will be used to pre-process input xml .
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--
--  ============================================================================

   PROCEDURE Preprocess_Input_ICC ( p_session_id      IN NUMBER,
                                    p_odi_session_id  IN NUMBER);



--  ============================================================================
--  Name        : Explode_ICC_Structure
--  Description : This procedure will be used to
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--
--  ============================================================================

   PROCEDURE Explode_ICC_Structure(p_session_id IN NUMBER,
                                p_odi_session_id IN NUMBER);


--  ============================================================================
--  Name        : Create_Config_Param
--  Description : This procedure will be used to insert record for configurable
--                parameters.
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--                p_webservice_name     IN      VARCHAR2
--                Name of webservice for which config parametera needs to create.
--
--                p_lang_search_str     IN      VARCHAR2
--                Input xml string for language node corresponding to a webservice.
--
--                p_parent_hier         IN      VARCHAR2
--                TRUE if parent hierarchy needs to publish
--
--                p_child_hier          IN      VARCHAR2
--                TRUE if child hierarchy needs to publish.
--
--
--  ============================================================================

   PROCEDURE Create_Config_Param(p_session_id       IN  NUMBER,
                                 p_odi_session_id   IN  NUMBER,
                                 p_webservice_name  IN  VARCHAR2,
                                 p_lang_search_str  IN  VARCHAR2,
                                 p_parent_hier      IN  VARCHAR2,
                                 p_child_hier       IN  VARCHAR2);


--  ============================================================================
--  Name        : Decode_Component_Code
--  Description : This procedure converts the given  component code (string
--                containing the concatenated inventory_item_ids from a given
--                component to the end-item in a BOM) into a human readable
--                XML describing containing the inventory item names, sequence
--                number, and other related information.
--
--
--  Parameters:
--        IN    :
--                component_code          IN      VARCHAR2
--                Component code for a given component inside a BOM.

--
--  ============================================================================
    FUNCTION Decode_Component_Code(component_code IN VARCHAR2) RETURN CLOB;

--  ============================================================================
--  Name        : Populate_Input_Identifier
--  Description : This procedure will be used to insert record for Input Identifier
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--                p_input_id     IN      VARCHAR2
--                Id of the Input Identifier.
--
--                p_param_name     IN      VARCHAR2
--                Name of the Parameter in the Identifier
--
--                p_param_value         IN      VARCHAR2
--                Value of the Parameter in the Identifier
--  ============================================================================

     PROCEDURE Populate_Input_Identifier(p_session_id       IN NUMBER,
                                         p_odi_session_id   IN NUMBER,
                                         p_input_id         IN NUMBER,
                                         p_param_name       IN VARCHAR2,
                                         p_param_value      IN VARCHAR2);


--  ============================================================================
--  Name        : Log_Error
--  Description : This procedure will be used to insert error record
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--                p_input_id     IN      VARCHAR2
--                Id of the Input Identifier for which the error occured.
--
--                p_err_code     IN      VARCHAR2
--                Error Code
--
--                p_err_message         IN      VARCHAR2
--                Error Message
--  ============================================================================
        PROCEDURE Log_Error(p_session_id       IN NUMBER,
                            p_odi_session_id   IN NUMBER,
                            p_input_id         IN NUMBER,
                            p_err_code         IN VARCHAR2,
                            p_err_message      IN VARCHAR2);



--  ============================================================================
--  Name        : validate_entity
--  Description : This procedure will be used to insert record for configurable
--                parameters.
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--                p_webservice_name     IN      VARCHAR2
--                Name of webservice for which config parametera needs to create.
--
--
--        RETURN  :
--                  BOOLEAN value

--  ============================================================================

  FUNCTION validate_entity( p_session_id         IN   NUMBER,
                            p_odi_session_id     IN   NUMBER,
                            p_batch_id           IN   NUMBER      DEFAULT  NULL,
                            p_webservice_name    IN   VARCHAR2    DEFAULT  NULL,
                            p_pk1_value          IN   VARCHAR2    DEFAULT  NULL,
                            p_pk2_value          IN   VARCHAR2    DEFAULT  NULL,
                            p_pk3_value          IN   VARCHAR2    DEFAULT  NULL,
                            p_pk4_value          IN   VARCHAR2    DEFAULT  NULL ,
                            p_pk5_value          IN   VARCHAR2    DEFAULT  NULL)
  RETURN BOOLEAN;



--  ============================================================================
--  Name          : Check_Access_Priv
--  Description   : This function will check access priviledge to function 'EGO_ITEM_ADMINISTRATION'
--                  and return boolean value.
--
--
--  Parameters:
--        IN      :
--                  p_session_id          IN      NUMBER
--                  An Unique DB sequence generated at Java wrapper.
--
--                  p_odi_session_id      IN      VARCHAR2
--                  ODI generated Unique Session Id for ODI Scenario.
--
--                  p_webservice_name     IN      VARCHAR2
--                  Name of webservice for which config parametera needs to create.
--
--
--        RETURN  :
--                  BOOLEAN value
--  ============================================================================

  FUNCTION Check_Access_Priv( p_session_id       IN NUMBER,
                              p_odi_session_id   IN NUMBER,
                              p_web_service_name IN VARCHAR2)
  RETURN BOOLEAN;

--  ============================================================================
--  Name        : Populate_Input_Identifier
--  Description : This procedure will be populate transaction attribute into flat
--                    table.
--
--  Parameters:
--        IN    :
--                p_session_id          IN      NUMBER
--                An Unique DB sequence generated at Java wrapper.
--
--                p_odi_session_id      IN      VARCHAR2
--                ODI generated Unique Session Id for ODI Scenario.
--
--  ============================================================================

PROCEDURE POPULATE_TRANS_ATTR_LIST(  p_session_id                IN          NUMBER,
                                                 p_odi_session_id            IN          NUMBER) ;

--  ============================================================================

/*============================================================================
Name        : POPULATE_VSTBLINFO_VSSVC
Description : This procedure populates the details of Table Type of ValueSet
              This procedure will be called by ValueSet ODI Project

Parameters:   p_Session_Id          IN      NUMBER
              An Unique DB sequence generated at Java wrapper.

              p_ODISession_Id      IN      VARCHAR2
              p_ODI generated Unique Session Id for ODI Scenario*/

PROCEDURE POPULATE_VSTBLINFO_VSSVC(p_Session_Id    IN NUMBER,
                                   p_ODISession_Id IN NUMBER);
/*============================================================================*/

/*============================================================================
Name        : POPULATE_VSTBLINFO_ICCSVC
Description : This procedure populates the details of Table Type of ValueSet
              This procedure will be called by ICC ODI Project

Parameters:   p_Session_Id          IN      NUMBER
              An Unique DB sequence generated at Java wrapper.

              p_ODISession_Id      IN      VARCHAR2
              p_ODI generated Unique Session Id for ODI Scenario*/

PROCEDURE POPULATE_VSTBLINFO_ICCSVC(p_Session_Id    IN NUMBER,
                                   p_ODISession_Id IN NUMBER);
/*============================================================================*/

   ---------------------------------------------------------------
   -- Global Variables and Constants --
   ---------------------------------------------------------------
   G_CURRENT_USER_ID          NUMBER        := FND_GLOBAL.User_Id;
   G_CURRENT_LOGIN_ID         NUMBER        := FND_GLOBAL.Login_Id;
   G_ICC_WEBSERVICE           VARCHAR2(20)  :='GETICCDETAILS';
   G_VS_WEBSERVICE            VARCHAR2(20)  :='GETVALUESETDETAILS';




END EGO_ODI_PUB;

/
