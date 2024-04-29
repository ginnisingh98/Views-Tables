--------------------------------------------------------
--  DDL for Package Body ICX_REQ_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_CUSTOM" as
/* $Header: ICXRQCUB.pls 115.1 99/07/17 03:23:09 porting ship $ */


/*  The comments given below are simply my quick hints for writting user
    defaults and validation.  The sql once written should be VALIDATED and
    TUNED!!!  Remeber any overhead you add will result in slower performance.
    Try to keep the defaulting to the defaulting routines, and the validation
    to the validation routines.  These routines give you a lot of power over
    the system, use it wisely........


	Thanks,
	   KW

*/


/****************************************************************************/
/*************************   CART TABLES ************************************/
/****************************************************************************



	ICX_SHOPPING_CARTS  -- Header info for the Requisition

 CART_ID                         NOT NULL NUMBER
 LAST_UPDATE_DATE                NOT NULL DATE
 LAST_UPDATED_BY                 NOT NULL NUMBER
 CREATION_DATE                   NOT NULL DATE
 CREATED_BY                               NUMBER
 SHOPPER_ID                      NOT NULL NUMBER
 SAVED_FLAG                      NOT NULL NUMBER
 APPROVER_ID                              NUMBER
 APPROVER_NAME                            VARCHAR2(240)
 NOTE_TO_APPROVER                         VARCHAR2(240)
 REQ_NUMBER_SEGMENT1                      VARCHAR2(30)
 HEADER_DESCRIPTION                       VARCHAR2(240)
 HEADER_ATTRIBUTE_CATEGORY                VARCHAR2(30)
 HEADER_ATTRIBUTE1                        VARCHAR2(150)
 HEADER_ATTRIBUTE2                        VARCHAR2(150)
 HEADER_ATTRIBUTE3                        VARCHAR2(150)
 HEADER_ATTRIBUTE4                        VARCHAR2(150)
 HEADER_ATTRIBUTE5                        VARCHAR2(150)
 HEADER_ATTRIBUTE6                        VARCHAR2(150)
 HEADER_ATTRIBUTE7                        VARCHAR2(150)
 HEADER_ATTRIBUTE8                        VARCHAR2(150)
 HEADER_ATTRIBUTE9                        VARCHAR2(150)
 HEADER_ATTRIBUTE10                       VARCHAR2(150)
 HEADER_ATTRIBUTE11                       VARCHAR2(150)
 HEADER_ATTRIBUTE12                       VARCHAR2(150)
 HEADER_ATTRIBUTE13                       VARCHAR2(150)
 HEADER_ATTRIBUTE14                       VARCHAR2(150)
 HEADER_ATTRIBUTE15                       VARCHAR2(150)
 NOTE_TO_BUYER                            VARCHAR2(240)
 RESERVED_PO_NUM                          VARCHAR2(220)
 DESTINATION_TYPE_CODE                    VARCHAR2(25)
 DESTINATION_ORGANIZATION_ID              NUMBER
 DELIVER_TO_LOCATION_ID                   NUMBER
 DELIVER_TO_REQUESTOR_ID                  NUMBER
 NEED_BY_DATE                             DATE
 ORG_ID                                   NUMBER
 DELIVER_TO_LOCATION                      VARCHAR2(20)
 DELIVER_TO_REQUESTOR                     VARCHAR2(240)
 EMERGENCY_FLAG                           VARCHAR2(1)


	ICX_SHOPPING_CART_LINES  --Line level information for the Requisition

 CART_LINE_ID                    NOT NULL NUMBER
 LAST_UPDATE_DATE                NOT NULL DATE
 LAST_UPDATED_BY                 NOT NULL NUMBER
 CREATION_DATE                   NOT NULL DATE
 CREATED_BY                      NOT NULL NUMBER
 LAST_UPDATE_LOGIN                        NUMBER
 CART_ID                         NOT NULL NUMBER
 LINE_ID                                  VARCHAR2(80)
 ITEM_DESCRIPTION                         VARCHAR2(240)
 QUANTITY                                 NUMBER
 UNIT_PRICE                               NUMBER
 ITEM_ID                                  NUMBER
 ITEM_REVISION                            VARCHAR2(3)
 CATEGORY_ID                              NUMBER
 UNIT_OF_MEASURE                          VARCHAR2(25)
 LINE_TYPE_ID                             NUMBER
 EXPENDITURE_TYPE                         VARCHAR2(30)
 DESTINATION_ORGANIZATION_ID              NUMBER
 DELIVER_TO_LOCATION_ID                   NUMBER
 SUGGESTED_BUYER_ID                       NUMBER
 SUGGESTED_VENDOR_NAME                    VARCHAR2(80)
 SUGGESTED_VENDOR_SITE                    VARCHAR2(15)
 LINE_ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 LINE_ATTRIBUTE1                          VARCHAR2(150)
 LINE_ATTRIBUTE2                          VARCHAR2(150)
 LINE_ATTRIBUTE3                          VARCHAR2(150)
 LINE_ATTRIBUTE4                          VARCHAR2(150)
 LINE_ATTRIBUTE5                          VARCHAR2(150)
 LINE_ATTRIBUTE6                          VARCHAR2(150)
 LINE_ATTRIBUTE7                          VARCHAR2(150)
 LINE_ATTRIBUTE8                          VARCHAR2(150)
 LINE_ATTRIBUTE9                          VARCHAR2(150)
 LINE_ATTRIBUTE10                         VARCHAR2(150)
 LINE_ATTRIBUTE11                         VARCHAR2(150)
 LINE_ATTRIBUTE12                         VARCHAR2(150)
 LINE_ATTRIBUTE13                         VARCHAR2(150)
 LINE_ATTRIBUTE14                         VARCHAR2(150)
 LINE_ATTRIBUTE15                         VARCHAR2(150)
 NEED_BY_DATE                             DATE
 AUTOSOURCE_DOC_HEADER_ID                 NUMBER
 AUTOSOURCE_DOC_LINE_NUM                  NUMBER
 PROJECT_ID                               NUMBER
 TASK_ID                                  NUMBER
 EXPENDITURE_ITEM_DATE                    DATE
 SUGGESTED_VENDOR_CONTACT                 VARCHAR2(80)
 SUGGESTED_VENDOR_PHONE                   VARCHAR2(20)
 SUGGESTED_VENDOR_ITEM_NUM                VARCHAR2(25)
 EXPENDITURE_ORGANIZATION_ID              NUMBER
 SUPPLIER_ITEM_NUM                        VARCHAR2(25)
 ORG_ID                                   NUMBER
 EXPRESS_NAME                             VARCHAR2(25)
 ITEM_NUMBER                              VARCHAR2(40)
 DELIVER_TO_LOCATION                      VARCHAR2(20)
 CUSTOM_DEFAULTED                         CHAR(1)
 CART_LINE_NUMBER                NOT NULL NUMBER


	ICX_CART_DISTRIBUTIONS   -- Account information turned on at the
				 -- Header level

 CART_ID                         NOT NULL NUMBER
 DISTRIBUTION_ID                 NOT NULL NUMBER
 LAST_UPDATED_BY                 NOT NULL NUMBER
 LAST_UPDATE_DATE                NOT NULL DATE
 LAST_UPDATE_LOGIN               NOT NULL NUMBER
 CREATION_DATE                   NOT NULL DATE
 CREATED_BY                      NOT NULL NUMBER
 CHARGE_ACCOUNT_SEGMENT1                  VARCHAR2(240)
 CHARGE_ACCOUNT_SEGMENT2                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT3                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT4                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT5                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT6                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT7                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT8                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT9                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT10                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT11                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT12                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT13                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT14                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT15                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT16                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT17                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT18                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT19                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT20                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT21                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT22                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT23                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT24                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT25                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT26                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT27                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT28                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT29                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT30                 VARCHAR2(25)
 ORG_ID                                   NUMBER

	ICX_CART_LINE_DISTRIBUTIONS -- Account information turned on at the
				    -- Line level

 CART_LINE_ID                    NOT NULL NUMBER
 DISTRIBUTION_ID                 NOT NULL NUMBER
 LAST_UPDATED_BY                 NOT NULL NUMBER
 LAST_UPDATE_DATE                NOT NULL DATE
 LAST_UPDATE_LOGIN               NOT NULL NUMBER
 CREATION_DATE                   NOT NULL DATE
 CREATED_BY                      NOT NULL NUMBER
 CHARGE_ACCOUNT_ID                        NUMBER
 CHARGE_ACCOUNT_SEGMENT1                  VARCHAR2(240)
 CHARGE_ACCOUNT_SEGMENT2                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT3                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT4                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT5                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT6                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT7                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT8                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT9                  VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT10                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT11                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT12                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT13                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT14                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT15                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT16                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT17                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT18                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT19                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT20                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT21                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT22                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT23                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT24                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT25                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT26                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT27                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT28                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT29                 VARCHAR2(25)
 CHARGE_ACCOUNT_SEGMENT30                 VARCHAR2(25)
 DIST_ATTRIBUTE_CATEGORY                  VARCHAR2(30)
 DISTRIBUTION_ATTRIBUTE1                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE2                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE3                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE4                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE5                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE6                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE7                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE8                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE9                  VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE10                 VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE11                 VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE12                 VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE13                 VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE14                 VARCHAR2(150)
 DISTRIBUTION_ATTRIBUTE15                 VARCHAR2(150)
 ACCRUAL_ACCOUNT_ID                       NUMBER
 VARIANCE_ACCOUNT_ID                      NUMBER
 BUDGET_ACCOUNT_ID                        NUMBER
 ORG_ID                                   NUMBER
 CART_ID                         NOT NULL NUMBER



*/


