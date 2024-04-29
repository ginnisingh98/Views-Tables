--------------------------------------------------------
--  DDL for Package INV_DECIMALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DECIMALS_PUB" AUTHID CURRENT_USER AS
/* $Header: INVDECPS.pls 120.1 2005/06/09 17:55:36 appldev  $ */


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
 |x_resultant_to_quantity	OUT	NUMBER, -- calculated qty in second UOM
 |x_comparison			OUT	NUMBER,--Possible values are 1,0,-1,-99
 |x_msg_count			OUT	NUMBER, -- number of messages
 |x_msg_data			OUT	VARCHAR2, -- populated,if msg count = 1
 |x_return_status		OUT	VARCHAR2) -- return status
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
		x_resultant_to_quantity	OUT  NOCOPY	NUMBER,
		x_valid_conversion	OUT  NOCOPY	NUMBER,
 		x_msg_count		OUT  NOCOPY	NUMBER,
 		x_msg_data		OUT  NOCOPY	VARCHAR2,
		x_return_status		OUT  NOCOPY	VARCHAR2);


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
 |x_msg_count			OUT	NUMBER,
 |x_msg_data			OUT	VARCHAR2,
 |x_return_status		OUT	VARCHAR2)
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
 		x_msg_count		OUT	NOCOPY NUMBER,
 		x_msg_data		OUT	NOCOPY VARCHAR2,
		x_return_status		OUT	NOCOPY VARCHAR2) return NUMBER ;


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
 | x_uom_class		OUT	VARCHAR2,
 | x_base_uom		OUT	VARCHAR2,
 | x_msg_count		OUT	NUMBER,
 | x_msg_data		OUT	VARCHAR2,
 | x_return_status	OUT	VARCHAR2);
 +--------------------------------------------------------------------------*/


Procedure get_uom_properties(
  p_api_version_number	IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_uom_code		IN	VARCHAR2,
  x_uom_class		OUT NOCOPY	VARCHAR2,
  x_base_uom		OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  x_return_status	OUT NOCOPY	VARCHAR2);


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
 |	x_comaprison_result		OUT	NUMBER,
 |	x_msg_count			OUT	NUMBER,
 |	x_msg_data			OUT	VARCHAR2,
 |	x_return_status			OUT	VARCHAR2);
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
	x_return_status			OUT NOCOPY	VARCHAR2);


/*-----------------------------------------------------------------------+
 | Procedure Validate_Quantity(
 |	p_item_id			IN	NUMBER,
 |	p_organization_id		IN	NUMBER,
 |	p_input_quantity		IN	NUMBER,
 |	p_UOM_code			IN	VARCHAR2,
 |	x_output_quantity		OUT	NUMBER,
 |	x_primary_quantity		OUT	NUMBER,
 |	x_return_status			OUT	VARCHAR2);
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
 +-------------------------------------------------------------------------*/

Procedure Validate_Quantity(
	p_item_id			IN	NUMBER,
 	p_organization_id		IN	NUMBER,
	p_input_quantity		IN	NUMBER,
	p_UOM_code			IN	VARCHAR2,
  	x_output_quantity		OUT NOCOPY	NUMBER,
	x_primary_quantity		OUT NOCOPY	NUMBER,
	x_return_status			OUT NOCOPY	VARCHAR2);

/*------------------------------------------------------------------------+
 | Procedure Validate_Quantity(
 |      p_item_id                       IN      NUMBER,
 |      p_organization_id               IN      NUMBER,
 |      p_input_quantity                IN      NUMBER,
 |      p_UOM_code                      IN      VARCHAR2,
 |      p_max_decimal_digits            IN      NUMBER DEFAULT NULL,
 |      x_output_quantity               OUT     NUMBER,
 |      x_primary_quantity              OUT     NUMBER,
 |      x_return_status                 OUT     VARCHAR2);
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
        x_return_status                 OUT NOCOPY   VARCHAR2);


function get_primary_quantity(
		p_organization_id	IN	NUMBER,
		p_inventory_item_id	IN	NUMBER,
		p_uom			IN	VARCHAR2,
		p_quantity		IN	NUMBER) return number;



end INV_DECIMALS_PUB;

 

/
