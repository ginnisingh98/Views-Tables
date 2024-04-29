--------------------------------------------------------
--  DDL for Package Body PA_CC_TP_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_TP_CLIENT_EXTN" AS
/*  $Header: PAPTPRCB.pls 120.1 2005/08/19 16:46:44 mwasowic noship $  */



-------------------------------------------------------------------------------
  -- Pre-client extension

PROCEDURE Determine_Transfer_Price(
        p_transaction_type		IN	Varchar2 DEFAULT 'ACTUAL',
        p_prvdr_org_id                  IN      Number,
 	p_prvdr_organization_id		IN      Number,
        p_recvr_org_id                  IN      Number,
        p_recvr_organization_id         IN      Number,
        p_expnd_organization_id         IN      Number,
        p_expenditure_item_id           IN      Number,
        p_expenditure_item_type         IN      Varchar2,
        p_expenditure_type_class        IN      Varchar2,
	p_task_id                       IN      Number,
	p_project_id                    IN      Number,
	p_quantity                      IN      Number,
	p_incurred_by_person_id         IN      Number,
	x_denom_tp_curr_code            OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
	x_denom_transfer_price          OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_tp_bill_rate                  OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_tp_bill_markup_percentage     OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_error_message                 OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
	x_status                        OUT     NOCOPY NUMBER	 --File.Sql.39 bug 4440895
        )
IS
BEGIN

   x_denom_transfer_price := null;
   x_denom_tp_curr_code  := null;
   x_tp_bill_rate  := null;
   x_tp_bill_markup_percentage := null;
   x_status := 0;
   x_error_message := null;

END Determine_Transfer_Price;

--------------------------------------------------------------------------------
-- Post-client extension

PROCEDURE Override_Transfer_Price(
        p_transaction_type		IN	Varchar2 DEFAULT 'ACTUAL',
        p_prvdr_org_id                  IN      Number,
 	p_prvdr_organization_id		IN      Number,
        p_recvr_org_id                  IN      Number,
        p_recvr_organization_id         IN      Number,
        p_expnd_organization_id         IN      Number,
        p_expenditure_item_id           IN      Number,
        p_expenditure_item_type         IN      Varchar2,
        p_expenditure_type_class        IN      Varchar2,
	p_task_id                       IN      Number,
	p_project_id                    IN      Number,
	p_quantity                      IN      Number,
	p_incurred_by_person_id         IN      Number,
	p_base_curr_code                IN      Varchar2,
	p_base_amount                   IN      Number,
	p_denom_tp_curr_code            IN      Varchar2,
	p_denom_transfer_price          IN      Number,
	x_denom_tp_curr_code            OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
	x_denom_transfer_price          OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_tp_bill_rate                  OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_tp_bill_markup_percentage     OUT     NOCOPY Number, --File.Sql.39 bug 4440895
	x_error_message                 OUT     NOCOPY Varchar2, --File.Sql.39 bug 4440895
	x_status                        OUT     NOCOPY NUMBER	 --File.Sql.39 bug 4440895
        )
IS
BEGIN

   x_denom_tp_curr_code := p_denom_tp_curr_code;
   x_denom_transfer_price := p_denom_transfer_price;
   x_tp_bill_rate := null;
   x_tp_bill_markup_percentage := null;
   x_error_message := null;
   x_status := 0;

END Override_Transfer_Price;

--------------------------------------------------------------------------------

END PA_CC_TP_CLIENT_EXTN;

/