-------------------------------------------------------------------------
  procedure add_user_error(v_cart_id number, error_message varchar2) is
-------------------------------------------------------------------------


begin
	icx_util.add_error(error_message);
	ICX_REQ_SUBMIT.storeerror(v_cart_id, error_message);

end;




-------------------------------------------------------------------------
  procedure cart_custom_build_req_account(v_cart_line_id  IN NUMBER,
				     V_ACCOUNT_NUM 	OUT VARCHAR2,
				     V_ACCOUNT_ID	OUT NUMBER,
				     RETURN_CODE        OUT VARCHAR2) IS
-------------------------------------------------------------------------


/*	The following is a cursor you can use to get the infomation
	available about the requisition line


	CURSOR get_info is
	SELECT isc.ANY_COLUMN_OF_ICX_SHOPPING_CARTS
	       iscl.ANY_COLUMN_OF_ICX_SHOPPING_CART_LINES
	       iscd.ANY_COLUMN_OF_ICX_CART_DISTRIBUTIONS
	       iscld.ANY_COLUMN_OF_ICX_CART_LINE_DISTRIBUTIONS
	       hecv.default_code_combination_id employee_default_account_id,
               hecv.organization_id employee_org_id,
               hecv.business_group_id employee_bus_group_id,
	       fsp.org_id po_org_id,
	       fsp.set_of_books_id,
	       msi.expense_account
	FROM   financials_system_parameters fsp,
               hr_employees_current_v hecv,
               mtl_system_items msi,
	       icx_cart_distributions iscd,
	       icx_cart_line_distributions iscld,
               icx_shopping_carts isc,
               icx_shopping_cart_lines iscl
	WHERE  isc.cart_id = iscl.cart_id
	AND    iscl.cart_line_id = v_cart_line_id
	AND    iscd.cart_id = iscl.cart_id
	AND    iscld.cart_line_id = v_cart_line_id
	AND    msi.INVENTORY_ITEM_ID (+) = iscl.ITEM_ID
	AND    nvl(msi.ORGANIZATION_ID, isc.DESTINATION_ORG_ID) = isc.DESTINATION_ORG_ID
	AND    hecv.EMPLOYEE_ID = isc.shopper_id;


	If you decide to not use some of the above information (such as the
	info from ht_employees_current_v) it is faster to remove it from the
	join and the select.

	You can then OPEN the cursor, FETCH the info, and figure out a
	ACCOUNT.  Remember to CLOSE the CURSOR.

	You can add any table join to the above or do your own SQL to build the
	account

*/




  BEGIN
        -- PLACE CUSTOM CODE HERE!!!!!

        -- generate new charge account id

        V_ACCOUNT_NUM := NULL;
        V_ACCOUNT_ID := NULL;
	RETURN_CODE := null;

  END;



