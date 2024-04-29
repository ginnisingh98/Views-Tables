--------------------------------------------------------
--  DDL for Package Body EDW_TIME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_TIME_PKG" AS
/* $Header: FIICATMB.pls 120.0 2002/08/24 04:50:22 appldev noship $  */
VERSION  CONSTANT CHAR(80) := '$Header: FIICATMB.pls 120.0 2002/08/24 04:50:22 appldev noship $';

-- --------------------------------------------------------------
-- Name: cal_day_fk
-- Performance: 4 buffer gets per call
-- --------------------------------------------------------------
function cal_day_fk(cal_date              date,
                    p_set_of_books_id     number,
                    p_instance_code in VARCHAR2:=NULL)
return varchar2 is
l_accounted_period_type    Varchar2(15) := NULL;
l_period_set_name          Varchar2(15) := NULL;
l_instance                 Varchar2(40) := NULL;
x_no_data_found            EXCEPTION;

cursor c1 is
select	ins.instance_code,
        sob.accounted_period_type,
        sob.period_set_name
from 	edw_local_instance ins,
        gl_sets_of_books sob
where 	set_of_books_id = p_set_of_books_id;

begin

-- ----------------------------------------------------
-- For performance reasons, we will not check if the
-- input date falls in a valid GL period.  If not
-- within a valid period, the record will get rejected
-- in the warehouse.
-- ----------------------------------------------------

if (cal_date is null) or
   (p_set_of_books_id is null)
then
   return('NA_EDW');
else
   OPEN c1;
   FETCH c1 into l_instance, l_accounted_period_type,l_period_set_name;
   CLOSE c1;
end if;

if (p_instance_code is not NULL)
then
   l_instance := p_instance_code;
end if;

if (l_period_set_name is NULL)
then
   -- Cursor did not find any records
   RAISE x_no_data_found;
else
   return(to_char(cal_date,'dd-mm-yyyy') || '-' || l_period_set_name || '-' ||
          l_accounted_period_type || '-' || l_instance ||'-CD');
end if;

exception
    when x_no_data_found then
	raise_application_error(-20000, 'No data found, cal_date='||
		to_char(cal_date)||',sob_id='||p_set_of_books_id);
    when others then
        if c1%ISOPEN then
                close c1;
        end if;
        raise_application_error(-20000, 'Other Error, cal_date='||
		to_char(cal_date)||',sob_id='||p_set_of_books_id);

end;


-- --------------------------------------------------------------
-- Name: cal_period_fk
-- Performance: 4 buffer gets per call
-- --------------------------------------------------------------
function cal_period_fk(cal_period          varchar2,
                       p_set_of_books_id     number,
                       p_instance_code in VARCHAR2:=NULL)
return varchar2 is
l_period_set_name          Varchar2(15) := NULL;
l_instance                 Varchar2(40) := NULL;
x_no_data_found            EXCEPTION;

cursor c1 is
select	ins.instance_code,
  	sob.period_set_name
from 	edw_local_instance ins,
	gl_sets_of_books sob
where 	set_of_books_id = p_set_of_books_id;

begin

if ((cal_period is null) or
   (p_set_of_books_id is null))
then
  return('NA_EDW');
else
  OPEN c1;
  FETCH c1 into l_instance, l_period_set_name;
  CLOSE c1;
end if;

if (p_instance_code is not NULL)
then
   l_instance := p_instance_code;
end if;

if (l_period_set_name is NULL)
then
  -- Cursor did not find any records
  RAISE x_no_data_found;
else
  return(l_period_set_name||'-'||cal_period||'-'||l_instance||'-CPER');
end if;

exception
    when x_no_data_found then
        raise_application_error(-20000, 'No data found, cal_period='||
                cal_period||',sob_id='||p_set_of_books_id);
    when others then
        if c1%ISOPEN then
                close c1;
        end if;
        raise_application_error(-20000, 'Other Error, cal_period='||
                cal_period||',sob_id='||p_set_of_books_id);

end;



-- --------------------------------------------------------------
-- Name: cal_day_to_cal_period_fk
-- Performance: 15.5 buffer gets per call
-- --------------------------------------------------------------
function cal_day_to_cal_period_fk(cal_date              date,
                                  p_set_of_books_id     number,
                                  p_instance_code in VARCHAR2:=NULL)
