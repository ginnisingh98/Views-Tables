--------------------------------------------------------
--  DDL for Package Body CS_CF_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CF_UPG_PKG" as
/* $Header: cscfupgb.pls 120.1 2005/06/14 10:00:54 appldev  $ */

  CURSOR does_region_already_exists (p_region_code VARCHAR2, p_region_application_id NUMBER)
  IS
    SELECT count(*) from ak_regions
    where region_application_id = p_region_application_id
    and region_code = p_region_code;

PROCEDURE Upgrade_Main IS

  l_region_upgrade_required boolean := FALSE;
  l_flow_upgrade_required boolean := FALSE;
  l_respTable CS_CF_UPG_UTL_PKG.RespTable;
  l_applTable CS_CF_UPG_UTL_PKG.ApplTable;
  l_siteProfilesTable CS_CF_UPG_UTL_PKG.ProfileTable;
  l_return_value boolean := FALSE;

  l_flowRespTable CS_CF_UPG_UTL_PKG.RespTable;
  l_flowApplTable CS_CF_UPG_UTL_PKG.ApplTable;
  l_flowProfilesTable CS_CF_UPG_UTL_PKG.ProfileTable;

  l_logfilename VARCHAR2(2000) := '';
  l_region_fresh_install BOOLEAN := TRUE;


BEGIN

    -- generate a suffix to the filename
    select to_char(sysdate, 'mm-dd-yy') || to_char(sysdate, 'hh24:mi:ss')
    into l_logfilename
    from dual;

    CS_CF_UPG_UTL_PKG.setup_log('IBUCFUPG-' || l_logfilename);


    l_region_upgrade_required := Is_Region_Upgrade_Required(l_respTable,l_applTable, l_siteProfilesTable);

    -- if l_region_upgrade_required , do region upgrade

    IF (l_region_upgrade_required) THEN
      Do_Region_Upgrade(l_respTable, l_applTable, l_siteProfilesTable);
    END IF;

    l_flow_upgrade_required := Is_Flow_Upgrade_Required(l_flowRespTable, l_flowApplTable, l_flowProfilesTable);

    IF (l_flow_upgrade_required) THEN
      Do_Flow_Upgrade(l_respTable, l_applTable, l_flowProfilesTable);
    END IF;

      -- if l_upgrade_required, do flow upgrade

    IF (l_region_upgrade_required OR l_flow_upgrade_required) THEN
      -- Check if the config profile has been customized
      IF (CS_CF_UPG_UTL_PKG.configProfileCustomized) THEN
        -- The profile has been customized. Don't overwrite
        CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Upgrade_Main', 'Configuration profile has been customized. Will not overwrite.');
      ELSE
        -- Update the profile to set to CUSTOM
        CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Upgrade_Main', 'Saving profile to CUSTOM');

        l_return_value := FND_PROFILE.SAVE('IBU_REGION_FIELD_CONFIG_OPTION', 'CUSTOM', 'SITE');
        IF NOT(l_return_value) THEN
          CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Upgrade_Main', 'Saving profile to CUSTOM was unsuccessful');

          RAISE PROGRAM_ERROR;
        END IF ;
  	   commit;
      END IF;
    END IF;

    CS_CF_UPG_UTL_PKG.wrapup('SUCCESS');

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.wrapup('ERROR');
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_PKG.Upgrade_Main','Exception raised in Upgrade_Main');
    RAISE;
End Upgrade_Main;

/*
 * Returns the list of unique responsibilities
 * and applications for which customization of the
 * configuration profiles affecting region
 * configurations have been made.
 * If there are any responsibilities or applications
 * for which a non-default value has been set,
 * this function will return true, otherwise false.
 */
FUNCTION Is_Region_Upgrade_Required(p_respTable OUT NOCOPY CS_CF_UPG_UTL_PKG.RespTable,
                                    p_applTable OUT NOCOPY CS_CF_UPG_UTL_PKG.ApplTable,
                                    p_siteProfilesTable OUT NOCOPY CS_CF_UPG_UTL_PKG.ProfileTable)
                                    RETURN BOOLEAN
IS
  l_resp_index NUMBER := 0;
  l_appl_index NUMBER := 0;
  l_site_index NUMBER := 0;

  l_upgrade_required BOOLEAN := FALSE;
  l_upg_return_value BOOLEAN := FALSE;

