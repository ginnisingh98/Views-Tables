--------------------------------------------------------
--  DDL for Package Body JAI_OM_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_OM_UTILS_PKG" AS
/* $Header: jai_om_utils.plb 120.2.12010000.7 2009/08/28 11:21:53 vkaranam ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_om_utils -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

13-Jun-2005  4428980     File Version: 116.3
                         Ramananda for bug#4428980. Removal of SQL LITERALs is done

28-Jul-2009              Xiao Lv for IL Advanced Pricing.
                         Add if condition control for specific release version, code as:
                         IF lv_release_name NOT LIKE '12.0%' THEN
                            Advanced Pricing code;
                         END IF;

28-aug-2009  vkaranam for bug#8844209
             Issue:
	     IL ASSESSABLE VALUE NOT CONSIDERING  CURRENCY CONVERSION FOR EXPORT SALES ORDER

	     Fix:
	     Added a conversion factor while calculating the assessable value.
	     Changes are done in get_oe_assessable_value.
	     Please query by bug number to see the changes.


*--------------------------------------------------------------------------------------*/

PROCEDURE get_ato_pricelist_value
(
 NEW_LIST NUMBER,
 UNIT_CODE NUMBER,
 INVENTORY_ID NUMBER,
 IL6 NUMBER,
 NAMOUNT OUT NOCOPY NUMBER
)
IS

   PRICE     NUMBER;
   SUM_TOT   NUMBER;
   NO        NUMBER;

-- Changed For Migration To R11i on 17-10-2000 by A.Raina
-- Table "SO_LINES_ALL IS REPLACED BY "OE_ORDER_LINES_ALL"
-- so field "UNIT_CODE" is replace by "ORDER_QUANTITY_UOM" .
-- Also table "SO_PRICE_LIST_LINES" is replaced by "SO_PRICE_LIST_LINES_115"

  CURSOR sel_line_id is
  SELECT line_id,ordered_quantity,order_quantity_uom,inventory_item_id
    FROM oe_order_lines_all
   WHERE line_id = il6;

  CURSOR sel_ato_lines(ln_id number) is select line_id,ato_line_id,ordered_quantity,inventory_itEM_ID,ORDER_QUANTITY_UOM
    FROM oe_order_lines_all
   WHERE ato_line_id = ln_id;

  CURSOR n_lst_price(id number,unt varchar2) is select list_price
    FROM so_price_list_lines_115
   WHERE inventory_item_id = id
     AND unit_code = unt
     AND price_list_id = new_list;

   lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_utils_pkg.get_ato_pricelist_value';

BEGIN

FOR I IN SEL_LINE_ID   ---------------------------------------------------------------- (1)
LOOP
    FOR J IN SEL_ATO_LINES(I.LINE_ID)  -------------------------------------------------(2)
    LOOP
        FOR K IN N_LST_PRICE(J.INVENTORY_ITEM_ID,J.ORDER_QUANTITY_UOM)  ----------------(3)
        LOOP
            SUM_TOT := K.LIST_PRICE * J.ORDERED_QUANTITY;
            NO := NO + J.ORDERED_QUANTITY;
        END LOOP;                                              -------------------------(3)
    END LOOP;                         ------------------------------------------------- (2)

    FOR L IN N_LST_PRICE(I.INVENTORY_ITEM_ID,I.ORDER_QUANTITY_UOM)  ------------------- (4)
    LOOP
        SUM_TOT := L.LIST_PRICE * I.ORDERED_QUANTITY;
        NO := NO + I.ORDERED_QUANTITY;
    END LOOP;                                              -----------------------------(4)
    PRICE := SUM_TOT/NO;
END LOOP;              ---------------------------------------------------------------- (1)
 NAMOUNT := PRICE;

EXCEPTION
  WHEN OTHERS THEN
  NAMOUNT := null;
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_ato_pricelist_value ;


 function get_oe_assessable_value
