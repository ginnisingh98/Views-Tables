--------------------------------------------------------
--  DDL for Package Body JAI_INV_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_INV_ITEMS_PKG" AS
/* $Header: jai_inv_items.plb 120.4.12010000.2 2010/01/28 13:00:53 csahoo ship $ */
PROCEDURE jai_get_attrib
                      ( p_regime_code       IN   JAI_RGM_ITM_TEMPLATES.REGIME_CODE%TYPE ,
                        p_organization_id   IN   JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE ,
                        p_inventory_item_id IN   JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE ,
                        p_attribute_code    IN   JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_CODE%TYPE,
                        p_attribute_value OUT NOCOPY JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_VALUE%TYPE,
                        p_process_flag OUT NOCOPY VARCHAR2 ,
                        p_process_msg OUT NOCOPY VARCHAR2
                      )
  IS
  /**********************************************************************************
  ||  This procedure will return the attribute_value (as OUT parameter)
  ||  given the regime_code, organization_id, inventory_item_id and attribute_code.
  ||  If the precess is successful it will return proces_flag ='SS' else it may return
  ||  process_flag='EE' (Expected Error) or process_flag = 'UE' (Unexpected Error)
  ||  and the process_msg will return the error message.
  ||  -------------------------------------------------------------------------------
  ||  Recommended variable declaration in calling module
  ||  process_msg   VARCHAR2 (1000) ;
  ||  process_flag  VARCHAR2 (2);
  ************************************************************************************/

    LV_ATTRIBUTE_VALUE      JAI_RGM_ITM_TMPL_ATTRS.ATTRIBUTE_VALUE%TYPE      DEFAULT NULL ;
-- Added by sacsethi for bug 5631784 on 31-01-2007
    LN_RGM_ITEM_REGNS_ID    JAI_RGM_ITM_TMPL_ATTRS.RGM_ITEM_REGNS_ID%TYPE    DEFAULT NULL ;
    LN_TEMPLATE_ID          JAI_RGM_ITM_TMPL_ATTRS.TEMPLATE_ID%TYPE          DEFAULT NULL ;
    LV_ITEM_NAME            MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE ;
--END 5631784

    /* Added by Brathod from bug# 4299606 */
  CURSOR cur_get_item_attrib
  IS
  SELECT attribute_value , template_id , rgm_item_regns_id
  FROM   jai_rgm_item_attrib_v
  WHERE  attribute_code     = p_attribute_code
  AND    inventory_item_id  = p_inventory_item_id
  AND    organization_id    = p_organization_id
  AND    regime_code        = p_regime_code;
-- Added by sacsethi for bug 5631784 on 31-01-2007

 CURSOR C_GET_ITEM_NAME
   IS
      SELECT  CONCATENATED_SEGMENTS
      FROM    MTL_SYSTEM_ITEMS_KFV
      WHERE   ORGANIZATION_ID   = P_ORGANIZATION_ID
      AND     INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID;
--END 5631784
  BEGIN

  /* ------------------------------------------------------------------------------------------------------------------------------------------------
  FILENAME: jai_items_pkg_b.sql  CHANGE HISTORY:
  SlNo.  DD/MM/YYYY       Author and Details of Modifications
  -------------------------------------------------------------------------------------------------------------------------------------------------
  1.   22/04/2005   Brathod for Bug # 4299606 (Item DFF Elimination), File Version 116.1

        Issue:- Item DFF Needs to be eliminated

  Package fie is renamed to JAI_INV_ITEMS_PKG.PLB
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


3.      08-Jun-2005      Version 116.3 jai_inv_items -Object is Modified to refer to New DB Entity names in place of
                         Old DB Entity Names as required for CASE COMPLAINCE.
4.      13-Jun-2005      File Version: 116.4
                         Ramananda for bug#4428980. Removal of SQL LITERALs is done

5.      13-Jun-2005     File Version: 116.2
                         Ramananda for bug#4428980. Removal of SQL LITERALs is done

6.      15-Jul-2005     Brathod, For Bug# 4496223 Version 117.2
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

7.      16-Aug-2005     Brathod, For Bug#4554851, File Version 120.3
                        Issue :-  Item Classification form allows multiple template assign ment
                                  for same organization item combination
                        Solution:- Added a regime_code condition in cursor cur_get_itm_attribs
                                   to fetch only attribute value for EXCISE regime.
                        Dependency
                        ----------
                        JAIITMCL.fmb (120.5)

8.      31-01-2007      SACSETHI , FOR BUG#5631784 , File Version #120.4

                        FORWARD PORTING BUG FROM 11I BUG 4742259
                        NEW ENH: TAX COLLECTION AT SOURCE IN RECEIVABLES

                        Changes -

                        Object Type     Object Name     Change                 Description
                        -----------------------------------------------------------------------------------------------------
                        VARIABLE      LN_RGM_ITEM_REGNS_ID             NEW                   FOR TCS TO CHECK ITEMS REGIME ID
                        VARIABLE      LN_TEMPLATE_ID                   NEW                   FOR TEMPLATE_ID
                        VARIABLE      LV_ITEM_NAME                     NEW                   ITEM NAME USED TO SEND TO CALLING OBJECT

9.      28-Jan-2010     CSahoo for bug#9191274, File Version 120.3.12000000.3
                        ISSUE: VAT ITEM ATTRIBUTES NOT ASSIGNED AUTOMATICALLY FOR STAR ITEM,  AFTER CONFIGURATI
                        FIX:  Added a parameter pn_regime_code to the procedure copy_items. Further modified the code to
                              copy the VAT attributes also.


  Future Dependencies For the release Of this Object:-
  (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
  A datamodel change )

  -------------------------------------------------------------------------------------------------------------------------------------------------
  Current Version       Current Bug    Dependent         Dependency On Files       Version   Author   Date          Remarks
  Of File                              On Bug/Patchset
  jai_inv_items_pkg_b.sql
  --------------------------------------------------------------------------------------------------------------------------------------------------
  115.0                 4245134       IN60105D2         VAT Objects                115.0     Brathod  17-Mar-2005   Technical Dependacny
                                      +4245089
  --------------------------------------------------------------------------------------------------------------------------------------------------*/

    IF p_regime_code IS NULL THEN
      p_process_flag := jai_constants.expected_error;
      p_process_msg := 'Regime cannot be null';
      return ;
    END IF;

    IF p_organization_id IS NULL THEN
      p_process_flag := jai_constants.expected_error;
      p_process_msg := 'Organization cannot be null';
      return ;
    END IF;

    IF p_inventory_item_id IS NULL THEN
      p_process_flag := jai_constants.expected_error;
      p_process_msg := 'Item cannot be null';
      return ;
    END IF;

    OPEN cur_get_item_attrib;
    FETCH cur_get_item_attrib INTO lv_attribute_value  ,LN_RGM_ITEM_REGNS_ID ,LN_TEMPLATE_ID  ;
    CLOSE cur_get_item_attrib;

