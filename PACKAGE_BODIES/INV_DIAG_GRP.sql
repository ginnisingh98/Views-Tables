--------------------------------------------------------
--  DDL for Package Body INV_DIAG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DIAG_GRP" AS
/* $Header: INVDGTPB.pls 120.0.12000000.1 2007/06/22 00:49:51 musinha noship $ */
FUNCTION CHECK_AVAIL(p_Inventory_item_id Number
                    ,p_Organization_id  Number
                    ,p_revision   Varchar2
                    ,p_Subinventory_code Varchar2
                    ,p_locator_id        Number
                    ) return NUMBER IS
L_api_return_status  VARCHAR2(1);
l_qty_oh             NUMBER;
l_qty_res_oh         NUMBER;
l_qty_res            NUMBER;
l_qty_sug            NUMBER;
l_qty_att            NUMBER;
l_qty_atr            NUMBER;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(1000);
subinventory_code    VARCHAR2(13);
revision             varchar2(100);
locator_id           Number;
is_revision_control  boolean:=true;
QATT                  NUmber;

BEGIN
inv_quantity_tree_grp.clear_quantity_cache;

if p_revision is null then
revision:=null;
is_revision_control:=false;
else
revision := p_revision;
end if;

if p_subinventory_code is NULL then
   subinventory_code:=null;
   locator_id:=null;
else
   subinventory_code:=p_subinventory_code;
   locator_id:=p_locator_id;
end if;

if p_locator_id is NULL then
   locator_id:=null;
else
   locator_id:=p_locator_id;
end if;

apps.INV_Quantity_Tree_PUB.Query_Quantities (
  p_api_version_number => 1.0
, p_init_msg_lst       => apps.fnd_api.g_false
, x_return_status      => L_api_return_status
, x_msg_count          => l_msg_count
, x_msg_data           => l_msg_data
, p_organization_id    => p_organization_id
, p_inventory_item_id  => p_inventory_item_id
, p_tree_mode          => apps.INV_Quantity_Tree_PUB.g_transaction_mode
, p_onhand_source      => NULL
, p_is_revision_control=> is_revision_control
, p_is_lot_control     => FALSE
, p_is_serial_control  => FALSE
, p_revision           => revision
, p_lot_number         => NULL
, p_subinventory_code  => subinventory_code
, p_locator_id         => locator_id
, x_qoh                => l_qty_oh
, x_rqoh               => l_qty_res_oh
, x_qr                 => l_qty_res
, x_qs                 => l_qty_sug
, x_att                => l_qty_att
, x_atr                => l_qty_atr );

if L_api_return_status <> fnd_api.g_ret_sts_success then
   QATT:=0;
else
   QATT:=l_qty_att;
end if;
return QATT;

end;

FUNCTION CHECK_ONHAND(p_Inventory_item_id Number
                     ,p_Organization_id  Number
                     ,p_revision   Varchar2
                     ,p_Subinventory_code Varchar2
                     ,p_locator_id        Number
                     ) return NUMBER IS
L_api_return_status  VARCHAR2(1);
l_qty_oh             NUMBER;
l_qty_res_oh         NUMBER;
l_qty_res            NUMBER;
l_qty_sug            NUMBER;
l_qty_att            NUMBER;
l_qty_atr            NUMBER;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(1000);
subinventory_code    VARCHAR2(13);
revision             varchar2(100);
locator_id           Number;
is_revision_control  boolean:=true;
QOH                  NUmber;

BEGIN
inv_quantity_tree_grp.clear_quantity_cache;

if p_revision is null then
revision:=null;
is_revision_control:=false;
else
revision := p_revision;
end if;

if p_subinventory_code is NULL then
   subinventory_code:=null;
   locator_id:=null;
else
   subinventory_code:=p_subinventory_code;
   locator_id:=p_locator_id;
end if;

if p_locator_id is NULL then
   locator_id:=null;
else
   locator_id:=p_locator_id;
end if;

apps.INV_Quantity_Tree_PUB.Query_Quantities (
  p_api_version_number => 1.0
, p_init_msg_lst       => apps.fnd_api.g_false
, x_return_status      => L_api_return_status
, x_msg_count          => l_msg_count
, x_msg_data           => l_msg_data
, p_organization_id    => p_organization_id
, p_inventory_item_id  => p_inventory_item_id
, p_tree_mode          => apps.INV_Quantity_Tree_PUB.g_transaction_mode
, p_onhand_source      => NULL
, p_is_revision_control=> is_revision_control
, p_is_lot_control     => FALSE
, p_is_serial_control  => FALSE
, p_revision           => revision
, p_lot_number         => NULL
, p_subinventory_code  => subinventory_code
, p_locator_id         => locator_id
, x_qoh                => l_qty_oh
, x_rqoh               => l_qty_res_oh
, x_qr                 => l_qty_res
, x_qs                 => l_qty_sug
, x_att                => l_qty_att
, x_atr                => l_qty_atr );

if L_api_return_status <> fnd_api.g_ret_sts_success then
   QOH:=0;
else
   QOH:=l_qty_oh;
end if;
return QOH;

end;

-- to check if user has valid responsibility

FUNCTION check_responsibility(p_responsibility_name in FND_RESPONSIBILITY_TL.Responsibility_Name%type) return BOOLEAN is
l_dummy number;
begin

select count(*)
into l_dummy
from fnd_user_resp_groups fg, fnd_responsibility_vl fr
where fg.RESPONSIBILITY_ID=fr.RESPONSIBILITY_ID
and nvl(fr.START_DATE, sysdate) <= sysdate
and nvl(fr.END_DATE, sysdate) >= sysdate
and nvl(fg.START_DATE, sysdate) <=sysdate
and nvl(fg.END_DATE, sysdate) >=sysdate
and fr.RESPONSIBILITY_NAME = p_responsibility_name
and user_id=fnd_global.user_id;

if l_dummy >=1 then
   return TRUE;
else
   return FALSE;
end if;

exception when no_data_found then
   return FALSE ;
end;

end;

/
