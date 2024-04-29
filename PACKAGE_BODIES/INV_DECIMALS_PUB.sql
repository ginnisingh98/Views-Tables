--------------------------------------------------------
--  DDL for Package Body INV_DECIMALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DECIMALS_PUB" AS
/* $Header: INVDECPB.pls 120.3 2005/07/12 02:05:58 varajago noship $ */


/*--------------------------------------------------------------------------+
 |Procedure validate_compare_quantities(..)
 |Returns the quantity converted from the first UOM in the second UOM.
 |If quantities in 2 UOMs are already available, then this procedure will
 |compare and validate these quantities based on conversion rates
 |and UOM and decimal qty controls. This procedure may be used to validate
 |scenarios where quatities are entered in dual UOMs. We want to make sure
 |quantities are valid based on conversion, and conversion
 |rate tolerances.
 |
 |Procedure validate_and_compare(
 |p_api_version_number		IN	NUMBER, -- version # of API
 |p_init_msg_list		IN	VARCHAR2, -- whether to initialize list
 |p_inventory_item_id		IN	NUMBER, -- inventory_item_id
 |p_organization_id		IN	NUMBER, -- organization_id
 |p_lot_control_code		IN	NUMBER, -- item's lot control code
 |p_lot_number			IN	VARCHAR2, -- lot number
 |p_sub_lot_control_code	IN	NUMBER, --sub lot control code
 |p_sublot_number		IN	VARCHAR2, -- sublot number
 |p_from_quantity		IN	NUMBER, -- qty in first UOM
 |p_from_uom_code		IN	VARCHAR2, -- UOM of fisrt qty
 |p_to_uom_code			IN	VARCHAR2, -- UOM of second qty
 |p_to_quantity_to_check	IN	NUMBER, -- qty in second UOM
 |x_resultant_to_quantity OUT NOCOPY  NUMBER, -- calculated qty in second UOM
 |x_comparison		 OUT NOCOPY  NUMBER,--Possible values are 1,0,-1,-99
 |x_msg_count		 OUT NOCOPY  NUMBER, -- number of messages
 |x_msg_data		 OUT NOCOPY  VARCHAR2, -- populated,if msg count = 1
 |x_return_status	 OUT NOCOPY  VARCHAR2) -- return status
 |
 |Note: The comparisons are done in base UOM
 | of the UOM class to which the first UOM belongs. x_comparison returns:
 |-1		if from_quantity is less than to_quantity (A < B)
 | 0		if from_quantity is equal to to_quantity (A = B)
 | 1		if from_quantity is greater than to_quantity (A > B)
 | -99	if the validations for the first/second quantity failed
 | If the UOMs belong to different classes, then users can specify whether
 | they want to use the effective interclass UOM conversion tolerance, say, T.
 | CASE: p_use_interclass_tolerance = 1
 | ------
 | Q1 > Q2 if (Q1 - Q2) >= T
 | Q1 = Q2 if ABS(Q1 - Q2) < T
 | Q1 < Q2 if (Q1 - Q2 ) <= -T
 |
 |The output variable x_resultant_to_quantity will contain the converted
 |quantity
 |in the second UOM, using effective conversion rates.
 |Usage: In a dual UOM scenario, this api will confirm whether quantities in
 |the two UOMs are equal or not, based on x_comparison output variable.
 +--------------------------------------------------------------------------*/

-- Package Globals
-- a warning exception
	g_inv_warning	exception ;
	g_ret_warning	CONSTANT	VARCHAR2(1):= 'W';


   g_package_name		CONSTANT	VARCHAR2(50) := 'INV_DECIMALS';
   g_max_decimal_digits	CONSTANT	NUMBER := 9 ;
   g_max_real_digits	CONSTANT	NUMBER := 10 ;
   g_max_total_digits	CONSTANT	NUMBER := 19 ;

