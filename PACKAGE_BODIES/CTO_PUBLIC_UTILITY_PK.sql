--------------------------------------------------------
--  DDL for Package Body CTO_PUBLIC_UTILITY_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_PUBLIC_UTILITY_PK" as
/* $Header: CTOPUTLB.pls 115.1 2003/03/28 01:56:24 sbhaskar noship $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
| FILE NAME   : CTOPUTLS.pls
|
| DESCRIPTION : This is a PUBLIC package used primarily for having APIs which are
|               called from other products. We decided to keep these APIs in
|               seperate file to reduce dependencies.
|
| HISTORY     : Created on 23-DEC-2002  by Shashi Bhaskaran
|
+-----------------------------------------------------------------------------*/

/*************************************************************************************

 Bugfix 2695239

 Input Parameters
 ----------------
 p_config_line_id 	: Line Id of the configuration
 p_model_line_id    	: Line Id of the ATO model
 p_quantity       	: Quantity for which total selling price is to be calculated


 Output Parameters
 -----------------
 x_unit_selling_price 	: Unit Selling Price of the model. Calculated.
 x_qty_selling_price 	: Total Selling Price of the model for quantity 'p_quantity'. Calculated.
 x_currency_code 	: Currencty Code of the order line.

 x_return_status 	: Return status of the API. Returns FND_API.G_RET_STS_ERROR if others exception is raised.
                   	  Otherwise G_RET_STS_SUCCESS
 x_error_code    	: Return error code. 0 if success. 1 if error.

 Note:
  In case of hard-error, x_error_code will be set to 1
			and x_return_status will be set to FND_API.G_RET_STS_ERROR
  In case of soft-error, x_error_code will be set to 1
			but x_return_status will be G_RET_STS_SUCCESS

*************************************************************************************/


procedure get_selling_price (
		  p_config_line_id	IN  NUMBER
		, p_model_line_id	IN  NUMBER DEFAULT NULL
		, p_quantity		IN  NUMBER DEFAULT 0
		, x_unit_selling_price	OUT NOCOPY NUMBER
		, x_qty_selling_price	OUT NOCOPY NUMBER
		, x_currency_code       OUT NOCOPY VARCHAR2
   		, x_return_status	OUT NOCOPY VARCHAR2
   		, x_error_code		OUT NOCOPY NUMBER)
is
	config_ato_line_id	NUMBER;
	config_ordered_qty	NUMBER;
begin

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_error_code := 0;

	x_unit_selling_price := 0;
	x_qty_selling_price  := 0;

	if p_config_line_id is not null then
		select ato_line_id, ordered_quantity
		into   config_ato_line_id, config_ordered_qty
		from   oe_order_lines_all
		where  line_id = p_config_line_id;
	end if;

	if config_ordered_qty = 0 then
		x_unit_selling_price := 0;
		x_qty_selling_price := 0;
		return;
	end if;
	--
	-- If config_line_id  is passed, then, we get the corresponding ATO line id and sum up the
	-- selling price. Basically, we ignore the p_model_line_id value.
	--

	-- Bug 2862057 : Modified the logic to determine the right unit_selling_price.

	select nvl( sum(l.UNIT_SELLING_PRICE * nvl(ORDERED_QUANTITY,0)) / config_ordered_qty , 0),
	       nvl((sum(l.UNIT_SELLING_PRICE * nvl(ORDERED_QUANTITY,0)) / config_ordered_qty) * p_quantity, 0),
	       max(h.TRANSACTIONAL_CURR_CODE)
	into   x_unit_selling_price,
	       x_qty_selling_price,
	       x_currency_code
	from   oe_order_lines_all l,
	       oe_order_headers_all h
	where  l.ato_line_id = decode(p_config_line_id, null, p_model_line_id, config_ato_line_id)
	and    l.header_id = h.header_id;


exception
	when no_data_found then
		-- We will not set the return_status since it is a soft-error.
		x_error_code := 1;	-- Set the error code

	when others then
		-- We will set the return_status here since it will be a hard-error.
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_error_code := 1;	-- Set the error code
end;

END CTO_PUBLIC_UTILITY_PK;

/