-- Added by sacsethi for bug 5631784 on 31-01-2007

    IF LN_RGM_ITEM_REGNS_ID IS NULL AND LN_TEMPLATE_ID IS NULL THEN
        OPEN  C_GET_ITEM_NAME;
        FETCH C_GET_ITEM_NAME INTO LV_ITEM_NAME;
        CLOSE C_GET_ITEM_NAME;

  p_process_flag := jai_constants.expected_error;
        p_process_msg  :=   'Cannot find item classification for "'||p_regime_code||'" regime and "'|| lv_item_name || '" item of '||p_organization_id ||' organization(id)';
    RETURN ;
    END IF ;
-- END 5631784


    IF lv_attribute_value IS NULL THEN
        p_process_flag := jai_constants.expected_error;
        p_process_msg  := 'Given item is either not registered with template or does not have the given attribute';
    ELSE
      p_attribute_value := lv_attribute_value;
      p_process_flag    := jai_constants.successful;
      p_process_msg     :=  null;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_attribute_value := null;
      p_process_flag    := jai_constants.unexpected_error;
      p_process_msg     := substr (sqlerrm,1,999) ;

  END jai_get_attrib;

  /*------------------------------------------- CREATE TEMPLATE -------------------------------------------*/

  FUNCTION jai_create_template(   p_regime_code       JAI_RGM_ITM_TEMPLATES.REGIME_CODE%TYPE
                                , p_template_name     JAI_RGM_ITM_TEMPLATES.TEMPLATE_NAME%TYPE
                                , p_description       JAI_RGM_ITM_TEMPLATES.DESCRIPTION%TYPE DEFAULT NULL
                               )
  RETURN NUMBER
  AS

    ln_template_id    JAI_RGM_ITM_TEMPLATES.TEMPLATE_ID%TYPE DEFAULT NULL;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_inv_items_pkg.jai_create_template';
  BEGIN -- Create Template

    --SELECT JAI_RGM_ITM_TEMPLATES_S.NEXTVAL    INTO   ln_template_id    FROM   DUAL;

    INSERT INTO JAI_RGM_ITM_TEMPLATES
                (
                   template_id
                 , template_name
                 , description
                 , regime_code
                 , creation_date
                 , created_by
                 , last_update_date
                 , last_updated_by
                 , last_update_login
                )
          VALUES
                (
                    --ln_template_id
        JAI_RGM_ITM_TEMPLATES_S.NEXTVAL  /* Modified by Ramananda for removal of SQL LITERALs */
                  , p_template_name
                  , p_description
                  , p_regime_code
                  , sysdate
                  , fnd_global.user_id
                  , sysdate
                  , fnd_global.user_id
                  , fnd_global.login_id
                )
    RETURNING template_id INTO ln_template_id;

    RETURN ln_template_id ;

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END jai_create_template;
/*---------------------------------------------- ASSIGN TEMPLATE ----------------------------------------*/

  PROCEDURE jai_assign_template( p_template_id       JAI_RGM_ITM_TEMPLATES.TEMPLATE_ID%TYPE
                               , p_organization_id   JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE
                               , p_inventory_item_id JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE DEFAULT NULL
                               )
  AS

    CURSOR cur_get_items
      IS
      SELECT inventory_item_id
      FROM   JAI_INV_ITM_SETUPS
      WHERE  organization_id = p_organization_id
      AND    inventory_item_id = p_inventory_item_id;

    CURSOR cur_chk_templ_org
      IS
      SELECT templ_org_regns_id
      FROM   JAI_RGM_TMPL_ORG_REGNS torg
      WHERE  torg.organization_id = p_organization_id
      AND    torg.template_id     = p_template_id;

    ln_templ_org_regns_id JAI_RGM_TMPL_ORG_REGNS.TEMPL_ORG_REGNS_ID%TYPE DEFAULT NULL;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_inv_items_pkg.jai_assign_template';

    /* --------------------------------------  Local Procedure ---------------------------------------*/
    PROCEDURE assign_template (p_templ_id   JAI_RGM_ITM_TEMPLATES.TEMPLATE_ID%TYPE
                              ,p_org_id     JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE
                              ,p_inv_itm_id JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE
                              ,p_templ_org_regns_id  IN OUT NOCOPY JAI_RGM_TMPL_ORG_REGNS.TEMPL_ORG_REGNS_ID%TYPE
                              )
    AS

    CURSOR cur_chk_templ_itm_regns
    IS
    SELECT templ_itm_regns_id
    FROM   JAI_RGM_TMPL_ITM_REGNS tirg
    WHERE  tirg.templ_org_regns_id = p_templ_org_regns_id
    AND    tirg.inventory_item_id  = p_inv_itm_id;

    ln_templ_itm_regns_id   JAI_RGM_TMPL_ITM_REGNS.TEMPL_ITM_REGNS_ID%TYPE DEFAULT NULL;

    BEGIN

      IF p_templ_org_regns_id IS NULL THEN

        SELECT JAI_RGM_TMPL_ORG_REGNS_S.NEXTVAL
        INTO   p_templ_org_regns_id
        FROM   DUAL;
    /*  Create template organization association */
        INSERT INTO JAI_RGM_TMPL_ORG_REGNS
             (  templ_org_regns_id
              , template_id
              , organization_id
              , creation_date
              , created_by
              , last_update_date
              , last_updated_by
              , last_update_login
             )
          VALUES
          (
                p_templ_org_regns_id
              , p_templ_id
              , p_org_id
              , sysdate
              , fnd_global.user_id
              , sysdate
              , fnd_global.user_id
              , fnd_global.login_id
          );
      END IF;

      OPEN  cur_chk_templ_itm_regns;
      FETCH cur_chk_templ_itm_regns INTO ln_templ_itm_regns_id;
      CLOSE cur_chk_templ_itm_regns;
      /*  Create template item association */
      IF ln_templ_itm_regns_id IS NULL THEN
        INSERT INTO JAI_RGM_TMPL_ITM_REGNS
                (
                   templ_itm_regns_id
                 , templ_org_regns_id
                 , inventory_item_id
                 , creation_date
                 , created_by
                 , last_update_date
                 , last_updated_by
                 , last_update_login
                )
        VALUES   (
                    JAI_RGM_TMPL_ITM_REGNS_S.nextval
                  , p_templ_org_regns_id
                  , p_inv_itm_id
                  , sysdate
                  , fnd_global.user_id
                  , sysdate
                  , fnd_global.user_id
                  , fnd_global.login_id
                );
      END IF;

    END assign_template;

    /* -------------------------------- End of Local Procedure -------------------------------*/

  BEGIN

    OPEN  cur_chk_templ_org ;
    FETCH cur_chk_templ_org INTO ln_templ_org_regns_id;
    CLOSE cur_chk_templ_org;

    IF p_inventory_item_id IS NOT NULL THEN
      /* Call the local procedure to create assignment */
      assign_template( p_templ_id   => p_template_id
                      ,p_org_id     => p_organization_id
                      ,p_inv_itm_id => p_inventory_item_id
                      ,p_templ_org_regns_id => ln_templ_org_regns_id
                     );
    ELSE
      FOR c_items IN cur_get_items
      LOOP
        /* Call the local procedure to create assignment */
        assign_template( p_templ_id   => p_template_id
                        ,p_org_id     => p_organization_id
                        ,p_inv_itm_id => c_items.inventory_item_id
                        ,p_templ_org_regns_id => ln_templ_org_regns_id
                     );
      END LOOP; /* c_items */
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END jai_assign_template;

