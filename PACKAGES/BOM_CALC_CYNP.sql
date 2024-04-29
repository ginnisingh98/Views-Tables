--------------------------------------------------------
--  DDL for Package BOM_CALC_CYNP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CALC_CYNP" AUTHID CURRENT_USER as
/* $Header: bomcynps.pls 115.8 2002/11/29 14:18:09 djebar ship $ */

procedure calc_cynp (
	p_routing_sequence_id	in	number,
	p_operation_type	in	varchar2,
	p_update_events		in	number
);

procedure calc_cynp_rbo ( -- Added for RBO support for NPP; Bug: 2689249
	p_routing_sequence_id	in	number,
	p_operation_type	in	varchar2,
	p_update_events		in	number,
      	x_token_tbl		OUT NOCOPY Error_Handler.Token_Tbl_Type,
      	x_err_msg		OUT NOCOPY VARCHAR2,
      	x_return_status		OUT NOCOPY VARCHAR2
);

END BOM_CALC_CYNP;

 

/
