--------------------------------------------------------
--  DDL for Package Body PQP_GB_TP_TYPE2_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_TP_TYPE2_FUNCTIONS" as
--  /* $Header: pqpgbtp2.pkb 120.0.12010000.4 2009/06/09 11:39:49 dchindar ship $ */
--
-- Local Variables

  g_inclusion_flag   varchar2(1)   := 'N';
  g_error_text       varchar2(200) := null;
  g_error_number     number        := null;
--  g_ele_exists       varchar2(1)   := null;

-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

Procedure debug
  (p_trace_message  in     varchar2
  ,p_trace_location in     number   default null
  ) is
--
  l_padding            varchar2(12);
  l_max_message_length number:= 2000;
--
Begin

  --
  --
  --
  If p_trace_location is not null Then

     l_padding := substr
                    (rpad(' ',least(g_nested_level,5)*2,' ')
                    ,1,l_max_message_length
                    - least(length(p_trace_message)
                              ,l_max_message_length)
                    );

     hr_utility.set_location (l_padding || substr(p_trace_message
               ,greatest(-length(p_trace_message),-l_max_message_length))
               ,p_trace_location);

  Else

    hr_utility.trace(substr(p_trace_message,1,250));

  End If;
  --

End debug;

--
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

Procedure debug
  (p_trace_number   in     number ) is
--
Begin

  --
  debug(fnd_number.number_to_canonical(p_trace_number));
  --

End debug;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

Procedure debug
  (p_trace_date     in     date ) is
--
Begin

  --
  debug(fnd_date.date_to_canonical(p_trace_date));
  --

End debug;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_enter >-------------------------------|
-- ----------------------------------------------------------------------------

/*Procedure debug_enter
  (p_proc_name in varchar2 default null
  ,p_trace_on  in varchar2 default null
  ) is
--
   l_trace_options    varchar2(200);
--
Begin

  --
  -- --Uncomment this code to run the extract with a debug trace
  --
--   If  g_nested_level = 0 -- swtich tracing on/off at the top level only
--   And nvl(p_trace_on,'N') = 'Y'
--   Then
  --
--      hr_utility.trace_on(null,'REQID'); -- Pipe name REQIDnnnnnn

--  End If; -- if nested level = 0
  --
  -- --Uncomment this code to run the extract with a debug trace

  g_nested_level :=  g_nested_level + 1;
  debug('Entered: '||nvl(p_proc_name,g_proc_name),g_nested_level*100);
  --

End debug_enter;*/

--
-- debug_enter
-- swtich tracing on/off at the top level only
--

PROCEDURE debug_enter
  (p_proc_name IN VARCHAR2  default null
  ,p_trace_on  IN VARCHAR2  default null
  )
IS

  l_extract_attributes    pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes%ROWTYPE;
  l_business_group_id     per_all_assignments_f.business_group_id%TYPE;

BEGIN

  debug(':g_nested_level:'||g_nested_level,000);

  IF  g_nested_level = 0 THEN -- swtich tracing on/off at the top level only

    -- Set the trace flag, but only the first time around
    debug(':g_trace:'||g_trace,000);

    IF g_trace IS NULL THEN

      OPEN pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes;
      FETCH pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes INTO l_extract_attributes;
      CLOSE pqp_gb_tp_pension_extracts.csr_pqp_extract_attributes;

      l_business_group_id := fnd_global.per_business_group_id;

      BEGIN
        g_trace := hruserdt.get_table_value
                  (p_bus_group_id   => l_business_group_id
                  ,p_table_name     => l_extract_attributes.user_table_name
                  ,p_col_name       => 'Attribute Location Qualifier 1'
                  ,p_row_value      => 'Debug'
                  ,p_effective_date => NULL -- don't hv the date
                  );
      debug(':g_trace:'||g_trace,000);

      EXCEPTION
        WHEN OTHERS THEN
          g_trace := 'N';
      END;

      g_trace := nvl(g_trace,'N');

      debug('UDT Trace Flag : '||g_trace);

    END IF; -- g_trace IS NULL THEN

    debug(':g_trace:'||g_trace,000);

    IF NVL(p_trace_on,'N') = 'Y'
       OR
       g_trace = 'Y' THEN

      hr_utility.trace_on(NULL,'REQID'); -- Pipe name REQIDnnnnnn
      debug(':Switching on the Trace: ',000);

    END IF; -- NVL(p_trace_on,'N') = 'Y'
    --
  END IF; -- if nested level = 0

  g_nested_level :=  g_nested_level + 1;
  debug('Entered: '||NVL(p_proc_name,g_proc_name),g_nested_level*100);

END debug_enter;

--
-- debug_exit
--   The exception handler of top level functions must call debug_ext
--   with p_trace_off = 'Y'

PROCEDURE debug_exit
  (p_proc_name IN VARCHAR2 default null
  ,p_trace_off IN VARCHAR2 default null
  )
