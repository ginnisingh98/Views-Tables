--------------------------------------------------------
--  DDL for Package Body WSH_DEL_OI_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DEL_OI_CORE" as
/* $Header: WSHSDVAB.pls 115.8 99/08/09 15:28:53 porting sh $ */

  -- Name           Get_order_info
  -- Purpose        Obtain order info for the picking_header_id
  -- Notes

PROCEDURE GET_ORDER_INFO  (X_picking_header_id  in  number,
                           X_Order_currency     in out varchar2,
                           X_Order_category     in out varchar2) is
BEGIN
declare
  cursor order_info  is
    SELECT soh.currency_code ,
           soh.order_category
    FROM   so_headers_all soh,
           so_picking_headers_all soph
    WHERE  soph.picking_header_id = X_picking_header_id
    AND    soh.header_id = soph.order_header_id;
begin
   open order_info;
   fetch order_info
   into X_order_currency, X_order_category;
   close order_info;
   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.get_order_info');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

end;
END GET_ORDER_INFO;



  -- Name : PICKSLIP_OPEN - returns true if its closed
  --
  -- Assumptions
  -- actually works on picking header id not pick slip number
  -- calling routine should raise error OE_SH_PICK_SLIP_CLOSED
 FUNCTION PICKSLIP_CLOSED (X_PICKING_HEADER_ID IN NUMBER) RETURN BOOLEAN
  IS
    CURSOR open_hdr IS
    SELECT pick_slip_number
    FROM   so_picking_headers_all
    WHERE  picking_header_id = X_Picking_Header_id
    AND    status_code = 'OPEN';
    sql_dummy number;

  BEGIN
    OPEN open_hdr;
    FETCH open_hdr INTO sql_dummy;
    IF open_hdr%NOTFOUND THEN
      CLOSE open_hdr;
      RETURN (TRUE);
    ELSE
      CLOSE open_hdr;
      RETURN (FALSE);
    END IF;
    EXCEPTION WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.pickslip_closed');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

   END;





  -- Name       GET_ITEM_CONTROL_CODES
  -- Purpose    Gets control code flags for a given org/item
  -- Notes
  --
PROCEDURE GET_ITEM_CONTROL_CODES
	(X_warehouse_id               in number,
	 X_item_id                    in number,
         X_order_category             in varchar2,
	 X_subinv_restricted_flag     in out varchar2,
	 X_revision_control_flag      in out varchar2,
	 X_lot_control_flag           in out varchar2,
	 X_serial_number_control_flag in out varchar2,
	 error_code                   in out varchar2) is
BEGIN
declare
  cursor control_codes is
    SELECT
       decode(msi.restrict_subinventories_code,1,'Y','N') ,
       decode(msi.revision_qty_control_code,2,'Y','N') ,
       decode(msi.lot_control_code,2,'Y',3,'Y','N'),
       decode(msi.serial_number_control_code,
-- 2=Predefined serial# 5=Dynamic at inv. receipt 6=Dynamic at sales issue
              2,'Y', 5,'Y', 6,decode(X_order_category,'P','N','D'),'N')
    from  mtl_system_items msi
    where msi.inventory_item_id = X_item_id
    and   msi.organization_id = X_warehouse_id;
begin
  open control_codes;
  fetch control_codes
  into   X_subinv_restricted_flag,
	 X_revision_control_flag,
	 X_lot_control_flag,
         X_serial_number_control_flag;
  if control_codes%notfound then
     error_code := 'WSH_OI_INVALID_ITEM';
  end if;
  close control_codes;


   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.get_item_control_codes');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;
END get_item_control_codes;


  -- Name :                      VALID_SUBINVENTORY
  --
  -- Purpose:                    Validate Sub for this item/warehouse
  -- Arguments
  --   x_warehouse_id            input org id
  --   x_item_id                 input item_id
  --   x_subinventory            input sub for validation
  --   x_order_category          the order category
  --   x_subinv_restricted_flag  either Y or N. If Y then sub is validated
  --                             against predefined list
  --   error_code                error_code: 0 = success all others = error
  -- Notes
  -- Sub is input only because it is validated only: nothing is derived

FUNCTION  VALID_SUBINVENTORY
			(X_warehouse_id 	    in number,
			 X_item_id 		    in number,
			 X_subinventory             in varchar2,
                         X_subinv_restricted_flag   in varchar2)
                         RETURN BOOLEAN IS
