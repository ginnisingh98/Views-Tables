--------------------------------------------------------
--  DDL for Package QP_BULK_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BULK_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: QPXBLVAS.pls 120.3.12010000.1 2008/07/28 11:50:38 appldev ship $ */

   TYPE num_type      IS TABLE OF Number         INDEX BY BINARY_INTEGER;
   TYPE char_type     IS TABLE OF Varchar2(1)    INDEX BY BINARY_INTEGER;
   TYPE char30_type   IS TABLE OF Varchar2(30)   INDEX BY BINARY_INTEGER;
   TYPE char2_type    IS TABLE OF Varchar2(2)    INDEX BY BINARY_INTEGER;
   TYPE char240_type  IS TABLE OF Varchar2(240)  INDEX BY BINARY_INTEGER;
   TYPE char4_type    IS TABLE OF Varchar2(4)    INDEX BY BINARY_INTEGER;
   TYPE char3_type    IS TABLE OF Varchar2(3)    INDEX BY BINARY_INTEGER;
   TYPE char50_type   IS TABLE OF Varchar2(50)   INDEX BY BINARY_INTEGER;
   TYPE char2000_type IS TABLE OF Varchar2(2000) INDEX BY BINARY_INTEGER;
   TYPE char10_type   IS TABLE OF Varchar2(10)   INDEX BY BINARY_INTEGER;
   TYPE real_type     IS TABLE OF Number(32,10)  INDEX BY BINARY_INTEGER;
   TYPE date_type     IS TABLE OF Date           INDEX BY BINARY_INTEGER;

TYPE DUPL_LINE_TYPE IS RECORD
(a_orig_sys_line_ref char50_type,
    b_orig_sys_line_ref char50_type,
    orig_sys_header_ref char50_type,
    a_product_uom_code char3_type,
    b_product_uom_code char3_type,
    a_pricing_attribute_context char30_type,
    b_pricing_attribute_context char30_type,
    a_pricing_attribute char30_type,
    b_pricing_attribute char30_type,
    a_pricing_attr_value_from char240_type,
    a_pricing_attr_value_to char240_type,
    b_pricing_attr_value_from char240_type,
    b_pricing_attr_value_to char240_type,
    a_comparison_operator_code char30_type,
    b_comparison_operator_code char30_type
    -- Bug 5092813 RAVI
    ,b_list_line_id num_type
    -- Bug 5234939 RAVI START
    ,a_orig_sys_pricing_attr_ref char50_type
    ,b_orig_sys_pricing_attr_ref char50_type);

TYPE PA_LINE_TYPE IS RECORD
(   orig_sys_pricing_attr_ref char50_type,
    orig_sys_line_ref         char50_type,
    pricing_attribute_context char30_type,
    pricing_attribute         char30_type,
    pricing_attr_value_from   char240_type,
    pricing_attr_value_to     char240_type,
    comparison_operator_code  char30_type
);
-- Bug 5234939 RAVI END

g_context     VARCHAR2(240);
g_attribute1  VARCHAR2(240);
g_attribute2  VARCHAR2(240);
g_attribute3  VARCHAR2(240);
g_attribute4  VARCHAR2(240);
g_attribute5  VARCHAR2(240);
g_attribute6  VARCHAR2(240);
g_attribute7  VARCHAR2(240);
g_attribute8  VARCHAR2(240);
g_attribute9  VARCHAR2(240);
g_attribute10 VARCHAR2(240);
g_attribute11 VARCHAR2(240);
g_attribute12 VARCHAR2(240);
g_attribute13 VARCHAR2(240);
g_attribute14 VARCHAR2(240);
g_attribute15 VARCHAR2(240);

g_context_name     VARCHAR2(240);
g_attribute1_name  VARCHAR2(240);
g_attribute2_name  VARCHAR2(240);
g_attribute3_name  VARCHAR2(240);
g_attribute4_name  VARCHAR2(240);
g_attribute5_name  VARCHAR2(240);
g_attribute6_name  VARCHAR2(240);
g_attribute7_name  VARCHAR2(240);
g_attribute8_name  VARCHAR2(240);
g_attribute9_name  VARCHAR2(240);
g_attribute10_name VARCHAR2(240);
g_attribute11_name VARCHAR2(240);
g_attribute12_name VARCHAR2(240);
g_attribute13_name VARCHAR2(240);
g_attribute14_name VARCHAR2(240);
g_attribute15_name VARCHAR2(240);

g_orig_sys_header_ref VARCHAR2(50);
g_orig_sys_line_ref VARCHAR2(50);

PROCEDURE DUP_LINE_CHECK
          (p_request_id NUMBER);

PROCEDURE ENTITY_HEADER(p_header_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.HEADER_REC_TYPE);

PROCEDURE ENTITY_LINE(P_LINE_REC IN OUT NOCOPY QP_BULK_LOADER_PUB.LINE_REC_TYPE);

PROCEDURE ENTITY_QUALIFIER(p_qualifier_rec IN OUT NOCOPY QP_BULK_LOADER_PUB.qualifier_rec_type);

PROCEDURE ENTITY_PRICING_ATTR(p_pricing_attr_rec IN OUT  NOCOPY QP_BULK_LOADER_PUB.pricing_attr_rec_type);

PROCEDURE ATTRIBUTE_HEADER(p_request_id NUMBER);

PROCEDURE ATTRIBUTE_QUALIFIER(p_request_id NUMBER);

PROCEDURE ATTRIBUTE_LINE(p_request_id NUMBER);

PROCEDURE MARK_ERRORED_INTERFACE_RECORD
(p_table_type  VARCHAR2
 ,p_request_id  NUMBER);

-- Bug# 5412045
-- Shell for qp_validate.product_uom to return Varchar2 ('TRUE', 'FALSE')
-- qp_validate.product_uom returns a boolean.
FUNCTION Product_Uom ( p_product_uom_code IN VARCHAR2,
                       p_category_id IN NUMBER,
                       p_list_header_id IN NUMBER ) RETURN VARCHAR2;

END QP_BULK_VALIDATE;

/
