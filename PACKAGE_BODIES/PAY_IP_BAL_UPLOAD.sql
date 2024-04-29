--------------------------------------------------------
--  DDL for Package Body PAY_IP_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IP_BAL_UPLOAD" AS
/* $Header: pyipupld.pkb 120.3.12010000.1 2008/07/27 22:56:11 appldev ship $ */

 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');

 --
 -- Global variable type
 --
 type t_dimension_names_tab is table of
   pay_balance_dimensions.dimension_name%type index by binary_integer;

 type t_route_names_tab is table of
   ff_routes.route_name%type index by binary_integer;

 --
 -- Cache for expiry date
 --
 type t_expiry_date_rec is record
   (itd_start_date   date                   -- ITD Start date.
   ,assignment_id    number
   );

 --
 -- Global cache
 --
 g_legislation_code  varchar2(30);          -- legislation code
 g_leg_supported     boolean;               -- legislation is supported?
 g_dimension_names   t_dimension_names_tab; -- dimension name cache
 g_route_names       t_route_names_tab;     -- route name cache
 g_expiry_date_rec   t_expiry_date_rec;

 -- -------------------------------------------------------------------------
 -- initialize
 -- -------------------------------------------------------------------------
 -- Description: This procedure sets up dimension names cache for the
 --              specified legislation.
 -- -------------------------------------------------------------------------
 procedure initialize(p_legislation_code in         varchar2)
 is
   cursor csr_baldim
   is
   select
     upper(pbd.dimension_name)
    ,r.route_name
   from
     pay_balance_dimensions pbd
    ,ff_routes              r
   where
       pbd.legislation_code = p_legislation_code
   and pbd.route_id = r.route_id
   and r.route_name in
     ('Global Assignment Inception To Date',
      'Global Assignment Processing Period To Date',
      'Global Assignment Calendar Month To Date',
      'Global Assignment Calendar Quarter To Date',
      'Global Assignment Calendar Year To Date',
      'Global Assignment Tax Quarter To Date',
      'Global Assignment Tax Year To Date',
      'Global Assignment Fiscal Quarter To Date',
      'Global Assignment Fiscal Year To Date',
      'Global Element Entry Inception To Date',
      'Global Element Entry Processing Period To Date',
      'Global Element Entry Calendar Month To Date',
      'Global Element Entry Calendar Quarter To Date',
      'Global Element Entry Calendar Year To Date',
      'Global Assignment Within Tax Unit Inception To Date',
      'Global Assignment Within Tax Unit Processing Period To Date',
      'Global Assignment Within Tax Unit Calendar Month To Date',
      'Global Assignment Within Tax Unit Calendar Quarter To Date',
      'Global Assignment Within Tax Unit Calendar Year To Date',
      'Global Assignment Within Tax Unit Tax Quarter To Date',
      'Global Assignment Within Tax Unit Tax Year To Date',
      'Global Assignment Within Tax Unit Fiscal Quarter To Date',
      'Global Assignment Within Tax Unit Fiscal Year To Date')
   union
   select
     upper(pbd.dimension_name)
    ,r.route_name
   from
     pay_balance_dimensions pbd
    ,pay_dimension_routes   pdr
    ,ff_routes              r
   where
       pbd.legislation_code = p_legislation_code
   and pbd.balance_dimension_id = pdr.balance_dimension_id
   and pdr.route_id = r.route_id
   and pdr.route_type = 'RR'
   and r.route_name in
     ('Global Assignment Inception To Date',
      'Global Assignment Processing Period To Date',
      'Global Assignment Calendar Month To Date',
      'Global Assignment Calendar Quarter To Date',
      'Global Assignment Calendar Year To Date',
      'Global Assignment Tax Quarter To Date',
      'Global Assignment Tax Year To Date',
      'Global Assignment Fiscal Quarter To Date',
      'Global Assignment Fiscal Year To Date',
      'Global Element Entry Inception To Date',
      'Global Element Entry Processing Period To Date',
      'Global Element Entry Calendar Month To Date',
      'Global Element Entry Calendar Quarter To Date',
      'Global Element Entry Calendar Year To Date',
      'Global Assignment Within Tax Unit Inception To Date',
      'Global Assignment Within Tax Unit Processing Period To Date',
      'Global Assignment Within Tax Unit Calendar Month To Date',
      'Global Assignment Within Tax Unit Calendar Quarter To Date',
      'Global Assignment Within Tax Unit Calendar Year To Date',
      'Global Assignment Within Tax Unit Tax Quarter To Date',
      'Global Assignment Within Tax Unit Tax Year To Date',
      'Global Assignment Within Tax Unit Fiscal Quarter To Date',
      'Global Assignment Within Tax Unit Fiscal Year To Date')
   ;
   --
   null_expiry_date_rec t_expiry_date_rec;

 begin

   --
   -- set the legislation code
   --
   g_legislation_code := p_legislation_code;

   --
   -- Retrieve dimension names
   --
   open csr_baldim;
   fetch csr_baldim bulk collect into g_dimension_names, g_route_names;
   close csr_baldim;

   g_leg_supported := (g_dimension_names.count > 0);

   --
   -- Reset the expiry date cache
   --
   g_expiry_date_rec := null_expiry_date_rec;

 end initialize;
 --
 -- -------------------------------------------------------------------------
 -- get_dim_route_name
 -- -------------------------------------------------------------------------
 -- Description: This function returns the route name for the specified
 --              dimension name.
 --              The name is derived from the supported route list.
 -- -------------------------------------------------------------------------
 function get_dim_route_name
   (p_dimension_name   in varchar2
   ,p_legislation_code in varchar2
   ) return varchar2
 is
  l_idx binary_integer;
 begin
  if (g_legislation_code = p_legislation_code) then
    --
    -- cache has been established, check if there are any
    -- dimensions supported.
    --
    if not g_leg_supported then
      return '';
    end if;
  elsif (p_legislation_code is not null) then
    --
    -- initialize the legislation cache.
    --
    initialize(p_legislation_code);
  --
  else
    return '';
  end if;

  --
  -- Check if the dimension name exists in the cache.
  --
  for l_idx in 1..g_dimension_names.count loop
    if upper(g_dimension_names(l_idx)) = upper(p_dimension_name) then
      --
      return g_route_names(l_idx);
      --
    end if;
  end loop;
  --
  -- dimension not found
  --
  return '';

 end get_dim_route_name;
 --
 -- -------------------------------------------------------------------------
 -- get_expiry_date_info
 -- -------------------------------------------------------------------------
 -- Description: This procedure returns the expiry date info.
 --
 -- -------------------------------------------------------------------------
 procedure get_expiry_date_info
   (p_assignment_id  in             number
   ,p_upload_date    in             date
   ,p_itd_start_date    out  nocopy date
   )
 is
   --
   -- Bug 5234566. Use of union all to ensure the start date returned is
   -- on a time period.
   --
   cursor csr_itd_start_date
   is
   --
   -- Minimum asg start date that is on time period.
   --
   -- Asg   |----------------->
   -- Prd |----->|----->|----->
   --
   select
     min(asg.effective_start_date) start_date
   from
      per_all_assignments_f asg
     ,per_time_periods      ptp
   where
       asg.assignment_id = p_assignment_id
   and ptp.payroll_id    = asg.payroll_id
   and asg.effective_start_date between ptp.start_date
                                    and ptp.end_date
   UNION ALL
   --
   -- Minimum period start date that is on the assignment.
   --
   -- Asg |----------------->
   -- Prd   |----->|----->|----->
   --
   select
     min(ptp.start_date) start_date
   from
      per_all_assignments_f asg
     ,per_time_periods      ptp
   where
       asg.assignment_id = p_assignment_id
   and ptp.payroll_id    = asg.payroll_id
   and ptp.start_date between asg.effective_start_date
                          and asg.effective_end_date
   order by 1
   ;

   l_itd_start_date date;

 begin
   if p_assignment_id = g_expiry_date_rec.assignment_id then

     --
     -- The start date is before the upload date.
     --
     l_itd_start_date := g_expiry_date_rec.itd_start_date;

   elsif p_assignment_id is not null then
     --
     -- Reset the expiry date info.
     --
     g_expiry_date_rec.assignment_id := p_assignment_id;

     open csr_itd_start_date;
     fetch csr_itd_start_date into l_itd_start_date;
     close csr_itd_start_date;

     l_itd_start_date := nvl(l_itd_start_date, END_OF_TIME);
     g_expiry_date_rec.itd_start_date := l_itd_start_date;

   end if;

   --
   -- Check to see if the start date is before the upload date.
   --
   if l_itd_start_date <= p_upload_date then
     p_itd_start_date := l_itd_start_date;
   else
     p_itd_start_date := END_OF_TIME;
   end if;

 end get_expiry_date_info;
 --
