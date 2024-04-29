--------------------------------------------------------
--  DDL for Package Body WMS_PARAMETER_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_PARAMETER_EXT" as
/* $Header: WMSGPHLB.pls 115.5 2004/03/25 00:49:19 joabraha noship $ */

-- ---------------------------------------------------------------------------------------
-- |---------------------< trace >--------------------------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the tracing utility.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name        Reqd Type     Description
--   ---------   ---- -------- ---------------------------------------
--   p_message   Yes  varchar2 Message to be displayed in the log file.
--   p_prompt    Yes  varchar2 Prompt.
--   p_level     No   number   Level.
--
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--
Procedure trace(
   p_message  in varchar2
,  p_level    in number
   ) is
begin
      INV_LOG_UTIL.trace(p_message, 'WMS_PARAMETER_EXT', p_level);
end trace;
--
-- ---------------------------------------------------------------------------------------
-- |---------------------< GetPOHeaderLineIDWrap >----------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the wms_parameter_pvt.GetSOHeaderLineID(). This is a wrapper around the
-- wms_parameter_pvt.GetSOHeaderLineID().
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   --------------------  ---- -------- ---------------------------------------
--   p_transaction_id      Yes  number   Task ID(MMTT.transaction_temp_id)
--   p_header_flag         No   varchar2 Flag to indicate that the call to this
--                                       function is to derive the SO Header ID
--   p_line_flag           No   varchar2 Flag to indicate that the call to this
--                                       function is to derive the SO Line ID
--                                       location ID.
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Function GetSOHeaderLineIDWrap(
  p_transaction_id      in number
, p_header_flag         in varchar2 default 'N'
, p_line_flag           in varchar2 default 'N'
) return number
is

   l_proc                  varchar2(72) := 'GetSOHeaderLineIDWrap :';
   l_so_header_id          number := -1;
   l_so_line_id            number := -1;
   l_return_val_wrap       number := -1;

   l_reference                   varchar2(50);
   l_reference_id                number;
   l_move_order_line_id          number;
   l_transaction_source_type_id  number;
   l_debug                       number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   cursor get_mo_line_info is
   select mtrl.reference, mtrl.reference_id, mtrl.line_id, mmtt.transaction_source_type_id
   from   mtl_material_transactions_temp mmtt, mtl_txn_request_lines mtrl
   where  mtrl.line_id = mmtt.move_order_line_id
   and    mmtt.transaction_temp_id = p_transaction_id;

begin
   -- ### Initialize API return status to success
   --x_return_status := fnd_api.g_ret_sts_success;

   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc || ' p_transaction_id   => ' || nvl(p_transaction_id, -99));
      trace(l_proc || ' p_header_flag  => ' || p_header_flag);
      trace(l_proc || ' p_line_flag  => ' || p_line_flag);
   end if;

    -- Validate input parameters
    --if p_transaction_id is null then
    --  if (l_debug = 1) then
    --     trace(l_proc || ' Missing Required Input Parameter values, refer to trace messages above...');
    --  end if;
    --  return null;
    --end if;

   -- ### Derive Move Order Line and related task Information details to start with.
   open  get_mo_line_info;
   fetch get_mo_line_info
   into  l_reference, l_reference_id, l_move_order_line_id, l_transaction_source_type_id;

   if get_mo_line_info%NOTFOUND then
      fnd_message.set_name('WMS', 'WMS_INVALID_TASK_ID');
      fnd_msg_pub.ADD;
      raise fnd_api.g_exc_error;
   else
      -- ### Print values derived from the cursor into the log file.
      if (l_debug = 1) then
         trace(l_proc || ' Printing Move Order Line and related task Information details...');
         trace(l_proc || ' l_reference : '|| nvl(l_reference, '@@@'));
         trace(l_proc || ' l_reference_id : '|| nvl(l_reference_id, -99));
         trace(l_proc || ' l_move_order_line_id : '|| nvl(l_move_order_line_id, -99));
         trace(l_proc || ' l_transaction_source_type_id : '|| nvl(l_transaction_source_type_id, -99));
      end if;

      if (p_header_flag = 'Y' or p_line_flag = 'Y') then
         if (l_debug = 1) then
            trace(l_proc || ' Within if (p_header_flag = Y or p_line_flag = Y) condition');
         end if;

         l_return_val_wrap := wms_parameter_pvt.getsoheaderlineid(
                                p_line_id  => l_move_order_line_id
                              , p_transaction_source_type_id => l_transaction_source_type_id
                              , p_reference  => l_reference
                              , p_reference_id  => l_reference_id
                              , p_header_flag  => p_header_flag
                              , p_line_flag  => p_line_flag
                              );
      end if;

      if p_header_flag = 'Y' then
         if (l_debug = 1) then
            trace(l_proc || ' SO Header ID Derived  : '|| nvl(l_return_val_wrap, -99));
         end if;
      elsif p_line_flag = 'Y' then
         if (l_debug = 1) then
            trace(l_proc || ' SO Line ID Derived : '|| nvl(l_return_val_wrap, -99));
         end if;
      end if;

   end if;
   -- ### Close the cursor.
   close get_mo_line_info;

   return l_return_val_wrap;

