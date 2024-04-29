--------------------------------------------------------
--  DDL for Package Body CZ_BOM_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_BOM_SYNCH" AS
/*	$Header: czbomsyb.pls 120.9.12010000.2 2009/11/11 10:08:42 kksriram ship $		*/
---------------------------------------------------------------------------------------
TYPE typeNumberTable       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE typeIntegerTable      IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(15);
TYPE typeStringTable       IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE typeRefCursor         IS REF CURSOR;

component_item_id_map      typeNumberTable;
component_seq_id_map       typeNumberTable;
catalog_group_id_map       typeNumberTable;
organization_id_map        typeNumberTable;
APC_APPL_ID                CONSTANT  NUMBER:=431;  --Application ID for Advanced Product Catalog Application
g_target_instance          cz_servers.server_local_id%TYPE;
GenHeader                  VARCHAR2(100) := '$Header: czbomsyb.pls 120.9.12010000.2 2009/11/11 10:08:42 kksriram ship $';
---------------------------------------------------------------------------------------
--Synchronizes all the models in one instance to corresponding bills in the specified
--target instance. Stops and rolls back at the very first error or warning.

PROCEDURE synchronize_all_models_cp(errbuf        OUT NOCOPY VARCHAR2,
                                    retcode       OUT NOCOPY NUMBER,
                                    p_target_name IN  VARCHAR2) IS

  RunId      PLS_INTEGER;
  ErrorFlag  VARCHAR2(1);

BEGIN

  retcode := CONCURRENT_SUCCESS;
  errbuf := '';

  build_structure_map(NULL, p_target_name, EXECUTION_MODE_SYNC, LOG_LEVEL_MESSAGES, ErrorFlag, RunId);

  IF(ErrorFlag = ERROR_FLAG_ERROR)THEN

    retcode := CONCURRENT_ERROR;
    --'Syncronization failed, please see log for details'
    errbuf := cz_utils.get_text('CZ_SYNC_CONCURRENT_ERROR');
  END IF;
END;
---------------------------------------------------------------------------------------
--Verifies the specified model against the corresponding bill in the specified target
--instance without actual synchronization. Reports all the problems.

PROCEDURE report_model_cp(errbuf        OUT NOCOPY VARCHAR2,
                          retcode       OUT NOCOPY NUMBER,
                          p_target_name IN  VARCHAR2,
                          p_model_id    IN  NUMBER) IS

  RunId      PLS_INTEGER;
  ErrorFlag  VARCHAR2(1);

BEGIN

  retcode := CONCURRENT_SUCCESS;
  errbuf := '';

  build_structure_map(p_model_id, p_target_name, EXECUTION_MODE_REPORT, LOG_LEVEL_MESSAGES, ErrorFlag, RunId);

  IF(ErrorFlag = ERROR_FLAG_ERROR)THEN

    retcode := CONCURRENT_ERROR;
    --'Syncronization failed, please see log for details'
    errbuf := cz_utils.get_text('CZ_SYNC_CONCURRENT_ERROR');
  END IF;
END;
---------------------------------------------------------------------------------------
--Verifies all the models in one instance against to corresponding bills in the specified
--target instance without actual synchronization. Reports all the problems.

PROCEDURE report_all_models_cp(errbuf        OUT NOCOPY VARCHAR2,
                               retcode       OUT NOCOPY NUMBER,
                               p_target_name IN  VARCHAR2) IS

  RunId      PLS_INTEGER;
  ErrorFlag  VARCHAR2(1);

BEGIN

  retcode := CONCURRENT_SUCCESS;
  errbuf := '';

  build_structure_map(NULL, p_target_name, EXECUTION_MODE_REPORT, LOG_LEVEL_MESSAGES, ErrorFlag, RunId);

  IF(ErrorFlag = ERROR_FLAG_ERROR)THEN

    retcode := CONCURRENT_ERROR;
    --'Syncronization failed, please see log for details'
    errbuf := cz_utils.get_text('CZ_SYNC_CONCURRENT_ERROR');
  END IF;
END;
---------------------------------------------------------------------------------------
--Verifies the specified model against the corresponding bill in the specified target
--instance without actual synchronization. Stops at the very first error.

PROCEDURE verify_model(p_model_id    IN NUMBER,
                       p_target_name IN VARCHAR2,
                       p_error_flag  IN OUT NOCOPY VARCHAR2,
                       p_run_id      IN OUT NOCOPY NUMBER) IS
BEGIN

  build_structure_map(p_model_id, p_target_name, EXECUTION_MODE_VERIFY, LOG_LEVEL_MESSAGES, p_error_flag, p_run_id);

END;
---------------------------------------------------------------------------------------
--build_structure_map

--The root procedure. Only concurrent procedures and synchronizators are external to
--this procedure. The concurrent procedures call build_structure_map with different
--combinations of parameters.

PROCEDURE build_structure_map(p_model_id       IN NUMBER,
                              p_target_name    IN VARCHAR2,
                              p_execution_mode IN NUMBER,
                              p_log_level      IN NUMBER,
                              p_error_flag     IN OUT NOCOPY VARCHAR2,
                              p_run_id         IN OUT NOCOPY NUMBER)
IS

  TYPE typePsNodeId           IS TABLE OF cz_ps_nodes.ps_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typePsNodeType         IS TABLE OF cz_ps_nodes.ps_node_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeInitialValue       IS TABLE OF cz_ps_nodes.initial_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeInitNumVal         IS TABLE OF cz_ps_nodes.initial_num_value%TYPE INDEX BY BINARY_INTEGER;  -- sselahi
  TYPE typeParentId           IS TABLE OF cz_ps_nodes.parent_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeItemId             IS TABLE OF cz_ps_nodes.item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeMinimum            IS TABLE OF cz_ps_nodes.minimum%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeMaximum            IS TABLE OF cz_ps_nodes.maximum%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeMinimumSelected    IS TABLE OF cz_ps_nodes.minimum_selected%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeMaximumSelected    IS TABLE OF cz_ps_nodes.maximum_selected%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeReferenceId        IS TABLE OF cz_ps_nodes.reference_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeEffectiveFrom      IS TABLE OF cz_ps_nodes.effective_from%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeEffectiveUntil     IS TABLE OF cz_ps_nodes.effective_until%TYPE INDEX BY BINARY_INTEGER;
  TYPE typePsNodeName         IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeOrigSysRef         IS TABLE OF cz_ps_nodes.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeSequencePath       IS TABLE OF cz_ps_nodes.component_sequence_path%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeSequenceId         IS TABLE OF cz_ps_nodes.component_sequence_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeBomRequiredFlag    IS TABLE OF cz_ps_nodes.bom_required_flag%TYPE INDEX BY BINARY_INTEGER;

  TYPE typeRefPartNbr         IS TABLE OF cz_item_masters.ref_part_nbr%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeItemOrigSysRef     IS TABLE OF cz_item_masters.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;

  TYPE typeItemTypeId         IS TABLE OF cz_item_types.item_type_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeItemTypeName       IS TABLE OF cz_item_types.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeTypeOrigSysRef     IS TABLE OF cz_item_types.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;

  TYPE typeIntlTextId         IS TABLE OF cz_localized_texts.intl_text_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeTextOrigSysRef     IS TABLE OF cz_localized_texts.orig_sys_ref%TYPE INDEX BY BINARY_INTEGER;

  TYPE typeDevlProjectId      IS TABLE OF cz_devl_projects.devl_project_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeDevlOrigSysRef     IS TABLE OF cz_devl_projects.orig_sys_ref%TYPE INDEX BY VARCHAR2(15);

  TYPE typeModelPsNodeId      IS TABLE OF cz_xfr_project_bills.model_ps_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typeOrganizationId     IS TABLE OF cz_xfr_project_bills.organization_id%TYPE INDEX BY VARCHAR2(15);
  TYPE typeTopItemId          IS TABLE OF cz_xfr_project_bills.top_item_id%TYPE INDEX BY VARCHAR2(15);
  TYPE typeComponentId        IS TABLE OF cz_xfr_project_bills.component_item_id%TYPE INDEX BY VARCHAR2(15);
  TYPE typeSourceServer       IS TABLE OF cz_xfr_project_bills.source_server%TYPE INDEX BY VARCHAR2(15);

  TYPE typePublicationId      IS TABLE OF cz_model_publications.publication_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typePubOrganizationId  IS TABLE OF cz_xfr_project_bills.organization_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typePubTopItemId       IS TABLE OF cz_model_publications.top_item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typePubProductKey      IS TABLE OF cz_model_publications.product_key%TYPE INDEX BY BINARY_INTEGER;

  TYPE typeInventoryItemId    IS TABLE OF mtl_system_items.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE typePropertyId    IS TABLE OF CZ_ITEM_TYPE_PROPERTIES.PROPERTY_ID%TYPE INDEX BY BINARY_INTEGER;

  thisVersionString           user_source.text%TYPE;

  nDebug                      PLS_INTEGER := 1000;
  messageId                   PLS_INTEGER := 1000;
  sourceLinkVerified          PLS_INTEGER := ORACLE_NO;
  sourceLinkName              user_db_links.db_link%TYPE;
  targetLinkName              user_db_links.db_link%TYPE;
  sourceServer                cz_servers.server_local_id%TYPE;

  alreadyVerified             typeIntegerTable;

  baseLanguageCode            fnd_languages.language_code%TYPE;
  numberOfLanguages           PLS_INTEGER;
  VerifyItemProperties        PLS_INTEGER;

  tabItemTypeId               typeItemTypeId;
  tabItemTypeName             typeItemTypeName;
  tabItemTypeOrigSysRef       typeTypeOrigSysRef;
  hashItemTypeId              typeNumberTable;
  hashItemTypeName            typeItemTypeName;

  DaysTillEpochEnd            NUMBER;
  EpochEndLine                DATE;

  --Synchronization update and rollback implementation parameters section

  tabCandidateNode            typePsNodeId;
  tabCandidateItem            typeItemId;
  tabCandidateDevl            typeDevlProjectId;
  tabCandidateText            typeIntlTextId;
  tabCandidateProj            typeModelPsNodeId;
  tabCandidateType            typeItemTypeId;
  tabCandidatePubl            typePublicationId;

  hashRbNodeOrigSysRef        typeOrigSysRef;
  hashRbNodeSequencePath      typeSequencePath;
  hashRbNodeSequenceId        typeSequenceId;

  hashRbItemOrigSysRef        typeItemOrigSysRef;
  hashRbDevlOrigSysRef        typeDevlOrigSysRef;
  hashRbTextOrigSysRef        typeTextOrigSysRef;
  hashRbTypeOrigSysRef        typeTypeOrigSysRef;

  hashRbOrganizationId        typeOrganizationId;
  hashRbTopItemId             typeTopItemId;
  hashRbComponentItemId       typeComponentId;
  hashRbSourceServer          typeSourceServer;

  hashRbPubOrganizationId     typePubOrganizationId;
  hashRbPubTopItemId          typePubTopItemId;
  hashRbPubProductKey         typePubProductKey;

  tabRbItmPropValPropId      typePropertyId;
  tabRbItmTypPropId          typePropertyId;

  tabRbItmPropValOrigSysRef  typeOrigSysRef;
  tabRbItmTypPropOrigSysRef  typeOrigSysRef;

  tabRbItmPropValItemId    typeItemId;
  tabRbItmTypPropItTypeId  typeItemTypeId;

  nodeRollback                PLS_INTEGER := 0;
  itemRollback                PLS_INTEGER := 0;
  devlRollback                PLS_INTEGER := 0;
  textRollback                PLS_INTEGER := 0;
  typeRollback                PLS_INTEGER := 0;
  projRollback                PLS_INTEGER := 0;
  publRollback                PLS_INTEGER := 0;
  itemTypePropRollback        PLS_INTEGER := 0;
  itemPropValRollback         PLS_INTEGER := 0;
---------------------------------------------------------------------------------------
--build_structure_map->report

--The reporting procedure. Runs in an autonomous transaction, because we don't want to
--commit the current transaction when we are just verifying a model, but we don't want
--our error messages to be rolled back either.

PROCEDURE report(inMessage IN VARCHAR2, inUrgency IN PLS_INTEGER) IS
  l_log_level  NUMBER;
