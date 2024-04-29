--------------------------------------------------------
--  DDL for Package Body INVIDIT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVIDIT1" AS
/* $Header: INVIDI1B.pls 120.18.12010000.2 2008/10/16 04:04:04 xiaozhou ship $ */

PROCEDURE Get_Startup_Info
(
   X_org_id                     IN   NUMBER
,  X_mode                       IN   VARCHAR2
,  X_master_org_id              OUT  NOCOPY NUMBER
,  X_master_org_name            OUT  NOCOPY VARCHAR2
,  X_master_org_code            OUT  NOCOPY VARCHAR2
,  X_master_chart_of_accounts   OUT  NOCOPY number
,  X_updateable_item            OUT  NOCOPY varchar2
,  X_default_status             OUT  NOCOPY varchar2
,  x_default_uom_b              OUT  NOCOPY VARCHAR2
,  x_default_uom                OUT  NOCOPY VARCHAR2
,  x_default_uom_code           OUT  NOCOPY VARCHAR2
,  x_default_uom_class          OUT  NOCOPY VARCHAR2
,  x_time_uom_class             OUT  NOCOPY VARCHAR2
,  x_default_lot_status_id      OUT  NOCOPY NUMBER
,  x_default_lot_status         OUT  NOCOPY VARCHAR2
,  x_default_serial_status_id   OUT  NOCOPY NUMBER
,  x_default_serial_status      OUT  NOCOPY VARCHAR2
,  x_Item_Category_Set_id       OUT  NOCOPY NUMBER
,  x_Item_Category_Structure_id OUT  NOCOPY NUMBER
,  x_Item_Category_Validate_Flag OUT NOCOPY VARCHAR2--Bug:3578024
,  x_Item_Category_Set_Ctrl_level OUT NOCOPY VARCHAR2--Bug:3723668
,  x_Default_Template_id        OUT  NOCOPY NUMBER
,  x_Default_Template_Name      OUT  NOCOPY VARCHAR2
,  X_icgd_option                OUT NOCOPY varchar2
,  X_allow_item_desc_update_flag OUT NOCOPY varchar2
,  X_rfq_required_flag          OUT NOCOPY varchar2
,  X_receiving_flag             OUT NOCOPY varchar2
,  X_taxable_flag               OUT NOCOPY varchar2
,  X_org_locator_control        OUT NOCOPY number
,  X_org_expense_account        OUT NOCOPY number
,  X_org_encumbrance_account    OUT NOCOPY number
,  X_org_cost_of_sales_account  OUT NOCOPY number
,  X_org_sales_account          OUT NOCOPY number
,  X_serial_generation          OUT NOCOPY number
,  X_lot_generation             OUT NOCOPY number
,  X_cost_method                OUT NOCOPY number
,  X_category_flex_structure    OUT NOCOPY number
,  X_bom_enabled_status         OUT NOCOPY number
,  X_purchasable_status         OUT NOCOPY number
,  X_transactable_status        OUT NOCOPY number
,  X_stockable_status           OUT NOCOPY number
,  X_wip_status                 OUT NOCOPY number
,  X_cust_ord_status            OUT NOCOPY number
,  X_int_ord_status             OUT NOCOPY number
,  X_invoiceable_status         OUT NOCOPY number
,  X_order_by_segments          OUT NOCOPY varchar2
,  X_product_family_templ_id    OUT NOCOPY number
,  X_encumbrance_reversal_flag  OUT NOCOPY NUMBER --* Added for Bug #3818342
/* Start Bug 3713912 */
,X_recipe_enabled_status OUT NOCOPY number,
X_process_exec_enabled_status OUT NOCOPY number
/* End Bug 3713912 */
/* Adding attributes for R12 */
,  X_tp_org                  OUT NOCOPY VARCHAR2

)
IS

  master_org    number;
  uom_default   varchar2(25);

   -- Set default values for the Default Material Statuses
   --
   c_default_lot_status_id       CONSTANT  NUMBER  := 1;
   c_default_serial_status_id    CONSTANT  NUMBER  := 1;

   l_Item_Category_Set_id         NUMBER;
   l_Default_Template_id          NUMBER;

  icgd_profile_exists   boolean;
  v_operating_unit      number;
  v_status_attr         varchar2(50);
  v_status_ctrl         number;
  v_segs                varchar2(15) := null;
  v_enabled_segs        varchar2(150) := null;

  -- Retrieve the status control code for the status attributes
  CURSOR status_attr_control is
        select attribute_name, status_control_code
        from mtl_item_attributes
        where status_control_code is not null;


  -- This sql statement retrieves each of the enabled item flex segments
  --  in order
  -- This info is used to dynamically build the ORDER_BY clause in
  --  the Items form
  --
  CURSOR flex_segs is
        select application_column_name
        from fnd_id_flex_segments
        where application_id = 401
        and id_flex_code = 'MSTK'
        and id_flex_num = 101
        and enabled_flag = 'Y'
        order by segment_num;

