--------------------------------------------------------
--  DDL for Package OE_FREIGHT_RATING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FREIGHT_RATING_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVFRRS.pls 120.0.12010000.1 2008/07/25 07:59:53 appldev ship $ */

TYPE T_DATE  is TABLE OF DATE;
TYPE T_NUM   is TABLE OF NUMBER;
TYPE T_V1    is TABLE OF VARCHAR(01);
TYPE T_V3    is TABLE OF VARCHAR(03);
TYPE T_V10   is TABLE OF VARCHAR(10);
TYPE T_V15   is TABLE OF VARCHAR(15);
TYPE T_V25   is TABLE OF VARCHAR(25);
TYPE T_V30   is TABLE OF VARCHAR(30);
TYPE T_V40   is TABLE OF VARCHAR(40);
TYPE T_V50   is TABLE OF VARCHAR(50);
TYPE T_V80   is TABLE OF VARCHAR(80);
TYPE T_V240  is TABLE OF VARCHAR(240);
TYPE T_V1000 is TABLE OF VARCHAR(1000);
TYPE T_V2000 is TABLE OF VARCHAR(2000);
TYPE NUMBER_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE Bulk_Line_Adj_Rec_Type IS RECORD
(   price_adjustment_id            T_NUM
,   header_id                      T_NUM
,   line_id                        T_NUM
,   adjusted_amount                T_NUM
,   operand                        T_NUM
,   list_line_type_code            T_V30
,   charge_type_code               T_V30
,   estimated_flag                 T_V1
,   source_system_code             T_V30
,   creation_date                  T_DATE
,   created_by                     T_NUM
,   last_updated_by                T_NUM
,   last_update_date               T_DATE
,   last_update_login              T_NUM
);

Type List_Line_Type_Code_Rec_Type is Record
(
      list_line_type_code                   Varchar2(30)
);

TYPE List_Line_Type_Code_Tbl_Type IS TABLE OF List_Line_Type_Code_Rec_Type
    INDEX BY BINARY_INTEGER;

g_list_line_type_code_rec       List_Line_Type_Code_Rec_Type;
g_list_line_type_code_tbl       List_Line_Type_Code_Tbl_Type;

FUNCTION Get_List_Line_Type_Code
(   p_key	IN NUMBER)
RETURN VARCHAR2;

PROCEDURE Process_FTE_Output
( p_header_id              IN NUMBER
 ,p_x_fte_source_line_tab  IN OUT  NOCOPY  FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab
 ,p_x_line_tbl             IN OUT  NOCOPY  OE_ORDER_PUB.line_tbl_type
 ,p_fte_rates_tab          IN FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_Tab
 ,p_config_count           IN NUMBER
 ,p_ui_flag                IN VARCHAR2
 ,p_call_pricing_for_FR    IN VARCHAR2
 ,x_return_status          OUT NOCOPY VARCHAR2

);

END OE_FREIGHT_RATING_PVT;

/