/* ------------------------------- CREATE ITEM SPECIFIC REGISTRATION ---------------------------------*/
  PROCEDURE jai_create_item_regns ( p_regime_code       JAI_RGM_ITM_REGNS.REGIME_CODE%TYPE
                                   ,p_organization_id   JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE
                                   ,p_inventory_item_id JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE
                                   ,p_tab_attributes    jai_inv_items_pkg.GT_ATTRIBUTES%TYPE
                                  )
  AS
  CURSOR cur_chk_rgm_item_regns
  IS
    SELECT rgm_item_regns_id
    FROM   JAI_RGM_ITM_REGNS rirg
    WHERE  rirg.regime_code = p_regime_code
    AND    rirg.organization_id = p_organization_id
    AND    rirg.inventory_item_id = p_inventory_item_id;

  ln_rgm_item_regns_id  JAI_RGM_ITM_REGNS.RGM_ITEM_REGNS_ID%TYPE DEFAULT NULL;
  ltab_attribs          jai_inv_items_pkg.GT_ATTRIBUTES%TYPE;
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_inv_items_pkg.jai_create_item_regns';

  BEGIN
    /*  Chekc if item specific registration already exists */
    OPEN  cur_chk_rgm_item_regns;
    FETCH cur_chk_rgm_item_regns INTO ln_rgm_item_regns_id;
    CLOSE cur_chk_rgm_item_regns;

    IF ln_rgm_item_regns_id IS NULL THEN
      /*
       * Item specific registration does not exist so create one by inserting a row in
       * JAI_RGM_ITM_REGNS
       */

      --SELECT JAI_RGM_ITM_REGNS_S.NEXTVAL INTO ln_rgm_item_regns_id FROM DUAL;

      INSERT INTO JAI_RGM_ITM_REGNS
                  (  rgm_item_regns_id
                    ,regime_code
                    ,organization_id
                    ,inventory_item_id
                    ,creation_date
                    ,created_by
                    ,last_update_date
                    ,last_updated_by
                    ,last_update_login
                  )
            VALUES(
                    --ln_rgm_item_regns_id
        JAI_RGM_ITM_REGNS_S.NEXTVAL /* Modified by Ramananda for removal of SQL LITERALs */
                  , p_regime_code
                  , p_organization_id
                  , p_inventory_item_id
                  , sysdate
                  , fnd_global.user_id
                  , sysdate
                  , fnd_global.user_id
                  , fnd_global.login_id
                ) returning rgm_item_regns_id into ln_rgm_item_regns_id;
    END IF;

    jai_inv_items_pkg.jai_create_attribs( p_template_id       => ''
                                     ,p_rgm_item_regns_id => ln_rgm_item_regns_id
                                     ,p_tab_attributes    => p_tab_attributes
                                    );

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END jai_create_item_regns ;
  /* -------------------------------------- CREATE TEMPLATE ATTRIBUTES ------------------------------*/
  PROCEDURE jai_create_attribs ( p_template_id        JAI_RGM_ITM_TEMPLATES.TEMPLATE_ID%TYPE
                                ,p_rgm_item_regns_id  JAI_RGM_ITM_REGNS.RGM_ITEM_REGNS_ID%TYPE
                                ,p_tab_attributes     jai_inv_items_pkg.GT_ATTRIBUTES%TYPE
                                )
  IS
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_inv_items_pkg.jai_create_attribs';
  BEGIN
  /*
   *  For each row in pl-sql table create row in jai_item_templ_attribs
   */
  FOR ln_attrib IN 1..p_tab_attributes.COUNT LOOP
    INSERT INTO JAI_RGM_ITM_TMPL_ATTRS(
        ITM_TEMPL_ATTRIBUTE_ID,
        TEMPLATE_ID,
        RGM_ITEM_REGNS_ID,
        ATTRIBUTE_CODE,
        ATTRIBUTE_VALUE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY
    ) VALUES (JAI_RGM_ITM_TMPL_ATTRS_S.nextval
        ,p_template_id
        ,p_rgm_item_regns_id
        ,p_tab_attributes(ln_attrib).attribute_code
        ,p_tab_attributes(ln_attrib).attribute_value
        ,SYSDATE, fnd_global.user_id , SYSDATE, fnd_global.login_id, fnd_global.user_id
    );
  END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END jai_create_attribs;

