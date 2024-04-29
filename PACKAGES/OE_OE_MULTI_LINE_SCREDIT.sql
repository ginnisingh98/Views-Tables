--------------------------------------------------------
--  DDL for Package OE_OE_MULTI_LINE_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_MULTI_LINE_SCREDIT" AUTHID CURRENT_USER AS
/* $Header: OEXMLSCS.pls 120.1.12000000.2 2007/07/27 08:20:03 cpati ship $ */

TYPE Line_MULTI_Scredit_Tbl_Type IS TABLE OF OE_ORDER_PUB.Line_Scredit_Rec_Type
    INDEX BY BINARY_INTEGER;

Function Get_Multi_Errors
   (p_start_with_first Varchar2 default FND_API.G_TRUE
   ) Return Varchar2;

Procedure Add_Multi_Line_Scredit_Req
  (p_init              IN Varchar2 Default FND_API.G_FALSE
  ,p_salesrep_id       IN Number
  ,p_sales_Credit_type_id IN Number
  ,p_percent           IN Number
  -- changes start for bug 3742335
  ,p_Context	  Varchar2
  ,p_Attribute1	  Varchar2
  ,p_Attribute2	  Varchar2
  ,p_Attribute3   Varchar2
  ,p_Attribute4   Varchar2
  ,p_Attribute5   Varchar2
  ,p_Attribute6   Varchar2
  ,p_Attribute7   Varchar2
  ,p_Attribute8   Varchar2
  ,p_Attribute9   Varchar2
  ,p_Attribute10  Varchar2
  ,p_Attribute11  Varchar2
  ,p_Attribute12  Varchar2
  ,p_Attribute13  Varchar2
  ,p_Attribute14  Varchar2
  ,p_Attribute15  Varchar2
  -- changes end for bug 3742335
  ,p_sales_group_id       IN Number  --5692017
  ,p_sales_group_updated_flag  IN Varchar2  --5692017
  ,p_return_status OUT NOCOPY Varchar2

,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY Varchar2

  );

/* Replace credit type : R  - Revenue
                         NR - Non Revenue
                         B  - Both Revenue and Non-Revenue
*/
Procedure Replace_Multi_Line_Scredit
   (
    p_cont_on_error            IN  Varchar2 Default FND_API.G_TRUE
    ,p_Line_id_list            IN  Oe_Globals.Selected_Record_Tbl   --MOAC PI
    ,p_replace_credit_type     IN  Varchar2
,p_Return_Status OUT NOCOPY Varchar2

,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY Varchar2

   );

END OE_OE_Multi_Line_Scredit;


 

/