(
  p_customer_id IN NUMBER,
  p_ship_to_site_use_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_uom_code IN VARCHAR2,
  p_default_price IN NUMBER,
  p_ass_value_date IN DATE,    --DEFAULT SYSDATE --Added global variable gd_ass_value_date in package spec. by Ramananda for File.Sql.35
  /* Bug 5096787. Added the following parameters */
  p_sob_id           IN NUMBER   ,
  p_curr_conv_code   IN VARCHAR2 ,
  p_conv_rate        IN NUMBER
)
RETURN NUMBER  IS

    CURSOR address_cur      ( p_ship_to_site_use_id IN NUMBER )
    IS
    SELECT NVL(cust_acct_site_id , 0) address_id
    FROM hz_cust_site_uses_all A -- Removed ra_site_uses_all for Bug# 4434287
    WHERE A.site_use_id = p_ship_to_site_use_id;  /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
    --WHERE A.site_use_id = NVL(p_ship_to_site_use_id,0);

    /*
     Get the assessable Value based on the Customer Id, Address Id, inventory_item_id, uom code, ,Ordered date.
     Exact Match condition
    */
    CURSOR c_assessable_value
                             ( p_customer_id        NUMBER  ,
                               p_address_id         NUMBER  ,
                               p_inventory_item_id  NUMBER  ,
                               p_uom_code           VARCHAR2,
                               p_ordered_date       DATE
                             )
    IS
    SELECT
            b.operand list_price,
            c.product_uom_code list_price_uom_code  ,
                  qlhb.currency_code  /* Added for bug#8844209 */

    FROM
            JAI_CMN_CUS_ADDRESSES a,
            qp_list_lines b,
            qp_pricing_attributes c ,
	    qp_list_headers_b qlhb  /* Added for bug#8844209 */
    WHERE
            a.customer_id           = p_customer_id                                 AND
            a.address_id            = p_address_id                                  AND
            a.price_list_id         = b.LIST_header_ID                              AND
            c.list_line_id          = b.list_line_id                                AND
            c.product_attr_value    = to_char(p_inventory_item_id)                  AND
            c.product_uom_code      = p_uom_code                                    AND
	     qlhb.list_header_id     = b.list_header_id                              AND    /* Added for bug#8844209 */
            p_ordered_date          BETWEEN nvl( qlhb.start_date_active, p_ordered_date)        AND
                                            nvl( qlhb.end_date_active, SYSDATE)            AND
              p_ordered_date          BETWEEN nvl( b.start_date_active, p_ordered_date) AND
                                            nvl( b.end_date_active, SYSDATE);

    /*
     Get the assessable Value based on the Customer Id, Address Id, inventory_item_id, Ordered date.
     Exact Match condition
    */
     --Added by Nagaraj.s for Bug3700249
     CURSOR c_assessable_value_pri_uom(
                                        p_customer_id        NUMBER,
                                        p_address_id         NUMBER,
                                        p_inventory_item_id  NUMBER,
                                        p_ordered_date       DATE
                                      )
     IS
     SELECT
             b.operand list_price,
             c.product_uom_code list_price_uom_code ,
             qlhb.currency_code  /* Added for bug#8844209 */
     FROM
             JAI_CMN_CUS_ADDRESSES a,
             qp_list_lines b,
             qp_pricing_attributes c,
                   qp_list_headers_b qlhb  /* Added for bug#8844209 */
     WHERE
             a.customer_id                           = p_customer_id                      AND
             a.address_id                            = p_address_id                       AND
             a.price_list_id                         = b.list_header_id                   AND
             c.list_line_id                          = b.list_line_id                     AND
             c.product_attr_value                    = to_char(p_inventory_item_id)       AND
             trunc(nvl(b.end_date_active,sysdate))   >= trunc(p_ordered_date)             AND
	       qlhb.list_header_id                     = b.list_header_id                   AND  /* Added for bug#8844209 */
                   nvl(qlhb.active_flag,'N') = 'Y'  AND               /*added for  bug#8844209*/
	     primary_uom_flag               ='Y'; /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
             --nvl(primary_uom_flag,'N')               ='Y';

     CURSOR c_assessable_value_other_uom
                                     (
                                       p_customer_id           NUMBER,
                                       p_address_id            NUMBER,
                                       p_inventory_item_id     NUMBER,
                                       p_ordered_date          DATE
                                     )
     IS
     SELECT
             b.operand list_price,
             c.product_uom_code list_price_uom_code   ,
             qlhb.currency_code  /* Added for bug#8844209 */
     FROM
             JAI_CMN_CUS_ADDRESSES a,
             qp_list_lines b,
             qp_pricing_attributes c,
                   qp_list_headers_b qlhb  /* Added for bug#8844209 */
     WHERE
             a.customer_id                  = p_customer_id                  AND
             a.address_id                   = p_address_id                   AND
             a.price_list_id                = b.LIST_header_ID               AND
             c.list_line_id                 = b.list_line_id                 AND
             c.PRODUCT_ATTR_VALUE           = TO_CHAR(p_inventory_item_id)   AND
	     qlhb.list_header_id            = b.list_header_id               AND  /* Added for bug#8844209 */
             NVL(qlhb.end_date_active,SYSDATE) >= p_ordered_date             AND
             NVL(qlhb.active_flag,'N') = 'Y'                                 AND /*Added for bug#8844209*/
	     (b.end_date_active is null OR b.end_date_active >= p_ordered_date); /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
             --NVL(b.end_date_active,SYSDATE) >= p_ordered_date;

     v_primary_uom_code qp_pricing_attributes.product_uom_code%type; --Added by Nagaraj.s for Bug3700249
     v_other_uom_code   qp_pricing_attributes.product_uom_code%type; --Added by Nagaraj.s for Bug3700249

     v_debug VARCHAR2(1);   --File.Sql.35 Cbabu  := 'N';
     v_address_id NUMBER;
     v_assessable_value NUMBER;
     v_conversion_rate NUMBER;
     v_price_list_uom_code VARCHAR2(4);
     lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_utils_pkg.get_oe_assessable_value';

     /* Added for bug#8844209 */

     lv_assess_val_curr_code VARCHAR2(100) ;
      ln_assess_val_conv_rate  NUMBER ;

     -- add by Xiao for recording down the release version on 27-Jul-2009
     lv_release_name VARCHAR2(30);
     lv_other_release_info VARCHAR2(30);
     lb_result BOOLEAN := FALSE ;

    -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
    ----------------------------------------------------------------------------------------------------------
    -- Get category_set_name
    CURSOR category_set_name_cur
    IS
    SELECT
      category_set_name
    FROM
      mtl_default_category_sets_fk_v
    WHERE functional_area_desc = 'Order Entry';

    lv_category_set_name  VARCHAR2(30);

    -- Get the Excise Assessable Value based on the Customer Id, Address Id, inventory_item_id, uom code, Ordered date.
    CURSOR cust_ass_value_category_cur
    ( pn_party_id          NUMBER
    , pn_address_id        NUMBER
    , pn_inventory_item_id NUMBER
    , pv_uom_code          VARCHAR2
    , pd_ordered_date      DATE
    )
    IS
    SELECT
      b.operand          list_price
    , c.product_uom_code list_price_uom_code,
             qlhb.currency_code  /* Added for bug#8844209 */
    FROM
      jai_cmn_cus_addresses a
    , qp_list_lines         b
    , qp_pricing_attributes c  ,
                   qp_list_headers_b qlhb  /* Added for bug#8844209 */
    WHERE a.customer_id        = pn_party_id
      AND a.address_id         = pn_address_id
      AND a.price_list_id      = b.list_header_id
      AND c.list_line_id       = b.list_line_id
      AND c.product_uom_code   = pv_uom_code
      AND  qlhb.list_header_id            = b.list_header_id                 /* Added for bug#8844209 */
       AND      NVL(qlhb.end_date_active,SYSDATE) >= pd_ordered_date
       AND      NVL(qlhb.active_flag,'N') = 'Y'                                  /*Added for bug#8844209*/
      AND pd_ordered_date BETWEEN NVL( b.start_date_active, pd_ordered_date)
                              AND NVL( b.end_date_active, SYSDATE)
      AND EXISTS ( SELECT
                     'x'
                   FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );

    --Get the Excise Assessable Value based on the Primary Uom, Customer Id, Address Id, inventory_item_id, Ordered date.
     CURSOR cust_ass_value_pri_uom_cur
     ( pn_party_id          NUMBER
     , pn_address_id        NUMBER
     , pn_inventory_item_id NUMBER
     , pd_ordered_date      DATE
     )
     IS
     SELECT
       b.operand          list_price
     , c.product_uom_code list_price_uom_code,
             qlhb.currency_code  /* Added for bug#8844209 */
     FROM
       jai_cmn_cus_addresses a
     , qp_list_lines         b
     , qp_pricing_attributes c   ,
                   qp_list_headers_b qlhb  /* Added for bug#8844209 */
     WHERE a.customer_id                           = pn_party_id
       AND a.address_id                            = pn_address_id
       AND a.price_list_id                         = b.list_header_id
       AND c.list_line_id                          = b.list_line_id
        AND  qlhb.list_header_id            = b.list_header_id                 /* Added for bug#8844209 */
       AND      NVL(qlhb.end_date_active,SYSDATE) >= pd_ordered_date
       AND      NVL(qlhb.active_flag,'N') = 'Y'
       AND TRUNC(NVL(b.end_date_active,SYSDATE))   >= TRUNC(pd_ordered_date)
       AND NVL(primary_uom_flag,'N')               ='Y'
       AND EXISTS ( SELECT
                      'x'
                    FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );

    --Get the Excise Assessable Value based on the Customer Id, Address Id, inventory_item_id, Ordered date.
     CURSOR cust_ass_value_other_uom_cur
     ( pn_party_id          NUMBER
     , pn_address_id        NUMBER
     , pn_inventory_item_id NUMBER
     , pd_ordered_date      DATE
     )
     IS
     SELECT
       b.operand          list_price
     , c.product_uom_code list_price_uom_code,
             qlhb.currency_code  /* Added for bug#8844209 */
     FROM
       jai_cmn_cus_addresses a
     , qp_list_lines         b
     , qp_pricing_attributes c ,
                   qp_list_headers_b qlhb  /* Added for bug#8844209 */
     WHERE a.customer_id                         = pn_party_id
       AND a.address_id                          = pn_address_id
       AND a.price_list_id                       = b.list_header_id
       AND c.list_line_id                        = b.list_line_id
        AND  qlhb.list_header_id            = b.list_header_id                 /* Added for bug#8844209 */
       AND      NVL(qlhb.end_date_active,SYSDATE) >= pd_ordered_date
       AND      NVL(qlhb.active_flag,'N') = 'Y'
       AND TRUNC(NVL(b.end_date_active,SYSDATE)) >= TRUNC(pd_ordered_date)
       AND EXISTS ( SELECT
                      'x'
                    FROM
                     mtl_item_categories_v d
                   WHERE d.category_set_name  = lv_category_set_name
                     AND d.inventory_item_id  = pn_inventory_item_id
                     AND c.product_attr_value = TO_CHAR(d.category_id)
                  );
    ----------------------------------------------------------------------------------------------------------
    --- Added by Jia for Advanced Pricing on 08-Jun-2009, End

