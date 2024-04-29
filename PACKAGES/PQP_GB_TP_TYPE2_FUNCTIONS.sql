--------------------------------------------------------
--  DDL for Package PQP_GB_TP_TYPE2_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_TP_TYPE2_FUNCTIONS" AUTHID CURRENT_USER as
--  /* $Header: pqpgbtp2.pkh 120.0 2005/05/29 02:02:21 appldev noship $ */
--
-- Debug Variables.
--
  g_proc_name              varchar2(61) := 'pqp_gb_tp_type2_functions.';
  g_nested_level           number       := 0;
  g_trace                  varchar2(1)  := Null;

--
-- Global Variables
--
  g_business_group_id      number       := Null;
  g_legislation_code       varchar2(10) := 'GB';
  g_effective_date         date;
  g_extract_type           varchar2(30);
  g_effective_start_date   date;
  g_effective_end_date     date;
  g_header_system_element  ben_ext_rslt_dtl.val_01%type;
  g_add_cont_balance_name  varchar2(200) := 'Total Additional Contributions';
  g_total_add_cont         number := 0;


  Type t_number is table of number
  index by binary_integer;

  g_add_cont_value t_number;

--ENH3 And ENH4:
--
  g_estb_number                 VARCHAR2(4):='0000';
  g_crossbg_enabled             VARCHAR2(1) := 'N';
  g_lea_number                  VARCHAR2(3):=RPAD(' ',3,' ');
  g_criteria_location_code      VARCHAR2(20);
  g_extract_udt_name            VARCHAR2(80);
  g_master_bg_id                NUMBER:= NULL;
  g_effective_run_date          DATE;
  g_cross_per_enabled           VARCHAR2(1);

--

--
-- Cursor Definitions
--

  -- Cursor to get balance type id for a balance

  Cursor csr_get_pay_bal_id
    (c_balance_name  varchar2
    ) is
  select balance_type_id
    from pay_balance_types
  where balance_name     = c_balance_name
    and nvl(business_group_id, g_business_group_id) =
          g_business_group_id
    and legislation_code = 'GB';

  g_add_cont_bal_id pay_balance_types.balance_type_id%type;

  -- Cursor to get element type ids from balance
  --ENH2:The business group check was removed and business group id was
  --added in the select.This was done so that we pick up all the
  --element feeds to the balance.
  Cursor csr_get_pay_ele_ids_from_bal
    (c_balance_type_id      number
    ,c_effective_start_date date
    ,c_effective_end_date   date
    ) is
  select pet.element_type_id element_type_id,pet.business_group_id
    from pay_element_types_f pet
        ,pay_input_values_f  piv
        ,pay_balance_feeds_f pbf
  where  pet.element_type_id   = piv.element_type_id
--    and  pet.business_group_id = g_business_group_id
    and  piv.input_value_id    = pbf.input_value_id
    and  pbf.balance_type_id   = c_balance_type_id
    and  (pbf.effective_start_date between c_effective_start_date
                                     and c_effective_end_date
          or
          pbf.effective_end_date between c_effective_start_date
                                   and c_effective_end_date
          or
          c_effective_start_date between pbf.effective_start_date
                                   and pbf.effective_end_date
          or
          c_effective_end_date between pbf.effective_start_date
                                 and pbf.effective_end_date
         )
    order by pet.business_group_id,pet.element_type_id;

  type t_ele_ids_from_bal is table of csr_get_pay_ele_ids_from_bal%rowtype
  index by binary_integer;

  g_add_cont_ele_ids t_ele_ids_from_bal;

  -- Cursor to get assignment attribute information for a given assignment

  Cursor csr_get_aat_info
    (c_assignment_id        number
    ,c_effective_start_date date
    ,c_effective_end_date   date
    ) is
  select assignment_attribute_id
        ,assignment_id
        ,greatest(effective_start_date,
           c_effective_start_date) effective_start_date
        ,least(effective_end_date,
           c_effective_end_date)   effective_end_date
        ,tp_is_teacher
        ,tp_elected_pension
    from pqp_assignment_attributes_f
  where  assignment_id = c_assignment_id
    and  (effective_start_date between c_effective_start_date
                                 and c_effective_end_date
          or
          effective_end_date between c_effective_start_date
                               and c_effective_end_date
          or
          c_effective_start_date between effective_start_date
                                   and effective_end_date
          or
          c_effective_end_date between effective_start_date
                                 and effective_end_date
         )
  order by effective_start_date;

  Type t_aat_info is table of csr_get_aat_info%rowtype
  index by binary_integer;

  -- Cursor to get assignment information

  Cursor csr_get_asg_info
    (c_assignment_id        number
    ,c_effective_start_date date
    ,c_effective_end_date   date
    ) is
  select person_id
        ,assignment_id
        ,greatest(effective_start_date,
           c_effective_start_date)      effective_start_date
        ,least(effective_end_date,
           c_effective_end_date)        effective_end_date
        ,location_id
        ,business_group_id              --ENH8
        ,NVL(employment_category,'FT') asg_emp_cat_cd      --ENH3
    from per_all_assignments_f
  where  assignment_id = c_assignment_id
    and  (effective_start_date between c_effective_start_date
                                 and c_effective_end_date
          or
          effective_end_date between c_effective_start_date
                               and c_effective_end_date
          or
          c_effective_start_date between effective_start_date
                                   and effective_end_date
          or
          c_effective_end_date between effective_start_date
                                 and effective_end_date
         )
  order by effective_start_date;

  Type t_asg_info is table of csr_get_asg_info%rowtype
  index by binary_integer;

  -- Cursor to get element entries information
  --ENH8:The cursor has been changed to return only the valid element type id
  -- in the element entries list.

  Cursor csr_get_eet_info
    (c_assignment_id        number
    ,c_effective_start_date date
    ,c_effective_end_date   date
    ,c_element_type_id      number
    ) is
  select pee.element_type_id
    from pay_element_entries_f pee
