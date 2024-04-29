--------------------------------------------------------
--  DDL for Package Body PA_TIME_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TIME_CLIENT_EXTN" AS
/*  $Header: PAPSSTCB.pls 120.2 2006/06/26 23:48:20 eyefimov noship $  */


PROCEDURE Set_Batch_Name (
			p_expenditure_id		      IN	NUMBER,
			p_person_id			          IN	NUMBER,
			p_expenditure_ending_date 	  IN	DATE,
			p_expenditure_organization_id IN	NUMBER,
			x_user_batch_name		      OUT NOCOPY VARCHAR2,
			x_return_status			      OUT NOCOPY VARCHAR2,
			x_msg_application_name		  OUT NOCOPY VARCHAR2,
			x_message_data			      OUT NOCOPY VARCHAR2,
			x_token_name1			      OUT NOCOPY VARCHAR2,
			x_token_val1			      OUT NOCOPY VARCHAR2,
			x_token_name2			      OUT NOCOPY VARCHAR2,
			x_token_val2			      OUT NOCOPY VARCHAR2,
			x_token_name3			      OUT NOCOPY VARCHAR2,
			x_token_val3			      OUT NOCOPY VARCHAR2,
			x_token_name4			      OUT NOCOPY VARCHAR2,
			x_token_val4			      OUT NOCOPY VARCHAR2,
			x_token_name5			      OUT NOCOPY VARCHAR2,
			x_token_val5			      OUT NOCOPY VARCHAR2
			)
IS

-- This API could be customized to derive a batch_name as per your
-- Business rules.
-- Oracle Projects provides the logic for deriving the default batch name
-- in this API.  The default logic for deriving the batch name is
-- batch_name = (week_ending_date in MMDDYY format)-(random sequence that is
-- unique for week_ending_date and incurred_by_organization combination)
-- The default logic will work only for week_ending_dates that have less that
-- 1000 incurred_by_organizations
--
-- changed the query of c_user_batch_name to fix the bug 1572751
-- added AND expenditure_id = p_expenditure_id to where clause.
--

cursor c_user_batch_name is
	SELECT user_batch_name
	FROM PA_EXPENDITURES
	WHERE incurred_by_organization_id  =
				p_expenditure_organization_id
	AND trunc(Expenditure_ending_date) = p_expenditure_ending_date
	AND expenditure_id = p_expenditure_id;

l_date_string		VARCHAR2(6);
l_sequence_no		NUMBER;

BEGIN

	OPEN c_user_batch_name;
	FETCH c_user_batch_name
	INTO x_user_batch_name;

	IF (c_user_batch_name%NOTFOUND) THEN

	   x_return_status := 'E';
	   x_msg_application_name := 'PA';
	   x_message_data := 'NO_EXPND_RECORD_FOUND';
	   x_token_name1 := 'TOKEN1';
	   x_token_val1 := to_char(p_expenditure_id);
	   x_token_name2 := 'TOKEN2';
	   x_token_val2 := to_char(p_expenditure_organization_id);
	   x_token_name3 := 'TOKEN3';
	   x_token_val3 := to_char(p_expenditure_ending_date);

	ELSE

	   IF (x_user_batch_name IS NULL) THEN

           /** Create the batch Name **/

              SELECT To_Char(p_expenditure_ending_date,'MMDDYY')
	      INTO l_date_string
	      FROM dual;

		  /** Get the next value from sequence **/
	      SELECT mod(PA_EXPENDITURE_GROUPS_S.nextval,1000)
	      INTO l_sequence_no
	      FROM DUAL;

	      x_user_batch_name := l_date_string||'-'||to_char(l_sequence_no);

	   ELSE

	       x_return_status := null;

	   END IF;

    END IF;


	CLOSE c_user_batch_name;

EXCEPTION

     WHEN OTHERS THEN
	      x_return_status := 'U';
	      x_message_data := to_char(SQLCODE);

END Set_Batch_Name;


--------------------------------------------------------------------------------

PROCEDURE Override_Match_Status(
         p_person_id              IN per_people_f.person_id%TYPE,
         p_project_id             IN pa_projects_all.project_id%TYPE,
         p_task_id                IN pa_tasks.task_id%TYPE,
         p_expenditure_type       IN pa_expenditure_types.expenditure_type%TYPE,
         p_expenditure_type_class IN pa_system_linkages.function%TYPE,
         p_expenditure_item_date  IN pa_expenditure_items_all.expenditure_item_date%TYPE,
         p_quantity               IN pa_expenditure_items_all.quantity%TYPE,
         p_expenditure_comment    IN Varchar2,
         p_attribute_category     IN pa_expenditure_items_all.attribute_category%TYPE,
         p_attribute1             IN pa_expenditure_items_all.attribute1%TYPE,
         p_attribute2             IN pa_expenditure_items_all.attribute2%TYPE,
         p_attribute3             IN pa_expenditure_items_all.attribute3%TYPE,
         p_attribute4             IN pa_expenditure_items_all.attribute4%TYPE,
         p_attribute5             IN pa_expenditure_items_all.attribute5%TYPE,
         p_attribute6             IN pa_expenditure_items_all.attribute6%TYPE,
         p_attribute7             IN pa_expenditure_items_all.attribute7%TYPE,
         p_attribute8             IN pa_expenditure_items_all.attribute8%TYPE,
         p_attribute9             IN pa_expenditure_items_all.attribute9%TYPE,
         p_attribute10            IN pa_expenditure_items_all.attribute10%TYPE,
         p_match_status           IN Varchar2,
         x_match_status           OUT NOCOPY varchar2)