exception
   when fnd_api.g_exc_error then
      --x_return_status  := fnd_api.g_ret_sts_error;
      null;

   when others  then
      --x_return_status  := fnd_api.g_ret_sts_error;
      if (l_debug = 1) then
         trace(' Error Code, Error Message...' || sqlerrm(sqlcode), 1);
      end if;
      if get_mo_line_info%ISOPEN then
         close get_mo_line_info;
      end if;

end GetSOHeaderLineIDWrap;

-- ---------------------------------------------------------------------------------------
-- |---------------------< GetPOHeaderLineIDWrap >----------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the wms_parameter_pvt.GetPOHeaderLineID(). If the p_line_location_flag is
-- 'Y', then the po_line_location_id is derved within this function. In all other casess
-- the wms_parameter_pvt.GetPOHeaderLineID() is called to derive th appropraite values.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                  Reqd Type     Description
--   --------------------  ---- -------- ---------------------------------------
--   p_transaction_id      Yes  number   Task ID(MMTT.transaction_temp_id)
--   p_header_flag         No   varchar2 Flag to indicate that the call to this
--                                       function is to derive the PO Header ID
--   p_line_flag           No   varchar2 Flag to indicate that the call to this
--                                       function is to derive the PO Line ID
--   p_line_location_flag  No   varchar2 Flag to indicate that the call to this
--                                       function is to derive the PO Line
--                                       location ID.
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Function GetPOHeaderLineIDWrap(
  p_transaction_id      in number
, p_header_flag         in varchar2
, p_line_flag           in varchar2
, p_line_location_flag  in varchar2
)  return number
is

   l_proc                  varchar2(72) := 'GetPOHeaderLineIDWrap :';
   l_po_header_id          number := -1;
   l_po_line_id            number := -1;
   l_po_line_location_id   number := -1;
   l_return_val_wrap       number := -1;

   l_reference                   varchar2(50);
   l_reference_id                number;
   l_move_order_line_id          number;
   l_transaction_source_type_id  number;
   l_debug                       number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   cursor get_mo_line_info is
   select mtrl.reference, mtrl.reference_id, mtrl.line_id, mmtt.transaction_source_type_id
   from   mtl_material_transactions_temp mmtt, mtl_txn_request_lines mtrl
   where  mtrl.line_id = mmtt.move_order_line_id
   and    mmtt.transaction_temp_id = p_transaction_id;

