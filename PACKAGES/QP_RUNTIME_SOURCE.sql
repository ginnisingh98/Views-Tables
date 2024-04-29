--------------------------------------------------------
--  DDL for Package QP_RUNTIME_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_RUNTIME_SOURCE" AUTHID CURRENT_USER AS
/* $Header: QPXRSRCS.pls 120.0 2005/06/01 23:56:23 appldev noship $ */

-- Global constant holding the package name
G_PKG_NAME     CONSTANT VARCHAR2(30) := 'QP_RUNTIME_SOURCE';

TYPE ACCUM_RECORD_TYPE IS RECORD (
     p_request_type_code     VARCHAR2(240),
     context                 VARCHAR2(30),
     attribute               VARCHAR2(240)
);

TYPE accum_req_line_attrs_rec IS RECORD (
  line_index       NUMBER,
  attribute_type   VARCHAR2(30),
  context          VARCHAR2(30),
  attribute        VARCHAR2(30),
  value            VARCHAR2(240),
  grouping_no      NUMBER
);

TYPE accum_req_line_attrs_tbl IS TABLE OF accum_req_line_attrs_rec
  INDEX BY BINARY_INTEGER;

FUNCTION Get_numeric_attribute_value(
     p_list_line_id          IN NUMBER,
     p_list_line_no          IN VARCHAR2,
     p_order_header_id       IN NUMBER,
     p_order_line_id         IN NUMBER,
     p_price_effective_date  IN DATE,
     p_req_line_attrs_tbl    IN ACCUM_REQ_LINE_ATTRS_TBL,
     p_accum_rec             IN ACCUM_RECORD_TYPE
) RETURN NUMBER;

END QP_RUNTIME_SOURCE;

 

/
