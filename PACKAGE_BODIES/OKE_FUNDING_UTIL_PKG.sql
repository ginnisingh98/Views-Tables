--------------------------------------------------------
--  DDL for Package Body OKE_FUNDING_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FUNDING_UTIL_PKG" as
/* $Header: OKEFUTLB.pls 120.0 2005/05/25 17:37:54 appldev noship $ */


--
-- Procedure  : validate_source_pool_amount
--
-- Purpose    : check if there is enough funding from the pool party to be allocated
--
-- Parameters :
--         (in) x_first_amount		number 		amount
--		x_source_id		number		funding_source_id
--		x_pool_party_id		number		pool_party_id
--		x_new_flag		varchar2 	new funding source record
--							Y : new funding source
--
--        (out) x_return_status		varchar2	return status
--							Y : valid
--							N : invalid
--

PROCEDURE validate_source_pool_amount(x_first_amount			number		,
  			   	      x_source_id			number		,
  			   	      x_pool_party_id			number		,
  			   	      x_new_flag			varchar2	,
  			              x_return_status	OUT    NOCOPY	varchar2	) is
   cursor c_pool_party is
   select amount, available_amount
   from   oke_pool_parties
   where  pool_party_id = x_pool_party_id;

   cursor c_source is
   select amount
   from   oke_k_funding_sources
   where  funding_source_id = x_source_id;

  l_amount			number;
  l_available_amount		number;
  --l_allocated_amount		number;
  l_delta			number;
  l_orig_amount			number;

begin

   OPEN c_pool_party;
   FETCH c_pool_party INTO l_amount, l_available_amount;
   CLOSE c_pool_party;

   if (x_new_flag = 'Y') then

      l_delta := x_first_amount;

   else

      OPEN c_source;
      FETCH c_source INTO l_orig_amount;
      CLOSE c_source;

     -- l_allocated_amount := l_amount - l_available_amount;
      l_delta	         := x_first_amount - l_orig_amount;

   end if;

   if (l_delta <= l_available_amount) then

    --  if (l_amount >= l_available_amount - l_delta) then

          x_return_status := 'Y';

    --  else

       --   x_return_status := 'N';

    --  end if;

   else

     x_return_status := 'N';

   end if;

exception
   when NO_DATA_FOUND then
      x_return_status := 'N';
      if (c_source%ISOPEN) then
          close c_source;
      elsif (c_pool_party%ISOPEN) then
          close c_pool_party;
      end if;

end validate_source_pool_amount;



--
-- Procedure  : validate_source_pool_date
--
-- Purpose    : check if
--		 1) funding source start date assocated w/ the pool party >= pool party start date
--               2) funding source end date associated w/ the pool party <= pool party end date
--
-- Parameters :
--         (in) x_start_end			varchar2	date validation choice
--								START : start date
--								END   : end date
--		x_pool_party_id			number		pool party id
--		x_date				date		date to be validated
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_source_pool_date(x_start_end					varchar2	,
  				    x_pool_party_id				number		,
  		         	    x_date					date		,
  		          	    x_return_status	OUT    NOCOPY		varchar2	) is

  cursor c_start_date is
  	select nvl(start_date_active, x_date)
  	from   oke_pool_parties
  	where  pool_party_id = x_pool_party_id;

  cursor c_end_date is
  	select nvl(end_date_active, x_date)
  	from   oke_pool_parties
  	where  pool_party_id = x_pool_party_id;

  compare_date		date;

begin

    if (x_start_end = 'START') then

       open c_start_date;
       fetch c_start_date into compare_date;

       if (c_start_date%notfound) then
          close c_start_date;
          raise no_data_found;
       end if;

       if (x_date >= compare_date) or
       	  (x_date is null and compare_date is null) then

           x_return_status := 'Y';

       else

           x_return_status := 'N';

       end if;

       close c_start_date;

   else

       open c_end_date;
       fetch c_end_date into compare_date;

       if (c_end_date%notfound) then
          close c_end_date;
          raise no_data_found;
       end if;

       if (x_date <= compare_date) or
          (x_date is null and compare_date is null) then

           x_return_status := 'Y';

       else

           x_return_status := 'N';

       end if;

       close c_end_date;

   end if;

exception
   when NO_DATA_FOUND then
   	x_return_status := 'N';

end validate_source_pool_date;



--
-- Procedure  : validate_alloc_source_amount
--
-- Purpose    : check if the new funding source amount >= sum of its allocations
--
-- Parameters :
--         (in) x_source_id			number 		funding source id
--	        x_allocation_id			number		funding allocation id
--		x_amount			number		allocation amount
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_alloc_source_amount(x_source_id				number		,
				       x_allocation_id				number		,
  				       x_amount					number		,
  			   	       x_return_status		OUT    NOCOPY	varchar2	) is

   cursor c_alloc is
     select nvl(sum(amount), 0)
     from   oke_k_fund_allocations
     where  funding_source_id = x_source_id;

   cursor c_source is
      select amount
      from   oke_k_funding_sources
      where  funding_source_id = x_source_id;

   cursor c_existing is
      select amount
      from   oke_k_fund_allocations
      where  fund_allocation_id = x_allocation_id;

   source_amount 	 number;
   alloc_amount		 number := 0;
   original_amount	 number;
   diff_amount		 number := 0;
   final_amount		 number := 0;