Procedure validate_compare_quantities(
		p_api_version_number	IN	NUMBER,
		p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_inventory_item_id	IN	NUMBER,
		p_organization_id	IN	NUMBER,
		p_lot_control_code	IN	NUMBER,
		p_lot_number		IN	VARCHAR2,
 		p_sub_lot_control_code	IN	NUMBER,
 		p_sublot_number		IN	VARCHAR2,
		p_from_quantity		IN	NUMBER,
		p_from_uom_code		IN	VARCHAR2,
		p_to_uom_code		IN	VARCHAR2,
		p_to_quantity_to_check	IN	NUMBER,
		x_resultant_to_quantity	OUT NOCOPY	NUMBER,
		x_valid_conversion	OUT NOCOPY	NUMBER,
 		x_msg_count		OUT NOCOPY	NUMBER,
 		x_msg_data		OUT NOCOPY	VARCHAR2,
		x_return_status		OUT NOCOPY	VARCHAR2) IS

BEGIN

null;

end validate_compare_quantities ;


/*--------------------------------------------------------------------------+
 |Function convert_UOM(..) return NUMBER ;
 |Returns the quantity converted from the first unit into the second unit.
 |If conversion is not possible, return status is failure.
 |Function convert(
 |p_api_version_number		IN	NUMBER,
 |p_init_msg_list		IN	VARCHAR2, -- whether to initialize list
 |p_inventory_item_id		IN	NUMBER, -- inventory_item_id
 |p_organization_id		IN	NUMBER, -- organization_id
 |p_lot_control_code		IN	NUMBER, -- item's lot control code
 |p_lot_number			IN	VARCHAR2, -- lot number
 |p_sub_lot_control_code	IN	NUMBER,
 |p_sublot_number		IN	VARCHAR2,
 |p_from_quantity		IN	NUMBER, -- qty in first UOM
 |p_from_uom_code		IN	VARCHAR2, -- UOM of fisrt qty
 |p_to_uom_code			IN	VARCHAR2, -- UOM of second qty
 |x_msg_count		 OUT NOCOPY  NUMBER,
 |x_msg_data		 OUT NOCOPY  VARCHAR2,
 |x_return_status	 OUT NOCOPY  VARCHAR2)
 |					  return NUMBER ;
 |If there is an error, then -99 is returned.
 |1) From_quantity must be an absolute value.
 |2) From_quantity will then converted to base UOM in the class,
 |3) Then converted to base UOM of the
 |   to_UOM class,
 |4) Then converted to the quantity in to_UOM,
 |5) Then rounded to 9 decimals
 +--------------------------------------------------------------------------*/

Function convert_UOM(
		p_api_version_number	IN	NUMBER,
		p_init_msg_list		IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_inventory_item_id	IN	NUMBER,
		p_organization_id	IN	NUMBER,
		p_lot_control_code	IN	NUMBER,
		p_lot_number		IN	VARCHAR2,
		p_sub_lot_control_code	IN	NUMBER,
 		p_sublot_number		IN	VARCHAR2,
		p_from_quantity		IN	NUMBER,
		p_from_uom_code		IN	VARCHAR2,
		p_to_uom_code		IN	VARCHAR2,
 		x_msg_count		OUT NOCOPY	NUMBER,
 		x_msg_data		OUT NOCOPY	VARCHAR2,
		x_return_status		OUT NOCOPY	VARCHAR2) return NUMBER IS

BEGIN

return 0;

end convert_uom ;


/*--------------------------------------------------------------------------+
 | get_uom_properties(..)
 | This procedure is used to interrogate the UOM.
 | It returns:
 | uom class, base uom.
 | if the UOM is not found, the return status indicates this.
 | Procedure get_uom_properties(
 | p_api_version_number	IN	NUMBER,
 | p_init_msg_list	IN	VARCHAR2,
 | p_uom_code		IN	VARCHAR2,
 | x_uom_class	 OUT NOCOPY  VARCHAR2,
 | x_base_uom	 OUT NOCOPY  VARCHAR2,
 | x_msg_count	 OUT NOCOPY  NUMBER,
 | x_msg_data	 OUT NOCOPY  VARCHAR2,
 | x_return_status OUT NOCOPY  VARCHAR2);
 +--------------------------------------------------------------------------*/


Procedure get_uom_properties(
  p_api_version_number	IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_uom_code		IN	VARCHAR2,
  x_uom_class		OUT NOCOPY	VARCHAR2,
  x_base_uom		OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  x_return_status	OUT NOCOPY	VARCHAR2) IS