return varchar2 is
l_period_set_name          Varchar2(15) := NULL;
l_instance                 Varchar2(40) := NULL;
l_gl_period                Varchar2(30) := NULL;
x_no_data_found            EXCEPTION;

cursor c1 is
select  ins.instance_code,
	maps.period_set_name,
	maps.period_name
from	edw_local_instance ins,
	gl_sets_of_books sob,
	gl_date_period_map maps
where	maps.period_set_name = sob.period_set_name
and	maps.period_type = sob.accounted_period_type
and	maps.accounting_date = trunc(cal_date)
and	sob.set_of_books_id = p_set_of_books_id;

begin
if (cal_date is null) or
   (p_set_of_books_id is null)
then
   return('NA_EDW');
else
   OPEN c1;
   FETCH c1 into l_instance, l_period_set_name, l_gl_period;
   CLOSE c1;
end if;

if (p_instance_code is not NULL)
then
   l_instance := p_instance_code;
end if;

if (l_period_set_name is NULL) then
  -- Cursor did not find any records
  RAISE x_no_data_found;
end if;

return(l_period_set_name
         ||'-' || l_gl_period || '-' || l_instance ||'-CPER');

exception
    when x_no_data_found then
        raise_application_error(-20000, 'No data found, cal_date='||
                cal_date||',sob_id='||p_set_of_books_id);
    when others then
        if c1%ISOPEN then
                close c1;
        end if;
        raise_application_error(-20000, 'Other Error, cal_date='||
                cal_date||',sob_id='||p_set_of_books_id);
end;


-- --------------------------------------------------------------
-- Name: pa_cal_day_fk
-- Performance: 6 buffer gets per call
-- --------------------------------------------------------------
Function pa_cal_day_fk(p_cal_date       IN date,
                       p_org_id         IN number DEFAULT NULL,
                       p_instance_code  IN VARCHAR2:=NULL)
return varchar2 is
l_period_set_name   Varchar2(15) := NULL;
l_period_type       Varchar2(15) := NULL;
l_instance          Varchar2(40) := NULL;
x_no_data_found     EXCEPTION;


-- Cursor for Multi-org install
cursor c1 is
   select ins.instance_code,
          gl.period_set_name,
          imp.pa_period_type
   from   edw_local_instance ins,
          pa_implementations_all imp,
          gl_sets_of_books gl
   where  imp.org_id = p_org_id
   and    gl.set_of_books_id = imp.set_of_books_id;

-- Cursor for Single org install
cursor c2 is
   select ins.instance_code,
          gl.period_set_name,
          imp.pa_period_type
   from   edw_local_instance ins,
          pa_implementations_all imp,
          gl_sets_of_books gl
   where  imp.org_id is NULL
   and    gl.set_of_books_id = imp.set_of_books_id;

begin

-- ----------------------------------------------------
-- Decided not to check if the date falls in the
-- a valid PA period.  If not within a valid period,
-- the record will get rejected in the warehouse
-- ----------------------------------------------------

if (p_cal_date is NULL)
then
   return 'NA_EDW';
elsif (p_org_id is NULL)
then
  OPEN c2;
  FETCH c2 into l_instance, l_period_set_name, l_period_type;
  CLOSE c2;
else
  OPEN c1;
  FETCH c1 into l_instance, l_period_set_name, l_period_type;
  CLOSE c1;
end if;

if (p_instance_code is not NULL)
then
   l_instance := p_instance_code;
end if;

if (l_period_set_name is NULL)
then
  -- Cursor did not find any records
  RAISE x_no_data_found;
else
  return (to_char(p_cal_date,'dd-mm-yyyy') || '-' || l_period_set_name
          || '-' || l_period_type ||'-' || l_instance ||'-PD');
end if;

exception
    when x_no_data_found then
	raise_application_error(-20000, 'No data found, cal_date='||
		to_char(p_cal_date)||',org_id='||p_org_id);
    when others then
        if c1%ISOPEN then
                close c1;
        end if;
        if c2%ISOPEN then
                close c2;
        end if;
        raise_application_error(-20000, 'Other Error, cal_date='||
		to_char(p_cal_date)||',org_id='||p_org_id);
end;


end;

/