begin

   if (x_allocation_id is not null) then

      open c_existing;
      fetch c_existing into original_amount;

      if (c_existing%notfound) then
         close c_existing;
         raise no_data_found;
      end if;

      diff_amount := x_amount - original_amount;
      final_amount := diff_amount;

      close c_existing;

   else
      final_amount := x_amount;

   end if;

   open c_alloc;
   fetch c_alloc into alloc_amount;

   if (c_alloc%notfound) then
       close c_alloc;
   end if;

   open c_source;
   fetch c_source into source_amount;

   if (c_source%notfound) then
       close c_source;
       raise no_data_found;
   end if;

   if ((nvl(alloc_amount, 0) + nvl(final_amount, 0)) < 0) then

         x_return_status := 'E';

   elsif (source_amount >= (alloc_amount + final_amount)) then

      	 x_return_status := 'Y';

   else

         x_return_status := 'N';

   end if;

   close c_alloc;
   close c_source;

end validate_alloc_source_amount;



--
-- Procedure  : validate_alloc_source_limit
--
-- Purpose    : check if
--		  w/ allocation_id passed in :
--		    there is enough funding source hard limit to be allocated for the newly allocated
--		    hard limit
--
--		  w/o allocaiton_id passed in
--		    the new funding source hard limit is >= sum of its hard limit allocations
--
-- Parameters :
--         (in) x_source_id			number 		funding source id
--		x_allocation_id			number		funding allocation id (optional)
--		x_amount			number		limit amount
--		x_revenue_amount		number		revenue hard limit
--
--        (out) x_type				varchar2	hard limit type (INVOICE/REVENUE)
--		x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_alloc_source_limit(x_source_id				number		,
  				      x_allocation_id				number		,
  				      x_amount					number		,
  				      x_revenue_amount				number		,
  				      x_type		OUT    NOCOPY		varchar2	,
  			   	      x_return_status	OUT    NOCOPY		varchar2	) is


   cursor c_alloc is
     select nvl(sum(hard_limit), 0), nvl(sum(revenue_hard_limit), 0)
     from   oke_k_fund_allocations
     where  funding_source_id = x_source_id;

   cursor c_source is
      select nvl(hard_limit, 0), nvl(revenue_hard_limit, 0)
      from   oke_k_funding_sources
      where  funding_source_id = x_source_id;

   cursor c_existing is
      select nvl(hard_limit, 0), nvl(revenue_hard_limit, 0)
      from   oke_k_fund_allocations
      where  fund_allocation_id = x_allocation_id;

   source_hl_amount 	 number;
   source_rhl_amount	 number;
   alloc_hl_amount	 number := 0;
   alloc_rhl_amount	 number := 0;
   orig_hl_amt		 number;
   orig_rhl_amt		 number;
   diff_hl_amount	 number := 0;
   diff_rhl_amount	 number := 0;
   final_hl_amount	 number := 0;
   final_rhl_amount	 number := 0;

begin

   x_type := null;

   if (x_allocation_id is not null) then

      open c_existing;
      fetch c_existing into orig_hl_amt, orig_rhl_amt;

      if (c_existing%notfound) then
         close c_existing;
         raise no_data_found;
      end if;

      diff_hl_amount  	:= x_amount - orig_hl_amt;
      diff_rhl_amount 	:= x_revenue_amount - orig_rhl_amt;
      final_hl_amount 	:= diff_hl_amount;
      final_rhl_amount 	:= diff_rhl_amount;
      close c_existing;

   else
     final_hl_amount 	:= x_amount;
     final_rhl_amount	:= x_revenue_amount;

   end if;

   open c_alloc;
   fetch c_alloc into alloc_hl_amount, alloc_rhl_amount;

   if (c_alloc%notfound) then
       close c_alloc;
   end if;

   open c_source;
   fetch c_source into source_hl_amount, source_rhl_amount;

   if (c_source%notfound) then
       close c_source;
       raise no_data_found;
   end if;

   if ((nvl(alloc_hl_amount, 0) + nvl(final_hl_amount, 0)) < 0) then

       x_return_status := 'E';
       x_type 	       := 'INVOICE';

   elsif ((nvl(alloc_rhl_amount, 0) + nvl(final_rhl_amount, 0)) < 0) then

       x_return_status := 'E';
       x_type 	       := 'REVENUE';

   elsif (source_hl_amount >= (alloc_hl_amount + final_hl_amount)) then

   	if (source_rhl_amount >= (alloc_rhl_amount + final_rhl_amount)) then

      	   x_return_status := 'Y';

   	else

           x_return_status := 'N';
           x_type 	   := 'REVENUE';

        end if;

   else

         x_return_status := 'N';
         x_type 	 := 'INVOICE';

   end if;

   close c_alloc;
   close c_source;

end validate_alloc_source_limit;



