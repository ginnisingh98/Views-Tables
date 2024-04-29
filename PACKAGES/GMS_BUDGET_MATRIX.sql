--------------------------------------------------------
--  DDL for Package GMS_BUDGET_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BUDGET_MATRIX" AUTHID CURRENT_USER as
 -- $Header: GMSBUMXS.pls 120.1 2005/07/26 14:21:28 appldev ship $
--==============================================================

--
-- Define Global Variables, Functions and Procedure
--

-- Define Global Variables
-- Global Record
	TYPE GlobalVars IS RECORD
	(	  Project_id                    NUMBER(15)
		, Budget_version_id             NUMBER(15)
		, Task_Id			NUMBER(15)
		, Prd1			        DATE
		, Prd2			        DATE
		, Prd3			        DATE
		, Prd4			        DATE
		, Prd5			        DATE
		, Totals_start_date	        DATE
		, Totals_end_date	        DATE
		, Raw_cost_flag		        VARCHAR2(2)
		, Burdened_cost_flag	        VARCHAR2(2)
		, Revenue_flag  	        VARCHAR2(2)
		, Quantity_flag  	        VARCHAR2(2)

	);

GlobVars	GlobalVars;

--
------------------------------------------------------------------------------------------
-- Define Functions to help pass Global Variables from to Views
------------------------------------------------------------------------------------------
--

--  Derive Project_id
	FUNCTION Get_Project_id RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( Get_Project_id, WNDS, WNPS );

--  Derive Budget_version_id
	FUNCTION Get_Budget_version_id RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( Get_Budget_version_id, WNDS, WNPS );

--  Derive Task Id
	FUNCTION Get_Task_Id RETURN NUMBER;
	pragma RESTRICT_REFERENCES  ( Get_Task_Id, WNDS, WNPS );

--  Derive Prd1
	FUNCTION Get_Prd1 RETURN DATE;
	pragma RESTRICT_REFERENCES  ( Get_prd1, WNDS, WNPS );

--  Derive Prd2
	FUNCTION Get_Prd2 RETURN DATE;
	pragma RESTRICT_REFERENCES  ( Get_prd2, WNDS, WNPS );

--  Derive Prd3
	FUNCTION Get_Prd3 RETURN DATE;
	pragma RESTRICT_REFERENCES  ( Get_prd3, WNDS, WNPS );

--  Derive Prd4
	FUNCTION Get_Prd4 RETURN DATE;
	pragma RESTRICT_REFERENCES  ( Get_prd4, WNDS, WNPS );

--  Derive Prd5
	FUNCTION Get_Prd5 RETURN DATE;
	pragma RESTRICT_REFERENCES  ( Get_prd5, WNDS, WNPS );

--  Derive Totals_start_date
        FUNCTION Get_totals_start_date RETURN DATE;
	pragma RESTRICT_REFERENCES  ( Get_totals_start_date, WNDS, WNPS );

--  Derive Totals_end_date
        FUNCTION Get_totals_end_date RETURN DATE;
	pragma RESTRICT_REFERENCES  ( Get_totals_end_date, WNDS, WNPS );

--  Derive Raw Cost Flag
	FUNCTION Get_Raw_Cost_Flag RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Raw_cost_Flag, WNDS, WNPS );

--  Derive Burdened Cost Flag
	FUNCTION Get_Burdened_Cost_Flag RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Burdened_cost_Flag, WNDS, WNPS );

--  Derive Quantity Flag
	FUNCTION Get_Quantity_Flag RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Quantity_Flag, WNDS, WNPS );

--  Derive Revenue Flag
	FUNCTION Get_Revenue_Flag RETURN VARCHAR2;
	pragma RESTRICT_REFERENCES  ( Get_Revenue_Flag, WNDS, WNPS );

--  Define Procedure to Set Global Variables for Aforementioned Functions
--

	PROCEDURE  gms_budget_matrix_driver (
				x_project_id     		IN 	NUMBER
				, x_Budget_version_id		IN 	NUMBER
				, x_task_id			IN	NUMBER
				, x_Prd1	        	IN	DATE
				, x_Prd2	        	IN	DATE
				, x_Prd3	        	IN	DATE
				, x_Prd4	        	IN	DATE
				, x_Prd5	        	IN	DATE
				, x_totals_start_date           IN      DATE
				, x_totals_end_date             IN      DATE
				, x_Raw_cost_flag	        IN      VARCHAR2
				, x_Burdened_cost_flag	        IN      VARCHAR2
				, x_Revenue_flag  	        IN      VARCHAR2
				, x_Quantity_flag  	        IN      VARCHAR2);

	PROCEDURE  gms_calc_side_totals(
				x_project_id                    IN      NUMBER
				, x_Budget_version_id           IN      NUMBER
				, x_task_id                     IN      NUMBER
				, x_RLMI                        IN      NUMBER
				, x_Totals_start_date           IN      DATE
				, x_Totals_end_date             IN      DATE
				, x_amt_type                    IN      VARCHAR2
				, x_tot                         IN OUT NOCOPY  NUMBER
				, x_tot2                        IN OUT NOCOPY  NUMBER );



PROCEDURE  gms_calc_bottom_totals(
			x_project_id                    IN      NUMBER
			, x_Budget_version_id           IN      NUMBER
			, x_task_id                     IN      NUMBER
			, x_start_date                  IN      DATE
			, x_end_date                    IN      DATE
			, x_list_view_totals            IN OUT NOCOPY  VARCHAR2
			, x_p1                          IN OUT NOCOPY  VARCHAR2
			, x_p2                          IN OUT NOCOPY  VARCHAR2
			, x_p3                          IN OUT NOCOPY  VARCHAR2
			, x_p4                          IN OUT NOCOPY  VARCHAR2
			, x_p1_tot                      IN OUT NOCOPY  NUMBER
			, x_p2_tot                      IN OUT NOCOPY  NUMBER
			, x_p3_tot                      IN OUT NOCOPY  NUMBER
			, x_p4_tot                      IN OUT NOCOPY  NUMBER );


PROCEDURE  gms_calc_grand_totals(
			x_project_id                    IN      NUMBER
			, x_Budget_version_id           IN      NUMBER
			, x_task_id                     IN      NUMBER
			, x_start_date                  IN      DATE
			, x_end_date                    IN      DATE
			, x_list_view_totals            IN OUT NOCOPY  VARCHAR2
			, x_grand_tot                   IN OUT NOCOPY  NUMBER );



END gms_budget_matrix;

 

/