IS
BEGIN

  debug('Leaving: '||NVL(p_proc_name,g_proc_name),-g_nested_level*100);
  g_nested_level := g_nested_level - 1;
  debug('g_nested level is '||g_nested_level,000);

  -- debug enter sets trace ON when g_trace = 'Y' and nested level = 0
  -- so we must turn it off for the same condition
  -- Also turn off tracing when the override flag of p_trace_off has been passed as Y
  IF (g_nested_level = 0
      AND
      g_trace = 'Y'
     )
     OR
     NVL(p_trace_off,'N') = 'Y' THEN
    debug(':Switching off the Trace: ',000);
    hr_utility.trace_off;

  END IF; -- (g_nested_level = 0

END debug_exit;


--
-- ----------------------------------------------------------------------------
-- |------------------------< set_effective_dates >---------------------------|
-- ----------------------------------------------------------------------------

Procedure set_effective_dates
  is
--
  l_year       number;
  l_proc_name  varchar2(60) := g_proc_name || 'set_effective_dates';
--
Begin

  --
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  --
  debug_enter(l_proc_name);

  If to_number(to_char(g_effective_date, 'MM'))
       between 1 and 3 Then

     -- Pension year should start YY - 2
     l_year := to_number(to_char(g_effective_date, 'YYYY')) - 2;

  Else

    -- Pension year should start YY - 1
    l_year := to_number(to_char(g_effective_date, 'YYYY')) - 1;

  End If; -- End if of month check...

  debug(':l_year:'||l_year,500);

  g_effective_start_date := to_date('01/04/'||to_char(l_year), 'DD/MM/YYYY');
  g_effective_end_date   := to_date('31/03/'||to_char(l_year+1)||
                              '23:59:59', 'DD/MM/YYYY HH24:MI:SS');

  debug(':g_effective_start_date:'||g_effective_start_date,510);
  debug(':g_effective_end_date:'||g_effective_end_date,520);
  debug(':g_header_system_element:'||g_header_system_element,525);

  g_header_system_element:=
        g_header_system_element||
        fnd_date.date_to_canonical(g_effective_start_date)||':'||
        fnd_date.date_to_canonical(g_effective_end_date)||':'||
        fnd_date.date_to_canonical(g_effective_date)||':' ;


  pqp_gb_tp_pension_extracts.g_header_system_element := g_header_system_element;



  --debug(':g_header_system_element:'||g_header_system_element,530);
  --
  hr_utility.set_location('Leaving: '||l_proc_name, 15);
  --
  debug_exit(l_proc_name);


End set_effective_dates;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_pay_bal_id >------------------------------|
-- ----------------------------------------------------------------------------

Function get_pay_bal_id
  (p_balance_name in     varchar2)
  Return number is
--
  l_proc_name        varchar2(60) := g_proc_name || 'get_pay_bal_id';
  l_bal_type_id      csr_get_pay_bal_id%rowtype;
--
Begin


  debug_enter(l_proc_name);

  debug(':p_balance_name:'||p_balance_name,1000);

  Open csr_get_pay_bal_id
    (c_balance_name => p_balance_name);
  Fetch csr_get_pay_bal_id into l_bal_type_id;
  Close csr_get_pay_bal_id;

  debug(':l_bal_type_id.balance_type_id:'||l_bal_type_id.balance_type_id,1100);

  debug_exit(l_proc_name);
  --

  Return l_bal_type_id.balance_type_id;

End get_pay_bal_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_pay_ele_ids_from_bal >---------------------|
-- ----------------------------------------------------------------------------

Procedure get_pay_ele_ids_from_bal
  (p_balance_type_id      in     number
  ,p_effective_start_date in     date
  ,p_effective_end_date   in     date
  ,p_tab_ele_ids          out nocopy    t_ele_ids_from_bal
  ) is
--
  l_proc_name        varchar2(60) := g_proc_name || 'get_pay_ele_ids_from_bal';
  l_ele_ids          csr_get_pay_ele_ids_from_bal%rowtype;
  idx                number := 1;
  i                  number := 1;
--
Begin


  debug_enter(l_proc_name);
  debug(l_proc_name, 900);
  debug(':p_balance_type_id:'||p_balance_type_id);
  debug(':p_effective_start_date:'||p_effective_start_date);
  debug(':p_effective_end_date:'||p_effective_end_date);

  Open csr_get_pay_ele_ids_from_bal
    (c_balance_type_id      => p_balance_type_id
    ,c_effective_start_date => p_effective_start_date
    ,c_effective_end_date   => p_effective_end_date);
  Loop

    Fetch csr_get_pay_ele_ids_from_bal into l_ele_ids;
    Exit when csr_get_pay_ele_ids_from_bal%notfound;

      --get the valid element type ids for this BG.
      IF (
         pqp_gb_t1_pension_extracts.g_lea_business_groups.exists(l_ele_ids.business_group_id)
         OR
         g_business_group_id = l_ele_ids.business_group_id
         )
         THEN
          p_tab_ele_ids(i) := l_ele_ids;
          debug(':i:'||i, 910 + idx/1000000);
          debug(':l_ele_ids eleement type id :'||l_ele_ids.element_type_id, 920 + idx/1000000);
          debug(':l_ele_ids business group id :'||l_ele_ids.business_group_id, 930 + idx/1000000);
          i := i + 1;
      END IF;
      --
      idx := idx + 1 ;
  End Loop;

  If csr_get_pay_ele_ids_from_bal%ROWCOUNT = 0 Then

     g_error_number := 93000;
     g_error_text   := 'BEN_93000_EXT_TP2_BAL_NOFEEDS';
     debug(':csr_get_pay_ele_ids_from_bal%rowcount = 0', 940 );

  End If;
  Close csr_get_pay_ele_ids_from_bal;

  debug_exit(l_proc_name);

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Entering excep:'||l_proc_name, 25);

       p_tab_ele_ids.delete;

       RAISE;

End get_pay_ele_ids_from_bal;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_type2_globals >--------------------------|
-- ----------------------------------------------------------------------------

Procedure set_type2_globals
  is
--
  l_proc_name    varchar2(60) := g_proc_name || 'set_type2_globals';

--
Begin

  --
  debug_enter(l_proc_name);
  --ENH3 And ENH4.
  -- Set the globals in this package  from type 4

  -- ********* Variables ***************

    g_lea_number                  := pqp_gb_tp_pension_extracts.g_lea_number;
    g_crossbg_enabled             := pqp_gb_tp_pension_extracts.g_crossbg_enabled;
    g_estb_number                 := pqp_gb_tp_pension_extracts.g_estb_number;
    -- "end of day" of a day before effective date
    g_effective_run_date :=
        fnd_date.canonical_to_date(TO_CHAR(g_effective_date - 1,'YYYY/MM/DD')||'23:59:59');
-- ********* Ennd of Variables ***************


  debug(':g_estb_number:'||g_estb_number,210 );
  debug(':g_crossbg_enabled:'||g_crossbg_enabled,220);

/* Commented out as this is now being done in Type 4 set globals
  -- If its the LEA run
  -- AND current BG is enabled for cross BG reporting
  IF g_estb_number = '0000'
     AND
     g_crossbg_enabled = 'Y'
  THEN
    -- Store all BGs with same LEA Number and
    -- enabled for cross BG reporting

    pqp_gb_t1_pension_extracts.g_nested_level := g_nested_level;

    pqp_gb_t1_pension_extracts.store_cross_bg_details;

    pqp_gb_t1_pension_extracts.g_nested_level := 0;

  ELSE -- Non-LEA Run
    g_master_bg_id := g_business_group_id;
  END IF;

  --ENH3 And ENH4.
*/

  --
  -- Get balance type id for additional contribution balance
  --
  debug(':g_add_cont_balance_name:'||g_add_cont_balance_name,230 );

  g_add_cont_bal_id := get_pay_bal_id
                         (p_balance_name  => g_add_cont_balance_name
                         );
  debug(':g_add_cont_bal_id:'||g_add_cont_bal_id,240 );


  If g_add_cont_bal_id is not null Then

    --
    -- Get Additional Contribution Elements
    --
    get_pay_ele_ids_from_bal
      (p_balance_type_id      => g_add_cont_bal_id
      ,p_effective_start_date => g_effective_start_date
      ,p_effective_end_date   => g_effective_end_date
      ,p_tab_ele_ids          => g_add_cont_ele_ids
      );

  Else

    g_error_number := 92999;
    g_error_text   := 'BEN_92999_EXT_TP2_BAL_NOTFOUND';

  End If; -- End if of cont bal id check...

  debug('g_error_number '||g_error_number,250);
  debug('g_error_text '||g_error_text,260);

  debug_exit(l_proc_name);

End set_type2_globals;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< calc_add_cont >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure calc_add_cont
  (p_assignment_id         in     number
  ,p_effective_start_date  in     date
  ,p_effective_end_date    in     date
  ) is
--
  l_proc_name      varchar2(60) := g_proc_name || 'calc_add_cont';
  l_add_cont_value number := 0;
  l_effective_date date;
  idx              number := 1;
--
Begin


  debug_enter(l_proc_name);
  debug(l_proc_name, 800) ;
  debug(':p_assignment_id:'||p_assignment_id ,810);
  debug(':p_effective_start_date:'||p_effective_start_date ,820);
  debug(':p_effective_end_date:'||p_effective_end_date ,830);



  Open csr_get_end_date
    (c_assignment_id        => p_assignment_id
    ,c_effective_start_date => p_effective_start_date
    ,c_effective_end_date   => p_effective_end_date
    );
  Loop

    Fetch csr_get_end_date into l_effective_date;
    Exit when csr_get_end_date%notfound;

    debug(':l_effective_date:'||l_effective_date, 840 + idx/10000 );
    debug(':g_add_cont_bal_id:'||g_add_cont_bal_id, 850 + idx/10000 );
    --

    l_add_cont_value := hr_gbbal.calc_asg_proc_ptd_date
                          (p_assignment_id   => p_assignment_id
                          ,p_balance_type_id => g_add_cont_bal_id
                          ,p_effective_date  => l_effective_date
                          );

    debug(':l_add_cont_value:'||l_add_cont_value, 860 + idx/10000 );

    If g_add_cont_value.exists(p_assignment_id) Then

      debug(':inside IF of add cont value exists', 870+ idx/10000 );

      g_add_cont_value(p_assignment_id) := g_add_cont_value(p_assignment_id) +
        (l_add_cont_value * 100);

    Else

      debug(':inside ELSE of add cont value exists', 880 + idx/10000);

      g_add_cont_value(p_assignment_id) := l_add_cont_value * 100;

    End If; -- End if of add cont value exists check...
    idx := idx + 1 ;
  End Loop;
  Close csr_get_end_date;

  debug_exit(l_proc_name);

End calc_add_cont;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_eet_info >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure get_eet_info
  (p_assignment_id        in     number
  ,p_effective_start_date in     date
  ,p_effective_end_date   in     date
  ,p_location_id          in     number
  ,p_business_group_id    in     number        --ENH8
  ,p_return_status        out nocopy boolean   --ENH3 And ENH4
  )
  is
--
  l_proc_name    varchar2(60) := g_proc_name || 'get_eet_info';
  l_eet_details  csr_get_eet_info%rowtype;
  l_ele_exists   varchar2(1)  := 'N';
  idx            number  := 1;

--
Begin

  --
  debug_enter(l_proc_name);
  debug(l_proc_name,600) ;
  debug(':p_assignment_id:'||p_assignment_id,610 );
  debug(':p_effective_start_date:'||p_effective_start_date,620 );
  debug(':p_effective_end_date:'||p_effective_end_date,630 );
  debug(':p_location_id:'||p_location_id ,640);


  --ENH3 And ENH4.The g_add_cont_ele_ids contains a collection of all the element type ids
  --linked to the Total Additional Contribution Balance across business groups.
  For i in 1..g_add_cont_ele_ids.count Loop

       debug('g_add_cont_ele_ids.count'||g_add_cont_ele_ids.count, 660 + i/10000 );
       debug('g_add_cont_ele_ids.bg id'||g_add_cont_ele_ids(i).business_group_id, 670 + i/10000 );
       debug('g_add_cont_ele_ids.element_type_id'||
       g_add_cont_ele_ids(i).element_type_id, 680 + i/10000 );
       debug('p_business_group_id '||p_business_group_id, 685 + i/10000 );


      --ENH3 And ENH4.check if the business group id is present in the global collection.
      IF (  NVL(g_add_cont_ele_ids(i).business_group_id,p_business_group_id)
            = p_business_group_id
         )
       THEN

         idx := 1;

         -- Check element entries exist with additional cont ele's
         Open csr_get_eet_info
         (c_assignment_id        => p_assignment_id
         ,c_effective_start_date => p_effective_start_date
         ,c_effective_end_date   => p_effective_end_date
         ,c_element_type_id      => g_add_cont_ele_ids(i).element_type_id --ENH8
         );
         Loop

         Fetch csr_get_eet_info into l_eet_details;
         Exit when csr_get_eet_info%notfound;


   --      Check atleast one add cont element exists
           IF l_eet_details.element_type_id IS NOT NULL THEN

               debug('element entry found  ', 690 + idx/10000 );
               debug(':l_eet_details.element_type_id :'||l_eet_details.element_type_id, 650 + idx/1000000 );

               l_ele_exists := 'Y';

               debug(':estb_number:'||pqp_gb_tp_pension_extracts.g_criteria_estbs(p_location_id).estb_number, 710 + idx/10000 );

               --ENH3 And ENH4
               p_return_status := true;
               debug('return status is true',720 + idx/10000);
               Exit;

            End If; -- End of l_eet_details check

        idx := idx + 1;

       End Loop;--End of csr_get_eet_info
       Close csr_get_eet_info;

    END IF;--business_group_id check

  End Loop;--g_add_cont_ele_ids

  If l_ele_exists = 'Y' Then

    debug('inside If l_ele_exists =Y ', 730  );

    -- Calculate additional contribution for this effective date
    calc_add_cont
      (p_assignment_id        => p_assignment_id
      ,p_effective_start_date => p_effective_start_date
      ,p_effective_end_date   => p_effective_end_date
      );

  End If; -- End if of add cont element entry exists ...

  debug_exit(l_proc_name);
EXCEPTION
  WHEN OTHERS THEN
  p_return_status := NULL;
  RAISE ;

End get_eet_info;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_asg_info >-------------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_asg_info
  (p_assignment_id        in               number
  ,p_effective_start_date in out nocopy    date       --ENH3 And ENH4
  ,p_effective_end_date   in               date
  ,p_location_id          out nocopy       number     --ENH3 And ENH4
  ,p_ext_emp_cat_cd       out nocopy       varchar2   --ENH3 And ENH4
  ) RETURN BOOLEAN                              --ENH3 And ENH4
  is
--
  l_proc_name        varchar2(60) := g_proc_name || 'get_asg_info';
  i                  number       := 0;
  l_asg_details      csr_get_asg_info%rowtype;
  l_next_asg_details csr_get_asg_info%rowtype;
  l_tab_asg_details  t_asg_info;
  l_return_status    boolean := false ;          --ENH3 And ENH4
  idx                NUMBER;
  idy                NUMBER;
  l_ext_emp_cat_cd   VARCHAR2(10);
  l_effective_start_date DATE;
  l_location_id      hr_location_extra_info.location_id%TYPE;
  l_asg_emp_cat_cd   per_all_assignments_f.employment_category%TYPE;
  l_business_group_id per_all_assignments_f.business_group_id%TYPE;

--
Begin

  --
  debug_enter(l_proc_name);
  debug(l_proc_name,310) ;
  debug(':p_assignment_id:'||p_assignment_id ,320);
  debug(':p_effective_start_date:'||p_effective_start_date ,330);
  debug(l_proc_name ||':p_effective_end_date:'||p_effective_end_date ,340);

  idx := 0;

  Open csr_get_asg_info
    (c_assignment_id        => p_assignment_id
    ,c_effective_start_date => p_effective_start_date
    ,c_effective_end_date   => p_effective_end_date
    );

  Loop -- Loop 1
    Fetch csr_get_asg_info into l_asg_details;
    Exit when csr_get_asg_info%notfound;

    idx := idx + 1;


    debug(':inside Loop 1', 350 +idx/10000) ;
    debug(':l_asg_details.person_id:'||l_asg_details.person_id, 360 +idx/10000);
    debug(':l_asg_details.assignment_id:'||l_asg_details.assignment_id ,370 +idx/10000);
    debug(':l_asg_details.location_id:'||l_asg_details.location_id ,380 +idx/10000);
    debug(':l_asg_details.business_group_id:'||l_asg_details.business_group_id ,390+idx/10000);

    -- Check whether the establishment is a criteria establishment
    If pqp_gb_tp_pension_extracts.g_criteria_estbs.exists(l_asg_details.location_id) Then

         i := i + 1;

         l_tab_asg_details(i) := l_asg_details;

         -- Check whether the next assignment row has a location
         -- Change or not
         idy := 0;

         Loop -- Loop 2
           Fetch csr_get_asg_info into l_next_asg_details;
           Exit when csr_get_asg_info%notfound;

           idy := idy + 1;

           debug(':inside Loop 2', 390 +idy/10000) ;
	   debug(':l_next_asg_details.person_id:'||l_next_asg_details.person_id , 410 + idy/10000);
           debug(':l_next_asg_details.assignment_id:'||l_next_asg_details.assignment_id,420 + idy/10000);
           debug(':l_next_asg_details.location_id:'||l_next_asg_details.location_id,430 + idy/10000 );

           If pqp_gb_tp_pension_extracts.g_criteria_estbs.exists(l_next_asg_details.location_id) Then

	      debug(':inside if ', 440 +idy/10000) ;
              -- Extend the effective end date
              l_tab_asg_details(i).effective_end_date :=
              l_next_asg_details.effective_end_date;

           Else
             debug(':inside else ', 450 +idy/10000) ;
             Exit;

           End If; -- End if of estb check...
        End Loop; -- End of Loop 2...

      End If; -- End if of estb check...

  End Loop; -- End of loop 1...
  Close csr_get_asg_info;

  -- Check atleast one assignment qualifies for type 2
  If l_tab_asg_details.count > 0 Then

      debug(':inside If l_tab_asg_details.count > 0  ', 460) ;

      debug(':l_tab_asg_details(1).person_id:' ||l_tab_asg_details(1).person_id, 480) ;

      l_return_status := false;

      For i in 1..l_tab_asg_details.count Loop


       debug('inside For ', 490 + i/10000) ;
       debug(':l_tab_asg_details(i).person_id:' ||l_tab_asg_details(i).person_id, 510+i/10000) ;
       debug(':l_tab_asg_details(i).assignment_id:' ||l_tab_asg_details(i).assignment_id,520+i/10000) ;
       debug(':l_tab_asg_details(i).location_id:' ||l_tab_asg_details(i).location_id ,530+i/10000) ;

       l_location_id := l_tab_asg_details(i).location_id;
       l_effective_start_date := l_tab_asg_details(i).effective_start_date;
       l_asg_emp_cat_cd := l_tab_asg_details(i).asg_emp_cat_cd;
       l_business_group_id :=  l_tab_asg_details(i).business_group_id;
       --
       -- Check whether additional contribution element exists
       --

       get_eet_info
           (p_assignment_id        => l_tab_asg_details(i).assignment_id
           ,p_effective_start_date => l_tab_asg_details(i).effective_start_date
           ,p_effective_end_date   => l_tab_asg_details(i).effective_end_date
           ,p_location_id          => l_tab_asg_details(i).location_id
           ,p_business_group_id    => l_tab_asg_details(i).business_group_id
           ,p_return_status        => l_return_status      -- OUT
           );

     End Loop;

  End If; -- End if of assignment qual for type2 check...

  IF l_return_status THEN

     l_ext_emp_cat_cd := pqp_gb_t1_pension_extracts.Get_Translate_Asg_Emp_Cat_Code
                         (
                           l_asg_emp_cat_cd
                          ,p_effective_start_date
                          ,'Pension Extracts Employment Category Code'
                          ,l_business_group_id
                         );

     debug('l_ext_emp_cat_cd is '|| l_ext_emp_cat_cd,171);

     l_ext_emp_cat_cd := nvl(l_ext_emp_cat_cd,'F');

     IF l_ext_emp_cat_cd = 'P' THEN

        pqp_gb_t1_pension_extracts.g_part_time_asg_count :=
        pqp_gb_t1_pension_extracts.g_part_time_asg_count + 1;
        debug('Incrementing part time assignment count',172);

     END IF;
     -- Commented below to fix bug 7476796
     -- p_effective_start_date := l_effective_start_date;
     p_location_id := l_location_id;
     p_ext_emp_cat_cd := l_ext_emp_cat_cd;

  END IF;-- return_status

  RETURN l_return_status;

  debug_exit(l_proc_name);

EXCEPTION
  WHEN OTHERS THEN

  p_effective_start_date := NULL;
  p_location_id := NULL;


  RAISE ;

End get_asg_info;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_aat_info >-------------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_aat_info
  (p_assignment_id        in    number
  ,p_effective_start_date in    date
  ,p_effective_end_date   in    date
  ,p_ext_emp_cat_cd       in    varchar2    --ENH3 And ENH4
  ,p_location_id          in    number      --ENH3 And ENH4
  ) RETURN BOOLEAN                          --ENH3 And ENH4
  is
--
  l_proc_name     varchar2(60) := g_proc_name || 'get_aat_info';
  i               number := 0;
  l_aat_info      csr_get_aat_info%rowtype;
  l_next_aat_info csr_get_aat_info%rowtype;
  l_tab_aat_info  t_aat_info;
  l_teacher       boolean := true;          --ENH3 And ENH4
  idx             NUMBER;
  idy             NUMBER;
  l_estb_number   VARCHAR2(10);
  l_estb_type     VARCHAR2(200);
--
Begin


  debug_enter(l_proc_name);
  debug(l_proc_name,210) ;
  debug(':p_assignment_id:'||p_assignment_id ,220);
  debug(':p_effective_start_date:'||p_effective_start_date ,230);
  debug(':p_effective_end_date:'||p_effective_end_date ,240 );
  debug(':p_location_id:'||p_location_id ,245 );

  idx := 0;

  Open csr_get_aat_info
    (c_assignment_id        => p_assignment_id
    ,c_effective_start_date => p_effective_start_date
    ,c_effective_end_date   => p_effective_end_date
    );
  Loop -- Loop 1


    Fetch csr_get_aat_info into l_aat_info;
    Exit when csr_get_aat_info%notfound;

    idx := idx + 1;

      --
      debug(':inside Loop 1', 250 + idx/10000) ;
      debug(':l_aat_info.assignment_attribute_id:'||l_aat_info.assignment_attribute_id ,260  + idx/10000);
      debug(':l_aat_info.assignment_id:'||l_aat_info.assignment_id ,270  + idx/10000);
      debug(':l_aat_info.effective_start_date:'||l_aat_info.effective_start_date,280  + idx/10000);
      debug(':l_aat_info.effective_end_date:'||l_aat_info.effective_end_date,290  + idx/10000);
      debug(':l_aat_info.tp_is_teacher:'||l_aat_info.tp_is_teacher,310  + idx/10000);
      debug(':l_aat_info.tp_elected_pension:'||l_aat_info.tp_elected_pension,320  + idx/10000);
      --

       i := i + 1;
       l_tab_aat_info(i) := l_aat_info;

       idy := 0;

       Loop -- Loop 2

         -- Check whether the subsequent row qualifies the below cond
         --
         Fetch csr_get_aat_info into l_next_aat_info;
         Exit when csr_get_aat_info%notfound;

         idy := idy + 1;
	  --
 	  debug(':inside Loop 2', 330 + idy/10000 ) ;
          debug(':l_next_aat_info.assignment_attribute_id:'||l_next_aat_info.assignment_attribute_id,340 + idy/10000 );
          debug(':l_next_aat_info.assignment_id:'||l_next_aat_info.assignment_id,350 + idy/10000 );
          debug(':l_next_aat_info.effective_start_date:'||l_next_aat_info.effective_start_date,360  + idy/10000 );
          debug(':l_next_aat_info.effective_end_date:'||l_next_aat_info.effective_end_date,370  + idy/10000 );
          debug(':l_next_aat_info.tp_is_teacher:'||l_next_aat_info.tp_is_teacher,380  + idy/10000 );
          debug(':l_next_aat_info.tp_elected_pension:'||l_next_aat_info.tp_elected_pension,390  + idy/10000 );
          --

         If nvl(l_next_aat_info.tp_is_teacher, hr_api.g_varchar2) =
              nvl(l_tab_aat_info(i).tp_is_teacher, hr_api.g_varchar2)
         and
            nvl(l_next_aat_info.tp_elected_pension, hr_api.g_varchar2) =
              nvl(l_tab_aat_info(i).tp_elected_pension, hr_api.g_varchar2)
         Then

            --
            -- Adjust the effective end date of the previous row to
            -- this one
            --
            l_tab_aat_info(i).effective_end_date :=
              l_next_aat_info.effective_end_date;

         Else

           i := i + 1;
           l_tab_aat_info(i) := l_next_aat_info;

         End If; -- End if of subsequent row check for teacher ...

      End Loop; -- End Loop 2 ...

  End Loop; -- End Loop 1 ...
  Close csr_get_aat_info;

  --
  -- Check atleast one assignment attribute for the given assignment
  -- exists
  --
  If l_tab_aat_info.count > 0 Then

     --
     debug(l_proc_name ||':inside If l_tab_aat_info.count > 0 ', 410 ) ;
     --
     For i in 1..l_tab_aat_info.count Loop
       --

       debug('inside For ', 420 + i/1000000) ;
       debug(':l_tab_aat_info(i).assignment_attribute_id:'||l_tab_aat_info(i).assignment_attribute_id,430 + i/1000000);
       debug(':l_tab_aat_info(i).assignment_id:'||l_tab_aat_info(i).assignment_id,440 + i/1000000);
       debug(':l_tab_aat_info(i).effective_start_date:'||l_tab_aat_info(i).effective_start_date , 450 + i/1000000);
       debug(':l_tab_aat_info(i).effective_end_date:'||l_tab_aat_info(i).effective_end_date ,460 + i/1000000);
       debug(':l_tab_aat_info(i).tp_is_teacher:'||l_tab_aat_info(i).tp_is_teacher ,470 + i/1000000);
       debug(':l_tab_aat_info(i).tp_elected_pension:'||l_tab_aat_info(i).tp_elected_pension ,480 + i/1000000);
       l_estb_number := pqp_gb_tp_pension_extracts.g_criteria_estbs(p_location_id).estb_number;
       l_estb_type := pqp_gb_tp_pension_extracts.g_criteria_estbs(p_location_id).estb_type;

       debug(':l_estb_number:'||l_estb_number,490 + i/1000000);
       debug(':p_ext_emp_cat_cd:'||p_ext_emp_cat_cd,490 + i/1000000);
       debug(':l_estb_type:'||l_estb_type,490 + i/1000000);

       --
       -- Assignment attribute exists
       -- get assignment information
       --
       -- Check whether this assignment attribute is a teacher and
       -- has elected pension

       IF (nvl(l_tab_aat_info(i).tp_is_teacher,'NONT') IN ('TCHR', 'TTR6')) THEN

           IF (
               nvl(l_tab_aat_info(i).tp_elected_pension,'X') = 'N'
               AND
               (
                 l_estb_number = '0966'
                 OR
                 (p_ext_emp_cat_cd = 'P'
                  AND
                  l_estb_type <> 'LEA_ESTB'
                 )
                 OR
                ( p_ext_emp_cat_cd = 'F'
                  AND
                  l_estb_type = 'IND_ESTB'
                )
               )
              ) THEN

                debug('not a teacher hence warn', 510) ;
                l_teacher := false;
              ELSE
                debug('is a teacher hence continue', 513) ;
                -- established that asg was a teacher in the year,
                -- we no longer need to check further
                l_teacher := true;
                exit;

            END IF;

       ELSE

           debug('not a teacher hence warn', 515) ;
           l_teacher := false;

       END IF;  -- End if of teacher and pension check...

     End Loop;

  Else

    --the assignment does not have an entry for teacher.
    debug(':inside Else of If l_tab_aat_info.count > 0 ', 520) ;
    l_teacher := false;


  End If; -- End if of assignment attribute check...

  return l_teacher;

  debug_exit(l_proc_name);

End get_aat_info;
--


-- ENH3 And ENH4
-- ----------------------------------------------------------------------------
-- |-----------------------< get_all_secondary_asgs >-----------------------|
-- ----------------------------------------------------------------------------
--

FUNCTION get_all_secondary_asgs
   (p_primary_assignment_id     IN NUMBER
   ,p_effective_date            IN DATE
   ,p_person_id                 IN NUMBER
   ) RETURN pqp_gb_t1_pension_extracts.t_sec_asgs_type
IS

  -- Rowtype Variable Declaration
  l_sec_asgs            pqp_gb_t1_pension_extracts.csr_sec_assignments%ROWTYPE;
  l_all_sec_asgs        pqp_gb_t1_pension_extracts.t_sec_asgs_type;
  idx                   NUMBER;

  --
  l_proc_name          VARCHAR2(61):=
     g_proc_name||'get_all_secondary_asgs';

BEGIN -- get_all_secondary_asgs

  debug_enter(l_proc_name);

  debug(' p_primary_assignment_id '||p_primary_assignment_id,10);
  debug(' p_person_id '||  p_person_id  ,20);
  debug(' p_effective_date '||p_effective_date,30);
  debug(' g_effective_run_date '||g_effective_run_date,40);
  debug(' g_cross_per_enabled '||g_cross_per_enabled,50);
  debug(' g_business_group_id '||g_business_group_id,60);

  --to be removed later
--  g_cross_per_enabled := 'Y';

  -- Fetch secondary assignments
  idx := 0;

  FOR l_sec_asgs IN pqp_gb_t1_pension_extracts.csr_sec_assignments(p_primary_assignment_id
                                       ,p_person_id
                                       ,p_effective_date
                                       )
  LOOP

    idx := idx + 1;

    debug('adding secondary assignment to the collection '||l_sec_asgs.assignment_id,80 + idx/10000);
    -- Add this to the table of valid secondary asgs
    l_all_sec_asgs(l_sec_asgs.assignment_id) := l_sec_asgs;

    --
  END LOOP; -- l_sec_asg_details IN csr_sec_asg_details

  debug_exit(l_proc_name);
  --
  RETURN l_all_sec_asgs;
  --
EXCEPTION
  WHEN OTHERS THEN

     hr_utility.set_location('Entering excep:'||l_proc_name, 35);
     hr_utility.set_location('SQLCODE :'||SQLCODE, 40);
     hr_utility.set_location('SQLERRM :'||SQLERRM, 50);
    debug_exit(' Others in '||l_proc_name);
    RAISE;
END; -- get_all_secondary_asgs

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_teacher_qual_for_tp2 >-----------------------|
-- ----------------------------------------------------------------------------
--

Function chk_teacher_qual_for_tp2
  (p_business_group_id        in      number  -- context
  ,p_effective_date           in      date    -- context
  ,p_assignment_id            in      number  -- context
  ,p_error_text                   out nocopy    varchar2
  ,p_error_number                 out nocopy     number
  -- ,p_trace                    in      varchar2  default null
  ) return varchar2                           -- Y or N
  is
--
  l_inclusion_flag   varchar2(20)  := 'N';
  l_sec_assignments  pqp_gb_t1_pension_extracts.t_sec_asgs_type;
  l_is_a_teacher     varchar2(1) := 'Y';
  l_person_id        per_all_people_f.person_id%TYPE;
  l_start_date       DATE;
  l_proc_name        varchar2(61) := g_proc_name || 'chk_teacher_qual_for_tp2';
  l_curr_sec_asg_id  per_all_assignments_f.assignment_id%TYPE;
  l_prev_sec_asg_id  per_all_assignments_f.assignment_id%TYPE;
  idx                NUMBER;
  l_first_time       BOOLEAN := TRUE;  --Flag to add sec asg details to primary asg
                                       -- if primary is not valid asg.
  l_business_group_id NUMBER;
  l_asg_cat_cd        VARCHAR2(10);
  l_location_id       hr_location_extra_info.location_id%TYPE;
  l_ext_emp_cat_cd   VARCHAR2(10);
  l_effective_start_date DATE;

--
Begin

  l_effective_start_date := null;
  debug_enter(l_proc_name);
  debug(l_proc_name,10) ;
  debug(':p_assignment_id:'||p_assignment_id ,20);
  debug(':p_effective_date:'||p_effective_date ,30 );
  debug(':p_business_group_id:'||p_business_group_id ,40);

   OPEN csr_get_person_id(p_assignment_id);
   FETCH csr_get_person_id INTO l_person_id,l_business_group_id;
   CLOSE csr_get_person_id;

  debug(':l_person_id:'||l_person_id ,50);
  debug(':l_business_group_id:'||l_business_group_id ,55);


  g_inclusion_flag := 'N';
  g_error_text     := null;
  g_error_number   := null;

  -- Bug fix 2848696
  -- Effective date passed should be the actual effective date
  -- passed whilst submitting extract process
  -- and not the session date

  If g_business_group_id is null Then

     debug(':inside If g_business_group_id is null', 60 );
     --ENH3 And ENH4 .Added the new parameter lea number.

     pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;



     pqp_gb_tp_pension_extracts.set_extract_globals (p_business_group_id
                                                    -- ,p_effective_date
                                                    ,ben_ext_person.g_effective_date
                                                    ,p_assignment_id
                                                    );

     pqp_gb_tp_pension_extracts.g_nested_level := 0;


     g_business_group_id     := pqp_gb_tp_pension_extracts.g_business_group_id;
     g_effective_date        := pqp_gb_tp_pension_extracts.g_effective_date;
     g_header_system_element := pqp_gb_tp_pension_extracts.g_header_system_element;

     debug(':g_business_group_id:'||g_business_group_id,80 );
     debug(':g_effective_date:'||g_effective_date,90 );
     debug(':g_header_system_element:'||g_header_system_element,110 );


     g_add_cont_ele_ids.delete;

     set_effective_dates;

     set_type2_globals;

     --set the g_effective_run_date for type1 as its being used in csr_sec_assignments.
     pqp_gb_t1_pension_extracts.g_effective_run_date := g_effective_run_date;

     If g_error_number is not null Then

       debug(':inside If g_error_number is not null'||g_error_number, 120 );
       debug('g_error_text '||g_error_text,130);
       p_error_text     := g_error_text;
       p_error_number   := g_error_number;
       l_inclusion_flag := 'ERROR';
       debug('l_inclusion_flag '||l_inclusion_flag,140);
       Return l_inclusion_flag;

     End If; -- End if of error check...

  End If;-- end of g_business_group_id is null

  l_effective_start_date := g_effective_start_date;

  -- Bugfix -- Bugfix 3671727: Performance enhancement
  --    If no location exists in the list of valid criteria
  --    establishments, then no point doing all checks
  --    Just warn once and skip every assignment
  IF pqp_gb_tp_pension_extracts.g_criteria_estbs.COUNT = 0 THEN

    debug('Setting inclusion flag to N as no locations EXIST.', 145);
    l_inclusion_flag := 'N';

    pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
    -- Call TP4 pkg proc to warning for no locations
    pqp_gb_tp_pension_extracts.warn_if_no_loc_exist
        (p_assignment_id => p_assignment_id) ;
    pqp_gb_tp_pension_extracts.g_nested_level := 0;

    RETURN l_inclusion_flag ; -- the assignment will eventually fail for validity as no location exists.

  END IF ;

  pqp_gb_t1_pension_extracts.g_part_time_asg_count := 0;

  -- Check if this person should be reported by the current run

    pqp_gb_t1_pension_extracts.g_nested_level := g_nested_level;

  IF pqp_gb_t1_pension_extracts.chk_report_person
     (p_business_group_id
     ,p_effective_date
     ,p_assignment_id
     )
     THEN

         debug('chk_report_person is true', 150 );

         debug('l_person_id is '||l_person_id, 160 );

       --ENH8:Added the code below here,so that it checks
       --if the assignment is a valid record for type 2.
       --before checking the assignment attributes.

       --
       -- Check if the person is eligible for Type 2 Report
       --

        --Y indicates that the record is a valid type 2 record.
        IF get_asg_info
          (
           p_assignment_id        => p_assignment_id
          ,p_effective_start_date => g_effective_start_date
          ,p_effective_end_date   => g_effective_end_date
          ,p_location_id          => l_location_id      -- OUT
          ,p_ext_emp_cat_cd       => l_ext_emp_cat_cd   -- OUT
          )
          THEN

           debug('get_asg_info is true ', 170 );

           g_inclusion_flag := 'Y';

           pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).person_id  :=
           l_person_id;

           pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).start_date :=
           g_effective_start_date;

           pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number :=
           pqp_gb_tp_pension_extracts.g_criteria_estbs(l_location_id).estb_number;

           debug('estb_number is  '||
           pqp_gb_tp_pension_extracts.g_criteria_estbs(l_location_id).estb_number
           , 175 );

           --
           -- Check the person is a teacher and has elected pension
           --
           debug('calling get_aat_info', 180) ;
           -- checks if the assignment is a teacher,
           -- else gives a warning.
           IF get_aat_info
                 (
                   p_assignment_id        => p_assignment_id
                  ,p_effective_start_date => g_effective_start_date
                  ,p_effective_end_date   => g_effective_end_date
                  ,p_ext_emp_cat_cd       => l_ext_emp_cat_cd
                  ,p_location_id          => l_location_id
                 )
              THEN

                  debug('get_aat_info is true'|| l_curr_sec_asg_id, 190 );
                  Null;

           ELSE

               debug('get_aat_info is false'|| l_curr_sec_asg_id, 210 );
               l_is_a_teacher := 'N';

           END IF;-- end if get_aat_info


       ELSE

          --if the primary assignment is not a valid type 2 record,set the report_asg
          --flag to 'N'
          pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).report_asg
          := 'N';

          debug('report_asg is N '|| p_assignment_id , 230 );

       End If; -- End if get_asg_info


      --End of ENH8.

      --ENH4:Earlier the check for type 2 records was carried out
      --for primary assignment only.
      --its now to be done for all the assignments.

     l_sec_assignments := get_all_secondary_asgs
                          (
                           p_primary_assignment_id => p_assignment_id
                          ,p_effective_date        => g_effective_start_date
                          ,p_person_id             => l_person_id
                          );

     idx := 0;

     IF l_sec_assignments.COUNT > 0 THEN

        debug('secondary assignments count > 0 ' , 240 );

        l_curr_sec_asg_id := l_sec_assignments.FIRST;

        WHILE l_curr_sec_asg_id IS NOT NULL
        LOOP

         idx := idx + 1;

         debug('seconday assignment found'|| l_curr_sec_asg_id, 250 + idx/10000);

         IF get_asg_info
            (
             p_assignment_id        => l_curr_sec_asg_id
            ,p_effective_start_date => g_effective_start_date
            ,p_effective_end_date   => g_effective_end_date
            ,p_location_id          => l_location_id      -- OUT
            ,p_ext_emp_cat_cd       => l_ext_emp_cat_cd   -- OUT
            )
            THEN

            debug('get_asg_info is true'|| l_curr_sec_asg_id, 260 + idx/10000);

            g_inclusion_flag := 'Y';

            pqp_gb_tp_pension_extracts.g_ext_asg_details(l_curr_sec_asg_id).person_id  :=
            l_person_id;

            pqp_gb_tp_pension_extracts.g_ext_asg_details(l_curr_sec_asg_id).start_date :=
            g_effective_start_date;

            pqp_gb_tp_pension_extracts.g_ext_asg_details(l_curr_sec_asg_id).estb_number :=
            pqp_gb_tp_pension_extracts.g_criteria_estbs(l_location_id).estb_number;

            debug('l_estb_number is  '||
            pqp_gb_tp_pension_extracts.g_criteria_estbs(l_location_id).estb_number
            ,265 );

            -- Check if hte Primary asg is not a valid asg
            -- then Add the secondary asg details at Primary asg also
            -- but only for the very first sec asg.

            IF l_first_time  --Should be TRUE for the first time..
               AND -- the primary asg is not a valid asg
              (pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).report_asg ='N') THEN

              debug ('Primary is not valid, adding details of sec to primary in global collection',267) ;

              pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).person_id   := l_person_id;
              pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).start_date  := g_effective_start_date; --l_start_date;
              pqp_gb_tp_pension_extracts.g_ext_asg_details(p_assignment_id).estb_number :=
              pqp_gb_tp_pension_extracts.g_criteria_estbs(l_location_id).estb_number;

              l_first_time := FALSE; -- reset the variable to prevent overwriting again and again.

            END IF;


           IF get_aat_info
                (
                  p_assignment_id        => l_curr_sec_asg_id
                 ,p_effective_start_date => g_effective_start_date
                 ,p_effective_end_date   => g_effective_end_date
                 ,p_ext_emp_cat_cd       => l_ext_emp_cat_cd
                 ,p_location_id          => l_location_id
                )
                THEN

                   debug('get_aat_info is true'|| l_curr_sec_asg_id, 270 + idx/10000);
                   Null;

            ELSE

                debug('get_aat_info is false'|| l_curr_sec_asg_id, 280 + idx/10000);
                l_is_a_teacher := 'N';

            END IF;-- get_aat_info

           --calculate the contributions and add them to the primary assignment
           IF g_add_cont_value.exists(l_curr_sec_asg_id) Then

              debug(':inside If g_add_cont_value.exists' , 290 + idx/10000);

              IF g_add_cont_value.exists(p_assignment_id) Then

                 g_add_cont_value(p_assignment_id) :=
                 g_add_cont_value(p_assignment_id) +
                 g_add_cont_value(l_curr_sec_asg_id);

              ELSE

                 g_add_cont_value(p_assignment_id) :=
                 g_add_cont_value(l_curr_sec_asg_id);

              END IF;

              debug(':g_add_cont_value(p_assignment_id):'||g_add_cont_value(p_assignment_id), 320 + idx/10000);

           END IF; -- End if of add cont value exist check...


          END IF;--get_asg_info

          -- Assign the current asg id to prev asg id
          -- and reset curr asg id, ready for the next one
          l_prev_sec_asg_id := l_curr_sec_asg_id;
          l_curr_sec_asg_id := NULL;

          l_curr_sec_asg_id := l_sec_assignments.NEXT(l_prev_sec_asg_id);

          debug('l_prev_sec_asg_id is '|| l_prev_sec_asg_id , 330 + idx/10000);
          debug('l_curr_sec_asg_id is '|| l_curr_sec_asg_id , 340 + idx/10000);


     END LOOP;--end of secondary assignments check

   END IF;--count of secondary assignments > 0