--
-- Procedure  : validate_pool_party_date
--
-- Purpose    : check if
--		 1) pool party start date <= the earliest funding source start date associated w/ the pool party
--		 2) pool party end >= the latest funding source end date associated w/ the pool party
--
-- Parameters :
--         (in) x_start_end			varchar2	date validation choice
--								START : start date
--								END   : end date
--		x_pool_party_id			number		pool party id
--		x_date				date		date to be validated
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_pool_party_date(x_start_end				varchar2		,
  				   x_pool_party_id			number			,
  		         	   x_date				date			,
  		          	   x_return_status	OUT    NOCOPY	varchar2		) is

  cursor c_exist is
     select 'x'
     from   oke_k_funding_sources
     where  pool_party_id = x_pool_party_id;

  cursor c_start_date is
     select nvl(min(start_date_active), add_months(x_date, -1))
     from   oke_k_funding_sources
     where  pool_party_id = x_pool_party_id;

  cursor c_end_date is
     select nvl(max(end_date_active), add_months(x_date, 1))
     from   oke_k_funding_sources
     where  pool_party_id = x_pool_party_id;

  compare_date		date;
  l_dummy_value 	varchar2(1) := '?';

begin

   open c_exist;
   fetch c_exist into l_dummy_value;
   close c_exist;

   if (l_dummy_value <> '?') then

     if (x_start_end = 'START') then

         open c_start_date;
         fetch c_start_date into compare_date;

         if (x_date <= compare_date) then

             x_return_status := 'Y';

         else

             x_return_status := 'N';

         end if;

         close c_start_date;

     else

         open c_end_date;
         fetch c_end_date into compare_date;

         if (x_date >= compare_date) then

             x_return_status := 'Y';

         else

             x_return_status := 'N';

         end if;

         close c_end_date;

      end if;

   else

      x_return_status := 'Y';

   end if;

end validate_pool_party_date;



--
-- Function   : allocation_exist
--
-- Purpose    : check if funding has been allocated for particular funding pool party or not
--
-- Parameters : x_pool_party id		number	pool party id
--
-- Return     : Y	-- allocation exists
-- values       N     -- no allocation exists
--

FUNCTION allocation_exist(x_pool_party_id		number) return varchar2 is

   l_exist	varchar2(1);
   l_count	number;

begin

   select count(1)
   into   l_count
   from   oke_k_funding_sources
   where  pool_party_id = x_pool_party_id;

   if l_count > 0 then

      l_exist := 'Y';

   else

      l_exist := 'N';

   end if;

   return(l_exist);

exception
   when OTHERS then
   	return('N');

end allocation_exist;



--
-- Procedure  : validate_pool_party_amount
--
-- Purpose    : check if the new pool party amount >= the allocated amount
--
-- Parameters :
--         (in) x_pool_party_id			number 		pool party id
--		x_amount			number		new funding amount
--
--        (out) x_allocated_amount		number		calculated allocated amount
--		x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_pool_party_amount(x_pool_party_id				number		,
				     x_amount					number		,
  				     x_allocated_amount		OUT    NOCOPY	number		,
  				     x_return_status		OUT    NOCOPY	varchar2	) is

   cursor c_record is
   	  select amount, available_amount
   	  from   oke_pool_parties
   	  where  pool_party_id = x_pool_party_id;

   l_amount		number;
   l_available_amount	number;

begin

   open c_record;
   fetch c_record into l_amount, l_available_amount;

   if (c_record%notfound) then
      close c_record;
      raise no_data_found;
   end if;

   x_allocated_amount := l_amount - l_available_amount;

   if (x_amount >= x_allocated_amount) then

       x_return_status := 'Y';

   else

       x_return_status := 'N';

   end if;

   close c_record;

end;



--
-- Procedure  : validate_source_alloc_date
--
-- Purpose    : check if
--		 1) funding source start date <= the earliest funding allocation start date
--		 2) funding source end date >= the latest funding allocation end date
--
-- Parameters :
--         (in) x_start_end			varchar2	date validation choice
--								START : start date
--								END   : end date
--		x_funding_source_id		number		funding source id
--		x_date				date		date to be validated
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_source_alloc_date(x_start_end				varchar2		,
  				     x_funding_source_id			number			,
  		         	     x_date					date			,
  		          	     x_return_status		OUT    NOCOPY	varchar2		) is

   cursor c_start_allocation is
   	 select min(nvl(start_date_active, add_months(x_date, -1)))
         from   oke_k_fund_allocations
         where  funding_source_id = x_funding_source_id;

   cursor c_end_allocation is
    	select max(nvl(end_date_active, add_months(x_date, 1)))
        from   oke_k_fund_allocations
        where  funding_source_id = x_funding_source_id;

   cursor c_scsr is
  	select start_date_active
  	from oke_k_fund_allocations
  	where funding_source_id = x_funding_source_id;

   cursor c_ecsr is
  	select end_date_active
  	from oke_k_fund_allocations
  	where funding_source_id = x_funding_source_id;

   l_date date;
   compare_date	date;

