--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_TRAINING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_TRAINING" AS
/* $Header: hriodtrn.pkb 120.0 2005/05/29 07:29:32 appldev noship $ */

---------------------------
-- Package global variables
---------------------------
g_bg_currency_code		per_business_groups.currency_code%type;
g_business_group_id		per_business_groups.business_group_id%type;
g_precision			fnd_currencies.precision%type;
g_rate_type			varchar2(30);
g_training_formula_id		ff_formulas_f.formula_id%type;


/******************************************************************************/
/* Procedure to set package global variables for Training Analysis            */
/******************************************************************************/
PROCEDURE set_training_globals(p_event_id    IN NUMBER) IS

  CURSOR bg_csr is
  SELECT business_group_id
  FROM ota_events
  WHERE event_id = p_event_id;

  CURSOR bg_currency_csr is
  SELECT bg.currency_code, NVL(c.precision,2)
  FROM fnd_currencies c
  ,per_business_groups bg
  WHERE bg.currency_code = c.currency_code
  AND bg.business_group_id = g_business_group_id;

BEGIN

  IF p_event_id IS NOT NULL THEN

-- Get Business Group Id
    OPEN bg_csr;
    FETCH bg_csr INTO g_business_group_id;
    CLOSE bg_csr;

-- Get currency of business group
    OPEN bg_currency_csr;
    FETCH bg_currency_csr INTO g_bg_currency_code, g_precision;
    CLOSE bg_currency_csr;

-- Determine Rate Type for BIS
    g_rate_type := hr_currency_pkg.get_rate_type(
			 p_business_group_id	=> g_business_group_id
			,p_conversion_date	=> sysdate
			,p_processing_type	=> 'I');

-- Determine Formula Id of the Training Convert Duration FastFormula
    g_training_formula_id := hr_disc_calculations.get_formula_id(
	 p_business_group_id	=> g_business_group_id
	,p_formula_name		=> 'BIS_TRAINING_CONVERT_DURATION');

  END IF;

END set_training_globals;


/******************************************************************************/
/* Private function to pro-rate an amount held against a Programme training   */
/* event across the members of the Programme                                  */
/******************************************************************************/
FUNCTION pro_rata_amount(p_event_id           IN NUMBER
                        ,p_program_event_id   IN NUMBER
                        ,p_programme_amount   IN NUMBER
                        ,p_currency_code      IN VARCHAR2)
               RETURN NUMBER IS

  CURSOR program_member_csr( p_program_event_id NUMBER ) is
  SELECT
   evt.event_id
  ,evt.duration
  ,evt.duration_units
  ,evt.title
  ,tav.version_name
  FROM
   ota_activity_versions    tav
  ,ota_events               evt
  ,ota_program_memberships  pm
  WHERE	evt.activity_version_id = tav.activity_version_id
  AND evt.event_id = pm.event_id
  AND pm.program_event_id = p_program_event_id;

  program_member_rec    program_member_csr%rowtype;

  l_activity_version_name  ota_activity_versions.version_name%type;
  l_duration               ota_events.duration%type := 0;
  l_event_duration         ota_events.duration%type := 0;
  l_event_name	           ota_events.title%type;
  l_pro_rata_amount        number := 0;
  l_pro_rata_total         number := 0;
  l_total_duration         number := 0;

BEGIN

------------------------------------
-- Have all parameters been passed ?
------------------------------------
  IF (p_event_id         IS NULL) OR (p_program_event_id IS NULL) OR
     (p_programme_amount IS NULL) OR (p_currency_code    IS NULL) THEN
    RETURN(0);
  END IF;

-------------------------------------------------------------
-- Loop round all the events which are members of the program
-------------------------------------------------------------
  FOR program_member_rec IN program_member_csr( p_program_event_id ) LOOP

    IF program_member_rec.duration_units = 'H' THEN
      l_duration := program_member_rec.duration;
    ELSE

----------------------------------
-- Convert event duration to hours
----------------------------------
      l_duration := hr_disc_calculations.training_convert_duration(
                 p_formula_id             => g_training_formula_id
                ,p_FROM_duration          => program_member_rec.duration
                ,p_FROM_duration_units    => program_member_rec.duration_units
                ,p_to_duration_units      => 'H'
                ,p_activity_version_name  => program_member_rec.version_name
                ,p_event_name             => program_member_rec.title
                ,p_session_date           => sysdate);

      IF program_member_rec.event_id = p_event_id then
        l_event_duration := l_duration;
      END IF;

    END IF;

    l_total_duration := l_total_duration + nvl(l_duration,0);

  END loop;

