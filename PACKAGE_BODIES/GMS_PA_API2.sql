--------------------------------------------------------
--  DDL for Package Body GMS_PA_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PA_API2" AS
-- $Header: gmspax2b.pls 120.2 2007/02/06 09:51:44 rshaik ship $
-- -----------------------------------
-- Function to check the award status .
-- -----------------------------------
  FUNCTION IS_AWARD_CLOSED (x_expenditure_item_id IN NUMBER ,x_task_id IN NUMBER, x_doc_type in varchar2 default 'EXP' ) RETURN VARCHAR2 IS --Bug 5726575

    x_return VARCHAR2(1) := 'N' ;
   BEGIN
    If gms_install.enabled THEN
       x_return := gms_pa_api.is_award_closed (x_expenditure_item_id ,x_task_id , x_doc_type) ; --Bug 5726575
    End if ;

     RETURN x_return ;

   END IS_AWARD_CLOSED ;


   -- ====================================================================
   -- bug : 2733355 Is_grants_enabled function was added.
   -- This will be used in pa_cdl_burden_detail_v view definition.
   -- ====================================================================
   -- return value : Y - Grants enabled.
   --                N - Grants not enabled.

   function is_grants_enabled return varchar2 is
   begin
	if gms_install.enabled then
		return 'Y' ;
	ELSE
		return 'N' ;
	end if ;
   end is_grants_enabled ;

END gms_pa_api2;

/