begin

   if (x_start_end = 'START') then

      open c_scsr;
      fetch c_scsr into l_date;

      if c_scsr%NOTFOUND then
         close c_scsr;
         raise no_data_found;
      end if;
      close c_scsr;

      open c_start_allocation;
      fetch c_start_allocation into compare_date;

      if (x_date is null) 			     or
         (nvl(x_date, compare_date) <= compare_date) then

          x_return_status := 'Y';

      else

          x_return_status := 'N';

      end if;

      close c_start_allocation;

   else

      open c_ecsr;
      fetch c_ecsr into l_date;

      if c_ecsr%NOTFOUND then
         close c_ecsr;
         raise no_data_found;
      end if;
      close c_ecsr;

      open c_end_allocation;
      fetch c_end_allocation into compare_date;

      if (x_date is null) 			     or
         (nvl(x_date, compare_date) >= compare_date) then

          x_return_status := 'Y';

      else

          x_return_status := 'N';

      end if;

      close c_end_allocation;

   end if;

exception
   when NO_DATA_FOUND then
   	x_return_status := 'Y';

end validate_source_alloc_date;



--
-- Procedure  : validate_alloc_source_date
--
-- Purpose    : check if
--		  1) funding allocation start date >= funding source start date
--		  2) funding allocation end date <= funding source end date
--
-- Parameters :
--         (in) x_start_end			varchar2	date validation choice
--								START : start date
--								END   : end date
--		x_funding_source_id		number		funding source id
--		x_date				date		date to be validated
--
--	  (out) x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_alloc_source_date(x_start_end				varchar2	,
  				     x_funding_source_id			number		,
  		         	     x_date					date		,
  		          	     x_return_status		OUT    NOCOPY	varchar2	) is

   cursor c_start_date is
   	select nvl(start_date_active, x_date)
   	from   oke_k_funding_sources
   	where  funding_source_id = x_funding_source_id;

    cursor c_end_date is
   	select nvl(end_date_active, x_date)
   	from   oke_k_funding_sources
   	where  funding_source_id = x_funding_source_id;

    compare_date	date;

begin

   if (x_start_end = 'START') then

      open c_start_date;
      fetch c_start_date into compare_date;

      if (c_start_date%notfound) then
         close c_start_date;
         raise no_data_found;
      end if;

      if (to_char(x_date, 'YYYY/MM/DD') >= to_char(compare_date, 'YYYY/MM/DD')) or
         (to_char(x_date, 'YYYY/MM/DD') is null and to_char(compare_date, 'YYYY/MM/DD') is null) then

          x_return_status := 'Y';

      else

          x_return_status := 'N';

      end if;

      close c_start_date;

   else

      open c_end_date;
      fetch c_end_date into compare_date;

      if (c_end_date%notfound) then
         close c_end_date;
         raise no_data_found;
      end if;

      if (to_char(x_date, 'YYYY/MM/DD') <= to_char(compare_date, 'YYYY/MM/DD')) or
         (to_char(x_date, 'YYYY/MM/DD') is null and to_char(compare_date, 'YYYY/MM/DD') is null) then

          x_return_status := 'Y';

      else

          x_return_status := 'N';

      end if;

      close c_end_date;

   end if;

exception
   when NO_DATA_FOUND then
   	x_return_status := 'N';

end validate_alloc_source_date;



--
-- Procedure  : multi_customer
--
-- Purpose    : find out how many customers associated with particular project
--
-- Parameters :
--         (in) x_project_id		number		project id
--
--        (out) x_count			number		number of customers
--		x_project_number	varchar2	project number
--

PROCEDURE multi_customer(x_project_id					number	,
			 x_project_number	OUT    NOCOPY		varchar2,
  		         x_count		OUT    NOCOPY    	number	) is

   cursor c_cust is
      select count(p.project_id),
      	     p.segment1
      from   pa_project_customers c,
      	     pa_projects_all p
      where  p.project_id = x_project_id
      and    p.project_id = c.project_id
      and    c.customer_bill_split <> 0
      group by p.project_id, p.segment1;

begin

   open c_cust;
   fetch c_cust into x_count, x_project_number;

   if (c_cust%notfound) then
         close c_cust;
         raise no_data_found;
   end if;

end multi_customer;



--
-- Procedure  : save_user_profile
--
-- Purpose    : save user profile on the preference of showing funding wizard or not
--
-- Parameters :
--         (in) x_profile_name	varchar2	profile name
--		x_value		varchar2	profile value
--

PROCEDURE save_user_profile(x_profile_name	varchar2,
  			    x_value		varchar2) is

   status	boolean;

begin

   status := fnd_profile.save_user(x_profile_name, x_value);
   commit;

end save_user_profile;




--
-- Procedure  : validate_start_end_date
--
-- Purpose    : check if start date <= end date
--
-- Parameters :
--         (in) x_start_date			date 		start date
--		x_end_date			date		end date
--
--        (out) x_return_status			varchar2	return status
--								Y : valid
--								N : not valid
--

PROCEDURE validate_start_end_date(x_start_date					date		,
  				  x_end_date			  		date		,
  			          x_return_status		OUT    NOCOPY	varchar2	) is

BEGIN

    if (X_Start_Date is not null) and
       (X_End_Date is not null) and
       (X_Start_Date > X_End_Date) then

       X_Return_Status := 'N';

    else

       X_Return_Status := 'Y';

    end if;

END validate_start_end_date;



--
-- Procedure  : validate_source_alloc_amount
--
-- Purpose    : validate if funding source amount >= sum(funding allocations)
--
-- Parameters :
--         (in) x_source_id			number			funding source id
--	        x_amount			number			amount
--
--	  (out) x_return_status			varchar2		return status
--								        Y : valid
--								        N : not valid
--