-----------------------------------
-- Perform the pro-rata calculation
-----------------------------------
  l_pro_rata_amount := l_event_duration * p_programme_amount / l_total_duration;

--------------------------------------------------------------------
-- Convert to currency of BG AND update total for all program events
--------------------------------------------------------------------
  l_pro_rata_amount := hri_bpl_currency.convert_currency_amount(
	 p_from_currency	=> p_currency_code
	,p_to_currency		=> g_bg_currency_code
        ,p_conversion_date      => SYSDATE
	,p_amount		=> l_pro_rata_amount
	,p_rate_type		=> g_rate_type);

  l_pro_rata_total  := l_pro_rata_total + l_pro_rata_amount;

  RETURN(l_pro_rata_total);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END pro_rata_amount;


/******************************************************************************/
/* Public function to calculate the Budget Cost of a training event           */
/******************************************************************************/
FUNCTION get_event_budget_cost(p_event_id      IN NUMBER)
               RETURN NUMBER IS

  CURSOR budget_cost_csr(p_csr_event_id    NUMBER) IS
  SELECT
   nvl(budget_cost,0)	budget_cost
  ,budget_currency_code
  ,business_group_id
  FROM ota_events
  WHERE event_id = p_csr_event_id;

  l_business_group_id       ota_events.business_group_id%type;

  CURSOR program_event_csr is
  SELECT program_event_id
  FROM ota_program_memberships
  WHERE event_id = p_event_id;

  program_event_rec        program_event_csr%rowtype;
  l_budget_cost	           ota_events.budget_cost%type := 0;
  l_budget_currency_code   ota_events.budget_currency_code%type;
  l_converted_amount       ota_events.budget_cost%type := 0;
  l_pro_rata_amount        NUMBER := 0;
  l_total_budget_cost      NUMBER := 0;
  l_pro_rata_total         NUMBER := 0;

BEGIN

  IF p_event_id IS NULL THEN
    RETURN(0);
  END IF;

-- Get Budget Cost of the event
  OPEN budget_cost_csr( p_event_id );
  FETCH budget_cost_csr INTO
	l_budget_cost, l_budget_currency_code, l_business_group_id;
  CLOSE budget_cost_csr;

  IF l_business_group_id IS NOT NULL THEN

-- Set package global variables
    set_training_globals(p_event_id => p_event_id);

-- Convert Budget Cost to business group currency
    l_converted_amount := hri_bpl_currency.convert_currency_amount(
                p_from_currency	   => l_budget_currency_code
               ,p_to_currency      => g_bg_currency_code
               ,p_conversion_date  => SYSDATE
               ,p_amount           => l_budget_cost
               ,p_rate_type        => g_rate_type);

  END IF;

-- Is the event a member of a programme(s) ?
  FOR program_event_rec IN program_event_csr LOOP

-- Get Budget Cost of the programme event
    OPEN budget_cost_csr( program_event_rec.program_event_id );
    FETCH budget_cost_csr INTO
	l_budget_cost, l_budget_currency_code, l_business_group_id;
    CLOSE budget_cost_csr;

-- Pro-rate programme amount if necessary
    IF l_budget_cost <> 0 THEN

      l_pro_rata_amount := pro_rata_amount(
            p_event_id         => p_event_id
           ,p_program_event_id => program_event_rec.program_event_id
           ,p_programme_amount => l_budget_cost
           ,p_currency_code    => l_budget_currency_code);

    END IF;

    l_pro_rata_total := l_pro_rata_total + l_pro_rata_amount;

  END LOOP;

  l_total_budget_cost := l_converted_amount + l_pro_rata_total;

  RETURN (ROUND(l_total_budget_cost, g_precision));

EXCEPTION
  WHEN OTHERS THEN

    RETURN(0);

END get_event_budget_cost;


/******************************************************************************/
/* Public function to calculate the Actual Cost of a training event           */
/******************************************************************************/
FUNCTION get_event_actual_cost(p_event_id    IN NUMBER)
                   RETURN NUMBER IS

