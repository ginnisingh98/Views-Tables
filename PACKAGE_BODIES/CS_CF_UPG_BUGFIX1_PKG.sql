--------------------------------------------------------
--  DDL for Package Body CS_CF_UPG_BUGFIX1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CF_UPG_BUGFIX1_PKG" as
/* $Header: cscfupg2b.pls 120.0 2005/06/01 12:05:33 appldev noship $ */


PROCEDURE Main IS

  l_logfilename VARCHAR2(2000) := '';

BEGIN

    -- generate a suffix to the filename
    select to_char(sysdate, 'mm-dd-yy') || to_char(sysdate, 'hh24:mi:ss')
    into l_logfilename
    from dual;

    CS_CF_UPG_UTL_PKG.setup_log('IBUCFUPG-' || l_logfilename);

    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_BUGFIX1_PKG.Main', 'Starting bugfix1 procedure');
    Fix_Regions_Bugfix1('R');
    Fix_Regions_Bugfix1('A');
    Fix_Regions_Bugfix1('GC');

    CS_CF_UPG_UTL_PKG.wrapup('SUCCESS');

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.wrapup('ERROR');
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_BUGFIX1_PKG.Main','Exception raised in Main');
    RAISE;
End Main;

PROCEDURE Fix_Regions_Bugfix1(p_contextType IN VARCHAR2) IS

  l_region_code AK_REGIONS.region_code%TYPE;
  l_newRegionCode AK_REGIONS.region_code%TYPE;
  l_suffix VARCHAR2(2000);
  l_node_display_flag AK_REGION_ITEMS.node_display_flag%TYPE;
  l_required_flag AK_REGION_ITEMS.required_flag%TYPE;
  l_count NUMBER := 0;

  CURSOR get_regions (p_region_code IN VARCHAR2, p_suffix IN VARCHAR2) IS
  SELECT region_code
  FROM ak_regions
  WHERE region_code like p_region_code || p_suffix || '%';


  CURSOR region_exist (p_region_code IN VARCHAR2) IS
  SELECT count(*)
  FROM ak_regions where region_code = p_region_code;

  CURSOR get_display_attributes(p_region_code IN VARCHAR2, p_region_application_id IN VARCHAR2,
                                p_attribute_code IN VARCHAR2, p_attribute_application_id IN VARCHAR2) IS
  SELECT node_display_flag, required_flag
  FROM ak_region_items
  WHERE region_code = p_region_code
  AND   region_application_id = p_region_application_id
  AND   attribute_code = p_attribute_code
  AND   attribute_application_id = p_attribute_application_id;



