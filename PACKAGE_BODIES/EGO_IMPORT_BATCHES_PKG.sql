--------------------------------------------------------
--  DDL for Package Body EGO_IMPORT_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_IMPORT_BATCHES_PKG" AS
/* $Header: EGOVBATB.pls 120.0.12010000.2 2009/04/02 01:58:16 geguo ship $ */

  PROCEDURE INSERT_ROW (
    X_ROWID                  IN OUT NOCOPY VARCHAR2,
    X_BATCH_ID               IN NUMBER,
    X_ORGANIZATION_ID        IN NUMBER,
    X_SOURCE_SYSTEM_ID       IN NUMBER,
    X_BATCH_TYPE             IN VARCHAR2,
    X_ASSIGNEE               IN NUMBER,
    X_BATCH_STATUS           IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER  IN NUMBER,
    X_NAME                   IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    X_CREATION_DATE          IN DATE,
    X_CREATED_BY             IN NUMBER,
    X_LAST_UPDATE_DATE       IN DATE,
    X_LAST_UPDATED_BY        IN NUMBER,
    X_LAST_UPDATE_LOGIN      IN NUMBER)
   IS
    CURSOR C IS
      SELECT ROWID FROM EGO_IMPORT_BATCHES_B
      WHERE BATCH_ID = X_BATCH_ID;
  BEGIN
    INSERT into EGO_IMPORT_BATCHES_B (
      ORGANIZATION_ID,
      BATCH_ID,
      SOURCE_SYSTEM_ID,
      BATCH_TYPE,
      ASSIGNEE,
      BATCH_STATUS,
      OBJECT_VERSION_NUMBER,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
    ) values (
      X_ORGANIZATION_ID,
      X_BATCH_ID,
      X_SOURCE_SYSTEM_ID,
      X_BATCH_TYPE,
      X_ASSIGNEE,
      X_BATCH_STATUS,
      X_OBJECT_VERSION_NUMBER,
      X_CREATION_DATE,
      X_CREATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN
    );

    INSERT into EGO_IMPORT_BATCHES_TL (
      BATCH_ID,
      NAME,
      DESCRIPTION,
      OBJECT_VERSION_NUMBER,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    ) SELECT
      X_BATCH_ID,
      X_NAME,
      X_DESCRIPTION,
      X_OBJECT_VERSION_NUMBER,
      X_CREATED_BY,
      X_CREATION_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      USERENV('LANG')
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND NOT EXISTS
      (SELECT NULL
      FROM EGO_IMPORT_BATCHES_TL T
      WHERE T.BATCH_ID = X_BATCH_ID
      AND T.LANGUAGE = L.LANGUAGE_CODE);

    OPEN C;
    FETCH C INTO X_ROWID;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
  END INSERT_ROW;

  PROCEDURE LOCK_ROW (
    X_BATCH_ID               IN NUMBER,
    X_ORGANIZATION_ID        IN NUMBER,
    X_SOURCE_SYSTEM_ID       IN NUMBER,
    X_BATCH_TYPE             IN VARCHAR2,
    X_ASSIGNEE               IN NUMBER,
    X_BATCH_STATUS           IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER  IN NUMBER,
    X_NAME                   IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2
  ) IS
    CURSOR C IS
      SELECT
        ORGANIZATION_ID,
        SOURCE_SYSTEM_ID,
        BATCH_TYPE,
        ASSIGNEE,
        BATCH_STATUS,
        OBJECT_VERSION_NUMBER
      FROM EGO_IMPORT_BATCHES_B
      WHERE BATCH_ID = X_BATCH_ID
      FOR UPDATE OF BATCH_ID NOWAIT;

    RECINFO C%ROWTYPE;

    CURSOR C1 IS
      SELECT
        NAME,
        DESCRIPTION,
        DECODE(LANGUAGE, USERENV('LANG'), 'Y', 'N') BASELANG
      FROM EGO_IMPORT_BATCHES_TL
      WHERE BATCH_ID = X_BATCH_ID
      AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
      FOR UPDATE OF BATCH_ID NOWAIT;
  BEGIN
    OPEN C;
    FETCH C INTO recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (    (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
        AND (recinfo.SOURCE_SYSTEM_ID = X_SOURCE_SYSTEM_ID)
        AND (recinfo.BATCH_TYPE = X_BATCH_TYPE)
        AND ((recinfo.ASSIGNEE = X_ASSIGNEE)
             OR ((recinfo.ASSIGNEE IS NULL) AND (X_ASSIGNEE IS NULL)))
        AND (recinfo.BATCH_STATUS = X_BATCH_STATUS)
        AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
    ) THEN
      NULL;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    FOR tlinfo IN c1 LOOP
      IF (tlinfo.BASELANG = 'Y') THEN
        IF (    (tlinfo.NAME = X_NAME)
            AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
                 OR ((tlinfo.DESCRIPTION IS NULL) AND (X_DESCRIPTION IS NULL)))
        ) THEN
          NULL;
        ELSE
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      END IF;
    END LOOP;
    RETURN;
  END LOCK_ROW;

  PROCEDURE UPDATE_ROW (
    X_BATCH_ID               IN NUMBER,
    X_ORGANIZATION_ID        IN NUMBER,
    X_SOURCE_SYSTEM_ID       IN NUMBER,
    X_BATCH_TYPE             IN VARCHAR2,
    X_ASSIGNEE               IN NUMBER,
    X_BATCH_STATUS           IN VARCHAR2,
    X_OBJECT_VERSION_NUMBER  IN NUMBER,
    X_NAME                   IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    X_LAST_UPDATE_DATE       IN DATE,
    X_LAST_UPDATED_BY        IN NUMBER,
    X_LAST_UPDATE_LOGIN      IN NUMBER
  ) IS
  BEGIN
    UPDATE EGO_IMPORT_BATCHES_B SET
      ORGANIZATION_ID = X_ORGANIZATION_ID,
      SOURCE_SYSTEM_ID = X_SOURCE_SYSTEM_ID,
      BATCH_TYPE = X_BATCH_TYPE,
      ASSIGNEE = X_ASSIGNEE,
      BATCH_STATUS = X_BATCH_STATUS,
      OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    WHERE BATCH_ID = X_BATCH_ID;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    UPDATE EGO_IMPORT_BATCHES_TL SET
      NAME = X_NAME,
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      SOURCE_LANG = USERENV('LANG')
    WHERE BATCH_ID = X_BATCH_ID
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END UPDATE_ROW;

  PROCEDURE DELETE_ROW (
    X_BATCH_ID IN NUMBER
  ) IS
  BEGIN
    DELETE FROM EGO_IMPORT_BATCHES_TL
    WHERE BATCH_ID = X_BATCH_ID;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    DELETE FROM EGO_IMPORT_BATCHES_B
    WHERE BATCH_ID = X_BATCH_ID;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END DELETE_ROW;


  PROCEDURE ADD_LANGUAGE
  IS
  BEGIN
    DELETE FROM EGO_IMPORT_BATCHES_TL T
    WHERE NOT EXISTS
      (SELECT NULL
      FROM EGO_IMPORT_BATCHES_B B
      WHERE B.BATCH_ID = T.BATCH_ID
      );

    UPDATE EGO_IMPORT_BATCHES_TL T SET (
        NAME,
        DESCRIPTION
      ) = (SELECT
        B.NAME,
        B.DESCRIPTION
      FROM EGO_IMPORT_BATCHES_TL B
      WHERE B.BATCH_ID = T.BATCH_ID
      AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (
        T.BATCH_ID,
        T.LANGUAGE
    ) IN (SELECT
        SUBT.BATCH_ID,
        SUBT.LANGUAGE
      FROM EGO_IMPORT_BATCHES_TL SUBB, EGO_IMPORT_BATCHES_TL SUBT
      WHERE SUBB.BATCH_ID = SUBT.BATCH_ID
      AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
      AND (SUBB.NAME <> SUBT.NAME
        OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
        OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
        OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
    ));

    INSERT INTO EGO_IMPORT_BATCHES_TL (
      BATCH_ID,
      NAME,
      DESCRIPTION,
      OBJECT_VERSION_NUMBER,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      LANGUAGE,
      SOURCE_LANG
    ) SELECT /*+ ORDERED */
      B.BATCH_ID,
      B.NAME,
      B.DESCRIPTION,
      B.OBJECT_VERSION_NUMBER,
      B.CREATED_BY,
      B.CREATION_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATE_LOGIN,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
    FROM EGO_IMPORT_BATCHES_TL B, FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND B.LANGUAGE = USERENV('LANG')
    AND NOT EXISTS
      (SELECT NULL
      FROM EGO_IMPORT_BATCHES_TL T
      WHERE T.BATCH_ID = B.BATCH_ID
      AND T.LANGUAGE = L.LANGUAGE_CODE);
  END ADD_LANGUAGE;

    /*Use this pulbic API to create item/structure import batch.
  * This API can create both PIMDH and none-PIMDH type import batches.
  * It will take 'PIMDH' as default if user not pass-in argument source system code.
  * If hasn't input any particular parameters, this pl/sql API will load
  * source system default setting.
  * Current version of API does not support creation of a new change order.
  *
  * @param p_source_system_code         A code indicating the Source System.
  * @param p_organization_id
  * @param p_batch_type_display_name    A code indicating the type for this import batch.
  *                                       Canditate values: 'Item','Structure', not case sensitive.
  * @param p_assignee_name              Indicate the user to whom this batch will been assigned. Default value: fnd_global.user_id.
  * @param p_batch_name
  * @param p_apply_def_match_rule_all   A flag indicating if apply the default match rule to all the items/structures within this batch.
  * @param p_match_on_data_load         A flag indicating if automatically match once data loaded.
  * @param p_confirm_single_match       A flag indicating if automatically confirm single matches.
  * @param p_import_on_data_load        A flag indicating if automatically import on data load.
  * @param p_import_xref_only           A flag indicating if import all data or only cross reference.
  *                                       Only N or null make sense the CO and NIR input.
  * @param p_revision_import_policy     A flag indicating the revision import policy.
  *                                       Candidate values: 'L' for update latest, or 'N' for create new.
  * @param p_structure_name             A code indicating the internal structure type name.
  * @param p_structure_effectivity_type A Number indicating the effectivity control type of the structure
  *                                       candidate values: 1 indicate using serial number or unit effectivity
  *                                                         2 indicate using effectivity date.
  * @param p_effectivity_date           A Code indicating the structure effectivity date.
  * @param p_from_end_item_unit_number  A Code indicating info for serial number or unit effectivity.
  * @param p_structure_content          A Code indicating if the structure contains changed components only
  *
  * @param p_change_order_creation      A Code indicating if create new change order or add to existing change order.
  *                                       candidate values: 'O' for None, 'N' for New and 'E' for adding to existing one.
  *                                       Current version API ONLY support O & E
  * @param p_add_all_to_change_flag     A flag indicating if add all imported items to change order.
  * @param p_change_mgmt_type_code      A Code indicating the Change Management Type Code. eg. 'CHANGE_ORDER'.
  * @param p_change_type_id             A Number indicating the change order type id.
  * @param p_change_notice              A Code indicating the change order notice.
  * @param p_change_name                  Default to null in this version Since new ECO not supported.
  * @param p_change_description           Default to null in this version Since new ECO not supported.
  * @param p_def_match_rule_cust_app_id A Number indicating the application id for default match rule applied.
  * @param p_def_match_rule_cust_code   A Number indicating the custom id for default match rule applied.
  * @param p_nir_option                 A Code indicating the NIR creation opting
  *                                       candidate values: 'N' for none, 'C' for one per ICC, 'I' for each item
  * @param p_enabled_for_data_pool      A Code indicating whether batch/source system is enabled for Data Pool or not
  *                                       If a batch is enabled for data pool, then only it can be used for inbound messages
  *
  * API USAGE:  CREATE_IMPORT_BATCH(
  *                      p_source_system_code         => 'PIMDH',
  *                      p_organization_id            => 204,
  *                      p_batch_type_display_name    => 'item',
  *                      p_assignee_name              => 'PLMMGR',
  *                      p_batch_name                 => 'Test Import Batch',
  *                      p_match_on_data_load         => 'Y',
  *                      p_apply_def_match_rule_all   => 'Y',
  *                      p_confirm_single_match       => 'Y',
  *                      p_import_on_data_load        => 'Y',
  *                      p_import_xref_only           => 'N',
  *                      p_revision_import_policy     => 'N',
  *                      p_structure_name             => 'MBOM',
  *                      p_structure_effectivity_type => 2,
  *                      p_effectivity_date           => TO_DATE('2009-03-04','yyyy-mm-dd'),
  *                      p_from_end_item_unit_number  => '',
  *                      p_structure_content          => '',
  *                      p_change_order_creation      => 'E',
  *                      p_add_all_to_change_flag     => 'y',
  *                      p_change_mgmt_type_code      => 'CHANGE_ORDER',
  *                      p_change_type_id             => 938 --'EBS CO',
  *                      p_change_notice              => 'ECO111',
  *                      p_def_match_rule_cust_app_id => 431,
  *                      p_def_match_rule_cust_code   => '1156416628834EGO_ITEM_MATCH_RU',
  *                      p_nir_option                 => 'N',
  *                      p_enabled_for_data_pool      => 'N',
  *                      x_batch_id                   => l_batch_id,
  *                      x_return_status              => l_return_status,
  *                      x_error_msg                  => l_error_msg);
  */
  Procedure CREATE_IMPORT_BATCH(p_source_system_code      IN VARCHAR2 DEFAULT 'PIMDH',
                                p_organization_id         IN NUMBER,
                                p_batch_type_display_name IN VARCHAR2 DEFAULT NULL,
                                p_assignee_name           IN VARCHAR2 DEFAULT NULL,
                                p_batch_name              IN VARCHAR2,
                                --Options
                                p_match_on_data_load       IN VARCHAR2 DEFAULT NULL,
                                p_apply_def_match_rule_all IN VARCHAR2 DEFAULT NULL,
                                p_confirm_single_match     IN VARCHAR2 DEFAULT NULL,
                                p_import_on_data_load      IN VARCHAR2 DEFAULT NULL,
                                p_import_xref_only         IN VARCHAR2 DEFAULT NULL,
                                p_revision_import_policy   IN VARCHAR2 DEFAULT NULL,
                                --p_structure_type_id
                                p_structure_name             IN VARCHAR2 DEFAULT NULL,
                                p_structure_effectivity_type IN NUMBER DEFAULT NULL,
                                p_effectivity_date           IN DATE DEFAULT SYSDATE,
                                p_from_end_item_unit_number  IN VARCHAR2 DEFAULT NULL,
                                p_structure_content          IN VARCHAR2 DEFAULT NULL,
                                --Change Order Options
                                p_change_order_creation  IN VARCHAR2 DEFAULT NULL,
                                p_add_all_to_change_flag IN VARCHAR2 DEFAULT NULL,
                                p_change_mgmt_type_code  IN VARCHAR2 DEFAULT NULL,
                                p_change_type_id         IN NUMBER DEFAULT NULL,
                                p_change_notice          IN VARCHAR2 DEFAULT NULL,
                                p_change_name            IN VARCHAR2 DEFAULT NULL,
                                p_change_description     IN VARCHAR2 DEFAULT NULL,
                                --p_object_version_number IN NUMBER,
                                p_def_match_rule_cust_app_id IN NUMBER DEFAULT 431,
                                p_def_match_rule_cust_code   IN VARCHAR2 DEFAULT NULL,
                                --p_def_match_rule_rn_app_id   IN NUMBER,
                                --p_def_match_rule_rn_code     IN VARCHAR2,
                                p_nir_option            IN VARCHAR2 DEFAULT NULL,
                                p_enabled_for_data_pool IN VARCHAR2 DEFAULT NULL,
                                x_batch_id              OUT NOCOPY NUMBER,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_error_msg             OUT NOCOPY VARCHAR2) IS

    Cursor Ego_Master_Org_Csr(v_organization_id IN NUMBER) IS
      SELECT MP.ORGANIZATION_ID, MP.MASTER_ORGANIZATION_ID
        FROM MTL_PARAMETERS MP
       WHERE MP.ORGANIZATION_ID = v_organization_id;

    Cursor Ego_Source_System_Csr(v_source_system_code IN VARCHAR2) IS
      SELECT SSM.ORIG_SYSTEM_ID
        FROM HZ_ORIG_SYSTEMS_VL SSM, EGO_SOURCE_SYSTEM_EXT SSM_EXT
       WHERE SSM_EXT.SOURCE_SYSTEM_ID = SSM.ORIG_SYSTEM_ID
         AND SSM.ORIG_SYSTEM = v_source_system_code;

    Cursor Ego_Ssm_Options_Csr(v_source_system_id IN NUMBER) IS
      select *
        from EGO_IMPORT_OPTION_SETS
       WHERE SOURCE_SYSTEM_ID = v_source_system_id
         AND BATCH_ID IS NULL;

    Cursor Ego_Ssm_Assignee_Csr(v_user_name in VARCHAR2) IS
      SELECT USER_ID FROM ego_user_v where UPPER(user_NAME) = v_user_name;

    Cursor Ego_Structure_Id_Name_Csr(v_structure_type_name in VARCHAR2) IS
      SELECT STRUCTURE_TYPE_ID
        FROM bom_structure_types_b
       WHERE STRUCTURE_TYPE_NAME = v_structure_type_name;

    Cursor Ego_Structure_Type_Csr(v_structure_type_id IN NUMBER, v_master_org_id IN NUMBER) IS
      SELECT DISPLAY_NAME
        FROM (SELECT DISTINCT bad.display_name              DISPLAY_NAME,
                              bad.alternate_designator_code ALTERNATE_DESIGNATOR_CODE,
                              bad.structure_type_id         STRUCTURE_TYPE_ID
                FROM BOM_ALTERNATE_DESIGNATORS_VL bad,
                     BOM_STRUCTURE_TYPES_VL       bsvl
               WHERE bad.alternate_designator_code IS NOT NULL
                 AND bad.structure_type_id IN
                     (SELECT bst.structure_type_id
                        FROM BOM_STRUCTURE_TYPES_B bst
                       START WITH bst.structure_type_id = v_structure_type_id
                      CONNECT BY PRIOR bst.parent_structure_type_id =
                                  bst.structure_type_id)
              UNION
              SELECT bom_globals.retrieve_message('BOM', 'BOM_PRIMARY') DISPLAY_NAME,
                     BOM_Globals.GET_PRIMARY_UI() ALTERNATE_DESIGNATOR_CODE,
                     structure_type_iD
                FROM BOM_STRUCTURE_TYPES_B b
               WHERE structure_type_name = 'All-Structure Types') QRSLT
       WHERE ((ALTERNATE_DESIGNATOR_CODE = BOM_Globals.GET_PRIMARY_UI() OR
             ALTERNATE_DESIGNATOR_CODE IN
             (SELECT DISTINCT ALTERNATE_DESIGNATOR_CODE
                  FROM BOM_ALTERNATE_DESIGNATORS_VL b, mtl_parameters p
                 WHERE p.master_organization_id = v_master_org_id
                   AND b.ORGANIZATION_ID = p.organization_id)) AND
             ((v_structure_type_id =
             (Select Structure_Type_id
                   FROM bom_structure_types_b
                  where structure_type_name = 'Packaging Hierarchy') AND
             ALTERNATE_DESIGNATOR_CODE IN
             (SELECT ALTERNATE_DESIGNATOR_CODE
                   FROM BOM_ALTERNATE_DESIGNATORS b1
                  WHERE b1.organization_id = v_master_org_id
                    and is_preferred = 'Y')) OR
             (v_structure_type_id IS NULL OR
             v_structure_type_id <>
             (Select Structure_Type_id
                   FROM bom_structure_types_b
                  where structure_type_name = 'Packaging Hierarchy'))));

    Cursor Change_Order_Category_Csr(v_change_mgmt_type_code IN VARCHAR2) IS
      select type_name,
             change_mgmt_type_code,
             change_order_type_id,
             decode(sign(nvl(disable_date, sysdate + 1) - sysdate),
                    1,
                    'N',
                    'Y') DISABLE_FLAG
        from eng_change_order_types_vl
       where base_change_mgmt_type_code = v_change_mgmt_type_code
         and type_classification = 'CATEGORY';

    Cursor Change_Order_Type_Csr(v_change_mgmt_type_code IN VARCHAR2, v_change_order_type_id IN NUMBER) IS
      SELECT change_order_type_id
        FROM (select description,
                     type_name change_order_type,
                     change_order_type_id,
                     change_mgmt_type_code,
                     assembly_type,
                     subject_id
                from eng_change_order_types_v
               where (disable_date is null or disable_date >= sysdate)
                 and nvl(START_DATE, sysdate) <= sysdate
                 and type_classification = 'HEADER'
                 and NOT (nvl(FND_PROFILE.value('ENG:ENG_ITEM_ECN_ACCESS'), 1) = 2 and
                      assembly_type = 2 and base_change_mgmt_type_code =
                      v_change_mgmt_type_code)
               order by change_order_type) QRSLT
       WHERE CHANGE_MGMT_TYPE_CODE = v_change_mgmt_type_code
         AND CHANGE_ORDER_TYPE_ID = v_change_order_type_id;

    Cursor Change_Order_Notice_Csr(v_change_mgmt_type_code IN VARCHAR2, v_change_notice IN VARCHAR2, v_master_org_id IN NUMBER) IS
      SELECT change_notice
        FROM (SELECT DISTINCT eec.change_notice, eec.CHANGE_MGMT_TYPE_CODE
                FROM eng_engineering_changes eec,
                     eng_lifecycle_statuses  els,
                     eng_change_statuses_vl  ecs
               WHERE els.entity_name(+) = 'ENG_CHANGE'
                 AND els.entity_id1(+) = eec.change_id
                 AND els.status_code(+) = eec.status_code
                 AND els.active_flag(+) = 'Y'
                 AND ecs.status_code = eec.status_code
                 AND (eec.status_type in (0, 1) OR
                      (eec.status_type = 10 AND ecs.status_type = 1))
                 AND (eec.status_code = 0 OR
                      (els.workflow_status is null OR
                      (els.workflow_status is not null AND
                      els.workflow_status <> 'IN_PROGRESS') OR
                      (els.workflow_status = 'IN_PROGRESS' AND
                      els.change_editable_flag = 'Y')))
                 AND (eec.status_code = 0 OR
                      (eec.approval_status_type is null OR
                      (eec.approval_status_type is not null AND
                      eec.approval_status_type <> 3) OR
                      (eec.approval_status_type = 3 AND
                      els.change_editable_flag = 'Y')))) QRSLT
       WHERE (CHANGE_NOTICE IN
             (SELECT CHANGE_NOTICE
                 FROM ENG_ENGINEERING_CHANGES EEC1, MTL_PARAMETERS mtp
                WHERE EEC1.ORGANIZATION_ID = mtp.ORGANIZATION_ID
                  and mtp.MASTER_ORGANIZATION_ID = v_master_org_id) AND
             (UPPER(CHANGE_MGMT_TYPE_CODE) =
             UPPER(v_change_mgmt_type_code)))
         AND change_notice = v_change_notice;

    Cursor Ego_Def_Match_Rule_Csr(v_def_match_rule_cust_app_id IN NUMBER, v_def_match_rule_cust_code IN VARCHAR2) IS
      select CUSTOMIZATION_CODE, REGION_CODE
        from EGO_CRITERIA_TEMPLATES_V
       WHERE REGION_CODE LIKE 'EGO_ITEM_MATCH_RULE_REGION'
         AND CLASSIFICATION1 = -1
         AND CUSTOMIZATION_APPLICATION_ID = v_def_match_rule_cust_app_id
         AND CUSTOMIZATION_CODE = v_def_match_rule_cust_code;

    l_master_org_rec Ego_Master_Org_Csr%ROWTYPE;

    l_batch_id           NUMBER := NULL; --p_batch_id;
    l_source_system_id   NUMBER := NULL;
    l_source_system_code HZ_ORIG_SYSTEMS_VL.ORIG_SYSTEM%TYPE := p_source_system_code;
    l_organization_id    NUMBER := p_organization_id;
    l_master_org_id      NUMBER := NULL;

    l_batch_type_display_name VARCHAR2(30) := p_batch_type_display_name;
    l_assignee_name           VARCHAR2(100) := p_assignee_name;
    l_assignee_id             NUMBER;

    l_batch_name   VARCHAR2(80) := p_batch_name;
    l_batch_status VARCHAR2(1) := 'A';

    l_option_set_id            NUMBER := NULL; --p_option_set_id;
    l_apply_def_match_rule_all VARCHAR2(1) := p_apply_def_match_rule_all;

    l_match_on_data_load     VARCHAR2(1) := p_match_on_data_load;
    l_confirm_single_match   VARCHAR2(1) := p_confirm_single_match;
    l_import_on_data_load    VARCHAR2(1) := p_import_on_data_load;
    l_revision_import_policy VARCHAR2(30) := p_revision_import_policy;

    l_import_xref_only VARCHAR2(1) := p_import_xref_only;

    l_structure_type_id          NUMBER := null; --p_structure_type_id;
    l_structure_name             VARCHAR2(10) := p_structure_name;
    l_structure_effectivity_type NUMBER := p_structure_effectivity_type;
    l_effectivity_date           DATE := p_effectivity_date;
    l_from_end_item_unit_number  VARCHAR2(30) := p_from_end_item_unit_number;
    l_structure_content          VARCHAR2(30) := p_structure_content;

    l_change_order_creation  VARCHAR2(30) := p_change_order_creation;
    l_add_all_to_change_flag VARCHAR2(1) := p_add_all_to_change_flag;
    l_change_mgmt_type_code  VARCHAR2(30) := p_change_mgmt_type_code;
    l_change_type_id         NUMBER := p_change_type_id;
    l_change_notice          VARCHAR2(10) := p_change_notice;
    l_change_name            VARCHAR2(240) := p_change_name;
    l_change_description     VARCHAR2(2000) := p_change_description;

    l_object_version_number NUMBER := 1; --p_object_version_number;

    l_def_match_rule_cust_app_id NUMBER := p_def_match_rule_cust_app_id;
    l_def_match_rule_cust_code   VARCHAR2(30) := p_def_match_rule_cust_code;
    l_def_match_rule_rn_app_id   NUMBER;
    l_def_match_rule_rn_code     VARCHAR2(30);

    l_nir_option            VARCHAR2(1) := p_nir_option;
    l_enabled_for_data_pool VARCHAR2(1) := p_enabled_for_data_pool;

    --l_tmp_import_batch_rec EGO_IMPORT_BATCHES_B%ROWTYPE;
    l_tmp_batch_type_name VARCHAR2(30);
    l_tmp_ssm_options_rec EGO_IMPORT_OPTION_SETS%ROWTYPE;
    l_def_match_rule_rec  Ego_Def_Match_Rule_Csr%ROWTYPE;

    l_tmp_change_order_type_id NUMBER;
    l_tmp_change_notice        VARCHAR2(10);

    l_api_name             VARCHAR2(50) := 'CREATE_IMPORT_BATCH';
    l_err_text             VARCHAR2(200) := '';
    l_import_batches_rowid VARCHAR2(50) := null;

    INVALID_ORGANIZATION_ID EXCEPTION;
    INVALID_SSM_ID EXCEPTION;
    INVALID_STRUCTURE_TYPE_ID EXCEPTION;
    INVALID_STRUCTURE_EFF_TYPE EXCEPTION;
    INVALID_DEF_MAT_RULE_CODE EXCEPTION;
    INVALID_CHG_ORDER_TYPE EXCEPTION;
    INVALID_CHG_ORDER_NOTICE EXCEPTION;
    INVALID_BATCH_TYPE_ID EXCEPTION;
    UNSUPPORTED_ECO_CREATION_TYPE EXCEPTION;

  BEGIN
    x_return_status := FND_API.g_ret_sts_success;
    --l_user_id := FND_GLOBAL.User_Id;

    -------------------------------------------------------
    --- Validate Batch Header                           ---
    -------------------------------------------------------
    --Debug_Msg('--Starting to validate Import Batch Header--');
    -- 1. Validate Source System info

    IF l_source_system_code IS NOT NULL THEN
      OPEN Ego_Source_System_Csr(v_source_system_code => l_source_system_code);
      FETCH Ego_Source_System_Csr
        INTO l_source_system_id;
      IF Ego_Source_System_Csr%NOTFOUND THEN
        RAISE INVALID_SSM_ID;
      END IF;
      CLOSE Ego_Source_System_Csr;

      OPEN Ego_Ssm_Options_Csr(v_source_system_id => l_source_system_id);
      FETCH Ego_Ssm_Options_Csr
        INTO l_tmp_ssm_options_rec;

      IF Ego_Ssm_Options_Csr%NOTFOUND THEN
        RAISE INVALID_SSM_ID;
      END IF;

    ELSE
      RAISE INVALID_SSM_ID;
    END IF;

    --Validate organization info
    IF NVL(l_organization_id, -1) = -1 THEN
      RAISE INVALID_ORGANIZATION_ID;
    END IF;
    OPEN Ego_Master_Org_Csr(v_organization_id => l_organization_id);
    FETCH Ego_Master_Org_Csr
      INTO l_master_org_rec;
    IF Ego_Master_Org_Csr%NOTFOUND THEN
      RAISE INVALID_ORGANIZATION_ID;
    ELSE
      l_master_org_id := l_master_org_rec.MASTER_ORGANIZATION_ID;
    END IF;
    CLOSE Ego_Master_Org_Csr;

    --Validate assignee user info
    IF l_assignee_name IS NOT NULL THEN
      OPEN Ego_Ssm_Assignee_Csr(v_user_name => l_assignee_name);
      FETCH Ego_Ssm_Assignee_Csr
        INTO l_assignee_id;
      IF Ego_Ssm_Assignee_Csr%NOTFOUND THEN
        l_assignee_name := 'PLMMGR';
        OPEN Ego_Ssm_Assignee_Csr(v_user_name => l_assignee_name);
        FETCH Ego_Ssm_Assignee_Csr
          INTO l_assignee_id;
      END IF;
      CLOSE Ego_Ssm_Assignee_Csr;
    ELSE
      l_assignee_id := fnd_global.user_id;
    END IF;

    -- 2. Generate Batch Option Set ID & Batch Id.
    SELECT MTL_SYSTEM_ITEMS_INTF_SETS_S.nextval INTO l_batch_id FROM dual;
    select EGO_IMPORT_OPTION_SETS_S.nextval INTO l_option_set_id FROM dual;

    -------------------------------------------------------
    --- Initializing Input Params                       ---
    -------------------------------------------------------
    select nvl(l_apply_def_match_rule_all,
               l_tmp_ssm_options_rec.APPLY_DEF_MATCH_RULE_ALL),
           nvl(l_match_on_data_load,
               l_tmp_ssm_options_rec.MATCH_ON_DATA_LOAD),
           nvl(l_confirm_single_match,
               l_tmp_ssm_options_rec.CONFIRM_SINGLE_MATCH),
           nvl(l_import_on_data_load,
               l_tmp_ssm_options_rec.IMPORT_ON_DATA_LOAD),
           nvl(l_revision_import_policy,
               l_tmp_ssm_options_rec.REVISION_IMPORT_POLICY),
           nvl(l_import_xref_only, l_tmp_ssm_options_rec.IMPORT_XREF_ONLY),
           nvl(l_structure_type_id, l_tmp_ssm_options_rec.STRUCTURE_TYPE_ID),
           nvl(l_structure_name, l_tmp_ssm_options_rec.STRUCTURE_NAME),
           nvl(l_structure_effectivity_type,
               l_tmp_ssm_options_rec.STRUCTURE_EFFECTIVITY_TYPE),
           nvl(l_effectivity_date, l_tmp_ssm_options_rec.EFFECTIVITY_DATE),
           nvl(l_from_end_item_unit_number,
               l_tmp_ssm_options_rec.FROM_END_ITEM_UNIT_NUMBER),
           nvl(l_structure_content, l_tmp_ssm_options_rec.STRUCTURE_CONTENT),
           nvl(l_change_order_creation,
               l_tmp_ssm_options_rec.CHANGE_ORDER_CREATION),
           nvl(l_add_all_to_change_flag,
               l_tmp_ssm_options_rec.ADD_ALL_TO_CHANGE_FLAG),
           nvl(l_change_mgmt_type_code,
               l_tmp_ssm_options_rec.CHANGE_MGMT_TYPE_CODE),
           nvl(l_change_type_id, l_tmp_ssm_options_rec.CHANGE_TYPE_ID),
           nvl(l_change_notice, l_tmp_ssm_options_rec.CHANGE_NOTICE),
           nvl(l_change_name, l_tmp_ssm_options_rec.CHANGE_NAME),
           nvl(l_change_description,
               l_tmp_ssm_options_rec.CHANGE_DESCRIPTION),
           nvl(l_object_version_number,
               l_tmp_ssm_options_rec.OBJECT_VERSION_NUMBER),
           nvl(l_def_match_rule_cust_app_id,
               l_tmp_ssm_options_rec.DEF_MATCH_RULE_CUST_APP_ID),
           nvl(l_def_match_rule_cust_code,
               l_tmp_ssm_options_rec.DEF_MATCH_RULE_CUST_CODE),
           nvl(l_def_match_rule_rn_app_id,
               l_tmp_ssm_options_rec.DEF_MATCH_RULE_RN_APP_ID),
           nvl(l_def_match_rule_rn_code,
               l_tmp_ssm_options_rec.DEF_MATCH_RULE_RN_CODE),
           nvl(l_nir_option, l_tmp_ssm_options_rec.NIR_OPTION),
           nvl(l_enabled_for_data_pool,
               l_tmp_ssm_options_rec.ENABLED_FOR_DATA_POOL)
      INTO l_apply_def_match_rule_all,
           l_match_on_data_load,
           l_confirm_single_match,
           l_import_on_data_load,
           l_revision_import_policy,
           l_import_xref_only,
           l_structure_type_id,
           l_structure_name,
           l_structure_effectivity_type,
           l_effectivity_date,
           l_from_end_item_unit_number,
           l_structure_content,
           l_change_order_creation,
           l_add_all_to_change_flag,
           l_change_mgmt_type_code,
           l_change_type_id,
           l_change_notice,
           l_change_name,
           l_change_description,
           l_object_version_number,
           l_def_match_rule_cust_app_id,
           l_def_match_rule_cust_code,
           l_def_match_rule_rn_app_id,
           l_def_match_rule_rn_code,
           l_nir_option,
           l_enabled_for_data_pool
      FROM DUAL;

    IF l_source_system_id = 7 THEN
      --should ignore l_apply_def_match_rule_all, l_match_on_data_load, l_confirm_single_match, set them to null.
      l_match_on_data_load         := l_tmp_ssm_options_rec.MATCH_ON_DATA_LOAD;
      l_confirm_single_match       := l_tmp_ssm_options_rec.CONFIRM_SINGLE_MATCH;
      l_def_match_rule_cust_app_id := l_tmp_ssm_options_rec.def_match_rule_cust_app_id;
      l_def_match_rule_cust_code   := l_tmp_ssm_options_rec.def_match_rule_cust_code;
      l_def_match_rule_rn_app_id   := l_tmp_ssm_options_rec.def_match_rule_rn_app_id;
      l_def_match_rule_rn_code     := l_tmp_ssm_options_rec.def_match_rule_rn_code;

      l_apply_def_match_rule_all := l_tmp_ssm_options_rec.APPLY_DEF_MATCH_RULE_ALL;
      l_import_xref_only         := l_tmp_ssm_options_rec.IMPORT_XREF_ONLY;
      l_revision_import_policy   := l_tmp_ssm_options_rec.revision_import_policy;
    End IF;
    CLOSE Ego_Ssm_Options_Csr;

    -- 3. Validate Batch Type
    IF NVL(l_batch_type_display_name, '') = '' THEN
      RAISE INVALID_BATCH_TYPE_ID;
    ELSE
      select obj_name
        into l_tmp_batch_type_name
        from fnd_objects_vl
       where obj_name in ('EGO_ITEM', 'BOM_STRUCTURE')
         AND upper(display_name) = upper(l_batch_type_display_name);

      IF l_tmp_batch_type_name <> 'BOM_STRUCTURE' THEN
        --Set all Structure related setting to nulls.
        l_structure_type_id          := null;
        l_structure_name             := null;
        l_structure_effectivity_type := null;
        l_effectivity_date           := null;
        l_from_end_item_unit_number  := null;
        l_structure_content          := null;
      ELSIF l_tmp_batch_type_name = 'BOM_STRUCTURE' THEN
        --Check the structure type id, validate the structure name
        --if not valid, set to default Root type.
        IF NVL(l_structure_name, '') = '' THEN
          RAISE INVALID_STRUCTURE_TYPE_ID;
        END IF;

        OPEN Ego_Structure_Id_Name_Csr(v_structure_type_name => l_structure_name);
        FETCH Ego_Structure_Id_Name_Csr
          INTO l_structure_type_id;
        IF Ego_Structure_Id_Name_Csr%NOTFOUND THEN
          RAISE INVALID_STRUCTURE_TYPE_ID;
        END IF;
        CLOSE Ego_Structure_Id_Name_Csr;

        OPEN Ego_Structure_Type_Csr(v_structure_type_id => l_structure_type_id,
                                    v_master_org_id     => l_master_org_id);
        FETCH Ego_Structure_Type_Csr
          INTO l_structure_name;
        IF Ego_Structure_Type_Csr%NOTFOUND THEN
          RAISE INVALID_STRUCTURE_TYPE_ID;
        ELSE
          IF NVL(l_structure_effectivity_type, 1) = 1 THEN
            --Date
            l_from_end_item_unit_number := NULL;
          ELSIF l_structure_effectivity_type = 2 THEN
            l_effectivity_date := NULL;
          ELSE
            RAISE INVALID_STRUCTURE_EFF_TYPE;
          END IF;
          CLOSE Ego_Structure_Type_Csr;
        END IF;

      END IF;

    END IF;

    -------------------------------------------------------
    -- Validate Data Load Options
    -------------------------------------------------------
    -- 1. Validate Match Rule
    IF l_source_system_id <> 7 THEN
      -- Even Match On Data Load is NO, you should still be able to save changes to the default match rule.
      IF l_match_on_data_load <> 'Y' THEN
        l_apply_def_match_rule_all   := NULL;
        l_match_on_data_load         := NULL;
        l_confirm_single_match       := NULL;
        l_def_match_rule_cust_app_id := NULL;
        l_def_match_rule_cust_code   := NULL;
        l_def_match_rule_rn_app_id   := NULL;
        l_def_match_rule_rn_code     := NULL;

      ELSIF l_match_on_data_load = 'Y' THEN
        IF l_def_match_rule_cust_code IS NULL OR
           l_def_match_rule_cust_code IS NULL THEN
          RAISE INVALID_DEF_MAT_RULE_CODE;
        END IF;
        -- validate the input match rule
        OPEN Ego_Def_Match_Rule_Csr(v_def_match_rule_cust_app_id => l_def_match_rule_cust_app_id,
                                    v_def_match_rule_cust_code   => l_def_match_rule_cust_code);
        FETCH Ego_Def_Match_Rule_Csr
          INTO l_def_match_rule_rec;

        IF Ego_Def_Match_Rule_Csr%NOTFOUND THEN
          RAISE INVALID_DEF_MAT_RULE_CODE;
        END IF;
        l_def_match_rule_rn_code := l_def_match_rule_rec.REGION_CODE;
        CLOSE Ego_Def_Match_Rule_Csr;

      END IF;
    END IF;

    -- 2. Data Load Import
    IF l_source_system_id = 7 THEN
      l_revision_import_policy := l_tmp_ssm_options_rec.REVISION_IMPORT_POLICY;
    END IF;

    -------------------------------------------------------
    -- Validate Import Options
    -------------------------------------------------------
    -- 1. if 'Data Import' is 'Create Cross References Only' then no CO and NIR required.
    IF l_import_xref_only = 'Y' THEN
      --NONE
      l_change_order_creation  := NULL;
      l_add_all_to_change_flag := NULL;
      l_change_mgmt_type_code  := NULL;
      l_change_type_id         := NULL;
      l_change_notice          := NULL;
      l_change_name            := NULL;
      l_change_description     := NULL;

    ELSE

      IF l_change_order_creation = 'O' THEN
        --NONE
        NULL;
      ELSE
        -- Validate Change Order Category & Change Order Type.
        OPEN Change_Order_Type_Csr(v_change_mgmt_type_code => l_change_mgmt_type_code,
                                   v_change_order_type_id  => l_change_type_id);
        FETCH Change_Order_Type_Csr
          INTO l_tmp_change_order_type_id;

        IF Change_Order_Type_Csr%NOTFOUND THEN
          -- invalid input change order category and change order type.
          RAISE INVALID_CHG_ORDER_TYPE;
        ELSE
          IF l_change_order_creation = 'N' THEN
            --NEW
            NULL; --Generate Change Order Number
            RAISE UNSUPPORTED_ECO_CREATION_TYPE;
            --NOT SUPPORTTED IN THIS VERSION
          ELSIF l_change_order_creation = 'E' THEN
            --EXISTING

            -- Validate Change Notice
            OPEN Change_Order_Notice_Csr(v_change_mgmt_type_code => l_change_mgmt_type_code,
                                         v_change_notice         => l_change_notice,
                                         v_master_org_id         => l_master_org_id);
            FETCH Change_Order_Notice_Csr
              into l_tmp_change_notice;

            IF Change_Order_Notice_Csr%NOTFOUND THEN
              RAISE INVALID_CHG_ORDER_NOTICE;
            END IF;
            CLOSE Change_Order_Notice_Csr;

          ELSE
            l_change_order_creation := 'O';
          END IF;
        END IF;
        CLOSE Change_Order_Type_Csr;
      END IF;

    END IF;

    INSERT_ROW(X_ROWID                 => l_import_batches_rowid,
               X_BATCH_ID              => l_batch_id,
               X_ORGANIZATION_ID       => l_master_org_id,
               X_SOURCE_SYSTEM_ID      => l_source_system_id,
               X_BATCH_TYPE            => l_tmp_batch_type_name,
               X_ASSIGNEE              => l_assignee_id,
               X_BATCH_STATUS          => l_batch_status,
               X_OBJECT_VERSION_NUMBER => l_object_version_number,
               X_NAME                  => l_batch_name,
               X_DESCRIPTION           => l_batch_name,
               X_CREATION_DATE         => sysdate,
               X_CREATED_BY            => fnd_global.user_id,
               X_LAST_UPDATE_DATE      => sysdate,
               X_LAST_UPDATED_BY       => fnd_global.user_id,
               X_LAST_UPDATE_LOGIN     => fnd_global.login_id);

    INSERT INTO EGO_IMPORT_OPTION_SETS
      (OPTION_SET_ID,
       SOURCE_SYSTEM_ID,
       BATCH_ID,
       MATCH_ON_DATA_LOAD,
       DEF_MATCH_RULE_CUST_APP_ID,
       DEF_MATCH_RULE_CUST_CODE,
       DEF_MATCH_RULE_RN_APP_ID,
       DEF_MATCH_RULE_RN_CODE,
       APPLY_DEF_MATCH_RULE_ALL,
       CONFIRM_SINGLE_MATCH,
       ENABLED_FOR_DATA_POOL,
       IMPORT_ON_DATA_LOAD,
       REVISION_IMPORT_POLICY,
       IMPORT_XREF_ONLY,
       STRUCTURE_TYPE_ID,
       STRUCTURE_NAME,
       STRUCTURE_EFFECTIVITY_TYPE,
       EFFECTIVITY_DATE,
       FROM_END_ITEM_UNIT_NUMBER,
       STRUCTURE_CONTENT,
       CHANGE_ORDER_CREATION,
       ADD_ALL_TO_CHANGE_FLAG,
       CHANGE_MGMT_TYPE_CODE,
       CHANGE_TYPE_ID,
       CHANGE_NOTICE,
       CHANGE_NAME,
       CHANGE_DESCRIPTION,
       NIR_OPTION,
       OBJECT_VERSION_NUMBER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN)
    VALUES
      (l_option_set_id,
       l_source_system_id,
       l_batch_id,
       l_match_on_data_load,
       l_def_match_rule_cust_app_id,
       l_def_match_rule_cust_code,
       l_def_match_rule_rn_app_id,
       l_def_match_rule_rn_code,
       l_apply_def_match_rule_all,
       l_confirm_single_match,
       l_enabled_for_data_pool,
       l_import_on_data_load,
       l_revision_import_policy,
       l_import_xref_only,
       l_structure_type_id,
       l_structure_name,
       l_structure_effectivity_type,
       l_effectivity_date,
       l_from_end_item_unit_number,
       l_structure_content,
       l_change_order_creation,
       l_add_all_to_change_flag,
       l_change_mgmt_type_code,
       l_change_type_id,
       l_change_notice,
       l_change_name,
       l_change_description,
       l_nir_option,
       l_object_version_number,
       fnd_global.user_id,
       sysdate,
       fnd_global.user_id,
       sysdate,
       fnd_global.login_id);

    -------------------------------------------------------
    -- Set OUT Argument values
    -------------------------------------------------------
    x_batch_id := l_batch_id;

  EXCEPTION
    WHEN INVALID_ORGANIZATION_ID THEN
      x_error_msg     := 'Invalid Organization ID';
      x_return_status := FND_API.g_ret_sts_error;

    WHEN INVALID_SSM_ID THEN
      x_error_msg     := 'Invalid Source System Code or ID';
      x_return_status := FND_API.g_ret_sts_error;

    WHEN INVALID_STRUCTURE_TYPE_ID THEN
      x_error_msg := 'Invalid Structure Type Name or ID';
      IF Ego_Structure_Type_Csr%ISOPEN THEN
        CLOSE Ego_Structure_Type_Csr;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;

    WHEN INVALID_STRUCTURE_EFF_TYPE THEN
      x_error_msg     := 'Invalid Structure Effectivity Type';
      x_return_status := FND_API.g_ret_sts_error;

    WHEN INVALID_DEF_MAT_RULE_CODE THEN
      x_error_msg := 'Invalid Default Match Rule Code';
      IF Ego_Def_Match_Rule_Csr%ISOPEN THEN
        CLOSE Ego_Def_Match_Rule_Csr;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;

    WHEN INVALID_CHG_ORDER_TYPE THEN
      x_error_msg := 'Invalid Change Order Type';
      IF Change_Order_Type_Csr%ISOPEN THEN
        CLOSE Change_Order_Type_Csr;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;

    WHEN INVALID_CHG_ORDER_NOTICE THEN
      x_error_msg := 'Invalid Change Order Notice';
      IF Change_Order_Notice_Csr%ISOPEN THEN
        CLOSE Change_Order_Notice_Csr;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;

    WHEN INVALID_BATCH_TYPE_ID THEN
      x_error_msg     := 'Invalid Import Batch Type';
      x_return_status := FND_API.g_ret_sts_error;

    WHEN UNSUPPORTED_ECO_CREATION_TYPE THEN
      x_error_msg     := 'Not support create new ECO';
      x_return_status := FND_API.g_ret_sts_error;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;
      l_err_text      := SUBSTRB(SQLERRM, 1, 240);
      x_error_msg     := l_err_text;

  END Create_Import_Batch;


  /* Use this API to change status of import batch.
  * @param p_batch_id
  * @param p_batch_name
  * @param p_batch_status  A Code indicating the import batch status.
  *                          'A' -- Active status
  *                          'C' -- Completed status
  *                          'R' -- Rejected status
  *                          'P' -- Pending status
  */
  PROCEDURE UPDATE_BATCH_STATUS(p_batch_id      NUMBER,
                                p_batch_name    VARCHAR2,
                                p_batch_status  VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_error_msg     OUT NOCOPY VARCHAR2) IS
    Cursor Ego_Import_Batch_Csr(v_batch_id NUMBER) IS
      SELECT B.BATCH_ID, TL.NAME
        FROM EGO_IMPORT_BATCHES_B B, EGO_IMPORT_BATCHES_TL TL
       WHERE B.BATCH_ID = TL.BATCH_ID
         AND B.BATCH_ID = v_batch_id
         AND TL.LANGUAGE = USERENV('LANG');

    Cursor Ego_Batch_Status_Csr(v_status_code VARCHAR2) IS
      SELECT LOOKUP_CODE, MEANING
        FROM FND_LOOKUPS
       WHERE LOOKUP_TYPE = 'EGO_IMPORT_BATCH_STATUS'
         AND LOOKUP_CODE = v_status_code;

    l_import_batch_rec Ego_Import_Batch_Csr%ROWTYPE;
    l_batch_status_rec Ego_Batch_Status_Csr%ROWTYPE;
    l_err_text         VARCHAR2(200);

    INVALID_BATCH_ID EXCEPTION;
    INVALID_BATCH_NAME EXCEPTION;
    INVALID_BATCH_STATUS EXCEPTION;

  BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    --Validate import batch id and name
    OPEN Ego_Import_Batch_Csr(v_batch_id => NVL(p_batch_id, 0));
    FETCH Ego_Import_Batch_Csr
      INTO l_import_batch_rec;
    IF Ego_Import_Batch_Csr%NOTFOUND THEN
      RAISE INVALID_BATCH_ID;
    ELSIF p_batch_name <> l_import_batch_rec.NAME THEN
      RAISE INVALID_BATCH_NAME;
    END IF;
    CLOSE Ego_Import_Batch_Csr;

    --Validate batch status
    IF p_batch_status IS NULL OR p_batch_status = '' THEN
      RAISE INVALID_BATCH_STATUS;
    END IF;
    OPEN Ego_Batch_Status_Csr(v_status_code => p_batch_status);
    FETCH Ego_Batch_Status_Csr
      INTO l_batch_status_rec;
    IF Ego_Batch_Status_Csr%NOTFOUND THEN
      RAISE INVALID_BATCH_STATUS;
    END IF;
    CLOSE Ego_Batch_Status_Csr;

    --Update table EGO_IMPORT_BATCHES_B
    UPDATE EGO_IMPORT_BATCHES_B
       SET BATCH_STATUS = p_batch_status
     WHERE BATCH_ID = p_batch_id;

  EXCEPTION
    WHEN INVALID_BATCH_ID THEN
      x_return_status := FND_API.g_ret_sts_error;
      x_error_msg     := 'Invalid Import Batch ID';
      IF Ego_Import_Batch_Csr%ISOPEN THEN
        CLOSE Ego_Import_Batch_Csr;
      END IF;

    WHEN INVALID_BATCH_NAME THEN
      x_return_status := FND_API.g_ret_sts_error;
      x_error_msg     := 'Invalid Import Batch Name';
      IF Ego_Batch_Status_Csr%ISOPEN THEN
        CLOSE Ego_Batch_Status_Csr;
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_error;
      l_err_text      := SUBSTRB(SQLERRM, 1, 240);
      x_error_msg     := l_err_text;

  END UPDATE_BATCH_STATUS;

END EGO_IMPORT_BATCHES_PKG;

/