BEGIN
declare
  X_description varchar2(50);

  cursor valid_sub is
    select   description
    from     mtl_secondary_inventories
    where    organization_id = X_warehouse_id
    and      quantity_tracked = 1
    and      trunc(sysdate) <= nvl( disable_date, trunc(sysdate) )
    and      secondary_inventory_name = x_subinventory;

  cursor valid_sub_restricted is
    select   mtlsub.description
    from     mtl_item_sub_inventories mtlisi
    ,        mtl_secondary_inventories mtlsub
    where    mtlisi.organization_id = X_warehouse_id
    and      mtlisi.inventory_item_id = X_item_id
    and      mtlsub.organization_id = X_warehouse_id
    and      mtlsub.secondary_inventory_name = mtlisi.secondary_inventory
    and      mtlsub.quantity_tracked = 1
    and      trunc(sysdate) <= nvl( mtlsub.disable_date, trunc(sysdate) )
    and      mtlsub.secondary_inventory_name = x_subinventory;


begin

     x_description := null;
     if X_subinv_restricted_flag = 'N' then
        OPEN  valid_sub;
        FETCH valid_sub into X_description;
        CLOSE valid_sub;
     else
        OPEN  valid_sub_restricted;
        FETCH valid_sub_restricted into X_description;
        CLOSE valid_sub_restricted;
     end if;

     IF x_description is null then
        return (FALSE);
     END IF;

     return (TRUE);
     exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.valid_subinventory');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;
END valid_subinventory;




  -- Name : DEFAULT_SUBINVENTORY
  --
  -- Purpose: Get Default Sub for this item/warehouse
  --
  -- Arguments
  --   x_warehouse_id             input org id
  --   x_item_id                  input item_id
  -- Returns default sub or null
  -- Notes
  --   Sub gets populated with the default for this org/item if it is defined
  --   else it returns null
  --   The query should always succeed. Any error is a system error which will
  --   terminate the program. Therefore no error_code parameter required

FUNCTION DEFAULT_SUBINVENTORY
	(X_warehouse_id           in number,
	 X_item_id 	          in number) RETURN varchar2 is
BEGIN
declare
  cursor default_sub is
       select mtlsub.secondary_inventory_name
         from mtl_item_sub_defaults mtlisd,
    	      mtl_secondary_inventories mtlsub
        where mtlisd.inventory_item_id = X_item_id
          and mtlisd.organization_id = X_warehouse_id
          and mtlisd.default_type = 1
          and mtlsub.organization_id = mtlisd.organization_id
    	  and mtlsub.secondary_inventory_name = mtlisd.subinventory_code
    	  and mtlsub.quantity_tracked = 1
    	  and trunc(sysdate) <= nvl( mtlsub.disable_date, trunc(sysdate));

   dflt_subinventory varchar2(30);
begin

   open  default_sub;
   fetch default_sub into dflt_subinventory;
   close default_sub;

   RETURN (dflt_subinventory);

   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.default_subinventory');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

end;
END DEFAULT_SUBINVENTORY;


  -- Name : GET_LOCATOR_CONTROLS
  --
  -- Purpose: Get Locator Controls for this Org/Item/Sub
  --
  -- Arguments
  --   x_warehouse_id            input org id
  --   x_item_id                 input item_id
  --   x_subinventory            input sub id
  --   x_location_control_flag     output
  --   x_location_restricted_flag  output
  --   error_code                error_code: 0 = success all others = error
  -- Notes
  --   This is seperate from get_item_controls because sub is required

PROCEDURE GET_LOCATOR_CONTROLS
	(X_warehouse_id             in number,
	 X_item_id 	            in number,
	 X_subinventory             in varchar2,
         X_location_control_flag    in out varchar2,
         X_location_restricted_flag in out varchar2,
	 error_code                 in out varchar2) is
BEGIN
declare
  cursor locator_controls is
    select decode( nvl( mtlpar.stock_locator_control_code, 1 ),
		 1, 'N', 2, 'Y', 3, 'D',
		 4, DECODE( NVL( mtlsin.locator_type, 1 ),
			  1, 'N', 2, 'Y', 3, 'D', 4, 'N',
			  5, DECODE( NVL( mtlsis.location_control_code, 1 ),
			     1, 'N', 2, 'Y', 3, 'D', 'N' ),
		         'N' ),
		 5, DECODE( NVL( mtlsis.location_control_code, 1 ),
			  1, 'N', 2, 'Y', 3, 'D', 'N' ),
		 'N' )
    ,      DECODE( mtlsis.restrict_locators_code, 1, 'Y', 'N' )
    from   mtl_parameters            mtlpar
    ,      mtl_secondary_inventories mtlsin
    ,      mtl_system_items          mtlsis
    where  mtlpar.organization_id          = X_warehouse_id
    and    mtlsin.organization_id          = mtlpar.organization_id
    and    mtlsin.secondary_inventory_name = X_subinventory
    and    mtlsis.organization_id          = mtlpar.organization_id
    and    mtlsis.inventory_item_id        = X_item_id;


