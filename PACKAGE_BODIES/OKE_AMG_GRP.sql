--------------------------------------------------------
--  DDL for Package Body OKE_AMG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_AMG_GRP" AS
/* $Header: OKEAMGDB.pls 120.1 2005/09/20 10:30:32 ausmani noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKE_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKE_AMG_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKE_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKE_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_CRT                        CONSTANT   VARCHAR2(10)  := 'CREATE';
  G_DEL                        CONSTANT   VARCHAR2(10)  := 'DELETE';
  G_UPD                        CONSTANT   VARCHAR2(10)  := 'UPDATE';
  G_SHIP                       CONSTANT   VARCHAR2(10)  := 'WSH';
  G_REQ                        CONSTANT   VARCHAR2(10)  := 'REQ';
  G_MDS                        CONSTANT   VARCHAR2(10)  := 'MDS';
  G_SOURCE_CODE                CONSTANT   VARCHAR2(3)   := 'PA';
  G_INV                        CONSTANT   VARCHAR2(30)   := 'INVENTORY';
  G_EXP                        CONSTANT   VARCHAR2(30)   :=  'EXPENSE';
  G_USER                       CONSTANT   VARCHAR2(4)   :=  'User';

  l_project_name               Varchar2(30);
  l_deliverable_name           Varchar2(150);
  l_action_name                varchar2(240);

Function get_project_name(p_project_id number) return varchar2 IS
cursor c_get_project_name is
Select name from pa_projects_all where project_id=p_project_id;

l_name varchar2(30);
begin
    open  c_get_project_name;
    fetch c_get_project_name into l_name;
    If c_get_project_name%notfound then
         close c_get_project_name;
         raise  FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
    close c_get_project_name;
    return l_name;
end;

Function get_dlv_name(p_deliverable_id number) return varchar2 IS
cursor c_dlv_name is
Select deliverable_number from oke_deliverables_b
 where deliverable_id = p_deliverable_id;

l_name varchar2(30);
begin
    open  c_dlv_name;
    fetch c_dlv_name into l_name;
    If c_dlv_name%notfound then
         close c_dlv_name;
         raise  FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
    close c_dlv_name;
    return l_name;
end;

Procedure validate_dlv_attr(
	                p_master_inv_org_id IN	   NUMBER,
	                p_item_id	    IN OUT NOCOPY NUMBER,
                	p_inventory_org_id  IN OUT NOCOPY NUMBER,
                	p_currency_code	    IN OUT NOCOPY VARCHAR2,
                	p_uom_code	    IN OUT NOCOPY VARCHAR2,
	                p_dlv_short_name    IN OUT NOCOPY VARCHAR2,
	                p_project_id	    IN OUT NOCOPY NUMBER,
	                p_quanitity	    IN OUT NOCOPY NUMBER,
	                p_unit_price	    IN OUT NOCOPY NUMBER,
	                p_unit_number	    IN OUT NOCOPY VARCHAR2,
                        p_quantity          IN OUT NOCOPY VARCHAR2,
	                p_item_dlv	    IN	    VARCHAR2,
                	p_deliverable_id    IN	    NUMBER,
                	x_return_status	    OUT NOCOPY	    VARCHAR2) IS

Cursor c_check_inv(b_master_org_id number,b_inv_org_id number) is
select 'x' from mtl_parameters
where master_organization_id=b_master_org_id
and organization_id=b_inv_org_id;

Cursor c_check_item(b_item_id number,b_inv_org_id number) is
select 'x' from oke_system_items_v
where id1=b_item_id and id2=b_inv_org_id;

Cursor c_check_currency(b_currency_code Varchar2) is
select 'x' from fnd_currencies
where currency_code=b_currency_code
and enabled_flag='Y'
and currency_flag='Y'
and sysdate >= nvl(start_date_active,sysdate)
and sysdate <= nvl(end_date_active,sysdate);

Cursor c_check_uom(b_item_id number,b_uom varchar2) is
select 'x' from mtl_item_uoms_view
where inventory_item_id=b_item_id
and uom_code=b_uom;

Cursor c_check_unit_number(b_item_id number,b_unit_number varchar2) is
select 'x' from pjm_unit_numbers_lov_v
where end_item_id=b_item_id
and unit_number=b_unit_number;

Cursor c_get_primary_uom(b_item_id number) is
select primary_uom_code from oke_system_items_v
where inventory_item_id=b_item_id;

l_x varchar2(1);
begin

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    If p_dlv_short_name is null then

       oke_api.set_message(p_msg_name       => 'OKE_DLV_SHORT_NAME',
                           p_token1         =>'PROJECT_NAME',
                           p_token1_value   =>l_project_name,
                           p_token2         =>'DELIVERABLE_NAME',
                           p_token2_value   =>l_deliverable_name);
        raise FND_API.G_EXC_ERROR;
    end if;
    If p_item_dlv <>'Y' then
       p_item_id := Null;
       p_inventory_org_id := Null;
       p_currency_code := null;
       p_uom_code := null;
       p_quantity := null;
       p_unit_number := null;
       p_unit_price := null;
    end if;
    If p_inventory_org_id is not null then
       Open c_check_inv(p_master_inv_org_id,p_inventory_org_id);
       Fetch c_check_inv into l_x;
       If c_check_inv%rowcount = 0 then
               oke_api.set_message(p_msg_name       => 'OKE_CHECK_DLV_INV',
                                   p_token1         =>'PROJECT_NAME',
                                   p_token1_value   =>l_project_name,
                                   p_token2         =>'DELIVERABLE_NAME',
                                   p_token2_value   =>l_deliverable_name);
               close c_check_inv;
               raise FND_API.G_EXC_ERROR;
       end if;
       close c_check_inv;

       If p_item_id is not null then
          Open c_check_item(p_item_id,p_inventory_org_id);
          Fetch c_check_item into l_x;
          If c_check_item%rowcount = 0 then
               oke_api.set_message(p_msg_name       =>'OKE_CHECK_DLV_ITEM',
                                   p_token1         =>'PROJECT_NAME',
                                   p_token1_value   =>l_project_name,
                                   p_token2         =>'DELIVERABLE_NAME',
                                   p_token2_value   =>l_deliverable_name);
               close c_check_item;
               raise FND_API.G_EXC_ERROR;
          end if;
          close c_check_item;
       end if;

  Else
      If p_item_id is not null then
         Open c_check_item(p_item_id,p_master_inv_org_id);
         Fetch c_check_item into l_x;
         If c_check_item%rowcount = 0 then
               oke_api.set_message(p_msg_name       =>'OKE_CHECK_DLV_ITEM_MAS',
                                   p_token1         =>'PROJECT_NAME',
                                   p_token1_value   =>l_project_name,
                                   p_token2         =>'DELIVERABLE_NAME',
                                   p_token2_value   =>l_deliverable_name);
               close c_check_item;
               raise FND_API.G_EXC_ERROR;
         end if;
         close c_check_item;
     end if;
  end if;

  If p_uom_code is not null then
    If p_item_id is not null then
       Open c_check_uom(p_item_id ,p_uom_code);
       Fetch c_check_uom into l_x;
       If c_check_uom%rowcount = 0 then
               oke_api.set_message(p_msg_name       =>'OKE_CHECK_UOM',
                                   p_token1         =>'PROJECT_NAME',
                                   p_token1_value   =>l_project_name,
                                   p_token2         =>'DELIVERABLE_NAME',
                                   p_token2_value   =>l_deliverable_name);
               close c_check_uom;
               raise FND_API.G_EXC_ERROR;
        End if;
        Close c_check_uom;
    Else
        oke_api.set_message(p_msg_name       =>'OKE_CHECK_UOM_ENTERABLE',
                            p_token1         =>'PROJECT_NAME',
                            p_token1_value   =>l_project_name,
                            p_token2         =>'DELIVERABLE_NAME',
                            p_token2_value   =>l_deliverable_name);

        raise FND_API.G_EXC_ERROR;
    End if;
  else
     If p_item_id is not null and  p_item_dlv = 'Y' then
        open c_get_primary_uom(p_item_id);
        fetch c_get_primary_uom into p_uom_code;
        close c_get_primary_uom;
     end if;
  End if;

  If p_currency_code is not null then
       Open c_check_currency(p_currency_code);
       Fetch c_check_currency into l_x;
       If c_check_currency%rowcount = 0 then
               oke_api.set_message(p_msg_name       =>'OKE_CHECK_CURRENCY',
                                   p_token1         =>'PROJECT_NAME',
                                   p_token1_value   =>l_project_name,
                                   p_token2         =>'DELIVERABLE_NAME',
                                   p_token2_value   =>l_deliverable_name);
               close c_check_currency;
               raise FND_API.G_EXC_ERROR;
        End if;
        Close c_check_currency;
  else
     If p_inventory_org_id is not null then
        p_currency_code := OKE_ACTION_VALIDATIONS_PKG.functional_currency(p_inventory_org_id);
      end if;
  End if;

  If p_unit_number is not null then
        If p_item_id is not null then
           Open c_check_unit_number(p_item_id,p_unit_number);
           Fetch c_check_unit_number into l_x;
           If c_check_unit_number%rowcount = 0 then
               oke_api.set_message(p_msg_name       =>'OKE_CHECK_UNIT_NO',
                                   p_token1         =>'PROJECT_NAME',
                                   p_token1_value   =>l_project_name,
                                   p_token2         =>'DELIVERABLE_NAME',
                                   p_token2_value   =>l_deliverable_name);
               close c_check_unit_number;
               raise FND_API.G_EXC_ERROR;
            End if;
            Close c_check_unit_number;
	    Else
          oke_api.set_message(p_msg_name       =>'OKE_CHECK_UNIT_NO_ENTERABLE',
                              p_token1         =>'PROJECT_NAME',
                              p_token1_value   =>l_project_name,
                              p_token2         =>'DELIVERABLE_NAME',
                              p_token2_value   =>l_deliverable_name);

           raise FND_API.G_EXC_ERROR;
        end if;
  end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
 x_return_status := G_RET_STS_ERROR ;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 x_return_status := G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN
x_return_status := G_RET_STS_UNEXP_ERROR ;
END;

Procedure Validate_dlv_action_attr(
                        	p_dlv_action_type  IN	VARCHAR2,
	                        p_item_dlv   	   IN	VARCHAR2,
                                p_deliverable_id   IN   NUMBER,
                        	p_inv_org_id	   IN	NUMBER,
                        	p_currency_code	   IN OUT NOCOPY VARCHAR2,
	                        p_quantity	   IN OUT NOCOPY NUMBER,
                           	p_demand_schedule  IN OUT NOCOPY VARCHAR2,
                        	p_ship_from_org_id IN OUT NOCOPY NUMBER,
                        	p_ship_from_loc_id IN OUT NOCOPY NUMBER,
                        	p_ship_to_org_id   IN OUT NOCOPY NUMBER,
                        	p_ship_to_loc_id   IN OUT NOCOPY NUMBER,
                        	p_volume	   IN OUT NOCOPY NUMBER,
                        	p_volume_uom	   IN OUT NOCOPY VARCHAR2,
                        	p_weight	   IN OUT NOCOPY NUMBER,
                        	p_weight_uom       IN OUT NOCOPY VARCHAR2,
                        	p_destination_type_code	IN OUT NOCOPY VARCHAR2,
                        	p_po_need_by_date	IN OUT NOCOPY DATE,
                        	p_exchange_rate_type	IN OUT NOCOPY VARCHAR2,
                        	p_exchange_rate		IN OUT NOCOPY NUMBER,
                        	P_exchange_rate_date	IN OUT NOCOPY DATE,
                        	p_expenditure_type	IN OUT NOCOPY VARCHAR2,
                        	p_expenditure_org_id	IN OUT NOCOPY NUMBER,
                        	p_requisition_line_type_id IN OUT NOCOPY NUMBER,
                        	p_category_id	    IN OUT NOCOPY NUMBER,
                                p_uom_code     	IN OUT NOCOPY VARCHAR2,
                                p_currency     	IN OUT NOCOPY VARCHAR2,
                                p_unit_price     	IN OUT NOCOPY NUMBER,
                           	x_return_status		OUT  NOCOPY  VARCHAR2
                                 )  IS
l_inv number;
Cursor c_check_currency IS
Select 'x' from fnd_currencies b
          where enabled_flag = 'Y'
            and currency_flag = 'Y'
            and b.currency_code = p_currency_code
            and sysdate >= nvl (b.start_date_active, sysdate)
            and sysdate <= nvl (b.end_date_active, sysdate);

Cursor c_check_rec_org IS
Select 'x' from org_organization_definitions
           where nvl(inventory_enabled_flag, 'N') = 'Y'
           and   nvl(disable_date, sysdate) >= sysdate
           and organization_id= p_ship_to_org_id;

Cursor c_check_rec_loc IS
Select 'x' from okx_locations_v ocv
   where organization_id = p_ship_to_org_id
    and  id1= p_ship_to_loc_id;

Cursor c_check_vendor IS
Select 'x' FROM PO_VENDORS
    where sysdate between nvl(start_date_active, sysdate)
    and nvl(end_date_active, sysdate)
    and vendor_id= p_ship_from_org_id;

Cursor c_check_vendor_site IS
Select 'x' from po_supplier_sites_val_v
           where nvl(rfq_only_site_flag, 'N') = 'N'
           and   vendor_id =p_ship_from_org_id
           and vendor_site_id= p_ship_from_loc_id;

Cursor c_check_exchange_type IS
Select 'x' from gl_daily_conversion_types
 where conversion_type= p_exchange_rate_type;

Cursor c_check_expend_type IS
Select 'x' from pa_expenditure_types_expend_v et
           where system_linkage_function = 'VI'
           and et.project_id = (select project_id from oke_deliverables_b
                                                  where deliverable_id=p_deliverable_id)
           and expenditure_type = p_expenditure_type
union
select 'x'  from pa_expenditure_types_expend_v et
            where system_linkage_function = 'VI'
            and et.project_id is null
            and expenditure_type = p_expenditure_type;

Cursor c_check_expend_org IS
Select 'x' from pa_organizations_expend_v o
           where active_flag = 'Y'
           and trunc(sysdate) between o.date_from and nvl(o.date_to, trunc(sysdate))
           and organization_id= p_expenditure_org_id;

Cursor c_check_req_type IS
Select 'x' from po_line_types
           where order_type_lookup_code = 'AMOUNT'
           and line_type_id= p_requisition_line_type_id;
Cursor c_get_inv_org is
select inventory_org_id from oke_deliverables_b
where deliverable_id=p_deliverable_id;

Cursor c_check_demand_schedule IS
Select 'x' from  mrp_designators_view v, oke_deliverables_b b
           where  v.designator_type = 1
           and    nvl( v.disable_date, trunc(sysdate + 1)) > trunc(sysdate)
           and    b.inventory_org_id = v.organization_id
           and    b.deliverable_id=p_deliverable_id
           and    v.designator = p_demand_schedule;

Cursor c_check_ship_from IS
Select 'x' from org_organization_definitions
           where nvl(inventory_enabled_flag, 'N') = 'Y'
           and nvl(disable_date, sysdate) >= sysdate
           and organization_id= p_ship_from_org_id;

Cursor c_check_ship_from_loc IS
Select 'x' from okx_locations_v ocv
           where organization_id = p_ship_from_org_id
           and id1= p_ship_from_loc_id;

Cursor c_check_customer IS
Select 'x' from oke_customer_accounts_v
           where id1= p_ship_to_org_id ;

Cursor c_check_cust_add IS
Select 'x' from oke_cust_site_uses_v
           where site_use_code = 'SHIP_TO'
           and cust_account_id = p_ship_to_org_id
           and location_id= p_ship_to_loc_id;

Cursor c_check_volume_uom IS
Select 'x' from mtl_units_of_measure uom,
                wsh_shipping_parameters wsp
           where wsp.organization_id =p_ship_from_org_id
           and   uom.uom_class = wsp.volume_uom_class
           and   sysdate < nvl(disable_date, sysdate + 1)
           and uom_code= p_volume_uom;

Cursor c_check_weight_uom IS
Select 'x' from mtl_units_of_measure uom,
                wsh_shipping_parameters wsp
           where wsp.organization_id =p_ship_from_org_id
           and   uom.uom_class = wsp.weight_uom_class
           and   sysdate < nvl(disable_date, sysdate + 1)
           and   uom_code= p_weight_uom;
Cursor c_check_uom IS
Select 'x' from mtl_units_of_measure uom
           where sysdate < nvl(disable_date, sysdate + 1)
           and   uom_code= p_uom_code;
Cursor c_check_category IS
Select 'x' from mtl_categories_b
           where category_id =p_category_id;

l_x                  Varchar2(1);
l_function_currency  Varchar2(30);
l_currency           Varchar2(30);

Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   If p_dlv_action_type=G_REQ then
             p_demand_schedule := Null;
             p_volume          := Null;
             p_volume_uom      := Null;
             p_weight_uom      := Null;
             p_weight_uom      := Null;

             If p_item_dlv='Y' then
                   p_category_id              := Null;
                   p_requisition_line_type_id := Null;
                   p_expenditure_type         := Null;
                   p_expenditure_org_id       := Null;
             end if;

       -- Check Currency
               If p_currency_code is not null then
                  Open c_check_currency;
                  fetch c_check_currency into l_x;
                  if c_check_currency%rowcount =0 then
                    oke_api.set_message(p_msg_name   =>'OKE_CHECK_CURRENCY',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name,
                                  p_token3       =>'ACTION_NAME',
                                  p_token3_value =>l_action_name
                                  );
                       Close c_check_currency;
                       raise FND_API.G_EXC_ERROR;
                  end if;
                  Close c_check_currency;
                end if;
     -- Check UOM
               If p_uom_code is not null then
                  Open c_check_uom;
                  fetch c_check_uom into l_x;
                  if c_check_uom%rowcount =0 then
                    oke_api.set_message(p_msg_name   =>'OKE_CHECK_UOM',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name
                                  );
                       Close c_check_uom;
                       raise FND_API.G_EXC_ERROR;
                  end if;
                  Close c_check_uom;
                end if;
             -- Check Destinattion Type

               If p_destination_type_code is not null then
                    If p_destination_type_code not in (G_INV, G_EXP) then
                         oke_api.set_message(p_msg_name     =>'OKE_INVALID_DESTINATION_TYPE',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name,
                                  p_token3       =>'ACTION_NAME',
                                  p_token3_value =>l_action_name
                                  );
                        raise FND_API.G_EXC_ERROR;
                    end if;

                    If p_destination_type_code='INVENTORYE' and p_item_dlv<>'Y' then
                         oke_api.set_message(p_msg_name=>'OKE_INVALID_NONITEM_DEST_TYPE',
                                        p_token1       =>'PROJECT_NAME',
                                        p_token1_value =>l_project_name,
                                        p_token2       =>'DELIVERABLE_NAME',
                                        p_token2_value =>l_deliverable_name,
                                        p_token3       =>'ACTION_NAME',
                                        p_token3_value =>l_action_name
                                        );
                        raise FND_API.G_EXC_ERROR;
                    end if;
              end if;
              -- Check Receiving Org
              If p_ship_to_org_id is not null then
                 If p_item_dlv='Y' then
                   If p_ship_to_org_id <> p_inv_org_id then
                         oke_api.set_message(p_msg_name     =>'OKE_SAME_REC_ORG',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name,
                                  p_token3       =>'ACTION_NAME',
                                  p_token3_value =>l_action_name
                                  );
                        raise FND_API.G_EXC_ERROR;
                   end if;
                 Else
	                    Open c_check_rec_org;
                        Fetch c_check_rec_org into l_x;
                        if c_check_rec_org%rowcount =0 then
                             oke_api.set_message(p_msg_name     =>'OKE_INVALID_REC_ORG',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name,
                                  p_token3       =>'ACTION_NAME',
                                  p_token3_value =>l_action_name
                                  );
                               close c_check_rec_org;
                               raise FND_API.G_EXC_ERROR;
                         end if;
                         close c_check_rec_org;
                  end if;

           end if;
  -- Check Receiving Location
           If p_ship_to_loc_id is not null then
                    If p_ship_to_org_id is not null then
	                Open c_check_rec_loc;
                        Fetch c_check_rec_loc into l_x;
                        if c_check_rec_loc%rowcount =0 then
                             oke_api.set_message(p_msg_name     =>'OKE_INVALID_RECV_LOC',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name,
                                  p_token3       =>'ACTION_NAME',
                                  p_token3_value =>l_action_name
                                  );
                               close c_check_rec_loc;
                               raise FND_API.G_EXC_ERROR;
                         end if;
                         close c_check_rec_loc;
                     else
                         oke_api.set_message(p_msg_name     =>'OKE_INVALID_RECV_LOC1',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name,
                                  p_token3       =>'ACTION_NAME',
                                  p_token3_value =>l_action_name
                                  );
                               close c_check_rec_loc;
                               raise FND_API.G_EXC_ERROR;
                     end if;
               end if;
            -- Check Vendor
               If p_ship_from_org_id is not null then
                        Open c_check_vendor;
                        Fetch c_check_vendor into l_x;
                        if c_check_vendor%rowcount =0 then
                             oke_api.set_message(p_msg_name     =>'OKE_INVALID_VENDOR',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name,
                                  p_token3       =>'ACTION_NAME',
                                  p_token3_value =>l_action_name
                                  );
                               close c_check_vendor;
                               raise FND_API.G_EXC_ERROR;
                         end if;
                         close c_check_vendor;
               end if;
               -- Check Vendor address
               If p_ship_from_loc_id is not null then
                         If p_ship_from_org_id is not null then
                            Open c_check_vendor_site;
                            Fetch c_check_vendor_site into l_x;
                            if c_check_vendor_site%rowcount =0 then
                                   oke_api.set_message(p_msg_name     =>'OKE_INVALID_VENDOR_SITE',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                    );
                                   close c_check_vendor_site;
                                   raise FND_API.G_EXC_ERROR;
                            end if;
                            close c_check_vendor_site;
                         else
                             oke_api.set_message(p_msg_name     =>'OKE_INVALID_VENDOR_SITE1',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                    );
                             raise FND_API.G_EXC_ERROR;
                         end if;
                end if;
                -- Check Exchange rate type
                If p_exchange_rate_type is not null then
                            Open c_check_exchange_type;
                            Fetch c_check_exchange_type into l_x;
                            if c_check_exchange_type%rowcount =0 then
                                   oke_api.set_message(p_msg_name     =>'OKE_INVALID_EXCHANGE_TYPE',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                    );
                                   close c_check_exchange_type;
                                   raise FND_API.G_EXC_ERROR;
                            end if;
                            close c_check_exchange_type;
                end if;
                      -- Check Exchange rate
                If p_exchange_rate is not null and p_exchange_rate_type =G_USER then
                              oke_api.set_message(p_msg_name     =>'OKE_INVALID_EXCHANGE_RATE',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                  );
                               raise FND_API.G_EXC_ERROR;
                 end if;
                 If p_exchange_rate is not null then
                         If p_exchange_rate_type <>'User' then
                            If p_exchange_rate_date is NULL or p_ship_to_org_id is null then
                                       oke_api.set_message(p_msg_name     =>'OKE_INVALID_EXCHANGE_RATE1',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                  );
                                   raise FND_API.G_EXC_ERROR;
                             end if;
                              l_function_currency := OKE_ACTION_VALIDATIONS_PKG.functional_currency(p_ship_to_org_id);
                              Select nvl(p_currency_code,currency_code) into l_currency
                                     from oke_deliverables_b
                                     where deliverable_id=p_deliverable_id;
                              p_exchange_rate := OKE_ACTION_VALIDATIONS_PKG.exchange_rate(l_currency, l_function_currency, p_exchange_rate_type,p_exchange_rate_date);
                         else
                              p_exchange_rate_date := Null;
                         end if;
                   end if;
                         -- Check Expenditure type
                   If p_expenditure_type is not null then
                            Open   c_check_expend_type;
                            Fetch  c_check_expend_type into l_x;
                            if c_check_expend_type%rowcount =0 then
                                   oke_api.set_message(p_msg_name     =>'OKE_INVALID_EXPENDITURE_TYPE',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                    );
                                   close  c_check_expend_type;
                                   raise FND_API.G_EXC_ERROR;
                            end if;
                            close c_check_expend_type;
                   end if;
             -- Check Expenditure org
                   If p_expenditure_org_id is not null then
                            Open   c_check_expend_org;
                            Fetch  c_check_expend_org into l_x;
                            if c_check_expend_org%rowcount =0 then
                                   oke_api.set_message(p_msg_name     =>'OKE_INVALID_EXPENDITURE_ORG',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                    );
                                   close  c_check_expend_org;
                                   raise FND_API.G_EXC_ERROR;
                            end if;
                            close c_check_expend_org;
                   end if;
                               -- Check Requisition Line type
                   If p_requisition_line_type_id is not null then
                            Open   c_check_req_type;
                            Fetch  c_check_req_type into l_x;
                            if c_check_req_type%rowcount =0 then
                                   oke_api.set_message(p_msg_name     =>'OKE_INVALID_REQ_TYPE',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                    );
                                   close  c_check_req_type;
                                   raise FND_API.G_EXC_ERROR;
                            end if;
                            close c_check_req_type;
                   end if;
                   If p_category_id is not null then
                            Open   c_check_category;
                            Fetch  c_check_category into l_x;
                            if c_check_category%rowcount =0 then
                                   oke_api.set_message(p_msg_name     =>'OKE_INVALID_CATEGORY',
                                           p_token1       =>'PROJECT_NAME',
                                           p_token1_value =>l_project_name,
                                           p_token2       =>'DELIVERABLE_NAME',
                                           p_token2_value =>l_deliverable_name,
                                           p_token3       =>'ACTION_NAME',
                                           p_token3_value =>l_action_name
                                                    );
                                   close  c_check_category;
                                   raise FND_API.G_EXC_ERROR;
                            end if;
                            close c_check_category;
                      --Check for Item Category:
                   end if;

    elsif p_dlv_action_type=G_SHIP then
          p_destination_type_code    := Null;
          p_po_need_by_date          := Null;
          p_exchange_rate_type       := Null;
          p_exchange_rate_date       := Null;
          p_exchange_rate            := Null;
          p_expenditure_type         := Null;
          p_expenditure_org_id       := Null;
          p_requisition_line_type_id := Null;
          p_category_id              := Null;
          p_currency_code            := Null;
          p_unit_price               := Null;


          If p_item_dlv='Y' then
             p_volume     := Null;
             p_volume_uom := Null;
             p_weight     := Null;
             p_weight_uom := Null;
          else
             p_demand_schedule := Null;
          end if;
     -- Check UOM
           If p_uom_code is not null then
                  Open c_check_uom;
                  fetch c_check_uom into l_x;
                  if c_check_uom%rowcount =0 then
                    oke_api.set_message(p_msg_name   =>'OKE_CHECK_UOM',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name
                                  );
                       Close c_check_uom;
                       raise FND_API.G_EXC_ERROR;
                  end if;
                  Close c_check_uom;
            end if;
          --Check Demand Schedule
          If p_demand_schedule is not null then
             l_inv := null;
             open c_get_inv_org;
             fetch c_get_inv_org into l_inv;
             close c_get_inv_org;
             If l_inv is not null then
                Open  c_check_demand_schedule;
                Fetch  c_check_demand_schedule into l_x;
                 If c_check_demand_schedule%rowcount =0 then
                     oke_api.set_message(p_msg_name     =>'OKE_INVALID_DEMAND_SCH',
                                         p_token1       =>'PROJECT_NAME',
                                         p_token1_value =>l_project_name,
                                         p_token2       =>'DELIVERABLE_NAME',
                                         p_token2_value =>l_deliverable_name,
                                         p_token3       =>'ACTION_NAME',
                                         p_token3_value =>l_action_name
                                               );
                        close  c_check_demand_schedule;
                        raise FND_API.G_EXC_ERROR;
                 end if;
               close c_check_demand_schedule;
            else
                  oke_api.set_message(p_msg_name     =>'OKE_INV_ORG_B4_PLAN',
                                      p_token1       =>'PROJECT_NAME',
                                      p_token1_value =>l_project_name,
                                      p_token2       =>'DELIVERABLE_NAME',
                                      p_token2_value =>l_deliverable_name,
                                      p_token3       =>'ACTION_NAME',
                                      p_token3_value =>l_action_name
                                         );
                  raise FND_API.G_EXC_ERROR;
            end if;
          end if;
          --Check Ship From org
          If p_ship_from_org_id  is not null then
             Open  c_check_ship_from;
             Fetch  c_check_ship_from into l_x;
             If c_check_ship_from%rowcount =0 then
                     oke_api.set_message(p_msg_name     =>'OKE_INVALID_SHIP_FROM_ORG',
                                         p_token1       =>'PROJECT_NAME',
                                         p_token1_value =>l_project_name,
                                         p_token2       =>'DELIVERABLE_NAME',
                                         p_token2_value =>l_deliverable_name,
                                         p_token3       =>'ACTION_NAME',
                                         p_token3_value =>l_action_name
                                               );
                        close  c_check_ship_from;
                        raise FND_API.G_EXC_ERROR;
              end if;
              close c_check_ship_from;
          end if;
                    --Check Ship From loc
          If p_ship_from_loc_id  is not null then
             If p_ship_from_org_id  is not null then
                Open  c_check_ship_from_loc;
                Fetch  c_check_ship_from_loc into l_x;
                If c_check_ship_from_loc%rowcount =0 then
                     oke_api.set_message(p_msg_name     =>'OKE_INVALID_SHIP_FROM_LOC',
                                         p_token1       =>'PROJECT_NAME',
                                         p_token1_value =>l_project_name,
                                         p_token2       =>'DELIVERABLE_NAME',
                                         p_token2_value =>l_deliverable_name,
                                         p_token3       =>'ACTION_NAME',
                                         p_token3_value =>l_action_name
                                               );
                        close  c_check_ship_from_loc;
                        raise FND_API.G_EXC_ERROR;
                 end if;
                 close c_check_ship_from_loc;
              else
                     oke_api.set_message(p_msg_name     =>'OKE_INVALID_SHIP_FROM_LOC1',
                                         p_token1       =>'PROJECT_NAME',
                                         p_token1_value =>l_project_name,
                                         p_token2       =>'DELIVERABLE_NAME',
                                         p_token2_value =>l_deliverable_name,
                                         p_token3       =>'ACTION_NAME',
                                         p_token3_value =>l_action_name
                                               );
                        raise FND_API.G_EXC_ERROR;
              end if;
          end if;
          -- Check Custome Account

          If p_ship_to_org_id  is not null then
             Open  c_check_customer;
             Fetch  c_check_customer into l_x;
             If c_check_customer%rowcount =0 then
                     oke_api.set_message(p_msg_name     =>'OKE_INVALID_CUSTOMER',
                                         p_token1       =>'PROJECT_NAME',
                                         p_token1_value =>l_project_name,
                                         p_token2       =>'DELIVERABLE_NAME',
                                         p_token2_value =>l_deliverable_name,
                                         p_token3       =>'ACTION_NAME',
                                         p_token3_value =>l_action_name
                                               );
                        close  c_check_customer;
                        raise FND_API.G_EXC_ERROR;
              end if;
              close c_check_customer;
         end if;
         --Check Customer Address
         If p_ship_to_loc_id  is not null then
             If p_ship_to_org_id is not null then
                 Open   c_check_cust_add;
                 Fetch  c_check_cust_add into l_x;
                 If c_check_cust_add%rowcount =0 then
                          oke_api.set_message(p_msg_name     =>'OKE_INVALID_CUST_ADD',
                                              p_token1       =>'PROJECT_NAME',
                                              p_token1_value =>l_project_name,
                                              p_token2       =>'DELIVERABLE_NAME',
                                              p_token2_value =>l_deliverable_name,
                                              p_token3       =>'ACTION_NAME',
                                              p_token3_value =>l_action_name
                                               );
                        close  c_check_cust_add;
                        raise FND_API.G_EXC_ERROR;
                 end if;
                 close c_check_cust_add;
             else
                          oke_api.set_message(p_msg_name     =>'OKE_INVALID_CUST_ADD1',
                                              p_token1       =>'PROJECT_NAME',
                                              p_token1_value =>l_project_name,
                                              p_token2       =>'DELIVERABLE_NAME',
                                              p_token2_value =>l_deliverable_name,
                                              p_token3       =>'ACTION_NAME',
                                              p_token3_value =>l_action_name
                                               );
                        raise FND_API.G_EXC_ERROR;
              end if;
         end if;
         If  p_volume is not null or p_volume_uom is not null
             or  p_weight is not null or  p_weight_uom is not null then
             --Check Volume UOM
             If p_volume_uom is not null then
                 Open c_check_volume_uom;
                 Fetch  c_check_volume_uom into l_x;
                 If c_check_volume_uom%rowcount =0 then
                        oke_api.set_message(p_msg_name     =>'OKE_INVALID_VOLUME_UOM',
                                              p_token1       =>'PROJECT_NAME',
                                              p_token1_value =>l_project_name,
                                              p_token2       =>'DELIVERABLE_NAME',
                                              p_token2_value =>l_deliverable_name,
                                              p_token3       =>'ACTION_NAME',
                                              p_token3_value =>l_action_name
                                               );
                        close  c_check_volume_uom;
                        raise FND_API.G_EXC_ERROR;
                 end if;
                 close c_check_volume_uom;
             end if;
             If p_weight_uom is not null then
                 Open c_check_weight_uom;
                 Fetch  c_check_weight_uom into l_x;
                 If  c_check_weight_uom%rowcount =0 then
                          oke_api.set_message(p_msg_name     =>'OKE_INVALID_WEIGHT_UOM',
                                              p_token1       =>'PROJECT_NAME',
                                              p_token1_value =>l_project_name,
                                              p_token2       =>'DELIVERABLE_NAME',
                                              p_token2_value =>l_deliverable_name,
                                              p_token3       =>'ACTION_NAME',
                                              p_token3_value =>l_action_name
                                               );
                        close  c_check_weight_uom;
                        raise FND_API.G_EXC_ERROR;
                 end if;
                 close c_check_weight_uom;
             end if;
         end if;
    end if;
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
x_return_status := G_RET_STS_ERROR ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
x_return_status := G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN
x_return_status := G_RET_STS_UNEXP_ERROR ;

End;


Procedure manage_dlv (
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_commit	          IN	Varchar2 default fnd_api.g_false,
                   	p_action       		  IN	Varchar2,
	                p_item_dlv		  IN	Varchar2,
	                p_master_inv_org_id	  IN	Number,
	                p_dlv_rec		IN OUT NOCOPY	dlv_rec_type,
	                x_return_status		OUT NOCOPY Varchar2,
                	x_msg_data		OUT NOCOPY Varchar2,
                	x_msg_count		OUT NOCOPY Number
                        ) IS
l_api_version            CONSTANT NUMBER := 1;
l_api_name               CONSTANT VARCHAR2(30) := 'manage_dlv';
l_deliverable_id         NUMBER;
l_x                      Varchar2(1);
l_row_id                 varchar2(30);

CURSOR c_get_dlv_id IS
SELECT
 deliverable_id from oke_deliverables_b
 where project_id=p_dlv_rec.project_id
   and source_deliverable_id=p_dlv_rec.pa_deliverable_id;

cursor c_check_action(b_del_id NUMBER) IS
SELECT 'x'
 from oke_deliverable_actions
 where deliverable_id= b_del_id
   and reference1 > 0;
BEGIN


    -- Standard Start of API savepoint
    SAVEPOINT manage_dlv;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    If p_action not in (G_DEL,G_UPD,G_CRT) then
       oke_api.set_message(p_msg_name       => OKE_API.G_INVALID_VALUE,
                           p_token1         =>'COL_NAME',
                           p_token1_value   =>'p_action');
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    l_project_name := get_project_name(p_dlv_rec.project_id);
    l_deliverable_name := p_dlv_rec.dlv_short_name;

    If p_action in (G_DEL,G_UPD) then
           Open c_get_dlv_id;
           fetch c_get_dlv_id into l_deliverable_id;

           If c_get_dlv_id%notfound then
                oke_api.set_message(p_msg_name     =>OKE_API.G_INVALID_VALUE,
                                    p_token1       =>'COL_NAME',
                                    p_token1_value =>'source_deliverable_id'
                                     );
                close c_get_dlv_id;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

           close c_get_dlv_id;
           Open c_check_action(l_deliverable_id);
           fetch c_check_action into l_x;

           if c_check_action%found then
                oke_api.set_message(p_msg_name     =>'OKE_DLV_ACTION_INITIATED',
                                    p_token1       =>'PROJECT_NAME',
                                    p_token1_value =>l_project_name,
                                    p_token2       =>'DELIVERABLE_NAME',
                                    p_token2_value =>l_deliverable_name
                                     );
                close c_check_action;
                raise FND_API.G_EXC_ERROR;
           end if;
           close c_check_action;
    end if;

    If p_action in (G_CRT,G_UPD) then

                 validate_dlv_attr(
	                p_master_inv_org_id => p_master_inv_org_id,
	                p_item_id	    => p_dlv_rec.item_id,
                	p_inventory_org_id  => p_dlv_rec.inventory_org_id,
                	p_currency_code	    => p_dlv_rec.currency_code,
                	p_uom_code	    => p_dlv_rec.uom_code,
	                p_dlv_short_name    => p_dlv_rec.dlv_short_name,
	                p_project_id	    => p_dlv_rec.project_id,
	                p_quanitity	    => p_dlv_rec.quantity,
	                p_unit_price	    => p_dlv_rec.unit_price,
	                p_unit_number	    => p_dlv_rec.unit_number,
                    p_quantity          => p_dlv_rec.quantity,
	                p_item_dlv	    => p_item_dlv,
                	p_deliverable_id    => l_deliverable_id,
                	x_return_status	    => x_return_status);

                If (x_return_status = G_RET_STS_UNEXP_ERROR) then
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                elsif (x_return_status = G_RET_STS_ERROR) then
                        RAISE FND_API.G_EXC_ERROR ;
                end if;

                If p_action = G_CRT then
                   select oke_k_deliverables_s.nextval into l_deliverable_id from dual;
                   OKE_DELIVERABLES_PKG.insert_row(
                       X_ROWID              => l_row_id,
                       X_DELIVERABLE_ID     => l_deliverable_id,
                       X_DELIVERABLE_NUMBER => p_dlv_rec.dlv_short_name,
                       X_SOURCE_CODE        => G_SOURCE_CODE,
                       X_UNIT_PRICE         => p_dlv_rec.unit_price,
                       X_UOM_CODE           => p_dlv_rec.uom_code,
                       X_QUANTITY           => p_dlv_rec.quantity,
                       X_UNIT_NUMBER        => p_dlv_rec.unit_number,
                       X_ATTRIBUTE_CATEGORY => null,
                       X_ATTRIBUTE1         => null,
                       X_ATTRIBUTE2         => null,
                       X_ATTRIBUTE3         => null,
                       X_ATTRIBUTE4         => null,
                       X_ATTRIBUTE5         => null,
                       X_ATTRIBUTE6         => null,
                       X_ATTRIBUTE7         => null,
                       X_ATTRIBUTE8         => null,
                       X_ATTRIBUTE9         => null,
                       X_ATTRIBUTE10        => null,
                       X_ATTRIBUTE11        => null,
                       X_ATTRIBUTE12        => null,
                       X_ATTRIBUTE13        => null,
                       X_ATTRIBUTE14        => null,
                       X_ATTRIBUTE15        => null,
                       X_SOURCE_HEADER_ID   => p_dlv_rec.project_id,
                       X_SOURCE_LINE_ID     => null,
                       X_SOURCE_DELIVERABLE_ID => p_dlv_rec.pa_deliverable_id,
                       X_PROJECT_ID         => p_dlv_rec.project_id,
                       X_CURRENCY_CODE      => p_dlv_rec.currency_code,
                       X_INVENTORY_ORG_ID   => p_dlv_rec.inventory_org_id,
                       X_DELIVERY_DATE      => NULL,
                       X_ITEM_ID            => p_dlv_rec.item_id,
                       X_DESCRIPTION        => p_dlv_rec.dlv_description,
                       X_COMMENTS           => Null,
                       X_CREATION_DATE      => sysdate,
                       X_CREATED_BY         => Fnd_Global.User_Id,
                       X_LAST_UPDATE_DATE   => sysdate,
                       X_LAST_UPDATED_BY    => Fnd_Global.User_Id,
                       X_LAST_UPDATE_LOGIN  => Fnd_Global.login_id
                           );
                elsif p_action=G_UPD then

                       update OKE_DELIVERABLES_B
                       set
                          CURRENCY_CODE     = p_dlv_rec.currency_code,
                          UNIT_PRICE        = p_dlv_rec.unit_price,
                          UOM_CODE          = p_dlv_rec.uom_code,
                          QUANTITY          = p_dlv_rec.quantity,
                          UNIT_NUMBER       = p_dlv_rec.unit_number,
                          DELIVERABLE_NUMBER= p_dlv_rec.dlv_short_name,
                          PROJECT_ID        = p_dlv_rec.project_id,
                          ITEM_ID           = p_dlv_rec.item_id,
                          SOURCE_HEADER_ID  = p_dlv_rec.project_id,
                          INVENTORY_ORG_ID  = p_dlv_rec.inventory_org_id,
                          SOURCE_CODE       = 'PA',
                          SOURCE_DELIVERABLE_ID = p_dlv_rec.pa_deliverable_id,
                          LAST_UPDATE_DATE  = sysdate,
                          LAST_UPDATED_BY   = fnd_globaL.user_id,
                          LAST_UPDATE_LOGIN = fnd_global.login_id
                     where DELIVERABLE_ID   = l_deliverable_id;
                     if (sql%notfound) then
                           raise  FND_API.G_EXC_UNEXPECTED_ERROR;
                     end if;

                    update OKE_DELIVERABLES_TL set
                          DESCRIPTION =  p_dlv_rec.dlv_description,
                          LAST_UPDATE_DATE  = sysdate,
                          LAST_UPDATED_BY   = fnd_globaL.user_id,
                          LAST_UPDATE_LOGIN = fnd_global.login_id,
                          SOURCE_LANG = userenv('LANG')
                   where DELIVERABLE_ID = l_deliverable_id
                   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

                    If p_item_dlv ='Y' then

                       update OKE_DELIVERABLE_actions
                         set
                          CURRENCY_CODE     = decode(action_type,G_REQ,p_dlv_rec.currency_code,currency_code),
                          UNIT_PRICE        = decode(action_type,G_REQ,p_dlv_rec.unit_price,unit_price),
                          UOM_CODE          = p_dlv_rec.uom_code,
                          QUANTITY          = p_dlv_rec.quantity,
                          LAST_UPDATE_DATE  = sysdate,
                          LAST_UPDATED_BY   = fnd_globaL.user_id,
                          LAST_UPDATE_LOGIN = fnd_global.login_id
                      where DELIVERABLE_ID   = l_deliverable_id;

                    end if;
                end if;
    end if;

    if p_action = G_DEL then
        if p_dlv_rec.pa_deliverable_id is null then
           raise  FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
        OKE_DELIVERABLE_ACTIONS_PKG.delete_deliverable(p_dlv_rec.pa_deliverable_id);
    end if;
   If fnd_api.to_boolean( p_commit ) then
      commit work;
   end if;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 ROLLBACK TO manage_dlv;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

 ROLLBACK TO manage_dlv;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

ROLLBACK TO manage_dlv;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END;

Procedure manage_dlv_action(
                            p_api_version           IN     Number,
                            p_init_msg_list		IN     Varchar2 default fnd_api.g_false,
                            p_commit	        IN     Varchar2 default fnd_api.g_false,
                       	    p_action       		IN     Varchar2,
	                    p_item_dlv		IN     Varchar2,
	                    p_master_inv_org_id	IN     Number,
	                    p_dlv_action_type	IN     Varchar2,
                 	    p_dlv_ship_action_rec	IN OUT NOCOPY dlv_ship_action_rec_type,
	                    p_dlv_req_action_rec	IN OUT NOCOPY dlv_req_action_rec_type,
	                    x_return_status		OUT NOCOPY Varchar2,
                	    x_msg_data		OUT	NOCOPY Varchar2,
                	    x_msg_count		OUT	NOCOPY Number
                        ) IS
l_api_version            CONSTANT NUMBER := 1;
l_api_name               CONSTANT VARCHAR2(30) := 'manage_dlv_action';
l_action_id              NUMBER;
l_deliverable_id         NUMBER;
l_project_id             NUMBER;
l_x                      Varchar2(1);
l_pa_action_id           Number;
l_pa_deliverable_id      Number;
l_inv_org_id             number;
l_currency_code          varchar2(30);
l_quantity               number;
l_demand_schedule        varchar2(10);
l_ship_from_org_id       number;
l_ship_from_loc_id       number;
l_ship_to_org_id         number;
l_item_org_id            number;
l_ship_to_loc_id         number;
l_volume	             NUMBER;
l_volume_uom	         VARCHAR2(30);
l_weight	             NUMBER;
l_weight_uom	         VARCHAR2(30);
l_unit_price             number;
l_destination_type_code	 VARCHAR2(30);
l_po_need_by_date	     DATE;
l_exchange_rate_type	 VARCHAR2(30);
l_exchange_rate		     NUMBER;
l_exchange_rate_date	 DATE;
l_expenditure_type	     VARCHAR2(30);
l_expenditure_org_id	 NUMBER;
l_EXPENDITURE_ITEM_DATE  date;
l_requisition_line_type_id  NUMBER;
l_category_id	          NUMBER;
l_ready_to_procure_flag	  VARCHAR2(1);
l_ready_to_ship_flag	  VARCHAR2(1);
l_task_id                 Number;
l_promised_shipment_date  DATE ;
l_expected_shipment_date  DATE;
l_INSPECTION_REQ_FLAG     varchar2(1);
l_uom_code                Varchar2(30);


cursor c_get_actions_ids(b_pa_action_id number) is
Select act.action_id,
       act.deliverable_id,
       del.project_id
  from oke_deliverable_actions act , oke_deliverables_b del
  where act.deliverable_id = del.deliverable_id
  and   pa_action_id= b_pa_action_id;


cursor c_get_del_ids(b_pa_deliverable_id number) is
Select deliverable_id,
       project_id
  from oke_deliverables_b
  where source_deliverable_id = b_pa_deliverable_id;

Cursor c_get_action_status(b_action_id number) is
Select 'x' from oke_deliverable_actions
where action_id=b_action_id and reference1>0;

Cursor c_get_inv_org(b_deliverable_id number) is
select inventory_org_id from oke_deliverables_b where deliverable_id=b_deliverable_id;

Cursor c_get_item_dtl(b_dlv_id number) is
select uom_code,currency_code,unit_price,quantity,inventory_org_id from oke_deliverables_b
where deliverable_id=b_dlv_id ;
BEGIN


    -- Standard Start of API savepoint
    SAVEPOINT manage_dlv_action;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   If p_action not in (G_CRT,G_DEL,G_UPD) then
       oke_api.set_message(p_msg_name       => OKE_API.G_INVALID_VALUE,
                           p_token1         =>'COL_NAME',
                           p_token1_value   =>'p_action');
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

    If p_dlv_action_type not in (G_SHIP,G_REQ) then
       oke_api.set_message(p_msg_name     => OKE_API.G_INVALID_VALUE,
                           p_token1         =>'COL_NAME',
                           p_token1_value   =>'p_dlv_action_type');
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    Select decode(p_dlv_action_type,G_SHIP,p_dlv_ship_action_rec.pa_action_id,G_REQ, p_dlv_req_action_rec.pa_action_id,NULL),
     decode(p_dlv_action_type,G_SHIP,p_dlv_ship_action_rec.pa_deliverable_id,G_REQ, p_dlv_req_action_rec.pa_deliverable_id,NULL),
     decode(p_dlv_action_type,G_SHIP,p_dlv_ship_action_rec.action_name,G_REQ, p_dlv_req_action_rec.action_name,NULL)
           into l_pa_action_id,l_pa_deliverable_id,l_action_name from dual;

     If l_pa_action_id is null then
       oke_api.set_message(p_msg_name     => OKE_API.G_INVALID_VALUE,
                           p_token1         =>'COL_NAME',
                           p_token1_value   =>'pa_action_id');
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;

     If p_action in (G_DEL,G_UPD) then
          Open c_get_actions_ids(l_pa_action_id);
          Fetch c_get_actions_ids into l_action_id, l_deliverable_id,l_project_id;

            If l_action_id is null then
                oke_api.set_message(p_msg_name     => OKE_API.G_INVALID_VALUE,
                           p_token1         =>'COL_NAME',
                           p_token1_value   =>'pa_action_id');
                  close c_get_actions_ids;
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
          close c_get_actions_ids;
      else
          Open c_get_del_ids(l_pa_deliverable_id);
          Fetch c_get_del_ids into l_deliverable_id,l_project_id;

            If l_deliverable_id is null then
                oke_api.set_message(p_msg_name     => OKE_API.G_INVALID_VALUE,
                                    p_token1         =>'COL_NAME',
                                    p_token1_value   =>'pa_deliverable_id');
                  close c_get_del_ids;
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
          close c_get_del_ids;
      end if;

     l_project_name := get_project_name(l_project_id);
     l_deliverable_name := get_dlv_name(l_deliverable_id);

     If p_action in (G_DEL,G_UPD) then
       Open c_get_action_status(l_action_id);
       fetch c_get_action_status into l_x;
       If c_get_action_status%rowcount > 0 then
              oke_api.set_message(p_msg_name     =>'OKE_DLV_ACTION_INITIATED',
                                  p_token1       =>'PROJECT_NAME',
                                  p_token1_value =>l_project_name,
                                  p_token2       =>'DELIVERABLE_NAME',
                                  p_token2_value =>l_deliverable_name,
                                  p_token3       =>'ACTION_NAME',
                                  p_token3_value =>l_action_name
                                  );
              raise FND_API.G_EXC_ERROR;
       end if;
       close c_get_action_status;

       If p_action = G_DEL then
            If OKE_DELIVERABLE_UTILS_PUB.Action_Deletable_Yn(l_pa_action_id)='Y' then
                OKE_DELIVERABLE_ACTIONS_PKG.Delete_action(l_pa_action_id);
            else
                      oke_api.set_message(p_msg_name     =>'OKE_DLV_ACTION_INITIATED',
                                          p_token1       =>'PROJECT_NAME',
                                          p_token1_value =>l_project_name,
                                          p_token2       =>'DELIVERABLE_NAME',
                                          p_token2_value =>l_deliverable_name,
                                          p_token3       =>'ACTION_NAME',
                                          p_token3_value =>l_action_name
                                        );
                      raise FND_API.G_EXC_ERROR;
            end if;
       end if;
    end if;

    If p_action in (G_CRT,G_UPD) then

               If p_dlv_action_type = G_SHIP then

                   l_action_name             := p_dlv_ship_action_rec.action_name;
                   l_demand_schedule         := p_dlv_ship_action_rec.demand_schedule;
                   l_ship_from_org_id        := p_dlv_ship_action_rec.ship_from_organization_id;
                   l_ship_from_loc_id        := p_dlv_ship_action_rec.ship_from_location_id;
                   l_ship_to_org_id          := p_dlv_ship_action_rec.ship_to_organization_id;
                   l_ship_to_loc_id          := p_dlv_ship_action_rec.ship_to_location_id;
                   l_volume	                 := p_dlv_ship_action_rec.volume;
                   l_volume_uom              := p_dlv_ship_action_rec.volume_uom;
                   l_weight	                 := p_dlv_ship_action_rec.weight;
                   l_weight_uom              := p_dlv_ship_action_rec.weight_uom;
                   l_promised_shipment_date  := p_dlv_ship_action_rec.promised_shipment_date;
                   l_expected_shipment_date  := p_dlv_ship_action_rec.expected_shipment_date;
                   l_inspection_req_flag     := p_dlv_ship_action_rec.inspection_req_flag;
                   l_ready_to_ship_flag	     := p_dlv_ship_action_rec.ready_to_ship_flag;
                   l_task_id                 := p_dlv_ship_action_rec.ship_finnancial_task_id;
                   l_quantity                := p_dlv_ship_action_rec.quantity;
                   l_uom_code                := p_dlv_ship_action_rec.uom_code;

               elsif p_dlv_action_type = G_REQ then

                   l_action_name        := p_dlv_req_action_rec.action_name;
                   l_quantity           := p_dlv_req_action_rec.quantity;
                   l_uom_code           := p_dlv_req_action_rec.uom_code;
                   l_ship_from_org_id   := p_dlv_req_action_rec.vendor_id;
                   l_ship_from_loc_id   := p_dlv_req_action_rec.vendor_site_id;
                   l_ship_to_org_id     := p_dlv_req_action_rec.receiving_org_id;
                   l_ship_to_loc_id     := p_dlv_req_action_rec.receiving_location_id;
                   l_unit_price         := p_dlv_req_action_rec.unit_price;
                   l_currency_code      := p_dlv_req_action_rec.currency;
                   l_destination_type_code	:= p_dlv_req_action_rec.destination_type_code;
                   l_po_need_by_date	:= p_dlv_req_action_rec.po_need_by_date;
                   l_exchange_rate_type	:= p_dlv_req_action_rec.exchange_rate_type;
                   l_exchange_rate_date	:= p_dlv_req_action_rec.exchange_rate_date;
                   l_exchange_rate   	:= p_dlv_req_action_rec.exchange_rate;
                   l_expenditure_type   := p_dlv_req_action_rec.expenditure_type;
                   l_expenditure_org_id := p_dlv_req_action_rec.expenditure_org_id;
                   l_requisition_line_type_id  := p_dlv_req_action_rec.requisition_line_type_id;
                   l_category_id	    := p_dlv_req_action_rec.category_id;
                   l_ready_to_procure_flag	   := p_dlv_req_action_rec.ready_to_procure_flag;
                   l_task_id            := p_dlv_req_action_rec.proc_finnancial_task_id;
                   l_EXPENDITURE_ITEM_DATE := p_dlv_req_action_rec.EXPENDITURE_ITEM_DATE;

               end if;

               open  c_get_inv_org(l_deliverable_id);
               fetch c_get_inv_org into l_inv_org_id;
               close c_get_inv_org;
               If p_item_dlv ='Y' then
                      Open  c_get_item_dtl(l_deliverable_id);
                      fetch c_get_item_dtl into l_uom_code,l_currency_code,l_unit_price,l_quantity,l_item_org_id;
                      close c_get_item_dtl;
                      If p_dlv_action_type=G_SHIP then
                         l_currency_code := null;
                         l_unit_price    := null;
                         l_ship_from_org_id := l_item_org_id;
                      end if;
                      If p_dlv_action_type=G_REQ then
                         l_ship_to_org_id := l_item_org_id;
                      end if;
                end if;


               VALIDATE_DLV_ACTION_ATTR(
                                p_dlv_action_type  => p_dlv_action_type,
	                        p_item_dlv	       => p_item_dlv,
                        	p_inv_org_id	   => l_inv_org_id,
                        	p_deliverable_id   => l_deliverable_id,
	                        p_currency_code	   => l_currency_code,
	                        p_quantity	       => l_quantity,
                        	p_demand_schedule  => l_demand_schedule,
                        	p_ship_from_org_id => l_ship_from_org_id,
                        	p_ship_from_loc_id => l_ship_from_loc_id,
                        	p_ship_to_org_id   => l_ship_to_org_id,
                        	p_ship_to_loc_id   => l_ship_to_loc_id,
                        	p_volume	       => l_volume,
                        	p_volume_uom	   => l_volume_uom,
                        	p_weight	       => l_weight,
                        	p_weight_uom       => l_weight_uom,
                        	p_destination_type_code	=> l_destination_type_code,
                        	p_po_need_by_date	    => l_po_need_by_date,
                        	p_exchange_rate_type	=> l_exchange_rate_type,
                        	p_exchange_rate		    => l_exchange_rate,
                        	P_exchange_rate_date	=> l_exchange_rate_date,
                        	p_expenditure_type	    => l_expenditure_type,
                        	p_expenditure_org_id	=> l_expenditure_org_id,
                        	p_requisition_line_type_id => l_requisition_line_type_id,
                        	p_category_id	        => l_category_id,
                                p_uom_code              => l_uom_code,
                                p_currency              => l_currency_code,
                                p_unit_price            => l_unit_price,
                           	x_return_status		    => x_return_status);

               If (x_return_status = G_RET_STS_UNEXP_ERROR) then
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
               elsif (x_return_status = G_RET_STS_ERROR) then
                        RAISE FND_API.G_EXC_ERROR ;
               end if;

                If p_action=G_CRT then

                   Select oke_k_deliverables_S.nextval into l_action_id  from dual;
                   Insert into oke_deliverable_actions(ACTION_ID,
                                                       CREATION_DATE,
                                                       CREATED_BY ,
                                                       LAST_UPDATE_DATE,
                                                       LAST_UPDATED_BY ,
                                                       LAST_UPDATE_LOGIN,
                                                       ACTION_TYPE ,
                                                       ACTION_NAME ,
                                                       PA_ACTION_ID ,
                                                       TASK_ID ,
                                                       DELIVERABLE_ID,
                                                       SHIP_TO_ORG_ID ,
                                                       SHIP_TO_LOCATION_ID,
                                                       SHIP_FROM_ORG_ID ,
                                                       SHIP_FROM_LOCATION_ID,
                                                       INSPECTION_REQ_FLAG,
                                                       EXPECTED_DATE ,
                                                       PROMISED_DATE ,
                                                       SCHEDULE_DESIGNATOR,
                                                       VOLUME ,
                                                       VOLUME_UOM_CODE,
                                                       WEIGHT ,
                                                       WEIGHT_UOM_CODE,
                                                       EXPENDITURE_ORGANIZATION_ID,
                                                       EXPENDITURE_TYPE ,
                                                       EXPENDITURE_ITEM_DATE,
                                                       DESTINATION_TYPE_CODE ,
                                                       RATE_TYPE ,
                                                       RATE_DATE ,
                                                       EXCHANGE_RATE,
                                                       REQUISITION_LINE_TYPE_ID,
                                                       PO_CATEGORY_ID,
                                                       quantity,
                                                       uom_code,
                                                       unit_price,
                                                       currency_code)
                                                 Values(l_ACTION_ID,
                                                        sysdate,
                                                       fnd_global.user_id ,
                                                       sysdate,
                                                       fnd_global.user_id ,
                                                       fnd_global.login_id,
                                                       p_dlv_action_type ,
                                                       l_ACTION_NAME ,
                                                       l_PA_ACTION_ID ,
                                                       l_TASK_ID ,
                                                       l_DELIVERABLE_ID,
                                                       l_SHIP_TO_ORG_ID ,
                                                       l_SHIP_TO_LOC_ID,
                                                       l_SHIP_FROM_ORG_ID ,
                                                       l_SHIP_FROM_LOC_ID,
                                                       l_INSPECTION_REQ_FLAG,
                                                       decode(p_dlv_action_type,G_REQ,l_po_need_by_date,G_SHIP,l_expected_shipment_date),
                                                       l_PROMISED_shipment_DATE ,
                                                       l_demand_SCHEDULE,
                                                       l_VOLUME ,
                                                       l_VOLUME_UOM,
                                                       l_WEIGHT ,
                                                       l_WEIGHT_UOM,
                                                       l_EXPENDITURE_ORG_ID,
                                                       l_EXPENDITURE_TYPE ,
                                                       l_EXPENDITURE_ITEM_DATE,
                                                       l_DESTINATION_TYPE_CODE ,
                                                       l_exchange_RATE_TYPE ,
                                                       l_exchange_rate_date ,
                                                       l_EXCHANGE_RATE,
                                                       l_REQUISITION_LINE_TYPE_ID,
                                                       l_CATEGORY_ID,
                                                       l_quantity,
                                                       l_uom_code,
                                                       l_unit_price,
                                                       l_currency_code);

               end if;
               If p_action='UPDATE' then
                     update oke_deliverable_actions set
	                        LAST_UPDATE_DATE	=	sysdate,
	                        LAST_UPDATED_BY	=	fnd_global.user_id ,
	                        LAST_UPDATE_LOGIN	=	fnd_global.login_id,
	                        ACTION_TYPE	=	p_dlv_action_type ,
	                        ACTION_NAME	=	l_ACTION_NAME,
	                        PA_ACTION_ID	=	l_PA_ACTION_ID,
	                        TASK_ID	=	l_TASK_ID,
	                        DELIVERABLE_ID	=	l_DELIVERABLE_ID,
	                        SHIP_TO_ORG_ID	=	l_SHIP_TO_ORG_ID,
	                        SHIP_TO_LOCATION_ID	=	l_SHIP_TO_LOC_ID,
	                        SHIP_FROM_ORG_ID	=	l_SHIP_FROM_ORG_ID,
	                        SHIP_FROM_LOCATION_ID	=	l_SHIP_FROM_LOC_ID,
	                        INSPECTION_REQ_FLAG	=	l_INSPECTION_REQ_FLAG,
	                        EXPECTED_DATE	= decode(p_dlv_action_type,G_REQ,l_po_need_by_date,G_SHIP,l_expected_shipment_date),
	                        PROMISED_DATE	=	l_promised_shipment_date,
	                       	SCHEDULE_DESIGNATOR	=	l_demand_schedule,
	                        VOLUME	=	l_VOLUME,
	                        VOLUME_UOM_CODE	=	l_VOLUME_UOM,
	                        WEIGHT	=	l_WEIGHT,
	                        WEIGHT_UOM_CODE	=	l_WEIGHT_UOM,
	                        EXPENDITURE_ORGANIZATION_ID	=	l_EXPENDITURE_ORG_ID,
	                        EXPENDITURE_TYPE	=	l_EXPENDITURE_TYPE,
	                        EXPENDITURE_ITEM_DATE	=	l_EXPENDITURE_ITEM_DATE,
	                        DESTINATION_TYPE_CODE	=	l_DESTINATION_TYPE_CODE,
	                        RATE_TYPE	=	l_EXCHANGE_RATE_TYPE,
	                        RATE_DATE	=	l_EXCHANGE_RATE_DATE,
	                        EXCHANGE_RATE	=	l_EXCHANGE_RATE,
	                        REQUISITION_LINE_TYPE_ID	=	l_REQUISITION_LINE_TYPE_ID,
	                        PO_CATEGORY_ID	=	l_CATEGORY_ID,
                            quantity        =   l_quantity,
                            uom_code        =   l_uom_code,
                            unit_price      =   l_unit_price,
                            currency_code   =   l_currency_code
	           where action_id=l_action_id;


                  -- Update all columns of oke_deliverable_actions;
               end if;
               /*
               If p_dlv_action_type=G_REQ and p_item_dlv <> 'Y' then
                        update oke_deliverables_b set quantity = l_quantity,
                                                      unit_price = l_unit_price,
                                                      currency_code   = l_currency_code,
                                                      uom_code   = l_uom_code
                        where deliverable_id = l_deliverable_id;
                   --Update oke_deliverables_b to update quantity, currency, uom and unit_price;
               end if;
*/
               If p_dlv_action_type =G_REQ and p_dlv_req_action_rec.ready_to_procure_flag='Y' then



                           If OKE_ACTION_VALIDATIONS_PKG.Validate_Req( P_Action_ID			=> l_action_id
			                                                         , P_Deliverable_ID		=> l_deliverable_id
			                                                         , P_Task_ID			=> l_task_id
			                                                         , P_Ship_From_Org_ID	=> l_Ship_From_Org_ID
			                                                         , P_Ship_From_Location_ID	=> l_Ship_From_loc_ID
			                                                         , P_Ship_To_Org_ID		=> l_Ship_To_Org_ID
			                                                         , P_Ship_To_Location_ID => l_Ship_To_Loc_ID
			                                                         , P_Expected_Date		=> l_po_need_by_date
			                                                         , P_Destination_Type_Code	=> l_destination_type_code
			                                                         , P_Requisition_Line_Type_ID => l_requisition_line_type_id
			                                                         , P_Category_ID			 => l_category_id
			                                                         , P_Currency_Code		     => l_currency_code
			                                                         , P_Quantity			     => l_quantity
                                                                     , p_uom_code                => l_uom_code
			                                                         , P_Unit_Price			     => l_unit_price
			                                                         , P_Rate_Type			     => l_exchange_rate_type
			                                                         , P_Rate_Date			     => l_exchange_rate_date
			                                                         , P_Exchange_Rate		     => l_exchange_rate
			                                                         , P_Expenditure_Type_Code	 => l_expenditure_type
			                                                         , P_Expenditure_Organization_Id => l_Expenditure_Org_Id
			                                                         , P_Expenditure_Item_Date	     =>  l_expenditure_item_DATE ) ='Y' then
                                          update oke_deliverable_actions set
                                                   LAST_UPDATE_DATE	=	sysdate,
	                                               LAST_UPDATED_BY	=	fnd_global.user_id ,
	                                               LAST_UPDATE_LOGIN	=	fnd_global.login_id,
	                                               READY_FLAG	=	'Y'
	                                      where action_id=l_action_id;
                             else
                                          raise FND_API.G_EXC_ERROR ;
                             end if;
                end if;
                If p_dlv_action_type =G_SHIP and p_dlv_ship_action_rec.ready_to_ship_flag='Y' then
                           If OKE_ACTION_VALIDATIONS_PKG.Validate_Wsh( P_Action_ID			=> l_action_id
			                                                         , P_Deliverable_ID		=> l_deliverable_id
			                                                         , P_Task_ID			=> l_task_id
			                                                         , P_Ship_From_Org_ID	=> l_Ship_From_Org_ID
			                                                         , P_Ship_From_Location_ID	=> l_Ship_From_loc_ID
			                                                         , P_Ship_To_Org_ID		=> l_Ship_To_Org_ID
			                                                         , P_Ship_To_Location_ID => l_Ship_To_Loc_ID
			                                                         , P_Expected_Date		=> sysdate
			                                                         , P_volume	            => l_volume
			                                                         , P_volume_uom         => l_volume_uom
			                                                         , P_weight			    => l_weight
			                                                         , P_weight_uom		    => l_weight_uom
			                                                         , P_quantity	        => l_quantity
			                                                         , P_uom_code		    => l_uom_code
                                                                     ) ='Y' then
                                          update oke_deliverable_actions set
                                                   LAST_UPDATE_DATE	 =	sysdate,
	                                               LAST_UPDATED_BY	 =	fnd_global.user_id ,
	                                               LAST_UPDATE_LOGIN =	fnd_global.login_id,
	                                               READY_FLAG        =	'Y'
	                                      where action_id=l_action_id;
                             else
                                          raise FND_API.G_EXC_ERROR ;
                             end if;
                end if;
               If p_dlv_action_type =G_SHIP then
                  If p_dlv_ship_action_rec.initiate_planning_flag ='Y' then
                     initiate_dlv_action(
                              p_api_version     => 1,
                              p_pa_action_id    => l_pa_action_id,
                              p_dlv_action_type => G_MDS,
                              x_return_status   => x_return_status,
                              x_msg_data        => x_msg_data,
                              x_msg_count       => x_msg_count);
                       If (x_return_status = G_RET_STS_UNEXP_ERROR) then
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                       elsif (x_return_status = G_RET_STS_ERROR) then
                           RAISE FND_API.G_EXC_ERROR ;
                      end if;
                  end if;
                  If p_dlv_ship_action_rec.initiate_shipping_flag ='Y' then
                     initiate_dlv_action (
                              p_api_version     => 1,
                              p_pa_action_id    => l_pa_action_id,
                              p_dlv_action_type => G_SHIP,
                              x_return_status   => x_return_status,
                              x_msg_data        => x_msg_data,
                              x_msg_count       => x_msg_count);
                       If (x_return_status = G_RET_STS_UNEXP_ERROR) then
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                       elsif (x_return_status = G_RET_STS_ERROR) then
                           RAISE FND_API.G_EXC_ERROR ;
                      end if;
                 end if;
              end if;
              If p_dlv_action_type =G_REQ and p_dlv_req_action_rec.initiate_procure_flag ='Y' then
                      initiate_dlv_action (
                              p_api_version     => 1,
                              p_pa_action_id    => l_pa_action_id,
                              p_dlv_action_type => G_REQ,
                              x_return_status   => x_return_status,
                              x_msg_data        => x_msg_data,
                              x_msg_count       => x_msg_count);
                       If (x_return_status = G_RET_STS_UNEXP_ERROR) then
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                       elsif (x_return_status = G_RET_STS_ERROR) then
                           RAISE FND_API.G_EXC_ERROR ;
                      end if;
               end if;
     end if;
   If fnd_api.to_boolean( p_commit ) then
      commit work;
   end if;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 ROLLBACK TO manage_dlv_action;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

 ROLLBACK TO manage_dlv_action;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