BEGIN
  -- Get master org and master org code for this organization

  BEGIN
  select a.master_organization_id, b.organization_code
   , DECODE(X_mode,'DEFINE',NVL(b.encumbrance_reversal_flag,2),NVL(a.encumbrance_reversal_flag,2)) --* Added for Bug #3818342
  into master_org, X_master_org_code, X_encumbrance_reversal_flag
  from mtl_parameters a, mtl_parameters b
  where a.organization_id = X_org_id
  and a.master_organization_id = b.organization_id;

  X_master_org_id := master_org;

  EXCEPTION
  when NO_DATA_FOUND then
    null;
  END;

  -- Get chart of accounts for master org

  begin

  SELECT lgr.CHART_OF_ACCOUNTS_ID
  into X_master_chart_of_accounts
  FROM   gl_ledgers lgr,
         hr_organization_information hoi
  where hoi.organization_id = master_org
    and (HOI.ORG_INFORMATION_CONTEXT|| '') ='Accounting Information'
    and TO_NUMBER(DECODE(RTRIM(TRANSLATE(HOI.ORG_INFORMATION1,'0123456789',' ')), NULL, HOI.ORG_INFORMATION1,-99999)) = LGR.LEDGER_ID
    and lgr.object_type_code = 'L'
    and rownum = 1;


  exception
    when NO_DATA_FOUND then
      null;
  end;

  -- Get profiles used in form.
  --
  fnd_profile.get('INV_UPDATEABLE_ITEM', X_updateable_item);
  fnd_profile.get('INV_STATUS_DEFAULT', X_default_status);

  -- Put default uom in a local variable so it can be used in later select.
  fnd_profile.get('INV_UOM_DEFAULT', uom_default);

  x_default_uom_b := uom_default;

  fnd_profile.get('TIME_UOM_CLASS', X_time_uom_class);
  fnd_profile.get('USE_NAME_ICG_DESC', X_icgd_option);


  -- Get user specified category set for item folder.
  --
  --FND_PROFILE.Get ('INV_USER_CATEGORY_SET', l_Item_Category_Set_id);

  IF ( FND_PROFILE.Defined ('INV_ITEM_FOLDER_CATEGORY_SET') ) THEN
     l_Item_Category_Set_id := FND_PROFILE.Value ('INV_ITEM_FOLDER_CATEGORY_SET');
  END IF;

  IF ( l_Item_Category_Set_id IS NOT NULL ) THEN
  BEGIN

     SELECT structure_id, validate_flag, control_level --Bug:3578024
       INTO x_Item_Category_Structure_id, x_Item_Category_Validate_Flag, x_Item_Category_Set_Ctrl_level
     FROM mtl_category_sets_b
     WHERE category_set_id = l_Item_Category_Set_id;

     x_Item_Category_Set_id := l_Item_Category_Set_id;

  EXCEPTION
     WHEN no_data_found THEN
        x_Item_Category_Set_id       := NULL;
        x_Item_Category_Structure_id := NULL;

  END;
  END IF;

  -- Get optional default template to be used to initialize new items.
  --
  IF ( FND_PROFILE.Defined ('INV_ITEM_DEFAULT_TEMPLATE') ) THEN
     l_Default_Template_id := FND_PROFILE.Value ('INV_ITEM_DEFAULT_TEMPLATE');
  END IF;

  IF ( l_Default_Template_id IS NOT NULL ) THEN
  BEGIN

     SELECT template_name
       INTO x_Default_Template_Name
     FROM mtl_item_templates
     WHERE template_id = l_Default_Template_id;

     x_Default_Template_id := l_Default_Template_id;

  EXCEPTION
     WHEN no_data_found THEN
        x_Default_Template_id   := NULL;
        x_Default_Template_Name := NULL;

  END;
  END IF;

   -- Get asset category flex structure
  --
  if ( INV_Item_Util.g_Appl_Inst.fa <> 0 ) then
  BEGIN

    select category_flex_structure
    into X_category_flex_structure
    from fa_system_controls;

  EXCEPTION
    when NO_DATA_FOUND then
      X_category_flex_structure := null;

  END;
  end if;
  -- Get uom_code and uom_class for default primary uom
  --
  if ( uom_default is not null ) then
    begin
    select
       unit_of_measure_tl, uom_code, uom_class
    into
       x_default_uom, x_default_uom_code, x_default_uom_class
    from
       mtl_units_of_measure_vl
    where
       unit_of_measure = uom_default;

    exception
      when NO_DATA_FOUND then
        X_default_uom_code := null;
        X_default_uom_class := null;
    end;

  end if;

  --Jalaj Srivastava Bug 5934365
  --No need to check for wms install for lot status
  --material status in R12 is core INV functionality.
--IF ( INV_Item_Util.g_Appl_Inst.WMS <> 0 ) THEN

     IF ( c_default_lot_status_id is not null ) THEN
     BEGIN
        SELECT  status_code
          INTO  x_default_lot_status
        FROM  mtl_material_statuses_vl
        WHERE  status_id = c_default_lot_status_id
          AND  lot_control = 1;

        x_default_lot_status_id := c_default_lot_status_id;

     EXCEPTION
        WHEN no_data_found THEN
           x_default_lot_status := null;
     END;
     END IF;

     IF ( c_default_serial_status_id is not null ) THEN
     BEGIN
        SELECT  status_code
          INTO  x_default_serial_status
        FROM  mtl_material_statuses_vl
        WHERE  status_id = c_default_serial_status_id
          AND  serial_control = 1;

        x_default_serial_status_id := c_default_serial_status_id;

     EXCEPTION
        WHEN no_data_found THEN
           x_default_serial_status := null;
     END;
     END IF;

--END IF;
  -- Get defaults for purchasing attributes
  --
  if ( INV_Item_Util.g_Appl_Inst.po <> 0 ) then
  BEGIN
    select DECODE(ORG_INFORMATION_CONTEXT,
                          'Accounting Information',
                           TO_NUMBER(ORG_INFORMATION3),
                           TO_NUMBER(NULL)) operating_unit
    into   V_operating_unit
    from   hr_organization_information
    where  organization_id = X_org_id
    and (org_information_context|| '') ='Accounting Information';


    select allow_item_desc_update_flag,
           rfq_required_flag,
           receiving_flag,
           taxable_flag
    into   X_allow_item_desc_update_flag,
           X_rfq_required_flag,
           X_receiving_flag,
           X_taxable_flag
    from po_system_parameters_all
    where nvl(org_id, -11) = nvl(v_operating_unit, -11);

  EXCEPTION
    when NO_DATA_FOUND then
      X_allow_item_desc_update_flag := null;
      x_rfq_required_flag := null;
      X_receiving_flag := null;
      X_taxable_flag := null;

  END;
  end if;

  -- Get organization info for master org
  -- Accounts are used for defaults when
  --  creating an item, so use the master org
  --
  BEGIN
  select mp.cost_of_sales_account,
         mp.encumbrance_account,
         mp.sales_account,
         mp.expense_account,
         hr.name
  into   X_org_cost_of_sales_account,
         X_org_encumbrance_account,
         X_org_sales_account,
         X_org_expense_account,
         X_master_org_name
  from   mtl_parameters mp, hr_organization_units hr
  where  mp.organization_id = master_org
  and    mp.organization_id = hr.organization_id;

  -- Get this info for the current org
  --
  select decode(mp.stock_locator_control_code, '5', '1',
                                            '4', '1',
                mp.stock_locator_control_code),
         mp.primary_cost_method,
         mp.lot_number_generation,
         mp.serial_number_generation,
	 mp.trading_partner_org_flag
  into   X_org_locator_control,
         X_cost_method,
         X_lot_generation,
         X_serial_generation,
	 X_tp_org
  from   mtl_parameters mp
  where  mp.organization_id = X_org_id;

  EXCEPTION
    when NO_DATA_FOUND then
      null;
  END;

  OPEN status_attr_control;

  LOOP
     FETCH status_attr_control INTO v_status_attr, v_status_ctrl;
     EXIT when status_attr_control%NOTFOUND;

  if v_status_attr = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG' then
    X_bom_enabled_status := v_status_ctrl;

  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG' then
    X_purchasable_status := v_status_ctrl;

  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG' then
    X_transactable_status := v_status_ctrl;

  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG' then
    X_stockable_status := v_status_ctrl;

  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG' then
    X_wip_status := v_status_ctrl;

  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG' then
    X_cust_ord_status := v_status_ctrl;

  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG' then
    X_int_ord_status := v_status_ctrl;

  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG' then
    X_invoiceable_status := v_status_ctrl;
/* Start Bug 3713912 */
  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG' then
    X_recipe_enabled_status := v_status_ctrl;
  elsif v_status_attr = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG' then
    X_process_exec_enabled_status := v_status_ctrl;
/* End Bug 3713912 */

  end if;

  END LOOP;

  CLOSE status_attr_control;


  -- Retrieve each of the enabled item flex segments into a variable
  -- Concatenate all of them together to return 1 string in the format:
  --  segment1,segment2
  --
  OPEN flex_segs;
  LOOP
    FETCH flex_segs into v_segs;
    EXIT when flex_segs%NOTFOUND;

    -- if this is the first segment, don't concat the ',' before it
    if v_enabled_segs is null then
      v_enabled_segs := v_segs;
    else
      v_enabled_segs := v_enabled_segs || ',' || v_segs;
    end if;

  END LOOP;

  CLOSE flex_segs;

  X_order_by_segments := v_enabled_segs;

  BEGIN
  -- Return template_id of the 'Product Family' template
  -- if one is defined in the profile option
  --
    X_product_family_templ_id := fnd_profile.value('INV_ITEMS_PRODUCT_FAMILY_TEMPLATE');

  EXCEPTION
     WHEN OTHERS THEN
        X_product_family_templ_id := 0;
  END;

