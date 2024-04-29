--------------------------------------------------------
--  DDL for Package QP_BULK_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BULK_MSG" AUTHID CURRENT_USER AS
/* $Header: QPXBMSGS.pls 120.0.12010000.2 2009/09/01 08:55:32 dnema ship $ */

TYPE num_type      IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE char30_type   IS TABLE OF Varchar2(30)   INDEX BY BINARY_INTEGER;
TYPE char50_type   IS TABLE OF Varchar2(50)   INDEX BY BINARY_INTEGER;
TYPE char240_type  IS TABLE OF Varchar2(240)   INDEX BY BINARY_INTEGER;
TYPE char2000_type  IS TABLE OF Varchar2(2000)   INDEX BY BINARY_INTEGER; --Bug 8392670

TYPE Msg_Rec_Type IS RECORD
( Request_id    NUMBER,
  entity_type   VARCHAR2(30),
  table_name    VARCHAR2(30),
  orig_sys_header_ref VARCHAR2(50),
  list_header_id  NUMBER,
  orig_sys_line_ref VARCHAR2(50),
  orig_sys_qualifier_ref VARCHAR2(50),
  orig_sys_pricing_attr_ref VARCHAR2(50),
  error_message VARCHAR2(240));

TYPE Msg_Rec_Type1 IS RECORD
( Request_id    num_type,
  entity_type   char30_type,
  table_name    char30_type,
  orig_sys_header_ref char50_type,
  list_header_id  num_type,
  orig_sys_line_ref char50_type,
  orig_sys_qualifier_ref char50_type,
  orig_sys_pricing_attr_ref char50_type,
  error_message char2000_type); --bug 8392670
  --error_message char240_type);

G_Msg_Rec  Msg_Rec_Type1;

PROCEDURE ADD(p_msg_rec  QP_BULK_MSG.MSG_REC_TYPE);

PROCEDURE SAVE_MESSAGE(p_request_id NUMBER);

END QP_BULK_MSG;

/