IS

l_stage    Varchar2(200) := NULL;

--
-- If you want to match the txn to it's original then set
-- x_match_status to M. When the timecard is imported into
-- Oracle Projects via Transaction Import, this txn will be
-- matched to the original( i.e adjusted_expenditure_item_id will
-- be set to the original Expenditure Item id and
-- net_zero_adjustment_flag will be set to Y. )

-- If you do not want the txn to be matched the set the x_match_status
-- to 'U'

BEGIN

   l_stage := 'Assigning p_match_status to x_match_status';


   if p_quantity < 0 then
        x_match_status := 'M';
   else
        x_match_status := p_match_status;
   end if;


EXCEPTION WHEN others THEN
   raise_application_error(-20003, 'OMS-'||l_stage||'-'||SQLERRM);
END Override_Match_Status;

-- ==========================================================================
-- Display_Business_Message API:
-- ==========================================================================
-- This API will be used to generate a customized message which will
-- be displayed when validation expendtiures and Workflow approval screens.
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
-- P_Timecard_Table            PL/SQL table holding data of OTL only
-- P_Module                    The module calling this routine
--                             Can only be 'SST' or 'OTL'
-- P_Expenditure_id            System generated identifier of the timecard
--                             Will be NULL when P_Module = 'OTL'
-- P_Person_Id                 System generated identifire of the employee
--                             from whome the timecard was created
-- P_Week_Ending_Date          Week Ending date of the timecard
-- X_msg_Application_Name      Message owning application short name.
-- X_Message_data              Message Name
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
-- ------------------------ For OTL ------------------------------
--
--   Oracle Time Capture (OTL) is a new product that captures and stores
--   timecard information in a system that is not directly tied to
--   Oracle Projects.  Projects interfaces with OTC to validate the data.
--   After the timecard in OTL is approved, it can be imported
--   into Oracle Projects.  Until it is imported into Projects, there are no
--   records of any kind within Projects for this data.  Therefore, a
--   pl/sql table is provided that is in a Projects-compatible
--   structure so that summary-level validation can take place.
--   A new parameter, P_Timecard_Rec, is therefore being introduced for this purpose.
--   Below is the table record structure:
--
--     Project_Number              Pa_Projects_All.Segment1%TYPE,
--     Project_Id                  Pa_Projects_All.Project_Id%TYPE,
--     Task_Number                 Pa_Tasks.Task_Number%TYPE,
--     Task_Id                     Pa_Tasks.Task_Id%TYPE,
--     Expenditure_Type            Pa_Expenditure_Types.Expenditure_Type%TYPE,
--     System_Linkage_Function     Pa_System_Linkages.Function%TYPE,
--     Quantity                    Pa_Expenditure_Items_All.quantity%TYPE,
--     Incurred_By_Person_Id       Pa_Expenditures_All.Incurred_By_Person_Id%TYPE,
--     Override_Approver_Person_Id Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE,
--     Expenditure_Item_Date       Pa_Expenditure_Items_All.Expenditure_Item_Date%TYPE,
--     Exp_Ending_Date             Pa_Expenditures_All.Expenditure_Ending_Date%TYPE,
--     Attribute_Category          Pa_Expenditure_Items_All.Attribute_Category%TYPE,
--     Attribute1                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute2                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute3                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute4                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute5                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute6                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute7                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute8                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute9                  Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Attribute10                 Pa_Expenditure_Items_All.Attribute1%TYPE,
--     Billable_Flag               Pa_Expenditure_Items_All.Billable_Flag%TYPE,
--     Expenditure_Item_Comment    Pa_Expenditure_Comments.Expenditure_Comment%TYPE,
--     Orig_Exp_Txn_Reference1     Pa_Expenditures_All.Orig_Exp_Txn_Reference1%TYPE)
--
--     The following pl/sql table columns will always be NULL:
--        Orig_Exp_Txn_Reference1
--
--     The parameters P_Expenditure_Id and P_Week_Ending_Date will not be populated when called from OTL.
--
--     To search through the table pull out the data use a FOR LOOP
--