END Get_Startup_Info;


-- Get product installation status
--  application_id      product
--  --------------      -------
--      140             Fixed Assets
--      170             Service
--      201             Purchasing
--      222             Receivables
--      300             Order Entry
--      401             Inventory
--      702             BOM
--      703             Engineering
--      704             MRP
--      706             WIP
--
PROCEDURE Get_Installs(X_inv_install    OUT NOCOPY number,
                       X_po_install     OUT NOCOPY number,
                       X_ar_install     OUT NOCOPY number,
                       X_oe_install     OUT NOCOPY number,
                       X_bom_install    OUT NOCOPY number,
                       X_eng_install    OUT NOCOPY number,
                       X_cs_install     OUT NOCOPY number,
                       X_mrp_install    OUT NOCOPY number,
                       X_wip_install    OUT NOCOPY number,
                       X_fa_install     OUT NOCOPY number,
                       X_pjm_unit_eff_enabled     OUT NOCOPY VARCHAR2
) is
  -- local variables

  is_installed  boolean;
  indust        varchar2(10);
  inv_installed varchar2(10);
  po_installed  varchar2(10);
  ar_installed  varchar2(10);
  oe_installed  varchar2(10);
  bom_installed varchar2(10);
  eng_installed varchar2(10);
  cs_installed  varchar2(10);
  mrp_installed varchar2(10);
  wip_installed varchar2(10);
  fa_installed  varchar2(10);

begin

  -- If it's installed, set it to application_id; if not, set it to 0
  --  (form logic needs it to be 0 if not installed
  -- status = 'I' indicates the product is fully installed
  --
  is_installed := fnd_installation.get(appl_id => 401, dep_appl_id => 401,
        status => inv_installed, industry => indust);
  if (inv_installed = 'I') then
    X_inv_install := 401;
  else
    X_inv_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 201, dep_appl_id => 201,
        status => po_installed, industry => indust);
  if (po_installed = 'I') then
    X_po_install := 201;
  else
    X_po_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 222, dep_appl_id => 222,
        status => ar_installed, industry => indust);
  if (ar_installed = 'I') then
    X_ar_install := 222;
  else
    X_ar_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 300, dep_appl_id => 300,
        status => oe_installed, industry => indust);
  if (oe_installed = 'I') then
    X_oe_install := 300;
  else
    X_oe_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 702, dep_appl_id => 702,
        status => bom_installed, industry => indust);
  if (bom_installed = 'I') then
    X_bom_install := 702;
  else
    X_bom_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 703, dep_appl_id => 703,
        status => eng_installed, industry => indust);
  if (eng_installed = 'I') then
    X_eng_install := 703;
  else
    X_eng_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 170, dep_appl_id => 170,
        status => cs_installed, industry => indust);
  if (cs_installed = 'I') then
    X_cs_install := 170;
  else
    X_cs_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 704, dep_appl_id => 704,
        status => mrp_installed, industry => indust);
  if (mrp_installed = 'I') then
    X_mrp_install := 704;
  else
    X_mrp_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 706, dep_appl_id => 706,
        status => wip_installed, industry => indust);
  if (wip_installed = 'I') then
    X_wip_install := 706;
  else
    X_wip_install := 0;
  end if;

  is_installed := fnd_installation.get(appl_id => 140, dep_appl_id => 140,
        status => fa_installed, industry => indust);
  if (fa_installed = 'I') then
    X_fa_install := 140;
  else
    X_fa_install := 0;
  end if;

  -- Parameter gets value Y/N depending on whether Model/Unit Effectivity
  -- has been enabled or not.
  --
  X_pjm_unit_eff_enabled := PJM_UNIT_EFF.Enabled();

end Get_Installs;


-- Resolve foreign key references
--
PROCEDURE Populate_Fields
(
   X_org_id                     IN   NUMBER
,  X_item_id                    IN   NUMBER
,  X_buyer_id                   IN   NUMBER,
   X_hazard_class_id            IN   NUMBER,
   X_un_number_id               IN   NUMBER,
   X_picking_rule_id            IN   NUMBER,
   X_atp_rule_id                IN   NUMBER,
   X_payment_terms_id           IN   NUMBER,
   X_accounting_rule_id         IN   NUMBER,
   X_invoicing_rule_id          IN   NUMBER,
   X_default_shipping_org       IN   NUMBER,
   X_source_organization_id     IN   NUMBER,
   X_weight_uom_code            IN   VARCHAR2,
   X_volume_uom_code            IN   VARCHAR2,
   X_item_type                  IN   VARCHAR2,
   X_container_type             IN   VARCHAR2,
   X_conversion                 IN   NUMBER,
   X_buyer                      OUT NOCOPY varchar2,
   X_hazard_class               OUT NOCOPY varchar2,
   X_un_number                  OUT NOCOPY varchar2,
   X_un_description             OUT NOCOPY varchar2,
   X_picking_rule               OUT NOCOPY varchar2,
   X_atp_rule                   OUT NOCOPY varchar2,
   X_payment_terms              OUT NOCOPY varchar2,
   X_accounting_rule            OUT NOCOPY varchar2,
   X_invoicing_rule             OUT NOCOPY varchar2,
   X_default_shipping_org_dsp   OUT NOCOPY varchar2,
   X_source_organization        OUT NOCOPY varchar2,
   X_source_org_name            OUT NOCOPY varchar2,
   X_weight_uom                 OUT NOCOPY varchar2,
   X_volume_uom                 OUT NOCOPY varchar2,
   X_item_type_dsp              OUT NOCOPY varchar2,
   X_container_type_dsp         OUT NOCOPY varchar2,
   X_conversion_dsp             OUT NOCOPY varchar2,
   X_service_duration_per_code  IN   VARCHAR2
,  X_service_duration_period    OUT  NOCOPY VARCHAR2
,  X_coverage_schedule_id       IN   number
,  X_coverage_schedule          OUT  NOCOPY varchar2
,  p_primary_uom_code           IN   VARCHAR2
,  x_primary_uom                OUT  NOCOPY VARCHAR2
,  x_uom_class                  OUT  NOCOPY VARCHAR2
,  p_dimension_uom_code         IN   VARCHAR2
,  p_default_lot_status_id      IN   NUMBER
,  p_default_serial_status_id   IN   NUMBER
,  x_dimension_uom              OUT  NOCOPY VARCHAR2
,  x_default_lot_status         OUT  NOCOPY VARCHAR2
,  x_default_serial_status      OUT  NOCOPY VARCHAR2
,  p_eam_activity_type_code     IN   VARCHAR2
,  p_eam_activity_cause_code    IN   VARCHAR2
,  p_eam_act_shutdown_status    IN   VARCHAR2
,  x_eam_activity_type          OUT  NOCOPY VARCHAR2
,  x_eam_activity_cause         OUT  NOCOPY VARCHAR2
,  x_eam_act_shutdown_status_dsp OUT NOCOPY VARCHAR2
,  p_secondary_uom_code         IN   VARCHAR2
,  x_secondary_uom              OUT  NOCOPY VARCHAR2
--Jalaj Srivastava Bug 5017588
,  x_secondary_uom_class        OUT  NOCOPY VARCHAR2
,  p_Folder_Category_Set_id     IN   NUMBER
,  x_Folder_Item_Category_id    OUT  NOCOPY NUMBER
,  x_Folder_Item_Category       OUT  NOCOPY VARCHAR2
--Added as part of 11.5.9 ENH
,  p_eam_activity_source_code   IN   VARCHAR2
,  x_eam_activity_source        OUT  NOCOPY VARCHAR2
-- Item Transaction Defaults for 11.5.9
,  X_Default_Move_Order_Sub_Inv OUT  NOCOPY VARCHAR2
,  X_Default_Receiving_Sub_Inv  OUT  NOCOPY VARCHAR2
,  X_Default_Shipping_Sub_Inv   OUT  NOCOPY VARCHAR2
,  X_charge_periodicity_code    IN   VARCHAR2
,  X_charge_unit_of_measure     OUT  NOCOPY VARCHAR2
,  X_inv_item_status_code       IN VARCHAR2
,  X_inv_item_status_code_tl    OUT NOCOPY VARCHAR2
,  p_default_material_status_id      IN   NUMBER
,  x_default_material_status         OUT  NOCOPY VARCHAR2
)
IS

   CURSOR csr_Folder_Category
   IS
      SELECT  category_id, NULL
      FROM  mtl_item_categories
      WHERE
              inventory_item_id = X_item_id
         AND  organization_id   = X_org_id
         AND  category_set_id = p_Folder_Category_Set_id;

   CURSOR csr_Default_SubInventories
   IS
    SELECT subinventory_code, default_type
    FROM   mtl_item_sub_defaults
    WHERE  inventory_item_id = X_Item_Id
      AND  organization_id   = X_org_id; --Bug:2791548

    l_sec_uom_code VARCHAR2(10);