PROCEDURE validate_source_alloc_amount(x_source_id					number		,
  				       x_amount						number		,
  			   	       x_return_status		OUT    NOCOPY		varchar2	) is

   cursor c_alloc is
      select nvl(sum(amount), 0)
      from   oke_k_fund_allocations
      where  funding_source_id = x_source_id;

   l_alloc	number;

BEGIN

   OPEN c_alloc;
   FETCH c_alloc into l_alloc;

   IF (c_alloc%NOTFOUND) THEN

     l_alloc := 0;

   END IF;

   IF (l_alloc < 0) THEN

      x_return_status := 'E';

   ELSIF (x_amount >= l_alloc) THEN

      x_return_status := 'Y';

   ELSE

      x_return_status := 'N';

   END IF;

END  validate_source_alloc_amount;


--
-- Procedure  : validate_hard_limit
--
-- Purpose    : validate if hard limit <= funding amount
--
-- Parameters :
--         (in) x_fund_amount			number			funding amount
--		x_hard_limit			number			hard limit
--
--	  (out) x_return_status			varchar2		return status
--								        Y : valid
--								        N : not valid
--

PROCEDURE validate_hard_limit(x_fund_amount						number		,
			      x_hard_limit						number		,
  			      x_return_status		OUT    NOCOPY			varchar2	) is
BEGIN

   IF (nvl(x_fund_amount, 0) >= nvl(x_hard_limit, 0)) THEN

      x_return_status := 'Y';

   ELSE

      x_return_status := 'N';

   END IF;

END validate_hard_limit;


--
-- Procedure  : validate_source_alloc_limit
--
-- Purpose    : check if funding source invoice/revenue hard limit >= sum(funding allocations invoice/revenue hard limit)
--		(for MCB change)
--
-- Parameters :
--         (in) x_source_id			number 		funding source id
--		x_amount			number		limit amount
--		x_revenue_amount		number		revenue hard limit amount
--
--        (out) x_type				varchar2	hard limit type
--		x_return_status			varchar2	return status
--								Y : valid
--								N : invalid
--

PROCEDURE validate_source_alloc_limit(x_source_id					number		,
  				      x_amount						number		,
  				      x_revenue_amount					number		,
  				      x_type			OUT    NOCOPY		varchar2	,
  			   	      x_return_status		OUT    NOCOPY		varchar2	) is

     cursor c_alloc is
      select nvl(sum(hard_limit), 0), nvl(sum(revenue_hard_limit), 0)
      from   oke_k_fund_allocations
      where  funding_source_id = x_source_id;

   l_alloc		number;
   l_revenue_alloc	number;

BEGIN

   x_type := null;

   OPEN c_alloc;
   FETCH c_alloc into l_alloc, l_revenue_alloc;

   IF (c_alloc%NOTFOUND) THEN

     l_alloc 		:= 0;
     l_revenue_alloc	:= 0;

   END IF;

   IF (nvl(l_alloc, 0) < 0) THEN

      x_return_status := 'E';
      x_type 	      := 'INVOICE';

   ELSIF (nvl(l_revenue_alloc, 0) < 0) THEN

      x_return_status := 'E';
      x_type 	      := 'REVENUE';

   ELSIF (nvl(x_amount, 0) >= l_alloc) THEN

      IF (nvl(x_revenue_amount, 0) >= l_revenue_alloc) THEN

      	 x_return_status := 'Y';

      ELSE

      	 x_return_status := 'N';
      	 x_type 	 := 'REVENUE';

      END IF;

   ELSE

      x_return_status := 'N';
      x_type 	      := 'INVOICE';

   END IF;

END  validate_source_alloc_limit;



--
-- Procedure  : get_conversion_rate
--
-- Purpose    : get the conversion rate for the particular conversion type and date
--
-- Parameters :
--         (in) x_from_currency			varchar2		conversion from currency
--		x_to_currency			varchar2		conversion to currency
--		x_conversion_type		varchar2		conversion type
--		x_conversion_date		date			conversion date
--
--        (out) x_conversion_date		number			conversion rate
--		x_return_status			varchar2		return status
--								        Y : exist
--								        N : not exist
--

PROCEDURE get_conversion_rate(x_from_currency					varchar2	,
           			x_to_currency					varchar2	,
           			x_conversion_type				varchar2	,
           			x_conversion_date				date		,
           			x_conversion_rate		OUT    NOCOPY 	number		,
           			x_return_status			OUT    NOCOPY 	varchar2
           			) is

   numerator		number;
   denominator		number;
   amount		number := 0;
   converted_amount	number := 0;

BEGIN

   GL_CURRENCY_API.CONVERT_AMOUNT(x_from_currency    	  => x_from_currency			,
				  x_to_currency           => x_to_currency			,
				  x_conversion_date 	  => x_conversion_date			,
				  x_conversion_type 	  => x_conversion_type			,
 				  x_amount 		  => amount				,
 			          x_converted_amount 	  => converted_amount			,
				  x_denominator 	  => denominator 			,
				  x_numerator	  	  => numerator				,
				  x_rate		  => x_conversion_rate
				  );
    x_return_status := 'Y';

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'N';

END get_conversion_rate;



