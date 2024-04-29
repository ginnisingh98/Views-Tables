--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_STATUS" AUTHID CURRENT_USER as
/* $Header: PAXVPS2S.pls 120.2 2006/07/21 09:15:52 ajdas noship $   */
/*#
 * You can use a PSI client extension to derive an alternate column value, even if you have entered a column definition in the PSI Columns
 * window. You can also use the extension to override the totals fields in the Project window.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Project Status inquiry(PSI)
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_PERF_REPORTING
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

--=======================================================
--
-------------------------------------------------------------------------------------------------
-- Function to determine if the corresponding body should be used by the
-- Post-Query trigger in Project Status Inquiry form.
--------------------------------------------------------------------------------------------------
--

FUNCTION ProjCustomExtn RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  (ProjCustomExtn, WNDS, WNPS );

FUNCTION TaskCustomExtn RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  (TaskCustomExtn, WNDS, WNPS );

FUNCTION RsrcCustomExtn RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  (RsrcCustomExtn, WNDS, WNPS );

--------------------------------------------------------------------------------------------
-- 14-JUL-99, jwhite: Added Functions for PSI Project Status Totals Functionality

FUNCTION Hide_Totals    RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  (Hide_Totals, WNDS, WNPS );

FUNCTION Proj_Tot_Custom_Extn RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  (Proj_Tot_Custom_Extn, WNDS, WNPS );
--
--------------------------------------------------------------------------------------------


--
-------------------------------------------------------------------------------
-- Generic Procedure to Process Derived Columns in Oracle Forms'
--  Project Status Inquiry
-------------------------------------------------------------------------------
--




/*#
* If you enable the Get Columns procedure, the Project Status window display the column prompts defined in the PSI Columns window and
* the values calculated by the extension.Because the values calculated by the extension override values defined values defined in the
* PSI Columns window ,you do not need to enter a definition for a column whose value is Calculated by a client extension.
* @param x_project_id The identifier of the project.
* @rep:paraminfo {@rep:required}
* @param x_task_id The identifier of the task. This value is set to 0 if called for the project level columns.
* @rep:paraminfo {@rep:required}
* @param x_resource_list_member_id  The identifier for the resource. This value is set to 0 if called for project or task level columns.
* @rep:paraminfo {@rep:required}
* @param x_cost_budget_type_code    The identifier of the cost budget type displayed in PSI.
* @rep:paraminfo {@rep:required}
* @param x_rev_budget_type_code   The identifier of the revenue budget type displayed in PSI.
* @rep:paraminfo {@rep:required}
* @param x_status_view   The identifier of the status folder: PROJECTS, TASKS, or RESOURCES
* @rep:paraminfo {@rep:required}
* @param x_pa_install The identifier of the Oracle Projects product installed:BILLING or COSTING.
* BILLING includes all default PSI columns. COSTING includes all but the actual revenue and revenue budget columns.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_1 Three alphanumeric derived columns. Each can have up to 255 characters. Note: Column 1
* refers to the first column in both the PSI Columns and the Project Status windows, Column 2 refers to the second
* column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_2 Three alphanumeric derived columns. Each can have up to 255 characters. Note: Column 1
* refers to the first column in both the PSI Columns and the Project Status windows, Column 2 refers to the second
* column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_3 Three alphanumeric derived columns. Each can have up to 255 characters. Note: Column 1
* refers to the first column in both the PSI Columns and the Project Status windows, Column 2 refers to the second
* column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_4 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_5 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_6 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_7 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_8 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_9 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_10 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_11 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_12 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_13 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_14 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_15 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_16 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_17 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_18 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_19 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_20 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_21 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_22 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_23 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_24 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_25 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_26 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_27 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_28 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_29 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_30 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_31 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_32 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @param x_derived_col_33 30 numeric derived columns.Note: Column 4 refers to the fourth column in both the PSI
* Columns and the Project Status windows, Column 5 refers to the fifth column in each window, etc.
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Columns.
* @rep:compatibility S
*/