BEGIN
  IF (inUrgency = URGENCY_ERROR OR inUrgency = URGENCY_WARNING) THEN
    l_log_level := fnd_log.LEVEL_ERROR;
  ELSIF (inUrgency = URGENCY_MESSAGE) THEN
    l_log_level := fnd_log.LEVEL_PROCEDURE;
  ELSE
    l_log_level := fnd_log.LEVEL_STATEMENT;
  END IF;

  -- passing null routime name and nDebug
  cz_utils.log_report('cz_bom_synch', 'BOM Synchronization', nDebug, inMessage, l_log_level);

  --Bug #4318949.
  IF((inUrgency <= p_log_level + 1) AND (FND_GLOBAL.CONC_REQUEST_ID > 0))THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, inMessage);
  END IF;

  --When executing in the synchronization mode we want to stop at the first error or warning.

  IF(p_execution_mode > EXECUTION_MODE_REPORT AND inUrgency < URGENCY_MESSAGE)THEN
    RAISE CZ_SYNC_GENERAL_EXCEPTION;
  END IF;
END;
---------------------------------------------------------------------------------------
--build_structure_map->debug

--Calls the report procedure with a particular urgency level for debug information.

PROCEDURE debug(inMessage IN VARCHAR2) IS
BEGIN
  report(inMessage, URGENCY_DEBUG);
END;
---------------------------------------------------------------------------------------
--build_structure_map->report_on_exit

--Need this version to log a message in the most outer exception handler. It is always
--URGENCY_ERROR and never re-raises any exceptions.

PROCEDURE report_on_exit(inMessage IN VARCHAR2) IS
BEGIN

  -- INSERT INTO cz_db_logs (message, statuscode, caller, urgency, run_id, logtime, message_id)
  -- VALUES (inMessage, nDebug, 'BOM Synchronization', URGENCY_ERROR, p_run_id, SYSDATE, messageId);
  -- messageId := messageId + 1;

  -- COMMIT;
  report(inMessage, URGENCY_ERROR);
END;
---------------------------------------------------------------------------------------
--build_structure_map->verify_database_link

--Verifies a database link by quering user_db_links and remote org_organization_definitions.

PROCEDURE verify_database_link(inLinkName IN VARCHAR2) IS

  nGeneric  PLS_INTEGER;

BEGIN

  --This block is commented OUT NOCOPY as a fix for the bug #2195164. When the global name contains
  --a not empty domain part, it will be automatically appended in user_db_links table to the
  --link name. As the same operation does not automatically occur in cz_servers table, names
  --of the links may not match.

  --BEGIN

  --  SELECT NULL INTO nGeneric
  --    FROM user_db_links
  --   WHERE UPPER(db_link) = UPPER(inLinkName);

  --EXCEPTION
  --  WHEN NO_DATA_FOUND THEN
  --    RAISE CZ_SYNC_NO_DATABASE_LINK;
  --END;

  BEGIN

    --org_organization_definitions is always a reasonbly short table, so this check should
    --work fast enough. Can be replaced with any other check to verify that the link is in
    --a working condition.

    EXECUTE IMMEDIATE 'SELECT count(*) FROM org_organization_definitions@' || inLinkName
    INTO nGeneric;

  EXCEPTION
    WHEN OTHERS THEN
      --'Problem accessing database link ''%LINKNAME'': %ERRORTEXT'
      report(CZ_UTILS.GET_TEXT('CZ_SYNC_BAD_DATABASE_LINK', 'LINKNAME', inLinkName, 'ERRORTEXT', SQLERRM), URGENCY_ERROR);
      RAISE CZ_SYNC_GENERAL_EXCEPTION;
  END;
END; --verify_database_link
---------------------------------------------------------------------------------------
--build_structure_map->verify_source_server

--Verifies the existence and working condition of the link assigned to server sourceServer.
--Does this only once per session.

PROCEDURE verify_source_server IS

  instanceName  cz_servers.local_name%TYPE;
  linkName      cz_servers.fndnam_link_name%TYPE;

BEGIN
  IF(sourceLinkVerified = ORACLE_NO)THEN

    BEGIN

      SELECT fndnam_link_name, local_name INTO linkName, instanceName
        FROM cz_servers
       WHERE server_local_id = sourceServer;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --'Unable to resolve import source server with server id: %SERVERID'
        report(CZ_UTILS.GET_TEXT('CZ_SYNC_INCORRECT_SOURCE', 'SERVERID', sourceServer), URGENCY_ERROR);
        RAISE CZ_SYNC_GENERAL_EXCEPTION;
    END;

    IF(linkName IS NOT NULL)THEN

      verify_database_link(linkName);
      linkName := '@' || linkName;

    END IF;

    --The link is verified, assign the global variable to be used in the code.

    sourceLinkName := linkName;
    sourceLinkVerified := ORACLE_YES;
  END IF;

EXCEPTION
  WHEN CZ_SYNC_NO_DATABASE_LINK THEN
    --'Database link does not exist for the import source instance ''%TARGETNAME'''
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_NO_SOURCE_LINK', 'TARGETNAME', instanceName), URGENCY_ERROR);
    RAISE CZ_SYNC_GENERAL_EXCEPTION;
END;
---------------------------------------------------------------------------------------
--build_structure_map->execute_model

--The basic procedure called by build_structure_map after the preparatory work is completed.
--Finds the BOM model down the stream if p_model_id is not a BOM model (recursively),
--verifies the source server if necessary, populates the organizations hash table and
--rollback tables for cz_devl_projects and cz_xfr_project_bills, and calls execute_structure_map.

PROCEDURE execute_model(p_model_id IN NUMBER) IS

  sourceOrgId              PLS_INTEGER;
  sourceTopId              PLS_INTEGER;
  targetOrgId              PLS_INTEGER;

  modelName                cz_ps_nodes.name%TYPE;
  modelOrigSysRef          cz_devl_projects.orig_sys_ref%TYPE;
  modelEngineType          cz_devl_projects.config_engine_type%TYPE;

  modelNameStack           typeStringTable;
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->execute_structure_map

--Reads the product structure for the specified model, builds parent-child control tables,
--determines the actual BOM root and calls verify_children_list for it. Recursively follows
--the references.

PROCEDURE execute_structure_map(p_model_id IN NUMBER) IS

  tabPsNodeId              typePsNodeId;
  tabPsNodeType            typePsNodeType;
  tabInitialValue          typeInitialValue;
  tabInitNumVal            typeInitNumVal;
  tabParentId              typeParentId;
  tabItemId                typeItemId;
  tabMinimum               typeMinimum;
  tabMaximum               typeMaximum;
  tabMinimumSelected       typeMinimumSelected;
  tabMaximumSelected       typeMaximumSelected;
  tabReferenceId           typeReferenceId;
  tabEffectiveFrom         typeEffectiveFrom;
  tabEffectiveUntil        typeEffectiveUntil;
  tabPsNodeName            typePsNodeName;
  tabOrigSysRef            typeOrigSysRef;
  tabSequencePath          typeSequencePath;
  tabSequenceId            typeSequenceId;
  tabIntlTextId            typeIntlTextId;
  tabTextOrigSysRef        typeTextOrigSysRef;
  tabItemMasterTypeId      typeItemTypeId;
  tabBomRequiredFlag       typeBomRequiredFlag;

  tabRefPartNbr            typeRefPartNbr;
  tabItemOrigSysRef        typeItemOrigSysRef;

  jhashNodeFirstChild      typeIntegerTable;
  jhashNodeLastChild       typeIntegerTable;
  jRootNode                INTEGER;
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->execute_structure_map->generate_name

--Generates full name for a referenced model.

  FUNCTION generate_name RETURN VARCHAR2 IS
    name  VARCHAR2(2000);
  BEGIN

    FOR i IN 1..modelNameStack.COUNT LOOP
      IF(i > 1)THEN name := name || NAME_PATH_SEPARATOR; END IF;
      name := name || modelNameStack(i);
    END LOOP;

   RETURN name;
  END; --generate_name
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->execute_structure_map->extract_item_id

--Extracts item_id from cz_item_masters.orig_sys_ref

  FUNCTION extract_item_id(j IN PLS_INTEGER) RETURN PLS_INTEGER IS
  BEGIN

    --The return value can only be a not null valid number.

    RETURN TO_NUMBER(NVL(SUBSTR(tabItemOrigSysRef(j), 1, INSTR(tabItemOrigSysRef(j), ORIGINAL_SEPARATOR) - 1), 'NULL'));
  EXCEPTION
    WHEN OTHERS THEN
      --'Unable to extract item id for item ''%ITEMNAME'' in configuration model ''%MODELNAME'''
      report(CZ_UTILS.GET_TEXT('CZ_SYNC_INVALID_ITEM_ID', 'ITEMNAME', tabRefPartNbr(j), 'MODELNAME', generate_name), URGENCY_WARNING);
      RETURN NULL;
  END; --extract_item_id
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->execute_structure_map->extract_project_reference

--Extracts cz_devl_projects.orig_sys_ref part of cz_ps_nodes.orig_sys_ref. Uses the fact
--the first is always a part of the second.

  FUNCTION extract_project_reference(j IN PLS_INTEGER) RETURN VARCHAR2 IS
  BEGIN

    RETURN SUBSTR(tabOrigSysRef(j), INSTR(tabOrigSysRef(j), ORIGINAL_SEPARATOR, -1, 3) + 1);
  END; --extract_project_reference
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->execute_structure_map->verify_children_list

--Makes the actual comparisons intersecting effectivity ranges. Recurse on every option class.

  PROCEDURE verify_children_list(j IN PLS_INTEGER, inEffectivityDate IN DATE, inDisableDate IN DATE) IS

    localPsNodeId         cz_ps_nodes.ps_node_id%TYPE := tabPsNodeId(j);
    localParentName       cz_ps_nodes.name%TYPE := tabPsNodeName(j);
    localParentType       cz_ps_nodes.ps_node_type%TYPE := tabPsNodeType(j);
    bomRequiredFlag       cz_ps_nodes.bom_required_flag%TYPE;
    tabInventoryItemId    typeInventoryItemId;

    l_item_type_msg       VARCHAR2(4000);
    l_parent_type_msg     VARCHAR2(4000);

    getBillChildren       typeRefCursor;
    childrenFirst         PLS_INTEGER := 1;
    childrenLast          PLS_INTEGER := 0;
    slidePointer          PLS_INTEGER;
    startPointer          PLS_INTEGER;
    localString           VARCHAR2(2000);
    bomQuantity           NUMBER;
    nodeQuantity          NUMBER;

    lastConcatSegments    mtl_system_items_vl.concatenated_segments%TYPE := NULL;
    itemConcatSegments    mtl_system_items_vl.concatenated_segments%TYPE;
    itemInventoryId       mtl_system_items.inventory_item_id%TYPE;
    itemCatalogGroupId    mtl_system_items.item_catalog_group_id%TYPE;

    billSequenceId        bom_bill_of_materials.bill_sequence_id%TYPE;
    billCommonSequenceId  bom_bill_of_materials.common_bill_sequence_id%TYPE;
    useSequenceId         bom_bill_of_materials.bill_sequence_id%TYPE;

    bomEffectivityDate    bom_inventory_components.effectivity_date%TYPE;
    bomDisableDate        bom_inventory_components.disable_date%TYPE;
    bomComponentQuantity  bom_inventory_components.component_quantity%TYPE;
    bomComponentSeqId     bom_inventory_components.component_sequence_id%TYPE;
    bomHighQuantity       bom_inventory_components.high_quantity%TYPE;
    bomLowQuantity        bom_inventory_components.low_quantity%TYPE;
    bomMutuallyExclusive  bom_inventory_components.mutually_exclusive_options%TYPE;
    bomItemType           bom_inventory_components.bom_item_type%TYPE;
    bomOptional           bom_inventory_components.optional%TYPE;
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->execute_structure_map->verify_children_list->hash_item