begin
   open  locator_controls;
   fetch locator_controls
    into X_location_control_flag,
         X_location_restricted_flag;
   if locator_controls%notfound then
      error_code := 'WSH_OI_MISSING_LOC_CNTRL';
   end if;
   close locator_controls;
   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.get_locator_controls');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;
END get_locator_controls;



  -- Name : VALID_LOT_NUMBER
  -- Purpose:                    Validates the lot number
  -- Arguments
  --   x_warehouse_id            input org id
  --   x_item_id                 input item_id
  --   x_subinventory            input sub id
  --   x_lot_number              input lot number for validation
  --   error_code                error_code: 0 = success all others = error
  -- Notes
  --   This validates the lot number: it does not populate it therefore
  --   the only out parameter is error_code
  --
FUNCTION VALID_LOT_NUMBER
	(X_warehouse_id             in number,
	 X_item_id 	            in number,
	 X_subinventory             in varchar2,
         X_lot_number               in varchar2) return BOOLEAN is
BEGIN
declare
  cursor validate_lot is
    select  'lot number valid'
    from    mtl_onhand_quantities
    where   inventory_item_id = X_item_id
    and     organization_id   = X_warehouse_id
    and     nvl(subinventory_code,'X') = nvl(X_subinventory,'X')
    and     lot_number        = X_lot_number;

  dummy varchar2(40);
begin
   open  validate_lot;
   fetch validate_lot into dummy;
   close validate_lot;

   if dummy is null then
      return (FALSE);
   end if;
   return (TRUE);

   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.valid_lot_number');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

end;
END valid_lot_number;



  -- Name : VALID_REVISION
  -- Purpose:                    Validates the lot number
  -- Arguments
  --   x_warehouse_id            input org id
  --   x_item_id                 input item_id
  --   x_revision                input revision number for validation
  --   error_code                error_code: 0 = success all others = error
  -- Notes
  --   This validates the revision number: it does not populate it therefore
  --   the only out parameter is error_code
  --
FUNCTION VALID_REVISION
	(X_warehouse_id             in number,
	 X_item_id 	            in number,
         X_revision                 in varchar2) return BOOLEAN is

BEGIN
declare
  cursor validate_revision is
   select   'revision is valid'
   from     mtl_item_revisions
   where    organization_id   = X_warehouse_id
   and      inventory_item_id = X_item_id
   and      revision          = X_revision;
  dummy varchar2(40);
begin
   open  validate_revision;
   fetch validate_revision into dummy;
   close validate_revision;

   if dummy is null then
      return (FALSE);
   end if;
   return (TRUE);

   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.valid_revision');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;
END VALID_REVISION;


  -- Name : VALIDATE_LOCATOR_ID
  -- Purpose:                    Validates Locator Id for this item/org/sub
  -- Arguments
  --   x_warehouse_id            input org id
  --   x_item_id                 input item_id
  --   x_subinventory            input sub id
  --   x_location_restricted_flag either Y or N. If Y will ensure
  --                              location is in predefined list
  --   X_locator_id              locator_id
  -- Notes
  --   either locator segment or id must be supplied. If both are supplied then
  --   segments are ignored and priority given to the id.
  --
FUNCTION  VALID_LOCATOR_ID
	(X_warehouse_id             in number,
	 X_item_id 	            in number,
         X_subinventory             in varchar2,
         X_location_restricted_flag in varchar2,
         X_locator_id           in number) return BOOLEAN is
BEGIN
declare
  sql_string varchar2(30);
  cursor validate_locator is
	select 'valid locator id'
	from   mtl_item_locations mtlloc
        where  organization_id = X_warehouse_id
        and    mtlloc.inventory_location_id = X_locator_id
        and  ( nvl(X_location_restricted_flag, 'N') = 'N'
	       or
	        (nvl(X_location_restricted_flag, 'N') = 'Y'
	         and  nvl(mtlloc.inventory_location_id, -1) in (
	       		select mtlsls.secondary_locator
			from   mtl_secondary_locators mtlsls
		      	where  mtlsls.organization_id = X_warehouse_id
		      	and    mtlsls.inventory_item_id = X_item_id
        		and    mtlsls.subinventory_code = X_subinventory)));