/* ------------------------------------------- SYNCHRONIZATION ---------------------------------------*/

  procedure jai_synchronize_jmsi
  (
    p_synchronization_number JAI_INV_ITM_SETUPS.synchronization_number%type default null
  )
  is
   lv_new_excise_flag               JAI_INV_ITM_SETUPS.excise_flag%type;
   lv_new_item_class                JAI_INV_ITM_SETUPS.item_class%type;
   lv_new_modvat_flag               JAI_INV_ITM_SETUPS.modvat_flag%type;
   lv_new_item_tariff               JAI_INV_ITM_SETUPS.item_tariff%type;
   lv_new_item_folio                JAI_INV_ITM_SETUPS.item_folio%type;
   lv_new_item_trading_flag         JAI_INV_ITM_SETUPS.item_trading_flag%type;
   lv_object_name CONSTANT VARCHAR2 (61) := 'jai_inv_items_pkg.jai_synchronize_jmsi';

    cursor cur_get_jmsi_row(cpn_synchronization_number number )   is
    select
      jmsi.rowid,
      jmsi.excise_flag      ,
      jmsi.item_class       ,
      jmsi.modvat_flag      ,
      jmsi.item_tariff      ,
      jmsi.item_folio       ,
      jmsi.item_trading_flag,
      jmsi.organization_id,
      jmsi.inventory_item_id
    from   JAI_INV_ITM_SETUPS jmsi
    where (
           (cpn_synchronization_number is null)
           or
           ( (cpn_synchronization_number is not null ) and (synchronization_number = cpn_synchronization_number ) )
           );

    cursor cur_get_itm_attribs
    (
      cpn_organization_id   jai_rgm_item_attrib_v.organization_id%type
      ,cpn_inventory_item_id jai_rgm_item_attrib_v.inventory_item_id%type
    )
    is
    select attribute_code,
           attribute_value,
           last_updated_by
    from   jai_rgm_item_attrib_v
    where  organization_id    =  cpn_organization_id
    and    inventory_item_id  =  cpn_inventory_item_id
    AND    regime_code        =  jai_constants.excise_regime ;

  begin
    /*  Get all the rows to be synchronized */
    for rec_jmsi in cur_get_jmsi_row(p_synchronization_number)
    loop

        lv_new_excise_flag        := null;
        lv_new_item_class         := null;
        lv_new_modvat_flag        := null;
        lv_new_item_tariff        := null;
        lv_new_item_folio         := null;
        lv_new_item_trading_flag  := null;

        /*  Get attributes for each organization and inventory item */
        for rec_attribs in
          cur_get_itm_attribs (cpn_organization_id   => rec_jmsi.organization_id,
                               cpn_inventory_item_id => rec_jmsi.inventory_item_id
                              )
        loop

          if rec_attribs.attribute_code ='EXCISABLE' then
            lv_new_excise_flag := rec_attribs.attribute_value;
          elsif rec_attribs.attribute_code ='ITEM CLASS' then
            lv_new_item_class := rec_attribs.attribute_value;
          elsif rec_attribs.attribute_code ='MODVATABLE' then
            lv_new_modvat_flag := rec_attribs.attribute_value;
          elsif rec_attribs.attribute_code ='ITEM TARIFF' then
            lv_new_item_tariff := rec_attribs.attribute_value;
          elsif rec_attribs.attribute_code ='ITEM FOLIO' then
            lv_new_item_folio := rec_attribs.attribute_value;
          elsif rec_attribs.attribute_code ='TRADABLE' then
            lv_new_item_trading_flag := rec_attribs.attribute_value;
          end if;

      end loop; /* Attributes */

      /*  Update JAI_INV_ITM_SETUPS if atleast one attribute is changed */

      if  nvl(lv_new_excise_flag, 'NULL') <> nvl(rec_jmsi.excise_flag, 'NULL') or
          nvl(lv_new_item_class, 'NULL')  <> nvl(rec_jmsi.item_class, 'NULL') or
          nvl(lv_new_modvat_flag, 'NULL') <> nvl(rec_jmsi.modvat_flag, 'NULL') or
          nvl(lv_new_item_tariff, 'NULL') <> nvl(rec_jmsi.item_tariff, 'NULL') or
          nvl(lv_new_item_folio, 'NULL')  <> nvl(rec_jmsi.item_folio, 'NULL') or
          nvl(lv_new_item_trading_flag, 'NULL') <> nvl(rec_jmsi.item_trading_flag, 'NULL')
      then

        update JAI_INV_ITM_SETUPS
        set    excise_flag          =    lv_new_excise_flag
             , item_class           =    lv_new_item_class
             , modvat_flag          =    lv_new_modvat_flag
             , item_tariff          =    lv_new_item_tariff
             , item_folio           =    lv_new_item_folio
             , item_trading_flag    =     lv_new_item_trading_flag
             , last_update_date     =     sysdate
             , last_updated_by      =     0405051/* p_synchronization_number*/
        where rowid = rec_jmsi.rowid;

      end if;  /*  update */

    end loop;   /* rec_jmsi */
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  end jai_synchronize_jmsi;
 /*-----------------------------------------------------------------------------------*/
 /*  Added by Brathod for bug#4389149 */
 /* India Localization code hook for Base item copy/delete/assignment/import action */