-- -------------------------------------------------------------------------
-- Function to check whether a particular dimension is supported by
-- International Payroll. Function returns TRUE if it is a International
-- Payroll supported dimension, otherwise returns FALSE.
-- -------------------------------------------------------------------------
FUNCTION international_payroll
			(p_dimension_name	IN	VARCHAR2,
			 p_legislation_code	IN	VARCHAR2) RETURN BOOLEAN IS
  l_idx binary_integer;
  l_route_name           ff_routes.route_name%type;
BEGIN
  hr_utility.trace('Entering pay_ip_bal_upload.international_payroll');

  --
  -- Check to see if the dimension/route exists in the support list.
  --
  l_route_name := get_dim_route_name
                    (p_dimension_name   => p_dimension_name
                    ,p_legislation_code => p_legislation_code
                    );

  if l_route_name is not null then
    return true;
  else
    return false;
  end if;

  hr_utility.trace('Exiting pay_ip_bal_upload.international_payroll');
END international_payroll;


-- -------------------------------------------------------------------------
-- Funtion to return expiry date for supported Routes.
-- -------------------------------------------------------------------------
FUNCTION expiry_date
		(p_upload_date		IN	DATE,
		 p_dimension_name	IN	VARCHAR2,
		 p_assignment_id	IN	NUMBER,
		 p_original_entry_id	IN	NUMBER,
		 p_business_group_id	IN	NUMBER,
		 p_legislation_code	IN	VARCHAR2) RETURN DATE IS

