--------------------------------------------------------
--  DDL for Package WMS_PARAMETER_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PARAMETER_EXT" AUTHID CURRENT_USER as
 /* $Header: WMSGPHLS.pls 115.4 2004/03/05 21:46:07 joabraha noship $ */

g_miss_num  CONSTANT NUMBER      := fnd_api.g_miss_num;
g_miss_char CONSTANT VARCHAR2(1) := fnd_api.g_miss_char;
g_miss_date CONSTANT DATE        := fnd_api.g_miss_date;

--==============================================================
-- API name    : GetPOHeaderLineIDWrap
-- Type        : Public
-- Function    : Returns PO Header ID, Line ID or Po Line Location ID
--               based on Move Order Line Reference and Reference ID
--               and header, line or line location flag.
--               ( Used for join condition in seed data  )
Function GetPOHeaderLineIDWrap(
  p_transaction_id      in number
, p_header_flag         in varchar2 default 'N'
, p_line_flag           in varchar2 default 'N'
, p_line_location_flag  in varchar2 default 'N'
) return number;
--
--
--==============================================================
-- API name    : GetSOHeaderLineIDWrap
-- Type        : Public
-- Function    : Returns SO Header ID or Line ID based on Move
--               Order Line Reference and Reference ID
--               and headeror line flag.
--               ( Used for join condition in seed data  )
Function GetSOHeaderLineIDWrap(
  p_transaction_id      in number
, p_header_flag         in varchar2 default 'N'
, p_line_flag           in varchar2 default 'N'
) return number;
--
--
-- API name    : GetItemOnHandWrap
-- Type        : Private
-- Function    : This is a wrapper to the function which Returns on hand stock
--		 of a given inventory item in the transaction UOM in the
--               wms_parameter_pvt.( Used for capacity calculation parameters )
Function GetItemOnhandWrap(
  p_organization_id           in number default g_miss_num
, p_inventory_item_id         in number default g_miss_num
, p_subinventory_code         in varchar2 default g_miss_char
, p_locator_id                in number default g_miss_num
, p_transaction_uom           in varchar2 default g_miss_char
) return number;
--
--
Procedure trace(
   p_message  in varchar2
,  p_level    in number default 4
);
--
-- API name    : GetNumOtherLots
-- Type        : Private
-- Function    : This is a wrapper to the function which Returns the number of
--               lots for the given item within the locator other than the given lot
--               ( Used for building rules)
Function GetNumOtherLotsWrap(
  p_transaction_id       in number default g_miss_num
) return number;
--
--
-- API name    : GetLpnQuantityRevLot
-- Type        : Private
-- Function    : Returns quantity of the given item, revision, and lot in the given LPN
function getlpnquantityrevlot(
           p_lpn_id            in number
         , p_inventory_item_id in number
         , p_revision          in varchar2 default null
         , p_lot_number        in varchar2 default null
         , p_organization_id   in number
) return number;
--
--
-- API name    : GetLpnTotalQuantity
-- Type        : Private
-- Function    : Returns quantity of the given item in the given LPN
function getlpntotalquantity(
           p_lpn_id            in number
         , p_inventory_item_id in number
         , p_organization_id   in number
) return number;
--
--
-- API name    : GetLpnNumOtherItems
-- Type        : Private
-- Function    : Returns number of the given item in the the given LPN
function getlpnnumofitems(
           p_lpn_id          in number
         , p_organization_id in number
) return number;
--
--
-- API name    : GetLpnNumOtherRevs
-- Type        : Private
-- Function    : Returns number of revisions of the given item in the given LPN
function getlpnnumofrevs(
           p_lpn_id            in number
         , p_inventory_item_id in number
         , p_organization_id   in number
) return number;
--
--
-- API name    : GetLpnNumOtherLots
-- Type        : Private
-- Function    : Returns number of lots of the given item in the given LPN
function getlpnnumoflots(
           p_lpn_id            in number
         , p_inventory_item_id in number
         , p_organization_id   in number
) return number;
--
--
end wms_parameter_ext;

 

/
