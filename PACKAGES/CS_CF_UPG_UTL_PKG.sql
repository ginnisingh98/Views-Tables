--------------------------------------------------------
--  DDL for Package CS_CF_UPG_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CF_UPG_UTL_PKG" AUTHID CURRENT_USER as
/* $Header: cscfutls.pls 120.0 2005/06/01 13:19:40 appldev noship $ */

  TYPE RespRec IS RECORD (
    respId FND_PROFILE_OPTION_VALUES.level_value%TYPE,
    respApplId FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE
  );

  Type RespTable IS TABLE OF RespRec
    INDEX BY BINARY_INTEGER;

  Type ApplTable IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  TYPE ProfileRec IS RECORD (
    profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE,
    profileOptionValue FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE
  );

  Type ProfileTable IS TABLE OF ProfileRec
    INDEX BY BINARY_INTEGER;


FUNCTION Eval_SR_Account_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                 p_respTable IN OUT NOCOPY RespTable,
                                 p_appl_index IN OUT NOCOPY NUMBER,
                                 p_applTable IN OUT NOCOPY ApplTable,
                                 p_site_index IN OUT NOCOPY NUMBER,
                                 p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                 RETURN BOOLEAN;

FUNCTION Eval_SR_Problem_Code_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                 p_respTable IN OUT NOCOPY RespTable,
                                 p_appl_index IN OUT NOCOPY NUMBER,
                                 p_applTable IN OUT NOCOPY ApplTable,
                                 p_site_index IN OUT NOCOPY NUMBER,
                                 p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                 RETURN BOOLEAN;