/************
*
* Now this ITD expiry is checked in get_expiry_date_info.
*
CURSOR csr_expiry_date
		(p_assignment_id	NUMBER
		,p_upload_date		DATE
		,p_expiry_date		DATE) IS
SELECT nvl(GREATEST(MIN(ass.effective_start_date), MIN(ptp.start_date), p_expiry_date)
	  ,END_OF_TIME)
FROM	per_assignments_f ass
       ,per_time_periods  ptp
WHERE	ass.assignment_id = p_assignment_id
AND 	ass.effective_start_date <= p_upload_date
AND	ass.effective_end_date	 >= p_expiry_date
AND 	ptp.payroll_id		  = ass.payroll_id
AND 	ptp.start_date BETWEEN ass.effective_start_date and p_upload_date;
************/

--
-- period start date
--
CURSOR csr_start_of_date
		(p_assignment_id	NUMBER
		,p_upload_date		DATE
		) IS
SELECT  ptp.start_date
FROM	per_all_assignments_f ass
       ,per_time_periods  ptp
WHERE	ass.assignment_id = p_assignment_id
AND 	ass.effective_start_date <= p_upload_date
AND	ass.effective_end_date	 >= p_upload_date
AND 	ptp.payroll_id		  = ass.payroll_id
AND 	p_upload_date BETWEEN ptp.start_date
AND     ptp.end_date;