BEGIN
     v_debug := 'N';

/*----------------------------------------------------------------------------------------------------------------------------
Change History for File -> get_oe_assessable_value_f.sql
S.No.    DD/MM/YY      Author AND Details
------------------------------------------------------------------------------------------------------------------------------
1        25/03/03      Vijay Shankar for Bug# 2837970, FileVersion: 615.1
                        This function is written for CRM Localization Print Quote Taxes functionality. But this function can be called
            from anywhere in Order Management to fetch the assessable value. Required Parameter needs to be passed during
                        invocation of this procedure.
                        Basically this fetches the assessable value of an ITEM based on the Customer additional information setup
                        If assessable value is not found then it returns the value passed as P_DEFAULT_PRICE
                        This is a duplicate code for jai_cmn_tax_defaultation_pkg.ja_in_cust_default_taxes procedure

2. 2004/14/07  Aiyer - bug # 3700249  File Version 115.2
         Issue
           The assessable value does not get calculated properly.

         Solution
       The following 5 level assessable value derivation logic has been implemented now:-
           Each Logic will come into picture only if the preceding one does not get any value.
           1. Assessable Value is picked up for the Customer Id, Address Id, UOM Code, inventory_item_id,Assessable value date
           2. Assessable Value is picked up for the Customer Id, Null Site, UOM Code, Assessable value date

           3. Assessable Value and Primary UOM is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
              for the Primary UOM defined in Price List.
              Then Inv_convert.Inv_um_conversion is called and the UOM rate is calculated and is included
              as the product of the Assessable value.
           4. Assessable Value is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
              on a first come first serve basis.
           5. If all the above are not found then the initial logic of picking up the Assessable value is followed (Unit selling price)
                and then inv_convert.inv_um_conversion is called and the UOM rate is calculated and is included
                as the product of the Assessable value.

           6. 08-Jun-2009 Jia Li for IL Advanced Pricing.
               There were enhancement requests from customers to enhance the current India Localization functionality
               on assessable values where an assessable value can be defined either based on an item or an item category.

           7. 30-Jul-2009 Jia Li for Bug#8731794
               Add Item-UOM validation for null site level.

     Dependency Due to this Bug:-
          None

Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent           Files          Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
get_oe_assessable_value_f.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
115.2                  3700249      IN60105D2             None           --       Aiyer   14/07/2004   Row introduces to start dependency tracking

----------------------------------------------------------------------------------------------------------------------------------------------------*/

