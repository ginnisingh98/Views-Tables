--------------------------------------------------------
--  DDL for Package QP_LIMIT_BALANCE_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LIMIT_BALANCE_CHECK_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVLCKS.pls 120.0.12010000.1 2008/07/28 11:58:51 appldev ship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME		 CONSTANT  VARCHAR2(30) := 'QP_LIMIT_BALANCE_CHECK_PVT';

--Max no.of times to recheck balance in one call of Process Limits
G_MAX_LOOP_COUNT         CONSTANT NUMBER := 50;

--No of times balance has been rechecked in one call of Process Limits
G_LOOP_COUNT             NUMBER;

TYPE Limit_Balance_Line_Rec IS RECORD
(  limit_id          NUMBER,
   limit_balance_id  NUMBER,
   line_index        NUMBER,
   list_header_id    NUMBER,
   list_line_id      NUMBER,
   basis             VARCHAR2(30),
   wanted_amount     NUMBER,
   available_amount  NUMBER,
   available_percent NUMBER,
   given_amount      NUMBER,
   least_percent     NUMBER,
   limit_hold_flag   VARCHAR2(1),
   limit_code        VARCHAR2(30),
   hold_code         VARCHAR2(30),
   adjustment_amount NUMBER,
   operand_value     NUMBER,
   benefit_qty       NUMBER,
   created_from_list_line_type    VARCHAR2(30),
   pricing_group_sequence   NUMBER,
   operand_calculation_code VARCHAR2(30),
   bal_price_request_code   VARCHAR2(240),
   price_request_code       VARCHAR2(240),
   request_type_code        VARCHAR2(30),
   line_category            VARCHAR2(30),
   pricing_phase_id         NUMBER,
   transaction_amount       NUMBER,
   full_available_amount    NUMBER,
   line_detail_index        NUMBER,
   limit_level       VARCHAR2(1),
   limit_amount      NUMBER,
   limit_level_code  VARCHAR2(30),
   process_action    VARCHAR2(1), --'I' for insert, 'U' for Update
   hard_limit_exceeded     BOOLEAN,
   each_attr_exists        VARCHAR2(1),
   limit_exceed_action_code     VARCHAR2(30),
   multival_attr1_context       VARCHAR2(30),
   multival_attribute1          VARCHAR2(30),
   multival_attr1_value         VARCHAR2(240),
   multival_attr1_type          VARCHAR2(30),
   multival_attr1_datatype      VARCHAR2(10),
   multival_attr2_context       VARCHAR2(30),
   multival_attribute2          VARCHAR2(30),
   multival_attr2_value         VARCHAR2(240),
   multival_attr2_type          VARCHAR2(30),
   multival_attr2_datatype      VARCHAR2(10),
   organization_attr_context    VARCHAR2(30),
   organization_attribute       VARCHAR2(30),
   organization_attr_value      VARCHAR2(240)
);

TYPE Limit_Balance_Line_Tbl IS TABLE OF Limit_Balance_Line_Rec
  INDEX BY BINARY_INTEGER;

--Global plsql table type of variable
g_limit_balance_line    Limit_Balance_Line_Tbl;

--Global Constants
g_insert  CONSTANT  VARCHAR2(1) := 'I';
g_update  CONSTANT  VARCHAR2(1) := 'U';

--This Record Type should always be in sync with the limits_cur%rowtype
TYPE Limit_Rec IS RECORD
(line_index                   NUMBER,
 created_from_list_header_id  NUMBER,
 created_from_list_line_id    NUMBER,
 limit_level                  VARCHAR2(1),
 limit_id                     NUMBER,
 amount                       NUMBER ,
 limit_exceed_action_code     VARCHAR2(30),
 basis                        VARCHAR2(30),
 limit_hold_flag              VARCHAR2(1),
 limit_level_code             VARCHAR2(30),
 adjustment_amount            NUMBER,
 benefit_qty                  NUMBER,
 created_from_list_line_type  VARCHAR2(30),
 pricing_group_sequence       NUMBER,
 operand_calculation_code     VARCHAR2(30),
 price_request_code           VARCHAR2(240),
 request_type_code            VARCHAR2(30),
 line_category                VARCHAR2(30),
 operand_value                NUMBER,
 unit_price                   NUMBER,
 each_attr_exists             VARCHAR2(1),
 pricing_phase_id             NUMBER,
 non_each_attr_count          NUMBER,
 total_attr_count             NUMBER,
 line_detail_index            NUMBER,
 organization_attr_context    VARCHAR2(30),
 organization_attribute       VARCHAR2(30),
 multival_attr1_context       VARCHAR2(30),
 multival_attribute1          VARCHAR2(30),
 multival_attr1_type          VARCHAR2(30),
 multival_attr1_datatype      VARCHAR2(10),
 multival_attr2_context       VARCHAR2(30),
 multival_attribute2          VARCHAR2(30),
 multival_attr2_type          VARCHAR2(30),
 multival_attr2_datatype      VARCHAR2(10),
 gross_revenue_wanted         NUMBER,
 cost_wanted                  NUMBER,
 accrual_wanted               NUMBER,
 quantity_wanted              NUMBER
);

/*Procedure to Process Limits */
PROCEDURE Process_Limits(x_return_status OUT NOCOPY VARCHAR2,
                         x_return_text   OUT NOCOPY VARCHAR2);

END QP_LIMIT_BALANCE_CHECK_PVT;

/