PROCEDURE propagate_item_action
  (
    pv_action_type                IN    VARCHAR2
  , pn_organization_id            IN    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
  , pn_inventory_item_id          IN    MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
  , pn_source_organization_id     IN    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
  , pn_source_inventory_item_id   IN    MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
  , pn_set_process_id             IN    NUMBER
  , pv_called_from                IN    VARCHAR2
  )
  IS
   CURSOR cur_get_items_from_interface
    IS
    SELECT   intf.organization_id                       organization_id
            ,intf.inventory_item_id                     inventory_item_id
            ,master_org.master_organization_id          source_organization_id
    FROM     mtl_system_items_interface intf
            ,mtl_parameters master_org
    WHERE   intf.process_flag           =     7
    AND     intf.transaction_type       =     'CREATE'
    AND     intf.request_id             =     fnd_global.conc_request_id
    AND     intf.set_process_id         =     pn_set_process_id
    AND     intf.organization_id        =     master_org.organization_id
    AND     intf.organization_id        <>    master_org.master_organization_id ;

    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_inv_items_pkg.propagate_item_action';

  BEGIN
    /*
      pv_action_type "IMPORT" indicates to import items from interface.
      In this case pt_item_data (PL/SQL) table will be null and desired data will
      be fetched from interface table
     */

    IF pv_action_type IN ('IMPORT') THEN
      FOR rec_itms IN cur_get_items_from_interface
      LOOP

        IF rec_itms.organization_id IS NULL THEN
           fnd_message.set_name('JA','JAI_DEST_ORG_CANT_BE_NULL');
           app_exception.raise_exception;
        END IF;
        IF rec_itms.inventory_item_id IS NULL THEN
          fnd_message.set_name ('JA','JAI_ITEM_CANT_BE_NULL');
          app_exception.raise_exception;
        END IF;
        IF rec_itms.source_organization_id IS NULL THEN
          fnd_message.set_name('JA','JAI_SOURCE_ORG_CANT_BE_NULL');
          app_exception.raise_exception;
        END IF;

        jai_inv_items_pkg.copy_items
                  ( pn_organization_id          => rec_itms.organization_id
                   ,pn_inventory_item_id        => rec_itms.inventory_item_id
                   ,pn_source_organization_id   => rec_itms.source_organization_id
                   ,pn_source_inventory_item_id => rec_itms.inventory_item_id
                   );
      END LOOP;
    ELSE  /* pv_action_type is either COPY, ASSIGN or DELETE */

      IF pv_action_type IN ('COPY','ASSIGN') THEN

      IF pn_organization_id IS NULL
      OR pn_inventory_item_id IS NULL
      OR pn_source_organization_id IS NULL
      OR pn_source_inventory_item_id IS NULL THEN
        fnd_message.set_name('JA','JAI_IL_API_ARGS_NOT_PROPER');
        app_exception.raise_exception;
      END IF;

      jai_inv_items_pkg.copy_items
                  ( pn_organization_id          => pn_organization_id
                   ,pn_inventory_item_id        => pn_inventory_item_id
                   ,pn_source_organization_id   => pn_source_organization_id
                   ,pn_source_inventory_item_id => pn_source_inventory_item_id
                   );

      ELSIF pv_action_type IN ('DELETE') THEN

        IF pn_organization_id IS NULL
        OR pn_inventory_item_id IS NULL  THEN
          fnd_message.set_name('JA','JAI_IL_API_ARGS_NOT_PROPER');
          app_exception.raise_exception;
        END IF;

        jai_inv_items_pkg.delete_items
                    (
                      pn_organization_id   =>  pn_organization_id
                     ,pn_inventory_item_id =>  pn_inventory_item_id
                    );
        END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||SQLERRM );
    app_exception.raise_exception;
  END propagate_item_action;
