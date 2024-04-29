--------------------------------------------------------
--  DDL for Package Body PA_SELF_SERVICE_MSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SELF_SERVICE_MSG_PUB" AS
/* $Header: PAXPSSMB.pls 120.2 2005/08/24 14:00:05 rmarcel noship $ */

-- ==========================================================================
-- This API will be used to generate a customized message which will
-- be displayed in the final review screen and supervisor approval screens.
--
-- The message generated by this API could be used to ensure that the
-- employees are billable to a specified percentage determined as follows.
--
-- (billable hours in timecard )/(total hours on timecard) *100
--
-- The messages are customizable by customers, hence the customer could
-- generate message that would display total number of hours, % utilization
-- etc.
--
--
-- Parameter Description
-- =====================
--
-- P_Expenditure_id            System generated identifier of the timecard
-- P_Person_Id                 System generated identifire of the employee
--                             from whome the timecard was created
-- P_Week_Ending_Date          Week Ending date of the timecard
-- X_Application_Name          Message owning application short name.
-- X_Message_Name              Message Name
-- X_Msg_Token1_Name           Optional parameter provided for use in
--                             construction of the message.  If this
--                             parameter is being used, then the message
--                             text should be constructed with token
--                             name equal to the value in this parameter.
-- X_Msg_Token1_Value          Optional parameter provided for use in
--                             construction of message.  If this parameter
--                             is being used, then the token used in message
--                             text should be populated with the value in this
--                             parameter
-- X_Msg_Token2_Name           Description, Same as X_Msg_Token1_Name.
--
-- X_Msg_Token2_Value          Description, Same as X_Msg_Token1_Value.
--
-- X_Msg_Token3_Name           Description, Same as X_Msg_Token1_Name.
--
-- X_Msg_Token3_Value          Description, Same as X_Msg_Token1_Value.
--
--
-- Coding calling programs:
-- ========================
-- Programs that call pa_self_service_msg_pub.business_message should
-- construct a translated message using the OUT parameters.  The following
-- section will illustrate how to construct a message using the out parameters.
--
--  The calling procedure should has a out parameter X_return_message.
--
--  declare local variables
--  l_msg_application_name varchar2(50);
--  l_msg_token1_name      varchar2(50);
--  l_msg_token1_value     varchar2(50);
--  l_msg_token2_name      varchar2(50);
--  l_msg_token2_value     varchar2(50);
--  l_msg_token3_name      varchar2(50);
--  l_msg_token3_value     varchar2(50);
--  l_msg_name             varchar2(30);
--  Begin
--
--   pa_self_Service_msg_pub.business_message( P_Expenditure_id => 1122,
--         P_Person_Id => 1234,
--         P_Week_Ending_Date => '01-JAN-97',
--         X_Msg_Application_Name => l_msg_application_name
--         X_Message_Name => l_msg_name
--         X_Msg_Token1_Name => l_msg_token1_name
--         X_Msg_Token1_Value => l_msg_token1_value
--         X_Msg_Token2_Name => l_msg_token2_name
--         X_Msg_Token2_Value => l_msg_token2_value
--         X_Msg_Token3_Name => l_msg_token3_name
--         X_Msg_Token3_Value => l_msg_token3_value);
--
--
--   If( l_msg_name is NOT NULL ) THEN
--
--      fnd_message.set_name(l_msg_application_name,l_msg_name);
--      fnd_message.set_token(l_msg_token1_name,l_msg_token1_value);
--      fnd_message.set_token(l_msg_token2_name,l_msg_token2_value);
--      fnd_message.set_token(l_msg_token3_name,l_msg_token3_value);
--      fnd_message.set_token(l_msg_token2_name,l_msg_token2_value);
--
--      X_return_message := fnd_message.get;
--     where X_Return_Message is the out parameter of the calling program.
--   end if;
-- end;
--
PROCEDURE business_message(
         P_Expenditure_Id   IN pa_expenditures_all.expenditure_id%TYPE,
         P_Person_id        IN per_all_people_f.person_id%TYPE,
         P_Week_Ending_Date IN Date,
         X_Msg_Application_Name OUT NOCOPY Fnd_Application.Application_short_name%TYPE, --File.Sql.39 bug 4440895
         X_Msg_Name     OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
         X_Msg_Token1_Name  OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
         X_Msg_Token1_Value OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
         X_Msg_Token2_Name  OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
         X_Msg_Token2_Value OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
         X_Msg_Token3_Name  OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
         X_Msg_Token3_Value OUT NOCOPY Varchar2) IS --File.Sql.39 bug 4440895

