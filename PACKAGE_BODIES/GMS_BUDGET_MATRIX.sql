--------------------------------------------------------
--  DDL for Package Body GMS_BUDGET_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BUDGET_MATRIX" AS
 -- $Header: GMSBUMXB.pls 120.1 2005/07/26 14:21:25 appldev ship $
--================================================================
--
--
------------------------------------------------------------------------------------------------------------------
-- Functions and Procedures to Drive Budget Matrix Form Views
------------------------------------------------------------------------------------------------------------------
--

FUNCTION Get_project_id RETURN NUMBER
IS
BEGIN

	RETURN (  GlobVars.project_id );
END;

FUNCTION Get_budget_version_id RETURN NUMBER
IS
BEGIN

	RETURN (  GlobVars.Budget_version_id );
END;

FUNCTION Get_Task_Id RETURN NUMBER
IS
BEGIN

	RETURN ( GlobVars.Task_Id );
END;


FUNCTION Get_prd1 RETURN DATE
IS
BEGIN

	RETURN (  GlobVars.Prd1  );
END;


FUNCTION Get_prd2 RETURN DATE
IS
BEGIN

	RETURN (  GlobVars.Prd2  );
END;


FUNCTION Get_prd3 RETURN DATE
IS
BEGIN

	RETURN (  GlobVars.Prd3  );
END;

FUNCTION Get_prd4 RETURN DATE
IS
BEGIN

	RETURN (  GlobVars.Prd4  );
END;

FUNCTION Get_prd5 RETURN DATE
IS
BEGIN

	RETURN (  GlobVars.Prd5  );
END;

FUNCTION Get_totals_start_date RETURN DATE
IS
BEGIN

	RETURN (  GlobVars.totals_start_date  );
END;

FUNCTION Get_totals_end_date RETURN DATE
IS
BEGIN

	RETURN (  GlobVars.totals_end_date  );
END;


FUNCTION Get_Raw_Cost_Flag RETURN VARCHAR2
IS
BEGIN
       RETURN (GlobVars.Raw_Cost_Flag);
END;

FUNCTION Get_Burdened_Cost_Flag RETURN VARCHAR2
IS
BEGIN
       RETURN (GlobVars.Burdened_Cost_Flag);
END;

FUNCTION Get_Quantity_Flag RETURN VARCHAR2
IS
BEGIN
       RETURN (GlobVars.Quantity_Flag);
END;

FUNCTION Get_Revenue_Flag RETURN VARCHAR2
IS
BEGIN
       RETURN (GlobVars.Revenue_Flag);
END;

PROCEDURE  gms_budget_matrix_driver (
			x_project_id                    IN      NUMBER
			, x_Budget_version_id           IN      NUMBER
			, x_task_id                     IN      NUMBER
			, x_Prd1                        IN      DATE
			, x_Prd2                        IN      DATE
			, x_Prd3                        IN      DATE
			, x_Prd4                        IN      DATE
			, x_Prd5                        IN      DATE
			, x_totals_start_date           IN      DATE
			, x_totals_end_date             IN      DATE
			, x_Raw_cost_flag	        IN      VARCHAR2
			, x_Burdened_cost_flag	        IN      VARCHAR2
			, x_Revenue_flag  	        IN      VARCHAR2
			, x_Quantity_flag  	        IN      VARCHAR2) IS
BEGIN
  GlobVars.project_id             :=      x_project_id;
  GlobVars.Budget_version_id      :=      x_Budget_version_id;
  GlobVars.Task_Id                :=      x_task_id;
  GlobVars.Prd1                   :=      x_Prd1;
  GlobVars.Prd2                   :=      x_Prd2;
  GlobVars.Prd3                   :=      x_Prd3;
  GlobVars.Prd4                   :=      x_Prd4;
  GlobVars.Prd5                   :=      x_Prd5;
  GlobVars.Totals_start_date      :=      x_totals_start_date;
  GlobVars.Totals_end_date        :=      x_totals_end_date;
  GlobVars.Raw_cost_flag          :=      x_Raw_cost_flag;
  GlobVars.Burdened_cost_flag	  :=      x_Burdened_cost_flag ;
  GlobVars.Revenue_flag  	  :=      x_Revenue_flag;
  GlobVars.Quantity_flag  	  :=      x_Quantity_flag;