--        ,pay_element_links_f   pel
  where  pee.assignment_id = c_assignment_id
    and  pee.element_type_id = c_element_type_id       --ENH8
    and  (pee.effective_start_date between c_effective_start_date
                                     and c_effective_end_date
          or
          pee.effective_end_date between c_effective_start_date
                                   and c_effective_end_date
          or
          c_effective_start_date between pee.effective_start_date
                                   and pee.effective_end_date
          or
          c_effective_end_date between pee.effective_start_date
                                 and pee.effective_end_date
         )
--    and  pel.element_link_id = pee.element_link_id
  order by pee.effective_start_date;

  -- Cursor to get multiple assignment info for a primary
  -- assignment

  Cursor csr_get_multiple_assignments
    (c_assignment_id        number
    ,c_effective_start_date date
    ,c_effective_end_date   date
    ) is
  select distinct(pef2.assignment_id) assignment_id
    from per_assignments_f pef
        ,per_assignments_f pef2
  where  pef.assignment_id = c_assignment_id
    and  pef2.person_id    = pef.person_id
    and  pef2.assignment_id <> pef.assignment_id
    and  (pef.effective_start_date between c_effective_start_date
                                     and c_effective_end_date
          or
          pef.effective_end_date between c_effective_start_date
                                   and c_effective_end_date
          or
          c_effective_start_date between pef.effective_start_date
                                   and pef.effective_end_date
          or
          c_effective_end_date between pef.effective_start_date
                                 and pef.effective_end_date
         )
    and  (pef2.effective_start_date between c_effective_start_date
                                      and c_effective_end_date
          or
          pef2.effective_end_date between c_effective_start_date
                                    and c_effective_end_date
          or
          c_effective_start_date between pef2.effective_start_date
                                   and pef2.effective_end_date
          or
          c_effective_end_date between pef2.effective_start_date
                                 and pef2.effective_end_date
         );

  -- Cursor to retrieve end_dates from per_time_periods
  Cursor csr_get_end_date
    (c_assignment_id         number
    ,c_effective_start_date  date
    ,c_effective_end_date    date) is
  select distinct(ptp.end_date) end_date
    from per_time_periods       ptp
        ,pay_payroll_actions    ppa
        ,pay_assignment_actions paa
  where  ptp.time_period_id    = ppa.time_period_id
    and  ppa.payroll_action_id = paa.payroll_action_id
    and  ppa.effective_date between c_effective_start_date
                              and c_effective_end_date
    and  ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
    and  paa.assignment_id     = c_assignment_id
  order by ptp.end_date;

  --