BEGIN

  -- Call the following utility apis to retrieve the list of unique
  -- responsibilities, and applications for which configuration profiles have
  -- been customized.
  -- The apis will add the responsibility and application to the table(s)
  -- and maintain the indexes on them.

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Account_Option(l_resp_index,
								  p_respTable,
								  l_appl_index,
								  p_applTable,
								  l_site_index,
								  p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Problem_Code_Option(l_resp_index,
								  p_respTable,
								  l_appl_index,
								  p_applTable,
								  l_site_index,
								  p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;


  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Creation_Prod_Option(l_appl_index,
                                                                  p_applTable,
                                                                  l_resp_index,
                                                                  p_respTable,
                                                                  l_site_index,
                                                                  p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Display(l_appl_index,
                                                                  p_applTable,
                                                                  l_resp_index,
                                                                  p_respTable,
                                                                  l_site_index,
                                                                  p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Mandatory(l_appl_index,
                                                                 p_applTable,
                                                                 l_resp_index,
                                                                 p_respTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Address_Option(l_resp_index,
                                                                 p_respTable,
                                                                 l_appl_index,
                                                                 p_applTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Contact_Option(l_resp_index,
                                                                 p_respTable,
                                                                 l_appl_index,
                                                                 p_applTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Address_Option(l_resp_index,
                                                                 p_respTable,
                                                                 l_appl_index,
                                                                 p_applTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Contact_Option(l_resp_index,
                                                                 p_respTable,
                                                                 l_appl_index,
                                                                 p_applTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;


  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_InstalledAt_Address(l_resp_index,
                                                                 p_respTable,
                                                                 l_appl_index,
                                                                 p_applTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Attachment_Option(l_resp_index,
                                                                 p_respTable,
                                                                 l_appl_index,
                                                                 p_applTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Task_Display(l_appl_index,
                                                                 p_applTable,
                                                                 l_resp_index,
                                                                 p_respTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Interact_Log(l_resp_index,
                                                                 p_respTable,
                                                                 l_appl_index,
                                                                 p_applTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Template(l_appl_index,
                                                                 p_applTable,
                                                                 l_resp_index,
                                                                 p_respTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_Product_Selection(l_appl_index,
                                                                 p_applTable,
                                                                 l_resp_index,
                                                                 p_respTable,
                                                                 l_site_index,
                                                                 p_siteProfilesTable);
  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  IF (l_upgrade_required) THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Is_Region_Upgrade_Required','Is_Region_Upgrade_Required returns true');
  ELSE
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Is_Region_Upgrade_Required','Is_Region_Upgrade_Required returns false');
  END IF;
  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_PKG.Is_Region_Upgrade_Required','Exception raised in Is_Region_Upgrade_Required');
    RAISE;

END Is_Region_Upgrade_Required;

/*
 * Returns the list of unique responsibilities
 * and applications for which customization of the
 * configuration profiles affecting page flow
 * configurations have been made.
 * If there are any responsibilities or applications
 * for which a non-default value has been set,
 * this function will return true, otherwise false.
 */

FUNCTION Is_Flow_Upgrade_Required(p_respTable OUT NOCOPY CS_CF_UPG_UTL_PKG.RespTable,
                                  p_applTable OUT NOCOPY CS_CF_UPG_UTL_PKG.ApplTable,
                                  p_siteProfilesTable OUT NOCOPY CS_CF_UPG_UTL_PKG.ProfileTable)
                                  RETURN BOOLEAN
IS
  l_resp_index NUMBER := 0;
  l_appl_index NUMBER := 0;
  l_site_index NUMBER := 0;

  l_upgrade_required BOOLEAN := FALSE;
  l_upg_return_value BOOLEAN := FALSE;


BEGIN

  l_upg_return_value := CS_CF_UPG_UTL_PKG.Eval_SR_KB_Option(l_appl_index,
                                          p_applTable,
                                          l_resp_index,
                                          p_respTable,
                                          l_site_index,
                                          p_siteProfilesTable);

  IF (l_upg_return_value) THEN
    l_upgrade_required := TRUE;
  END IF;

  IF (l_upgrade_required) THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Is_Flow_Upgrade_Required','Is_Flow_Upgrade_Required returns true');
  ELSE
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Is_Flow_Upgrade_Required','Is_Flow_Upgrade_Required returns false');
  END IF;
  return l_upgrade_required;
END Is_Flow_Upgrade_Required;

/*
 * Top level procedure for performing region
 * upgrades; Internally this will call
 * region upgrades for each profile level, ie resp, application, etc
 */
PROCEDURE Do_Region_Upgrade(p_respTable IN CS_CF_UPG_UTL_PKG.RespTable, p_applTable IN CS_CF_UPG_UTL_PKG.ApplTable, p_siteProfilesTable IN CS_CF_UPG_UTL_PKG.ProfileTable)
IS

BEGIN

  Do_Region_Upgrades_For_Resp(p_respTable);
  Do_Region_Upgrades_For_Appl(p_applTable);
  Do_Region_Upgrades_For_Global(p_siteProfilesTable);

END Do_Region_Upgrade;

/*
 * Procedure to performing upgrades for responsibility level
 * For each resp
 */
PROCEDURE Do_Region_Upgrades_For_Resp(p_respTable IN CS_CF_UPG_UTL_PKG.RespTable)
IS

  -- this picks up all the configuration profiles
  -- that affects region configuration for
  -- a particular responsibility and it's corresponding
  -- higher application level and site level

  CURSOR get_profiles_for_resp (respId NUMBER, respApplId NUMBER)
  IS
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    1 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10003
  AND   b.level_value = respId
  AND   b.level_value_application_id = respApplId
  AND   a.profile_option_id = b.profile_option_id
  AND   b.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_ACCOUNT_OPTION',
                                 'IBU_A_SR_PROB_CODE_MANDATORY',
                                 'IBU_SR_CREATION_PRODUCT_OPTION',
                                 'IBU_SR_ADDR_DISPLAY',
                                 'IBU_SR_ADDR_MANDATORY',
                                 'IBU_A_SR_BILLTO_ADDRESS_OPTION',
                                 'IBU_A_SR_BILLTO_CONTACT_OPTION',
                                 'IBU_A_SR_SHIPTO_ADDRESS_OPTION',
                                 'IBU_A_SR_SHIPTO_CONTACT_OPTION',
                                 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION',
                                 'IBU_A_SR_ATTACHMENT_OPTION',
                                 'IBU_SR_TASK_DISPLAY',
                                 'IBU_A_SR_ENABLE_INTERACTION_LOGGING',
                                 'IBU_SR_ENABLE_TEMPLATE',
                                 'IBU_A_SR_PRODUCT_SELECTION_OPTION')
  UNION
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    2 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10002
  AND   b.level_value = respApplId
  AND   a.profile_option_id = b.profile_option_id
  AND   b.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_ACCOUNT_OPTION',
                                 'IBU_A_SR_PROB_CODE_MANDATORY',
                                 'IBU_SR_CREATION_PRODUCT_OPTION',
                                 'IBU_SR_ADDR_DISPLAY',
                                 'IBU_SR_ADDR_MANDATORY',
                                 'IBU_A_SR_BILLTO_ADDRESS_OPTION',
                                 'IBU_A_SR_BILLTO_CONTACT_OPTION',
                                 'IBU_A_SR_SHIPTO_ADDRESS_OPTION',
                                 'IBU_A_SR_SHIPTO_CONTACT_OPTION',
                                 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION',
                                 'IBU_A_SR_ATTACHMENT_OPTION',
                                 'IBU_SR_TASK_DISPLAY',
                                 'IBU_A_SR_ENABLE_INTERACTION_LOGGING',
                                 'IBU_SR_ENABLE_TEMPLATE',
                                 'IBU_A_SR_PRODUCT_SELECTION_OPTION')
  UNION
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    3 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10001
  AND   a.profile_option_id = b.profile_option_id
  AND   b.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_ACCOUNT_OPTION',
                                 'IBU_A_SR_PROB_CODE_MANDATORY',
                                 'IBU_SR_CREATION_PRODUCT_OPTION',
                                 'IBU_SR_ADDR_DISPLAY',
                                 'IBU_SR_ADDR_MANDATORY',
                                 'IBU_A_SR_BILLTO_ADDRESS_OPTION',
                                 'IBU_A_SR_BILLTO_CONTACT_OPTION',
                                 'IBU_A_SR_SHIPTO_ADDRESS_OPTION',
                                 'IBU_A_SR_SHIPTO_CONTACT_OPTION',
                                 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION',
                                 'IBU_A_SR_ATTACHMENT_OPTION',
                                 'IBU_SR_TASK_DISPLAY',
                                 'IBU_A_SR_ENABLE_INTERACTION_LOGGING',
                                 'IBU_SR_ENABLE_TEMPLATE',
                                 'IBU_A_SR_PRODUCT_SELECTION_OPTION')
  ORDER BY PROFILE_OPTION_NAME, PRIORITY;


  l_count NUMBER := p_respTable.COUNT;
  l_index NUMBER := 0;
  l_index2 NUMBER := 0;
  l_profile_option_name FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE;
  l_level_value_application_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
  l_priority NUMBER := 0;

  l_ProfileTable CS_CF_UPG_UTL_PKG.ProfileTable;

BEGIN

  CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG: Do_Region_Upgrades_For_Resp', 'Processing Do_Region_Upgrades_For_Resp');


  WHILE (l_index < l_count) LOOP
    -- Get the list of profile names and their values
    -- and store it in a table
    -- This table may contain duplicate entries for
    -- each profile because we pick up the values
    -- for the application and site level also
    OPEN get_profiles_for_resp(p_respTable(l_index).respId, p_respTable(l_index).respApplId);
      -- Retrieve information into the local variables
    FETCH get_profiles_for_resp INTO l_profile_option_name,
                                     l_level_value,
                                     l_level_value_application_id,
                                     l_profile_option_value,
                                     l_priority;
    WHILE get_profiles_for_resp%FOUND LOOP

      l_ProfileTable(l_index2).profileOptionName := l_profile_option_name;
	 l_ProfileTable(l_index2).profileOptionValue := l_profile_option_value;

	 l_index2 := l_index2 + 1;

      FETCH get_profiles_for_resp INTO l_profile_option_name,
                                       l_level_value,
                                       l_level_value_application_id,
                                       l_profile_option_value,
                                       l_priority;

    END LOOP;
    CLOSE get_profiles_for_resp;

    -- Now we have a table of profiles
    -- Determine which regions need to be cloned for this resp

    IF (CS_CF_UPG_UTL_PKG.Regions_Not_Already_Cloned('R' || p_respTable(l_index).respId)) THEN
      Clone_Regions_For_Resp(l_ProfileTable, p_respTable(l_index).respId,
								   p_respTable(l_index).respApplId);
      commit;
    END IF;

    -- now clean up the table so it can be reused
    l_ProfileTable.DELETE;
    l_index2 := 0;
    l_index := l_index + 1;

  END LOOP; -- ends while loop

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_PKG: Do_Region_Upgrades_For_Resp', 'Exception in Do_Region_Upgrades_For_Resp');
    IF (get_profiles_for_resp%ISOPEN) THEN
	 CLOSE get_profiles_for_resp;
    END IF;
    RAISE;

END Do_Region_Upgrades_For_Resp;


/*
 * Perform the actually cloning
 * of ak regions, based on the list of
 * profiles that are customized at the resp level
 */
PROCEDURE Clone_Regions_For_Resp(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
                                 p_respId IN FND_PROFILE_OPTION_VALUES.level_value%TYPE,
                                 p_respApplId IN FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE)
IS
  l_count NUMBER := p_ProfileTable.COUNT;
  l_index NUMBER := 0;
  l_profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_profileOptionValue FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
  l_newPrimaryContactRegionCode VARCHAR2(30) := 'IBU_CF_SR_10_G';
  l_newAddressRegionCode VARCHAR2(30) := 'IBU_CF_SR_20_G';
  l_newUpdateAddressRegionCode VARCHAR2(30) := 'IBU_CF_SR_25_G';
  l_newIdentifyProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_30_G';
  l_newTemplateProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_35_G';
  l_newIdentifyProblemRegionCode VARCHAR2(30) := 'IBU_CF_SR_40_G';
  l_newReviewRegionCode VARCHAR2(30) := 'IBU_CF_SR_50_G';
  l_newProblemDetailsRegionCode VARCHAR2(30) := 'IBU_CF_SR_60_G';
  l_newContactInfoRegionCode VARCHAR2(30) := 'IBU_CF_SR_70_G';
  l_newDtlOverviewRegionCode VARCHAR2(30) := 'IBU_CF_SR_130_G';
  l_newDtlContactAddrRegionCode VARCHAR2(30) := 'IBU_CF_SR_210_G';
  l_newDtlTabsRegionCode VARCHAR2(30) := 'IBU_CF_SR_160_G';
  l_newDtlDetailsRegionCode VARCHAR2(30) := 'IBU_CF_SR_190_G';
  l_newDtlProgOptionsRegionCode VARCHAR2(30) := 'IBU_CF_SR_110_G';
  l_newDtlProgressRegionCode VARCHAR2(30) := 'IBU_CF_SR_120_G';
  l_newDtlResolnRegionCode VARCHAR2(30) := 'IBU_CF_SR_150_G';
  l_newCreateTemplateRegionCode VARCHAR2(30) := 'IBU_CF_SR_310_G';
  l_newUpdateTemplateRegionCode VARCHAR2(30) := 'IBU_CF_SR_320_G';
  l_newCreateViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_430_G';
  l_newUpdateViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_440_G';
  l_newSearchViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_450_G';
  l_newProductFilterRegionCode VARCHAR2(30) := 'IBU_CF_SR_420_G';
  l_newRegProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_80_G';
  l_newAllProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_90_G';
  l_newFilterRegionCode VARCHAR2(30) := 'IBU_CF_SR_410_G';


  l_displayBillToAddress FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayBillToContact FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayShipToAddress FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayShipToContact FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayInstalledAtAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayIncidentAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_mandatoryIncidentAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayAttachment FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayRegProducts FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayAllProducts FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_enableTemplate FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayTasks FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_mandatoryProblemCode FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';



  l_region_count NUMBER := 0;

  l_respId VARCHAR2(10) := to_char(p_respId);
  l_respApplId VARCHAR2(10) := to_char(p_respApplId);

  l_newIdentifyProblemExists BOOLEAN := FALSE;
  l_newPrimaryContactExists BOOLEAN := FALSE;
  l_newProblemDetailsExists BOOLEAN := FALSE;
  l_newAddressExists BOOLEAN := FALSE;
  l_newUpdateAddressExists BOOLEAN := FALSE;
  l_newContactInfoExists BOOLEAN := FALSE;
  l_newReviewExists BOOLEAN := FALSE;
  l_newDtlOverviewExists BOOLEAN := FALSE;
  l_newDtlContactAddrExists BOOLEAN := FALSE;
  l_newDtlTabsExists BOOLEAN := FALSE;
  l_newDtlProgressOptionsExists BOOLEAN := FALSE;
  l_newDtlResolnExists BOOLEAN := FALSE;
  l_newDtlDetailsExists BOOLEAN := FALSE;
  l_newDtlProgressExists BOOLEAN := FALSE;
  l_newIdentifyProductExists BOOLEAN := FALSE;
  l_newTemplateProductExists BOOLEAN := FALSE;
  l_newCreateTemplateExists BOOLEAN := FALSE;
  l_newUpdateTemplateExists BOOLEAN := FALSE;
  l_newProductFilterExists BOOLEAN := FALSE;
  l_newCreateViewExists BOOLEAN := FALSE;
  l_newUpdateViewExists BOOLEAN := FALSE;
  l_newSearchViewExists BOOLEAN := FALSE;
  l_newRegProductExists BOOLEAN := FALSE;
  l_newAllProductExists BOOLEAN := FALSE;
  l_newFilterExists     BOOLEAN := FALSE;

  -- the following set of variables are used to
  -- determine whether we've already examined
  -- the profile option. If we have, we don't need to look at it again
  l_examineSrAccountOption BOOLEAN := TRUE;
  l_examineAddressOption BOOLEAN := TRUE;
  l_examineCreateProdOption BOOLEAN := TRUE;
  l_examineAttachmentOption BOOLEAN := TRUE;
  l_examineTemplateOption BOOLEAN := TRUE;
  l_examineLoggingOption BOOLEAN := TRUE;
  l_examineTaskOption BOOLEAN := TRUE;
  l_examineProdSelectOption BOOLEAN := TRUE;
  l_examineProbCodeOption BOOLEAN := TRUE;

BEGIN

  CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Cloning regions for respId: ' || l_respId || ' respApplId: ' || l_respApplId);
  WHILE (l_index < l_count) LOOP
    l_profileOptionName := p_ProfileTable(l_index).profileOptionName;
    l_profileOptionValue := p_ProfileTable(l_index).profileOptionValue;

    IF (l_profileOptionName = 'IBU_A_SR_ACCOUNT_OPTION' AND l_examineSrAccountOption) THEN
      -- clone the region
      l_newPrimaryContactRegionCode := 'IBU_CF_SR_10_R' || p_respId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_10_G',
                                     672,
                                     l_newPrimaryContactRegionCode,
                                     672, FALSE);

      IF (l_profileOptionValue = 'OPTIONAL') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newPrimaryContactRegionCode,
                                               'IBU_CF_SR_ACCOUNT_NUMBER',
                                               'Y', 'N', null);
      END IF;
      l_examineSrAccountOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Done with SR Account Option');
    ELSIF (l_profileOptionName = 'IBU_A_SR_PRODUCT_SELECTION_OPTION' AND l_examineProdSelectOption) THEN
      -- clone the regions
      l_newRegProductRegionCode := 'IBU_CF_SR_80_R' || p_respId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_80_G',
                                     672,
                                     l_newRegProductRegionCode,
                                     672, FALSE);

      IF (l_profileOptionValue = 'N') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newRegProductRegionCode,
                                              'IBU_CF_SR_R_PROD_NAME_LOV',
                                              'Y', 'N', null);

      END IF;
      l_newAllProductRegionCode := 'IBU_CF_SR_90_R' || p_respId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_90_G',
                                     672,
                                     l_newAllProductRegionCode,
                                     672, FALSE);

      IF (l_profileOptionValue = 'N') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAllProductRegionCode,
                                            'IBU_CF_SR_PROD_BY_NAME_LOV',
                                            'Y', 'N', null);

      END IF;
      l_examineProdSelectOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Done with SR Product Selection Option');
    ELSIF ((l_profileOptionName = 'IBU_A_SR_BILLTO_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_BILLTO_CONTACT_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_SHIPTO_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_SHIPTO_CONTACT_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_SR_ADDR_DISPLAY' OR
		 l_profileOptionName = 'IBU_SR_ADDR_MANDATORY') AND
		 l_examineAddressOption) THEN

      -- we only want to clone the address region once if any of the
      -- address profile options are customized, but we need to  clone
      -- two of them, one for create, and one for update

      l_newAddressRegionCode := 'IBU_CF_SR_20_R' || p_respId;
      l_newUpdateAddressRegionCode := 'IBU_CF_SR_25_R' || p_respId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_20_G',
                                     672,
                                     l_newAddressRegionCode,
                                     672, FALSE);

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_25_G',
                                     672,
                                     l_newUpdateAddressRegionCode,
                                     672, FALSE);


      -- get all the address-specific profile option values
      -- for this resp

      CS_CF_UPG_UTL_PKG.getAddressProfileValues(p_ProfileTable,
				  l_displayBillToAddress,
				  l_displayBillToContact,
				  l_displayShipToAddress,
				  l_displayShipToContact,
				  l_displayInstalledAtAddr,
				  l_displayIncidentAddr,
				  l_mandatoryIncidentAddr);

      IF (l_displayBillToAddress = 'Y' OR l_displayBillToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                                            'IBU_CF_SR_BILL_TO_HDR',
                                            'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                                            'IBU_CF_SR_BILL_TO_HDR',
                                            'Y', 'N', null);

      END IF;

      IF (l_displayBillToAddress = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                                            'IBU_CF_SR_BILL_TO_ADDRESS',
                                            l_displayBillToAddress, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                                            'IBU_CF_SR_BILL_TO_ADDRESS',
                                            l_displayBillToAddress, 'N', null);

      END IF;

      IF (l_displayBillToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                                            'IBU_CF_SR_BILL_TO_CONTACT',
                                            l_displayBillToContact, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                                            'IBU_CF_SR_BILL_TO_CONTACT',
                                            l_displayBillToContact, 'N', null);

      END IF;

      IF (l_displayShipToAddress = 'Y' OR l_displayShipToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                                            'IBU_CF_SR_SHIP_TO_HDR',
                                            'Y', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                                            'IBU_CF_SR_SHIP_TO_HDR',
                                            'Y', 'N', null);

      END IF;

      IF (l_displayShipToAddress = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                                           'IBU_CF_SR_SHIP_TO_ADDRESS',
                                           l_displayShipToAddress, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                                           'IBU_CF_SR_SHIP_TO_ADDRESS',
                                           l_displayShipToAddress, 'N', null);

      END IF;

      IF (l_displayShipToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                                            'IBU_CF_SR_SHIP_TO_CONTACT',
                                            l_displayShipToContact, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                                            'IBU_CF_SR_SHIP_TO_CONTACT',
                                            l_displayShipToContact, 'N', null);

      END IF;

      IF (l_displayInstalledAtAddr = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                                            'IBU_CF_SR_INSTALLED_AT_HDR',
                                            'Y', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                                            'IBU_CF_SR_INSTALLED_AT_HDR',
                                            'Y', 'N', null);


        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                                            'IBU_CF_SR_INSTALL_AT_ADDR',
                                            l_displayInstalledAtAddr, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                                            'IBU_CF_SR_INSTALL_AT_ADDR',
                                            l_displayInstalledAtAddr, 'N', null);


      END IF;

       -- Now we take care of the case for the incident address
       -- Note that we do not take care of the case where
       -- display addr = N but mandatory addr = Y, because it
       -- doesn't make sense
      IF (l_displayIncidentAddr = 'Y' AND l_mandatoryIncidentAddr = 'Y') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);

          -- For the address region for update, the mandatory flag
          -- can be ignored.
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);


     ELSIF (l_displayIncidentAddr = 'Y' AND l_mandatoryIncidentAddr = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                              'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);

          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                              'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);


    ELSIF (l_displayIncidentAddr = 'N' AND l_mandatoryIncidentAddr = 'Y') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'N', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'N', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'N', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'N', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'N', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'N', 'N', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'N', 'Y', null);
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'N', 'N', null);
          -- We don't need to worry about this case for Update SR address regions, so
          -- no need to do anything.
    END IF;
    l_examineAddressOption := FALSE;
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Done with Address Options');

    ELSIF (l_profileOptionName = 'IBU_SR_CREATION_PRODUCT_OPTION' AND l_examineCreateProdOption) THEN
      -- mkcyee 12/14/2004 - This profile also impacts the product region for
      -- Search and Templates, so we need to clone that region as well.

      l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_R' || p_respId;
      l_newTemplateProductRegionCode := 'IBU_CF_SR_35_R' || p_respId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_30_G',
                                     672,
                                     l_newIdentifyProductRegionCode,
                                     672, FALSE);

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_35_G',
                                     672,
                                     l_newTemplateProductRegionCode,
                                     672, FALSE);

      IF (l_profileOptionValue = 'USE_ONLY_INSTALLBASE_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);


      ELSIF (l_profileOptionValue = 'USE_ONLY_INVENTORY_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
					   'IBU_CF_SR_REG_PRODUCT_RG',
					   'N', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
					   'IBU_CF_SR_REG_PRODUCT_RG',
					   'N', 'N', null);

      END IF;
      l_newProductFilterRegionCode := 'IBU_CF_SR_420_R' || p_respId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_420_G',
                                     672,
                                     l_newProductFilterRegionCode,
                                     672, FALSE);
      IF (l_profileOptionValue = 'USE_ONLY_INSTALLBASE_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);

      ELSIF (l_profileOptionValue = 'USE_ONLY_INVENTORY_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
					   'IBU_CF_SR_REG_PRODUCT_RG',
					   'N', 'N', null);
      END IF;
      l_examineCreateProdOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Done with Creation Product Option');
    ELSIF ((l_profileOptionName = 'IBU_A_SR_ATTACHMENT_OPTION' AND l_examineAttachmentOption) OR (l_profileOptionName = 'IBU_A_SR_PROB_CODE_MANDATORY' and l_examineProbCodeOption)) THEN
      l_newIdentifyProblemRegionCode := 'IBU_CF_SR_40_R' || p_respId;

      CS_CF_UPG_UTL_PKG.getAttachmentProbCodeValues(p_ProfileTable,
                                                    l_displayAttachment,
                                                    l_mandatoryProblemCode);

      IF (l_displayAttachment = 'DONOTSHOW' OR l_displayAttachment = 'SHOWDURINGUPDATE' OR l_mandatoryProblemCode = 'Y') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_40_G',
                                       672,
                                       l_newIdentifyProblemRegionCode,
                                       672, FALSE);
        IF (l_displayAttachment = 'DONOTSHOW') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                           'IBU_CF_SR_ATTACHMENTS_RG',
                           'N', 'N', null);
        ELSIF (l_displayAttachment = 'SHOWDURINGUPDATE') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
                            'N', 'N', null);
        ELSIF(l_mandatoryProblemCode = 'Y') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                          'IBU_CF_SR_PROB_TYPE_CODE',
                          'Y', 'Y', null);

        END IF;
      END IF;
      l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_R' || p_respId;
      IF (l_displayAttachment = 'DONOTSHOW' OR l_displayAttachment = 'SHOWDURINGCREATE') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_130_G',
                                       672,
                                       l_newDtlOverviewRegionCode,
                                       672, FALSE);

        IF (l_displayAttachment = 'DONOTSHOW') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
                            'N', 'N', null);
        ELSIF (l_displayAttachment = 'SHOWDURINGCREATE') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
                            'N', 'N', null);

        END IF;
      END IF; -- end if l_region_count for IBU_CF_SR_130_G
      l_examineAttachmentOption := FALSE;
      l_examineProbCodeOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Done with Attachment Option and Mandatory Problem Code');
    ELSIF (l_profileOptionName = 'IBU_SR_ENABLE_TEMPLATE' AND l_examineTemplateOption) THEN
      l_newProblemDetailsRegionCode := 'IBU_CF_SR_60_R' || p_respId;

      IF (l_profileOptionName = 'N') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_60_G',
                                       672,
                                       l_newProblemDetailsRegionCode,
                                       672, FALSE);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
                            'IBU_CF_SR_PROB_DETAILS',
                            'N', 'N', null);
      END IF;
      l_examineTemplateOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Done with Template Option');

    ELSIF (l_profileOptionName = 'IBU_A_SR_ENABLE_INTERACTION_LOGGING' AND l_examineLoggingOption) THEN
      l_newDtlProgOptionsRegionCode := 'IBU_CF_SR_110_R' || p_respId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_110_G',
                                     672,
                                     l_newDtlProgOptionsRegionCode,
                                     672, FALSE);
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlProgOptionsRegionCode,
                            'IBU_CF_SR_DTL_PROGRESS_INTRCT',
                            'Y', 'N', null);
      l_examineLoggingOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Done with Interaction Logging Option');
    ELSIF (l_profileOptionName = 'IBU_SR_TASK_DISPLAY' AND l_examineTaskOption) THEN
      l_newDtlResolnRegionCode := 'IBU_CF_SR_150_R' || p_respId;
      IF (l_profileOptionValue = 'Y') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_150_G',
                                       672,
                                       l_newDtlResolnRegionCode,
                                       672, FALSE);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlResolnRegionCode,
                            'IBU_CF_SR_DTL_ACTS_RG',
                            'Y', 'N', null);
      END IF;
      l_examineTaskOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Resp', 'Done with Task Display Option');
    END IF; -- end profile checks
    l_index := l_index + 1;
  END LOOP; -- end while loop

  -- Check whether a region has already been cloned for
  -- Primary Contact sub region
  l_newPrimaryContactRegionCode := 'IBU_CF_SR_10_R' || p_respId;
  OPEN does_region_already_exists(l_newPrimaryContactRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newPrimaryContactExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Reg Product sub region
  l_newRegProductRegionCode := 'IBU_CF_SR_80_R' || p_respId;
  OPEN does_region_already_exists(l_newRegProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newRegProductExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- All Product sub region
  l_newAllProductRegionCode := 'IBU_CF_SR_90_R' || p_respId;
  OPEN does_region_already_exists(l_newAllProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newAllProductExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Identify Product sub region
  l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_R' || p_respId;
  OPEN does_region_already_exists(l_newIdentifyProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newIdentifyProductExists := TRUE;
    select node_display_flag INTO
    l_displayRegProducts
    from ak_region_items
    where region_code = l_newIdentifyProductRegionCode
    and attribute_code = 'IBU_CF_SR_REG_PRODUCT_RG'
    and region_application_id = 672
    and attribute_application_id = 672;

    select node_display_flag INTO
    l_displayAllProducts
    from ak_region_items
    where region_code = l_newIdentifyProductRegionCode
    and attribute_code = 'IBU_CF_SR_ALL_PRODUCT_RG'
    and region_application_id = 672
    and attribute_application_id = 672;
  END IF;

  IF (l_newIdentifyProductExists) THEN
    l_newTemplateProductExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for IBU_CF_SR_VW_PRODUCT_FILTER
  l_newProductFilterRegionCode := 'IBU_CF_SR_420_R' || p_respId;
  OPEN does_region_already_exists(l_newProductFilterRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newProductFilterExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for addresses
  l_newAddressRegionCode := 'IBU_CF_SR_20_R' || p_respId;
  OPEN does_region_already_exists(l_newAddressRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newAddressExists := TRUE;
  END IF;

  l_newUpdateAddressRegionCode := 'IBU_CF_SR_25_R' || p_respId;
  OPEN does_region_already_exists(l_newUpdateAddressRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newUpdateAddressExists := TRUE;
  END IF;





  -- Check cloned subregions for Create Service Request flows

  -- Check whether a region has already been
  -- cloned for Identify Problem
  l_newIdentifyProblemRegionCode := 'IBU_CF_SR_40_R' || p_respId;
  OPEN does_region_already_exists(l_newIdentifyProblemRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newIdentifyProblemExists := TRUE;

    select node_display_flag INTO
    l_displayAttachment
    from ak_region_items
    where region_code = l_newIdentifyProblemRegionCode
    and attribute_code = 'IBU_CF_SR_ATTACHMENTS_RG'
    and region_application_id = 672
    and attribute_application_id = 672;

  ELSIF (l_newPrimaryContactExists OR l_newIdentifyProductExists OR l_newAddressExists) THEN
    -- mkcyee 12/07/04 - new Address region has been added to Identify
    -- Problem page, so we need to clone this region is Address region
    -- has been cloned

    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_40_G',
                                   672,
                                   l_newIdentifyProblemRegionCode,
                                   672, FALSE);
    l_newIdentifyProblemExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Problem Details
  l_newProblemDetailsRegionCode := 'IBU_CF_SR_60_R' || p_respId;
  OPEN does_region_already_exists(l_newProblemDetailsRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newProblemDetailsExists := TRUE;

    select node_display_flag INTO
    l_enableTemplate
    from ak_region_items
    where region_code = l_newProblemDetailsRegionCode
    and attribute_code = 'IBU_CF_SR_PROB_DETAILS'
    and region_application_id = 672
    and attribute_application_id = 672;
  ELSIF (l_newPrimaryContactExists OR l_newAddressExists) THEN
    -- mkcyee 12/07/04 - new Address region has been added to Problem
    -- details page, so we need to clone this region is Address region
    -- has been cloned
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_60_G',
                                   672,
                                   l_newProblemDetailsRegionCode,
                                   672, FALSE);
    l_newProblemDetailsExists := TRUE;
  END IF;


  -- Check whether a region has already been cloned for
  -- Update Overview sub region
  l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_R' || p_respId;
  OPEN does_region_already_exists(l_newDtlOverviewRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlOverviewExists := TRUE;
  END IF;


  -- Check whether a region has been cloned for Contact Info
  l_newContactInfoRegionCode := 'IBU_CF_SR_70_R' || p_respId;
  IF (l_newPrimaryContactExists OR l_newAddressExists) THEN
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_70_G',
                                     672,
                                     l_newContactInfoRegionCode,
                                     672, FALSE);
    l_newContactInfoExists := TRUE;
  END IF;

  l_newReviewRegionCode := 'IBU_CF_SR_50_R' || p_respId;

  IF (l_newAddressExists OR l_enableTemplate = 'N' OR
	   l_displayAttachment='N') THEN
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_50_G',
                                     672,
                                     l_newReviewRegionCode,
                                     672, FALSE);

     l_newReviewExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for progress options
  l_newDtlProgOptionsRegionCode := 'IBU_CF_SR_110_R' || p_respId;
  OPEN does_region_already_exists(l_newDtlProgOptionsRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlProgressOptionsExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for IBU_CF_SR_DTL_RESOLN
  l_newDtlResolnRegionCode := 'IBU_CF_SR_150_R' || p_respId;
  OPEN does_region_already_exists(l_newDtlResolnRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlResolnExists := TRUE;
    select node_display_flag INTO
    l_displayTasks
    from ak_region_items
    where region_code = l_newDtlResolnRegionCode
    and attribute_code = 'IBU_CF_SR_DTL_ACTS_RG'
    and region_application_id = 672
    and attribute_application_id = 672;

  END IF;

  -- If regions that were created impact other regions,
  -- make sure to set them to the proper region code.
  -- For some cases, we may have to clone new regions

  IF (l_newAllProductExists AND l_newRegProductExists) THEN
    IF NOT(l_newIdentifyProductExists) THEN
      -- need to clone the IBU_CF_SR_IDENTIFY_PRODUCT region
      l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_R' || p_respId;
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_30_G',
                                     672,
                                     l_newIdentifyProductRegionCode,
                                     672, FALSE);
        l_newIdentifyProductExists := TRUE;
        IF (l_displayRegProducts = '') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
				    'IBU_CF_SR_REG_PRODUCT_RG',
				    'Y', 'N', l_newRegProductRegionCode);
        ELSE
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
				    'IBU_CF_SR_REG_PRODUCT_RG',
				    l_displayRegProducts, 'N', l_newRegProductRegionCode);
        END IF;
        IF (l_displayAllProducts = '') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
				    'IBU_CF_SR_ALL_PRODUCT_RG',
				    'Y', 'N', l_newAllProductRegionCode);
        ELSE
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
				    'IBU_CF_SR_ALL_PRODUCT_RG',
				    l_displayAllProducts, 'N', l_newAllProductRegionCode);
        END IF;
    END IF;
  END IF;

  IF (l_displayRegProducts = 'N' OR l_displayAllProducts = 'N') THEN
    IF NOT(l_newTemplateProductExists) THEN
      -- need to clone the IBU_CF_SR_IDENTIFY_PRODUCT region for Templates
      l_newTemplateProductRegionCode := 'IBU_CF_SR_35_R' || p_respId;
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_35_G',
                                     672,
                                     l_newTemplateProductRegionCode,
                                     672, FALSE);
        l_newTemplateProductExists := TRUE;
        IF (l_displayRegProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
				    'IBU_CF_SR_REG_PRODUCT_RG',
				    'N', 'N', 'IBU_CF_SR_REG_PRODUCT');
        END IF;
        IF (l_displayAllProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
				    'IBU_CF_SR_ALL_PRODUCT_RG',
				    'N', 'N', 'IBU_CF_SR_ALL_PRODUCT');
        END IF;
    END IF;
    IF NOT(l_newProductFilterExists) THEN
      -- need to clone the IBU_CF_SR_VW_PRODUCT_FILTER region
      l_newProductFilterRegionCode := 'IBU_CF_SR_420_R' || p_respId;
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_420_G',
                                     672,
                                     l_newProductFilterRegionCode,
                                     672, FALSE);
        l_newProductFilterExists := TRUE;
        IF (l_displayRegProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
				    'IBU_CF_SR_REG_PRODUCT_RG',
				    'N', 'N', 'IBU_CF_SR_REG_PRODUCT');
        END IF;
        IF (l_displayAllProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
				    'IBU_CF_SR_ALL_PRODUCT_RG',
				    'N', 'N', 'IBU_CF_SR_ALL_PRODUCT');
        END IF;
    END IF;
  END IF;

  IF (l_newIdentifyProblemExists) THEN
    IF (l_newPrimaryContactExists) THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
				    'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
    IF (l_newIdentifyProductExists) THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
				    'Y', 'N', l_newIdentifyProductRegionCode);

    END IF;
    IF (l_newAddressExists) THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
         			    'IBU_CF_SR_ADDRESS_RG',
         			    'N', 'N', l_newAddressRegionCode);
    END IF;
  END IF;

  IF (l_newProblemDetailsExists) THEN
    IF (l_newPrimaryContactExists) THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
				    'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
    IF (l_displayAttachment = 'N') THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_ATTACHMENTS_RG',
				    'N', 'N', null);
    END IF;

    -- mkcyee 12/07/2004 - now the address regions have been added to
    -- Identify Problem and Problem Details pages
    IF (l_newAddressExists) THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
         			    'IBU_CF_SR_ADDRESS_RG',
         			    'N', 'N', l_newAddressRegionCode);
    END IF;
  END IF;


  IF (l_newReviewExists) THEN
    IF (l_displayAttachment = 'N') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_ATTACHMENTS_RG',
	                   'N', 'N', null);
    END IF;
    IF (l_newAddressExists) THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
				    'Y', 'N', l_newAddressRegionCode);
    END IF;
    IF (l_enableTemplate = 'N') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_PROB_DETAILS',
				    'N', 'N', null);
    END IF;
  END IF;

  IF (l_newContactInfoExists) THEN
    IF (l_newAddressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newContactInfoRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
	                   'Y', 'N', l_newAddressRegionCode);
    END IF;
    IF (l_newPrimaryContactExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newContactInfoRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
	                   'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
  END IF;
  --For update service request flows, clone required regions

  IF (l_newUpdateAddressExists) THEN
   --  need to clone the IBU_CF_SR_DTL_CONTACT region
   l_newDtlContactAddrRegionCode := 'IBU_CF_SR_210_R' || p_respId;
   CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_210_G',
                                      672,
                                     l_newDtlContactAddrRegionCode,
                                     672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlContactAddrRegionCode,
  				    'IBU_CF_SR_ADDRESS_RG',
                                    'Y', 'N', l_newUpdateAddressRegionCode);
    l_newDtlContactAddrExists := TRUE;
  END IF;

  IF (l_newDtlProgressOptionsExists) THEN
    -- We must clone IBU_CF_SR_DTL_PROGRESS
    l_newDtlProgressRegionCode := 'IBU_CF_SR_120_R' || p_respId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_120_G',
                                     672,
                                     l_newDtlProgressRegionCode,
                                     672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlProgressRegionCode,
				    'IBU_CF_SR_DTL_PROGRESS_OPT_RG',
                                    'Y', 'N', l_newDtlProgOptionsRegionCode);
    l_newDtlProgressExists := TRUE;
  END IF;

  IF (l_newDtlProgressExists OR l_newDtlResolnExists) THEN
    -- if any of these regions are cloned, then we
    -- must clone IBU_CF_SR_DTL_OVERVIEW
    l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_R' || p_respId;

    IF NOT(l_newDtlOverviewExists)  THEN
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_130_G',
                                     672,
                                     l_newDtlOverviewRegionCode,
                                     672, FALSE);
    END IF;
    IF (l_newUpdateAddressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
    				    'IBU_CF_SR_ADDRESS_RG',
    	                   'N', 'N', l_newUpdateAddressRegionCode);
    END IF;
    IF (l_newDtlProgressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
				    'IBU_CF_SR_DTL_PROGRESS_RG',
	                   'Y', 'N', l_newDtlProgressRegionCode);
    END IF;
    IF (l_newDtlResolnExists AND l_displayTasks = 'Y') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
				    'IBU_CF_SR_DTL_ACTS_RG',
	                   'Y', 'N', null);
    END IF;
    l_newDtlOverviewExists := TRUE;
  END IF;


  IF (l_newDtlOverviewExists OR l_newDtlResolnExists) THEN
    -- then we must clone IBU_CF_SR_DTL_TABS
    l_newDtlTabsRegionCode := 'IBU_CF_SR_160_R' || p_respId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_160_G',
                                   672,
                                   l_newDtlTabsRegionCode,
                                   672, FALSE);
    IF (l_newDtlOverviewExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlTabsRegionCode,
				    'IBU_CF_SR_DTL_OVERVIEW_TAB_RG',
	                   'Y', 'N', l_newDtlOverviewRegionCode);
    END IF;
    IF (l_newDtlResolnExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlTabsRegionCode,
  			         'IBU_CF_SR_DTL_RESOLN_TAB_RG',
	                   'N', 'N', l_newDtlResolnRegionCode);
    END IF;
    l_newDtlTabsExists := TRUE;
  END IF;

  IF (l_newDtlTabsExists) THEN
    -- then we must clone IBU_CF_SR_DETAILS
    l_newDtlDetailsRegionCode := 'IBU_CF_SR_190_R' || p_respId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_190_G',
                                   672,
                                   l_newDtlDetailsRegionCode,
                                   672, FALSE);
    IF (l_newDtlDetailsExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlDetailsRegionCode,
				    'IBU_CF_SR_DTL_TABS_RG',
	                   'Y', 'N', l_newDtlTabsRegionCode);
    END IF;
    l_newDtlDetailsExists := TRUE;
  END IF;

  -- Now check for the Templates

  -- mkcyee 12/14/2004 - use l_newTemplateProductExists
  -- because Templates and Search now have a separate product section

  IF (l_newTemplateProductExists) THEN
    l_newCreateTemplateRegionCode := 'IBU_CF_SR_310_R' || p_respId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_310_G',
                                   672,
                                   l_newCreateTemplateRegionCode,
                                   672, FALSE);
    -- mkcyee 12/16/2004 - The template region now points to its own copy of
    -- primary contact region, so no need to clone create/update template region
    -- because of this.
    --IF (l_newPrimaryContactExists) THEN
    --  CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateTemplateRegionCode,
    --				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
    --	                   'Y', 'N', l_newPrimaryContactRegionCode);
    --END IF;
    --IF (l_newTemplateProductExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateTemplateRegionCode,
    				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
                       'Y', 'N', l_newTemplateProductRegionCode);
    --END IF;
    l_newCreateTemplateExists := TRUE;
    l_newUpdateTemplateRegionCode := 'IBU_CF_SR_320_R' || p_respId;

    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_320_G',
                                   672,
                                   l_newUpdateTemplateRegionCode,
                                   672, FALSE);
    --IF (l_newPrimaryContactExists) THEN
    --  CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateTemplateRegionCode,
    --				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
    --	                   'Y', 'N', l_newPrimaryContactRegionCode);
    --END IF;
    --IF (l_newTemplateProductExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateTemplateRegionCode,
    				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
    	                   'Y', 'N', l_newTemplateProductRegionCode);
    --END IF;
    l_newUpdateTemplateExists := TRUE;
  END IF;

  IF (l_newProductFilterExists) THEN
    -- need to clone IBU_CF_SR_VW_FILTER
    l_newFilterRegionCode := 'IBU_CF_SR_410_R' || p_respId;

    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_410_G',
                                   672,
                                   l_newFilterRegionCode,
                                   672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newFilterRegionCode,
                                   'IBU_CF_SR_VW_PRODUCT_FILTER_RG',
	                   'Y', 'N', l_newProductFilterRegionCode);

    l_newFilterExists := TRUE;
  END IF;

  IF (l_newFilterExists) THEN
    -- need to clone IBU_CF_SR_VW_SEARCH, IBU_CF_SR_VW_CREATE, IBU_CF_SR_VW_UPDATE
    l_newSearchViewRegionCode := 'IBU_CF_SR_450_R' || p_respId;

    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_450_G',
                                   672,
                                   l_newSearchViewRegionCode,
                                   672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newSearchViewRegionCode,
				    'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newSearchViewExists := TRUE;

    l_newCreateViewRegionCode := 'IBU_CF_SR_430_R' || p_respId;

    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_430_G',
                                   672,
                                   l_newCreateViewRegionCode,
                                   672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateViewRegionCode,
                                   'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newCreateViewExists := TRUE;

    l_newUpdateViewRegionCode := 'IBU_CF_SR_440_R' || p_respId;

    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_440_G',
                                   672,
                                   l_newUpdateViewRegionCode,
                                   672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateViewRegionCode,
				    'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newUpdateViewExists := TRUE;
  END IF;

  -- Now enter the rows in the cs_cf_source_cxt_targets table
  -- for this responsibility

  IF (l_newIdentifyProblemExists ) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
	   'IBU_SR_CR_IDENTIFY_PROBLEM',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newIdentifyProblemRegionCode,
        '672');
  END IF;

  IF (l_newReviewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_REVIEW',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newReviewRegionCode,
        '672');
  END IF;

  IF (l_newProblemDetailsExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_PROBLEM_DETAILS',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newProblemDetailsRegionCode,
        '672');
  END IF;


  IF (l_newContactInfoExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_CONTACT_INFORMATION',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newContactInfoRegionCode,
        '672');
  END IF;

  IF (l_newDtlDetailsExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_DETAILS',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newDtlDetailsRegionCode,
        '672');
  END IF;

  IF (l_newCreateTemplateExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_TEMP_CREATE',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newCreateTemplateRegionCode,
        '672');
  END IF;

  IF (l_newUpdateTemplateExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_TEMP_UPDATE',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newUpdateTemplateRegionCode,
        '672');
  END IF;

  IF (l_newSearchViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_SUMMARY',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newSearchViewRegionCode,
        '672');
  END IF;

  IF (l_newCreateViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_CREATE',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newCreateViewRegionCode,
        '672');
  END IF;

  IF (l_newUpdateViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_UPDATE',
	   'RESP',
	   l_respId,
	   l_respApplId,
	   NULL,
	   NULL,
        l_newUpdateViewRegionCode,
        '672');
  END IF;

