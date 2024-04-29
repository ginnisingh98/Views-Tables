--------------------------------------------------------
--  DDL for Package Body PON_ATTR_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_ATTR_MAPPING" AS
/* $Header: PONATMPB.pls 120.0.12010000.29 2013/09/16 04:28:34 puppulur noship $ */
  PROCEDURE Get_Supp_Related_Class_Codes (
          p_vendor_id                   IN NUMBER
        , p_party_id                    IN NUMBER
        , p_object_id                   IN NUMBER
        , p_data_level_name             IN VARCHAR2
        , p_attr_group_id               IN NUMBER
        , p_class_code_pairs            IN OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
        ) AS

        class_code                      VARCHAR2(3000)      := NULL;
        scheme_code                     VARCHAR2(5)         := NULL;
        return_code                     VARCHAR2(3000)      := NULL;
        end_position                    NUMBER              := 0;
        start_position                  NUMBER              := 1;
        segment_definition              VARCHAR2(3000)      := NULL;
        segment_count                   NUMBER              := 0;
        po_category_set_id              NUMBER              := 0;
        x_delimiter                     VARCHAR2(10)        := NULL;
        st_code                         VARCHAR2(40)        := NULL;

        CURSOR class_cursor(x_object_id NUMBER, x_data_level_name VARCHAR2, x_attr_group_id NUMBER)
        IS
          SELECT  classification_code
          FROM    EGO_OBJ_AG_ASSOCS_B
          WHERE   object_id = x_object_id
          AND     data_level = x_data_level_name
          AND     attr_group_id = x_attr_group_id;

        CURSOR bc_cursor(x_party_id NUMBER)
        IS
          SELECT  'BC:'||lookup_code AS Code
          FROM    pos_bus_class_attr
          WHERE   party_id = x_party_id
          AND     start_date_active <= SYSDATE
          AND     NVL(end_date_active, SYSDATE) >= SYSDATE
          AND     status = 'A';

        CURSOR ac_cursor(x_party_id NUMBER)
        IS
          SELECT  DISTINCT 'AC:'||hzl.country AS Code
          FROM    hz_locations hzl, hz_party_sites hzps
          WHERE   hzps.party_id      = x_party_id
          AND     hzl.location_id    = hzps.location_id;

        CURSOR ap_cursor(x_party_id NUMBER, x_vendor_id NUMBER)
        IS
          SELECT  'AP:' || site_use_type AS Code
          FROM    hz_party_sites hzps, hz_party_site_uses hzpsu
          WHERE   hzps.party_id = x_party_id
          AND     hzpsu.party_site_id = hzps.party_site_id
          AND     hzpsu.status = 'A'
          UNION
          SELECT  'AP:PURCHASING' as code
          FROM    ap_supplier_sites_all
          WHERE   vendor_id = x_vendor_id
          AND     purchasing_site_flag = 'Y'
          UNION
          SELECT  'AP:PAY'
          FROM    ap_supplier_sites_all
          WHERE   vendor_id = x_vendor_id
          AND     pay_site_flag = 'Y'
          UNION
          SELECT  'AP:PRIMARY_PAY'
          FROM    ap_supplier_sites_all
          WHERE   vendor_id = x_vendor_id
          AND     primary_pay_site_flag = 'Y'
          UNION
          SELECT  'AP:RFQ'
          FROM    ap_supplier_sites_all
          WHERE   vendor_id = x_vendor_id
          AND     rfq_only_site_flag = 'Y'
          UNION
          SELECT  'AP:PCARD'
          FROM    ap_supplier_sites_all
          WHERE   vendor_id = x_vendor_id
          AND     pcard_site_flag = 'Y';

        CURSOR ps_cursor(x_vendor_id NUMBER)
        IS
          SELECT  'PS:' || pos_product_service_utl_pkg.get_concat_code(classification_id) as code
          FROM    pos_sup_products_services
          WHERE   vendor_id = x_vendor_id;

        CURSOR hz_cursor(x_party_id NUMBER)
        IS
          SELECT  'HZ:'|| hccr.class_category || ':' || hccr.class_code AS code
          FROM    hz_class_code_relations hccr,
                  ( SELECT  class_category, class_code, owner_table_id
                    FROM    hz_code_assignments
                    WHERE   owner_table_name = 'HZ_PARTIES'
                    AND     owner_table_id = x_party_id
                    AND     start_date_active <= SYSDATE
                    AND     NVL(end_date_active,   SYSDATE) >= SYSDATE
                    AND     status = 'A' ) v
          WHERE   hccr.class_category = v.class_category
          START WITH  hccr.class_code = v.class_code
          CONNECT BY PRIOR  hccr.class_code = hccr.sub_class_code
          UNION
          SELECT  'HZ:'|| fnd.lookup_type || ':' || fnd.lookup_code
          FROM    fnd_lookup_values_vl fnd,
                  ( SELECT class_category, class_code, owner_table_id
                    FROM hz_code_assignments
                    WHERE owner_table_name = 'HZ_PARTIES'
                    AND owner_table_id = x_party_id
                    AND start_date_active <= SYSDATE
                    AND nvl(end_date_active,   SYSDATE) >= SYSDATE
                    AND status = 'A' ) v
          WHERE   fnd.lookup_type = v.class_category
          AND     fnd.lookup_code = v.class_code;

  BEGIN
    IF (p_class_code_pairs IS NOT NULL) THEN
      p_class_code_pairs := NULL;
    END IF;

    FOR class_rec IN class_cursor(p_object_id, p_data_level_name, p_attr_group_id) LOOP
      class_code := class_rec.classification_code;
      scheme_code := SUBSTR(class_code, 1, 2);
      CASE scheme_code
        WHEN 'BS' THEN
          IF (class_code = 'BS:BASE') THEN
            return_code := class_code;
          END IF;
        WHEN 'ST' THEN
          SELECT  'ST:'||vendor_type_lookup_code
          INTO    st_code
          FROM    AP_SUPPLIERS
          WHERE   party_id = p_party_id;
          IF (class_code = st_code) THEN
            return_code := class_code;
          END IF;
        WHEN 'BC' THEN
          FOR bc_rec IN bc_cursor(p_party_id) LOOP
            IF (class_code = bc_rec.code) THEN
              return_code := class_code;
              EXIT;
            END IF;
         END LOOP;
        WHEN 'AC' THEN
          FOR ac_rec IN ac_cursor(p_party_id) LOOP
            IF (class_code = ac_rec.code) THEN
              return_code := class_code;
              EXIT;
            END IF;
          END LOOP;
        WHEN 'AP' THEN
          FOR ap_rec IN ap_cursor(p_party_id, p_vendor_id) LOOP
            IF (class_code = ap_rec.code) THEN
              return_code := class_code;
              EXIT;
            END IF;
          END LOOP;
        WHEN 'PS' THEN
          pos_product_service_utl_pkg.get_product_meta_data(segment_definition, segment_count, po_category_set_id, x_delimiter);
          FOR ps_rec IN ps_cursor(p_vendor_id) LOOP
            IF (class_code = ps_rec.code) THEN
              return_code := class_code;
              EXIT;
            END IF;
            start_position := 1;
            end_position := 0;
            LOOP
              end_position := INSTR(ps_rec.code, x_delimiter, start_position);
              EXIT WHEN end_position = 0;
              IF (class_code = SUBSTR(ps_rec.code, 0, end_position-1)) THEN
                return_code := class_code;
                EXIT;
              END IF;
              start_position := end_position + 1;
            END LOOP;
          END LOOP;
        WHEN 'HZ' THEN
          FOR hz_rec IN hz_cursor(p_party_id) LOOP
            IF (class_code = hz_rec.code) THEN
              return_code := class_code;
              EXIT;
            END IF;
          END LOOP;
        ELSE           return_code := NULL;
      END CASE;
    END LOOP;

    IF (return_code IS NOT NULL) THEN
      p_class_code_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY();
      p_class_code_pairs.EXTEND();
      p_class_code_pairs(p_class_code_pairs.LAST)
        := EGO_COL_NAME_VALUE_PAIR_OBJ('CLASSIFICATION_CODE', return_code);
    END IF;

  END Get_Supp_Related_Class_Codes;

  PROCEDURE Get_Item_Related_Class_Codes (
          p_item_id                     IN NUMBER
        , p_class_code_pairs            IN OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
        ) AS
        l_related_class_codes_list      VARCHAR2(150)           := NULL;
        l_item_catalog_group_id         NUMBER                  := NULL;
  BEGIN
    SELECT  ITEM_CATALOG_GROUP_ID
    INTO    l_item_catalog_group_id
    FROM    MTL_SYSTEM_ITEMS_B
    WHERE   INVENTORY_ITEM_ID = p_item_id
    AND     ROWNUM = 1;

    IF (p_class_code_pairs IS NOT NULL) THEN
      p_class_code_pairs := NULL;
    END IF;

    IF (l_item_catalog_group_id IS NOT NULL) THEN
      EGO_ITEM_PVT.Get_Related_Class_Codes (
            l_item_catalog_group_id
          , NULL
          , NULL
          , NULL
          , l_related_class_codes_list
          );
      p_class_code_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(
                                  EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', TO_CHAR(l_item_catalog_group_id))
                                , EGO_COL_NAME_VALUE_PAIR_OBJ('RELATED_CLASS_CODE_LIST', l_related_class_codes_list)
                                );
    END IF;
  END Get_Item_Related_Class_Codes;

  PROCEDURE Process_User_Attrs_Data (
          p_auction_header_id       IN  NUMBER
        , p_bid_number              IN  NUMBER
        , x_return_status           OUT NOCOPY VARCHAR2
        , x_err_msg                 OUT NOCOPY VARCHAR2
        ) AS

        l_auction_title             VARCHAR2(80)    := NULL;
        l_document_number           pon_auction_headers_all.document_number%TYPE;

        l_extension_id              NUMBER          := NULL;
        l_mode                      VARCHAR2(2000)  := NULL;
        l_return_status             VARCHAR2(1)     := NULL;
        l_error_code                VARCHAR2(2000)  := NULL;
        l_msg_count                 NUMBER          := NULL;
        l_msg_data                  VARCHAR2(2000)  := NULL;
        l_entity_id                 VARCHAR2(1000)    := NULL;
        l_message_type              VARCHAR2(1000)    := NULL;

        l_intgr_hdr_flag            VARCHAR2(1)     := NULL;
        l_intgr_cat_line_flag       VARCHAR2(1)     := NULL;
        l_intgr_item_line_flag      VARCHAR2(1)     := NULL;
        l_hdr_enable_weights_flag   VARCHAR2(1)     := NULL;

        l_evaluator_name            VARCHAR2(360)   := NULL;
        l_supp_contact_name         VARCHAR2(360)   := NULL;
        l_publish_date              DATE            := NULL;
        l_party_id                  NUMBER          := NULL;
        l_vendor_id                 NUMBER          := NULL;
        l_vendor_name               VARCHAR2(240)   := NULL;
        l_vendor_site_id            NUMBER          := NULL;
        l_ship_to_org_id            NUMBER          := NULL;
        l_evaluation_flag           VARCHAR2(1)     := NULL;

        l_item_id                   NUMBER          := NULL;
        l_item_number               VARCHAR2(820)   := NULL;
        l_org_id                    NUMBER          := NULL;

        l_datatype                  VARCHAR2(3)     := NULL;
        l_value                     VARCHAR2(4000)  := NULL;
        l_score                     NUMBER          := NULL;

        l_counter                   NUMBER          := 0;
        l_attr_value_str            VARCHAR2(1000)  := NULL;
        l_attr_value_num            NUMBER          := NULL;
        l_attr_value_date           DATE            := NULL;
        l_attr_disp_value           VARCHAR2(1000)  := NULL;
        l_value_set_id              NUMBER          := NULL;

        l_object_id                 NUMBER          := NULL;
        l_object_name               VARCHAR2(430)   := NULL;
        l_application_id            NUMBER          := NULL;
        l_attr_group_type           VARCHAR2(40)    := NULL;
        l_attr_group_name           VARCHAR2(30)    := NULL;
        l_attr_group_disp_name      VARCHAR2(80)    := NULL;
        l_data_level_name           VARCHAR2(30)    := NULL;
        l_user_data_level_name      VARCHAR2(240)   := NULL;

        l_row_attrs_table           EGO_USER_ATTR_DATA_TABLE            := NULL;
        l_current_data_element      EGO_USER_ATTR_DATA_OBJ              := NULL;
        l_pk_column_pairs           EGO_COL_NAME_VALUE_PAIR_ARRAY       := NULL;
        l_class_code_pairs          EGO_COL_NAME_VALUE_PAIR_ARRAY       := NULL;
        l_data_level_pairs          EGO_COL_NAME_VALUE_PAIR_ARRAY       := NULL;

        CURSOR supp_ag_dl_cursor(p_header_id IN NUMBER)
        IS
          SELECT  DISTINCT
                  ATTR_GROUP_ID
                , DATA_LEVEL_ID
                , LINE_NUMBER
          FROM    PON_AUCTION_ATTR_MAPPING_B
          WHERE   AUCTION_HEADER_ID           = p_header_id
          AND     MAPPING_TYPE IN ('DOC_HEADER','DOC_REQ', 'CAT_LINE', 'DOC_SEC_SCORE'); --Bug13471195 Header Mapping Issue

        CURSOR supp_mapping_setup_cursor(p_header_id IN NUMBER
                                       , p_attr_group_id IN NUMBER
                                       , p_data_level_id IN NUMBER
                                       , p_line_number IN NUMBER)
        IS
          SELECT  SECTION_ID
                , SEQUENCE_NUMBER
                , MAPPING_TYPE
                , RESPONSE
                , ATTR_INT_NAME
          FROM    PON_AUCTION_ATTR_MAPPING_B
          WHERE   AUCTION_HEADER_ID           = p_header_id
          AND     ATTR_GROUP_ID               = p_attr_group_id
          AND     DATA_LEVEL_ID               = p_data_level_id
          AND     ( ( LINE_NUMBER = p_line_number AND mapping_type IN ('DOC_REQ', 'CAT_LINE', 'DOC_SEC_SCORE') )
                    OR ( LINE_NUMBER = -1 AND mapping_type = 'DOC_HEADER') );

        CURSOR item_ag_dl_cursor(p_header_id IN NUMBER)
        IS
          SELECT  DISTINCT
                  ATTR_GROUP_ID
                , DATA_LEVEL_ID
                , LINE_NUMBER
          FROM    PON_AUCTION_ATTR_MAPPING_B
          WHERE   AUCTION_HEADER_ID           = p_header_id
          AND     MAPPING_TYPE IN ('ITEM_LINE','ITEM_HEADER'); ----Bug13471195 Header Mapping Issue

        CURSOR item_mapping_setup_cursor(p_header_id IN NUMBER
                                       , p_attr_group_id IN NUMBER
                                       , p_data_level_id IN NUMBER
                                       , p_line_number IN NUMBER)
        IS
          SELECT  SEQUENCE_NUMBER
                , MAPPING_TYPE
                , RESPONSE
                , ATTR_INT_NAME
          FROM    PON_AUCTION_ATTR_MAPPING_B
          WHERE   AUCTION_HEADER_ID           = p_header_id
          AND     ATTR_GROUP_ID               = p_attr_group_id
          AND     DATA_LEVEL_ID               = p_data_level_id
          AND     ( ( LINE_NUMBER = p_line_number AND mapping_type = 'ITEM_LINE' )
                    OR ( LINE_NUMBER = -1 AND mapping_type = 'ITEM_HEADER') );

      INCORRECT_DATA                EXCEPTION;

  BEGIN
    SAVEPOINT Process_User_Attrs_Data_PUB;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_err_msg := NULL;

    -- Bug 16401315
    -- Added document_number to the query for mapping RFx Number
    SELECT  AUCTION_TITLE
          , DOCUMENT_NUMBER
          , INTGR_HDR_ATTR_FLAG
          , INTGR_CAT_LINE_ATTR_FLAG
          , INTGR_ITEM_LINE_ATTR_FLAG
          , HDR_ATTR_ENABLE_WEIGHTS
    INTO    l_auction_title
          , l_document_number
          , l_intgr_hdr_flag
          , l_intgr_cat_line_flag
          , l_intgr_item_line_flag
          , l_hdr_enable_weights_flag
    FROM    PON_AUCTION_HEADERS_ALL
    WHERE   AUCTION_HEADER_ID = p_auction_header_id;

    /* PARTY ID, SUPPLIER ID, SUPPLIER SITE ID IF ANY */
    SELECT  HZ1.PARTY_NAME
          , HZ2.PARTY_NAME
          , PON.PUBLISH_DATE
          , PON.TRADING_PARTNER_ID
          , PON.VENDOR_ID
          , PON.VENDOR_SITE_ID
          , AP.VENDOR_NAME
          , PON.EVALUATION_FLAG
    INTO    l_evaluator_name
          , l_supp_contact_name
          , l_publish_date
          , l_party_id
          , l_vendor_id
          , l_vendor_site_id
          , l_vendor_name
          , l_evaluation_flag
    FROM    PON_BID_HEADERS PON
          , HZ_PARTIES      HZ1
          , HZ_PARTIES      HZ2
          , AP_SUPPLIERS    AP
    WHERE   PON.AUCTION_HEADER_ID       = p_auction_header_id
    AND     PON.BID_NUMBER              = p_bid_number
    AND     HZ1.PARTY_ID (+)            = PON.EVALUATOR_ID
    AND     HZ2.PARTY_ID (+)            = PON.TRADING_PARTNER_CONTACT_ID
    AND     AP.VENDOR_ID                = PON.VENDOR_ID;

    IF (l_party_id IS NULL or l_vendor_id IS NULL) THEN
      RETURN;
    END IF;

    FOR supp_ag_dl_rec IN supp_ag_dl_cursor(p_auction_header_id) LOOP

      IF ( (supp_ag_dl_rec.line_number = -1 AND l_intgr_hdr_flag = 'Y') OR
           (supp_ag_dl_rec.line_number <> -1 AND l_intgr_cat_line_flag = 'Y') ) THEN

        l_extension_id := NULL;
        l_mode := NULL;
        l_return_status := NULL;
        l_error_code := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        l_entity_id := NULL;
        l_message_type := NULL;
        l_attr_group_name := NULL;
        l_attr_group_disp_name := NULL;
        l_data_level_name := NULL;
        l_user_data_level_name := NULL;

        IF (l_row_attrs_table IS NOT NULL) THEN
          l_row_attrs_table.DELETE;
        END IF;
        l_row_attrs_table := EGO_USER_ATTR_DATA_TABLE();

        l_counter := 0;

        SELECT  ATTR_GROUP_NAME
              , ATTR_GROUP_DISP_NAME
        INTO    l_attr_group_name
              , l_attr_group_disp_name
        FROM    EGO_ATTR_GROUPS_V
        WHERE   ATTR_GROUP_ID = supp_ag_dl_rec.attr_group_id;

        SELECT  DATA_LEVEL_NAME
              , USER_DATA_LEVEL_NAME
        INTO    l_data_level_name
              , l_user_data_level_name
        FROM    EGO_DATA_LEVEL_VL
        WHERE   DATA_LEVEL_ID = supp_ag_dl_rec.data_level_id;

        FOR supp_mapping_setup_rec IN supp_mapping_setup_cursor(p_auction_header_id
                                                              , supp_ag_dl_rec.attr_group_id
                                                              , supp_ag_dl_rec.data_level_id
                                                              , supp_ag_dl_rec.line_number) LOOP
        BEGIN
          /* get auction attribute value, type and score */
          l_value := NULL;
          l_datatype := NULL;
          l_score := NULL;
          IF (supp_mapping_setup_rec.mapping_type = 'DOC_HEADER') THEN
            IF (supp_mapping_setup_rec.sequence_number = 10) THEN
              l_value := l_auction_title;
              l_datatype := 'TXT';
            ELSIF (supp_mapping_setup_rec.sequence_number = 20) THEN
              l_value := l_document_number;
              l_datatype := 'RFN';
            ELSIF (supp_mapping_setup_rec.sequence_number = 30 AND l_evaluation_flag <> 'Y') THEN
              l_value := p_bid_number;
              l_datatype := 'NUM';
            ELSIF (supp_mapping_setup_rec.sequence_number = 40 AND l_evaluation_flag <> 'Y') THEN
              l_value := l_publish_date;
              l_datatype := 'DAT';
            ELSIF (supp_mapping_setup_rec.sequence_number = 50 AND l_evaluation_flag <> 'Y') THEN
              l_value := l_supp_contact_name;
              l_datatype := 'TXT';
            ELSIF (supp_mapping_setup_rec.sequence_number = 60 AND l_evaluation_flag = 'Y') THEN
              l_value := p_bid_number;
              l_datatype := 'NUM';
            ELSIF (supp_mapping_setup_rec.sequence_number = 70 AND l_evaluation_flag = 'Y') THEN
              l_value := l_publish_date;
              l_datatype := 'DAT';
            ELSIF (supp_mapping_setup_rec.sequence_number = 80 AND l_evaluation_flag = 'Y') THEN
              l_value := l_evaluator_name;
              l_datatype := 'TXT';
            END IF;
          ELSIF (supp_mapping_setup_rec.mapping_type = 'DOC_SEC_SCORE') THEN
            IF (supp_mapping_setup_rec.section_id = -10000) THEN
              SELECT  'NUM'
                    , NULL
                    , DECODE(l_hdr_enable_weights_flag, 'Y', SUM(WEIGHTED_SCORE), 'N', SUM(SCORE), NULL)
              INTO    l_datatype
                    , l_value
                    , l_score
              FROM    PON_BID_ATTRIBUTE_VALUES
              WHERE   AUCTION_HEADER_ID       = p_auction_header_id
              AND     BID_NUMBER              = p_bid_number
              AND     AUCTION_LINE_NUMBER     = supp_ag_dl_rec.line_number;
            ELSE
              SELECT  'NUM'
                    , NULL
                    , DECODE(l_hdr_enable_weights_flag, 'Y', SUM(WEIGHTED_SCORE), 'N', SUM(SCORE), NULL)
              INTO    l_datatype
                    , l_value
                    , l_score
              FROM    PON_BID_ATTRIBUTE_VALUES BID
                    , PON_AUCTION_ATTRIBUTES ATTR
                    , PON_AUCTION_SECTIONS SEC
              WHERE   BID.AUCTION_HEADER_ID   = p_auction_header_id
              AND     BID.BID_NUMBER          = p_bid_number
              AND     BID.AUCTION_LINE_NUMBER = supp_ag_dl_rec.line_number
              AND     BID.AUCTION_HEADER_ID   = ATTR.AUCTION_HEADER_ID
              AND     BID.AUCTION_HEADER_ID   = SEC.AUCTION_HEADER_ID
              AND     BID.LINE_NUMBER         = ATTR.LINE_NUMBER
              AND     BID.LINE_NUMBER         = SEC.LINE_NUMBER
              AND     ATTR.SECTION_NAME       = SEC.SECTION_NAME
              AND     SEC.SECTION_ID          = supp_mapping_setup_rec.section_id
              AND     BID.SEQUENCE_NUMBER = ATTR.SEQUENCE_NUMBER;
            END IF;
          ELSIF (supp_mapping_setup_rec.mapping_type = 'CAT_LINE' AND supp_mapping_setup_rec.sequence_number = -10000) THEN
            l_value := supp_ag_dl_rec.line_number;
            l_datatype := 'NUM';
          ELSE
            SELECT  DATATYPE
                  , VALUE
                  , DECODE(l_hdr_enable_weights_flag, 'Y', WEIGHTED_SCORE, 'N', SCORE, NULL)
            INTO    l_datatype
                  , l_value
                  , l_score
            FROM    PON_BID_ATTRIBUTE_VALUES
            WHERE   AUCTION_HEADER_ID       = p_auction_header_id
            AND     BID_NUMBER              = p_bid_number
            AND     AUCTION_LINE_NUMBER     = supp_ag_dl_rec.line_number
            AND     SEQUENCE_NUMBER         = supp_mapping_setup_rec.sequence_number;
	     IF (L_DATATYPE = 'DAT') THEN
                L_VALUE := TO_DATE(L_VALUE,'DD-MM-YYYY'); --Bug 14170832 Date format error
              END IF;
          END IF;

          IF (l_value IS NULL AND l_score IS NULL) THEN
            RAISE INCORRECT_DATA;
          END IF;

          l_attr_value_str := NULL;
          l_attr_value_num := NULL;
          l_attr_value_date := NULL;
          l_attr_disp_value := NULL;
          l_value_set_id := NULL;

          SELECT  VALUE_SET_ID
          INTO    l_value_set_id
          FROM    EGO_ATTRS_V
          WHERE   ATTR_GROUP_NAME   = l_attr_group_name
          AND     ATTR_NAME         = supp_mapping_setup_rec.attr_int_name;

          IF (supp_mapping_setup_rec.response IS NULL OR supp_mapping_setup_rec.response = 'V') THEN
            IF (l_value_set_id IS NOT NULL) THEN
              l_attr_disp_value := l_value;
            ELSIF (l_datatype = 'RFN') THEN  -- Bug 16401315
              l_attr_value_str := l_value;
              l_attr_value_num := p_auction_header_id;
            ELSIF (l_datatype = 'TXT' OR l_datatype = 'URL') THEN
              l_attr_value_str := l_value;
            ELSIF (l_datatype = 'NUM') THEN
              l_attr_value_num := l_value;
            ELSIF (l_datatype = 'DAT') THEN
              l_attr_value_date := l_value;
            ELSE
              RAISE INCORRECT_DATA;
            END IF;
          ELSIF (supp_mapping_setup_rec.response = 'S') THEN
            l_attr_value_num := l_score;
          ELSE
            RAISE INCORRECT_DATA;
          END IF;

          l_current_data_element := EGO_USER_ATTR_DATA_OBJ(l_counter
                                                         , supp_mapping_setup_rec.attr_int_name
                                                         , l_attr_value_str
                                                         , l_attr_value_num
                                                         , l_attr_value_date
                                                         , l_attr_disp_value
                                                         , NULL
                                                         , l_counter);
          l_row_attrs_table.EXTEND;
          l_row_attrs_table(l_row_attrs_table.LAST) := l_current_data_element;
          l_counter := l_counter + 1;

        EXCEPTION
          -- if mapping is defined for a requirement/attribute, but no response is provided, skip the mapping row
          WHEN OTHERS THEN
            NULL;
        END;

        END LOOP; -- supp_mapping_setup_cursor

        IF (l_row_attrs_table.COUNT > 0) THEN
          l_object_id := EGO_EXT_FWK_PUB.Get_Object_Id_From_Name('HZ_PARTIES');
          l_object_name := 'HZ_PARTIES';
          l_application_id := 177;
          l_attr_group_type := 'POS_SUPP_PROFMGMT_GROUP';
          l_pk_column_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PARTY_ID', l_party_id));
          Get_Supp_Related_Class_Codes(l_vendor_id, l_party_id, l_object_id, l_data_level_name, supp_ag_dl_rec.attr_group_id, l_class_code_pairs);

          -- Bug 12815017
          -- If l_class_code_pairs is null, it means that none of the
          -- supplier's classifications matches the attribute group's
          -- classifications, and hence no need to do the mapping.
          -- CONTINUE WHEN l_class_code_pairs IS NULL;

          -- Bug 16169826
          -- Modified code to use IF stement instead of CONTINUE
          IF (l_class_code_pairs IS NOT NULL) THEN

            l_data_level_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('IS_PROSPECT', 'N'));

            /* call ego api to sync data */
            ego_user_attrs_data_pvt.Process_Row(
                      p_api_version                   =>  1.0
                    , p_object_id                     =>  l_object_id
                    , p_object_name                   =>  l_object_name-- HZ_PARTIES/EGO_ITEM
                    , p_attr_group_id                 =>  supp_ag_dl_rec.attr_group_id-- input
                    , p_application_id                =>  l_application_id-- 177 for supplier, 431 for item
                    , p_attr_group_type               =>  l_attr_group_type-- POS_SUPP_PROFMGMT_GROUP/EGO_ITEMMGMT_GROUP
                    , p_attr_group_name               =>  l_attr_group_name-- input
                    , p_validate_hierarchy            =>  FND_API.G_FALSE
                    , p_pk_column_name_value_pairs    =>  l_pk_column_pairs-- input
                    , p_class_code_name_value_pairs   =>  l_class_code_pairs-- input
                    , p_data_level                    =>  l_data_level_name-- input
                    , p_data_level_name_value_pairs   =>  l_data_level_pairs-- input
                    , p_extension_id                  =>  NULL
                    , p_attr_name_value_pairs         =>  l_row_attrs_table-- input
                    , p_entity_id                     =>  NULL
                    , p_entity_index                  =>  NULL
                    , p_entity_code                   =>  NULL
                    , p_validate_only                 =>  FND_API.G_FALSE
                    , p_language_to_process           =>  NULL
                    , p_mode                          =>  ego_user_attrs_data_pvt.G_SYNC_MODE
                    , p_change_obj                    =>  NULL
                    , p_pending_b_table_name          =>  NULL
                    , p_pending_tl_table_name         =>  NULL
                    , p_pending_vl_name               =>  NULL
                    , p_init_fnd_msg_list             =>  FND_API.G_FALSE
                    , p_add_errors_to_fnd_stack       =>  FND_API.G_FALSE
                    , p_commit                        =>  FND_API.G_FALSE
                    , p_raise_business_event          =>  FALSE
                    , x_extension_id                  =>  l_extension_id
                    , x_mode                          =>  l_mode
                    , x_return_status                 =>  l_return_status
                    , x_errorcode                     =>  l_error_code
                    , x_msg_count                     =>  l_msg_count
                    , x_msg_data                      =>  l_msg_data
            );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := l_return_status;
              ERROR_HANDLER.Get_Message(l_msg_data, l_error_code, l_entity_id, l_message_type);
              x_err_msg := x_err_msg || G_DELIMITER
                            || 'Supplier: ' || l_vendor_name
                            || ', Attribute Group: ' || l_attr_group_disp_name
                            || ', Data Level: ' || l_user_data_level_name
                            || ', Error Message: ' || l_msg_data;
              IF (LENGTH(x_err_msg) > 30000) THEN
                EXIT;
              END IF;
            END IF;

          END IF; -- (l_class_code_pairs IS NOT NULL)

        END IF;

      END IF; -- (supp_ag_dl_rec.line_number = -1 AND l_intgr_hdr_flag = 'Y') OR
              -- (supp_ag_dl_rec.line_number <> -1 AND l_intgr_cat_line_flag = 'Y')

    END LOOP; -- supp_ag_dl_cursor

    IF (l_intgr_item_line_flag = 'Y') THEN

      FOR item_ag_dl_rec IN item_ag_dl_cursor(p_auction_header_id) LOOP
      BEGIN

        l_extension_id := NULL;
        l_mode := NULL;
        l_return_status := NULL;
        l_error_code := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        l_entity_id := NULL;
        l_message_type := NULL;
        l_attr_group_name := NULL;
        l_attr_group_disp_name := NULL;
        l_data_level_name := NULL;
        l_user_data_level_name := NULL;
        l_item_id := NULL;
        l_item_number := NULL;
        l_org_id := NULL;
        l_ship_to_org_id := NULL;

        IF (l_row_attrs_table IS NOT NULL) THEN
          l_row_attrs_table.DELETE;
        END IF;
        l_row_attrs_table := EGO_USER_ATTR_DATA_TABLE();

        l_counter := 0;

        SELECT  ATTR_GROUP_NAME
              , ATTR_GROUP_DISP_NAME
        INTO    l_attr_group_name
              , l_attr_group_disp_name
        FROM    EGO_ATTR_GROUPS_V
        WHERE   ATTR_GROUP_ID = item_ag_dl_rec.attr_group_id;

        SELECT  DATA_LEVEL_NAME
              , USER_DATA_LEVEL_NAME
        INTO    l_data_level_name
              , l_user_data_level_name
        FROM    EGO_DATA_LEVEL_VL
        WHERE   DATA_LEVEL_ID = item_ag_dl_rec.data_level_id;

        /* ORG_ID in PON_AUCTION_ITEM_PRICES_ALL is only the OU id, and the actual INVENTORY_ORGANIZATION_ID is in FINANCIALS_SYSTEM_PARAMS_ALL */
        SELECT  ITEM_ID
              , ITEM_NUMBER
              , F.INVENTORY_ORGANIZATION_ID
        INTO    l_item_id
              , l_item_number
              , l_org_id
        FROM    PON_AUCTION_ITEM_PRICES_ALL P
              , FINANCIALS_SYSTEM_PARAMS_ALL F
        WHERE   P.AUCTION_HEADER_ID       = p_auction_header_id
        AND     P.LINE_NUMBER             = item_ag_dl_rec.line_number
        AND     P.ORG_ID                  = F.ORG_ID;

        IF (l_vendor_id IS NULL OR l_item_id IS NULL OR l_org_id IS NULL) THEN
          RAISE INCORRECT_DATA;
        END IF;

        IF (item_ag_dl_rec.data_level_id = 43104) THEN
          IF (l_vendor_site_id IS NULL) THEN
            RAISE INCORRECT_DATA;
          END IF;
        END IF;

        IF (item_ag_dl_rec.data_level_id = 43105) THEN
          SELECT  SHIP_TO_LOCATION_ID
          INTO    l_ship_to_org_id
          FROM    PON_BID_ITEM_PRICES
          WHERE   AUCTION_HEADER_ID       = p_auction_header_id
          AND     BID_NUMBER              = p_bid_number
          AND     LINE_NUMBER             = item_ag_dl_rec.line_number;

          IF (l_ship_to_org_id IS NULL) THEN
            RAISE INCORRECT_DATA;
          END IF;
        END IF;

        IF (l_current_data_element IS NOT NULL) THEN
          l_current_data_element := NULL;
        END IF;

        FOR item_mapping_setup_rec IN item_mapping_setup_cursor(p_auction_header_id
                                                              , item_ag_dl_rec.attr_group_id
                                                              , item_ag_dl_rec.data_level_id
                                                              , item_ag_dl_rec.line_number) LOOP
        BEGIN
          /* get auction attribute value, type and score */
          l_value := NULL;
          l_datatype := NULL;
          l_score := NULL;
          IF (item_mapping_setup_rec.mapping_type = 'ITEM_HEADER') THEN
            IF (item_mapping_setup_rec.sequence_number = 10) THEN
              l_value := l_auction_title;
              l_datatype := 'TXT';
            ELSIF (item_mapping_setup_rec.sequence_number = 20) THEN
              l_value := l_document_number;
              l_datatype := 'RFN';
            ELSIF (item_mapping_setup_rec.sequence_number = 30 AND l_evaluation_flag <> 'Y') THEN
              l_value := p_bid_number;
              l_datatype := 'NUM';
            ELSIF (item_mapping_setup_rec.sequence_number = 40 AND l_evaluation_flag <> 'Y') THEN
              l_value := l_publish_date;
              l_datatype := 'DAT';
            ELSIF (item_mapping_setup_rec.sequence_number = 50 AND l_evaluation_flag <> 'Y') THEN
              l_value := l_supp_contact_name;
              l_datatype := 'TXT';
            ELSIF (item_mapping_setup_rec.sequence_number = 60 AND l_evaluation_flag = 'Y') THEN
              l_value := p_bid_number;
              l_datatype := 'NUM';
            ELSIF (item_mapping_setup_rec.sequence_number = 70 AND l_evaluation_flag = 'Y') THEN
              l_value := l_publish_date;
              l_datatype := 'DAT';
            ELSIF (item_mapping_setup_rec.sequence_number = 80 AND l_evaluation_flag = 'Y') THEN
              l_value := l_evaluator_name;
              l_datatype := 'TXT';
            END IF;
          ELSIF (item_mapping_setup_rec.mapping_type = 'ITEM_LINE' AND item_mapping_setup_rec.sequence_number = -10000) THEN
            l_value := item_ag_dl_rec.line_number;
            l_datatype := 'NUM';
          ELSE
            SELECT  DATATYPE
                  , VALUE
                  , DECODE(l_hdr_enable_weights_flag, 'Y', WEIGHTED_SCORE, 'N', SCORE, NULL)
            INTO    l_datatype
                  , l_value
                  , l_score
            FROM    PON_BID_ATTRIBUTE_VALUES
            WHERE   AUCTION_HEADER_ID       = p_auction_header_id
            AND     BID_NUMBER              = p_bid_number
            AND     AUCTION_LINE_NUMBER     = item_ag_dl_rec.line_number
            AND     SEQUENCE_NUMBER         = item_mapping_setup_rec.sequence_number;
	     IF (L_DATATYPE = 'DAT') THEN
                L_VALUE := TO_DATE(L_VALUE,'DD-MM-YYYY'); --Bug 14170832 Date format error
              END IF;
          END IF;

          IF (l_value IS NULL AND l_score IS NULL) THEN
            RAISE INCORRECT_DATA;
          END IF;

          l_attr_value_str := NULL;
          l_attr_value_num := NULL;
          l_attr_value_date := NULL;
          l_attr_disp_value := NULL;
          l_value_set_id := NULL;

          SELECT  VALUE_SET_ID
          INTO    l_value_set_id
          FROM    EGO_ATTRS_V
          WHERE   ATTR_GROUP_NAME   = l_attr_group_name
          AND     ATTR_NAME         = item_mapping_setup_rec.attr_int_name;

          IF (item_mapping_setup_rec.response IS NULL OR item_mapping_setup_rec.response = 'V') THEN
            IF (l_value_set_id IS NOT NULL) THEN
              l_attr_disp_value := l_value;
            ELSIF (l_datatype = 'RFN') THEN  -- Bug 16401315
              l_attr_value_str := l_value;
              l_attr_value_num := p_auction_header_id;
            ELSIF (l_datatype = 'TXT' OR l_datatype = 'URL') THEN
              l_attr_value_str := l_value;
            ELSIF (l_datatype = 'NUM') THEN
              l_attr_value_num := l_value;
            ELSIF (l_datatype = 'DAT') THEN
              l_attr_value_date := l_value;
            ELSE
              RAISE INCORRECT_DATA;
            END IF;
          ELSIF (item_mapping_setup_rec.response = 'S') THEN
            l_attr_value_num := l_score;
          ELSE
            RAISE INCORRECT_DATA;
          END IF;

          l_current_data_element := EGO_USER_ATTR_DATA_OBJ(l_counter
                                                         , item_mapping_setup_rec.attr_int_name
                                                         , l_attr_value_str
                                                         , l_attr_value_num
                                                         , l_attr_value_date
                                                         , l_attr_disp_value
                                                         , NULL
                                                         , l_counter);
          l_row_attrs_table.EXTEND;
          l_row_attrs_table(l_row_attrs_table.LAST) := l_current_data_element;
          l_counter := l_counter + 1;

        EXCEPTION
          -- if mapping is defined for a requirement/attribute, but no response is provided, skip the mapping row
          WHEN OTHERS THEN
            NULL;
        END;

        END LOOP; -- item_mapping_setup_cursor

        IF (l_row_attrs_table.COUNT > 0) THEN
          l_object_id := EGO_EXT_FWK_PUB.Get_Object_Id_From_Name('EGO_ITEM');
          l_object_name := 'EGO_ITEM';
          l_application_id := 431;
          l_attr_group_type := 'EGO_ITEMMGMT_GROUP';
          IF (item_ag_dl_rec.data_level_id = 43103) THEN
            l_pk_column_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', l_item_id)
                                                             , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', l_org_id));
            Get_Item_Related_Class_Codes(l_item_id, l_class_code_pairs);
            l_data_level_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PK1_VALUE', l_vendor_id));
          ELSIF (item_ag_dl_rec.data_level_id = 43104) THEN
            l_pk_column_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', l_item_id)
                                                             , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', l_org_id));
            Get_Item_Related_Class_Codes(l_item_id, l_class_code_pairs);
            l_data_level_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PK1_VALUE', l_vendor_id)
                                                              , EGO_COL_NAME_VALUE_PAIR_OBJ('PK2_VALUE', l_vendor_site_id));
          ELSIF (item_ag_dl_rec.data_level_id = 43105) THEN
            l_pk_column_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', l_item_id)
                                                             , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', l_ship_to_org_id));
            Get_Item_Related_Class_Codes(l_item_id, l_class_code_pairs);
            l_data_level_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('PK1_VALUE', l_vendor_id)
                                                              , EGO_COL_NAME_VALUE_PAIR_OBJ('PK2_VALUE', l_vendor_site_id));
          END IF;

          /* call ego api to sync data */
          ego_user_attrs_data_pvt.Process_Row(
                    p_api_version                   =>  1.0
                  , p_object_id                     =>  l_object_id
                  , p_object_name                   =>  l_object_name-- HZ_PARTIES/EGO_ITEM
                  , p_attr_group_id                 =>  item_ag_dl_rec.attr_group_id-- input
                  , p_application_id                =>  l_application_id-- 177 for supplier, 431 for item
                  , p_attr_group_type               =>  l_attr_group_type-- POS_SUPP_PROFMGMT_GROUP/EGO_ITEMMGMT_GROUP
                  , p_attr_group_name               =>  l_attr_group_name-- input
                  , p_validate_hierarchy            =>  FND_API.G_FALSE
                  , p_pk_column_name_value_pairs    =>  l_pk_column_pairs-- input
                  , p_class_code_name_value_pairs   =>  l_class_code_pairs-- input
                  , p_data_level                    =>  l_data_level_name-- input
                  , p_data_level_name_value_pairs   =>  l_data_level_pairs-- input
                  , p_extension_id                  =>  NULL
                  , p_attr_name_value_pairs         =>  l_row_attrs_table-- input
                  , p_entity_id                     =>  NULL
                  , p_entity_index                  =>  NULL
                  , p_entity_code                   =>  NULL
                  , p_validate_only                 =>  FND_API.G_FALSE
                  , p_language_to_process           =>  NULL
                  , p_mode                          =>  ego_user_attrs_data_pvt.G_SYNC_MODE
                  , p_change_obj                    =>  NULL
                  , p_pending_b_table_name          =>  NULL
                  , p_pending_tl_table_name         =>  NULL
                  , p_pending_vl_name               =>  NULL
                  , p_init_fnd_msg_list             =>  FND_API.G_FALSE
                  , p_add_errors_to_fnd_stack       =>  FND_API.G_FALSE
                  , p_commit                        =>  FND_API.G_FALSE
                  , p_raise_business_event          =>  FALSE
                  , x_extension_id                  =>  l_extension_id
                  , x_mode                          =>  l_mode
                  , x_return_status                 =>  l_return_status
                  , x_errorcode                     =>  l_error_code
                  , x_msg_count                     =>  l_msg_count
                  , x_msg_data                      =>  l_msg_data
          );
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            ERROR_HANDLER.Get_Message(l_msg_data, l_error_code, l_entity_id, l_message_type);
            x_err_msg := x_err_msg || G_DELIMITER
                          || 'Supplier: ' || l_vendor_name
                          || ', Item: ' || l_item_number
                          || ', Attribute Group: ' || l_attr_group_disp_name
                          || ', Data Level: ' || l_user_data_level_name
                          || ', Error Message: ' || l_msg_data;
            IF (LENGTH(x_err_msg) > 30000) THEN
              EXIT;
            END IF;
          END IF;
        END IF;

      EXCEPTION
        -- if data provided are not complete for the item line, skip the entire line
        WHEN OTHERS THEN
          NULL;
      END;

      END LOOP; -- item_ag_dl_cursor

    END IF; -- l_intgr_item_line_flag = 'Y'

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      ROLLBACK TO Process_User_Attrs_Data_PUB;
    END IF;

  END Process_User_Attrs_Data;

  PROCEDURE Sync_Approved_Supplier_List(p_auction_header_id   IN NUMBER)
  AS

        l_asl_row_id                VARCHAR2(18)    := NULL;
        l_asl_id                    NUMBER          := NULL;
        l_attr_row_id               VARCHAR2(18)    := NULL;
        l_intgr_cat_line_asl        VARCHAR2(1)     := NULL;


        -- Bug 12895392
        -- 1. Use Ship-To organization_id instead of location_id
        -- 2. If there is no Ship-To Location, mark category as Global in ASL

        CURSOR cate_line_cursor (p_header_id IN NUMBER)
        IS
          SELECT  item.bid_number
                , item.line_number
                , bid.vendor_id
                , bid.vendor_site_id
                , item.ship_to_location_id
                , item.category_id
                , item.approval_status
                , f.inventory_organization_id
                , NVL(hl.inventory_organization_id, -1) ship_to_org_id
          FROM    pon_bid_headers bid
                , pon_bid_item_prices item
                , pon_auction_item_prices_all price
                , financials_system_params_all f
                , hr_locations_all hl
          WHERE bid.bid_number = item.bid_number
          AND   item.line_number = price.line_number
          AND   bid.auction_header_id = price.auction_header_id
          AND   price.item_id IS NULL
          AND   bid.auction_header_id = p_header_id
          AND   item.approval_status = 'APPROVED'
          AND   f.org_id = price.org_id
          AND   hl.location_id(+) = item.ship_to_location_id;

  BEGIN
    SELECT  INTGR_CAT_LINE_ASL_FLAG
    INTO    l_intgr_cat_line_asl
    FROM    PON_AUCTION_HEADERS_ALL
    WHERE   AUCTION_HEADER_ID = p_auction_header_id;

    IF (l_intgr_cat_line_asl <> 'Y') THEN
      RETURN;
    END IF;

    FOR cate_lin_rec IN cate_line_cursor(p_auction_header_id) LOOP
      l_asl_row_id := NULL;
      l_asl_id := NULL;
      l_attr_row_id := NULL;

      -- Bug 12895392
      IF (cate_lin_rec.vendor_site_id = -1) THEN
        cate_lin_rec.vendor_site_id := NULL;
      END IF;

      BEGIN
        PO_ASL_THS.insert_row(
                l_asl_row_id,
                l_asl_id,
                cate_lin_rec.ship_to_org_id, -- ship to org
                cate_lin_rec.inventory_organization_id, --x_owning_organization_id
                'DIRECT', --x_vendor_business_type, -- direct, manufacture, or distributor, if distributor, need to provide manufacturer_id
                2, --x_asl_status_id, 1 for new, 2 for approved
                sysdate, --x_last_update_date,
                fnd_global.user_id, --x_last_updated_by,
                sysdate, --x_creation_date,
                fnd_global.user_id, --x_created_by,
                NULL, --x_manufacturer_id,
                cate_lin_rec.vendor_id, --x_vendor_id,
                NULL, --x_item_id,
                cate_lin_rec.category_id, --x_category_id,
                cate_lin_rec.vendor_site_id, --x_vendor_site_id,
                NULL, --x_primary_vendor_item,
                NULL, --x_manufacturer_asl_id,
                NULL, --x_comments,
                NULL, --x_review_by_date,
                NULL, --x_attribute_category,
                NULL, --x_attribute1,
                NULL, --x_attribute2,
                NULL, --x_attribute3,
                NULL, --x_attribute4,
                NULL, --x_attribute5,
                NULL, --x_attribute6,
                NULL, --x_attribute7,
                NULL, --x_attribute8,
                NULL, --x_attribute9,
                NULL, --x_attribute10,
                NULL, --x_attribute11,
                NULL, --x_attribute12,
                NULL, --x_attribute13,
                NULL, --x_attribute14,
                NULL, --x_attribute15,
                fnd_global.user_id, --x_last_update_login,
                NULL --x_disable_flag
                );

        IF (l_asl_id IS NOT NULL) THEN
          PO_ASL_ATTRIBUTES_THS.insert_row(
                  l_attr_row_id,
                  l_asl_id,
                  cate_lin_rec.ship_to_org_id, --x_using_organization_id   		    NUMBER,
                  sysdate, --x_last_update_date	            DATE,
                  fnd_global.user_id, --x_last_updated_by	    NUMBER,
                  sysdate, --x_creation_date		    DATE,
                  fnd_global.user_id, --x_created_by	    NUMBER,
                  'ASL', --x_document_sourcing_method	    VARCHAR2,
                  NULL, --x_release_generation_method	    VARCHAR2,
                  NULL, --x_purchasing_unit_of_measure	    VARCHAR2,
                  'N', --x_enable_plan_schedule_flag	    VARCHAR2,
                  'N', --x_enable_ship_schedule_flag	    VARCHAR2,
                  NULL, --x_plan_schedule_type	            VARCHAR2,
                  NULL, --x_ship_schedule_type		    VARCHAR2,
                  NULL, --x_plan_bucket_pattern_id            NUMBER,
                  NULL, --x_ship_bucket_pattern_id	    NUMBER,
                  'N', --x_enable_autoschedule_flag	    VARCHAR2,
                  NULL, --x_scheduler_id			    NUMBER,
                  'N', --x_enable_authorizations_flag	    VARCHAR2,
                  cate_lin_rec.vendor_id, --x_vendor_id	    NUMBER,
                  cate_lin_rec.vendor_site_id, --x_site_id    NUMBER,
                  NULL, --x_item_id			    NUMBER,
                  cate_lin_rec.category_id, --x_category_id   NUMBER,
                  NULL, --x_attribute_category	  	    VARCHAR2,
                  NULL, --x_attribute1		  	    VARCHAR2,
                  NULL, --x_attribute2		  	    VARCHAR2,
                  NULL, --x_attribute3		  	    VARCHAR2,
                  NULL, --x_attribute4		  	    VARCHAR2,
                  NULL, --x_attribute5		  	    VARCHAR2,
                  NULL, --x_attribute6		  	    VARCHAR2,
                  NULL, --x_attribute7		  	    VARCHAR2,
                  NULL, --x_attribute8		  	    VARCHAR2,
                  NULL, --x_attribute9		  	    VARCHAR2,
                  NULL, --x_attribute10		  	    VARCHAR2,
                  NULL, --x_attribute11		  	    VARCHAR2,
                  NULL, --x_attribute12		  	    VARCHAR2,
                  NULL, --x_attribute13		  	    VARCHAR2,
                  NULL, --x_attribute14		  	    VARCHAR2,
                  NULL, --x_attribute15		  	    VARCHAR2,
                  fnd_global.user_id, --x_last_update_login   NUMBER,
                  NULL, --x_price_update_tolerance            NUMBER,
                  NULL, --x_processing_lead_time              NUMBER,
                  NULL, --x_delivery_calendar                 VARCHAR2,
                  NULL, --x_min_order_qty                     NUMBER,
                  NULL, --x_fixed_lot_multiple                NUMBER,
                  NULL, --x_country_of_origin_code            VARCHAR2,
                  NULL, --x_enable_vmi_flag                   VARCHAR2,
                  NULL, --x_vmi_min_qty                       NUMBER,
                  NULL, --x_vmi_max_qty                       NUMBER,
                  NULL, --x_enable_vmi_auto_repl_flag         VARCHAR2,
                  NULL, --x_vmi_replenishment_approval        VARCHAR2,
                  NULL, --x_consigned_from_supplier_flag      VARCHAR2,
                  NULL, --x_consigned_billing_cycle           NUMBER ,
                  NULL, --x_last_billing_date                 DATE,
                  NULL, --x_replenishment_method              NUMBER,
                  NULL, --x_vmi_min_days                      NUMBER,
                  NULL, --x_vmi_max_days                      NUMBER,
                  NULL, --x_fixed_order_quantity              NUMBER,
                  NULL, --x_forecast_horizon                  NUMBER,
                  NULL, --x_consume_on_aging_flag             VARCHAR2,
                  NULL --x_aging_period                       NUMBER
                  );
        END IF;
      EXCEPTION
        -- When the ASL already exists, move on to the next supplier
        WHEN OTHERS THEN
          NULL;
      END;

    END LOOP; -- cate_line_cursor

  END Sync_Approved_Supplier_List;

  PROCEDURE Sync_User_Attrs_Data (
          p_auction_header_id       IN  NUMBER
        , p_vendor_id               IN  NUMBER
        , x_return_status           OUT NOCOPY VARCHAR2
        , x_err_msg                 OUT NOCOPY VARCHAR2
        ) AS

        l_vendor_id                 NUMBER := NULL;
        l_return_status             VARCHAR2(1)     := NULL;
        l_msg_data                  VARCHAR2(2000)  := NULL;

        -- Bug 16198923
        -- Added order by clause so that supplier response is always mapped
        -- after evaluation response. This way, when mapping RFx scores to
        -- single row UDA, it will always be the supplier response's scores.
        CURSOR bids_cursor(p_header_id IN NUMBER)
        IS
          SELECT  BID_NUMBER
          FROM    PON_BID_HEADERS
          WHERE   AUCTION_HEADER_ID = p_header_id
          AND     BID_STATUS = 'ACTIVE'
          AND     VENDOR_ID <> -1
          ORDER BY VENDOR_ID,
                   EVALUATION_FLAG DESC,
                   BID_NUMBER;

        CURSOR auctions_cursor(p_v_id IN NUMBER)
        IS
          SELECT  BID.AUCTION_HEADER_ID
                , BID.BID_NUMBER
          FROM    PON_BID_HEADERS BID
                , PON_AUCTION_HEADERS_ALL AUCTION
          WHERE   BID.VENDOR_ID = p_v_id
          AND     BID.AUCTION_HEADER_ID = AUCTION.AUCTION_HEADER_ID
          AND     AUCTION.AUCTION_STATUS = 'AUCTION_CLOSED'
          ORDER BY AUCTION_HEADER_ID,
                   EVALUATION_FLAG DESC,
                   BID_NUMBER;

  BEGIN
    SAVEPOINT Sync_User_Attrs_Data_PUB;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_err_msg := NULL;

    IF (p_auction_header_id IS NOT NULL AND p_vendor_id IS NULL) THEN
      FOR bids_rec IN bids_cursor(p_auction_header_id) LOOP
        l_return_status := NULL;
        l_msg_data := NULL;
        Process_User_Attrs_Data(p_auction_header_id, bids_rec.bid_number, l_return_status, l_msg_data);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          x_err_msg := x_err_msg || l_msg_data;
        END IF;
      END LOOP;
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        Sync_Approved_Supplier_List(p_auction_header_id);
      END IF;
    ELSIF (p_auction_header_id IS NULL AND p_vendor_id IS NOT NULL) THEN
      FOR auctions_rec IN auctions_cursor(p_vendor_id) LOOP
        l_return_status := NULL;
        l_msg_data := NULL;
        Process_User_Attrs_Data(auctions_rec.auction_header_id, auctions_rec.bid_number, l_return_status, l_msg_data);
      END LOOP;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          x_err_msg := x_err_msg || l_msg_data;
        END IF;
     END IF;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      ROLLBACK TO Sync_User_Attrs_Data_PUB;
    END IF;

  END Sync_User_Attrs_Data;

END PON_ATTR_MAPPING;

/