-- This cursor won't work if the resource is priced in units other than Days
-- Need to fix this in a future release
  CURSOR resource_bookings_csr(p_csr_event_id   NUMBER) IS
  SELECT
   sr.currency_code
  ,sr.cost_unit
  ,nvl(sr.cost,0) * nvl(rb.quantity,0) *
           nvl(trunc(rb.required_date_to - rb.required_date_FROM + 1),0) cost
  FROM
   ota_suppliable_resources  sr
  ,ota_resource_bookings     rb
  WHERE	rb.supplied_resource_id = sr.supplied_resource_id
  AND rb.event_id = p_csr_event_id
  AND rb.status = 'C';	-- Confirmed bookings only

  resource_bookings_rec	  resource_bookings_csr%rowtype;

  CURSOR actual_cost_csr IS
  SELECT
   nvl(actual_cost,0)
  ,budget_currency_code
  ,business_group_id
  FROM ota_events
  WHERE event_id = p_event_id;

  l_actual_cost              NUMBER := 0;
  l_actual_currency_code     ota_events.budget_currency_code%type;
  l_business_group_id        ota_events.business_group_id%type;
  l_event_cost               NUMBER := 0;
  l_resource_cost            NUMBER := 0;

BEGIN

  IF p_event_id IS NULL THEN
    RETURN(0);
  END IF;

-- Get Actual Cost of the event
  OPEN actual_cost_csr;
  FETCH actual_cost_csr INTO
	l_actual_cost, l_actual_currency_code, l_business_group_id;
  CLOSE actual_cost_csr;

-- Set package global variables
  set_training_globals(p_event_id => p_event_id);

-- Calculate total cost of resource bookings against the event
  FOR resource_bookings_rec IN resource_bookings_csr(p_event_id) LOOP

-- Convert to currency of BG
    l_resource_cost := hri_bpl_currency.convert_currency_amount(
                 p_from_currency    => resource_bookings_rec.currency_code
                ,p_to_currency      => g_bg_currency_code
                ,p_conversion_date  => SYSDATE
                ,p_amount           => resource_bookings_rec.cost
                ,p_rate_type        => g_rate_type);

    l_event_cost := l_event_cost + l_resource_cost;

  END loop;

-- Default to the actual cost on the event if necessary
  IF l_event_cost = 0 THEN

    l_event_cost := hri_bpl_currency.convert_currency_amount(
                 p_from_currency    => l_actual_currency_code
                ,p_to_currency      => g_bg_currency_code
                ,p_conversion_date  => SYSDATE
                ,p_amount           => l_actual_cost
                ,p_rate_type        => g_rate_type);

  END IF;

  RETURN (ROUND(l_event_cost, g_precision));

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_event_actual_cost;


/******************************************************************************/
/* Private function to calculate the Internal Revenue generated by a training */
/* event                                                                      */
/******************************************************************************/
FUNCTION get_internal_revenue(p_event_id     IN NUMBER)
               RETURN NUMBER IS

  CURSOR event_csr is
  SELECT
   price_basis
  ,nvl(stANDard_price,0)
  ,currency_code
  FROM ota_events
  WHERE event_id = p_event_id;

  CURSOR internal_bookings_csr is
  SELECT NVL(SUM(NVL(tdb.number_of_places,1)),0)
  FROM
   ota_booking_status_types   bst
  ,ota_delegate_bookings      tdb
  WHERE tdb.booking_status_type_id = bst.booking_status_type_id
  AND bst.type = 'A'   -- Attended
  AND tdb.organization_id IS NOT NULL
  AND tdb.event_id = p_event_id;

  l_currency_code       ota_events.currency_code%type;
  l_internal_revenue    NUMBER := 0;
  l_price_basis	        ota_events.price_basis%type;
  l_standard_price      ota_events.standard_price%type;
  l_total_int_students  NUMBER := 0;

BEGIN
-- Get event details
  OPEN event_csr;
  FETCH event_csr INTO
	l_price_basis, l_standard_price, l_currency_code;
  CLOSE event_csr;

-- Price Basis = 'Student' ?
  IF (l_price_basis = 'S') AND (l_standard_price <> 0) then

    OPEN internal_bookings_csr;
    FETCH internal_bookings_csr INTO l_total_int_students;
    CLOSE internal_bookings_csr;

-- Calculate internal revenue
    l_internal_revenue := l_total_int_students * l_standard_price;

