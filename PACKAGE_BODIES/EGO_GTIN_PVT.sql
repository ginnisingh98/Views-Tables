--------------------------------------------------------
--  DDL for Package Body EGO_GTIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_GTIN_PVT" AS
/* $Header: EGOUCCPB.pls 120.19 2007/03/27 16:59:46 dsakalle ship $ */

  g_pkg_name                VARCHAR2(30) := 'EGO_UCCNET_PUBLICATION_PUB';
  g_app_name                VARCHAR2(3)  := 'EGO';
  g_current_user_id         NUMBER       := EGO_SCTX.Get_User_Id();
  g_current_login_id        NUMBER       := FND_GLOBAL.Login_Id;
  g_plsql_err               VARCHAR2(17) := 'EGO_PLSQL_ERR';
  g_pkg_name_token          VARCHAR2(8)  := 'PKG_NAME';
  g_api_name_token          VARCHAR2(8)  := 'API_NAME';
  g_sql_err_msg_token       VARCHAR2(11) := 'SQL_ERR_MSG';
  g_debug_flag              VARCHAR2(1)  := 'N';
  g_bo_identifier           VARCHAR2(20);
  g_log_file                VARCHAR2(240);
  g_log_file_dir            VARCHAR2(1000);
  Debug_File                UTL_FILE.FILE_TYPE;

/************************************************************************
* Procedure: WRITE_DEBUG_LOG
* Purpose  : This method will write debug information to the standard debug
**************************************************************************/
PROCEDURE WRITE_DEBUG_LOG(p_message IN  varchar2) IS
BEGIN
  EGO_COMMON_PVT.WRITE_DIAGNOSTIC(p_module => 'EGO_GTIN_PVT',
                                  p_message => p_message);
END WRITE_DEBUG_LOG;

-------------------------------------------
-- Private function to check if propagation required
-------------------------------------------
FUNCTION check_propagation_allowed (p_attr_id  IN  NUMBER)
RETURN BOOLEAN IS
  l_temp_char  VARCHAR2(1);
BEGIN
  SELECT 'X'
  INTO l_temp_char
  FROM EGO_FND_DF_COL_USGS_EXT attr_col
  WHERE attr_col.attr_id = p_attr_id
    AND attr_col.edit_in_hierarchy_code IN ('AP', 'LP');
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END check_propagation_allowed;

-------------------------------------------

FUNCTION Is_Pub_Status_Param_Expected
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp  VARCHAR2(1);
BEGIN
    SELECT 'X' INTO l_temp
    FROM DUAL
    WHERE EXISTS
        (
        SELECT 1
        FROM MTL_CUSTOMER_ITEMS MCI,
            MTL_CUSTOMER_ITEM_XREFS MCIX,
            MTL_CROSS_REFERENCES MCR,
            MTL_SYSTEM_ITEMS_B MSI,
            MTL_PARAMETERS MP
        WHERE MSI.INVENTORY_ITEM_ID = p_inventory_item_id
            AND MSI.ORGANIZATION_ID = p_org_id
            AND MSI.INVENTORY_ITEM_ID = MCIX.INVENTORY_ITEM_ID
            AND MSI.ORGANIZATION_ID = MCIX.MASTER_ORGANIZATION_ID
            AND MCIX.CUSTOMER_ITEM_ID = MCI.CUSTOMER_ITEM_ID
            AND MCI.ITEM_DEFINITION_LEVEL = 3
            AND MCI.CUSTOMER_CATEGORY_CODE = 'UCCNET'
            AND MCI.CUSTOMER_ID = p_customer_id
            AND MCI.ADDRESS_ID = p_address_id
            AND MCI.CUSTOMER_ITEM_NUMBER = MCR.CROSS_REFERENCE
            AND MCR.CROSS_REFERENCE_TYPE = 'GTIN'
            AND MCR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
            AND
            (
                MCR.ORGANIZATION_ID IS NULL
                OR MCR.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            )
            AND MCR.UOM_CODE = MSI.PRIMARY_UOM_CODE
            AND MSI.ORGANIZATION_ID = MP.ORGANIZATION_ID
            AND MP.ORGANIZATION_ID = MP.MASTER_ORGANIZATION_id
        );
    RETURN(TRUE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);
END Is_Pub_Status_Param_Expected;


FUNCTION Get_Publication_Status
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_address_id                 IN  NUMBER
)RETURN  VARCHAR2
IS
  l_gln                        VARCHAR2(80);
  l_customer_id                NUMBER ;
  l_party_site_id              NUMBER;
  l_publication_status       VARCHAR2(80);

BEGIN
  --derive gln and customer_id from address_id

  SELECT cust_account_id, party_site_id INTO l_customer_id, l_party_site_id
  FROM hz_cust_acct_sites_all
  WHERE cust_acct_site_id = p_address_id;

  SELECT global_location_number INTO l_gln
  FROM hz_party_sites
  WHERE party_site_id = l_party_site_id;

  l_publication_status := Get_Publication_Status( p_inventory_item_id,
                                                  p_org_id,
                                                  l_gln,
                                                  l_customer_id,
                                                  p_address_id );

  RETURN( l_publication_status);

END Get_Publication_Status;

-------------------------------------------

FUNCTION Get_Publication_Status
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
)RETURN  VARCHAR2
IS

  l_publication_status       VARCHAR2(80);
  l_publication_code         VARCHAR2(30);
  l_not_published            BOOLEAN;
  l_published                BOOLEAN;
  l_re_publish_needed        BOOLEAN;
  l_publication_in_prog      BOOLEAN;
  l_rejected                 BOOLEAN;
  l_withdrawn                BOOLEAN;
  l_delisted                 BOOLEAN;
BEGIN

  --hard code for testing
   l_publication_code := Get_Publication_Status_Code( p_inventory_item_id
                                                    , p_org_id
                                                    , p_gln
                                                    , p_customer_id
                                                    , p_address_id);

  IF( l_publication_code IS NULL ) THEN
    -- no publication code found
    l_publication_status := '';
  ELSE
    -- get publication status meaning
    SELECT meaning INTO l_publication_status
    FROM fnd_lookups
    WHERE lookup_type = 'EGO_UCCNET_PUB_STATUS'
    AND lookup_code = l_publication_code;

  END IF;

  RETURN( l_publication_status );
END Get_Publication_Status;



-------------------------------------------

FUNCTION Get_Publication_Status_Code
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_address_id                 IN  NUMBER
)RETURN  VARCHAR2
IS
  l_gln                        VARCHAR2(80);
  l_customer_id                NUMBER ;
  l_party_site_id              NUMBER;
  l_publication_status       VARCHAR2(80);

BEGIN
  --derive gln and customer_id from address_id

  SELECT cust_account_id, party_site_id INTO l_customer_id, l_party_site_id
  FROM hz_cust_acct_sites_all
  WHERE cust_acct_site_id = p_address_id;

  SELECT global_location_number INTO l_gln
  FROM hz_party_sites
  WHERE party_site_id = l_party_site_id;

  l_publication_status := Get_Publication_Status_Code( p_inventory_item_id,
                                                  p_org_id,
                                                  l_gln,
                                                  l_customer_id,
                                                  p_address_id );

  RETURN( l_publication_status);

END Get_Publication_Status_Code;

-------------------------------------------

FUNCTION Get_Publication_Status_Code
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
)RETURN  VARCHAR2
IS

  l_publication_code         VARCHAR2(30);
  l_not_published            BOOLEAN;
  l_published                BOOLEAN;
  l_re_publish_needed        BOOLEAN;
  l_publication_in_prog      BOOLEAN;
  l_rejected                 BOOLEAN;
  l_withdrawn                BOOLEAN;
  l_delisted                 BOOLEAN;
BEGIN

   IF Is_Pub_Status_Param_Expected( p_inventory_item_id
                                  , p_org_id
                                  , p_gln
                                  , p_customer_id
                                  , p_address_id) = FALSE
   THEN
      IF Is_Delisted(p_inventory_item_id, p_org_id) THEN
         RETURN 'DELISTED';
      ELSE
         RETURN NULL;
      END IF;
   END IF;
  --hard code for testing
  l_publication_code := NULL;

  l_not_published := Is_Not_Published( p_inventory_item_id
                                     , p_org_id
                                     , p_gln
                                     , p_customer_id
                                     , p_address_id );


  IF( l_not_published ) THEN
    l_publication_code := 'NOT_PUBLISHED';
  ELSE
    l_publication_in_prog := Is_Publication_In_Prog( p_inventory_item_id
                                                   , p_org_id
                                                   , p_gln
                                                   , p_customer_id
                                                   , p_address_id );


    IF(l_publication_in_prog) THEN
      l_publication_code := 'PUBLICATION_IN_PROGRESS';
    ELSE
      l_rejected := Is_Rejected( p_inventory_item_id
                                 , p_org_id
                                 , p_gln
                                 , p_customer_id
                                 , p_address_id );
      IF( l_rejected ) THEN
        l_publication_code := 'REJECTED';
      ELSE
        l_delisted := Is_Delisted( p_inventory_item_id
                                 , p_org_id  );
         IF( l_delisted ) THEN
           l_publication_code := 'DELISTED';
         ELSE
           l_withdrawn := Is_Withdrawn( p_inventory_item_id
                                 , p_org_id
                                 , p_gln
                                 , p_customer_id
                                 , p_address_id );
           IF( l_withdrawn) THEN
             l_publication_code := 'WITHDRAWN';
           ELSE
             l_published := Is_Published( p_inventory_item_id
                                        , p_org_id
                                        , p_gln
                                        , p_customer_id
                                        , p_address_id );

             IF(l_published) THEN
               l_publication_code := 'PUBLISHED';
             ELSE
               l_re_publish_needed := Is_Re_Publish_Needed( p_inventory_item_id
                                                          , p_org_id
                                                          , p_gln
                                                          , p_customer_id
                                                          , p_address_id );

                IF(l_re_publish_needed) THEN
                  l_publication_code := 'RE_PUBLISH_NEEDED';

                END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;


  RETURN( l_publication_code );
END Get_Publication_Status_Code;

-------------------------------------------

FUNCTION Is_Not_Published
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
) RETURN BOOLEAN
IS
  l_is_not_published BOOLEAN;
  l_temp  VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE
      NOT EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
          AND ORGANIZATION_ID = p_org_id
          AND ADDRESS_ID = p_address_id
          AND PARENT_GTIN = 0
          AND EVENT_TYPE = 'PUBLICATION'
          AND EVENT_ACTION IN ( 'INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION', 'NEW_ITEM' )
          AND
          (
              DISPOSITION_CODE <> 'FAILED'
              OR DISPOSITION_CODE IS NULL
          )
      )
      AND NOT EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
          AND ORGANIZATION_ID = p_org_id
          AND PARENT_GTIN = 0
          AND EVENT_TYPE = 'PUBLICATION'
          AND EVENT_ACTION = 'DE_LIST'
          AND DISPOSITION_CODE <> 'FAILED'
      ); -- DELISTED

  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);

END Is_Not_Published;

-------------------------------------------

FUNCTION Is_Publication_In_Prog
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
) RETURN BOOLEAN
IS
  l_is_publish_in_prog BOOLEAN;
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE
      EXISTS
      (
      SELECT
          'Y'
      FROM EGO_UCCNET_EVENTS
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
          AND ORGANIZATION_ID = p_org_id
          AND ADDRESS_ID = p_address_id
          AND PARENT_GTIN = 0
          AND EVENT_TYPE = 'PUBLICATION'
          AND DISPOSITION_CODE IS NULL
      )
      AND NOT EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
          AND ORGANIZATION_ID = p_org_id
          AND PARENT_GTIN = 0
          AND EVENT_TYPE = 'PUBLICATION'
          AND EVENT_ACTION = 'DE_LIST'
          AND DISPOSITION_CODE <> 'FAILED'
      ); -- DELISTED

  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);

END  Is_Publication_In_Prog;


-------------------------------------------

FUNCTION Is_Published
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
) RETURN BOOLEAN
IS
  l_is_published BOOLEAN;
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS UE
      WHERE UE.EVENT_ROW_ID =
          (
          SELECT
              MAX(EVENT_ROW_ID)
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND ADDRESS_ID = p_address_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND EVENT_ACTION IN ('NEW_ITEM', 'INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION')
              AND DISPOSITION_CODE <> 'FAILED'
          )
          AND NOT EXISTS
          (
          SELECT
              1
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND ADDRESS_ID = p_address_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND
              (
                  (
                      DISPOSITION_CODE = 'REJECTED'
                      AND EVENT_ACTION IN ('INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION','NEW_ITEM')
                  )-- REJECTED
                  OR DISPOSITION_CODE IS NULL -- IN-PROGRESS
                  OR
                  (
                      EVENT_ACTION = 'WITHDRAW'
                      AND DISPOSITION_CODE <> 'FAILED'
                      AND UE.EVENT_ROW_ID < EVENT_ROW_ID
                  ) -- Withdrawn
              )
          )
          AND NOT EXISTS
          (
          SELECT
              1
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND EVENT_ACTION = 'DE_LIST'
              AND DISPOSITION_CODE <> 'FAILED'
          ) -- DELISTED
          AND
          (
              UE.CREATION_DATE >=
              (
              SELECT
                  NVL(MAX(EICA.LAST_UPDATE_DATE) , TO_DATE('01-01-1998', 'MM-DD-YYYY'))
              FROM EGO_ITEM_CUST_ATTRS_B EICA,
                  EGO_UCCNET_EVENTS EV2,
                  HZ_CUST_ACCT_SITES_ALL HCAS
              WHERE EV2.BATCH_ID = UE.BATCH_ID
                  AND EV2.TOP_ITEM_ID = UE.INVENTORY_ITEM_ID
                  AND EV2.ORGANIZATION_ID = UE.ORGANIZATION_ID
                  AND EV2.ADDRESS_ID = UE.ADDRESS_ID
                  AND HCAS.CUST_ACCT_SITE_ID = UE.ADDRESS_ID
                  AND EICA.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                  AND EICA.INVENTORY_ITEM_ID = EV2.INVENTORY_ITEM_ID
                  AND EICA.MASTER_ORGANIZATION_ID = EV2.ORGANIZATION_ID
              )
              AND UE.CREATION_DATE >=
              (
              SELECT
                  NVL(MAX(TP_NEUTRAL_UPDATE_DATE), TO_DATE('01-01-1998', 'MM-DD-YYYY'))
              FROM EGO_ITEM_GTN_ATTRS_B EGA2,
                  EGO_UCCNET_EVENTS EV2
              WHERE EV2.BATCH_ID = UE.BATCH_ID
                  AND EV2.TOP_ITEM_ID = UE.INVENTORY_ITEM_ID
                  AND EV2.ORGANIZATION_ID = UE.ORGANIZATION_ID
                  AND EV2.ADDRESS_ID = UE.ADDRESS_ID
                  AND EGA2.INVENTORY_ITEM_ID = EV2.INVENTORY_ITEM_ID
                  AND EGA2.ORGANIZATION_ID = EV2.ORGANIZATION_ID
              )
              AND UE.CREATION_DATE >=
              (
              SELECT
                  (
                  CASE
                      WHEN(
                            Nvl( (Max(tl.LAST_UPDATE_DATE)), ( To_Date('01-01-1990','MM-DD-YYYY')) )
                                >=
                            Nvl( (Max(b.LAST_UPDATE_DATE)),  (To_Date('01-01-1990','MM-DD-YYYY')) )
                          )
                      THEN Nvl( (Max(tl.LAST_UPDATE_DATE)), (To_Date('01-01-1990','MM-DD-YYYY')) )
                      ELSE Nvl( (Max(b.LAST_UPDATE_DATE)),  (To_Date('01-01-1990','MM-DD-YYYY')) )
                  END
                  ) AS LAST_UPDATE_DATE
              FROM EGO_ITEM_TP_ATTRS_EXT_B b,
                   EGO_ITEM_TP_ATTRS_EXT_TL tl,
                   EGO_UCCNET_EVENTS EV2,
                   HZ_CUST_ACCT_SITES_ALL HCAS
              WHERE   EV2.BATCH_ID = UE.BATCH_ID
                  AND EV2.TOP_ITEM_ID = UE.INVENTORY_ITEM_ID
                  AND EV2.ORGANIZATION_ID = UE.ORGANIZATION_ID
                  AND EV2.ADDRESS_ID = UE.ADDRESS_ID
                  AND HCAS.CUST_ACCT_SITE_ID = UE.ADDRESS_ID
                  AND b.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                  AND tl.LANGUAGE = USERENV('LANG')
                  AND b.INVENTORY_ITEM_ID = EV2.INVENTORY_ITEM_ID
                  AND b.MASTER_ORGANIZATION_ID = EV2.ORGANIZATION_ID
                  AND b.EXTENSION_ID = tl.EXTENSION_ID
              )
          )
      );

  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);



END Is_Published;

-------------------------------------------


FUNCTION Is_Re_Publish_Needed
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
) RETURN BOOLEAN
IS
  l_is_re_publish_needed BOOLEAN;
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS UE
      WHERE UE.EVENT_ROW_ID =
          (
          SELECT
              MAX(EVENT_ROW_ID)
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND ADDRESS_ID = p_address_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND EVENT_ACTION IN ('NEW_ITEM', 'INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION')
              AND DISPOSITION_CODE <> 'FAILED'
          )
          AND NOT EXISTS
          (
          SELECT
              1
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND ADDRESS_ID = p_address_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND
              (
                  (
                      DISPOSITION_CODE = 'REJECTED'
                      AND EVENT_ACTION IN ('INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION','NEW_ITEM')
                  )-- REJECTED
                  OR DISPOSITION_CODE IS NULL -- IN-PROGRESS
                  OR
                  (
                      EVENT_ACTION = 'WITHDRAW'
                      AND DISPOSITION_CODE <> 'FAILED'
                      AND UE.EVENT_ROW_ID < EVENT_ROW_ID
                  ) -- Withdrawn
              )
          )
          AND NOT EXISTS
          (
          SELECT
              1
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND EVENT_ACTION = 'DE_LIST'
              AND DISPOSITION_CODE <> 'FAILED'
          ) -- DELISTED
          AND
          (
              UE.CREATION_DATE <
              (
              SELECT
                  NVL(MAX(EICA.LAST_UPDATE_DATE) , TO_DATE('01-01-1998', 'MM-DD-YYYY'))
              FROM EGO_ITEM_CUST_ATTRS_B EICA,
                  EGO_UCCNET_EVENTS EV2,
                  HZ_CUST_ACCT_SITES_ALL HCAS
              WHERE EV2.BATCH_ID = UE.BATCH_ID
                  AND EV2.TOP_ITEM_ID = UE.INVENTORY_ITEM_ID
                  AND EV2.ORGANIZATION_ID = UE.ORGANIZATION_ID
                  AND EV2.ADDRESS_ID = UE.ADDRESS_ID
                  AND HCAS.CUST_ACCT_SITE_ID = UE.ADDRESS_ID
                  AND EICA.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                  AND EICA.INVENTORY_ITEM_ID = EV2.INVENTORY_ITEM_ID
                  AND EICA.MASTER_ORGANIZATION_ID = EV2.ORGANIZATION_ID
              )
              OR UE.CREATION_DATE <
              (
              SELECT
                  NVL(MAX(TP_NEUTRAL_UPDATE_DATE), TO_DATE('01-01-1998', 'MM-DD-YYYY'))
              FROM EGO_ITEM_GTN_ATTRS_B EGA2,
                  EGO_UCCNET_EVENTS EV2
              WHERE EV2.BATCH_ID = UE.BATCH_ID
                  AND EV2.TOP_ITEM_ID = UE.INVENTORY_ITEM_ID
                  AND EV2.ORGANIZATION_ID = UE.ORGANIZATION_ID
                  AND EV2.ADDRESS_ID = UE.ADDRESS_ID
                  AND EGA2.INVENTORY_ITEM_ID = EV2.INVENTORY_ITEM_ID
                  AND EGA2.ORGANIZATION_ID = EV2.ORGANIZATION_ID
              )
              OR UE.CREATION_DATE <
              (
              SELECT
                  (
                  CASE
                      WHEN(
                            Nvl( (Max(tl.LAST_UPDATE_DATE)), ( To_Date('01-01-1990','MM-DD-YYYY')) )
                                >=
                            Nvl( (Max(b.LAST_UPDATE_DATE)),  (To_Date('01-01-1990','MM-DD-YYYY')) )
                          )
                      THEN Nvl( (Max(tl.LAST_UPDATE_DATE)), (To_Date('01-01-1990','MM-DD-YYYY')) )
                      ELSE Nvl( (Max(b.LAST_UPDATE_DATE)),  (To_Date('01-01-1990','MM-DD-YYYY')) )
                  END
                  ) AS LAST_UPDATE_DATE
              FROM EGO_ITEM_TP_ATTRS_EXT_B b,
                   EGO_ITEM_TP_ATTRS_EXT_TL tl,
                   EGO_UCCNET_EVENTS EV2,
                   HZ_CUST_ACCT_SITES_ALL HCAS
              WHERE   EV2.BATCH_ID = UE.BATCH_ID
                  AND EV2.TOP_ITEM_ID = UE.INVENTORY_ITEM_ID
                  AND EV2.ORGANIZATION_ID = UE.ORGANIZATION_ID
                  AND EV2.ADDRESS_ID = UE.ADDRESS_ID
                  AND HCAS.CUST_ACCT_SITE_ID = UE.ADDRESS_ID
                  AND b.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                  AND tl.LANGUAGE = USERENV('LANG')
                  AND b.INVENTORY_ITEM_ID = EV2.INVENTORY_ITEM_ID
                  AND b.MASTER_ORGANIZATION_ID = EV2.ORGANIZATION_ID
                  AND b.EXTENSION_ID = tl.EXTENSION_ID
              )
          )
      );

  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);



END  Is_Re_Publish_Needed;

--------------------------------


FUNCTION Is_Withdrawn
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS UE
      WHERE UE.EVENT_ROW_ID =
          (
          SELECT
              MAX(EVENT_ROW_ID)
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND ADDRESS_ID = p_address_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND EVENT_ACTION = 'WITHDRAW'
              AND DISPOSITION_CODE <> 'FAILED'
          )
          AND NOT EXISTS
          (
          SELECT
              1
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND ADDRESS_ID = p_address_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND
              (
                  (
                      DISPOSITION_CODE = 'REJECTED'
                      AND EVENT_ACTION IN ('INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION','NEW_ITEM')
                  )-- REJECTED
                  OR DISPOSITION_CODE IS NULL -- IN-PROGRESS
                  OR
                  (
                      EVENT_ACTION IN ('NEW_ITEM', 'INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION')
                      AND DISPOSITION_CODE <> 'FAILED'
                      AND UE.EVENT_ROW_ID < EVENT_ROW_ID
                  )
              )
          )
          AND NOT EXISTS
          (
          SELECT
              1
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND EVENT_ACTION = 'DE_LIST'
              AND DISPOSITION_CODE <> 'FAILED'
          ) -- DELISTED
      );

  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);



END  Is_Withdrawn;

--------------------------------

