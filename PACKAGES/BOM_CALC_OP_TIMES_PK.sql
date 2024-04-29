--------------------------------------------------------
--  DDL for Package BOM_CALC_OP_TIMES_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CALC_OP_TIMES_PK" AUTHID CURRENT_USER AS
/* $Header: BOMOPTMS.pls 120.0 2005/05/25 05:08:05 appldev noship $ */

	PROCEDURE calculate_operation_times(
				arg_org_id				IN NUMBER,
				arg_routing_sequence_id IN NUMBER );

END BOM_CALC_OP_TIMES_PK;
 

/