begin
   -- ### Initialize API return status to success
   --x_return_status := fnd_api.g_ret_sts_success;

   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc || ' p_transaction_id   => ' || nvl(p_transaction_id, -99));
      trace(l_proc || ' p_header_flag  => ' || p_header_flag);
      trace(l_proc || ' p_line_flag  => ' || p_line_flag);
      trace(l_proc || ' p_line_location_flag  => ' || p_line_location_flag);
   end if;

    -- Validate input parameters
    --if p_transaction_id is null then
    --  if (l_debug = 1) then
    --     trace(l_proc || ' Missing Required Input Parameter values, refer to trace messages above...');
    --  end if;
    --  return null;
    --end if;

   -- ### Derive Move Order Line and related task Information details to start with.
   open  get_mo_line_info;
   fetch get_mo_line_info
   into  l_reference, l_reference_id, l_move_order_line_id, l_transaction_source_type_id;

   if get_mo_line_info%NOTFOUND then
      fnd_message.set_name('WMS', 'WMS_INVALID_TASK_ID');
      fnd_msg_pub.ADD;
      raise fnd_api.g_exc_error;
   else
      -- ### Print values derived from the cursor into the log file.
      if (l_debug = 1) then
         trace(l_proc || ' Printing Move Order Line and related task Information details...');
         trace(l_proc || ' l_reference : '|| nvl(l_reference, '@@@'));
         trace(l_proc || ' l_reference_id : '|| nvl(l_reference_id, -99));
         trace(l_proc || ' l_move_order_line_id : '|| nvl(l_move_order_line_id, -99));
         trace(l_proc || ' l_transaction_source_type_id : '|| nvl(l_transaction_source_type_id, -99));
      end if;

      if (p_line_location_flag = 'Y') then
         if (l_reference = 'PO_LINE_LOCATION_ID') then
            if (l_debug = 1) then
               trace(l_proc || ' Within if (p_line_location_flag = Y) condition');
               trace(l_proc || ' po_line_location_id derived : '|| nvl(l_reference_id, -99));
            end if;
            l_return_val_wrap := l_reference_id;
         end if;
      elsif (p_header_flag = 'Y' or p_line_flag = 'Y') then
         if (l_debug = 1) then
            trace(l_proc || ' Within if (p_header_flag = Y or p_line_flag = Y) condition');
         end if;

         l_return_val_wrap := wms_parameter_pvt.getpoheaderlineid(
                                p_transaction_source_type_id => l_transaction_source_type_id
                              , p_reference  => l_reference
                              , p_reference_id  => l_reference_id
                              , p_header_flag  => p_header_flag
                              , p_line_flag  => p_line_flag
                              );
      end if;

      if p_header_flag = 'Y' then
         if (l_debug = 1) then
            trace(l_proc || ' PO Header ID Derived  : '|| nvl(l_return_val_wrap, -99));
         end if;
      elsif p_line_flag = 'Y' then
         if (l_debug = 1) then
            trace(l_proc || ' PO Line ID Derived : '|| nvl(l_return_val_wrap, -99));
         end if;
      elsif p_line_location_flag = 'Y' then
         if (l_debug = 1) then
            trace(l_proc || ' PO Line Location ID Derived : '|| nvl(l_return_val_wrap, -99));
         end if;
      end if;

   end if;
   -- ### Close the cursor.
   close get_mo_line_info;

   return l_return_val_wrap;

exception
   when fnd_api.g_exc_error then
      --x_return_status  := fnd_api.g_ret_sts_error;
      null;

   when others  then
      --x_return_status  := fnd_api.g_ret_sts_error;
      if (l_debug = 1) then
         trace(' Error Code, Error Message...' || sqlerrm(sqlcode), 1);
      end if;
      if get_mo_line_info%ISOPEN then
         close get_mo_line_info;
      end if;

end GetPOHeaderLineIDWrap;