-- Convert to currency of business group
    l_internal_revenue := hri_bpl_currency.convert_currency_amount(
                 p_from_currency    => l_currency_code
                ,p_to_currency      => g_bg_currency_code
                ,p_conversion_date  => SYSDATE
                ,p_amount           => l_internal_revenue
                ,p_rate_type        => g_rate_type);

  END IF;

  RETURN(l_internal_revenue);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_internal_revenue;


/******************************************************************************/
/* Private function to calculate the External Revenue generated by a training */
/* event                                                                      */
/******************************************************************************/
FUNCTION get_external_revenue(p_event_id    IN NUMBER)
                    RETURN NUMBER IS

  CURSOR external_bookings_csr is
  SELECT tdb.booking_id
  FROM ota_booking_status_types   bst
      ,ota_delegate_bookings    tdb
  WHERE	tdb.booking_status_type_id = bst.booking_status_type_id
  AND bst.type = 'A'     -- Attended
  AND tdb.customer_id is not null
  AND tdb.event_id = p_event_id;

  external_bookings_rec      external_bookings_csr%rowtype;

  CURSOR finance_lines_csr( p_delegate_booking_id NUMBER ) is
  SELECT
   currency_code
  ,SUM(NVL(money_amount,0))	amount
  FROM	ota_finance_lines
  WHERE line_type = 'E'	   -- Enrollment
  AND cancelled_flag = 'N'
  AND booking_id = p_delegate_booking_id
  GROUP BY currency_code;

  finance_lines_rec       finance_lines_csr%rowtype;

  l_external_revenue      NUMBER := 0;
  l_line_amount	          NUMBER := 0;

BEGIN

  FOR external_bookings_rec IN external_bookings_csr LOOP

    FOR finance_lines_rec IN finance_lines_csr(external_bookings_rec.booking_id) LOOP

-- Convert to currency of business group
      l_line_amount := hri_bpl_currency.convert_currency_amount(
                 p_FROM_currency    => finance_lines_rec.currency_code
                ,p_to_currency      => g_bg_currency_code
                ,p_conversion_date  => SYSDATE
                ,p_amount           => finance_lines_rec.amount
                ,p_rate_type        => g_rate_type);

      l_external_revenue := l_external_revenue + l_line_amount;

    END LOOP;

  END LOOP;

  RETURN(l_external_revenue);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_external_revenue;


/******************************************************************************/
/* cbridge, 13/09/20000, course ranking workbook functions                    */
/* Private function to calculate the Internal Revenue generated by a training */
/* event for a particular delegate booking where the delegate attended the    */
/* event                                                                      */
/******************************************************************************/
FUNCTION get_att_int_rev_booking(p_event_id       IN NUMBER,
                                 p_booking_id     IN NUMBER)
               RETURN NUMBER IS

  CURSOR event_csr is
  SELECT
   price_basis
  ,nvl(stANDard_price,0)
  ,currency_code
  FROM ota_events
  WHERE event_id = p_event_id;

  CURSOR internal_bookings_csr is
  SELECT  NVL(SUM(NVL(tdb.number_of_places,1)),0)
  FROM     ota_booking_status_types     bst
          ,ota_delegate_bookings        tdb
  WHERE tdb.booking_status_type_id = bst.booking_status_type_id
  AND bst.type = 'A'       -- AttENDed
  AND tdb.organization_id IS NOT NULL
  AND tdb.booking_id = p_booking_id
  AND tdb.event_id = p_event_id;

  l_currency_code         ota_events.currency_code%type;
  l_internal_revenue      NUMBER := 0;
  l_price_basis           ota_events.price_basis%type;
  l_standard_price        ota_events.standard_price%type;
  l_total_int_students    NUMBER := 0;

BEGIN

  ----------------------
  -- Set package globals
  ----------------------
  set_training_globals(p_event_id => p_event_id);

  -- Get event details
  OPEN event_csr;
  FETCH event_csr INTO
        l_price_basis, l_stANDard_price, l_currency_code;
  CLOSE event_csr;

-- Price Basis = 'Student' ?
  IF (l_price_basis = 'S') AND (l_standard_price <> 0) THEN

    OPEN internal_bookings_csr;
    FETCH internal_bookings_csr INTO l_total_int_students;
    CLOSE internal_bookings_csr;

