--------------------------------------------------------
--  DDL for Package Body ICX_STORE_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_STORE_CUSTOM" as
/* $Header: ICXCSTMB.pls 115.1 99/07/17 03:16:08 porting ship $ */


-------------------------------------------------------------------------
  procedure add_user_error(p_cart_id number, error_message varchar2) is
-------------------------------------------------------------------------


begin
        icx_util.add_error(error_message);

end;





-------------------------------------------------------------------------
 procedure  store_default_lines(p_cart_id in number)is

-------------------------------------------------------------------------
/*  You can default any informaion into the lines.  Please be carefull......

    You can do this in one of two ways.  Line by line, or with set processing.
    Line by line will allow you to do specific defaults at a line level
    while set processing will update all the columns at the same time.  It
    should be noted that set processing is FASTER...

    Please note that this procedure will be run ONCE per ADD.  This means that
    if a user adds 6 different items from a Template, this procedure will only
    be called ONCE.
*/


 begin
  -- Custom default code will come here
  -- do nothing;
  null;

 end store_default_lines;


-------------------------------------------------------------------------
 procedure  store_default_head( p_cart_id IN number)is

-------------------------------------------------------------------------
/*   The default head is run once when the Header record is created.  This
     occurs when the user enters the Req program.  Here you can default in
     any values you wish.  Again BE CAREFUL......

*/

 begin
  -- Custom default code will come here
  -- do nothing;
  null;
 end store_default_head;


-------------------------------------------------------------------------
 procedure  store_validate_line(p_cart_id IN number)is

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
             icx_util.add_error(error_message);

*/


 begin
  -- Custom validation code will come here
  -- do nothing;
  null;
 end store_validate_line;


-------------------------------------------------------------------------
 procedure  store_validate_head(p_cart_id IN number) is
-------------------------------------------------------------------------
/*   You can do your own header validation here.  As in lines, you can
     put your errors directly to our error stack.  In this way, your errors
     look exactly like errors raise by Oracle.  If you find an error, please
     put it on the stack and continue.  In this way, all errors will be reported
     to the user.

     Please do only Header logic, and please TRAP ALL YOUR ERRORS!!!!!


        To add a message to the error stack use
             add_user_error(p_cart_id, 'YOUR ERROR MESSAGE');

*/


 begin
  -- Custom validation code will come here
  -- do nothing;
  null;
 end store_validate_head;


----------------------------------------------------------------
 procedure freight_customcalc(p_cart_id in number,
                              p_amt out number) is

------------------------------------------------------------------


begin

 null;

end freight_customcalc;



end icx_store_custom;

/
