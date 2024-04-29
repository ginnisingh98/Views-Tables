--------------------------------------------------------
--  DDL for Package Body WIP_BIS_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_BIS_COMMON" AS
/* $Header: wipbcomb.pls 120.0 2005/05/24 18:04:52 appldev noship $ */


/* Private Global Variables  */

   g_legal_entity NUMBER := 204 ;

/* Public Procedures  */

FUNCTION GET_SEGMENT( str IN VARCHAR2,
                      delim IN VARCHAR2,
                      segment_num IN NUMBER ) RETURN VARCHAR2 IS
  -- first segment is segment #0
  l_str VARCHAR2(1000);
BEGIN
  l_str := str || delim;
  if segment_num = 0 then
      return substr(str, 1, instr(l_str, delim, 1, 1)-1);
  else
      return substr(str, instr(l_str, delim, 1, segment_num)+1,
                         instr(l_str, delim, 1, segment_num+1) -
                         instr(l_str, delim, 1, segment_num) - 1 );
  end if;

END GET_SEGMENT;


  function Avg_Employee_Num
		       (p_acct_period_id    IN  NUMBER,
			p_organization_id   IN  NUMBER)
  return NUMBER is

  Cursor Employee_Num(p_date DATE, p_organization_id NUMBER) is
   select count(assignment_id)
   from per_all_assignments_f
   where primary_flag = 'Y'
     and assignment_type = 'E'
     and trunc(p_date) between effective_start_date and effective_end_date
     and organization_id = p_organization_id;

   x_start_date DATE;
   x_close_date DATE;
   x_initial_count NUMBER;
   x_final_count NUMBER;

  begin

	begin

		select PERIOD_START_DATE, SCHEDULE_CLOSE_DATE
		into   x_start_date, x_close_date
		from  org_acct_periods
		where ACCT_PERIOD_ID = p_acct_period_id
		and   ORGANIZATION_ID = p_organization_id ;

	exception

	   when NO_DATA_FOUND then

		return null ;
	end ;


	OPEN Employee_Num (x_start_date, p_organization_id) ;
        FETCH Employee_Num INTO x_initial_count;
        if (Employee_Num%NOTFOUND) then
                CLOSE Employee_Num;
        end if;
        CLOSE Employee_Num;

        OPEN Employee_Num (x_close_date, p_organization_id) ;
        FETCH Employee_Num INTO x_final_count;
        if (Employee_Num%NOTFOUND) then
                CLOSE Employee_Num;
        end if;
        CLOSE Employee_Num;


   	return (x_initial_count+x_final_count)/2 ;


  end Avg_Employee_Num;


  function get_Legal_Entity
  return NUMBER is

  begin

        return g_legal_entity;

  end get_Legal_Entity ;


  procedure set_Legal_Entity(p_legal_entity in NUMBER ) is
  begin

	g_legal_entity := p_legal_entity ;
        return ;

  end set_Legal_Entity ;

  function get_Period_Target
                       (p_calendar    	IN  VARCHAR2,
                        p_period_value  IN  VARCHAR2,
			p_organization_id IN NUMBER,
			p_indicator     IN VARCHAR2)
  return NUMBER
  IS
  x_target        NUMBER;
  x_organization  VARCHAR2(250);
  s_cursor        NUMBER;
  ignore          NUMBER;
  selstmt         VARCHAR2(2000);
  Begin

/*
   begin

	select organization_name into x_organization
	from   org_organization_definitions
	where  organization_id = p_organization_id ;

   exception
	when others then

	  x_organization := null ;

   end ;

*/


    if (p_indicator = 'WIPBIIT') then
        select target
          into x_target
          from bis_wipbiitorgprd_v
         where organization = p_organization_id
           and calendar = p_calendar
           and period_value = p_period_value;
    elsif (p_indicator = 'WIPBIPA') then
        select target
          into x_target
	 from  bis_wipbipaorgprd_v
         where organization = p_organization_id
           and calendar = p_calendar
           and period_value = p_period_value;
    elsif (p_indicator = 'WIPBIUZ') then
        select target
          into x_target
          from bis_wipbiuzorgprd_v
         where organization = p_organization_id
           and calendar = p_calendar
           and period_value = p_period_value;
    elsif (p_indicator = 'WIPBIEF') then
        select target
          into x_target
          from bis_wipbieforgprd_v
         where organization = p_organization_id
           and calendar = p_calendar
           and period_value = p_period_value;
    end if;

    return x_target ;

    exception
        when no_data_found then
            x_target := null;
	    return x_target ;


  End get_Period_Target ;

END WIP_BIS_COMMON ;

/