--
-- PROCEDURE  : check_agreement_exist
--
-- Purpose    : check if agreement exist for the funding source
--
-- Parameters :
--         (in) x_funding_source_id		number			funding_source_id
--
--	  (out) x_return_status			varchar2		return status
--								        Y : exist
--								        N : not exist
--

PROCEDURE check_agreement_exist(x_funding_source_id			number		,
				x_return_status		OUT    NOCOPY 	varchar2	) is

   cursor c_exist is
      select nvl(agreement_flag, 'N')
      from   oke_k_funding_sources
      where  funding_source_id = x_funding_source_id;

begin

   open c_exist;
   fetch c_exist into x_return_status;

   if (c_exist%NOTFOUND) then
       x_return_status := 'N';
   end if;

   close c_exist;

end check_agreement_exist;



--
-- Function   : get_project_currency
--
-- Purpose    : get the project currency
--
-- Parameters :
--         (in) x_project_id		number		project_id
--

FUNCTION get_project_currency(x_project_id 	number) return varchar2
  			     is
   cursor c_currency is
      select currency_code
      from   pa_projects_all p,
      	     pa_implementations_all i,
      	     gl_sets_of_books g
      where  p.project_id = x_project_id
      and    nvl(p.org_id, -99) = nvl(i.org_id, -99)
      and    i.set_of_books_id = g.set_of_books_id;

   l_currency 	varchar2(15);

BEGIN

    open c_currency;
    fetch c_currency into l_currency;

    if (c_currency%NOTFOUND) then
    	close c_currency;
        return(null);
    end if;
    close c_currency;
    return(l_currency);

END get_project_currency;



--
-- Function   : get_owned_by
--
-- Purpose    : get the owned_by_person_id
--
-- Parameters :
--         (in) x_user_id			number		user id
--

FUNCTION get_owned_by(x_user_id		number) return number is

   cursor c_owned is
      select employee_id
      from   fnd_user
      where  user_id = x_user_id;

   l_emp_id 	number;

BEGIN

   OPEN c_owned;
   FETCH c_owned into l_emp_id;
   IF (c_owned%NOTFOUND) THEN

      l_emp_id := null;

   END IF;

   CLOSE c_owned;
   return(l_emp_id);

END get_owned_by;


--
-- PROCEDURE  : get_agreement_info
--
-- Purpose    : get existing agreement_type, customer_id for the existing funding_source_id
--
-- Parameters :
--         (in) x_funding_source_id		number		funding_source_id
--
--	  (out) x_agreement_type		varchar2	agreement_type
--		x_customer_id			number		customer_id
--		x_return_status			varchar2	return status
--								   Y : exist
--								   N : not exist
--

PROCEDURE get_agreement_info(x_funding_source_id			number		,
  			     x_agreement_type		OUT    NOCOPY	varchar2	,
  			     x_customer_id		OUT    NOCOPY	number		,
  			     x_return_status		OUT    NOCOPY	varchar2
  			     ) is

   CURSOR c_agreement IS
     SELECT agreement_type, customer_id
     FROM   pa_agreements_all
     WHERE  pm_product_code = OKE_FUNDING_PUB.G_PRODUCT_CODE
     AND    pm_agreement_reference LIKE '%-' || to_char(x_funding_source_id);

begin

   OPEN c_agreement;
   FETCH c_agreement into x_agreement_type, x_customer_id;

   if (c_agreement%NOTFOUND) then
       close c_agreement;
       x_return_status := 'N';
       raise no_data_found;
   end if;

   close c_agreement;
   x_return_status := 'Y';

end get_agreement_info;


--
-- Procedure   : update_alloc_version
--
-- Description : This procedure is used to update agreement_version and insert_update_flag of OKE_K_FUND_ALLOCATIONS table
--
-- Parameters  :
--	    (in)  x_fund_allocation_id		number			fund_allocation_id
--		  x_version_add			number			version increment
--		  x_commit			varchar2		commit flag
--

PROCEDURE update_alloc_version(x_fund_allocation_id			IN	NUMBER,
			       x_version_add				IN	NUMBER,
  			       x_commit					IN	VARCHAR2 := OKE_API.G_FALSE
		              ) is

begin

   update oke_k_fund_allocations
   set    agreement_version = nvl(agreement_version, 0) + x_version_add,
          insert_update_flag = null
   where  fund_allocation_id = x_fund_allocation_id;

   if FND_API.to_boolean(x_commit) then

      commit work;

   end if;

end update_alloc_version;



--
-- Procedure   : update_source_flag
--
-- Description : This procedure is used to update agreement_flag of OKE_K_FUNDING_SOURCES table
--
-- Parameters  :
--	    (in)  x_funding_source_id		number			funding_source_id
--		  x_commit			varchar2		commit flag
--

PROCEDURE update_source_flag(x_funding_source_id		IN	NUMBER,
  			     x_commit				IN	VARCHAR2 := OKE_API.G_FALSE
		            ) is
  l_flag VARCHAR2(1) := 'N';
  CURSOR c_agr IS
    SELECT 'Y'
     FROM   pa_agreements_all
     WHERE  pm_product_code = OKE_FUNDING_PUB.G_PRODUCT_CODE
     AND    pm_agreement_reference LIKE '%-' || to_char(x_funding_source_id);