begin

   sql_string  := null;
   open  validate_locator;
   fetch validate_locator     into sql_string;
   close validate_locator;


   if sql_string is not null  then
      RETURN(TRUE);
   else
      RETURN(FALSE);
   end if;

   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.valid_locator_id');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

end;
END valid_locator_id;



  -- Name : DEFAULT_LOCATOR
  -- Purpose:                    Lookup and retrieve Default Location Id
  -- Arguments
  --   x_warehouse_id            input org id
  --   x_item_id                 input item_id
  --   x_subinventory            input sub id
  --   x_location_restricted_flag either Y or N. If Y will ensure
  --                              location is in predefined list
  --   deflt_locator_id          output
  -- Notes
  --   retieves default locator. If none exists then it returns null.
  --   Any other error is a system error so program will terminate.
  --   Therfore there is no error_code paramter.
  --
FUNCTION DEFAULT_LOCATOR
	(X_warehouse_id             in number,
	 X_item_id 	            in number,
         X_subinventory             in varchar2,
         X_location_restricted_flag in varchar2) return number is

BEGIN

wsh_del_oi_core.println('inside DEFAULT_LOCATOR');

declare
  cursor default_locator is
    select mtldl.locator_id
    from   mtl_item_loc_defaults mtldl
    where  mtldl.inventory_item_id = X_item_id
    and    mtldl.organization_id = X_warehouse_id
    and    mtldl.default_type = 1
    and    mtldl.subinventory_code = X_subinventory
    and   (  nvl(X_location_restricted_flag, 'N') = 'N'
	   OR
	     (nvl(X_location_restricted_flag, 'N') = 'Y'
	      and nvl(mtldl.locator_id, -1) in
		   (select mtlsls.secondary_locator
		    from   mtl_secondary_locators mtlsls
		    where  mtlsls.organization_id = X_warehouse_id
		    and    mtlsls.inventory_item_id = X_item_id
		    and    mtlsls.subinventory_code = X_subinventory)));
     dflt_locator_id             number;

begin

wsh_del_oi_core.println('inside DEFAULT_LOCATOR');
   open  default_locator;
   fetch default_locator    into  dflt_locator_id;
   close default_locator;

   return (dflt_locator_id);

   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.default_locator');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;
END default_locator;



  -- Name: Valid_Serial_Number
  -- Notes : validates serial# is OK for this combination of inv controls,
  -- the sub permits serial number and  loc is valid when under restricted locs
  --
  --

FUNCTION  VALID_SERIAL_NUMBER
	(X_warehouse_id                 in number,
	 X_item_id 	                in number,
         X_subinventory                 in varchar2,
         X_revision                     in varchar2,
         X_lot_number                   in varchar2,
         X_locator_id                   in number,
         X_serial_number                in varchar2,
         X_location_restricted_flag     in varchar2,
         X_location_control_flag        in varchar2,
         X_serial_number_control_flag   in varchar2) return BOOLEAN is

BEGIN
declare
  sql_string varchar2(30);
  cur_stat number;
  msg_string varchar2(200);
  cursor validate_ser_num is
     SELECT
              'valid serial number', S.CURRENT_STATUS
     FROM     MTL_SERIAL_NUMBERS S,
              MTL_ITEM_LOCATIONS LOC
     WHERE    S.CURRENT_ORGANIZATION_ID   = x_warehouse_id
     AND      S.INVENTORY_ITEM_ID         = x_item_id
     AND      NVL( S.REVISION, '~' )      = NVL( x_revision, '~' )
     AND      NVL( S.LOT_NUMBER, '~' )    = NVL( x_lot_number, '~' )
     AND      S.SERIAL_NUMBER             = x_serial_number
     AND      S.CURRENT_ORGANIZATION_ID   = LOC.ORGANIZATION_ID(+)
     -- if not under locator control then -1 = -1 else s.current_loc=x_loc
     AND      DECODE(x_location_control_flag,
                     'Y', NVL(S.CURRENT_LOCATOR_ID, -1),
                     'D', NVL(S.CURRENT_LOCATOR_ID, -1),
                          -1) =
              DECODE(x_locator_id,
                     '', DECODE(x_location_control_flag,
                                   'Y', LOC.INVENTORY_LOCATION_ID,
                                   'D', LOC.INVENTORY_LOCATION_ID, -1),
                     x_locator_id)
     AND      NVL(S.CURRENT_LOCATOR_ID, -1) = LOC.INVENTORY_LOCATION_ID(+)
     -- if restricted loc then check in mtl_sec_loc
     AND      (NVL(x_location_restricted_flag, 'N') = 'N'  OR
              (NVL(x_location_restricted_flag, 'N') = 'Y'
              AND
                    NVL(LOC.INVENTORY_LOCATION_ID, -1) IN (
                    SELECT NVL(MAX(MTLSLS.SECONDARY_LOCATOR),-1)
                    FROM   MTL_SECONDARY_LOCATORS MTLSLS
                    WHERE  MTLSLS.ORGANIZATION_ID = x_warehouse_id
                    AND    MTLSLS.INVENTORY_ITEM_ID = x_item_id
                    AND    MTLSLS.SUBINVENTORY_CODE = x_subinventory
     -- Bug 842175
                    AND    MTLSLS.SECONDARY_LOCATOR = x_locator_id )))
     AND      S.CURRENT_SUBINVENTORY_CODE = x_subinventory
     AND      S.CURRENT_STATUS IN (
              DECODE( x_serial_number_control_flag, 'Y', 3, -1 ),
              DECODE( x_serial_number_control_flag, 'D', 3, -1 ),
              DECODE( x_serial_number_control_flag, 'D', 1, -1 ),
              DECODE( x_serial_number_control_flag, 'D', 4, -1 ),
	      DECODE( x_serial_number_control_flag, 'D', 5, -1 ));