/******************************** Part 1 Get Customer address id ******************************/
    OPEN address_cur(p_ship_to_site_use_id);
    FETCH address_cur INTO v_address_id;
    CLOSE address_cur;


    IF v_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log, 'v_address_id -> '||v_address_id);
    END IF;

    ----------------------------------------------------------------------------------------------------------
    /*
    --Assessable Value Fetching Logic is based upon the following logic now.....
    --Each Logic will come into picture only if the preceding one does not get any value.
    --1. Assessable Value is picked up for the Customer Id, Address Id, UOM Code, inventory_item_id,Assessable value date
    --1.1. Assessable Value of item cetegory is picked up for the Customer Id, Address Id, UOM Code, inventory_item_id,Assessable value date

    --2. Assessable Value is picked up for the Customer Id, Null Site, UOM Code, Assessable value date
    --2.1. Assessable Value of item cetegory is picked up for the Customer Id, Null Site, UOM Code, Assessable value date

    --3. Assessable Value and Primary UOM is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
         for the Primary UOM defined in Price List.
         Then Inv_convert.Inv_um_conversion is called and the UOM rate is calculated and is included
         as the product of the Assessable value.
    --3.1. Assessable Value of item cetegory and Primary UOM is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
         for the Primary UOM defined in Price List.
         Then Inv_convert.Inv_um_conversion is called and the UOM rate is calculated and is included
         as the product of the Assessable value.

    --4. Assessable Value is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
         on a first come first serve basis.
    --4.1. Assessable Value of item cetegory is picked up for the Customer Id, Address Id, inventory_item_id,  Assessable value date
         on a first come first serve basis.

    --5. If all the above are not found then the initial logic of picking up the Assessable value is followed (Unit selling price)
         and then inv_convert.inv_um_conversion is called and the UOM rate is calculated and is included
         as the product of the Assessable value.
    */
    ----------------------------------------------------------------------------------------------------------

    -- Add by Xiao to get release version on 24-Jul-2009
    lb_result := fnd_release.get_release(lv_release_name, lv_other_release_info);

    -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
    ----------------------------------------------------------------------------------------------------------
     -- Get category_set_name
     OPEN category_set_name_cur;
     FETCH category_set_name_cur INTO lv_category_set_name;
     CLOSE category_set_name_cur;

    -- Validate if there is more than one Item-UOM combination existing in used AV list for the Item selected
    -- in the transaction. If yes, give an exception error message to stop transaction.

    -- Add condition by Xiao for specific release version for Advanced Pricing code on 24-Jul-2009
    IF lv_release_name NOT LIKE '12.0%' THEN

    Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_customer_id
                                                   , pn_party_site_id     => v_address_id
                                                   , pn_inventory_item_id => p_inventory_item_id
                                                   , pd_ordered_date      => TRUNC(p_ass_value_date)
                                                   , pv_party_type        => 'C'
                                                   , pn_pricing_list_id   => NULL
                                                   );
    END IF;

    ----------------------------------------------------------------------------------------------------------
    -- Added by Jia for Advanced Pricing on 08-Jun-2009, End


   /********************************************* Part 2 ****************************************/

   /*
    Get the Assessable Value based on the Customer Id, Address Id, UOM Code, inventory_item_id,Ordered date
    Exact Match condition.
   */

    -- Fetch Assessable Price List Value for the given Customer and Location Combination
    OPEN c_assessable_value( p_customer_id, v_address_id, p_inventory_item_id, p_uom_code, trunc(p_ass_value_date));
    FETCH c_assessable_value INTO v_assessable_value, v_price_list_uom_code,lv_assess_val_curr_code; /* Added for bug#8844209 */
    CLOSE c_assessable_value;

    -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
    ----------------------------------------------------------------------------------------------------------

    -- Add condition for specific release version for Advanced Pricing code
    IF lv_release_name NOT LIKE '12.0%' THEN
      IF v_assessable_value IS NULL
      THEN
        -- Fetch Excise Assessable Value of item category for the given Customer, Site, Inventory Item and UOM Combination
        OPEN cust_ass_value_category_cur( p_customer_id
                                      , v_address_id
                                      , p_inventory_item_id
                                      , p_uom_code
                                      , TRUNC(p_ass_value_date)
                                      );
        FETCH
          cust_ass_value_category_cur
        INTO
          v_assessable_value
        , v_price_list_uom_code,lv_assess_val_curr_code; /* Added for bug#8844209 */
        CLOSE cust_ass_value_category_cur;
      END IF; -- v_assessable_value is null for given customer/site/inventory_item_id/UOM
    END IF; --lv_release_name NOT LIKE '12.0%'

    ----------------------------------------------------------------------------------------------------------
    -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

   /********************************************* Part 3 ****************************************/

   /*
    Get the Assessable Value based on the Customer Id, Null Site, UOM Code, inventory_item_id,Ordered date
    Null Site condition.
   */

    IF v_assessable_value IS NULL THEN

        IF v_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,' Inside IF OF v_assessable_value IS NULL ');
        END IF;

        -- Added by Jia for Bug#8731794 on 30-Jul-2009, Begin
        ----------------------------------------------------------------------------------------------------------
        IF lv_release_name NOT LIKE '12.0%' THEN

        Jai_Avlist_Validate_Pkg.Check_AvList_Validation( pn_party_id          => p_customer_id
                                                       , pn_party_site_id     => 0
                                                       , pn_inventory_item_id => p_inventory_item_id
                                                       , pd_ordered_date      => TRUNC(p_ass_value_date)
                                                       , pv_party_type        => 'C'
                                                       , pn_pricing_list_id   => NULL
                                                       );
        END IF;
        ----------------------------------------------------------------------------------------------------------
        -- Added by Jia for Bug#8731794 on 30-Jul-2009, End

        -- Fetch Assessable Price List Value for the
        -- given Customer and NULL LOCATION Combination
        OPEN c_assessable_value( p_customer_id, 0, p_inventory_item_id, p_uom_code, trunc(p_ass_value_date) );
        FETCH c_assessable_value INTO v_assessable_value, v_price_list_uom_code,lv_assess_val_curr_code; /* Added for bug#8844209 */
        CLOSE c_assessable_value;

        -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
        ----------------------------------------------------------------------------------------------------------

        -- Add condition by Xiao for specific release version for Advanced Pricing code on 27-Jul-2009
        IF lv_release_name NOT LIKE '12.0%' THEN

          IF v_assessable_value IS NULL
          THEN
            -- Fetch the VAT Assessable Value of item category
            -- for the given Customer, null Site, Inventory Item Id, UOM and Ordered date Combination.
            OPEN cust_ass_value_category_cur( p_customer_id
                                          , 0
                                          , p_inventory_item_id
                                          , p_uom_code
                                          , TRUNC(p_ass_value_date)
                                          );
            FETCH
              cust_ass_value_category_cur
            INTO
              v_assessable_value
            , v_price_list_uom_code,lv_assess_val_curr_code; /* Added for bug#8844209 */
            CLOSE cust_ass_value_category_cur;
          END IF; -- v_assessable_value is null for given customer/null site/inventory_item_id/UOM
        END IF; -- lv_release_name NOT LIKE '12.0%'

        ----------------------------------------------------------------------------------------------------------
        -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

  END IF;

    IF v_debug = 'Y' THEN
        fnd_file.put_line(fnd_file.log, '2 v_assessable_value -> '||v_assessable_value||', v_price_list_uom_code -> '||v_price_list_uom_code);
    END IF;

   /********************************************* Part 4 ****************************************/

   /*
    Get the Assessable Value based on the Customer Id, Address id, inventory_item_id,primary_uom_code and Ordered date
    Primary UOM condition.
   */

    --Added by Aiyer for Bug 3700249
    IF v_assessable_value is null THEN

      open c_assessable_value_pri_uom
          (
            p_customer_id,
            v_address_id,
            p_inventory_item_id,
            trunc(p_ass_value_date)
          );
      fetch c_assessable_value_pri_uom into v_assessable_value,v_primary_uom_code,lv_assess_val_curr_code; /* Added for bug#8844209 */
      close c_assessable_value_pri_uom;

      IF v_primary_uom_code is not null THEN

        inv_convert.inv_um_conversion
          (
            p_uom_code,
            v_primary_uom_code,
            p_inventory_item_id,
            v_conversion_rate
          );


        IF nvl(v_conversion_rate, 0) <= 0 THEN
          Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
          IF NVL(v_conversion_rate, 0) <= 0 THEN
            v_conversion_rate := 0;
          END IF;
        END IF;

        v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;

    ELSE
        -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
        ----------------------------------------------------------------------------------------------------------
        -- Fetch the Excise Assessable Value of item category and Primary UOM
        -- for the given Customer, Site, Inventory Item Id, Ordered date Combination.

        -- Add condition by Xiao for specific release version for Advanced Pricing code on 27-Jul-2009
        IF lv_release_name NOT LIKE '12.0%' THEN

        OPEN cust_ass_value_pri_uom_cur( p_customer_id
                                       , v_address_id
                                       , p_inventory_item_id
                                       , TRUNC(p_ass_value_date)
                                       );
        FETCH
          cust_ass_value_pri_uom_cur
        INTO
          v_assessable_value
        , v_primary_uom_code,lv_assess_val_curr_code; /* Added for bug#8844209 */
        CLOSE cust_ass_value_pri_uom_cur;

        IF v_primary_uom_code IS NOT NULL
        THEN
          inv_convert.inv_um_conversion( p_uom_code
                                       , v_primary_uom_code
                                       , p_inventory_item_id
                                       , v_conversion_rate
                                       );

          IF NVL(v_conversion_rate, 0) <= 0
          THEN
            Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
            IF NVL(v_conversion_rate, 0) <= 0
            THEN
              v_conversion_rate := 0;
            END IF;
          END IF;

          v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;
        END IF; -- v_primary_uom_code IS NOT NULL for Customer/Site/Inventory_item_id

        END IF; -- lv_release_name NOT LIKE '12.0%'

        IF v_assessable_value IS NULL
        THEN
        ----------------------------------------------------------------------------------------------------------
        -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

        /* Primary uom code setup not found for the customer id, address id, inventory_item_id and ordered_date.
             Get the assessable value for a combination of customer id, address id, inventory_item_id
         and ordered_date. Pick up the assessable value by first come first serve basis.
          */

          OPEN c_assessable_value_other_uom
            (
              p_customer_id,
              v_address_id,
              p_inventory_item_id,
              trunc(p_ass_value_date)
            );
          FETCH c_assessable_value_other_uom into v_assessable_value,v_other_uom_code,lv_assess_val_curr_code; /* Added for bug#8844209 */
          CLOSE c_assessable_value_other_uom;

          IF v_other_uom_code is not null THEN
            inv_convert.inv_um_conversion
              (
                p_uom_code,
                v_other_uom_code,
                p_inventory_item_id,
                v_conversion_rate
              );

            IF nvl(v_conversion_rate, 0) <= 0 THEN

              Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );

              IF NVL(v_conversion_rate, 0) <= 0 THEN
                v_conversion_rate := 0;
              END IF;
            END IF;
            v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;

          -- Added by Jia for Advanced Pricing on 08-Jun-2009, Begin
          ----------------------------------------------------------------------------------------------------------
          ELSE
            -- Primary uom code setup not found for the Customer, Site, Inventory Item Id and Ordered_date.
            -- Fetch the Excise Assessable Value of item category and other UOM
            -- for the given Customer, Site, Inventory Item Id, Ordered date Combination.


            -- Add condition by Xiao for specific release version for Advanced Pricing code on 27-Jul-2009
            IF lv_release_name NOT LIKE '12.0%' THEN

            OPEN cust_ass_value_other_uom_cur( p_customer_id
                                              , v_address_id
                                              , p_inventory_item_id
                                              , TRUNC(p_ass_value_date)
                                              );
            FETCH
              cust_ass_value_other_uom_cur
            INTO
              v_assessable_value
            , v_other_uom_code,lv_assess_val_curr_code; /* Added for bug#8844209 */
            CLOSE cust_ass_value_other_uom_cur;

            IF v_other_uom_code IS NOT NULL
            THEN
              inv_convert.inv_um_conversion( p_uom_code
                                           , v_other_uom_code
                                           , p_inventory_item_id
                                           , v_conversion_rate
                                           );

              IF NVL(v_conversion_rate, 0) <= 0
              THEN
                Inv_Convert.inv_um_conversion( p_uom_code, v_primary_uom_code, 0, v_conversion_rate );
                IF NVL(v_conversion_rate, 0) <= 0
                THEN
                  v_conversion_rate := 0;
                END IF;
              END IF;

              v_assessable_value :=  NVL(v_assessable_value,0) * v_conversion_rate;
            END IF; -- v_other_uom_code is not null for Customer/Site/Inventory_item_id

            END IF; -- lv_release_name NOT LIKE '12.0%'

          ----------------------------------------------------------------------------------------------------------
          -- Added by Jia for Advanced Pricing on 08-Jun-2009, End

          END IF; --end if for v_other_uom_code is not null
        END IF; -- v_assessable_value is null, Added by Jia for Advanced Pricing on 08-Jun-2009.
      END IF; --end if for v_primary_uom_code is not null
    END IF; --end if for v_assessable_value
    --Ends here..........................


    /*
    IF NVL(v_assessable_value,0) > 0 THEN

        -- If still the Assessable Value is available
        IF v_price_list_uom_code IS NOT NULL THEN

            IF v_debug = 'Y' THEN
                fnd_file.put_line(fnd_file.log,' BEFORE Calling Inv_Convert.inv_um_conversion 1');
            END IF;

            Inv_Convert.inv_um_conversion ( v_uom_code, v_price_list_uom_code, v_inventory_item_id, v_conversion_rate );
            IF NVL(v_conversion_rate, 0) <= 0 THEN

                IF v_debug = 'Y' THEN
                    fnd_file.put_line(fnd_file.log,' BEFORE Calling Inv_Convert.inv_um_conversion 2');
                END IF;

                Inv_Convert.inv_um_conversion(v_uom_code, v_price_list_uom_code, 0, v_conversion_rate);
                IF NVL(v_conversion_rate, 0) <= 0 THEN
                    v_conversion_rate := 0;
                END IF;

            END IF;

        END IF;

        v_assessable_value := nvl(v_assessable_value,0) * v_conversion_rate;
        -- v_assessable_value := NVL(1/v_converted_rate,0) * NVL(v_assessable_value,0) * v_conversion_rate;
        -- v_assessable_amount := NVL(v_assessable_value,0) * v_line_quantity;

    ELSE

        IF v_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,' inside ELSE OF v_assessable_value IS NULL ');
        END IF;

        -- If the assessable value is not available
        -- then pick up the Line price for Tax Calculation
        v_assessable_value  := NVL(p_default_price, 0);
        -- v_assessable_amount := v_line_amount;

    END IF; -- v_assessable_value IS NULL THEN
    */

  IF nvl(v_assessable_value,0) =0 THEN
        IF v_debug = 'Y' THEN
            fnd_file.put_line(fnd_file.log,' No Assessable value is defined, so default price is returning back ');
        END IF;

        v_assessable_value  := NVL(p_default_price, 0);
 ELSE

        /* Added for bug#8844209 */
        ln_assess_val_conv_rate :=jai_cmn_utils_pkg.currency_conversion (
                                  p_sob_id,
                                  lv_assess_val_curr_code,
                                  NULL,
                                  p_curr_conv_code,
                                  NULL
                                );

         v_assessable_value := v_assessable_value*(ln_assess_val_conv_rate/nvl(p_conv_rate,1));
         /* end bug#8844209 */

    END IF;

    RETURN v_assessable_value;
