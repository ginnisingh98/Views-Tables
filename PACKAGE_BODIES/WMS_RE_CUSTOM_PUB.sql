--------------------------------------------------------
--  DDL for Package Body WMS_RE_CUSTOM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RE_CUSTOM_PUB" as
/* $Header: WMSPPPUB.pls 120.1 2005/05/27 02:01:56 appldev  $ */

  -- File        : WMSPPPUB.pls
  -- Content     : WMS_RE_Custom_PUB package body
  -- Description : Customizable stub procedures and functions called during rules
  --               engine run.
  -- Notes       :
  -- Modified    : 02/08/99 mzeckzer created

  g_pkg_name constant varchar2(30) := 'WMS_RE_Custom_PUB';

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
                                    ) return number is
    l_total_capacity            number := 0;

  begin
    -- validate input parameters
    if   p_organization_id   is null
      or p_organization_id   = g_miss_num
      or p_subinventory_code is null
      or p_subinventory_code = g_miss_char
      or p_inventory_item_id is null
      or p_inventory_item_id = g_miss_num
      or p_transaction_uom   is null
      or p_transaction_uom   = g_miss_char
    then
      return(null);
    end if;

    -- customer-specific logic

    -- return calculated total capacity
    return(l_total_capacity);

  end GetTotalLocationCapacity;

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
                                       ) return number is
    l_occupied_capacity         number := 0;

  begin
    -- validate input parameters
    if   p_organization_id   is null
      or p_organization_id   = g_miss_num
      or p_subinventory_code is null
      or p_subinventory_code = g_miss_char
      or p_inventory_item_id is null
      or p_inventory_item_id = g_miss_num
      or p_transaction_uom   is null
      or p_transaction_uom   = g_miss_char
    then
      return(null);
    end if;

    -- customer-specific logic

    -- return calculated occupied capacity
    return(l_occupied_capacity);

  end GetOccupiedLocationCapacity;

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
                                        ) return number is
    l_available_capacity        number := 0;

  begin
    -- validate input parameters
    if   p_organization_id      is null
      or p_organization_id      = g_miss_num
      or p_subinventory_code    is null
      or p_subinventory_code    = g_miss_char
      or p_inventory_item_id    is null
      or p_inventory_item_id    = g_miss_num
      or p_transaction_quantity is null
      or p_transaction_quantity = g_miss_num
      or p_transaction_uom      is null
      or p_transaction_uom      = g_miss_char
    then
      return(null);
    end if;

    -- customer-specific logic

    -- return calculated available capacity
    return(l_available_capacity);

  end GetAvailableLocationCapacity;

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
                                        ) return number is
    l_remaining_capacity        number := 0;

  begin
    -- validate input parameters
    if   p_organization_id      is null
      or p_organization_id      = g_miss_num
      or p_subinventory_code    is null
      or p_subinventory_code    = g_miss_char
      or p_inventory_item_id    is null
      or p_inventory_item_id    = g_miss_num
      or p_transaction_quantity is null
      or p_transaction_quantity = g_miss_num
      or p_transaction_uom      is null
      or p_transaction_uom      = g_miss_char
    then
      return(null);
    end if;

    -- customer-specific logic

    -- return calculated remaining capacity
    return(l_remaining_capacity);

  end GetRemainingLocationCapacity;

  -- Start of comments
  -- API name    : SearchForStrategy
  -- Type        : Public
  -- Function    : Searches for a wms strategy assignment to a
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
           ,x_msg_count            out NOCOPY number
           ,x_msg_data             out NOCOPY varchar2
           ,p_transaction_temp_id  in   number   := fnd_api.g_miss_num
           ,p_type_code            in   number   := fnd_api.g_miss_num
           ,x_strategy_id          out  NOCOPY number
                              ) is

    -- API standard variables
    l_api_name                     constant varchar2(30) := 'SearchForStrategy';

  begin

    -- Initialize message list if p_init_msg_list is set to TRUE
    if fnd_api.to_boolean( p_init_msg_list ) then
      fnd_msg_pub.initialize;
    end if;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Search for Strategy in a custom-specific manner, using
    -- View WMS_STRATEGY_MAT_TXN_TMP_V ( Actual transaction values )
    -- Table WMS_STRATEGY_ASSIGNMENTS ( Setup data )
    -- ...
    -- ...
    -- ...
    -- By default, no Strategy is found using custom-specific procedure
    x_strategy_id := null;

    if x_strategy_id is null then
      -- Message: No strategy found using custom-specific stub procedure
      raise fnd_api.g_exc_error;
    end if;

    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );

  exception
    when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

    when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

  end SearchForStrategy;



--*************************************************************************
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
           ,x_return_type          out NOCOPY varchar2 -- 'V' for Value , 'R' for Rule , 'S' for strategy
           ,x_return_type_id       out NOCOPY number
	) is

    -- API standard variables
    l_api_name                     constant varchar2(30) := 'SearchForStrategy';

  begin

    -- Initialize message list if p_init_msg_list is set to TRUE
    if fnd_api.to_boolean( p_init_msg_list ) then
      fnd_msg_pub.initialize;
    end if;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Search for Strategy in a custom-specific manner, using
    -- View WMS_STRATEGY_MAT_TXN_TMP_V ( Actual transaction values )
    -- Table WMS_STRATEGY_ASSIGNMENTS ( Setup data )
    -- ...
    -- ...
    -- ...
    -- By default, no Strategy/Rule/Value is found using custom-specific procedure
    x_return_type :=NULL;
    x_return_type_id := null;

    if x_return_type_id is null then
      -- Message: No strategy/Rule/Value found using custom-specific stub procedure
      raise fnd_api.g_exc_error;
    end if;

    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                              ,p_data  => x_msg_data );

  exception
    when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

    when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) then
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      end if;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                                ,p_data  => x_msg_data );

  end SearchForStrategy;



end WMS_RE_Custom_PUB;

/