--     CLOSE csr_sec_assignments;

  END IF;--chk_report_person

  pqp_gb_t1_pension_extracts.g_nested_level := 0;

  l_inclusion_flag := g_inclusion_flag;
  --
  debug(':l_inclusion_flag:'||l_inclusion_flag, 350 );
  hr_utility.set_location('Leaving: '||l_proc_name, 360);
  --

     IF l_inclusion_flag = 'Y' THEN

       -- The following piece of code raises a warning if
       -- there exist more than one lea with the same lea Number within a BG.
       -- the warning is raised for the first valid assignment for a single Run.
       -- the flag for warning is set during the global setting through set_extract_globals.

        pqp_gb_tp_pension_extracts.g_nested_level := g_nested_level;
        pqp_gb_tp_pension_extracts.warn_if_multi_lea_exist (p_assignment_id => p_assignment_id);
        pqp_gb_tp_pension_extracts.g_nested_level := 0;

        IF l_is_a_teacher = 'N' THEN

           --set the warning
           g_error_number := 93007;
           g_error_text   := 'BEN_93007_EXT_TP2_NOT_TEACHER';

       END IF;

     END IF;

  p_error_number := g_error_number;
  p_error_text   := g_error_text;

  g_nested_level := 1;

  -- restoring the global start date for next asg
  g_effective_start_date := l_effective_start_date;

  debug_exit(l_proc_name
  ,'Y'-- turn trace off
  );
  Return l_inclusion_flag;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       if l_effective_start_date is not null
       then
            g_effective_start_date := l_effective_start_date;
       end if;
       hr_utility.set_location('Entering excep:'||l_proc_name, 35);
       hr_utility.set_location('SQLCODE :'||SQLCODE, 40);
       hr_utility.set_location('SQLERRM :'||SQLERRM, 50);
       p_error_number := SQLCODE;
       p_error_text   := SQLERRM;
       debug_exit(' Others in '||l_proc_name
                ,'Y' -- turn trace off
                );
       RAISE;

