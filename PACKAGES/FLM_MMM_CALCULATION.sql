--------------------------------------------------------
--  DDL for Package FLM_MMM_CALCULATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_MMM_CALCULATION" AUTHID CURRENT_USER AS
/* $Header: FLMMMMCS.pls 120.0.12000000.1 2007/01/19 09:30:36 appldev ship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : FLMMMMCS.pls                                               |
| DESCRIPTION  : This package contains functions used to calculate values   |
|                for the New Mixed Model Map Form		            |
| Coders       : Liye Ma 	(01/09/02 - 03/30/02)                       |
|    		 Hadi Wenas 	(04/01/02 - present )                       |
+===========================================================================*/

-- Constants
C_DEMAND_TYPE_FORECAST	CONSTANT NUMBER	:= 1;
C_DEMAND_TYPE_MDS	CONSTANT NUMBER	:= 2;
C_DEMAND_TYPE_MPS	CONSTANT NUMBER	:= 3;
C_DEMAND_TYPE_AP	CONSTANT NUMBER	:= 4;
C_DEMAND_TYPE_SO	CONSTANT NUMBER := 5;
C_DEMAND_TYPE_PO	CONSTANT NUMBER := 6;

C_REPLAN_FLAG_YES	CONSTANT VARCHAR2(5) := 'YES';
C_REPLAN_FLAG_NO	CONSTANT VARCHAR2(5) := 'NO';

C_ERROR_CODE_SUCCESS	CONSTANT NUMBER := 0;
C_ERROR_CODE_FAILURE	CONSTANT NUMBER := 1;

C_BUCKET_DAYS		CONSTANT NUMBER := 1;
C_BUCKET_WEEKS		CONSTANT NUMBER := 2;
C_BUCKET_PERIODS	CONSTANT NUMBER := 3;

C_CALC_OPTION_NO_IPK		CONSTANT NUMBER	:= 1;
C_CALC_OPTION_ONE_RESOURCE	CONSTANT NUMBER	:= 2;
C_CALC_OPTION_RES_ASSIGNED	CONSTANT NUMBER	:= 3;
C_CALC_OPTION_IPK_ASSIGNED	CONSTANT NUMBER	:= 4;

-- Types
TYPE t_demand_rec IS RECORD (
	assembly_item_id	NUMBER,
	line_id			NUMBER,
	average_daily_demand	NUMBER);

TYPE t_demand_table IS TABLE OF t_demand_rec
	INDEX BY BINARY_INTEGER;

-- Public Functions
FUNCTION get_offset_date (i_organization_id	IN NUMBER,
			  i_start_date          IN DATE,
                	  i_bucket_type         IN NUMBER
	) RETURN DATE;

-- Public Procedures
PROCEDURE calculate(
	i_plan_id			IN	NUMBER,
	i_organization_id		IN	NUMBER,
	i_calculation_operation_type	IN	NUMBER,
	i_product_family_id		IN	NUMBER,
	i_line_id			IN	NUMBER,
	i_demand_type			IN	NUMBER,
	i_demand_code			IN	VARCHAR2,
	i_start_date			IN	DATE,
	i_end_date			IN	DATE,
	i_demand_days			IN	NUMBER,
	i_hours_per_day			IN	NUMBER,
	i_boost_percent			IN	NUMBER,
	i_calculation_option		IN	NUMBER,
	i_calendar_code			IN	VARCHAR2,
    	i_exception_set_id  		IN	NUMBER,
    	i_last_calendar_date 		IN	DATE,
	i_replan_flag			IN	VARCHAR2,
	o_error_code			OUT NOCOPY	NUMBER,
	o_error_msg			OUT NOCOPY	VARCHAR2);

PROCEDURE recalculate(
	i_plan_id			IN	NUMBER,
	i_organization_id		IN	NUMBER,
	i_calculation_operation_type	IN	NUMBER,
	i_calculation_option		IN	NUMBER,
	i_standard_operation_id		IN	NUMBER,
	o_error_code			OUT NOCOPY	NUMBER,
	o_error_msg			OUT NOCOPY	VARCHAR2);

PROCEDURE update_assigned_with_needed(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_line_id		IN	NUMBER,
	i_standard_operation_id	IN	NUMBER,
	i_resource_id		IN	NUMBER,
	i_calc_op_type		IN	NUMBER,
	o_error_code		OUT NOCOPY	NUMBER);

PROCEDURE save(
	i_plan_id		IN	NUMBER,
	i_organization_id	IN	NUMBER,
	i_operation_type	IN	NUMBER);

END flm_mmm_calculation;

 

/