-- Calculate internal revenue
    l_internal_revenue := l_total_int_students * l_stANDard_price;

-- Convert to currency of business group
    l_internal_revenue := hri_bpl_currency.convert_currency_amount(
                 p_from_currency        => l_currency_code
                ,p_to_currency          => g_bg_currency_code
                ,p_conversion_date      => SYSDATE
                ,p_amount               => l_internal_revenue
                ,p_rate_type            => g_rate_type);

  END IF;

  RETURN(l_internal_revenue);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_att_int_rev_booking;


/******************************************************************************/
/* Private function to calculate the External Revenue generated by a training */
/* event for a particular delegate booking where the delegate attended the    */
/* event                                                                      */
/******************************************************************************/
FUNCTION get_att_ext_rev_booking(p_event_id     IN NUMBER,
                                 p_booking_id   IN NUMBER)
              RETURN NUMBER IS

  CURSOR external_bookings_csr IS
  SELECT tdb.booking_id
  FROM  ota_booking_status_types       bst
       ,ota_delegate_bookings          tdb
  WHERE tdb.booking_status_type_id = bst.booking_status_type_id
  AND bst.type = 'A'           -- Attended
  AND tdb.booking_id = p_booking_id
  AND tdb.organization_id IS NULL -- bug fix 1432057
  AND tdb.event_id = p_event_id;

  external_bookings_rec   external_bookings_csr%rowtype;

  CURSOR finance_lines_csr(p_delegate_booking_id    NUMBER) IS
  SELECT
   currency_code
  ,sum(nvl(money_amount,0))       amount
  FROM ota_finance_lines
  WHERE line_type = 'E'   -- Enrollment
  AND cancelled_flag = 'N'
  AND booking_id = p_delegate_booking_id
  GROUP BY currency_code;

  finance_lines_rec       finance_lines_csr%rowtype;

  l_external_revenue      NUMBER := 0;
  l_line_amount           NUMBER := 0;

BEGIN

  ----------------------
  -- Set package globals
  ----------------------
  set_training_globals(p_event_id => p_event_id);

  FOR external_bookings_rec IN external_bookings_csr LOOP

    FOR finance_lines_rec IN finance_lines_csr(external_bookings_rec.booking_id) LOOP

    -- Convert to currency of business group
      l_line_amount := hri_bpl_currency.convert_currency_amount(
                 p_from_currency        => finance_lines_rec.currency_code
                ,p_to_currency          => g_bg_currency_code
                ,p_conversion_date      => SYSDATE
                ,p_amount               => finance_lines_rec.amount
                ,p_rate_type            => g_rate_type);

      l_external_revenue := l_external_revenue + l_line_amount;

    END LOOP;

  END LOOP;

  RETURN(l_external_revenue);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_att_ext_rev_booking;


/******************************************************************************/
/* Private function to calculate the Internal Revenue generated by a training */
/* event for a particular delegate booking where the delegate did not attend  */
/* the event                                                                  */
/******************************************************************************/
FUNCTION get_non_att_int_rev_booking(p_event_id     IN NUMBER,
                                     p_booking_id   IN NUMBER)
                 RETURN NUMBER IS

  CURSOR event_csr is
  SELECT
   price_basis
  ,nvl(stANDard_price,0)
  ,currency_code
  FROM ota_events
  WHERE event_id = p_event_id;

  CURSOR internal_bookings_csr is
  SELECT NVL(SUM(NVL(tdb.number_of_places,1)),0)
  FROM ota_booking_status_types       bst
      ,ota_delegate_bookings          tdb
  WHERE tdb.booking_status_type_id = bst.booking_status_type_id
  AND bst.type IN ('P','C')            -- Placed, Cancelled
  AND tdb.organization_id IS NOT NULL
  AND tdb.booking_id = p_booking_id
  AND tdb.event_id = p_event_id;

  l_currency_code         ota_events.currency_code%type;
  l_internal_revenue      NUMBER := 0;
  l_price_basis           ota_events.price_basis%type;
  l_standard_price        ota_events.standard_price%type;
  l_total_int_students    NUMBER := 0;

BEGIN

  ----------------------
  -- Set package globals
  ----------------------
  set_training_globals(p_event_id => p_event_id);