End chk_teacher_qual_for_tp2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_add_cont_value >-----------------------------|
-- ----------------------------------------------------------------------------
Function get_add_cont_value
  (p_assignment_id in     number)
  Return varchar2 is
--
  l_proc_name      varchar2(61) := g_proc_name || 'get_add_cont_value';
  l_add_cont_value number := 0;
  l_add_cont       varchar2(6);
--
Begin


  debug_enter(l_proc_name);
  debug(':p_assignment_id:'||p_assignment_id, 10 );



  If g_add_cont_value.exists(p_assignment_id) Then

    debug(':inside If g_add_cont_value.exists(p_assignment_id)', 20 );
    l_add_cont_value := g_add_cont_value(p_assignment_id);

  Else

     l_add_cont_value := 0;

  End If; -- End if of add cont value exists check...

  l_add_cont := lpad(l_add_cont_value,6,' ');
  debug(':l_add_cont:'||l_add_cont, 30 );

  debug_exit(l_proc_name);

  Return l_add_cont;

End get_add_cont_value;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_add_cont_refund_ind >------------------------|
-- ----------------------------------------------------------------------------
Function get_add_cont_refund_ind
  (p_assignment_id in     number)
  Return number is
--
  Cursor csr_translate_sign is
  select decode(sign(get_add_cont_value(p_assignment_id)),-1,1,0)
    from dual;

  l_proc_name    varchar2(61) := g_proc_name || 'get_add_cont_refund_ind';
  l_add_cont_ind number := 0;