-- ---------------------------------------------------------------------------------------
-- |---------------------< GetItemOnhandWrap >----------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the wms_parameter_pvt.GetItemOnhand().
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                  Reqd Type      Description
--   --------------------  ---- --------  ---------------------------------------
--   p_organization_id      Yes  number   Organization ID(MMTT.organization_id)
--   p_inventory_item_id    Yes  number   Item ID(MMTT.inventory_item_id)
--   p_subinventory_code    No   varchar2 Subcode(nvl(MMTT.transfer_subinventory, MMTT.subinventory_code))
--   p_locator_id           No   number   Location ID(MMTT.location_id)
--   p_transaction_uom      No   varchar2 Transaction UOM (MMTT.transaction_uom)
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Function GetItemOnhandWrap(
  p_organization_id           in number default g_miss_num
, p_inventory_item_id         in number default g_miss_num
, p_subinventory_code         in varchar2 default g_miss_char
, p_locator_id                in number default g_miss_num
, p_transaction_uom           in varchar2 default g_miss_char
)return number
is
   l_primary_uom_code     varchar2(10);
   l_proc                 varchar2(72) := 'GetItemOnhandWrap :';
   l_debug                number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_return_val_wrap       number := -1;

   cursor get_item_primary_uom is
   select primary_uom_code
   from   mtl_system_items msi
   where  msi.inventory_item_id = p_inventory_item_id
   and    msi.organization_id = p_organization_id;

begin
   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc || ' p_organization_id   => ' || nvl(p_organization_id, -99));
      trace(l_proc || ' p_inventory_item_id  => ' || nvl(p_inventory_item_id, -99));
      trace(l_proc || ' p_subinventory_code  => ' || nvl(p_subinventory_code, '@@@'));
      trace(l_proc || ' p_locator_id  => ' || nvl(p_locator_id, -99));
      trace(l_proc || ' p_transaction_uom  => ' || nvl(p_transaction_uom, '@@@'));
   end if;

   --check for missing org, item.
   if p_organization_id = g_miss_num or p_inventory_item_id = g_miss_num then
     return null;
   elsif p_organization_id is null or p_inventory_item_id is null then
     return null;
   end if;

   -- ### Derive Move Order Line and related task Information details to start with.
   open  get_item_primary_uom;
   fetch get_item_primary_uom
   into  l_primary_uom_code;

   if get_item_primary_uom%NOTFOUND then
      close get_item_primary_uom;
      return null;
   else
      l_return_val_wrap := wms_parameter_pvt.getitemonhand(
                             p_organization_id           => p_organization_id
                           , p_inventory_item_id         => p_inventory_item_id
                           , p_subinventory_code         => p_subinventory_code
                           , p_locator_id                => p_locator_id
                           , p_primary_uom               => l_primary_uom_code
                           , p_transaction_uom           => p_transaction_uom
                           );
   end if;
      -- ### Close the cursor.
   close get_item_primary_uom;

   return l_return_val_wrap;
exception
   when fnd_api.g_exc_error then
      --x_return_status  := fnd_api.g_ret_sts_error;
      null;

   when others  then
      --x_return_status  := fnd_api.g_ret_sts_error;
      if (l_debug = 1) then
         trace(' Error Code, Error Message...' || sqlerrm(sqlcode), 1);
      end if;
      if get_item_primary_uom%ISOPEN then
         close get_item_primary_uom;
      end if;

end GetItemOnhandWrap;
--
-- ---------------------------------------------------------------------------------------
-- |---------------------< GetNumOtherLotsWrap >----------------------------------------|
-- ---------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the wms_parameter_pvt.GetNumOtherLots().
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                  Reqd Type      Description
--   --------------------  ---- --------  ---------------------------------------
--   p_tranmsaction_id      Yes  number   Task ID(MMTT.transaction_temp_id)
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Function GetNumOtherLotsWrap(
  p_transaction_id       in number
) return number
is
   l_proc                 varchar2(72) := 'GetNumOtherLotsWrap :';
   l_debug                number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_return_val_wrap       number := -1;

   l_organization_id     number := -1;
   l_inventory_item_id   number := -1;
   l_subinventory_code   varchar2(100) := null;
   l_locator_id          number := -1;
   l_lot_number          varchar2(100) := null;

   cursor get_lot_other_info is
   select mmtt.organization_id, mmtt.inventory_item_id,
          nvl(mmtt.transfer_subinventory, mmtt.subinventory_code),
          nvl(mmtt.transfer_to_location, mmtt.locator_id),
          mtlt.lot_number
   from   mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
   where  mmtt.transaction_temp_id = mtlt.transaction_temp_id
   and    mmtt.transaction_temp_id = p_transaction_id;