FUNCTION Is_Rejected
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
 , p_gln                        IN  VARCHAR2
 , p_customer_id                IN  NUMBER
 , p_address_id                 IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE EXISTS
      (
      SELECT
          1
      FROM DUAL
      WHERE EXISTS
          (
          SELECT
              1
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND ADDRESS_ID = p_address_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND EVENT_ACTION IN ('INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION','NEW_ITEM')
              AND DISPOSITION_CODE = 'REJECTED'
          )
          AND NOT EXISTS
          (
          SELECT
              1
          FROM EGO_UCCNET_EVENTS
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND PARENT_GTIN = 0
              AND EVENT_TYPE = 'PUBLICATION'
              AND EVENT_ACTION = 'DE_LIST'
              AND DISPOSITION_CODE <> 'FAILED'
          ) -- DELISTED
      );


  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);



END  Is_Rejected;

--------------------------------

FUNCTION Is_Delisted
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE EXISTS
      (
      SELECT
          1
      FROM DUAL
      WHERE EXISTS
          (
          SELECT
              1
          FROM ego_uccnet_events
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND ORGANIZATION_ID = p_org_id
              AND EVENT_TYPE = 'PUBLICATION'
              AND PARENT_GTIN = 0
              AND EVENT_ACTION = 'DE_LIST'
              AND DISPOSITION_CODE <> 'FAILED'
          )
      );

  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);



END  Is_Delisted;


-------------------------------------------

FUNCTION Is_Reg_Status_Param_Expected
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp  VARCHAR2(1);
BEGIN
    SELECT 'X' INTO l_temp
    FROM MTL_CROSS_REFERENCES MCR,
         MTL_SYSTEM_ITEMS_B MSI,
         MTL_PARAMETERS MP
    WHERE MCR.CROSS_REFERENCE_TYPE = 'GTIN'
        AND MCR.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
        AND NVL(MCR.ORGANIZATION_ID, MSI.ORGANIZATION_ID) = MSI.ORGANIZATION_ID
        AND MSI.ORGANIZATION_ID = MP.ORGANIZATION_ID
        AND MP.ORGANIZATION_ID = MP.MASTER_ORGANIZATION_ID
        AND MCR.UOM_CODE = MSI.PRIMARY_UOM_CODE
        AND MSI.INVENTORY_ITEM_ID = p_inventory_item_id
        AND MSI.ORGANIZATION_ID = p_org_id
        AND NVL(GDSN_OUTBOUND_ENABLED_FLAG, 'N') = 'Y';
    RETURN(TRUE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);
END Is_Reg_Status_Param_Expected;


FUNCTION Get_Registration_Status
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
)RETURN  VARCHAR2
IS

  l_registration_status       VARCHAR2(80);
  l_registration_code         VARCHAR2(30);
  l_not_registered            BOOLEAN;
  l_registered                BOOLEAN;
  l_re_register_needed        BOOLEAN;
  l_registration_in_prog      BOOLEAN;
BEGIN

  --hard code for testing
  l_registration_code := Get_Registration_Status_Code(p_inventory_item_id, p_org_id);

  -- this is needed due to a seeded lookup code not consistent with the
  -- registration status code
  IF l_registration_code = 'RE_REGISTER_NEEDED' THEN
     l_registration_code := 'REREG_NEEDED';
  END IF;

  IF( l_registration_code IS NULL ) THEN
    -- no registration code found
    l_registration_status := '';
  ELSE
    -- get publication status meaning
    select meaning into l_registration_status
    from fnd_lookups
    where lookup_type = 'EGO_UCCNET_STATUS'
    and lookup_code = l_registration_code;

  END IF;

  RETURN( l_registration_status );
END Get_Registration_Status;

-------------------------------------------

FUNCTION Get_Registration_Status_Code
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
)RETURN  VARCHAR2
IS

  l_registration_code         VARCHAR2(30);
  l_not_registered            BOOLEAN;
  l_registered                BOOLEAN;
  l_re_register_needed        BOOLEAN;
  l_registration_in_prog      BOOLEAN;
BEGIN

  IF Is_Reg_Status_Param_Expected(p_inventory_item_id, p_org_id) = FALSE THEN
     RETURN NULL;
  END IF;

   --hard code for testing
  l_registration_code := null;

  l_not_registered := Is_Not_Registered( p_inventory_item_id
                                     , p_org_id          );


  IF( l_not_registered ) THEN
    l_registration_code := 'NOT_REGISTERED';
  ELSE
    l_registration_in_prog := Is_Registration_In_Prog( p_inventory_item_id
                                                   , p_org_id  );


    IF(l_registration_in_prog) THEN
      l_registration_code := 'REGISTRATION_IN_PROGRESS';
    ELSE
      l_registered := Is_Registered( p_inventory_item_id
                                 , p_org_id );


      IF(l_registered) THEN
        l_registration_code := 'REGISTERED';
      ELSE
        l_re_register_needed := Is_Re_Register_Needed( p_inventory_item_id
                                                   , p_org_id );


        IF(l_re_register_needed) THEN
          l_registration_code := 'RE_REGISTER_NEEDED';

        END IF;
      END IF;
    END IF;
  END IF;


  RETURN( l_registration_code );
END Get_Registration_Status_Code;

-------------------------------------------


FUNCTION Is_Not_Registered
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp  VARCHAR2(1);
BEGIN

    SELECT
        'Y'
    INTO l_temp
    FROM DUAL
    WHERE NOT EXISTS
        (
        SELECT
            1
        FROM EGO_UCCNET_EVENTS
        WHERE INVENTORY_ITEM_ID = p_inventory_item_id
            AND ORGANIZATION_ID = p_org_id
            AND EVENT_TYPE = 'REGISTRATION'
            AND
            (
                DISPOSITION_CODE <> 'FAILED'
                OR DISPOSITION_CODE IS NULL
            )
        );

  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);

END Is_Not_Registered;

-------------------------------------------

FUNCTION Is_Registration_In_Prog
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
          AND ORGANIZATION_ID = p_org_id
          AND EVENT_TYPE = 'REGISTRATION'
          AND DISPOSITION_CODE IS NULL
      );

  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);

END  Is_Registration_In_Prog;


-------------------------------------------

FUNCTION Is_Registered
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS UE,
          EGO_ITEM_GTN_ATTRS_B GA
      WHERE UE.EVENT_ROW_ID =
          (
              SELECT
                  max(EVENT_ROW_ID)
              FROM EGO_UCCNET_EVENTS
              WHERE INVENTORY_ITEM_ID = p_inventory_item_id
                  AND ORGANIZATION_ID = p_org_id
                  AND EVENT_TYPE = 'REGISTRATION'
                  AND EVENT_ACTION IN ('ADD', 'CHANGE', 'CORRECT')
                  AND DISPOSITION_CODE <> 'FAILED'
          )
          AND NOT EXISTS
          (
              SELECT
                  1
              FROM EGO_UCCNET_EVENTS
              WHERE INVENTORY_ITEM_ID = p_inventory_item_id
                  AND ORGANIZATION_ID = p_org_id
                  AND EVENT_TYPE = 'REGISTRATION'
                  AND DISPOSITION_CODE IS NULL
          )
          AND UE.INVENTORY_ITEM_ID = GA.INVENTORY_ITEM_ID
          AND UE.ORGANIZATION_ID = GA.ORGANIZATION_ID
          AND (
                  GA.REGISTRATION_UPDATE_DATE <= UE.CREATION_DATE
                  OR GA.REGISTRATION_UPDATE_DATE IS NULL
              )
       );
  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);


END Is_Registered;

-------------------------------------------


FUNCTION Is_Re_Register_Needed
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
) RETURN BOOLEAN
IS
  l_temp VARCHAR2(1);
BEGIN

  SELECT
      'Y'
  INTO l_temp
  FROM DUAL
  WHERE EXISTS
      (
      SELECT
          1
      FROM EGO_UCCNET_EVENTS UE,
          EGO_ITEM_GTN_ATTRS_B GA
      WHERE UE.EVENT_ROW_ID =
          (
              SELECT
                  max(EVENT_ROW_ID)
              FROM EGO_UCCNET_EVENTS
              WHERE INVENTORY_ITEM_ID = p_inventory_item_id
                  AND ORGANIZATION_ID = p_org_id
                  AND EVENT_TYPE = 'REGISTRATION'
                  AND EVENT_ACTION IN ('ADD', 'CHANGE', 'CORRECT')
                  AND DISPOSITION_CODE <> 'FAILED'
          )
          AND NOT EXISTS
          (
              SELECT
                  1
              FROM EGO_UCCNET_EVENTS
              WHERE INVENTORY_ITEM_ID = p_inventory_item_id
                  AND ORGANIZATION_ID = p_org_id
                  AND EVENT_TYPE = 'REGISTRATION'
                  AND DISPOSITION_CODE IS NULL
          )
          AND UE.INVENTORY_ITEM_ID = GA.INVENTORY_ITEM_ID
          AND UE.ORGANIZATION_ID = GA.ORGANIZATION_ID
          AND GA.REGISTRATION_UPDATE_DATE > UE.CREATION_DATE
      );
  RETURN(TRUE);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN(FALSE);
  WHEN OTHERS THEN
       RETURN(FALSE);



END  Is_Re_Register_Needed;

--------------------------------

FUNCTION Is_Globally_Published
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
) RETURN VARCHAR2
IS
  l_temp VARCHAR2(1);
BEGIN

  SELECT 'Y' into l_temp
  FROM DUAL
  WHERE EXISTS(
    SELECT 1 FROM EGO_UCCNET_EVENTS
    WHERE inventory_item_id = p_inventory_item_id
    AND organization_id = p_org_id
    AND event_type = 'PUBLICATION'
    AND event_action IN ('NEW_ITEM', 'INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION')
    AND NOT (disposition_code = 'FAILED'));

  RETURN('Y');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN('N');
  WHEN OTHERS THEN
       RETURN('N');


END Is_Globally_Published;

  /* Bug 5523228 - API validates the Unit wt and wt uom against Trade Item Descriptor */
FUNCTION Validate_Unit_Wt_Uom
(  p_inventory_item_id          IN  NUMBER
 , p_org_id                     IN  NUMBER
) RETURN VARCHAR2
IS
   l_trade_unit_desc MTL_SYSTEM_ITEMS_B.TRADE_ITEM_DESCRIPTOR%TYPE;
   l_ret_code VARCHAR2(100);
BEGIN
   l_ret_code := FND_API.G_TRUE;

   SELECT TRADE_ITEM_DESCRIPTOR
     INTO l_trade_unit_desc
     FROM MTL_SYSTEM_ITEMS_B
    WHERE INVENTORY_ITEM_ID = p_inventory_item_id
      AND ORGANIZATION_ID = p_org_id;

    IF NVL(l_trade_unit_desc,'BASE_UNIT_OR_EACH') <> 'BASE_UNIT_OR_EACH' THEN
       l_ret_code := FND_API.G_FALSE;
    END IF;
    RETURN(l_ret_code);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN(FND_API.G_TRUE);
   WHEN OTHERS THEN
     RETURN (FND_API.G_FALSE);
END Validate_Unit_Wt_Uom;

--------------------------------
/**
* Written by Nisar to changed REGISTRATION_UPDATE_DATE when UDEX Catelog Category is updated.
*/
PROCEDURE PROCESS_CAT_ASSIGNMENT ( p_inventory_item_id NUMBER,
                                   p_organization_id   NUMBER) AS
BEGIN
  UPDATE EGO_ITEM_GTN_ATTRS_B
  SET REGISTRATION_UPDATE_DATE = SYSDATE
  WHERE INVENTORY_ITEM_ID = p_inventory_item_id
    AND ORGANIZATION_ID = p_organization_id;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END PROCESS_CAT_ASSIGNMENT;


/*
** Added by Devendra - for updation of REGISTRATION_UPDATE_DATE and TP_NEUTRAL_UPDATE_DATE
*/
PROCEDURE PROCESS_ATTRIBUTE_UPDATES (p_inventory_item_id NUMBER,
                                     p_organization_id   NUMBER,
                                     p_attribute_names   EGO_VARCHAR_TBL_TYPE,
                                     p_commit            VARCHAR2 := FND_API.G_FALSE,
                                     x_return_status     OUT NOCOPY VARCHAR2,
                                     x_msg_count         OUT NOCOPY NUMBER,
                                     x_msg_data          OUT NOCOPY VARCHAR2) AS

  l_reg_attr_updated       BOOLEAN :=  FALSE;
  l_pub_attr_updated       BOOLEAN := FALSE;
  l_tp_attr_updated        BOOLEAN := FALSE;
  l_non_tp_attr_updated    BOOLEAN := FALSE;
  l_update_last_upd_date   BOOLEAN := FALSE;

  Net_Content                   CONSTANT VARCHAR2(100) := 'Net_Content';
  Uom_Net_Content               CONSTANT VARCHAR2(100) := 'Uom_Net_Content';
  Trade_Item_Descriptor         CONSTANT VARCHAR2(100) := 'Trade_Item_Descriptor';
  Brand_Name                    CONSTANT VARCHAR2(100) := 'Brand_Name';
  Is_Trade_Item_A_Consumer_Unit CONSTANT VARCHAR2(100) := 'Is_Trade_Item_A_Consumer_Unit';
  Customer_Order_Enabled_Flag   CONSTANT VARCHAR2(100) := 'CUSTOMER_ORDER_ENABLED_FLAG';
  Unit_Weight                   CONSTANT VARCHAR2(100) := 'Unit_Weight';
  Unit_Height                   CONSTANT VARCHAR2(100) := 'Unit_Height';
  Unit_Length                   CONSTANT VARCHAR2(100) := 'Unit_Length';
  Unit_Width                    CONSTANT VARCHAR2(100) := 'Unit_Width';
  Unit_Volume                   CONSTANT VARCHAR2(100) := 'Unit_Volume';
  Dimension_Uom_Code            CONSTANT VARCHAR2(100) := 'DIMENSION_UOM_CODE';
  Size_Code_Value               CONSTANT VARCHAR2(100) := 'Size_Code_Value';
  Size_Code_List_Agency         CONSTANT VARCHAR2(100) := 'Size_Code_List_Agency';
  Effective_Date                CONSTANT VARCHAR2(100) := 'Effective_Date';
  Eanucc_Code                   CONSTANT VARCHAR2(100) := 'Eanucc_Code';
  EANUCC_Type                   CONSTANT VARCHAR2(100) := 'EANUCC_Type';
  Retail_Brand_Owner_Gln        CONSTANT VARCHAR2(100) := 'Retail_Brand_Owner_Gln';
  Retail_Brand_Owner_Name       CONSTANT VARCHAR2(100) := 'Retail_Brand_Owner_Name';
  Description                   CONSTANT VARCHAR2(100) := 'Description';
  Is_Trade_Item_Info_Private    CONSTANT VARCHAR2(100) := 'Is_Trade_Item_Info_Private';
  Description_Short             CONSTANT VARCHAR2(100) := 'Description_Short'; -- Bug: 3863176
  Weight_Uom_Code               CONSTANT VARCHAR2(100) := 'WEIGHT_UOM_CODE'; -- Bug: 3874653
  Delivery_Method_Indicator     CONSTANT VARCHAR2(100) := 'Delivery_Method_Indicator'; -- Bug: 3990094
  -- Bug: 3921782
  -- Few registration attributes were missing, while checking for registration attributes changed or not
  -- added Weight_Uom_Code, Gross_Weight, Uom_Gross_Weight, Volume_Uom_Code in the list of registration attrs
  Gross_Weight                  CONSTANT VARCHAR2(100) := 'Gross_Weight';
  Uom_Gross_Weight              CONSTANT VARCHAR2(100) := 'Uom_Gross_Weight';
  Volume_Uom_Code               CONSTANT VARCHAR2(100) := 'VOLUME_UOM_CODE';

  Canceled_Date                 CONSTANT VARCHAR2(100) := 'Canceled_Date';
  Discontinued_Date             CONSTANT VARCHAR2(100) := 'Discontinued_Date';

  l_action_map                  Bom_Rollup_Pub.Rollup_Action_Map := Bom_Rollup_Pub.G_EMPTY_ACTION_MAP;
  l_structure_type_name         VARCHAR2(200);
  x_error_message               VARCHAR2(2000);
  l_rollup_reqd                 BOOLEAN := FALSE;
  l_gtin                        MTL_CROSS_REFERENCES.CROSS_REFERENCE%TYPE;

  l_start_availability_date_time	EGO_ITEM_CUST_ATTRS_B.START_AVAILABILITY_DATE_TIME%TYPE;
  l_end_availability_date_time		EGO_ITEM_CUST_ATTRS_B.END_AVAILABILITY_DATE_TIME%TYPE;
  l_is_trade_item_a_despatch_unt	EGO_ITEM_CUST_ATTRS_B.IS_TRADE_ITEM_A_DESPATCH_UNIT%TYPE;
  l_is_trade_item_an_invoice_unt	EGO_ITEM_CUST_ATTRS_B.IS_TRADE_ITEM_AN_INVOICE_UNIT%TYPE;
  l_min_trade_item_life_arr		    EGO_ITEM_CUST_ATTRS_B.MIN_TRADE_ITEM_LIFE_ARR%TYPE;
  l_order_quantity_min			      EGO_ITEM_CUST_ATTRS_B.ORDER_QUANTITY_MIN%TYPE;
  l_order_quantity_max			      EGO_ITEM_CUST_ATTRS_B.ORDER_QUANTITY_MAX%TYPE;

  l_reg_attr_list EGO_VARCHAR_TBL_TYPE := EGO_VARCHAR_TBL_TYPE(Net_Content, Uom_Net_Content, Trade_Item_Descriptor, Brand_Name,
                                                               Is_Trade_Item_A_Consumer_Unit, Customer_Order_Enabled_Flag,
                                                               Unit_Weight, Unit_Height, Unit_Length, Unit_Width, Unit_Volume,
                                                               Dimension_Uom_Code, Size_Code_Value, Size_Code_List_Agency,
                                                               Effective_Date, Eanucc_Code, EANUCC_Type, Retail_Brand_Owner_Gln,
                                                               Retail_Brand_Owner_Name, Description, Is_Trade_Item_Info_Private,
                                                               Description_Short, Weight_Uom_Code, Gross_Weight, Uom_Gross_Weight,
                                                               Volume_Uom_Code, Delivery_Method_Indicator, Canceled_Date, Discontinued_Date
                                                               );

  l_core_tp_attr_list EGO_VARCHAR_TBL_TYPE := EGO_VARCHAR_TBL_TYPE
                                                ('Shelf_Life_Days', 'Start_Availability_Date_Time', 'End_Availability_Date_Time',
                                                 'Order_Quantity_Min', 'Order_Quantity_Max', 'Shippable_Item_Flag',
                                                 'Invoiceable_Item_Flag');
  CURSOR c_customers(c_gtin IN VARCHAR2) IS
    SELECT ACCT_SITE.PARTY_SITE_ID AS PARTY_SITE_ID
    FROM MTL_CUSTOMER_ITEMS MCI, MTL_CUSTOMER_ITEM_XREFS MCIX, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
    WHERE MCI.ITEM_DEFINITION_LEVEL = 3
      AND MCI.CUSTOMER_CATEGORY_CODE= 'UCCNET'
      AND MCI.CUSTOMER_ITEM_ID  = MCIX.CUSTOMER_ITEM_ID
      AND MCIX.PREFERENCE_NUMBER = 1
      AND MCI.CUSTOMER_ITEM_NUMBER = c_gtin
      AND MCIX.INVENTORY_ITEM_ID = p_inventory_item_id
      AND MCIX.MASTER_ORGANIZATION_ID = p_organization_id
      AND MCI.CUSTOMER_ID = ACCT_SITE.CUST_ACCOUNT_ID
      AND MCI.ADDRESS_ID = ACCT_SITE.CUST_ACCT_SITE_ID;