--
Begin

  --
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  --
  debug_enter(l_proc_name);
  debug(':p_assignment_id:'||p_assignment_id, 1150 );


  Open csr_translate_sign;
  Fetch csr_translate_sign into l_add_cont_ind;
  Close csr_translate_sign;

  debug(':l_add_cont_ind:'||l_add_cont_ind, 1160 );
  --
  hr_utility.set_location('Leaving: '||l_proc_name, 15);
  --
  debug_exit(l_proc_name);

  Return l_add_cont_ind;

End get_add_cont_refund_ind;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_financial_year >-----------------------------|
-- ----------------------------------------------------------------------------
Function get_financial_year
  Return varchar2 is
--
  l_proc_name      varchar2(60) := g_proc_name || 'get_financial_year';
  l_financial_year varchar2(2);
--
Begin

  --
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  --
  debug_enter(l_proc_name);

  l_financial_year := TO_CHAR(g_effective_end_date, 'YY');

  --
  hr_utility.set_location('Leaving: '||l_proc_name, 15);
  --
  debug_exit(l_proc_name);

  Return l_financial_year;

End get_financial_year;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_total_add_cont >-----------------------------|
-- ----------------------------------------------------------------------------
Function get_total_add_cont
  Return varchar2 is
--
  Cursor csr_get_total_add_cont
     (p_ext_rcd_id    ben_ext_rcd.ext_rcd_id%TYPE)
  is
  select sum(dtl.val_10) total_value
    from ben_ext_rslt_dtl dtl
        --,ben_ext_rcd      rcd
  where  dtl.ext_rslt_id = ben_ext_thread.g_ext_rslt_id
    and  dtl.ext_rcd_id  = p_ext_rcd_id;
