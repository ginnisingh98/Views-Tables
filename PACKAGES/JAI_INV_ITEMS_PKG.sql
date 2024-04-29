--------------------------------------------------------
--  DDL for Package JAI_INV_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_INV_ITEMS_PKG" 
/* $Header: jai_inv_items.pls 120.2.12010000.2 2010/01/28 12:58:38 csahoo ship $ */
AUTHID CURRENT_USER AS
 /*  */
 /* ------------------------------------------------------------------------------------------------------------------------------------------------
  FILENAME: jai_items_pkg_s.pls  CHANGE HISTORY:
  SlNo.  DD/MM/YYYY       Author and Details of Modifications
  -------------------------------------------------------------------------------------------------------------------------------------------------
  1.   22/04/2005       Brathod for Bug # 4299606 (Item DFF Elimination), File Version 116.1

                        Issue:- Item DFF Needs to be eliminated
  Package fie is renamed to JAI_INV_ITEMS_PKG.PLS
  -----------------------------------------------
  2.   24/05/2005         Brathod, For Bug# 4389149 (Item Code Hook - API), File Version 116.1
                          Issue:-
                          Code hook (API) needs to developed that will be called when item is either
                          copied, assigned, deleted or imported in the base item form.
                          Fix:-
                          To support this functionality a procedure PROPAGATE_ITEM_ACTION is developed
                          which accepts the base action as well as pl/sql table as inventory items to be processed.
                          The procedure will be able to process items in bulk so that only one call from base item
                          form can propagate changes in many items.  Each row in plsql table PT_ITEM_DATA will be
                          a comman (,) seperated string depending upon the PV_ACTION_TYPE argument.
                          (For more details regarding possible values for each argument and format of the string
                          for each PV_ACTION_TYPE argument please refere the bug# 4389149)

3. 08-Jun-2005  Version 116.2 jai_inv_items -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

4. 15-Jul-2005            Brathod, For Bug# 4496223 Version 117.2
                          Issue: -
                          The Code hook API for IL Item currently accepts datatype of the type
                          table_item which is pl-sql table of varchar2(100).  But as the code hook
                          needs to be called by base application it should not have any depedancy on IL
                          Product.  Use of this data type introduces the dependancy of IL.
                          Solution:-
                          To avoid this the datatype should be independent of product.  The pl-sql table
                          type aregument is removed from PROPAGATE_ITEM_ACTION procedure and added
                          the following four simple arguments
                          1. pn_organization_id   - NUMBER - Destination Organization
                          2. pn_inventory_item_id - NUMBER - Destination Inventory Item
                          3. pn_source_organization_id   - NUMBER - Source Organization
                          4. pn_source_inventory_item_id - NUMBER - Source Inventory Item
                            of TABLE_ITEMS.

5.  28-JAN-2010           CSahoo for bug#9191274, File Version: 120.2.12000000.2
                          ISSUE: VAT ITEM ATTRIBUTES NOT ASSIGNED AUTOMATICALLY FOR STAR ITEM,  AFTER CONFIGURATI
                          Fix: Added a parameter pn_regime_code to the procedure copy_items.


  Future Dependencies For the release Of this Object:-
  (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
  A datamodel change )

  -------------------------------------------------------------------------------------------------------------------------------------------------
  Current Version       Current Bug    Dependent         Dependency On Files       Version   Author   Date          Remarks
  Of File                              On Bug/Patchset
  jai_items_pkg_s.sql
  --------------------------------------------------------------------------------------------------------------------------------------------------
  115.0                 4245134       IN60105D2         VAT Objects                115.0     Brathod  17-Mar-2005   Technical Dependacny
                                      +4245089
  --------------------------------------------------------------------------------------------------------------------------------------------------*/
  TYPE type_rec_jmsi_attribs IS RECORD
  (
    item_class        JAI_INV_ITM_SETUPS.item_class%TYPE
  , modvat_flag       JAI_INV_ITM_SETUPS.modvat_flag%TYPE
  , item_tariff       JAI_INV_ITM_SETUPS.item_tariff%TYPE
  , item_folio        JAI_INV_ITM_SETUPS.item_folio%TYPE
  , excise_flag       JAI_INV_ITM_SETUPS.excise_flag%TYPE
  , trading_flag      JAI_INV_ITM_SETUPS.item_trading_flag%TYPE
  , count             NUMBER
  );

  TYPE type_rec_rgm_itm_attribs IS RECORD
  (
     attribute_code   JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_CODE%TYPE
    ,attribute_value  JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_VALUE%TYPE
  );

  TYPE type_tab_attributes IS TABLE OF type_rec_rgm_itm_attribs
  INDEX BY BINARY_INTEGER;

  gr_jmsi_attribs type_rec_jmsi_attribs;
  gt_attributes   type_tab_attributes;

  /*  Added by Brathod for bug#4389149 */

   -- TYPE table_items IS TABLE OF VARCHAR2 (100) -- Bug# 4496223
   -- INDEX BY BINARY_INTEGER;

  /*  End of Bug# 4389149 */

  /*  API to find out attribute of particular inventory item */
  PROCEDURE jai_get_attrib
                      ( p_regime_code       IN   JAI_RGM_ITM_TEMPLATES.REGIME_CODE%TYPE ,
                        p_organization_id   IN   JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE ,
                        p_inventory_item_id IN   JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE ,
                        p_attribute_code    IN   JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_CODE%TYPE,
                        p_attribute_value OUT NOCOPY JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_VALUE%TYPE,
                        p_process_flag OUT NOCOPY VARCHAR2 ,
                        p_process_msg OUT NOCOPY VARCHAR2
                      );
  /*  This function will create template and retrun the newly created template_id */
  FUNCTION jai_create_template(   p_regime_code   JAI_RGM_ITM_TEMPLATES.REGIME_CODE%TYPE
                                , p_template_name JAI_RGM_ITM_TEMPLATES.TEMPLATE_NAME%TYPE
                                , p_description   JAI_RGM_ITM_TEMPLATES.DESCRIPTION%TYPE DEFAULT NULL
                             )
  RETURN NUMBER;
  /*  Procedure to assign template to particular / all inventory items in organization */
  PROCEDURE jai_assign_template(  p_template_id       JAI_RGM_ITM_TEMPLATES.TEMPLATE_ID%TYPE
                                , p_organization_id   JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE
                                , p_inventory_item_id JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE DEFAULT NULL
                              ) ;
  /*  Procedure to create item specific registration */
  PROCEDURE jai_create_item_regns ( p_regime_code       JAI_RGM_ITM_REGNS.REGIME_CODE%TYPE
                                   ,p_organization_id   JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE
                                   ,p_inventory_item_id JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE
                                   ,p_tab_attributes    jai_inv_items_pkg.GT_ATTRIBUTES%TYPE
                                  );
  /*  Procedure will create either item/template attributes based on attributes passed as pl-sql table */
  PROCEDURE jai_create_attribs ( p_template_id        JAI_RGM_ITM_TEMPLATES.TEMPLATE_ID%TYPE
                                ,p_rgm_item_regns_id  JAI_RGM_ITM_REGNS.RGM_ITEM_REGNS_ID%TYPE
                                ,p_tab_attributes     jai_inv_items_pkg.GT_ATTRIBUTES%TYPE
                                );
  /*  Synchronization procedure for JAI_INV_ITM_SETUPS table */
  PROCEDURE jai_synchronize_jmsi (p_synchronization_number JAI_INV_ITM_SETUPS.SYNCHRONIZATION_NUMBER%TYPE DEFAULT NULL
                                 );


 /*  Added by Brathod for bug#4389149 */
 /* India Localization code hook for Base item copy/delete/assignment/import action */
 PROCEDURE propagate_item_action
  (
    pv_action_type                IN    VARCHAR2
  --, pt_item_data                IN    dbms_utility.uncl_array  -- TABLE_ITEMS, Bug# 4496223
  , pn_organization_id            IN    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
  , pn_inventory_item_id          IN    MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
  , pn_source_organization_id     IN    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
  , pn_source_inventory_item_id   IN    MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
  , pn_set_process_id             IN    NUMBER
  , pv_called_from                IN    VARCHAR2
  );
 PROCEDURE  copy_items
              ( pn_organization_id          MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
               ,pn_inventory_item_id        MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
               ,pn_source_organization_id   MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
               ,pn_source_inventory_item_id MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
               ,pn_regime_code              JAI_RGM_ITM_REGNS.REGIME_CODE%TYPE DEFAULT 'EXCISE' --added for bug#9191274
              );

 PROCEDURE  delete_items
              ( pn_organization_id    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
               ,pn_inventory_item_id  MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
              );

 /*  End of Bug# 4389149 */

END jai_inv_items_pkg;

/