begin
   if (l_debug = 1) then
      trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc || ' p_transaction_id   => ' || nvl(p_transaction_id, -99));
   end if;

   -- ### Derive Move Order Line and related task Information details to start with.
   open  get_lot_other_info;
   fetch get_lot_other_info
   into  l_organization_id,l_inventory_item_id,l_subinventory_code,l_locator_id,l_lot_number ;

   if get_lot_other_info%NOTFOUND then
      close get_lot_other_info;
      return null;
   else
      l_return_val_wrap := wms_parameter_pvt.GetNumOtherLots(
                             p_organization_id           => l_organization_id
                           , p_inventory_item_id         => l_inventory_item_id
                           , p_subinventory_code         => l_subinventory_code
                           , p_locator_id                => l_locator_id
                           , p_lot_number                => l_lot_number
                           );
   end if;
   -- ### Close the cursor.
   close get_lot_other_info;

   return l_return_val_wrap;
exception
   when fnd_api.g_exc_error then
      --x_return_status  := fnd_api.g_ret_sts_error;
      null;

   when others  then
      --x_return_status  := fnd_api.g_ret_sts_error;
      if (l_debug = 1) then
         trace(' Error Code, Error Message...' || sqlerrm(sqlcode), 1);
      end if;
      if get_lot_other_info%ISOPEN then
         close get_lot_other_info;
      end if;

end GetNumOtherLotsWrap;

-- API name    : GetLpnQuantityRevLot
-- Type        : Private
-- Function    : Returns quantity of the given item, revision, and lot in the given LPN
--
--               Data in WLC is generally in primary UOM. However this is because INV-TM
--               always converts to primary UOM before calling pack/unpack API. packUnpack
--               by itself does not make any assumption that material will always be in pri-uom.
--               packunpack API could be called directly (as is done in ASN import, due to which
--               we have this bug) by an API and a different UOM can be specified. So
--               you cannot  make the assumption that WLC will always be in pri-uom.
--               Hence not in all cases, can we safely assume that the UOM CODE on the WLC record
--               is in the primary UOM of the item. So it is always best to convert if the
--               MMTT.TRANSACTION_UOM and the WLC.UOM_CODE doesn't match. .
function getlpnquantityrevlot(
           p_lpn_id            in number
         , p_inventory_item_id in number
         , p_revision          in varchar2 default null
         , p_lot_number        in varchar2 default null
         , p_organization_id   in number)
return number
is
     l_proc         varchar2(72) := 'GetLpnQuantityRevLot :';
     l_return_value number:= 0;
     l_primary_uom  varchar2(3);
     l_total_quantity number:= 0;
     l_loop_counter number:=0;
     l_debug  number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


     -- @@@ Get the primary uom for the Item in question.
     cursor c_get_prim_uom_code is
     select primary_uom_code
     from mtl_system_items mtl
     where mtl.inventory_item_id = p_inventory_item_id
     and mtl.organization_id = p_organization_id;

     -- @@@ Get the records in WLC in the prim uom of the item.
     cursor c_get_wlc_quantity is
     select sum(wlc.quantity) summed_quantity, uom_code
     from wms_lpn_contents wlc
     where wlc.parent_lpn_id = p_lpn_id
     and wlc.inventory_item_id = p_inventory_item_id
     and wlc.organization_id = p_organization_id
     and nvl(wlc.revision, '@@@') = nvl(p_revision, nvl(wlc.revision, '@@@'))
     and nvl(wlc.lot_number, '@@@@') = nvl(p_lot_number, nvl(wlc.lot_number, '@@@@'))
     group by uom_code;