--Adds the item that passed all the comparisons to the corresponding hash tables and populates
--rollback hash tables for cz_ps_nodes, cz_item_masters and cz_localized_texts.

    PROCEDURE hash_item(j IN PLS_INTEGER) IS

      itemId     PLS_INTEGER;
    BEGIN

      itemId := extract_item_id(j);

      IF(itemId IS NOT NULL)THEN

        debug('Hash map entry: key item_id = ' || itemId || ', inventory_item_id = ' || itemInventoryId || ', sequence_id = ' || bomComponentSeqId);

        component_item_id_map(itemId) := itemInventoryId;

        IF(tabSequenceId(j) IS NOT NULL)THEN
          component_seq_id_map(tabSequenceId(j)) := bomComponentSeqId;
        END IF;

        debug('Update candidate entry: ps_node_id = ' || tabPsNodeId(j) || ', item_id = ' || tabItemId(j) || ', intl_text_id = ' || tabIntlTextId(j));

        IF(NOT hashRbNodeOrigSysRef.EXISTS(tabPsNodeId(j)))THEN

          tabCandidateNode(tabCandidateNode.COUNT + 1) := tabPsNodeId(j);
          hashRbNodeOrigSysRef(tabPsNodeId(j)) := tabOrigSysRef(j);
          hashRbNodeSequencePath(tabPsNodeId(j)) := tabSequencePath(j);
          hashRbNodeSequenceId(tabPsNodeId(j)) := tabSequenceId(j);

          IF(tabItemId(j) IS NOT NULL)THEN
            IF(NOT hashRbItemOrigSysRef.EXISTS(tabItemId(j)))THEN
              tabCandidateItem(tabCandidateItem.COUNT + 1) := tabItemId(j);
              hashRbItemOrigSysRef(tabItemId(j)) := tabItemOrigSysRef(j);
            END IF;
          END IF;

          IF(tabIntlTextId(j) IS NOT NULL)THEN
            IF(NOT hashRbTextOrigSysRef.EXISTS(tabIntlTextId(j)))THEN
              tabCandidateText(tabCandidateText.COUNT + 1) := tabIntlTextId(j);
              hashRbTextOrigSysRef(tabIntlTextId(j)) := tabTextOrigSysRef(j);
            END IF;
          END IF;
        END IF;
      END IF;
    END; --hash_item
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->execute_structure_map->verify_children_list->verify_item_properties

--All imported item propeties should be present as descriptive elements of the corresponding bom item
--and the values should match.

    PROCEDURE verify_item_properties(j IN PLS_INTEGER) IS

      TL_TEXT_TYPE  CONSTANT  NUMBER := 8;
      elementValue  mtl_descr_element_values.element_value%TYPE;
      l_val         VARCHAR2(4000);
      l_flag        PLS_INTEGER;
      position      NUMBER;
      l_src_application_id cz_properties.src_application_id%TYPE;
      l_item_catalog_group_id cz_exv_item_master.item_catalog_group_id%TYPE;
      l_database_column  cz_exv_apc_properties.database_column%TYPE;
      l_attr_group_id    cz_exv_apc_properties.attr_group_id%TYPE;
      l_attr_id        cz_exv_apc_properties.attr_id%TYPE;

    BEGIN
      FOR c_prop IN (SELECT name, data_type, property_value, property_num_value , p.src_application_id
                       FROM cz_properties p, cz_item_property_values v
                      WHERE p.deleted_flag = FLAG_NOT_DELETED
                        AND p.orig_sys_ref IS NOT NULL
                        AND v.deleted_flag = FLAG_NOT_DELETED
                        AND v.item_id = tabItemId(j)
                        AND p.property_id = v.property_id
                        AND p.data_type NOT IN(TL_TEXT_TYPE)
                     UNION
                      SELECT name, data_type,def_value as property_value,def_num_value as property_num_value,src_application_id
                        FROM cz_properties p
                       WHERE p.property_id IN(
                                              SELECT it.property_id FROM cz_item_type_properties it
                                               WHERE it.item_type_id IN(SELECT im.item_type_id FROM CZ_ITEM_MASTERS im
                                                                         WHERE im.item_id=tabItemId(j) AND
                                                                               im.deleted_flag=FLAG_NOT_DELETED) AND
                                                     it.deleted_flag=FLAG_NOT_DELETED
                                              ) AND
                             NOT EXISTS(SELECT NULL FROM cz_item_property_values iv
                                         WHERE iv.property_id=p.property_id AND iv.item_id=tabItemId(j) AND
                                               iv.deleted_flag=FLAG_NOT_DELETED) AND
                          p.deleted_flag = FLAG_NOT_DELETED AND
                          p.orig_sys_ref IS NOT NULL AND
                          p.data_type NOT IN(TL_TEXT_TYPE)
                       ) LOOP
        BEGIN
          l_src_application_id:=c_prop.src_application_id;
          IF c_prop.src_application_id = APC_APPL_ID THEN
                 --This is an APC attribute
                 EXECUTE IMMEDIATE
                 'SELECT distinct item_catalog_group_id '||
                 '  FROM mtl_system_items_b'|| targetLinkName ||
                 ' WHERE organization_id = :1 '||
                 '   AND inventory_item_id =  :2 '||
                 '   AND item_catalog_group_id IS NOT NULL'
                 INTO l_item_catalog_group_id
                 USING  targetOrgId,itemInventoryId;

                 position := INSTR(c_prop.name,'.');

                 EXECUTE IMMEDIATE
                 'SELECT distinct database_column, attr_group_id, attr_id'||
                 ' FROM cz_exv_apc_properties'|| targetLinkName ||
                 ' WHERE application_id = :1 '||
                 ' AND attr_group_name  = :2 '||
                 ' AND attr_name = :3 '||
		 ' AND item_catalog_group_id IN (SELECT item_catalog_group_id '||
                 ' FROM mtl_item_catalog_groups'|| targetLinkName ||' CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id '||
                 ' START WITH item_catalog_group_id = :4  )'
		 INTO l_database_column , l_attr_group_id  ,l_attr_id
		 USING APC_APPL_ID , substr(c_prop.name,1,position-1) , substr(c_prop.name,position+1) ,l_item_catalog_group_id;


                 EXECUTE IMMEDIATE
                    'SELECT to_char('|| l_database_column ||') FROM CZ_EXV_ITEM_APC_PROP_VALUES' || targetLinkName ||
                    ' WHERE INVENTORY_ITEM_ID= :1    and ORGANIZATION_ID = :2  and ITEM_CATALOG_GROUP_ID =:3  '||
                    ' and ATTR_GROUP_ID =:4'
                 INTO elementValue
                 USING itemInventoryId ,targetOrgId,l_item_catalog_group_id,l_attr_group_id ;

                 IF elementValue IS NULL THEN
                   EXECUTE IMMEDIATE
                    'SELECT default_value '||
                    ' FROM cz_exv_apc_properties'|| targetLinkName ||
                    ' WHERE application_id = :1 '||
                    ' AND attr_group_id  = :2 '||
                    ' AND attr_id = :3 '
                   INTO elementValue
		       USING APC_APPL_ID , l_attr_group_id , l_attr_id;
                 END IF;

           ELSE
               -- not an APC attribute

                  EXECUTE IMMEDIATE
                    'SELECT element_value FROM mtl_descr_element_values' || targetLinkName ||
                    ' WHERE inventory_item_id = :1' ||
                    '   AND element_name = :2'
                  INTO elementValue
                  USING itemInventoryId, c_prop.name;

          END IF;


          l_val := c_prop.property_value;
          l_flag := 0;

          IF(c_prop.data_type = 2)THEN

             l_val := TO_CHAR(c_prop.property_num_value);

             BEGIN

               elementValue := TO_CHAR(TO_NUMBER(elementValue));

             EXCEPTION
               WHEN INVALID_NUMBER THEN
                 l_flag := 1;
               WHEN VALUE_ERROR THEN
                 l_flag := 1;
             END;
          END IF;
          IF((l_flag = 1) OR ((l_val IS NULL) <> (elementValue IS NULL)) OR (RTRIM(l_val) <> RTRIM(elementValue)))THEN
            IF (l_src_application_id=APC_APPL_ID) THEN
              --The value of the user-defined attribute ATTRIBUTENAME for Inventory Item ITEMNAME with parent PARENTNAME does not match the corresponding Property value.
              report(CZ_UTILS.GET_TEXT('CZ_SYN_USR_ATTR_PROP_NO_MATCH', 'ITEMNAME', itemConcatSegments, 'PARENTNAME', localParentName, 'ATTRIBUTENAME', c_prop.name), URGENCY_WARNING);
            ELSE
              --'Value of descriptive element ''%ELEMENTNAME'' for inventory item ''%ITEMNAME'' with parent ''%PARENTNAME'' does not match with corresponding property value'
              report(CZ_UTILS.GET_TEXT('CZ_SYNC_VALUE_NO_MATCH', 'ITEMNAME', itemConcatSegments, 'PARENTNAME', localParentName, 'ELEMENTNAME', c_prop.name), URGENCY_WARNING);
            END IF;
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           IF (l_src_application_id=APC_APPL_ID) THEN
             --The Inventory Item ITEMNAME with parent PARENTNAME does not contain the user-defined attribute ATTRIBUTENAME.
             report(CZ_UTILS.GET_TEXT('CZ_SYN_USR_ATTR_NOT_PRESENT', 'ITEMNAME', itemConcatSegments, 'PARENTNAME', localParentName, 'ATTRIBUTENAME', c_prop.name), URGENCY_WARNING);
           ELSE
             --'Inventory item ''%ITEMNAME'' with parent ''%PARENTNAME'' does not have descriptive element ''%ELEMENTNAME'''
             report(CZ_UTILS.GET_TEXT('CZ_SYNC_NO_SUCH_ELEMENT', 'ITEMNAME', itemConcatSegments, 'PARENTNAME', localParentName, 'ELEMENTNAME', c_prop.name), URGENCY_WARNING);
           END IF;
        END;
      END LOOP;
    END; --verify_item_properties
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->execute_structure_map->verify_children_list->hash_catalog_group

--If a configuration item is assigned to an imported item type, the corresponding bom item should be
--assigned to some catalog group. Verifies that and populates hash and rollback tables.

    PROCEDURE hash_catalog_group(j IN PLS_INTEGER) IS

      catalogId     PLS_INTEGER := hashItemTypeId(tabItemMasterTypeId(j));
      typeName      cz_item_types.name%TYPE := hashItemTypeName(tabItemMasterTypeId(j));
    BEGIN

      IF(itemCatalogGroupId IS NULL)THEN

        --'Inventory item ''%ITEMNAME'' with parent ''%PARENTNAME'' is not assigned to any catalog group. Its corresponding item in model ''%MODELNAME'' is assigned to type ''%TYPENAME'''
        report(CZ_UTILS.GET_TEXT('CZ_SYNC_NO_CATALOG_GROUP', 'ITEMNAME', itemConcatSegments, 'PARENTNAME', localParentName, 'MODELNAME', generate_name, 'TYPENAME', typeName), URGENCY_WARNING);
        RETURN;
      END IF;

      catalog_group_id_map(catalogId) := itemCatalogGroupId;
      tabCandidateType(tabCandidateType.COUNT + 1) := tabItemMasterTypeId(j);
      hashRbTypeOrigSysRef(tabItemMasterTypeId(j)) := TO_CHAR(catalogId);
    END; --hash_catalog_group