BEGIN

  -- For each product that is fully installed, resolve foreign key references
  --
  if ( INV_Item_Util.g_Appl_Inst.po <> 0 ) then

    if (X_buyer_id is not null) then
   --Modifying the procedure to query buyers from other organisations when the profile is Y
   --For bug no. 3845910- Anmurali

    begin
      	SELECT full_name INTO X_buyer
	FROM   per_people_f
	WHERE  person_id = X_buyer_id
	  AND  trunc(sysdate) between effective_start_date and effective_end_date;
      exception
         when OTHERS then
	    BEGIN
               SELECT full_name INTO X_buyer
	       FROM   per_people_f
	       WHERE  person_id = X_buyer_id;
	    EXCEPTION
	       WHEN OTHERS THEN
	          X_buyer := null;
	    END;
    end;
     --End of alteration for bug no. 3845910- Anmurali
    end if;

    if (X_hazard_class_id is not null) then
    begin
      select hazard_class
      into X_hazard_class
      from po_hazard_classes
      where hazard_class_id = X_hazard_class_id;
    exception
      when NO_DATA_FOUND then
        X_hazard_class := null;
    end;

    end if;

    if (X_un_number_id is not null) then
    begin
      select un_number, description
      into X_un_number, X_un_description
      from po_un_numbers
      where un_number_id = X_un_number_id;

    exception
      when NO_DATA_FOUND then
        X_un_number := null;
        X_un_description := null;
    end;
    end if;

  end if;  -- po_installed

  if ( INV_Item_Util.g_Appl_Inst.ONT <> 0 ) then

    if (X_picking_rule_id is not null) then
    begin
      select picking_rule_name
      into X_picking_rule
      from mtl_picking_rules
      where picking_rule_id = X_picking_rule_id;
    exception
      when NO_DATA_FOUND then
        X_picking_rule := null;
    end;
    end if;

    if (X_atp_rule_id is not null) then
    begin
      select rule_name
      into X_atp_rule
      from mtl_atp_rules
      where rule_id = X_atp_rule_id;
    exception
      when NO_DATA_FOUND then
        X_atp_rule := null;
    end;
    end if;

    if (X_payment_terms_id is not null) then
    begin
      select name
      into X_payment_terms
      from ra_terms
      where term_id = X_payment_terms_id;
    exception
      when NO_DATA_FOUND then
        X_payment_terms := null;
    end;
    end if;

    if (X_default_shipping_org is not null) then
    begin
      select name
      into X_default_shipping_org_dsp
      from hr_organization_units
      where organization_id = X_default_shipping_org;
    exception
      when NO_DATA_FOUND then
        X_default_shipping_org_dsp := null;
    end;
    end if;

  end if;  -- ONT installed

  if ( INV_Item_Util.g_Appl_Inst.ar <> 0 ) then

    if (X_accounting_rule_id is not null) then
    begin
      select name
      into X_accounting_rule
      from ra_rules
      where rule_id = X_accounting_rule_id;
    exception
      when NO_DATA_FOUND then
        X_accounting_rule := null;
    end;
    end if;

    if (X_invoicing_rule_id is not null) then
    begin
      select name
      into X_invoicing_rule
      from ra_rules
      where rule_id = X_invoicing_rule_id;
    exception
      when NO_DATA_FOUND then
        X_invoicing_rule := null;
    end;
    end if;

  end if;  -- ar_installed

  if ( INV_Item_Util.g_Appl_Inst.inv <> 0 ) then

    if (X_atp_rule_id is not null) then
    begin
      select rule_name
      into X_atp_rule
      from mtl_atp_rules
      where rule_id = X_atp_rule_id;
    exception
      when NO_DATA_FOUND then
        X_atp_rule := null;
    end;
    end if;

    if (X_source_organization_id is not null) then
    begin
      select mp.organization_code,hou.name
      into X_source_organization, X_source_org_name
      from hr_organization_units hou
          ,mtl_parameters mp
      where hou.organization_id = mp.organization_id
      and   mp.organization_id  = X_source_organization_id;
    exception
      when NO_DATA_FOUND then
        X_source_organization := null;
        X_source_org_name := null;
    end;
    end if;

  end if;  -- inv_installed

  if ( INV_Item_Util.g_Appl_Inst.inv <> 0 or
       INV_Item_Util.g_Appl_Inst.po  <> 0 ) then

    if (X_weight_uom_code is not null) then
    begin
      select unit_of_measure_tl
        into X_weight_uom
      from mtl_units_of_measure_vl
      where uom_code = X_weight_uom_code;
    exception
      when NO_DATA_FOUND then
        X_weight_uom := null;
    end;
    end if;

    if (X_volume_uom_code is not null) then
    begin
      select unit_of_measure_tl
        into X_volume_uom
      from mtl_units_of_measure_vl
      where uom_code = X_volume_uom_code;
    exception
      when NO_DATA_FOUND then
        X_volume_uom := null;
    end;
    end if;

  end if;  -- inv or po installed

  if ( INV_Item_Util.g_Appl_Inst.inv <> 0 or
       INV_Item_Util.g_Appl_Inst.po  <> 0 or
       INV_Item_Util.g_Appl_Inst.ar  <> 0 or
       INV_Item_Util.g_Appl_Inst.ONT <> 0 ) then

    if (X_item_type is not null) then
    begin
      select meaning
      into X_item_type_dsp
      from fnd_common_lookups
      where lookup_code = X_item_type
      and lookup_type = 'ITEM_TYPE';
    exception
      when NO_DATA_FOUND then
        X_item_type_dsp := null;
    end;
    end if;

    if (X_conversion is not null) then
    begin
      select meaning
      into X_conversion_dsp
      from mfg_lookups
      where lookup_type = 'MTL_CONVERSION_TYPE'
      and lookup_code = X_conversion;
    exception
      when NO_DATA_FOUND then
        X_conversion_dsp := null;
    end;
    end if;

  end if;  -- if po, inv, ar, or ONT installed

  -- Resolve service_duration_period_code
  --
  if ( X_service_duration_per_code is not null ) then
  begin
    select unit_of_measure_tl
      into X_service_duration_period
    from mtl_units_of_measure_vl
    where uom_code = X_service_duration_per_code;
  exception
    when NO_DATA_FOUND then
      X_service_duration_period := null;
  end;
  end if;

  -- Get the primary UOM and UOM Class for item's uom code
  --
  if ( p_primary_uom_code is not null ) then
  begin
    select unit_of_measure_tl, uom_class
      into x_primary_uom, x_uom_class
    from  mtl_units_of_measure_vl
    where uom_code = p_primary_uom_code;
  exception
    when NO_DATA_FOUND then
      x_primary_uom := null;
      x_uom_class := null;
  end;
  end if;

  if ( INV_Item_Util.g_Appl_Inst.OKS <> 0 ) then  -- Contracts Service installed

    if ( X_coverage_schedule_id is not null ) then
       begin
         select  name
           into  X_coverage_schedule
         from  oks_coverage_templts_v
         where  id = X_coverage_schedule_id;
       exception
         when no_data_found then
            X_coverage_schedule := null;
       end;
    end if;

  end if;

  if (X_container_type is not null) then
    begin
      select meaning
      into X_container_type_dsp
      from fnd_common_lookups
      where lookup_code = X_container_type
      and lookup_type = 'CONTAINER_TYPE';
    exception
      when NO_DATA_FOUND then
        X_container_type_dsp := null;
    end;
  end if;

  IF ( INV_Item_Util.g_Appl_Inst.INV <> 0 ) THEN

     IF ( p_dimension_uom_code is not null ) then
     BEGIN
        SELECT  unit_of_measure_tl
          INTO  x_dimension_uom
        FROM  mtl_units_of_measure_vl
        WHERE  uom_code = p_dimension_uom_code;
     EXCEPTION
        WHEN no_data_found THEN
           x_dimension_uom := null;
     END;
     END IF;

  END IF;