BEGIN
   OPEN c_agr;
   FETCH c_agr INTO l_flag;
   CLOSE c_agr;

   UPDATE oke_k_funding_sources
   SET    agreement_flag = l_flag
   WHERE  funding_source_id = x_funding_source_id;

   IF FND_API.to_boolean(x_commit) THEN

       COMMIT WORK;

   END IF;

END update_source_flag;



--
-- Procedure   : funding_mode
--
-- Description : This procedure is used to check the funding mode is vaild or not
--
-- Parameters  :
--	    (in)  x_proj_sum_tbl		proj_sum_tbl_type		allocation amount by project
--		  x_task_sum_tbl		task_sum_tbl_type		allocation amount by task
--
--	   (out)  x_funding_level_tbl		funding_level_tbl_type		funding level by project
--		  x_return_status		varchar2			return_status
--										S: successful
--										E: error
--		  x_project_err			varchar2			project number with funding mode error
--

PROCEDURE funding_mode(x_proj_sum_tbl				IN		PROJ_SUM_TBL_TYPE,
  		       x_task_sum_tbl				IN		TASK_SUM_TBL_TYPE,
  		       x_funding_level_tbl			OUT    NOCOPY   FUNDING_LEVEL_TBL_TYPE,
  		       x_return_status				OUT    NOCOPY	VARCHAR2,
  		       x_project_err				OUT    NOCOPY	VARCHAR2
		       ) is

    i		number;
    j		number;
    exist_flag  varchar2(1);

begin

    x_return_status := 'S';

    if (x_proj_sum_tbl.COUNT > 0) then

       i := x_proj_sum_tbl.FIRST;

       loop

       	  if (x_proj_sum_tbl(i).amount <> 0) then

       	     if (x_task_sum_tbl.COUNT > 0) then

       	        j := x_task_sum_tbl.FIRST;

       	        loop

       	           if (x_task_sum_tbl(j).project_id = i) and
       	              (x_task_sum_tbl(j).amount <> 0)    then

       	              x_return_status := 'E';
                      x_project_err   := x_task_sum_tbl(j).project_number;
                      exit;

       	           end if;

                   exit when (j = x_task_sum_tbl.LAST);
                   j := x_task_sum_tbl.NEXT(j);

                end loop;

             end if;

             if (x_return_status <> 'E') then

                x_funding_level_tbl(i).project_id    := x_proj_sum_tbl(i).project_id;
                x_funding_level_tbl(i).funding_level := 'P';

             end if;

	  elsif (x_proj_sum_tbl(i).amount = 0) then

             x_funding_level_tbl(i).funding_level    := 'T';
             x_funding_level_tbl(i).project_id       := x_proj_sum_tbl(i).project_id;

          end if;

          exit when (i = x_proj_sum_tbl.LAST);
          i := x_proj_sum_tbl.NEXT(i);

       end loop;

    end if;

    if (x_task_sum_tbl.COUNT > 0) THEN

       i := x_task_sum_tbl.FIRST;

       loop

       	  if (x_funding_level_tbl.COUNT > 0) then

       	     j := x_funding_level_tbl.FIRST;
       	     exist_flag := 'N';

       	     loop

       	        -- bug 3006791, start
       	        --if (x_funding_level_tbl(j).project_id = i) then
       	          if (x_funding_level_tbl(j).project_id = x_task_sum_tbl(i).project_id) then
       	        -- bug 3006791, end

       	           exist_flag := 'Y';

       	        end if;
       	        exit when (j = x_funding_level_tbl.LAST or exist_flag = 'Y');
       	        j := x_funding_level_tbl.NEXT(j);

       	     end loop;

       	     if (exist_flag <> 'Y') then

                x_funding_level_tbl(x_task_sum_tbl(i).project_id).funding_level    := 'T';
                x_funding_level_tbl(x_task_sum_tbl(i).project_id).project_id       := x_task_sum_tbl(i).project_id;

             end if;

          else

             x_funding_level_tbl(x_task_sum_tbl(i).project_id).funding_level    := 'T';
             x_funding_level_tbl(x_task_sum_tbl(i).project_id).project_id       := x_task_sum_tbl(i).project_id;

          end if;

          exit when (i = x_task_sum_tbl.LAST);
          i := x_task_sum_tbl.NEXT(i);

       end loop;

    end if;

end funding_mode;



--
-- Procedure   : get_converted_amount
--
-- Description : This function is used to calculate the allocated amount
--
-- Parameters  :
--	    (in)  x_funding_source_id			number		funding_source_id
--		  x_project_id				number		project_id
--		  x_project_number			varchar2	project number
--		  x_amount				number		original amount
--		  x_conversion_type			varchar2	currency conversion type
--		  x_conversion_date			date		currency conversion date
--		  x_conversion_rate			number		currency conversion rate
--
--	   (out)  x_converted_amount			number		converted amount
--		  x_return_status			varchar2	return status
--									S: successful
--							      	        E: error
--							       	        U: unexpected error
--