BEGIN

null;

end get_uom_properties ;



/*-------------------------------------------------------------------------+
 | Procedure compare_quantities(..)
 | Procedure compare_quantities(
 |	p_api_version_number		IN	NUMBER,
 |	p_init_msg_list			IN	VARCHAR2,
 | 	p_inventory_item_id		IN	NUMBER,
 | 	p_organization_id		IN	NUMBER,
 |	p_lot_control_code		IN	NUMBER,
 | 	p_lot_number			IN	VARCHAR2,
 |	p_sub_lot_control_code		IN	NUMBER,
 |	p_sublot_number			IN	VARCHAR2,
 | 	p_fisrt_qauantity		IN	NUMBER,
 |	p_first_uom			IN	VARCHAR2,
 |	p_second_quantity		IN	NUMBER,
 | 	p_second_uom			IN	VARCHAR2,
 |	p_use_interclass_tolerance	IN	VARCHAR2, -- Yes = 1, 2 = No
 |	x_comaprison_result	 OUT NOCOPY  NUMBER,
 |	x_msg_count		 OUT NOCOPY  NUMBER,
 |	x_msg_data		 OUT NOCOPY  VARCHAR2,
 |	x_return_status		 OUT NOCOPY  VARCHAR2);
 |
 | This procedure compares the quantities A and B and returns result in the
 | output variable x_comparison_result. The comparisons are done in base UOM
 | of the UOM class to which the first UOM belongs:
 |-1		if quantity A is less than quantity B (A < B)
 | 0		if quantity A is equal to quantity B (A = B)
 | 1		if quantity A is greater than quantity B (A > B)
 | If the UOMs belong to different classes, then users can specify whether
 | they want to use interclass UOM conversion tolerance, say, T.
 | CASE: p_use_interclass_tolerance = 1
 | ------
 | Q1 > Q2 if (Q1 - Q2) >= T
 | Q1 = Q2 if ABS(Q1 - Q2) < T
 | Q1 < Q2 if (Q1 - Q2 ) <= -T
 +------------------------------------------------------------------------*/

 Procedure compare_quantities(
	p_api_version_number		IN	NUMBER,
	p_init_msg_list			IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
 	p_inventory_item_id		IN	NUMBER,
 	p_organization_id		IN	NUMBER,
	p_lot_control_code		IN	NUMBER,
	p_lot_number			IN	VARCHAR2,
	p_sub_lot_control_code		IN	NUMBER,
 	p_sublot_number			IN	VARCHAR2,
 	p_fisrt_qauantity		IN	NUMBER,
	p_first_uom			IN	VARCHAR2,
	p_second_quantity		IN	NUMBER,
 	p_second_uom			IN	VARCHAR2,
	p_use_interclass_tolerance	IN	VARCHAR2,
	x_comaprison_result		OUT NOCOPY	NUMBER,
 	x_msg_count			OUT NOCOPY	NUMBER,
 	x_msg_data			OUT NOCOPY	VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2) IS

BEGIN

null;

end compare_quantities ;



/*-----------------------------------------------------------------------+
 | Procedure Validate_Quantity(
 |	p_item_id			IN	NUMBER,
 |	p_organization_id		IN	NUMBER,
 |	p_input_quantity		IN	NUMBER,
 |	p_UOM_code			IN	VARCHAR2,
 |	x_output_quantity	 OUT NOCOPY  NUMBER,
 |	x_primary_quantity	 OUT NOCOPY  NUMBER,
 |	x_return_status		 OUT NOCOPY  VARCHAR2);
 |
 | Validates and returns the quantity in this manner (the caller does not need
 | to adjust the result):
 | This routine checks to make sure that the input quantity precision does not exceed
 | the decimal precision. Max Precision is: 10 digits before the decimal point and
 | 9 digits after the decimal point.
 | The routine also makes sure that if the item is serial number controlled, then
 | the quantity in primary UOM is an integer number.
 | The routine also makes sure that if the item's indivisible_flag is set to yes,
 | then the item quantity is an integer in the primary UOM.
 | The routine also checks if the profile, INV:DETECT TRUNCATION, is set to yes
 | the item quantity in primary UOM also obeys max precision and that it is not zero
 | if the input quantity was not zero.
 | The procedure retruns a correct output quantity in the transaction UOM, returns the
 | the primary quantity (in priamry UOM, of course), and returns a status of success,failure
 | or warning.
 |
 +-------------------------------------------------------------------------*/