begin
   if (l_debug = 1) then
     trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
     trace(l_proc || ' p_lpn_id   => ' || p_lpn_id);
     trace(l_proc || ' p_inventory_item_id  => ' || p_inventory_item_id);
     trace(l_proc || ' p_organization_id  => ' || p_organization_id);
     trace(l_proc || ' p_revision  => ' || p_revision);
     trace(l_proc || ' p_lot_number  => ' || p_lot_number);
  end if;

  if p_lpn_id is null or p_inventory_item_id is null then
    return -1;
  end if;

  -- @@@ Open cursor to fetch primary UOM code for the item in question.
  open  c_get_prim_uom_code;
  fetch c_get_prim_uom_code
  into  l_primary_uom;


  if c_get_prim_uom_code%NOTFOUND then
     close c_get_prim_uom_code;
     return null;
  else
     trace(l_proc || 'l_primary_uom : ' || nvl(l_primary_uom, '@@@'));
     for v_get_wlc_quantity in c_get_wlc_quantity
     loop
        l_loop_counter := l_loop_counter + 1;
        trace(l_proc || 'l_loop_counter : ' || nvl(l_loop_counter, -99));
        if v_get_wlc_quantity.uom_code <> l_primary_uom then
           trace(l_proc || 'summed_quantity : ' || nvl(v_get_wlc_quantity.summed_quantity, -99));
           trace(l_proc || 'uom_code : ' || nvl(v_get_wlc_quantity.uom_code, '@@@'));
           l_return_value := inv_convert.inv_um_convert(
                                item_id       => p_inventory_item_id
                             ,  precision     => null
                             ,  from_quantity => v_get_wlc_quantity.summed_quantity
                             ,  from_unit     => v_get_wlc_quantity.uom_code
                             ,  to_unit       => l_primary_uom
                             ,  from_name     => null
                             ,  to_name	      => null
                             );
           -- @@@ The above call(INVUNCMB,pls) is code such that when the "When Others" exception occurs,
           -- @@@ it sets the value of l_return_value to -9999. When this happens inside the loop,
           -- @@@ we have to make sure that the value of l_total_quantity is unchanged. Hence the check around this.
           trace(l_proc || 'l_return_value : ' || nvl(l_return_value, -99));
           if (l_return_value = -99999) then
              l_total_quantity := 0;
              trace(l_proc || 'l_total_quantity just before exit : ' || nvl(l_total_quantity, -99));
              exit;
           else
              l_total_quantity := l_total_quantity + l_return_value;
              trace(l_proc || 'l_total_quantity in the else of the l_return_value check : ' || nvl(l_total_quantity, -99));
           end if;
        else
           l_total_quantity := l_total_quantity + v_get_wlc_quantity.summed_quantity;
           trace(l_proc || 'l_total_quantity in the else : ' || nvl(l_return_value, -99));
        end if;-- Marker for Check  v_get_wlc_quantity.uom_code <> l_primary_uom
     end loop;
     -- @@@ Close the cursor since the loop has been exited prematurely.
     if (l_return_value = -99999) then
        if c_get_wlc_quantity%ISOPEN then
           trace(l_proc || 'c_get_wlc_quantity is open and hence being closed ');
           close c_get_wlc_quantity;
        end if;
     end if;
     close c_get_prim_uom_code;
  end if;-- Marker for c_get_prim_uom_code FOUND/NOTFOUND
  return l_total_quantity;
