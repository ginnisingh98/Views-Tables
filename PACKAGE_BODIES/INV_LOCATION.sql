--------------------------------------------------------
--  DDL for Package Body INV_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOCATION" AS
/* $Header: INVHLOCB.pls 120.1 2005/11/29 17:09:16 pojha noship $ */
--
  --
  PROCEDURE INV_PREDEL_VALIDATION (p_location_id   number)
  IS
  --
  v_delete_permitted    varchar2(1);
  l_msg 		varchar2(30);
  --
  --
  BEGIN
     --
     hr_utility.set_location('INV_LOCATION.INV_PREDEL_VALIDATION', 1);
      --
      begin

        l_msg := 'INV_LOC_INTERORG_SHIP_METHODS';
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (

		select  null
                from    MTL_INTERORG_SHIP_METHODS
                where   FROM_LOCATION_ID			= P_LOCATION_ID
                  or    TO_LOCATION_ID				= P_LOCATION_ID
        );


        l_msg := 'INV_LOC_TRANSACTIONS_TEMP';
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (

		select  null
                from    MTL_MATERIAL_TRANSACTIONS_TEMP
                where   SHIP_TO_LOCATION			= P_LOCATION_ID
        );


        l_msg := 'INV_LOC_MOVEMENT_PARAMTERS';
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (

                select  null
                from    MTL_MOVEMENT_PARAMETERS
                where   TAX_OFFICE_LOCATION_ID			= P_LOCATION_ID
        );


	-- bug 4730244 : Deleted the check on mtl_movement_statistics

        l_msg := 'INV_LOC_REPLENISH_HEADERS';
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (

                select  null
                from    MTL_REPLENISH_HEADERS
                where   DELIVERY_LOCATION_ID			= P_LOCATION_ID
        );


        l_msg := 'INV_LOC_REPLENISH_HEADERS_INT';
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (

                select  null
                from    MTL_REPLENISH_HEADERS_INT
                where   DELIVERY_LOCATION_ID			= P_LOCATION_ID
        );


        l_msg := 'INV_LOC_MTL_SUPPLY';
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (

                select  null
                from    MTL_SUPPLY
                where
-- Commented out the below for Bug2828220
--                      PO_LINE_LOCATION_ID			= P_LOCATION_ID
                      LOCATION_ID				= P_LOCATION_ID
        );


        l_msg := 'INV_LOC_TRANSACTION_INTERFACE';
        select 'Y'
        into    v_delete_permitted
        from    sys.dual
        where   not exists (

                select  null
                from    MTL_TRANSACTIONS_INTERFACE
                where   SHIP_TO_LOCATION_ID			= P_LOCATION_ID
        );

      exception
        when NO_DATA_FOUND then
                hr_utility.set_message (401, l_msg);
                hr_utility.raise_error;
      end;
      --
      --
  END INV_PREDEL_VALIDATION;
--
END INV_LOCATION;

/
