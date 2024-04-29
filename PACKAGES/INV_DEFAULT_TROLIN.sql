--------------------------------------------------------
--  DDL for Package INV_DEFAULT_TROLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DEFAULT_TROLIN" AUTHID CURRENT_USER AS
/* $Header: INVDTRLS.pls 120.1.12010000.2 2009/04/29 11:56:55 asugandh ship $ */

/*Fixed for bug#7126566
  Added below variable to ensure that when Get_Line_Number function is called
  it does increment line number properly.
  The process to increment line number is this:
  When called by FORM
   Form will increate the line number (global variable -INV_Globals.g_max_line_num)
   by calling the inv_trnasfer_order_pvt.increment_max_line_number.
   This ensure that when user goes from one line to another it does not
   increase line number unnecessarily.

  When called by API
   Function Get_Line_Number will increase the line number and would generate
   unique line number.

*/
G_CALLED_BY_FORM  VARCHAR2(1);

PROCEDURE Set_CALLED_BY_FORM(P_CALLED_BY_FORM in varchar2 );

--  Procedure Attributes

PROCEDURE Attributes
(   p_trolin_rec                    IN  INV_Move_Order_PUB.Trolin_Rec_Type :=
                                        INV_Move_Order_PUB.G_MISS_TROLIN_REC
,   p_iteration                     IN  NUMBER := 1
,   x_trolin_rec                    OUT nocopy INV_Move_Order_PUB.Trolin_Rec_Type
);

END INV_Default_Trolin;

/
