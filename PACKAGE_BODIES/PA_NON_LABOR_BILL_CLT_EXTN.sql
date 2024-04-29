--------------------------------------------------------
--  DDL for Package Body PA_NON_LABOR_BILL_CLT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_NON_LABOR_BILL_CLT_EXTN" as
/* $Header: PAXINCTB.pls 120.1 2005/08/19 17:14:22 mwasowic noship $ */

  PROCEDURE Calc_Bill_Amount
                     (
                       x_transaction_type       in varchar2 default 'ACTUAL',
                       x_expenditure_item_id   IN      NUMBER,
                       x_sys_linkage_function  IN      VARCHAR2,
                       x_amount                IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_expenditure_type      IN      VARCHAR2,
                       x_non_labor_resource    IN      VARCHAR2,
                       x_non_labor_res_org     IN      NUMBER,
                       x_bill_rate_flag        IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_status                IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_bill_trans_currency_code      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_bill_txn_bill_rate    OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_markup_percentage     OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_rate_source_id        OUT     NOCOPY NUMBER)  --File.Sql.39 bug 4440895
  is
   begin
	-- Reset the output parameters.
	x_amount := NULL;
	x_bill_rate_flag := NULL;
	x_status := 0;
	-- Add your calculation of bill amount here.
	-- Assign the result of bill amount to x_amount
	-- If you want a bill rate populated by Project Accounting, set
	-- x_bill_rate_flag to 'B' return rate in the x_bill_txn_bill_rate and if you are using markup, return
        -- markup percentage in the x_markup_percentage and populate the x_rate_source_id with unique identifier
        -- of the source that was used to derive the bill rate or markup. If x_bill_rate_flag's null or
        -- set to 'N', x_amount will be treated as a markup, and bill rate will not be populated.
        -- Do not add 'commit' or 'rollback' in your code, since Oracle
        -- Project Accounting controls the transaction for you.

   exception
	when others then
        -- Add your exception handler here.
	-- To raise an application error, assign a positive number to x_status.
	-- To raise an ORACLE error, assign SQLCODE to x_status.
	null;

   end Calc_Bill_Amount;


end PA_NON_LABOR_BILL_CLT_EXTN;

/