-------------------------------------------------------------------------
  procedure cart_custom_build_req_account2(v_cart_line_id IN NUMBER,
                                   VARIANCE_ACCOUNT_ID         OUT NUMBER,
                                   BUDGET_ACCOUNT_ID   OUT NUMBER,
                                   ACCRUAL_ACCOUNT_ID  OUT NUMBER,
                                   RETURN_CODE  OUT VARCHAR2) is
-------------------------------------------------------------------------

/*  To get at the information you need you can use the following cursor

	CURSOR get_info is
	SELECT isc.ANY_COLUMN_YOU_WANT_FROM_ICX_SHOPPING_CARTS
	       iscl.ANY_COLUMN_OF_ICX_SHOPPING_CART_LINES
	       iscd.ANY_COLUMN_OF_ICX_CART_DISTRIBUTIONS
	       iscld.ANY_COLUMN_OF_ICX_CART_LINE_DISTRIBUTIONS
	FROM   icx_cart_distributions iscd,
	       icx_cart_line_distributions iscd,
	       icx_shopping_cart_lines iscl,
	       icx_shopping_carts isc
	WHERE  isc.cart_id = iscl.cart_id
	AND    isc.cart_id = iscd.cart_id
	AND    iscl.cart_line_id = v_cart_line_id
	AND    iscl.cart_line_id = iscld.cart_line_id;


     You can then build the correct Accounts in the same way you did above
*/
  BEGIN
     VARIANCE_ACCOUNT_ID := NULL;
     BUDGET_ACCOUNT_ID := NULL;
     ACCRUAL_ACCOUNT_ID := NULL;
     RETURN_CODE := NULL;
  end;