Procedure Validate_Quantity(
	p_item_id			IN	NUMBER,
	p_organization_id		IN	NUMBER,
	p_input_quantity		IN	NUMBER,
	p_UOM_code			IN	VARCHAR2,
	x_output_quantity		OUT NOCOPY	NUMBER,
	x_primary_quantity		OUT NOCOPY	NUMBER,
	x_return_status			OUT NOCOPY	VARCHAR2) IS

  -- Constants
     c_api_version_number CONSTANT NUMBER  	:= 1.0 ;
     c_api_name 	  CONSTANT VARCHAR2(50):= 'VALIDATE_QUANTITY';

  -- Variables
     l_qty_string		VARCHAR2(50);
     l_decimal_len 		NUMBER; -- number of decimal digits
     l_real_len			NUMBER; -- number of digits before decimal point
     l_total_len		NUMBER; -- total number of digits
     l_uom_class		VARCHAR2(50); -- uom class name
     l_base_uom			VARCHAR2(50); -- base uom in class
     l_primary_uom		VARCHAR2(10); -- primary uom of item
     l_highest_factor		NUMBER; -- biggest factor in class w.r.t uom
     l_lowest_factor		NUMBER; -- lowest factor in class w.r.t. uom
     l_conv_factor		NUMBER;
     l_exp_factor		NUMBER;
     l_decimal_profile		VARCHAR2(240);
     l_serial_control		NUMBER ;
     l_do_conversion		NUMBER := 1;
     l_raise_warning		NUMBER := 0;
     l_indivisible_flag		VARCHAR2(10):= 'N';