/************
*
* This is replaced by get_dim_route_name().
*
CURSOR csr_route_name
		(p_legislation_code	VARCHAR2,
		 p_dimension_name	VARCHAR2) IS
SELECT route_name
FROM ff_routes
WHERE route_id =
		(SELECT route_id
		FROM PAY_BALANCE_DIMENSIONS
		WHERE legislation_code= p_legislation_code
		AND upper(dimension_name) = upper(p_dimension_name)
		AND business_group_id IS NULL);
************/
--
-- original entry start date
--
cursor csr_oe_start_date
is
  select min(pee.effective_start_date)
  from
    pay_element_entries_f pee
  where
      pee.assignment_id = p_assignment_id
  and pee.entry_type = 'E'
  and ((pee.element_entry_id = p_original_entry_id
        and pee.original_entry_id is null)
       or (pee.original_entry_id = p_original_entry_id));

l_expiry_date	DATE;
l_business_group_id	PER_ALL_ASSIGNMENTS_F.BUSINESS_GROUP_ID%TYPE;
l_route_name		FF_ROUTES.ROUTE_NAME%TYPE;
l_itd_start_date        date;
l_oe_start_date         date;
BEGIN

    hr_utility.trace('Entering pay_ip_bal_upload.expiry_date');

    l_route_name :=  get_dim_route_name
                       (p_dimension_name   => p_dimension_name
                       ,p_legislation_code => p_legislation_code);

    hr_utility.trace('Route='||l_route_name);
    --
    -- Get the ITD start date.
    --
    get_expiry_date_info
       (p_assignment_id  => p_assignment_id
       ,p_upload_date    => p_upload_date
       ,p_itd_start_date => l_itd_start_date
       );

    --
    hr_utility.trace('Asg Start Date='||l_itd_start_date);

    --
    -- Get the original entry start date.
    --
    if l_route_name in ('Global Element Entry Inception To Date'
                       ,'Global Element Entry Processing Period To Date'
                       ,'Global Element Entry Calendar Month To Date'
                       ,'Global Element Entry Calendar Quarter To Date'
                       ,'Global Element Entry Calendar Year To Date') then
       --
       open csr_oe_start_date;
       fetch csr_oe_start_date into l_oe_start_date;
       close csr_oe_start_date;

       l_oe_start_date := nvl(l_oe_start_date, END_OF_TIME);
       hr_utility.trace('OE Start Date='||l_oe_start_date);

    end if;

IF l_route_name IN ( 'Global Assignment Processing Period To Date',
                     'Global Element Entry Processing Period To Date',
		     'Global Assignment Within Tax Unit Processing Period To Date') THEN

	open csr_start_of_date(p_assignment_id, p_upload_date);
	fetch csr_start_of_date into l_expiry_date;
	close csr_start_of_date;
        hr_utility.trace('Period Start Date=' || l_expiry_date);

ELSIF l_route_name IN (	'Global Assignment Inception To Date',
		       	'Global Element Entry Inception To Date',
		       	'Global Assignment Within Tax Unit Inception To Date') THEN
		l_expiry_date := l_itd_start_date;
                hr_utility.trace('Asg Start Date=' || l_expiry_date);

ELSIF l_route_name IN (	'Global Assignment Calendar Month To Date',
		       	'Global Element Entry Calendar Month To Date',
		       	'Global Assignment Within Tax Unit Calendar Month To Date') THEN
		l_expiry_date := TRUNC(p_upload_date,'MM');
                hr_utility.trace('Mth Start Date=' || l_expiry_date);

ELSIF l_route_name IN (	'Global Assignment Calendar Quarter To Date',
			'Global Element Entry Calendar Quarter To Date',
			'Global Assignment Within Tax Unit Calendar Quarter To Date') THEN
		l_expiry_date := TRUNC(p_upload_date,'Q');
                hr_utility.trace('Qtr Start Date=' || l_expiry_date);

