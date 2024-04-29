--------------------------------------------------------
--  DDL for Package CTO_PUBLIC_UTILITY_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_PUBLIC_UTILITY_PK" AUTHID CURRENT_USER as
/* $Header: CTOPUTLS.pls 120.0 2005/05/25 04:28:10 appldev noship $*/

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
   		, x_error_code		OUT NOCOPY NUMBER);

END CTO_PUBLIC_UTILITY_PK;

 

/