END Clone_Regions_For_Resp;

/*
 * Procedure to performing upgrades for application level
 * For each application
 */
PROCEDURE Do_Region_Upgrades_For_Appl(p_applTable IN CS_CF_UPG_UTL_PKG.ApplTable)
IS

  -- this picks up all the configuration profiles
  -- that affects region configuration for
  -- the application and the higher site level
  CURSOR get_profiles_for_appl (applId NUMBER)
  IS
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    1 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10002
  AND   b.level_value = applId
  AND   a.profile_option_id = b.profile_option_id
  AND   a.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_ACCOUNT_OPTION',
                                 'IBU_A_SR_PROB_CODE_MANDATORY',
                                 'IBU_SR_CREATION_PRODUCT_OPTION',
                                 'IBU_SR_ADDR_DISPLAY',
                                 'IBU_SR_ADDR_MANDATORY',
                                 'IBU_A_SR_BILLTO_ADDRESS_OPTION',
                                 'IBU_A_SR_BILLTO_CONTACT_OPTION',
                                 'IBU_A_SR_SHIPTO_ADDRESS_OPTION',
                                 'IBU_A_SR_SHIPTO_CONTACT_OPTION',
                                 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION',
                                 'IBU_A_SR_ATTACHMENT_OPTION',
                                 'IBU_SR_TASK_DISPLAY',
                                 'IBU_A_SR_ENABLE_INTERACTION_LOGGING',
                                 'IBU_SR_ENABLE_TEMPLATE',
                                 'IBU_A_SR_PRODUCT_SELECTION_OPTION')
  UNION
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    2 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10001
  AND   a.profile_option_id = b.profile_option_id
  AND   a.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_ACCOUNT_OPTION',
                                 'IBU_A_SR_PROB_CODE_MANDATORY',
                                 'IBU_SR_CREATION_PRODUCT_OPTION',
                                 'IBU_SR_ADDR_DISPLAY',
                                 'IBU_SR_ADDR_MANDATORY',
                                 'IBU_A_SR_BILLTO_ADDRESS_OPTION',
                                 'IBU_A_SR_BILLTO_CONTACT_OPTION',
                                 'IBU_A_SR_SHIPTO_ADDRESS_OPTION',
                                 'IBU_A_SR_SHIPTO_CONTACT_OPTION',
                                 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION',
                                 'IBU_A_SR_ATTACHMENT_OPTION',
                                 'IBU_SR_TASK_DISPLAY',
                                 'IBU_A_SR_ENABLE_INTERACTION_LOGGING',
                                 'IBU_SR_ENABLE_TEMPLATE',
                                 'IBU_A_SR_PRODUCT_SELECTION_OPTION')
  ORDER BY PROFILE_OPTION_NAME, PRIORITY;

  l_count NUMBER := p_applTable.COUNT;
  l_index NUMBER := 0;
  l_index2 NUMBER := 0;
  l_profile_option_name FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE;
  l_level_value_application_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
  l_priority NUMBER := 0;

  l_ProfileTable CS_CF_UPG_UTL_PKG.ProfileTable;