-- Get event details
  OPEN event_csr;
  FETCH event_csr INTO
         l_price_basis, l_standard_price, l_currency_code;
  CLOSE event_csr;

  -- Price Basis = 'Student' ?
  IF (l_price_basis = 'S') AND (l_standard_price <> 0) THEN

    OPEN internal_bookings_csr;
    FETCH internal_bookings_csr INTO l_total_int_students;
    CLOSE internal_bookings_csr;

    -- Calculate internal revenue
    l_internal_revenue := l_total_int_students * l_stANDard_price;

    -- Convert to currency of business group
    l_internal_revenue := hri_bpl_currency.convert_currency_amount(
               p_FROM_currency        => l_currency_code
              ,p_to_currency          => g_bg_currency_code
              ,p_conversion_date      => SYSDATE
              ,p_amount               => l_internal_revenue
              ,p_rate_type            => g_rate_type);

  END IF;

  RETURN(l_internal_revenue);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_non_att_int_rev_booking;


/******************************************************************************/
/* Private function to calculate the External Revenue generated by a training */
/* event for a particular delegate booking where the delegate did not attend  */
/* the event                                                                  */
/******************************************************************************/
FUNCTION get_non_att_ext_rev_booking(p_event_id     IN NUMBER,
                                     p_booking_id   IN NUMBER)
              RETURN NUMBER IS

  CURSOR external_bookings_csr is
  SELECT tdb.booking_id
  FROM ota_booking_status_types       bst
      ,ota_delegate_bookings          tdb
  WHERE tdb.booking_status_type_id = bst.booking_status_type_id
  AND bst.type IN ('P','C')            -- Placed, Cancelled
  AND tdb.booking_id = p_booking_id
  AND tdb.organization_id IS NULL      -- bug fix 1432057
  AND tdb.event_id = p_event_id;

  external_bookings_rec   external_bookings_csr%rowtype;

  CURSOR finance_lines_csr(p_delegate_booking_id    NUMBER) IS
  SELECT
   currency_code
  ,SUM(NVL(money_amount,0))       amount
  FROM ota_finance_lines
  WHERE line_type = 'E'   -- Enrollment
  AND cancelled_flag = 'N'
  AND booking_id = p_delegate_booking_id
  GROUP BY currency_code;

  finance_lines_rec       finance_lines_csr%rowtype;

  l_external_revenue      NUMBER := 0;
  l_line_amount           NUMBER := 0;

BEGIN

  ----------------------
  -- Set package globals
  ----------------------
  set_training_globals(p_event_id => p_event_id);

  FOR external_bookings_rec IN external_bookings_csr LOOP

    FOR finance_lines_rec IN finance_lines_csr(external_bookings_rec.booking_id) LOOP

   -- Convert to currency of business group
      l_line_amount := hri_bpl_currency.convert_currency_amount(
                p_from_currency        => finance_lines_rec.currency_code
               ,p_to_currency          => g_bg_currency_code
               ,p_conversion_date      => SYSDATE
               ,p_amount               => finance_lines_rec.amount
               ,p_rate_type            => g_rate_type);

      l_external_revenue := l_external_revenue + l_line_amount;

    END loop;

  END loop;

  RETURN(l_external_revenue);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_non_att_ext_rev_booking;


/******************************************************************************/
/* Public function to calculate the Total Revenue generated by a training     */
/* event                                                                      */
/******************************************************************************/
FUNCTION get_event_revenue(p_event_id   IN NUMBER)
              RETURN NUMBER IS

  CURSOR program_event_csr IS
  SELECT program_event_id
  FROM ota_program_memberships
  WHERE event_id = p_event_id;

  program_event_rec     program_event_csr%rowtype;

  l_external_revenue           NUMBER := 0;
  l_internal_revenue           NUMBER := 0;
  l_program_ext_revenue	       NUMBER := 0;
  l_program_int_revenue	       NUMBER := 0;
  l_program_prorata_revenue    NUMBER := 0;
  l_program_prorata_total      NUMBER := 0;
  l_program_revenue            NUMBER := 0;
  l_total_revenue              NUMBER := 0;

BEGIN

  IF p_event_id IS NULL THEN
    RETURN(0);
  END IF;

----------------------
-- Set package globals
----------------------
  set_training_globals(p_event_id => p_event_id);

-------------------------------------
-- Get Internal Revenue for the event
-------------------------------------
  l_internal_revenue := get_internal_revenue(p_event_id	=> p_event_id);