ELSIF l_route_name IN (	'Global Assignment Calendar Year To Date',
			'Global Element Entry Calendar Year To Date',
			'Global Assignment Within Tax Unit Calendar Year To Date') THEN
		l_expiry_date := TRUNC(p_upload_date,'Y');
                hr_utility.trace('Year Start Date=' || l_expiry_date);

ELSIF l_route_name IN (	'Global Assignment Tax Quarter To Date',
			'Global Assignment Within Tax Unit Tax Quarter To Date') THEN
		l_expiry_date := pay_ip_route_support.tax_quarter(p_business_group_id, p_upload_date);
                hr_utility.trace('Tax Qtr Start Date=' || l_expiry_date);

ELSIF l_route_name IN (	'Global Assignment Tax Year To Date',
			'Global Assignment Within Tax Unit Tax Year To Date') THEN
		l_expiry_date := pay_ip_route_support.tax_year(p_business_group_id, p_upload_date);
                hr_utility.trace('Tax Year Start Date=' || l_expiry_date);

ELSIF l_route_name IN (	'Global Assignment Fiscal Quarter To Date',
			'Global Assignment Within Tax Unit Fiscal Quarter To Date') THEN
		l_expiry_date := pay_ip_route_support.fiscal_quarter(p_business_group_id, p_upload_date);
                hr_utility.trace('FQ Start Date=' || l_expiry_date);

ELSIF l_route_name IN (	'Global Assignment Fiscal Year To Date',
			'Global Assignment Within Tax Unit Fiscal Year To Date') THEN
		l_expiry_date := pay_ip_route_support.fiscal_year(p_business_group_id, p_upload_date);
                hr_utility.trace('FY Start Date=' || l_expiry_date);

ELSE
  --
  -- Dimension not supported.
  --
  l_expiry_date := END_OF_TIME;
  hr_utility.trace('Dimension Not Supported. ' || p_dimension_name);

END IF;

  l_expiry_date := nvl(greatest(l_itd_start_date
                               ,l_expiry_date
                               ,nvl(l_oe_start_date, l_expiry_date)
                               ), END_OF_TIME);

  if (l_expiry_date <> END_OF_TIME) and (l_expiry_date > p_upload_date) then
    hr_utility.trace('Expiry date is later than upload_date! expiry_date='||l_expiry_date);
    --
    l_expiry_date := END_OF_TIME;
  end if;

    hr_utility.trace('Exiting pay_ip_bal_upload.expiry_date');

RETURN l_expiry_date;

END expiry_date;

-- -------------------------------------------------------------------------
-- Function to check if adjustment is required for a particular Dimension.
-- p_test_batch_line_id identifies the adjustment that has already been processed
-- p_batch_line_id identifies the adjustment currently being processed.
-- -------------------------------------------------------------------------
FUNCTION include_adjustment
 	(
	  p_balance_type_id     NUMBER
	 ,p_dimension_name      VARCHAR2
	 ,p_original_entry_id   NUMBER
	 ,p_upload_date	        DATE
	 ,p_batch_line_id	NUMBER
	 ,p_test_batch_line_id	NUMBER
	 ,p_legislation_code	VARCHAR2
	 ) RETURN BOOLEAN IS

 l_include_adj BOOLEAN :=  TRUE ;
 l_orginal_entry_id   NUMBER;
 l_tax_unit_id	NUMBER;

	CURSOR csr_bal_adj (p_test_batch_line_id NUMBER, p_batch_line_id NUMBER) IS
	  SELECT tba.original_entry_id
	  FROM   pay_temp_balance_adjustments tba,
		 pay_balance_batch_lines bbl
	  WHERE  tba.batch_line_id = p_test_batch_line_id
	  AND    bbl.batch_line_id = p_batch_line_id
	  AND    nvl(tba.original_entry_id,0) = nvl(bbl.original_entry_id,0);

	CURSOR csr_bal_adj_tu (p_test_batch_line_id NUMBER, p_batch_line_id NUMBER) IS
	  SELECT tba.tax_unit_id
	  FROM   pay_temp_balance_adjustments tba,
		 pay_balance_batch_lines bbl
	  WHERE  tba.batch_line_id = p_test_batch_line_id
	  AND    bbl.batch_line_id = p_batch_line_id
	  AND    nvl(tba.tax_unit_id,0) = nvl(bbl.tax_unit_id,0);