--    and  rcd.rcd_type_cd = 'D';

  l_proc_name             varchar2(60) := g_proc_name || 'get_total_add_cont';
  l_total_add_cont_value  number := 0;
  l_total_add_cont        varchar2(10);
  l_ext_rcd_id            ben_ext_rcd.ext_rcd_id%TYPE;
--
Begin

  --
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  --
  debug_enter(l_proc_name);

  -- 11.5.10_CU2: Performance fix :
  -- get the ben_ext_rcd.ext_rcd_id
  -- and use this one for next the cursor
  -- This will prevent FTS on the table.

  OPEN pqp_gb_t1_pension_extracts.csr_ext_rcd_id
                            (p_hide_flag       => 'N'
                            ,p_rcd_type_cd     => 'D'
                             );
  FETCH pqp_gb_t1_pension_extracts.csr_ext_rcd_id INTO l_ext_rcd_id;
  CLOSE pqp_gb_t1_pension_extracts.csr_ext_rcd_id ;

  debug('l_ext_rcd_id: '|| l_ext_rcd_id, 10) ;

  Open csr_get_total_add_cont(p_ext_rcd_id => l_ext_rcd_id );
  Fetch csr_get_total_add_cont into l_total_add_cont_value;
  Close csr_get_total_add_cont;

  debug(':l_total_add_cont_value:'||l_total_add_cont_value, 20 );
  debug(':g_total_add_cont:'||g_total_add_cont, 30 );

  g_total_add_cont := l_total_add_cont_value;

  l_total_add_cont := lpad(l_total_add_cont_value,10,' ');

  debug(':l_total_add_cont:'||l_total_add_cont, 40);

  --
  hr_utility.set_location('Leaving: '||l_proc_name, 50);
  --
  debug_exit(l_proc_name);

  Return l_total_add_cont;