exception
  when others then
    if c_get_prim_uom_code%ISOPEN then
       close c_get_prim_uom_code;
    end if;

    if c_get_wlc_quantity%ISOPEN then
       close c_get_wlc_quantity;
    end if;
    return 0;
end getlpnquantityrevlot;
--
--
-- API name    : GetLpnTotalQuantity
-- Type        : Private
-- Function    : Returns quantity of the given item in the given LPN for the given item.
--
--               Data in WLC is generally in primary UOM. However this is because INV-TM
--               always converts to primary UOM before calling pack/unpack API. packUnpack
--               by itself does not make any assumption that material will always be in pri-uom.
--               packunpack API could be called directly (as is done in ASN import, due to which
--               we have this bug) by an API and a different UOM can be specified. So
--               you cannot  make the assumption that WLC will always be in pri-uom.
--               Hence not in all cases, can we safely assume that the UOM CODE on the WLC record
--               is in the primary UOM of the item. So it is always best to convert if the
--               primary uom for the item and the WLC.UOM_CODE doesn't match. .
function getlpntotalquantity(
           p_lpn_id            in number
         , p_inventory_item_id in number
         , p_organization_id   in number)
return number
is
     l_proc         varchar2(72) := 'GetLpnTotalQuantity :';
     l_return_value number:= 0;
     l_primary_uom  varchar2(3);
     l_total_quantity number:= 0;
     l_loop_counter number := 0;
     l_debug  number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     -- @@@ Get the primary uom for the Item in question.
     cursor c_get_prim_uom_code is
     select primary_uom_code
     from mtl_system_items mtl
     where mtl.inventory_item_id = p_inventory_item_id
     and mtl.organization_id = p_organization_id;

     -- @@@ Check to see if the record in WLC is in the prim uom of the item.
     cursor c_get_wlc_quantity is
     select sum(wlc.quantity) summed_quantity, uom_code
     from wms_lpn_contents wlc
     where wlc.parent_lpn_id = p_lpn_id
     and wlc.inventory_item_id = p_inventory_item_id
     and wlc.organization_id = p_organization_id
     group by uom_code;