CURSOR cur_billable IS
   SELECT sum(nvl(quantity_1,0)) qty_1,
          sum(nvl(quantity_2,0)) qty_2,
          sum(nvl(quantity_3,0)) qty_3,
          sum(nvl(quantity_4,0)) qty_4,
          sum(nvl(quantity_5,0)) qty_5,
          sum(nvl(quantity_6,0)) qty_6,
          sum(nvl(quantity_7,0)) qty_7,
          sum(decode(ei.billable_flag_1,'Y',ei.quantity_1,0)) bill_qty_1,
          sum(decode(ei.billable_flag_2,'Y',ei.quantity_2,0)) bill_qty_2,
          sum(decode(ei.billable_flag_3,'Y',ei.quantity_3,0)) bill_qty_3,
          sum(decode(ei.billable_flag_4,'Y',ei.quantity_4,0)) bill_qty_4,
          sum(decode(ei.billable_flag_5,'Y',ei.quantity_5,0)) bill_qty_5,
          sum(decode(ei.billable_flag_6,'Y',ei.quantity_6,0)) bill_qty_6,
          sum(decode(ei.billable_flag_7,'Y',ei.quantity_7,0)) bill_qty_7
    from pa_expenditures exp,
         pa_ei_denorm ei
   where ei.expenditure_id = exp.expenditure_id
     and exp.expenditure_id = p_expenditure_id
     and exp.incurred_by_person_id = p_person_id
     and exp.expenditure_ending_date = p_week_ending_date;
l_total_qty Number;
l_total_bill_qty Number;

BEGIN

-- initilize total variables

   l_total_qty := 0;
   l_total_bill_qty := 0;

   FOR bill_rec IN cur_billable
   LOOP

      l_total_qty := l_total_qty + bill_rec.qty_1 + bill_rec.qty_2 +
                     bill_rec.qty_3 + bill_rec.qty_4 + bill_rec.qty_5 +
                     bill_rec.qty_6 + bill_rec.qty_7;

      l_total_bill_qty := l_total_bill_qty + bill_rec.bill_qty_1 +
                          bill_rec.bill_qty_2 + bill_rec.bill_qty_3 +
                          bill_rec.bill_qty_4 + bill_rec.bill_qty_5 +
                          bill_rec.bill_qty_6 + bill_rec.bill_qty_7;

   END LOOP;

   -- Now calculate the % billable by using the formula
   -- ( Total Billable hours/ Total hours ) *100

   IF ( l_total_qty = 0 ) THEN

      -- Bug 997075, division by zero
      l_total_qty := 1;

   END IF;

   X_msg_Token1_value := to_char( trunc((l_total_bill_qty/l_total_qty ) * 100,2));

   -- Set the token name. this token name should be used in  the message text
   -- when the messages is created in Oracle Applications
   --
   X_msg_token1_name := 'BILLABLE';
   X_Msg_name := 'PA_BILLABLE_PERCENT';
   X_Msg_Application_name := 'PA';

   -- if customers want to customize the message
   -- then they have to create a new message in a custom application and
   -- then modify the client extension to pass back the customized message
   -- name and custom application short name.

   -- Example:  steps involved in creating customized messages
   --
   -- 1.  create a message using the create messages screen in application
   --     developer responsibility
   --
   -- 2.  Let's say a custom message( name = TK_UTILIZATION ) was created
   --     in costom application ( name = TK ).  The text of the message
   --     is as follows.
   --     " Utilization percentage = <ampersand>UTIL "
   --
   -- 3.  Customize the client extension to calculate the utilization
   --     percentage using your business rules .
   --
   -- 4.  After calculating the utilization % set the message name and tokens
   --     that will used to construct a meaningful message. Use teh following
   --     api's to set your messages
   --
   --     X_msg_application := 'TK';
   --     X_msg_Name := 'TK_UTILIZATION';
   --     X_msg_token1_name := 'UTIL';
   --     X_msg_token1_value := <utilization derived from your business rules>;
   --     the value should be converted to a character using to_char function.
   --
   --     where TK is the custom application short name
   --     and   TK_UTILIZATION is the custom message name
   --     make sure the custom messages are created in custom application.
   --     Custom messages created in Oracle Projects Application will not
   --     be supported, You might loose the contents during upgrade.
   --

END business_message;

END pa_self_service_msg_pub;

/