END gms_budget_matrix_driver;


PROCEDURE  gms_calc_side_totals(
			x_project_id                    IN      NUMBER
			, x_Budget_version_id           IN      NUMBER
			, x_task_id                     IN      NUMBER
			, x_RLMI                        IN      NUMBER
			, x_Totals_start_date           IN      DATE
			, x_Totals_end_date             IN      DATE
			, x_amt_type                    IN      VARCHAR2
			, x_tot                         IN OUT NOCOPY  NUMBER
			, x_tot2                        IN OUT NOCOPY  NUMBER )

IS
 begin
    select sum(
              decode(x_amt_type,'RC',nvl(raw_cost,0),'BC',nvl(burdened_cost,0),'RE',nvl(revenue,0),
                     'QU',decode(track_as_labor_flag,'Y',nvl(quantity,0),0))),
           sum(
              decode(x_amt_type,'RC',nvl(raw_cost,0),'BC',nvl(burdened_cost,0),'RE',nvl(revenue,0),
                     'QU',nvl(quantity,0),0))
    into   x_tot,
           x_tot2
    from   gms_budget_lines_v
    where  budget_version_id = x_budget_version_id
    and    task_id = x_task_id
    and    resource_list_member_id = x_RLMI
    and    project_id  = x_project_id
    and    start_date between x_totals_start_date
                      and  x_totals_end_date  ;
 end;

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
			, x_p4_tot                      IN OUT NOCOPY  NUMBER )


IS
 begin
    select sum(decode(period_name,x_p1,
               decode(x_list_view_totals, 'RC', nvl(raw_cost,0),
                                          'BC', nvl(burdened_cost,0),
                                          'RE', nvl(revenue,0),
                                          'QU', decode(track_As_labor_flag,'Y',nvl(quantity,0),0 ),
                      0), 0) ) ,
           sum(decode(period_name,x_p2,
               decode(x_list_view_totals, 'RC', nvl(raw_cost,0),
                                          'BC', nvl(burdened_cost,0),
                                          'RE', nvl(revenue,0),
                                          'QU', decode(track_As_labor_flag,'Y',nvl(quantity,0),0 ),
                      0), 0) ) ,
           sum(decode(period_name,x_p3,
               decode(x_list_view_totals, 'RC', nvl(raw_cost,0),
                                          'BC', nvl(burdened_cost,0),
                                          'RE', nvl(revenue,0),
                                          'QU', decode(track_As_labor_flag,'Y',nvl(quantity,0),0 ),
                      0), 0) ) ,
           sum(decode(period_name,x_p4,
               decode(x_list_view_totals, 'RC', nvl(raw_cost,0),
                                          'BC', nvl(burdened_cost,0),
                                          'RE', nvl(revenue,0),
                                          'QU', decode(track_As_labor_flag,'Y',nvl(quantity,0),0 ),
                      0), 0) )
    into   x_p1_tot,
           x_p2_tot,
           x_p3_tot,
           x_p4_tot
    from   gms_budget_lines_v
    where  budget_version_id = x_budget_version_id
    and    task_id = x_task_id
    and    project_id  = x_project_id
    and    start_date between x_start_date
                      and  x_end_date  ;
 end;

PROCEDURE  gms_calc_grand_totals(
			x_project_id                    IN      NUMBER
			, x_Budget_version_id           IN      NUMBER
			, x_task_id                     IN      NUMBER
			, x_start_date                  IN      DATE
			, x_end_date                    IN      DATE
			, x_list_view_totals            IN OUT NOCOPY  VARCHAR2
			, x_grand_tot                   IN OUT NOCOPY  NUMBER )


IS
 begin
    select sum(decode(x_list_view_totals, 'RC', nvl(raw_cost,0),
                                          'BC', nvl(burdened_cost,0),
                                          'RE', nvl(revenue,0),
                                          'QU', decode(track_As_labor_flag,'Y',nvl(quantity,0),0 ),
                      0) )
    into   x_grand_tot
    from   gms_budget_lines_v
    where  budget_version_id = x_budget_version_id
    and    task_id = x_task_id
    and    project_id  = x_project_id
    and    start_date between x_start_date
                      and  x_end_date  ;
end;

END gms_budget_matrix;

/