--Jalaj Srivastava Bug 5934365
  --No need to check for wms install for lot status
  --material status in R12 is core INV functionality.
--IF ( INV_Item_Util.g_Appl_Inst.WMS <> 0 ) THEN

     IF ( p_default_lot_status_id is not null ) THEN
     BEGIN
        SELECT  status_code
          INTO  x_default_lot_status
        FROM  mtl_material_statuses_vl
        WHERE  status_id = p_default_lot_status_id
          AND  lot_control = 1;
     EXCEPTION
        WHEN no_data_found THEN
           x_default_lot_status := null;
     END;
     END IF;

     -- Fix for Bug#6644711
     IF ( p_default_material_status_id is not null ) THEN
       BEGIN
         SELECT  status_code
         INTO  x_default_material_status
         FROM  mtl_material_statuses_vl
         WHERE  status_id = p_default_material_status_id
         AND  onhand_control = 1;
       EXCEPTION
       WHEN no_data_found THEN
         x_default_material_status := null;
       END;
     END IF;

     IF ( p_default_serial_status_id is not null ) THEN
     BEGIN
        SELECT  status_code
          INTO  x_default_serial_status
        FROM  mtl_material_statuses_vl
        WHERE  status_id = p_default_serial_status_id
          AND  serial_control = 1;
     EXCEPTION
        WHEN no_data_found THEN
           x_default_serial_status := null;
     END;
     END IF;

--END IF;

     if (p_eam_activity_type_code is not null) then
     begin
        select meaning
          into x_eam_activity_type
        from  mfg_lookups
        where lookup_type = 'MTL_EAM_ACTIVITY_TYPE'
                and lookup_code = p_eam_activity_type_code;
     exception
        when NO_DATA_FOUND then
        x_eam_activity_type := null;
     end;
     end if;

     if (p_eam_activity_cause_code is not null) then
     begin
        select meaning
          into x_eam_activity_cause
        from  mfg_lookups
        where lookup_type = 'MTL_EAM_ACTIVITY_CAUSE'
          and lookup_code = p_eam_activity_cause_code;
     exception
        when NO_DATA_FOUND then
        x_eam_activity_cause := null;
     end;
     end if;

     if (p_eam_act_shutdown_status is not null) then
     begin
        select meaning
          into x_eam_act_shutdown_status_dsp
        from  mfg_lookups
        where lookup_type = 'BOM_EAM_SHUTDOWN_TYPE'
          and lookup_code = p_eam_act_shutdown_status;
     exception
        when NO_DATA_FOUND then
        x_eam_act_shutdown_status_dsp := null;
     end;
     end if;
--Added as part of 11.5.9 ENH
     if (p_eam_activity_source_code is not null) then
     begin
        select meaning
          into x_eam_activity_source
        from fnd_lookup_values_vl
        where lookup_type = 'MTL_EAM_ACTIVITY_SOURCE'
          and lookup_code = p_eam_activity_source_code;
     exception
        when NO_DATA_FOUND then
        x_eam_activity_source := null;
     end;
     end if;

     IF ( p_secondary_uom_code IS NOT NULL ) THEN
     BEGIN
        SELECT  unit_of_measure_tl, uom_class
          INTO  x_secondary_uom, x_secondary_uom_class
        FROM  mtl_units_of_measure_vl
        WHERE  uom_code = p_secondary_uom_code;
     EXCEPTION
        WHEN no_data_found THEN
           x_secondary_uom := NULL;
           x_secondary_uom_class := NULL;
     END;
     END IF;

     IF x_secondary_uom_class IS NULL THEN
       BEGIN
         SELECT secondary_uom_code
	   INTO l_sec_uom_code
	   FROM mtl_system_items
          WHERE inventory_item_id = X_item_id
	    AND secondary_uom_code IS NOT NULL
	    AND rownum = 1;
       EXCEPTION
         WHEN no_data_found THEN
           l_sec_uom_code := NULL;
       END;
       IF l_sec_uom_code IS NOT NULL THEN
         BEGIN
           SELECT uom_class
	     INTO x_secondary_uom_class
	     FROM mtl_units_of_measure_vl
	    WHERE uom_code = l_sec_uom_code;
	  EXCEPTION
           WHEN no_data_found THEN
	     x_secondary_uom_class := NULL;
	  END;
	END IF;
      END IF;