---------------------------------------------------------------------------------------
  BEGIN

     --Query information for the model/option class itself.

     BEGIN

       EXECUTE IMMEDIATE
         'SELECT b.bill_sequence_id, b.common_bill_sequence_id, i.inventory_item_id, i.item_catalog_group_id' ||
         '  FROM bom_bill_of_materials' || targetLinkName || ' b, mtl_system_items_vl' || targetLinkName || ' i' ||
         ' WHERE i.concatenated_segments = :1' ||
         '   AND i.organization_id = :2' ||
         '   AND b.assembly_item_id = i.inventory_item_id' ||
         '   AND b.organization_id = i.organization_id' ||
         '   AND b.alternate_bom_designator IS NULL'
       INTO billSequenceId, billCommonSequenceId, itemInventoryId, itemCatalogGroupId
       USING tabRefPartNbr(j), targetOrgId;

       debug('Values received: bill_sequence_id = ' || billSequenceId || ', common_bill_sequence_id = ' || billCommonSequenceId);

     EXCEPTION
       WHEN NO_DATA_FOUND THEN

         --Report differently depending on whether this is a root model or not.

         IF(j = jRootNode)THEN

           --'There is no root bill for configuration model ''%MODELNAME'', unable to verify the model'
           report(CZ_UTILS.GET_TEXT('CZ_SYNC_MODEL_NO_BILL', 'MODELNAME', generate_name), URGENCY_WARNING);
         ELSE

           --'Item ''%ITEMNAME'' in configuration model ''%MODELNAME'' has no corresponding bill'
           report(CZ_UTILS.GET_TEXT('CZ_SYNC_ITEM_NO_BILL', 'ITEMNAME', tabRefPartNbr(j), 'MODELNAME', generate_name), URGENCY_WARNING);
         END IF;
         RETURN;
     END;

     --If this is the root model, add the item to the hash tables here because there will be no
     --other chance to do this.

     IF(j = jRootNode)THEN hash_item(j); END IF;

     --Set the parameters for the comparison algorythm. Note, that the way the variables are
     --initialized, if the node has no children, all the cycles would be from 1 to 0, empty.

     IF(jhashNodeFirstChild.EXISTS(localPsNodeId))THEN childrenFirst := jhashNodeFirstChild(localPsNodeId); END IF;
     IF(jhashNodeLastChild.EXISTS(localPsNodeId))THEN childrenLast := jhashNodeLastChild(localPsNodeId); END IF;

     debug('Children pointers: first = ' || childrenFirst || ', last = ' || childrenLast);

     --startPointer points to the first model item eligible for processing. All model items before
     --this pointer have already got all the processing they may need.

     startPointer := childrenFirst;

     --Use the common bill if common_bill_sequence_id is not null, otherwise use bill_sequence_id.

     useSequenceId := NVL(billCommonSequenceId, billSequenceId);

     --Read the bom children list.
     --Ordering by effectivity_date provides that components with earlier effectivity dates will
     --come up first. This should be consistent with ordering by effective_from when quering the
     --product structure.

     OPEN getBillChildren FOR
       'SELECT i.inventory_item_id, i.concatenated_segments, b.effectivity_date, b.disable_date, b.component_quantity,' ||
       '       b.component_sequence_id, b.high_quantity, b.low_quantity, b.mutually_exclusive_options,' ||
       '       b.bom_item_type, b.optional, i.item_catalog_group_id' ||
       '  FROM mtl_system_items_vl' || targetLinkName || ' i, bom_inventory_components' || targetLinkName || ' b' ||
       ' WHERE b.bill_sequence_id = :1' ||
       '   AND b.implementation_date IS NOT NULL' ||
       '   AND i.organization_id = :2' ||
       '   AND (b.optional = :3 OR b.bom_item_type <= :4)' ||
       '   AND i.inventory_item_id = b.component_item_id' ||
       ' ORDER BY i.concatenated_segments, b.effectivity_date'
     USING useSequenceId, targetOrgId, ORACLE_YES, ORACLE_BOM_OPTIONCLASS;

     LOOP

       FETCH getBillChildren INTO itemInventoryId, itemConcatSegments, bomEffectivityDate,
                                  bomDisableDate, bomComponentQuantity, bomComponentSeqId,
                                  bomHighQuantity, bomLowQuantity, bomMutuallyExclusive,
                                  bomItemType, bomOptional, itemCatalogGroupId;
       EXIT WHEN getBillChildren%NOTFOUND;

       --Handle the effectivity ranges. Need to account for bug #1710684.
       --Effectivity date is not nullable.

       IF(bomDisableDate IS NULL OR bomDisableDate > EpochEndDate)THEN bomDisableDate := EpochEndDate; END IF;
       IF(bomEffectivityDate < EpochBeginDate)THEN bomEffectivityDate := EpochBeginDate; END IF;

       --bom_inventory_components.optional can be null which means optional. Also we need to
       --invert the value to compare to cz_ps_nodes.bom_required_flag.

       IF(bomOptional = ORACLE_NO)THEN
          bomRequiredFlag := FLAG_BOM_REQUIRED;
       ELSE
          bomRequiredFlag := FLAG_BOM_OPTIONAL;
       END IF;

       --Intersect the effectivity range with the parent's.

       IF(bomEffectivityDate < inEffectivityDate)THEN bomEffectivityDate := inEffectivityDate; END IF;
       IF(bomDisableDate > inDisableDate)THEN bomDisableDate := inDisableDate; END IF;

       --The item will we skipped if its effectivity range doesn't intersect with its parent range.

       IF(bomEffectivityDate <= bomDisableDate)THEN

         debug('Current start pointer: ' || startPointer || '. Processing item: item_id = ' || itemInventoryId || ', concatenated_segments = ' || itemConcatSegments);

         --Set the sliding pointer. Always start with the first model item eligible for processing.

         slidePointer := startPointer;

         --Scan the model items until match with the current bom item. Do not report all the items scanned
         --as not having the match at this point because if no match will be found,we will have to process
         --these items again. Do not skip references except for minimum/maximum verification.
         --Ref part number is not null, so it is safe to use <not equal> here.

         WHILE(slidePointer <= childrenLast AND (tabRefPartNbr(slidePointer) IS NULL OR tabRefPartNbr(slidePointer) <> itemConcatSegments))LOOP
           slidePointer := slidePointer + 1;
         END LOOP;

         --Now the pointer points to the first model item matched with the current bom item. If the pointer
         --is greater than the index of the last model item, no match was found. If so, report the bom item
         --as not having match in the configuration model.

         IF(slidePointer > childrenLast)THEN

           IF(bomItemType = ORACLE_BOM_MODEL)THEN

             l_item_type_msg := CZ_UTILS.GET_TEXT('CZ_DEV_TEXT_BOM_MODEL');
           ELSIF(bomItemType = ORACLE_BOM_OPTIONCLASS)THEN

             l_item_type_msg := CZ_UTILS.GET_TEXT('CZ_DEV_TEXT_OPTION_CLASS');
           ELSIF(bomItemType = ORACLE_BOM_STANDARD)THEN

             l_item_type_msg := CZ_UTILS.GET_TEXT('CZ_DEV_TEXT_STD_ITEM');
           ELSE

             l_item_type_msg := CZ_UTILS.GET_TEXT('CZ_DEV_TEXT_UNKNOWN_BOM');
           END IF;

           IF(localParentType = PS_NODE_TYPE_BOM_MODEL)THEN

             l_parent_type_msg := CZ_UTILS.GET_TEXT('CZ_DEV_TEXT_BOM_MODEL');
           ELSIF(localParentType = PS_NODE_TYPE_BOM_OPTIONCLASS)THEN

             l_parent_type_msg := CZ_UTILS.GET_TEXT('CZ_DEV_TEXT_OPTION_CLASS');
           ELSIF(localParentType = PS_NODE_TYPE_BOM_STANDARD)THEN

             l_parent_type_msg := CZ_UTILS.GET_TEXT('CZ_DEV_TEXT_STD_ITEM');
           ELSE

             l_parent_type_msg := CZ_UTILS.GET_TEXT('CZ_DEV_TEXT_NON_BOM');
           END IF;

           --'%ITEMTYPE ''%ITEMNAME'' with parent %PARENTTYPE ''%PARENTNAME'' has no match in configuration model ''%MODELNAME'''
           report(CZ_UTILS.GET_TEXT('CZ_SYNC_INV_NO_MATCH', 'ITEMTYPE', l_item_type_msg, 'ITEMNAME', itemConcatSegments,
                                    'PARENTTYPE', l_parent_type_msg, 'PARENTNAME', localParentName, 'MODELNAME', generate_name),
                                    URGENCY_WARNING);

         ELSE

           --The match has been found. Now report all the configuration items skipped in the cycle above
           --because we will never get back to process them.

           FOR i IN startPointer..slidePointer - 1 LOOP

             --'Item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'' cannot be matched with any inventory item'
             report(CZ_UTILS.GET_TEXT('CZ_SYNC_ITEM_NO_MATCH', 'ITEMNAME', tabRefPartNbr(i), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);

           END LOOP;

           debug('Match found at position: ' || slidePointer || ', comparing items...');

           --A match has been found, so we reset the startPointer.

           startPointer := slidePointer + 1;

           --Now make the actual comparison.

           localString := NVL(TO_CHAR(bomComponentQuantity), '0');
           IF(localString = '0')THEN localString := '1'; END IF;
           IF(localString <> tabInitNumVal(slidePointer))THEN -- sselahi

             --'Initial value does not match for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'''
             report(CZ_UTILS.GET_TEXT('CZ_SYNC_INITIAL_VALUE', 'ITEMNAME', tabRefPartNbr(slidePointer), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);
           END IF;

           IF ( modelEngineType = 'L' OR bomLowQuantity IS NOT NULL ) THEN

              bomQuantity := NVL(bomLowQuantity, 0);
              IF(tabPsNodeType(slidePointer) = PS_NODE_TYPE_REFERENCE)THEN
                nodeQuantity := NVL(tabMinimumSelected(slidePointer), 0);
              ELSE
                nodeQuantity := NVL(tabMinimum(slidePointer), 0);
              END IF;

              IF(bomQuantity <> nodeQuantity)THEN

                --'Minimum value does not match for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'''
                report(CZ_UTILS.GET_TEXT('CZ_SYNC_MINIMUM_VALUE', 'ITEMNAME', tabRefPartNbr(slidePointer), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);
              END IF;
           END IF;

           IF ( modelEngineType = 'L' OR bomHighQuantity IS NOT NULL ) THEN

              bomQuantity := NVL(bomHighQuantity, 0);
              IF(tabPsNodeType(slidePointer) = PS_NODE_TYPE_REFERENCE)THEN
                nodeQuantity := NVL(tabMaximumSelected(slidePointer), 0);
              ELSE
                nodeQuantity := NVL(tabMaximum(slidePointer), 0);
              END IF;
              IF(bomQuantity = 0)THEN bomQuantity := -1; END IF;
              IF(nodeQuantity = 0)THEN nodeQuantity := -1; END IF;

              IF(bomQuantity <> nodeQuantity)THEN

                --'Maximum value does not match for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'''
                report(CZ_UTILS.GET_TEXT('CZ_SYNC_MAXIMUM_VALUE', 'ITEMNAME', tabRefPartNbr(slidePointer), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);
              END IF;
           END IF;

           IF(bomMutuallyExclusive = ORACLE_YES AND
              (tabMaximumSelected(slidePointer) IS NULL OR tabMaximumSelected(slidePointer) < 1))THEN

             --'Maximum selected value does not match for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'''
             report(CZ_UTILS.GET_TEXT('CZ_SYNC_MAXIMUM_SELECTED', 'ITEMNAME', tabRefPartNbr(slidePointer), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);
           END IF;

           IF(bomRequiredFlag <> tabBomRequiredFlag(slidePointer))THEN

             --'Required when parent is selected property does not match for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'''
             report(CZ_UTILS.GET_TEXT('CZ_SYNC_BOM_REQUIRED', 'ITEMNAME', tabRefPartNbr(slidePointer), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);
           END IF;

           IF(lastConcatSegments = itemConcatSegments)THEN

             --This is one of the components, not the first one, with the same concatenated_segments,
             --so both start and end dates should be the same.

             IF(bomEffectivityDate <> tabEffectiveFrom(slidePointer) OR
                bomDisableDate <> tabEffectiveUntil(slidePointer))THEN

               --'Effectivity range does not match for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'''
               report(CZ_UTILS.GET_TEXT('CZ_SYNC_EFFECTIVITY_RANGE', 'ITEMNAME', tabRefPartNbr(slidePointer), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);
             END IF;
           ELSE

             --If there are more than one items with the same concatenated_segments, then this is the
             --first one, end dates should match, start dates have some logic.

             IF(((bomEffectivityDate > SYSDATE OR tabEffectiveFrom(slidePointer) > SYSDATE) AND
                  bomEffectivityDate <> tabEffectiveFrom(slidePointer)) OR
                (bomDisableDate <> tabEffectiveUntil(slidePointer)))THEN

               --'Effectivity range does not match for item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'''
               report(CZ_UTILS.GET_TEXT('CZ_SYNC_EFFECTIVITY_RANGE', 'ITEMNAME', tabRefPartNbr(slidePointer), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);
             END IF;
           END IF;

           --If a configuration item belongs to an imported item type, the corresponding bom item should
           --belong to some catalog group.

           IF(tabItemMasterTypeId(slidePointer) IS NOT NULL AND hashItemTypeId.EXISTS(tabItemMasterTypeId(slidePointer)))THEN

             hash_catalog_group(slidePointer);
           END IF;

           IF(VerifyItemProperties = 1)THEN

             verify_item_properties(slidePointer);
           END IF;

           --Add the item to the hash tables.

           hash_item(slidePointer);
           lastConcatSegments := itemConcatSegments;

           --For bom option classes call the procedure recursively.

           IF(bomItemType = ORACLE_BOM_OPTIONCLASS)THEN

             debug('Ready to verify children for item id ' || itemInventoryId || ', item name ''' || itemConcatSegments || '''');

             verify_children_list(slidePointer, bomEffectivityDate, bomDisableDate);
           END IF;
         END IF; --item has been matched
       END IF; --effectivity ranges intersect
     END LOOP;
     CLOSE getBillChildren;

     --Report all the not matched children at the end of the list.

     FOR i IN startPointer..childrenLast LOOP

         --'Item ''%ITEMNAME'' with parent ''%PARENTNAME'' in configuration model ''%MODELNAME'' cannot be matched with any inventory item'
         report(CZ_UTILS.GET_TEXT('CZ_SYNC_ITEM_NO_MATCH', 'ITEMNAME', tabRefPartNbr(i), 'PARENTNAME', localParentName, 'MODELNAME', generate_name), URGENCY_WARNING);

     END LOOP;

     debug('Returning to caller after processing children of item id ' || tabPsNodeId(j) || ', item name ''' || tabRefPartNbr(j) || '''');

  EXCEPTION
    WHEN OTHERS THEN

       --Just see if the cursor variable is open and close it if necessary.

      IF(getBillChildren%ISOPEN)THEN CLOSE getBillChildren; END IF;
      RAISE;
  END; --verify_children_list
---------------------------------------------------------------------------------------
BEGIN --execute_structure_map

  debug('Entering model with model id ' || p_model_id);

  --We don't want to verify the same model more than once during the session.

  IF(alreadyVerified.EXISTS(p_model_id))THEN

    debug('Model already processed before, exiting...');
    RETURN;
  END IF;
  alreadyVerified(p_model_id) := 1;

  debug('Reading the product structure:');

  --The statement uses ordering by parent_id to ensure that for every node all of its
  --children will follow it in a dense list.

  SELECT p.ps_node_id, p.parent_id, p.ps_node_type, p.item_id, p.effective_from,
         p.effective_until, p.minimum, maximum, p.minimum_selected, p.maximum_selected,
         p.initial_value, p.initial_num_value, p.reference_id, p.name, p.orig_sys_ref, p.component_sequence_path, --sselahi
         p.component_sequence_id, p.intl_text_id, p.bom_required_flag, t.orig_sys_ref,
         i.ref_part_nbr, i.orig_sys_ref, i.item_type_id
    BULK COLLECT INTO tabPsNodeId, tabParentId, tabPsNodeType, tabItemId, tabEffectiveFrom,
         tabEffectiveUntil, tabMinimum, tabMaximum, tabMinimumSelected, tabMaximumSelected,
         tabInitialValue, tabInitNumVal, tabReferenceId, tabPsNodeName, tabOrigSysRef, tabSequencePath, -- sselahi
         tabSequenceId, tabIntlTextId, tabBomRequiredFlag, tabTextOrigSysRef,
         tabRefPartNbr, tabItemOrigSysRef, tabItemMasterTypeId
    FROM cz_item_masters i, cz_ps_nodes p, cz_localized_texts t
   WHERE p.devl_project_id = p_model_id
     AND p.deleted_flag = FLAG_NOT_DELETED
     AND p.orig_sys_ref IS NOT NULL
     AND p.src_application_id = 702
     AND t.language (+) = baseLanguageCode
     AND p.item_id = i.item_id (+)
     AND p.intl_text_id = t.intl_text_id (+)
   ORDER BY p.parent_id, i.ref_part_nbr, p.effective_from;

  --Populate auxiliary arrays and values:
  --jhashNodeFirstChild - index of the first node's child;
  --jhashNodeLastChild - index of the last node's child;
  --jRootNode - index of the root node.

  FOR i IN 1..tabPsNodeId.COUNT LOOP

    --Fix the effective_until date (bug #2006980).

    IF(tabEffectiveUntil(i) > EpochEndLine)THEN tabEffectiveUntil(i) := EpochEndDate; END IF;

    IF(tabParentId(i) IS NOT NULL)THEN

      IF(NOT jhashNodeFirstChild.EXISTS(tabParentId(i)))THEN

        --This is populated only for the first child.

        jhashNodeFirstChild(tabParentId(i)) := i;
      END IF;

      --This is always rolled forward to the next child.

      jhashNodeLastChild(tabParentId(i)) := i;

    ELSE

      --This is the root node.

      jRootNode := i;
    END IF;

    debug('j = ' || i || ', ps_node_id = ' || tabPsNodeId(i) || ', parent_id = ' || NVL(TO_CHAR(tabParentId(i)), '<null>') ||
          ', ps_node_type = ' || tabPsNodeType(i) || ', reference_id = ' || tabReferenceId(i) || ', ref_part_nbr = ' || tabRefPartNbr(i) ||
          ', orig_sys_ref = ' || tabItemOrigSysRef(i));
  END LOOP;

  --Step down from the root node until we find the root BOM model.

  WHILE(tabPsNodeType(jRootNode) <> PS_NODE_TYPE_BOM_MODEL)LOOP

    --Raise the error if the node has more than one child because this is an unexpected
    --structure. If there is only one child, step down to it.

    IF(jhashNodeFirstChild(tabPsNodeId(jRootNode)) - jhashNodeLastChild(tabPsNodeId(jRootNode)) > 0)THEN
      RAISE CZ_SYNC_UNEXPECTED_STRUCTURE;
    END IF;
    jRootNode := jhashNodeFirstChild(tabPsNodeId(jRootNode));
  END LOOP;

  --Populate candidate tables and rollback hash tables for cz_devl_projects and cz_xfr_project_bills.

  tabCandidateDevl(tabCandidateDevl.COUNT + 1) := p_model_id;
  hashRbDevlOrigSysRef(p_model_id) := extract_project_reference(jRootNode);

  tabCandidateProj(tabCandidateProj.COUNT + 1) := p_model_id;
  hashRbOrganizationId(p_model_id) := sourceOrgId;
  hashRbTopItemId(p_model_id) := extract_item_id(jRootNode);
  hashRbComponentItemId(p_model_id) := hashRbTopItemId(p_model_id);
  hashRbSourceServer(p_model_id) := sourceServer;

  --Maintain the stack of model names in order to report full paths.

  modelNameStack(modelNameStack.COUNT + 1) := tabPsNodeName(jRootNode);

  debug('Root resolved, root index ' || jRootNode || ', model name ''' || generate_name || '''');

  --Follow the references.

  FOR i IN 1..tabPsNodeId.COUNT LOOP

    IF(tabPsNodeType(i) = PS_NODE_TYPE_REFERENCE)THEN

      debug('Following the reference to model id ' || tabReferenceId(i));

      execute_structure_map(tabReferenceId(i));
    END IF;
  END LOOP;

  debug('Ready to verify children starting with the root model id ' || p_model_id || ', model name ''' || generate_name || '''');

  verify_children_list(jRootNode, EpochBeginDate, EpochEndDate);
  modelNameStack.DELETE(modelNameStack.COUNT);

  debug('Returning to caller after processing model with id ' || p_model_id);

--This exception block handles all the exceptions that should terminate the process for
--the current model but go on for other models.
--Fatal exceptions may also be caught here to make some scope-specific processing, then
--they should be re-raised.

EXCEPTION
  WHEN CZ_SYNC_UNEXPECTED_STRUCTURE THEN
    --'Configuration model ''%MODELNAME'' has incorrect structure and cannot be synchronized'
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_UNEXPECTED_STRUCTURE', 'MODELNAME', tabPsNodeName(jRootNode)), URGENCY_ERROR);
  WHEN OTHERS THEN
    RAISE;
END; --execute_structure_map
---------------------------------------------------------------------------------------
--build_structure_map->execute_model->extract_organization_id

--Extracts organization_id from cz_devl_projects.orig_sys_ref.

FUNCTION extract_organization_id RETURN PLS_INTEGER IS

  startPos  PLS_INTEGER;
  endPos    PLS_INTEGER;

BEGIN

  startPos := INSTR(modelOrigSysRef, ORIGINAL_SEPARATOR, -1, 2) + 1;
  endPos := INSTR(modelOrigSysRef, ORIGINAL_SEPARATOR, -1, 1);

  --The return value can only be a not null valid number.

  RETURN TO_NUMBER(NVL(SUBSTR(modelOrigSysRef, startPos, endPos - startPos), 'NULL'));
EXCEPTION
  WHEN OTHERS THEN
    --'Unable to extract organization id for model ''%MODELNAME'', original system reference ''%ORIGSYSREF'''
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_INVALID_ORG_ID', 'MODELNAME', modelName, 'ORIGSYSREF', modelOrigSysRef), URGENCY_WARNING);
    RAISE CZ_SYNC_NO_ORGANIZATION_ID;
END;
---------------------------------------------------------------------------------------
BEGIN --execute_model

  BEGIN

    SELECT orig_sys_ref, name, NVL ( config_engine_type, 'L' ) INTO modelOrigSysRef, modelName, modelEngineType
    FROM cz_devl_projects
    WHERE deleted_flag = FLAG_NOT_DELETED
      AND devl_project_id = p_model_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE CZ_SYNC_INCORRECT_MODEL;
  END;

  IF(modelOrigSysRef IS NOT NULL)THEN

    --This is a BOM model.

    IF(sourceServer IS NULL)THEN

      --This procedure is called for a single model, so we will get and verify the source server
      --for this particular model here. If not null, the source server has already been verified
      --from verify_source_instance procedure.
      --Also this model has to be an original model, not a publishing target model, so it has to
      --have its own record in cz_xfr_project_bills.

      BEGIN

        SELECT source_server INTO sourceServer
          FROM cz_xfr_project_bills
         WHERE model_ps_node_id = p_model_id
           AND deleted_flag = FLAG_NOT_DELETED;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE CZ_SYNC_INCORRECT_MODEL;
      END;

      verify_source_server;
    END IF;

    --We always need organization_id. We cannot always read it from cz_xfr_project_bills
    --because publishing targets will not have records there. This why we extracting the
    --value from orig_sys_ref rather than reading it from a table.

    sourceOrgId := extract_organization_id;

    --Add to the organization hash table for the resolved model if not there yet.

    IF(NOT organization_id_map.EXISTS(sourceOrgId))THEN
      BEGIN

        EXECUTE IMMEDIATE 'SELECT organization_id FROM org_organization_definitions' || targetLinkName ||
                          ' WHERE UPPER(organization_name) = ' ||
                          '  (SELECT UPPER(organization_name) FROM org_organization_definitions' || sourceLinkName ||
                          '    WHERE organization_id = :1)'
        INTO targetOrgId USING sourceOrgId;

        organization_id_map(sourceOrgId) := targetOrgId;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE CZ_SYNC_NO_ORGANIZATION_ID;
      END;
    ELSE
      targetOrgId := organization_id_map(sourceOrgId);
    END IF;

    --Populate the candidate and rollback tables for cz_model_publications. We need to do that
    --only in the SYNC mode, because we have nothing to verify.

    IF(p_execution_mode = EXECUTION_MODE_SYNC)THEN

      FOR c_pub IN (SELECT publication_id, top_item_id, organization_id, product_key
                      FROM cz_model_publications
                     WHERE model_id = p_model_id
                       AND deleted_flag = FLAG_NOT_DELETED)LOOP

        tabCandidatePubl(tabCandidatePubl.COUNT + 1) := c_pub.publication_id;
        hashRbPubOrganizationId(c_pub.publication_id) := c_pub.organization_id;
        hashRbPubTopItemId(c_pub.publication_id) := c_pub.top_item_id;
        hashRbPubProductKey(c_pub.publication_id) := c_pub.product_key;
      END LOOP;
    END IF;

    --Start the process.

    execute_structure_map(p_model_id);

  ELSE

    --This is a non-BOM model, but we still need to follow the references.

    FOR c_model IN (SELECT component_id FROM cz_model_ref_expls
                     WHERE model_id = p_model_id
                       AND deleted_flag = FLAG_NOT_DELETED
                       AND ps_node_type = PS_NODE_TYPE_REFERENCE
                       AND node_depth = 1)LOOP

      execute_model(c_model.component_id);
    END LOOP;
  END IF;

EXCEPTION
  WHEN CZ_SYNC_INCORRECT_MODEL THEN
    --'Unable to resolve the specified model id: %MODELID'
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_INCORRECT_MODEL', 'MODELID', p_model_id), URGENCY_WARNING);
  WHEN CZ_SYNC_NO_ORGANIZATION_ID THEN
    --'Unable to resolve source organization for the configuration model ''%MODELNAME'''
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_NO_ORGANIZATION_ID', 'MODELNAME', modelName), URGENCY_WARNING);
END; --execute_model
---------------------------------------------------------------------------------------
--build_structure_map->verify_target_instance

--Reads and verifies the link to the instance specified as target.

PROCEDURE verify_target_instance IS

  linkName      cz_servers.fndnam_link_name%TYPE;

BEGIN

  --Read the link name from cz_servers for the specified target instance and verify the link.

  BEGIN

    SELECT fndnam_link_name, server_local_id INTO linkName, g_target_instance
      FROM cz_servers
     WHERE UPPER(local_name) = UPPER(p_target_name);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --'Unable to resolve the specified target instance name: %TARGETNAME'
      report(CZ_UTILS.GET_TEXT('CZ_SYNC_INCORRECT_TARGET', 'TARGETNAME', p_target_name), URGENCY_ERROR);
      RAISE CZ_SYNC_GENERAL_EXCEPTION;
  END;

  IF(linkName IS NOT NULL)THEN

    verify_database_link(linkName);
    linkName := '@' || linkName;

  END IF;

  --The link is verified, assign the global variable to be used over the code.

  targetLinkName := linkName;

EXCEPTION
  WHEN CZ_SYNC_NO_DATABASE_LINK THEN
    --'Database link does not exist for the specified target instance ''%TARGETNAME'''
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_NO_DATABASE_LINK', 'TARGETNAME', p_target_name), URGENCY_ERROR);
    RAISE CZ_SYNC_GENERAL_EXCEPTION;
END; --verify_target_instance
---------------------------------------------------------------------------------------
--build_structure_map->verify_source_instance

--Verified that there is only one import source server for all models, there is no
--pending publications and the target instance is different from the import source
--server.

PROCEDURE verify_source_instance IS
BEGIN
  BEGIN

    SELECT DISTINCT source_server INTO sourceServer
      FROM cz_xfr_project_bills b, cz_devl_projects r
     WHERE b.deleted_flag = FLAG_NOT_DELETED
       AND r.deleted_flag = FLAG_NOT_DELETED
       AND b.model_ps_node_id = r.devl_project_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --'Unable to find any imported models to synchronize, import control table is empty'
      report(CZ_UTILS.GET_TEXT('CZ_SYNC_NO_MODELS'), URGENCY_ERROR);
      RAISE CZ_SYNC_GENERAL_EXCEPTION;
    WHEN TOO_MANY_ROWS THEN
      --'Multiple import source servers found, unable to synchronize'
      report(CZ_UTILS.GET_TEXT('CZ_SYNC_TOO_MANY_SERVERS'), URGENCY_ERROR);
      RAISE CZ_SYNC_GENERAL_EXCEPTION;
  END;

  --Check if any publication is currently processing.

  FOR c_pub IN (SELECT publication_id FROM cz_model_publications
                 WHERE deleted_flag = FLAG_NOT_DELETED
                   AND export_status = PUBLICATION_STATUS_PROCESSING)LOOP

    --'Synchronization cannot be done while a publication is processing. At least one publication (%PUBLICATIONID) is currently in processing status'
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_PUB_PROCESSING'), URGENCY_ERROR);
    RAISE CZ_SYNC_GENERAL_EXCEPTION;
  END LOOP;

  IF(sourceServer = g_target_instance)THEN
    --'Import source server and synchronization target instance are the same, synchronization is not required'
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_SAME_INSTANCE'), URGENCY_WARNING);
    RAISE CZ_SYNC_NORMAL_EXCEPTION;
  END IF;

  verify_source_server;
END; --verify_source_instance
---------------------------------------------------------------------------------------
--build_structure_map->clear_structure_maps

--Clears global hash tables.

PROCEDURE clear_structure_maps IS
BEGIN

  component_item_id_map.DELETE;
  component_seq_id_map.DELETE;
  catalog_group_id_map.DELETE;
  organization_id_map.DELETE;

  targetLinkName := NULL;
  g_target_instance := NULL;
END;
---------------------------------------------------------------------------------------
--build_structure_map->rollback_structure

--Rollback procedure.

PROCEDURE rollback_structure IS
BEGIN

   FOR i IN 1..nodeRollback LOOP
     UPDATE cz_ps_nodes SET
       orig_sys_ref = hashRbNodeOrigSysRef(tabCandidateNode(i)),
       component_sequence_path = hashRbNodeSequencePath(tabCandidateNode(i)),
       component_sequence_id = hashRbNodeSequenceId(tabCandidateNode(i))
     WHERE ps_node_id = tabCandidateNode(i);
     COMMIT;
   END LOOP;

   debug('Table cz_ps_nodes updates rolled back');

   FOR i IN 1..itemRollback LOOP
     UPDATE cz_item_masters SET
       orig_sys_ref = hashRbItemOrigSysRef(tabCandidateItem(i))
     WHERE item_id = tabCandidateItem(i);
     COMMIT;
   END LOOP;

   debug('Table cz_item_masters updates rolled back');

   FOR i IN 1..devlRollback LOOP
     UPDATE cz_devl_projects SET
       orig_sys_ref = hashRbDevlOrigSysRef(tabCandidateDevl(i))
     WHERE devl_project_id = tabCandidateDevl(i);
     COMMIT;
   END LOOP;

   debug('Table cz_devl_projects updates rolled back');

   FOR i IN 1..textRollback LOOP
     UPDATE cz_localized_texts SET
       orig_sys_ref = hashRbTextOrigSysRef(tabCandidateText(i))
     WHERE intl_text_id = tabCandidateText(i);
     COMMIT;
   END LOOP;

   debug('Table cz_localized_texts updates rolled back');

   FOR i IN 1..typeRollback LOOP
     UPDATE cz_item_types SET
       orig_sys_ref = hashRbTypeOrigSysRef(tabCandidateType(i))
     WHERE item_type_id = tabCandidateType(i);
     COMMIT;
   END LOOP;

   debug('Table cz_item_types updates rolled back');

   FOR i IN 1..projRollback LOOP
     UPDATE cz_xfr_project_bills SET
       organization_id = hashRbOrganizationId(tabCandidateProj(i)),
       top_item_id = hashRbTopItemId(tabCandidateProj(i)),
       component_item_id = hashRbComponentItemId(tabCandidateProj(i)),
       source_server = hashRbSourceServer(tabCandidateProj(i))
     WHERE model_ps_node_id = tabCandidateProj(i);
     COMMIT;
   END LOOP;

   debug('Table cz_xfr_project_bills updates rolled back');

   FOR i IN 1..publRollback LOOP
     UPDATE cz_model_publications SET
       organization_id = hashRbPubOrganizationId(tabCandidatePubl(i)),
       top_item_id = hashRbPubTopItemId(tabCandidatePubl(i)),
       product_key = hashRbPubProductKey(tabCandidatePubl(i))
     WHERE publication_id = tabCandidatePubl(i);
     COMMIT;
   END LOOP;

   debug('Table cz_model_publications updates rolled back');
      FOR i IN 1..tabRbItmPropValItemId.count LOOP
     UPDATE cz_item_property_values SET
       orig_sys_ref = tabRbItmPropValOrigSysRef(i)
     WHERE item_id = tabRbItmPropValItemId(i)
     and property_id=tabRbItmPropValPropId(i)
     and deleted_flag='0';
     COMMIT;
   END LOOP;

   debug('Table cz_item_property_values updates rolled back');

   FOR i IN 1..tabRbItmTypPropItTypeId.count LOOP
     UPDATE CZ_ITEM_TYPE_PROPERTIES SET
       orig_sys_ref = tabRbItmTypPropOrigSysRef(i)
     WHERE item_type_id = tabRbItmTypPropItTypeId(i)
     and property_id=tabRbItmTypPropId(i)
     and deleted_flag='0';
     COMMIT;
   END LOOP;

   debug('Table CZ_ITEM_TYPE_PROPERTIES updates rolled back');

END; --rollback_structure;
---------------------------------------------------------------------------------------
--build_structure_map->synchronize_structure

--Performs the actual database update for synchronization.

PROCEDURE synchronize_structure IS

  CommitBlockSize      PLS_INTEGER;
  textCommitBlockSize  PLS_INTEGER;
  segmentStart         PLS_INTEGER;
  segmentEnd           PLS_INTEGER;
  localCount           PLS_INTEGER;
  loopCount            PLS_INTEGER;
  l_tabRbItmPropValPropId      typePropertyId;
  l_tabRbItmTypPropId          typePropertyId;

  l_tabRbItmPropValOrigSysRef  typeOrigSysRef;
  l_tabRbItmTypPropOrigSysRef  typeOrigSysRef;

  l_tabRbItmPropValItemId      typeItemId;
  l_tabRbItmTypPropItTypeId    typeItemTypeId;

BEGIN

  --Read the commit block size.

  BEGIN

    SELECT TO_NUMBER(value) INTO CommitBlockSize
      FROM cz_db_settings
     WHERE UPPER(setting_id) = COMMIT_BLOCK_SETTING_ID
       AND UPPER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      CommitBlockSize := DEFAULT_COMMIT_BLOCK_SIZE;
  END;

  --Decrease the commit block size for cz_localized_texts according to the number of
  --installed languages.

  textCommitBlockSize := CommitBlockSize / numberOfLanguages;

  --Update cz_ps_nodes table.

  localCount := tabCandidateNode.COUNT;
  segmentStart := 1;

  debug('Updating cz_ps_nodes table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  --Have to use NVL in the following update statements, because FORALL construct is extremely
  --tolerant to any exceptions occurring inside the functions, including data not found. When
  --the exception occurs it is just like the function returned null.  This may result in lost
  --data because of the code internal bugs. When the code is known to work correctly, NVL can
  --be removed if they decrease performance.

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + CommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    nodeRollback := segmentEnd;

    FORALL i IN segmentStart..segmentEnd
     UPDATE cz_ps_nodes SET
       orig_sys_ref = NVL(psnode_origSysRef(orig_sys_ref), orig_sys_ref),
       component_sequence_path = NVL(psnode_compSeqPath(component_sequence_path), component_sequence_path),
       component_sequence_id = NVL(psnode_compSeqId(component_sequence_id), component_sequence_id)
     WHERE ps_node_id = tabCandidateNode(i);

    COMMIT;
    segmentStart := segmentEnd + 1;

  END LOOP;

  --Update cz_item_masters table.

  localCount := tabCandidateItem.COUNT;
  segmentStart := 1;

  debug('Updating cz_item_masters table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + CommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    itemRollback := segmentEnd;

    FORALL i IN segmentStart..segmentEnd
     UPDATE cz_item_masters SET
       orig_sys_ref = NVL(itemMaster_origSysRef(orig_sys_ref), orig_sys_ref)
     WHERE item_id = tabCandidateItem(i);

    COMMIT;
    segmentStart := segmentEnd + 1;

  END LOOP;

  --Update cz_devl_projects table.

  localCount := tabCandidateDevl.COUNT;
  segmentStart := 1;

  debug('Updating cz_devl_projects table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + CommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    devlRollback := segmentEnd;

    FORALL i IN segmentStart..segmentEnd
     UPDATE cz_devl_projects SET
       orig_sys_ref = NVL(devlProject_origSysRef(orig_sys_ref), orig_sys_ref)
     WHERE devl_project_id = tabCandidateDevl(i);

    COMMIT;
    segmentStart := segmentEnd + 1;

  END LOOP;

  --Update cz_localized_texts table.

  localCount := tabCandidateText.COUNT;
  segmentStart := 1;

  debug('Updating cz_localized_texts table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + textCommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    textRollback := segmentEnd;

    FORALL i IN segmentStart..segmentEnd
     UPDATE cz_localized_texts SET
       orig_sys_ref = NVL(locText_origSysRef(orig_sys_ref), orig_sys_ref)
     WHERE intl_text_id = tabCandidateText(i);

    COMMIT;
    segmentStart := segmentEnd + 1;

  END LOOP;

  --Update cz_item_types table.

  localCount := tabCandidateType.COUNT;
  segmentStart := 1;

  debug('Updating cz_item_types table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + textCommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    typeRollback := segmentEnd;

    FORALL i IN segmentStart..segmentEnd
     UPDATE cz_item_types SET
       orig_sys_ref = NVL(itemtype_origSysRef(orig_sys_ref), orig_sys_ref)
     WHERE item_type_id = tabCandidateType(i);

    COMMIT;
    segmentStart := segmentEnd + 1;

  END LOOP;

  --Update cz_xfr_project_bills table.

  localCount := tabCandidateProj.COUNT;
  segmentStart := 1;

  debug('Updating cz_xfr_project_bills table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + CommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    projRollback := segmentEnd;

    FORALL i IN segmentStart..segmentEnd
     UPDATE cz_xfr_project_bills SET
       organization_id = NVL(projectBill_orgId(organization_id), organization_id),
       top_item_id = NVL(projectBill_topItemId(top_item_id), top_item_id),
       component_item_id = NVL(projectBill_compItemId(component_item_id), component_item_id),
       source_server = NVL(projectBill_sourceServer(source_server), source_server)
     WHERE model_ps_node_id = tabCandidateProj(i);

    COMMIT;
    segmentStart := segmentEnd + 1;

  END LOOP;

  --Update cz_model_publications table.

  localCount := tabCandidatePubl.COUNT;
  segmentStart := 1;

  debug('Updating cz_model_publications table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + CommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    publRollback := segmentEnd;

    FORALL i IN segmentStart..segmentEnd
     UPDATE cz_model_publications SET
       organization_id = NVL(modelPublication_orgId(organization_id), organization_id),
       top_item_id = NVL(modelPublication_topItemId(top_item_id), top_item_id),
       product_key = NVL(modelPublication_productKey(product_key), product_key)
     WHERE publication_id = tabCandidatePubl(i);

    COMMIT;
    segmentStart := segmentEnd + 1;

  END LOOP;

 --Update cz_item_property_values  table.

  localCount := tabCandidateItem.COUNT;
  segmentStart := 1;

  debug('Updating cz_item_property_values table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + CommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    itemPropValRollback := segmentEnd;

     for i IN segmentStart..segmentEnd LOOP

     select ITEM_ID,PROPERTY_ID,ORIG_SYS_REF
     BULK COLLECT INTO l_tabRbItmPropValItemId,l_tabRbItmPropValPropId,l_tabRbItmPropValOrigSysRef
     FROM  cz_item_property_values where item_id = tabCandidateItem(i)
     and deleted_flag='0';

     loopCount:=tabRbItmPropValItemId.count;
     for j in 1..l_tabRbItmPropValItemId.COUNT
     LOOP

      loopCount:=loopCount+1;
      tabRbItmPropValItemId(loopCount):=l_tabRbItmPropValItemId(j);
      tabRbItmPropValPropId(loopCount):=l_tabRbItmPropValPropId(j);
      tabRbItmPropValOrigSysRef(loopCount):=l_tabRbItmPropValOrigSysRef(j);

     END LOOP;
    END LOOP;

    FORALL i IN segmentStart..segmentEnd

     UPDATE cz_item_property_values SET
       orig_sys_ref = NVL(itemPropValues_origSysRef(orig_sys_ref),orig_sys_ref)
       WHERE item_id = tabCandidateItem(i)
       and deleted_flag='0';

    COMMIT;
    segmentStart := segmentEnd + 1;
  END LOOP;

   --Update CZ_ITEM_TYPE_PROPERTIES  table.

  localCount := tabCandidateType.COUNT;
  segmentStart := 1;

  debug('Updating CZ_ITEM_TYPE_PROPERTIES table, ' || localCount || ' update candidate records, time started: ' || TO_CHAR(SYSDATE,'HH24:MI:SS'));

  WHILE(segmentStart <= localCount)LOOP

    segmentEnd := segmentStart + CommitBlockSize - 1;
    IF(segmentEnd > localCount)THEN segmentEnd := localCount; END IF;
    itemTypePropRollback := segmentEnd;

     for i IN segmentStart..segmentEnd LOOP
     select ITEM_TYPE_ID,PROPERTY_ID,ORIG_SYS_REF
     BULK COLLECT INTO l_tabRbItmTypPropItTypeId,l_tabRbItmTypPropId,l_tabRbItmTypPropOrigSysRef
     FROM cz_item_type_properties where item_type_id = tabCandidateType(i)
     and deleted_flag='0';

     loopCount:=tabRbItmTypPropItTypeId.count;
     for j in 1..l_tabRbItmTypPropItTypeId.COUNT
     LOOP

      loopCount:=loopCount+1;
      tabRbItmTypPropItTypeId(loopCount):=l_tabRbItmTypPropItTypeId(j);
      tabRbItmTypPropId(loopCount):=l_tabRbItmTypPropId(j);
      tabRbItmTypPropOrigSysRef(loopCount):=l_tabRbItmTypPropOrigSysRef(j);

     END LOOP;
    END LOOP;

    FORALL i IN segmentStart..segmentEnd
     UPDATE CZ_ITEM_TYPE_PROPERTIES SET
       orig_sys_ref = NVL(itemTypeProp_origSysRef(orig_sys_ref),orig_sys_ref)
       WHERE item_type_id = tabCandidateType(i)
       and deleted_flag='0';

    COMMIT;
    segmentStart := segmentEnd + 1;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    rollback_structure;
    RAISE;
END; --synchronize_structure;
---------------------------------------------------------------------------------------
BEGIN --build_structure_map

  p_error_flag := ERROR_FLAG_SUCCESS;

  --Take care of the run_id.

  IF(p_run_id IS NULL)THEN
   SELECT cz_xfr_run_infos_s.NEXTVAL INTO p_run_id FROM DUAL;
  END IF;

  --Read the version of the software and log the header message.
  --We do not want to stop just because an error occurs at this point, so we use the
  --unconditional exception handler. As the only known problem that may occur inside
  --this exception block is obviously a server bug (substr(substr(,),) does not work
  --when selecting from user_source) we are not logging any messages.

  --Bug #4865406. There is no need to query against user_source.

  BEGIN

    thisVersionString := SUBSTR(SUBSTR(GenHeader, INSTR(GenHeader, THIS_FILE_NAME) + LENGTH(THIS_FILE_NAME) + 1), 1,
                  INSTR(SUBSTR(GenHeader, INSTR(GenHeader, THIS_FILE_NAME) + LENGTH(THIS_FILE_NAME) + 1), ' ') - 1);

    --'Synchronization software version %VERSION started %DATETIME, session run ID: %RUNID'
    report(CZ_UTILS.GET_TEXT('CZ_SYNC_VERSION_INFO', 'VERSION', thisVersionString, 'DATETIME',
                      TO_CHAR(SYSDATE, THIS_DATE_FORMAT),'RUNID', p_run_id), URGENCY_MESSAGE);

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --Read the database settings.

  BEGIN

    --Get the flag determining whether to verify item properties, default - yes.

    SELECT DECODE(UPPER(value), '1', 1, 'ON',  1, 'Y', 1, 'YES', 1,'TRUE',  1, 'ENABLE',  1,
                                '0', 0, 'OFF', 0, 'N', 0, 'NO',  0,'FALSE', 0, 'DISABLE', 0,
                                1) --default value
      INTO VerifyItemProperties
      FROM cz_db_settings
     WHERE UPPER(setting_id) = VERIFY_PROPERTIES_SETTING_ID
       AND UPPER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      VerifyItemProperties := 1; --enforce the default value
  END;

  BEGIN

    --Get the number of days from now after which a date is considered to be the epoch end date.

    SELECT TO_NUMBER(value) INTO DaysTillEpochEnd
      FROM cz_db_settings
     WHERE UPPER(setting_id) = DAYSTILLEPOCHEND_SETTING_ID
       AND UPPER(section_name) = DBSETTINGS_SECTION_NAME;

  EXCEPTION
    WHEN OTHERS THEN
      DaysTillEpochEnd := DEFAULT_DAYSTILLEPOCHEND; --enforce the default value
  END;

  --Calculate the date after which any date becomes the epoch end date.

  EpochEndLine := SYSDATE + DaysTillEpochEnd;
  IF(EpochEndLine > EpochEndDate)THEN EpochEndLine := EpochEndDate; END IF;

  --Read the base/installed languages information.

  BEGIN

    SELECT language_code INTO baseLanguageCode
      FROM fnd_languages
     WHERE installed_flag = FND_LANGUAGES_BASE;

    SELECT count(*) + 1 INTO numberOfLanguages
      FROM fnd_languages
     WHERE installed_flag = FND_LANGUAGES_INSTALLED;

  EXCEPTION
    WHEN OTHERS THEN
      --'Language information is not available'
      report(CZ_UTILS.GET_TEXT('CZ_SYNC_NO_LANGUAGE_INFO'), URGENCY_WARNING);
  END;

  clear_structure_maps;
  verify_target_instance;

  --Cash the item types data. Consider only imported item types and make sure orig_sys_ref
  --can be resolved to an integer.

  BEGIN

    SELECT item_type_id, name, orig_sys_ref
    BULK COLLECT INTO tabItemTypeId, tabItemTypeName, tabItemTypeOrigSysRef
    FROM cz_item_types
    WHERE deleted_flag = FLAG_NOT_DELETED
      AND orig_sys_ref IS NOT NULL
      AND REPLACE(TRANSLATE(orig_sys_ref, '0123456789', '0000000000'), '0', NULL) IS NULL;

    FOR i IN 1..tabItemTypeId.COUNT LOOP

      hashItemTypeId(tabItemTypeId(i)) := TO_NUMBER(tabItemTypeOrigSysRef(i));
      hashItemTypeName(tabItemTypeId(i)) := tabItemTypeName(i);
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      --'Error while reading item types: %ERRORTEXT'
      report(CZ_UTILS.GET_TEXT('CZ_SYNC_NO_ITEM_TYPES', 'ERRORTEXT', SQLERRM), URGENCY_WARNING);
  END;

  IF(p_model_id IS NOT NULL)THEN

    --Verify the single model specified.

    execute_model(p_model_id);

  ELSE

    verify_source_instance;

    --Verify all the eligible models. All the repository models are eligible anyway.

    FOR c_model IN (SELECT object_id FROM cz_rp_entries
                     WHERE deleted_flag = FLAG_NOT_DELETED
                       AND object_type = REPOSITORY_TYPE_PROJECT) LOOP

      execute_model(c_model.object_id);
    END LOOP;

    --If we will be synchronizing to the local instance, we also need to verify all
    --the models created by publishing.

    IF(g_target_instance = LOCAL_SERVER_SEED_ID)THEN

      FOR c_model IN (SELECT model_id FROM cz_model_publications
                       WHERE deleted_flag = FLAG_NOT_DELETED
                         AND source_target_flag = PUBLICATION_TARGET_FLAG
                         AND export_status = PUBLICATION_STATUS_OK) LOOP

        execute_model(c_model.model_id);
      END LOOP;
    END IF;
  END IF;

  --Synchronize if called in the synchronization mode.

  IF(p_execution_mode = EXECUTION_MODE_SYNC)THEN

    synchronize_structure;

    --Mark deleted all the imported items that are not referenced from the product structure,
    --because these items have not been synchronize and may cause problems for consequtive
    --BOM import.
    --Bug #3634107.

    UPDATE cz_item_masters item SET deleted_flag = '1'
     WHERE deleted_flag = FLAG_NOT_DELETED
       AND src_application_id = 401
       AND NOT EXISTS
     (SELECT NULL FROM cz_ps_nodes
       WHERE deleted_flag = FLAG_NOT_DELETED
         AND item_id = item.item_id);

    COMMIT;
  END IF;

--Here we handle all the user-defined fatal exception that terminate the execution and
--all other exceptions that may occur.

EXCEPTION
  WHEN CZ_SYNC_NORMAL_EXCEPTION THEN
    --This exception is used when the program needs to terminate immediately without error.
    --An appropriate message has already been logged, so just set the flag.
    p_error_flag := ERROR_FLAG_SUCCESS;
  WHEN CZ_SYNC_GENERAL_EXCEPTION THEN
    --The error has already been logged because this exception is raised from anywhere
    --in the code in order to terminate the execution. So, just set the flag.
    p_error_flag := ERROR_FLAG_ERROR;
  WHEN OTHERS THEN
    p_error_flag := ERROR_FLAG_ERROR;
    --'Unable to continue because of %ERRORTEXT'
    report_on_exit(CZ_UTILS.GET_TEXT('CZ_G_GENERAL_ERROR', 'ERRORTEXT', SQLERRM));
END; --build_structure_map
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
FUNCTION psnode_origSysRef(p_orig_sys_ref IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_str            VARCHAR2(1200) := p_orig_sys_ref;
  v_comp_code      VARCHAR2(1000);
  v_expl_type      VARCHAR2(20);
  v_org_id         VARCHAR2(20);
  v_item_id        VARCHAR2(20);
  v_delim_pos      INTEGER;
  v_ret_val        VARCHAR2(1200);

BEGIN
  -- format of cz_ps_nodes.orig_sys_ref:  comp_code:expl_type:org_id:top_item_id
  IF (p_orig_sys_ref IS NOT NULL) THEN
    v_delim_pos := instr(v_str, ':', -1);
    v_item_id := TO_CHAR(component_item_id_map(TO_NUMBER(substr(v_str, v_delim_pos + 1))));
    v_str := substr(v_str, 1, v_delim_pos - 1);

    v_delim_pos := instr(v_str, ':', -1);
    v_org_id := TO_CHAR(organization_id_map(TO_NUMBER(substr(v_str, v_delim_pos + 1))));
    v_str := substr(v_str, 1, v_delim_pos - 1);

    v_delim_pos := instr(v_str, ':');
    IF (v_delim_pos = 0) THEN
      v_ret_val := v_str || ':' || v_org_id || ':' || v_item_id;
    ELSE
      v_expl_type := substr(v_str, v_delim_pos);
      v_str := substr(v_str, 1, v_delim_pos - 1);

      v_delim_pos := instr(v_str, '-');
      WHILE (v_delim_pos <> 0) LOOP
        v_comp_code := v_comp_code || '-' || TO_CHAR(component_item_id_map(TO_NUMBER(substr(v_str, 1, v_delim_pos - 1))));
        v_str := substr(v_str, v_delim_pos + 1);
        v_delim_pos := instr(v_str, '-');
      END LOOP;
      v_comp_code := v_comp_code || '-' || TO_CHAR(component_item_id_map(TO_NUMBER(v_str)));
      v_ret_val := substr(v_comp_code, 2) || v_expl_type || ':' || v_org_id || ':' || v_item_id;
    END IF;
  END IF;

  RETURN v_ret_val;

END psnode_origSysRef;

---------------------------------------------------------------------------------------
FUNCTION psnode_compSeqPath(p_component_seq_path IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_str           VARCHAR2(2000) := p_component_seq_path;
  v_delim_pos     INTEGER;
  v_ret_val       VARCHAR2(2000);

BEGIN
  IF (p_component_seq_path IS NOT NULL) THEN
    v_delim_pos := instr(v_str, '-');
    WHILE (v_delim_pos <> 0) LOOP
      v_ret_val := v_ret_val || '-' || TO_CHAR(component_seq_id_map(TO_NUMBER(substr(v_str, 1, v_delim_pos - 1))));
      v_str := substr(v_str, v_delim_pos + 1);
      v_delim_pos := instr(v_str, '-');
    END LOOP;

    v_ret_val := v_ret_val || '-' || TO_CHAR(component_seq_id_map(TO_NUMBER(v_str)));
    RETURN substr(v_ret_val, 2);
  END IF;

  RETURN NULL;
END psnode_compSeqPath;

---------------------------------------------------------------------------------------
FUNCTION psnode_compSeqId(p_component_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  IF (p_component_id IS NOT NULL) THEN
    RETURN component_seq_id_map(p_component_id);
  END IF;

  RETURN NULL;
END psnode_compSeqId;

---------------------------------------------------------------------------------------
FUNCTION itemMaster_origSysRef(p_orig_sys_ref IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_delim_pos    INTEGER;
  v_item_id      VARCHAR2(20);
  v_org_id       VARCHAR2(20);

BEGIN
  --format of cz_item_mstater.orig_sys_ref:  inv_item_id:org_id
  IF (p_orig_sys_ref IS NOT NULL) THEN
    v_delim_pos := instr(p_orig_sys_ref, ':');
    v_item_id := TO_CHAR(component_item_id_map(TO_NUMBER(substr(p_orig_sys_ref, 1, v_delim_pos - 1))));
    v_org_id := TO_CHAR(organization_id_map(TO_NUMBER(substr(p_orig_sys_ref, v_delim_pos + 1))));
    RETURN (v_item_id || ':' || v_org_id);
  END IF;

  RETURN NULL;
END itemMaster_origSysRef;

---------------------------------------------------------------------------------------
FUNCTION itemPropValues_origSysRef(p_orig_sys_ref IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_inv_id_pos    INTEGER;
  v_org_id_pos    INTEGER;
  v_item_id      VARCHAR2(20);
  v_org_id       VARCHAR2(20);

BEGIN
  --format of cz_item_property_values.orig_sys_ref:  inv_item_id:property_id
  IF (p_orig_sys_ref IS NOT NULL) THEN
    v_inv_id_pos := instr(p_orig_sys_ref, ':',1,1);
    v_org_id_pos := instr(p_orig_sys_ref, ':',1,2);
    v_item_id := TO_CHAR(component_item_id_map(TO_NUMBER(substr(p_orig_sys_ref, 1, v_inv_id_pos - 1))));
    v_org_id := TO_CHAR(organization_id_map(TO_NUMBER(substr(p_orig_sys_ref,v_inv_id_pos+1,v_org_id_pos-(v_inv_id_pos+1)))));
    RETURN (v_item_id || ':' || v_org_id||substr(p_orig_sys_ref,v_org_id_pos));
    END IF;

  RETURN NULL;
END itemPropValues_origSysRef;

FUNCTION itemTypeProp_origSysRef(p_orig_sys_ref IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_inv_id_pos    INTEGER;
  v_catalog_grp_id      VARCHAR2(20);

BEGIN
  --format of CZ_ITEM_TYPE_PROPERTIES.orig_sys_ref:  catalog_group_id:..
  IF (p_orig_sys_ref IS NOT NULL) THEN
    v_inv_id_pos := instr(p_orig_sys_ref, ':',1,1);
    v_catalog_grp_id := TO_CHAR(catalog_group_id_map(TO_NUMBER(substr(p_orig_sys_ref, 1, v_inv_id_pos - 1))));
    RETURN (v_catalog_grp_id ||substr(p_orig_sys_ref,v_inv_id_pos));
    END IF;

  RETURN NULL;
END itemTypeProp_origSysRef;

---------------------------------------------------------------------------------------
FUNCTION itemType_origSysRef(p_orig_sys_ref IN VARCHAR2)
  RETURN VARCHAR2
IS

BEGIN
  IF (p_orig_sys_ref IS NOT NULL) THEN
    RETURN TO_CHAR(catalog_group_id_map(TO_NUMBER(p_orig_sys_ref)));
  END IF;

  RETURN NULL;
END itemType_origSysRef;

---------------------------------------------------------------------------------------
FUNCTION devlProject_origSysRef(p_orig_sys_ref IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_str           VARCHAR2(255) := p_orig_sys_ref;
  v_delim_pos     INTEGER;
  v_item_id       VARCHAR2(20);
  v_org_id        VARCHAR2(20);
  v_expl_type     VARCHAR2(20);

BEGIN
  -- format of cz_devl_projects.orig_sys_ref:  expl_type:org_id:top_item_id
  IF (p_orig_sys_ref IS NOT NULL) THEN
    v_delim_pos := instr(v_str, ':');
    v_expl_type := substr(v_str, 1, v_delim_pos);
    v_str := substr(v_str, v_delim_pos + 1);

    v_delim_pos := instr(v_str, ':');
    v_org_id := TO_CHAR(organization_id_map(TO_NUMBER(substr(v_str, 1, v_delim_pos - 1))));
    v_item_id := TO_CHAR(component_item_id_map(TO_NUMBER(substr(v_str, v_delim_pos + 1))));

    RETURN (v_expl_type || v_org_id || ':' || v_item_id);
  END IF;

  RETURN NULL;
END devlProject_origSysRef;

---------------------------------------------------------------------------------------
FUNCTION locText_origSysRef(p_orig_sys_ref IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_delim_pos     INTEGER;
  v_str           VARCHAR2(255) := p_orig_sys_ref;
  v_item_id       VARCHAR2(20);
  v_org_id        VARCHAR2(20);
  v_compSeqId     VARCHAR2(20);
  v_expl_type     VARCHAR2(20);

BEGIN
  -- format of cz_localized_texts.orig_sys_ref:  item_id:expl_type:org_id:comp_seq_id
  IF (p_orig_sys_ref IS NOT NULL) THEN
    v_delim_pos := instr(v_str, ':');
    v_item_id := TO_CHAR(component_item_id_map(TO_NUMBER(substr(v_str, 1, v_delim_pos - 1))));
    v_str := substr(v_str, v_delim_pos);

    v_delim_pos := instr(v_str, ':', 2);
    v_expl_type := substr(v_str, 1, v_delim_pos);
    v_str := substr(v_str, v_delim_pos+1);
    v_delim_pos := instr(v_str, ':', -1);
    v_org_id := TO_CHAR(organization_id_map(TO_NUMBER(substr(v_str,1, v_delim_pos -1))));
    v_compSeqId := TO_CHAR(component_seq_id_map(TO_NUMBER(substr(v_str, v_delim_pos+1))));
    RETURN (v_item_id || v_expl_type || v_org_id || ':' || v_compSeqId);
  END IF;
  RETURN NULL;
EXCEPTION WHEN OTHERS THEN
RETURN NULL;
END locText_origSysRef;

---------------------------------------------------------------------------------------
FUNCTION projectBill_orgId(p_organization_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  IF (p_organization_id IS NOT NULL) THEN
    RETURN organization_id_map(p_organization_id);
  END IF;

  RETURN NULL;
END projectBill_orgId;

---------------------------------------------------------------------------------------
FUNCTION projectBill_topItemId(p_top_item_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  IF (p_top_item_id IS NOT NULL) THEN
    RETURN component_item_id_map(p_top_item_id);
  END IF;

  RETURN NULL;
END projectBill_topItemId;

---------------------------------------------------------------------------------------
FUNCTION projectBill_compItemId(p_component_item_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  IF (p_component_item_id IS NOT NULL) THEN
    RETURN component_item_id_map(p_component_item_id);
  END IF;

  RETURN NULL;
END projectBill_compItemId;

---------------------------------------------------------------------------------------
FUNCTION projectBill_sourceServer(p_server_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  RETURN g_target_instance;
END projectBill_sourceServer;

---------------------------------------------------------------------------------------
FUNCTION modelPublication_productKey(p_product_key IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_delim_pos    INTEGER;
  v_item_id      VARCHAR2(20);
  v_org_id       VARCHAR2(20);

BEGIN
  --format of cz_model_publications.product_key: org_id:inv_item_id
  IF (p_product_key IS NOT NULL) THEN
    v_delim_pos := instr(p_product_key, ':');
    v_org_id := TO_CHAR(organization_id_map(TO_NUMBER(substr(p_product_key, 1, v_delim_pos - 1))));
    v_item_id := TO_CHAR(component_item_id_map(TO_NUMBER(substr(p_product_key, v_delim_pos + 1))));
    RETURN (v_org_id || ':' || v_item_id);
  END IF;

  RETURN NULL;
END modelPublication_productKey;

---------------------------------------------------------------------------------------
FUNCTION modelPublication_topItemId(p_top_item_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  IF (p_top_item_id IS NOT NULL) THEN
    RETURN component_item_id_map(p_top_item_id);
  END IF;

  RETURN NULL;
END modelPublication_topItemId;

---------------------------------------------------------------------------------------
FUNCTION modelPublication_orgId(p_organization_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  IF (p_organization_id IS NOT NULL) THEN
    RETURN organization_id_map(p_organization_id);
  END IF;

  RETURN NULL;
END modelPublication_orgId;

---------------------------------------------------------------------------------------
FUNCTION devlProject_invId(p_inventory_item_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  IF (p_inventory_item_id IS NOT NULL) THEN
    RETURN component_item_id_map(p_inventory_item_id);
  END IF;

  RETURN NULL;
END devlProject_invId;

----------------------------
FUNCTION devlProject_orgId(p_organization_id IN NUMBER)
  RETURN NUMBER
IS

BEGIN
  IF (p_organization_id IS NOT NULL) THEN
    RETURN organization_id_map(p_organization_id);
  END IF;

  RETURN NULL;
END devlProject_orgId;

----------------------------
FUNCTION devlProject_productKey(p_product_key IN VARCHAR2)
  RETURN VARCHAR2
IS
  v_delim_pos    INTEGER;
  v_item_id      VARCHAR2(20);
  v_org_id       VARCHAR2(20);

BEGIN
  --format of cz_model_publications.product_key: org_id:inv_item_id
  IF (p_product_key IS NOT NULL) THEN
    v_delim_pos := instr(p_product_key, ':');
    v_org_id := TO_CHAR(organization_id_map(TO_NUMBER(substr(p_product_key, 1, v_delim_pos - 1))));
    v_item_id := TO_CHAR(component_item_id_map(TO_NUMBER(substr(p_product_key, v_delim_pos + 1))));
    RETURN (v_org_id || ':' || v_item_id);
  END IF;

  RETURN NULL;
END devlProject_productKey;

-----------------------------------------------------------------
END CZ_BOM_SYNCH;

/