-- Coding calling programs:
-- ========================
-- Programs that call PA_TIME_CLIENT_EXTN.Display_Business_Message should
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
--  l_msg_data             varchar2(30);
--  Begin
--
--   PA_TIME_CLIENT_EXTN.Display_Business_Message(
--         P_Timecard_Table => NULL,
--         P_Module => 'SST'
--         P_Expenditure_id => 1122,
--         P_Person_Id => 1234,
--         P_Week_Ending_Date => '01-JAN-97',
--         X_Msg_Application_Name => l_msg_application_name
--         X_Message_data => l_msg_data
--         X_Msg_Token1_Name => l_msg_token1_name
--         X_Msg_Token1_Value => l_msg_token1_value
--         X_Msg_Token2_Name => l_msg_token2_name
--         X_Msg_Token2_Value => l_msg_token2_value
--         X_Msg_Token3_Name => l_msg_token3_name
--         X_Msg_Token3_Value => l_msg_token3_value);
--
--
--   If( l_msg_data is NOT NULL ) THEN
--
--      fnd_message.set_name(l_msg_application_name,l_msg_data);
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
   PROCEDURE Display_Business_Message(
         P_Timecard_Table       IN Pa_Otc_Api.Timecard_Table,
	     P_Module               IN VARCHAR2,
         P_Expenditure_Id       IN pa_expenditures_all.expenditure_id%TYPE DEFAULT NULL,
         P_Person_id            IN per_all_people_f.person_id%TYPE,
         P_Week_Ending_Date     IN Date,
         X_Msg_Application_Name OUT NOCOPY Fnd_Application.Application_short_name%TYPE,
         X_Message_data         OUT NOCOPY Varchar2,
         X_Msg_Token1_Name      OUT NOCOPY Varchar2,
         X_Msg_Token1_Value     OUT NOCOPY Varchar2,
         X_Msg_Token2_Name      OUT NOCOPY Varchar2,
         X_Msg_Token2_Value     OUT NOCOPY Varchar2,
         X_Msg_Token3_Name      OUT NOCOPY Varchar2,
         X_Msg_Token3_Value     OUT NOCOPY Varchar2)

   IS

--    CURSOR cur_billable IS
--       SELECT sum(nvl(quantity_1,0)) qty_1,
--              sum(nvl(quantity_2,0)) qty_2,
--              sum(nvl(quantity_3,0)) qty_3,
--              sum(nvl(quantity_4,0)) qty_4,
--              sum(nvl(quantity_5,0)) qty_5,
--              sum(nvl(quantity_6,0)) qty_6,
--              sum(nvl(quantity_7,0)) qty_7,
--              sum(decode(ei.billable_flag_1,'Y',ei.quantity_1,0)) bill_qty_1,
--              sum(decode(ei.billable_flag_2,'Y',ei.quantity_2,0)) bill_qty_2,
--              sum(decode(ei.billable_flag_3,'Y',ei.quantity_3,0)) bill_qty_3,
--              sum(decode(ei.billable_flag_4,'Y',ei.quantity_4,0)) bill_qty_4,
--              sum(decode(ei.billable_flag_5,'Y',ei.quantity_5,0)) bill_qty_5,
--              sum(decode(ei.billable_flag_6,'Y',ei.quantity_6,0)) bill_qty_6,
--              sum(decode(ei.billable_flag_7,'Y',ei.quantity_7,0)) bill_qty_7
--        from pa_expenditures exp,
--             pa_ei_denorm ei
--       where ei.expenditure_id = exp.expenditure_id
--         and exp.expenditure_id = p_expenditure_id
--         and exp.incurred_by_person_id = p_person_id
--         and exp.expenditure_ending_date = p_week_ending_date;
--    l_total_qty Number;
--    l_total_bill_qty Number;

   BEGIN

 /*
    This client extension contains no default code, but can be used by customers
    used to generate a customized message which will be displayed during validation and
    Workflow approval screens.

    The message generated by this API could be used to ensure that the
    employees are billable to a specified percentage determined as follows.

       (billable hours in timecard )/(total hours on timecard) *100

    -- Initilize Total Variables

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

        -- Bug 997075, division by zero. If the total qty is zero then
        -- set it to 1 to avoid division by zero error.

        l_total_qty := 1;

     END IF;

     X_msg_Token1_value :=
                         to_char( trunc((l_total_bill_qty/l_total_qty ) * 100,2));

     -- Set the token name. this token name should be used in  the message text
     -- when the messages is created in Oracle Applications
     --
     X_msg_token1_name := 'BILLABLE';
     X_Message_data := 'PA_BILLABLE_PERCENT';
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
     --     that will used to construct a meaningful message. Use the following
     --     api's to set your messages
     --
     --     X_msg_application_name := 'TK';
     --     X_message_data := 'TK_UTILIZATION';
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

    The messages are customizable by customers, hence the customer could
    generate message that would display total number of hours, % utilization
    etc.
*/

	NULL;

   END Display_Business_Message;

END PA_TIME_CLIENT_EXTN;

/