/*----------------------------------------------------------------------------------*/
  PROCEDURE  copy_items
              ( pn_organization_id          MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
               ,pn_inventory_item_id        MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
               ,pn_source_organization_id   MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
               ,pn_source_inventory_item_id MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
               ,pn_regime_code              JAI_RGM_ITM_REGNS.REGIME_CODE%TYPE DEFAULT 'EXCISE' --added for bug#9191274
              )
  IS
    ln_items                      NUMBER := 0;
    ln_item_regns_id              NUMBER ;
    ln_dest_item_regns_id         NUMBER ;
    ln_template_id                NUMBER ;
    ln_dest_template_id           NUMBER ;

    ln_organization_id            MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE   ;
    ln_inventory_item_id          MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE ;
    ln_source_organization_id     MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE   ;
    ln_source_inventory_item_id   MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE ;

    lt_attribs                    JAI_INV_ITEMS_PKG.GT_ATTRIBUTES%TYPE;
    lv_object_name CONSTANT       VARCHAR2 (61) := 'jai_inv_items_pkg.copy_items';
    lv_regime_code                VARCHAR2(15);

    CURSOR cur_get_item_regns
            (cpv_regime_code         JAI_RGM_ITM_REGNS.REGIME_CODE%TYPE
            ,cpn_organization_id     JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE
            ,cpn_inventory_item_id   JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE
            )
    IS
      SELECT  rgm_item_regns_id
      FROM    JAI_RGM_ITM_REGNS
      WHERE   regime_code       = cpv_regime_code
      AND     organization_id   = cpn_organization_id
      AND     inventory_item_id = cpn_inventory_item_id;

    CURSOR cur_get_rec_item_attrib (cpv_itm_templ_flg VARCHAR2
                                   ,cpn_itm_templ_id  NUMBER
                                   )
    IS
      SELECT   template_id
              ,rgm_item_regns_id
              ,attribute_code
              ,attribute_value
      FROM    JAI_RGM_ITM_TMPL_ATTRS
      WHERE   ((  template_id      = cpn_itm_templ_id AND cpv_itm_templ_flg = 'T')
               OR
               ( rgm_item_regns_id = cpn_itm_templ_id AND cpv_itm_templ_flg = 'I')
              );

    CURSOR cur_get_template_id
            (cpv_regime_code         JAI_RGM_ITM_REGNS.REGIME_CODE%TYPE
            ,cpn_organization_id     JAI_RGM_ITM_REGNS.ORGANIZATION_ID%TYPE
            ,cpn_inventory_item_id   JAI_RGM_ITM_REGNS.INVENTORY_ITEM_ID%TYPE
            )
    IS
      SELECT torg.template_id
      FROM   JAI_RGM_TMPL_ITM_REGNS tirg
            ,JAI_RGM_TMPL_ORG_REGNS torg
            ,JAI_RGM_ITM_TEMPLATES   rgtmp
      WHERE tirg.templ_org_regns_id = torg.templ_org_regns_id
      AND   torg.template_id        = rgtmp.template_id
      AND   torg.organization_id    = cpn_organization_id
      AND   tirg.inventory_item_id  = cpn_inventory_item_id
      AND   rgtmp.regime_code       = cpv_regime_code;


  BEGIN

    ln_organization_id          := pn_organization_id;
    ln_inventory_item_id        := pn_inventory_item_id;
    ln_source_organization_id   := pn_source_organization_id;
    ln_source_inventory_item_id := pn_source_inventory_item_id;
    lv_regime_code              := pn_regime_code; --added for bug#9191274


    /* Check if destination item already exists */

    OPEN  cur_get_item_regns (cpv_regime_code       => lv_regime_code --replaced jai_constants.excise_regime for bug#9191274
                             ,cpn_organization_id   => ln_organization_id
                             ,cpn_inventory_item_id => ln_inventory_item_id
                             );

    FETCH cur_get_item_regns INTO ln_dest_item_regns_id;

    CLOSE cur_get_item_regns;

    IF ln_dest_item_regns_id IS NOT NULL THEN
      fnd_message.set_name('JA', 'JAI_DUP_ITEM');
      app_exception.raise_exception;
    END IF;

    /* Check if item specific registration exists for the source item */

    OPEN  cur_get_item_regns (cpv_regime_code       => lv_regime_code --replaced jai_constants.excise_regime for bug#9191274
                             ,cpn_organization_id   => ln_source_organization_id
                             ,cpn_inventory_item_id => ln_source_inventory_item_id
                             );
    FETCH cur_get_item_regns INTO ln_item_regns_id;
    CLOSE cur_get_item_regns;


    IF ln_item_regns_id IS NOT NULL THEN
    /*
       Item specific registration exists, so create item specific registration for
       new item by copying the attributes of source item
    */
       lt_attribs.delete; -- Flush plsql table

       FOR cur_attribs IN cur_get_rec_item_attrib (cpv_itm_templ_flg => 'I'
                                                  ,cpn_itm_templ_id  => ln_item_regns_id
                                                  )
       LOOP
         lt_attribs(lt_attribs.count+1).attribute_code := cur_attribs.attribute_code;
         lt_attribs(lt_attribs.count).attribute_value  := cur_attribs.attribute_value;
       END LOOP;

       jai_inv_items_pkg.jai_create_item_regns
                ( p_regime_code       => lv_regime_code --replaced jai_constants.excise_regime for bug#9191274
                 ,p_organization_id   => ln_organization_id
                 ,p_inventory_item_id => ln_inventory_item_id
                 ,p_tab_attributes    => lt_attribs
                );
    END IF; /* End of Item Specific Registration*/

    /* Check if source item is alredy registred with some template */
    OPEN  cur_get_template_id
            (cpv_regime_code       => lv_regime_code --replaced jai_constants.excise_regime for bug#9191274
            ,cpn_organization_id   => ln_organization_id
            ,cpn_inventory_item_id => ln_inventory_item_id
            );
    FETCH cur_get_template_id INTO ln_dest_template_id;
    CLOSE cur_get_template_id ;

    IF ln_dest_template_id IS NOT NULL THEN
     /*  Item is alredy registered so nothing to do */
     RETURN;
    END IF;

    /*  Check if source item is assigned to template */
    OPEN  cur_get_template_id
            (cpv_regime_code       => lv_regime_code --replaced jai_constants.excise_regime for bug#9191274
            ,cpn_organization_id   => ln_source_organization_id
            ,cpn_inventory_item_id => ln_source_inventory_item_id
            );
    FETCH cur_get_template_id INTO ln_template_id;
    CLOSE cur_get_template_id ;

    IF ln_template_id IS NOT NULL THEN
    /*
        Source item is assigned to a template and so new item should also
        be assigned to the same template
    */
      jai_inv_items_pkg.jai_assign_template (p_template_id        => ln_template_id
                                        ,p_organization_id    => ln_organization_id
                                        ,p_inventory_item_id  => ln_inventory_item_id
                                        );

    END IF; /* End of Template Assignment */
    /*
       For Excise regime create a copy record in the JAI_INV_ITM_SETUPS
       from the source item
    */
    --added the IF condition for bug#9191274
    IF lv_regime_code = jai_constants.excise_regime THEN
      INSERT INTO JAI_INV_ITM_SETUPS
      (
               inventory_item_id
            ,  organization_id
            ,  item_class
            ,  modvat_flag
            ,  item_tariff
            ,  item_folio
            ,  excise_flag
            ,  creation_date
            ,  created_by
            ,  last_update_date
            ,  last_updated_by
            ,  last_update_login
            ,  item_trading_flag
            ,  synchronization_number
      )
      (SELECT
               ln_inventory_item_id
            ,  ln_organization_id
            ,  item_class
            ,  modvat_flag
            ,  item_tariff
            ,  item_folio
            ,  excise_flag
            ,  sysdate
            ,  fnd_global.user_id
            ,  sysdate
            ,  fnd_global.user_id
            ,  fnd_global.login_id
            ,  item_trading_flag
            ,  NULL
      FROM  JAI_INV_ITM_SETUPS
      WHERE organization_id   = ln_source_organization_id
      AND   inventory_item_id = ln_source_inventory_item_id
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||SQLERRM );
    app_exception.raise_exception;
  END copy_items;
