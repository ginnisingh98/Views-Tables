--------------------------------------------------------
--  DDL for Package Body PA_DATE_OVERLAP_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DATE_OVERLAP_CHECKS" as
-- $Header: PAXDTCHB.pls 120.2 2005/08/08 12:40:10 sbharath noship $


--
--  PROCEDURE
--              date_overlap_check_lcm
--  PURPOSE
--              This procedure checks if there are any labor
--              cost multipliers whose dates are overlapping.
--              If overlapping dates exists then it returns
--              0 along with the labor cost multiplier name.
--  HISTORY
--   14-FEB-96      Sandeep        Created
--
Procedure date_overlap_check_lcm
           ( X_Status       Out NOCOPY Number,
             X_Error_Text   Out NOCOPY Varchar2,
             X_Labor_Cost_Multiplier_Name Out NOCOPY Varchar2 ) is


  cursor c1 is
      select  a.labor_cost_multiplier_name
        from  pa_labor_cost_multipliers a,
              pa_labor_cost_multipliers b
       where  a.labor_cost_multiplier_name = b.labor_cost_multiplier_name
         and  (a.start_date_active  between b.start_date_active
         and   nvl(b.end_date_active, a.start_date_active + 1)
          or   a.end_date_active  between b.start_date_active
         and   nvl(b.end_date_active, a.end_date_active + 1)
          or   b.start_date_active  between a.start_date_active
         and   nvl(a.end_date_active, b.start_date_active + 1))
         and   a.rowid <> b.rowid ;

     X_LCM_Name        Varchar2(100);

Begin
     open  c1;
     fetch c1
      into X_Labor_Cost_Multiplier_Name;

     if c1%found  then
        X_Status  :=  0 ;
--        X_Labor_Cost_Multiplier_Name := X_LCM_Name ;
     else
        close c1;
        raise no_data_found;
     end if;
     close c1;

Exception
       When Others Then
           X_Status      := SQLCODE;
           X_Error_Text  := SQLERRM;
           X_Labor_Cost_Multiplier_Name := NULL;
End date_overlap_check_lcm;


END PA_DATE_OVERLAP_CHECKS;

/