BEGIN

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;

 -- now make sure that # of decimal digits does not exceed g_max_decimal_digits
    if ( p_input_quantity <> ROUND(p_input_quantity, g_max_decimal_digits)) then
       fnd_message.set_name('INV', 'MAX_DECIMAL_LENGTH');
       x_output_quantity := ROUND(p_input_quantity, g_max_decimal_digits);
       l_raise_warning := 1 ;
    else
       if (x_output_quantity IS NULL) then
           x_output_quantity := p_input_quantity;
       end if;
    end if;

  -- Now make sure that the length of real part of number doesn't exceed
  -- g_max_real_digits
    if ( trunc(abs(p_input_quantity)) > (POWER(10,g_max_real_digits) - 1) ) then
       fnd_message.set_name('INV', 'MAX_REAL_LENGTH');
       raise fnd_api.g_exc_error;
     end if;

  -- now that in the given UOM the item quantity obeys the decimal precision rules
  -- we can now make sure that when converted to primary qty, decimal precision
  -- rules will still be obeyed.


  -- get the item's primary uom, serial_number_control_code, and the item's indivisible flag

     SELECT primary_uom_code, serial_number_control_code, NVL(indivisible_flag,'N')
     INTO l_primary_uom, l_serial_control, l_indivisible_flag
     FROM mtl_system_items
     WHERE inventory_item_id = p_item_id
     AND organization_id = p_organization_id ;

     -- if the primary uom is same as input uom, then nothing more to validate
     if ( l_primary_uom = p_uom_code) then
       x_primary_quantity := p_input_quantity ;
       l_do_conversion := 0;
     end if;

     if ( l_do_conversion = 1 ) then
       -- get the conversion rate. call inv_convert.uom_convert procedure.
       -- NOTE: this convert routines ROUNDS (not truncates) to precision specified
       l_conv_factor := inv_convert.inv_um_convert(
        item_id		=> p_item_id,
        precision	=> g_max_decimal_digits +2,
        from_quantity   =>  p_input_quantity,
        from_unit       => p_uom_code,
        to_unit         => l_primary_uom,
        from_name	=> null,
        to_name	        => null);

       x_primary_quantity := l_conv_factor;

        -- Begin fix 2256336
       IF x_primary_quantity <> TRUNC(x_primary_quantity) AND l_indivisible_flag = 'Y' THEN
       l_conv_factor := inv_convert.inv_um_convert(
        item_id         => p_item_id,
        precision       => g_max_decimal_digits +2,
        from_quantity   => 1,
        from_unit       => l_primary_uom,
        to_unit         => p_uom_code,
        from_name       => null,
        to_name         => null);
        IF l_conv_factor <> 0 THEN
         x_primary_quantity := p_input_quantity/l_conv_factor ;
        END IF;
       END IF;
        -- End fix 2256336


     -- check if the profile detect_truncation is set. If yes, then make sure primary qty
     -- also does not break decimal precision rules.
     fnd_profile.get('INV_DETECT_TRUNCATION',l_decimal_profile);

     if ( l_decimal_profile = '1' ) then -- '1'= yes, '2' = no

       if ( x_primary_quantity <> ROUND(x_primary_quantity,g_max_decimal_digits) ) then
         fnd_message.set_name('INV', 'PRI_MAX_DECIMAL_LENGTH');
	 raise fnd_api.g_exc_error;
       end if;

    -- Now make sure that the length of real part of number doesn't exceed
    -- g_max_real_digits
       if ( trunc(abs(x_primary_quantity)) > ( POWER(10,g_max_real_digits) - 1) ) then
         fnd_message.set_name('INV', 'PRI_MAX_REAL_LENGTH');
         raise fnd_api.g_exc_error;
       end if;

     -- now check if the quantity in primary UOM is zero
       if ( (x_primary_quantity = 0) AND (p_input_quantity <> 0) ) then
         fnd_message.set_name('INV', 'PRI_QTY_IS_ZERO');
         raise fnd_api.g_exc_error ;
       end if;

     end if;

    end if;

    -- if item has indivisible flag set, then make sure that quantity is integer in
    -- primary UOM

       if (( l_indivisible_flag = 'Y' ) AND ( Round(x_primary_quantity,(g_max_decimal_digits-1)) <> TRUNC(x_primary_quantity)) ) then
         fnd_message.set_name('INV', 'DIVISIBILITY_VIOLATION');
	 raise fnd_api.g_exc_error ;
       end if;

    -- if item is serial number controlled, make the qty in primary UOM is integer
    -- Assumption: Whenever an item is unser serial number control, teh quantity must be
    -- integer in primary uom. Even if specific serial may not be required at the time, the
    -- qty of a serial number should be integer in primary uom.

       if ( (l_serial_control > 1 ) AND ( x_primary_quantity <> TRUNC(x_primary_quantity)) ) then
         fnd_message.set_name('INV', 'SERIAL_QTY_VIOLATION');
	 raise fnd_api.g_exc_error ;
       end if;

       if ( l_raise_warning = 1 ) then
         raise g_inv_warning ;
       end if;

 EXCEPTION
       when fnd_api.g_exc_error then
         x_return_status := fnd_api.g_ret_sts_error ;

       when fnd_api.g_exc_unexpected_error then
         x_return_status := fnd_api.g_ret_sts_unexp_error;

       when g_inv_warning then
	 x_return_status := g_ret_warning ;

       when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         if (fnd_msg_pub.check_msg_level
           (fnd_msg_pub.g_msg_lvl_unexp_error))then
           fnd_msg_pub.add_exc_msg(g_package_name,c_api_name);
         end if;

end validate_quantity ;

/*-----------------------------------------------------------------------+
 | Procedure Validate_Quantity(
 |      p_item_id                       IN      NUMBER,
 |      p_organization_id               IN      NUMBER,
 |      p_input_quantity                IN      NUMBER,
 |      p_UOM_code                      IN      VARCHAR2,
 |      p_max_decimal_digits            IN      NUMBER,
 |      x_output_quantity               OUT NOCOPY      NUMBER,
 |      x_primary_quantity              OUT NOCOPY      NUMBER,
 |      x_return_status                 OUT NOCOPY      VARCHAR2);
 |
 | This procedure overloads validate_quantity with one more parameter p_max_decimal_digits
 | to adjust max precision. If the value of p_max_decimal_digits is null, then default
 | it to g_max_decimal_digits. Other works the same as the above Validate_Quantity procedure.
 +-------------------------------------------------------------------------*/