/*  No need for this FK -- the form field is a poplist.

     IF ( p_contract_item_type_code IS NOT NULL ) THEN
     BEGIN
        SELECT  meaning
          INTO  x_contract_item_type
        FROM  fnd_lookup_values_vl
        WHERE  lookup_type = 'OKB_CONTRACT_ITEM_TYPE'
          AND  lookup_code = p_contract_item_type_code;
     EXCEPTION
        WHEN no_data_found THEN
           x_contract_item_type := NULL;
     END;
     END IF;
*/

     IF ( p_Folder_Category_Set_id IS NOT NULL ) THEN
     BEGIN

        OPEN csr_Folder_Category;

        FETCH csr_Folder_Category
        INTO
           x_Folder_Item_Category_id
        ,  x_Folder_Item_Category;

        CLOSE csr_Folder_Category;

     EXCEPTION
       -- WHEN no_data_found THEN
        WHEN others THEN

           IF ( csr_Folder_Category%ISOPEN ) THEN
              CLOSE csr_Folder_Category;
           END IF;

           x_Folder_Item_Category_id := NULL;
           x_Folder_Item_Category := NULL;

     END;
     END IF;
 -- Populate Item Transaction Default SubInventories for 11.5.9
     BEGIN
          X_Default_Move_Order_Sub_Inv := NULL;
          X_Default_Receiving_Sub_Inv := NULL;
          X_Default_Shipping_Sub_Inv := NULL;
     FOR I IN csr_Default_SubInventories LOOP
      IF I.Default_Type = 3 THEN
        X_Default_Move_Order_Sub_Inv := I.subinventory_code;
      ELSIF I.Default_Type = 2 THEN
        X_Default_Receiving_Sub_Inv := I.subinventory_code;
      ELSIF I.Default_Type = 1 THEN
        X_Default_Shipping_Sub_Inv := I.subinventory_code;
      END IF;
     END LOOP;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          X_Default_Move_Order_Sub_Inv := NULL;
          X_Default_Receiving_Sub_Inv := NULL;
          X_Default_Shipping_Sub_Inv := NULL;
     END;

    BEGIN
      IF X_charge_periodicity_code IS NOT NULL THEN
         SELECT UNIT_OF_MEASURE INTO X_charge_unit_of_measure
         from mtl_units_of_measure_vl     --Bug 5174403
         WHERE UOM_CODE = X_charge_periodicity_code;
      END IF;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        X_charge_unit_of_measure := NULL;
    END;

    BEGIN
      IF X_inv_item_status_code IS NOT NULL THEN
       select inventory_item_status_code_tl INTO X_inv_item_status_code_tl
         from mtl_item_status
	where inventory_item_status_code = X_inv_item_status_code;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        X_inv_item_status_code_tl := NULL;
    END;

END Populate_Fields;


-- Function to check on entry if source organization is valid
-- Returns:     0 - source org is ok
--              1 - source org does not have item and/or does not use
--                   the same set of books
--              2 - sub is nettable or null
--              3 - interorg network is not defined
--
FUNCTION Validate_Source_Org(X_org_id      number,
                             X_item_id     number,
                             X_new_item_id number,
                             X_source_org  number,
                             X_mrp_plan    number,
                             X_source_sub  varchar2
                            ) return number is
  source_item      number;
  nettable_sub     number;
  org_network      number;

begin

  -- If this returns a row, item exists in source org
/* Fix for bug 5844510-Commented the below query.
  select count(1)
  into source_item
  from dual
  where X_source_org in (
        select organization_id
        from mtl_system_items
        where (inventory_item_id = nvl(X_new_item_id, -11)
        or inventory_item_id = nvl(X_item_id, -11))
        )
  and rownum = 1;
*/
/* Fix for bug 5844510- Replaced the above query with one below. This was done to improve its performance.
   Here it is sufficient to check whether the item exists in the source org.
   Note that source_org is already validated against OOD view in INVPVD6B.pls*/

   select count(1)
   into   source_item
   from   mtl_system_items_b
   where  (inventory_item_id = nvl(X_new_item_id, -11)
           or inventory_item_id = nvl(X_item_id, -11))
   and    organization_id= X_source_org;

  if (source_item = 0) then
    return(1);
  end if;

  if (X_source_org = X_org_id) then
 -- return code of 2 does not seem to be used anywhere.
 -- however, in future if to be used, mrp_plan of 3,7,9 to function
 -- similar. enhancement for MRP planning code attribute
    if (X_mrp_plan = 3 or
        X_mrp_plan = 7 or
        X_mrp_plan = 9 ) then
      -- If this returns a row, the sub is nettable or null
      select count(1)
      into nettable_sub
      from mtl_secondary_inventories
      where secondary_inventory_name=nvl(X_source_sub, secondary_inventory_name)
      and availability_type = 1
      and rownum = 1;
    end if;

    if (nettable_sub = 1) then
      return(2);
    end if;

  else
    -- If this returns a row, the interorg network is defined
    select count(1)
    into org_network
    from mtl_interorg_parameters
    where to_organization_id = X_org_id
    and from_organization_id = X_source_org
    and rownum = 1;

    -- No org network defined, so return 3
    if (org_network = 0) then
      return(3);
    end if;

  end if;   -- if source_org = org_id

  return(0);

end Validate_Source_Org;

--2463543 :Below is used in Item Search Form. Exclusively Built for INVIVCSU
PROCEDURE Item_Search_Execute_Query
                       (p_grp_handle_id      IN NUMBER,
                        p_org_id             IN NUMBER   DEFAULT NULL,
                        p_item_mask          IN VARCHAR2 DEFAULT NULL,
			p_item_description   IN VARCHAR2 DEFAULT NULL,
			p_base_item_id       IN NUMBER   DEFAULT NULL,
			p_status             IN VARCHAR2 DEFAULT NULL,
			p_catalog_grp_id     IN NUMBER   DEFAULT NULL,
			p_catalog_complete   IN VARCHAR2 DEFAULT NULL,
			p_manufacturer_id    IN NUMBER   DEFAULT NULL,
			p_mfg_part_num       IN VARCHAR2 DEFAULT NULL,
			p_vendor_id          IN NUMBER   DEFAULT NULL,
			p_default_assignment IN VARCHAR2 DEFAULT NULL,
			p_vendor_product_num IN VARCHAR2 DEFAULT NULL,
			p_contract           IN VARCHAR2 DEFAULT NULL,
			p_blanket_agreement  IN VARCHAR2 DEFAULT NULL,
			p_xref_type          IN dbms_sql.Varchar2_Table,
			p_xref_val           IN dbms_sql.Varchar2_Table,
			p_relationship_type  IN dbms_sql.Number_Table,
			p_related_item       IN dbms_sql.Number_Table,
			p_category_set       IN dbms_sql.Number_Table,
			p_category_id        IN dbms_sql.Number_Table,
			p_element_name       IN dbms_sql.Varchar2_Table,
			p_element_val        IN dbms_sql.Varchar2_Table) IS

   l_cursor                NUMBER;
   l_rowcount              NUMBER;
   sql_stmt                VARCHAR2(30000);

   l_supplier_stmt         VARCHAR2(2000);
   l_sup_tab_list          VARCHAR2(200);
   l_sup_where_clause      VARCHAR2(2000);

   l_xref_stmt             VARCHAR2(2000);
   l_xref_row_stmt         VARCHAR2(2000);
   l_xref_bind             NUMBER := 1;

   l_relation_stmt         VARCHAR2(2000);
   l_relation_row_stmt     VARCHAR2(2000);
   l_relation_bind         NUMBER := 1;

   l_category_stmt         VARCHAR2(2000);
   l_category_row_stmt     VARCHAR2(2000);
   l_category_bind         NUMBER := 1;

   l_element_stmt          VARCHAR2(2000);
   l_element_row_stmt      VARCHAR2(2000);
   l_element_bind          NUMBER := 1;