begin

   if (l_debug = 1) then
     trace(' Entering procedure  '|| l_proc || ':'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
     trace(l_proc || ' p_lpn_id   => ' || p_lpn_id);
     trace(l_proc || ' p_inventory_item_id  => ' || p_inventory_item_id);
     trace(l_proc || ' p_organization_id  => ' || p_organization_id);
  end if;

  -- @@@ Open cursor to fetch primary UOM code for the item in question.
  open  c_get_prim_uom_code;
  fetch c_get_prim_uom_code
  into  l_primary_uom;


  if c_get_prim_uom_code%NOTFOUND then
     close c_get_prim_uom_code;
     return null;
  else
     trace(l_proc || 'l_primary_uom : ' || nvl(l_primary_uom, '@@@'));
     for v_get_wlc_quantity in c_get_wlc_quantity
     loop
        l_loop_counter := l_loop_counter + 1;
        trace(l_proc || 'l_loop_counter : ' || nvl(l_loop_counter, -99));
        if v_get_wlc_quantity.uom_code <> l_primary_uom then
           trace(l_proc || 'summed_quantity : ' || nvl(v_get_wlc_quantity.summed_quantity, -99));
           trace(l_proc || 'uom_code : ' || nvl(v_get_wlc_quantity.uom_code, '@@@'));
           l_return_value := inv_convert.inv_um_convert(
                                item_id       => p_inventory_item_id
                             ,  precision     => null
                             ,  from_quantity => v_get_wlc_quantity.summed_quantity
                             ,  from_unit     => v_get_wlc_quantity.uom_code
                             ,  to_unit       => l_primary_uom
                             ,  from_name     => null
                             ,  to_name	      => null
                             );
           -- @@@ The above call(INVUNCMB,pls) is code such that when the "When Others" exception occurs,
           -- @@@ it sets the value of l_return_value to -9999. When this happens inside the loop,
           -- @@@ we have to make sure that the loop is exited and the l_total_quantity is 0.
           -- @@@ Hence a check around this.
           trace(l_proc || 'l_return_value : ' || nvl(l_return_value, -99));
           trace(l_proc || 'l_return_value : ' || nvl(l_return_value, -99));
           if (l_return_value = -99999) then
              l_total_quantity := 0;
              trace(l_proc || 'l_total_quantity just before exit : ' || nvl(l_total_quantity, -99));
              exit;
           else
              l_total_quantity := l_total_quantity + l_return_value;
              trace(l_proc || 'l_total_quantity in the else of the l_return_value check : ' || nvl(l_total_quantity, -99));
           end if;
        else
           l_total_quantity := l_total_quantity + v_get_wlc_quantity.summed_quantity;
           trace(l_proc || 'l_total_quantity in the else : ' || nvl(l_return_value, -99));
        end if;
     end loop;
     -- @@@ Close the cursor since the loop has been exited prematurely.
     if (l_return_value = -99999) then
        if c_get_wlc_quantity%ISOPEN then
           trace(l_proc || 'c_get_wlc_quantity is open and hence being closed ');
           close c_get_wlc_quantity;
        end if;
     end if;
     close c_get_prim_uom_code;
  end if;
  return l_total_quantity;
exception
  when others then
    if c_get_prim_uom_code%ISOPEN then
       close c_get_prim_uom_code;
    end if;

    if c_get_wlc_quantity%ISOPEN then
       close c_get_wlc_quantity;
    end if;
    return 0;
end getlpntotalquantity;
--
--
-- API name    : GetLpnNumOfItems
-- Type        : Private
-- Function    : Returns number of items - 1 in the the given LPN.
--               This function considers the current item as well as all the other items.
function getlpnnumofitems(
           p_lpn_id          in number
         , p_organization_id in number)
return number
is
    l_return_value number;

begin
  if p_lpn_id is null then
    return -1;
  end if;

  select count(distinct(wlc.inventory_item_id))
  into  l_return_value
  from  wms_lpn_contents wlc
  where wlc.parent_lpn_id = p_lpn_id
  and   wlc.organization_id = p_organization_id;

  return l_return_value;
exception
  when others then
    return -1;
end getlpnnumofitems;

-- API name    : GetLpnNumOtherRevs
-- Type        : Private
-- Function    : Returns number of revisions of this item in the given LPN
function getlpnnumofrevs(
           p_lpn_id            in number
         , p_inventory_item_id in number
         , p_organization_id   in number)
return number
is
    l_return_value NUMBER;

begin
  if p_lpn_id is null or p_inventory_item_id is null then
    return -1;
  end if;

  select count(distinct(wlc.revision))
  into  l_return_value
  from  wms_lpn_contents wlc
  where wlc.parent_lpn_id = p_lpn_id
  and   wlc.inventory_item_id = p_inventory_item_id
  and   wlc.organization_id = p_organization_id;

  return l_return_value;
exception
  when others then
    return -1;
end getlpnnumofrevs;

-- API name    : GetLpnNumOtherLots
-- Type        : Private
-- Function    : Returns number of lots of this item - 1
--               in the the given LPN
function getlpnnumoflots(
           p_lpn_id            in number
         , p_inventory_item_id in number
         , p_organization_id   in number)
return number
is
     l_return_value number;

begin
  if p_lpn_id is null or p_inventory_item_id is null then
    return -1;
  end if;

  select count(distinct(wlc.lot_number))
  into  l_return_value
  from  wms_lpn_contents wlc
  where wlc.parent_lpn_id = p_lpn_id
  and   wlc.inventory_item_id = p_inventory_item_id
  and   wlc.organization_id = p_organization_id;


  return l_return_value;
exception
  when others then
    return -1;
end getlpnnumoflots;

end wms_parameter_ext;

/