ROLLBACK TO manage_dlv_action;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END;



Procedure initiate_dlv_action(
                            p_api_version       IN     Number,
                            p_init_msg_list		IN     Varchar2 default fnd_api.g_false,
                            p_commit	        IN     Varchar2 default fnd_api.g_false,
                       	    p_pa_action_id      IN     Number,
	                    p_dlv_action_type	IN     Varchar2,
	                    x_return_status	OUT NOCOPY   Varchar2,
                	    x_msg_data	        OUT NOCOPY   Varchar2,
                	    x_msg_count	        OUT NOCOPY   Number
                        ) IS
l_api_version            CONSTANT NUMBER := 1;
l_api_name               CONSTANT VARCHAR2(30) := 'initiate_dlv_action';
Cursor c_get_detail(b_pa_action_id number) is
Select act.deliverable_id,
       action_id,
       Task_ID,
       Ship_From_Org_ID,
       Ship_From_Location_ID,
       Ship_To_Org_ID,
       Ship_To_Location_ID,
       Schedule_Designator,
       Expected_Date,
       ready_flag,
       action_name,
       dlv.project_id,
       act.quantity,
       act.uom_code
from oke_deliverable_actions act,oke_deliverables_b dlv
where pa_action_id=b_pa_action_id
and   dlv.deliverable_id = act.deliverable_id;