BEGIN

    l_cursor := DBMS_SQL.OPEN_CURSOR;
    sql_stmt := 'INSERT INTO MTL_CATALOG_SEARCH_ITEMS ( ' ||
                     ' SELECT :handle,            MSI.INVENTORY_ITEM_ID, '||
		     '        MSI.ORGANIZATION_ID,MSI.DESCRIPTION,       '||
		     '        MSI.PRIMARY_UOM_CODE, MSI.RESERVABLE_TYPE  '||
		     ' FROM  MTL_SYSTEM_ITEMS_VL MSI                     '||
		     ' WHERE 1= 1                                        ';

    IF p_org_id IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.ORGANIZATION_ID = :p_org_id ';
    END IF;

    IF p_item_mask IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.CONCATENATED_SEGMENTS LIKE :p_item_mask ';
    END IF;

    -- FP bug fix for 12.1.1. The bug # is 7303779
    -- Fixed by Sean on 10/14/08. Added upper function
    -- to make the description search case insensitive
    IF p_item_description IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND upper(MSI.DESCRIPTION) LIKE upper(:p_item_description) ';
    END IF;
    -- END of fix 730799
    IF p_base_item_id IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.BASE_ITEM_ID = :p_base_item_id ' ;
    END IF;

    IF p_status IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.INVENTORY_ITEM_STATUS_CODE = :p_status ';
    END IF;

    IF p_catalog_grp_id IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.ITEM_CATALOG_GROUP_ID = :p_catalog_grp_id ';
    END IF;

    IF p_catalog_complete IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.CATALOG_STATUS_FLAG = :p_catalog_complete ';
    END IF;

    -- Start Purchase Details Query Building
    IF p_manufacturer_id IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND EXISTS (SELECT NULL FROM MTL_MFG_PART_NUMBERS MPN ' ||
                                             ' WHERE MPN.MANUFACTURER_ID   = :p_manufacturer_id '||
					     ' AND   MPN.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID ';
       IF p_mfg_part_num IS NOT NULL THEN
          sql_stmt := sql_stmt || ' AND MPN.MFG_PART_NUM = :p_mfg_part_num ';
       END IF;
       sql_stmt := sql_stmt || ')';
    END IF;

    IF p_vendor_id IS NOT NULL THEN
       l_sup_tab_list := 'MRP_SOURCING_RULES MS, MRP_SR_ASSIGNMENTS MA, MRP_SR_RECEIPT_ORG MR, MRP_SR_SOURCE_ORG M1';
       l_sup_where_clause := 'M1.VENDOR_ID = :p_vendor_id AND MA.assignment_set_id = :p_default_assignment ' ||
                             'AND MA.sourcing_rule_id = MS.sourcing_rule_id AND MR.sr_receipt_id = M1.sr_receipt_id ' ||
			     'AND MA.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID ';
    END IF;

    IF p_vendor_product_num IS NOT NULL THEN
       IF l_sup_tab_list IS NOT NULL THEN
	    l_sup_tab_list := l_sup_tab_list || ', ';
       END IF;
       l_sup_tab_list := l_sup_tab_list || 'PO_LINES_ALL L';
       IF l_sup_where_clause IS NOT NULL THEN
          l_sup_where_clause := l_sup_where_clause || ' AND ';
       END IF;
       l_sup_where_clause := l_sup_where_clause || 'L.VENDOR_PRODUCT_NUM = :p_vendor_product_num ' ||
                                                   'AND L.ITEM_ID = MSI.INVENTORY_ITEM_ID';
    END IF;

    IF p_contract IS NOT NULL THEN
       IF l_sup_tab_list IS NOT NULL THEN
	    l_sup_tab_list := l_sup_tab_list || ', ';
       END IF;
       l_sup_tab_list := l_sup_tab_list || 'PO_HEADERS_ALL H';
       IF INSTR(l_sup_tab_list,'PO_LINES_ALL') = 0 THEN
          l_sup_tab_list := l_sup_tab_list || ',PO_LINES_ALL L';
          IF l_sup_where_clause IS NOT NULL THEN
             l_sup_where_clause := l_sup_where_clause || ' AND ';
          END IF;
          l_sup_where_clause := l_sup_where_clause || ' L.ITEM_ID = MSI.INVENTORY_ITEM_ID ';
       END IF;
       IF l_sup_where_clause IS NOT NULL THEN
          l_sup_where_clause := l_sup_where_clause || ' AND ';
       END IF;
       l_sup_where_clause := l_sup_where_clause || 'H.SEGMENT1 = :p_contract AND H.PO_HEADER_ID = L.PO_HEADER_ID';
    END IF;

    IF p_blanket_agreement IS NOT NULL THEN
       IF l_sup_tab_list IS NOT NULL THEN
	    l_sup_tab_list := l_sup_tab_list || ', ';
       END IF;
       l_sup_tab_list := l_sup_tab_list || 'PO_HEADERS_ALL H2';
       IF INSTR(l_sup_tab_list,'PO_LINES_ALL') = 0 THEN
          l_sup_tab_list := l_sup_tab_list || ', PO_LINES_ALL L';
          IF l_sup_where_clause IS NOT NULL THEN
             l_sup_where_clause := l_sup_where_clause || ' AND ';
          END IF;
          l_sup_where_clause := l_sup_where_clause || ' L.ITEM_ID = MSI.INVENTORY_ITEM_ID ';
       END IF;
       l_sup_where_clause := l_sup_where_clause || 'H2.SEGMENT1 = :p_blanket_agreement ' ||
                                                   ' AND H2.PO_HEADER_ID = L.PO_HEADER_ID';
    END IF;

    IF l_sup_tab_list IS NOT NULL THEN
       l_supplier_stmt := 'SELECT NULL FROM ' || l_sup_tab_list || ' WHERE ' || l_sup_where_clause;
       sql_stmt := sql_stmt || ' AND EXISTS (' || l_supplier_stmt || ')';
    END IF;

    -- Start Xref Details Query Building
    IF p_xref_type.COUNT <> 0 THEN
       FOR i IN p_xref_type.FIRST .. p_xref_type.LAST LOOP
          l_xref_row_stmt := '(SELECT MCR.INVENTORY_ITEM_ID FROM MTL_CROSS_REFERENCES MCR ' ||
                             ' WHERE MCR.CROSS_REFERENCE_TYPE = :xref_type' ||  l_xref_bind ||
			     '   AND MCR.CROSS_REFERENCE = :xref_val' || l_xref_bind || ')';
          l_xref_bind := l_xref_bind + 1;
	  IF l_xref_stmt IS NOT NULL THEN
	     l_xref_stmt := l_xref_stmt || ' INTERSECT ';
	  END IF;
	  l_xref_stmt := l_xref_stmt || l_xref_row_stmt;
       END LOOP;
    END IF;
    IF l_xref_stmt IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.INVENTORY_ITEM_ID IN (' || l_xref_stmt || ')';
    END IF;

    -- Start Item Relation Query Building.
    IF p_relationship_type.COUNT <> 0 THEN
       FOR i IN p_relationship_type.FIRST .. p_relationship_type.LAST LOOP
          l_relation_row_stmt := '(SELECT MRI.INVENTORY_ITEM_ID FROM MTL_RELATED_ITEMS_VIEW MRI ' ||
                                 ' WHERE MRI.RELATIONSHIP_TYPE_ID = :relation_type' || l_relation_bind ||
				 '   AND MRI.RELATED_ITEM_ID = :related_item' || l_relation_bind || ')';
	  l_relation_bind := l_relation_bind + 1;
	  IF l_relation_stmt IS NOT NULL THEN
	     l_relation_stmt := l_relation_stmt || ' INTERSECT ';
	  END IF;
	  l_relation_stmt := l_relation_stmt || l_relation_row_stmt;
       END LOOP;
    END IF;
    IF l_relation_stmt IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.INVENTORY_ITEM_ID IN (' || l_relation_stmt || ')';
    END IF;

    -- Start Item Category Query Building.
    IF p_category_set.COUNT <> 0 THEN
       FOR i IN p_category_set.FIRST .. p_category_set.LAST LOOP
          l_category_row_stmt := '(SELECT MIC.INVENTORY_ITEM_ID FROM MTL_ITEM_CATEGORIES MIC ' ||
                                 ' WHERE MIC.CATEGORY_SET_ID = :category_set' || l_category_bind ||
	                         '   AND MIC.CATEGORY_ID = :category_id' || l_category_bind ||
				 '   AND MIC.ORGANIZATION_ID = MSI.ORGANIZATION_ID)';
	  l_category_bind := l_category_bind + 1;
	  IF l_category_stmt IS NOT NULL THEN
	     l_category_stmt := l_category_stmt || ' INTERSECT ';
	  END IF;
	  l_category_stmt := l_category_stmt || l_category_row_stmt;
       END LOOP;

    END IF;
    IF l_category_stmt IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.INVENTORY_ITEM_ID IN (' || l_category_stmt || ')';
    END IF;

    -- Start Item Catalog Group Query Building.
    IF p_element_name.COUNT <> 0 THEN
       FOR i IN p_element_name.FIRST .. p_element_name.LAST LOOP
          IF(p_element_val(i) IS NOT NULL) THEN
              l_element_row_stmt := '(SELECT DEV.INVENTORY_ITEM_ID FROM MTL_DESCR_ELEMENT_VALUES DEV ' ||
                                  ' WHERE DEV.ELEMENT_NAME = :element_name' || l_element_bind ||
	                                '   AND DEV.ELEMENT_VALUE = :element_val' || l_element_bind || ')';
          	  l_element_bind := l_element_bind + 1;
          	  IF l_element_stmt IS NOT NULL THEN
          	     l_element_stmt := l_element_stmt || ' INTERSECT ';
          	  END IF;
          	  l_element_stmt := l_element_stmt || l_element_row_stmt;
          END IF;
       END LOOP;
    END IF;
    IF l_element_stmt IS NOT NULL THEN
       sql_stmt := sql_stmt || ' AND MSI.INVENTORY_ITEM_ID IN (' || l_element_stmt || ')';
    END IF;

    sql_stmt := sql_stmt || ')';

    DBMS_SQL.PARSE(l_cursor, sql_stmt, dbms_sql.native);
    DBMS_SQL.BIND_VARIABLE(l_cursor, 'handle', p_grp_handle_id);

    IF p_org_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_org_id', p_org_id);
    END IF;

    IF p_item_mask IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_item_mask', p_item_mask);
    END IF;

    IF p_item_description IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_item_description', p_item_description);
    END IF;

    IF p_base_item_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_base_item_id', p_base_item_id);
    END IF;

    IF p_status IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_status', p_status);
    END IF;

    IF p_catalog_grp_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_catalog_grp_id', p_catalog_grp_id);
    END IF;

    IF p_catalog_complete IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_catalog_complete', p_catalog_complete);
    END IF;

    IF p_manufacturer_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_manufacturer_id', p_manufacturer_id);
       IF p_mfg_part_num IS NOT NULL THEN
	   DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_mfg_part_num' , p_mfg_part_num);
       END IF;
    END IF;

    IF p_vendor_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_vendor_id', p_vendor_id);
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_default_assignment', p_default_assignment);
    END IF;

    IF p_vendor_product_num IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_vendor_product_num', p_vendor_product_num);
    END IF;

    IF p_contract IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_contract', p_contract);
    END IF;

    IF p_blanket_agreement IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_cursor, 'p_blanket_agreement', p_blanket_agreement);
    END IF;

    IF p_xref_type.COUNT <> 0 THEN
       l_xref_bind := 1;
       FOR i IN p_xref_type.FIRST .. p_xref_type.LAST LOOP
          DBMS_SQL.BIND_VARIABLE(l_cursor, 'xref_type' || l_xref_bind , p_xref_type(i));
	  DBMS_SQL.BIND_VARIABLE(l_cursor, 'xref_val' || l_xref_bind , p_xref_val(i));
          l_xref_bind := l_xref_bind + 1;
       END LOOP;
    END IF;

    IF p_relationship_type.COUNT <> 0 THEN
       l_relation_bind := 1;
       FOR i IN p_relationship_type.FIRST .. p_relationship_type.LAST LOOP
           DBMS_SQL.BIND_VARIABLE(l_cursor, 'relation_type' || l_relation_bind, p_relationship_type(i));
	   DBMS_SQL.BIND_VARIABLE(l_cursor, 'related_item' || l_relation_bind, p_related_item(i));
	   l_relation_bind := l_relation_bind + 1;
       END LOOP;
    END IF;

    IF p_category_set.COUNT <> 0 THEN
       l_category_bind := 1;
       FOR i IN p_category_set.FIRST .. p_category_set.LAST LOOP
          DBMS_SQL.BIND_VARIABLE(l_cursor, 'category_set' || l_category_bind, p_category_set(i));
	  DBMS_SQL.BIND_VARIABLE(l_cursor, 'category_id' || l_category_bind, p_category_id(i));
          l_category_bind := l_category_bind + 1;
       END LOOP;
    END IF;

    IF p_element_name.COUNT <> 0 THEN
       l_element_bind := 1;
       FOR i IN p_element_name.FIRST .. p_element_name.LAST LOOP
          IF(p_element_val(i) IS NOT NULL) THEN
              DBMS_SQL.BIND_VARIABLE(l_cursor, 'element_name' || l_element_bind, p_element_name(i));
	            DBMS_SQL.BIND_VARIABLE(l_cursor, 'element_val' || l_element_bind, p_element_val(i));
              l_element_bind := l_element_bind + 1;
           END IF;
       END LOOP;
    END IF;

    l_rowcount := DBMS_SQL.EXECUTE(l_cursor);

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

END;

END INVIDIT1;

/