begin
    msg_string :=  ('Ware:'||to_char(x_warehouse_id)||
                    ',item:'||to_char(x_item_id)||
                    ',sub:'||x_subinventory||
                    ',rev:'||x_revision||
                    ',lot:'||x_lot_number||
                    ',loc:'||to_char(x_locator_id)||
                    ',srl:'||x_serial_number||
                    ',l_res:'||X_location_restricted_flag||
                    ',l_ctl:'||X_location_control_flag||
                    ',s_ctl:'||X_serial_number_control_flag );

   open  validate_ser_num;
   fetch validate_ser_num into sql_string, cur_stat;
   close validate_ser_num;

   if ( x_serial_number_control_flag = 'D' ) Then
	if ( sql_string is NULL ) Then
	    return TRUE ;
        elsif (( cur_stat = 1 ) or ( cur_stat = 3 )) Then
            return TRUE;
        else
            wsh_del_oi_core.println('Valid_srl_no:'||msg_string);
            wsh_del_oi_core.println('Dynamic Srl controlled but status !=(1 or 3)');
	    return FALSE;
        end if;
   elsif sql_string is null then
      wsh_del_oi_core.println('valid_srl_no:'||msg_string);
      wsh_del_oi_core.println('Predefined Srl nos but srlno does not exist.');
      return (FALSE);
   end if;
   return (TRUE);

   exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.valid_serial_number');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

end;
END valid_serial_number;

  -- Name: AR_INTERFACED
  -- Notes
  -- returns TRUE if order has been interfaced to AR
  --
FUNCTION AR_Interfaced (X_delivery_id  in  number)
  RETURN BOOLEAN IS
BEGIN
declare
  -- s5 = Receivables Interface flag: 5= Partial, 9= Interfaced
  cursor ar_valid (del_id number) is
    select 'exists'
    from   so_picking_lines_all pl, so_picking_line_details pld
    where  pl.picking_line_id = pld.picking_line_id
    and    pld.delivery_id = del_id
    and    pl.ra_interface_status is not null
    and    exists(  select 'interfaced lines exist'
    	            from   so_lines_all l
    	            where  l.s5  in (5,8,9)
    	            and    l.line_id = pl.order_line_id);
  dummy varchar2(30);

begin
  open  ar_valid(x_delivery_id);
  fetch ar_valid into dummy;
  if ar_valid%found then
     close ar_valid;
     RETURN (TRUE);
  else
     close ar_valid;
     wsh_del_oi_core.println('Its not AR_interfaced');
     RETURN (FALSE);
  end if;
  exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.AR_INTERFACED');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;

END AR_INTERFACED;



  -- Name : Valid_freight_type
  --
  -- Notes
  -- validates type id/code. If both are supplied for validation,
  -- code is ignored and preference is given to id.
  --
FUNCTION  Valid_freight_type
	(X_in_id                       in number,
	 X_in_code                     in varchar2) RETURN number is
BEGIN
declare
  cursor sofct is
     SELECT freight_charge_type_id
     FROM   so_freight_charge_types
     WHERE  freight_charge_type_id  = nvl(X_in_id, freight_charge_type_id)
     AND    freight_charge_type_code = decode(X_in_id,null,X_in_code,freight_charge_type_code )
     AND    nvl(start_date_active,sysdate) <= sysdate
     AND    nvl(end_date_active,sysdate)   >= sysdate;
  x_out_id number;
