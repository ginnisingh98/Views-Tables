--------------------------------------------------------
--  DDL for Package Body FA_MASS_ADD_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_ADD_VALIDATE" as
--$Header: faxmadb.pls 120.3.12010000.3 2009/08/05 20:24:57 bridgway ship $

--
--
--  FUNCTION
--              check_valid_asset_number
--  PURPOSE
--              This function returns
--                 1 if asset number has not been used by FA and
--                      does not conflict with FA automatic numbers
--                 0 if asset number is already in use
--                 2 if asset number is not in use, but conflicts with FA
--                      automatic numbering
--
--              If Oracle error occurs, Oracle error number is returned.
--
--
--  HISTORY
--   28-NOV-95      C. Conlin       Created
--
--

function check_valid_asset_number (x_asset_number  IN varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                                    return number
is

    cursor c2 is
          select asset_number
          from fa_additions
          where asset_number = x_asset_number;

    c2_rec c2%rowtype;

    cursor c3 is
          select asset_number
          from fa_mass_additions
          where asset_number = x_asset_number;

    c3_rec c3%rowtype;

    x_numeric_asset_number NUMBER;

    cursor c5 is
	select initial_asset_id
	from fa_system_controls
	where initial_asset_id < x_numeric_asset_number;

    c5_rec c5%rowtype;


begin
        if (x_asset_number is null ) then
            return(null);
        end if;

	open c2;
	fetch c2 into c2_rec;
	--asset number used in fa_additions table?
	if c2%notfound then
	  open c3;
          fetch c3 into c3_rec;
          --asset number used in fa_mass_additions table?
          if c3%notfound then
		BEGIN
       		x_numeric_asset_number := TO_NUMBER(x_asset_number);
		--asset number all numeric?
		EXCEPTION
		WHEN VALUE_ERROR THEN
                  return(1);
		END;
		--asset number conflict with automatic numbering?
		open c5;
	 	fetch c5 into c5_rec;
		if c5%notfound then
		   return(1);
		else
		   return(2);
		end if;
		close c5;
	   else
	     return(0);
	   end if;
	   close c3;
        else
           return(0);
        end if;
        close c2;

exception
   when others then
        return(SQLCODE);

end check_valid_asset_number;


--
--  FUNCTION
--              can_add_to_asset
--  PURPOSE
--              This function returns 1 if the asset can receive
--              additional cost and returns 0 if the asset cannot
--              receive additional cost.
--
--              If Oracle error occurs, Oracle error number is returned.
--
--  USAGE	The asset_id parameter should be the FA (not PA) asset_id
--		(find in fa_additions) for the asset to be added to.
--
--		The book_type_code parameter should be the book_type_code
--		found on the invoice line you are attempting to add.  (This
--		should be the same book type code as on the asset.)
--
--
--
--  HISTORY
--   28-NOV-95      C. Conlin       Created
--
--

function can_add_to_asset(x_asset_id  IN number,
			  x_book_type_code IN varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
					 return number
is

    cursor c1 is
          select asset_type
          from fa_additions
          where asset_id = x_asset_id;

    c1_rec c1%rowtype;


    cursor c2 is
          select book_class
          from fa_book_controls
          where book_type_code = x_book_type_code;

    c2_rec c2%rowtype;

    cursor c3 is
	select asset_id
	from fa_books
	where x_asset_id = fa_books.asset_id
	and exists
	  (select 1 from fa_books fabk
	   where x_asset_id = fabk.asset_id
		and fabk.book_type_code = x_book_type_code
		and fabk.date_ineffective is null
		and fabk.period_counter_fully_retired is null
		and (fabk.period_counter_fully_reserved is null or
		    (fabk.period_counter_fully_reserved is not null
		and fabk.period_counter_life_complete is not null))
		and not exists
		   (select 1 from fa_retirements faret
		    where faret.asset_id = x_asset_id
		    and faret.book_type_code = x_book_type_code
		    and faret.status in
			('PENDING','REINSTATE','PARTIAL')));
    c3_rec c3%rowtype;



BEGIN
    open c1;
    fetch c1 into c1_rec;
    if c1_rec.asset_type = 'EXPENSED' then
	close c1;
	return(0);
    else
	close c1;
	open c2;
	fetch c2 into c2_rec;
	if c2_rec.book_class <> 'CORPORATE' then
	  close c2;
	  return(0);
	else
	  close c2;
	  open c3;
	  fetch c3 into c3_rec;
	  if c3%notfound then
	    close c3;
	    return(0);
	  else
	    close c3;
	    return(1);
	  end if;
	end if;
    end if;
exception
  when others then
	return(SQLCODE);
end can_add_to_asset;

--  FUNCTION
--             valid_date_in_service
--  PURPOSE
--	The function returns a 1 if the date in service is valid
--	and returns a 0 if the date in service is not valid.
--
--
--
--  HISTORY
--   28-NOV-95      C. Conlin       Created



function valid_date_in_service(x_date_in_service  IN date,
				x_book_type_code IN varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                                         return number
is
    cursor c1 (x_date_in_service IN date) is
        select count(*) dummy
        from fa_deprn_periods dp, fa_book_controls bc
	where trunc(x_date_in_service) >
	   trunc(nvl(dp.calendar_period_close_date,
		x_date_in_service))
	and bc.book_class = 'CORPORATE'
	and bc.book_type_code = nvl(x_book_type_code, 'X')
	and dp.book_type_code = nvl(x_book_type_code, 'X')
	and dp.period_close_date is null;
    c1_rec c1%rowtype;

/*
    cursor c2 is
	select greatest(dp.calendar_period_open_date,
		 least(sysdate, dp.calendar_period_close_date))
		 valid_date
	from fa_deprn_periods dp
	where dp.book_type_code = nvl(x_book_type_code, 'X')
	and dp.period_close_date is null;
    c2_rec c2%rowtype;
*/
--not necessary for PA purposes.  FA should include in their packages.


BEGIN

 IF (x_date_in_service is null) OR
	(x_book_type_code is null)THEN
	return(0);
 END IF;

 open c1(x_date_in_service);
 fetch c1 into c1_rec;
 if c1_rec.dummy =  0 then
	close c1;
	return(1);
 else
	close c1;
	return(0);
 end if;

exception
   when others then
       return(SQLCODE);
end valid_date_in_service;


end fa_mass_add_validate;

/