BEGIN


  WHILE (l_index < l_count) LOOP
    -- Get the list of profile names and their values
    -- and store it in a table
    -- This table may contain duplicate entries for
    -- each profile because we pick up the values
    -- for the application and site level also
    OPEN get_profiles_for_appl(p_applTable(l_index));
    LOOP
	 -- Retrieve information into the local variables
	 FETCH get_profiles_for_appl INTO l_profile_option_name,
							    l_level_value,
							    l_level_value_application_id,
							    l_profile_option_value,
							    l_priority;

      l_ProfileTable(l_index2).profileOptionName := l_profile_option_name;
	 l_ProfileTable(l_index2).profileOptionValue := l_profile_option_value;

	 l_index2 := l_index2 + 1;

	 EXIT WHEN get_profiles_for_appl%NOTFOUND;

    END LOOP;
    CLOSE get_profiles_for_appl;

    -- Now we have a table of profiles
    -- Determine which regions need to be cloned for this resp

    IF (CS_CF_UPG_UTL_PKG.Regions_Not_Already_Cloned('A' || p_ApplTable(l_index))) THEN
      Clone_Regions_For_Appl(l_ProfileTable, p_ApplTable(l_index));
      commit;
    END IF;

    -- now clean up the table so it can be reused
    l_ProfileTable.DELETE;
    l_index2 := 0;

    l_index := l_index + 1;
  END LOOP; -- ends while loop

END Do_Region_Upgrades_For_Appl;

/*
 * Procedure to performing upgrades for site level
 */
PROCEDURE Do_Region_Upgrades_For_Global(p_siteProfilesTable IN CS_CF_UPG_UTL_PKG.ProfileTable)
IS

BEGIN

  -- mkcyee 12/13/2004 - Global regions are a special case.  Because ldt file
  -- may overwrite the cust target values, we must run the procedure to
  -- make sure we place back the cust target values even if the regions are already cloned.

--  IF (CS_CF_UPG_UTL_PKG.Regions_Not_Already_cloned('GC')) THEN
    Clone_Regions_For_Global(p_siteProfilesTable);
    commit;
--  END IF;

END Do_Region_Upgrades_For_Global;

/*
 * Procedure for cloning regions at the global level
 */

PROCEDURE Clone_Regions_For_Global(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTAble)

IS

  l_count NUMBER := p_ProfileTable.COUNT;
  l_index NUMBER := 0;
  l_profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_profileOptionValue FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
  l_newPrimaryContactRegionCode VARCHAR2(30) := 'IBU_CF_SR_10_G';
  l_newAddressRegionCode VARCHAR2(30) := 'IBU_CF_SR_20_G';
  l_newUpdateAddressRegionCode VARCHAR2(30) := 'IBU_CF_SR_25_G';
  l_newIdentifyProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_30_G';
  l_newTemplateProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_35_G';
  l_newIdentifyProblemRegionCode VARCHAR2(30) := 'IBU_CF_SR_40_G';
  l_newReviewRegionCode VARCHAR2(30) := 'IBU_CF_SR_50_G';
  l_newProblemDetailsRegionCode VARCHAR2(30) := 'IBU_CF_SR_60_G';
  l_newContactInfoRegionCode VARCHAR2(30) := 'IBU_CF_SR_70_G';
  l_newDtlOverviewRegionCode VARCHAR2(30) := 'IBU_CF_SR_130_G';
  l_newDtlContactAddrRegionCode VARCHAR2(30) := 'IBU_CF_SR_210_G';
  l_newDtlTabsRegionCode VARCHAR2(30) := 'IBU_CF_SR_160_G';
  l_newDtlDetailsRegionCode VARCHAR2(30) := 'IBU_CF_SR_190_G';
  l_newDtlProgOptionsRegionCode VARCHAR2(30) := 'IBU_CF_SR_110_G';
  l_newDtlProgressRegionCode VARCHAR2(30) := 'IBU_CF_SR_120_G';
  l_newDtlResolnRegionCode VARCHAR2(30) := 'IBU_CF_SR_150_G';
  l_newCreateTemplateRegionCode VARCHAR2(30) := 'IBU_CF_SR_310_G';
  l_newUpdateTemplateRegionCode VARCHAR2(30) := 'IBU_CF_SR_320_G';
  l_newCreateViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_430_G';
  l_newUpdateViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_440_G';
  l_newSearchViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_450_G';
  l_newProductFilterRegionCode VARCHAR2(30) := 'IBU_CF_SR_420_G';
  l_newRegProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_80_G';
  l_newAllProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_90_G';
  l_newFilterRegionCode VARCHAR2(30) := 'IBU_CF_SR_410_G';

  l_displayBillToAddress FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayBillToContact FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayShipToAddress FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayShipToContact FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayInstalledAtAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayIncidentAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_mandatoryIncidentAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayAttachment FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayRegProducts FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayAllProducts FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_enableTemplate FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayTasks FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_mandatoryProblemCode FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';


  l_region_count NUMBER := 0;

  l_newIdentifyProblemExists BOOLEAN := FALSE;
  l_newPrimaryContactExists BOOLEAN := FALSE;
  l_newProblemDetailsExists BOOLEAN := FALSE;
  l_newAddressExists BOOLEAN := FALSE;
  l_newUpdateAddressExists BOOLEAN := FALSE;
  l_newContactInfoExists BOOLEAN := FALSE;
  l_newReviewExists BOOLEAN := FALSE;
  l_newDtlOverviewExists BOOLEAN := FALSE;
  l_newDtlContactAddrExists BOOLEAN := FALSE;
  l_newDtlTabsExists BOOLEAN := FALSE;
  l_newDtlProgressOptionsExists BOOLEAN := FALSE;
  l_newDtlResolnExists BOOLEAN := FALSE;
  l_newDtlDetailsExists BOOLEAN := FALSE;
  l_newDtlProgressExists BOOLEAN := FALSE;
  l_newIdentifyProductExists BOOLEAN := FALSE;
  l_newTemplateProductExists BOOLEAN := FALSE;
  l_newCreateTemplateExists BOOLEAN := FALSE;
  l_newUpdateTemplateExists BOOLEAN := FALSE;
  l_newProductFilterExists BOOLEAN := FALSE;
  l_newCreateViewExists BOOLEAN := FALSE;
  l_newUpdateViewExists BOOLEAN := FALSE;
  l_newSearchViewExists BOOLEAN := FALSE;
  l_newRegProductExists BOOLEAN := FALSE;
  l_newAllProductExists BOOLEAN := FALSE;
  l_newFilterExists BOOLEAN := FALSE;

  -- the following set of variables are used to
  -- determine whether we've already examined
  -- the profile option. If we have, we don't need to look at it again
  l_examineSrAccountOption BOOLEAN := TRUE;
  l_examineAddressOption BOOLEAN := TRUE;
  l_examineCreateProdOption BOOLEAN := TRUE;
  l_examineAttachmentOption BOOLEAN := TRUE;
  l_examineTemplateOption BOOLEAN := TRUE;
  l_examineLoggingOption BOOLEAN := TRUE;
  l_examineTaskOption BOOLEAN := TRUE;
  l_examineProdSelectOption BOOLEAN := TRUE;
  l_examineProbCodeOption BOOLEAN := TRUE;

