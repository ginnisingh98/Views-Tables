--------------------------------------------------------
--  DDL for Package OE_SALES_CREDIT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SALES_CREDIT_HOOK" AUTHID CURRENT_USER AS
/* $Header: OEXSCHOS.pls 115.2 2003/10/20 07:09:06 appldev ship $ */
Procedure Calculate(p_header_id        In  Number,
                    p_sales_rep_id_tbl In  OE_HEADER_SCREDIT_UTIL.SALESREP_ID_TBL_TYPE,
x_sales_credit_tbl OUT NOCOPY OE_HEADER_SCREDIT_UTIL.SALES_CREDIT_TBL_TYPE,

x_return_status OUT NOCOPY Varchar2);


End;

 

/