-------------------------------------------------------------------------
  procedure po_custom_build_req_account(EMPLOYEE_ID     IN NUMBER,
                                     employee_default_account_id IN NUMBER,
                                     employee_org_id    IN NUMBER,
                                     employee_bus_group_id NUMBER,
                                     po_org_id          IN NUMBER,
                                     NEED_BY_DATE       IN DATE,
                                     DESTINATION_TYPE   IN VARCHAR2,
                                     DESTINATION_ORG_ID IN NUMBER,
                                     SITE_ID            IN NUMBER,
                                     set_of_books_id    IN NUMBER,
                                     ITEM_ID            IN NUMBER,
                                     ITEM_REVISION      IN VARCHAR2,
                                     ITEM_DESCRIPTION   IN VARCHAR2,
                                     item_default_account_id IN NUMBER,
                                     UNIT_OF_MEASURE    IN VARCHAR2,
                                     QUANTITY           IN NUMBER,
                                     PRICE              IN NUMBER,
                                     SUPPLIER_ITEM_NUM  IN VARCHAR2,
                                     CATEGORY_ID        IN NUMBER,
                                     LINE_TYPE          IN NUMBER,
                                     SUPPLIER           IN VARCHAR2,
                                     SUPPLIER_SITE      IN VARCHAR2,
                                     SOURCE_DOC_NUM     IN VARCHAR2,
                                     SOURCE_LINE_NUM    IN NUMBER,
                                     CHARGE_ACCT_LINE_SEGMENTS IN VARCHAR2,
                                     ACCOUNT_NUM        OUT VARCHAR2,
                                     CHARGE_ACCOUNT_ID  OUT NUMBER,
				     RETURN_CODE        OUT VARCHAR2) IS
-------------------------------------------------------------------------

    l_new_charge_account_id NUMBER;
    l_new_seg VARCHAR2(1000);
    pos NUMBER;

    cursor getChargeAccount(new_seg varchar2) is
           select code_combination_id
           from gl_code_combinations_kfv
           where concatenated_segments = rtrim(l_new_seg);


  BEGIN
        -- PLACE CUSTOM CODE HERE!!!!!

        -- generate new charge account id

        ACCOUNT_NUM := NULL;
        CHARGE_ACCOUNT_ID := NULL;
        l_new_charge_account_id := NULL;
        l_new_seg := CHARGE_ACCT_LINE_SEGMENTS;

        if l_new_seg is NOT NULL then

           open getChargeAccount(l_new_seg);
           fetch getChargeAccount into l_new_charge_account_id;
           close getChargeAccount;

          -- send back the new account id
          -- otherwise pass in the old charge account id
          -- and pass that back out
          if l_new_charge_account_id is not NULL then
             CHARGE_ACCOUNT_ID := l_new_charge_account_id;
          end if;

        end if;

	RETURN_CODE := null;

  exception
    when NO_DATA_FOUND then
        CHARGE_ACCOUNT_ID := NULL;
        ACCOUNT_NUM := NULL;
        RETURN_CODE := NULL;
  END;