BEGIN
  write_debug_log('Entering EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES ... Date and Time - '||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));
  write_debug_log('Item ID , Org ID = '||p_inventory_item_id||','||p_organization_id);
  FOR i IN p_attribute_names.FIRST..p_attribute_names.LAST LOOP
    FOR j IN l_reg_attr_list.FIRST..l_reg_attr_list.LAST LOOP
      IF UPPER(p_attribute_names(i)) = UPPER(l_reg_attr_list(j)) THEN
        l_reg_attr_updated := TRUE;
        EXIT;
      END IF;
    END LOOP; -- j

    IF l_reg_attr_updated = TRUE THEN
      EXIT;
    END IF;
  END LOOP; -- i

  -- Bug: 5254856
  -- finding out if any TP dependant attributes are updated
  -- l_non_tp_attr_updated - if this is true, then we have to update the TP_NEUTRAL_UPDATE_DATE
  -- l_non_tp_attr_updated - if this is false and l_tp_attr_updated is true, then we need to only
  --    update the LAST_UPDATE_DATE for customer (which does not have this attribute value associated)
  FOR i IN p_attribute_names.FIRST..p_attribute_names.LAST LOOP
    FOR j IN l_core_tp_attr_list.FIRST..l_core_tp_attr_list.LAST LOOP
      IF UPPER(p_attribute_names(i)) = UPPER(l_core_tp_attr_list(j)) THEN
        l_tp_attr_updated := TRUE;
        EXIT;
      END IF;
    END LOOP; -- j

    IF l_tp_attr_updated = FALSE THEN
      l_non_tp_attr_updated := TRUE;
      EXIT;
    END IF;
  END LOOP; -- i

  IF l_reg_attr_updated = TRUE THEN
    UPDATE EGO_ITEM_GTN_ATTRS_B
    SET REGISTRATION_UPDATE_DATE = SYSDATE,
        TP_NEUTRAL_UPDATE_DATE = SYSDATE
    WHERE INVENTORY_ITEM_ID = p_inventory_item_id
      AND ORGANIZATION_ID = p_organization_id;
  ELSE
    IF p_attribute_names.COUNT > 0 AND l_non_tp_attr_updated THEN
      UPDATE EGO_ITEM_GTN_ATTRS_B
      SET TP_NEUTRAL_UPDATE_DATE = SYSDATE
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;
    ELSIF p_attribute_names.COUNT > 0 AND (l_tp_attr_updated AND (NOT l_non_tp_attr_updated) ) THEN
      -- getting GTIN of item
      BEGIN
        SELECT CROSS_REFERENCE INTO l_gtin
        FROM MTL_CROSS_REFERENCES MCR, MTL_SYSTEM_ITEMS_B MSIB
        WHERE MCR.CROSS_REFERENCE_TYPE = 'GTIN'
          AND MCR.INVENTORY_ITEM_ID = MSIB.INVENTORY_ITEM_ID
          AND MSIB.PRIMARY_UOM_CODE = MCR.UOM_CODE
          AND MSIB.ORGANIZATION_ID = p_organization_id
          AND MSIB.INVENTORY_ITEM_ID = p_inventory_item_id;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_gtin := NULL;
      END;

      FOR i IN c_customers(l_gtin) LOOP
        BEGIN
          SELECT
            START_AVAILABILITY_DATE_TIME,
            END_AVAILABILITY_DATE_TIME,
            IS_TRADE_ITEM_A_DESPATCH_UNIT,
            IS_TRADE_ITEM_AN_INVOICE_UNIT,
            MIN_TRADE_ITEM_LIFE_ARR,
            ORDER_QUANTITY_MIN,
            ORDER_QUANTITY_MAX
          INTO
            l_start_availability_date_time,
            l_end_availability_date_time,
            l_is_trade_item_a_despatch_unt,
            l_is_trade_item_an_invoice_unt,
            l_min_trade_item_life_arr,
            l_order_quantity_min,
            l_order_quantity_max
          FROM EGO_ITEM_CUST_ATTRS_B
          WHERE INVENTORY_ITEM_ID = p_inventory_item_id
            AND MASTER_ORGANIZATION_ID = p_organization_id
            AND PARTY_SITE_ID = i.PARTY_SITE_ID;

          l_update_last_upd_date := FALSE;
          FOR j IN p_attribute_names.FIRST..p_attribute_names.LAST LOOP
            write_debug_log('attr - '||UPPER(p_attribute_names(j)) );
            IF UPPER(p_attribute_names(j)) = 'SHELF_LIFE_DAYS' AND l_min_trade_item_life_arr IS NULL THEN
              l_update_last_upd_date := TRUE;
            ELSIF UPPER(p_attribute_names(j)) = 'START_AVAILABILITY_DATE_TIME' AND l_start_availability_date_time IS NULL THEN
              l_update_last_upd_date := TRUE;
            ELSIF UPPER(p_attribute_names(j)) = 'END_AVAILABILITY_DATE_TIME' AND l_end_availability_date_time IS NULL THEN
              l_update_last_upd_date := TRUE;
            ELSIF UPPER(p_attribute_names(j)) = 'ORDER_QUANTITY_MIN' AND l_order_quantity_min IS NULL THEN
              l_update_last_upd_date := TRUE;
            ELSIF UPPER(p_attribute_names(j)) = 'ORDER_QUANTITY_MAX' AND l_order_quantity_max IS NULL THEN
              l_update_last_upd_date := TRUE;
            ELSIF UPPER(p_attribute_names(j)) = 'SHIPPABLE_ITEM_FLAG' AND l_is_trade_item_a_despatch_unt IS NULL THEN
              l_update_last_upd_date := TRUE;
            ELSIF UPPER(p_attribute_names(j)) = 'INVOICEABLE_ITEM_FLAG' AND l_is_trade_item_an_invoice_unt IS NULL THEN
              l_update_last_upd_date := TRUE;
            END IF;
          END LOOP; --FOR j IN p_attribute_names.FIRST..p_attribute_names.LAST LOOP

          IF l_update_last_upd_date THEN
            UPDATE EGO_ITEM_CUST_ATTRS_B
            SET LAST_UPDATE_DATE = SYSDATE
            WHERE INVENTORY_ITEM_ID = p_inventory_item_id
              AND MASTER_ORGANIZATION_ID = p_organization_id
              AND PARTY_SITE_ID = i.PARTY_SITE_ID;
          END IF; --IF l_update_last_upd_date THEN
        EXCEPTION WHEN NO_DATA_FOUND THEN
          INSERT INTO EGO_ITEM_CUST_ATTRS_B
          (
            EXTENSION_ID,
            INVENTORY_ITEM_ID,
            MASTER_ORGANIZATION_ID,
            PARTY_SITE_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
          )
          VALUES
          (
            EGO_EXTFWK_S.NEXTVAL,
            p_inventory_item_id,
            p_organization_id,
            i.PARTY_SITE_ID,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE
          );
        END;
      END LOOP; --FOR i IN c_customers(l_gtin) LOOP
    END IF; -- IF other attrs got updated
  END IF; -- IF registration attrs got updated

  -- achampan: removed rollup call
  IF p_commit = FND_API.G_TRUE THEN
    write_debug_log('Commiting...');
    COMMIT;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := NULL;

  write_debug_log('End - EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES ... Date and Time - '||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));
EXCEPTION WHEN OTHERS THEN

  x_return_status := 'U';
  x_msg_data := SQLERRM;
  x_msg_count := 1;

END PROCESS_ATTRIBUTE_UPDATES;

/*
 * This procedure is added as a part of fix for bug: 3983838
 * This procedure is called from User Defined attributes EO i.e. EgoMtlSyItemsExtVLEOImpl
 * If any Extension GDSN attributes are updated, we update the TP_NEUTRAL_UPDATE_DATE or
 * LAST_UPDATE_DATE of EGO_ITEM_TP_ATTRS_EXT_B, depending upon whether the Attibute group
 * is TP-Dependant or not.
 */
PROCEDURE PROCESS_EXTN_ATTRIBUTE_UPDATES (p_inventory_item_id NUMBER,
                                          p_organization_id   NUMBER,
                                          p_attribute_names   EGO_VARCHAR_TBL_TYPE,
                                          p_attr_group_name   VARCHAR2,
                                          p_commit            VARCHAR2 := FND_API.G_FALSE,
                                          x_return_status     OUT NOCOPY VARCHAR2,
                                          x_msg_count         OUT NOCOPY NUMBER,
                                          x_msg_data          OUT NOCOPY VARCHAR2) AS
  x_error_message          VARCHAR2(2000);
  l_gtin                   MTL_CROSS_REFERENCES.CROSS_REFERENCE%TYPE;
  l_view_name              VARCHAR2(100);
  l_select_columns         VARCHAR2(32000);
  l_sql                    VARCHAR2(32000);
  l_value                  VARCHAR2(15000);
  l_extn_id                NUMBER;
  l_attr_group_id          NUMBER;
  l_ext_seq_val            NUMBER;

  CURSOR c_customers IS
    SELECT PARTY_SITE_ID
    FROM EGO_UCCNET_EVENTS
    WHERE INVENTORY_ITEM_ID = p_inventory_item_id
      AND ORGANIZATION_ID = p_organization_id
      AND EVENT_TYPE = 'PUBLICATION'
      AND EVENT_ACTION IN ( 'INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION', 'NEW_ITEM' )
      AND
         (
           DISPOSITION_CODE <> 'FAILED'
           OR DISPOSITION_CODE IS NULL
         )
    GROUP BY PARTY_SITE_ID;
BEGIN
  write_debug_log('Entering EGO_GTIN_PVT.PROCESS_EXTN_ATTRIBUTE_UPDATES ... Date and Time - '||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));
  write_debug_log('Item ID , Org ID, Attr_Group_Name = '||p_inventory_item_id||','||p_organization_id||','||p_attr_group_name);

  BEGIN
    SELECT AGV_NAME, ATTR_GROUP_ID INTO l_view_name, l_attr_group_id
    FROM EGO_FND_DSC_FLX_CTX_EXT
    WHERE DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_ITEM_TP_EXT_ATTRS'
      AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
      AND APPLICATION_ID = 431;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    write_debug_log('Attribute group does not belongs to EGO_ITEM_TP_EXT_ATTRS, so updating TP_NEUTRAL_UPDATE_DATE');
    -- even if a single attribute other than TP-Dependant attribute is updated, update the TP-Neutral Update date.
    FOR i IN p_attribute_names.FIRST..p_attribute_names.LAST LOOP
      UPDATE EGO_ITEM_GTN_ATTRS_B
      SET TP_NEUTRAL_UPDATE_DATE = SYSDATE
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;

      EXIT;
    END LOOP;
    write_debug_log('Exiting EGO_GTIN_PVT.PROCESS_EXTN_ATTRIBUTE_UPDATES ... Date and Time - '||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));
    x_return_status := 'S';
    x_msg_count := 0;
    x_msg_data := NULL;
    RETURN;
  END;

  FOR i IN p_attribute_names.FIRST..p_attribute_names.LAST LOOP
    l_select_columns := l_select_columns || UPPER(p_attribute_names(i)) || '||';
  END LOOP; -- i

  l_select_columns := RTRIM(l_select_columns, '||');

  l_sql := ' SELECT '||l_select_columns||' ,EXTENSION_ID FROM '||l_view_name||
           ' WHERE INVENTORY_ITEM_ID = :1 AND MASTER_ORGANIZATION_ID = :2 AND PARTY_SITE_ID = :3 AND ROWNUM = 1';

  write_debug_log('l_sql = '||l_sql);

  FOR i IN c_customers LOOP
    BEGIN
      write_debug_log('i.PARTY_SITE_ID  = '||i.PARTY_SITE_ID);
      EXECUTE IMMEDIATE l_sql INTO l_value, l_extn_id USING p_inventory_item_id, p_organization_id, i.PARTY_SITE_ID;

      IF l_value IS NULL THEN
        write_debug_log('Value is null l_extn_id= '||l_extn_id);
        UPDATE EGO_ITEM_TP_ATTRS_EXT_B
        SET LAST_UPDATE_DATE = SYSDATE
        WHERE EXTENSION_ID = l_extn_id;
      END IF;
      write_debug_log('Value is not null l_extn_id= '||l_extn_id);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      write_debug_log('No Data Found - inserting');
      SELECT EGO_EXTFWK_S.NEXTVAL INTO l_ext_seq_val FROM DUAL;

      INSERT INTO EGO_ITEM_TP_ATTRS_EXT_B
      (
        EXTENSION_ID,
        INVENTORY_ITEM_ID,
        MASTER_ORGANIZATION_ID,
        PARTY_SITE_ID,
        ATTR_GROUP_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE
      )
      VALUES
      (
        l_ext_seq_val,
        p_inventory_item_id,
        p_organization_id,
        i.PARTY_SITE_ID,
        l_attr_group_id,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE
      );

      INSERT INTO EGO_ITEM_TP_ATTRS_EXT_TL
      (
        EXTENSION_ID,
        INVENTORY_ITEM_ID,
        MASTER_ORGANIZATION_ID,
        PARTY_SITE_ID,
        ATTR_GROUP_ID,
        LANGUAGE,
        SOURCE_LANG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE
      )
      SELECT
        l_ext_seq_val,
        p_inventory_item_id,
        p_organization_id,
        i.PARTY_SITE_ID,
        l_attr_group_id,
        L.LANGUAGE_CODE,
        USERENV('LANG'),
        FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        SYSDATE
      FROM FND_LANGUAGES L
      WHERE L.INSTALLED_FLAG IN ('I', 'B')
        AND NOT EXISTS
             (SELECT NULL
              FROM EGO_ITEM_TP_ATTRS_EXT_TL T
              WHERE T.EXTENSION_ID = l_ext_seq_val
                AND T.LANGUAGE = L.LANGUAGE_CODE);
    END;
  END LOOP; --FOR i IN c_customers(l_gtin) LOOP

  IF p_commit = FND_API.G_TRUE THEN
    write_debug_log('Commiting...');
    COMMIT;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := NULL;

  write_debug_log('End - EGO_GTIN_PVT.PROCESS_EXTN_ATTRIBUTE_UPDATES ... Date and Time - '||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));
EXCEPTION WHEN OTHERS THEN
  x_return_status := 'U';
  x_msg_data := SQLERRM;
  x_msg_count := 1;
END PROCESS_EXTN_ATTRIBUTE_UPDATES;

/*
** Added by Devendra - This method will be called from Items IOI.
*  This procedure will validate the MSI attributes for UCCnet and will call PROCESS_ATTRIBUTE_UPDATES
*/
PROCEDURE PROCESS_UCCNET_ATTRIBUTES (P_Prog_AppId  NUMBER  DEFAULT -1,
                                     P_Prog_Id     NUMBER  DEFAULT -1,
                                     P_Request_Id  NUMBER  DEFAULT -1,
                                     P_User_Id     NUMBER  DEFAULT -1,
                                     P_Login_Id    NUMBER  DEFAULT -1,
                                     P_Set_id      NUMBER  DEFAULT -999,
                                     P_Suppress_Rollup VARCHAR2 DEFAULT 'N'
                                    )
IS
  CURSOR c_upated_items IS
    SELECT
      inventory_item_id,
      organization_id,
      unit_length,
      unit_weight,
      unit_width,
      unit_height,
      unit_volume,
      dimension_uom_code,
      list_price_per_unit,
      shippable_item_flag,
      invoiceable_item_flag,
      customer_order_enabled_flag,
      description,
      rowid,
      transaction_id,
      weight_uom_code,
      volume_uom_code,
      shelf_life_days,
      trade_item_descriptor
    FROM MTL_SYSTEM_ITEMS_INTERFACE
    WHERE (SET_PROCESS_ID = p_set_id OR SET_PROCESS_ID = p_set_id + 1000000000000)
      AND TRANSACTION_TYPE IN ('UPDATE', 'AUTO_CHILD')
      AND PROCESS_FLAG = 4;

  l_msib_rowid                     ROWID;
  l_unit_length                    MTL_SYSTEM_ITEMS.UNIT_LENGTH%TYPE := NULL;
  l_unit_weight                    MTL_SYSTEM_ITEMS.UNIT_WEIGHT%TYPE := NULL;
  l_unit_width                     MTL_SYSTEM_ITEMS.UNIT_WIDTH%TYPE := NULL;
  l_unit_height                    MTL_SYSTEM_ITEMS.UNIT_HEIGHT%TYPE := NULL;
  l_unit_volume                    MTL_SYSTEM_ITEMS.UNIT_VOLUME%TYPE := NULL;
  l_dimension_uom_code             MTL_SYSTEM_ITEMS.DIMENSION_UOM_CODE%TYPE := NULL;
  l_list_price_per_unit            MTL_SYSTEM_ITEMS.LIST_PRICE_PER_UNIT%TYPE := NULL;
  l_shippable_item_flag            MTL_SYSTEM_ITEMS.SHIPPABLE_ITEM_FLAG%TYPE := NULL;
  l_invoiceable_item_flag          MTL_SYSTEM_ITEMS.INVOICEABLE_ITEM_FLAG%TYPE := NULL;
  l_customer_order_enabled_flag    MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG%TYPE := NULL;
  l_description                    MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE := NULL;
  l_weight_uom_code                MTL_SYSTEM_ITEMS.WEIGHT_UOM_CODE%TYPE := NULL; -- Bug: 3874653
  l_volume_uom_code                MTL_SYSTEM_ITEMS.VOLUME_UOM_CODE%TYPE := NULL; -- Bug: 3921782
  l_shelf_life_days                MTL_SYSTEM_ITEMS.SHELF_LIFE_DAYS%TYPE := NULL; -- Bug: 5254856
  l_trade_item_desc                MTL_SYSTEM_ITEMS_B.TRADE_ITEM_DESCRIPTOR%TYPE;

  l_attribute_names                EGO_VARCHAR_TBL_TYPE := EGO_VARCHAR_TBL_TYPE(null);

  k                                BINARY_INTEGER := 0;
  l_return_status                  VARCHAR2(1);
  l_msg_text                       VARCHAR2(2000);
  l_msg_count                      NUMBER;
  err_text                         VARCHAR2(2000);
  l_gdsn_outbound_enabled_flag     VARCHAR2(1);
  dumm_status                      NUMBER;
  l_error                          BOOLEAN := FALSE;
  l_gross_weight                   NUMBER := NULL;
  l_msib_upd_reqd                  BOOLEAN := FALSE;
  l_pk_column_name_value_pairs     EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_class_code_name_value_pairs    EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_data_level_name_value_pairs    EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_attr_diffs                     EGO_USER_ATTR_DIFF_TABLE;
  l_error_message                  VARCHAR2(2000);
  l_item_catalog_group_id          NUMBER;