PROCEDURE getcols
		(x_project_id				IN NUMBER
		, x_task_id				IN NUMBER
		, x_resource_list_member_id		IN NUMBER
		, x_cost_budget_type_code		IN VARCHAR2
		, x_rev_budget_type_code			IN VARCHAR2
		, x_status_view				IN VARCHAR2
		, x_pa_install				IN VARCHAR2
		, x_derived_col_1			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
		, x_derived_col_2			OUT NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
		, x_derived_col_3			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
		, x_derived_col_4			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_5			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_6			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_7			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_8			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_9			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_10			OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_derived_col_11			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_12			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_13			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_14			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_15			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_16			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_17			OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_derived_col_18			OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_derived_col_19			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_20			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_21			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_22			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_23			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_24			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_25			OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_derived_col_26			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_27			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_28			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_29			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_30			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_31			OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_derived_col_32			OUT NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_derived_col_33			OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

--
-------------------------------------------------------------------------------
-- 03-AUG-99, jwhite
-- Generic Procedure to Process Totals
-------------------------------------------------------------------------------
--

/*#
* If you enable the PSI Totals client extension, you can override the total fields for all thirty numeric columns on the project window
* for which you assign values to the OUT-parameters.The project window displays NULL for any OUT-parameter that is not assigned a value.
* @param x_where_clause  The where clause of the totals query statement.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column4 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column5 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column6 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column7 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column8 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column9 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column10 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column11 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column12 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column13 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column14 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column15 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column16 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column17 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column18 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column19 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column20 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column21 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column22 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column23 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column24 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column25 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column26 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column27 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column28 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column29 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column30 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column31 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column32 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_in_tot_column33 30 totals columns. The totals query assigns the totals that it returns to these columns.
* Column 4 refers to the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column4 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column5 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column6 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column7 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column8 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column9 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column10 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column11 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column12 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column13 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column14 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column15 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column16 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column17 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column18 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column19 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column20 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column21 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column22 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column23 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column24 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column25 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column26 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column27 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column28 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column29 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column30 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column31 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column32 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_out_tot_column33 30 totals columns.The totals assigned by the Get_Totals procedure. Column 4 refers to
* the fourth column in the PSI columns and the Project Status Inquiry windows.
* @rep:paraminfo {@rep:required}
* @param x_error_code Error handling code. NOTE: A non-zero number invokes error
* processing by the PSI Project window and terminates totals processing.
* @rep:paraminfo {@rep:required}
* @param  x_error_message  User-defined error message.The non-zero error handling
* code and the user-defined message are displayed to the user in the event of an error.
* To facilitate debugging, the PSI Project window displays the totals returned by the totals
* query from PA_STATUS_PROJ_TOTALS_V.
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Totals.
* @rep:compatibility S
*/


PROCEDURE Get_Totals
		(x_where_clause                         IN     VARCHAR2
		, x_in_tot_column4			IN     NUMBER
		, x_in_tot_column5			IN     NUMBER
		, x_in_tot_column6			IN     NUMBER
		, x_in_tot_column7			IN     NUMBER
		, x_in_tot_column8			IN     NUMBER
		, x_in_tot_column9			IN     NUMBER
		, x_in_tot_column10			IN     NUMBER
		, x_in_tot_column11			IN     NUMBER
		, x_in_tot_column12			IN     NUMBER
		, x_in_tot_column13			IN     NUMBER
		, x_in_tot_column14			IN     NUMBER
		, x_in_tot_column15			IN     NUMBER
		, x_in_tot_column16			IN     NUMBER
		, x_in_tot_column17			IN     NUMBER
		, x_in_tot_column18			IN     NUMBER
		, x_in_tot_column19			IN     NUMBER
		, x_in_tot_column20			IN     NUMBER
		, x_in_tot_column21			IN     NUMBER
		, x_in_tot_column22			IN     NUMBER
		, x_in_tot_column23			IN     NUMBER
		, x_in_tot_column24			IN     NUMBER
		, x_in_tot_column25			IN     NUMBER
		, x_in_tot_column26			IN     NUMBER
		, x_in_tot_column27			IN     NUMBER
		, x_in_tot_column28			IN     NUMBER
		, x_in_tot_column29			IN     NUMBER
		, x_in_tot_column30			IN     NUMBER
		, x_in_tot_column31			IN     NUMBER
		, x_in_tot_column32			IN     NUMBER
		, x_in_tot_column33			IN     NUMBER
		, x_out_tot_column4			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column5			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column6			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column7			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column8			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column9			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column10			OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_out_tot_column11			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column12			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column13			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column14			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column15			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column16			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column17			OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_out_tot_column18			OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_out_tot_column19			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column20			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column21			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column22			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column23			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column24			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column25			OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_out_tot_column26			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column27			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column28			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column29			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column30			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column31			OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
		, x_out_tot_column32			OUT    NOCOPY NUMBER 	 --File.Sql.39 bug 4440895
		, x_out_tot_column33			OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
                , x_error_code                          OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
                , x_error_message                       OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                );

END  pa_client_extn_status;

 

/
