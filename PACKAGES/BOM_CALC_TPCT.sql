--------------------------------------------------------
--  DDL for Package BOM_CALC_TPCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CALC_TPCT" AUTHID CURRENT_USER as
/* $Header: bomtpcts.pls 115.2 99/07/16 05:49:18 porting ship $ */

function calc_tpct (
	p_routing_sequence_id	in	number,
	p_operation_type	in	varchar2
) return number;

procedure calculate_tpct(
	p_routing_sequence_id   in      number,
	p_operation_type        in      varchar2
);
END BOM_CALC_TPCT;

 

/