l_deliverable_id        Number;
l_Task_ID               Number;
l_Ship_From_Org_ID      Number;
l_Ship_From_Location_ID Number;
l_Ship_To_Org_ID        Number;
l_Ship_To_Location_ID   Number;
l_Schedule_Designator   Varchar2(10);
l_Expected_Date         Date;
l_ready_flag            Varchar2(1);
l_action_id             Number;
l_out_id                Number;
l_action_name           Varchar2(240);
l_project_id            Number;
l_project_name          Varchar2(30);
l_quantity              Number;
l_uom_code              Varchar2(30);
l_deliverable_name      varchar2(100);
BEGIN

    SAVEPOINT initiate_dlv_action;
        -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    If p_dlv_action_type not in (G_SHIP,G_REQ,G_MDS) then
              oke_api.set_message(p_msg_name       => OKE_API.G_INVALID_VALUE,
                                  p_token1         =>'COL_NAME',
                                  p_token1_value   =>'p_dlv_action_type');
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if;

    Open  c_get_detail(p_pa_action_id );
    Fetch c_get_detail into l_deliverable_id,
                            l_action_id,
                            l_Task_ID,
                            l_Ship_From_Org_ID,
                            l_Ship_From_Location_ID,
                            l_Ship_To_Org_ID,
                            l_Ship_To_Location_ID,
                            l_Schedule_Designator,
                            l_Expected_Date,
                            l_ready_flag,
                            l_action_name,
                            l_project_id,
                            l_quantity,
                            l_uom_code ;
    If c_get_detail%rowcount=0 then
       close  c_get_detail;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
    close  c_get_detail;

    l_deliverable_name := get_dlv_name(l_deliverable_id);
    l_project_name     := get_project_name(l_project_id);

    If p_dlv_action_type =G_MDS then
          If OKE_ACTION_VALIDATIONS_PKG.Validate_mds(P_Action_ID            => l_action_id,
                                                     P_Deliverable_ID       => l_deliverable_id,
                                                     P_Task_ID	            => l_task_id,
			                             P_Ship_From_Org_ID     => l_ship_from_org_id,
                                                     P_Ship_From_Location_ID=> l_ship_from_Location_id,
			                             P_Ship_To_Org_ID		=> l_ship_to_org_id,
			                             P_Ship_To_Location_ID  => l_ship_to_location_id,
			                             P_Schedule_Designator	=> l_Schedule_Designator,
                                                     P_Expected_Date		=> l_expected_date,
                                                     P_quantity	            => l_quantity,
			                             P_uom_code		        => l_uom_code)='Y' then

                  OKE_DELIVERABLE_ACTIONS_PKG.Create_Demand( P_Action_ID 	 => l_action_id,
		                                                     P_Init_Msg_List => fnd_api.g_false,
		                                                     X_ID			 => l_out_id,
		                                                     X_Return_Status => x_return_status,
		                                                     X_Msg_Count     => x_msg_count,
		                                                     X_Msg_Data		 => x_msg_data );
                     If (x_return_status = G_RET_STS_UNEXP_ERROR) then
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                     elsif (x_return_status = G_RET_STS_ERROR) then
                           RAISE FND_API.G_EXC_ERROR ;
                     end if;
          else
                  RAISE FND_API.G_EXC_ERROR ;
          end if;

    end if;
    If p_dlv_action_type =G_REQ then
          If l_ready_flag='Y' then
             OKE_DELIVERABLE_ACTIONS_PKG.Create_Requisition( P_Action_ID 	 => l_action_id,
		                                                     P_Init_Msg_List => fnd_api.g_false,
		                                                     X_ID			 => l_out_id,
		                                                     X_Return_Status => x_return_status,
		                                                     X_Msg_Count     => x_msg_count,
		                                                     X_Msg_Data		 => x_msg_data );
                     If (x_return_status = G_RET_STS_UNEXP_ERROR) then
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                     elsif (x_return_status = G_RET_STS_ERROR) then
                           RAISE FND_API.G_EXC_ERROR ;
                     end if;
          else
                     oke_api.set_message(p_msg_name       => 'OKE_ACTION_NOT_READY',
                                         p_token1         => 'PROJECT_NAME',
                                         p_token1_value   => l_project_name,
                                         p_token2         => 'DELIVERABLE_NAME',
                                         p_token2_value   => l_deliverable_name,
                                         p_token3         => 'ACTION_NAME',
                                         p_token3_value   => l_action_name
                                         );
                    raise FND_API.G_EXC_ERROR;
          end if;
   end if;
   If p_dlv_action_type =G_SHIP then
         If l_ready_flag='Y' then
            OKE_DELIVERABLE_ACTIONS_PKG.create_Shipment( P_Action_ID 	 => l_action_id,
		                                                 P_Init_Msg_List => fnd_api.g_false,
		                                                 X_ID			 => l_out_id,
		                                                 X_Return_Status => x_return_status,
		                                                 X_Msg_Count     => x_msg_count,
		                                                 X_Msg_Data		 => x_msg_data );
                     If (x_return_status = G_RET_STS_UNEXP_ERROR) then
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                     elsif (x_return_status = G_RET_STS_ERROR) then
                           RAISE FND_API.G_EXC_ERROR ;
                     end if;
          else
                     oke_api.set_message(p_msg_name       => 'OKE_ACTION_NOT_READY',
                                         p_token1         => 'PROJECT_NAME',
                                         p_token1_value   => l_project_name,
                                         p_token2         => 'DELIVERABLE_NAME',
                                         p_token2_value   => l_deliverable_name,
                                         p_token3         => 'ACTION_NAME',
                                         p_token3_value   => l_action_name
                                         );
                    raise FND_API.G_EXC_ERROR;
          end if;
   end if;

   If fnd_api.to_boolean( p_commit ) then
      commit work;
   end if;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

 ROLLBACK TO initiate_dlv_action ;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

 ROLLBACK TO initiate_dlv_action ;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

ROLLBACK TO initiate_dlv_action ;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
End;
END OKE_AMG_GRP;

/