PROCEDURE get_converted_amount(x_funding_source_id			IN		NUMBER					,
			       x_project_id				IN 		NUMBER					,
			       x_project_number				IN		VARCHAR2				,
			       x_amount					IN		NUMBER					,
			      -- x_org_id					IN	NUMBER					,
			       x_conversion_type			IN		VARCHAR2				,
			       x_conversion_date			IN		DATE					,
			       x_conversion_rate			IN		NUMBER					,
			       x_converted_amount			OUT    NOCOPY	NUMBER					,
			       x_return_status				OUT    NOCOPY	VARCHAR2
			       ) is

    cursor c_currency is
    	select currency_code
    	from   oke_k_funding_sources
    	where  funding_source_id = x_funding_source_id;

    cursor c_min_unit is
    	select nvl(minimum_accountable_unit, power(10, -1 * precision)),
    	       p.projfunc_currency_code
    	from   pa_projects_all p,
    	       fnd_currencies f
    	where  project_id = x_project_id
    	and    f.currency_code = p.projfunc_currency_code;

    l_currency		VARCHAR2(15);
    l_min_unit		NUMBER;
    l_project_currency	VARCHAR2(15);

begin

    x_return_status := 'S';

    OPEN c_currency;
    FETCH c_currency into l_currency;
    CLOSE c_currency;

    OPEN c_min_unit;
    FETCH c_min_unit into l_min_unit, l_project_currency;
    CLOSE c_min_unit;

    get_calculate_amount(x_conversion_type	=>	x_conversion_type		,
    			 x_conversion_date	=>	x_conversion_date		,
    			 x_conversion_rate	=>	x_conversion_rate		,
    		         x_org_amount		=>	x_amount			,
    		         x_min_unit		=>	l_min_unit			,
    		         x_fund_currency	=>	l_currency			,
    		         x_project_currency	=>	l_project_currency		,
    		         x_amount		=>	x_converted_amount		,
    		         x_return_status	=>	x_return_status
    		         );

EXCEPTION
   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      IF c_min_unit%ISOPEN THEN
         CLOSE c_min_unit;
      END IF;

      IF c_currency%ISOPEN THEN
         CLOSE c_currency;
      END IF;

      x_return_status := 'U';

end get_converted_amount;



--
-- Procedure   : get_calculate_amount
--
-- Description : This procedure is used to get the converted amount
--
-- Parameters  :
--	    (in)  x_conversion_type			varchar2	currency conversion type
--		  x_conversion_date			date		currency conversion date
--		  x_conversion_rate			number		currency conversion rate
--		  x_org_amount				number		original amount
--		  x_min_unit				number		minimum amount unit of the currency
--		  x_fund_currency			varchar2	funding source currency
--		  x_project_currency			varchar2	project currency
--
--	   (out)  x_amount				number		converted amount
--		  x_return_status			varchar2	return status
--									S: successful
--							      	        E: error
--							       	        U: unexpected error
--

PROCEDURE get_calculate_amount(x_conversion_type			VARCHAR2	,
			       x_conversion_date			DATE		,
			       x_conversion_rate			NUMBER		,
			       x_org_amount				NUMBER		,
			       x_min_unit				NUMBER		,
			       x_fund_currency				VARCHAR2	,
			       x_project_currency			VARCHAR2	,
      			       x_amount			OUT    NOCOPY 	NUMBER		,
      			       x_return_status		OUT    NOCOPY	VARCHAR2
      			     ) is

    MISSING_ERROR	EXCEPTION;

begin

   x_return_status := 'S';

   IF (x_project_currency <> x_fund_currency) THEN

       IF (x_conversion_type is null) THEN

          OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			      p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			      p_token1			=> 	'VALUE'				,
      			      p_token1_value		=> 	'pa_conversion_type'
     			      );

          RAISE MISSING_ERROR;

       END IF;

       IF (x_conversion_date is null) THEN

          OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			      p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			      p_token1			=> 	'VALUE'				,
      			      p_token1_value		=> 	'pa_conversion_date'
     			      );

          RAISE MISSING_ERROR;

       END IF;

       IF (upper(x_conversion_type) = 'USER') AND
          (x_conversion_rate is null) 	      THEN

          OKE_API.set_message(p_app_name		=> 	G_APP_NAME			,
      			      p_msg_name		=>	'OKE_API_MISSING_VALUE'		,
      			      p_token1			=> 	'VALUE'				,
      			      p_token1_value		=> 	'pa_conversion_rate'
     			      );

          RAISE MISSING_ERROR;

       END IF;

   END IF;

   IF (x_conversion_rate is null) THEN

      x_amount := x_org_amount;

   ELSE

      x_amount := round(x_org_amount * x_conversion_rate / x_min_unit) * x_min_unit;

   END IF;

EXCEPTION
   WHEN MISSING_ERROR THEN
      x_return_status := 'E';

   WHEN OTHERS THEN
      OKE_API.set_message(p_app_name		=>	G_APP_NAME		,
      			  p_msg_name		=>	G_UNEXPECTED_ERROR	,
      			  p_token1		=>	G_SQLCODE_TOKEN		,
      			  p_token1_value	=>	SQLCODE			,
      			  p_token2		=>	G_SQLERRM_TOKEN		,
      			  p_token2_value	=>	SQLERRM
      			 );

      x_return_status := 'U';

end get_calculate_amount;

end OKE_FUNDING_UTIL_PKG;

/
