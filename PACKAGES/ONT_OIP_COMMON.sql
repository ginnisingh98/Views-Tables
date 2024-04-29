--------------------------------------------------------
--  DDL for Package ONT_OIP_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OIP_COMMON" AUTHID CURRENT_USER as
/* $Header: ontcomns.pls 120.4.12000000.1 2007/01/16 22:23:26 appldev ship $ */

gContactID	number :=0;
gOPMCustID	number :=0;
gCustomerID	number :=0;
gCustomerAddrID	number :=0;
gCustName	varchar2(80);
gUserFName	Varchar2(150);
gUserLName	Varchar2(150);
gUserEmail 	Varchar2(250);
gUserPhone 	Varchar2(250);

gProductID      number := 559;

gAndVal		varchar2(1) :='&';
gSpace		varchar2(6) :=gAndVal||'nbsp';
gTab		varchar2(50) :=gSpace||gspace||gspace||gspace;

gCustFContact	varchar2(250);      -- Feedback Contact email to send info to
gCustFContactID  number := 0;
gCustDContact	varchar2(250);      -- Defect Contact email to send info to
gCustDContactID  number := 0;
gCustCContact	varchar2(250);      -- Cancel Contact email to send info to
gCustCContactID  number := 0;

-----------------------------------------------
-- Declare Global Message Instantiation here.
-----------------------------------------------

gHelp		varchar2(1000);
gReload		varchar2(1000);
gMenu		varchar2(1000);
gSave		varchar2(1000);
gExit		varchar2(1000);


-------------------------------------------------
-- Generic funtion to get messages.
-------------------------------------------------
function   getMessage(pMsgName      varchar2,
		     pTokenName1    varchar2 DEFAULT NULL,
		     pTokenValue1   varchar2 DEFAULT NULL,
		     pTokenName2    varchar2 DEFAULT NULL,
		     pTokenValue2   varchar2 DEFAULT NULL,
		     pTokenName3    varchar2 DEFAULT NULL,
		     pTokenValue3   varchar2 DEFAULT NULL,
		     pTokenName4    varchar2 DEFAULT NULL,
		     pTokenValue4   varchar2 DEFAULT NULL,
		     pTokenName5    varchar2 DEFAULT NULL,
		     pTokenValue5   varchar2 DEFAULT NULL) return varchar2;

function     getRecCount(pCurrent   number,
			 pPageTot   number,
			 pTotal     number) return varchar2;

function  Get_Released_Status_Name(p_source_code       IN  VARCHAR2,
                                p_released_status      IN  VARCHAR2,
                                p_oe_interfaced_flag   IN  VARCHAR2,
                                p_inv_interfaced_flag  IN  VARCHAR2,
                                p_move_order_line_id   IN  NUMBER) RETURN  VARCHAR2;


procedure getContactId(lContactid in out NOCOPY varchar2);

procedure initialize;


procedure getContactDetails(lUserId in number,
pContactId out nocopy number,

pUserFName out nocopy varchar2,

pUserLName out nocopy varchar2,

pUserEmail out nocopy varchar2,

pCustName out nocopy varchar2,

pCustomerID out nocopy number,

pCustomerAddrID out nocopy number,

pStatusCode out nocopy number);


/****************************************************
 * procedure Get_Price_Formatted
 **********************************************************
 * Logic :a) call FND_CURRENCY.get_info to get the precision and extend
 *          precision defined for the currency code.
 *
 *         b)check profile OM: Unit Price Precision Type
 *           If the profile options value is "EXTENDED", call
 *           FND_CURRENCY.build_format_mask by passing the ext_precision
 *           from step(a) to get the format_mask.
 *
 *           If the profile options value is "STANDARD", call
 *           FND_CURRENCY.build_format_mask by passing the precision from
 *           step(a) to get the format_mask.
 *
 *         c)convert unit_selling_price from lines table to Char with correct
 *           format mask.
 * Bug: 4058254
 *
 *
 ************************************************************/

procedure  Get_Price_formatted(
p_transactional_curr_code  IN  VARCHAR2,
p_price                    IN NUMBER,
p_line_category_code       IN VARCHAR2,
x_price_formatted          OUT NOCOPY VARCHAR2
);


end;


 

/
