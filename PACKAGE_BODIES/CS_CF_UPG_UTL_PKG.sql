--------------------------------------------------------
--  DDL for Package Body CS_CF_UPG_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CF_UPG_UTL_PKG" as
/* $Header: cscfutlb.pls 120.1 2006/01/03 16:53:41 mkcyee noship $ */

  CURSOR get_profile_option_values (p_profile_option_name VARCHAR2)
  IS SELECT
  b.level_id,
  b.level_value,
  b.level_value_application_id,
  b.profile_option_value
  FROM fnd_profile_options a, fnd_profile_option_values b
  where a.profile_option_name = p_profile_option_name
  and a.profile_option_id = b.profile_option_id
  and a.application_id = b.application_id
  order by b.level_id;


  CURSOR get_profile_option_count (p_profile_option_name VARCHAR2)
  IS SELECT count(*)
  FROM fnd_profile_options a
  WHERE a.profile_option_name in (p_profile_option_name);



/*
 * Compare values for the IBU_SR_ACCOUNT_OPTION profile
 * Oracle iSupport: Service Request Account Option
 */

FUNCTION Eval_SR_Account_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                 p_respTable IN OUT NOCOPY RespTable,
                                 p_appl_index IN OUT NOCOPY NUMBER,
                                 p_applTable IN OUT NOCOPY ApplTable,
                                 p_site_index IN OUT NOCOPY NUMBER,
                                 p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                 RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN

    OPEN get_profile_option_values('IBU_A_SR_ACCOUNT_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'MWOSO') THEN
		l_upgrade_required := TRUE;
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_A_SR_ACCOUNT_OPTION';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Eval_SR_Account_Option', 'site level value customized. Profile option value: ' || l_profile_option_value);
        END IF;
      ELSIF (l_level_id = 10002) THEN
        -- there should not have been a value set at the appl level
        -- If there is a vvalue, then it is customized
        l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Account_Option', 'appl level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Account_Option', 'Application Id: ' || to_char(l_level_value));
        IF NOT(Appl_Already_Exists(p_applTable, l_level_value)) THEN
          p_applTable(p_appl_index) := l_level_value;
          p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- there should not have been a value set at the resp level
	   -- If there is a value, then it is customized
	   l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Account_Option', 'resp level value customized. Profile option value: ' || l_profile_option_value);

        log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Eval_SR_Account_Option', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));


	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
          p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

    return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:Eval_SR_Account_Option', 'Exception in Eval_SR_Account_Option');
    IF (get_profile_option_values%ISOPEN) THEN
	 CLOSE get_profile_option_values;
    END IF;
    RAISE;
END Eval_SR_Account_Option;

/*
 * Compare values for the IBU_A_SR_PROB_CODE_MANDATORY profile
 * Oracle iSupport: Problem Code Mandatory During Service Request Creation
 */

FUNCTION Eval_SR_Problem_Code_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                 p_respTable IN OUT NOCOPY RespTable,
                                 p_appl_index IN OUT NOCOPY NUMBER,
                                 p_applTable IN OUT NOCOPY ApplTable,
                                 p_site_index IN OUT NOCOPY NUMBER,
                                 p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                 RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;
  l_count NUMBER := 0;

BEGIN

    OPEN get_profile_option_count('IBU_A_SR_PROB_CODE_MANDATORY');
    FETCH get_profile_option_count INTO l_count;
    CLOSE get_profile_option_count;

    -- mkcyee 12/14/2004 - This profile was added in the branch of 1159 and was not
    -- forward ported to seedr10, so it is possible that this profile does not get
    -- exist if this is a pre-1159+ or 11510 and later installation.

    IF (l_count = 0) THEN
      return l_upgrade_required;
    END IF;

    OPEN get_profile_option_values('IBU_A_SR_PROB_CODE_MANDATORY');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'N') THEN
		l_upgrade_required := TRUE;
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_A_SR_PROB_CODE_MANDATORY';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Eval_SR_Problem_Code_Option', 'site level value customized. Profile option value: ' || l_profile_option_value);
        END IF;
      ELSIF (l_level_id = 10002) THEN
        -- there should not have been a value set at the appl level
        -- If there is a vvalue, then it is customized
        l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Problem_Code_Option', 'appl level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Problem_Option', 'Application Id: ' || to_char(l_level_value));
        IF NOT(Appl_Already_Exists(p_applTable, l_level_value)) THEN
          p_applTable(p_appl_index) := l_level_value;
          p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
           -- there should not be any values, so if there is,
           -- it must be a customization
	   l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Problem_Code_Option', 'resp level value customized. Profile option value: ' || l_profile_option_value);

           log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Eval_SR_Problem_Code_Option', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));


	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
             p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
           END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

    return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:Eval_SR_Problem_Code_Option', 'Exception in Eval_SR_Problem_Code_Option');
    IF (get_profile_option_values%ISOPEN) THEN
	 CLOSE get_profile_option_values;
    END IF;
    IF (get_profile_option_count%ISOPEN) THEN
	 CLOSE get_profile_option_count;
    END IF;

    RAISE;
END Eval_SR_Problem_Code_Option;

/*
 * Compare values for the IBU_SR_CREATION_PRODUCT_OPTION profile
 * Oracle iSupport: Create Service Request Product Option
 */