begin
  open  sofct;
  fetch sofct  into  X_out_id;
  close sofct;



  return (x_out_id);

  exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.valid_freight_type');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;
END Valid_freight_type;



  -- Name : Valid_carrier_code
  --
  -- Notes
  -- validates carrier code /ship_method_code
  --
FUNCTION  Valid_carrier_code
	(X_organization_id           in number,
	 X_carrier_code              in varchar2) RETURN BOOLEAN is
BEGIN
declare
  cursor car_code is
     SELECT 'valid'
     FROM   org_freight
     WHERE  organization_id = x_organization_id
     AND    freight_code = x_carrier_code
     AND    nvl(disable_date, sysdate)   >= sysdate;

  sql_dummy varchar2(30);
begin
  open  car_code;
  fetch car_code  into sql_dummy;
  close car_code;

  if sql_dummy = 'valid' then
     return (TRUE);
  else
     wsh_del_oi_core.println('Invalid Carrier code.');
     return(FALSE);
  end if;

  exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.valid_freight_type');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;
END Valid_Carrier_Code;


  -- Name : Validate_container_id
  --
  -- Notes
  -- validates container_id / sequence number is valid for this
  -- delivery
  --

FUNCTION  Validate_Container_Id
	(X_container_id           in number,
	 X_sequence_number        in number,
         x_delivery_id            in number,
         error_code		  in out varchar2) return NUMBER is
BEGIN
declare

--   use either (1) container_id - the PK
--	 or     (2) delivery_id,sequence_number - concatenated key

    cursor container_lookup is
    SELECT container_id
      FROM wsh_packed_containers
     WHERE container_id = nvl(x_container_id, container_id)
       AND sequence_number = decode(x_container_id, null, x_sequence_number, sequence_number)
       AND delivery_id = x_delivery_id;

  container_id number;

begin

  open  container_lookup;
  fetch container_lookup into container_id;

  if container_lookup%NOTFOUND THEN
     wsh_del_oi_core.println('Validate_container_id - container_lookup Cursor not found');

     close container_lookup;

     if x_container_id is not null then
          wsh_del_oi_core.println('Validate_container_id container_id is not null');
          error_code := 'WSH_OI_INVALID_CONTAINER';
          return (container_id);
     end if;

     container_id := null;

   else
     close container_lookup;
   end if;

  return (container_id);

  exception
        when others then
	  FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	  FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.validate_container_id');
	  FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
          FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	  APP_EXCEPTION.Raise_Exception;
end;
END Validate_container_id;


  -- Name : Validate_currency
  --
  -- Notes
  -- validates currency code/name. If both are supplied,
  -- name is ignored and preference is given to code.
  --
PROCEDURE VALIDATE_CURRENCY
	(X_in_code                   in  varchar2,
	 X_in_name                   in  varchar2,
         X_amount                    in  number,
	 X_out_code                  out varchar2,
	 X_out_name                  out varchar2,
	 error_code                  in out varchar2) is
BEGIN

declare
  cursor currency_cursor is
    SELECT currency_code,
           name,
           nvl(precision,0),
           decode(instr(to_char(nvl(x_amount,0)),'.'),0,0,
                        length(to_char(nvl(x_amount,0)))-
                        instr(to_char(nvl(x_amount,0)),'.'))
    FROM fnd_currencies_VL
    WHERE enabled_flag = 'Y'
    AND name = decode( X_in_code, null, X_in_name, name)
    AND currency_code = nvl( X_in_code, currency_code)
    AND trunc(sysdate) between nvl( start_date_active, trunc(sysdate) )
		        and nvl( end_date_active, trunc(sysdate) );
    x_precision     number;
    x_in_precision  number;

begin
  if x_in_code is null and x_in_name is null then
     error_code := 'CURR-No code';
     FND_MESSAGE.set_name('FND', error_code);
  else
     open  currency_cursor;
     fetch currency_cursor
     into  X_out_code, X_out_name, X_precision, X_in_precision;
     if currency_cursor%notfound then
        if x_in_code is not null then
          error_code := 'CURR-Invalid code';
          FND_MESSAGE.set_name('FND', error_code);
          FND_MESSAGE.set_token('CODE',x_in_code);
        else
          error_code := 'CURR-Invalid currency value';
          FND_MESSAGE.set_name('FND', error_code);
        end if;
     end if;
     close currency_cursor;
     if x_in_precision > x_precision then
        error_code := 'CURR-Precision';
        FND_MESSAGE.set_name('FND', error_code);
        FND_MESSAGE.set_token('PRECISON',to_char(x_precision));
     end if;
  end if;
  exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.validate_currency');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;

