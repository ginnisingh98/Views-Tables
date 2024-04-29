--------------------------------------------------------
--  DDL for Package WMS_RE_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_RE_CUSTOM_PUB" AUTHID CURRENT_USER as
/* $Header: WMSPPPUS.pls 120.1 2005/05/27 02:01:16 appldev  $ */

  -- File        : WMSPPPUS.pls
  -- Content     : WNS_RE_Custom_PUB package specification
  -- Description : Customizable stub procedures and functions called during
  --               WMS rules engine run.
  -- Notes       :
  -- Modified    : 02/08/99 mzeckzer created

  -- Local copies of fnd globals to prevent pragma violations of api functions
  g_miss_num  constant number      := fnd_api.g_miss_num;
  g_miss_char constant varchar2(1) := fnd_api.g_miss_char;
  g_miss_date constant date        := fnd_api.g_miss_date;

  -- Start of comments
  -- API name    : GetTotalLocationCapacity
  -- Type        : Public
  -- Function    : Calculates and returns the total capacity of a location
  --               ( sub or sub/locator ) in a customer-specific manner
  --               This function is made available to be used within put away
  --               rule setup.
  -- Pre-reqs    : none
  -- Parameters  :
  --  p_organization_id      in  number   required default = fnd_api.g_miss_num
  --  p_subinventory_code    in  varchar2 required default = fnd_api.g_miss_char
  --  p_locator_id           in  number   optional default = null
  --  p_inventory_item_id    in  number   required default = fnd_api.g_miss_num
  --  p_transaction_uom      in  varchar2 required default = fnd_api.g_miss_char
  --  return value           out number
  -- Version     : not tracked
  -- Notes       : capacity should be returned as measured in txn UOM
  -- End of comments

  function GetTotalLocationCapacity (
           p_organization_id          number      := g_miss_num
          ,p_subinventory_code        varchar2    := g_miss_char
          ,p_locator_id               number      := null
          ,p_inventory_item_id        number      := g_miss_num
          ,p_transaction_uom          varchar2    := g_miss_char
                                ) return number;
  pragma restrict_references(GetTotalLocationCapacity, WNDS, WNPS);

  -- Start of comments
  -- API name    : GetOccupiedLocationCapacity
  -- Type        : Public
  -- Function    : Calculates and returns the occupied capacity of a location
  --               ( sub or sub/locator ) in a customer-specific manner
  --               This function is made available to be used within put away
  --               rule setup.
  -- Pre-reqs    : none
  -- Parameters  :
  --  p_organization_id      in  number   required default = fnd_api.g_miss_num
  --  p_subinventory_code    in  varchar2 required default = fnd_api.g_miss_char
  --  p_locator_id           in  number   optional default = null
  --  p_inventory_item_id    in  number   required default = fnd_api.g_miss_num
  --  p_transaction_uom      in  varchar2 required default = fnd_api.g_miss_char
  --  return value           out number
  -- Version     : not tracked
  -- Notes       : capacity should be returned as measured in txn UOM
  -- End of comments

  function GetOccupiedLocationCapacity (
           p_organization_id          number      := g_miss_num
          ,p_subinventory_code        varchar2    := g_miss_char
          ,p_locator_id               number      := null
          ,p_inventory_item_id        number      := g_miss_num
          ,p_transaction_uom          varchar2    := g_miss_char
                                   ) return number;
  pragma restrict_references(GetOccupiedLocationCapacity, WNDS, WNPS);

  -- Start of comments
  -- API name    : GetAvailableLocationCapacity
  -- Type        : Public
  -- Function    : Calculates and returns the available capacity of a location
  --               ( sub or sub/locator ) in a customer-specific manner
  --               This function is made available to be used within put away
  --               rule setup.
  -- Pre-reqs    : none
  -- Parameters  :
  --  p_organization_id      in  number   required default = fnd_api.g_miss_num
  --  p_subinventory_code    in  varchar2 required default = fnd_api.g_miss_char
  --  p_locator_id           in  number   optional default = null
  --  p_inventory_item_id    in  number   required default = fnd_api.g_miss_num
  --  p_transaction_quantity in  number   required default = fnd_api.g_miss_num
  --  p_transaction_uom      in  varchar2 required default = fnd_api.g_miss_char
  --  return value           out number
  -- Version     : not tracked
  -- Notes       : capacity must be returned as measured in txn UOM
  -- End of comments

  function GetAvailableLocationCapacity (
           p_organization_id          number      := g_miss_num
          ,p_subinventory_code        varchar2    := g_miss_char
          ,p_locator_id               number      := null
          ,p_inventory_item_id        number      := g_miss_num
          ,p_transaction_quantity     number      := g_miss_num
          ,p_transaction_uom          varchar2    := g_miss_char
                                    ) return number;
  pragma restrict_references(GetAvailableLocationCapacity, WNDS, WNPS);

  -- Start of comments
  -- API name    : GetRemainingLocationCapacity
  -- Type        : Public
  -- Function    : Calculates and returns the occupied capacity of a location
  --               ( sub or sub/locator ) in a customer-specific manner
  --               This function is made available to be used within put away
  --               rule setup.
  -- Pre-reqs    : none
  -- Parameters  :
  --  p_organization_id      in  number   required default = fnd_api.g_miss_num
  --  p_subinventory_code    in  varchar2 required default = fnd_api.g_miss_char
  --  p_locator_id           in  number   optional default = null
  --  p_inventory_item_id    in  number   required default = fnd_api.g_miss_num
  --  p_transaction_quantity in  number   required default = fnd_api.g_miss_num
  --  p_transaction_uom      in  varchar2 required default = fnd_api.g_miss_char
  --  return value           out number
  -- Version     : not tracked
  -- Notes       : capacity should be returned as measured in txn UOM
  -- End of comments

  function GetRemainingLocationCapacity (
           p_organization_id          number      := g_miss_num
          ,p_subinventory_code        varchar2    := g_miss_char
          ,p_locator_id               number      := null
          ,p_inventory_item_id        number      := g_miss_num
          ,p_transaction_quantity     number      := g_miss_num
          ,p_transaction_uom          varchar2    := g_miss_char
                                    ) return number;
  pragma restrict_references(GetRemainingLocationCapacity, WNDS, WNPS);

  -- Start of comments
  -- API name    : SearchForStrategy
  -- Type        : Public
  -- Function    : Searches for a pick or put away strategy assignment to a
  --               customer-defined business object in a customer-specific
  --               manner.
  --               This procedure gets called just before the standard algorithm
  --               which searches for strategy assignments to system-defined
  --               business objects.
  -- Pre-reqs    : transaction record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
  --                identified by parameters p_transaction_temp_id and
  --                p_type_code ( already validated by calling procedure )
  --               set up strategy assignment in WMS_STRATEGY_ASSIGNMENTS
  -- Parameters  :
  --  p_init_msg_list        in  varchar2 optional default = fnd_api.g_false
  --  x_return_status        out varchar2(1)
  --  x_msg_count            out number
  --  x_msg_data             out varchar2(2000)
  --  p_transaction_temp_id  in  number   required default = fnd_api.g_miss_num
  --  p_type_code            in  number   required default = fnd_api.g_miss_num
  --  x_strategy_id          out number
  -- Version     : not tracked
  -- Notes       : type code of returned strategy has to match type code
  --               parameter
  -- End of comments

  procedure SearchForStrategy (
            p_init_msg_list        in   varchar2 := fnd_api.g_false
           ,x_return_status        out NOCOPY varchar2
           ,x_msg_count            out NOCOPY  number
           ,x_msg_data             out NOCOPY varchar2
           ,p_transaction_temp_id  in   number   := fnd_api.g_miss_num
           ,p_type_code            in   number   := fnd_api.g_miss_num
           ,x_strategy_id          out NOCOPY  number
           );

   /**

    API name    : SearchForStrategy
    Type        : Public
    Function    : Searches for a wms strategy/rule/value assignment to a
                  customer-defined business object in a customer-specific
                  manner.
    Pre-reqs    : transaction record in WMS_STRATEGY_MAT_TXN_TMP_V uniquely
                   identified by parameters p_transaction_temp_id and
                   p_type_code ( already validated by calling procedure )
                  set up strategy assignment in WMS_STRATEGY_ASSIGNMENTS
    Parameters  :
     p_init_msg_list        in  varchar2 optional default = fnd_api.g_false
     x_return_status        out varchar2(1)
     x_msg_count            out number
     x_msg_data             out varchar2(2000)
     p_transaction_temp_id  in  number   required default = fnd_api.g_miss_num
     p_type_code            in  number   required default = fnd_api.g_miss_num
     x_return_type          out  varchar2 'V' for Value , 'R' for Rule , 'S' for strategy
    ,x_return_type_id       out  number
      Notes       : type code of returned strategy has to match type code
                  parameter
  */
  procedure SearchForStrategy (
            p_init_msg_list        in   varchar2 := fnd_api.g_false
           ,x_return_status        out NOCOPY varchar2
           ,x_msg_count            out NOCOPY number
           ,x_msg_data             out NOCOPY varchar2
           ,p_transaction_temp_id  in   number   := fnd_api.g_miss_num
           ,p_type_code            in   number   := fnd_api.g_miss_num
           ,x_return_type          out  NOCOPY varchar2 -- 'V' for Value , 'R' for Rule , 'S' for strategy
           ,x_return_type_id       out  NOCOPY number
           );

end WMS_RE_Custom_PUB;

 

/