FUNCTION Eval_SR_Creation_Prod_Option (p_appl_index IN OUT NOCOPY NUMBER,
                                       p_applTable IN OUT NOCOPY ApplTable,
                                       p_resp_index IN OUT NOCOPY NUMBER,
                                       p_respTable IN OUT NOCOPY RespTable,
                                       p_site_index IN OUT NOCOPY NUMBER,
                                       p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                       RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN
    OPEN get_profile_option_values('IBU_SR_CREATION_PRODUCT_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP

      IF (l_level_id = 10001) THEN
	   IF (l_profile_option_value <> 'USE_BOTH_INVENTORY_AND_INSTALL') THEN
		log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Prod_Creation_Option', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_SR_CREATION_PRODUCT_OPTION';
		p_siteProfilesTAble(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		l_upgrade_required := TRUE;
        END IF ;
      ELSIF (l_level_id = 10002) THEN
	   -- There wasn't any seeded value for the app level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Prod_Creation_Option', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Prod_Creation_Option', 'Application Id: ' || to_char(l_level_value));

	   IF NOT(Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
	     p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- There wasn't any seeded value for the resp level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Prod_Creation_Option', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Prod_Creation_Option', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT (Resp_Already_Exists(p_RespTable, l_level_value, l_level_value_appl_id)) THEN
          p_RespTable(p_resp_index).respId := l_level_value;
	     p_RespTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
	 log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_Prod_Creation_Option', 'Exception in Eval_SR_Prod_Creation_Option');
	 IF (get_profile_option_values%ISOPEN) THEN
	   CLOSE get_profile_option_values;
      END IF;
      RAISE;
END Eval_SR_Creation_Prod_Option;

/*
 * Compare values for the IBU_SR_ADDR_DISPLAY profile
 * Oracle iSupport: Show Address Section in Service Request
 */

FUNCTION Eval_SR_Addr_Display (p_appl_index IN OUT NOCOPY NUMBER,
                               p_applTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_respTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN
    OPEN get_profile_option_values('IBU_SR_ADDR_DISPLAY');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- There wasn't any seeded value for the site level. Therefore, this
	   -- must be a customization
           l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Display', 'site level value customized. Profile option value: ' || l_profile_option_value);
	   p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_SR_ADDR_DISPLAY';
	   p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
	   p_site_index := p_site_index + 1;

      ELSIF (l_level_id = 10002) THEN
	   -- There wasn't any seeded value for the app level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Display', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Display', 'Application Id: ' || to_char(l_level_value));
	   IF NOT (Appl_Already_Exists(p_applTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
	     p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- There wasn't any seeded value for the resp level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Display', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Display', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT (Resp_Already_Exists(p_RespTable, l_level_value, l_level_value_appl_id)) THEN
          p_RespTable(p_resp_index).respId := l_level_value;
	     p_RespTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
	 log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Display', 'Exception in Eval_SR_Addr_Display');
	 IF (get_profile_option_values%ISOPEN) THEN
	   CLOSE get_profile_option_values;
      END IF;
      RAISE;
END Eval_SR_Addr_Display;


/*
 * Compare values for the IBU_SR_ADDR_MANDATORY profile
 * Oracle iSupport: Address Field Mandatory in Service Request Creation
 */

FUNCTION Eval_SR_Addr_Mandatory (p_appl_index IN OUT NOCOPY NUMBER,
                               p_ApplTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_RespTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN
    OPEN get_profile_option_values('IBU_SR_ADDR_MANDATORY');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP

      IF (l_level_id = 10001) THEN
	   -- There wasn't any seeded value for the site level. Therefore, this
	   -- must be a customization
           l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Mandatory', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_SR_ADDR_MANDATORY';
		p_siteProfilesTAble(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
      ELSIF (l_level_id = 10002) THEN
	   -- There wasn't any seeded value for the app level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Mandatory', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Mandatory','Application Id: ' || to_char(l_level_value));
	   IF NOT (Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
	     p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- There wasn't any seeded value for the resp level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Mandatory', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Mandatory','Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT (Resp_Already_Exists(p_RespTable, l_level_value, l_level_value_appl_id)) THEN
          p_RespTable(p_resp_index).respId := l_level_value;
	     p_RespTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
	 log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_Addr_Mandatory', 'Exception in Eval_SR_Addr_Mandatory');
      IF (get_profile_option_values%ISOPEN) THEN
	   CLOSE get_profile_option_values;
      END IF;
      RAISE;
END Eval_SR_Addr_Mandatory;


/*
 * Compare values for the IBU_A_SR_BILLTO_ADDRESS_OPTION profile
 * Oracle iSupport: Service Request Bill To Address Option
 */

FUNCTION Eval_SR_BillTo_Address_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                        p_respTable IN OUT NOCOPY RespTable,
                                        p_appl_index IN OUT NOCOPY NUMBER,
                                        p_applTable IN OUT NOCOPY ApplTable,
                                        p_site_index IN OUT NOCOPY NUMBER,
                                        p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                        RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN

    OPEN get_profile_option_values('IBU_A_SR_BILLTO_ADDRESS_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'NOTDISPLAYED') THEN
          log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Address', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_SR_BILLTO_ADDRESS_OPTION';
		p_siteProfilesTAble(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- There wasn't any seeded value for the app level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Address', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Address','Application Id: ' || to_char(l_level_value));
	   IF NOT (Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
	     p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- there should not have been a value set at the resp level
	   -- If there is a value, then it is customized
	   l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Address', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Address', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
          p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
	 log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Address', 'Exception in Eval_SR_BillTo_Address_Option');
	 IF (get_profile_option_values%ISOPEN) THEN
	   CLOSE get_profile_option_values;
      END IF;
      RAISE;
END Eval_SR_BillTo_Address_Option;

/*
 * Compare values for the IBU_A_SR_BILLTO_CONTACT_OPTION profile
 * Oracle iSupport: Service Request Bill To Contact Option
 */

FUNCTION Eval_SR_BillTo_Contact_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                        p_respTable IN OUT NOCOPY RespTable,
                                        p_appl_index IN OUT NOCOPY NUMBER,
                                        p_applTable IN OUT NOCOPY ApplTable,
                                        p_site_index IN OUT NOCOPY NUMBER,
                                        p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                        RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN

    OPEN get_profile_option_values('IBU_A_SR_BILLTO_CONTACT_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'NOTDISPLAYED') THEN
          log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Contact', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_SR_BILLTO_CONTACT_OPTION';
		p_siteProfilesTAble(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- There wasn't any seeded value for the app level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Contact', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Contact','Application Id: ' || to_char(l_level_value));
	   IF NOT (Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
	     p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- there should not have been a value set at the resp level
	   -- If there is a value, then it is customized
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Contact', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Contact', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   l_upgrade_required := TRUE;
	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
          p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
	 log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_BillTo_Contact_Option', 'Exception in Eval_SR_BillTo_Contact_Option');
      IF (get_profile_option_values%ISOPEN) THEN
	   CLOSE get_profile_option_values;
      END IF;
	 RAISE;
END Eval_SR_BillTo_Contact_Option;

/*
 * Compare values for the IBU_A_SR_SHIPTO_ADDRESS_OPTION profile
 * Oracle iSupport: Service Request Ship To Address Option
 */

FUNCTION Eval_SR_ShipTo_Address_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                        p_respTable IN OUT NOCOPY RespTable,
                                        p_appl_index IN OUT NOCOPY NUMBER,
                                        p_applTable IN OUT NOCOPY ApplTable,
                                        p_site_index IN OUT NOCOPY NUMBER,
                                        p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                        RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN

    OPEN get_profile_option_values('IBU_A_SR_SHIPTO_ADDRESS_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'NOTDISPLAYED') THEN
          log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Address', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_A_SR_SHIPTO_ADDRESS_OPTION';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- there should not have been a value set at the appl level
	   -- if there is a value, then it is customized
           l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Address_Option', 'appl level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Address_Option', 'Application Id: ' || to_char(l_level_value));
        IF NOT(Appl_Already_Exists(p_applTable, l_level_value)) THEN
          p_applTable(p_appl_index) := l_level_value;
          p_appl_index := p_appl_index + 1;
        END IF;

      ELSIF (l_level_id = 10003) THEN
	   -- there should not have been a value set at the resp level
	   -- If there is a value, then it is customized
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Address_Option',  'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Address_Option', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   l_upgrade_required := TRUE;
	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
          p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
	 log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Address_Option', 'Exception in Eval_SR_ShipTo_Address_Option');
      IF (get_profile_option_values%ISOPEN) THEN
	   CLOSE get_profile_option_values;
      END IF;
	 RAISE;
END Eval_SR_ShipTo_Address_Option;

/*
 * Compare values for the IBU_A_SR_SHIPTO_CONTACT_OPTION profile
 * Oracle iSupport: Service Request Ship To Contact Option
 */

FUNCTION Eval_SR_ShipTo_Contact_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                        p_respTable IN OUT NOCOPY RespTable,
                                        p_appl_index IN OUT NOCOPY NUMBER,
                                        p_applTable IN OUT NOCOPY ApplTable,
                                        p_site_index IN OUT NOCOPY NUMBER,
                                        p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                        RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN

    OPEN get_profile_option_values('IBU_A_SR_SHIPTO_CONTACT_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'NOTDISPLAYED') THEN
          log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Contact', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_A_SR_SHIPTO_CONTACT_OPTION';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- there should not have been a value set at the appl level
	   -- if there is a value, then it is customized
           l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Contact_Option', 'appl level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Contact_Option', 'Application Id: ' || to_char(l_level_value));
        IF NOT(Appl_Already_Exists(p_applTable, l_level_value)) THEN
          p_applTable(p_appl_index) := l_level_value;
          p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- there should not have been a value set at the resp level
	   -- If there is a value, then it is customized
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Contact_Option', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Contact_Option','Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   l_upgrade_required := TRUE;
	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
          p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
	 log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_ShipTo_Contact_Option', 'Exception in Eval_SR_ShipTo_Contact_Option');
      IF (get_profile_option_values%ISOPEN) THEN
        CLOSE get_profile_option_values;
	 END IF;
	 RAISE;

END Eval_SR_ShipTo_Contact_Option;

/*
 * Compare values for the IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION profile
 * Oracle iSupport: Service Request Installed At Address Option
 */

FUNCTION Eval_SR_InstalledAt_Address (p_resp_index IN OUT NOCOPY NUMBER,
                                      p_respTable IN OUT NOCOPY RespTable,
                                      p_appl_index IN OUT NOCOPY NUMBER,
                                      p_applTable IN OUT NOCOPY ApplTable,
                                      p_site_index IN OUT NOCOPY NUMBER,
                                      p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                      RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN

    OPEN get_profile_option_values('IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'NOTDISPLAYED') THEN
          log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_InstalledAt_Addr', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- there should not have been a value set at the appl level
	   -- if there is a value, then it is customized
           l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_InstalledAt_Addr', 'appl level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_InstalledAt_Addr', 'Application Id: ' || to_char(l_level_value));
        IF NOT(Appl_Already_Exists(p_applTable, l_level_value)) THEN
          p_applTable(p_appl_index) := l_level_value;
          p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- there should not have been a value set at the resp level
	   -- If there is a value, then it is customized
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_InstalledAt_Addr', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_InstalledAt_Addr', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   l_upgrade_required := TRUE;
	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
          p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
	 log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_InstalledAt_Addr', 'Exception in Eval_SR_InstalledAt_Address');
      IF (get_profile_option_values%ISOPEN) THEN
        CLOSE get_profile_option_values;
      END IF;
      RAISE;

END Eval_SR_InstalledAt_Address;


/*
 * Compare values for the IBU_A_SR_ATTACHMENT_OPTION profile
 * Oracle iSupport: Service Request Attachment Option
 */

FUNCTION Eval_SR_Attachment_Option (p_resp_index IN OUT NOCOPY NUMBER,
                                    p_respTable IN OUT NOCOPY RespTable,
                                    p_appl_index IN OUT NOCOPY NUMBER,
                                    p_applTable IN OUT NOCOPY ApplTable,
                                    p_site_index IN OUT NOCOPY NUMBER,
                                    p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                    RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN

    OPEN get_profile_option_values('IBU_A_SR_ATTACHMENT_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'SHOWDURINGBOTH') THEN
          log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Eval_SR_Attachment_Option', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_A_SR_ATTACHMENT_OPTION';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- there should not have been a value set at the appl level
	   -- if there is a value, then it is customized
           l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Attachment_Option', 'appl level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Attachment_Option', 'Application Id: ' || to_char(l_level_value));
        IF NOT(Appl_Already_Exists(p_applTable, l_level_value)) THEN
          p_applTable(p_appl_index) := l_level_value;
          p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- there should not have been a value set at the resp level
	   -- If there is a value, then it is customized
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Attachment_Option', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Attachment_Option','Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   l_upgrade_required := TRUE;
	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
          p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_Attachment_Option', 'Exception in Eval_SR_ShipTo_Address_Option');
    IF (get_profile_option_values%ISOPEN) THEN
      CLOSE get_profile_option_values;
    END IF;
    RAISE;

END Eval_SR_Attachment_Option;

/*
 * Compare values for the IBU_SR_TASK_DISPLAY profile
 * Oracle iSupport: Show Task in Service Request Module
 */

FUNCTION Eval_SR_Task_Display (p_appl_index IN OUT NOCOPY NUMBER,
                               p_ApplTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_RespTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN
    OPEN get_profile_option_values('IBU_SR_TASK_DISPLAY');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   IF (l_profile_option_value <> 'N') THEN
		log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Task_Display', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_SR_TASK_DISPLAY';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
	     l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- There wasn't any seeded value for the app level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Task_Display', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Task_Display', 'Application Id: ' || to_char(l_level_value));
	   IF NOT (Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
	     p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- There wasn't any seeded value for the resp level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Task_Display', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Task_Display', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT(Resp_Already_Exists(p_RespTable, l_level_value, l_level_value_appl_id)) THEN
          p_RespTable(p_resp_index).respId := l_level_value;
	     p_RespTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
       END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_Task_Display','Exception in Eval_SR_ShipTo_Address_Option');
      IF (get_profile_option_values%ISOPEN) THEN
        CLOSE get_profile_option_values;
      END IF;
      RAISE;

END Eval_SR_Task_Display;

/*
 * Compare values for the IBU_A_SR_ENABLE_INTERACTION_LOGGING profile
 * Oracle iSupport: Enable Interaction Logging
 */

FUNCTION Eval_SR_Enable_Interact_Log (p_resp_index IN OUT NOCOPY NUMBER,
                                      p_respTable IN OUT NOCOPY RespTable,
                                      p_appl_index IN OUT NOCOPY NUMBER,
                                      p_applTable IN OUT NOCOPY ApplTable,
                                      p_site_index IN OUT NOCOPY NUMBER,
                                      p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                                      RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN

    OPEN get_profile_option_values('IBU_A_SR_ENABLE_INTERACTION_LOGGING');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   -- check if the value set at site is equal to
	   -- value seeded out-of-the-box
	   IF (l_profile_option_value <> 'N') THEN
		log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Interaction_Logging', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_A_SR_ENABLE_INTERACTION_LOGGING';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
		l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- There wasn't any seeded value for the app level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Interaction_Logging', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Interaction_Logging', 'Application Id: ' || to_char(l_level_value));
	   IF NOT (Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
	     p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- there should not have been a value set at the resp level
	   -- If there is a value, then it is customized
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Interaction_Logging', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Interaction_Logging', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT (Resp_Already_Exists(p_respTable, l_level_value, l_level_value_appl_id)) THEN
          p_respTable(p_resp_index).respId := l_level_value;
	     p_respTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Interact_Log', 'Exception in Eval_SR_Enable_Interact_Log');
    IF (get_profile_option_values%ISOPEN) THEN
      CLOSE get_profile_option_values;
    END IF;
    RAISE;

END Eval_SR_Enable_Interact_Log;

/*
 * Compare values for the IBU_A_SR_KB_OPTION profile
 * Oracle iSupport: Search Knowledge Base Option
 */

FUNCTION Eval_SR_KB_Option (p_appl_index IN OUT NOCOPY NUMBER,
                               p_applTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_respTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN
    OPEN get_profile_option_values('IBU_A_SR_KB_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   IF (l_profile_option_value <> 'PROMPT') THEN
		log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_KB_Option','site level value customized. Profile option value: ' || l_profile_option_value);
          p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_A_SR_KB_OPTION';
          p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
          p_site_index := p_site_index + 1;

	     l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   -- There wasn't any seeded value for the app level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_KB_Option', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_KB_Option', 'Application Id: ' || to_char(l_level_value));
	   IF NOT (Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
	     p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- There wasn't any seeded value for the resp level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_KB_Option',  'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_KB_Option', 'Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT (Resp_Already_Exists(p_RespTable, l_level_value, l_level_value_appl_id)) THEN
          p_RespTable(p_resp_index).respId := l_level_value;
	     p_RespTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:Eval_SR_ShipTo_Address_Option', 'Exception in Eval_SR_ShipTo_Address_Option');
      IF (get_profile_option_values%ISOPEN) THEN
        CLOSE get_profile_option_values;
      END IF;
      RAISE;

END Eval_SR_KB_OPTION;

/*
 * Compare values for the IBU_SR_ENABLE_TEMPLATE profile
 * Oracle iSupport: Enable Service Request Template
 */

FUNCTION Eval_SR_Enable_Template (p_appl_index IN OUT NOCOPY NUMBER,
                               p_applTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_respTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN
    OPEN get_profile_option_values('IBU_SR_ENABLE_TEMPLATE');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   IF (l_profile_option_value <> 'Y') THEN
		log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Template', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_SR_ENABLE_TEMPLATE';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
	     l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
	   IF(l_profile_option_value <> 'Y') THEN
	     log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Template', 'appl level value customized. Profile option value: ' || l_profile_option_value);
	     log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Template', 'Application Id: ' || to_char(l_level_value));
          IF NOT (Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
            p_ApplTable(p_appl_index) := l_level_value;
  	       p_appl_index := p_appl_index + 1;
          END IF;
	     l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- There wasn't any seeded value for the resp level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Template', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Template','Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT (Resp_Already_Exists(p_RespTable, l_level_value, l_level_value_appl_id)) THEN
          p_RespTable(p_resp_index).respId := l_level_value;
	     p_RespTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Template','Exception in Eval_SR_Enable_Template');
      IF (get_profile_option_values%ISOPEN) THEN
        CLOSE get_profile_option_values;
      END IF;
      RAISE;

END Eval_SR_Enable_Template;

/*
 * Compare values for the IBU_A_SR_PRODUCT_SELECTION_OPTION profile
 * Oracle iSupport: Enforce Product Selection Option
 */

FUNCTION Eval_SR_Product_Selection (p_appl_index IN OUT NOCOPY NUMBER,
                               p_applTable IN OUT NOCOPY ApplTable,
                               p_resp_index IN OUT NOCOPY NUMBER,
                               p_respTable IN OUT NOCOPY RespTable,
                               p_site_index IN OUT NOCOPY NUMBER,
                               p_siteProfilesTable IN OUT NOCOPY ProfileTable)
                               RETURN BOOLEAN
IS

  l_profile_option_id FND_PROFILE_OPTION_VALUES.profile_option_id%TYPE := 0;
  l_level_id FND_PROFILE_OPTION_VALUES.level_id%TYPE := 0;
  l_level_value FND_PROFILE_OPTION_VALUES.level_value%TYPE := 0;
  l_level_value_appl_id FND_PROFILE_OPTION_VALUES.level_value_application_id%TYPE := 0;
  l_profile_option_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE := '';

  l_upgrade_required BOOLEAN := FALSE;

BEGIN
    OPEN get_profile_option_values('IBU_A_SR_PRODUCT_SELECTION_OPTION');
    FETCH get_profile_option_values INTO
      l_level_id,
      l_level_value,
      l_level_value_appl_id,
      l_profile_option_value;
    WHILE get_profile_option_values%FOUND LOOP
      IF (l_level_id = 10001) THEN
	   IF (l_profile_option_value <> 'Y') THEN
		log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Enable_Template', 'site level value customized. Profile option value: ' || l_profile_option_value);
		p_siteProfilesTable(p_site_index).profileOptionName := 'IBU_SR_ENABLE_TEMPLATE';
		p_siteProfilesTable(p_site_index).profileOptionValue := l_profile_option_value;
		p_site_index := p_site_index + 1;
	     l_upgrade_required := TRUE;
        END IF;
      ELSIF (l_level_id = 10002) THEN
        -- there wasn't any seeded value for the appl level. Therefore,
        -- this must be a customization
        l_upgrade_required := TRUE;
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Product_Selection', 'appl level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Product_Selection', 'Application Id: ' || to_char(l_level_value));
        IF NOT (Appl_Already_Exists(p_ApplTable, l_level_value)) THEN
          p_ApplTable(p_appl_index) := l_level_value;
          p_appl_index := p_appl_index + 1;
        END IF;
      ELSIF (l_level_id = 10003) THEN
	   -- There wasn't any seeded value for the resp level. Therefore,
	   -- this must be a customization
           l_upgrade_required := TRUE;
	   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Product_Selection', 'resp level value customized. Profile option value: ' || l_profile_option_value);
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Eval_SR_Product_Selection','Resp id: ' || to_char(l_level_value) || ' Resp Appl Id: ' || to_char(l_level_value_appl_id));
	   IF NOT (Resp_Already_Exists(p_RespTable, l_level_value, l_level_value_appl_id)) THEN
          p_RespTable(p_resp_index).respId := l_level_value;
	     p_RespTable(p_resp_index).respApplId := l_level_value_appl_id;
	     p_resp_index := p_resp_index + 1;
        END IF;
      END IF;
      FETCH get_profile_option_values INTO
        l_level_id,
        l_level_value,
        l_level_value_appl_id,
        l_profile_option_value;
    END LOOP;
    CLOSE get_profile_option_values;

  return l_upgrade_required;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Eval_SR_Product_Selection','Exception in Eval_SR_Product_Selection');
      IF (get_profile_option_values%ISOPEN) THEN
        CLOSE get_profile_option_values;
      END IF;
      RAISE;

END Eval_SR_Product_Selection;


/*
 * Checks whether a specific responsibility
 * has already been added to the table
 */
FUNCTION Resp_Already_Exists(p_RespTable IN RespTable,
					    p_level_value IN NUMBER,
					    p_level_value_application_id IN NUMBER)
					    RETURN BOOLEAN
IS

  l_found BOOLEAN := FALSE;
  l_count NUMBER := p_RespTable.COUNT;
  l_index NUMBER := 0;

BEGIN
  WHILE ((l_index < l_count) AND l_found = FALSE) LOOP
    IF (p_RespTable(l_index).respId = p_level_value
	   AND p_RespTable(l_index).respApplId = p_level_value_application_id) THEN
	   l_found := TRUE;
    END IF;
    l_index := l_index + 1;
  END LOOP;

  RETURN l_found;

END Resp_Already_Exists;

/*
 * Checks whether a specific application has
 * already been added to the table
 */
FUNCTION Appl_Already_Exists(p_ApplTable IN ApplTable,
					    p_level_value IN NUMBER)
					    RETURN BOOLEAN
IS

  l_found BOOLEAN := FALSE;
  l_count NUMBER := p_ApplTable.COUNT;
  l_index NUMBER := 0;

BEGIN
  WHILE ((l_index < l_count) AND l_found=FALSE) LOOP
    IF (p_ApplTable(l_index) = p_level_value) THEN
	   l_found := TRUE;
    END IF;
    l_index := l_index + 1;
  END LOOP;

  RETURN l_found;

END Appl_Already_Exists;

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
					   p_custTargetValue2 IN VARCHAR2)
IS

  no_row_found EXCEPTION;

  l_source_context_type_id NUMBER := 0;
  l_source_context_target_id NUMBER := 0;
  l_count NUMBER := 0;
  l_rowid VARCHAR2(50) := '';
  l_created_by NUMBER := FND_LOAD_UTIL.OWNER_ID('ORACLE');

  u_source_context_target_id NUMBER := 0;
  u_context_value1 VARCHAR2(10) := 0;
  u_context_value2 VARCHAR2(10) := 0;
  u_context_value3 VARCHAR2(10) := 0;
  u_context_value4 VARCHAR2(10) := 0;
  u_context_value5 VARCHAR2(10) := 0;
  u_object_version_number NUMBER := 0;
  u_seed_target_value1 VARCHAR2(30) := '';
  u_seed_target_value2 VARCHAR2(30) := '';
  u_cust_target_value1 VARCHAR2(30) := '';
  u_cust_target_value2 VARCHAR2(30) := '';
  u_created_by NUMBER := 2;
  u_creation_date DATE;
  u_last_updated_by NUMBER := 0;
  u_last_update_date DATE;
  u_last_update_login NUMBER := 0;
  u_attribute_category VARCHAR2(30) := '';
  u_attribute1 VARCHAR2(150) := '';
  u_attribute2 VARCHAR2(150) := '';
  u_attribute3 VARCHAR2(150) := '';
  u_attribute4 VARCHAR2(150) := '';
  u_attribute5 VARCHAR2(150) := '';
  u_attribute6 VARCHAR2(150) := '';
  u_attribute7 VARCHAR2(150) := '';
  u_attribute8 VARCHAR2(150) := '';
  u_attribute9 VARCHAR2(150) := '';
  u_attribute10 VARCHAR2(150) := '';
  u_attribute11 VARCHAR2(150) := '';
  u_attribute12 VARCHAR2(150) := '';
  u_attribute13 VARCHAR2(150) := '';
  u_attribute14 VARCHAR2(150) := '';
  u_attribute15 VARCHAR2(150) := '';
  u_additional_info1 VARCHAR2(150) := '';
  u_additional_info2 VARCHAR2(150) := '';
  u_additional_info3 VARCHAR2(150) := '';
  u_additional_info4 VARCHAR2(150) := '';
  u_additional_info5 VARCHAR2(150) := '';
  u_additional_info6 VARCHAR2(150) := '';
  u_additional_info7 VARCHAR2(150) := '';
  u_additional_info8 VARCHAR2(150) := '';
  u_additional_info9 VARCHAR2(150) := '';
  u_additional_info10 VARCHAR2(150) := '';
  u_additional_info11 VARCHAR2(150) := '';
  u_additional_info12 VARCHAR2(150) := '';
  u_additional_info13 VARCHAR2(150) := '';
  u_additional_info14 VARCHAR2(150) := '';
  u_additional_info15 VARCHAR2(150) := '';





  CURSOR source_context_type_id (p_sourceCode VARCHAR2, p_contextType VARCHAR2)
  IS
    SELECT source_context_type_id
    FROM CS_CF_SOURCE_CXT_TYPES
    WHERE SOURCE_CODE = p_sourceCode
    AND CONTEXT_TYPE = p_contextType;

  CURSOR target_count_resp (p_contextTypeId NUMBER, p_contextValue1 VARCHAR2, p_contextValue2 VARCHAR2)
  IS
    SELECT count(*)
    FROM CS_CF_SOURCE_CXT_TARGETS
    WHERE source_context_type_id = p_contextTypeId
    AND context_value1 = p_contextValue1
    AND context_value2 = p_contextValue2;

  CURSOR target_count_appl (p_contextTypeId NUMBER, p_contextValue1 VARCHAR2)
  IS
    SELECT count(*)
    FROM CS_CF_SOURCE_CXT_TARGETS
    WHERE source_context_type_id = p_contextTypeId
    AND context_value1 = p_contextValue1;

  CURSOR target_count_global (p_contextTypeId NUMBER)
  IS
    SELECT count(*)
    FROM CS_CF_SOURCE_CXT_TARGETS
    WHERE source_context_type_id = p_contextTypeId;

  CURSOR target_values_global (p_contextTypeId NUMBER)
  IS
    SELECT source_context_target_id,
           context_value1,
           context_value2,
           context_value3,
           context_value4,
           context_value5,
           object_version_number,
           seed_target_value1,
           seed_target_value2,
           cust_target_value1,
           cust_target_value2,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           additional_info1,
           additional_info2,
           additional_info3,
           additional_info4,
           additional_info5,
           additional_info6,
           additional_info7,
           additional_info8,
           additional_info9,
           additional_info10,
           additional_info11,
           additional_info12,
           additional_info13,
           additional_info14,
           additional_info15
    FROM CS_CF_SOURCE_CXT_TARGETS
    WHERE source_context_type_id = p_contextTypeId;

BEGIN
    log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Insert_New_Target', 'Called Inserting new target row for sourceCode: ' || p_sourceCode || ' contextType: ' || p_contextType);

  OPEN source_context_type_id(p_sourceCode, p_contextType);
  FETCH source_context_type_id INTO l_source_context_type_id;
  CLOSE source_context_type_id;

  IF (p_contextType = 'RESP') THEN
    OPEN target_count_resp (l_source_context_type_id, p_contextValue1, p_contextValue2);
    FETCH target_count_resp INTO l_count;
    CLOSE target_count_resp;

  ELSIF (p_contextType = 'APPLICATION') THEN
    OPEN target_count_appl (l_source_context_type_id, p_contextValue1);
    FETCH target_count_appl INTO l_count;
    CLOSE target_count_appl;

  ELSIF (p_contextType = 'GLOBAL') THEN
    OPEN target_count_global(l_source_context_type_id);
    FETCH target_count_global INTO l_count;
    CLOSE target_count_global;

    IF (l_count > 0) THEN
      OPEN target_values_global(l_source_context_type_id);
      FETCH target_values_global
      INTO u_source_context_target_id,
           u_context_value1,
           u_context_value2,
           u_context_value3,
           u_context_value4,
           u_context_value5,
           u_object_version_number,
           u_seed_target_value1,
           u_seed_target_value2,
           u_cust_target_value1,
           u_cust_target_value2,
           u_created_by,
           u_creation_date,
           u_last_updated_by,
           u_last_update_date,
           u_last_update_login,
           u_attribute_category,
           u_attribute1,
           u_attribute2,
           u_attribute3,
           u_attribute4,
           u_attribute5,
           u_attribute6,
           u_attribute7,
           u_attribute8,
           u_attribute9,
           u_attribute10,
           u_attribute11,
           u_attribute12,
           u_attribute13,
           u_attribute14,
           u_attribute15,
           u_additional_info1,
           u_additional_info2,
           u_additional_info3,
           u_additional_info4,
           u_additional_info5,
           u_additional_info6,
           u_additional_info7,
           u_additional_info8,
           u_additional_info9,
           u_additional_info10,
           u_additional_info11,
           u_additional_info12,
           u_additional_info13,
           u_additional_info14,
           u_additional_info15;

      CLOSE target_values_global;
    log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Insert_New_Target', 'Global context: last_updated_by:' || u_last_updated_by  || 'created_by:' || u_created_by);
    END IF;
  END IF;

  IF (p_contextType <> 'GLOBAL' AND (l_count = 0))  THEN
    SELECT cs_cf_source_cxt_targets_s.nextval
    INTO l_source_context_target_id
    FROM dual;

    log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Insert_New_Target', 'Inserting new target row for sourceCode: ' || p_sourceCode || ' contextTargetId: ' || l_source_context_target_id);
    log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Insert_New_Target',  ' contextTypeId: ' || l_source_context_type_id || ' p_contextValue1: ' || p_contextValue1 || ' p_contextValue2: ' || p_contextValue2 );

    CS_CF_SOURCE_CXT_TARGETS_PKG.Insert_Row(
        X_ROWID => l_rowid,
        X_SOURCE_CONTEXT_TARGET_ID => l_source_context_target_id,
        X_SOURCE_CONTEXT_TYPE_ID => l_source_context_type_id,
        X_CONTEXT_VALUE1 => p_contextValue1,
        X_CONTEXT_VALUE2 => p_contextValue2,
        X_CONTEXT_VALUE3 => NULL,
        X_CONTEXT_VALUE4 => NULL,
        X_CONTEXT_VALUE5 => NULL,
        X_SEED_TARGET_VALUE1 => p_seedTargetValue1,
        X_SEED_TARGET_VALUE2 => p_seedTargetValue2,
        X_CUST_TARGET_VALUE1 => p_custTargetValue1,
        X_CUST_TARGET_VALUE2 => p_custTargetValue2,
        X_OBJECT_VERSION_NUMBER => 1,
        X_ATTRIBUTE_CATEGORY => NULL,
        X_ATTRIBUTE1 => NULL,
        X_ATTRIBUTE2 => NULL,
        X_ATTRIBUTE3 => NULL,
        X_ATTRIBUTE4 => NULL,
        X_ATTRIBUTE5 => NULL,
        X_ATTRIBUTE6 => NULL,
        X_ATTRIBUTE7 => NULL,
        X_ATTRIBUTE8 => NULL,
        X_ATTRIBUTE9 => NULL,
        X_ATTRIBUTE10 => NULL,
        X_ATTRIBUTE11 => NULL,
        X_ATTRIBUTE12 => NULL,
        X_ATTRIBUTE13 => NULL,
        X_ATTRIBUTE14 => NULL,
        X_ATTRIBUTE15 => NULL,
        X_ADDITIONAL_INFO1 => NULL,
        X_ADDITIONAL_INFO2 => NULL,
        X_ADDITIONAL_INFO3 => NULL,
        X_ADDITIONAL_INFO4 => NULL,
        X_ADDITIONAL_INFO5 => NULL,
        X_ADDITIONAL_INFO6 => NULL,
        X_ADDITIONAL_INFO7 => NULL,
        X_ADDITIONAL_INFO8 => NULL,
        X_ADDITIONAL_INFO9 => NULL,
        X_ADDITIONAL_INFO10 => NULL,
        x_ADDITIONAL_INFO11 => NULL,
        X_ADDITIONAL_INFO12 => NULL,
        X_ADDITIONAL_INFO13 => NULL,
        X_ADDITIONAL_INFO14 => NULL,
        X_ADDITIONAL_INFO15 => NULL,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => l_created_by,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => l_created_by,
        X_LAST_UPDATE_LOGIN => 0);

  ELSIF(p_contextType = 'GLOBAL' and l_count = 0) THEN
    RAISE no_row_found;

  ELSIF (p_contextType = 'GLOBAL' AND (l_count > 0 AND ((u_last_updated_by = u_created_by) OR (u_last_updated_by = -1)))) THEN

    -- mkcyee 12/09/2004
    -- Update the existing row in place. This is a special
    -- case for global regions because there will already be an existing
    -- row present after installation.
    -- We also keep the last_update_date to be the same because
    -- we want future ldt changes to overwrite this row.

    log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Insert_New_Target', 'Updating target row for sourceCode: ' || p_sourceCode || ' contextTargetId: ' || l_source_context_target_id);
    log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_UTL_PKG.Insert_New_Target',  ' contextTypeId: ' || l_source_context_type_id || ' p_contextValue1: ' || p_contextValue1 || ' p_contextValue2: ' || p_contextValue2 );

    CS_CF_SOURCE_CXT_TARGETS_PKG.UPDATE_ROW(
      X_SOURCE_CONTEXT_TARGET_ID => u_source_context_target_id,
      X_SOURCE_CONTEXT_TYPE_ID => l_source_context_type_id,
      X_CONTEXT_VALUE1 => u_context_value1,
      X_CONTEXT_VALUE2 => u_context_value2,
      X_CONTEXT_VALUE3 => u_context_value3,
      X_CONTEXT_VALUE4 => u_context_value4,
      X_CONTEXT_VALUE5 => u_context_value5,
      X_SEED_TARGET_VALUE1 => u_seed_target_value1,
      X_SEED_TARGET_VALUE2 => u_seed_target_value2,
      X_CUST_TARGET_VALUE1 => p_custTargetValue1,
      X_CUST_TARGET_VALUE2 => p_custTargetValue2,
      X_OBJECT_VERSION_NUMBER => u_object_version_number+1,
      X_LAST_UPDATE_DATE => u_last_update_date,
      X_LAST_UPDATED_BY => u_last_updated_by,
      X_LAST_UPDATE_LOGIN => u_last_update_login,
      X_ATTRIBUTE_CATEGORY => u_attribute_category,
      X_ATTRIBUTE1 => u_attribute1,
      X_ATTRIBUTE2 => u_attribute2,
      X_ATTRIBUTE3 => u_attribute3,
      X_ATTRIBUTE4 => u_attribute4,
      X_ATTRIBUTE5 => u_attribute5,
      X_ATTRIBUTE6 => u_attribute6,
      X_ATTRIBUTE7 => u_attribute7,
      X_ATTRIBUTE8 => u_attribute8,
      X_ATTRIBUTE9 => u_attribute9,
      X_ATTRIBUTE10 => u_attribute10,
      X_ATTRIBUTE11 => u_attribute11,
      X_ATTRIBUTE12 => u_attribute12,
      X_ATTRIBUTE13 => u_attribute13,
      X_ATTRIBUTE14 => u_attribute14,
      X_ATTRIBUTE15 => u_attribute15,
      X_ADDITIONAL_INFO1 => u_additional_info1,
      X_ADDITIONAL_INFO2 => u_additional_info2,
      X_ADDITIONAL_INFO3 => u_additional_info3,
      X_ADDITIONAL_INFO4 => u_additional_info4,
      X_ADDITIONAL_INFO5 => u_additional_info5,
      X_ADDITIONAL_INFO6 => u_additional_info6,
      X_ADDITIONAL_INFO7 => u_additional_info7,
      X_ADDITIONAL_INFO8 => u_additional_info8,
      X_ADDITIONAL_INFO9 => u_additional_info9,
      X_ADDITIONAL_INFO10 => u_additional_info10,
      X_ADDITIONAL_INFO11 => u_additional_info11,
      X_ADDITIONAL_INFO12 => u_additional_info12,
      X_ADDITIONAL_INFO13 => u_additional_info13,
      X_ADDITIONAL_INFO14 => u_additional_info14,
      X_ADDITIONAL_INFO15 => u_additional_info15);

  END IF;

EXCEPTION
  WHEN no_row_found THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG.Insert_New_Target', 'Unexpected error: There should be at least one entry at the global level for source code ' || p_sourceCode);
    RAISE;
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:Insert_New_Target', 'Exception for sourceCode:  ' || p_sourceCode || 'contextType: ' || p_contextType);
    IF (source_context_type_id%ISOPEN) THEN
	 CLOSE source_context_type_id;
    END IF;
    IF (target_count_resp%ISOPEN) THEN
	 CLOSE target_count_resp;
    END IF;

    IF (target_count_appl%ISOPEN) THEN
	 CLOSE target_count_appl;
    END IF;
    IF (target_count_global%ISOPEN) THEN
	 CLOSE target_count_global;
    END IF;
    IF (target_values_global%ISOPEN) THEN
	 CLOSE target_values_global;
    END IF;

    RAISE;

END Insert_New_Target;

/*
 * Wrapper function to call AK's api to clone regions
 */
PROCEDURE Clone_Region(p_regionCode IN VARCHAR2,
				   p_regionApplId IN NUMBER,
				   p_newRegionCode IN VARCHAR2,
				   p_newRegionApplId IN NUMBER,
                                   p_checkRegion IN BOOLEAN)
IS

r_rec ak_regions%rowtype;

CURSOR r_csr (p_csr_code IN VARCHAR2, p_csr_id IN NUMBER) is
SELECT *
FROM ak_regions
WHERE region_code = p_csr_code
AND region_application_id = p_csr_id;

CURSOR region_exists (p_region_code IN VARCHAR2, p_region_application_id IN NUMBER) IS
SELECT count(*)
FROM ak_regions
where region_code = p_region_code
AND region_application_id = p_region_application_id;



b_success BOOLEAN;
l_count NUMBER := 0;

BEGIN

  -- mkcyee 12/14/2004 p_checkRgion is TRUE only in the case of the Global
  -- level.

  IF (p_checkRegion) THEN
    OPEN region_exists(p_newRegionCode, p_newRegionApplId);
    FETCH region_exists INTO l_count;
    CLOSE region_exists;
  END IF;

  -- mkcyee 12/14/2004 - For global regions, we will make sure
  -- not to clone a region if it already exists. For resp and appl,
  -- we will never get here because if any regions are cloned, we will
  -- exit out of their upgrade procedure.
  -- This is so that the cust target values column in the
  -- cs_cf_source_cxt_targets table will get populated again
  -- after the ldt is uploaded.

  IF ((p_checkRegion AND l_count = 0) OR NOT p_checkRegion) THEN

      AK_REGIONS2_PKG.copy_records(p_regionCode,
						 p_regionApplId,
						 p_newRegionCode,
						 p_newRegionApplId);

      log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG:Clone_Region', 'Cloning Region for p_regionCode:  ' || p_regionCode || ' p_regionApplId: ' || to_char(p_regionApplId));
      log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG:Clone_Region',  ' p_newRegionCode: ' || p_newRegionCode || ' p_newRegionApplId: ' || to_char(p_newRegionApplId));

      OPEN r_csr(p_newRegionCode, p_newRegionApplId);
      FETCH r_csr INTO r_rec;

      b_success := r_csr%FOUND;
      IF (not b_success) THEN
        log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG:Clone_Region', ' Could not find cloned region');
        close r_csr;
        RAISE PROGRAM_ERROR;
      ELSE
        close r_csr;

        -- mkcyee 02/24/2004 After we clone the region, we need to update
        -- the region name; Otherwise, it uses the same name as the region we
        -- are trying to clone
        AK_REGIONS_PKG.Update_Row(X_REGION_APPLICATION_ID => r_rec.region_application_id,
                              X_REGION_CODE => r_rec.region_code,
                              X_DATABASE_OBJECT_NAME => r_rec.database_object_name,
                              X_REGION_STYLE => r_rec.region_style,
                              X_NUM_COLUMNS => r_rec.num_columns,
                              X_ICX_CUSTOM_CALL => r_rec.icx_custom_call,
                              X_NAME => p_newRegionCode,
                              X_DESCRIPTION => '',
                              X_REGION_DEFAULTING_API_PKG => r_rec.region_defaulting_api_pkg,
                              X_REGION_DEFAULTING_API_PROC => r_rec.region_defaulting_api_proc,
                              X_REGION_VALIDATION_API_PKG => r_rec.region_validation_api_pkg,
                              X_REGION_VALIDATION_API_PROC => r_rec.region_validation_api_proc,
                              X_APPL_MODULE_OBJECT_TYPE  => r_rec.applicationmodule_object_type,
                              X_NUM_ROWS_DISPLAY => r_rec.num_rows_display,
                              X_REGION_OBJECT_TYPE => r_rec.region_object_type,
                              X_IMAGE_FILE_NAME => r_rec.image_file_name,
                              X_ISFORM_FLAG => r_rec.isform_flag,
                              X_HELP_TARGET => r_rec.help_target,
                              X_STYLE_SHEET_FILENAME => r_rec.style_sheet_filename,
                              X_VERSION => r_rec.version,
                              X_APPLICATIONMODULE_USAGE_NAME => r_rec.applicationmodule_usage_name,
                              X_ADD_INDEXED_CHILDREN => r_rec.add_indexed_children,
                              X_STATEFUL_FLAG => r_rec.stateful_flag,
                              X_FUNCTION_NAME => r_rec.function_name,
                              X_CHILDREN_VIEW_USAGE_NAME => r_rec.children_view_usage_name,
                              X_SEARCH_PANEL => r_rec.search_panel,
                              X_ADVANCED_SEARCH_PANEL => r_rec.advanced_search_panel,
                              X_CUSTOMIZE_PANEL => r_rec.customize_panel,
                              X_DEFAULT_SEARCH_PANEL => r_rec.default_search_panel,
                              X_RESULTS_BASED_SEARCH => r_rec.results_based_search,
                              X_DISPLAY_GRAPH_TABLE => r_rec.display_graph_table,
                              X_DISABLE_HEADER => r_rec.disable_header,
                              X_STANDALONE => r_rec.standalone,
                              X_AUTO_CUSTOMIZATION_CRITERIA => r_rec.auto_customization_criteria,
                              X_LAST_UPDATE_DATE => sysdate,
                              X_LAST_UPDATED_BY => r_rec.last_updated_by,
                              X_LAST_UPDATE_LOGIN => r_rec.last_update_login,
                              X_ATTRIBUTE_CATEGORY => r_rec.attribute_category,
                              X_ATTRIBUTE1 => r_rec.attribute1,
                              X_ATTRIBUTE2 => r_rec.attribute2,
                              X_ATTRIBUTE3 => r_rec.attribute3,
                              X_ATTRIBUTE4 => r_rec.attribute4,
                              X_ATTRIBUTE5 => r_rec.attribute5,
                              X_ATTRIBUTE6 => r_rec.attribute6,
                              X_ATTRIBUTE7 => r_rec.attribute7,
                              X_ATTRIBUTE8 => r_rec.attribute8,
                              X_ATTRIBUTE9 => r_rec.attribute9,
                              X_ATTRIBUTE10 => r_rec.attribute10,
                              X_ATTRIBUTE11 => r_rec.attribute11,
                              X_ATTRIBUTE12 => r_rec.attribute12,
                              X_ATTRIBUTE13 => r_rec.attribute13,
                              X_ATTRIBUTE14 => r_rec.attribute14,
                              X_ATTRIBUTE15 => r_rec.attribute15);

       END IF;
     END IF;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:Clone_Region', 'Unexpected exception - p_regionCode:  ' || p_regionCode || ' p_regionApplId: ' || to_char(p_regionApplId));
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:Clone_Region',  ' p_newRegionCode: ' || p_newRegionCode || ' p_newRegionApplId: ' || to_char(p_newRegionApplId));

    IF (r_csr%ISOPEN) THEN
      CLOSE r_csr;
    END IF;

    IF (region_exists%ISOPEN) THEN
      CLOSE region_exists;
    END IF;

  RAISE;
END;

/*
 * Updates the actual region items in the region
 * Assumes all regions and attributes are defined
 * under 672.
 */
PROCEDURE UpdateRegionItems(p_regionCode IN VARCHAR2,
					   p_attributeCode IN VARCHAR2,
					   p_displayFlag IN VARCHAR2,
					   p_mandatoryFlag IN VARCHAR2,
					   p_subRegionCode IN VARCHAR2)
IS

  l_displaySequence NUMBER;
  l_nodeQueryFlag VARCHAR2(1);
  l_attributeLabelLength NUMBER;
  l_bold VARCHAR2(1);
  l_italic VARCHAR2(1);
  l_verticalAlignment VARCHAR2(30);
  l_horizontalAlignment VARCHAR2(30);
  l_itemStyle VARCHAR2(30);
  l_objectAttributeFlag VARCHAR2(1);
  l_attributeLabelLong VARCHAR2(80);
  l_description VARCHAR2(2000);
  l_securityCode VARCHAR2(30);
  l_updateFlag VARCHAR2(1);
  l_requiredFlag VARCHAR2(1);
  l_displayValueLength NUMBER;
  l_lovRegionApplicationId NUMBER;
  l_lovRegionCode VARCHAR2(30);
  l_lovForeignKeyName VARCHAR2(30);
  l_lovAttributeApplicationId NUMBER;
  l_lovAttributeCode VARCHAR2(30);
  l_lovDefaultFlag VARCHAR2(1);
  l_regionDefaultingApiPkg VARCHAR2(30);
  l_regionDefaultingApiProc VARCHAR2(30);
  l_regionValidationApiPkg VARCHAR2(30);
  l_regionValidationApiProc VARCHAR2(30);
  l_orderSequence NUMBER;
  l_orderDirection VARCHAR2(30);
  l_defaultValueVarchar2 VARCHAR2(240);
  l_defaultValueNumber NUMBER;
  l_defaultValueDate DATE;
  l_itemName VARCHAR2(30);
  l_displayHeight NUMBER;
  l_submit VARCHAR2(1);
  l_encrypt VARCHAR2(1);
  l_viewUsageName VARCHAR2(80);
  l_viewAttributeName VARCHAR2(80);
  l_cssClassName VARCHAR2(80);
  l_cssLabelClassName VARCHAR2(80);
  l_url VARCHAR2(2000);
  l_poplistViewObject VARCHAR2(240);
  l_poplistDisplayAttribute VARCHAR2(80);
  l_poplistValueAttribute VARCHAR2(80);
  l_imageFileName VARCHAR2(80);
  l_nestedRegionCode VARCHAR2(30);
  l_nestedRegionApplId NUMBER;
  l_menuName VARCHAR2(30);
  l_flexfieldName VARCHAR2(40);
  l_flexfieldApplicationId NUMBER;
  l_tabularFunctionCode VARCHAR2(30);
  l_tipType VARCHAR2(30);
  l_tipTypeMessageName VARCHAR2(30);
  l_tipMessageApplicationId NUMBER;
  l_flexSegmentList VARCHAR2(4000);
  l_entityId VARCHAR2(30);
  l_anchor VARCHAR2(1);
  l_poplistViewUsageName VARCHAR2(80);
  l_attributeCategory VARCHAR2(30);
  l_attribute1 VARCHAR2(150);
  l_attribute2 VARCHAR2(150);
  l_attribute3 VARCHAR2(150);
  l_attribute4 VARCHAR2(150);
  l_attribute5 VARCHAR2(150);
  l_attribute6 VARCHAR2(150);
  l_attribute7 VARCHAR2(150);
  l_attribute8 VARCHAR2(150);
  l_attribute9 VARCHAR2(150);
  l_attribute10 VARCHAR2(150);
  l_attribute11 VARCHAR2(150);
  l_attribute12 VARCHAR2(150);
  l_attribute13 VARCHAR2(150);
  l_attribute14 VARCHAR2(150);
  l_attribute15 VARCHAR2(150);

  l_subRegionCode VARCHAR2(30) := p_subRegionCode;

BEGIN

   IF (l_subRegionCode is NULL) THEN
	l_subRegionCode := '';
   END IF;

   SELECT a.display_sequence,
		a.node_query_flag,
          a.attribute_label_length,
		a.bold,
		a.italic,
		a.vertical_alignment,
		a.horizontal_alignment,
		a.item_style,
		a.object_attribute_flag,
		b.attribute_label_long,
		b.description,
		a.security_code,
		a.update_flag,
		a.required_flag,
		a.display_value_length,
		a.lov_region_application_id,
		a.lov_region_code,
		a.lov_foreign_key_name,
		a.lov_attribute_application_id,
		a.lov_attribute_code,
		a.lov_default_flag,
		a.region_defaulting_api_pkg,
		a.region_defaulting_api_proc,
		a.region_validation_api_pkg,
		a.region_validation_api_proc,
		a.order_sequence,
		a.order_direction,
		a.default_value_varchar2,
		a.default_value_number,
		a.default_value_date,
		a.item_name,
		a.display_height,
		a.submit,
		a.encrypt,
		a.view_usage_name,
		a.view_attribute_name,
		a.css_class_name,
		a.css_label_class_name,
		a.url,
		a.poplist_viewobject,
		a.poplist_display_attribute,
		a.poplist_value_attribute,
		a.image_file_name,
		a.nested_region_application_id,
		a.nested_region_code,
		a.menu_name,
		a.flexfield_name,
		a.flexfield_application_id,
		a.tabular_function_code,
		a.tip_type,
		a.tip_message_name,
		a.tip_message_application_id,
		a.flex_segment_list,
		a.entity_id,
		a.anchor,
		a.poplist_view_usage_name,
		a.attribute_category,
		a.attribute1,
		a.attribute2,
		a.attribute3,
		a.attribute4,
		a.attribute5,
		a.attribute6,
		a.attribute7,
		a.attribute8,
		a.attribute9,
		a.attribute10,
		a.attribute11,
		a.attribute12,
		a.attribute13,
		a.attribute14,
		a.attribute15
    INTO
		l_displaySequence,
		l_nodeQueryFlag,
		l_attributeLabelLength,
		l_bold,
		l_italic,
		l_verticalAlignment,
		l_horizontalAlignment,
          l_itemStyle,
		l_objectAttributeFlag,
		l_attributeLabelLong,
		l_description,
		l_securityCode,
		l_updateFlag,
		l_requiredFlag,
		l_displayValueLength,
		l_lovRegionApplicationId,
		l_lovRegionCode,
		l_lovForeignKeyName,
		l_lovAttributeApplicationId,
		l_lovAttributeCode,
		l_lovDefaultFlag,
		l_regionDefaultingApiPkg,
		l_regionDefaultingApiProc,
		l_regionValidationApiPkg,
		l_regionValidationApiProc,
		l_orderSequence,
		l_orderDirection,
		l_defaultValueVarchar2,
		l_defaultValueNumber,
		l_defaultValueDate,
		l_itemName,
		l_displayHeight,
		l_submit,
		l_encrypt,
		l_viewUsageName,
		l_viewAttributeName,
		l_cssClassName,
		l_cssLabelClassName,
		l_url,
		l_poplistViewObject,
		l_poplistDisplayAttribute,
		l_poplistValueAttribute,
		l_imageFileName,
		l_nestedRegionApplId,
		l_nestedRegionCode,
		l_menuName,
		l_flexfieldName,
		l_flexfieldApplicationId,
		l_tabularFunctionCode,
		l_tipType,
		l_tipTypeMessageName,
		l_tipMessageApplicationId,
		l_flexSegmentList,
		l_entityId,
	     l_anchor,
		l_poplistViewUsageName,
		l_attributeCategory,
		l_attribute1,
		l_attribute2,
		l_attribute3,
		l_attribute4,
		l_attribute5,
		l_attribute6,
		l_attribute7,
		l_attribute8,
		l_attribute9,
		l_attribute10,
		l_attribute11,
		l_attribute12,
		l_attribute13,
		l_attribute14,
		l_attribute15
    FROM  ak_region_items a,
		ak_region_items_tl b
    WHERE a.region_code = b.region_code
    AND   a.region_application_id = b.region_application_id
    AND   a.attribute_code = b.attribute_code
    AND   a.attribute_application_id = b.attribute_application_id
    AND   b.language = USERENV('LANG')
    AND   a.region_code = p_regionCode
    AND   a.region_application_id = 672
    AND   a.attribute_code = p_attributeCode
    and   a.attribute_application_id = 672
    FOR UPDATE NOWAIT;


   IF (p_subRegionCode is null) THEN

	AK_REGION_ITEMS_PKG.UPDATE_ROW(
	  X_REGION_APPLICATION_ID => 672,
	  X_REGION_CODE => p_regionCode,
	  X_ATTRIBUTE_APPLICATION_ID => 672,
	  X_ATTRIBUTE_CODE => p_attributeCode,
	  X_DISPLAY_SEQUENCE => l_displaySequence,
	  X_NODE_DISPLAY_FLAG => p_displayFlag,
       X_NODE_QUERY_FLAG => l_nodeQueryFlag,
	  X_ATTRIBUTE_LABEL_LENGTH => l_attributeLabelLength,
	  X_BOLD => l_bold,
	  X_ITALIC => l_italic,
	  X_VERTICAL_ALIGNMENT => l_verticalAlignment,
	  X_HORIZONTAL_ALIGNMENT => l_horizontalAlignment,
	  X_ITEM_STYLE => l_itemStyle,
	  X_OBJECT_ATTRIBUTE_FLAG => l_objectAttributeFlag,
	  X_ATTRIBUTE_LABEL_LONG => l_attributeLabelLong,
	  X_DESCRIPTION => l_description,
	  X_SECURITY_CODE => l_securityCode,
	  X_UPDATE_FLAG => l_updateFlag,
	  X_REQUIRED_FLAG => p_mandatoryFlag,
	  X_DISPLAY_VALUE_LENGTH => l_displayValueLength,
	  X_LOV_REGION_APPLICATION_ID => l_lovRegionApplicationId,
	  X_LOV_REGION_CODE => l_lovRegionCode,
	  X_LOV_FOREIGN_KEY_NAME => l_lovForeignKeyName,
	  X_LOV_ATTRIBUTE_APPLICATION_ID => l_lovAttributeApplicationId,
	  X_LOV_ATTRIBUTE_CODE => l_lovAttributeCode,
	  X_LOV_DEFAULT_FLAG => l_lovDefaultFlag,
	  X_REGION_DEFAULTING_API_PKG => l_regionDefaultingApiPkg,
	  X_REGION_DEFAULTING_API_PROC => l_regionDefaultingApiProc,
	  X_REGION_VALIDATION_API_PKG => l_regionValidationApiPkg,
	  X_REGION_VALIDATION_API_PROC => l_regionValidationApiProc,
	  X_ORDER_SEQUENCE => l_orderSequence,
	  X_ORDER_DIRECTION => l_orderDirection,
	  X_DEFAULT_VALUE_VARCHAR2 => l_defaultValueVarchar2,
	  X_DEFAULT_VALUE_NUMBER => l_defaultValueNumber,
	  X_DEFAULT_VALUE_DATE => l_defaultValueDate,
	  X_ITEM_NAME => l_itemName,
	  X_DISPLAY_HEIGHT => l_displayHeight,
	  X_SUBMIT => l_submit,
	  X_ENCRYPT => l_encrypt,
	  X_VIEW_USAGE_NAME => l_viewUsageName,
	  X_VIEW_ATTRIBUTE_NAME => l_viewAttributeName,
	  X_CSS_CLASS_NAME => l_cssClassName,
	  X_CSS_LABEL_CLASS_NAME => l_cssLabelClassName,
	  X_URL => l_url,
	  X_POPLIST_VIEWOBJECT => l_poplistViewObject,
	  X_POPLIST_DISPLAY_ATTRIBUTE => l_poplistDisplayAttribute,
	  X_POPLIST_VALUE_ATTRIBUTE => l_poplistValueAttribute,
	  X_IMAGE_FILE_NAME => l_imageFileName,
	  X_NESTED_REGION_CODE => l_nestedRegionCode,
	  X_NESTED_REGION_APPL_ID => l_nestedRegionApplId,
	  X_MENU_NAME => l_menuName,
	  X_FLEXFIELD_NAME => l_flexfieldName,
	  X_FLEXFIELD_APPLICATION_ID => l_flexfieldApplicationId,
	  X_TABULAR_FUNCTION_CODE => l_tabularFunctionCode,
	  X_TIP_TYPE => l_tipType,
	  X_TIP_MESSAGE_NAME => l_tipTypeMessageName,
	  X_TIP_MESSAGE_APPLICATION_ID => l_tipMessageApplicationId,
	  X_FLEX_SEGMENT_LIST => l_flexSegmentList,
	  X_ENTITY_ID => l_entityId,
	  X_ANCHOR => l_anchor,
	  X_POPLIST_VIEW_USAGE_NAME => l_poplistViewUsageName,
	  X_LAST_UPDATE_DATE => sysdate,
	  X_LAST_UPDATED_BY => fnd_load_util.owner_id('ORACLE'),
	  X_LAST_UPDATE_LOGIN => 0,
	  X_ATTRIBUTE_CATEGORY => l_attributeCategory,
	  X_ATTRIBUTE1 => l_attribute1,
	  X_ATTRIBUTE2 => l_attribute2,
	  X_ATTRIBUTE3 => l_attribute3,
	  X_ATTRIBUTE4 => l_attribute4,
	  X_ATTRIBUTE5 => l_attribute5,
	  X_ATTRIBUTE6 => l_attribute6,
	  X_ATTRIBUTE7 => l_attribute7,
	  X_ATTRIBUTE8 => l_attribute8,
	  X_ATTRIBUTE9 => l_attribute9,
	  X_ATTRIBUTE10 => l_attribute10,
	  X_ATTRIBUTE11 => l_attribute11,
	  X_ATTRIBUTE12 => l_attribute12,
	  X_ATTRIBUTE13 => l_attribute13,
	  X_ATTRIBUTE14 => l_attribute14,
	  X_ATTRIBUTE15 => l_attribute15);
   ELSE
	AK_REGION_ITEMS_PKG.UPDATE_ROW(
	  X_REGION_APPLICATION_ID => 672,
	  X_REGION_CODE => p_regionCode,
	  X_ATTRIBUTE_APPLICATION_ID => 672,
	  X_ATTRIBUTE_CODE => p_attributeCode,
	  X_DISPLAY_SEQUENCE => l_displaySequence,
	  X_NODE_DISPLAY_FLAG => p_displayFlag,
       X_NODE_QUERY_FLAG => l_nodeQueryFlag,
	  X_ATTRIBUTE_LABEL_LENGTH => l_attributeLabelLength,
	  X_BOLD => l_bold,
	  X_ITALIC => l_italic,
	  X_VERTICAL_ALIGNMENT => l_verticalAlignment,
	  X_HORIZONTAL_ALIGNMENT => l_horizontalAlignment,
	  X_ITEM_STYLE => l_itemStyle,
	  X_OBJECT_ATTRIBUTE_FLAG => l_objectAttributeFlag,
	  X_ATTRIBUTE_LABEL_LONG => l_attributeLabelLong,
	  X_DESCRIPTION => l_description,
	  X_SECURITY_CODE => l_securityCode,
	  X_UPDATE_FLAG => l_updateFlag,
	  X_REQUIRED_FLAG => p_mandatoryFlag,
	  X_DISPLAY_VALUE_LENGTH => l_displayValueLength,
	  X_LOV_REGION_APPLICATION_ID => l_lovRegionApplicationId,
	  X_LOV_REGION_CODE => l_lovRegionCode,
	  X_LOV_FOREIGN_KEY_NAME => l_lovForeignKeyName,
	  X_LOV_ATTRIBUTE_APPLICATION_ID => l_lovAttributeApplicationId,
	  X_LOV_ATTRIBUTE_CODE => l_lovAttributeCode,
	  X_LOV_DEFAULT_FLAG => l_lovDefaultFlag,
	  X_REGION_DEFAULTING_API_PKG => l_regionDefaultingApiPkg,
	  X_REGION_DEFAULTING_API_PROC => l_regionDefaultingApiProc,
	  X_REGION_VALIDATION_API_PKG => l_regionValidationApiPkg,
	  X_REGION_VALIDATION_API_PROC => l_regionValidationApiProc,
	  X_ORDER_SEQUENCE => l_orderSequence,
	  X_ORDER_DIRECTION => l_orderDirection,
	  X_DEFAULT_VALUE_VARCHAR2 => l_defaultValueVarchar2,
	  X_DEFAULT_VALUE_NUMBER => l_defaultValueNumber,
	  X_DEFAULT_VALUE_DATE => l_defaultValueDate,
	  X_ITEM_NAME => l_itemName,
	  X_DISPLAY_HEIGHT => l_displayHeight,
	  X_SUBMIT => l_submit,
	  X_ENCRYPT => l_encrypt,
	  X_VIEW_USAGE_NAME => l_viewUsageName,
	  X_VIEW_ATTRIBUTE_NAME => l_viewAttributeName,
	  X_CSS_CLASS_NAME => l_cssClassName,
	  X_CSS_LABEL_CLASS_NAME => l_cssLabelClassName,
	  X_URL => l_url,
	  X_POPLIST_VIEWOBJECT => l_poplistViewObject,
	  X_POPLIST_DISPLAY_ATTRIBUTE => l_poplistDisplayAttribute,
	  X_POPLIST_VALUE_ATTRIBUTE => l_poplistValueAttribute,
	  X_IMAGE_FILE_NAME => l_imageFileName,
	  X_NESTED_REGION_CODE => p_subRegionCode,
	  X_NESTED_REGION_APPL_ID => 672,
	  X_MENU_NAME => l_menuName,
	  X_FLEXFIELD_NAME => l_flexfieldName,
	  X_FLEXFIELD_APPLICATION_ID => l_flexfieldApplicationId,
	  X_TABULAR_FUNCTION_CODE => l_tabularFunctionCode,
	  X_TIP_TYPE => l_tipType,
	  X_TIP_MESSAGE_NAME => l_tipTypeMessageName,
	  X_TIP_MESSAGE_APPLICATION_ID => l_tipMessageApplicationId,
	  X_FLEX_SEGMENT_LIST => l_flexSegmentList,
	  X_ENTITY_ID => l_entityId,
	  X_ANCHOR => l_anchor,
	  X_POPLIST_VIEW_USAGE_NAME => l_poplistViewUsageName,
	  X_LAST_UPDATE_DATE => sysdate,
	  X_LAST_UPDATED_BY => fnd_load_util.owner_id('ORACLE'),
	  X_LAST_UPDATE_LOGIN => 0,
	  X_ATTRIBUTE_CATEGORY => l_attributeCategory,
	  X_ATTRIBUTE1 => l_attribute1,
	  X_ATTRIBUTE2 => l_attribute2,
	  X_ATTRIBUTE3 => l_attribute3,
	  X_ATTRIBUTE4 => l_attribute4,
	  X_ATTRIBUTE5 => l_attribute5,
	  X_ATTRIBUTE6 => l_attribute6,
	  X_ATTRIBUTE7 => l_attribute7,
	  X_ATTRIBUTE8 => l_attribute8,
	  X_ATTRIBUTE9 => l_attribute9,
	  X_ATTRIBUTE10 => l_attribute10,
	  X_ATTRIBUTE11 => l_attribute11,
	  X_ATTRIBUTE12 => l_attribute12,
	  X_ATTRIBUTE13 => l_attribute13,
	  X_ATTRIBUTE14 => l_attribute14,
	  X_ATTRIBUTE15 => l_attribute15);

   END IF;

   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UTL_UPG_PKG.UpdateRegionItems', 'Updating region items for p_regionCode: ' || p_regionCode || ' p_attributeCode: ' || p_attributeCode );

   log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UTL_UPG_PKG.UpdateRegionItems', ' p_displayFlag: ' || p_displayFlag || ' p_mandatoryFlag: ' || p_mandatoryFlag || ' p_subRegionCode: ' || l_subRegionCode);

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UTL_UPG_PKG.UpdateRegionItems', 'Exception for p_regionCode: ' || p_regionCode || ' p_attributeCode: ' || p_attributeCode );
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UTL_UPG_PKG.UpdateRegionItems', ' p_displayFlag: ' || p_displayFlag || ' p_mandatoryFlag: ' || p_mandatoryFlag || ' p_subRegionCode: ' || l_subRegionCode);
  RAISE;
END UpdateRegionItems;

PROCEDURE getAddressProfileValues(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
                                  p_displayBillToAddress IN OUT NOCOPY VARCHAR2,
                                  p_displayBillToContact IN OUT NOCOPY VARCHAR2,
                                  p_displayShipToAddress IN OUT NOCOPY VARCHAR2,
                                  p_displayShipToContact IN OUT NOCOPY VARCHAR2,
                                  p_displayInstalledAtAddr IN OUT NOCOPY VARCHAR2,
                                  p_displayIncidentAddr IN OUT NOCOPY VARCHAR2,
                                  p_mandatoryIncidentAddr IN OUT NOCOPY VARCHAR2)
IS
  l_count NUMBER := p_ProfileTable.COUNT;
  l_index NUMBER := 0;
  l_profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE;

  l_examineBillToAddress BOOLEAN := TRUE;
  l_examineBillToContact BOOLEAN := TRUE;
  l_examineShipToAddress BOOLEAN := TRUE;
  l_examineShipToContact BOOLEAN := TRUE;
  l_examineInstalledAtAddress BOOLEAN := TRUE;
  l_examineAddrDisplay BOOLEAN := TRUE;
  l_examineAddrMandatory BOOLEAN := TRUE;

BEGIN

  WHILE (l_index < l_count) LOOP
    l_profileOptionName := p_ProfileTable(l_index).profileOptionName;
    IF (l_profileOptionName = 'IBU_A_SR_BILLTO_ADDRESS_OPTION' AND
	   l_examineBillToAddress) THEN
	 p_displayBillToAddress := p_ProfileTable(l_index).profileOptionValue;
	 l_examineBillToAddress := FALSE;
    ELSIF (l_profileOptionName = 'IBU_A_SR_BILLTO_CONTACT_OPTION' AND
	   l_examineBillToContact) THEN
	 p_displayBillToContact := p_ProfileTable(l_index).profileOptionValue;
	 l_examineBillToContact := FALSE;
    ELSIF (l_profileOptionName = 'IBU_A_SR_SHIPTO_ADDRESS_OPTION' AND
	 l_examineShipToAddress) THEN
	 p_displayShipToAddress := p_ProfileTable(l_index).profileOptionValue;
	 l_examineShipToAddress := FALSE;
    ELSIF (l_profileOptionName = 'IBU_A_SR_SHIPTO_CONTACT_OPTION' AND
	 l_examineShipToContact) THEN
	 p_displayShipToContact := p_ProfileTable(l_index).profileOptionValue;
	 l_examineShipToContact := FALSE;
    ELSIF (l_profileOptionName = 'IBU_A_SR_INSTALLEDAT_ADDRESS_OPTION' AND
	 l_examineInstalledAtAddress) THEN
	 p_displayInstalledAtAddr := p_ProfileTable(l_index).profileOptionValue;
	 l_examineInstalledAtAddress := FALSE;
    ELSIF (l_profileOptionName = 'IBU_SR_ADDR_DISPLAY' AND
	 l_examineAddrDisplay) THEN
	 p_displayIncidentAddr := p_ProfileTable(l_index).profileOptionValue;
	 l_examineAddrDisplay := FALSE;
    ELSIF (l_profileOptionName = 'IBU_SR_ADDR_MANDATORY' AND
	 l_examineAddrMandatory) THEN
      p_mandatoryIncidentAddr := p_ProfileTable(l_index).profileOptionValue;
	 l_examineAddrMandatory := FALSE;
    END IF;
    l_index := l_index + 1;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:getAddressProfileOptions', 'Unexpected exception in getAddressProfileOptions');
    RAISE;

END getAddressProfileValues;

PROCEDURE getAttachmentProbCodeValues(p_ProfileTable IN CS_CF_UPG_UTL_PKG.ProfileTable,
                                  p_displayAttachment IN OUT NOCOPY VARCHAR2,
                                  p_mandatoryProblemCode IN OUT NOCOPY VARCHAR2)
IS
  l_count NUMBER := p_ProfileTable.COUNT;
  l_index NUMBER := 0;
  l_profileOptionName FND_PROFILE_OPTIONS.profile_option_name%TYPE;

  l_examineAttachment BOOLEAN := TRUE;
  l_examineProbCode BOOLEAN := TRUE;

BEGIN

  WHILE (l_index < l_count) LOOP
    l_profileOptionName := p_ProfileTable(l_index).profileOptionName;
    IF (l_profileOptionName = 'IBU_A_SR_PROB_CODE_MANDATORY' AND
	   l_examineProbCode) THEN
	 p_mandatoryProblemCode := p_ProfileTable(l_index).profileOptionValue;
	 l_examineProbCode := FALSE;
    ELSIF (l_profileOptionName = 'IBU_A_SR_ATTACHMENT_OPTION' AND
	   l_examineAttachment) THEN
	 p_displayAttachment := p_ProfileTable(l_index).profileOptionValue;
	 l_examineAttachment:= FALSE;
    END IF;
    l_index := l_index + 1;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:getAttachmentProbCodeValues', 'Unexpected exception in getAttachmentProbCodeValues');
    RAISE;

END getAttachmentProbCodeValues;

PROCEDURE setup_log(p_filename IN VARCHAR2)
IS
BEGIN
  FND_FILE.PUT_NAMES(p_filename || '.log', p_filename || '.out',
    get_log_directory);


  FND_FILE.PUT_LINE(FND_FILE.LOG, '*** THIS FILE IS GENERATED BY ORACLE ISUPPORT UPGRADE PROCEDURE. IT IS INTENDED FOR DEVELOPMENT USE. *** ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '*** PLEASE DO NOT DISCARD. THIS FILE MAY BE REFERENCED IN THE FUTURE TO DIAGNOSE ISSUES EXPERIENCED BY THE CUSTOMER.  *** ');

  FND_FILE.PUT_LINE(FND_FILE.LOG, '');

  log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG:setup_log', 'System time at the start of the upgrade process is: ' || fnd_date.date_to_charDT(sysdate));

END setup_log;


PROCEDURE log_mesg(p_level IN NUMBER,
			    p_module IN VARCHAR2,
			    p_text IN VARCHAR2)
IS
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || '- ' || p_text);
  --DBMS_OUTPUT.PUT_LINE(p_module || '-' || p_text);

/*
  IF (p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(p_level, p_module, p_text);
  END IF;
*/
END log_mesg;

PROCEDURE wrapup(p_status IN VARCHAR2)
IS
BEGIN
  IF (p_status = 'SUCCESS') THEN
    log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.wrapup', 'Upgrade process completed at: ' || fnd_date.date_to_charDT(sysdate));
  ELSIF (p_status = 'ERROR') THEN
    log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.wrapup', 'Upgrade process terminated at: ' || fnd_date.date_to_charDT(sysdate));
  END IF;

End wrapup;

FUNCTION get_log_directory return VARCHAR2
IS

  utl_file_dir varchar2(2000);
  l_start number := 1;
  l_end number := 1;
  l_val varchar2(512);
BEGIN
  -- We use v$parameter to determine the utl_file_dir
  SELECT value || ',' into utl_file_dir
  FROM v$parameter
  WHERE name = 'utl_file_dir';

  -- We just pick the first one from the list
  l_end := instr(utl_file_dir, ',', l_start) - 1;
  l_val := substr(utl_file_dir, l_start, l_end - l_start + 1);

  return l_val;
END get_log_directory;


FUNCTION Regions_Not_Already_Cloned(p_suffix IN VARCHAR2) RETURN BOOLEAN
IS

  l_count number := 0;
BEGIN
  SELECT count(*) INTO l_count
  FROM ak_regions
  WHERE region_code in ('IBU_CF_SR_10_'|| p_suffix,
                        'IBU_CF_SR_20_' || p_suffix,
                        'IBU_CF_SR_30_' || p_suffix,
                        'IBU_CF_SR_40_' || p_suffix,
                        'IBU_CF_SR_50_' || p_suffix,
                        'IBU_CF_SR_60_' || p_suffix,
                        'IBU_CF_SR_70_' || p_suffix,
                        'IBU_CF_SR_80_' || p_suffix,
                        'IBU_CF_SR_90_' || p_suffix,
                        'IBU_CF_SR_110_' || p_suffix,
                        'IBU_CF_SR_120_' || p_suffix,
                        'IBU_CF_SR_130_' || p_suffix,
                        'IBU_CF_SR_140_' || p_suffix,
                        'IBU_CF_SR_150_' || p_suffix,
                        'IBU_CF_SR_160_' || p_suffix,
                        'IBU_CF_SR_170_' || p_suffix,
                        'IBU_CF_SR_180_' || p_suffix,
                        'IBU_CF_SR_190_' || p_suffix,
                        'IBU_CF_SR_200_' || p_suffix,
                        'IBU_CF_SR_210_' || p_suffix,
                        'IBU_CF_SR_220_' || p_suffix,
                        'IBU_CF_SR_230_' || p_suffix,
                        'IBU_CF_SR_240_' || p_suffix,
                        'IBU_CF_SR_310_' || p_suffix,
                        'IBU_CF_SR_320_' || p_suffix,
                        'IBU_CF_SR_410_' || p_suffix,
                        'IBU_CF_SR_420_' || p_suffix,
                        'IBU_CF_SR_430_' || p_suffix,
                        'IBU_CF_SR_440_' || p_suffix,
                        'IBU_CF_SR_450_' || p_suffix);

  IF (l_count > 0) THEN
    return FALSE;
  ELSE
    return TRUE;
  END IF;
END Regions_Not_Already_Cloned ;

-- mkcyee 02/25/2004 - added to check if flow has already been cloned
FUNCTION Flows_Not_Already_Cloned(p_flowId IN NUMBER) RETURN BOOLEAN
IS

  l_count number := 0;
  l_flowId NUMBER := 0-p_flowId;
  b_success BOOLEAN;

  CURSOR l_cur (flowId IN NUMBER) IS
  SELECT count(*)
  FROM cs_cf_flows_b
  WHERE flow_id = flowId;

BEGIN

  OPEN l_cur(l_flowId);
  FETCH l_cur INTO l_count;
  CLOSE l_cur;

  IF (l_count > 0) THEN
    return FALSE;
  ELSE
    return TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG: Flows_Not_Already_Cloned', ' Unexpected exception in Flows_Not_Already_Cloned');
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG: Flows_Not_Already_Cloned', ' p_flowId = ' + to_char(p_flowId));

    IF (l_cur%ISOPEN) THEN
      CLOSE l_cur;
    END IF;
    RAISE;

END Flows_Not_Already_Cloned ;


-- mkcyee 02/24/04 - added to check if config profile option has been customized
-- mkcyee 01/03/06 - fix bug 4887917
FUNCTION configProfileCustomized RETURN BOOLEAN IS

CURSOR l_cur IS
SELECT b.last_updated_by
FROM fnd_profile_options a, fnd_profile_option_values b
WHERE a.profile_option_id = b.profile_option_id
AND   a.profile_option_name = 'IBU_REGION_FIELD_CONFIG_OPTION'
AND   B.LEVEL_ID = 10001
AND   A.APPLICATION_ID = 672
AND   A.APPLICATION_ID = B.APPLICATION_ID;

l_lub NUMBER;
b_success BOOLEAN;

BEGIN

  OPEN l_cur;
  FETCH l_cur INTO l_lub;

  b_success := l_cur%FOUND;
  IF (NOT b_success) THEN
    log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG:configProfileCustomized', ' Could not find configuration profile');
    CLOSE l_cur;
    RAISE PROGRAM_ERROR;
  ELSE
    CLOSE l_cur;
    IF (l_lub in (-1,1,2)) THEN
      RETURN false;
    ELSE
      RETURN true;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG: configProfileCustomized', ' Unexpected exception in configProfileCustomized');
    IF (l_cur%ISOPEN) THEN
      CLOSE l_cur;
    END IF;
    RAISE;


END configProfileCustomized;


/*
 * mkcyee 02/25/2004 - Create new function to clone a flow
 * p_newFlowId is the flow id of the newly cloned flow
 * p_flowId is the flow that we want to clone
 */

PROCEDURE Clone_Flow(p_newFlowId in NUMBER, p_flowId in NUMBER) IS

l_flow_rec cs_cf_flows_vl%rowtype;
l_page_rec cs_cf_flow_pages_vl%rowtype;

l_newFlowId NUMBER := 0-p_newFlowId;
l_rowid VARCHAR2(50);

CURSOR l_flow_cur(l_flowId IN NUMBER) IS
SELECT *
FROM cs_cf_flows_vl
WHERE flow_id = l_flowId;

CURSOR l_page_cur(l_flowId IN NUMBER) IS
SELECT *
FROM cs_cf_flow_pages_vl
WHERE flow_id = l_flowId;

b_success BOOLEAN;
l_created_by NUMBER := fnd_load_util.owner_id('ORACLE');

BEGIN

  log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Clone_Flow', ' Cloning Flow for p_newFlowId = ' || to_char(p_newFlowId));
  log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Clone_Flow', ' Cloning Flow for p_flowId = ' || to_char(p_flowId));

  OPEN l_flow_cur(p_flowId);
  FETCH l_flow_cur INTO l_flow_rec;

  b_success := l_flow_cur%FOUND;
  IF (NOT b_success) THEN
    log_mesg(FND_LOG.LEVEL_STATEMENT, 'CS_CF_UPG_UTL_PKG.Clone_Flow', ' Could not successfully execute cursor! ');
    close l_flow_cur;
    RAISE PROGRAM_ERROR;
  ELSE
    close l_flow_cur;

    -- mkcyee 02/26/2004 - we need to supply a unique flow display name for the
    -- cloned flow because we have a unique index defined on flow_display_name
    -- and language on the table CS_CF_FLOWS_TL
    CS_CF_FLOWS_PKG.Insert_Row(X_ROWID => l_rowid,
                               X_FLOW_ID => l_newFlowId,
                               X_FLOW_TYPE_CODE => l_flow_rec.flow_type_code,
                               X_FLOW_DISPLAY_NAME => 'Cloned Flow for Flow Id: ' || to_char(p_newFlowId),
                               X_OBJECT_VERSION_NUMBER => 1,
                               X_ATTRIBUTE_CATEGORY => l_flow_rec.attribute_category,
                               X_ATTRIBUTE1 => l_flow_rec.attribute1,
                               X_ATTRIBUTE2 => l_flow_rec.attribute2,
                               X_ATTRIBUTE3 => l_flow_rec.attribute3,
                               X_ATTRIBUTE4 => l_flow_rec.attribute4,
                               X_ATTRIBUTE5 => l_flow_rec.attribute5,
                               X_ATTRIBUTE6 => l_flow_rec.attribute6,
                               X_ATTRIBUTE7 => l_flow_rec.attribute7,
                               X_ATTRIBUTE8 => l_flow_rec.attribute8,
                               X_ATTRIBUTE9 => l_flow_rec.attribute9,
                               X_ATTRIBUTE10 => l_flow_rec.attribute10,
                               X_ATTRIBUTE11 => l_flow_rec.attribute11,
                               X_ATTRIBUTE12 => l_flow_rec.attribute12,
                               X_ATTRIBUTE13 => l_flow_rec.attribute13,
                               X_ATTRIBUTE14 => l_flow_rec.attribute14,
                               X_ATTRIBUTE15 => l_flow_rec.attribute15,
                               X_SEEDED_FLAG => 'N',
                               X_CREATION_DATE => sysdate,
                               X_CREATED_BY => l_created_by,
                               X_LAST_UPDATE_DATE => sysdate,
                               X_LAST_UPDATED_BY => l_created_by,
                               X_LAST_UPDATE_LOGIN => 0);


    OPEN l_page_cur(p_flowId);
    FETCH l_page_cur INTO l_page_rec;

    WHILE l_page_cur%FOUND LOOP
      CS_CF_FLOW_PAGES_PKG.INSERT_ROW(X_ROWID => l_rowid,
                          X_FLOW_ID => l_newFlowId,
                          X_FLOW_TYPE_PAGE_ID => l_page_rec.flow_type_page_id,
                          X_ENABLED_FLAG => l_page_rec.enabled_flag,
                          X_OBJECT_VERSION_NUMBER => 1,
                          X_ATTRIBUTE_CATEGORY => l_page_rec.attribute_category,
                          X_ATTRIBUTE1 => l_page_rec.attribute1,
                          X_ATTRIBUTE2 => l_page_rec.attribute2,
                          X_ATTRIBUTE3 => l_page_rec.attribute3,
                          X_ATTRIBUTE4 => l_page_rec.attribute4,
                          X_ATTRIBUTE5 => l_page_rec.attribute5,
                          X_ATTRIBUTE6 => l_page_rec.attribute6,
                          X_ATTRIBUTE7 => l_page_rec.attribute7,
                          X_ATTRIBUTE8 => l_page_rec.attribute8,
                          X_ATTRIBUTE9 => l_page_rec.attribute9,
                          X_ATTRIBUTE10 => l_page_rec.attribute10,
                          X_ATTRIBUTE11 => l_page_rec.attribute11,
                          X_ATTRIBUTE12 => l_page_rec.attribute12,
                          X_ATTRIBUTE13 => l_page_rec.attribute13,
                          X_ATTRIBUTE14 => l_page_rec.attribute14,
                          X_ATTRIBUTE15 => l_page_rec.attribute15,
                          X_PAGE_DISPLAY_NAME => l_page_rec.page_display_name,
                          X_CREATION_DATE => sysdate,
                          X_CREATED_BY => l_created_by,
                          X_LAST_UPDATE_DATE => sysdate,
                          X_LAST_UPDATED_BY => l_created_by,
                          X_LAST_UPDATE_LOGIN => 0);

      FETCH l_page_cur INTO l_page_rec;
    END LOOP;
    CLOSE l_page_cur;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_UTL_PKG:Clone_Flow',
	 'Unexpected exception - p_newFlowId:  ' || to_char(p_newFlowId) || ' p_flowId: ' || to_char(p_flowId));

    IF (l_page_cur%ISOPEN) THEN
	 CLOSE l_page_cur;
    END IF;

    IF (l_flow_cur%ISOPEN) THEN
	 CLOSE l_flow_cur;
    END IF;

    RAISE;

END Clone_Flow;

END CS_CF_UPG_UTL_PKG;

/