-------------------------------------
-- Get External Revenue for the event
-------------------------------------
  l_external_revenue := get_external_revenue(p_event_id	=> p_event_id);

----------------------------
-- Calculate program revenue
----------------------------

-- Is the event a member of a programme ?
  FOR program_event_rec IN program_event_csr LOOP

-- Determine internal revenue for the program event
    l_program_int_revenue := get_internal_revenue
                      (p_event_id => program_event_rec.program_event_id);

-- Determine external revenue for the program event
    l_program_ext_revenue := get_external_revenue
                      (p_event_id => program_event_rec.program_event_id);

-- Calculate total program revenue
    l_program_revenue := l_program_int_revenue + l_program_ext_revenue;

-- Prorate the program revenue

    l_program_prorata_revenue := pro_rata_amount(
                   p_event_id           => p_event_id
                  ,p_program_event_id   => program_event_rec.program_event_id
                  ,p_programme_amount   => l_program_revenue
                  ,p_currency_code      => g_bg_currency_code);

    l_program_prorata_total := l_program_prorata_total + l_program_prorata_revenue;

  END loop;

--------------------------
-- Calculate total revenue
--------------------------
  l_total_revenue := l_internal_revenue + l_external_revenue + l_program_prorata_total;

  RETURN (ROUND(l_total_revenue, g_precision) );

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END get_event_revenue;

/******************************************************************************/
/* Public function to convert Training Duration FROM one set of units to      */
/* another                                                                    */
/******************************************************************************/
FUNCTION convert_training_duration(p_formula_id              IN NUMBER
                                  ,p_from_duration           IN NUMBER
                                  ,p_from_duration_units     IN VARCHAR2
                                  ,p_to_duration_units       IN VARCHAR2
                                  ,p_activity_version_name   IN VARCHAR2
                                  ,p_event_name              IN VARCHAR2
                                  ,p_session_date            IN DATE)
                  RETURN NUMBER IS

  l_to_duration       NUMBER := 0;

  l_inputs            FF_Exec.Inputs_T;
  l_outputs           FF_Exec.Outputs_T;

BEGIN

-- Check whether all mandatory parameters have been supplied
  IF (p_formula_id          IS NULL) OR (p_from_duration     IS NULL) OR
     (p_from_duration_units IS NULL) OR (p_to_duration_units IS NULL) OR
     (p_event_name          IS NULL) OR (p_session_date      IS NULL) THEN
   --
   -- bug fix 1432188 remove check for (p_activity_version_name IS NULL)
   --
    RETURN(0);
  END IF;

-- Initialise the Inputs and Outputs tables
  FF_Exec.Init_Formula(
         p_formula_id => p_formula_id
        ,p_effective_date => sysdate
        ,p_inputs => l_inputs
        ,p_outputs => l_outputs);

  IF (l_inputs.first IS NOT NULL) AND (l_inputs.last IS NOT NULL) THEN

-- Set up context values for the formula
    FOR i IN l_inputs.first..l_inputs.last LOOP

      IF l_inputs(i).name = 'FROM_DURATION' THEN
        l_inputs(i).value := to_char(p_from_duration);

      ELSIF l_inputs(i).name = 'FROM_DURATION_UNITS' THEN
        l_inputs(i).value := p_FROM_duration_units;

      ELSIF l_inputs(i).name = 'TO_DURATION_UNITS' THEN
        l_inputs(i).value := p_to_duration_units;

      ELSIF l_inputs(i).name = 'ACTIVITY_VERSION_NAME' THEN
      -- bug fix 1432188,  added NVL(p_activity_version_name,'X')
        l_inputs(i).value := NVL(p_activity_version_name,'X');

      ELSIF l_inputs(i).name = 'EVENT_NAME' THEN
        l_inputs(i).value := p_event_name;

      END IF;

    END loop;

  END IF;

-- Run the Fast Formula
  FF_Exec.Run_Formula(
         p_inputs	=> l_inputs
        ,p_outputs	=> l_outputs);

  l_to_duration := to_number(l_outputs(l_outputs.first).value);

  RETURN(l_to_duration);

EXCEPTION
  WHEN OTHERS THEN

  RETURN(0);

END convert_training_duration;

END hri_oltp_disc_training;

/