-------------------------------------------------------------------------
  procedure po_custom_build_req_account2(EMPLOYEE_ID        IN NUMBER,
				   employee_default_account_id IN NUMBER,
				   employee_org_id    IN NUMBER,
				   employee_bus_group_id NUMBER,
				   po_org_id          IN NUMBER,
                                   NEED_BY_DATE       IN DATE,
                                   DESTINATION_TYPE   IN VARCHAR2,
                                   DESTINATION_ORG_ID IN NUMBER,
                                   SITE_ID            IN NUMBER,
				   set_of_books_id    IN NUMBER,
                                   ITEM_ID            IN NUMBER,
                                   ITEM_REVISION      IN VARCHAR2,
				   ITEM_DESCRIPTION   IN VARCHAR2,
				   item_default_account_id IN NUMBER,
                                   UNIT_OF_MEASURE    IN VARCHAR2,
                                   QUANTITY           IN NUMBER,
                                   PRICE              IN NUMBER,
                                   SUPPLIER_ITEM_NUM  IN VARCHAR2,
                                   CATEGORY_ID        IN NUMBER,
                                   LINE_TYPE          IN NUMBER,
                                   SUPPLIER           IN VARCHAR2,
                                   SUPPLIER_SITE      IN VARCHAR2,
                                   SOURCE_DOC_NUM     IN VARCHAR2,
                                   SOURCE_LINE_NUM    IN NUMBER,
                                   CHARGE_ACCT_LINE_SEGMENTS IN VARCHAR2,
                                   CHARGE_ACCOUNT_ID IN NUMBER,
                                   ACCOUNT_NUM        OUT VARCHAR2,
                                   VARIANCE_ACCOUNT_ID         OUT NUMBER,
                                   BUDGET_ACCOUNT_ID   OUT NUMBER,
                                   ACCRUAL_ACCOUNT_ID  OUT NUMBER,
                                   RETURN_CODE  OUT VARCHAR2) is
-------------------------------------------------------------------------
  BEGIN
     ACCOUNT_NUM := NULL;
     VARIANCE_ACCOUNT_ID := NULL;
     BUDGET_ACCOUNT_ID := NULL;
     ACCRUAL_ACCOUNT_ID := NULL;
     RETURN_CODE := NULL;
  end;

-------------------------------------------------------------------------
 procedure  reqs_default_lines( p_emergency IN VARCHAR2,
				cartId IN number) is
-------------------------------------------------------------------------

/*  You can default any informaion into the lines.  Please be carefull......

    You can do this in one of two ways.  Line by line, or with set processing.
    Line by line will allow you to do specific defaults at a line level
    while set processing will update all the columns at the same time.  It
    should be noted that set processing is FASTER...

    Please note that this procedure will be run ONCE per ADD.  This means that
    if a user adds 6 different items from a Template, this procedure will only
    be called ONCE.

    You will use the CUSTOM_DEFAULTED flag in icx_shopping_cart_lines to
    determine which records you have already done the defaulting for.
    When we create the record, we set CUSTUM_DEFAULTED to 'N'.  When you do
    your defaulting, set the CUSTUM_DEFAULTED to 'Y'.  I am not going to
    force this, its your defaulting mechanism, it is just a suggestion.


    LINE BY LINE  -- Use a Cursor and loop through


    CURSOR get_info is
    SELECT isc.ANY_SHOPPING_CART_COLUMN
	   iscl.ANY_SHOPPING_CART_LINE_COLUMN
	   iscld.ANY_CART_LINE_DISTRIBUTIONS_COLUMN
    FROM   icx_shopping_carts isc,
	   icx_cart_line_distributions iscld,
	   icx_shopping_cart_lines iscl
    WHERE  isc.cart_id = cartId
    AND    iscl.cart_id = cartId
    AND    iscld.cart_line_id = iscl.cart_line_id
    AND    isc.CUSTOM_DEFAULTED = 'N';


    Then simply LOOP through the record and do any updates you want


    FOR prec in get_info LOOP

    UPDATE icx_shopping_cart_lines
    set    WHATEVER = WHATEVER,
	   CUSTOM_DEFAULTED = 'Y'
    where  cart_line_id = CART_LINE_ID FROM YOUR CURSOR;

    UPDATE icx_cart_line_distributions
    set    WHATEVER = WHATEVER
    where  cart_line_id = CART_LINE_ID FROM YOUR CURSOR;

    end LOOP;


    SET PROCESSING  -- simply update the tables

    -- do the distributions first
    update icx_cart_line_distributions
    set    WHATEVER = WHATEVER
    where  cart_line_id in
	(SELECT cart_line_id
	 from   icx_shopping_cart_lines
	 where  cart_id = cartId
	 and    CUSTOM_DEFAULTED = 'N');


    update icx_shopping_cart_lines
    set  (WHATEVER, CUSTOM_DEFAULTED) =
	(SELECT WHATEVER, 'Y'
	 FROM WHEREVER)
    where cart_id = cartId
    and   CUSTOM_DEFAULTED = 'N';


*/

 begin
  -- Custom default code will come here
  -- do nothing;
  null;
 end reqs_default_lines;


