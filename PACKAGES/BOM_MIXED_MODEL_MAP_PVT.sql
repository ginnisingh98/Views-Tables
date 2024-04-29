--------------------------------------------------------
--  DDL for Package BOM_MIXED_MODEL_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_MIXED_MODEL_MAP_PVT" AUTHID CURRENT_USER AS
/* $Header: BOMMMMCS.pls 115.7 2002/11/27 10:11:51 nrajpal ship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMMMMCS.pls                                               |
| DESCRIPTION  : This package contains functions used to calculate values   |
|                for the Mixed Model Map form		                    |
| History:                                                                  |
|    08/09/97   Julie Maeyama   Creation				    |
+===========================================================================*/
PROCEDURE GetProcessLineOp (
    p_mmm_id            NUMBER,
    p_org_id            NUMBER,
    p_line_id           NUMBER,
    p_family_item_id    NUMBER,
    p_operation_type    NUMBER,
    p_order             NUMBER,
    p_user_id           NUMBER,
    x_err_text     OUT  NOCOPY	VARCHAR2
);


PROCEDURE GetDetails (
    p_mmm_id		NUMBER,
    p_line_id		NUMBER,
    p_family_item_id	NUMBER,
    p_org_id		NUMBER,
    p_user_id		NUMBER,
    p_start_date	DATE,
    p_end_date		DATE,
    p_demand_type	NUMBER,
    p_demand_code	VARCHAR2,
    p_hours_per_day	NUMBER,
    p_demand_days	NUMBER,
    p_boost_percent	NUMBER,
    p_operation_type	NUMBER,
    p_time_uom		NUMBER,
    p_calendar_code	VARCHAR2,
    p_exception_set_id  NUMBER,
    p_last_calendar_date DATE,
    x_err_text     OUT  NOCOPY	VARCHAR2);


PROCEDURE GetCells (
    p_mmm_id            NUMBER,
    p_group_number      NUMBER,
    p_line_id		NUMBER,
    p_family_item_id    NUMBER,
    p_org_id            NUMBER,
    p_user_id           NUMBER,
    p_start_date        DATE,
    p_end_date          DATE,
    p_demand_type       NUMBER,
    p_demand_code       VARCHAR2,
    p_process_line_op	NUMBER,
    p_hours_per_day     NUMBER,
    p_demand_days       NUMBER,
    p_boost_percent     NUMBER,
    p_operation_type    NUMBER,
    p_time_type         NUMBER,
    p_ipk_value         NUMBER,
    p_time_uom          NUMBER,
    p_calendar_code	VARCHAR2,
    p_exception_set_id  NUMBER,
    p_last_calendar_date DATE,
    p_op_code1          VARCHAR2,
    p_op_code2          VARCHAR2,
    p_op_code3          VARCHAR2,
    p_op_code4          VARCHAR2,
    p_op_code5          VARCHAR2,
    x_line_takt    OUT  NOCOPY	NUMBER,
    x_err_text     OUT  NOCOPY	VARCHAR2)
;

PROCEDURE GetDemand (
        p_org_id        NUMBER,
        p_demand_type   NUMBER,
        p_line_id       NUMBER,
        p_assembly_item_id      NUMBER,
        p_calendar_code VARCHAR2,
        p_start_date    DATE,
        p_end_date      DATE,
        p_last_calendar_date    DATE,
        p_exception_set_id      NUMBER,
        p_demand_code   VARCHAR2,
        o_demand        OUT NOCOPY	NUMBER,
        o_stmt_num      OUT NOCOPY	NUMBER);

END BOM_Mixed_Model_Map_PVT;

 

/