/* -------------------------------  END OF PROCEDURE COPY_ITEMS ------------------------*/

  PROCEDURE  delete_items ( pn_organization_id    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
                           ,pn_inventory_item_id  MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
                          )
  IS
    ln_organization_id            MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE   ;
    ln_inventory_item_id          MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE ;
    ln_rgm_item_regns_id          JAI_RGM_ITM_REGNS.RGM_ITEM_REGNS_ID%TYPE;
    ln_templ_org_regns_id         JAI_RGM_TMPL_ORG_REGNS.TEMPL_ORG_REGNS_ID%TYPE;
    ln_templ_itm_regns            NUMBER := NULL;
    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_inv_items_pkg.delete_items';

    CURSOR cur_chk_templ_itm_regns (cpn_templ_org_regns_id JAI_RGM_TMPL_ITM_REGNS.TEMPL_ORG_REGNS_ID%TYPE)
    IS
      SELECT 1
      FROM   JAI_RGM_TMPL_ITM_REGNS
      WHERE  templ_org_regns_id = cpn_templ_org_regns_id;

  BEGIN
    ln_organization_id          := pn_organization_id;
    ln_inventory_item_id        := pn_inventory_item_id;

    DELETE FROM JAI_RGM_ITM_REGNS
    WHERE inventory_item_id = ln_inventory_item_id
    AND   organization_id   = ln_organization_id
    AND   regime_code       = jai_constants.excise_regime
    RETURNING rgm_item_regns_id INTO ln_rgm_item_regns_id;

    IF ln_rgm_item_regns_id IS NOT NULL THEN
      DELETE FROM JAI_RGM_ITM_TMPL_ATTRS
      WHERE  rgm_item_regns_id = ln_rgm_item_regns_id;
    END IF;

    DELETE FROM JAI_RGM_TMPL_ITM_REGNS
    WHERE  templ_itm_regns_id IN (SELECT templ_itm_regns_id
                                  FROM    JAI_RGM_TMPL_ITM_REGNS tirg
                                         ,JAI_RGM_TMPL_ORG_REGNS torg
                                         ,JAI_RGM_ITM_TEMPLATES    rgtmp
                                  WHERE  tirg.templ_org_regns_id = torg.templ_org_regns_id
                                  AND    torg.template_id        = rgtmp.template_id
                                  AND    tirg.inventory_item_id  = ln_inventory_item_id
                                  AND    torg.organization_id    = ln_organization_id
                                  AND    rgtmp.regime_code       = jai_constants.excise_regime
                                  )
    RETURNING templ_org_regns_id  INTO ln_templ_org_regns_id ;

    /*
      Check if any item is registered with templ_org_regns_id.  If no such items found
      then delete the template organizatin registration also
    */
    OPEN  cur_chk_templ_itm_regns  (cpn_templ_org_regns_id => ln_templ_org_regns_id);
    FETCH cur_chk_templ_itm_regns   INTO ln_templ_itm_regns ;
    CLOSE cur_chk_templ_itm_regns ;

    IF ln_templ_itm_regns IS NULL THEN
      DELETE FROM JAI_RGM_TMPL_ORG_REGNS
      WHERE  templ_org_regns_id = ln_templ_org_regns_id;
    END IF;

    DELETE FROM JAI_INV_ITM_SETUPS
    WHERE organization_id   = ln_organization_id
    AND   inventory_item_id = ln_inventory_item_id;

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  END delete_items;
/* -----------------------END OF PROCEDURE DELETE_ITEMS ----------------------------*/
 /*  End of Bug# 4389149 */

end jai_inv_items_pkg;

/