FUNCTION Eval_SR_Addr_Display (p_appl_index IN OUT NOCOPY NUMBER,
                               p_applTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_respTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN;

FUNCTION Eval_SR_Addr_Mandatory (p_appl_index IN OUT NOCOPY NUMBER,
                                 p_applTable IN OUT NOCOPY ApplTable,
                                 p_resp_index IN OUT NOCOPY NUMBER,
                                 p_respTable IN OUT NOCOPY RespTable,
                                 p_site_index IN OUT NOCOPY NUMBER,
                                 p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                 RETURN BOOLEAN;


FUNCTION Eval_SR_BillTo_Address_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                        p_respTable IN OUT NOCOPY RespTable,
                                        p_appl_index IN OUT NOCOPY NUMBER,
                                        p_applTable IN OUT NOCOPY ApplTable,
                                        p_site_index IN OUT NOCOPY NUMBER,
                                        p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                        RETURN BOOLEAN;


FUNCTION Eval_SR_BillTo_Contact_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                        p_respTable IN OUT NOCOPY RespTable,
                                        p_appl_index IN OUT NOCOPY NUMBER,
                                        p_applTable IN OUT NOCOPY ApplTable,
                                        p_site_index IN OUT NOCOPY NUMBER,
                                        p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                        RETURN BOOLEAN;


FUNCTION Eval_SR_Creation_Prod_Option (p_appl_index IN OUT NOCOPY NUMBER,
                                       p_applTable IN OUT NOCOPY ApplTable,
                                       p_resp_index IN OUT NOCOPY NUMBER,
                                       p_respTable IN OUT NOCOPY RespTable,
                                       p_site_index IN OUT NOCOPY NUMBER,
                                       p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                       RETURN BOOLEAN;

FUNCTION Eval_SR_ShipTo_Address_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                        p_respTable IN OUT NOCOPY RespTable,
                                        p_appl_index IN OUT NOCOPY NUMBER,
                                        p_applTable IN OUT NOCOPY ApplTable,
                                        p_site_index IN OUT NOCOPY NUMBER,
                                        p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                        RETURN BOOLEAN;

FUNCTION Eval_SR_ShipTo_Contact_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                        p_respTable IN OUT NOCOPY RespTable,
                                        p_appl_index IN OUT NOCOPY NUMBER,
                                        p_applTable IN OUT NOCOPY ApplTable,
                                        p_site_index IN OUT NOCOPY NUMBER,
                                        p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                        RETURN BOOLEAN;

FUNCTION Eval_SR_InstalledAt_Address (p_resp_index IN OUT NOCOPY NUMBER,
                                      p_respTable IN OUT NOCOPY RespTable,
                                      p_appl_index IN OUT NOCOPY NUMBER,
                                      p_applTable IN OUT NOCOPY ApplTable,
                                      p_site_index IN OUT NOCOPY NUMBER,
                                      p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                      RETURN BOOLEAN;


FUNCTION Eval_SR_Attachment_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                    p_respTable IN OUT NOCOPY RespTable,
                                    p_appl_index IN OUT NOCOPY NUMBER,
                                    p_applTable IN OUT NOCOPY ApplTable,
                                    p_site_index IN OUT NOCOPY NUMBER,
                                    p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                    RETURN BOOLEAN;

FUNCTION Eval_SR_Task_Display (p_appl_index IN OUT NOCOPY NUMBER,
                               p_applTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_respTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN;

FUNCTION Eval_SR_Enable_Interact_Log (p_resp_index IN OUT NOCOPY NUMBER,
                                      p_respTable IN OUT NOCOPY RespTable,
                                      p_appl_index IN OUT NOCOPY NUMBER,
                                      p_applTable IN OUT NOCOPY ApplTable,
                                      p_site_index IN OUT NOCOPY NUMBER,
                                      p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                      RETURN BOOLEAN;


FUNCTION Eval_SR_KB_Option (p_appl_index IN OUT NOCOPY NUMBER,
                            p_applTable IN OUT NOCOPY ApplTable,
                            p_resp_index IN OUT NOCOPY NUMBER,
                            p_respTable IN OUT NOCOPY RespTable,
                            p_site_index IN OUT NOCOPY NUMBER,
                            p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                            RETURN BOOLEAN;

FUNCTION Eval_SR_Enable_Template (p_appl_index IN OUT NOCOPY NUMBER,
                                  p_applTable IN OUT NOCOPY ApplTable,
                                  p_resp_index IN OUT NOCOPY NUMBER,
                                  p_respTable IN OUT NOCOPY RespTable,
                                  p_site_index IN OUT NOCOPY NUMBER,
                                  p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                  RETURN BOOLEAN;

FUNCTION Eval_SR_Product_Selection (p_appl_index IN OUT NOCOPY NUMBER,
                               p_applTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_respTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN;

FUNCTION Resp_Already_Exists(p_respTable IN RespTable,
                             p_level_value IN NUMBER,
                             p_level_value_application_id IN NUMBER)
                             RETURN BOOLEAN;

FUNCTION Appl_Already_Exists(p_applTable IN ApplTable,
                             p_level_value IN NUMBER)
                             RETURN BOOLEAN;


/*
 * This procedure inserts a new row into CS_CF_SOURCE_CONTEXT_TARGETS
 * table for the newly cloned regions
 */

PROCEDURE Insert_New_Target(p_sourceCode IN VARCHAR2,
                            p_contextType IN VARCHAR2,
                            p_contextValue1 IN VARCHAR2,
                            p_contextValue2 IN VARCHAR2,
                            p_seedTargetValue1 IN VARCHAR2,
                            p_seedTargetValue2 IN VARCHAR2,
                            p_custTargetValue1 IN VARCHAR2,
                            p_custTargetValue2 IN VARCHAR2);

/*
 * Wrapper function to call AK's api to clone regions
 */
PROCEDURE Clone_Region(p_regionCode IN VARCHAR2,
                       p_regionApplId IN NUMBER,
                       p_newRegionCode IN VARCHAR2,
                       p_newRegionApplId IN NUMBER,
                       p_checkRegion IN BOOLEAN);


PROCEDURE UpdateRegionItems(p_regionCode IN VARCHAR2,
                            p_attributeCode IN VARCHAR2,
                            p_displayFlag IN VARCHAR2,
                            p_mandatoryFlag IN VARCHAR2,
                            p_subRegionCode IN VARCHAR2);

PROCEDURE getAddressProfileValues(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
                                  p_displayBillToAddress IN OUT NOCOPY VARCHAR2,
                                  p_displayBillToContact IN OUT NOCOPY VARCHAR2,
                                  p_displayShipToAddress IN OUT NOCOPY VARCHAR2,
                                  p_displayShipToContact IN OUT NOCOPY VARCHAR2,
                                  p_displayInstalledAtAddr IN OUT NOCOPY VARCHAR2,
                                  p_displayIncidentAddr IN OUT NOCOPY VARCHAR2,
                                  p_mandatoryIncidentAddr IN OUT NOCOPY VARCHAR2);

PROCEDURE getAttachmentProbCodeValues(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
                                  p_displayAttachment IN OUT NOCOPY VARCHAR2,
                                  p_mandatoryProblemCode IN OUT NOCOPY VARCHAR2);

PROCEDURE setup_log(p_filename IN VARCHAR2);

PROCEDURE log_mesg(p_level IN NUMBER,
                   p_module IN VARCHAR2,
                   p_text IN VARCHAR2);

PROCEDURE wrapup(p_status IN VARCHAR2);

FUNCTION get_log_directory RETURN VARCHAR2;

FUNCTION Regions_Not_Already_Cloned(p_suffix IN VARCHAR2) RETURN BOOLEAN;

--mkcyee 02/25/2004 - added to check if a flow has already been cloned
FUNCTION Flows_Not_Already_Cloned(p_flowId IN NUMBER) RETURN BOOLEAN;

-- mkcyee 02/24/04 - added to check if config profile option has been customized
FUNCTION configProfileCustomized RETURN BOOLEAN;

-- mkcyee 02/24/04 - added to clone a flow
PROCEDURE Clone_Flow(p_newFlowId in NUMBER,  p_flowId in NUMBER);

End CS_CF_UPG_UTL_PKG;

 

/