End get_total_add_cont;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_total_add_cont_sign >------------------------|
-- ----------------------------------------------------------------------------
Function get_total_add_cont_sign
  Return number is
--
  Cursor csr_get_total_add_cont_sign is
  select decode(sign(g_total_add_cont),-1,1,0)
    from dual;

  l_proc_name        varchar2(60) := g_proc_name || 'get_total_add_cont_sign';
  l_total_refund_ind number ;
--
Begin

  --
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  --
  debug_enter(l_proc_name);

  Open csr_get_total_add_cont_sign;
  Fetch csr_get_total_add_cont_sign into l_total_refund_ind;
  Close csr_get_total_add_cont_sign;

  debug(':l_total_refund_ind:'||l_total_refund_ind, 1200 );
  --
  hr_utility.set_location('Leaving: '||l_proc_name, 15);
  --
  debug_exit(l_proc_name);

  Return l_total_refund_ind;

End get_total_add_cont_sign;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_lea_run >------------------------------|
-- ----------------------------------------------------------------------------
Function chk_lea_run
  Return varchar2 is
--
  l_proc_name      varchar2(60) := g_proc_name || 'chk_lea_run';
  l_lea_run        varchar2(1) := 'N';
--
Begin

  --
  hr_utility.set_location('Entering: '||l_proc_name, 5);
  --
  debug_enter(l_proc_name);

  If pqp_gb_tp_pension_extracts.g_estb_number = '0000' Then
     l_lea_run := 'Y';
  End If; -- End if of estb number check...

  debug(':l_lea_run:'||l_lea_run, 1300 );
  --
  hr_utility.set_location('Leaving: '||l_proc_name, 15);
  --
  debug_exit(l_proc_name);

  Return l_lea_run;

End chk_lea_run;



--
End pqp_gb_tp_type2_functions;

/