BEGIN

  CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', '');
  WHILE (l_index < l_count) LOOP
    l_profileOptionName := p_ProfileTable(l_index).profileOptionName;
    l_profileOptionValue := p_ProfileTable(l_index).profileOptionValue;

    IF (l_profileOptionName = 'IBU_A_SR_ACCOUNT_OPTION' AND l_examineSrAccountOption) THEN
      -- clone the region
      l_newPrimaryContactRegionCode := 'IBU_CF_SR_10_GC';

      -- the region doesn't already exist, so go ahead and create it
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_10_G',
                                       672,
                                       l_newPrimaryContactRegionCode,
                                       672, TRUE);

      IF (l_profileOptionValue = 'OPTIONAL') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newPrimaryContactRegionCode,
                                              'IBU_CF_SR_ACCOUNT_NUMBER',
                                              'Y', 'N', null);

      END IF;
      l_examineSrAccountOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', 'Done with SR Account Option');
    ELSIF (l_profileOptionName = 'IBU_A_SR_PRODUCT_SELECTION_OPTION' AND l_examineProdSelectOption) THEN
      -- clone the regions
      l_newRegProductRegionCode := 'IBU_CF_SR_80_GC';

      -- the region doesn't already exist, so go ahead and create it
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_80_G',
                                       672,
                                       l_newRegProductRegionCode,
                                       672, TRUE);

      IF (l_profileOptionValue = 'N') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newRegProductRegionCode,
                                              'IBU_CF_SR_R_PROD_NAME_LOV',
                                              'Y', 'N', null);

      END IF;
      l_newAllProductRegionCode := 'IBU_CF_SR_90_GC';
      -- the region doesn't already exist, so go ahead and create it
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_90_G',
                                       672,
                                       l_newAllProductRegionCode,
                                       672, TRUE);

      IF (l_profileOptionValue = 'N') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAllProductRegionCode,
                                              'IBU_CF_SR_PROD_BY_NAME_LOV',
                                              'Y', 'N', null);

      END IF;
      l_examineProdSelectOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', 'Done with SR Product Selection Option');
    ELSIF ((l_profileOptionName = 'IBU_A_SR_BILLTO_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_BILLTO_CONTACT_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_SHIPTO_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_SHIPTO_CONTACT_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_SR_ADDR_DISPLAY' OR
		 l_profileOptionName = 'IBU_SR_ADDR_MANDATORY') AND
		 l_examineAddressOption) THEN

      -- we only want to clone the address region once if any of the
       -- address profile options are customized.

      l_newAddressRegionCode := 'IBU_CF_SR_20_GC';

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_20_G',
							672,
							l_newAddressRegionCode,
							672, TRUE);
      l_newUpdateAddressRegionCode := 'IBU_CF_SR_25_GC';

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_25_G',
							672,
							l_newUpdateAddressRegionCode,
							672, TRUE);


      -- get all the address-specific profile option values
      -- for this resp

      CS_CF_UPG_UTL_PKG.getAddressProfileValues(p_ProfileTable,
				  l_displayBillToAddress,
				  l_displayBillToContact,
				  l_displayShipToAddress,
				  l_displayShipToContact,
				  l_displayInstalledAtAddr,
				  l_displayIncidentAddr,
				  l_mandatoryIncidentAddr);

      IF (l_displayBillToAddress = 'Y' OR l_displayBillToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
					'IBU_CF_SR_BILL_TO_HDR',
                                        'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
					'IBU_CF_SR_BILL_TO_HDR',
                                        'Y', 'N', null);

      END IF;

      IF (l_displayBillToAddress = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_BILL_TO_ADDRESS',
						l_displayBillToAddress, 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_BILL_TO_ADDRESS',
						l_displayBillToAddress, 'N', null);

      END IF;

      IF (l_displayBillToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_BILL_TO_CONTACT',
						l_displayBillToContact, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_BILL_TO_CONTACT',
						l_displayBillToContact, 'N', null);

      END IF;

      IF (l_displayShipToAddress = 'Y' OR l_displayShipToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_SHIP_TO_HDR',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_SHIP_TO_HDR',
						'Y', 'N', null);

      END IF;

      IF (l_displayShipToAddress = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                              'IBU_CF_SR_SHIP_TO_ADDRESS',
						l_displayShipToAddress, 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                              'IBU_CF_SR_SHIP_TO_ADDRESS',
						l_displayShipToAddress, 'N', null);


      END IF;

      IF (l_displayShipToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_SHIP_TO_CONTACT',
						l_displayShipToContact, 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_SHIP_TO_CONTACT',
						l_displayShipToContact, 'N', null);

      END IF;

      IF (l_displayInstalledAtAddr = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_INSTALLED_AT_HDR',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_INSTALLED_AT_HDR',
						'Y', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_INSTALL_AT_ADDR',
						l_displayInstalledAtAddr, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_INSTALL_AT_ADDR',
						l_displayInstalledAtAddr, 'N', null);

      END IF;

      -- Now we take care of the case for the incident address
      -- Note that we do not take care of the case where
      -- display addr = N but mandatory addr = Y, because it
      -- doesn't make sense
      IF (l_displayIncidentAddr = 'Y' AND l_mandatoryIncidentAddr = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);
        -- we update this for the address region for update SR, but the
        -- mandatory flag is ignored.
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);

      ELSIF (l_displayIncidentAddr = 'Y' AND l_mandatoryIncidentAddr = 'N') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                              'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                              'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);

      ELSIF (l_displayIncidentAddr = 'N' AND l_mandatoryIncidentAddr = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
					'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'N', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'N', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'N', 'N', null);

        -- we can ignore this case for the address region in update SR
      END IF;
      l_examineAddressOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', 'Done with Address Options');

    ELSIF (l_profileOptionName = 'IBU_SR_CREATION_PRODUCT_OPTION' AND l_examineCreateProdOption) THEN

      -- mkcyee 12/14/2004 - This profile also impacts the product region for
      -- Templates, so we need to clone that region as well.

      l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_GC';
      l_newTemplateProductRegioncode := 'IBU_CF_SR_35_GC';

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_30_G',
                                     672,
                                     l_newIdentifyProductRegionCode,
                                     672, TRUE);

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_35_G',
                                     672,
                                     l_newTemplateProductRegionCode,
                                     672, TRUE);

      IF (l_profileOptionValue = 'USE_ONLY_INSTALLBASE_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);

      ELSIF (l_profileOptionValue = 'USE_ONLY_INVENTORY_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
				   'IBU_CF_SR_REG_PRODUCT_RG',
					   'N', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
                                           'IBU_CF_SR_REG_PRODUCT_RG',
                                           'N', 'N', null);

      END IF;
      l_newProductFilterRegionCode := 'IBU_CF_SR_420_GC';

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_420_G',
                                     672,
                                     l_newProductFilterRegionCode,
                                     672, TRUE);
      IF (l_profileOptionValue = 'USE_ONLY_INSTALLBASE_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);

      ELSIF (l_profileOptionValue = 'USE_ONLY_INVENTORY_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
					   'IBU_CF_SR_REG_PRODUCT_RG',
					   'N', 'N', null);
      END IF;
      l_examineCreateProdOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', 'Done with Creation Product Option');
    ELSIF ((l_profileOptionName = 'IBU_A_SR_ATTACHMENT_OPTION' AND l_examineAttachmentOption) OR (l_profileOptionName = 'IBU_A_SR_PROB_CODE_MANDATORY' and l_examineProbCodeOption)) THEN
      l_newIdentifyProblemRegionCode := 'IBU_CF_SR_40_GC';

      CS_CF_UPG_UTL_PKG.getAttachmentProbCodeValues(p_ProfileTable,
                                                         l_displayAttachment,
                                                         l_mandatoryProblemCode);

      IF (l_displayAttachment = 'DONOTSHOW' OR l_displayAttachment = 'SHOWDURINGUPDATE' OR l_mandatoryProblemCode = 'Y') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_40_G',
                                       672,
                                       l_newIdentifyProblemRegionCode,
                                       672, TRUE);
        IF (l_displayAttachment = 'DONOTSHOW') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
					   'N', 'N', null);
        ELSIF (l_displayAttachment = 'SHOWDURINGUPDATE') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
					   'N', 'N', null);
        ELSIF (l_mandatoryProblemCode = 'Y') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                            'IBU_CF_SR_PROB_TYPE_CODE',
					   'Y', 'Y', null);

        END IF;
      END IF;
      l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_GC';
      IF (l_displayAttachment = 'DONOTSHOW' OR l_displayAttachment = 'SHOWDURINGCREATE') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_130_G',
                                       672,
                                       l_newDtlOverviewRegionCode,
                                       672, TRUE);

        IF (l_displayAttachment = 'DONOTSHOW') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
					   'N', 'N', null);
        ELSIF (l_displayAttachment = 'SHOWDURINGCREATE') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
					   'N', 'N', null);
        END IF;
      END IF;
      l_examineAttachmentOption := FALSE;
      l_examineProbCodeOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', 'Done with Attachment Option and Mandatory Problem Code' );
    ELSIF (l_profileOptionName = 'IBU_SR_ENABLE_TEMPLATE' AND l_examineTemplateOption) THEN
      l_newProblemDetailsRegionCode := 'IBU_CF_SR_60_GC';
      IF (l_profileOptionName = 'N') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_60_G',
                                       672,
                                       l_newProblemDetailsRegionCode,
                                       672, TRUE);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
                            'IBU_CF_SR_PROB_DETAILS',
					   'N', 'N', null);
      END IF;
      l_examineTemplateOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', 'Done with Template Option');

    ELSIF (l_profileOptionName = 'IBU_A_SR_ENABLE_INTERACTION_LOGGING' AND l_examineLoggingOption) THEN
      l_newDtlProgOptionsRegionCode := 'IBU_CF_SR_110_GC';
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_110_G',
							672,
							l_newDtlProgOptionsRegionCode,
						     672, TRUE);
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlProgOptionsRegionCode,
                            'IBU_CF_SR_DTL_PROGRESS_INTRCT',
					   'Y', 'N', null);
      l_examineLoggingOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', 'Done with Interaction Logging Option');
    ELSIF (l_profileOptionName = 'IBU_SR_TASK_DISPLAY' AND l_examineTaskOption) THEN
      l_newDtlResolnRegionCode := 'IBU_CF_SR_150_GC';
      IF (l_profileOptionValue = 'Y') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_150_G',
							672,
							l_newDtlResolnRegionCode,
						     672, TRUE);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlResolnRegionCode,
                            'IBU_CF_SR_DTL_ACTS_RG',
					   'Y', 'N', null);
      END IF;
      l_examineTaskOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Global', 'Done with Task Display Option');
    END IF; -- end profile checks
    l_index := l_index + 1;
  END LOOP; -- end while loop

  -- Check whether a region has already been cloned for
  -- Primary Contact sub region
  l_newPrimaryContactRegionCode := 'IBU_CF_SR_10_GC';
  OPEN does_region_already_exists(l_newPrimaryContactRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newPrimaryContactExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Reg Product sub region
  l_newRegProductRegionCode := 'IBU_CF_SR_80_GC';
  OPEN does_region_already_exists(l_newRegProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newRegProductExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- All Product sub region
  l_newAllProductRegionCode := 'IBU_CF_SR_90_GC';
  OPEN does_region_already_exists(l_newAllProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newAllProductExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Identify Product sub region
  l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_GC';
  OPEN does_region_already_exists(l_newIdentifyProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newIdentifyProductExists := TRUE;
    select node_display_flag INTO
    l_displayRegProducts
    from ak_region_items
    where region_code = l_newIdentifyProductRegionCode
    and attribute_code = 'IBU_CF_SR_REG_PRODUCT_RG'
    and region_application_id = 672
    and attribute_application_id = 672;

    select node_display_flag INTO
    l_displayAllProducts
    from ak_region_items
    where region_code = l_newIdentifyProductRegionCode
    and attribute_code = 'IBU_CF_SR_ALL_PRODUCT_RG'
    and region_application_id = 672
    and attribute_application_id = 672;
  END IF;

  IF (l_newIdentifyProductExists) THEN
    l_newTemplateProductExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for Product Filter
  l_newProductFilterRegionCode := 'IBU_CF_SR_420_GC';
  OPEN does_region_already_exists(l_newProductFilterRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newProductFilterExists := TRUE;
  END IF;


  -- Check whether a region has been cloned for addresses
  l_newAddressRegionCode := 'IBU_CF_SR_20_GC';
  OPEN does_region_already_exists(l_newAddressRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newAddressExists := TRUE;
  END IF;

  l_newUpdateAddressRegionCode := 'IBU_CF_SR_25_GC';
  OPEN does_region_already_exists(l_newUpdateAddressRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newUpdateAddressExists := TRUE;
  END IF;




  -- Check cloned subregions for Create Service Request flows

  -- Check whether a region has already been
  -- cloned for Identify Problem
  l_newIdentifyProblemRegionCode := 'IBU_CF_SR_40_GC';
  OPEN does_region_already_exists(l_newIdentifyProblemRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newIdentifyProblemExists := TRUE;

    select node_display_flag INTO
    l_displayAttachment
    from ak_region_items
    where region_code = l_newIdentifyProblemRegionCode
    and attribute_code = 'IBU_CF_SR_ATTACHMENTS_RG'
    and region_application_id = 672
    and attribute_application_id = 672;

  ELSIF (l_newPrimaryContactExists OR l_newIdentifyProductExists OR l_newAddressExists) THEN
    -- mkcyee 12/07/04 - new Address region has been added to Identify
    -- Problem page, so we need to clone this region is Address region
    -- has been cloned

    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_40_G',
							672,
							l_newIdentifyProblemRegionCode,
							672, TRUE);
    l_newIdentifyProblemExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Problem Details
  l_newProblemDetailsRegionCode := 'IBU_CF_SR_60_GC';
  OPEN does_region_already_exists(l_newProblemDetailsRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newProblemDetailsExists := TRUE;

    select node_display_flag INTO
    l_enableTemplate
    from ak_region_items
    where region_code = l_newProblemDetailsRegionCode
    and attribute_code = 'IBU_CF_SR_PROB_DETAILS'
    and region_application_id = 672
    and attribute_application_id = 672;
  ELSIF (l_newPrimaryContactExists OR l_newAddressExists) THEN
    -- mkcyee 12/07/04 - new Address region has been added to Problem
    -- details page, so we need to clone this region is Address region
    -- has been cloned
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_60_G',
							672,
							l_newProblemDetailsRegionCode,
							672, TRUE);
    l_newProblemDetailsExists := TRUE;
  END IF;


  -- Check whether a region has already been cloned for
  -- Update Overview sub region
  l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_GC';
  OPEN does_region_already_exists(l_newDtlOverviewRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlOverviewExists := TRUE;
  END IF;


  -- Check whether a region has been cloned for Contact Info
  l_newContactInfoRegionCode := 'IBU_CF_SR_70_GC' ;
  IF (l_newPrimaryContactExists OR l_newAddressExists) THEN
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_70_G',
                                   672,
                                   l_newContactInfoRegionCode,
                                   672, TRUE);
    l_newContactInfoExists := TRUE;
  END IF;

  l_newReviewRegionCode := 'IBU_CF_SR_50_GC' ;
  IF (l_newAddressExists OR l_enableTemplate = 'N' OR
	   l_displayAttachment='N') THEN
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_50_G',
							672,
							l_newReviewRegionCode,
							672, TRUE);

    l_newReviewExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for progress options
  l_newDtlProgOptionsRegionCode := 'IBU_CF_SR_110_GC' ;
  OPEN does_region_already_exists(l_newDtlProgOptionsRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlProgressOptionsExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for IBU_CF_SR_DTL_RESOLN
  l_newDtlResolnRegionCode := 'IBU_CF_SR_150_GC' ;
  OPEN does_region_already_exists(l_newDtlResolnRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlResolnExists := TRUE;
    select node_display_flag INTO
    l_displayTasks
    from ak_region_items
    where region_code = l_newDtlResolnRegionCode
    and attribute_code = 'IBU_CF_SR_DTL_ACTS_RG'
    and region_application_id = 672
    and attribute_application_id = 672;
  END IF;

  -- If regions that were created impact other regions,
  -- make sure to set them to the proper region code.
  -- For some cases, we may have to clone new regions


  IF (l_newAllProductExists AND l_newRegProductExists) THEN
    IF NOT(l_newIdentifyProductExists) THEN
      -- need to clone the IBU_CF_SR_IDENTIFY_PRODUCT region
      l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_GC';
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_30_G',
                                     672,
                                     l_newIdentifyProductRegionCode,
                                     672, TRUE);
        l_newIdentifyProductExists := TRUE;
        IF (l_displayRegProducts = '') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
                                    'IBU_CF_SR_REG_PRODUCT_RG',
                                    'Y', 'N', l_newRegProductRegionCode);
        ELSE
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
                                    'IBU_CF_SR_REG_PRODUCT_RG',
                                    l_displayRegProducts, 'N', l_newRegProductRegionCode);
        END IF;
        IF (l_displayAllProducts = '') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
                                    'IBU_CF_SR_ALL_PRODUCT_RG',
                                    'Y', 'N', l_newAllProductRegionCode);
        ELSE
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
                                    'IBU_CF_SR_ALL_PRODUCT_RG',
                                    l_displayAllProducts, 'N', l_newAllProductRegionCode);
        END IF;
    END IF;
  END IF;

  IF (l_displayRegProducts = 'N' OR l_displayAllProducts = 'N') THEN
    IF NOT(l_newTemplateProductExists) THEN
      -- need to clone the IBU_CF_SR_IDENTIFY_PRODUCT region for Templates
      l_newTemplateProductRegionCode := 'IBU_CF_SR_35_GC';
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_35_G',
                                     672,
                                     l_newTemplateProductRegionCode,
                                     672, TRUE);
        l_newTemplateProductExists := TRUE;
        IF (l_displayRegProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
                                    'IBU_CF_SR_REG_PRODUCT_RG',
                                    'N', 'N', 'IBU_CF_SR_REG_PRODUCT');
        END IF;
        IF (l_displayAllProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
                                    'IBU_CF_SR_ALL_PRODUCT_RG',
                                    'N', 'N', 'IBU_CF_SR_ALL_PRODUCT');
        END IF;
    END IF;
    IF NOT(l_newProductFilterExists) THEN
      -- need to clone the IBU_CF_SR_VW_PRODUCT_FILTER region
      l_newProductFilterRegionCode := 'IBU_CF_SR_420_GC';
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_420_G',
                                     672,
                                     l_newProductFilterRegionCode,
                                     672, TRUE);
        l_newProductFilterExists := TRUE;
        IF (l_displayRegProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
                                    'IBU_CF_SR_REG_PRODUCT_RG',
                                    'N', 'N', 'IBU_CF_SR_REG_PRODUCT');
        END IF;
        IF (l_displayAllProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
                                    'IBU_CF_SR_ALL_PRODUCT_RG',
                                    'N', 'N', 'IBU_CF_SR_ALL_PRODUCT');
        END IF;
    END IF;
  END IF;

  IF (l_newIdentifyProblemExists) THEN
    IF (l_newPrimaryContactExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
				    'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
    IF (l_newIdentifyProductExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
				    'Y', 'N', l_newIdentifyProductRegionCode);

    END IF;
    IF (l_newAddressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
				    'N', 'N', l_newAddressRegionCode);
    END IF;
  END IF;

  IF (l_newProblemDetailsExists) THEN
    IF (l_newPrimaryContactExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
				    'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
    IF (l_displayAttachment = 'N') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_ATTACHMENTS_RG',
				    'N', 'N', null);
    END IF;

    -- mkcyee 12/07/2004 - the address region has been added to Identify
    -- Problem and Problem Details
    IF (l_newAddressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
				    'N', 'N', l_newAddressRegionCode);
    END IF;
  END IF;


  IF (l_newReviewExists) THEN
    IF (l_displayAttachment = 'N') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_ATTACHMENTS_RG',
	                   'N', 'N', null);
    END IF;
    IF (l_newAddressExists) THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
				    'Y', 'N', l_newAddressRegionCode);
    END IF;
    IF (l_enableTemplate = 'N') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_PROB_DETAILS',
				    'N', 'N', null);
    END IF;
  END IF;

  IF (l_newContactInfoExists) THEN
    IF (l_newAddressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newContactInfoRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
	                   'Y', 'N', l_newAddressRegionCode);
    END IF;
    IF (l_newPrimaryContactExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newContactInfoRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
	                   'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
  END IF;
  --For update service request flows, clone required regions
  IF (l_newUpdateAddressExists) THEN

    -- need to clone the IBU_CF_SR_DTL_CONTACT region
    l_newDtlContactAddrRegionCode := 'IBU_CF_SR_210_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_210_G',
  							672,
  							l_newDtlContactAddrRegionCode,
  							672, TRUE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlContactAddrRegionCode,
  				    'IBU_CF_SR_ADDRESS_RG',
  	                   'Y', 'N', l_newUpdateAddressRegionCode);

    l_newDtlContactAddrExists := TRUE;
  END IF;

  IF (l_newDtlProgressOptionsExists) THEN
    -- We must clone IBU_CF_SR_DTL_PROGRESS
    l_newDtlProgressRegionCode := 'IBU_CF_SR_120_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_120_G',
							672,
							l_newDtlProgressRegionCode,
							672, TRUE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlProgressRegionCode,
				    'IBU_CF_SR_DTL_PROGRESS_OPT_RG',
	                   'Y', 'N', l_newDtlProgOptionsRegionCode);
    l_newDtlProgressExists := TRUE;
  END IF;

  IF (l_newDtlProgressExists OR l_newDtlResolnExists) THEN
    -- if any of these regions are cloned, then we
    -- must clone IBU_CF_SR_DTL_OVERVIEW
    l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_GC';

      IF NOT (l_newDtlOverviewExists) THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_130_G',
                                        672,
                                        l_newDtlOverviewRegionCode,
                                        672, TRUE);
      END IF;
      IF (l_newUpdateAddressExists) THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
      				    'IBU_CF_SR_ADDRESS_RG',
      	                   'N', 'N', l_newUpdateAddressRegionCode);
      END IF;
      IF (l_newDtlProgressExists) THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
				    'IBU_CF_SR_DTL_PROGRESS_RG',
	                   'Y', 'N', l_newDtlProgressRegionCode);
      END IF;
      IF (l_newDtlResolnExists AND l_displayTasks = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
				    'IBU_CF_SR_DTL_ACTS_RG',
	                   'Y', 'N', null);
      END IF;
      l_newDtlOverviewExists := TRUE;
  END IF;


  IF (l_newDtlOverviewExists OR l_newDtlResolnExists) THEN
    -- then we must clone IBU_CF_SR_DTL_TABS
    l_newDtlTabsRegionCode := 'IBU_CF_SR_160_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_160_G',
							672,
							l_newDtlTabsRegionCode,
							672, TRUE);
    IF (l_newDtlOverviewExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlTabsRegionCode,
				    'IBU_CF_SR_DTL_OVERVIEW_TAB_RG',
	                   'Y', 'N', l_newDtlOverviewRegionCode);
    END IF;
    IF (l_newDtlResolnExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlTabsRegionCode,
  			         'IBU_CF_SR_DTL_RESOLN_TAB_RG',
	                   'N', 'N', l_newDtlResolnRegionCode);
    END IF;
    l_newDtlTabsExists := TRUE;
  END IF;

  IF (l_newDtlTabsExists) THEN
    -- then we must clone IBU_CF_SR_DETAILS
    l_newDtlDetailsRegionCode := 'IBU_CF_SR_190_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_190_G',
							672,
							l_newDtlDetailsRegionCode,
							672, TRUE);
    IF (l_newDtlDetailsExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlDetailsRegionCode,
				    'IBU_CF_SR_DTL_TABS_RG',
	                   'Y', 'N', l_newDtlTabsRegionCode);
    END IF;
    l_newDtlDetailsExists := TRUE;
  END IF;

  -- Now check for the Templates

  IF (l_newTemplateProductExists) THEN
    l_newCreateTemplateRegionCode := 'IBU_CF_SR_310_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_310_G',
							672,
							l_newCreateTemplateRegionCode,
							672, TRUE);
    --IF (l_newPrimaryContactExists) THEN
    --  CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateTemplateRegionCode,
    --				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
    --	                   'Y', 'N', l_newPrimaryContactRegionCode);
    --END IF;
    --IF (l_newTemplateProductExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateTemplateRegionCode,
				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
	                   'Y', 'N', l_newTemplateProductRegionCode);
    --END IF;
    l_newCreateTemplateExists := TRUE;
    l_newUpdateTemplateRegionCode := 'IBU_CF_SR_320_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_320_G',
							672,
							l_newUpdateTemplateRegionCode,
							672, TRUE);
    --IF (l_newPrimaryContactExists) THEN
    --  CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateTemplateRegionCode,
    --				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
    --	                   'Y', 'N', l_newPrimaryContactRegionCode);
    --END IF;
    --IF (l_newTemplateProductExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateTemplateRegionCode,
				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
	                   'Y', 'N', l_newTemplateProductRegionCode);
    --END IF;
    l_newUpdateTemplateExists := TRUE;
  END IF;


  IF (l_newProductFilterExists) THEN
    -- need to clone IBU_CF_SR_VW_FILTER
    l_newFilterRegionCode := 'IBU_CF_SR_410_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_410_G',
							672,
							l_newFilterRegionCode,
							672, TRUE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newFilterRegionCode,
				    'IBU_CF_SR_VW_PRODUCT_FILTER_RG',
	                   'Y', 'N', l_newProductFilterRegionCode);

    l_newFilterExists := TRUE;
  END IF;

  IF (l_newFilterExists) THEN
    -- need to clone IBU_CF_SR_VW_SEARCH, IBU_CF_SR_VW_CREATE, IBU_CF_SR_VW_UPDATE
    l_newSearchViewRegionCode := 'IBU_CF_SR_450_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_450_G',
						672,
							l_newSearchViewRegionCode,
							672, TRUE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newSearchViewRegionCode,
				    'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newSearchViewExists := TRUE;

    l_newCreateViewRegionCode := 'IBU_CF_SR_430_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_430_G',
							672,
							l_newCreateViewRegionCode,
							672, TRUE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateViewRegionCode,
				    'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newCreateViewExists := TRUE;

    l_newUpdateViewRegionCode := 'IBU_CF_SR_440_GC' ;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_440_G',
							672,
							l_newUpdateViewRegionCode,
							672, TRUE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateViewRegionCode,
				    'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newUpdateViewExists := TRUE;
  END IF;

  -- Now enter the rows in the cs_cf_source_cxt_targets table
  -- for this responsibility

  IF (l_newIdentifyProblemExists ) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
	   'IBU_SR_CR_IDENTIFY_PROBLEM',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newIdentifyProblemRegionCode,
        '672');
  END IF;

  IF (l_newReviewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_REVIEW',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newReviewRegionCode,
        '672');
  END IF;

  IF (l_newProblemDetailsExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_PROBLEM_DETAILS',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newProblemDetailsRegionCode,
        '672');
  END IF;


  IF (l_newContactInfoExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_CONTACT_INFORMATION',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newContactInfoRegionCode,
        '672');
  END IF;

  IF (l_newDtlDetailsExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_DETAILS',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newDtlDetailsRegionCode,
        '672');
  END IF;

  IF (l_newCreateTemplateExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_TEMP_CREATE',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newCreateTemplateRegionCode,
        '672');
  END IF;

  IF (l_newUpdateTemplateExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_TEMP_UPDATE',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newUpdateTemplateRegionCode,
        '672');
  END IF;

  IF (l_newSearchViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_SUMMARY',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newSearchViewRegionCode,
        '672');
  END IF;

  IF (l_newCreateViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_CREATE',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newCreateViewRegionCode,
        '672');
  END IF;

  IF (l_newUpdateViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_UPDATE',
	   'GLOBAL',
	   NULL,
	   NULL,
	   NULL,
	   NULL,
        l_newUpdateViewRegionCode,
        '672');
  END IF;