BEGIN
  write_debug_log('Entering EGO_GTIN_PVT.PROCESS_UCCNET_ATTRIBUTES ... Date and Time - '||to_char(sysdate, 'dd-mon-yyyy hh:mi:ss'));
  FOR i IN c_upated_items LOOP
    write_debug_log('Item ID , Org ID = '||i.inventory_item_id||','||i.organization_id);
    l_error := FALSE;
    l_msib_upd_reqd := FALSE;
    l_attribute_names := EGO_VARCHAR_TBL_TYPE(null);
    k := 0;
    l_attr_diffs := EGO_USER_ATTR_DIFF_TABLE();
    -- find whether updated item is an UCCnet enabled item or not
    BEGIN
      SELECT GDSN_OUTBOUND_ENABLED_FLAG INTO l_gdsn_outbound_enabled_flag
      FROM MTL_SYSTEM_ITEMS_B
      WHERE INVENTORY_ITEM_ID = i.inventory_item_id
        AND ORGANIZATION_ID = i.organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_gdsn_outbound_enabled_flag := NULL;
    END;

    write_debug_log('l_gdsn_outbound_enabled_flag = '||l_gdsn_outbound_enabled_flag);
    -- if the updated item is UCCnet enabled item then only proceed
    IF NVL(l_gdsn_outbound_enabled_flag, 'N') = 'Y' THEN
      -- Bug: 3930946 - validating only if the involved attributes are changed
      -- fetching old attribute values
      BEGIN
        SELECT
          msib.ROWID,
          msib.unit_length,
          msib.unit_weight,
          msib.unit_width,
          msib.unit_height,
          msib.unit_volume,
          msib.dimension_uom_code,
          msib.list_price_per_unit,
          msib.shippable_item_flag ,
          msib.invoiceable_item_flag,
          msib.customer_order_enabled_flag,
          msit.description,
          msib.weight_uom_code,
          msib.volume_uom_code,
          msib.shelf_life_days,
          msib.trade_item_descriptor
        INTO
          l_msib_rowid,
          l_unit_length,
          l_unit_weight,
          l_unit_width,
          l_unit_height,
          l_unit_volume,
          l_dimension_uom_code,
          l_list_price_per_unit,
          l_shippable_item_flag,
          l_invoiceable_item_flag,
          l_customer_order_enabled_flag,
          l_description,
          l_weight_uom_code,
          l_volume_uom_code,
          l_shelf_life_days,
          l_trade_item_desc
       FROM MTL_SYSTEM_ITEMS_B msib, MTL_SYSTEM_ITEMS_TL msit
       WHERE msib.INVENTORY_ITEM_ID = i.inventory_item_id
         AND msib.ORGANIZATION_ID = i.organization_id
         AND msib.INVENTORY_ITEM_ID = msit.INVENTORY_ITEM_ID
         AND msib.ORGANIZATION_ID = msit.ORGANIZATION_ID
         AND msit.LANGUAGE = USERENV('LANG');

      EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      -- Removed the inter-attribute group validations from here i.e. the validation that Gross_Weight
      -- is required when Customer Order Enabled flag is Y. Removed this validation since we were validating
      -- on the un-commited data.
      -- Bug: 3864260 - removed the validation for gross_weight can not be less than unit weight

      IF NOT l_error THEN
        write_debug_log('No Errors ...');
        -- if old and new values are different then putting attribute names into a Nested Table
        IF nvl(i.unit_length, -999) <> nvl(l_unit_length, -999) THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Unit_Length';
        END IF;

        IF nvl(i.unit_weight, -999) <> nvl(l_unit_weight, -999) THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Unit_Weight';
          l_msib_upd_reqd := TRUE;
          l_attr_diffs.EXTEND();
          l_attr_diffs(l_attr_diffs.LAST) := EGO_USER_ATTR_DIFF_OBJ
            ( attr_id             => 0
            , attr_name           => l_attribute_names(k)
            , old_attr_value_str  => null
            , old_attr_value_num  => l_unit_weight
            , old_attr_value_date => null
            , old_attr_uom        => null
            , new_attr_value_str  => null
            , new_attr_value_num  => i.unit_weight
            , new_attr_value_date => null
            , new_attr_uom        => null
            , unique_key_flag     => null
            , extension_id        => null
            );
        END IF;

        IF nvl(i.unit_width, -999) <> nvl(l_unit_width, -999) THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Unit_Width';
        END IF;

        IF nvl(i.unit_height, -999) <> nvl(l_unit_height, -999) THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Unit_Height';
        END IF;

        IF nvl(i.unit_volume, -999) <> nvl(l_unit_volume, -999) THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Unit_Volume';
        END IF;

        IF nvl(i.dimension_uom_code, '-x-') <> nvl(l_dimension_uom_code, '-x-') THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Dimension_Uom_Code';
        END IF;

        IF nvl(i.list_price_per_unit, -999) <> nvl(l_list_price_per_unit, -999) THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'List_Price_Per_Unit';
        END IF;

        IF nvl(i.shippable_item_flag, '-x-') <> nvl(l_shippable_item_flag, '-x-') THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Shippable_Item_Flag';
        END IF;

        IF nvl(i.invoiceable_item_flag, '-x-') <> nvl(l_invoiceable_item_flag, '-x-') THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Invoiceable_Item_Flag';
        END IF;

        IF nvl(i.customer_order_enabled_flag, '-x-') <> nvl(l_customer_order_enabled_flag, '-x-') THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Customer_Order_Enabled_Flag';
          l_msib_upd_reqd := TRUE;
          l_attr_diffs.EXTEND();
          l_attr_diffs(l_attr_diffs.LAST) := EGO_USER_ATTR_DIFF_OBJ
            ( attr_id             => 0
            , attr_name           => l_attribute_names(k)
            , old_attr_value_str  => l_customer_order_enabled_flag
            , old_attr_value_num  => null
            , old_attr_value_date => null
            , old_attr_uom        => null
            , new_attr_value_str  => i.customer_order_enabled_flag
            , new_attr_value_num  => null
            , new_attr_value_date => null
            , new_attr_uom        => null
            , unique_key_flag     => null
            , extension_id        => null
            );
        END IF;

        IF nvl(i.description, '-x-') <> nvl(l_description, '-x-') THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Description';
        END IF;

        -- Bug: 3874653 -- if the UOM of unit weight was changed, the change was not
        --                 getting propagated to higher level GTINs
        IF nvl(i.weight_uom_code, '-x-') <> nvl(l_weight_uom_code, '-x-') THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Weight_Uom_Code';
          l_msib_upd_reqd := TRUE;
          l_attr_diffs.EXTEND();
          l_attr_diffs(l_attr_diffs.LAST) := EGO_USER_ATTR_DIFF_OBJ
            ( attr_id             => 0
            , attr_name           => l_attribute_names(k)
            , old_attr_value_str  => l_weight_uom_code
            , old_attr_value_num  => null
            , old_attr_value_date => null
            , old_attr_uom        => null
            , new_attr_value_str  => i.weight_uom_code
            , new_attr_value_num  => null
            , new_attr_value_date => null
            , new_attr_uom        => null
            , unique_key_flag     => null
            , extension_id        => null
            );
        END IF;

        -- Bug: 3921782 -- if the UOM of Volume was changed, the registration status was
        --                 not getting changed to re-registration needed
        IF nvl(i.volume_uom_code, '-x-') <> nvl(l_volume_uom_code, '-x-') THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Volume_Uom_Code';
        END IF;

        -- Bug: 5254856 -- for TP dependent attrs
        IF nvl(i.shelf_life_days, -999) <> nvl(l_shelf_life_days, -999) THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Shelf_Life_Days';
        END IF;

        -- R12-C
        IF nvl(i.trade_item_descriptor, '-x-') <> nvl(l_trade_item_desc, '-x-') THEN
          l_attribute_names.EXTEND;
          k := k +1;
          l_attribute_names(k) := 'Trade_Item_Descriptor';
        END IF;

        IF k > 0 THEN
          FOR l in 1..k LOOP
            write_debug_log('Attribute modified -> '||l_attribute_names(l));
          END LOOP;
        END IF;

        IF k > 0 THEN
          IF l_msib_upd_reqd THEN
            UPDATE MTL_SYSTEM_ITEMS_B
            SET
              UNIT_WEIGHT = i.unit_weight,
              CUSTOMER_ORDER_ENABLED_FLAG = i.customer_order_enabled_flag,
              WEIGHT_UOM_CODE = i.weight_uom_code -- Bug: 3874653
            WHERE ROWID = l_msib_rowid;
          END IF;

          IF P_Suppress_Rollup <> 'Y' THEN

            l_pk_column_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
              ( EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', to_char(i.inventory_item_id))
              , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', to_char(i.organization_id))
              );

            -- issue query against MSIB for item_cat_group_id, value for item_id, org_id
            SELECT item_catalog_group_id
              INTO l_item_catalog_group_id
              FROM mtl_system_items_b
             WHERE inventory_item_id = i.inventory_item_id
               AND organization_id = i.organization_id;

            l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
              (EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', to_char(l_item_catalog_group_id)));

            l_data_level_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
              (EGO_COL_NAME_VALUE_PAIR_OBJ('DATA_LEVEL', 'EGO_ITEM'));

            -- achampan: add call to item_propagate_attributes
            EGO_GTIN_PVT.Item_Propagate_Attributes
              ( p_pk_column_name_value_pairs => l_pk_column_name_value_pairs
              , p_class_code_name_value_pairs => l_class_code_name_value_pairs
              , p_data_level_name_value_pairs => l_data_level_name_value_pairs
              , p_attr_diffs => l_attr_diffs
              , p_transaction_type => 'UPDATE'
              , x_error_message => l_error_message
              );

          END IF;

          write_debug_log('Before calling EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES from IOI ...');
          EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES(
              p_inventory_item_id => i.inventory_item_id,
              p_organization_id   => i.organization_id,
              p_attribute_names   => l_attribute_names,
              p_commit            => FND_API.G_FALSE,
              x_return_status     => l_return_status,
              x_msg_count         => l_msg_count,
              x_msg_data          => l_msg_text);

          write_debug_log('After calling EGO_GTIN_PVT.PROCESS_ATTRIBUTE_UPDATES from IOI ... return_status, error = '||l_return_status||' , '||l_msg_text);
          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            UPDATE MTL_SYSTEM_ITEMS_INTERFACE
            SET process_flag = 3
            WHERE rowid = i.rowid;

            dumm_status  := INVPUOPI.mtl_log_interface_err(
                                   i.organization_id
                                  ,P_User_Id
                                  ,P_Login_Id
                                  ,P_Prog_AppId
                                  ,P_Prog_Id
                                  ,P_Request_Id
                                  ,i.transaction_id
                                  ,l_msg_text
                                  ,'UCCnet'
                                  ,'MTL_SYSTEM_ITEMS_INTERFACE'
                                  ,'INV_IOI_ERR'
                                  ,err_text);

          END IF; -- if not success
        END IF; -- if k > 0 i.e. if new attribute values are not equal to old attribute values
      END IF; -- end if not l_error
    END IF; -- if l_gdsn_outbound_enabled_flag = Y
  END LOOP;
  write_debug_log('End calling EGO_GTIN_PVT.PROCESS_UCCNET_ATTRIBUTES...');
END PROCESS_UCCNET_ATTRIBUTES;

/*
** Added by Devendra - This method will update the REGISTRATION_UPDATE_DATE and TP_NEUTRAL_UPDATE_DATE
**  for an item. If parameter p_update_reg is supplied as 'Y' then REGISTRATION_UPDATE_DATE and
**  TP_NEUTRAL_UPDATE_DATE will be updated else only TP_NEUTRAL_UPDATE_DATE will be updated.
*/
PROCEDURE UPDATE_REG_PUB_UPDATE_DATES (p_inventory_item_id NUMBER,
                                       p_organization_id   NUMBER,
                                       p_update_reg        VARCHAR2 := 'N',
                                       p_commit            VARCHAR2 := FND_API.G_FALSE,
                                       x_return_status     OUT NOCOPY VARCHAR2,
                                       x_msg_count         OUT NOCOPY NUMBER,
                                       x_msg_data          OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF NVL(p_update_reg, 'N') = 'Y' THEN
    UPDATE EGO_ITEM_GTN_ATTRS_B
    SET REGISTRATION_UPDATE_DATE = SYSDATE,
        TP_NEUTRAL_UPDATE_DATE = SYSDATE
    WHERE INVENTORY_ITEM_ID = p_inventory_item_id
      AND ORGANIZATION_ID = p_organization_id;
  ELSE
    UPDATE EGO_ITEM_GTN_ATTRS_B
    SET TP_NEUTRAL_UPDATE_DATE = SYSDATE
    WHERE INVENTORY_ITEM_ID = p_inventory_item_id
      AND ORGANIZATION_ID = p_organization_id;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
    COMMIT;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := NULL;
EXCEPTION WHEN OTHERS THEN
  x_return_status := 'U';
  x_msg_data := SQLERRM;
  x_msg_count := 1;
END UPDATE_REG_PUB_UPDATE_DATES;

--------------------------------
/*
** Added by Amay - for propagation of attributes up the hierarchy
*/
--------------------------------
-- sridhar modified
--------------------------------

PROCEDURE Item_Propagate_Attributes
        ( p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_diffs                    IN EGO_USER_ATTR_DIFF_TABLE
        , p_transaction_type              IN VARCHAR2
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , x_error_message                 OUT NOCOPY VARCHAR2
        )
  IS
    l_action_map           Bom_Rollup_Pub.Rollup_Action_Map;
    l_item_id              NUMBER;
    l_organization_id      NUMBER;
    l_structure_type_name  VARCHAR2(200);

    l_api_name             VARCHAR2(30);
    l_item_obj_name        VARCHAR2(30);

    l_propagate_brand_info         BOOLEAN;
    l_propagate_mfg_info           BOOLEAN;
    l_trade_item_or_consumer_unit  BOOLEAN;
    l_propagate_sh_temps           BOOLEAN;
    l_propagate_top_gtin           BOOLEAN;
    l_propagate_unit_weight        BOOLEAN;

    l_null_str_value          VARCHAR2(1);
    l_null_num_value          NUMBER;
    l_null_date_value         DATE;

    l_user_attr_diff_data     EGO_USER_ATTR_DIFF_OBJ;

  BEGIN

    l_api_name             := 'Item_Propagate_Attributes';
    WRITE_DEBUG_LOG(l_api_name || ': Started ');
    l_item_obj_name        := 'EGO_ITEM';
    l_action_map           := Bom_Rollup_Pub.G_EMPTY_ACTION_MAP;
    l_structure_type_name  := 'Packaging Hierarchy';

    l_propagate_brand_info         := FALSE;
    l_propagate_mfg_info           := FALSE;
    l_trade_item_or_consumer_unit  := FALSE;
    l_propagate_sh_temps           := FALSE;
    l_propagate_top_gtin           := FALSE;
    l_propagate_unit_weight        := FALSE;

    l_null_str_value          := FND_API.G_MISS_CHAR;
    l_null_num_value          := FND_API.G_MISS_NUM;
    l_null_date_value         := FND_API.G_MISS_DATE;

    l_item_id := p_pk_column_name_value_pairs(p_pk_column_name_value_pairs.FIRST).VALUE;
    l_organization_id := p_pk_column_name_value_pairs(p_pk_column_name_value_pairs.FIRST+1).VALUE;

    IF (p_attr_diffs.COUNT > 0) THEN
      WRITE_DEBUG_LOG(l_api_name || ': exists a list of attributes ');
      FOR i in p_attr_diffs.first..p_attr_diffs.last LOOP
        l_user_attr_diff_data := p_attr_diffs(i);
        WRITE_DEBUG_LOG(l_api_name || ': checking record - '|| i || ' - in the list of attributes sent - '||l_user_attr_diff_data.attr_name);
        IF (NVL(l_user_attr_diff_data.old_attr_value_str,l_null_str_value) <>
               NVL(l_user_attr_diff_data.new_attr_value_str,l_null_str_value))
            OR
            (NVL(l_user_attr_diff_data.old_attr_value_num,l_null_num_value) <>
               NVL(l_user_attr_diff_data.new_attr_value_num,l_null_num_value))
            OR
            (NVL(l_user_attr_diff_data.old_attr_value_date,l_null_date_value) <>
               NVL(l_user_attr_diff_data.new_attr_value_date,l_null_date_value))
            OR
            (NVL(l_user_attr_diff_data.old_attr_uom,l_null_str_value) <>
               NVL(l_user_attr_diff_data.new_attr_uom,l_null_str_value))  THEN
          WRITE_DEBUG_LOG(l_api_name || ': an attribute has changed ');
          IF NOT l_propagate_brand_info
             AND
             UPPER(l_user_attr_diff_data.attr_name)
                      IN ('RETAIL_BRAND_OWNER_NAME'
                         ,'RETAIL_BRAND_OWNER_GLN'
                         ,'FUNCTIONAL_NAME'
                         ,'SUB_BRAND') THEN
            WRITE_DEBUG_LOG(l_api_name || ': Brand info has changed ');
            l_propagate_brand_info    := check_propagation_allowed(l_user_attr_diff_data.attr_id);
            -- the following functions will be rolled up
            --    attribute             attribute_name
            -- ** BrandOwnerName        Retail_Brand_Owner_Name
            -- ** BrandOwnerGLN         Retail_Brand_Owner_Gln
            -- ** FunctionalName        Functional_name
            -- ** SubBrand              Sub_Brand
          ELSIF NOT l_propagate_mfg_info
                AND
                UPPER(l_user_attr_diff_data.attr_name)
                      IN ('MANUFACTURER_GLN'
                         ,'NAME_OF_MANUFACTURER') THEN
            WRITE_DEBUG_LOG(l_api_name || ': Manufacturer info has changed ');
            l_propagate_mfg_info      := check_propagation_allowed(l_user_attr_diff_data.attr_id);
            -- the following functions will be rolled up
            --    attribute             attribute_name
            -- ** ManufacturerGLN       Manufacturer_Gln
            -- ** ManufacturerName      Name_Of_Manufacturer
          ELSIF NOT l_trade_item_or_consumer_unit
                AND
                upper(l_user_attr_diff_data.attr_name) = 'IS_TRADE_ITEM_A_CONSUMER_UNIT' THEN
             l_trade_item_or_consumer_unit := check_propagation_allowed(l_user_attr_diff_data.attr_id);
          ELSIF NOT l_propagate_sh_temps
                AND
                UPPER(l_user_attr_diff_data.attr_name)
                        IN ('UCCNET_STORAGE_TEMP_MIN'
                           ,'UOM_STORAGE_HANDLING_TEMP_MIN'
                           ,'UCCNET_STORAGE_TEMP_MAX'
                           ,'UOM_STORAGE_HANDLING_TEMP_MAX') THEN
            WRITE_DEBUG_LOG(l_api_name || ': Storage Handling Temps have changed ');
            l_propagate_sh_temps := check_propagation_allowed(l_user_attr_diff_data.attr_id);
            IF NOT l_propagate_sh_temps THEN
              l_propagate_sh_temps := TRUE;
            END IF;
            -- the following functions will be rolled up
            --    attribute                 attribute_name
            -- ** UccnetStorageTempMin      Uccnet_Storage_Temp_Min
            -- ** UomStorageHandlingTempMin Uom_Storage_Handling_Temp_Min
            -- ** UccnetStorageTempMax      Uccnet_Storage_Temp_Max
            -- ** UomStorageHandlingTempMax Uom_Storage_Handling_Temp_Max
          ELSIF NOT l_propagate_top_gtin
                 AND
                 UPPER(l_user_attr_diff_data.attr_name) = 'CUSTOMER_ORDER_ENABLED_FLAG' THEN
            WRITE_DEBUG_LOG(l_api_name || ': Customer Order Enabled Flag has changed ');
            l_propagate_top_gtin := TRUE; --check_propagation_allowed(l_user_attr_diff_data.attr_id);
            -- the following functions will be rolled up
            --    attribute                 attribute_name
            -- ** TopGtin                   TopGtin
          ELSIF NOT l_propagate_unit_weight
                 AND
                 UPPER(l_user_attr_diff_data.attr_name)
                        IN ('UNIT_WEIGHT'
                           ,'WEIGHT_UOM_CODE') THEN
            WRITE_DEBUG_LOG(l_api_name || ': Unit Weight/UOM has changed ');
            l_propagate_unit_weight := TRUE; --check_propagation_allowed(l_user_attr_diff_data.attr_id);
            -- the following functions will be rolled up
            --    attribute                 attribute_name
            -- ** UnitWeight                Unit_Weight
            -- ** WeightUomCode             Weight_Uom_Code
          ELSE
            WRITE_DEBUG_LOG(l_api_name || ': Attribute values ALREADY tagged for change OR a different GTIN attribute has been observed ');
          END IF; -- attribute that needs to be changed.
        ELSE
          WRITE_DEBUG_LOG(l_api_name || ': Attribute values have not changed ');
        END IF; -- value has changed
      END LOOP; -- looping each attribute
    ELSE
      WRITE_DEBUG_LOG(l_api_name || ': list of attributes is NULL ');
    END IF; -- there exists attr diffs
    WRITE_DEBUG_LOG(l_api_name || ': using params ('||l_item_id||','||l_organization_id||','||l_structure_type_name||')');

    IF l_propagate_brand_info THEN
      Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => l_item_obj_name
        , p_Rollup_Action       => Bom_Rollup_Pub.G_PROPOGATE_BRAND_INFO
        , p_DML_Function        => 'Bom_Compute_Functions.Set_Brand_Info'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_action_map
        );
    END IF;

    IF l_propagate_mfg_info THEN
       Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => l_item_obj_name
        , p_Rollup_Action       => Bom_Rollup_Pub.G_COMPUTE_MULTI_ROW_ATTRS
        , p_DML_Function        => 'Bom_Compute_Functions.Set_Multirow_Attributes'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_action_map
        );
    END IF;

    IF  l_trade_item_or_consumer_unit OR l_propagate_top_gtin THEN
      Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => l_item_obj_name
        , p_Rollup_Action       => Bom_Rollup_Pub.G_COMPUTE_TOP_GTIN_FLAG
        , p_DML_Function        => 'Bom_Compute_Functions.Set_Top_GTIN_Flag'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_action_map
        );
    END IF;

    IF  l_propagate_sh_temps THEN
      Bom_Rollup_Pub.Add_Rollup_Function
        ( p_Object_Name         => l_item_obj_name
        , p_Rollup_Action       => Bom_Rollup_Pub.G_PROPAGATE_SH_TEMPS
        , p_DML_Function        => 'Bom_Compute_Functions.Set_SH_Temps'
        , p_DML_Delayed_Write   => 'N'
        , x_Rollup_Action_Map   => l_action_map
        );
    END IF;

    IF  l_propagate_unit_weight THEN
      Bom_Rollup_Pub.Add_Rollup_Function
          ( p_Object_Name         => 'EGO_ITEM'
          , p_Rollup_Action       => Bom_Rollup_Pub.G_COMPUTE_NET_WEIGHT
          , p_DML_Function        => 'Bom_Compute_Functions.Set_Net_Weight'
          , p_DML_Delayed_Write   => 'N'
          , x_Rollup_Action_Map   => l_action_map
          );
    END IF;

--    IF  l_propagate_brand_info OR l_trade_item_or_consumer_unit THEN
-- todo uncomment the below after making mfg changes
    IF  l_propagate_brand_info OR
        l_propagate_mfg_info OR
        l_trade_item_or_consumer_unit OR
        l_propagate_sh_temps OR
        l_propagate_top_gtin OR
        l_propagate_unit_weight THEN
      WRITE_DEBUG_LOG(l_api_name || ': calling Bom_Rollup_Pub.Perform_Rollup');
      Bom_Rollup_Pub.Perform_Rollup
      (   p_item_id                     => l_item_id
        , p_organization_id           => l_organization_id
        , p_structure_type_name       => l_structure_type_name
        , p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
        , p_class_code_name_value_pairs   => p_class_code_name_value_pairs
        , p_data_level_name_value_pairs   => p_data_level_name_value_pairs
        , p_attr_diffs                    => p_attr_diffs
        , p_transaction_type              => p_transaction_type
        , p_attr_group_id                 => p_attr_group_id
        , p_action_map                => l_action_map
        , x_error_message             => x_error_message
        );
    END IF;
  WRITE_DEBUG_LOG(l_api_name || 'return value from Perform_Rollup:' || x_error_message);
    WRITE_DEBUG_LOG(l_api_name || ': Done ');


  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name(G_APP_NAME, G_PLSQL_ERR);
      FND_MESSAGE.Set_Token(G_PKG_NAME_TOKEN, G_PKG_NAME);
      FND_MESSAGE.Set_Token(G_API_NAME_TOKEN, l_api_name);
      FND_MESSAGE.Set_Token(G_SQL_ERR_MSG_TOKEN, SQLERRM);
      x_error_message := FND_MSG_PUB.Get;
      WRITE_DEBUG_LOG(x_error_message);
      RETURN;
END Item_Propagate_Attributes;
--------------------------------

-- Call correct EGO API to update attribute, update registration flag as necessary
-- Currently, this only support SINGLE-ROW attributes.  See the other Update_Attributes API for MULTI-ROW
PROCEDURE Update_Attribute
        ( p_inventory_item_id             IN NUMBER
        , p_organization_id               IN NUMBER
        , p_attr_name                     IN VARCHAR2
        , p_attr_group_type               IN VARCHAR2 DEFAULT NULL
        , p_attr_group_name               IN VARCHAR2 DEFAULT NULL
        , p_attr_new_value_str            IN VARCHAR2 DEFAULT NULL
        , p_attr_new_value_num            IN NUMBER   DEFAULT NULL
        , p_attr_new_value_date           IN DATE     DEFAULT NULL
        , p_attr_new_value_uom            IN VARCHAR2 DEFAULT NULL
        , p_debug_level                   IN NUMBER   DEFAULT 0
        , x_return_status                 OUT NOCOPY VARCHAR2
        , x_errorcode                     OUT NOCOPY NUMBER
        , x_msg_count                     OUT NOCOPY NUMBER
        , x_msg_data                      OUT NOCOPY VARCHAR2
        )
  IS
    CURSOR c_msi_old_values IS
      SELECT
        inventory_item_id,
        organization_id,
        segment1,
        unit_weight,
        weight_uom_code
      FROM MTL_SYSTEM_ITEMS_B
      WHERE inventory_item_id = p_inventory_item_id
        AND organization_id = p_organization_id;

    l_unit_weight                    MTL_SYSTEM_ITEMS.UNIT_WEIGHT%TYPE := NULL;
    l_weight_uom_code                MTL_SYSTEM_ITEMS.WEIGHT_UOM_CODE%TYPE := NULL;

    l_msi_attr_names EGO_VARCHAR_TBL_TYPE := EGO_VARCHAR_TBL_TYPE(null);
    l_msi_attr_given BOOLEAN := FALSE;
    l_msi_index NUMBER;

    CURSOR c_user_attr_metadata IS
      SELECT data_type_code
           , database_column
        FROM ego_attrs_v v
       WHERE attr_group_type = p_attr_group_type
         AND attr_group_name = p_attr_group_name
         AND attr_name = p_attr_name
         AND application_id = 431;

    l_data_type_code VARCHAR2(30);
    l_attr_old_value_str  VARCHAR2(1000) := NULL;
    l_attr_old_value_num  NUMBER := NULL;
    l_attr_old_value_date DATE := NULL;
    l_attr_old_value_uom  VARCHAR2(3) := NULL;
    l_old_query VARCHAR2(4000);

    l_pk_columns EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_class_code EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_item_catalog_group_id  NUMBER;
    l_error_code NUMBER;
    l_attribute_names EGO_VARCHAR_TBL_TYPE;
    l_attr_new_values EGO_USER_ATTR_DATA_TABLE;

    --Cursor for creating the classification code
    CURSOR get_classification_code IS
      SELECT item_catalog_group_id
        FROM mtl_system_items_b
       WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id;

    l_inventory_item_id NUMBER;
    l_organization_id   NUMBER;
    l_api_name          VARCHAR2(40);
    l_weight_changed    BOOLEAN := FALSE;
    l_uom_changed       BOOLEAN := FALSE;
    l_found_attr        BOOLEAN := FALSE;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_api_name := 'Update_Attribute';

    write_debug_log(l_api_name||': starting for '||p_inventory_item_id||'-'||p_organization_id);

    IF p_attr_group_type IS NOT NULL THEN

      -- setting user-defined attributes