EXCEPTION
  WHEN OTHERS THEN
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;

END get_oe_assessable_value;



procedure get_ato_assessable_value
(
  NEW_ASSESS_LIST NUMBER,
  IL6 NUMBER ,
  NAMOUNT OUT NOCOPY NUMBER
)
IS
  APRICE  NUMBER;
  ASUM_TOT  NUMBER;
  ANO   NUMBER;

-- Changed For Migration To R11i on 17-10-2000 by A.Raina
-- Table "SO_LINES_ALL IS REPLACED BY "OE_ORDER_LINES_ALL"
-- so field "UNIT_CODE" is replace by "ORDER_QUANTITY_UOM" .
-- Also table "SO_PRICE_LIST_LINES" is replaced by "SO_PRICE_LIST_LINES_115"

  CURSOR ASEL_LINE_ID IS
  SELECT LINE_ID,ORDERED_QUANTITY,ORDER_QUANTITY_UOM,INVENTORY_ITEM_ID
    FROM OE_ORDER_LINES_ALL
   WHERE LINE_ID = IL6;

  CURSOR ASEL_ATO_LINES(LN_ID NUMBER) IS
  SELECT LINE_ID,ATO_LINE_ID,ORDERED_QUANTITY,INVENTORY_ITEM_ID,ORDER_QUANTITY_UOM
    FROM OE_ORDER_LINES_ALL
   WHERE ATO_LINE_ID = LN_ID;

  CURSOR AN_LIST_PRICE (INVENT NUMBER,UNT NUMBER,NEW_NO NUMBER) IS
  SELECT LIST_PRICE
    FROM SO_PRICE_LIST_LINES_115
   WHERE INVENTORY_ITEM_ID = INVENT
     AND UNIT_CODE = UNT
     AND PRICE_LIST_ID = NEW_NO
     AND SYSDATE BETWEEN
     NVL(START_DATE_ACTIVE,SYSDATE)
     AND NVL(END_DATE_ACTIVE,SYSDATE);

  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_om_utils_pkg.get_ato_assessable_value';

