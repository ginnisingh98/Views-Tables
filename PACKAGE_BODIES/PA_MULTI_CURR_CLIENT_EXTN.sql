--------------------------------------------------------
--  DDL for Package Body PA_MULTI_CURR_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MULTI_CURR_CLIENT_EXTN" AS
/*  $Header: PAPMCECB.pls 120.3 2006/06/22 06:32:06 rkchoudh noship $  */

-------------------------------------------------------------------------------
  -- Client extension to override Currency Conversion attributes

PROCEDURE Override_Curr_Conv_Attributes(
        p_project_id                    IN      Number,
 	p_task_id                       IN      Number,
	p_transaction_class             IN      Varchar2,
        p_expenditure_item_id           IN      Number,
        p_expenditure_type_class        IN      Varchar2,
        p_expenditure_type              IN      Varchar2,
	p_expenditure_category          IN      Varchar2,
	p_from_currency_code            IN      Varchar2,
	p_to_currency_code              IN      Varchar2,
        p_conversion_type               IN      Varchar2,
	p_conversion_date               IN      Date,
        x_rate_type                     OUT      NOCOPY Varchar2,  --File.Sql.39 bug 4440895
	x_rate_date                     OUT      NOCOPY Date, --File.Sql.39 bug 4440895
	x_exchange_rate                 OUT      NOCOPY Number, --File.Sql.39 bug 4440895
        x_error_message                 OUT      NOCOPY Varchar2,  --File.Sql.39 bug 4440895
        x_status                        OUT      NOCOPY Number  --File.Sql.39 bug 4440895
        )
IS
BEGIN

   x_status := 0;

END Override_Curr_Conv_Attributes;

--------------------------------------------------------------------------------

END PA_MULTI_CURR_CLIENT_EXTN ;

/