--This cursor is not being used.The one from type1 is being used.
--
-- Secondary Assignments which are Effective and future
--
/*CURSOR csr_sec_assignments
   (p_primary_assignment_id     NUMBER
   ,p_person_id                 NUMBER
   ,p_effective_date            DATE
   ) IS
SELECT DISTINCT asg.person_id         person_id
               ,asg.assignment_id     assignment_id
               ,asg.primary_flag        primary_flag
               ,asg.business_group_id business_group_id
               ,DECODE(asg.business_group_id
                      ,g_business_group_id, 0
                      ,asg.business_group_id) bizgrpcol
  FROM per_all_assignments_f asg
 WHERE asg.person_id = p_person_id
   AND asg.assignment_id <> p_primary_assignment_id
   AND ((p_effective_date BETWEEN asg.effective_start_date
                              AND asg.effective_end_date
        )
        OR
        ( -- Must have started on or after pension year start date
          asg.effective_start_date >= p_effective_date
          AND
          -- must have started within the reporting period
          asg.effective_start_date <= g_effective_run_date
        )
       )
UNION
SELECT DISTINCT per.person_id            person_id
               ,asg.assignment_id        assignment_id
               ,asg.primary_flag        primary_flag
               ,asg.business_group_id    business_group_id
               ,DECODE(asg.business_group_id
                      ,g_business_group_id, 0
                      ,asg.business_group_id) bizgrpcol
  FROM per_all_people_f per, per_all_assignments_f asg
 WHERE per.person_id <> p_person_id
   AND p_effective_date BETWEEN per.effective_start_date
                            AND per.effective_end_date
   AND g_cross_per_enabled = 'Y' -- Cross Person is enabled
   AND (g_crossbg_enabled = 'Y' -- get CrossBG multiple per recs
        OR
        (g_crossbg_enabled = 'N' -- get multiple per recs only in this BG
         AND
         per.business_group_id = g_business_group_id
        )
       )
   AND national_identifier =
         (SELECT national_identifier
          FROM per_all_people_f per2
          WHERE person_id = p_person_id
            AND p_effective_date BETWEEN per2.effective_start_date
                                     AND per2.effective_end_date
         )
   AND asg.person_id = per.person_id
   AND ((p_effective_date BETWEEN asg.effective_start_date
                            AND asg.effective_end_date
        )
        OR
        ( -- Must have started on or after pension year start date
          asg.effective_start_date >= p_effective_date
          AND
          -- must have started within the reporting period
          asg.effective_start_date <= g_effective_run_date
        )
       )
ORDER BY bizgrpcol ASC, person_id, primary_flag DESC;

TYPE t_secondary_asgs_type IS TABLE OF csr_sec_assignments%ROWTYPE
  INDEX BY BINARY_INTEGER;
*/

--ENH3 AND ENH4
CURSOR csr_get_person_id
(
c_assignment_id IN NUMBER
)
IS
SELECT person_id,business_group_id
FROM   per_all_assignments_f
WHERE  assignment_id = c_assignment_id
AND ROWNUM < 2;

--ENH3 AND ENH4

CURSOR csr_get_asg_cat
(
 c_assignment_id IN NUMBER
,c_start_date    IN DATE
)
IS
SELECT NVL(asg.employment_category,'FT') asg_emp_cat_cd
FROM   per_all_assignments_f asg
WHERE  asg.assignment_id = c_assignment_id
     AND ( c_start_date BETWEEN asg.effective_start_date
                                  AND asg.effective_end_date )
   ORDER BY asg.effective_start_date DESC; -- effective row first

---



--
-- Procedures and Functions
--

-- Get Pay Balance ID From Name

Function get_pay_bal_id
  (p_balance_name in     varchar2)
  Return number;

-- Get Pay Element Ids From Balance

Procedure get_pay_ele_ids_from_bal
  (p_balance_type_id      in     number
  ,p_effective_start_date in     date
  ,p_effective_end_date   in     date
  ,p_tab_ele_ids             out nocopy t_ele_ids_from_bal
  );

-- Get Element Entires Details

Procedure get_eet_info
  (p_assignment_id        in     number
  ,p_effective_start_date in     date
  ,p_effective_end_date   in     date
  ,p_location_id          in     number
  ,p_business_group_id    in     number        --ENH8
  ,p_return_status        out nocopy boolean   --ENH3 And ENH4
  );

-- Get Assignment Details

FUNCTION get_asg_info
  (p_assignment_id        in            number
  ,p_effective_start_date in out nocopy date        --ENH3 And ENH4
  ,p_effective_end_date   in            date
  ,p_location_id          out nocopy    number      --ENH3 And ENH4
  ,p_ext_emp_cat_cd       out nocopy    varchar2    --ENH3 And ENH4
  ) RETURN BOOLEAN;  --ENH3 And ENH4

-- Get Assignment Attributes Details

FUNCTION get_aat_info
  (p_assignment_id        in    number
  ,p_effective_start_date in    date
  ,p_effective_end_date   in    date
  ,p_ext_emp_cat_cd       in    varchar2    --ENH3 And ENH4
  ,p_location_id          in    number      --ENH3 And ENH4
  ) RETURN BOOLEAN; --ENH3 And ENH4



-- Criteria function

Function chk_teacher_qual_for_tp2
  (p_business_group_id  in      number
  ,p_effective_date     in      date
  ,p_assignment_id      in      number
  ,p_error_text             out nocopy  varchar2
  ,p_error_number           out nocopy number
  )
  Return varchar2;

-- Get Additional Contribution Value

Function get_add_cont_value
  (p_assignment_id in     number)
  Return varchar2;

-- Get Additional Contribution Refund Indicator

Function get_add_cont_refund_ind
  (p_assignment_id in     number)
  Return number;

-- Get Financial Year

Function get_financial_year
  Return varchar2;

-- Get Total Additional Contribution Value

Function get_total_add_cont
  Return varchar2;

-- Get Total Additional Contribution Refund Indicator

Function get_total_add_cont_sign
  Return number;

--

-- Check LEA run

Function chk_lea_run
  Return varchar2;




End pqp_gb_tp_type2_functions;

 

/