END Clone_Regions_For_Global;



/*
 * Perform the actually cloning
 * of ak regions, based on the list of
 * profiles that are customized at the appl level
 */
PROCEDURE Clone_Regions_For_Appl(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
						   p_ApplId IN NUMBER)
IS
  l_count NUMBER := p_ProfileTable.COUNT;
  l_index NUMBER := 0;
  l_profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_profileOptionValue FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
  l_newPrimaryContactRegionCode VARCHAR2(30) := 'IBU_CF_SR_10_G';
  l_newAddressRegionCode VARCHAR2(30) := 'IBU_CF_SR_20_G';
  l_newUpdateAddressRegionCode VARCHAR2(30) := 'IBU_CF_SR_25_G';
  l_newIdentifyProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_30_G';
  l_newTemplateProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_35_G';
  l_newIdentifyProblemRegionCode VARCHAR2(30) := 'IBU_CF_SR_40_G';
  l_newReviewRegionCode VARCHAR2(30) := 'IBU_CF_SR_50_G';
  l_newProblemDetailsRegionCode VARCHAR2(30) := 'IBU_CF_SR_60_G';
  l_newContactInfoRegionCode VARCHAR2(30) := 'IBU_CF_SR_70_G';
  l_newDtlOverviewRegionCode VARCHAR2(30) := 'IBU_CF_SR_130_G';
  l_newDtlContactAddrRegionCode VARCHAR2(30) := 'IBU_CF_SR_210_G';
  l_newDtlTabsRegionCode VARCHAR2(30) := 'IBU_CF_SR_160_G';
  l_newDtlDetailsRegionCode VARCHAR2(30) := 'IBU_CF_SR_190_G';
  l_newDtlProgOptionsRegionCode VARCHAR2(30) := 'IBU_CF_SR_110_G';
  l_newDtlProgressRegionCode VARCHAR2(30) := 'IBU_CF_SR_120_G';
  l_newDtlResolnRegionCode VARCHAR2(30) := 'IBU_CF_SR_150_G';
  l_newCreateTemplateRegionCode VARCHAR2(30) := 'IBU_CF_SR_310_G';
  l_newUpdateTemplateRegionCode VARCHAR2(30) := 'IBU_CF_SR_320_G';
  l_newCreateViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_430_G';
  l_newUpdateViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_440_G';
  l_newSearchViewRegionCode VARCHAR2(30) := 'IBU_CF_SR_450_G';
  l_newProductFilterRegionCode VARCHAR2(30) := 'IBU_CF_SR_420_G';
  l_newRegProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_80_G';
  l_newAllProductRegionCode VARCHAR2(30) := 'IBU_CF_SR_90_G';
  l_newFilterRegionCode VARCHAR2(30) := 'IBU_CF_SR_410_G';

  l_displayBillToAddress FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayBillToContact FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayShipToAddress FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayShipToContact FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayInstalledAtAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayIncidentAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_mandatoryIncidentAddr FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := 'N';
  l_displayAttachment FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayRegProducts FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayAllProducts FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_enableTemplate FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_displayTasks FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';
  l_mandatoryProblemCode FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';


  l_region_count NUMBER := 0;

  l_ApplId VARCHAR2(10) := to_char(p_ApplId);

  l_newIdentifyProblemExists BOOLEAN := FALSE;
  l_newPrimaryContactExists BOOLEAN := FALSE;
  l_newProblemDetailsExists BOOLEAN := FALSE;
  l_newAddressExists BOOLEAN := FALSE;
  l_newUpdateAddressExists BOOLEAN := FALSE;
  l_newContactInfoExists BOOLEAN := FALSE;
  l_newReviewExists BOOLEAN := FALSE;
  l_newDtlOverviewExists BOOLEAN := FALSE;
  l_newDtlContactAddrExists BOOLEAN := FALSE;
  l_newDtlTabsExists BOOLEAN := FALSE;
  l_newDtlProgressOptionsExists BOOLEAN := FALSE;
  l_newDtlResolnExists BOOLEAN := FALSE;
  l_newDtlDetailsExists BOOLEAN := FALSE;
  l_newDtlProgressExists BOOLEAN := FALSE;
  l_newIdentifyProductExists BOOLEAN := FALSE;
  l_newTemplateProductExists BOOLEAN := FALSE;
  l_newCreateTemplateExists BOOLEAN := FALSE;
  l_newUpdateTemplateExists BOOLEAN := FALSE;
  l_newProductFilterExists BOOLEAN := FALSE;
  l_newCreateViewExists BOOLEAN := FALSE;
  l_newUpdateViewExists BOOLEAN := FALSE;
  l_newSearchViewExists BOOLEAN := FALSE;
  l_newRegProductExists BOOLEAN := FALSE;
  l_newAllProductExists BOOLEAN := FALSE;
  l_newFilterExists BOOLEAN := FALSE;

  -- the following set of variables are used to
  -- determine whether we've already examined
  -- the profile option. If we have, we don't need to look at it again
  l_examineSrAccountOption BOOLEAN := TRUE;
  l_examineAddressOption BOOLEAN := TRUE;
  l_examineCreateProdOption BOOLEAN := TRUE;
  l_examineAttachmentOption BOOLEAN := TRUE;
  l_examineTemplateOption BOOLEAN := TRUE;
  l_examineLoggingOption BOOLEAN := TRUE;
  l_examineTaskOption BOOLEAN := TRUE;
  l_examineProdSelectOption BOOLEAN := TRUE;
  l_examineProbCodeOption BOOLEAN := TRUE;