/********************
*
* This is replaced by get_dim_route_name().
*
	CURSOR csr_route_name (l_legislation_code VARCHAR2, l_dimension_name VARCHAR2) IS
	  SELECT route_name
	  FROM ff_routes
	  WHERE route_id =
		(SELECT route_id
		FROM PAY_BALANCE_DIMENSIONS
		WHERE legislation_code= l_legislation_code
		AND upper(dimension_name) = upper(l_dimension_name)
		AND business_group_id IS NULL);
********************/

	l_route_name	FF_ROUTES.ROUTE_NAME%TYPE;
BEGIN

    hr_utility.trace('Entering pay_ip_bal_upload.include_adjustment');

    l_route_name :=  get_dim_route_name
                       (p_dimension_name   => p_dimension_name
                       ,p_legislation_code => p_legislation_code);

 	IF l_route_name IN ('Global Assignment Inception To Date',
			    'Global Assignment Processing Period To Date',
			    'Global Assignment Calendar Month To Date',
			    'Global Assignment Calendar Quarter To Date',
			    'Global Assignment Calendar Year To Date',
			    'Global Assignment Tax Quarter To Date',
			    'Global Assignment Tax Year To Date',
			    'Global Assignment Fiscal Quarter To Date',
			    'Global Assignment Fiscal Year To Date') THEN
                 l_include_adj := TRUE;

        ELSIF l_route_name IN ('Global Element Entry Inception To Date',
			       'Global Element Entry Processing Period To Date',
		     	       'Global Element Entry Calendar Month To Date',
			       'Global Element Entry Calendar Quarter To Date',
			       'Global Element Entry Calendar Year To Date') THEN

		 OPEN csr_bal_adj(p_test_batch_line_id => p_test_batch_line_id,
		 p_batch_line_id => p_batch_line_id);

		 FETCH csr_bal_adj INTO l_orginal_entry_id;

		 IF csr_bal_adj%NOTFOUND THEN
		      l_include_adj := FALSE ;
		 END IF;

		 CLOSE csr_bal_adj;
	ELSIF l_route_name IN ('Global Assignment Within Tax Unit Inception To Date',
			       'Global Assignment Within Tax Unit Processing Period To Date',
	   		       'Global Assignment Within Tax Unit Calendar Month To Date',
			       'Global Assignment Within Tax Unit Calendar Quarter To Date',
			       'Global Assignment Within Tax Unit Calendar Year To Date',
			       'Global Assignment Within Tax Unit Tax Quarter To Date',
			       'Global Assignment Within Tax Unit Tax Year To Date',
			       'Global Assignment Within Tax Unit Fiscal Quarter To Date',
			       'Global Assignment Within Tax Unit Fiscal Year To Date') THEN

		 OPEN csr_bal_adj_tu(p_test_batch_line_id => p_test_batch_line_id,
		 p_batch_line_id => p_batch_line_id);

		 FETCH csr_bal_adj_tu INTO l_tax_unit_id;

		 IF csr_bal_adj_tu%NOTFOUND THEN
		      l_include_adj := FALSE ;
		 END IF;

		 CLOSE csr_bal_adj_tu;
	ELSE
		NULL;
	END IF;

    hr_utility.trace('Exiting pay_ip_bal_upload.include_adjustment');

 RETURN l_include_adj;

END include_adjustment;
END pay_ip_bal_upload;


/
