--------------------------------------------------------
--  DDL for Package Body QP_TM_RUNTIME_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_TM_RUNTIME_SOURCE" AS
/* $Header: QPXTMRSB.pls 120.2 2005/09/30 13:55:30 gtippire noship $ */


FUNCTION Get_numeric_attribute_value(
     p_list_line_id          IN NUMBER,
     p_list_line_no          IN VARCHAR2,
     p_order_header_id       IN NUMBER,
     p_order_line_id         IN NUMBER,
     p_price_effective_date  IN DATE,
     p_req_line_attrs_tbl    IN QP_RUNTIME_SOURCE.ACCUM_REQ_LINE_ATTRS_TBL,
     p_accum_rec             IN QP_RUNTIME_SOURCE.ACCUM_RECORD_TYPE
) RETURN NUMBER
IS
 	l_volume	NUMBER;
BEGIN
	l_volume := Ozf_Volume_Calculation_Pub.Get_Numeric_Attribute_Value
                         (p_list_line_id         => p_list_line_id
                         ,p_list_line_no         => p_list_line_no
                         ,p_order_header_id      => p_order_header_id
                         ,p_order_line_id        => p_order_line_id
                         ,p_price_effective_date => p_price_effective_date
                         ,p_req_line_attrs_tbl   => p_req_line_attrs_tbl
                         ,p_accum_rec            => p_accum_rec);

	RETURN l_volume;
END;

END QP_TM_RUNTIME_SOURCE;

/
