--------------------------------------------------------
--  DDL for Package CS_CF_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CF_UPG_PKG" AUTHID CURRENT_USER as
/* $Header: cscfupgs.pls 120.0 2005/06/01 12:27:10 appldev noship $ */


PROCEDURE Upgrade_Main;


FUNCTION Is_Region_Upgrade_Required(p_respTable OUT NOCOPY CS_CF_UPG_UTL_PKG.RespTable ,
                                    p_applTable OUT NOCOPY CS_CF_UPG_UTL_PKG.ApplTable,
                                    p_siteProfilesTable OUT NOCOPY CS_CF_UPG_UTL_PKG.ProfileTable) RETURN BOOLEAN;

FUNCTION Is_Flow_Upgrade_Required(p_respTable OUT NOCOPY CS_CF_UPG_UTL_PKG.RespTable ,
                                  p_applTable OUT NOCOPY CS_CF_UPG_UTL_PKG.ApplTable,
                                  p_siteProfilesTable OUT NOCOPY CS_CF_UPG_UTL_PKG.ProfileTable)
                                  RETURN BOOLEAN;

PROCEDURE Do_Region_Upgrade (p_respTable IN CS_CF_UPG_UTL_PKG.RespTable, p_applTable IN CS_CF_UPG_UTL_PKG.ApplTable, p_siteProfilesTable IN CS_CF_UPG_UTL_PKG.ProfileTable);

PROCEDURE Do_Region_Upgrades_For_Resp(p_respTable IN CS_CF_UPG_UTL_PKG.RespTable);

PROCEDURE Clone_Regions_For_Resp(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
                                 p_respId IN FND_PROFILE_OPTION_VALUES.level_value%TYPE,
                                 p_respApplId IN FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE);


PROCEDURE Do_Region_Upgrades_For_Appl(p_applTable IN CS_CF_UPG_UTL_PKG.ApplTable);

PROCEDURE Do_Region_Upgrades_For_Global(p_siteProfilesTable IN CS_CF_UPG_UTL_PKG.ProfileTable);

/*
 * Perform the actually cloning
 * of ak regions, based on the list of
 * profiles that are customized at the appl level
 */
PROCEDURE Clone_Regions_For_Appl(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable, p_ApplId IN NUMBER);

/*
 * Perform the actually cloning
 * of ak regions, based on the list of
 * profiles that are customized at the global level
 */
PROCEDURE Clone_Regions_For_Global(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable);


/*
 * Top level procedure for performing flow
 * upgrades; Internally this will call
 * flow upgrades for each profile level, ie resp, application, etc
 */
PROCEDURE Do_Flow_Upgrade(p_respTable IN CS_CF_UPG_UTL_PKG.RespTable,
                          p_applTable IN CS_CF_UPG_UTL_PKG.ApplTable,
                          p_siteProfilesTable IN CS_CF_UPG_UTL_PKG.ProfileTable);


/*
 * Procedure to performing flow upgrades for responsibility level
 * For each resp
 */
PROCEDURE Do_Flow_Upgrades_For_Resp(p_respTable IN CS_CF_UPG_UTL_PKG.RespTable);

/*
 * Perform the actually cloning
 * of flows, based on the list of
 * profiles that are customized at the resp level
 */
PROCEDURE Clone_Flows_For_Resp(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
                            p_respId IN FND_PROFILE_OPTION_VALUES.level_value%TYPE,
                            p_respApplId IN FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE);

/*
 * Procedure to performing flow upgrades for application level
 */
PROCEDURE Do_Flow_Upgrades_For_Appl(p_applTable IN CS_CF_UPG_UTL_PKG.ApplTable);

/*
 * Perform the actually cloning
 * of flows, based on the list of
 * profiles that are customized at the application level
 */

PROCEDURE Clone_Flows_For_Appl(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
					   p_applId IN NUMBER);


/*
 * Procedure to performing flow upgrades for site level
 */
PROCEDURE Do_Flow_Upgrades_For_Global(p_siteProfilesTable IN CS_CF_UPG_UTL_PKG.ProfileTable);

End CS_CF_UPG_PKG;

 

/