BEGIN

  CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Cloning regions for ApplId: ' || l_ApplId);
  WHILE (l_index < l_count) LOOP
    l_profileOptionName := p_ProfileTable(l_index).profileOptionName;
    l_profileOptionValue := p_ProfileTable(l_index).profileOptionValue;

    IF (l_profileOptionName = 'IBU_A_SR_ACCOUNT_OPTION' AND l_examineSrAccountOption) THEN
      -- clone the region
      l_newPrimaryContactRegionCode := 'IBU_CF_SR_10_A' || p_ApplId;

      -- the region doesn't already exist, so go ahead and create it
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_10_G',
                                       672,
                                       l_newPrimaryContactRegionCode,
                                       672, FALSE);

      IF (l_profileOptionValue = 'OPTIONAL') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newPrimaryContactRegionCode,
                                              'IBU_CF_SR_ACCOUNT_NUMBER',
                                              'Y', 'N', null);

      END IF;
      l_examineSrAccountOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Done with SR Account Option');
    ELSIF (l_profileOptionName = 'IBU_A_SR_PRODUCT_SELECTION_OPTION' AND l_examineProdSelectOption) THEN
      -- clone the regions
      l_newRegProductRegionCode := 'IBU_CF_SR_80_A' || p_ApplId;

      -- the region doesn't already exist, so go ahead and create it
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_80_G',
                                       672,
                                       l_newRegProductRegionCode,
                                       672, FALSE);

      IF (l_profileOptionValue = 'N') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newRegProductRegionCode,
                                              'IBU_CF_SR_R_PROD_NAME_LOV',
                                              'Y', 'N', null);

      END IF;
      l_newAllProductRegionCode := 'IBU_CF_SR_90_A' || p_ApplId;
      -- the region doesn't already exist, so go ahead and create it
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_90_G',
                                       672,
                                       l_newAllProductRegionCode,
                                       672, FALSE);

      IF (l_profileOptionValue = 'N') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAllProductRegionCode,
                                              'IBU_CF_SR_PROD_BY_NAME_LOV',
                                              'Y', 'N', null);

      END IF;
      l_examineProdSelectOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Done with SR Product Selection Option');
    ELSIF ((l_profileOptionName = 'IBU_A_SR_BILLTO_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_BILLTO_CONTACT_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_SHIPTO_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_SHIPTO_CONTACT_OPTION' OR
		 l_profileOptionName = 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION' OR
		 l_profileOptionName = 'IBU_SR_ADDR_DISPLAY' OR
		 l_profileOptionName = 'IBU_SR_ADDR_MANDATORY') AND
		 l_examineAddressOption) THEN

      -- we only want to clone the address region once if any of the
       -- address profile options are customized.

      l_newAddressRegionCode := 'IBU_CF_SR_20_A' || p_ApplId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_20_G',
							672,
							l_newAddressRegionCode,
							672,FALSE);

      l_newUpdateAddressRegionCode := 'IBU_CF_SR_25_A' || p_ApplId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_25_G',
							672,
							l_newUpdateAddressRegionCode,
							672,FALSE);

      -- get all the address-specific profile option values
      -- for this resp

      CS_CF_UPG_UTL_PKG.getAddressProfileValues(p_ProfileTable,
				  l_displayBillToAddress,
				  l_displayBillToContact,
				  l_displayShipToAddress,
				  l_displayShipToContact,
				  l_displayInstalledAtAddr,
				  l_displayIncidentAddr,
				  l_mandatoryIncidentAddr);

      IF (l_displayBillToAddress = 'Y' OR l_displayBillToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
					'IBU_CF_SR_BILL_TO_HDR',
                                        'Y', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
					'IBU_CF_SR_BILL_TO_HDR',
                                        'Y', 'N', null);

      END IF;

      IF (l_displayBillToAddress = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_BILL_TO_ADDRESS',
						l_displayBillToAddress, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_BILL_TO_ADDRESS',
						l_displayBillToAddress, 'N', null);

      END IF;

      IF (l_displayBillToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_BILL_TO_CONTACT',
						l_displayBillToContact, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_BILL_TO_CONTACT',
						l_displayBillToContact, 'N', null);


      END IF;

      IF (l_displayShipToAddress = 'Y' OR l_displayShipToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_SHIP_TO_HDR',
						'Y', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_SHIP_TO_HDR',
						'Y', 'N', null);

      END IF;

      IF (l_displayShipToAddress = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                              'IBU_CF_SR_SHIP_TO_ADDRESS',
						l_displayShipToAddress, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                              'IBU_CF_SR_SHIP_TO_ADDRESS',
						l_displayShipToAddress, 'N', null);

      END IF;

      IF (l_displayShipToContact = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_SHIP_TO_CONTACT',
						l_displayShipToContact, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_SHIP_TO_CONTACT',
						l_displayShipToContact, 'N', null);

      END IF;

      IF (l_displayInstalledAtAddr = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_INSTALLED_AT_HDR',
						'Y', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_INSTALLED_AT_HDR',
						'Y', 'N', null);


        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_INSTALL_AT_ADDR',
						l_displayInstalledAtAddr, 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_INSTALL_AT_ADDR',
						l_displayInstalledAtAddr, 'N', null);


      END IF;

      -- Now we take care of the case for the incident address
      -- Note that we do not take care of the case where
      -- display addr = N but mandatory addr = Y, because it
      -- doesn't make sense
      IF (l_displayIncidentAddr = 'Y' AND l_mandatoryIncidentAddr = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);
        -- we update the update address region, but can ignore the mandatory flag
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);

      ELSIF (l_displayIncidentAddr = 'Y' AND l_mandatoryIncidentAddr = 'N') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
                              'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
                              'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_CITY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_STATE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'Y', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'Y', 'N', null);

      ELSIF (l_displayIncidentAddr = 'N' AND l_mandatoryIncidentAddr = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
					'IBU_CF_SR_INCIDENT_ADDRESS_HDR',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_ADDRESS',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_CITY',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_STATE',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_PROVINCE',
						'N', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_POSTAL_CODE',
						'N', 'N', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTRY',
						'N', 'Y', null);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newAddressRegionCode,
						'IBU_CF_SR_COUNTY',
						'N', 'N', null);

      END IF;
      l_examineAddressOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Done with Address Options');

    ELSIF (l_profileOptionName = 'IBU_SR_CREATION_PRODUCT_OPTION' AND l_examineCreateProdOption) THEN
      -- mkcyee 12/14/2004 - This profile also impacts the product region for
      -- Templates, so we need to clone that region as well.

      l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_A' || p_ApplId;
      l_newTemplateProductRegionCode := 'IBU_CF_SR_35_A' || p_ApplId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_30_G',
                                     672,
                                     l_newIdentifyProductRegionCode,
                                     672,FALSE);

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_35_G',
                                     672,
                                     l_newTemplateProductRegionCode,
                                     672, FALSE);

      IF (l_profileOptionValue = 'USE_ONLY_INSTALLBASE_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);


      ELSIF (l_profileOptionValue = 'USE_ONLY_INVENTORY_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
				   'IBU_CF_SR_REG_PRODUCT_RG',
					   'N', 'N', null);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
				   'IBU_CF_SR_REG_PRODUCT_RG',
					   'N', 'N', null);
      END IF;
      l_newProductFilterRegionCode := 'IBU_CF_SR_420_A' || p_ApplId;

      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_420_G',
                                     672,
                                     l_newProductFilterRegionCode,
                                     672, FALSE);
      IF (l_profileOptionValue = 'USE_ONLY_INSTALLBASE_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
					   'IBU_CF_SR_ALL_PRODUCT_RG',
					   'N', 'N', null);

      ELSIF (l_profileOptionValue = 'USE_ONLY_INVENTORY_PRODUCT') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
					   'IBU_CF_SR_REG_PRODUCT_RG',
					   'N', 'N', null);
      END IF;
      l_examineCreateProdOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Done with Creation Product Option');
    ELSIF ((l_profileOptionName = 'IBU_A_SR_ATTACHMENT_OPTION' AND l_examineAttachmentOption) OR (l_profileOptionName = 'IBU_A_SR_PROB_CODE_MANDATORY' and l_examineProbCodeOption)) THEN
      l_newIdentifyProblemRegionCode := 'IBU_CF_SR_40_A' || p_ApplId;

      CS_CF_UPG_UTL_PKG.getAttachmentProbCodeValues(p_ProfileTable,
                                                         l_displayAttachment,
                                                         l_mandatoryProblemCode);

      IF (l_displayAttachment = 'DONOTSHOW' OR l_displayAttachment = 'SHOWDURINGUPDATE' OR l_mandatoryProblemCode = 'Y') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_40_G',
                                       672,
                                       l_newIdentifyProblemRegionCode,
                                       672, FALSE);
        IF (l_displayAttachment = 'DONOTSHOW') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
					   'N', 'N', null);
        ELSIF (l_displayAttachment = 'SHOWDURINGUPDATE') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
					   'N', 'N', null);
        ELSIF (l_mandatoryProblemCode = 'Y') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
                            'IBU_CF_SR_PROB_TYPE_CODE',
					   'Y', 'Y', null);

        END IF;
      END IF;
      l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_A' || p_ApplId;
      IF (l_displayAttachment = 'DONOTSHOW' OR l_displayAttachment = 'SHOWDURINGCREATE') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_130_G',
                                       672,
                                       l_newDtlOverviewRegionCode,
                                       672, FALSE);

        IF (l_displayAttachment = 'DONOTSHOW') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
					   'N', 'N', null);
        ELSIF (l_displayAttachment = 'SHOWDURINGCREATE') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
                            'IBU_CF_SR_ATTACHMENTS_RG',
					   'N', 'N', null);
        END IF;
      END IF;
      l_examineAttachmentOption := FALSE;
      l_examineProbCodeOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Done with Attachment Option and Mandatory Problem Code' );
    ELSIF (l_profileOptionName = 'IBU_SR_ENABLE_TEMPLATE' AND l_examineTemplateOption) THEN
      l_newProblemDetailsRegionCode := 'IBU_CF_SR_60_A' || p_ApplId;
      IF (l_profileOptionName = 'N') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_60_G',
                                       672,
                                       l_newProblemDetailsRegionCode,
                                       672, FALSE);

        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
                            'IBU_CF_SR_PROB_DETAILS',
					   'N', 'N', null);
      END IF;
      l_examineTemplateOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Done with Template Option');

    ELSIF (l_profileOptionName = 'IBU_A_SR_ENABLE_INTERACTION_LOGGING' AND l_examineLoggingOption) THEN
      l_newDtlProgOptionsRegionCode := 'IBU_CF_SR_110_A' || p_ApplId;
      CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_110_G',
							672,
							l_newDtlProgOptionsRegionCode,
						     672, FALSE);
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlProgOptionsRegionCode,
                            'IBU_CF_SR_DTL_PROGRESS_INTRCT',
					   'Y', 'N', null);
      l_examineLoggingOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Done with Interaction Logging Option');
    ELSIF (l_profileOptionName = 'IBU_SR_TASK_DISPLAY' AND l_examineTaskOption) THEN
      l_newDtlResolnRegionCode := 'IBU_CF_SR_150_A' || p_ApplId;
      IF (l_profileOptionValue = 'Y') THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_150_G',
							672,
							l_newDtlResolnRegionCode,
						     672, FALSE);
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlResolnRegionCode,
                            'IBU_CF_SR_DTL_ACTS_RG',
					   'Y', 'N', null);
      END IF;
      l_examineTaskOption := FALSE;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Regions_For_Appl', 'Done with Task Display Option');
    END IF; -- end profile checks
    l_index := l_index + 1;
  END LOOP; -- end while loop

  -- Check whether a region has already been cloned for
  -- Primary Contact sub region
  l_newPrimaryContactRegionCode := 'IBU_CF_SR_10_A' || p_ApplId;
  OPEN does_region_already_exists(l_newPrimaryContactRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newPrimaryContactExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Reg Product sub region
  l_newRegProductRegionCode := 'IBU_CF_SR_80_A' || p_ApplId;
  OPEN does_region_already_exists(l_newRegProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newRegProductExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- All Product sub region
  l_newAllProductRegionCode := 'IBU_CF_SR_90_A' || p_ApplId;
  OPEN does_region_already_exists(l_newAllProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newAllProductExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Identify Product sub region
  l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_A' || p_ApplId;
  OPEN does_region_already_exists(l_newIdentifyProductRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newIdentifyProductExists := TRUE;
    select node_display_flag INTO
    l_displayRegProducts
    from ak_region_items
    where region_code = l_newIdentifyProductRegionCode
    and attribute_code = 'IBU_CF_SR_REG_PRODUCT_RG'
    and region_application_id = 672
    and attribute_application_id = 672;

    select node_display_flag INTO
    l_displayAllProducts
    from ak_region_items
    where region_code = l_newIdentifyProductRegionCode
    and attribute_code = 'IBU_CF_SR_ALL_PRODUCT_RG'
    and region_application_id = 672
    and attribute_application_id = 672;
  END IF;

  IF (l_newIdentifyProductExists) THEN
    l_newTemplateProductExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for Product Filter
  l_newProductFilterRegionCode := 'IBU_CF_SR_420_A' || p_ApplId;
  OPEN does_region_already_exists(l_newProductFilterRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newProductFilterExists := TRUE;
  END IF;


  -- Check whether a region has been cloned for addresses
  l_newAddressRegionCode := 'IBU_CF_SR_20_A' || p_ApplId;
  OPEN does_region_already_exists(l_newAddressRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newAddressExists := TRUE;
  END IF;

  l_newUpdateAddressRegionCode := 'IBU_CF_SR_25_A' || p_ApplId;
  OPEN does_region_already_exists(l_newUpdateAddressRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newUpdateAddressExists := TRUE;
  END IF;

  -- Check cloned subregions for Create Service Request flows

  -- Check whether a region has already been
  -- cloned for Identify Problem
  l_newIdentifyProblemRegionCode := 'IBU_CF_SR_40_A' || p_ApplId;
  OPEN does_region_already_exists(l_newIdentifyProblemRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newIdentifyProblemExists := TRUE;

    select node_display_flag INTO
    l_displayAttachment
    from ak_region_items
    where region_code = l_newIdentifyProblemRegionCode
    and attribute_code = 'IBU_CF_SR_ATTACHMENTS_RG'
    and region_application_id = 672
    and attribute_application_id = 672;

  ELSIF (l_newPrimaryContactExists OR l_newIdentifyProductExists OR l_newAddressExists) THEN
    -- mkcyee 12/07/04 - new Address region has been added to Identify
    -- Problem page, so we need to clone this region is Address region
    -- has been cloned

    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_40_G',
							672,
							l_newIdentifyProblemRegionCode,
							672, FALSE);
    l_newIdentifyProblemExists := TRUE;
  END IF;

  -- Check whether a region has already been cloned for
  -- Problem Details
  l_newProblemDetailsRegionCode := 'IBU_CF_SR_60_A' || p_ApplId;
  OPEN does_region_already_exists(l_newProblemDetailsRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newProblemDetailsExists := TRUE;

    select node_display_flag INTO
    l_enableTemplate
    from ak_region_items
    where region_code = l_newProblemDetailsRegionCode
    and attribute_code = 'IBU_CF_SR_PROB_DETAILS'
    and region_application_id = 672
    and attribute_application_id = 672;
  ELSIF (l_newPrimaryContactExists OR l_newAddressExists) THEN
    -- mkcyee 12/07/04 - new Address region has been added to Problem
    -- details page, so we need to clone this region is Address region
    -- has been cloned
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_60_G',
							672,
							l_newProblemDetailsRegionCode,
							672, FALSE);
    l_newProblemDetailsExists := TRUE;
  END IF;


  -- Check whether a region has already been cloned for
  -- Update Overview sub region
  l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_A' || p_ApplId;
  OPEN does_region_already_exists(l_newDtlOverviewRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlOverviewExists := TRUE;
  END IF;


  -- Check whether a region has been cloned for Contact Info
  l_newContactInfoRegionCode := 'IBU_CF_SR_70_A' || p_ApplId;
  IF (l_newPrimaryContactExists OR l_newAddressExists) THEN
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_70_G',
                                   672,
                                   l_newContactInfoRegionCode,
                                   672, FALSE);
    l_newContactInfoExists := TRUE;
  END IF;

  l_newReviewRegionCode := 'IBU_CF_SR_50_A' || p_ApplId;
  IF (l_newAddressExists OR l_enableTemplate = 'N' OR
	   l_displayAttachment='N') THEN
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_50_G',
							672,
							l_newReviewRegionCode,
							672, FALSE);

    l_newReviewExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for progress options
  l_newDtlProgOptionsRegionCode := 'IBU_CF_SR_110_A' || p_ApplId;
  OPEN does_region_already_exists(l_newDtlProgOptionsRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlProgressOptionsExists := TRUE;
  END IF;

  -- Check whether a region has been cloned for IBU_CF_SR_DTL_RESOLN
  l_newDtlResolnRegionCode := 'IBU_CF_SR_150_A' || p_ApplId;
  OPEN does_region_already_exists(l_newDtlResolnRegionCode, 672);
  FETCH does_region_already_exists INTO l_region_count;
  CLOSE does_region_already_exists;

  IF (l_region_count > 0) THEN
    l_newDtlResolnExists := TRUE;
    select node_display_flag INTO
    l_displayTasks
    from ak_region_items
    where region_code = l_newDtlResolnRegionCode
    and attribute_code = 'IBU_CF_SR_DTL_ACTS_RG'
    and region_application_id = 672
    and attribute_application_id = 672;
  END IF;

  -- If regions that were created impact other regions,
  -- make sure to set them to the proper region code.
  -- For some cases, we may have to clone new regions


  IF (l_newAllProductExists AND l_newRegProductExists) THEN
    IF NOT(l_newIdentifyProductExists) THEN
      -- need to clone the IBU_CF_SR_IDENTIFY_PRODUCT region
      l_newIdentifyProductRegionCode := 'IBU_CF_SR_30_A' || p_ApplId;
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_30_G',
                                     672,
                                     l_newIdentifyProductRegionCode,
                                     672, FALSE);
        l_newIdentifyProductExists := TRUE;
        IF (l_displayRegProducts = '') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
                                    'IBU_CF_SR_REG_PRODUCT_RG',
                                    'Y', 'N', l_newRegProductRegionCode);
        ELSE
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
                                    'IBU_CF_SR_REG_PRODUCT_RG',
                                    l_displayRegProducts, 'N', l_newRegProductRegionCode);
        END IF;
        IF (l_displayAllProducts = '') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
                                    'IBU_CF_SR_ALL_PRODUCT_RG',
                                    'Y', 'N', l_newAllProductRegionCode);
        ELSE
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProductRegionCode,
                                    'IBU_CF_SR_ALL_PRODUCT_RG',
                                    l_displayAllProducts, 'N', l_newAllProductRegionCode);
        END IF;
    END IF;
  END IF;
  IF (l_displayRegProducts = 'N' OR l_displayAllProducts = 'N') THEN
    IF NOT(l_newTemplateProductExists) THEN
      -- need to clone the IBU_CF_SR_IDENTIFY_PRODUCT region for Templates
      l_newTemplateProductRegionCode := 'IBU_CF_SR_35_A' || p_ApplId;
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_35_G',
                                     672,
                                     l_newTemplateProductRegionCode,
                                     672, FALSE);
        l_newTemplateProductExists := TRUE;
        IF (l_displayRegProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
                                    'IBU_CF_SR_REG_PRODUCT_RG',
                                    'N', 'N', 'IBU_CF_SR_REG_PRODUCT');
        END IF;
        IF (l_displayAllProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newTemplateProductRegionCode,
                                    'IBU_CF_SR_ALL_PRODUCT_RG',
                                    'N', 'N', 'IBU_CF_SR_ALL_PRODUCT');
        END IF;
    END IF;
    IF NOT(l_newProductFilterExists) THEN
      -- need to clone the IBU_CF_SR_VW_PRODUCT_FILTER region
      l_newProductFilterRegionCode := 'IBU_CF_SR_420_A' || p_ApplId;
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_420_G',
                                     672,
                                     l_newProductFilterRegionCode,
                                     672, FALSE);
        l_newProductFilterExists := TRUE;
        IF (l_displayRegProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
                                    'IBU_CF_SR_REG_PRODUCT_RG',
                                    'N', 'N', 'IBU_CF_SR_REG_PRODUCT');
        END IF;
        IF (l_displayAllProducts = 'N') THEN
          CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProductFilterRegionCode,
                                    'IBU_CF_SR_ALL_PRODUCT_RG',
                                    'N', 'N', 'IBU_CF_SR_ALL_PRODUCT');
        END IF;
    END IF;
  END IF;

  IF (l_newIdentifyProblemExists) THEN
    IF (l_newPrimaryContactExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
				    'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
    IF (l_newIdentifyProductExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
				    'Y', 'N', l_newIdentifyProductRegionCode);

    END IF;
    IF (l_newAddressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
				    'N', 'N', l_newAddressRegionCode);
    END IF;
  END IF;

  IF (l_newProblemDetailsExists) THEN
    IF (l_newPrimaryContactExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
				    'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
    IF (l_displayAttachment = 'N') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newIdentifyProblemRegionCode,
				    'IBU_CF_SR_ATTACHMENTS_RG',
				    'N', 'N', null);
    END IF;

    -- mkcyee 12/07/2004 - the address region have been added in
    -- problem details and identify problem pages
    IF (l_newAddressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newProblemDetailsRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
				    'N', 'N', l_newAddressRegionCode);
    END IF;
  END IF;


  IF (l_newReviewExists) THEN
    IF (l_displayAttachment = 'N') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_ATTACHMENTS_RG',
	                   'N', 'N', null);
    END IF;
    IF (l_newAddressExists) THEN
	 CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
				    'Y', 'N', l_newAddressRegionCode);
    END IF;
    IF (l_enableTemplate = 'N') THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newReviewRegionCode,
				    'IBU_CF_SR_PROB_DETAILS',
				    'N', 'N', null);
    END IF;
  END IF;

  IF (l_newContactInfoExists) THEN
    IF (l_newAddressExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newContactInfoRegionCode,
				    'IBU_CF_SR_ADDRESS_RG',
	                   'Y', 'N', l_newAddressRegionCode);
    END IF;
    IF (l_newPrimaryContactExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newContactInfoRegionCode,
				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
	                   'Y', 'N', l_newPrimaryContactRegionCode);
    END IF;
  END IF;
  --For update service request flows, clone required regions
  IF (l_newUpdateAddressExists) THEN

    -- need to clone the IBU_CF_SR_DTL_CONTACT region
    l_newDtlContactAddrRegionCode := 'IBU_CF_SR_210_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_210_G',
  							672,
  							l_newDtlContactAddrRegionCode,
  							672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlContactAddrRegionCode,
  				    'IBU_CF_SR_ADDRESS_RG',
  	                   'Y', 'N', l_newUpdateAddressRegionCode);

    l_newDtlContactAddrExists := TRUE;
  END IF;

  IF (l_newDtlProgressOptionsExists) THEN
    -- We must clone IBU_CF_SR_DTL_PROGRESS
    l_newDtlProgressRegionCode := 'IBU_CF_SR_120_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_120_G',
							672,
							l_newDtlProgressRegionCode,
							672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlProgressRegionCode,
				    'IBU_CF_SR_DTL_PROGRESS_OPT_RG',
	                   'Y', 'N', l_newDtlProgOptionsRegionCode);
    l_newDtlProgressExists := TRUE;
  END IF;

  IF (l_newDtlProgressExists OR l_newDtlResolnExists) THEN
    -- if any of these regions are cloned, then we
    -- must clone IBU_CF_SR_DTL_OVERVIEW
    l_newDtlOverviewRegionCode := 'IBU_CF_SR_130_A' || p_ApplId;

      IF NOT (l_newDtlOverviewExists) THEN
        CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_130_G',
                                        672,
                                        l_newDtlOverviewRegionCode,
                                        672, FALSE);
      END IF;
      IF (l_newUpdateAddressExists) THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
      				    'IBU_CF_SR_ADDRESS_RG',
      	                   'N', 'N', l_newUpdateAddressRegionCode);
      END IF;
      IF (l_newDtlProgressExists) THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
				    'IBU_CF_SR_DTL_PROGRESS_RG',
	                   'Y', 'N', l_newDtlProgressRegionCode);
      END IF;
      IF (l_newDtlResolnExists AND l_displayTasks = 'Y') THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlOverviewRegionCode,
				    'IBU_CF_SR_DTL_ACTS_RG',
	                   'Y', 'N', null);
      END IF;
      l_newDtlOverviewExists := TRUE;
  END IF;


  IF (l_newDtlOverviewExists OR l_newDtlResolnExists) THEN
    -- then we must clone IBU_CF_SR_DTL_TABS
    l_newDtlTabsRegionCode := 'IBU_CF_SR_160_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_160_G',
							672,
							l_newDtlTabsRegionCode,
							672, FALSE);
    IF (l_newDtlOverviewExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlTabsRegionCode,
				    'IBU_CF_SR_DTL_OVERVIEW_TAB_RG',
	                   'Y', 'N', l_newDtlOverviewRegionCode);
    END IF;
    IF (l_newDtlResolnExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlTabsRegionCode,
  			         'IBU_CF_SR_DTL_RESOLN_TAB_RG',
	                   'N', 'N', l_newDtlResolnRegionCode);
    END IF;
    l_newDtlTabsExists := TRUE;
  END IF;

  IF (l_newDtlTabsExists) THEN
    -- then we must clone IBU_CF_SR_DETAILS
    l_newDtlDetailsRegionCode := 'IBU_CF_SR_190_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_190_G',
							672,
							l_newDtlDetailsRegionCode,
							672, FALSE);
    IF (l_newDtlDetailsExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newDtlDetailsRegionCode,
				    'IBU_CF_SR_DTL_TABS_RG',
	                   'Y', 'N', l_newDtlTabsRegionCode);
    END IF;
    l_newDtlDetailsExists := TRUE;
  END IF;

  -- Now check for the Templates

  -- mkcyee 12/14/2004 - use l_newTemplateProductExists
  -- because Templates and Search now have a separate product section

  IF (l_newTemplateProductExists) THEN
    l_newCreateTemplateRegionCode := 'IBU_CF_SR_310_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_310_G',
							672,
							l_newCreateTemplateRegionCode,
							672, FALSE);
    --IF (l_newPrimaryContactExists) THEN
    --  CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateTemplateRegionCode,
    --				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
    --	                   'Y', 'N', l_newPrimaryContactRegionCode);
    --END IF;
    --IF (l_newTemplateProductExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateTemplateRegionCode,
				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
	                   'Y', 'N', l_newTemplateProductRegionCode);
    --END IF;
    l_newCreateTemplateExists := TRUE;
    l_newUpdateTemplateRegionCode := 'IBU_CF_SR_320_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_320_G',
							672,
							l_newUpdateTemplateRegionCode,
							672, FALSE);
    --IF (l_newPrimaryContactExists) THEN
    --  CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateTemplateRegionCode,
    --				    'IBU_CF_SR_PRIMARY_CONTACT_RG',
    --	                   'Y', 'N', l_newPrimaryContactRegionCode);
    --END IF;
    --IF (l_newTemplateProductExists) THEN
      CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateTemplateRegionCode,
				    'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
	                   'Y', 'N', l_newTemplateProductRegionCode);
    --END IF;
    l_newUpdateTemplateExists := TRUE;
  END IF;


  IF (l_newProductFilterExists) THEN
    -- need to clone IBU_CF_SR_VW_FILTER
    l_newFilterRegionCode := 'IBU_CF_SR_410_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_410_G',
							672,
							l_newFilterRegionCode,
							672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newFilterRegionCode,
				    'IBU_CF_SR_VW_PRODUCT_FILTER_RG',
	                   'Y', 'N', l_newProductFilterRegionCode);

    l_newFilterExists := TRUE;
  END IF;

  IF (l_newFilterExists) THEN
    -- need to clone IBU_CF_SR_VW_SEARCH, IBU_CF_SR_VW_CREATE, IBU_CF_SR_VW_UPDATE
    l_newSearchViewRegionCode := 'IBU_CF_SR_450_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_450_G',
						672,
							l_newSearchViewRegionCode,
							672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newSearchViewRegionCode,
				    'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newSearchViewExists := TRUE;

    l_newCreateViewRegionCode := 'IBU_CF_SR_430_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_430_G',
							672,
							l_newCreateViewRegionCode,
							672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newCreateViewRegionCode,
				    'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newCreateViewExists := TRUE;

    l_newUpdateViewRegionCode := 'IBU_CF_SR_440_A' || p_ApplId;
    CS_CF_UPG_UTL_PKG.Clone_Region('IBU_CF_SR_440_G',
							672,
							l_newUpdateViewRegionCode,
							672, FALSE);
    CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newUpdateViewRegionCode,
				    'IBU_CF_SR_VW_FILTER_RG',
	                   'Y', 'N', l_newFilterRegionCode);

    l_newUpdateViewExists := TRUE;
  END IF;

  -- Now enter the rows in the cs_cf_source_cxt_targets table
  -- for this responsibility

  IF (l_newIdentifyProblemExists ) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
	   'IBU_SR_CR_IDENTIFY_PROBLEM',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newIdentifyProblemRegionCode,
        '672');
  END IF;

  IF (l_newReviewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_REVIEW',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newReviewRegionCode,
        '672');
  END IF;

  IF (l_newProblemDetailsExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_PROBLEM_DETAILS',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newProblemDetailsRegionCode,
        '672');
  END IF;


  IF (l_newContactInfoExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_CR_CONTACT_INFORMATION',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newContactInfoRegionCode,
        '672');
  END IF;

  IF (l_newDtlDetailsExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_DETAILS',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newDtlDetailsRegionCode,
        '672');
  END IF;

  IF (l_newCreateTemplateExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_TEMP_CREATE',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newCreateTemplateRegionCode,
        '672');
  END IF;

  IF (l_newUpdateTemplateExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_TEMP_UPDATE',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newUpdateTemplateRegionCode,
        '672');
  END IF;

  IF (l_newSearchViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_SUMMARY',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newSearchViewRegionCode,
        '672');
  END IF;

  IF (l_newCreateViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_CREATE',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newCreateViewRegionCode,
        '672');
  END IF;

  IF (l_newUpdateViewExists) THEN
    CS_CF_UPG_UTL_PKG.Insert_New_Target(
        'IBU_SR_VIEW_UPDATE',
	   'APPLICATION',
	   l_ApplId,
	   NULL,
	   NULL,
	   NULL,
        l_newUpdateViewRegionCode,
        '672');
  END IF;


