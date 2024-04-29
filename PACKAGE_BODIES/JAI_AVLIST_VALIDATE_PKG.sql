--------------------------------------------------------
--  DDL for Package Body JAI_AVLIST_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AVLIST_VALIDATE_PKG" AS
--$Header: Jai_AvList_Validate.plb 120.0.12010000.5 2009/06/27 04:25:20 jijili noship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     Jai_Avlist_Validate.plb                                           |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Validate if there is more than one Item-UOM combination existing  |
--|     in used AV list for the Item selected in the transaction.         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Check_Validation                                |
--|                                                                       |
--| HISTORY                                                               |
--|     2009/06/08   Jia Li     Created                                   |
--|                                                                       |
--+======================================================================*/


--==========================================================================
--  PROCEDURE NAME:
--
--    Check_AvList_Validation                      Public
--
--  DESCRIPTION:
--
--    This is a validation procedure which will be used to check
--    whether there is more than one Item-UOM combination existing
--    in used AV list for the Item selected in the transaction.
--
--  PARAMETERS:
--      In:  pn_party_id            Identifier of Customer id or Vendor id
--           pn_party_site_id       Identifier of Customer/Vendor site id
--           pn_inventory_item_id   Identifier of Inventory item id
--           pd_ordered_date        Identifier of Ordered date
--           pv_party_type          Identifier of Party type, 'C' is mean customer, 'V' is mean vendor
--           pn_pricing_list_id     Identifier of vat/excise assessable price id, for base form used.
--
--
--  DESIGN REFERENCES:
--    FDD_R12i_Advanced_Pricing_V1.0.doc
--
--  CHANGE HISTORY:
--
--           08-Jun-2009   Jia Li   created
--==========================================================================
PROCEDURE Check_AvList_Validation
( pn_party_id          IN NUMBER
, pn_party_site_id     IN NUMBER
, pn_inventory_item_id IN NUMBER
, pd_ordered_date      IN DATE
, pv_party_type        IN VARCHAR2
, pn_pricing_list_id   IN NUMBER
)
IS
  -- Get category_set_name
  CURSOR category_set_name_cur
  IS
  SELECT
    category_set_name
  FROM
    mtl_default_category_sets_fk_v
  WHERE functional_area_desc = 'Order Entry';

  lv_category_set_name  VARCHAR2(30);

  -- Get excise&vat price_list_id based on customer&site or customer&null site
  CURSOR cust_price_list_cur
  IS
  SELECT
    price_list_id      excise_av_list
  , vat_price_list_id  vat_av_list
  FROM
    jai_cmn_cus_addresses
  WHERE customer_id = pn_party_id
    AND address_id = NVL(pn_party_site_id,0);

  -- Get excise&vat price_list_id based on vendor&site or vendorr&null site
  CURSOR vend_price_list_cur
  IS
  SELECT
    price_list_id      excise_av_list
  , vat_price_list_id  vat_av_list
  FROM
    jai_cmn_vendor_sites
  WHERE vendor_id = pn_party_id
    AND vendor_site_id = NVL(pn_party_site_id,0);

  -- Get AV list name based on excise/vat price list id.
  CURSOR av_list_name_cur
  ( pn_list_header_id  NUMBER
  )
  IS
  SELECT
    name
  FROM
    qp_list_headers
  WHERE list_header_id = pn_list_header_id;

  -- Check same UOM ,whether item and item category that contains the same item existing in a same price list.
  CURSOR check_item_category_cur
  ( pn_list_header_id   NUMBER
  )
  IS
  SELECT
    micv.category_id         category_id
  FROM
    qp_list_lines          ql1
  , qp_pricing_attributes  qp1
  , mtl_item_categories_v  micv
  , qp_list_lines          ql2
  , qp_pricing_attributes  qp2
  WHERE ql1.list_header_id = pn_list_header_id
    AND ql1.list_line_id = qp1.list_line_id
    AND qp1.product_attr_value = TO_CHAR(micv.category_id)
    AND micv.inventory_item_id = NVL( pn_inventory_item_id, micv.inventory_item_id)
    AND micv.category_set_name = lv_category_set_name
    AND qp2.product_attr_value = TO_CHAR(micv.inventory_item_id)
    AND qp1.list_header_id = qp2.list_header_id
    AND ql2.list_line_id = qp2.list_line_id
    AND qp1.product_uom_code = qp2.product_uom_code
    AND pd_ordered_date BETWEEN NVL( ql1.start_date_active, pd_ordered_date)
                               AND NVL( ql1.end_date_active, SYSDATE)
    AND pd_ordered_date BETWEEN NVL( ql2.start_date_active, pd_ordered_date)
                               AND NVL(ql2.end_date_active, SYSDATE)
  GROUP BY micv.inventory_item_id,micv.category_id;

  -- Check same UOM ,whether multiple item categories that contains the same item existing in a same price list.
  CURSOR check_multi_category_cur
  ( pn_list_header_id    NUMBER
  )
  IS
  SELECT
    qp.product_uom_code           uom_code
  , COUNT(qp.product_attr_value)  category_number
  FROM
    qp_list_lines ql
  , qp_pricing_attributes qp
  WHERE ql.list_header_id = pn_list_header_id
    AND ql.list_line_id = qp.list_line_id
    AND EXISTS ( SELECT
                   micv.category_id
                 FROM
                   mtl_item_categories_v micv
                 WHERE micv.inventory_item_id = NVL( pn_inventory_item_id, micv.inventory_item_id)
                   AND micv.category_set_name = lv_category_set_name
                   AND TO_CHAR(micv.category_id) = qp.product_attr_value
                )
    AND pd_ordered_date BETWEEN NVL( ql.start_date_active, pd_ordered_date)
                               AND NVL( ql.end_date_active, SYSDATE)
  GROUP BY qp.product_uom_code;

  ln_excise_list_id   NUMBER;
  ln_vat_list_id      NUMBER;
  lv_av_list_name     qp_list_headers.name%type;
  ln_category_id      NUMBER;
  le_multi_row        EXCEPTION;

  lv_procedure_name   VARCHAR2(40) := 'Check_AvList_Validation';
  ln_dbg_level        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ln_proc_level       NUMBER := FND_LOG.LEVEL_PROCEDURE;

 BEGIN
   --logging for debug
   IF (ln_proc_level >= ln_dbg_level)
   THEN
     FND_LOG.STRING( ln_proc_level
                   , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.Begin'
                   , 'Enter Procedure'
                   );
   END IF; --l_proc_level>=l_dbg_level

   -- Get category_set_name
   OPEN category_set_name_cur;
   FETCH category_set_name_cur INTO lv_category_set_name;
   CLOSE category_set_name_cur;

   -- Invoked by form
   IF pn_pricing_list_id IS NOT NULL
   THEN
     -- Get AV List name.
     OPEN av_list_name_cur(pn_pricing_list_id);
     FETCH av_list_name_cur INTO lv_av_list_name;
     CLOSE av_list_name_cur;

     -- Check same UOM ,whether item and item category that contains the same item existing in a same price list.
     OPEN check_item_category_cur(pn_pricing_list_id);
     FETCH check_item_category_cur INTO ln_category_id;
     CLOSE check_item_category_cur;

     IF ln_category_id IS NOT NULL
     THEN
       RAISE le_multi_row;
     END IF;

     -- Check same UOM ,whether multiple item categories that contains the same item existing in a same price list.
     FOR multi_category_csr IN check_multi_category_cur(pn_pricing_list_id)
     LOOP
       IF multi_category_csr.category_number > 1
       THEN
         RAISE le_multi_row;
       END IF;
     END LOOP;

   ELSE

     IF pv_party_type = 'C'
     THEN
       -- Get excise and vat price list id based on customer and site.
       OPEN cust_price_list_cur;
       FETCH
         cust_price_list_cur
       INTO
         ln_excise_list_id
       , ln_vat_list_id;
       CLOSE cust_price_list_cur;
     ELSIF pv_party_type = 'V'
     THEN
       -- Get excise and vat price list id based on vendor and site.
       OPEN vend_price_list_cur;
       FETCH
         vend_price_list_cur
       INTO
         ln_excise_list_id
       , ln_vat_list_id;
       CLOSE vend_price_list_cur;
     END IF;

     IF ln_excise_list_id IS NOT NULL
     THEN
       -- Get Excise AV List name.
       OPEN av_list_name_cur(ln_excise_list_id);
       FETCH av_list_name_cur INTO lv_av_list_name;
       CLOSE av_list_name_cur;

       -- Check same UOM ,whether item and item category that contains the same item existing in a same price list.
       OPEN check_item_category_cur(ln_excise_list_id);
       FETCH check_item_category_cur INTO ln_category_id;
       CLOSE check_item_category_cur;

       IF ln_category_id IS NOT NULL
       THEN
         RAISE le_multi_row;
       END IF;

       -- Check same UOM ,whether multiple item categories that contains the same item existing in a same price list.
       FOR multi_category_csr IN check_multi_category_cur(ln_excise_list_id)
       LOOP
         IF multi_category_csr.category_number > 1
         THEN
           RAISE le_multi_row;
         END IF;
       END LOOP;
     END IF; --ln_excise_list_id is not null

     IF ln_vat_list_id IS NOT NULL
     THEN
       -- Get VAT AV List name.
       OPEN av_list_name_cur(ln_vat_list_id);
       FETCH av_list_name_cur INTO lv_av_list_name;
       CLOSE av_list_name_cur;

       -- Check same UOM ,whether item and item category that contains the same item existing in a same price list.
       OPEN check_item_category_cur(ln_vat_list_id);
       FETCH check_item_category_cur INTO ln_category_id;
       CLOSE check_item_category_cur;

       IF ln_category_id IS NOT NULL
       THEN
         RAISE le_multi_row;
       END IF;

       -- Check same UOM ,whether multiple item categories that contains the same item existing in a same price list.
       FOR multi_category_csr IN check_multi_category_cur(ln_vat_list_id)
       LOOP
         IF multi_category_csr.category_number > 1
         THEN
           RAISE le_multi_row;
         END IF;
       END LOOP;
     END IF;  -- ln_vat_list_id is not null

   END IF; -- pn_pricing_list_id IS NOT NULL


   --logging for debug
   IF (ln_proc_level >= ln_dbg_level)
   THEN
     FND_LOG.STRING( ln_proc_level
                   , GV_MODULE_PREFIX ||'.' || lv_procedure_name || '.End'
                   , 'Enter Procedure'
                   );
   END IF; --l_proc_level>=l_dbg_level

 EXCEPTION
   WHEN le_multi_row THEN
     IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
     THEN
       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED
                     , GV_MODULE_PREFIX ||'.' || lv_procedure_name
                     || '.Multi_Exception '
                     , SQLCODE||SQLERRM);
     END IF; -- (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)

     FND_MESSAGE.SET_NAME ('JA','JAI_AV_LIST_VALIDATION');
     FND_MESSAGE.SET_TOKEN ('AV_LIST_NAME',lv_av_list_name);
     app_exception.raise_exception;

 END Check_AvList_Validation;

END JAI_AVLIST_VALIDATE_PKG;

/