Procedure Validate_Quantity(
        p_item_id                       IN      NUMBER,
        p_organization_id               IN      NUMBER,
        p_input_quantity                IN      NUMBER,
        p_UOM_code                      IN      VARCHAR2,
        p_max_decimal_digits            IN      NUMBER,
        p_primary_uom                   IN      VARCHAR2,
        p_indivisible_flag              IN      VARCHAR2,
        x_output_quantity               OUT NOCOPY   NUMBER,
        x_primary_quantity              OUT NOCOPY   NUMBER,
        x_return_status                 OUT NOCOPY   VARCHAR2) IS

  -- Constants
     c_api_version_number CONSTANT NUMBER       := 1.0 ;
     c_api_name           CONSTANT VARCHAR2(50):= 'VALIDATE_QUANTITY';

  -- Variables
     l_qty_string               VARCHAR2(50);
     l_decimal_len              NUMBER; -- number of decimal digits
     l_real_len                 NUMBER; -- number of digits before decimal point
     l_total_len                NUMBER; -- total number of digits
     l_uom_class                VARCHAR2(50); -- uom class name
     l_base_uom                 VARCHAR2(50); -- base uom in class
     l_primary_uom              VARCHAR2(10) := p_primary_uom; -- primary uom of item
     l_highest_factor           NUMBER; -- biggest factor in class w.r.t uom
     l_lowest_factor            NUMBER; -- lowest factor in class w.r.t. uom
     l_conv_factor              NUMBER;
     l_exp_factor               NUMBER;
     l_decimal_profile          VARCHAR2(240);
     l_serial_control           NUMBER := 1;
     l_do_conversion            NUMBER := 1;
     l_raise_warning            NUMBER := 0;
     l_indivisible_flag         VARCHAR2(10):= NVL(p_indivisible_flag, 'N');
     l_max_decimal_digits       NUMBER := p_max_decimal_digits;