BEGIN
   FOR I IN ASEL_LINE_ID
   LOOP
       FOR J IN ASEL_ATO_LINES(I.LINE_ID)
       LOOP
          FOR K IN AN_LIST_PRICE(J.INVENTORY_ITEM_ID,J.ORDER_QUANTITY_UOM,NEW_ASSESS_LIST)
          LOOP
            ASUM_TOT := K.LIST_PRICE * J.ORDERED_QUANTITY;
          END LOOP;
       END LOOP;
       FOR L IN AN_LIST_PRICE(I.INVENTORY_ITEM_ID,I.ORDER_QUANTITY_UOM,NEW_ASSESS_LIST)
       LOOP
            ASUM_TOT := L.LIST_PRICE * I.ORDERED_QUANTITY;
            ANO :=  I.ORDERED_QUANTITY;
       END LOOP;
           APRICE := ASUM_TOT/ANO;
  END LOOP;
    NAMOUNT := APRICE;
EXCEPTION
  WHEN OTHERS THEN
  namount := null;
  FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
  FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
  app_exception.raise_exception;
END get_ato_assessable_value;


FUNCTION validate_excise_exemption
(
  p_line_id                   JAI_OM_OE_SO_LINES.LINE_ID%TYPE               ,
  p_excise_exempt_type        JAI_OM_OE_SO_LINES.EXCISE_EXEMPT_TYPE%TYPE    ,
  p_line_number               JAI_OM_OE_SO_LINES.LINE_NUMBER%TYPE           ,
  p_shipment_line_number      JAI_OM_OE_SO_LINES.SHIPMENT_LINE_NUMBER%TYPE  ,
  p_error_msg       OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
/***************************************************************************************************************************************************************

Created By          : Aiyer

Created Date        : 11-Feb-2004

Bug                 : 3436541

Purpose             : This function validates the different valid combination of values that can exist  between
                      JAI_OM_OE_SO_LINES.excise_exempt_type and tax types associated with the table JAI_OM_OE_SO_TAXES

                      A sales order In India Localization Order Management should be allowed to be shipped only when the
                      following conditions are satisfied: -
                      1. A Sales order with excise exemption types (field JAI_OM_OE_SO_LINES.excise_exempt_type) like
                         'EXCISE_EXEMPT_CERT', 'CT2','CT3' should not have Modvat Receovery type of taxes attached
                         ( table JAI_OM_OE_SO_TAXES)

                      2.  A Sales order with excise exemption types (field JAI_OM_OE_SO_LINES.excise_exempt_type) like
                          'EXCISE_EXEMPT_CERT_OTH', 'CT2_OTH' should have modvat recovery type of tax attached
                           ( table JAI_OM_OE_SO_TAXES)

                      3.  A sales order which does not have any excise exemptions specified (Null value for field
                          JAI_OM_OE_SO_LINES.excise_exempt_type) should not have any Modvat Recovery type of taxes
                          ( table JAI_OM_OE_SO_TAXES).

                      This function returns an error when any of the above conditions are not satisified.

Return Status       : Returns 'EE' -> Expected Error
                                      Out parameter p_error_msg populated with business logic violation message.

                      Returns 'UE' -> Unexpected Error
                                      Out parameter p_error_msg populated with sqlerrm error message.

                      Returns 'S'  -> Indicates Success.
                                      Out parameter p_error_msg populated with Null value

Called From         : 1. Procedure validate_exc_exmpt_cond (which is called from Key Exit trigger)
                         in the Sales Order India Localization Form (File Name JAINEORD.fmb ).

                      2. Trigger ja_in_wsh_dlry_au_rel_stat_trg  (File Name ja_in_wsh_dlry_au_rel_stat_trg.sql).

                      Dependency Due To The Current Bug :
                      1. Form JAINEORD.fmb (618.3) and Trigger ja_in_wsh_dlry_au_rel_stat_trg.sql (618.1)
                         call the function ->validate_excise_exemption(618.1)

Change History
==============
Future Dependencies For the release Of this Object:-
(Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
A datamodel change )

----------------------------------------------------------------------------------------------------------------------------------------------------
Current Version       Current Bug    Dependent          Files          Version   Author   Date         Remarks
Of File                              On Bug/Patchset    Dependent On
validate_excise_exemption_f.sql
----------------------------------------------------------------------------------------------------------------------------------------------------
618.1                  3436541       IN60105D2          None             --       Aiyer   11/02/2004   This object is not dependent on any object however,
                                                                                                       this object is called from Form JAINEORD.fmb and
                                                                                                       trigger ja_in_wsh_dlry_au_rel_stat_trg.sql
----------------------------------------------------------------------------------------------------------------------------------------------------

***********************************************************************************************************************************************************/
IS
   CURSOR c_chk_modvat_rectax
   IS
   SELECT
                        '1'
   FROM
                        JAI_OM_OE_SO_TAXES      tl,
                        JAI_CMN_TAXES_ALL         tc
   WHERE
                        tc.tax_type = jai_constants.tax_type_modvat_recovery AND /*--'Modvat Recovery'  Ramananda for removal of SQL LITERALs :bug#4428980*/
                        tc.tax_id   = tl.tax_id          AND
                        tl.line_id  = p_line_id ;

   lv_exists                            VARCHAR2(1)   ;

  BEGIN

    p_error_msg := NULL;
    OPEN  c_chk_modvat_rectax;
    FETCH c_chk_modvat_rectax INTO lv_exists;
    /*
      Validate that EXCISE_EXEMPT_CERT, CT2,CT3 types of exemption types should not have
      modvat types of taxes attached because the basis of the modvat reversal will be based on
      the setup in the additional organization information.
    */
   IF nvl(p_excise_exempt_type,'###') IN ('EXCISE_EXEMPT_CERT_OTH', 'CT2_OTH') THEN
     IF c_chk_modvat_rectax%NOTFOUND THEN
       CLOSE c_chk_modvat_rectax;
       p_error_msg := 'Modvat Type of a tax must be entered for the Sales Order line with Line Number ' ||p_line_number ||
                                       ' and Shipment line Number '||p_shipment_line_number;
       return ('EE');
     END IF;

   /*
      For the EXCISE_EXEMPT_CERT_OTH, CT2_OTH types of excise exemptions , modvat recovery type
      of tax has to be entered and the modvat recovery will be done based on the actual amount of
      excise tax levied in the sales order.
      Also sales order which does not have any excise exemptions specified should not have any Modvat Recovery type of taxes
   */
   ELSIF nvl(p_excise_exempt_type,'###') IN ('###','EXCISE_EXEMPT_CERT', 'CT2', 'CT3') THEN
     IF c_chk_modvat_rectax%FOUND THEN
        CLOSE c_chk_modvat_rectax;
        p_error_msg :=  'Modvat Type of a tax should not be entered for the line with Line Number ' ||p_line_number ||
                        ' and Shipment line Number '||p_shipment_line_number;
       return ('EE');
     END IF;
   END IF;
   CLOSE c_chk_modvat_rectax;
   p_error_msg := NULL;
   return ('S');

Exception

WHEN OTHERS THEN
   /* Handle all unexpected errors. */
    p_error_msg := 'Unexpected error occured in function validate_excise_exemption - '||sqlerrm;
    return jai_constants.unexpected_error;
END validate_excise_exemption;

END jai_om_utils_pkg;

/
