--------------------------------------------------------
--  DDL for Package Body ICX_REQ_ACCT_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_REQ_ACCT_DIST" AS
/* $Header: ICXRQADB.pls 115.5 99/07/17 03:22:32 porting ship $ */


PROCEDURE get_default_account (v_cart_id IN NUMBER,
                               v_cart_line_id IN NUMBER,
                               v_emp_id IN NUMBER,
                               v_oo_id IN NUMBER,
                               v_item_id IN VARCHAR2,
                               v_account_id OUT NUMBER,
                               v_account_num OUT VARCHAR2

) IS

 CURSOR line_default_account(v_cart_id number,v_cart_line_id number,
                             v_item_id number, v_emp_id number,
                             v_oo_id number) IS
        SELECT  hecv.default_code_combination_id employee_default_account_id,
                msi.expense_account
        FROM    hr_employees_current_v hecv,
                mtl_system_items msi,
                icx_shopping_carts isc,
                icx_shopping_cart_lines iscl
        WHERE   msi.INVENTORY_ITEM_ID (+) = iscl.ITEM_ID
        AND     nvl(msi.ORGANIZATION_ID,
                    nvl(isc.DESTINATION_ORGANIZATION_ID,
                        iscl.DESTINATION_ORGANIZATION_ID)) =
                nvl(isc.DESTINATION_ORGANIZATION_ID,
                    iscl.DESTINATION_ORGANIZATION_ID)
        AND     hecv.EMPLOYEE_ID = v_emp_id
        AND     iscl.cart_id = v_cart_id
        AND     iscl.cart_line_id = v_cart_line_id
        AND     nvl(isc.org_id, -9999) = nvl(v_oo_id, -9999)
        AND     nvl(iscl.org_id, -9999) = nvl(v_oo_id, -9999);

      CURSOR chart_account_id IS
      SELECT CHART_OF_ACCOUNTS_ID
      FROM gl_sets_of_books,
           financials_system_parameters fsp
      WHERE gl_sets_of_books.SET_OF_BOOKS_ID = fsp.set_of_books_id;


BEGIN
 null;

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in display acct distributions ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));

END get_default_account;

------------------------------------------------------
PROCEDURE display_acct_distributions (p_cart_line_id IN NUMBER,
                                      p_cart_id IN NUMBER,
                                      p_show_more_lines IN NUMBER DEFAULT NULL,
                          icx_charge_acct_seg1 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg2 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg3 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg4 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg5 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg6 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg7 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg8 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg9 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg10 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg11 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg12 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg13 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg14 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg15 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg16 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg17 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg18 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg19 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg20 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg21 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg22 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg23 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg24 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg25 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg26 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg27 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg28 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg29 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg30 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_account_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_percentage IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_amount IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_id IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          v_error_text IN VARCHAR2 DEFAULT NULL
                                     ) IS

v_cart_line_id      NUMBER := NULL;
v_cart_id           NUMBER := NULL;
v_title             VARCHAR2(80) := NULL;
v_prompts           icx_util.g_prompts_table;
v_encrypted_where   NUMBER := NULL;
v_where_clause      VARCHAR2(1000) := NULL;
v_web_user_id       NUMBER := NULL;
v_responsibility_id NUMBER := NULL;
v_language_code     VARCHAR2(30) := NULL;
v_dcd_name          VARCHAR2(200) := NULL;
v_multirow_color varchar2(30) := NULL;
v_rows_returned     NUMBER := NULL;
v_extended_price     NUMBER := NULL;
v_percentage_value   NUMBER := NULL;

-- total number of lines displayed intially and the increment is 5
-- this value is hard coded
v_fixed_line_count     NUMBER := 5;
v_total_lines_entered  NUMBER := 5;
v_display_lines        NUMBER := NULL;
v_value		varchar2(240) := NULL;

l_values        icx_util.char240_table;
l_pos           NUMBER := 0 ;


-- the following variable hold the charge account values
-- these will be used as hidden variables in the FORM
v_charge_account_seg1  VARCHAR2(240) := NULL;
v_charge_account_seg2  VARCHAR2(240) := NULL;
v_charge_account_seg3  VARCHAR2(240) := NULL;
v_charge_account_seg4  VARCHAR2(240) := NULL;
v_charge_account_seg5  VARCHAR2(240) := NULL;
v_charge_account_seg6  VARCHAR2(240) := NULL;
v_charge_account_seg7  VARCHAR2(240) := NULL;
v_charge_account_seg8  VARCHAR2(240) := NULL;
v_charge_account_seg9  VARCHAR2(240) := NULL;
v_charge_account_seg10  VARCHAR2(240) := NULL;
v_charge_account_seg11  VARCHAR2(240) := NULL;
v_charge_account_seg12  VARCHAR2(240) := NULL;
v_charge_account_seg13  VARCHAR2(240) := NULL;
v_charge_account_seg14  VARCHAR2(240) := NULL;
v_charge_account_seg15  VARCHAR2(240) := NULL;
v_charge_account_seg16  VARCHAR2(240) := NULL;
v_charge_account_seg17  VARCHAR2(240) := NULL;
v_charge_account_seg18  VARCHAR2(240) := NULL;
v_charge_account_seg19  VARCHAR2(240) := NULL;
v_charge_account_seg20  VARCHAR2(240) := NULL;
v_charge_account_seg21  VARCHAR2(240) := NULL;
v_charge_account_seg22  VARCHAR2(240) := NULL;
v_charge_account_seg23  VARCHAR2(240) := NULL;
v_charge_account_seg24  VARCHAR2(240) := NULL;
v_charge_account_seg25  VARCHAR2(240) := NULL;
v_charge_account_seg26  VARCHAR2(240) := NULL;
v_charge_account_seg27  VARCHAR2(240) := NULL;
v_charge_account_seg28  VARCHAR2(240) := NULL;
v_charge_account_seg29  VARCHAR2(240) := NULL;
v_charge_account_seg30  VARCHAR2(240) := NULL;
v_charge_account_num  VARCHAR2(240) := NULL;

v_distribution_header_region VARCHAR2(50) := NULL;
v_distribution_lines_region  VARCHAR2(50) := NULL;

v_display_first varchar2(1000) := NULL;

BEGIN

 IF icx_sec.validateSession('ICX_REQS') THEN

   v_dcd_name := owa_util.get_cgi_env('SCRIPT_NAME');
   v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   v_web_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
   v_responsibility_id  := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

   v_cart_id :=  icx_call.decrypt2(p_cart_id);
   -- v_cart_line_id :=  icx_call.decrypt2(p_cart_line_id);
   -- cart line id is not encrypted from my order page
   v_cart_line_id :=  p_cart_line_id;

   v_total_lines_entered := icx_percentage.COUNT;

   -- Initialise header and line regions
   v_distribution_header_region := 'ICX_CART_LINE_ACCOUNT_HEADER_R';
   v_distribution_lines_region  := 'ICX_CART_LINE_DISTRIBUTIONS_R';

   v_multirow_color := icx_util.get_color('TABLE_DATA_MULTIROW');

   icx_util.getPrompts(601, v_distribution_header_region, v_title, v_prompts);
   icx_util.error_page_setup;

   -- v_encrypted_where := p_where;

   v_where_clause := 'CART_ID =' || v_cart_id || 'AND CART_LINE_ID =' || v_cart_line_id;

   htp.htmlOpen;
   htp.headOpen;
   icx_util.copyright;
   js.scriptOpen;

   htp.p('function submit() {
             // document.ACCOUNT_DISTRIBUTION.cart_id.value = parent.parent.cartId;
             // parent.frames[0].document.ACCOUNT_DISTRIBUTION.submit();
             document.ACCOUNT_DISTRIBUTION.p_user_action.value ="APPLY";
             document.ACCOUNT_DISTRIBUTION.submit();
          }');

   htp.p('function apply_to_all() {
             document.ACCOUNT_DISTRIBUTION.p_user_action.value ="APPLY_TO_ALL";
             // parent.frames[0].document.ACCOUNT_DISTRIBUTION.submit();
             document.ACCOUNT_DISTRIBUTION.submit();
          }');

   htp.p('function show_more_lines() {
             document.ACCOUNT_DISTRIBUTION.p_user_action.value ="MORE_LINES";
             // parent.frames[0].document.ACCOUNT_DISTRIBUTION.submit();
             document.ACCOUNT_DISTRIBUTION.submit();
          }');

   htp.p('function cancel_account() {
             document.ACCOUNT_DISTRIBUTION.p_user_action.value ="CANCEL";
             parent.parent.account_dist="";
             top.switchFrames("my_order");
          }');

   fnd_message.set_name('ICX','ICX_NOT_NUMBER');
   htp.p('function checkNumber(input) {
          var msg = input.value + " '||icx_util.replace_quotes(fnd_message.get)||'";

          var str = input.value;
          for (var i = 0; i < str.length; i++) {
              var ch = str.substring(i, i + 1);
              if ((ch < "0" || "9" < ch) && ch != ".") {
                 alert(msg);
                 return false;
              }
           }
           return true;
          }
         ');

   -- Round the decimal part to 'roundDigits' digits
--    htp.p('function roundDecimals (input, roundDigits) {
--           var integerPart = input.value;
--           var decimalPart;
--           var tempVal;
--           integerPart = Math.floor(integerPart);
--           // added this if condition, bug#585186
--           if (roundDigits == 5)  {
--           tempVal = "" + Math.round(input.value * 100000);
--           }
--           else {
--           tempVal = "" + Math.round(input.value * 100);
--           }
--           decimalPart = tempVal.substring(tempVal.length - roundDigits, tempVal.length);

--           // return(integerPart+"."+decimalPart);
--           input.value = integerPart+"."+decimalPart;

--           }
--         ');
   -- Round the decimal part to 'roundDigits' digits
--    htp.p('function roundDecimalsValue (input, roundDigits) {
--           var integerPart = input;
--           var decimalPart;
--           var tempVal;
--           integerPart = Math.floor(integerPart);
--           // added this if condition, bug#585186
--           if (roundDigits == 5) {
--             tempVal = "" + Math.round(input * 100000);
--           }
--           else {
--             tempVal = "" + Math.round(input * 100);
--           }
--           decimalPart = tempVal.substring(tempVal.length - roundDigits, tempVal.length);

--           return(integerPart+"."+decimalPart);

--           }
	    --         ');


	    --MC: made the following changes for bug # 700664:
