--------------------------------------------------------
--  DDL for Package QP_CLEANUP_ADJUSTMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CLEANUP_ADJUSTMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVCLNS.pls 120.0.12010000.2 2009/08/19 11:26:12 hmohamme ship $ */

G_BINARY_LIMIT CONSTANT NUMBER :=2147483648; --8744755

FUNCTION get_sum_operand(p_header_id IN NUMBER) RETURN NUMBER;

PROCEDURE fetch_adjustments(p_view_code IN VARCHAR2,
                                p_event_code IN VARCHAR2,
				p_calculate_flag IN VARCHAR2,
                                p_rounding_flag IN VARCHAR2,
                                p_request_type_code IN VARCHAR2,
				x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2);


--PROCEDURE calculation_cleanup_adj(p_view_code IN VARCHAR2,
--                                      p_request_type_code IN VARCHAR2);

--PROCEDURE cleanup_adjustments(p_view_code IN VARCHAR2,
--                                p_cleanup_flag IN VARCHAR2);

--added by yangli for Java Engine
PROCEDURE cleanup_adjustments(p_view_code IN VARCHAR2,
                                p_request_type_code IN VARCHAR2,
                                p_cleanup_flag IN VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2);

PROCEDURE Populate_Price_Adj_ID(x_return_status OUT NOCOPY VARCHAR2,
                                x_return_status_text OUT NOCOPY VARCHAR2);
--added by yangli for Java Engine

END QP_CLEANUP_ADJUSTMENTS_PVT;

/
