--------------------------------------------------------
--  DDL for Package QP_TM_RUNTIME_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_TM_RUNTIME_SOURCE" AUTHID CURRENT_USER AS
/* $Header: QPXTMRSS.pls 120.2 2005/09/30 13:50:30 gtippire noship $ */

-- Global constant holding the package name
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'QP_TM_RUNTIME_SOURCE';

TYPE accum_req_line_attrs_rec IS RECORD (
  line_index       NUMBER,
  attribute_type   VARCHAR2(30),
  context          VARCHAR2(30),
  attribute        VARCHAR2(30),
  value            VARCHAR2(240),
  grouping_no      NUMBER
);

FUNCTION Get_numeric_attribute_value(
     p_list_line_id          IN NUMBER,
     p_list_line_no          IN VARCHAR2,
     p_order_header_id       IN NUMBER,
     p_order_line_id         IN NUMBER,
     p_price_effective_date  IN DATE,
     p_req_line_attrs_tbl    IN QP_RUNTIME_SOURCE.ACCUM_REQ_LINE_ATTRS_TBL,
     p_accum_rec             IN QP_RUNTIME_SOURCE.ACCUM_RECORD_TYPE
) RETURN NUMBER;

END QP_TM_RUNTIME_SOURCE;

 

/