-- 	    changed set_percent as follows:
-- 	      after setting the ICX_PERCENT column, also checks to see if
-- 	      the amount totals to the extended price.  If so, adjust the
-- 	      last percent field that has just been set so that percent
-- 	      totals to 100%.
-- 	      Vice versa for set_amount.
-- 	      also changed roundDecimals and roundDecimalsValue s.t b/c it
-- 	      was bahaving strangely in some cases.

	    --added for bug # 700664:
	    htp.p('
		  function roundDecimals (input, roundDigits)
		  {
		  var tmp= roundDecimalsValue(input.value, roundDigits);
		  input.value= tmp;
		  }
		  ');

	    --added for bug # 700664:
	    htp.p('
		  function roundDecimalsValue (input, roundDigits) {
		  var str= "" + Math.round(eval(input) * Math.pow(10, roundDigits));
		  while (str.length <= roundDigits)
		  {
		  str= "0"+str;
		  }
		  var decpoint= str.length- roundDigits;
		  return str.substring(0, decpoint) + "." + str.substring(decpoint, str.length);
		  }');


   htp.p('function get_forward_pos(start_pos) {
          var end_pos=0;
          if (document.ACCOUNT_DISTRIBUTION.elements[start_pos].name == "ICX_AMOUNT") {
	     var name2 = "ICX_PERCENTAGE";
          } else {
             var name2 = "ICX_AMOUNT";
          }
          for (var i=start_pos; i < document.ACCOUNT_DISTRIBUTION.elements.length; i++) {
             if (document.ACCOUNT_DISTRIBUTION.elements[i].name == name2) {
                end_pos=i;
                    break;
                }
         }
         if (end_pos != 0) {
            return end_pos;
         } else {
           if (document.ACCOUNT_DISTRIBUTION.elements[0].name !=  name2) {
              return -1;
           } else {
	      return 0;
           }
         }
        }');

   htp.p('function get_backward_pos(start_pos) {
          var end_pos=0;
          if (document.ACCOUNT_DISTRIBUTION.elements[start_pos].name == "ICX_AMOUNT") {
             var name1 = "ICX_PERCENTAGE";
          } else {
             var name1 = "ICX_AMOUNT";
          }

          var i=start_pos;
          while(i >= 0) {
	      if (document.ACCOUNT_DISTRIBUTION.elements[i].name == name1) {
                  end_pos=i;
                  break;
              } else {
                i = i - 1;
                end_pos = i;
              }
          }
             return end_pos;

          }');


         htp.p('function set_percent(pos,qty,value1,direction) {
               if(direction == 0) {
                  var npos = get_forward_pos(pos);
               } else {
                  var npos = get_backward_pos(pos);
               }
               if (npos >= 0) {
                //  document.ACCOUNT_DISTRIBUTION.elements[npos].value=qty * 100 / value1;
                var tempValue = qty * 100 / value1;
                document.ACCOUNT_DISTRIBUTION.elements[npos].value=roundDecimalsValue(tempValue, 5);

                if (get_total_percent()  !=100 &&
                    get_total_amount() == value1)
                {
                  var newTempValue= (100-get_total_percent())+
                       parseFloat(document.ACCOUNT_DISTRIBUTION.elements[npos].value);
                  document.ACCOUNT_DISTRIBUTION.elements[npos].value=
                       roundDecimalsValue(newTempValue, 5);
                }

               }
	   }');

         htp.p('function set_amount(pos,per,extended,direction) {
                if(direction == 0) {
                   var npos = get_forward_pos(pos);
                } else {
		   var npos = get_backward_pos(pos);
                }
                if (npos >=0) {
                   // document.ACCOUNT_DISTRIBUTION.elements[npos].value=extended * per / 100;
                   var tempValue = extended * per /100;
                   document.ACCOUNT_DISTRIBUTION.elements[npos].value=roundDecimalsValue(tempValue, 2);

                if (get_total_percent()  ==100 &&
                    get_total_amount() !=extended)
                {
                  var newTempValue= (extended-get_total_amount())+
                       parseFloat(document.ACCOUNT_DISTRIBUTION.elements[npos].value);
                   document.ACCOUNT_DISTRIBUTION.elements[npos].value=
                       roundDecimalsValue(newTempValue, 2);
                }


              }
         }');

	       htp.p('function get_total_amount()
		     {
		      var amt=0;
		      for(var i=0;
			  i<document.forms.ACCOUNT_DISTRIBUTION.ICX_AMOUNT.length;
			  i++)
		      {
		       var tmp=
		        parseFloat(document.forms.ACCOUNT_DISTRIBUTION.ICX_AMOUNT[i].value);
		       if (!isNaN(tmp))
		        amt= amt + tmp;
		      }
		      return amt;
		     }');

		     htp.p('function get_total_percent()
			    {
			     var pct=0;
			     for(var i=0;
				 i<document.forms.ACCOUNT_DISTRIBUTION.ICX_PERCENTAGE.length;
				 i++)
			     {
			      var tmp=
			        parseFloat(document.forms.ACCOUNT_DISTRIBUTION.ICX_PERCENTAGE[i].value);
			      if (!isNaN(tmp))
			         pct= pct + tmp;
			      }
			      return pct;
			    } ');

   js.scriptClose;
   htp.title(v_title);
   htp.headClose;

   htp.bodyOpen('','BGCOLOR="#CCFFFF" onLoad="top.winOpen(''nav'', ''my_order'')"');

   htp.header(3, v_title);

   htp.p('<FORM ACTION="' || v_dcd_name || '/icx_req_acct_dist.submit_accounts"  NAME="ACCOUNT_DISTRIBUTION" METHOD="POST">');

   htp.formHidden('p_cart_id', p_cart_id);
   htp.formHidden('p_cart_line_id', icx_call.encrypt2(p_cart_line_id));
   htp.formHidden('p_user_action', '');

   l_pos := l_pos + 3;

   -- call error display procedure
   display_account_errors(v_cart_id, v_cart_line_id);

   IF v_error_text IS NOT NULL THEN
     /* Changed to new font, to be in consistent with other errors
     FND_MESSAGE.SET_NAME('ICX','ICX_ERROR');
     htp.p(htf.bold(FND_MESSAGE.GET));
     htp.br;
     htp.p(htf.bold(v_error_text));
     htp.br;
     htp.br;
     */
     htp.p('<TABLE BORDER=5>');
     htp.p('<TR><TD>' || v_error_text || '</TD></TR>');
     htp.p('</TABLE>');
     htp.br;
   END IF;  /* IF v_error_text */

   ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                           P_PARENT_REGION_CODE    => v_distribution_header_region,
                           P_RESPONSIBILITY_ID     => v_responsibility_id,
                           P_USER_ID               => v_web_user_id,
                           P_WHERE_CLAUSE          => v_where_clause,
                           P_RETURN_PARENTS        => 'T',
                           P_RETURN_CHILDREN       => 'F');


   -- debug, turn on to dump the results table after the ak query
   -- icx_on_utilities2.printPLSQLtables;

   display_account_header(v_extended_price);

   /* Display account distribution lines */


   /* p_show_more_lines holds the number of number of lines displayed.
      If show more lines button is pressed then the total number of lines
      to be displayed will be lines displayed + the fixed line count.
   */
   IF p_show_more_lines IS NOT NULL THEN

    /* If show more lines is clicked then get only the structure, no data
      from AK. Set P_RETURN_PARENTS => 'F'   */
    ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                            P_PARENT_REGION_CODE    => v_distribution_lines_region,
                            P_RESPONSIBILITY_ID     => v_responsibility_id,
                            P_USER_ID               => v_web_user_id,
                            P_WHERE_CLAUSE          => v_where_clause,
                            P_RETURN_PARENTS        => 'F',
                            P_RETURN_CHILDREN       => 'F');

    print_lines_header;

    -- determine if amount is ahead of quantity or quantity is ahead of amount
    v_display_first := NULL;
    for j IN 0..ak_query_pkg.g_items_table.LAST LOOP
        if ak_query_pkg.g_items_table(j).attribute_code = 'ICX_PERCENTAGE' and
           v_display_first is NULL then
           v_display_first := 'ICX_PERCENTAGE';
           exit;
        elsif ak_query_pkg.g_items_table(j).attribute_code = 'ICX_AMOUNT' and
	   v_display_first is NULL then
           v_display_first := 'ICX_AMOUNT';
           exit;
        end if;
    end loop;

    IF v_error_text IS NULL THEN
      v_display_lines := p_show_more_lines + v_fixed_line_count;
    ELSE
      v_display_lines := p_show_more_lines;
    END IF; /* IF v_error_text */

    FOR r IN 1 .. v_display_lines LOOP

      htp.p('<TR BGColor="#'||v_multirow_color||'">');

      FOR i IN 0 .. ak_query_pkg.g_items_table.LAST LOOP
      -- FOR i IN 1 .. ak_query_pkg.g_items_table.LAST LOOP

        v_value := NULL;

        IF ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        AND ak_query_pkg.g_items_table(i).secured_column = 'F'
        AND ak_query_pkg.g_items_table(i).item_style = 'HIDDEN' THEN

          -- The condition icx_distribution_id.count >= r is required to
          -- prevent a memory out of bound value.
          -- The hidden values are returned only for those displayed in the
          -- browser. So if one distribution id is displayed as hidden value
          -- the count will be 1. If 5 distribution ids are displayed as hidden
          -- distribution count will be 5.
          IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DISTRIBUTION_ID'  AND (icx_distribution_id.COUNT >= r) THEN

            v_value := icx_distribution_id(r);
            htp.formHidden(cname => ak_query_pkg.g_items_table(i).attribute_code , cvalue => v_value);
            l_pos := l_pos + 1;

          END IF;  /* ICX_DISTRIBUTION_ID */
        END IF;  /* item_style = 'HIDDEN' */

	IF ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        AND ak_query_pkg.g_items_table(i).secured_column = 'F'
        AND ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' THEN


            IF r <= v_total_lines_entered THEN
              IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG1' THEN
              v_value := icx_charge_acct_seg1(r);
              ----------------------------------------------------------------
              -- Note:
              -- Get the display only segment value to populate the
              -- hidden fields later. This is done for all the charge accounts.
              -- Just get the value for only one as this the same for all the
              -- attributes which are turned to display only.
              -- v_charge_account_seg1 := icx_charge_acct_seg1(1);
              -- This is done repeatedly in this loop rather than in a different
              -- loop to avoid performance degradation. (avoding another loop!)
              ----------------------------------------------------------------
              v_charge_account_seg1 := icx_charge_acct_seg1(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG2' THEN
              v_value := icx_charge_acct_seg2(r);
              v_charge_account_seg2 := icx_charge_acct_seg2(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG3' THEN
              v_value := icx_charge_acct_seg3(r);
              v_charge_account_seg3 := icx_charge_acct_seg3(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG4' THEN
              v_value := icx_charge_acct_seg4(r);
              v_charge_account_seg4 := icx_charge_acct_seg4(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG5' THEN
              v_value := icx_charge_acct_seg5(r);
              v_charge_account_seg5 := icx_charge_acct_seg5(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG6' THEN
              v_value := icx_charge_acct_seg6(r);
              v_charge_account_seg6 := icx_charge_acct_seg6(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG7' THEN
              v_value := icx_charge_acct_seg7(r);
              v_charge_account_seg7 := icx_charge_acct_seg7(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG8' THEN
              v_value := icx_charge_acct_seg8(r);
              v_charge_account_seg8 := icx_charge_acct_seg8(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG9' THEN
              v_value := icx_charge_acct_seg9(r);
              v_charge_account_seg9 := icx_charge_acct_seg9(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG10' THEN
              v_value := icx_charge_acct_seg10(r);
              v_charge_account_seg10 := icx_charge_acct_seg10(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG11' THEN
              v_value := icx_charge_acct_seg11(r);
              v_charge_account_seg11 := icx_charge_acct_seg11(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG12' THEN
              v_value := icx_charge_acct_seg12(r);
              v_charge_account_seg12 := icx_charge_acct_seg12(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG13' THEN
              v_value := icx_charge_acct_seg13(r);
              v_charge_account_seg13 := icx_charge_acct_seg13(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG14' THEN
              v_value := icx_charge_acct_seg14(r);
              v_charge_account_seg14 := icx_charge_acct_seg14(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG15' THEN
              v_value := icx_charge_acct_seg15(r);
              v_charge_account_seg15 := icx_charge_acct_seg15(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG16' THEN
              v_value := icx_charge_acct_seg16(r);
              v_charge_account_seg16 := icx_charge_acct_seg16(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG17' THEN
              v_value := icx_charge_acct_seg17(r);
              v_charge_account_seg17 := icx_charge_acct_seg17(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG18' THEN
              v_value := icx_charge_acct_seg18(r);
              v_charge_account_seg18 := icx_charge_acct_seg18(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG19' THEN
              v_value := icx_charge_acct_seg19(r);
              v_charge_account_seg19 := icx_charge_acct_seg19(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG20' THEN
              v_value := icx_charge_acct_seg20(r);
              v_charge_account_seg20 := icx_charge_acct_seg20(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG21' THEN
              v_value := icx_charge_acct_seg21(r);
              v_charge_account_seg21 := icx_charge_acct_seg21(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG22' THEN
              v_value := icx_charge_acct_seg22(r);
              v_charge_account_seg22 := icx_charge_acct_seg22(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG23' THEN
              v_value := icx_charge_acct_seg23(r);
              v_charge_account_seg23 := icx_charge_acct_seg23(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG24' THEN
              v_value := icx_charge_acct_seg24(r);
              v_charge_account_seg24 := icx_charge_acct_seg24(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG25' THEN
              v_value := icx_charge_acct_seg25(r);
              v_charge_account_seg25 := icx_charge_acct_seg25(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG26' THEN
              v_value := icx_charge_acct_seg26(r);
              v_charge_account_seg26 := icx_charge_acct_seg26(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG27' THEN
              v_value := icx_charge_acct_seg27(r);
              v_charge_account_seg27 := icx_charge_acct_seg27(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG28' THEN
              v_value := icx_charge_acct_seg28(r);
              v_charge_account_seg28 := icx_charge_acct_seg28(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG29' THEN
              v_value := icx_charge_acct_seg29(r);
              v_charge_account_seg29 := icx_charge_acct_seg29(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG30' THEN
              v_value := icx_charge_acct_seg30(r);
              v_charge_account_seg30 := icx_charge_acct_seg30(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_NUM' THEN
              v_value := icx_charge_account_num(r);
              v_charge_account_num := icx_charge_account_num(1);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PERCENTAGE' THEN
              v_value := icx_percentage(r);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_AMOUNT' THEN
              v_value := icx_amount(r);
              ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_DISTRIBUTION_NUM' THEN
              v_value := icx_distribution_num(r);
              END IF; /* ak_query_pkg. ... ICX_ ... */
            ELSE
              v_value := NULL;
            END IF;  /* i < v_total_lines_entered */

            IF ak_query_pkg.g_items_table(i).update_flag = 'Y' THEN
		 IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PERCENTAGE'  THEN
                    IF v_display_first = ak_query_pkg.g_items_table(i).attribute_code THEN
                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'|| v_value
||'" onChange=''if(!checkNumber(this)) { this.focus();this.value="";} else {roundDecimals(this, 5); set_amount(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',0);}''>', crowspan => 1);
                    ELSE
                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'|| v_value
||'" onChange=''if(!checkNumber(this)) { this.focus(); this.value="";} else {roundDecimals(this, 5); set_amount(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',1);}''>', crowspan => 1);
                    END IF;

               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_AMOUNT' THEN
                    IF v_display_first = ak_query_pkg.g_items_table(i).attribute_code THEN
                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'|| v_value
||'" onChange='' if (!checkNumber(this)) { this.focus(); this.value="";} else {roundDecimals(this, 2); set_percent(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',0);}''>', crowspan => 1);
                    ELSE
                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'||
v_value ||'" onChange='' if (!checkNumber(this)) { this.focus(); this.value="";} else {roundDecimals(this, 2); set_percent(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',1);}''>', crowspan => 1);
                    END IF;
               ELSE
                    htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'|| v_value
||'">', crowspan => 1);
               END IF;

               l_pos := l_pos + 1;
            ELSE
               -- Print for display only; pass that as a hidden value

               IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG1'  THEN
                v_value := v_charge_account_seg1;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG2'  THEN
                v_value := v_charge_account_seg2;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG3'  THEN
                v_value := v_charge_account_seg3;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG4'  THEN
                v_value := v_charge_account_seg4;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG5'  THEN
                v_value := v_charge_account_seg5;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG6'  THEN
                v_value := v_charge_account_seg6;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG7'  THEN
                v_value := v_charge_account_seg7;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG8'  THEN
                v_value := v_charge_account_seg8;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG9'  THEN
                v_value := v_charge_account_seg9;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG10'  THEN
                v_value := v_charge_account_seg10;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG11'  THEN
                v_value := v_charge_account_seg11;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG12'  THEN
                v_value := v_charge_account_seg12;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG13'  THEN
                v_value := v_charge_account_seg13;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG14'  THEN
                v_value := v_charge_account_seg14;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG15'  THEN
                v_value := v_charge_account_seg15;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG16'  THEN
                v_value := v_charge_account_seg16;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG17'  THEN
                v_value := v_charge_account_seg17;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG18'  THEN
                v_value := v_charge_account_seg18;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG19'  THEN
                v_value := v_charge_account_seg19;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG20'  THEN
                v_value := v_charge_account_seg20;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG21'  THEN
                v_value := v_charge_account_seg21;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG22'  THEN
                v_value := v_charge_account_seg22;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG23'  THEN
                v_value := v_charge_account_seg23;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG24'  THEN
                v_value := v_charge_account_seg24;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG25'  THEN
                v_value := v_charge_account_seg25;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG26'  THEN
                v_value := v_charge_account_seg26;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG27'  THEN
                v_value := v_charge_account_seg27;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG28'  THEN
                v_value := v_charge_account_seg28;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG29'  THEN
                v_value := v_charge_account_seg29;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG30'  THEN
                v_value := v_charge_account_seg30;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCOUNT_NUM'  THEN
                v_value := v_charge_account_num;
               END IF; /* ak.. attribute_code = 'ICX_...' */

               htp.formHidden(cname => ak_query_pkg.g_items_table(i).attribute_code , cvalue => v_value);
               l_pos := l_pos + 1;

               IF v_value IS NULL THEN
                 htp.tableData(cvalue => '&nbsp', crowspan => 1);
               ELSE
                htp.tableData(cvalue => v_value, crowspan => 1);
               END IF; /* IF v_value */

            END IF; /* update_flag = 'Y' */

        END IF; /* node_display_flag = 'Y' */

      END LOOP; /* FOR i in items_table */

      htp.tableRowClose;

    END LOOP; /* FOR 1 .. v_display_lines */

   ELSE
    /* get the data from AK */
    ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                            P_PARENT_REGION_CODE    => v_distribution_lines_region,
                            P_RESPONSIBILITY_ID     => v_responsibility_id,
                            P_USER_ID               => v_web_user_id,
                            P_WHERE_CLAUSE          => v_where_clause,
                            P_RETURN_PARENTS        => 'T',
                            P_RETURN_CHILDREN       => 'F');

    -- to debug, uncomment the following dump the results table after
    -- the ak query
    -- icx_on_utilities2.printPLSQLtables;

    print_lines_header;

    v_rows_returned := ak_query_pkg.g_results_table.count;

    IF (v_rows_returned >= v_fixed_line_count) THEN
        v_display_lines := v_rows_returned + v_fixed_line_count;
    ELSE
        v_display_lines := v_fixed_line_count;
    END IF; /* if ak_query_pkg.g_result_table.count ... */

    -- determine if amount is ahead of quantity or quantity is ahead of amount
    v_display_first := NULL;

    FOR j IN 0..ak_query_pkg.g_items_table.LAST LOOP
        IF ak_query_pkg.g_items_table(j).attribute_code = 'ICX_PERCENTAGE' AND
           v_display_first is NULL THEN
           v_display_first := 'ICX_PERCENTAGE';
           EXIT;
        ELSIF ak_query_pkg.g_items_table(j).attribute_code = 'ICX_AMOUNT' AND
           v_display_first is NULL THEN
           v_display_first := 'ICX_AMOUNT';
           EXIT;
        END IF;
    END LOOP;

    IF v_rows_returned > 0 THEN
     FOR r IN 0..ak_query_pkg.g_results_table.LAST LOOP

      icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),l_values);

      htp.p('<TR BGColor="#'||v_multirow_color||'">');

      FOR i IN 0..ak_query_pkg.g_items_table.LAST LOOP

        IF ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        AND ak_query_pkg.g_items_table(i).secured_column = 'F'
        AND ak_query_pkg.g_items_table(i).item_style = 'HIDDEN' THEN

           htp.formHidden(cname => ak_query_pkg.g_items_table(i).attribute_code , cvalue => replace(l_values(ak_query_pkg.g_items_table(i).value_id),'"','&quot;'));
           l_pos := l_pos + 1;
        END IF;

	IF ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        AND ak_query_pkg.g_items_table(i).secured_column = 'F'
        AND ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' THEN

            IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PERCENTAGE'
              THEN
              v_percentage_value := l_values(ak_query_pkg.g_items_table(i).value_id);
            END IF; /* ICX_PERCENTAGE */

            IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_AMOUNT'
            THEN
              /* aahmad 1/28/98: Changed from ROUND to TO_CHAR.  Bug no. 585194 */
              /* v_value :=  ROUND(v_extended_price * (v_percentage_value/100), 2); */
              v_value := TO_CHAR(v_extended_price * (v_percentage_value/100), 'FM99999999999999999999999999999999999990D00');
            ELSE
              v_value := l_values(ak_query_pkg.g_items_table(i).value_id);
            END IF;

            IF ak_query_pkg.g_items_table(i).update_flag = 'Y' THEN
		 if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PERCENTAGE'  then
                    if v_display_first = ak_query_pkg.g_items_table(i).attribute_code then
                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'|| v_value
||'" onChange=''if(!checkNumber(this)) { this.focus();this.value="";} else {roundDecimals(this, 5); set_amount(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',0);}''>', crowspan => 1);
                    else
                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'||
v_value ||'" onChange=''if(!checkNumber(this)) { this.focus();this.value="";} else {roundDecimals(this, 5); set_amount(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',1);}''>', crowspan => 1);
                    end if;
               elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_AMOUNT' then
                    if v_display_first = ak_query_pkg.g_items_table(i).attribute_code then
                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'|| v_value
||'" onChange='' if (!checkNumber(this)) { this.focus(); this.value="";} else {roundDecimals(this, 2); set_percent(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',0);}''>', crowspan => 1);
                    else
                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'|| v_value
||'" onChange='' if (!checkNumber(this)) { this.focus(); this.value="";} else {roundDecimals(this, 2); set_percent(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',1);}''>', crowspan => 1);
                    end if;
               else
                  htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length ||
' VALUE = "'|| replace(v_value,'"','&quot;') ||'">', crowspan => 1);
               end if;

               l_pos := l_pos + 1;

            ELSE
               htp.formHidden(cname => ak_query_pkg.g_items_table(i).attribute_code , cvalue => replace(l_values(ak_query_pkg.g_items_table(i).value_id),'"','&quot;'));
               l_pos := l_pos + 1;
               -- Print as display only pass that data as hidden
               htp.tableData(cvalue => replace(l_values(ak_query_pkg.g_items_table(i).value_id),'"','&quot;'), crowspan => 1);

               -- capture the value to be used as hidden fields later for
               -- blank lines
               IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG1'  THEN
               v_charge_account_seg1 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG2'  THEN
               v_charge_account_seg2 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG3'  THEN
               v_charge_account_seg3 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG4'  THEN
               v_charge_account_seg4 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG5'  THEN
               v_charge_account_seg5 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG6'  THEN
               v_charge_account_seg6 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG7'  THEN
               v_charge_account_seg7 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG8'  THEN
               v_charge_account_seg8 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG9'  THEN
               v_charge_account_seg9 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG10'  THEN
               v_charge_account_seg10 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG11'  THEN
               v_charge_account_seg11 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG12'  THEN
               v_charge_account_seg12 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG13'  THEN
               v_charge_account_seg13 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG14'  THEN
               v_charge_account_seg14 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG15'  THEN
               v_charge_account_seg16 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG16'  THEN
               v_charge_account_seg16 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG17'  THEN
               v_charge_account_seg17 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG18'  THEN
               v_charge_account_seg18 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG19'  THEN
               v_charge_account_seg19 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG20'  THEN
               v_charge_account_seg20 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG21'  THEN
               v_charge_account_seg21 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG22'  THEN
               v_charge_account_seg22 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG23'  THEN
               v_charge_account_seg23 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG24'  THEN
               v_charge_account_seg24 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG25'  THEN
               v_charge_account_seg25 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG26'  THEN
               v_charge_account_seg26 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG27'  THEN
               v_charge_account_seg27 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG28'  THEN
               v_charge_account_seg28 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG29'  THEN
               v_charge_account_seg29 :=  l_values(ak_query_pkg.g_items_table(i).value_id);
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG30'  THEN
               v_charge_account_seg30 :=  l_values(ak_query_pkg.g_items_table(i).value_id);

               END IF; /* ak.. attribute_code = 'ICX_...' */

            END IF; /* update_flag = 'Y' */

        END IF; /* node_dispaly_flag = 'Y' */

      END LOOP; /* FOR i in items_table */

      htp.tablerowClose;

     END LOOP; /* FOR r in ... */

    END IF; /* IF v_rows_returned > 1 */

    /* Show  few more lines (v_fixed_line_count) as blank lines for entry */
    FOR r IN v_rows_returned + 1 .. v_display_lines LOOP

      htp.p('<TR BGColor="#'||v_multirow_color||'">');

      FOR i IN 0..ak_query_pkg.g_items_table.LAST LOOP

	IF ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
        AND ak_query_pkg.g_items_table(i).secured_column = 'F'
        AND ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' THEN

            v_value := NULL;

            IF ak_query_pkg.g_items_table(i).update_flag = 'Y' THEN
		 if ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PERCENTAGE'  then

                    if v_display_first = ak_query_pkg.g_items_table(i).attribute_code then


                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'||
v_value ||'" onChange=''if(!checkNumber(this)) { this.focus();this.value="";} else {roundDecimals(this, 5); set_amount(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',0);}''>', crowspan => 1);

                    else

                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'||
v_value ||'" onChange=''if(!checkNumber(this)) { this.focus();this.value="";} else {roundDecimals(this, 5); set_amount(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',1);}''>', crowspan => 1);


                    end if;

               elsif ak_query_pkg.g_items_table(i).attribute_code = 'ICX_AMOUNT' then

                    if v_display_first = ak_query_pkg.g_items_table(i).attribute_code then

                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'||
v_value ||'" onChange='' if (!checkNumber(this)) { this.focus(); this.value="";} else {roundDecimals(this, 2); set_percent(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',0);}''>', crowspan => 1);


                    else



                       htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'||
v_value ||'" onChange='' if (!checkNumber(this)) { this.focus(); this.value="";} else {roundDecimals(this, 2); set_percent(' || to_char(l_pos) || ',this.value,' || v_extended_price || ',1);}''>', crowspan => 1);


                    end if;

               else
               -- htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code || ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length ||
-- ' MAXLENGTH=' || ak_query_pkg.g_items_table(i).attribute_value_length || ' VALUE = "">', crowspan => 1);
               -- htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code ||
-- ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length || ' VALUE = "'|| v_value ||'">', crowspan => 1);
                 htp.tableData(cvalue => '<INPUT TYPE="TEXT" NAME = ' || ak_query_pkg.g_items_table(i).attribute_code
|| ' SIZE=' || ak_query_pkg.g_items_table(i).display_value_length ||'>', crowspan => 1);
               end if;

               l_pos := l_pos + 1;
            ELSE
               -- Print for display only; pass that as a hidden value

               IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG1'  THEN
                v_value := v_charge_account_seg1;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG2'  THEN
                v_value := v_charge_account_seg2;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG3'  THEN
                v_value := v_charge_account_seg3;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG4'  THEN
                v_value := v_charge_account_seg4;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG5'  THEN
                v_value := v_charge_account_seg5;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG6'  THEN
                v_value := v_charge_account_seg6;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG7'  THEN
                v_value := v_charge_account_seg7;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG8'  THEN
                v_value := v_charge_account_seg8;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG9'  THEN
                v_value := v_charge_account_seg9;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG10'  THEN
                v_value := v_charge_account_seg10;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG11'  THEN
                v_value := v_charge_account_seg11;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG12'  THEN
                v_value := v_charge_account_seg12;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG13'  THEN
                v_value := v_charge_account_seg13;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG14'  THEN
                v_value := v_charge_account_seg14;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG15'  THEN
                v_value := v_charge_account_seg15;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG16'  THEN
                v_value := v_charge_account_seg16;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG17'  THEN
                v_value := v_charge_account_seg17;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG18'  THEN
                v_value := v_charge_account_seg18;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG19'  THEN
                v_value := v_charge_account_seg19;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG20'  THEN
                v_value := v_charge_account_seg20;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG21'  THEN
                v_value := v_charge_account_seg21;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG22'  THEN
                v_value := v_charge_account_seg22;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG23'  THEN
                v_value := v_charge_account_seg23;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG24'  THEN
                v_value := v_charge_account_seg24;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG25'  THEN
                v_value := v_charge_account_seg25;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG26'  THEN
                v_value := v_charge_account_seg26;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG27'  THEN
                v_value := v_charge_account_seg27;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG28'  THEN
                v_value := v_charge_account_seg28;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG29'  THEN
                v_value := v_charge_account_seg29;
               ELSIF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_CHARGE_ACCT_SEG30'  THEN
                v_value := v_charge_account_seg30;
               END IF; /* ak.. attribute_code = 'ICX_...' */

               htp.formHidden(cname => ak_query_pkg.g_items_table(i).attribute_code , cvalue => v_value);
               l_pos := l_pos + 1;

               IF v_value IS NULL THEN
                 htp.tableData(cvalue => '&nbsp', crowspan => 1);
               ELSE
                htp.tableData(cvalue => v_value, crowspan => 1);
               END IF; /* IF v_value */

            END IF; /* update_flag = 'Y' */

        END IF; /* node_display_flag = 'Y' */

      END LOOP; /* FOR i in items_table */

      htp.tableRowClose;

    END LOOP; /* FOR v_rows_returned + 1 */

   END IF; /*  IF p_show_more_lines */


  htp.tableClose;

  htp.formHidden('p_show_more_lines', v_display_lines);
  l_pos := l_pos + 1;

  htp.br;
  htp.br;

  htp.formClose;
  htp.bodyClose;
  htp.htmlClose;

 END IF;  /* validate session */

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in display acct distributions ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END display_acct_distributions;


------------------------------------------------------
PROCEDURE display_account_header (v_extended_price OUT NUMBER) IS

y_table             icx_util.char240_table;

v_shopper_id        NUMBER := NULL;
v_shopper_name      VARCHAR2(250) := NULL;
v_location_id       NUMBER := NULL;
v_location_code     VARCHAR2(240) := NULL;
v_org_id            NUMBER := NULL;
v_org_code          VARCHAR2(30) := NULL;
v_currency          VARCHAR2(30) := NULL;
v_precision         NUMBER := NULL;
v_money_fmt_mask    VARCHAR2(32) := NULL;
v_ext_amount        NUMBER := NULL;

BEGIN

 IF icx_sec.validateSession('ICX_REQS') THEN

  v_shopper_id := icx_sec.getID(icx_sec.PV_INT_CONTACT_ID);
  ICX_REQ_NAVIGATION.shopper_info(v_shopper_id, v_shopper_name, v_location_id, v_location_code, v_org_id, v_org_code);
  ICX_REQ_NAVIGATION.get_currency(v_org_id, v_currency, v_precision, v_money_fmt_mask);
  v_money_fmt_mask := fnd_currency.safe_get_format_mask(v_currency, 30);

  htp.tableOpen('BORDER=0');

  icx_util.transfer_Row_To_Column( ak_query_pkg.g_results_table(ak_query_pkg.g_results_table.FIRST),y_table);

  FOR i IN ak_query_pkg.g_items_table.FIRST  ..  ak_query_pkg.g_items_table.LAST LOOP

  IF  ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
      AND ak_query_pkg.g_items_table(i).secured_column = 'F'
      AND ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' THEN

    htp.tableRowOpen;

    htp.tableData(cvalue => ak_query_pkg.g_items_table(i).attribute_label_long, calign => 'RIGHT', cattributes=>'VALIGN=CENTER');

    /* Leave a blank space between the prompt and the value */
    htp.tableData(cvalue => '&nbsp');

    htp.p('<TD border=1 bgcolor=#FFFFFF>');
    htp.p('<B>');
    IF ak_query_pkg.g_items_table(i).italic = 'Y' THEN
       htp.p('<I>');
    END IF;

    /* Format ext. price before displaying */
    IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE' THEN
      v_ext_amount := y_table(ak_query_pkg.g_items_table(i).value_id);
      htp.p(TO_CHAR(v_ext_amount, v_money_fmt_mask));
    ELSE
      htp.p(y_table(ak_query_pkg.g_items_table(i).value_id));
    END IF; /* ICX_EXT_PRICE */

       -- htp.tableData(cvalue => icx_on_utilities.formatText(y_table(ak_query_pkg.g_items_table(i).value_id),ak_query_pkg.g_items_table(i).bold,ak_query_pkg.g_items_table(i).italic),
-- calign => ak_query_pkg.g_items_table(i).horizontal_alignment, cattributes => 'VALIGN="'||ak_query_pkg.g_items_table(i).vertical_alignment||'"');

    IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_EXT_PRICE'
        THEN
       v_extended_price := y_table(ak_query_pkg.g_items_table(i).value_id);
    END IF; /* ICX_EXT_PRICE */

    IF ak_query_pkg.g_items_table(i).italic = 'Y' THEN
       htp.p('</I>');
    END IF;
    htp.p('</B>');
    htp.p('</TD>');


    htp.tableRowClose;

  END IF; /* aK_query... display_flag = 'Y' */

  END LOOP; /* for i in ... */

  htp.tableClose;
  htp.br;

 END IF;  /* validate session */

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in display acct header ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END display_account_header;


------------------------------------------------------
PROCEDURE print_lines_header IS

v_table_attribute VARCHAR2(50) := NULL;

BEGIN

 IF icx_sec.validateSession('ICX_REQS') THEN

  htp.p('<TABLE BORDER=5 bgcolor=''#F8F8F8''>');
  htp.p('<TR bgcolor=''#D8D8D8''>');

  v_table_attribute := ' COLSPAN=1';

  FOR i IN ak_query_pkg.g_items_table.FIRST  ..  ak_query_pkg.g_items_table.LAST LOOP
   IF (ak_query_pkg.g_items_table(i).item_style <> 'HIDDEN' AND
       ak_query_pkg.g_items_table(i).node_display_flag = 'Y' AND
       ak_query_pkg.g_items_table(i).secured_column <> 'T')  THEN

     htp.p( '<TD' || v_table_attribute || ' ALIGN="CENTER" >' || ak_query_pkg.g_items_table(i).attribute_label_long  || '</TD>' );

    END IF; /* if ak_query_pkg ... <> HIDDEN */

  END LOOP; /* FOR in ak_query_pkg ... */

  -- Leave a thin blank line border between the header and the table rows
  htp.p('</TR><TR></TR><TR></TR><TR></TR>');

 END IF;  /* validate session */

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in print lines header ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END print_lines_header;


------------------------------------------------------
PROCEDURE print_action_buttons IS

v_order_button_text VARCHAR2(50) := NULL;
v_language_code VARCHAR2(30) := NULL;

BEGIN

 IF icx_sec.validateSession('ICX_REQS') THEN
   v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

   htp.htmlOpen;
   htp.headOpen;
   htp.headClose;

   htp.bodyOpen('','BGCOLOR="#CCFFFF" onLoad="parent.parent.winOpen(''nav'',''my_order'');"');

   htp.tableOpen('border=0');
   htp.tableRowOpen;

           -- Show more lines button
           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('ICX','ICX_SHOW_MORE_LINES');
           v_order_button_text := FND_MESSAGE.GET;
           icx_util.DynamicButton(P_ButtonText      => v_order_button_text,
                                  P_ImageFileName   => 'FNDBSBMT.gif',
                                  P_OnMouseOverText => v_order_button_text,
                                  P_HyperTextCall   => 'javascript:parent.frames[0].show_more_lines()',
                                  P_LanguageCode    => v_language_code,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

           -- Apply to all lines
           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('ICX','ICX_APPLY_TO_ALL_LINES');
           v_order_button_text := FND_MESSAGE.GET;
           icx_util.DynamicButton(P_ButtonText      => v_order_button_text,
                                  P_ImageFileName   => 'FNDBSBMT.gif',
                                  P_OnMouseOverText => v_order_button_text,
                                  -- P_HyperTextCall   => 'javascript:submit()',
                                  P_HyperTextCall   => 'javascript:parent.frames[0].apply_to_all()',
                                  P_LanguageCode    => v_language_code,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

           -- Cancel button
           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('ICX','ICX_CANCEL');
           v_order_button_text := FND_MESSAGE.GET;
           icx_util.DynamicButton(P_ButtonText      => v_order_button_text,
                                  P_ImageFileName   => 'FNDBCNCL.gif',
                                  P_OnMouseOverText => v_order_button_text,
                                  -- P_HyperTextCall   => 'javascript:cancel_account()',
                                  P_HyperTextCall   => 'javascript:parent.frames[0].cancel_account()',
                                  P_LanguageCode    => v_language_code,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

           -- Apply button
           htp.p('<TD>');
           FND_MESSAGE.SET_NAME('ICX','ICX_APPLY_CHANGES');
           v_order_button_text := FND_MESSAGE.GET;
           icx_util.DynamicButton(P_ButtonText      => v_order_button_text,
                                  P_ImageFileName   => 'FNDBAPLY.gif',
                                  P_OnMouseOverText => v_order_button_text,
                                  P_HyperTextCall   => 'javascript:parent.frames[0].submit()',
                                  P_LanguageCode    => v_language_code,
                                  P_JavaScriptFlag  => FALSE);
           htp.p('</TD>');

   htp.tableRowClose;
   htp.tableClose;

   htp.bodyClose;
   htp.htmlClose;

 END IF; /* validate session */


EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in print action buttons ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END print_action_buttons;

------------------------------------------------------
PROCEDURE submit_accounts(p_cart_id IN NUMBER,
                          p_cart_line_id IN NUMBER,
                          p_user_action IN VARCHAR2 DEFAULT NULL,
                          p_show_more_lines IN NUMBER DEFAULT NULL,
                          icx_charge_acct_seg1 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg2 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg3 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg4 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg5 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg6 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg7 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg8 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg9 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg10 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg11 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg12 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg13 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg14 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg15 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg16 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg17 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg18 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg19 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg20 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg21 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg22 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg23 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg24 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg25 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg26 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg27 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg28 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg29 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg30 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_account_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_percentage IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_amount IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_id IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty
         ) IS

v_cart_id          NUMBER := NULL;
v_cart_line_id     NUMBER := NULL;
v_error_count      NUMBER := NULL;
v_error_text       VARCHAR2(200) := NULL;

 CURSOR  distribution_errors(l_cart_id NUMBER, l_cart_line_id NUMBER)  IS
      SELECT COUNT(distribution_num)
      FROM  icx_req_cart_errors
      WHERE cart_id = l_cart_id
      AND   cart_line_id = l_cart_line_id
      AND   distribution_num IS NOT NULL;

BEGIN

    v_cart_id := icx_call.decrypt2(p_cart_id);
    v_cart_line_id := icx_call.decrypt2(p_cart_line_id);

    IF p_user_action = 'MORE_LINES' THEN

      -- Call display function with p_more_lines to display more lines
      display_acct_distributions (icx_call.decrypt2(p_cart_line_id) ,
                                  p_cart_id ,
                                  p_show_more_lines ,
                                  icx_charge_acct_seg1,
                                  icx_charge_acct_seg2,
                                  icx_charge_acct_seg3,
                                  icx_charge_acct_seg4,
                                  icx_charge_acct_seg5,
                                  icx_charge_acct_seg6,
                                  icx_charge_acct_seg7,
                                  icx_charge_acct_seg8,
                                  icx_charge_acct_seg9,
                                  icx_charge_acct_seg10,
                                  icx_charge_acct_seg11,
                                  icx_charge_acct_seg12,
                                  icx_charge_acct_seg13,
                                  icx_charge_acct_seg14,
                                  icx_charge_acct_seg15,
                                  icx_charge_acct_seg16,
                                  icx_charge_acct_seg17,
                                  icx_charge_acct_seg18,
                                  icx_charge_acct_seg19,
                                  icx_charge_acct_seg20,
                                  icx_charge_acct_seg21,
                                  icx_charge_acct_seg22,
                                  icx_charge_acct_seg23,
                                  icx_charge_acct_seg24,
                                  icx_charge_acct_seg25,
                                  icx_charge_acct_seg26,
                                  icx_charge_acct_seg27,
                                  icx_charge_acct_seg28,
                                  icx_charge_acct_seg29,
                                  icx_charge_acct_seg30,
                                  icx_charge_account_num,
                                  icx_percentage,
                                  icx_amount,
                                  icx_distribution_num,
                                  icx_distribution_id);

       RETURN;
    END IF;  /* if p_user_action = 'MORE_LINES' */

    IF p_user_action = 'APPLY' THEN
       apply_account_distributions(v_cart_id ,
                                  v_cart_line_id ,
                                  icx_charge_acct_seg1,
                                  icx_charge_acct_seg2,
                                  icx_charge_acct_seg3,
                                  icx_charge_acct_seg4,
                                  icx_charge_acct_seg5,
                                  icx_charge_acct_seg6,
                                  icx_charge_acct_seg7,
                                  icx_charge_acct_seg8,
                                  icx_charge_acct_seg9,
                                  icx_charge_acct_seg10,
                                  icx_charge_acct_seg11,
                                  icx_charge_acct_seg12,
                                  icx_charge_acct_seg13,
                                  icx_charge_acct_seg14,
                                  icx_charge_acct_seg15,
                                  icx_charge_acct_seg16,
                                  icx_charge_acct_seg17,
                                  icx_charge_acct_seg18,
                                  icx_charge_acct_seg19,
                                  icx_charge_acct_seg20,
                                  icx_charge_acct_seg21,
                                  icx_charge_acct_seg22,
                                  icx_charge_acct_seg23,
                                  icx_charge_acct_seg24,
                                  icx_charge_acct_seg25,
                                  icx_charge_acct_seg26,
                                  icx_charge_acct_seg27,
                                  icx_charge_acct_seg28,
                                  icx_charge_acct_seg29,
                                  icx_charge_acct_seg30,
                                  icx_charge_account_num,
                                  icx_percentage,
                                  icx_amount,
                                  icx_distribution_num,
                                  icx_distribution_id,
                                  v_error_text);

      -- Query the error table for this line where distribution_num is not null
      open distribution_errors (v_cart_id, v_cart_line_id);
      fetch distribution_errors into v_error_count;
      close distribution_errors;

      IF  ((NVL(v_error_count, 0)) > 0) OR (v_error_text IS NOT NULL) THEN
        -- call distributions display page to display errors
      display_acct_distributions (icx_call.decrypt2(p_cart_line_id) ,
                                  p_cart_id ,
                                  p_show_more_lines,
                                  icx_charge_acct_seg1,
                                  icx_charge_acct_seg2,
                                  icx_charge_acct_seg3,
                                  icx_charge_acct_seg4,
                                  icx_charge_acct_seg5,
                                  icx_charge_acct_seg6,
                                  icx_charge_acct_seg7,
                                  icx_charge_acct_seg8,
                                  icx_charge_acct_seg9,
                                  icx_charge_acct_seg10,
                                  icx_charge_acct_seg11,
                                  icx_charge_acct_seg12,
                                  icx_charge_acct_seg13,
                                  icx_charge_acct_seg14,
                                  icx_charge_acct_seg15,
                                  icx_charge_acct_seg16,
                                  icx_charge_acct_seg17,
                                  icx_charge_acct_seg18,
                                  icx_charge_acct_seg19,
                                  icx_charge_acct_seg20,
                                  icx_charge_acct_seg21,
                                  icx_charge_acct_seg22,
                                  icx_charge_acct_seg23,
                                  icx_charge_acct_seg24,
                                  icx_charge_acct_seg25,
                                  icx_charge_acct_seg26,
                                  icx_charge_acct_seg27,
                                  icx_charge_acct_seg28,
                                  icx_charge_acct_seg29,
                                  icx_charge_acct_seg30,
                                  icx_charge_account_num,
                                  icx_percentage,
                                  icx_amount,
                                  icx_distribution_num,
                                  icx_distribution_id,
                                  v_error_text);

      ELSE
        -- return to my_order tab
        js.scriptOpen;
        htp.p('parent.parent.account_dist="";');
        htp.p('parent.parent.cartLineId=' || v_cart_line_id || ';');
        htp.p('top.switchFrames("my_order");');
        js.scriptClose;
        RETURN;

      END IF; /* v_error_count */

    END IF; /* p_user_action = 'APPLY' */

    IF p_user_action = 'APPLY_TO_ALL' THEN

       /* First apply the existing screen data. This is need to be done as
          the user may not have pressed the apply button, before calling
          apply to all lines. This is an implicit apply followed by an apply to
          all lines.
        */
       apply_account_distributions(v_cart_id ,
                                  v_cart_line_id ,
                                  icx_charge_acct_seg1,
                                  icx_charge_acct_seg2,
                                  icx_charge_acct_seg3,
                                  icx_charge_acct_seg4,
                                  icx_charge_acct_seg5,
                                  icx_charge_acct_seg6,
                                  icx_charge_acct_seg7,
                                  icx_charge_acct_seg8,
                                  icx_charge_acct_seg9,
                                  icx_charge_acct_seg10,
                                  icx_charge_acct_seg11,
                                  icx_charge_acct_seg12,
                                  icx_charge_acct_seg13,
                                  icx_charge_acct_seg14,
                                  icx_charge_acct_seg15,
                                  icx_charge_acct_seg16,
                                  icx_charge_acct_seg17,
                                  icx_charge_acct_seg18,
                                  icx_charge_acct_seg19,
                                  icx_charge_acct_seg20,
                                  icx_charge_acct_seg21,
                                  icx_charge_acct_seg22,
                                  icx_charge_acct_seg23,
                                  icx_charge_acct_seg24,
                                  icx_charge_acct_seg25,
                                  icx_charge_acct_seg26,
                                  icx_charge_acct_seg27,
                                  icx_charge_acct_seg28,
                                  icx_charge_acct_seg29,
                                  icx_charge_acct_seg30,
                                  icx_charge_account_num,
                                  icx_percentage,
                                  icx_amount,
                                  icx_distribution_num,
                                  icx_distribution_id,
                                  v_error_text);

       -- Check for errors after apply. This is to prevent bad data
       -- getting into distibutions. Display the error message back with the
       -- data entered by the user.

       -- Query the error table for this line where distribution_num is not null
       open distribution_errors (v_cart_id, v_cart_line_id);
       fetch distribution_errors into v_error_count;
       close distribution_errors;

       IF  ((NVL(v_error_count, 0)) > 0) OR (v_error_text IS NOT NULL) THEN
         -- call distributions display page to display errors
       display_acct_distributions (icx_call.decrypt2(p_cart_line_id) ,
                                  p_cart_id ,
                                  p_show_more_lines,
                                  icx_charge_acct_seg1,
                                  icx_charge_acct_seg2,
                                  icx_charge_acct_seg3,
                                  icx_charge_acct_seg4,
                                  icx_charge_acct_seg5,
                                  icx_charge_acct_seg6,
                                  icx_charge_acct_seg7,
                                  icx_charge_acct_seg8,
                                  icx_charge_acct_seg9,
                                  icx_charge_acct_seg10,
                                  icx_charge_acct_seg11,
                                  icx_charge_acct_seg12,
                                  icx_charge_acct_seg13,
                                  icx_charge_acct_seg14,
                                  icx_charge_acct_seg15,
                                  icx_charge_acct_seg16,
                                  icx_charge_acct_seg17,
                                  icx_charge_acct_seg18,
                                  icx_charge_acct_seg19,
                                  icx_charge_acct_seg20,
                                  icx_charge_acct_seg21,
                                  icx_charge_acct_seg22,
                                  icx_charge_acct_seg23,
                                  icx_charge_acct_seg24,
                                  icx_charge_acct_seg25,
                                  icx_charge_acct_seg26,
                                  icx_charge_acct_seg27,
                                  icx_charge_acct_seg28,
                                  icx_charge_acct_seg29,
                                  icx_charge_acct_seg30,
                                  icx_charge_account_num,
                                  icx_percentage,
                                  icx_amount,
                                  icx_distribution_num,
                                  icx_distribution_id,
                                  v_error_text);
       ELSE

        apply_to_all(v_cart_id, v_cart_line_id);

        -- return to my_order tab
        js.scriptOpen;
        htp.p('parent.parent.account_dist="";');
        htp.p('parent.parent.cartLineId=' || v_cart_line_id || ';');
        htp.p('top.switchFrames("my_order");');
        js.scriptClose;
        RETURN;
       END IF;  /* IF v_errror_count...  */

    END IF; /* p_user_action = 'APPLY_TO_ALL' */

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in submit_accounts ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END submit_accounts;


------------------------------------------------------
PROCEDURE apply_account_distributions(v_cart_id IN NUMBER,
                          v_cart_line_id IN NUMBER,
                          icx_charge_acct_seg1 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg2 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg3 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg4 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg5 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg6 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg7 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg8 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg9 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg10 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg11 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg12 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg13 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg14 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg15 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg16 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg17 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg18 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg19 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg20 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg21 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg22 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg23 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg24 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg25 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg26 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg27 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg28 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg29 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_acct_seg30 IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_charge_account_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_percentage IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_amount IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_num IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          icx_distribution_id IN ICX_OWA_PARMS.ARRAY DEFAULT ICX_OWA_PARMS.empty,
                          v_error_text OUT VARCHAR2
         ) IS

v_total_rows_returned     NUMBER := 0;
v_row_count               NUMBER := 0;
v_concatenated_segment    VARCHAR2(2) := NULL;
v_allocation_type         VARCHAR2(30) := NULL;

v_ak_attributes_table     varchar2_table;
v_segment_value           fnd_flex_ext.SegmentArray;
v_num_segments            NUMBER := 0;
v_percent_total           NUMBER := 0;

v_org_id                  NUMBER := NULL;
l                         NUMBER := NULL;

 cursor get_ak_attributes is
        select  ltrim(rtrim(a.ATTRIBUTE_CODE)) ATTRIBUTE_NAME
        from       ak_region_items a,
        ak_attributes b,
        ak_regions c,
        ak_object_attributes d
        where      a.NODE_DISPLAY_FLAG = 'Y'
        and        a.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
        and        a.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
        and        b.DATA_TYPE = 'VARCHAR2'
        and        c.REGION_APPLICATION_ID = 601
        and        a.REGION_CODE = c.REGION_CODE
        and        a.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
        and        c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
        and        a.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
        and        a.region_code = 'ICX_CART_LINE_DISTRIBUTIONS_R'
        and        a.ATTRIBUTE_CODE LIKE 'ICX_CHARGE_ACCT_SEG%'
        order by a.display_sequence;

 cursor check_concatenated_segment is
        select  1
        from       ak_region_items a,
        ak_attributes b,
        ak_regions c,
        ak_object_attributes d
        where      a.NODE_DISPLAY_FLAG = 'Y'
        and        a.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
        and        a.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
        and        b.DATA_TYPE = 'VARCHAR2'
        and        c.REGION_APPLICATION_ID = 601
        and        a.REGION_CODE = c.REGION_CODE
        and        a.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
        and        c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
        and        a.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
        and        a.region_code = 'ICX_CART_LINE_DISTRIBUTIONS_R'
        and        a.attribute_code = 'ICX_CHARGE_ACCOUNT_NUM';

BEGIN

 IF icx_sec.validateSession('ICX_REQS') THEN

    v_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);

    -- Set the allocation type. Right now only percentage is allowed.
    v_allocation_type := 'PERCENT';

    -- get the total number of rows returned from the browser
    v_total_rows_returned := icx_percentage.COUNT;

    -- If percentage does not add up to 100% return as error.
    FOR l in 1 .. v_total_rows_returned LOOP
      v_percent_total := v_percent_total + NVL(to_number(icx_percentage(l)), 0);
    END LOOP; /* FOR v_total_rows_returned */

    IF v_percent_total <> 100 THEN
       FND_MESSAGE.SET_NAME('ICX','ICX_NOT_100_PERCENT');
       v_error_text := FND_MESSAGE.GET;
       RETURN;
    END IF;  /* IF v_percenet_total */

     -- Delete the error messages for the distribution
     DELETE FROM icx_req_cart_errors
     WHERE cart_id = v_cart_id
     AND   cart_line_id = v_cart_line_id
     AND   distribution_num IS NOT NULL;


    /*
    Delete all the distributions in the table. This need to be done to
    take care of the deletion option. As we don't provide delete button option
    the user will either enter '0' (zero) or leave blank in the percentage
    column to indicate that, account entry is deleted.
    */

    DELETE FROM icx_cart_line_distributions
    WHERE cart_id = v_cart_id
    AND   cart_line_id = v_cart_line_id;


    -- Determine what is turned for display, the concatenated segments or
    -- invidual segments.
    OPEN check_concatenated_segment;
    FETCH check_concatenated_segment INTO v_row_count;
    CLOSE check_concatenated_segment;

    IF  v_row_count = 1 THEN
        v_concatenated_segment := 'Y';
    ELSE
        v_concatenated_segment := 'N';
    END IF;

    IF v_concatenated_segment = 'N' THEN
    -- Find the segments turned on and build a pl/sql table to hold
    -- the segment attribute code
    l := 1;
    FOR ak_col IN get_ak_attributes LOOP
      v_ak_attributes_table(l) := ak_col.attribute_name;
      l := l + 1;
    END LOOP;  /* FOR ak_col */

    -- Get the total number of segments
    v_num_segments := v_ak_attributes_table.COUNT;

    -- loop through every line returned to get the account segments
    FOR i in 1.. v_total_rows_returned LOOP

      -- Build the segment table for each row
      FOR j in 1 .. v_num_segments LOOP

          IF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG1' THEN
             v_segment_value(j) := icx_charge_acct_seg1(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG2' THEN
             v_segment_value(j) := icx_charge_acct_seg2(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG3' THEN
             v_segment_value(j) := icx_charge_acct_seg3(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG4' THEN
             v_segment_value(j) := icx_charge_acct_seg4(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG5' THEN
             v_segment_value(j) := icx_charge_acct_seg5(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG6' THEN
             v_segment_value(j) := icx_charge_acct_seg6(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG7' THEN
             v_segment_value(j) := icx_charge_acct_seg7(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG8' THEN
             v_segment_value(j) := icx_charge_acct_seg8(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG9' THEN
             v_segment_value(j) := icx_charge_acct_seg9(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG10' THEN
             v_segment_value(j) := icx_charge_acct_seg10(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG11' THEN
             v_segment_value(j) := icx_charge_acct_seg11(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG12' THEN
             v_segment_value(j) := icx_charge_acct_seg12(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG13' THEN
             v_segment_value(j) := icx_charge_acct_seg13(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG14' THEN
             v_segment_value(j) := icx_charge_acct_seg14(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG15' THEN
             v_segment_value(j) := icx_charge_acct_seg15(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG16' THEN
             v_segment_value(j) := icx_charge_acct_seg16(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG17' THEN
             v_segment_value(j) := icx_charge_acct_seg17(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG18' THEN
             v_segment_value(j) := icx_charge_acct_seg18(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG19' THEN
             v_segment_value(j) := icx_charge_acct_seg19(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG20' THEN
             v_segment_value(j) := icx_charge_acct_seg20(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG21' THEN
             v_segment_value(j) := icx_charge_acct_seg21(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG22' THEN
             v_segment_value(j) := icx_charge_acct_seg22(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG23' THEN
             v_segment_value(j) := icx_charge_acct_seg23(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG24' THEN
             v_segment_value(j) := icx_charge_acct_seg24(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG25' THEN
             v_segment_value(j) := icx_charge_acct_seg25(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG26' THEN
             v_segment_value(j) := icx_charge_acct_seg26(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG27' THEN
             v_segment_value(j) := icx_charge_acct_seg27(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG28' THEN
             v_segment_value(j) := icx_charge_acct_seg28(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG29' THEN
             v_segment_value(j) := icx_charge_acct_seg29(i);
          ELSIF v_ak_attributes_table(j) = 'ICX_CHARGE_ACCT_SEG30' THEN
             v_segment_value(j) := icx_charge_acct_seg30(i);
          END IF;   /* IF v_ak_attributes_table(j) */

      END LOOP;  /* FOR j in 1 .. */

      -- do not insert rows which are null or zero percent
      IF (icx_percentage(i) IS NOT NULL AND icx_percentage(i) > 0) THEN
        -- Insert into distribution table
        icx_req_acct2.update_account( v_cart_line_id => v_cart_line_id,
                                v_oo_id => v_org_id,
                                v_cart_id => v_cart_id,
                                v_segments => v_segment_value,
                                v_allocation_type => v_allocation_type,
                                v_allocation_value => to_number(icx_percentage(i)));
      END IF;  /* icx_percentage(i) */


    END LOOP;  /* FOR i in 1.. v_total_rows_returned */
    ELSE
      -- concatenated segment is turned for display
    -- loop through every line returned to get the account segments
    FOR i in 1.. v_total_rows_returned LOOP
      IF (icx_percentage(i) IS NOT NULL AND icx_percentage(i) > 0) THEN
        -- Insert into distribution table
        icx_req_acct2.update_account_num( v_cart_line_id => v_cart_line_id,
                                v_oo_id => v_org_id,
                                v_cart_id => v_cart_id,
                                v_account_num => icx_charge_account_num(i),
                                v_allocation_type => v_allocation_type,
                                v_allocation_value => to_number(icx_percentage(i)));
      END IF;  /* icx_percentage(i) */

    END LOOP;  /* FOR i in 1.. v_total_rows_returned */
    END IF; /* v_concatenated_segment = 'N' */
 END IF; /* validate session */

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in apply_account_distributions ' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END apply_account_distributions;


------------------------------------------------------
PROCEDURE apply_to_all(v_cart_id IN NUMBER,
                       v_cart_line_id IN NUMBER) IS

l                   NUMBER := NULL;
v_ak_segments       segment_table;
v_num_segments      NUMBER := 0;
v_where_clause      VARCHAR2(2000);
v_employee_id       NUMBER := NULL;
v_web_user_id       NUMBER := NULL;
v_responsibility_id NUMBER := NULL;
v_org_id            NUMBER := NULL;
v_allocation_type   VARCHAR2(50);
v_allocation_value  NUMBER := 0;
v_row_count         NUMBER := 0;
v_concatenated_segment    VARCHAR2(2) := NULL;

v_distribution_lines_region  VARCHAR2(50) := NULL;

l_values          icx_util.char240_table;
v_segment_value   fnd_flex_ext.SegmentArray;
v_line_segments   fnd_flex_ext.SegmentArray;

 CURSOR get_ak_attributes IS
        SELECT  ltrim(rtrim(a.ATTRIBUTE_CODE)) ATTRIBUTE_NAME,
                a.UPDATE_FLAG  UPDATE_FLAG
        FROM       ak_region_items a,
        ak_attributes b,
        ak_regions c
        WHERE      a.NODE_DISPLAY_FLAG = 'Y'
        AND        a.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
        AND        a.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
        AND        b.DATA_TYPE = 'VARCHAR2'
        AND        c.REGION_APPLICATION_ID = 601
        AND        a.REGION_CODE = c.REGION_CODE
        AND        a.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
        AND        a.REGION_CODE = 'ICX_CART_LINE_DISTRIBUTIONS_R'
        AND        a.ATTRIBUTE_CODE LIKE 'ICX_CHARGE_ACCT_SEG%'
        ORDER BY a.display_sequence;

 -- Exclude the current line
 CURSOR get_req_lines IS
        SELECT cart_line_id
        FROM icx_shopping_cart_lines
        WHERE cart_id = v_cart_id
        AND   cart_line_id <> v_cart_line_id;

 CURSOR get_distributions IS
        SELECT distribution_id
        FROM icx_cart_line_distributions
        WHERE cart_id = v_cart_id
        AND   cart_line_id = v_cart_line_id;

 CURSOR get_distributions_account_num IS
        SELECT charge_account_num, allocation_value, allocation_type
        FROM icx_cart_line_distributions
        WHERE cart_id = v_cart_id
        AND   cart_line_id = v_cart_line_id;

 CURSOR check_concatenated_segment IS
        SELECT  1
        FROM       ak_region_items a,
        ak_attributes b,
        ak_regions c,
        ak_object_attributes d
        WHERE      a.NODE_DISPLAY_FLAG = 'Y'
        AND        a.ATTRIBUTE_CODE = b.ATTRIBUTE_CODE
        AND        a.ATTRIBUTE_APPLICATION_ID = b.ATTRIBUTE_APPLICATION_ID
        AND        b.DATA_TYPE = 'VARCHAR2'
        AND        c.REGION_APPLICATION_ID = 601
        AND        a.REGION_CODE = c.REGION_CODE
        AND        a.REGION_APPLICATION_ID = c.REGION_APPLICATION_ID
        AND        c.DATABASE_OBJECT_NAME = d.DATABASE_OBJECT_NAME
        AND        a.ATTRIBUTE_CODE = d.ATTRIBUTE_CODE
        AND        a.region_code = 'ICX_CART_LINE_DISTRIBUTIONS_R'
        AND        a.attribute_code = 'ICX_CHARGE_ACCOUNT_NUM';

BEGIN

    v_distribution_lines_region  := 'ICX_CART_LINE_DISTRIBUTIONS_R';
    v_allocation_type := 'PERCENT';

    v_org_id := icx_sec.getId(icx_sec.PV_ORG_ID);
    v_employee_id := icx_sec.getID(icx_sec.PV_INT_CONTACT_ID);
    v_web_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
    v_responsibility_id  := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

    -- Determine what is turned for display, the concatenated segments or
    -- invidual segments.
    OPEN check_concatenated_segment;
    FETCH check_concatenated_segment INTO v_row_count;
    CLOSE check_concatenated_segment;

    IF  v_row_count = 1 THEN
        v_concatenated_segment := 'Y';
    ELSE
        v_concatenated_segment := 'N';
    END IF;

    -- Delte all the account distributions of all the lines except for
    -- for the current line. The 'apply to all' overwrites the existing
    -- distributions of other lines.
    DELETE FROM icx_cart_line_distributions
    WHERE cart_id = v_cart_id
    AND   cart_line_id <> v_cart_line_id;

    IF v_concatenated_segment = 'N' THEN
    /*
    Get the segment table first. This will be used to compare the
    segments with the actual segment value later. The update flag is updated
    Y in the pl/sql table record to indicate whether the default account need to
    be inherited from the line default.
    */
    l := 1;
    FOR ak_col IN get_ak_attributes LOOP
      v_ak_segments(l).segment_name := ak_col.attribute_name;
      v_ak_segments(l).update_flag  := ak_col.update_flag;
    l := l + 1;
    END LOOP;  /* FOR ak_col */

    v_num_segments := v_ak_segments.COUNT;

    -- For every line in the req apply the current distribution
    FOR req_line IN get_req_lines LOOP

      -- Get the current distribution
      FOR prec IN get_distributions LOOP

        v_where_clause := 'CART_ID =' || v_cart_id || 'AND CART_LINE_ID =' || v_cart_line_id || 'AND DISTRIBUTION_ID =' || prec.distribution_id;

        ak_query_pkg.exec_query(P_PARENT_REGION_APPL_ID => 601,
                                P_PARENT_REGION_CODE    => v_distribution_lines_region,
                                P_RESPONSIBILITY_ID     => v_responsibility_id,
                                P_USER_ID               => v_web_user_id,
                                P_WHERE_CLAUSE          => v_where_clause,
                                P_RETURN_PARENTS        => 'T',
                                P_RETURN_CHILDREN       => 'F');

        IF ak_query_pkg.g_results_table.COUNT > 0 THEN
          l := 1;
          FOR r IN 0..ak_query_pkg.g_results_table.LAST LOOP

            icx_util.transfer_Row_To_Column(ak_query_pkg.g_results_table(r),l_values);

            FOR i IN ak_query_pkg.g_items_table.FIRST .. ak_query_pkg.g_items_table.LAST LOOP

              IF ak_query_pkg.g_items_table(i).node_display_flag = 'Y'
                 AND (substr(ltrim(rtrim(ak_query_pkg.g_items_table(i).attribute_code)), 1, 19) = 'ICX_CHARGE_ACCT_SEG') THEN

                   -- Build the segment values in segment array
                   v_segment_value(l) := l_values(ak_query_pkg.g_items_table(i).value_id);
                   l := l + 1;
              END IF; /* IF ak_query_pkg */

              IF ak_query_pkg.g_items_table(i).attribute_code = 'ICX_PERCENTAGE' THEN
                 v_allocation_value := l_values(ak_query_pkg.g_items_table(i).value_id);
              END IF; /* IF ak_query_pkg */

            END LOOP; /* FOR i in items table */

          END LOOP; /* FOR r in results table */

        END IF; /* IF results_table.COUNT > 0 */

        -- Get the default segment for the current line
        icx_req_acct2.get_default_segs (v_cart_id => v_cart_id,
                                        v_cart_line_id => req_line.cart_line_id,
                                        v_emp_id => v_employee_id,
                                        v_oo_id => v_org_id,
                                        v_segments => v_line_segments);

        -- Only update the segments that are marked for update
        IF v_line_segments.COUNT > 0 THEN

           l := 1;
           FOR j IN v_ak_segments.FIRST .. v_ak_segments.LAST LOOP
             IF v_ak_segments(l).update_flag = 'Y' THEN
                v_line_segments(l) := v_segment_value(l);
             END IF;
             l := l + 1;
           END LOOP; /* FOR v_line_segments */

/*
-- debug
debug_plsql.write_time('Cart id  = ' || v_cart_id);
debug_plsql.write_time('Cart line id  = ' || req_line.cart_line_id);
debug_plsql.write_time('Current: v_segment_value(1) = ' || v_segment_value(1));
debug_plsql.write_time('Current: v_segment_value(2) = ' || v_segment_value(2));
debug_plsql.write_time('Current: v_segment_value(3) = ' || v_segment_value(3));
debug_plsql.write_time('Current: v_segment_value(4) = ' || v_segment_value(4));
debug_plsql.write_time('Current: v_segment_value(5) = ' || v_segment_value(5));
debug_plsql.write_time('Current: v_segment_value(6) = ' || v_segment_value(6));
debug_plsql.write_time('v_line_segments(1) = ' || v_line_segments(1));
debug_plsql.write_time('v_line_segments(2) = ' || v_line_segments(2));
debug_plsql.write_time('v_line_segments(3) = ' || v_line_segments(3));
debug_plsql.write_time('v_line_segments(4) = ' || v_line_segments(4));
debug_plsql.write_time('v_line_segments(5) = ' || v_line_segments(5));
debug_plsql.write_time('v_line_segments(6) = ' || v_line_segments(6));
debug_plsql.write_time('Allocation value = ' || v_allocation_value);
*/

           icx_req_acct2.update_account( v_cart_line_id => req_line.cart_line_id,
                                         v_oo_id => v_org_id,
                                         v_cart_id => v_cart_id,
                                         v_segments => v_line_segments,
                                         v_allocation_type => v_allocation_type,
                                         v_allocation_value => v_allocation_value,
                                         v_validate_flag => 'N');
       ELSIF v_line_segments.COUNT = 0 THEN
           /** If the code reaches here, we have been unable to build default
               account from the item/person. In this case, regardless of the
               updateability of the segments, we are going to copy over the
               current distribution's segments to all the lines.
           **/
           l := 1;
           FOR j IN v_ak_segments.FIRST .. v_ak_segments.LAST LOOP

                v_line_segments(l) := v_segment_value(l);

             l := l + 1;
           END LOOP; /* FOR v_ak_segments */
           /** Insert the distribution **/
           icx_req_acct2.update_account( v_cart_line_id => req_line.cart_line_id,
                                         v_oo_id => v_org_id,
                                         v_cart_id => v_cart_id,
                                         v_segments => v_line_segments,
                                         v_allocation_type => v_allocation_type,
                                         v_allocation_value => v_allocation_value,
                                         v_validate_flag => 'N');
        END IF; /* IF v_line_segments.COUNT > 0 */

      END LOOP;  /* FOR prec IN get_distributions */

    END LOOP;  /* FOR req_line */
    ELSE
      -- Concatenated segments are turned for display
      -- For every line in the req apply the current distribution
      FOR req_line IN get_req_lines LOOP
          FOR prec IN get_distributions_account_num LOOP
          -- Insert into distribution table

          icx_req_acct2.update_account_num(v_cart_line_id => req_line.cart_line_id,
                                  v_oo_id => v_org_id,
                                  v_cart_id => v_cart_id,
                                  v_account_num => prec.charge_account_num,
                                  v_allocation_type => prec.allocation_type,
                                  v_allocation_value => prec.allocation_value,
                                  v_validate_flag => 'N');

          END LOOP;  /* FOR prec */
      END LOOP;  /* FOR req_line */
    END IF; /* if v_concatenated_segment = 'N' */

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in apply_to_all' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END apply_to_all;

------------------------------------------------------
PROCEDURE display_account_errors(v_cart_id IN NUMBER,
                                 v_cart_line_id IN NUMBER) IS

  CURSOR get_errors(l_cart_id NUMBER) IS
  SELECT error_text
  FROM icx_req_cart_errors
  WHERE cart_id = v_cart_id
  AND   cart_line_id = v_cart_line_id
  AND distribution_num IS NOT NULL;

  l_first_time VARCHAR2(1);

BEGIN

    l_first_time := 'Y';
    FOR prec IN get_errors(v_cart_id) LOOP
       IF l_first_time = 'Y' THEN
          htp.p('<TABLE BORDER=5>');
          l_first_time := 'N';
       END IF;

       htp.p('<TR><TD>' || prec.error_text || '</TD></TR>');
    END LOOP;
    IF l_first_time = 'N' THEN
       htp.p('</TABLE>');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- htp.p('Error in display_account_errors' || substr(SQLERRM, 1, 512));
    icx_util.add_error(substr(SQLERRM, 12, 512));
    icx_util.error_page_print;

END display_account_errors;

END icx_req_acct_dist;

/
