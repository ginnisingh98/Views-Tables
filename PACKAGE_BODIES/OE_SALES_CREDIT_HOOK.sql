--------------------------------------------------------
--  DDL for Package Body OE_SALES_CREDIT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SALES_CREDIT_HOOK" AS
/* $Header: OEXSCHOB.pls 115.2 2003/10/20 07:09:04 appldev ship $ */
Procedure Calculate(p_header_id        In  Number,
                    p_sales_rep_id_tbl In  OE_HEADER_SCREDIT_UTIL.SALESREP_ID_TBL_TYPE,
x_sales_credit_tbl OUT NOCOPY OE_HEADER_SCREDIT_UTIL.SALES_CREDIT_TBL_TYPE,

x_return_status OUT NOCOPY Varchar2) Is

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  oe_debug_pub.add('Entering OE_SALES_CREDIT_HOOK');
  /*MIS_OE_SCREDIT_UTIL.Calculate(p_header_id       =>p_header_id,
                                p_sales_rep_id_tbl=>p_sales_rep_id_tbl,
                                x_sales_credit_tbl=>x_sales_credit_tbl,
                                x_return_status   =>x_return_status);*/
    NULL;
  oe_debug_pub.add('Leaving OE_SALES_CREDIT_HOOK');
End;

End;

/