END validate_currency;

  -- Name : Validate_uom
  --
  -- Notes
  -- validates uom code/desc. If both are supplied,
  -- desc is ignored and preference is given to code.
  --
PROCEDURE VALIDATE_UOM
	(X_class                     in  varchar2,
	 X_uom_code                  in  out  varchar2,
         X_uom_desc                  in  varchar2,
	 error_code                  in out varchar2) is
BEGIN
declare
  cursor uom_cursor (class varchar2, uomcode varchar2, uomdesc varchar2) is
	SELECT uom_code
	FROM  mtl_units_of_measure
	WHERE unit_of_measure = decode(uomcode,'',uomdesc,unit_of_measure)
 	AND   uom_code  = nvl(uomcode,uom_code)
        AND   uom_class = NVL(class,uom_class)
        AND  nvl(disable_date,sysdate) >= sysdate;
    valid_uom_code varchar2(3);

begin
   if (x_uom_code is not null)
   or (x_uom_desc is not null) then
      open uom_cursor(x_class, x_uom_code, x_uom_desc);
      fetch uom_cursor into valid_uom_code;
      if uom_cursor%notfound then
	 error_code := 'WSH_OI_INVALID_UOM';
      else
         x_uom_code := valid_uom_code;
      end if;
      close uom_cursor;
   end if;
  exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.validate_uom');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;

END validate_uom;

  -- Name : Validate_User
  --
  -- Notes
  -- validates User Id/Name. If both are supplied,
  -- Name is ignored and preference is given to Id.
  --
PROCEDURE VALIDATE_USER
	(X_user_id                   in  out number,
         X_user_name                 in  varchar2,
	 error_code                  in out varchar2) is
BEGIN
declare
    cursor user_lookup (userid in number, username in varchar2) is
	SELECT user_id
	FROM fnd_user
	WHERE user_id = NVL(userid,user_id)
	AND user_name = DECODE(userid,null,username,user_name)
        AND nvl(start_date , sysdate) <= sysdate
        AND nvl(end_date,sysdate) >= sysdate;
    valid_user_id number;

begin
   if (x_user_id   is not null)
   or (x_user_name is not null) then
      open user_lookup(x_user_id, x_user_name);
      fetch user_lookup into valid_user_id;
      if user_lookup%notfound then
	 error_code := 'WSH_OI_INVALID_USER';
      else
         x_user_id := valid_user_id;
      end if;
      close user_lookup;
   end if;
  exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.validate_user');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;

END validate_user;

  -- Name : Update_shipping_online
  --
  -- Notes : Must be called after a commit.
PROCEDURE UPDATE_SHIPPING_ONLINE
         (x_picking_header_id in number,
          x_batch_id          in number)  IS
BEGIN
declare x_dummy            varchar2(250);
        x_return_msg       varchar2(50);
        error_code_num     number;
begin
    -- Call the Shipping TM to run Update Shipping Program (includes inv interface)
    error_code_num:= FND_TRANSACTION.Synchronous
                     (timeout     => 1000,
		      outcome     => x_dummy,
		      message     => x_return_msg,
		      application => 'OE',
                      program     => 'OEBSCO',
                      arg_1       => '0',
                      arg_2       => to_char(x_picking_header_id),
                      arg_3       => fnd_profile.value( 'SO_RESERVATIONS'),
                      arg_4       => to_char(fnd_global.user_id),
                      arg_5       => to_char(fnd_global.login_id),
                      arg_6       => to_char(x_batch_id),
                      arg_7       => chr(0));


    wsh_del_oi_core.println('OEBSCO Returned with status '||x_dummy||' msg '||x_return_msg
     ||' and code = '||to_char(error_code_num));

    IF (error_code_num = 2) THEN
       FND_MESSAGE.Set_Name('OE','OE_SH_PROCESS_ONLINE_NO_MGR');

    ELSIF (error_code_num <> 0) THEN
       FND_MESSAGE.Set_Name('OE','OE_SH_PROCESS_ONLINE_ERROR');

    ELSE
       IF (x_return_msg = 'FAILURE') THEN
	   error_code_num := FND_TRANSACTION.get_values(x_return_msg,
   			       x_dummy, x_dummy, x_dummy, x_dummy, x_dummy,
   			       x_dummy, x_dummy, x_dummy, x_dummy, x_dummy,
   			       x_dummy, x_dummy, x_dummy, x_dummy, x_dummy,
   			       x_dummy, x_dummy, x_dummy, x_dummy);

	  IF (x_return_msg = 'SUCCESS') THEN
	    	   FND_MESSAGE.Set_Name('OE','OE_SH_PROCESS_ONLINE_FAILED');
 	           FND_MESSAGE.Set_Token('PROCESS','OE_SH_INVENTORY_INTERFACE');

 	  ELSE
	           FND_MESSAGE.Set_Name('OE','OE_SH_PROCESS_ONLINE_FAILED');
	           FND_MESSAGE.Set_Token('PROCESS','OE_SH_UPDATE_SHIPPING_INFO');

	  END IF;
       END IF;
    END IF;


