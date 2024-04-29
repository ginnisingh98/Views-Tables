--------------------------------------------------------
--  DDL for Package MTL_MOVEMENT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_MOVEMENT_RPT_PKG" AUTHID CURRENT_USER as
/* $Header: INVMVTPS.pls 120.0 2005/05/25 04:28:19 appldev noship $ */

------------------------------------------
-- Update mtl_movement_statistics table --
-- executed in Before Report Trigger    --
------------------------------------------

procedure BEFORE_REPORT_UPDATES
	(P_USER_ID		in number,
	 P_CONC_LOGIN_ID	in number,
	 P_PERIOD_NAME		in varchar2,
	 P_CONC_REQUEST_ID	in number,
	 P_CONC_APPLICATION_ID	in number,
	 P_CONC_PROGRAM_ID	in number,
	 P_REPORT_OPTION	in varchar2,
	 P_MOVEMENT_TYPE	in varchar2,
	 P_LEGAL_ENTITY_ID	in number,
	 P_REPORT_REFERENCE	in number,
         P_FORMAT_TYPE          in varchar2,
	 C_CONVERSION_TYPE	in varchar2,
	 C_CONVERSION_OPTION	in varchar2,
	 C_SET_OF_BOOKS_ID	in number,
	 C_START_DATE		in date,
	 C_END_DATE		in date,
         C_CURRENCY_CODE        in varchar2);

------------------------------------------
-- Update mtl_movement_statistics table --
-- and mtl_movement_parameters table    --
-- executed in After Report Trigger     --
------------------------------------------

procedure AFTER_REPORT_UPDATES
	(P_USER_ID               in number,
	 P_CONC_LOGIN_ID         in number,
	 P_PERIOD_NAME           in varchar2,
	 P_REPORT_OPTION	 in varchar2,
	 P_MOVEMENT_TYPE         in varchar,
	 P_LEGAL_ENTITY_ID       in number,
	 P_REPORT_REFERENCE      in number,
         P_FORMAT_TYPE           in varchar2,
	 C_START_DATE            in date,
	 C_END_DATE              in date);


-------------------------------------
-- Functions called from the       --
-- BEFORE REPORT UPDATES procedure --
-------------------------------------

----------------------------------------
-- Exchange Rate Calculation Function --
----------------------------------------
function EXCHANGE_RATE_CALC
	(C_CONVERSION_OPTION             varchar2,
	 C_CONVERSION_TYPE               varchar2,
	 C_SET_OF_BOOKS_ID               number,
	 C_END_DATE                      date,
         C_CURRENCY_CODE                 varchar2,
	 l_currency_code                 varchar2,
	 l_transaction_date              date,
         l_invoice_id                    number,
         l_document_source_type          varchar2,
         l_movement_type                 varchar2)
return number;

------------------------------------------
-- Conversion Date Calculation Function --
------------------------------------------
function CONVERSION_DATE_CALC
	(C_END_DATE		date,
	 C_CONVERSION_OPTION	varchar2,
         C_CURRENCY_CODE        varchar2,
         l_currency_code        varchar2,
	 l_transaction_date	date,
         l_invoice_id           number,
         l_document_source_type varchar2,
         l_movement_type        varchar2)
return date;

--------------------------------------
-- Unit Weight Calculation Function --
--------------------------------------
function UNIT_WEIGHT_CALC
	(l_inventory_item_id	number,
	 l_organization_id	number,
	 P_LEGAL_ENTITY_ID	number)
return number;

---------------------------------
-- Weight Calculation Function --
---------------------------------
function WEIGHT_CALC
	(l_total_weight		number,
	 l_inventory_item_id	number,
	 l_organization_id	number,
	 l_transaction_quantity number,
	 l_transaction_uom_code	varchar2,
	 P_LEGAL_ENTITY_ID	number,
         P_FORMAT_TYPE          varchar2)
return number;

--------------------------------------
-- Date Report Calculation Function --
--------------------------------------
function REPORT_DATE_CALC
	(l_invoice_date_reference	date,
	 l_transaction_date		date)
return date;

-----------------------------------------------------------------------------
-- Define pragmas to declare that the functions are pure and hence will
-- not alter the package state.
-----------------------------------------------------------------------------
PRAGMA RESTRICT_REFERENCES(EXCHANGE_RATE_CALC, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(CONVERSION_DATE_CALC, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(UNIT_WEIGHT_CALC, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(WEIGHT_CALC, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES(REPORT_DATE_CALC, WNDS, WNPS);


end MTL_MOVEMENT_RPT_PKG;

 

/