END Clone_Regions_For_Appl;

/*
 * Top level procedure for performing flow
 * upgrades; Internally this will call
 * flow upgrades for each profile level, ie resp, application, etc
 */
PROCEDURE Do_Flow_Upgrade(p_respTable IN CS_CF_UPG_UTL_PKG.RespTable,
					 p_applTable IN CS_CF_UPG_UTL_PKG.ApplTable,
					 p_siteProfilesTable IN CS_CF_UPG_UTL_PKG.ProfileTable)
IS

BEGIN

  Do_Flow_Upgrades_For_Resp(p_respTable);
  Do_Flow_Upgrades_For_Appl(p_applTable);
  Do_Flow_Upgrades_For_Global(p_siteProfilesTable);

END Do_Flow_Upgrade;

/*
 * Procedure to performing flow upgrades for responsibility level
 * For each resp
 */
PROCEDURE Do_Flow_Upgrades_For_Resp(p_respTable IN CS_CF_UPG_UTL_PKG.RespTable)
IS

  -- this picks up all the configuration profiles
  -- that affects region configuration for
  -- a particular responsibility and it's corresponding
  -- higher application level and site level

  CURSOR get_profiles_for_resp (respId NUMBER, respApplId NUMBER)
  IS
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    1 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10003
  AND   b.level_value = respId
  AND   b.level_value_application_id = respApplId
  AND   a.profile_option_id = b.profile_option_id
  AND   b.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_KB_OPTION')
  UNION
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    2 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10002
  AND   b.level_value = respApplId
  AND   a.profile_option_id = b.profile_option_id
  AND   b.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_KB_OPTION')
  UNION
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    3 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10001
  AND   a.profile_option_id = b.profile_option_id
  AND   b.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_KB_OPTION')
  ORDER BY PROFILE_OPTION_NAME, PRIORITY;

  l_count NUMBER := p_respTable.COUNT;
  l_index NUMBER := 0;
  l_index2 NUMBER := 0;
  l_profile_option_name FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE;
  l_level_value_application_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
  l_priority NUMBER := 0;

  l_ProfileTable CS_CF_UPG_UTL_PKG.ProfileTable;

BEGIN

  CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG: Do_Flow_Upgrades_For_Resp', 'Processing Do_Flow_Upgrades_For_Resp');


  WHILE (l_index < l_count) LOOP
    -- Get the list of profile names and their values
    -- and store it in a table
    -- This table may contain duplicate entries for
    -- each profile because we pick up the values
    -- for the application and site level also
    OPEN get_profiles_for_resp(p_respTable(l_index).respId, p_respTable(l_index).respApplId);
      -- Retrieve information into the local variables
    FETCH get_profiles_for_resp INTO l_profile_option_name,
							    l_level_value,
							    l_level_value_application_id,
							    l_profile_option_value,
							    l_priority;
    WHILE get_profiles_for_resp%FOUND LOOP

      l_ProfileTable(l_index2).profileOptionName := l_profile_option_name;
	 l_ProfileTable(l_index2).profileOptionValue := l_profile_option_value;

	 l_index2 := l_index2 + 1;

      FETCH get_profiles_for_resp INTO l_profile_option_name,
							    l_level_value,
							    l_level_value_application_id,
							    l_profile_option_value,
							    l_priority;

    END LOOP;
    CLOSE get_profiles_for_resp;

    -- Now we have a table of profiles
    -- Determine which flows need to be cloned for this resp

    IF (CS_CF_UPG_UTL_PKG.Flows_Not_Already_Cloned(to_number(p_respTable(l_index).respId || p_respTable(l_index).respApplId))) THEN

      Clone_Flows_For_Resp(l_ProfileTable, p_respTable(l_index).respId,
                      p_respTable(l_index).respApplId);
    END IF;

    commit;
    -- now clean up the table so it can be reused
    l_ProfileTable.DELETE;
    l_index2 := 0;
    l_index := l_index + 1;

  END LOOP; -- ends while loop

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_PKG: Do_Flow_Upgrades_For_Resp', 'Exception in Do_Flow_Upgrades_For_Resp');
    IF (get_profiles_for_resp%ISOPEN) THEN
	 CLOSE get_profiles_for_resp;
    END IF;
    RAISE;

END Do_Flow_Upgrades_For_Resp;

/*
 * Perform the actually cloning
 * of flows, based on the list of
 * profiles that are customized at the resp level
 */
PROCEDURE Clone_Flows_For_Resp(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
				   p_respId IN FND_PROFILE_OPTION_VALUES.level_value%TYPE,
                       p_respApplId IN FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE)
IS
  l_count NUMBER := p_ProfileTable.COUNT;
  l_index NUMBER := 0;
  l_profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_profileOptionValue FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;

  l_respId VARCHAR2(10) := to_char(p_respId);
  l_respApplId VARCHAR2(10) := to_char(p_respApplId);


  -- the following set of variables are used to
  -- determine whether we've already examined
  -- the profile option. If we have, we don't need to look at it again
  l_examineKBOption BOOLEAN := TRUE;

BEGIN

  CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Flows_For_Resp', 'Setting flow for respId: ' || l_respId || ' respApplId: ' || l_respApplId);
  WHILE (l_index < l_count) LOOP
    l_profileOptionName := p_ProfileTable(l_index).profileOptionName;
    l_profileOptionValue := p_ProfileTable(l_index).profileOptionValue;

    IF (l_profileOptionName = 'IBU_A_SR_KB_OPTION' AND l_examineKBOption) THEN
      IF (l_profileOptionValue = 'SEARCH') THEN
        -- this resp will use the default flow seeded for 11510
        CS_CF_UPG_UTL_PKG.Clone_Flow(to_number(l_respId || l_respApplId), 10);
      ELSE
        -- this resp will use default flow seeded for 1159
        CS_CF_UPG_UTL_PKG.Clone_Flow(to_number(l_respId || l_respApplId), 20);

      END IF;

      CS_CF_UPG_UTL_PKG.Insert_New_Target('IBU_SR_CRE',
                                          'RESP',
                                          l_respId,
                                          l_respApplId,
                                          NULL,
                                          NULL,
                                          to_char((0-to_number(l_respId || l_respApplId))),
                                          'NULL');

      l_examineKBOption := FALSE;
    END IF;

    l_index := l_index + 1;
  END LOOP;
End Clone_Flows_For_Resp;

/*
 * Procedure to performing flow upgrades for application level
 */
PROCEDURE Do_Flow_Upgrades_For_Appl(p_applTable IN CS_CF_UPG_UTL_PKG.ApplTable)
IS

  -- this picks up all the configuration profiles
  -- that affects region configuration for
  -- a particular application and site level

  CURSOR get_profiles_for_appl (applId NUMBER)
  IS
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    1 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10002
  AND   b.level_value = applId
  AND   a.profile_option_id = b.profile_option_id
  AND   b.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_KB_OPTION')
  UNION
  SELECT a.profile_option_name,
	    b.level_value,
	    b.level_value_application_id,
	    b.profile_option_value,
	    2 "PRIORITY"
  FROM fnd_profile_option_values b, fnd_profile_options a
  WHERE b.level_id = 10001
  AND   a.profile_option_id = b.profile_option_id
  AND   b.application_id = 672
  AND  a.profile_option_name in ('IBU_A_SR_KB_OPTION')
  ORDER BY PROFILE_OPTION_NAME, PRIORITY;

  l_count NUMBER := p_applTable.COUNT;
  l_index NUMBER := 0;
  l_index2 NUMBER := 0;
  l_profile_option_name FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE;
  l_level_value_application_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
  l_priority NUMBER := 0;

  l_ProfileTable CS_CF_UPG_UTL_PKG.ProfileTable;

BEGIN

  CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG: Do_Flow_Upgrades_For_Appl', 'Processing Do_Flow_Upgrades_For_Appl');


  WHILE (l_index < l_count) LOOP
    -- Get the list of profile names and their values
    -- and store it in a table
    -- This table may contain duplicate entries for
    -- each profile because we pick up the values
    -- for the application and site level also
    OPEN get_profiles_for_appl(p_applTable(l_index));
      -- Retrieve information into the local variables
    FETCH get_profiles_for_appl INTO l_profile_option_name,
							    l_level_value,
							    l_level_value_application_id,
							    l_profile_option_value,
							    l_priority;
    WHILE get_profiles_for_appl%FOUND LOOP

      l_ProfileTable(l_index2).profileOptionName := l_profile_option_name;
	 l_ProfileTable(l_index2).profileOptionValue := l_profile_option_value;

	 l_index2 := l_index2 + 1;

      FETCH get_profiles_for_appl INTO l_profile_option_name,
							    l_level_value,
							    l_level_value_application_id,
							    l_profile_option_value,
							    l_priority;

    END LOOP;
    CLOSE get_profiles_for_appl;

    -- Now we have a table of profiles
    -- Determine which flows need to be set for this appl

    IF (CS_CF_UPG_UTL_PKG.Flows_Not_Already_Cloned(p_applTable(l_index))) THEN
      Clone_Flows_For_Appl(l_ProfileTable, p_applTable(l_index));
    END IF;
    commit;

    -- now clean up the table so it can be reused
    l_ProfileTable.DELETE;
    l_index2 := 0;
    l_index := l_index + 1;

  END LOOP; -- ends while loop

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_PKG: Do_Flow_Upgrades_For_Appl', 'Exception in Do_Flow_Upgrades_For_Appl');
    IF (get_profiles_for_appl%ISOPEN) THEN
	 CLOSE get_profiles_for_appl;
    END IF;
    RAISE;

END Do_Flow_Upgrades_For_Appl;

/*
 * Perform the actually cloning
 * of flows, based on the list of
 * profiles that are customized at the application level
 */
PROCEDURE Clone_Flows_For_Appl(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
				   p_applId IN NUMBER)
IS
  l_count NUMBER := p_ProfileTable.COUNT;
  l_index NUMBER := 0;
  l_profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_profileOptionValue FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;

  l_applId VARCHAR2(10) := to_char(p_applId);


  -- the following set of variables are used to
  -- determine whether we've already examined
  -- the profile option. If we have, we don't need to look at it again
  l_examineKBOption BOOLEAN := TRUE;

BEGIN

  CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Clone_Flows_For_Appl', 'Setting flow for applId: ' || l_applId );
  WHILE (l_index < l_count) LOOP
    l_profileOptionName := p_ProfileTable(l_index).profileOptionName;
    l_profileOptionValue := p_ProfileTable(l_index).profileOptionValue;

    IF (l_profileOptionName = 'IBU_A_SR_KB_OPTION' AND l_examineKBOption) THEN
      IF (l_profileOptionValue = 'SEARCH') THEN
        -- this resp will use the default flow seeded for 11510
        CS_CF_UPG_UTL_PKG.Clone_Flow(p_applId, 10);
      ELSE
        -- this resp will use default flow seeded for 1159
        CS_CF_UPG_UTL_PKG.Clone_Flow(p_applId, 20);
      END IF;

      CS_CF_UPG_UTL_PKG.Insert_New_Target('IBU_SR_CRE',
                                          'APPLICATION',
                                          l_applId,
                                          NULL,
                                          NULL,
                                          NULL,
                                          to_char(0-l_applId),
                                          NULL);
      l_examineKBOption := FALSE;
    END IF;

    l_index := l_index + 1;
  END LOOP;
End Clone_Flows_For_Appl;

/*
 * Procedure to performing flow upgrades for site level
 */
PROCEDURE Do_Flow_Upgrades_For_Global(p_siteProfilesTable IN CS_CF_UPG_UTL_PKG.ProfileTable)
IS

  l_count NUMBER := p_siteProfilesTable.COUNT;
  l_index NUMBER := 0;
  l_profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE;
  l_profileOptionValue FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;

  l_examineKBOption BOOLEAN := TRUE;
  l_source_context_type_id NUMBER := 0;
  l_last_updated_by NUMBER;
  l_count2 NUMBER := 0;

  CURSOR l_cur(p_source_context_type_id IN VARCHAR2) IS
  SELECT last_updated_by
  FROM cs_cf_source_cxt_targets
  WHERE source_context_type_id = p_source_context_type_id;

  CURSOR l_cur2(p_source_context_type_id IN VARCHAR2) IS
  SELECT count(*)
  FROM cs_cf_source_cxt_targets
  WHERE source_context_type_id = p_source_context_type_id;

BEGIN

  WHILE (l_index < l_count) LOOP

    l_profileOptionName := p_siteProfilesTable(l_index).profileOptionName;
    l_profileOptionValue := p_siteProfilesTable(l_index).profileOptionValue;

    IF (l_profileOptionName = 'IBU_A_SR_KB_OPTION' AND l_examineKBOption) THEN
	 IF (l_profileOptionValue = 'SEARCH') THEN
	   SELECT SOURCE_CONTEXT_TYPE_ID
	   INTO l_source_context_type_id
	   FROM cs_cf_source_cxt_types
	   WHERE SOURCE_CODE = 'IBU_SR_CRE'
	   AND CONTEXT_TYPE = 'GLOBAL';

           OPEN l_cur(l_source_context_type_id);
           FETCH l_cur INTO l_last_updated_by;
           CLOSE l_cur;

           OPEN l_cur2(l_source_context_type_id);
           FETCH l_cur2 INTO l_count2;
           CLOSE l_cur2;

           -- mkcyee 02/26/2004 - only update the entry is it has not
           -- been customized
           IF (l_last_updated_by in (-1,1,2) AND l_count2 > 0) THEN

             UPDATE cs_cf_source_cxt_targets
	     SET cust_target_value1 = '10'
	     WHERE source_context_type_id = l_source_context_type_id;

	     CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_PKG.Do_Flow_Upgrades_For_Global', 'Updating global entry in cs_cf_source_cxt_targets to use 11510 default flow. l_source_context_type_id:' || l_source_context_type_id);
           END IF;

        END IF;
        l_examineKBOption := FALSE;
    END IF;
    commit;
    l_index := l_index + 1;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_PKG.Do_Flow_Upgrades_For_Global', 'Unexpected error in Do_Flow_Upgrades_For_Global');

    IF (l_cur%ISOPEN) THEN
      CLOSE l_cur;
    END IF;
    IF (l_cur2%ISOPEN) THEN
      CLOSE l_cur2;
    END IF;

    RAISE;

END Do_Flow_Upgrades_For_Global;


END CS_CF_UPG_PKG;

/
