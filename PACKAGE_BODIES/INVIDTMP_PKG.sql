--------------------------------------------------------
--  DDL for Package Body INVIDTMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVIDTMP_PKG" as
/* $Header: INVIDTMB.pls 120.1 2005/06/21 04:10:52 appldev ship $ */

PROCEDURE Populate_Fields
(  X_template_id                  IN   NUMBER
,			  X_inventory_item_status_code	OUT NOCOPY varchar2,
			  X_primary_unit_of_measure	OUT NOCOPY varchar2,
			  X_item_type_dsp		OUT NOCOPY varchar2,
			  X_bom_item_type		OUT NOCOPY varchar,
			  X_inventory_item_flag		OUT NOCOPY varchar,
			  X_stock_enabled_flag		OUT NOCOPY varchar,
			  X_mtl_transactions_enabled_fla OUT NOCOPY varchar,
			  X_costing_enabled_flag	OUT NOCOPY varchar,
			  X_purchasing_item_flag	OUT NOCOPY varchar,
			  X_purchasing_enabled_flag	OUT NOCOPY varchar,
			  X_customer_order_flag		OUT NOCOPY varchar,
			  X_customer_order_enabled_flag	OUT NOCOPY varchar,
			  X_internal_order_flag		OUT NOCOPY varchar,
			  X_internal_order_enabled_flag	OUT NOCOPY varchar,
			  X_invoiceable_item_flag	OUT NOCOPY varchar,
			  X_invoice_enabled_flag	OUT NOCOPY varchar,
			  X_build_in_wip_flag		OUT NOCOPY varchar,
			  X_bom_enabled_flag		OUT NOCOPY varchar,
                          X_eam_item_type                OUT  NOCOPY NUMBER,
                          /* Start Bug 3713912 */
                          X_recipe_enabled_flag              OUT NOCOPY varchar,
                          X_process_exec_enabled_flag   OUT NOCOPY varchar,
                          X_process_costing_enabled_flag     OUT NOCOPY varchar,
                          X_process_quality_enabled_flag     OUT NOCOPY varchar
                          /* End Bug 3713912 */
)
IS
  v_attr_name	varchar2(50);
  v_attr_value	varchar2(240);
  v_valid_code	number;

  CURSOR attr_info is
	select t.attribute_name,
	       t.attribute_value
	from mtl_item_templ_attributes t
	where template_id = X_template_id;
begin
  OPEN attr_info;
  LOOP
    FETCH attr_info into v_attr_name, v_attr_value;
    EXIT when attr_info%NOTFOUND;


    if (v_attr_name = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE') then
--      X_inventory_item_status_code := v_attr_value;
      Begin
	Select inventory_item_status_code_tl
	INTO X_inventory_item_status_code
	from mtl_item_status
	where  nvl(disable_date, sysdate+1) > sysdate
	and inventory_item_status_code = v_attr_value;
      Exception
	When no_data_found then
	 X_inventory_item_status_code := NULL;
       End;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE') then
       Begin
	SELECT unit_of_measure_tl
        INTO   X_primary_unit_of_measure
        FROM   mtl_units_of_measure_vl
        WHERE  uom_code = v_attr_value;
       Exception
	When no_data_found then
	 X_primary_unit_of_measure := NULL;
       End;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.ITEM_TYPE') then
      X_item_type_dsp := INVIDTMP_PKG.resolve_fnd_lookup('ITEM_TYPE', v_attr_value);
    elsif (v_attr_name =  'MTL_SYSTEM_ITEMS.BOM_ITEM_TYPE') then
      X_bom_item_type := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_FLAG') then
      X_inventory_item_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG') then
      X_stock_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG') then
      X_mtl_transactions_enabled_fla := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.COSTING_ENABLED_FLAG') then
      X_costing_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.PURCHASING_ITEM_FLAG') then
      X_purchasing_item_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG') then
      X_purchasing_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_FLAG') then
      X_customer_order_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG') then
      X_customer_order_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_FLAG') then
      X_internal_order_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG') then
      X_internal_order_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.INVOICEABLE_ITEM_FLAG') then
      X_invoiceable_item_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG') then
      X_invoice_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG') then
      X_build_in_wip_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG') then
      X_bom_enabled_flag := v_attr_value;

--  ** KNAGUMO **
    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.EAM_ITEM_TYPE') then
      X_eam_item_type := v_attr_value;
/* Start Bug 3713912 */
    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG') then
      X_recipe_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG') then
      X_process_exec_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.PROCESS_COSTING_ENABLED_FLAG') then
      X_process_costing_enabled_flag := v_attr_value;

    elsif (v_attr_name = 'MTL_SYSTEM_ITEMS.PROCESS_QUALITY_ENABLED_FLAG') then
      X_process_quality_enabled_flag := v_attr_value;

/* End Bug 3713912 */
    end if;

  end LOOP;
  CLOSE attr_info;

end Populate_Fields;


FUNCTION Resolve_Mfg_Lookup(X_lu_type IN varchar2,
			    X_lu_code IN number
			    ) return varchar2 is
  v_meaning	varchar2(80);

begin
  select meaning
  into v_meaning
  from mfg_lookups
  where lookup_type = X_lu_type
  and lookup_code = X_lu_code;

  return(v_meaning);

exception
  when NO_DATA_FOUND then
    return(null);

end Resolve_Mfg_Lookup;

FUNCTION Resolve_Fnd_Lookup(X_lu_type IN varchar2,
			     X_lu_code IN varchar2
			    ) return varchar2 is
  v_meaning	varchar2(80);

begin
  select meaning
  into v_meaning
  from fnd_common_lookups
  where lookup_type = X_lu_type
  and lookup_code = X_lu_code;

  return(v_meaning);

exception

  when NO_DATA_FOUND then
    return(null);

end Resolve_Fnd_Lookup;

END INVIDTMP_PKG;

/