-- todo: uoms? for right now, SH temp and weight are the only ones with uoms,
--  which we handle correctly

      -- first query up the current values
      FOR i IN c_user_attr_metadata LOOP

        l_found_attr := TRUE;
        l_old_query :=
          'SELECT '||i.database_column||
          '  FROM ego_item_gtn_attrs_vl '||
          ' WHERE inventory_item_id = :1 '||
          '   AND organization_id = :2';

        write_debug_log(l_api_name||': found data type code '||i.data_type_code);

        IF (i.data_type_code = EGO_EXT_FWK_PUB.G_CHAR_DATA_TYPE OR
            i.data_type_code = EGO_EXT_FWK_PUB.G_TRANS_TEXT_DATA_TYPE)
        THEN

          EXECUTE IMMEDIATE l_old_query
             INTO l_attr_old_value_str
            USING p_inventory_item_id, p_organization_id;

        ELSIF (i.data_type_code = EGO_EXT_FWK_PUB.G_NUMBER_DATA_TYPE)
        THEN

          EXECUTE IMMEDIATE l_old_query
             INTO l_attr_old_value_num
            USING p_inventory_item_id, p_organization_id;

        ELSIF (i.data_type_code = EGO_EXT_FWK_PUB.G_DATE_DATA_TYPE OR
            i.data_type_code = EGO_EXT_FWK_PUB.G_DATE_TIME_DATA_TYPE)
        THEN

          EXECUTE IMMEDIATE l_old_query
             INTO l_attr_old_value_date
            USING p_inventory_item_id, p_organization_id;

        END IF;

        write_debug_log(l_api_name||': got old value '||l_attr_old_value_str||','||l_attr_old_value_num||','||l_attr_old_value_date);

        -- only perform update if values are different
        IF (NVL(l_attr_old_value_str, '-x-') <> NVL(p_attr_new_value_str, '-x-')) OR
           (NVL(l_attr_old_value_num, -999) <> NVL(p_attr_new_value_num, -999)) OR
           (NOT ((l_attr_old_value_date IS NULL AND
                  p_attr_new_value_date IS NULL) OR
                 (l_attr_old_value_date IS NOT NULL AND
                  p_attr_new_value_date IS NOT NULL AND
                  l_attr_old_value_date = p_attr_new_value_date)))
        THEN

          l_pk_columns := EGO_COL_NAME_VALUE_PAIR_ARRAY
            ( EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', p_inventory_item_id)
            , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', p_organization_id)
            );

          FOR c1 IN get_classification_code
          LOOP
            l_item_catalog_group_id := c1.item_catalog_group_id;
          END LOOP;

          l_class_code := EGO_COL_NAME_VALUE_PAIR_ARRAY
            (EGO_COL_NAME_VALUE_PAIR_OBJ( 'ITEM_CATALOG_GROUP_ID', to_char(l_item_catalog_group_id)));

          l_attr_new_values :=
            EGO_USER_ATTR_DATA_TABLE
              ( EGO_USER_ATTR_DATA_OBJ
                ( 1
                , p_attr_name
                , p_attr_new_value_str
                , p_attr_new_value_num
                , p_attr_new_value_date
                , NULL
                , p_attr_new_value_uom
                , NULL
                )
              );

          write_debug_log(l_api_name||': calling Perform_DML_On_Row');

          EGO_USER_ATTRS_DATA_PVT.Perform_DML_On_Row
            ( p_api_version => 1.0
            , p_object_name => 'EGO_ITEM'
            , p_application_id => 431
            , p_attr_group_type => p_attr_group_type
            , p_attr_group_name => p_attr_group_name
            , p_pk_column_name_value_pairs => l_pk_columns
            , p_class_code_name_value_pairs => l_class_code
      --      , p_data_level_name_value_pairs => l_data_level
            , p_data_level_name_value_pairs => Bom_Rollup_Pub.g_data_level_name_value_pairs
            , p_attr_name_value_pairs => l_attr_new_values
       -- this is very important, because otherwise, updates would trigger rollups, creating an infinite loop
            , p_debug_level   => p_debug_level
            , p_bulkload_flag => FND_API.G_TRUE
            , x_return_status => x_return_status
            , x_errorcode => x_errorcode
            , x_msg_count => x_msg_count
            , x_msg_data => x_msg_data
            );

          write_debug_log(l_api_name||': called Perform_DML_On_Row with ret='||x_return_status);

          IF x_return_status = 'S' THEN

            -- build attr list and call process_attr_updates
            l_attribute_names := EGO_VARCHAR_TBL_TYPE(p_attr_name);

            write_debug_log(l_api_name||': calling Process_Attribute_Updates');

            Process_Attribute_Updates
              ( p_inventory_item_id => p_inventory_item_id
              , p_organization_id   => p_organization_id
              , p_attribute_names   => l_attribute_names
              , x_return_status     => x_return_status
              , x_msg_count         => x_msg_count
              , x_msg_data          => x_msg_data
              );

            write_debug_log(l_api_name||': called Process_Attribute_Updates with ret='||x_return_status);

          END IF;

        END IF;

      END LOOP; -- c_user_attr_metadata

    ELSE

      write_debug_log(l_api_name||': processing msi or top gtin attribute');

      -- Get old attr value from the db
      IF UPPER(p_attr_name) = 'UNIT_WEIGHT' OR
         UPPER(p_attr_name) = 'WEIGHT_UOM_CODE'
      THEN

        l_found_attr := TRUE;

        IF UPPER(p_attr_name) = 'UNIT_WEIGHT' THEN

          l_unit_weight := p_attr_new_value_num;
          l_weight_changed := TRUE;

          -- if uom is given in p_attr_new_value_uom, use it
          IF p_attr_new_value_uom IS NOT NULL THEN

            l_weight_uom_code := p_attr_new_value_uom;
            l_uom_changed := TRUE;

          END IF;

        ELSE

          -- allow passing of weight uom in either str or uom (str preferred)
          l_weight_uom_code := nvl(p_attr_new_value_str, p_attr_new_value_uom);
          l_uom_changed := TRUE;

        END IF;

        -- Compare old with new from the attr map
        FOR c2 IN c_msi_old_values
        LOOP

          write_debug_log(l_api_name||': old wt = '||c2.unit_weight||' '||c2.weight_uom_code||' new wt = '||l_unit_weight||' '||l_weight_uom_code);

          -- only perform update if values are different
          l_weight_changed := l_weight_changed AND (NVL(c2.unit_weight, -999) <> NVL(l_unit_weight, -999));
          l_uom_changed := l_uom_changed AND (NVL(c2.weight_uom_code, '-x-') <> NVL(l_weight_uom_code, '-x-'));

          -- default weight/uom to old value if missing
          IF l_weight_changed AND (NOT l_uom_changed) THEN

            write_debug_log(l_api_name||': defaulting uom');
            l_weight_uom_code := c2.weight_uom_code;

          ELSIF (NOT l_weight_changed) AND l_uom_changed THEN

            write_debug_log(l_api_name||': defaulting wt');
            l_unit_weight := c2.unit_weight;

          END IF;

          IF l_weight_changed OR l_uom_changed THEN

            write_debug_log(l_api_name||': calling Process_Item with wt '||l_unit_weight||' uom '||l_weight_uom_code);

            -- Call INV API for MSI attributes
            EGO_ITEM_PUB.Process_Item(
                  p_api_version       => 1.0
                , p_transaction_type  => EGO_ITEM_PUB.G_TTYPE_UPDATE
                , p_inventory_item_id => p_inventory_item_id
                , p_organization_id   => p_organization_id
                , p_item_number       => c2.segment1
                , p_weight_uom_code   => l_weight_uom_code
                , p_unit_weight       => l_unit_weight
                , p_process_control   => 'SUPPRESS_ROLLUP'
                , x_inventory_item_id => l_inventory_item_id
                , x_organization_id   => l_organization_id
                , x_return_status     => x_return_status
                , x_msg_count         => x_msg_count
                , x_msg_data          => x_msg_data
                );

            write_debug_log(l_api_name||': Process_Item returned '||x_return_status||' '||x_msg_data);

          END IF;

        END LOOP;

      ELSIF UPPER(p_attr_name) = 'TOP_GTIN' THEN

        l_found_attr := TRUE;
        Set_Top_GTIN_Flag(p_inventory_item_id, p_organization_id, p_attr_new_value_str, x_return_status);

      END IF; --p_attr_name

    END IF; --p_attr_group_type IS NOT NULL

    IF NOT l_found_attr THEN

      -- add more descriptive error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLERRM;
      x_msg_count := 1;

    END IF;

    IF x_return_status <> 'S' THEN

      write_debug_log(l_api_name||' : ******* ERROR ******* '||x_return_status||' '||fnd_msg_pub.get(1,x_msg_data));

    END IF;

  EXCEPTION

    WHEN OTHERS THEN

      write_debug_log(l_api_name||': failed: '||sqlerrm);

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', g_pkg_name);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);

END Update_Attribute;

--------------------------------

PROCEDURE Update_Attributes
        ( p_pk_column_name_value_pairs    IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_class_code_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_data_level_name_value_pairs   IN EGO_COL_NAME_VALUE_PAIR_ARRAY
        , p_attr_diffs                    IN EGO_USER_ATTR_DIFF_TABLE
        , p_transaction_type              IN VARCHAR2
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , x_error_message                 OUT NOCOPY VARCHAR2
        )
  IS

    l_object_name_table_index NUMBER;
    l_object_id              NUMBER;

  BEGIN

      EGO_USER_ATTRS_DATA_PVT.Update_Attributes
        ( p_pk_column_name_value_pairs
        , p_class_code_name_value_pairs
        , 'ITEM_LEVEL'
        , p_data_level_name_value_pairs
        , p_attr_diffs
        , p_transaction_type
        , p_attr_group_id
        , x_error_message);

END Update_Attributes;

--------------------------------

/*
** Added by Amay - for getting of attribute diff objects (called by BOM_ROLLUP_PUB)
*/
PROCEDURE Get_Attr_Diffs
        ( p_inventory_item_id             IN NUMBER
        , p_org_id                        IN NUMBER
        , p_attr_group_id                 IN NUMBER DEFAULT NULL
        , p_application_id                IN NUMBER DEFAULT NULL
        , p_attr_group_type               IN VARCHAR2 DEFAULT NULL
        , p_attr_group_name               IN VARCHAR2 DEFAULT NULL
        , px_attr_diffs                   IN OUT NOCOPY EGO_USER_ATTR_DIFF_TABLE
        , px_pk_column_name_value_pairs    OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
        , px_class_code_name_value_pairs   OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
        , px_data_level_name_value_pairs   OUT NOCOPY EGO_COL_NAME_VALUE_PAIR_ARRAY
        , x_error_message                 OUT NOCOPY VARCHAR2
        )
  IS
   --  l_pk_column_name_value_pairs    EGO_COL_NAME_VALUE_PAIR_ARRAY;
   --  l_class_code_name_value_pairs   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_item_catalog_group_id         NUMBER;
  BEGIN

     px_pk_column_name_value_pairs :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY
        ( EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID', to_char(p_inventory_item_id))
        , EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID', to_char(p_org_id))
        );

    -- issue query against MSIB for item_cat_group_id, value for item_id, org_id
    SELECT item_catalog_group_id INTO l_item_catalog_group_id
    FROM mtl_system_items_b
    WHERE inventory_item_id = p_inventory_item_id
    AND organization_id = p_org_id;

    px_class_code_name_value_pairs :=
      EGO_COL_NAME_VALUE_PAIR_ARRAY
        (EGO_COL_NAME_VALUE_PAIR_OBJ('ITEM_CATALOG_GROUP_ID', to_char(l_item_catalog_group_id)));

    EGO_USER_ATTRS_DATA_PVT.Get_Attr_Diffs
      ( p_object_name                 => 'EGO_ITEM'
      , p_pk_column_name_value_pairs  => px_pk_column_name_value_pairs
      , p_class_code_name_value_pairs => px_class_code_name_value_pairs
      , p_data_level                  => 'ITEM_LEVEL'
      , p_data_level_name_value_pairs => NULL
      , p_attr_group_id               => p_attr_group_id
      , p_application_id              => p_application_id
      , p_attr_group_type             => p_attr_group_type
      , p_attr_group_name             => p_attr_group_name
      , px_attr_diffs                 => px_attr_diffs
      , x_error_message               => x_error_message);

END Get_Attr_Diffs;

--------------------------------