BEGIN

    -- Find out if there are any regions cloned for IBU_CF_SR_30_G
    -- for corresponding level

    OPEN get_regions('IBU_CF_SR_30_',p_contextType);
    FETCH get_regions INTO l_region_code;
    WHILE get_regions%FOUND LOOP
      -- get the resp id/appl from the suffix
      IF (p_contextType <> 'GC') THEN
        l_suffix := substr(l_region_code, 15);
      ELSE
        l_suffix := '';
      END IF;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_BUGFIX1_PKG.Fix_Regions_Bugfix1', 'Fixing for IBU_CF_SR_30_X suffix:' || p_contextType || l_suffix);

      l_newRegionCode := 'IBU_CF_SR_35_' || p_contextType || l_suffix;

      OPEN region_exist('IBU_CF_SR_35_' || p_contextType || l_suffix);
      FETCH region_exist INTO l_count;
      CLOSE region_exist;

      IF (l_count = 0) THEN
        CS_CF_UPG_UTL_PKG.Clone_Region(l_region_code,
                                      672,
                                     l_newRegionCode,
                                     672, TRUE);

        OPEN get_display_attributes(l_region_code, 672,
                                  'IBU_CF_SR_ALL_PRODUCT_RG', 672);
        FETCH get_display_attributes INTO l_node_display_flag, l_required_flag;
        CLOSE get_display_attributes;
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newRegionCode,
                                          'IBU_CF_SR_ALL_PRODUCT_RG',
                                          l_node_display_flag,
                                          l_required_flag,
                                          'IBU_CF_SR_ALL_PRODUCT');
        OPEN get_display_attributes(l_region_code, 672,
                                  'IBU_CF_SR_REG_PRODUCT_RG', 672);
        FETCH get_display_attributes INTO l_node_display_flag, l_required_flag;
        CLOSE get_display_attributes;
        CS_CF_UPG_UTL_PKG.UpdateRegionItems(l_newRegionCode,
                                          'IBU_CF_SR_REG_PRODUCT_RG',
                                          l_node_display_flag,
                                          l_required_flag,
                                          'IBU_CF_SR_REG_PRODUCT');
        -- For Create/Update template, set the nested_region_code to point to this
        -- newly cloned region.

        OPEN region_exist('IBU_CF_SR_310_' || p_contextType || l_suffix);
        FETCH region_exist INTO l_count;
        CLOSE region_exist;

        IF (l_count > 0) THEN
          OPEN get_display_attributes('IBU_CF_SR_310_' || p_contextType||l_suffix, 672,
                                  'IBU_CF_SR_IDENTIFY_PRODUCT_RG', 672);
          FETCH get_display_attributes INTO l_node_display_flag, l_required_flag;
          CLOSE get_display_attributes;

          CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_310_' || p_contextType||l_suffix,
                                          'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
                                          l_node_display_flag,
                                          l_required_flag,
                                          'IBU_CF_SR_35_' || p_contextType||l_suffix);
        END IF;

        OPEN region_exist('IBU_CF_SR_320_' || p_contextType || l_suffix);
        FETCH region_exist INTO l_count;
        CLOSE region_exist;

        IF (l_count > 0) THEN
          OPEN get_display_attributes('IBU_CF_SR_320_' || p_contextType||l_suffix, 672,
                                  'IBU_CF_SR_IDENTIFY_PRODUCT_RG', 672);
          FETCH get_display_attributes INTO l_node_display_flag, l_required_flag;
          CLOSE get_display_attributes;

          CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_320_'|| p_contextType||l_suffix,
                                          'IBU_CF_SR_IDENTIFY_PRODUCT_RG',
                                          l_node_display_flag,
                                          l_required_flag,
                                          'IBU_CF_SR_35_'|| p_contextType||l_suffix);

        END IF;
      END IF; -- end if IBU_CF_SR_35_XX doesn't exist

      OPEN region_exist('IBU_CF_SR_420_' || p_contextType|| l_suffix);
      FETCH region_exist INTO l_count;
      CLOSE region_exist;

      IF (l_count > 0) THEN
        OPEN get_display_attributes('IBU_CF_SR_420_'|| p_contextType||l_suffix, 672,
                                  'IBU_CF_SR_ALL_PRODUCT_RG', 672);
        FETCH get_display_attributes INTO l_node_display_flag, l_required_flag;
        CLOSE get_display_attributes;
        CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_420_' || p_contextType|| l_suffix,
                                          'IBU_CF_SR_ALL_PRODUCT_RG',
                                          l_node_display_flag,
                                          l_required_flag,
                                          'IBU_CF_SR_ALL_PRODUCT');
        OPEN get_display_attributes('IBU_CF_SR_420_'|| p_contextType||l_suffix, 672,
                                  'IBU_CF_SR_REG_PRODUCT_RG', 672);
        FETCH get_display_attributes INTO l_node_display_flag, l_required_flag;
        CLOSE get_display_attributes;
        CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_420_' || p_contextType|| l_suffix,
                                          'IBU_CF_SR_REG_PRODUCT_RG',
                                          l_node_display_flag,
                                          l_required_flag,
                                          'IBU_CF_SR_REG_PRODUCT');
      END IF; -- end if l_count > 0
      FETCH get_regions INTO l_region_code;
    END LOOP;
    CLOSE get_regions;

    -- Find out if there are any regions cloned for IBU_CF_SR_130_G (Update SR Overview)
    -- for corresponding level. We need to set the address region to IBU_CF_SR_25_G

    OPEN get_regions('IBU_CF_SR_130_',p_contextType);
    FETCH get_regions INTO l_region_code;
    WHILE get_regions%FOUND LOOP
      -- get the resp id/appl from the suffix
      IF (p_contextType <> 'GC') THEN
        l_suffix := substr(l_region_code, 16);
      ELSE
        l_suffix := '';
      END IF;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_BUGFIX1_PKG.Fix_Regions_Bugfix1', 'Fixing for IBU_CF_SR_130_X suffix:' || p_contextType || l_suffix);

      OPEN region_exist('IBU_CF_SR_25_' || p_contextType || l_suffix);
      FETCH region_exist INTO l_count;
      CLOSE region_exist;

      IF (l_count = 0) THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_130_' || p_contextType || l_suffix,
                                          'IBU_CF_SR_ADDRESS_RG',
                                          'N', 'N', 'IBU_CF_SR_25_G');
      ELSE
        CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_130_' || p_contextType || l_suffix,
                                          'IBU_CF_SR_ADDRESS_RG',
                                          'N', 'N', 'IBU_CF_SR_25_'||p_contextType||l_suffix);
      END IF;
      FETCH get_regions INTO l_region_code;
    END LOOP;
    CLOSE get_regions;

    -- Find out if there are any regions cloned for IBU_CF_SR_210_G (Update SR Contacts)
    -- for corresponding level. We need to set the address region to IBU_CF_SR_25_G

    OPEN get_regions('IBU_CF_SR_210_',p_contextType);
    FETCH get_regions INTO l_region_code;
    WHILE get_regions%FOUND LOOP
      -- get the resp id/appl from the suffix
      IF (p_contextType <> 'GC') THEN
        l_suffix := substr(l_region_code, 16);
      ELSE
        l_suffix := '';
      END IF;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_BUGFIX1_PKG.Fix_Regions_Bugfix1', 'Fixing for IBU_CF_SR_210_X suffix:' || p_contextType || l_suffix);

      OPEN region_exist('IBU_CF_SR_25_' || p_contextType || l_suffix);
      FETCH region_exist INTO l_count;
      CLOSE region_exist;

      IF (l_count = 0) THEN
        CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_210_' || p_contextType || l_suffix,
                                          'IBU_CF_SR_ADDRESS_RG',
                                          'Y', 'N', 'IBU_CF_SR_25_G');
      ELSE
        CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_210_' || p_contextType || l_suffix,
                                          'IBU_CF_SR_ADDRESS_RG',
                                          'Y', 'N', 'IBU_CF_SR_25_' || p_contextType || l_suffix);
      END IF;
      FETCH get_regions INTO l_region_code;
    END LOOP;
    CLOSE get_regions;

    -- Find out if there are any regions cloned for IBU_CF_SR_310_G (Create Template)
    -- for corresponding level. We need to set the primary contact region to IBU_CF_SR_15_G

    OPEN get_regions('IBU_CF_SR_310_',p_contextType);
    FETCH get_regions INTO l_region_code;
    WHILE get_regions%FOUND LOOP
      -- get the resp id/appl from the suffix
      IF (p_contextType <> 'GC') THEN
        l_suffix := substr(l_region_code, 16);
      ELSE
        l_suffix := '';
      END IF;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_BUGFIX1_PKG.Fix_Regions_Bugfix1', 'Fixing for IBU_CF_SR_310_X suffix:' || p_contextType || l_suffix);

      CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_310_' || p_contextType || l_suffix,
                                          'IBU_CF_SR_PRIMARY_CONTACT_RG',
                                          'Y', 'N', 'IBU_CF_SR_15_G');
      FETCH get_regions INTO l_region_code;
    END LOOP;
    CLOSE get_regions;

    -- Find out if there are any regions cloned for IBU_CF_SR_320_G (Update Template)
    -- for corresponding level. We need to set the primary contact region to IBU_CF_SR_15_G

    OPEN get_regions('IBU_CF_SR_320_',p_contextType);
    FETCH get_regions INTO l_region_code;
    WHILE get_regions%FOUND LOOP
      -- get the resp id/appl from the suffix
      IF (p_contextType <> 'GC') THEN
        l_suffix := substr(l_region_code, 16);
      ELSE
        l_suffix := '';
      END IF;
      CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_STATEMENT,'CS_CF_UPG_BUGFIX1_PKG.Fix_Regions_Bugfix1', 'Fixing for IBU_CF_SR_320_X suffix:' || p_contextType || l_suffix);

      CS_CF_UPG_UTL_PKG.UpdateRegionItems('IBU_CF_SR_320_' || p_contextType || l_suffix,
                                          'IBU_CF_SR_PRIMARY_CONTACT_RG',
                                          'Y', 'N', 'IBU_CF_SR_15_G');
      FETCH get_regions INTO l_region_code;
    END LOOP;
    CLOSE get_regions;

    commit;

EXCEPTION
  WHEN OTHERS THEN
    CS_CF_UPG_UTL_PKG.wrapup('ERROR');
    CS_CF_UPG_UTL_PKG.log_mesg(FND_LOG.LEVEL_UNEXPECTED, 'CS_CF_UPG_BUGFIX1_PKG.Main','Exception raised in Main');

     IF (get_regions%ISOPEN) THEN
       CLOSE get_regions;
     END IF;
     IF (region_exist%ISOPEN) THEN
       CLOSE region_exist;
     END IF;
     IF (get_display_attributes%ISOPEN) THEN
       CLOSE get_display_attributes;
     END IF;



    RAISE;
End Fix_Regions_Bugfix1;

END CS_CF_UPG_BUGFIX1_PKG;

/
