--------------------------------------------------------
--  DDL for Package XTR_BISF_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_BISF_P" AUTHID CURRENT_USER as
/* $Header: xtrbisfs.pls 120.2.12010000.2 2008/08/06 10:42:21 srsampat ship $ */
----------------------------------------------------------------------------------------------------------------
Function Xtr_Reference_Spot(
p_deal_type in varchar2,
p_deal_number in varchar2
) return number;

Function Xtr_Reference_Internal(
p_deal_type in varchar2,
p_deal_number in varchar2,
p_transaction_number in number
) return varchar2;

Function Xtr_Ig_Onc_Sum_Intadj(
p_deal_type in varchar2,
p_deal_number in number,
p_transaction_number in number,
p_journal_date in date
) return number;

end XTR_BISF_P;

/