end;
END UPDATE_SHIPPING_ONLINE;



  -- Name           Ship_multi_org
  -- Purpose:
  -- used when checking for multi-org. Ensures order's org is same as current org
  -- where current org is the org on any/all orders in the so_headers view

FUNCTION Ship_multi_org (X_picking_header_id in number ) return BOOLEAN is
BEGIN
declare
 CURSOR multi_org_check  is
    SELECT 'SHIP_DIFF_ORG'
    FROM   so_headers_all h,
           so_picking_headers_all ph
    WHERE  h.header_id = ph.order_header_id
    AND    ph.picking_header_id = X_picking_header_id
    AND    nvl(h.org_id,-99) <>
                   (SELECT nvl(h2.org_id,-99)
		    FROM   so_headers h2
		    WHERE  rownum = 1);

    x_msg_name     VARCHAR2(40);

begin
     --  ensure org is in the same org as we are in
    OPEN  multi_org_check;
    FETCH multi_org_check INTO x_msg_name;
    IF multi_org_check%notfound then
       CLOSE multi_org_check;
       return(FALSE);
    ELSE
       CLOSE multi_org_check;
       wsh_del_oi_core.println('Multi_org_check returns FALSE');
       return(TRUE);
    END IF;
end;
END SHIP_MULTI_ORG;


---- write routines for debug purpose ---------------*/
---- personal profile oe_debug_level = 1 - 3. This governs the detail
---- of the messages in debug, 1 is most general and 3 is very detailed.
PROCEDURE print(msg IN VARCHAR2) IS
BEGIN
	if  not suppress_print then
	  fnd_file.put(FND_FILE.LOG, substr(msg,1,255));
	end if;
END;

PROCEDURE println IS
BEGIN
   if not suppress_print then
     IF NVL(FND_PROFILE.Value('OE_DEBUG_LEVEL'),0) in ('2','3') THEN
	fnd_file.new_line(FND_FILE.LOG, 1);
     END IF;
   end if;
END;

PROCEDURE println(msg IN VARCHAR2) IS
BEGIN
   if not suppress_print then
     IF NVL(FND_PROFILE.Value('OE_DEBUG_LEVEL'),0) in ('2','3') THEN
       fnd_file.put_line(FND_FILE.LOG, substr(msg,1,255));
     END IF;
   end if;
END;

  -- Name : Validate_SO_Code
  --
  -- Notes
  -- validates a code in so_lookups.
  -- If both code/meaning are supplied for validation,
  -- meaing is ignored and preference is given to internal code.
  --
PROCEDURE  Validate_so_code
	(X_lookup_type	in varchar2,
	 X_code         in out varchar2,
	 X_meaning      in varchar2,
	 X_error_code   in out varchar2) is

BEGIN
declare
  cursor so_code_lookup is
     SELECT lookup_code
     FROM   so_lookups
     WHERE  lookup_type = X_LOOKUP_TYPE
     AND    lookup_code  = nvl(X_code,lookup_code)
     AND    meaning = decode(X_code,null,X_meaning,meaning)
     AND    nvl(start_date_active,sysdate) <= sysdate
     AND    nvl(end_date_active,sysdate)   >= sysdate
     AND    enabled_flag = 'Y';

  valid_code varchar2(30);
begin
  open  so_code_lookup;
  fetch so_code_lookup  into  valid_code;

  if so_code_lookup%notfound then
     x_error_code := '1';
  else
     x_error_code := '0';
     x_code    := valid_code;
  end if;

  close so_code_lookup;

  exception when others then
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DEL_OI_CORE.validate_so_code');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
end;
END Validate_so_code;


end WSH_DEL_OI_CORE;

/
