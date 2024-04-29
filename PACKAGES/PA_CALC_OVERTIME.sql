--------------------------------------------------------
--  DDL for Package PA_CALC_OVERTIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CALC_OVERTIME" AUTHID CURRENT_USER as
/* $Header: PAXDLCOS.pls 120.3 2006/07/25 19:41:26 skannoji noship $ */
/*#
 * This package contains procedures that can be modified to implement overtime calculation.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Overtime Calculation Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PROJ_COST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
  --
  -- Process different types of overtime for each compensation rule
  --
/*#
* This procedure determines the amount and type of overtime for each employee and period,
* creates new expenditure items for these values.
* @param New_Expenditure_Created Flag indicating whether a new expenditure is created
* @rep:paraminfo {@rep:required}
* @param R_P_USER_ID Identifier of the user
* @rep:paraminfo {@rep:required}
* @param R_P_Program_ID Standard Who column
* @rep:paraminfo {@rep:required}
* @param R_P_Request_ID Standard Who column
* @rep:paraminfo {@rep:required}
* @param R_P_Program_App_ID Standard Who column
* @rep:paraminfo {@rep:required}
* @param R_Person_Id The identifier of the person who entered the expenditure
* @rep:paraminfo {@rep:required}
* @param R_Expenditure_End_Date End date of expenditure batch
* @rep:paraminfo {@rep:required}
* @param R_Overtime_Exp_Type Overtime expenditure type
* @rep:paraminfo {@rep:required}
* @param R_C_Double_Time_Hours Number of hours worked in compensation rule type Double Time
* @rep:paraminfo {@rep:required}
* @param R_C_Time_And_A_Half_Hours Number of hours worked in compensation rule type Time and a Half
* @rep:paraminfo {@rep:required}
* @param R_C_Uncompensated_Hours Number of hours worked in compensation rule type Uncompensated
* @rep:paraminfo {@rep:required}
* @param R_C_Extra_OT_Hours_1 Number of other overtime working hours - 1
* @rep:paraminfo {@rep:required}
* @param R_C_Extra_OT_Hours_2 Number of other overtime working hours - 2
* @rep:paraminfo {@rep:required}
* @param R_Organization Expenditure incurred organization
* @rep:paraminfo {@rep:required}
* @param R_Rule_Set Compensation rule set
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Process Overtime
* @rep:compatibility S
*/

  procedure Process_Overtime(
		New_Expenditure_Created		OUT NOCOPY boolean,
		R_P_User_ID		 	IN     number,
		R_P_Program_ID			IN     number,
		R_P_Request_ID			IN     number,
		R_P_Program_App_ID		IN     number,
		R_Person_Id			IN     number,
		R_Expenditure_End_Date		IN     date,
		R_Overtime_Exp_Type		IN     varchar2,
		R_C_Double_Time_Hours		IN OUT NOCOPY number,
		R_C_Time_And_A_Half_Hours	IN OUT NOCOPY number,
		R_C_Uncompensated_Hours		IN OUT NOCOPY number,
		R_C_Extra_OT_Hours_1		IN OUT NOCOPY number,
		R_C_Extra_OT_Hours_2		IN OUT NOCOPY number,
		R_Organization			IN     number,
		R_Rule_Set			IN     varchar2);

  --
  -- Fetch all overtime task ids.
  -- Called from BEFOREREPORT trigger so that if no 'OT' project or
  -- Double, Half, andUncomp tasks exist, report will stop.
  --


/*#
* This procedure looks for overtime projects and tasks and returns all relevant task names up
* to a maximum of five. These tasks determine the column titles in overtime calculation report.
* @param Overtime_Tasks_Exist Flag  indicating whether any overtime tasks exists for this project
* @rep:paraminfo {@rep:required}
* @param R_OT_Title_1 Title of the first item in the overtime calculation report
* @rep:paraminfo {@rep:required}
* @param R_OT_Title_2 Title of the second item in the overtime calculation report
* @rep:paraminfo {@rep:required}
* @param R_OT_Title_3 Title of the third item in the overtime calculation report
* @rep:paraminfo {@rep:required}
* @param R_OT_Title_4 Title of the fourth item in the overtime calculation report
* @rep:paraminfo {@rep:required}
* @param R_OT_Title_5 Title of the fifth item in the overtime calculation report
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Check If Overtime Tasks Exist
* @rep:compatibility S
*/

  procedure Check_Overtime_Tasks_Exist(
		Overtime_Tasks_Exist		   OUT NOCOPY boolean,
		R_OT_Title_1			   OUT NOCOPY varchar2,
		R_OT_Title_2			   OUT NOCOPY varchar2,
		R_OT_Title_3			   OUT NOCOPY varchar2,
		R_OT_Title_4			   OUT NOCOPY varchar2,
		R_OT_Title_5			   OUT NOCOPY varchar2);

  --
  -- Create status record so labor distribution knows Report finished
  --


/*#
* This procedure is called in the overtime calculation report PAXDLCOT.rdf to
* create a status record for the overtime calculation program. This record lets
* the costing program know whether the overtime calculation program is complete.
* @param R_P_User_ID Identifier of the user
* @rep:paraminfo {@rep:required}
* @param R_P_Request_ID Standard Who column
* @rep:paraminfo {@rep:required}
* @param R_P_Program_ID Standard Who column
* @rep:paraminfo {@rep:required}
* @param R_P_Program_App_ID Standard Who column
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create status record.
* @rep:compatibility S
*/
  procedure create_status_record(
		R_P_User_ID			IN      number,
		R_P_Request_ID			IN      number,
		R_P_Program_ID			IN      number,
		R_P_Program_App_ID		IN      number);

end PA_CALC_OVERTIME;

 

/