-------------------------------------------------------------------------
 procedure  reqs_default_head( p_emergency IN VARCHAR2,
			       v_cart_id   IN NUMBER) is

-------------------------------------------------------------------------

/*   The default head is run once when the Header record is created.  This
     occurs when the user enters the Req program.  Here you can default in
     any values you wish.  Again BE CAREFUL......


     update icx_shopping_carts
     set    WHATEVER = WHATEVER
     where  cart_id = v_cart_id;

     update icx_cart_distributions
     set    WHATEVER = WHATEVER
     where  cart_id = v_cart_id;


*/


 begin
  -- Custom default code will come here
  -- do nothing;
  null;
 end reqs_default_head;


-------------------------------------------------------------------------
 procedure  reqs_validate_line(p_emergency IN VARCHAR2,
			       v_cart_id number) is
-------------------------------------------------------------------------

/*      Validation of the line

	Please do validation of the lines here.  Remember this routine is run
	ONCE for all lines.  It is run during the submit of the requisition.
	If an error occurs, you should put an error on the error stack.  This
	will stop the submission.  Please make ALL your error checks here.  IF
 	you find an error, put it on the error stack and continue checking.
	Each error you report, plus any we find, will then be reproted to the
 	user at the same time, and in the same way.

 	To add a message to the error stack use
	     add_user_error(v_cart_id, 'YOUR ERROR MESSAGE');

	To get at the lines you can use line processing or set processing.

	LINE

        CURSOR get_info is
        SELECT isc.ANY_COLUMN_YOU_WANT_FROM_ICX_SHOPPING_CARTS
               iscl.ANY_COLUMN_OF_ICX_SHOPPING_CART_LINES
               iscd.ANY_COLUMN_OF_ICX_CART_DISTRIBUTIONS
               iscld.ANY_COLUMN_OF_ICX_CART_LINE_DISTRIBUTIONS
        FROM   icx_cart_distributions iscd,
               icx_cart_line_distributions iscd,
               icx_shopping_cart_lines iscl,
               icx_shopping_carts isc
        WHERE  isc.cart_id = iscl.cart_id
        AND    isc.cart_id = iscd.cart_id
        AND    iscl.cart_line_id = v_cart_line_id
        AND    iscl.cart_line_id = iscld.cart_line_id;



	SET  -- Completely depends on your logic

 	Please only do Line logic, and please TRAP ALL YOUR ERRORS!!!!!


*/

 begin
  -- Custom validation code will come here
  -- do nothing;
  null;
 end reqs_validate_line;


-------------------------------------------------------------------------
 procedure  reqs_validate_head(p_emergency IN VARCHAR2,
			       v_cart_id   IN NUMBER) is
-------------------------------------------------------------------------

/*   You can do your own header validation here.  As in lines, you can
     put your errors directly to our error stack.  In this way, your errors
     look exactly like errors raise by Oracle.  If you find an error, please
     put it on the stack and continue.  In this way, all errors will be reported
     to the user.

     Please do only Header logic, and please TRAP ALL YOUR ERRORS!!!!!


 	To add a message to the error stack use
	     add_user_error(v_cart_id, 'YOUR ERROR MESSAGE');

        CURSOR get_info is
        SELECT isc.ANY_COLUMN_YOU_WANT_FROM_ICX_SHOPPING_CARTS
               iscd.ANY_COLUMN_OF_ICX_CART_DISTRIBUTIONS
        FROM   icx_cart_distributions iscd,
               icx_shopping_carts isc
        WHERE  isc.cart_id = iscd.cart_id
        AND    isc.cart_id = v_cart_id;


*/

 begin
  -- Custom validation code will come here
  -- do nothing;
  null;
 end reqs_validate_head;

end icx_req_custom;

/