BEGIN

  -- initialize return status to success
     x_return_status := fnd_api.g_ret_sts_success;

  -- put the default = g_max_decimal_digits if l_max_decimal_digits is null
     if (l_max_decimal_digits IS NULL) then
         l_max_decimal_digits := g_max_decimal_digits;
     end if;

  -- now make sure that # of decimal digits does not exceed l_max_decimal_digits
    if ( p_input_quantity <> ROUND(p_input_quantity, l_max_decimal_digits)) then
       fnd_message.set_name('INV', 'MAX_DECIMAL_LENGTH');
       x_output_quantity := ROUND(p_input_quantity, l_max_decimal_digits);
       l_raise_warning := 1 ;
     else
       if (x_output_quantity IS NULL) then
           x_output_quantity := p_input_quantity;
       end if;
     end if;

  -- Now make sure that the length of real part of number doesn't exceed
  -- g_max_real_digits
    if ( trunc(abs(p_input_quantity)) > (POWER(10,g_max_real_digits) - 1) ) then
       fnd_message.set_name('INV', 'MAX_REAL_LENGTH');
       raise fnd_api.g_exc_error;
     end if;

  -- now that in the given UOM the item quantity obeys the decimal precision rules
  -- we can now make sure that when converted to primary qty, decimal precision
  -- rules will still be obeyed.


  -- get the item's primary uom, serial_number_control_code, and the item's indivisible flag
  IF (p_item_id IS NOT NULL) then
     SELECT primary_uom_code, serial_number_control_code, NVL(indivisible_flag,'N')
     INTO l_primary_uom, l_serial_control, l_indivisible_flag
     FROM mtl_system_items
     WHERE inventory_item_id = p_item_id
     AND organization_id = p_organization_id ;
  END IF;

     -- if the primary uom is same as input uom, then nothing more to validate
     if ( l_primary_uom = p_uom_code) then
       x_primary_quantity := p_input_quantity ;
       l_do_conversion := 0;
     end if;

     if ( l_do_conversion = 1 ) then
       -- get the conversion rate. call inv_convert.uom_convert procedure.
       -- NOTE: this convert routines ROUNDS (not truncates) to precision specified
       l_conv_factor := inv_convert.inv_um_convert(
        item_id         => p_item_id,
        precision       => l_max_decimal_digits +2,
        from_quantity   => p_input_quantity,
        from_unit       => p_uom_code,
        to_unit         => l_primary_uom,
        from_name       => null,
        to_name         => null);

       x_primary_quantity := l_conv_factor ;


     -- check if the profile detect_truncation is set. If yes, then make sure primary qty
     -- also does not break decimal precision rules.
     fnd_profile.get('INV_DETECT_TRUNCATION',l_decimal_profile);

     if ( l_decimal_profile = '1' ) then -- '1'= yes, '2' = no

       if ( x_primary_quantity <> ROUND(x_primary_quantity,l_max_decimal_digits) ) then
         fnd_message.set_name('INV', 'PRI_MAX_DECIMAL_LENGTH');
         raise fnd_api.g_exc_error;
       end if;

    -- Now make sure that the length of real part of number doesn't exceed
    -- g_max_real_digits
       if ( trunc(abs(x_primary_quantity)) > ( POWER(10,g_max_real_digits) - 1) ) then
         fnd_message.set_name('INV', 'PRI_MAX_REAL_LENGTH');
         raise fnd_api.g_exc_error;
       end if;

     -- now check if the quantity in primary UOM is zero
       if ( (x_primary_quantity = 0) AND (p_input_quantity <> 0) ) then
         fnd_message.set_name('INV', 'PRI_QTY_IS_ZERO');
         raise fnd_api.g_exc_error ;
       end if;

     end if;

    end if;

    -- if item has indivisible flag set, then make sure that quantity is integer in
    -- primary UOM

       if (( l_indivisible_flag = 'Y' ) AND ( Round(x_primary_quantity,(l_max_decimal_digits-1)) <> TRUNC(x_primary_quantity)) ) then
         fnd_message.set_name('INV', 'DIVISIBILITY_VIOLATION');
         raise fnd_api.g_exc_error ;
       end if;

    -- if item is serial number controlled, make the qty in primary UOM is integer
    -- Assumption: Whenever an item is unser serial number control, teh quantity must be
    -- integer in primary uom. Even if specific serial may not be required at the time, the
    -- qty of a serial number should be integer in primary uom.

       if ( (l_serial_control > 1 ) AND ( x_primary_quantity <> TRUNC(x_primary_quantity)) ) then
         fnd_message.set_name('INV', 'SERIAL_QTY_VIOLATION');
         raise fnd_api.g_exc_error ;
       end if;

       if ( l_raise_warning = 1 ) then
         raise g_inv_warning ;
       end if;

 EXCEPTION
       when fnd_api.g_exc_error then
         x_return_status := fnd_api.g_ret_sts_error ;

       when fnd_api.g_exc_unexpected_error then
         x_return_status := fnd_api.g_ret_sts_unexp_error;

       when g_inv_warning then
         x_return_status := g_ret_warning ;

       when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         if (fnd_msg_pub.check_msg_level
           (fnd_msg_pub.g_msg_lvl_unexp_error))then
           fnd_msg_pub.add_exc_msg(g_package_name,c_api_name);
         end if;

end Validate_Quantity;



function get_primary_quantity(
		p_organization_id	IN	NUMBER,
		p_inventory_item_id	IN	NUMBER,
		p_uom			IN	VARCHAR2,
		p_quantity		IN	NUMBER) return number IS

 -- local variables
  l_primary_uom		VARCHAR2(10);
BEGIN
     -- if input qty is null, assume 0, in which case we return 0 as converted
     -- qty also
     if ( ( p_quantity IS NULL ) OR (p_quantity = 0) ) then
       return 0;
     end if;

     SELECT primary_uom_code
     INTO l_primary_uom
     FROM mtl_system_items
     WHERE inventory_item_id = p_inventory_item_id
     AND organization_id = p_organization_id ;

return( inv_convert.inv_um_convert(
      item_id		=> p_inventory_item_id,
      precision		=> 9,
      from_quantity     => p_quantity,
      from_unit         => p_uom,
      to_unit           => l_primary_uom,
      from_name		=> null,
      to_name	        => null) );
end get_primary_quantity ;


end INV_DECIMALS_PUB;

/