PROCEDURE Set_Top_GTIN_Flag
        ( p_inventory_item_id             IN NUMBER
        , p_organization_id               IN NUMBER
        , p_top_gtin_flag                 IN VARCHAR2
        , x_return_status                 OUT NOCOPY VARCHAR2
        )
  IS
    l_gtin_dml_str VARCHAR2(2000);
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- for now just update
    l_gtin_dml_str := 'UPDATE ego_item_gtn_attrs_b SET ';
    l_gtin_dml_str := l_gtin_dml_str || 'TOP_GTIN = ''' || p_top_gtin_flag || '''';
    l_gtin_dml_str := l_gtin_dml_str ||
      ' WHERE inventory_item_id = :item_id ' ||
      ' AND organization_id = :org_id ' ;
/* Commented by snelloli as we have to update with empty string for 'N'
TOP_GTIN != '' does not return any rows and the update fails
 ||
      ' AND (TOP_GTIN IS NULL OR TOP_GTIN <> ''' || p_top_gtin_flag || ''')';
*/

    WRITE_DEBUG_LOG('Set_Top_GTIN_Flag: executing '||l_gtin_dml_str||' for '||p_inventory_item_id||'-'||p_organization_id);
    EXECUTE IMMEDIATE l_gtin_dml_str USING p_inventory_item_id, p_organization_id;

END Set_Top_GTIN_Flag;

--------------------------------

Function Is_Attribute_Group_Associated
        ( p_application_id                IN NUMBER
        , p_attr_group_type               IN VARCHAR2
        , p_attr_group_name               IN VARCHAR2
        , p_inventory_item_id             IN NUMBER
        , p_organization_id               IN NUMBER
        )
  RETURN BOOLEAN
  IS

    l_temp VARCHAR2(1);

   BEGIN

     SELECT 'X' into l_temp
     FROM
        EGO_OBJ_AG_ASSOCS_B A,
        EGO_FND_DSC_FLX_CTX_EXT EXT
     WHERE
          A.ATTR_GROUP_ID = EXT.ATTR_GROUP_ID
      AND EXT.APPLICATION_ID = p_application_id
      and EXT.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
      and EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
      and A.CLASSIFICATION_CODE IN
             ( SELECT ITEM_CATALOG_GROUP_ID
                 FROM MTL_ITEM_CATALOG_GROUPS_B
                 CONNECT BY PRIOR  PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID
                 START WITH  ITEM_CATALOG_GROUP_ID = (select item_catalog_group_id
                                                      from mtl_system_items_b
                                                      where inventory_item_id = p_inventory_item_id
                                                      and organization_id = p_organization_id) );
     RETURN(TRUE);

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RETURN(FALSE);
     WHEN OTHERS THEN
          RETURN(FALSE);

END IS_Attribute_Group_Associated;


PROCEDURE Seed_Uccnet_Attributes_Pages

IS

  TYPE t_NumberTbl      IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE t_PageNameTbl    IS TABLE OF EGO_PAGES_TL.DISPLAY_NAME%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_AttrGroupNameTbl IS TABLE OF EGO_FND_DSC_FLX_CTX_EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_AttrGroupTypeTbl IS TABLE OF EGO_FND_DSC_FLX_CTX_EXT.DESCRIPTIVE_FLEXFIELD_NAME%TYPE INDEX BY BINARY_INTEGER;

  -- CONSTANTS
  G_EGO_APP_ID           CONSTANT NUMBER := 431;
  G_ITEM_OBJECT_NAME     CONSTANT VARCHAR2(30) := 'EGO_ITEM';
  G_ITEM_LEVEL           CONSTANT VARCHAR2(150) := 'ITEM_LEVEL';

  -- Tables to hold the bulk collected values
  l_CatalogGroupIds    t_NumberTbl;
  l_PageIds            t_NumberTbl;
  l_AssocIds           t_NumberTbl;
  l_PageIndexes        t_NumberTbl;
  l_AttrGroupIds       t_NumberTbl;
  l_AttrGroupNames     t_AttrGroupNameTbl;
  l_AttrGroupTypes     t_AttrGroupTypeTbl;
  l_EntrySeqs          t_NumberTbl;
  l_PageNames          t_PageNameTbl;
  l_PageSeqs           t_NumberTbl;
  l_AssocPageIds       t_NumberTbl;
  l_TmpAttrGrpNames    t_AttrGroupNameTbl;
  l_TmpAttrGrpTypes    t_AttrGroupTypeTbl;
  l_TmpAttrGrpIds      t_NumberTbl;
  l_TmpPageNames       t_PageNameTbl;
  l_TmpPageIds         t_NumberTbl;


  --local variables
  l_attr_group_id             NUMBER;
  l_attr_group_name           VARCHAR2(30);
  l_item_catalog_group_id     NUMBER;
  l_object_id                 NUMBER;
  l_page_sequence             NUMBER;
  l_entry_sequence            NUMBER;
  l_page_name                 VARCHAR2(240);

  l_classification_code       VARCHAR2(150);
  l_attr_grp_id_list          VARCHAR2(2000);

  l_index                     NUMBER;
  l_zeroeth_assoc_exists      NUMBER;
  l_no_run                    BOOLEAN;
  l_loop_index                NUMBER;
  l_hash                      NUMBER;
  l_page_index                NUMBER;

  l_current_user_id           NUMBER := FND_GLOBAL.User_Id;
  l_current_login_id          NUMBER := FND_GLOBAL.Login_Id;
  l_sysdate                   DATE := SYSDATE;
  l_attr_group_found          BOOLEAN;
  j                           NUMBER;
  l_mssg_text                 VARCHAR2(2000);

  -- status params
  x_return_status             VARCHAR2(1);
  x_page_id                   NUMBER;
  x_association_id            NUMBER;
  x_errorcode                 VARCHAR2(1);
  x_msg_count                 NUMBER;
  x_msg_data                  VARCHAR2(2000);

  --errors
  e_exception EXCEPTION;
BEGIN
  -- check if script has already been run
  BEGIN
    --dbms_output.put_line('in run11 ');
    select 1
    into  l_zeroeth_assoc_exists
    from EGO_FND_DSC_FLX_CTX_EXT ext,
         EGO_OBJ_AG_ASSOCS_B assocs
    where assocs.classification_code = '-1'
      and assocs.object_id = (select object_id from fnd_objects where obj_name  = 'EGO_ITEM')
      and assocs.attr_group_id =ext.attr_group_id
      and ext.DESCRIPTIVE_FLEXFIELD_NAME in ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
      and ext.application_id = G_EGO_APP_ID
      and rownum<2;
    IF( l_zeroeth_assoc_exists = 1 ) THEN
      l_no_run := true;
    ELSE
      --script has already been run
      l_no_run := false;
    END IF;
    --dbms_output.put_line('in run112 ' || l_zeroeth_assoc_exists);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_no_run := false;
  END;

  IF (l_no_run = false ) THEN
    --dbms_output.put_line('in run');
    -- Since already we have decided the sequence of attribute groups hard code the values.
    -- The Entry sequence values are based on the attribute group sequence in the page.
    -- Page Indexes specifies in which page the attribute group should appear.


    --UCCnet Physical Attributes EGO_UCCNET_PHYSICAL_ATTRIBUTES
    l_PageIndexes(1) := 1;
    l_AttrGroupNames(1) :=  'Trade_Item_Description';
    l_AttrGroupTypes(1) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(1) :=  10;

    l_PageIndexes(2) := 1;
    l_AttrGroupNames(2) :=  'Trade_Item_Measurements';
    l_AttrGroupTypes(2) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(2) :=  20;

    l_PageIndexes(3) := 1;
    l_AttrGroupNames(3) :=  'Temperature_Information';
    l_AttrGroupTypes(3) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(3) :=  30;

    l_PageIndexes(4) := 1;
    l_AttrGroupNames(4) :=  'Trade_Item_Marking';
    l_AttrGroupTypes(4) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(4) :=  40;

    l_PageIndexes(5) := 1;
    l_AttrGroupNames(5) :=  'Gtin_Unit_Indicator';
    l_AttrGroupTypes(5) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(5) :=  50;

    l_PageIndexes(6) := 1;
    l_AttrGroupNames(6) :=  'Uccnet_Size_Description';
    l_AttrGroupTypes(6) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(6) :=  60;

    l_PageIndexes(7) := 1;
    l_AttrGroupNames(7) :=  'Material_Safety_Data';
    l_AttrGroupTypes(7) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(7) :=  70;

    l_PageIndexes(8) := 1;
    l_AttrGroupNames(8) :=  'Gtin_Color_Description';
    l_AttrGroupTypes(8) := 'EGO_ITEM_GTIN_MULTI_ATTRS';
    l_EntrySeqs(8) :=  80;

    l_PageIndexes(9) := 1;
    l_AttrGroupNames(9) :=  'Manufacturing_Info';
    l_AttrGroupTypes(9) := 'EGO_ITEM_GTIN_MULTI_ATTRS';
    l_EntrySeqs(9) :=  90;

    l_PageIndexes(10) := 1;
    l_AttrGroupNames(10) :=  'Country_Of_Origin';
    l_AttrGroupTypes(10) := 'EGO_ITEM_GTIN_MULTI_ATTRS';
    l_EntrySeqs(10) :=  100;


    --UCCnet Order Information   EGO_UCCNET_ORDER_INFORMATION
    l_PageIndexes(11) := 2;
    l_AttrGroupNames(11) :=  'Order_Information';
    l_AttrGroupTypes(11) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(11) :=  10;

    l_PageIndexes(12) := 2;
    l_AttrGroupNames(12) :=  'Price_Information';
    l_AttrGroupTypes(12) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(12) :=  20;

    l_PageIndexes(13) := 2;
    l_AttrGroupNames(13) :=  'Price_Date_Information';
    l_AttrGroupTypes(13) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(13) :=  30;

    l_PageIndexes(14) := 2;
    l_AttrGroupNames(14) :=  'Date_Information';
    l_AttrGroupTypes(14) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(14) :=  40;


    --UCCnet Packaging           EGO_UCCNET_PACKAGING
    l_PageIndexes(15) := 3;
    l_AttrGroupNames(15) :=  'Packaging_Marking';
    l_AttrGroupTypes(15) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(15) :=  10;

    l_PageIndexes(16) := 3;
    l_AttrGroupNames(16) :=  'Trade_Item_Hierarchy';
    l_AttrGroupTypes(16) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(16) :=  20;

    l_PageIndexes(17) := 3;
    l_AttrGroupNames(17) :=  'Bar_Code';
    l_AttrGroupTypes(17) := 'EGO_ITEM_GTIN_MULTI_ATTRS';
    l_EntrySeqs(17) :=  30;

    l_PageIndexes(18) := 3;
    l_AttrGroupNames(18) :=  'Handling_Information';
    l_AttrGroupTypes(18) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(18) :=  40;

    l_PageIndexes(19) := 3;
    l_AttrGroupNames(19) :=  'Handling_Information';
    l_AttrGroupTypes(19) := 'EGO_ITEM_GTIN_MULTI_ATTRS';
    l_EntrySeqs(19) :=  50;

    l_PageIndexes(20) := 3;
    l_AttrGroupNames(20) :=  'Security_Tag';
    l_AttrGroupTypes(20) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(20) :=  50;

    --UCCnet Hazardous           EGO_UCCNET_HAZARDOUS
    l_PageIndexes(21) := 4;
    l_AttrGroupNames(21) :=  'Hazardous_Information';
    l_AttrGroupTypes(21) := 'EGO_ITEM_GTIN_MULTI_ATTRS';
    l_EntrySeqs(21) :=  10;

    -- Bug: 4027782 - Attribute group without any pages
    l_AttrGroupNames(22) :=  'Delivery_Method_Indicator';
    l_AttrGroupTypes(22) := 'EGO_ITEM_GTIN_MULTI_ATTRS';

    l_AttrGroupNames(23) :=  'Size_Description';
    l_AttrGroupTypes(23) := 'EGO_ITEM_GTIN_MULTI_ATTRS';
    -- end Bug: 4027782

    --UCCnet Industry            EGO_UCCNET_INDUSTRY
    /*l_PageIndexes(21) := 5;
    l_AttrGroupNames(21) :=  'Uccnet_Hardlines';
    l_AttrGroupTypes(21) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(21) :=  10;*/

    /*l_PageIndexes(21) := 5;
    l_AttrGroupNames(21) :=  'TRADE_ITEM_HARMN_SYS_IDENT';
    l_AttrGroupTypes(21) := 'EGO_ITEM_GTIN_MULTI_ATTRS';
    l_EntrySeqs(21) :=  20;

    l_PageIndexes(21) := 5;
    l_AttrGroupNames(21) :=  'FMCG_MARKING';
    l_AttrGroupTypes(21) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(21) :=  30;

    l_PageIndexes(22) := 5;
    l_AttrGroupNames(22) :=  'FMCG_Measurements';
    l_AttrGroupTypes(22) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(22) :=  40;

    l_PageIndexes(23) := 5;
    l_AttrGroupNames(23) :=  'FMCG_Identification';
    l_AttrGroupTypes(23) := 'EGO_ITEM_GTIN_ATTRS';
    l_EntrySeqs(23) :=  50;*/


    -- define page order
    -- Hard code page sequence values.  Because it's not going to change.

    --UCCnet Physical Attributes EGO_UCCNET_PHYSICAL_ATTRIBUTES
    --UCCnet Order Information   EGO_UCCNET_ORDER_INFORMATION
    --UCCnet Packaging           EGO_UCCNET_PACKAGING
    --UCCnet Hazardous           EGO_UCCNET_HAZARDOUS
    --UCCnet Industry            EGO_UCCNET_INDUSTRY

    l_PageNames(1) := 'EGO_UCCNET_PHYSICAL_ATTRIBUTES';
    l_PageSeqs(1) := 10;
    l_PageNames(2) := 'EGO_UCCNET_ORDER_INFORMATION';
    l_PageSeqs(2) := 20;
    l_PageNames(3) := 'EGO_UCCNET_PACKAGING';
    l_PageSeqs(3) := 30;
    l_PageNames(4) := 'EGO_UCCNET_HAZARDOUS';
    l_PageSeqs(4) := 40;
    --l_PageNames(5) := 'EGO_UCCNET_INDUSTRY';
    --l_PageSeqs(5) := 50;

    --select all item catalog groups without parents
    l_CatalogGroupIds(1) := -1;

    -- Do a bulk collect for catalog groups without parent and without any UCCnet associations
    SELECT mi.item_catalog_group_id
      BULK COLLECT INTO l_CatalogGroupIds
    FROM mtl_item_catalog_groups_b mi
    WHERE mi.parent_catalog_group_id IS NULL
      AND NOT EXISTS
           (SELECT oa.attr_group_id
            FROM ego_obj_ag_assocs_b oa,
                 ego_attr_groups_v eag
            WHERE oa.classification_code = mi.item_catalog_group_id
              AND oa.attr_group_id = eag.attr_group_id
              AND eag.attr_group_type IN ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS'));

    l_CatalogGroupIds(l_CatalogGroupIds.count +1) := -1;
    l_object_id := EGO_EXT_FWK_PUB.Get_Object_Id_From_Name (p_object_name => G_ITEM_OBJECT_NAME) ;

    --dbms_output.put_line('after selecting all catalogs');
    -- Since same attribute group names are used for all catalog groups fetch it before
    -- looping through catalog groups.
    SELECT ATTR_GROUP_ID, DESCRIPTIVE_FLEX_CONTEXT_CODE, DESCRIPTIVE_FLEXFIELD_NAME
      BULK COLLECT INTO l_TmpAttrGrpIds, l_TmpAttrGrpNames, l_TmpAttrGrpTypes
    FROM EGO_FND_DSC_FLX_CTX_EXT
    -- Attribute Group Type
    WHERE DESCRIPTIVE_FLEXFIELD_NAME in ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
      AND application_id = G_EGO_APP_ID
      -- Attribute Group Name
      AND DESCRIPTIVE_FLEX_CONTEXT_CODE IN
                                         (  'Trade_Item_Description'
                                          , 'Trade_Item_Measurements'
                                          , 'Temperature_Information'
                                          , 'Trade_Item_Marking'
                                          , 'Gtin_Unit_Indicator'
                                          , 'Uccnet_Size_Description'
                                          , 'Material_Safety_Data'
                                          , 'Gtin_Color_Description'
                                          , 'Manufacturing_Info'
                                          , 'Country_Of_Origin'
                                          , 'Order_Information'
                                          , 'Price_Information'
                                          , 'Price_Date_Information'
                                          , 'Date_Information'
                                          , 'Packaging_Marking'
                                          , 'Trade_Item_Hierarchy'
                                          , 'Bar_Code'
                                          , 'Handling_Information'
                                          , 'Hazardous_Information'
                                          , 'Size_Description' -- Bug: 4027782
                                          , 'Delivery_Method_Indicator' -- Bug: 4027782
                                          , 'Security_Tag'
                                         --  , 'Uccnet_Hardlines'
                                         --  , 'TRADE_ITEM_HARMN_SYS_IDENT'
                                         --  , 'FMCG_MARKING'
                                         --  , 'FMCG_Measurements'
                                         --  , 'FMCG_Identification'
                                         );
    --dbms_output.put_line('after selecting attr group ids');

    -- Fetching can be in any order. So populate the attribute group ids based on the sequence
    -- by performing linear search.
    FOR i IN l_AttrGroupNames.FIRST..l_AttrGroupNames.LAST LOOP
      j := 1;
      l_attr_group_found := FALSE;
      WHILE NOT l_attr_group_found LOOP
        IF  (l_AttrGroupNames(i) = l_TmpAttrGrpNames(j) AND l_AttrGroupTypes(i) = l_TmpAttrGrpTypes(j)) THEN
             l_AttrGroupIds(i) := l_TmpAttrGrpIds(j);
             l_attr_group_found := TRUE;
        END IF;
        j := j + 1;
      END LOOP;
    END LOOP;
    --dbms_output.put_line('after setting attr group ids');
    --dbms_output.put_line('l_CatalogGroupIds count' || l_CatalogGroupIds.count);
    -- create default operational attribute pages for each item catalog category without a parent
    FOR l_loop_index IN l_CatalogGroupIds.FIRST..l_CatalogGroupIds.LAST
    LOOP
      l_item_catalog_group_id := l_CatalogGroupIds(l_loop_index);
      --dbms_output.put_line('getting l_item_catalog_group_id' || l_item_catalog_group_id);
      -- Tables uses classification_code which is varchar2 column.  So type cast catalog group id.
      l_classification_code := TO_CHAR(l_item_catalog_group_id);

      BEGIN
        -- get the sequence for this page
        l_page_sequence := 0;
        BEGIN
          SELECT max(sequence) INTO  l_page_sequence
          FROM EGO_PAGES_B
          WHERE object_id = l_object_id
            AND classification_code = l_classification_code;

          IF( l_page_sequence IS NULL ) THEN
            l_page_sequence := 0;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           l_page_sequence := 0;
        END;

        -- We have to create all 5 pages for this catalog group.
        -- Perform bulk insert for these 5 pages.
        FORALL i IN l_PageNames.FIRST..l_PageNames.LAST
          INSERT INTO EGO_PAGES_B
          (
            PAGE_ID
           ,OBJECT_ID
           ,CLASSIFICATION_CODE
           ,DATA_LEVEL
           ,INTERNAL_NAME
           ,SEQUENCE
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
          )
          SELECT EGO_PAGES_S.NEXTVAL
                ,l_object_id
                ,l_classification_code
                ,G_ITEM_LEVEL
                ,l_PageNames(i)
                ,l_PageSeqs(i) + l_page_sequence
                ,l_sysdate
                ,l_current_user_id
                ,l_sysdate
                ,l_current_user_id
                ,L_current_login_id
            FROM DUAL
           WHERE NOT EXISTS (
                  SELECT *
                    FROM EGO_PAGES_V
                   WHERE CLASSIFICATION_CODE = l_classification_code
                     AND INTERNAL_NAME = l_PageNames(i)
                 );

        --dbms_output.put_line('after inserting pages');

        -- TL table requires Page_Id, so perform bulk collect to get page ids for
        -- the inserted pages.
        SELECT page_id, internal_name
        BULK COLLECT INTO l_TmpPageIds, l_TmpPageNames
        FROM EGO_PAGES_B
        WHERE OBJECT_ID = l_object_id
          AND CLASSIFICATION_CODE = l_classification_code
          AND SEQUENCE > l_page_sequence -- Need to get only newly inserted rows
        ORDER BY SEQUENCE; -- Make sure to get it in the order in which have been inserted

        l_PageIds.DELETE;
        -- Associate the correct page IDs with the correct index
        IF (l_TmpPageIds.COUNT > 0) THEN
          FOR i IN l_TmpPageIds.FIRST..l_TmpPageIds.LAST
          LOOP
            FOR j IN l_PageNames.FIRST..l_PageNames.LAST
            LOOP
              IF (l_TmpPageNames(i) = l_PageNames(j)) THEN
                l_PageIds(j) := l_TmpPageIds(i);
                EXIT;
              END IF;
            END LOOP;
          END LOOP;
        END IF;

        -- ensure there are actually pages to insert into the TL table
        IF (l_PageIds.COUNT > 0) THEN
          -- Perform bulk insert for TL table.
          FOR i IN l_PageIds.FIRST..l_PageIds.LAST
          LOOP
            SELECT message_text
              INTO l_mssg_text
            FROM fnd_new_messages
            WHERE message_name = l_PageNames(i)
              AND application_id = G_EGO_APP_ID
              AND language_code = USERENV('LANG');
            --dbms_output.put_line('inserting...');
            INSERT INTO EGO_PAGES_TL
            (
              PAGE_ID
             ,DISPLAY_NAME
             ,LANGUAGE
             ,SOURCE_LANG
             ,CREATION_DATE
             ,CREATED_BY
             ,LAST_UPDATE_DATE
             ,LAST_UPDATED_BY
             ,LAST_UPDATE_LOGIN
            )
            SELECT
              l_PageIds(i)
             ,l_mssg_text
             ,L.LANGUAGE_CODE
             ,USERENV('LANG')
             ,l_Sysdate
             ,l_current_user_id
             ,l_Sysdate
             ,l_current_user_id
             ,l_current_login_id
            FROM FND_LANGUAGES L
            WHERE L.INSTALLED_FLAG in ('I', 'B');

          END LOOP;
        END IF;

        --dbms_output.put_line('after inserting tl pages');
        -- Create Page Association
        -- For each (total 15) attribute group create an association with the current catalog group.
        FORALL i IN l_AttrGroupIds.FIRST..l_AttrGroupIds.LAST
          INSERT INTO EGO_OBJ_AG_ASSOCS_B
          (
            ASSOCIATION_ID
           ,OBJECT_ID
           ,CLASSIFICATION_CODE
           ,DATA_LEVEL
           ,ATTR_GROUP_ID
           ,ENABLED_FLAG
           ,VIEW_PRIVILEGE_ID
           ,EDIT_PRIVILEGE_ID
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
          )
          VALUES
          (
            EGO_ASSOCS_S.NEXTVAL
           ,l_object_id
           ,l_classification_code
           ,G_ITEM_LEVEL
           ,l_AttrGroupIds(i)
           ,'Y'
           ,to_number(NULL)
           ,to_number(NULL)
           ,l_Sysdate
           ,l_current_user_id
           ,l_Sysdate
           ,l_current_user_id
           ,l_current_login_id
          );

        --dbms_output.put_line('after inserting assocs');
        -- Bulk fetch the association ids for the association which have created.
        l_attr_grp_id_list :='';
        FOR i IN l_AttrGroupIds.FIRST..l_AttrGroupIds.LAST
        LOOP
          l_attr_grp_id_list :=  l_attr_grp_id_list || l_AttrGroupIds(i);

          IF (i <> l_AttrGroupIds.count) THEN
            l_attr_grp_id_list :=  l_attr_grp_id_list || ',';
          END IF;
        END LOOP;

        --dbms_output.put_line('after getting attr grp id list ' || l_attr_grp_id_list);

        SELECT ASSOCIATION_ID -- , ATTR_GROUP_ID
        BULK COLLECT INTO l_AssocIds --, l_AttrGroupIds
        FROM EGO_OBJ_AG_ASSOCS_B
        WHERE OBJECT_ID = l_object_id
          AND CLASSIFICATION_CODE = l_classification_code
          and ATTR_GROUP_ID in (SELECT ATTR_GROUP_ID  FROM EGO_FND_DSC_FLX_CTX_EXT
                                WHERE DESCRIPTIVE_FLEXFIELD_NAME in ('EGO_ITEM_GTIN_ATTRS', 'EGO_ITEM_GTIN_MULTI_ATTRS')
                                 AND application_id = G_EGO_APP_ID
                                 AND DESCRIPTIVE_FLEX_CONTEXT_CODE IN
                                     (  'Trade_Item_Description'
                                      , 'Trade_Item_Measurements'
                                      , 'Temperature_Information'
                                      , 'Trade_Item_Marking'
                                      , 'Gtin_Unit_Indicator'
                                      , 'Uccnet_Size_Description'
                                      , 'Material_Safety_Data'
                                      , 'Gtin_Color_Description'
                                      , 'Manufacturing_Info'
                                      , 'Country_Of_Origin'
                                      , 'Order_Information'
                                      , 'Price_Information'
                                      , 'Price_Date_Information'
                                      , 'Date_Information'
                                      , 'Packaging_Marking'
                                      , 'Trade_Item_Hierarchy'
                                      , 'Bar_Code'
                                      , 'Handling_Information'
                                      , 'Hazardous_Information'
                                      , 'Security_Tag'
                                      --, 'Uccnet_Hardlines'
                                      --, 'TRADE_ITEM_HARMN_SYS_IDENT'
                                      --, 'FMCG_MARKING'
                                      --, 'FMCG_Measurements'
                                      --, 'FMCG_Identification'
                                      ))
        ORDER BY ASSOCIATION_ID;

        --dbms_output.put_line('after getting assoc ids');
        -- Populate l_AssocPageIds with page id to which the attribute group belongs to.
        FOR i IN l_PageIndexes.FIRST..l_PageIndexes.LAST
        LOOP
          BEGIN
            l_AssocPageIds(i) := l_PageIds(l_PageIndexes(i));
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- if no page ID can be found, then skip the page entry.
              NULL;
          END;
        END LOOP;

        --dbms_output.put_line('after getting page ids');
        -- Perform Bulk insert and create page entries for each association.
        --dbms_output.put_line('assoc cound -' || l_AssocIds.count);
        FORALL i IN l_AssocIds.FIRST..l_AssocIds.LAST
          INSERT INTO EGO_PAGE_ENTRIES_B
          (
            PAGE_ID
           ,ASSOCIATION_ID
           ,SEQUENCE
           ,CLASSIFICATION_CODE
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
          )
          VALUES
          (
            l_AssocPageIds(i)
           ,l_AssocIds(i)
           ,l_EntrySeqs(i)
           ,l_classification_code
           ,l_Sysdate
           ,l_current_user_id
           ,l_Sysdate
           ,l_current_user_id
           ,l_current_login_id
          );
          --dbms_output.put_line('after inserting page entries for classification' || l_classification_code);

          --EXCEPTION
          -- WHEN OTHERS THEN
          --   ROLLBACK;
      END;
    END LOOP; -- for all item catalog categories w/o parents and w/o UCCnet attr groups
    COMMIT; -- Commit only after processing all the catalog groups.
  END IF;  --check if script has already run

END Seed_Uccnet_Attributes_Pages;

FUNCTION Is_In_Sync_Customer
    ( p_inventory_item_id      IN NUMBER
    , p_org_id                 IN NUMBER
    , p_address_id             IN NUMBER
    , p_explode_group_id       IN NUMBER
    ) RETURN VARCHAR2
IS
   l_result VARCHAR2(1);
BEGIN
   SELECT 'Y' INTO l_result
   FROM DUAL
   WHERE NOT EXISTS
   (
   SELECT
       1
   FROM EGO_UCCNET_EVENTS EV1
   WHERE INVENTORY_ITEM_ID = p_inventory_item_id
       AND ORGANIZATION_ID = p_org_id
       AND ADDRESS_ID = p_address_id
       AND EVENT_TYPE = 'PUBLICATION'
       AND PARENT_GTIN = 0
       AND
       (
           DISPOSITION_CODE IS NULL
           OR
           (
               EVENT_ACTION IN ('NEW_ITEM', 'INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION')
               AND DISPOSITION_CODE = 'REJECTED'
           )
           OR
           (
               EVENT_ACTION = 'DE_LIST'
               AND DISPOSITION_CODE <> 'FAILED'
           )
           OR
           (
               EVENT_ACTION = 'WITHDRAW'
               AND DISPOSITION_CODE <> 'FAILED'
               AND NOT EXISTS
               (
               SELECT
                   1
               FROM EGO_UCCNET_EVENTS
               WHERE INVENTORY_ITEM_ID = p_inventory_item_id
                   AND ORGANIZATION_ID = p_org_id
                   AND ADDRESS_ID = p_address_id
                   AND EVENT_TYPE = 'PUBLICATION'
                   AND PARENT_GTIN = 0
                   AND EVENT_ROW_ID > EV1.EVENT_ROW_ID
                   AND DISPOSITION_CODE <> 'FALIED'
               )
           )
       )
   )
   AND EXISTS
   (
   SELECT
       1
   FROM EGO_ITEM_GTN_ATTRS_B EGA,
       BOM_EXPLOSIONS_ALL_V EXPL
   WHERE EXPL.GROUP_ID = p_explode_group_id
       AND EXPL.TOP_ITEM_ID = p_inventory_item_id
       AND EXPL.ORGANIZATION_ID = EGA.ORGANIZATION_ID
       AND EXPL.COMPONENT_ITEM_ID = EGA.INVENTORY_ITEM_ID
       AND TP_NEUTRAL_UPDATE_DATE >
       (
       SELECT
           MAX(CREATION_DATE)
       FROM EGO_UCCNET_EVENTS
       WHERE INVENTORY_ITEM_ID = p_inventory_item_id
           AND ORGANIZATION_ID = p_org_id
           AND ADDRESS_ID = p_address_id
           AND EVENT_TYPE = 'PUBLICATION'
           AND PARENT_GTIN = 0
           AND EVENT_ACTION IN ('NEW_ITEM', 'INITIAL_LOAD', 'DATA_CHANGE', 'CORRECTION')
           AND DISPOSITION_CODE IN ('PROCESSED', 'ACCEPTED', 'REVIEW', 'SYNCHRONIZED')
       )
   );
   RETURN l_result;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN 'N';
  WHEN OTHERS THEN
       RETURN 'N';
END Is_In_Sync_Customer;

  FUNCTION Get_Attr_Display_Name(p_attr_group_type VARCHAR2,
                                 p_attr_group_name VARCHAR2,
                                 p_attr_name       VARCHAR2)
  RETURN VARCHAR2 IS
    l_disp_name VARCHAR2(4000);
  BEGIN
    SELECT TL.FORM_LEFT_PROMPT ATTR_DISPLAY_NAME
    INTO l_disp_name
    FROM FND_DESCR_FLEX_COLUMN_USAGES FL_COL ,FND_DESCR_FLEX_COL_USAGE_TL TL
    WHERE FL_COL.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
      AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
      AND FL_COL.APPLICATION_ID = 431
      AND FL_COL.END_USER_COLUMN_NAME = p_attr_name
      AND FL_COL.APPLICATION_ID = TL.APPLICATION_ID
      AND FL_COL.DESCRIPTIVE_FLEXFIELD_NAME = TL.DESCRIPTIVE_FLEXFIELD_NAME
      AND FL_COL.DESCRIPTIVE_FLEX_CONTEXT_CODE = TL.DESCRIPTIVE_FLEX_CONTEXT_CODE
      AND FL_COL.APPLICATION_COLUMN_NAME = TL.APPLICATION_COLUMN_NAME
      AND TL.LANGUAGE = USERENV('LANG');

    RETURN l_disp_name;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN p_attr_name;
  END Get_Attr_Display_Name;

  /*
   * This method returns the page_id and page_display_name for the attribute group
   */
  PROCEDURE Get_Associated_Page_Details(p_catalog_group_id       NUMBER,
                                        p_attr_group_type        VARCHAR2,
                                        p_attr_group_name        VARCHAR2,
                                        x_page_id            OUT NOCOPY NUMBER,
                                        x_page_display_name  OUT NOCOPY VARCHAR2)
  IS
    l_page_id         NUMBER;
    l_page_disp_name  VARCHAR2(4000);
  BEGIN
    SELECT PT.PAGE_ID, PT.DISPLAY_NAME
    INTO l_page_id, l_page_disp_name
    FROM EGO_FND_DSC_FLX_CTX_EXT EXT, EGO_OBJ_AG_ASSOCS_B ASOC, EGO_PAGE_ENTRIES_B PGE, EGO_PAGES_TL PT
    WHERE EXT.ATTR_GROUP_ID = ASOC.ATTR_GROUP_ID
      AND EXT.APPLICATION_ID = 431
      AND EXT.DESCRIPTIVE_FLEXFIELD_NAME = p_attr_group_type
      AND EXT.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_attr_group_name
      AND ASOC.OBJECT_ID = (SELECT OBJECT_ID FROM FND_OBJECTS WHERE OBJ_NAME = 'EGO_ITEM')
      AND ASOC.CLASSIFICATION_CODE = p_catalog_group_id
      AND ASOC.ASSOCIATION_ID = PGE.ASSOCIATION_ID
      AND ASOC.CLASSIFICATION_CODE = PGE.CLASSIFICATION_CODE
      AND PGE.PAGE_ID = PT.PAGE_ID
      AND PT.LANGUAGE = USERENV('LANG')
      AND ROWNUM = 1;

    x_page_id := l_page_id;
    x_page_display_name := l_page_disp_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_page_id := -1;
      x_page_display_name := NULL;
  END Get_Associated_Page_Details;

  /*
   * This method validates SBDH attributes. if p_address_id is null then only item level attributes
   * are validated.
   * Returns a data object containing all errors
   */
  PROCEDURE Validate_SBDH_Attributes(p_inventory_item_id       NUMBER,
                                     p_organization_id         NUMBER,
                                     p_address_id              NUMBER,
                                     p_errors              OUT NOCOPY REF_CURSOR_TYPE)
  IS
    l_start_date        DATE;
    l_end_date          DATE;
    l_start_date1       DATE;
    l_end_date1         DATE;
    l_min_value         NUMBER;
    l_max_value         NUMBER;
    l_attr_value        NUMBER;
    l_attr_value_uom    VARCHAR2(10);
    l_attr1_value       NUMBER;
    l_attr1_value_uom   VARCHAR2(10);

    l_sql               VARCHAR2(15000);
    l_error_rec         SYSTEM.EGO_PAGEWISE_ERROR_REC;
    l_error_table       SYSTEM.EGO_PAGEWISE_ERROR_TABLE;
    l_unexp_err         VARCHAR2(4000);
    l_attr1_name        VARCHAR2(4000);
    l_attr2_name        VARCHAR2(4000);
    l_attr3_name        VARCHAR2(4000);
    l_peg_hole_number   NUMBER;
    l_peg_vertical      NUMBER;
    l_peg_horizontal    NUMBER;
    l_catalog_group_id  NUMBER;
    l_party_site_id     NUMBER;
    l_page_id           NUMBER;
    l_page_display_name VARCHAR2(4000);
    l_do_tp_validations BOOLEAN;

    TYPE ref_cursor_type IS REF CURSOR;
    c_ref_cursor        ref_cursor_type;

    column_not_found    EXCEPTION;
    PRAGMA EXCEPTION_INIT(column_not_found, -904);
  BEGIN
    l_error_table := SYSTEM.EGO_PAGEWISE_ERROR_TABLE();
    l_error_rec   := SYSTEM.EGO_PAGEWISE_ERROR_REC(NULL, '', '', '');

    BEGIN
      SELECT ITEM_CATALOG_GROUP_ID INTO l_catalog_group_id
      FROM MTL_SYSTEM_ITEMS_B
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id;
    EXCEPTION WHEN OTHERS THEN
      l_error_table.EXTEND;
      l_error_rec.PAGE_ID := -1;
      l_error_rec.ERROR_MESSAGE := SQLERRM;
      l_error_table(l_error_table.LAST) := l_error_rec;
      OPEN p_errors FOR
        SELECT *
        FROM TABLE( CAST(l_error_table AS SYSTEM.EGO_PAGEWISE_ERROR_TABLE) );
      RETURN;
    END;

    IF p_address_id IS NULL THEN
      l_do_tp_validations := FALSE;
    ELSE
      l_do_tp_validations := TRUE;
    END IF;

    IF l_do_tp_validations THEN
      -- validating address_id
      BEGIN
        SELECT PARTY_SITE_ID INTO l_party_site_id
        FROM HZ_CUST_ACCT_SITES_ALL
        WHERE CUST_ACCT_SITE_ID = p_address_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_error_table.EXTEND;
          l_error_rec.PAGE_ID := -1;
          l_error_rec.ERROR_MESSAGE := 'Unexpected Error: Invalid Address_ID - '||TO_CHAR(p_address_id);
          l_error_rec.ERROR_LEVEL := 'C';
          l_error_table(l_error_table.LAST) := l_error_rec;
          OPEN p_errors FOR
            SELECT *
            FROM TABLE( CAST(l_error_table AS SYSTEM.EGO_PAGEWISE_ERROR_TABLE) );
          RETURN;
        WHEN OTHERS THEN
          l_error_table.EXTEND;
          l_error_rec.PAGE_ID := -1;
          l_error_rec.ERROR_MESSAGE := 'Error while validating address: ' || SQLERRM;
          l_error_rec.ERROR_LEVEL := 'C';
          l_error_table(l_error_table.LAST) := l_error_rec;
          OPEN p_errors FOR
            SELECT *
            FROM TABLE( CAST(l_error_table AS SYSTEM.EGO_PAGEWISE_ERROR_TABLE) );
          RETURN;
      END;
    END IF; -- IF l_do_tp_validations THEN

    -- validating first the attributes that are not TP-Dependant
    -- 1. DEPOSIT_VALUE_EFFECTIVE_DATE can not be greater than DEPOSIT_VALUE_END_DATE
    BEGIN
      l_sql := ' SELECT DEPOSIT_VALUE_EFFECTIVE_DATE, DEPOSIT_VALUE_END_DATE ' ||
               ' FROM EGO_SBDH_DEP_VAL_DATE_INFO_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date USING p_inventory_item_id, p_organization_id;

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_DEP_VAL_DATE_INFO', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_DEP_VAL_DATE_INFO', 'DEPOSIT_VALUE_EFFECTIVE_DATE');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_DEP_VAL_DATE_INFO', 'DEPOSIT_VALUE_END_DATE');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_DEP_VAL_DATE_INFO - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 2. CAMPAIGN_START_DATE can not be greater than CAMPAIGN_END_DATE
    BEGIN
      l_sql := ' SELECT CAMPAIGN_START_DATE, CAMPAIGN_END_DATE ' ||
               ' FROM EGO_SBDH_CAMPAIGN_INFO_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date USING p_inventory_item_id, p_organization_id;

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_CAMPAIGN_INFO', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_CAMPAIGN_INFO', 'CAMPAIGN_START_DATE');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_CAMPAIGN_INFO', 'CAMPAIGN_END_DATE');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_CAMPAIGN_INFO - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 3. SEASONAL_AVL_START_DATE can not be greater than SEASONAL_AVL_END_DATE
    BEGIN
      l_sql := ' SELECT SEASONAL_AVL_START_DATE, SEASONAL_AVL_END_DATE ' ||
               ' FROM EGO_SBDH_SEASON_AVL_DATE_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date USING p_inventory_item_id, p_organization_id;

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_SEASON_AVL_DATE', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_SEASON_AVL_DATE', 'SEASONAL_AVL_START_DATE');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_SEASON_AVL_DATE', 'SEASONAL_AVL_END_DATE');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_SEASON_AVL_DATE - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 4. STORAGE_HNDLNG_HUMDTY_MIN can not be greater than STORAGE_HNDLNG_HUMDTY_MAX
    --    this is a multi-row attribute group, so using ref cursor.
    BEGIN
      l_page_id := -99;
      l_page_display_name := NULL;

      l_sql := ' SELECT STORAGE_HNDLNG_HUMDTY_MIN, STORAGE_HNDLNG_HUMDTY_MAX ' ||
               ' FROM EGO_SBDH_STRG_HNDLG_HMDTY_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      OPEN c_ref_cursor FOR l_sql USING p_inventory_item_id, p_organization_id;
      LOOP
        FETCH c_ref_cursor INTO l_min_value, l_max_value;
        EXIT WHEN c_ref_cursor%NOTFOUND;

        IF l_min_value > l_max_value THEN
          IF l_page_id = -99 THEN
            Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', l_page_id, l_page_display_name);
          END IF;
          l_error_table.EXTEND;
          l_error_rec.PAGE_ID := l_page_id;
          l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
          FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
          l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', 'STORAGE_HNDLNG_HUMDTY_MIN');
          l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', 'STORAGE_HNDLNG_HUMDTY_MAX');
          FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
          FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
          l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
          l_error_rec.ERROR_LEVEL := 'I';
          l_error_table(l_error_table.LAST) := l_error_rec;
        END IF;
      END LOOP;
      CLOSE c_ref_cursor;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
      WHEN OTHERS THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        l_unexp_err := 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 5. pegHorizontal, pegVertical and pegHoleNumber should be specified when either of them is specified.
    BEGIN
      l_sql := ' SELECT sbdh.PEG_HOLE_NUMBER, core.PEG_VERTICAL, core.PEG_HORIZONTAL ' ||
               ' FROM EGO_SBDH_TRADE_ITEM_INFO_AGV sbdh, EGO_ITEM_GTN_ATTRS_B core ' ||
               ' WHERE core.INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND core.ORGANIZATION_ID = :p_organization_id ' ||
               '   AND sbdh.INVENTORY_ITEM_ID (+) = core.INVENTORY_ITEM_ID ' ||
               '   AND sbdh.ORGANIZATION_ID (+) = core.ORGANIZATION_ID ';
      EXECUTE IMMEDIATE l_sql INTO l_peg_hole_number, l_peg_vertical, l_peg_horizontal USING p_inventory_item_id, p_organization_id;

      IF l_peg_hole_number IS NOT NULL AND (l_peg_vertical IS NULL OR l_peg_horizontal IS NULL) OR
         l_peg_vertical IS NOT NULL AND (l_peg_hole_number IS NULL OR l_peg_horizontal IS NULL) OR
         l_peg_horizontal IS NOT NULL AND (l_peg_hole_number IS NULL OR l_peg_vertical IS NULL)
      THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_TRADE_ITEM_INFO', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_3ATTRS_MUST_COEXIST');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_TRADE_ITEM_INFO', 'PEG_HOLE_NUMBER');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEM_GTIN_ATTRS', 'Trade_Item_Measurements', 'Peg_Horizontal');
        l_attr3_name := Get_Attr_Display_Name('EGO_ITEM_GTIN_ATTRS', 'Trade_Item_Measurements', 'Peg_Vertical');
        FND_MESSAGE.SET_TOKEN('ATTR1', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('ATTR2', l_attr2_name);
        FND_MESSAGE.SET_TOKEN('ATTR3', l_attr3_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_TRADE_ITEM_INFO - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- validating that UOM values and class are present
    -- 6. UOM for PRICE_COMPARISON_MSRMNT must be present if PRICE_COMPARISON_MSRMNT is present
    BEGIN
      l_page_id := -99;
      l_page_display_name := NULL;

      l_sql := ' SELECT PRICE_COMPARISON_MSRMNT, PRICE_COMPARISON_MSRMNT_UUOM ' ||
               ' FROM EGO_SBDH_PRC_CMPRSN_MSRMT_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id ';
      OPEN c_ref_cursor FOR l_sql USING p_inventory_item_id, p_organization_id;
      LOOP
        FETCH c_ref_cursor INTO l_attr_value, l_attr_value_uom;
        EXIT WHEN c_ref_cursor%NOTFOUND;

        IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
          IF l_page_id = -99 THEN
            Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_PRC_CMPRSN_MSRMT', l_page_id, l_page_display_name);
          END IF;
          l_error_table.EXTEND;
          l_error_rec.PAGE_ID := l_page_id;
          l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
          FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_REQD');
          l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_PRC_CMPRSN_MSRMT', 'PRICE_COMPARISON_MSRMNT');
          FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
          l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
          l_error_rec.ERROR_LEVEL := 'I';
          l_error_table(l_error_table.LAST) := l_error_rec;
        END IF;
      END LOOP;
      CLOSE c_ref_cursor;
    EXCEPTION
      WHEN column_not_found THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_PRC_CMPRSN_MSRMT', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_CLASS_REQD');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_PRC_CMPRSN_MSRMT', 'PRICE_COMPARISON_MSRMNT');
        FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      WHEN NO_DATA_FOUND THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
      WHEN OTHERS THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        l_unexp_err := 'EGOINT_GDSN_PRC_CMPRSN_MSRMT - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 7. UOM for TRADE_ITEM_COMPOSTN_WIDTH must be present if TRADE_ITEM_COMPOSTN_WIDTH is present
    BEGIN
      l_sql := ' SELECT TRADE_ITEM_COMPOSTN_WIDTH, TRADE_ITEM_COMPOSTN_WIDTH_UUOM ' ||
               ' FROM EGO_SBDH_TRADE_ITEM_INFO_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id ';
      EXECUTE IMMEDIATE l_sql INTO l_attr_value, l_attr_value_uom USING p_inventory_item_id, p_organization_id;

      IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_TRADE_ITEM_INFO', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_REQD');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_TRADE_ITEM_INFO', 'TRADE_ITEM_COMPOSTN_WIDTH');
        FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN column_not_found THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_TRADE_ITEM_INFO', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_CLASS_REQD');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_TRADE_ITEM_INFO', 'TRADE_ITEM_COMPOSTN_WIDTH');
        FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_TRADE_ITEM_INFO - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 8. UOM for MATERIAL_WEIGHT must be present if MATERIAL_WEIGHT is present
    BEGIN
      l_sql := ' SELECT MATERIAL_WEIGHT, MATERIAL_WEIGHT_UUOM ' ||
               ' FROM EGO_SBDH_MATERIAL_INFO_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id ';
      EXECUTE IMMEDIATE l_sql INTO l_attr_value, l_attr_value_uom USING p_inventory_item_id, p_organization_id;

      IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_MATERIAL_INFO', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_REQD');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_MATERIAL_INFO', 'MATERIAL_WEIGHT');
        FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN column_not_found THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_MATERIAL_INFO', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_CLASS_REQD');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_MATERIAL_INFO', 'MATERIAL_WEIGHT');
        FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_MATERIAL_INFO - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 9. UOM for STORAGE_HNDLNG_HUMDTY_MIN, STORAGE_HNDLNG_HUMDTY_MAX must be present if value os present
    --    this is a multi-row attribute group, so using ref cursor.
    BEGIN
      l_page_id := -99;
      l_page_display_name := NULL;

      l_sql := ' SELECT STORAGE_HNDLNG_HUMDTY_MIN, STORAGE_HNDLNG_HUMDTY_MAX, STORAGE_HNDLNG_HUMDTY_MIN_UUOM, STORAGE_HNDLNG_HUMDTY_MAX_UUOM ' ||
               ' FROM EGO_SBDH_STRG_HNDLG_HMDTY_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      OPEN c_ref_cursor FOR l_sql USING p_inventory_item_id, p_organization_id;
      LOOP
        FETCH c_ref_cursor INTO l_attr_value, l_attr1_value, l_attr_value_uom, l_attr1_value_uom;
        EXIT WHEN c_ref_cursor%NOTFOUND;

        -- checking for STORAGE_HNDLNG_HUMDTY_MIN
        IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
          IF l_page_id = -99 THEN
            Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', l_page_id, l_page_display_name);
          END IF;
          l_error_table.EXTEND;
          l_error_rec.PAGE_ID := l_page_id;
          l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
          FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_REQD');
          l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', 'STORAGE_HNDLNG_HUMDTY_MIN');
          FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
          l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
          l_error_rec.ERROR_LEVEL := 'I';
          l_error_table(l_error_table.LAST) := l_error_rec;
        END IF;

        -- checking for STORAGE_HNDLNG_HUMDTY_MAX
        IF l_attr1_value IS NOT NULL AND l_attr1_value_uom IS NULL THEN
          IF l_page_id = -99 THEN
            Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', l_page_id, l_page_display_name);
          END IF;
          l_error_table.EXTEND;
          l_error_rec.PAGE_ID := l_page_id;
          l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
          FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_REQD');
          l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', 'STORAGE_HNDLNG_HUMDTY_MAX');
          FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
          l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
          l_error_rec.ERROR_LEVEL := 'I';
          l_error_table(l_error_table.LAST) := l_error_rec;
        END IF;
      END LOOP;
      CLOSE c_ref_cursor;
    EXCEPTION
      WHEN column_not_found THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_CLASS_REQD2');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', 'STORAGE_HNDLNG_HUMDTY_MIN');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY', 'STORAGE_HNDLNG_HUMDTY_MAX');
        FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('ATTR1_NAME', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
      WHEN NO_DATA_FOUND THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
      WHEN OTHERS THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        l_unexp_err := 'EGOINT_GDSN_STRG_HNDLG_HUMIDTY - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        l_error_rec.ERROR_LEVEL := 'I';
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- validating TP-Dependant attributes
    -- 10. AGREED_MINIMUM_BUYING_QTY can not be more than AGREED_MAXIMUM_BUYING_QTY
    -- 11. START_DATE_MINIMUM_BUYING_QTY can not be more than END_DATE_MINIMUM_BUYING_QTY
    -- 12. START_DATE_MAXIMUM_BUYING_QTY can not be more than END_DATE_MAXIMUM_BUYING_QTY
    BEGIN
      l_page_id := -99;
      l_page_display_name := NULL;

      IF l_do_tp_validations THEN
        l_sql := ' SELECT  AGREED_MINIMUM_BUYING_QTY, ' ||
                 '         AGREED_MAXIMUM_BUYING_QTY, ' ||
                 '         START_DATE_MINIMUM_BUYING_QTY, ' ||
                 '         END_DATE_MINIMUM_BUYING_QTY, ' ||
                 '         START_DATE_MAXIMUM_BUYING_QTY, ' ||
                 '         END_DATE_MAXIMUM_BUYING_QTY ' ||
                 ' FROM EGO_SBDH_BUYING_QTY_INFO_TPV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_BUYING_QTY_INFO_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';
        EXECUTE IMMEDIATE l_sql INTO l_min_value, l_max_value, l_start_date, l_end_date, l_start_date1, l_end_date1
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT  AGREED_MINIMUM_BUYING_QTY, ' ||
                 '         AGREED_MAXIMUM_BUYING_QTY, ' ||
                 '         START_DATE_MINIMUM_BUYING_QTY, ' ||
                 '         END_DATE_MINIMUM_BUYING_QTY, ' ||
                 '         START_DATE_MAXIMUM_BUYING_QTY, ' ||
                 '         END_DATE_MAXIMUM_BUYING_QTY ' ||
                 ' FROM EGO_SBDH_BUYING_QTY_INFO_AGV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';
        EXECUTE IMMEDIATE l_sql INTO l_min_value, l_max_value, l_start_date, l_end_date, l_start_date1, l_end_date1
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      -- 10. AGREED_MINIMUM_BUYING_QTY can not be more than AGREED_MAXIMUM_BUYING_QTY
      IF l_min_value > l_max_value THEN
        l_error_table.EXTEND;
        IF l_page_id = -99 THEN
          IF l_do_tp_validations THEN
            l_error_rec.ERROR_LEVEL := 'C';
            l_page_id := -1;
          ELSE
            Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', l_page_id, l_page_display_name);
            l_error_rec.ERROR_LEVEL := 'I';
          END IF; -- IF l_do_tp_validations THEN
        END IF;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', 'AGREED_MINIMUM_BUYING_QTY');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', 'AGREED_MAXIMUM_BUYING_QTY');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;

      -- 11. START_DATE_MINIMUM_BUYING_QTY can not be more than END_DATE_MINIMUM_BUYING_QTY
      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        l_error_table.EXTEND;
        IF l_page_id = -99 THEN
          IF l_do_tp_validations THEN
            l_error_rec.ERROR_LEVEL := 'C';
            l_page_id := -1;
          ELSE
            Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', l_page_id, l_page_display_name);
            l_error_rec.ERROR_LEVEL := 'I';
          END IF; --IF l_do_tp_validations THEN
        END IF;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', 'START_DATE_MINIMUM_BUYING_QTY');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', 'END_DATE_MINIMUM_BUYING_QTY');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;

      -- 12. START_DATE_MAXIMUM_BUYING_QTY can not be more than END_DATE_MAXIMUM_BUYING_QTY
      IF NVL(l_start_date1, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date1, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        l_error_table.EXTEND;
        IF l_page_id = -99 THEN
          IF l_do_tp_validations THEN
            l_error_rec.ERROR_LEVEL := 'C';
            l_page_id := -1;
          ELSE
            Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', l_page_id, l_page_display_name);
            l_error_rec.ERROR_LEVEL := 'I';
          END IF; --IF l_do_tp_validations THEN
        END IF;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', 'START_DATE_MAXIMUM_BUYING_QTY');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_BUYING_QTY_INFO', 'END_DATE_MAXIMUM_BUYING_QTY');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_BUYING_QTY_INFO - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
        ELSE
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; -- IF l_do_tp_validations THEN
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 13. FIRST_ORDER_DATE can not be more than LAST_ORDER_DATE
    BEGIN
      IF l_do_tp_validations THEN
        l_sql := ' SELECT  FIRST_ORDER_DATE, ' ||
                 '         LAST_ORDER_DATE ' ||
                 ' FROM EGO_SBDH_ORDERING_INFO_TPV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_ORDERING_INFO_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';
        EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT  FIRST_ORDER_DATE, ' ||
                 '         LAST_ORDER_DATE ' ||
                 ' FROM EGO_SBDH_ORDERING_INFO_AGV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';
        EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        l_error_table.EXTEND;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
          l_page_id := -1;
        ELSE
          Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_ORDERING_INFO', l_page_id, l_page_display_name);
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; --IF l_do_tp_validations THEN
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_ORDERING_INFO', 'FIRST_ORDER_DATE');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_ORDERING_INFO', 'LAST_ORDER_DATE');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_ORDERING_INFO - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
        ELSE
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; -- IF l_do_tp_validations THEN
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 14. FIRST_SHIP_DATE can not be more than LAST_SHIP_DATE
    BEGIN
      IF l_do_tp_validations THEN
        l_sql := ' SELECT  FIRST_SHIP_DATE, ' ||
                 '         LAST_SHIP_DATE ' ||
                 ' FROM EGO_SBDH_SHIP_EXCL_DATES_TPV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_SHIP_EXCL_DATES_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';
        EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT  FIRST_SHIP_DATE, ' ||
                 '         LAST_SHIP_DATE ' ||
                 ' FROM EGO_SBDH_SHIP_EXCL_DATES_AGV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';
        EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        l_error_table.EXTEND;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
          l_page_id := -1;
        ELSE
          Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_SHIP_EXCL_DATES', l_page_id, l_page_display_name);
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; --IF l_do_tp_validations THEN
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_SHIP_EXCL_DATES', 'FIRST_SHIP_DATE');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_SHIP_EXCL_DATES', 'LAST_SHIP_DATE');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_SHIP_EXCL_DATES - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
        ELSE
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; -- IF l_do_tp_validations THEN
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 15. MIN_TRADE_ITEM_LIFE_ARR can not be more than MIN_TRADE_ITEM_LIFE_PROD
    BEGIN
      l_sql := ' SELECT NVL(C.MIN_TRADE_ITEM_LIFE_ARR, MSI.SHELF_LIFE_DAYS) MIN_TRADE_ITEM_LIFE_ARR ' ||
               ' FROM MTL_SYSTEM_ITEMS_B MSI,EGO_ITEM_CUST_ATTRS_B C ' ||
               ' WHERE C.PARTY_SITE_ID (+) = :party_site_id ' ||
               '   AND MSI.INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND MSI.ORGANIZATION_ID = :p_organization_id ' ||
               '   AND MSI.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID (+) '||
               '   AND MSI.ORGANIZATION_ID = C.MASTER_ORGANIZATION_ID (+) ';

      EXECUTE IMMEDIATE l_sql INTO l_min_value
      USING l_party_site_id, p_inventory_item_id, p_organization_id;

      IF l_do_tp_validations THEN
        l_sql := ' SELECT MIN_TRADE_ITEM_LIFE_PROD ' ||
                 ' FROM EGO_SBDH_TRD_ITM_LIFESPAN_TPV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_TRD_ITM_LIFESPAN_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';
        EXECUTE IMMEDIATE l_sql INTO l_max_value
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT MIN_TRADE_ITEM_LIFE_PROD ' ||
                 ' FROM EGO_SBDH_TRD_ITM_LIFESPAN_AGV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';
        EXECUTE IMMEDIATE l_sql INTO l_max_value
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      IF l_min_value > l_max_value THEN
        l_error_table.EXTEND;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
          l_page_id := -1;
        ELSE
          Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_TRD_ITM_LIFESPAN', l_page_id, l_page_display_name);
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; --IF l_do_tp_validations THEN
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_MIN_GT_MAX');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEM_CUSTOMER_ATTRS', 'Handling_Information', 'Min_Trade_Item_Life_Arr');
        l_attr2_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_TRD_ITM_LIFESPAN', 'MIN_TRADE_ITEM_LIFE_PROD');
        FND_MESSAGE.SET_TOKEN('MIN_ATTR', l_attr1_name);
        FND_MESSAGE.SET_TOKEN('MAX_ATTR', l_attr2_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_TRD_ITM_LIFESPAN - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
        ELSE
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; -- IF l_do_tp_validations THEN
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    -- 16. UOM for GOODS_PICK_UP_LEAD_TIME must be present if GOODS_PICK_UP_LEAD_TIME is present
    BEGIN
      IF l_do_tp_validations THEN
        l_sql := ' SELECT GOODS_PICK_UP_LEAD_TIME, GOODS_PICK_UP_LEAD_TIME_UUOM ' ||
                 ' FROM EGO_SBDH_ORDERING_INFO_TPV O' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_ORDERING_INFO_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';

        EXECUTE IMMEDIATE l_sql INTO l_attr_value, l_attr_value_uom
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT GOODS_PICK_UP_LEAD_TIME, GOODS_PICK_UP_LEAD_TIME_UUOM ' ||
                 ' FROM EGO_SBDH_ORDERING_INFO_AGV ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';

        EXECUTE IMMEDIATE l_sql INTO l_attr_value, l_attr_value_uom
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
        l_error_table.EXTEND;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
          l_page_id := -1;
        ELSE
          Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_ORDERING_INFO', l_page_id, l_page_display_name);
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; --IF l_do_tp_validations THEN
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_REQD');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_ORDERING_INFO', 'GOODS_PICK_UP_LEAD_TIME');
        FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        l_error_table(l_error_table.LAST) := l_error_rec;
      END IF;
    EXCEPTION
      WHEN column_not_found THEN
        Get_Associated_Page_Details(l_catalog_group_id, 'EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_ORDERING_INFO', l_page_id, l_page_display_name);
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := l_page_id;
        l_error_rec.PAGE_DISPLAY_NAME := l_page_display_name;
        FND_MESSAGE.SET_NAME('EGO', 'EGO_UOM_CLASS_REQD');
        l_attr1_name := Get_Attr_Display_Name('EGO_ITEMMGMT_GROUP', 'EGOINT_GDSN_ORDERING_INFO', 'GOODS_PICK_UP_LEAD_TIME');
        FND_MESSAGE.SET_TOKEN('ATTR_NAME', l_attr1_name);
        l_error_rec.ERROR_MESSAGE := FND_MESSAGE.GET();
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
        ELSE
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; -- IF l_do_tp_validations THEN
        l_error_table(l_error_table.LAST) := l_error_rec;
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        l_unexp_err := 'EGOINT_GDSN_ORDERING_INFO - '||SQLERRM;
        l_error_table.EXTEND;
        l_error_rec.PAGE_ID := -1;
        l_error_rec.ERROR_MESSAGE := l_unexp_err;
        IF l_do_tp_validations THEN
          l_error_rec.ERROR_LEVEL := 'C';
        ELSE
          l_error_rec.ERROR_LEVEL := 'I';
        END IF; -- IF l_do_tp_validations THEN
        l_error_table(l_error_table.LAST) := l_error_rec;
    END;

    OPEN p_errors FOR
      SELECT *
      FROM TABLE( CAST(l_error_table AS SYSTEM.EGO_PAGEWISE_ERROR_TABLE) );
  END Validate_SBDH_Attributes;

  /*
   * This method validates SBDH attributes. if p_address_id is null then only item level attributes
   * are validated.
   * Returns 'F' if some validation fails
   */
  FUNCTION Is_SBDH_Attributes_Valid(p_inventory_item_id       NUMBER,
                                    p_organization_id         NUMBER,
                                    p_address_id              NUMBER)
  RETURN VARCHAR2
  IS
    l_start_date        DATE;
    l_end_date          DATE;
    l_start_date1       DATE;
    l_end_date1         DATE;
    l_min_value         NUMBER;
    l_max_value         NUMBER;
    l_attr_value        NUMBER;
    l_attr_value_uom    VARCHAR2(10);
    l_attr1_value       NUMBER;
    l_attr1_value_uom   VARCHAR2(10);

    l_sql               VARCHAR2(15000);
    l_peg_hole_number   NUMBER;
    l_peg_vertical      NUMBER;
    l_peg_horizontal    NUMBER;
    l_party_site_id     NUMBER;
    l_do_tp_validations BOOLEAN;

    TYPE ref_cursor_type IS REF CURSOR;
    c_ref_cursor       ref_cursor_type;

    column_not_found  EXCEPTION;
    PRAGMA EXCEPTION_INIT(column_not_found, -904);
  BEGIN
    IF p_address_id IS NULL THEN
      l_do_tp_validations := FALSE;
    ELSE
      l_do_tp_validations := TRUE;
    END IF;

    IF l_do_tp_validations THEN
      -- retreiving party_site_id from address_id
      SELECT PARTY_SITE_ID INTO l_party_site_id
      FROM HZ_CUST_ACCT_SITES_ALL
      WHERE CUST_ACCT_SITE_ID = p_address_id;
    END IF; --IF l_do_tp_validations THEN

    -- validating first the attributes that are not TP-Dependant
    -- 1. DEPOSIT_VALUE_EFFECTIVE_DATE can not be greater than DEPOSIT_VALUE_END_DATE
    BEGIN
      l_sql := ' SELECT DEPOSIT_VALUE_EFFECTIVE_DATE, DEPOSIT_VALUE_END_DATE ' ||
               ' FROM EGO_SBDH_DEP_VAL_DATE_INFO_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date USING p_inventory_item_id, p_organization_id;

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        RETURN 'F';
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    -- 2. CAMPAIGN_START_DATE can not be greater than CAMPAIGN_END_DATE
    BEGIN
      l_sql := ' SELECT CAMPAIGN_START_DATE, CAMPAIGN_END_DATE ' ||
               ' FROM EGO_SBDH_CAMPAIGN_INFO_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date USING p_inventory_item_id, p_organization_id;

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        RETURN 'F';
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    -- 3. SEASONAL_AVL_START_DATE can not be greater than SEASONAL_AVL_END_DATE
    BEGIN
      l_sql := ' SELECT SEASONAL_AVL_START_DATE, SEASONAL_AVL_END_DATE ' ||
               ' FROM EGO_SBDH_SEASON_AVL_DATE_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date USING p_inventory_item_id, p_organization_id;

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        RETURN 'F';
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    -- 4. STORAGE_HNDLNG_HUMDTY_MIN can not be greater than STORAGE_HNDLNG_HUMDTY_MAX
    --    this is a multi-row attribute group, so using ref cursor.
    BEGIN
      l_sql := ' SELECT STORAGE_HNDLNG_HUMDTY_MIN, STORAGE_HNDLNG_HUMDTY_MAX ' ||
               ' FROM EGO_SBDH_STRG_HNDLG_HMDTY_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      OPEN c_ref_cursor FOR l_sql USING p_inventory_item_id, p_organization_id;
      LOOP
        FETCH c_ref_cursor INTO l_min_value, l_max_value;
        EXIT WHEN c_ref_cursor%NOTFOUND;

        IF l_min_value > l_max_value THEN
          IF c_ref_cursor%ISOPEN THEN
            CLOSE c_ref_cursor;
          END IF;
          RETURN 'F';
        END IF;
      END LOOP;
      CLOSE c_ref_cursor;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
      WHEN OTHERS THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        RAISE;
    END;

    -- 5. pegHorizontal, pegVertical and pegHoleNumber should be specified when either of them is specified.
    BEGIN
      l_sql := ' SELECT sbdh.PEG_HOLE_NUMBER, core.PEG_VERTICAL, core.PEG_HORIZONTAL ' ||
               ' FROM EGO_SBDH_TRADE_ITEM_INFO_AGV sbdh, EGO_ITEM_GTN_ATTRS_B core ' ||
               ' WHERE core.INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND core.ORGANIZATION_ID = :p_organization_id ' ||
               '   AND sbdh.INVENTORY_ITEM_ID (+) = core.INVENTORY_ITEM_ID ' ||
               '   AND sbdh.ORGANIZATION_ID (+) = core.ORGANIZATION_ID ';
      EXECUTE IMMEDIATE l_sql INTO l_peg_hole_number, l_peg_vertical, l_peg_horizontal USING p_inventory_item_id, p_organization_id;

      IF l_peg_hole_number IS NOT NULL AND (l_peg_vertical IS NULL OR l_peg_horizontal IS NULL) OR
         l_peg_vertical IS NOT NULL AND (l_peg_hole_number IS NULL OR l_peg_horizontal IS NULL) OR
         l_peg_horizontal IS NOT NULL AND (l_peg_hole_number IS NULL OR l_peg_vertical IS NULL)
      THEN
        RETURN 'F';
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    -- validating that UOM values and class are present
    -- 6. UOM for PRICE_COMPARISON_MSRMNT must be present if PRICE_COMPARISON_MSRMNT is present
    BEGIN
      l_sql := ' SELECT PRICE_COMPARISON_MSRMNT, PRICE_COMPARISON_MSRMNT_UUOM ' ||
               ' FROM EGO_SBDH_PRC_CMPRSN_MSRMT_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id ';
      OPEN c_ref_cursor FOR l_sql USING p_inventory_item_id, p_organization_id;
      LOOP
        FETCH c_ref_cursor INTO l_attr_value, l_attr_value_uom;
        EXIT WHEN c_ref_cursor%NOTFOUND;

        IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
          IF c_ref_cursor%ISOPEN THEN
            CLOSE c_ref_cursor;
          END IF;
          RETURN 'F';
        END IF;
      END LOOP;
      CLOSE c_ref_cursor;
    EXCEPTION
      WHEN column_not_found THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        RETURN 'F';
      WHEN NO_DATA_FOUND THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
      WHEN OTHERS THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        RETURN 'F';
    END;

    -- 7. UOM for TRADE_ITEM_COMPOSTN_WIDTH must be present if TRADE_ITEM_COMPOSTN_WIDTH is present
    BEGIN
      l_sql := ' SELECT TRADE_ITEM_COMPOSTN_WIDTH, TRADE_ITEM_COMPOSTN_WIDTH_UUOM ' ||
               ' FROM EGO_SBDH_TRADE_ITEM_INFO_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id ';
      EXECUTE IMMEDIATE l_sql INTO l_attr_value, l_attr_value_uom USING p_inventory_item_id, p_organization_id;

      IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
        RETURN 'F';
      END IF;
    EXCEPTION
      WHEN column_not_found THEN
        RETURN 'F';
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    -- 8. UOM for MATERIAL_WEIGHT must be present if MATERIAL_WEIGHT is present
    BEGIN
      l_sql := ' SELECT MATERIAL_WEIGHT, MATERIAL_WEIGHT_UUOM ' ||
               ' FROM EGO_SBDH_MATERIAL_INFO_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id ';
      EXECUTE IMMEDIATE l_sql INTO l_attr_value, l_attr_value_uom USING p_inventory_item_id, p_organization_id;

      IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
        RETURN 'F';
      END IF;
    EXCEPTION
      WHEN column_not_found THEN
        RETURN 'F';
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    -- 9. UOM for STORAGE_HNDLNG_HUMDTY_MIN, STORAGE_HNDLNG_HUMDTY_MAX must be present if value os present
    --    this is a multi-row attribute group, so using ref cursor.
    BEGIN
      l_sql := ' SELECT STORAGE_HNDLNG_HUMDTY_MIN, STORAGE_HNDLNG_HUMDTY_MAX, STORAGE_HNDLNG_HUMDTY_MIN_UUOM, STORAGE_HNDLNG_HUMDTY_MAX_UUOM ' ||
               ' FROM EGO_SBDH_STRG_HNDLG_HMDTY_AGV ' ||
               ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND ORGANIZATION_ID = :p_organization_id';
      OPEN c_ref_cursor FOR l_sql USING p_inventory_item_id, p_organization_id;
      LOOP
        FETCH c_ref_cursor INTO l_attr_value, l_attr1_value, l_attr_value_uom, l_attr1_value_uom;
        EXIT WHEN c_ref_cursor%NOTFOUND;

        -- checking for STORAGE_HNDLNG_HUMDTY_MIN
        IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
          IF c_ref_cursor%ISOPEN THEN
            CLOSE c_ref_cursor;
          END IF;
          RETURN 'F';
        END IF;

        -- checking for STORAGE_HNDLNG_HUMDTY_MAX
        IF l_attr1_value IS NOT NULL AND l_attr1_value_uom IS NULL THEN
          IF c_ref_cursor%ISOPEN THEN
            CLOSE c_ref_cursor;
          END IF;
          RETURN 'F';
        END IF;
      END LOOP;
      CLOSE c_ref_cursor;
    EXCEPTION
      WHEN column_not_found THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        RETURN 'F';
      WHEN NO_DATA_FOUND THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
      WHEN OTHERS THEN
        IF c_ref_cursor%ISOPEN THEN
          CLOSE c_ref_cursor;
        END IF;
        RAISE;
    END;

    -- validating TP-Dependant attributes
    -- 10. AGREED_MINIMUM_BUYING_QTY can not be more than AGREED_MAXIMUM_BUYING_QTY
    -- 11. START_DATE_MINIMUM_BUYING_QTY can not be more than END_DATE_MINIMUM_BUYING_QTY
    -- 12. START_DATE_MAXIMUM_BUYING_QTY can not be more than END_DATE_MAXIMUM_BUYING_QTY
    BEGIN
      IF l_do_tp_validations THEN
        l_sql := ' SELECT  AGREED_MINIMUM_BUYING_QTY, ' ||
                 '         AGREED_MAXIMUM_BUYING_QTY, ' ||
                 '         START_DATE_MINIMUM_BUYING_QTY, ' ||
                 '         END_DATE_MINIMUM_BUYING_QTY, ' ||
                 '         START_DATE_MAXIMUM_BUYING_QTY, ' ||
                 '         END_DATE_MAXIMUM_BUYING_QTY ' ||
                 ' FROM EGO_SBDH_BUYING_QTY_INFO_TPV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_BUYING_QTY_INFO_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';
        EXECUTE IMMEDIATE l_sql INTO l_min_value, l_max_value, l_start_date, l_end_date, l_start_date1, l_end_date1
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT  AGREED_MINIMUM_BUYING_QTY, ' ||
                 '         AGREED_MAXIMUM_BUYING_QTY, ' ||
                 '         START_DATE_MINIMUM_BUYING_QTY, ' ||
                 '         END_DATE_MINIMUM_BUYING_QTY, ' ||
                 '         START_DATE_MAXIMUM_BUYING_QTY, ' ||
                 '         END_DATE_MAXIMUM_BUYING_QTY ' ||
                 ' FROM EGO_SBDH_BUYING_QTY_INFO_AGV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';
        EXECUTE IMMEDIATE l_sql INTO l_min_value, l_max_value, l_start_date, l_end_date, l_start_date1, l_end_date1
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      -- 10. AGREED_MINIMUM_BUYING_QTY can not be more than AGREED_MAXIMUM_BUYING_QTY
      IF l_min_value > l_max_value THEN
        RETURN 'F';
      END IF;

      -- 11. START_DATE_MINIMUM_BUYING_QTY can not be more than END_DATE_MINIMUM_BUYING_QTY
      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        RETURN 'F';
      END IF;

      -- 12. START_DATE_MAXIMUM_BUYING_QTY can not be more than END_DATE_MAXIMUM_BUYING_QTY
      IF NVL(l_start_date1, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date1, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        RETURN 'F';
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    -- 13. FIRST_ORDER_DATE can not be more than LAST_ORDER_DATE
    BEGIN
      IF l_do_tp_validations THEN
        l_sql := ' SELECT  FIRST_ORDER_DATE, ' ||
                 '         LAST_ORDER_DATE ' ||
                 ' FROM EGO_SBDH_ORDERING_INFO_TPV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_ORDERING_INFO_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';
        EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT  FIRST_ORDER_DATE, ' ||
                 '         LAST_ORDER_DATE ' ||
                 ' FROM EGO_SBDH_ORDERING_INFO_AGV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';
        EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        RETURN 'F';
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    -- 14. FIRST_SHIP_DATE can not be more than LAST_SHIP_DATE
    BEGIN
      IF l_do_tp_validations THEN
        l_sql := ' SELECT  FIRST_SHIP_DATE, ' ||
                 '         LAST_SHIP_DATE ' ||
                 ' FROM EGO_SBDH_SHIP_EXCL_DATES_TPV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_SHIP_EXCL_DATES_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';
        EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT  FIRST_SHIP_DATE, ' ||
                 '         LAST_SHIP_DATE ' ||
                 ' FROM EGO_SBDH_SHIP_EXCL_DATES_AGV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';
        EXECUTE IMMEDIATE l_sql INTO l_start_date, l_end_date
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      IF NVL(l_start_date, TO_DATE('01-01-1990', 'DD-MM-YYYY')) > NVL(l_end_date, TO_DATE('31-12-9990', 'DD-MM-YYYY')) THEN
        RETURN 'F';
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    -- 15. MIN_TRADE_ITEM_LIFE_ARR can not be more than MIN_TRADE_ITEM_LIFE_PROD
    BEGIN
      l_sql := ' SELECT NVL(C.MIN_TRADE_ITEM_LIFE_ARR, MSI.SHELF_LIFE_DAYS) MIN_TRADE_ITEM_LIFE_ARR ' ||
               ' FROM MTL_SYSTEM_ITEMS_B MSI,EGO_ITEM_CUST_ATTRS_B C ' ||
               ' WHERE C.PARTY_SITE_ID (+) = :party_site_id ' ||
               '   AND MSI.INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
               '   AND MSI.ORGANIZATION_ID = :p_organization_id ' ||
               '   AND MSI.INVENTORY_ITEM_ID = C.INVENTORY_ITEM_ID (+) '||
               '   AND MSI.ORGANIZATION_ID = C.MASTER_ORGANIZATION_ID (+) ';

      EXECUTE IMMEDIATE l_sql INTO l_min_value
      USING l_party_site_id, p_inventory_item_id, p_organization_id;

      IF l_do_tp_validations THEN
        l_sql := ' SELECT MIN_TRADE_ITEM_LIFE_PROD ' ||
                 ' FROM EGO_SBDH_TRD_ITM_LIFESPAN_TPV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_TRD_ITM_LIFESPAN_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';
        EXECUTE IMMEDIATE l_sql INTO l_max_value
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT MIN_TRADE_ITEM_LIFE_PROD ' ||
                 ' FROM EGO_SBDH_TRD_ITM_LIFESPAN_AGV O ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';
        EXECUTE IMMEDIATE l_sql INTO l_max_value
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      IF l_min_value > l_max_value THEN
        RETURN 'F';
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    -- 16. UOM for GOODS_PICK_UP_LEAD_TIME must be present if GOODS_PICK_UP_LEAD_TIME is present
    BEGIN
      IF l_do_tp_validations THEN
        l_sql := ' SELECT GOODS_PICK_UP_LEAD_TIME, GOODS_PICK_UP_LEAD_TIME_UUOM ' ||
                 ' FROM EGO_SBDH_ORDERING_INFO_TPV O' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND MASTER_ORGANIZATION_ID = :p_organization_id ' ||
                 '   AND (PARTY_SITE_ID = :party_site_id ' ||
                 '        OR (PARTY_SITE_ID IS NULL '||
                 '            AND NOT EXISTS (SELECT NULL ' ||
                 '                            FROM EGO_SBDH_ORDERING_INFO_TPV I ' ||
                 '                            WHERE O.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID ' ||
                 '                              AND O.MASTER_ORGANIZATION_ID = I.MASTER_ORGANIZATION_ID ' ||
                 '                              AND I.PARTY_SITE_ID = :2)))';

        EXECUTE IMMEDIATE l_sql INTO l_attr_value, l_attr_value_uom
        USING p_inventory_item_id, p_organization_id, l_party_site_id, l_party_site_id;
      ELSE
        l_sql := ' SELECT GOODS_PICK_UP_LEAD_TIME, GOODS_PICK_UP_LEAD_TIME_UUOM ' ||
                 ' FROM EGO_SBDH_ORDERING_INFO_AGV ' ||
                 ' WHERE INVENTORY_ITEM_ID = :p_inventory_item_id ' ||
                 '   AND ORGANIZATION_ID = :p_organization_id ';

        EXECUTE IMMEDIATE l_sql INTO l_attr_value, l_attr_value_uom
        USING p_inventory_item_id, p_organization_id;
      END IF; --IF l_do_tp_validations THEN

      IF l_attr_value IS NOT NULL AND l_attr_value_uom IS NULL THEN
        RETURN 'F';
      END IF;
    EXCEPTION
      WHEN column_not_found THEN
        RETURN 'F';
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    RETURN 'T';
  END Is_SBDH_Attributes_Valid;

  /*
   * This method is called after Trade Item Descriptor is updated and
   * item is a GDSN Outbound Enabled Item. This method NULLs out all the attributes
   * that are not updateable at Non-Leaf level
   */
  PROCEDURE PROCESS_GTID_UPDATE (p_inventory_item_id NUMBER,
                                 p_organization_id   NUMBER,
                                 p_trade_item_desc   VARCHAR2,
                                 x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER,
                                 x_msg_data          OUT NOCOPY VARCHAR2)
  IS
    CURSOR c_single_attrs_not_upd IS
      SELECT DATA_TYPE_CODE, DATABASE_COLUMN
      FROM EGO_ATTRS_V
      WHERE ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_ATTRS'
        AND APPLICATION_ID = 431
        AND EDIT_IN_HIERARCHY_CODE LIKE 'L%'
        AND NVL(ENABLED_FLAG, 'N') = 'Y';

    l_b_sql            VARCHAR2(32000);
    l_tl_sql           VARCHAR2(32000);
    l_execute_b_sql    BOOLEAN;
    l_execute_tl_sql   BOOLEAN;
  BEGIN
    SAVEPOINT GTID_UPDATE;
    WRITE_DEBUG_LOG('Starting PROCESS_GTID_UPDATE');
    WRITE_DEBUG_LOG('Parameters: p_inventory_item_id, p_organization_id, p_trade_item_desc=' || p_inventory_item_id ||','|| p_organization_id||','|| p_trade_item_desc);
    IF NVL(p_trade_item_desc, 'BASE_UNIT_OR_EACH') <> 'BASE_UNIT_OR_EACH' THEN
      l_b_sql := 'UPDATE EGO_ITEM_GTN_ATTRS_B SET ';
      l_tl_sql := 'UPDATE EGO_ITEM_GTN_ATTRS_TL SET ';
      l_execute_b_sql := FALSE;
      l_execute_tl_sql := FALSE;
      FOR i IN c_single_attrs_not_upd LOOP
        IF i.DATA_TYPE_CODE <> 'A' THEN
          l_b_sql := l_b_sql || i.DATABASE_COLUMN || ' = NULL ,';
          l_execute_b_sql := TRUE;
        ELSE
          l_tl_sql := l_tl_sql || i.DATABASE_COLUMN || ' = NULL ,';
          l_execute_tl_sql := TRUE;
        END IF;
      END LOOP;
      l_b_sql := RTRIM(l_b_sql, ',') || ' WHERE INVENTORY_ITEM_ID = :1 AND ORGANIZATION_ID = :2 ';
      l_tl_sql := RTRIM(l_tl_sql, ',') || ' WHERE INVENTORY_ITEM_ID = :1 AND ORGANIZATION_ID = :2 ';

      WRITE_DEBUG_LOG('l_b_sql='||l_b_sql);
      WRITE_DEBUG_LOG('l_tl_sql='||l_tl_sql);

      IF l_execute_b_sql THEN
        EXECUTE IMMEDIATE l_b_sql USING p_inventory_item_id, p_organization_id;
      END IF;

      IF l_execute_tl_sql THEN
        EXECUTE IMMEDIATE l_tl_sql USING p_inventory_item_id, p_organization_id;
      END IF;

      WRITE_DEBUG_LOG('Deleting multi-row attributes');

      DELETE FROM EGO_ITM_GTN_MUL_ATTRS_B
      WHERE INVENTORY_ITEM_ID = p_inventory_item_id
        AND ORGANIZATION_ID = p_organization_id
        AND ATTR_GROUP_ID IN (SELECT AG.ATTR_GROUP_ID
                              FROM EGO_FND_DSC_FLX_CTX_EXT AG, EGO_ATTRS_V EAV
                              WHERE AG.APPLICATION_ID = 431
                                AND EAV.APPLICATION_ID = AG.APPLICATION_ID
                                AND AG.DESCRIPTIVE_FLEXFIELD_NAME = EAV.ATTR_GROUP_TYPE
                                AND AG.DESCRIPTIVE_FLEX_CONTEXT_CODE = EAV.ATTR_GROUP_NAME
                                AND EAV.EDIT_IN_HIERARCHY_CODE LIKE 'L%'
                                AND NVL(EAV.ENABLED_FLAG, 'N') = 'Y'
                                AND EAV.ATTR_GROUP_TYPE = 'EGO_ITEM_GTIN_MULTI_ATTRS');
      WRITE_DEBUG_LOG('Deleted '||SQL%ROWCOUNT||' rows');
    END IF;
    x_return_status := 'S';
    x_msg_data := NULL;
    x_msg_count := 0;
    WRITE_DEBUG_LOG('Done PROCESS_GTID_UPDATE');
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO SAVEPOINT GTID_UPDATE;
    WRITE_DEBUG_LOG('Error in PROCESS_GTID_UPDATE-'||SQLERRM);
    x_return_status := 'U';
    x_msg_data := SQLERRM;
    x_msg_count := 1;
  END PROCESS_GTID_UPDATE;

END EGO_GTIN_PVT;

/
